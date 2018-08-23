//
//  EventLoop.h
//  InstaVoice
//
//  Created by Eninov on 11/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Logger.h"

@interface EventLoop : NSThread
{
}
@property (strong) NSPersistentStoreCoordinator *sharedPSC;

// This function is the entry point of thread, called up with initialization of thread
-(void)main;
// This function is to add events by one thread(caller of the function) to other thread (thread which is implementing the function)  
-(int)addEvent:(NSMutableDictionary *)evObj;
// This function is to process all the events queued in the current thread.
-(int)handleEvent:(NSMutableDictionary *)evObj;
-(void)cancelEvent;
@end
