///
//  VoipSetting.m
//  InstaVoice
//
//  Created by Pandian on 7/3/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoipSetting.h"
#import "FetchVoipSettingAPI.h"
#import "IVFileLocator.h"
#import "Logger.h"
#import "FetchVoipSettingAPI.h"
#import "RegistrationApi.h"

#define kVoipSettingArchive @"VoipSetting.dat"

@implementation VoipSetting

-(id)init
{
    if(self = [super init])
    {
        NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath]
                                     stringByAppendingPathComponent:kVoipSettingArchive];
        
        @try {
            self.voipInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];
        }
        @catch (NSException *exception) {
            KLog(@"Unable to create object from archive file");
            EnLogd(@"Unable to create file for voipSetting");
        }
    }
    return self;
}

+(VoipSetting *)sharedVoipSetting
{
    static VoipSetting *sharedVoipSetting;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedVoipSetting = [[self alloc]init];
    });
    return sharedVoipSetting;
}

-(void)getVoipSetting {
    
    KLog(@"getVoipSetting");
    
    NSMutableDictionary* reqDic = [[NSMutableDictionary alloc]init];
    BOOL voipSettingFetched = [[ConfigurationReader sharedConfgReaderObj]getVoipSettingFetched];
    
    //Start fetching the data - if we already not fetched the data or we do not have locally saved data.
    if(!voipSettingFetched || nil == self.voipInfo) {
        FetchVoipSettingAPI* req = [[FetchVoipSettingAPI alloc]initWithRequest:reqDic];
        [req callNetworkRequest:reqDic withSuccess:^(FetchVoipSettingAPI *req, SettingModelVoip* responseObject) {
            self.voipInfo = responseObject;
            if(self.voipInfo) {
                [[ConfigurationReader sharedConfgReaderObj]setVoipSettingFetched:YES];
                [self writeVoipSettingDataInFile];
                [self.delegate fetchVoipSettingCompletWith:self.voipInfo withFetchStatus:TRUE];
            }
        } failure:^(FetchVoipSettingAPI *req, NSError *error) {
            EnLogd(@"FetchVoipSettingAPI failed.%@",error);
            KLog(@"FetchVoipSettingAPI failed.%@",error);
            [self.delegate fetchVoipSettingCompletWith:nil withFetchStatus:FALSE];
        }];
    }
}

-(void)writeVoipSettingDataInFile
{
    NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath]
                                 stringByAppendingPathComponent:kVoipSettingArchive];
    BOOL bSaved = [NSKeyedArchiver archiveRootObject:self.voipInfo toFile:archiveFilePath];
    
    if(bSaved) {
        KLog(@"archiveRootObject returns TRUE");
    } else {
        KLog(@"archiveRootObject returns FALSE");
        EnLogd(@"Error saving settings");
    }
}

@end
