//
//  Conversations.h
//  InstaVoice
//
//  Created by adwivedi on 18/05/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Conversations : NSObject
{
    NSDate* startTime;
}

+(id)sharedConversations;

-(void)fetchMessageFromServerWithSkipMsgId:(long)msgId notificationDic:(NSDictionary*) notificationDic;
-(void)fetchMessageActivitiesWithSkipActivityId:(long)activityId;

-(void)fetchMessageFromServerInBackgroundWithNotification:(NSDictionary*)notificationDic fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
-(void)markCompletionOfDataDownload:(BOOL)success;

@end
