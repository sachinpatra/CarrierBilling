//
//  NetworkController.h
//  InstaVoice
//
//  Created by Eninov on 10/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "EventLoop.h"

@class AppDelegate;
@interface NetworkController : EventLoop
{
    AppDelegate *appDelegate;
    NSString *serverUrl;

    // variable to check if request is complete or not
    BOOL isRequestDone;
    NSLock *netLock;
    
    NSMutableArray *eventQueue;
    
    // variables to store data of processing event
    NSMutableDictionary *reqEvObj;
    NSMutableDictionary *reqDic ;
    int curReqEvType;
    BOOL isAddedInRunLoop;
    NSInteger requestId;
    
    // NSMutableData to hold server response 
     NSMutableData *responseData;
    
    
    // Variable to check time taken in response from server
    long long reqTime;
}

@property (strong, nonatomic) NSURLSession *session;

/**
 * This function adds event to network thread from engine
 * @param : evObj: NSMutableDictionary contains eventType(EVENT_TYPE)for which request is to made and reuestdata(REQUESTDIC) to send to server 
 * @return : Success , failure or inprogress invalue defined in macro.h
 */
-(int)addEvent:(NSMutableDictionary *)evObj;

/**
 * This function is to 
 */
-(void)clearNetworkQueue;
@end
