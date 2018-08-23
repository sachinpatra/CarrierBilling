//
//  InterfaceController.m
//  InstaVoice WatchKit Extension
//
//  Created by adwivedi on 10/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "InterfaceController.h"
#import "NotificationDataManager.h"
#import "ChatTileRowType.h"
#import "NotificationData.h"
#import "IVAudioLoader.h"
#import "NotificationController.h"
#import "WatchScreenUtility.h"
#import "Logger.h"

@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [NotificationDataManager sharedNotificationDataManager];
    [WatchScreenUtility sharedWatchUtility];
    // Configure interface objects here.
//Deepak_Carpenter : added this code to resolve refresh tableview frequently and set top row in view while new notification comes
//BZI : 8632 & 8614
//////////////--------START----------///////

    [NSTimer scheduledTimerWithTimeInterval: 1.5 target: self                                                      selector: @selector(reloadTitlesData) userInfo: nil repeats: YES];
    
//////////////--------END----------///////

}
//Deepak_Carpenter : added this code to resolve refresh tableview frequently and set top row in view while new notification comes
//BZI : 8632 & 8614
//////////////--------START----------///////
-(void)reloadTitlesData{
    if (self.chatList.count>0 && [[NotificationDataManager sharedNotificationDataManager]getTopNotificationDataList].count>0) {
        NotificationData *dataObj1 = [self.chatList objectAtIndex:0];
        NotificationData *dataObj2 = [[[NotificationDataManager sharedNotificationDataManager]getTopNotificationDataList] objectAtIndex:0];
        if (dataObj1.msgId!=dataObj2.msgId) {
            self.chatList = [[NotificationDataManager sharedNotificationDataManager]getTopNotificationDataList];
            [self.tilesListView setRowTypes:@[@"tilesListViewRow"]];
            [self configureTableWithData:self.chatList];
            [self smoothTableScroll];
            
        }
    }
}
-(void)smoothTableScroll{
    for (int i = (int)[[NotificationDataManager sharedNotificationDataManager]getTopNotificationDataList].count; i>=0 ; i--) {
        [UIView animateWithDuration:0.2 animations:^{
        [self.tilesListView scrollToRowAtIndex:i];
        }];
    }
}

/////----------END-----------/////
- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    self.chatList = [[NotificationDataManager sharedNotificationDataManager]getTopNotificationDataList];
    [self.tilesListView setRowTypes:@[@"tilesListViewRow"]];
    [self configureTableWithData:self.chatList];
    [self.brandImage setImageNamed:@"iv_icon_with_text"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"newRemoteNotification"]) {
        
        
        [self transitionToNewViewContollerWithData:[[[NotificationDataManager sharedNotificationDataManager]getTopNotificationDataList]objectAtIndex:0]];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"newRemoteNotification"];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)configureTableWithData:(NSArray*)dataObjects {
    if ([dataObjects count]>0) {
    [self.tilesListView setNumberOfRows:[dataObjects count] withRowType:@"tilesListViewRow"];
    for (NSInteger i = 0; i < self.tilesListView.numberOfRows; i++) {
        ChatTileRowType* theRow = [self.tilesListView rowControllerAtIndex:i];
        
        NotificationData *dataObj = [dataObjects objectAtIndex:i];
         //Deepak : if there is no object in chatlist array
        if ([dataObjects count]==0) {
            [theRow.rowDescription setText : @"No New Notification"];
        }
        //
        
     //   UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0];
     //   NSAttributedString *attrb;
        NSString *attrb;
        
        if([IVAudioLoader isNumeric:dataObj.contactName])
           // attrb = [[NSAttributedString alloc]initWithString:[@"+" stringByAppendingString:dataObj.contactName] attributes:@{NSFontAttributeName: @""}];
            attrb = [[NSString alloc]initWithString:[NSString stringWithFormat:@"+%@",dataObj.contactName]];
        
        else
            //attrb = [[NSAttributedString alloc]initWithString:dataObj.contactName attributes:@{NSFontAttributeName:@""}];
            attrb = [[NSString alloc]initWithString:dataObj.contactName];
        
        //[theRow.rowDescription setAttributedText:attrb];
        [theRow.rowDescription setText:attrb];
        //Deepak
        [theRow.timeIcon setImageNamed:@"timeIcon"];
        
       // UIFont *fontForTime = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10.0];
     //   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *msgDate = [[WatchScreenUtility sharedWatchUtility]dateConverter:@([dataObj.msgDate integerValue]) dateFormateString:@"MMM d, h:mm a"];
        [theRow.timeLabel setText:msgDate];

       // });
        
                             
       // NSAttributedString *newAttrb = [[NSAttributedString alloc]initWithString:msgDate attributes:@{NSFontAttributeName:@""}];
       // [theRow.timeLabel setAttributedText:newAttrb];
        //Contact pic
        NSString *contactLocalPicPath = [[IVAudioLoader getTempSharedDirectoryPath]stringByAppendingPathComponent:dataObj.contactNumber];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isFileExist = [fm fileExistsAtPath:contactLocalPicPath];
        if(isFileExist)
        {
//Deepak_Carpenter : Added this code to download data in <iOS8.4 version
            //UIImage* imgMain = [UIImage imageWithContentsOfFile:contactLocalPicPath];
            //[theRow.remoteUserImage setImage:imgMain];
            
            ////// ----------- START ------------- /////////
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
                
                UIImage* imgMain =  [UIImage imageWithData:[NSData dataWithContentsOfFile:contactLocalPicPath] scale:[UIScreen mainScreen].scale];
                [theRow.remoteUserImage setImage:imgMain];
                
            }else{
                UIImage* imgMain = [UIImage imageWithContentsOfFile:contactLocalPicPath];
                [theRow.remoteUserImage setImage:imgMain];
            }
            //////---------------END---------------////////
        }
        else
        {
            [theRow.remoteUserImage setImageNamed:@"Default_Profile_Pic"];
            if(dataObj.contactPicURL.length > 1)
            {
                [IVAudioLoader loadContactPicFileFromServerWithURL:dataObj.contactPicURL andSaveToLocalPath:contactLocalPicPath withCompletionHandler:^(BOOL result){
                    if(result)
                    {
//Deepak_Carpenter : Added this code to download data in <iOS8.4 version
                        //UIImage* imgMain = [UIImage imageWithContentsOfFile:contactLocalPicPath];
                        //[theRow.remoteUserImage setImage:imgMain];
                        
        ////// ----------- START ------------- /////////
                        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
                            
                            UIImage* imgMain =  [UIImage imageWithData:[NSData dataWithContentsOfFile:contactLocalPicPath] scale:[UIScreen mainScreen].scale];
                            [theRow.remoteUserImage setImage:imgMain];
                            
                        }else{
                            UIImage* imgMain = [UIImage imageWithContentsOfFile:contactLocalPicPath];
                            [theRow.remoteUserImage setImage:imgMain];
                        }
        //////---------------END---------------////////
                    }
                }];
            }
        }
        //Contact pic path end
//Deepak_Carpenter : Added this code to change the radius of groupForImage
        //[theRow.groupForImage setCornerRadius:15];
        [theRow.groupForImage setCornerRadius:10];
        
        if([dataObj.msgContentType isEqualToString:@"a"])
        {
            if([dataObj.msgType isEqualToString:@"iv"])
                [theRow.messageIcon setImageNamed:@"Audio_Icon"];
            else
                [theRow.messageIcon setImageNamed:@"Audio_Icon_Grey"];
        }
        else if ([dataObj.msgContentType isEqualToString:@"t"])
        {
            if([dataObj.msgType isEqualToString:@"iv"])
                [theRow.messageIcon setImageNamed:@"Chat_Icon"];
            //DC MAY 26 2016
            else if([dataObj.msgSubType isEqualToString:@"ring"])
                [theRow.messageIcon setImageNamed:@"ringIconDown"];
                else
                [theRow.messageIcon setImageNamed:@"Missed_Call_Icon"];
        }
        else if([dataObj.msgContentType isEqualToString:@"i"])
        {
            [theRow.messageIcon setImageNamed:@"Image_Icon"];
        }
    }
    }
    else{
        [self.tilesListView setNumberOfRows:1 withRowType:@"tilesListViewRow"];
        ChatTileRowType* row = [self.tilesListView rowControllerAtIndex:0];
        UIFont *fontForTime = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
        NSAttributedString *newAttrb = [[NSAttributedString alloc]initWithString:@"No New" attributes:@{NSFontAttributeName: fontForTime}];
        [row.rowDescription setAttributedText:newAttrb];
        
        UIFont *fontForTime1 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
        //[row.remoteUserImage setImageNamed:@""];
        NSAttributedString *newAttrb1 = [[NSAttributedString alloc]initWithString:@"Notification" attributes:@{NSFontAttributeName: fontForTime1}];
        
        [row.timeLabel setAttributedText:newAttrb1];
      //  [row.timeIcon setImageNamed:@""];
        
    }
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"newRemoteNotification"];
    if ([self.chatList count]>0) {
    NotificationData* selectedRowData = [self.chatList objectAtIndex:rowIndex];
    KLog(@"Data = %@",selectedRowData);
    
    [self transitionToNewViewContollerWithData:selectedRowData];
    }
}

-(void)transitionToNewViewContollerWithData:(NotificationData *)data
{
    if([data.msgContentType isEqualToString:@"a"])
        [self pushControllerWithName:@"audioMessageInterfaceController" context:data];
    else if([data.msgContentType isEqualToString:@"i"])
        [self pushControllerWithName:@"imageMessageInterfaceController" context:data];
    else if([data.msgContentType isEqualToString:@"t"])
        [self pushControllerWithName:@"textMessageInterfaceController" context:data];
}


-(void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification
{
    KLog(@"Identifier Local: %@",identifier);
}

-(void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification
{
    KLog(@"Identifier Remote: %@",identifier);
    if([identifier isEqualToString:@"callButtonAction"])
    {
        //call user
        KLog(@"call user");
    }
    else
    {
        //[self popToRootController];
        //[self transitionToNewViewContollerWithData:remoteNotification];
    
        /*
         //download and show data.
         KLog(@"download and show");
         call parent application to download the file and save it to shared container.
        
        [InterfaceController openParentApplication:remoteNotification reply:^(NSDictionary *replyInfo, NSError *error) {
            KLog(@"Reply: %@",replyInfo);
        }];*/
    }
}

-(void)handleUserActivity:(NSDictionary *)userInfo
{
    KLog(@"UserInfo: %@",userInfo);
}

//for segues connected in storyboard use this method to configure the context object.
/*-(id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex
{
    NSMutableDictionary* selectedRowData = [self.chatList objectAtIndex:rowIndex];
    KLog(@"Data = %@",selectedRowData);
    return selectedRowData;
}*/


@end



