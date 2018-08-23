//
//  PendingEventManager.h
//  InstaVoice
//
//  Created by adwivedi on 07/05/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    PendingEventTypeSystemAlert = 1,
    PendingEventTypeFetchMessage, //2
    PendingEventTypeFetchVobolo,  //3
    PendingEventTypeFetchContact, //4
    PendingEventTypeFetchMessageActivity, //5
    PendingEventTypeFetchProfile,         //6
    PendingEventTypeFetchGroupUpdates,    //7
    PendingEventTypeSetDeviceInfo,        //8
    PendingEventTypeSignOut,              //9
    PendingEventTypeAppUpgradeRequired,   //10
    PendingEventTypeFetchSetting,         //11
    PendingEventTypeMQTTFallback          //12
} PendingEventType;

@interface PendingEventManager : NSObject
{
    NSMutableArray* _pendingEventList;
    BOOL _isEventProcessing;
    double _lastPendingEventTime;
    NSInteger _errorCount;
    NSLock* _lockEvents;
}

+(id)sharedPendingEventManager;
-(void)addPendingEvents:(NSMutableArray *)eventList atTime:(double)time;
-(void)pendingEventManagerDidSucceedWithResponse:(NSDictionary*)response forPendingEventType:(PendingEventType)eventType;
-(void)pendingEventManagerDidFailWithError:(NSError*)error forPendingEventType:(PendingEventType)eventType;
@property(nonatomic)long skipId;

@end
