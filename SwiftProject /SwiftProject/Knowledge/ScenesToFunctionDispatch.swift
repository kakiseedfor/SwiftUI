//
//  ScenesToFunctionDispatch.swift
//  SwiftProject
//
//  Created by kaki Yen on 2022/1/18.
//

import Foundation

protocol ProtocolMethodDispatch {
    func methodSeven()  //表派发函数
}

extension ProtocolMethodDispatch {
    func methodSeven() { print("Protocol : " + "\(#function)") }                    //直接派发函数
}

class ObjcMethodDispatch: ProtocolMethodDispatch {
    func methodOne() { print("Objc method : " + "\(#function)") }                   //表派发函数
    @objc func methodTwo() { print("Objc method : " + "\(#function)") }             //表派发函数，标记为可被 Runtime 识别
    dynamic func methodThree() { print("Objc method : " + "\(#function)") }         //表派发函数，标记当前函数或变量可以被替换
    @objc dynamic func methodFour() { print("Objc method : " + "\(#function)") }    //消息派发函数，可被 Runtime 识别
}

extension ObjcMethodDispatch {
    @_dynamicReplacement(for: methodThree)
    func methodFive() { print("Objc extension : " + "\(#function)") }               //直接派发函数，不可被子类重写
}

class SubObjcMethodDispatch: ObjcMethodDispatch {
    final func methodEight() { print("SubObjc method : " + "\(#function)") }        //直接派发函数，不可被子类重写
}

extension SubObjcMethodDispatch {
    @_dynamicReplacement(for: methodThree)
    func methodSix() { print("SubObjc extension : " + "\(#function)") }             //直接派发函数，不可被子类重写
}

func echoResult() {
    let tmpObjc = SubObjcMethodDispatch()
    tmpObjc.methodThree()

    let proObjc: ProtocolMethodDispatch = tmpObjc
    proObjc.methodSeven()   //直接派发函数

    var count: UInt32 = 0
    let methods: UnsafeMutablePointer<Method>? = class_copyMethodList(ObjcMethodDispatch.self, &count)
    for item in 0...count {
        guard let method = methods?[Int(item)] else {
            continue
        }

        print(method_getName(method).description)

        typealias Convention = @convention(c) (AnyObject, Selector) -> Void
        let imp: IMP = method_getImplementation(method)
        unsafeBitCast(imp, to: Convention.self)(tmpObjc, method_getName(method))
    }
}
