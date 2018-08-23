//
//  NotificationController.m
//  InstaVoice WatchKit Extension
//
//  Created by adwivedi on 10/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "NotificationController.h"
#import "NotificationDataManager.h"
#import "Logger.h"

//Deepak_Carpenter : Added for date format
#define INT_1000                1000
#define INT_60                  60
#define INT_9                   9
#define SIZE_1YEAR 31,536,000
#define SIZE_1WEEK 604,800
#define SIZE_2DAY 172,800
#define SIZE_1DAY  86400.0
#define SIZE_1HOUR   3600.0

@interface NotificationController()

@end


@implementation NotificationController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


- (void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    // This method is called when a local notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    KLog(@"Local Notification - %@",localNotification);
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}

- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    // This method is called when a remote notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    KLog(@"Remote Notification with Data %@",remoteNotification);
    
    [self.notificationText setText:[remoteNotification valueForKeyPath:@"aps.alert.body"]];
    
    NotificationData *data = [[NotificationData alloc]init];
    
    data.msgId          = [remoteNotification valueForKey:@"msg_id"];
    
    //
    //DC MEMLEAK MAY 25 2016
   // NSNumber *unformattedDateNumber = @([[remoteNotification valueForKey:@"msg_id"] intValue]);
    
    //KLog(@"dateNumber is %@",unformattedDateNumber);
 
    //    KLog(@"date after conversion is %@",[self dateConverter:unformattedDateNumber dateFormateString:@"MMM d, h:mm a"]);
    //

    
    NSString* unformattedDate = [remoteNotification valueForKey:@"msg_dt"];
     //   data.msgDate        = [self formattedDate:unformattedDate];
    data.msgDate = unformattedDate;
    
    data.msgType        = [remoteNotification valueForKey:@"msg_type"];
    //DC MAY 26 2016
    data.msgSubType        = [remoteNotification valueForKey:@"msg_subtype"];
    data.msgContentType = [remoteNotification valueForKey:@"msg_content_type"];
    
    if([data.msgContentType isEqualToString:@"t"])
    {
        if([data.msgType isEqualToString:@"iv"])
            data.msgContent     = [remoteNotification valueForKey:@"content"];
        else if([data.msgSubType isEqualToString:@"ring"])
            data.msgContent = [NSString stringWithFormat:@"Ring Missed Call from %@",[remoteNotification valueForKey:@"sender_id"]];
        else
            data.msgContent = [remoteNotification valueForKeyPath:@"aps.alert.body"];
    }
    else
    {
        data.msgContent     = [remoteNotification valueForKey:@"msg_uri"];
        if([data.msgContentType isEqualToString:@"a"])
        {
            data.msgDuration    = [[remoteNotification valueForKey:@"duration"]integerValue];
            data.msgFormat = [remoteNotification valueForKey:@"msg_format"];
        }
    }

    data.contactName = [remoteNotification valueForKey:@"sender_id"];
    data.contactPicURL = [remoteNotification valueForKey:@"pic_uri"];
    data.contactNumber = [remoteNotification valueForKey:@"phone"];
    if([remoteNotification valueForKey:@"sender_type"])
    {
        data.contactType    = [remoteNotification valueForKey:@"sender_type"];
    }
    else
        data.contactType    = [remoteNotification valueForKey:@"contact_type"];
    
    [[NotificationDataManager sharedNotificationDataManager]addNewNotification:data];
    //Deepak : added to transit screens while new notification comes
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"newRemoteNotification"];
    //
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}

-(NSString*)formattedDate:(NSString*)unformattedDate
{
    NSTimeInterval seconds = [unformattedDate doubleValue]/1000;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.timeStyle = NSDateFormatterMediumStyle;
    formatter.dateStyle = NSDateFormatterMediumStyle;
    [formatter setDateFormat:@"MMM dd, hh:mm a"];
    NSString* formattedDate = [formatter stringFromDate:date];
    return formattedDate;
}
@end



