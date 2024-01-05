//
//  CallTrace.swift
//  SwiftFramework
//
//  Created by kaki Yen on 2022/5/16.
//

import MachO
import Foundation
import SwiftFramework.CallTraceCode

extension NSNotification.Name {
    public static let CallTraceDidFinishNotification: NSNotification.Name = NSNotification.Name("CallTraceDidFinishNotification")
}

public func CallTrace() {
    var tmpString = ""
    
    let machPort: mach_port_t = mach_task_self_
    var threads: thread_act_array_t?
    var count: mach_msg_type_number_t = 0
    guard task_threads(machPort, &threads, &count) == KERN_SUCCESS else {
        return
    }
    
    for i in 0 ..< count {
        let thread: thread_act_t? = threads?[Int(i)]
        tmpString.append("----------------------------------------------------------------------------------\n")
        tmpString.append(stackOfThread(thread))
    }
    
    NotificationCenter.default.post(name: .CallTraceDidFinishNotification, object: nil, userInfo: [CallTraceKey.userInfo : tmpString])
}

func stackOfThread(_ thread: thread_t?) -> String {
    var tmpString: String = ""
    
    var count: mach_msg_type_number_t = mach_msg_type_number_t(THREAD_INFO_MAX)
    var threadInfo: [integer_t] = [integer_t](repeating: 0, count: Int(count))
    
    guard thread != 0 else {
        return tmpString
    }
    
    var threadBaseInfo: thread_basic_info?
    guard thread_info(thread!, thread_flavor_t(THREAD_BASIC_INFO), &threadInfo, &count) == KERN_SUCCESS else {
        return tmpString
    }
    
    //  数组内存转结构体内存，需要获取到数组的首地址
    threadBaseInfo = withUnsafePointer(to: &threadInfo[0]) { $0 }.withMemoryRebound(to: thread_basic_info.self, capacity: 1) { $0 }.pointee
    
    guard threadBaseInfo != nil else {
        return tmpString
    }
    
    var stateCount: mach_msg_type_number_t = threadStateCountOfCUP()
    var threadStateInfo: [natural_t] = [natural_t](repeating: 0, count: Int(stateCount))
    guard thread_get_state(thread!, threadStateOfCUP(), &threadStateInfo, &stateCount) == KERN_SUCCESS else {
        return tmpString
    }
    
    var machineContext: mcontext_t.Pointee = mcontext_t.Pointee.init()
    machineContext.__ss = withUnsafeMutablePointer(to: &threadStateInfo[0]) { $0 }.withMemoryRebound(to: type(of: machineContext.__ss), capacity: 1) { $0 }.pointee

    let size: Int = MemoryLayout<StackFrame>.size
    var outSize: vm_size_t = 0
    var stackFrame: StackFrame = StackFrame()
    let stackFramePointer: UnsafePointer<StackFrame> = withUnsafePointer(to: &stackFrame) { $0 }
    
    let fp: __uint64_t  = currentFramePointerOfThread(&machineContext)
    let vmAddresst: vm_address_t = vm_address_t(bitPattern: stackFramePointer)
    guard vm_read_overwrite(mach_task_self_, vm_address_t(fp), vm_size_t(size), vmAddresst, &outSize) == KERN_SUCCESS else {
        return tmpString
    }
    
    /**
     *  奇怪问题🤔，如果在thread_get_state和vm_read_overwrite之间创建并使用数组，就会造成后续获取不了调用栈
     */
    var i: Int = 0
    var bufferPointer: [__uint64_t] = [__uint64_t](repeating: 0, count: Int(stateCount))
    bufferPointer[i] = currentInstructPointerOfThread(&machineContext)
    i += 1

    let lr: __uint64_t = currentLinkregisterPointerOfThread(&machineContext)
    if lr != 0 {
        bufferPointer[i] = lr
        i += 1
    }
    
    var bufferedCount: Int = i
    for item in mach_msg_type_number_t(i) ..< stateCount {
        let lr: __uint64_t = stackFrame.callStackAddress
        guard lr != 0 else {
            break
        }
        
        bufferedCount += 1
        bufferPointer[Int(item)] = lr
        
        let fp: vm_address_t = vm_address_t(bitPattern: stackFrame.framePointer)
        guard fp != 0 else {
            break
        }
        
        guard vm_read_overwrite(mach_task_self_, fp, vm_size_t(size), vmAddresst, &outSize) == KERN_SUCCESS else {
            break
        }
    }
    
    var dlInfos: [Dl_info] = [Dl_info](repeating: Dl_info(), count: bufferedCount)
    symbolicOfAddress(bufferPointer[0], &dlInfos[0])
    for i in 1 ..< bufferedCount {
        symbolicOfAddress(currentInstructAddressOfPointer(bufferPointer[i]), &dlInfos[i])
    }
    
    tmpString.append("Stack of thread: \(thread!)   CPU used: \(threadBaseInfo!.cpu_usage / 10)%    user time: \(threadBaseInfo!.system_time.microseconds) microseconds\n")
    
    for i in 0 ..< bufferedCount {
        let dlInfo: Dl_info = dlInfos[i]
        let address: __uint64_t = bufferPointer[i]
        
        var dliFname: String = ""
        if dlInfo.dli_fname == nil {
            continue
        } else {
            var tmpString: [CChar]! = URL(string: String(cString: dlInfo.dli_fname))?.lastPathComponent.cString(using: .utf8)
            dliFname = String(format: "%-30s", withUnsafePointer(to: &tmpString[0]) { $0 })
        }
        
        var dliSname: String = ""
        if dlInfo.dli_sname != nil {
            dliSname = String(cString: dlInfo.dli_sname)
        }
        
        let outFormat: String = dliFname + "  " + String(format: "0x%lx", address) + "  " + dliSname + "  " + "\(UInt(address) - UInt(bitPattern: dlInfo.dli_saddr))" + "\n"
        tmpString.append(outFormat)
    }
    tmpString.append("----------------------------------------------------------------------------------\n")
    return tmpString
}

func symbolicOfAddress(_ address: __uint64_t, _ dlInfo: inout Dl_info) {
    /**
     *  首先确定该地址是在那个image镜像文件
     */
    let imageCount: UInt32 = _dyld_image_count()
    var index: UInt32 = UINT32_MAX
    for i in 0 ..< imageCount {
        let machHeader: UnsafePointer<MachHeader> = _dyld_get_image_header(i).withMemoryRebound(to: MachHeader.self, capacity: 1) { $0 }
        var loadCommandPointer: UnsafePointer<load_command>? = currentLoadCommandOfMachHeader(machHeader)
        if loadCommandPointer == nil {
            continue
        }
        
        let vmaddrSlide: Int = _dyld_get_image_vmaddr_slide(i) //地址偏移量
        if address < vmaddrSlide {
            continue
        }
        
        let vmaddress: __uint64_t = address - __uint64_t(vmaddrSlide)  //ASLR(address space layout randomization)
        for _ in 0 ..< machHeader.pointee.ncmds {
            if loadCommandPointer!.pointee.cmd == LC_SEGMENT {
                let segmentCommandPointer: UnsafePointer<segment_command> = loadCommandPointer!.withMemoryRebound(to: segment_command.self, capacity: 1) { $0 }
                
                if vmaddress >= segmentCommandPointer.pointee.vmaddr && vmaddress <= segmentCommandPointer.pointee.vmaddr + segmentCommandPointer.pointee.vmsize{
                    index = i
                    break
                }
            } else if loadCommandPointer!.pointee.cmd == LC_SEGMENT_64 {
                let segmentCommandPointer: UnsafePointer<segment_command_64> = loadCommandPointer!.withMemoryRebound(to: segment_command_64.self, capacity: 1) { $0 }
                
                if vmaddress >= segmentCommandPointer.pointee.vmaddr && vmaddress <= segmentCommandPointer.pointee.vmaddr + segmentCommandPointer.pointee.vmsize {
                    index = i
                    break
                }
            }
            
            loadCommandPointer = UnsafePointer<load_command>(bitPattern: UInt(bitPattern: loadCommandPointer) + UInt(loadCommandPointer!.pointee.cmdsize))
        }
        
        if index < UINT32_MAX {
            break
        }
    }
    
    if !(index < UINT32_MAX) {
        return
    }
    
    /**
     *  从确定的image镜像文件，找到__LINKEDIT（__TEXT、__DATA似乎也行），从而获取Segment片段基地址
     */
    let machHeader: UnsafePointer<MachHeader> = _dyld_get_image_header(index).withMemoryRebound(to: MachHeader.self, capacity: 1) { $0 }
    dlInfo.dli_fname = _dyld_get_image_name(index)
    dlInfo.dli_fbase = UnsafeMutableRawPointer(mutating: machHeader)
    
    let loadCommandPointer: UnsafePointer<load_command>? = currentLoadCommandOfMachHeader(machHeader)
    if loadCommandPointer == nil {
        return
    }
    
    var segmentCommandBaseAddress: UInt64 = 0
    let vmaddrSlide: Int = _dyld_get_image_vmaddr_slide(index) //地址偏移量
    var lcPointerToGetSegmentBaseAddress: UnsafePointer<load_command>? = loadCommandPointer
    for _ in 0 ..< machHeader.pointee.ncmds {
        guard let segmentCommandPointer: UnsafePointer<SegmentCommand> = (lcPointerToGetSegmentBaseAddress?.withMemoryRebound(to: SegmentCommand.self, capacity: 1) { $0 }) else {
            break
        }
        
        let segname: String = Mirror(reflecting: segmentCommandPointer.pointee.segname).children
            .map { ($0.value as? CChar) ?? 0 }
            .filter { $0 != 0 }
            .map { String(Unicode.Scalar(UInt8($0))) }
            .joined()
        if segname == SEG_LINKEDIT {
            segmentCommandBaseAddress = segmentCommandPointer.pointee.vmaddr - segmentCommandPointer.pointee.fileoff + UInt64(vmaddrSlide)
            break
        }
        
        lcPointerToGetSegmentBaseAddress = UnsafePointer<load_command>(bitPattern: UInt(bitPattern: lcPointerToGetSegmentBaseAddress) + UInt(lcPointerToGetSegmentBaseAddress!.pointee.cmdsize))
    }
    
    if segmentCommandBaseAddress == 0 {
        return
    }
    
    /**
     *  根据Segment片段基地址找到__symbol_table
     */
    var symtableList: UnsafeMutablePointer<Nlist>? //是一个不是很顺序的列表
    var strtableAddress: UInt64 = 0
    var symtabCommandPointer: UnsafePointer<symtab_command>?
    var lcPointerToGetSymTab: UnsafePointer<load_command>? = loadCommandPointer
    for _ in 0 ..< machHeader.pointee.ncmds {
        if lcPointerToGetSymTab!.pointee.cmd == LC_SYMTAB {
            symtabCommandPointer = lcPointerToGetSymTab!.withMemoryRebound(to: symtab_command.self, capacity: 1) { $0 }
            symtableList = UnsafeMutablePointer<Nlist>(bitPattern: UInt(segmentCommandBaseAddress + UInt64(symtabCommandPointer!.pointee.symoff)))
            strtableAddress = segmentCommandBaseAddress + UInt64(symtabCommandPointer!.pointee.stroff)
            break
        }
        
        lcPointerToGetSymTab = UnsafePointer<load_command>(bitPattern: UInt(bitPattern: lcPointerToGetSymTab) + UInt(lcPointerToGetSymTab!.pointee.cmdsize))
    }
    
    if symtabCommandPointer == nil {
        return
    }
    
    /**
     *  根据符号指针列表找到对应的符号表
     */
    var lastestGap: UInt64 = UINT64_MAX
    var symtableIndex: UInt32 = UINT32_MAX
    let vmaddress: __uint64_t = address - __uint64_t(vmaddrSlide)  //ASLR
    var tmpSymtableList: UnsafeMutablePointer<Nlist>? = symtableList
    for i in 0 ..< symtabCommandPointer!.pointee.nsyms {
        tmpSymtableList = symtableList?.advanced(by: Int(i))
        
        let symbolBase: UInt64 = tmpSymtableList?.pointee.n_value ?? 0
        if symbolBase == 0 {
            continue
        }
        
        if vmaddress < symbolBase {
            continue
        }
        
        let betweenGap: UInt64 = vmaddress - symbolBase
        if betweenGap > lastestGap {
            continue
        }
        
        lastestGap = betweenGap
        symtableIndex = i
    }
    
    /**
     *  根据在符号表的位置，找到在字符串表(String Table)中对应的字符
     */
    let symtable: UnsafeMutablePointer<Nlist> = symtableList! + UnsafeMutablePointer<Nlist>.Stride(symtableIndex)
    dlInfo.dli_saddr = UnsafeMutableRawPointer(bitPattern: UInt(symtable.pointee.n_value + UInt64(vmaddrSlide)))
    dlInfo.dli_sname = UnsafePointer<CChar>(bitPattern: UInt(strtableAddress + UInt64(symtable.pointee.n_un.n_strx)))
}

struct StackFrame {
    var framePointer: UnsafeMutablePointer<__uint64_t>?
    var callStackAddress: __uint64_t = 0
}
