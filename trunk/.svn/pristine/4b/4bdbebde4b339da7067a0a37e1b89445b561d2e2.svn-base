//
//  NotificationDataManager.h
//  InstaVoice
//
//  Created by adwivedi on 16/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationData.h"

@interface NotificationDataManager : NSObject
{
    NSMutableArray* _topNotificationDataList;
}

+(id)sharedNotificationDataManager;
-(void)addNewNotification:(NotificationData*)data;
-(NSArray*)getTopNotificationDataList;

@end
