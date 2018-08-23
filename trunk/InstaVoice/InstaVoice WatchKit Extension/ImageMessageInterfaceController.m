//
//  ImageMessageInterfaceController.m
//  InstaVoice
//
//  Created by adwivedi on 13/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "ImageMessageInterfaceController.h"
#import "NotificationData.h"
#import "IVAudioLoader.h"
#import "Logger.h"

@interface ImageMessageInterfaceController ()

@end

@implementation ImageMessageInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
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
           // UIImage* contactPic = [UIImage imageWithContentsOfFile:contactLocalPicPath];
           // [self.remoteUserImage setImage:contactPic];

            ////// ----------- START ------------- /////////
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
                
                UIImage* contactPic =  [UIImage imageWithData:[NSData dataWithContentsOfFile:contactLocalPicPath] scale:[UIScreen mainScreen].scale];
                [self.remoteUserImage setImage:contactPic];
                
            }else{
                UIImage* contactPic = [UIImage imageWithContentsOfFile:contactLocalPicPath];
                [self.remoteUserImage setImage:contactPic];
            }
            
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
        
        if([IVAudioLoader isNumeric:dataObj.contactName]){
            [self.remoteUserName setText:[@"+" stringByAppendingString:dataObj.contactName]];
            [self setTitle:dataObj.contactName];

        }
        else{
            [self.remoteUserName setText:dataObj.contactName];
            [self setTitle:dataObj.contactName];
        }
        [self.groupForImage setCornerRadius:10];

        NSString* msgLocalPath = [[IVAudioLoader getTempSharedDirectoryPath]stringByAppendingPathComponent:dataObj.msgId];
        
        isFileExistImage = [fm fileExistsAtPath:msgLocalPath];
        if(isFileExistImage)
        {
//Deepak_Carpenter : Added this code to download data in <iOS8.4 version
           // UIImage* imgMain = [UIImage imageWithContentsOfFile:msgLocalPath];
           // [self.imageMessage setImage:imgMain];
            ////// ----------- START ------------- /////////
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
                
                UIImage* imgMain =  [UIImage imageWithData:[NSData dataWithContentsOfFile:msgLocalPath] scale:[UIScreen mainScreen].scale];
                
                
                [self.imageMessage setImage:imgMain];
            }else{
                UIImage* imgMain = [UIImage imageWithContentsOfFile:msgLocalPath];
                [self.imageMessage setImage:imgMain];
            }
            //////---------------END---------------////////

        }
        else
        {
//Deepak_Carpenter : Added this code to add activity indicator untill image downloads
        ////// ----------- START ------------- /////////
        [self.imageMessage setImageNamed:@"Activity"];
        [self.imageMessage startAnimatingWithImagesInRange:NSMakeRange(1, 15) duration:1.0 repeatCount:0];
        //////---------------END---------------////////

           NSString* messageContentURL = dataObj.msgContent;
            [IVAudioLoader loadImageFileFromServerWithURL:messageContentURL andSaveToLocalPath:msgLocalPath withCompletionHandler:^(BOOL result){
                if(result)
                {
//Deepak_Carpenter : Added this code to download data in <iOS8.4 version
                    // UIImage* imgMain = [UIImage imageWithContentsOfFile:msgLocalPath];
                    // [self.imageMessage setImage:imgMain];
        ////// ----------- START ------------- /////////
                    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
                        
                        UIImage* imgMain =  [UIImage imageWithData:[NSData dataWithContentsOfFile:msgLocalPath] scale:[UIScreen mainScreen].scale];
                        [self.imageMessage setImage:imgMain];
                        [self.imageMessage stopAnimating];
                        
                    }else{
                        UIImage* imgMain = [UIImage imageWithContentsOfFile:msgLocalPath];
                        [self.imageMessage setImage:imgMain];
                        [self.imageMessage stopAnimating];
                    }
        //////---------------END---------------////////
                }
            }];
        }
        _contactNumber = dataObj.contactNumber;
    }
    // Configure interface objects here.
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
    [ImageMessageInterfaceController openParentApplication:contactInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        KLog(@"Reply: %@",replyInfo);
    }];
}
- (IBAction)forceTouceButtonAction {
    NSDictionary* contactInfo = @{@"PHONE":_contactNumber};
    [ImageMessageInterfaceController openParentApplication:contactInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        KLog(@"Reply: %@",replyInfo);
    }];
}
@end



