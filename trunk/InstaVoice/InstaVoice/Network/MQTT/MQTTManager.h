//
//  MQTTManager.h
//  InstaVoice
//
//  Created by adwivedi on 22/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMQTTClient.h"
@class ChatActivityData;

@interface MQTTManager : NSObject<MQTTClientManagerDelegate>
{
    NSMutableArray* _publishedMessageList;
    NSTimer* _sendMessageTimer;
    NSInteger _connectionTrialCount;
}
+(id)sharedMQTTManager;

-(void) connectMQTTClient;
-(void) disconnectMQTTClient;
-(BOOL) isConnected;
-(void) publishTextMessage:(NSMutableDictionary*) message;
-(void) publishReadReceiptData:(ChatActivityData*)activity;
-(void) publishAppStatusInBackground;

@property(atomic) BOOL canProcessThroughMQTT;

-(void)processAPNSPushNotificationData:(NSDictionary*)payload showOnBar:(BOOL)show;
//CMP
-(void)processPendingEvent:(NSString*)pendingEvents withAdditionalEvent:(NSString*)event skipId:(long)skipId atTime:(double)mid;
//

@end
