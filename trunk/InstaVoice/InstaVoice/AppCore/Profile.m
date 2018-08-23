//
//  Profile.m
//  InstaVoice
//
//  Created by adwivedi on 05/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "Profile.h"
#import "FetchUserProfileAPI.h"
#import "DownloadProfilePic.h"
#import "ConfigurationReader.h"
#import "IVFileLocator.h"
#import "UpdateUserProfileAPI.h"
#import "TableColumns.h"
#import "UploadProfilePicAPI.h"
#import <AddressBook/AddressBook.h>
#import "OpusCoder.h"
#import "FetchBlockedUsersAPI.h"
#import "ServerErrorMsg.h"
#import "IVImageUtility.h"
#import "PendingEventManager.h"
#import "Logger.h"
#import "Contacts.h"

static Profile* sharedProfile = Nil;

@implementation Profile

-(id)init
{
    if(self = [super init])
    {
        NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath]
                                     stringByAppendingPathComponent:@"Profile.dat"];
        
        @try {
            self.profileData = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];
        }
        @catch (NSException *exception) {
            KLog(@"Unable to create object from archive file");
        }
        
        if(_profileData == Nil)
        {
            _profileData = [[UserProfileModel alloc]init];
        }
    }
    return self;
}

+(Profile *)sharedUserProfile
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedProfile = [[self alloc]init];
    });
    return sharedProfile;
}

-(void)getProfileDataFromServer
{
    EnLogd(@"getProfileDataFromServer");
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    FetchUserProfileAPI* api = [[FetchUserProfileAPI alloc]initWithRequest:dic];
    
    [api callNetworkRequest:dic withSuccess:^(FetchUserProfileAPI *req, UserProfileModel *responseObject) {
        //Download the profile pic if it has changed
        EnLogd("profilePicPath = %@",self.profileData.profilePicPath);
        if(![self.profileData.profilePicPath isEqualToString:responseObject.profilePicPath] ||
           !self.profileData.localPicPath.length) {
            [self downloadProfilePic:responseObject.profilePicPath];
        }
        
        //AVN_TO_DO -- check and get greeting file from server url in case of change
        [self checkAndDownloadNewGreetingMessage:responseObject];
        
        self.profileData = responseObject;
        [self writeProfileDataInFile];
        if (self.delegate && [self.delegate respondsToSelector:@selector(fetchProfileCompletedWith:)]) {
            [self.delegate fetchProfileCompletedWith:self.profileData];
        }
        
        [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidSucceedWithResponse:req.request forPendingEventType:PendingEventTypeFetchProfile];
        
        
    } failure:^(FetchUserProfileAPI *req, NSError *error) {
        KLog(@"FetchUserProfileAPI:%@",error);
        [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidFailWithError:error forPendingEventType:PendingEventTypeFetchProfile];
    }];
}

#pragma mark -- MissedCall Greeting data
-(void)checkAndDownloadNewGreetingMessage:(UserProfileModel*)serverResponse
{
    if(![self.profileData.greetingName.mediaUrl isEqualToString:serverResponse.greetingName.mediaUrl])
    {
        [self downloadAndSaveGreetingName:serverResponse.greetingName.mediaUrl];
    }
    if(![self.profileData.greetingWelcome.mediaUrl isEqualToString:serverResponse.greetingWelcome.mediaUrl])
    {
        [self downloadAndSaveGreetingWelcome:serverResponse.greetingWelcome.mediaUrl];
    }
}

-(void)downloadAndSaveGreetingName:(NSString*)greetingURL
{
    if (greetingURL && ![greetingURL isEqualToString:@""]) {
        DownloadProfilePic* api = [[DownloadProfilePic alloc]initWithRequest:Nil];
        [api callNetworkRequest:greetingURL withSuccess:^(DownloadProfilePic *req, NSData *responseObject) {
            NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            NSString* localFileName = [NSString stringWithFormat:@"name_greeting_%@.iv",loginId];
            
            [IVFileLocator deleteFileAtPath:[IVFileLocator getMyProfilePicPath:localFileName]];
            [IVFileLocator deleteFileAtPath:[IVFileLocator getMyProfilePicPath:[[localFileName stringByDeletingPathExtension]stringByAppendingPathExtension:@"wav"]]];
            
            BOOL isWritten = [responseObject writeToFile:[IVFileLocator getMyProfilePicPath:localFileName] atomically:YES];
            if(isWritten)
            {
                [self decodeAndSaveFileWithName:[IVFileLocator getMyProfilePicPath:localFileName]];
                if (self.delegate && [self.delegate respondsToSelector:@selector(fetchProfileCompletedWith:)]) {
                    [self.delegate fetchProfileCompletedWith:self.profileData];
                }
                
            }
            
        } failure:^(DownloadProfilePic *req, NSError *error) {
            //
        }];
    }
    else {
        
        NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
        NSString* localFileName = [NSString stringWithFormat:@"name_greeting_%@.iv",loginId];
        
        [IVFileLocator deleteFileAtPath:[IVFileLocator getMyProfilePicPath:localFileName]];
        [IVFileLocator deleteFileAtPath:[IVFileLocator getMyProfilePicPath:[[localFileName stringByDeletingPathExtension]stringByAppendingPathExtension:@"wav"]]];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(fetchProfileCompletedWith:)]) {
            [self.delegate fetchProfileCompletedWith:self.profileData];
        }
    }
}

-(void)downloadAndSaveGreetingWelcome:(NSString*)greetingURL
{
    
    if (greetingURL && ![greetingURL isEqualToString:@""]) {
        DownloadProfilePic* api = [[DownloadProfilePic alloc]initWithRequest:Nil];
        [api callNetworkRequest:greetingURL withSuccess:^(DownloadProfilePic *req, NSData *responseObject) {
            NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            NSString* localFileName = [NSString stringWithFormat:@"welcome_greeting_%@.iv",loginId];
            
            [IVFileLocator deleteFileAtPath:[IVFileLocator getMyProfilePicPath:localFileName]];
            [IVFileLocator deleteFileAtPath:[IVFileLocator getMyProfilePicPath:[[localFileName stringByDeletingPathExtension]stringByAppendingPathExtension:@"wav"]]];
            
            BOOL isWritten = [responseObject writeToFile:[IVFileLocator getMyProfilePicPath:localFileName] atomically:YES];
            if(isWritten)
            {
                //decode the message
                [self decodeAndSaveFileWithName:[IVFileLocator getMyProfilePicPath:localFileName]];
                if (self.delegate && [self.delegate respondsToSelector:@selector(fetchProfileCompletedWith:)]) {
                    [self.delegate fetchProfileCompletedWith:self.profileData];
                }
            }
            
        } failure:^(DownloadProfilePic *req, NSError *error) {
            //
        }];
        
    }
    else {
        NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
        NSString* localFileName = [NSString stringWithFormat:@"welcome_greeting_%@.iv",loginId];
        [IVFileLocator deleteFileAtPath:[IVFileLocator getMyProfilePicPath:localFileName]];
        [IVFileLocator deleteFileAtPath:[IVFileLocator getMyProfilePicPath:[[localFileName stringByDeletingPathExtension]stringByAppendingPathExtension:@"wav"]]];
        if (self.delegate && [self.delegate respondsToSelector:@selector(fetchProfileCompletedWith:)]) {
            [self.delegate fetchProfileCompletedWith:self.profileData];
        }
    }
}

-(void)decodeAndSaveFileWithName:(NSString*)filePath
{
    NSString* wavFilePath = [[filePath stringByDeletingPathExtension]stringByAppendingPathExtension:@"wav"];
    NSString* pcmFilePath = [[filePath stringByDeletingPathExtension]stringByAppendingPathExtension:@"pcm"];
    
    [IVFileLocator deleteFileAtPath:pcmFilePath];
    [IVFileLocator deleteFileAtPath:wavFilePath];
    const char* cOpusFile = [filePath UTF8String];
    const char* cPcmFile = [pcmFilePath UTF8String];
    const char* cWavFile = [wavFilePath UTF8String];
    
    //OpusCoder* _opusCoder = [[OpusCoder alloc]init];
    
    int iResult = [OpusCoder DecodeAudio:8000 OPUSFile:cOpusFile PCMFile:cPcmFile WAVFile:cWavFile];
    if(SUCCESS == iResult) {
    }
    else {
    }
    
}
#pragma mark -- MissedCall Greeting data End

-(void)writeProfileDataInFile
{
    NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath]
                                 stringByAppendingPathComponent:@"Profile.dat"];
    [NSKeyedArchiver archiveRootObject:self.profileData toFile:archiveFilePath];
    
}

-(UserProfileModel*)getUserProfile
{
    NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath]
                                 stringByAppendingPathComponent:@"Profile.dat"];
    
    UserProfileModel* profile = Nil;
    @try {
        profile = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];
    }
    @catch (NSException *exception) {
        KLog(@"Unable to create object from archive file");
    }
    
    if(profile == Nil)
    {
        profile = [[UserProfileModel alloc]init];
    }
    return profile;
}

-(void)updateUserProfile:(UserProfileModel *)profileData
{
    //write the new data to file and load again this data from file in _profile variable
    NSMutableDictionary* request = [[NSMutableDictionary alloc]init];
    UpdateUserProfileAPI* api = [[UpdateUserProfileAPI alloc]initWithRequest:request];
    [api callNetworkRequest:profileData withSuccess:^(UpdateUserProfileAPI *req, BOOL responseObject) {
        profileData.profileSyncFlag = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateProfileCompletedWith:)]) {
            [self.delegate updateProfileCompletedWith:self.profileData];
        }
    } failure:^(UpdateUserProfileAPI *req, NSError *error) {
        profileData.profileSyncFlag = NO;
    }];
    self.profileData = profileData;
    [self writeProfileDataInFile];
}

-(void)downloadProfilePic:(NSString *)filePath
{
    DownloadProfilePic* api = [[DownloadProfilePic alloc]initWithRequest:Nil];
    [api callNetworkRequest:filePath withSuccess:^(DownloadProfilePic *req, NSData *responseObject) {
        //
        // NSString* localFilePath = [IVFileLocator createImageDirectory];
        NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
        //localFilePath = [localFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",loginId]];
        NSString* localFileName = [NSString stringWithFormat:@"%@.png",loginId];
        
        BOOL isWritten = [responseObject writeToFile:[IVFileLocator getMyProfilePicPath:localFileName] atomically:YES];
        if(isWritten)
        {
            NSString* cropFileName = [self createCropImg:localFileName];
            self.profileData.localPicPath = localFileName;
            self.profileData.picSyncFlag =YES;
            self.profileData.cropProfilePicPath = cropFileName;
            [self writeProfileDataInFile];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(downloadPicCompletedWithPath:)]) {
                [self.delegate downloadPicCompletedWithPath:[IVFileLocator getMyProfilePicPath:localFileName]];
            } else {
                EnLogd(@"*** ERR: downloadPicCompletedWithPath: not found. CHECK");
                KLog(@"*** ERR: downloadPicCompletedWithPath: not found. CHECK");
            }
        }
        
    } failure:^(DownloadProfilePic *req, NSError *error) {
        //
    }];
    
}

-(NSString*)createCropImg:(NSString*)localFileName
{
    NSString* cropFileName = [NSString stringWithFormat:@"crop%@.png",[[ConfigurationReader sharedConfgReaderObj] getLoginId]];
    //NSString *filePath = [IVFileLocator createImageDirectory];
    //filePath = [filePath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"crop%@.png",[[ConfigurationReader sharedConfgReagerObj] getLoginId]]];
    CGSize size;
    
    if([[UIScreen mainScreen] bounds].size.height < 481)
    {
        size = CGSizeMake(DEVICE_WIDTH, 205);
    }
    else
    {
        size = CGSizeMake(DEVICE_WIDTH, 230);
    }
    
    UIImage *userImg = [IVImageUtility getUIImageFromFilePath:[IVFileLocator getMyProfilePicPath:localFileName]];
    UIImage *img = nil;
    BOOL isWritten = NO;
    if(userImg != nil)
    {
        img = [IVImageUtility cropImage:userImg targetSize:size];
        if(img != nil)
        {
            @autoreleasepool { //JAN 27 CMP
                NSData *data = UIImagePNGRepresentation(img);
                isWritten = [data writeToFile:[IVFileLocator getMyProfilePicPath:cropFileName] atomically:YES];
            }
        }
    }
    if(isWritten)
        return cropFileName;
    else
        return @"";
}


-(void)resetProfileData
{
    _profileData = [[UserProfileModel alloc]init];
    [self writeProfileDataInFile];
}

-(void)uploadProfilePicWithPath:(NSString*)path fileName:(NSString*)fileName
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:path forKey:LOCAL_PIC_PATH];
    [dic setValue:@"png" forKey:PIC_TYPE];
    
    UploadProfilePicAPI* api = [[UploadProfilePicAPI alloc]initWithRequest:dic];
    [api callNetworkRequest:dic withSuccess:^(UploadProfilePicAPI *req, NSMutableDictionary *responseObject) {
        _profileData.picType = @"png";
        _profileData.picSyncFlag = YES;
        _profileData.localPicPath = path;
        _profileData.profilePicPath = [responseObject valueForKey:@"profile_pic_uri"];
        [self writeProfileDataInFile];
    } failure:^(UploadProfilePicAPI *req, NSError *error) {
        _profileData.picType = @"png";
        _profileData.picSyncFlag = NO;
        _profileData.localPicPath = path;
        [self writeProfileDataInFile];
    }];
}

//AVN_TO_DO
/*-(void)updateUserProfileFromNativeAB:(NSMutableDictionary*)dic
 {
 if(dic != nil && [dic count]>0)
 {
 ABAddressBookRef addressBook = nil;
 CFErrorRef error = NULL;
 
 addressBook = ABAddressBookCreateWithOptions(NULL, &error);
 NSNumber *recordID = [dic valueForKey:CONTACT_ID];
 ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook,recordID.integerValue);
 
 NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
 NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
 if((firstName != nil && [firstName length]>0))
 {
 if(lastName != nil && [lastName length] >0)
 {
 firstName = [firstName stringByAppendingString:lastName];
 }
 self.profileData.screenName = firstName;
 }
 
 ABMultiValueRef st = ABRecordCopyValue(person, kABPersonAddressProperty);
 if (ABMultiValueGetCount(st) > 0)
 {
 CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(st, 0);
 NSString *city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
 NSString *state = CFDictionaryGetValue(dict, kABPersonAddressStateKey);
 NSString *country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);
 if(city != nil && [city length]>0)
 {
 self.profileData.cityName = city;
 }
 
 if(state != nil && [state length]>0)
 {
 self.profileData.stateName = state;
 }
 
 if(country != nil && [country length]>0)
 {
 //self.profileData.countryCode = [[ConfigurationReader sharedConfgReagerObj]getCountryCode];
 self.profileData.countryName = country;
 }
 CFRelease(dict);
 }
 CFRelease(st);
 CFTypeRef bDayProperty = ABRecordCopyValue(person, kABPersonBirthdayProperty);
 NSDate *date=(__bridge NSDate*)bDayProperty;
 if(date != nil)
 {
 //Commented by Vinoth for VinothtimeIntervalSince1970
 //NSNumber *num = [NSNumber numberWithDouble:[date  timeIntervalSince1970]];
 NSNumber *num = [NSNumber numberWithDouble:[date  timeIntervalSinceDate:IVDOBreferenceDate]];
 self.profileData.dob = num;
 CFRelease(bDayProperty);
 }
 
 CFDataRef picRef = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
 NSData *pic = (__bridge NSData*)picRef;
 if(pic != nil)
 {
 NSMutableString *fullPath = [[NSMutableString alloc]init];
 NSString *contactImgPath = [IVFileLocator createImageDirectory];
 NSString *imgName =[NSString stringWithFormat:@"/%@.png",[[ConfigurationReader sharedConfgReagerObj] getLoginId]];
 [fullPath appendString:contactImgPath];
 [fullPath appendString:imgName];
 
 BOOL isWritten = [pic writeToFile:fullPath atomically:YES];
 if(!isWritten)
 {
 fullPath = nil;
 }
 if(fullPath != nil && [fullPath length]>0)
 {
 NSMutableDictionary *reqDic = [[NSMutableDictionary alloc] init];
 [reqDic setValue:@"png" forKey:PIC_TYPE];
 [reqDic setValue:fullPath forKey:LOCAL_PIC_PATH];
 self.profileData.localPicPath = fullPath;
 [self uploadProfilePicWithPath:fullPath fileName:@""];
 }
 CFRelease(picRef);
 }
 CFRelease(addressBook);
 
 [self updateUserProfile:self.profileData];
 }
 }*/

-(void)fetchBlockedUserList
{
#ifndef REACHME_APP
    NSMutableDictionary* req = [[NSMutableDictionary alloc]init];
    FetchBlockedUsersAPI* api = [[FetchBlockedUsersAPI alloc]initWithRequest:req];
    [api callNetworkRequest:req withSuccess:^(FetchBlockedUsersAPI *req, NSMutableDictionary *responseObject) {
        if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
            KLog(@"Error getting blicked user userlist. api request %@",api.request);
        }
        else {
            NSMutableArray* blockedUserIvIDList = [[NSMutableArray alloc]init];
            
            NSArray* blockedUserList = [responseObject valueForKey:@"blocked_user_list"];
            for(NSDictionary* blockedUser in blockedUserList) {
                NSString* ivUserID = [blockedUser valueForKey:@"blocked_contact_id"];
                [blockedUserIvIDList addObject:ivUserID];
            }
            [[ConfigurationReader sharedConfgReaderObj]setObject:blockedUserIvIDList forTheKey:@"BLOCKED_USERS_SRV_LIST"];
            KLog(@"blocked users: %@",blockedUserIvIDList);
            
            /*TODO:CMP verify
             if(![blockedUserIvIDList count])
             [[ConfigurationReader sharedConfgReaderObj]setObject:blockedUserIvIDList forTheKey:@"BLOCKED_TILES"];
             */
        }
    } failure:^(FetchBlockedUsersAPI *req, NSError *error) {
        //TODO
        KLog(@"*** Error fetching blocked users list: %@",[error description]);
        EnLogd(@"*** Error fetching blocked users: %@", [error description]);
    }];
#endif
}

@end
