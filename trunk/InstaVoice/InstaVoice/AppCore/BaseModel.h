//
//  BaseModel.h
//  InstaVoice
//
//  Created by EninovUser on 07/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate;
@class Engine;

@interface BaseModel : NSObject
{
    AppDelegate *appDelegate;
    NSLock *lockObj;
}


/*
 *This function add the common request parameter
 */
-(void)addCommonData:(NSMutableDictionary*)dic eventType:(int)eventType;

/**
 * This function handles all the Event from UI
 */
-(int )handleUIEvent:(int)eventType objectDic:(NSMutableDictionary *)objDic;

/**
 * This function handles all the Event from Network
 */
-(int)handleNetEvent:(int)eventType objectDic:(NSMutableDictionary *)objDic;

/**
 * This function adds event to network thread corresponding to event type 
 */
-(int)eventToNetwork:(int)eventType eventDic:(NSMutableDictionary *)evDic;


/**
 * This function notifies 
 */
-(void)notifyUI:(NSDictionary *)responseData;

@end
