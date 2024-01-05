//
//  CallTraceCode.c
//  SwiftFramework
//
//  Created by kaki Yen on 2022/5/16.
//

#include <mach/mach.h>
#include <mach-o/loader.h>
#include "CallTraceCode.h"

thread_state_flavor_t threadStateOfCUP(void) {
#ifdef __arm64__
    return ARM_THREAD_STATE64;
#elif __arm__
    return ARM_THREAD_STATE;
#elif __x86_64__
    return x86_THREAD_STATE64;
#elif __i386__
    return x86_THREAD_STATE32;
#endif
}

mach_msg_type_number_t threadStateCountOfCUP(void) {
    if (__builtin_available(iOS 17.0, *)) {
#ifdef __arm64__
    return ARM_THREAD_STATE64_COUNT;
#elif __arm__
    return ARM_THREAD_STATE_COUNT;
#elif __x86_64__
    return x86_THREAD_STATE64_COUNT;
#elif __i386__
    return x86_THREAD_STATE32_COUNT;
#endif
    } else {
#ifdef __arm64__
    return ARM_THREAD_STATE64_COUNT;
#elif __arm__
    return ARM_THREAD_STATE_COUNT;
#elif __x86_64__
    return x86_THREAD_STATE64_COUNT;
#elif __i386__
    return x86_THREAD_STATE32_COUNT;
#endif
    }
}

__uint64_t currentFramePointerOfThread(mcontext_t machineContext) {
#ifdef __arm64__
    return machineContext->__ss.__fp;
#elif __arm__
    return machineContext->__ss.__r[7];
#elif __x86_64__
    return machineContext->__ss.__rbp;
#elif __i386__
    return machineContext->__ss.__ebp;
#endif
}

//  the current instruction address pointer
__uint64_t currentInstructPointerOfThread(mcontext_t machineContext) {
#ifdef __arm64__
    return machineContext->__ss.__pc;
#elif __arm__
    return machineContext->__ss.__pc;
#elif __x86_64__
    return machineContext->__ss.__rip;
#elif __i386__
    return machineContext->__ss.__eip;
#endif
}

//  the current instruction address
__uint64_t currentInstructAddressOfPointer(__uint64_t address) {
    __uint64_t tmpAddress = address;
#ifdef __arm64__
    tmpAddress = address & ~(3UL);
#elif __arm__
    tmpAddress = address & ~(1UL);
#endif
    return tmpAddress - 1;
}


__uint64_t currentLinkregisterPointerOfThread(mcontext_t machineContext) {
#ifdef __x86_64__
    return 0;
#elif __i386__
    return 0;
#else
    return machineContext->__ss.__lr;
#endif
}

const struct load_command * currentLoadCommandOfMachHeader(const MachHeader *header) {
    if (!header) {
        return NULL;
    }
    
    struct load_command *loadCommand = NULL;
    switch (header->magic) {
        case MH_MAGIC:
        case MH_CIGAM:
        case MH_MAGIC_64:
        case MH_CIGAM_64:
            loadCommand = (struct load_command *)(header + 1);
            break;
        default:
            break;
    }
    
    return loadCommand;
}
