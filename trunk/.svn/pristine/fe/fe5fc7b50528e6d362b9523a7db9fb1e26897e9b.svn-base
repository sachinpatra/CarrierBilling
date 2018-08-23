//
//  AudioMessageInterfaceController.m
//  InstaVoice
//
//  Created by adwivedi on 13/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "AudioMessageInterfaceController.h"
#import "IVAudioLoader.h"
#import "Audio.h"
#import "NotificationData.h"
#import "Logger.h"

//Deepak_Carpenter : Commented and declared the same in .h
//@interface AudioMessageInterfaceController ()<AudioDelegate>
//@property(nonatomic,strong)Audio* audioObj;
/*
@interface AudioMessageInterfaceController ()
@end
*/

@implementation AudioMessageInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.audioObj = [[Audio alloc]init];
    self.audioObj.delegate = self;
    [self setTitle:@""];

    // Configure interface objects here.
    if([context isKindOfClass:[NotificationData class]])
    {
        NotificationData* dataObj = context;
        if([dataObj.msgType isEqualToString:@"iv"])
            [self.audioLabel setText:@"Audio Message"];
        else
            [self.audioLabel setText:@"Voicemail"];
        
        if([IVAudioLoader isNumeric:dataObj.contactName]){
            [self.remoteUserName setText:[@"+" stringByAppendingString:dataObj.contactName]];
            [self setTitle:dataObj.contactName];
        }
        else{
            [self.remoteUserName setText:dataObj.contactName];
            [self setTitle:dataObj.contactName];
        }
     //   _duration = dataObj.msgDuration ;
        //added +1 because timer was displaying 1 sec less time 
        _duration = dataObj.msgDuration + 1;
        [self.audioTimer setDate:[NSDate dateWithTimeIntervalSinceNow:_duration]];
        
        [self.playButton setEnabled:NO];
    
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
           ///
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

        
        [self.groupForImage setCornerRadius:24];
        [self.brandImage setImageNamed:@"iv_icon_new"];
    
        NSString* serverPath = dataObj.msgContent;
        NSString* msgLocalPath = [[IVAudioLoader getTempSharedDirectoryPath]stringByAppendingPathComponent:dataObj.msgId];
    
        BOOL isFileExist = [fm fileExistsAtPath:[msgLocalPath stringByAppendingPathExtension:@"wav"]];
        if(isFileExist)
        {
            msgLocalPath = [msgLocalPath stringByAppendingPathExtension:@"wav"];
            self.audioFilePath = msgLocalPath;
            [self.playButton setEnabled:YES];
        }
        else
        {
            [IVAudioLoader loadAudioFileFromServerWithURL:serverPath andSaveToLocalPath:msgLocalPath withCompletionHandler:^(BOOL result){
                if(result)
                {
                    self.audioFilePath = [msgLocalPath stringByAppendingPathExtension:@"wav"];
                    [self.playButton setEnabled:YES];
                }
            }];
        }
        
        _contactNumber = dataObj.contactNumber;
        
    }
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    //Deepak_Carpenter : Added this code to reset timer + Button label when watch active from sleep mode
    [self.audioObj stopPlayback];
    [self.audioTimer stop];
    [self.audioTimer setDate:[NSDate dateWithTimeIntervalSinceNow:_duration]];
    [self.playButton setTitle:@"Play"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"newRemoteNotification"]) {
        [self pushControllerWithName:@"interfaceController" context:nil];
    }
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [self.audioTimer stop];
    [self.audioObj stopPlayback];
}

- (IBAction)playAction {
    if([self.audioObj isPlay])
    {
        [self.audioObj stopPlayback];
        [self.audioTimer stop];
        [self.audioTimer setDate:[NSDate dateWithTimeIntervalSinceNow:_duration]];
        [self.playButton setTitle:@"Play"];
    }
    else
    {
        [self.audioObj startPlayback:self.audioFilePath playTime:0 playMode:YES];
        [self.audioTimer setDate:[NSDate new]];
        [self.audioTimer start];
        [self.playButton setTitle:@"Stop"];
    }
}

- (IBAction)callAction {
    NSDictionary* contactInfo = @{@"PHONE":_contactNumber};
    [AudioMessageInterfaceController openParentApplication:contactInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        KLog(@"Reply: %@",replyInfo);
    }];
}

-(void)audioDidCompletePlayingData
{
    [self.audioObj stopPlayback];
    [self.audioTimer stop];
    [self.audioTimer setDate:[NSDate dateWithTimeIntervalSinceNow:_duration]];
    [self.playButton setTitle:@"Play"];
}

-(void)didProximityStateChange:(BOOL)state {
}

-(void)didAudioRouteChange:(NSInteger)reason {
    
}

- (IBAction)forceTouceButtonAction {
    NSDictionary* contactInfo = @{@"PHONE":_contactNumber};
    [AudioMessageInterfaceController openParentApplication:contactInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        KLog(@"Reply: %@",replyInfo);
    }];
}
@end



