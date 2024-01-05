//
//  ScenseToCall.m
//  SwiftProject
//
//  Created by kaki Yen on 2022/5/16.
//

#import "ScenesToCall.h"
#import "SwiftProject-Swift.h"

@implementation ScenesToCall

+ (void)callTrace {
    [CallTraceManager callTrace];
//    [ScenesToCallOne performSelector:@selector(callTraceHello)];
}

@end
