//
//  EventLoop.m
//  InstaVoice
//
//  Created by Eninov on 11/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "EventLoop.h"
#import "Macro.h"

@implementation EventLoop

-(void)main
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    [runLoop run];
}
/*
vbn * evObj. This event is handled in handleEvent function called from runLoop Thread
 */
-(int)addEvent:(NSMutableDictionary *)evObj
{
    [self performSelector:@selector(handleEvent:) onThread:self withObject:evObj waitUntilDone:NO];
    return SUCCESS;
}

-(void)cancelEvent
{
    [NSRunLoop cancelPreviousPerformRequestsWithTarget:self];
}

/*
 * This function is to be overloaded by the derived object.
 */
-(int)handleEvent:(NSMutableDictionary *)evObj
{
    return 0;
}
@end
