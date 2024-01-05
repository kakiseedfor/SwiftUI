//
//  CallTraceCode.h
//  SwiftFramework
//
//  Created by kaki Yen on 2022/5/16.
//

#ifndef CallTraceCode_h
#define CallTraceCode_h

#include <MacTypes.h>
#include <stdio.h>

#ifdef __LP64__
typedef struct nlist_64 Nlist;
typedef struct mach_header_64 MachHeader;
typedef struct segment_command_64 SegmentCommand;
#else
typedef struct nlist Nlist;
typedef struct mach_header MachHeader;
typedef struct segment_command SegmentCommand;
#endif

thread_state_flavor_t threadStateOfCUP(void);

mach_msg_type_number_t threadStateCountOfCUP(void);

__uint64_t currentFramePointerOfThread(mcontext_t _Nonnull machineContext);

__uint64_t currentInstructPointerOfThread(mcontext_t _Nonnull machineContext);

__uint64_t currentLinkregisterPointerOfThread(mcontext_t _Nonnull machineContext);

__uint64_t currentInstructAddressOfPointer(__uint64_t address);

const struct load_command * _Nullable currentLoadCommandOfMachHeader(const MachHeader * _Nullable header);

#endif /* CallTraceCode_h */
