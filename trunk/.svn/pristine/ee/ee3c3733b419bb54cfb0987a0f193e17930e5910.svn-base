//
//  TextMessageInterfaceController.m
//  InstaVoice
//
//  Created by Jatin Mitruka on 4/17/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "TextMessageInterfaceController.h"
#import "NotificationData.h"
#import "IVAudioLoader.h"
#import "WatchScreenUtility.h"
#import "Logger.h"

@interface TextMessageInterfaceController ()

@end

@implementation TextMessageInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [WatchScreenUtility sharedWatchUtility];
    [self setTitle:@""];
    if([context isKindOfClass:[NotificationData class]])
    {
        NotificationData* dataObj = context;
        
        NSString *contactLocalPicPath = [[IVAudioLoader getTempSharedDirectoryPath]stringByAppendingPathComponent:dataObj.contactNumber];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isFileExistImage = [fm fileExistsAtPath:contactLocalPicPath];
        if(isFileExistImage)
        {
//Deepak_Carpenter : Added this code to download data in <iOS8.4 version
            //UIImage* imgMain = [UIImage imageWithContentsOfFile:contactLocalPicPath];
            //[self.remoteUserImage setImage:imgMain];
            
            ////// ----------- START ------------- /////////
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
                
                UIImage* imgMain =  [UIImage imageWithData:[NSData dataWithContentsOfFile:contactLocalPicPath] scale:[UIScreen mainScreen].scale];
                [self.remoteUserImage setImage:imgMain];
                
            }else{
                UIImage* imgMain = [UIImage imageWithContentsOfFile:contactLocalPicPath];
                [self.remoteUserImage setImage:imgMain];
            }
           //
            [IVAudioLoader loadContactPicFileFromServerWithURL:dataObj.contactPicURL andSaveToLocalPath:contactLocalPicPath withCompletionHandler:^(BOOL result){
                if(result)
                {
                    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
                        
                        UIImage* contactPic =  [UIImage imageWithData:[NSData dataWithContentsOfFile:contactLocalPicPath] scale:[UIScreen mainScreen].scale];
                        [self.remoteUserImage setImage:contactPic];
                        
                    }else{
                        UIImage* contactPic = [UIImage imageWithContentsOfFile:contactLocalPicPath];
                        [self.remoteUserImage setImage:contactPic];
                        
                    }}}];
            //////---------------END---------------////////
        }
        else
        {
            [self.remoteUserImage setImageNamed:@"Default_Profile_Pic"];
        }
        
       // [self.timeLabel setText:[WatchScreenUtility sharedWatchUtility]dateConverter]
        
       [self.timeLabel setText:[[WatchScreenUtility sharedWatchUtility]dateConverter:@([dataObj.msgDate integerValue]) dateFormateString:@"MMM d, h:mm a"]];

        if([IVAudioLoader isNumeric:dataObj.contactName]){
            [self.remoteUserName setText:[@"+" stringByAppendingString:dataObj.contactName]];
            [self setTitle:dataObj.contactName];
    }
        else
        {      [self.remoteUserName setText:dataObj.contactName];
            [self setTitle:dataObj.contactName];
        }
        
        [self.groupForImage setCornerRadius:10];
        
        NSString *msgContent = dataObj.msgContent;
        [self.textMessageLabel setText:msgContent];
        _contactNumber = dataObj.contactNumber;
        //[self.groupForTextMessage setBackgroundImageNamed:@"text_blue_unread"];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"newRemoteNotification"]) {
        [self pushControllerWithName:@"interfaceController" context:nil];
    }
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)callAction {
    NSDictionary* contactInfo = @{@"PHONE":_contactNumber};
    [TextMessageInterfaceController openParentApplication:contactInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        KLog(@"Reply: %@",replyInfo);
    }];

}
- (IBAction)forceTouceButtonAction {
    NSDictionary* contactInfo = @{@"PHONE":_contactNumber};
    [TextMessageInterfaceController openParentApplication:contactInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        KLog(@"Reply: %@",replyInfo);
    }];
}
@end



