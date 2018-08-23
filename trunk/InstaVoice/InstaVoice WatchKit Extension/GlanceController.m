//
//  GlanceController.m
//  InstaVoice WatchKit Extension
//
//  Created by adwivedi on 10/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "GlanceController.h"
#import "NotificationDataManager.h"

@interface GlanceController()

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    NSArray* msgList = [[NotificationDataManager sharedNotificationDataManager]getTopNotificationDataList];
    
    NSString* message = @"No unread message";
    if(msgList.count)
    {
        NotificationData* data = [msgList objectAtIndex:0];
        message = [NSString stringWithFormat:@"Last message from %@",data.contactName];
    }
    
    [self.unreadMsgCountLabel setText:message];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



