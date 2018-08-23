//
//  NotificationController.h
//  InstaVoice WatchKit Extension
//
//  Created by adwivedi on 10/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface NotificationController : WKUserNotificationInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *notificationText;

@end
