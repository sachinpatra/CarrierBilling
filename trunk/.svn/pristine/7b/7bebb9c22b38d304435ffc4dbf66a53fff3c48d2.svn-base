//
//  LoginAPI.m
//  InstaVoice
//
//  Created by adwivedi on 06/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "LoginAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "SettingModel.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "RegistrationApi.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif

#import "Macro.h"
#import "Common.h"
#import "Profile.h"
#import "Setting.h"
#import "IVFileLocator.h"

#include "MQTTManager.h"

#import "Contacts.h"

@implementation LoginAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        appDelegate = (AppDelegate *)APP_DELEGATE;
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(LoginAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(LoginAPI* req, NSError *error))failure
{
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:SIGN_IN];
    
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        [self processVerifyUserResponse:responseObject];
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

-(void)processVerifyUserResponse:(NSMutableDictionary*)respDic
{
    NSDictionary *reqDic = self.request;
    NSString *status = [respDic valueForKey:@"status"];
    if([status isEqualToString:@"ok"])
    {
        NSString *loginId = [reqDic valueForKey:API_LOGIN_ID];
        NSString *pwd = [reqDic valueForKey:API_PWD];
        NSString *prevLoginId = [appDelegate.confgReader getLoginId];
        if(prevLoginId != nil && [prevLoginId length]>0)
        {
            if(![prevLoginId isEqualToString:loginId])
            {
               [appDelegate.confgReader setContactServerSyncFlag:NO];
                [IVFileLocator deleteDirAndSubDir:[IVFileLocator getMediaDirectory]];
                
                //Added by Nivedita - Date 5th July.
                //Clearing the information only if loggedin user is different from the current logged in user.
                NSString* localFileName = [NSString stringWithFormat:@"CarrierLogo_%@.png",prevLoginId];
                [IVFileLocator deleteFileAtPath:[IVFileLocator getCarrierLogoPath:localFileName]];
                
                //Setting into Default theme color.
                [[Setting sharedSetting]setCarrierThemeColorForNumber:DEFAULT_THEMECOLOR number:prevLoginId];
                

                //Delete all core data DB
                /* NOV 2017
                NSError* error1 = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"ContactModel.*"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error1];
                [self removeFiles:regex inPath:NSHomeDirectory()];
                */
                
                [appDelegate.engObj resetLoginData:NO];
                [appDelegate.confgReader setVolumeMode:SPEAKER_MODE];
                [appDelegate.confgReader setVsmsLimit:0];
                
                [[ConfigurationReader sharedConfgReaderObj]setDefaultNetworkData:nil];
                [[ConfigurationReader sharedConfgReaderObj]setNetworkData:nil];
            }
            else
            {
                //AVN_TO_DO
                //[appDelegate.engObj resyncPendingContact];
                //[[Setting sharedSetting]setDeviceInfo];
            }
        }
        else
        {
            [appDelegate.confgReader setVsmsLimit:0];
            [appDelegate.confgReader setVolumeMode:SPEAKER_MODE];
        }
        
#ifdef MQTT_ENABLED
        /*
        TODO Need to be called from other place
        NSNumber* deviceID = [respDic valueForKey:@"iv_user_device_id"];
        [[MQTTManager sharedMQTTManager]connectMQTTClient:deviceID];
        */
#endif
        
        [appDelegate.confgReader setUserSecureKey:[respDic valueForKey:API_USER_SECURE_KEY]];
        //[[Setting sharedSetting]setDeviceInfo:nil];
        [appDelegate.confgReader setPnsAppID:[respDic valueForKey:API_PNS_APP_ID]];
        [appDelegate.confgReader setDocsUrl:[respDic valueForKey:API_DOCS_URL]];
        NSNumber *ivid = [respDic valueForKey:API_IV_USER_ID];
        [appDelegate.confgReader setIVUserId:[ivid longValue]];
        
        /* FEB 17, 2017 -- TODO discuss with Ajay
         There is no proper info from server whether the screen_name is set by user or by server.
         If it is set by server other than with random number, this code will break.
         */
        NSString* screenName = [respDic valueForKey:API_SCREEN_NAME];
        if(![self isNumber:screenName])
            [appDelegate.confgReader setScreenName:[respDic valueForKey:API_SCREEN_NAME]];
        
        //Save Login Info
        [appDelegate.confgReader setLoginId:loginId];
        [appDelegate.confgReader setPassword:pwd withTime:nil];
        
        //Start - Added by Nivedita - Date Apr 28
        [appDelegate.confgReader setCurrentLoggedInPhoneNumber:loginId];
        //End
        
        [appDelegate.confgReader setFBConnectUrl:[respDic valueForKey:API_FB_CONNECT_URL]];
        [appDelegate.confgReader setTWConnectUrl:[respDic valueForKey:API_TW_CONNECT_URL]];
        
        [appDelegate.confgReader setIsLoggedIn:TRUE];
        
        BOOL isFB = [[respDic valueForKey:API_FB_CONNECTED] boolValue];
        BOOL isTW = [[respDic valueForKey:API_TW_CONNECTED]boolValue];
        [appDelegate.confgReader setIsFBConnected:isFB];
        [appDelegate.confgReader setIsTWConnected:isTW];
        
        NSString *supportIDs = [respDic valueForKey:API_IV_SUPPORT_CONTACT_IDS];
        NSData *data = [supportIDs dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSMutableArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        [[Setting sharedSetting]saveSupportContacts:arr];
        [appDelegate registerForPushNotification];
#ifdef REACHME_APP
        [appDelegate registerForVOIPPush];
#endif
        //NSString *profilePicUri = [respDic valueForKey:API_PROFILE_PIC_URI];
        [[Profile sharedUserProfile]getProfileDataFromServer];
        KLog(@"Calling fetchMsgRequest...");
        [appDelegate.engObj fetchMsgRequest:nil];
        [appDelegate.confgReader setISSignUp:NO];
        
        //Nivedita - Call fetch Secondary Numbers
        [[Contacts sharedContact]fetchSecondaryNumbers];
    }
}

//FEB 17, 2017
-(BOOL)isNumber:(NSString*)text
{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber* number = [numberFormatter numberFromString:text];
    
    if (number != nil)
        return TRUE;
    
    return FALSE;
}
//

//MAY 16
- (void)removeFiles:(NSRegularExpression*)regex inPath:(NSString*)path {
    NSDirectoryEnumerator *filesEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    
    NSString *file;
    NSError *error;
    while (file = [filesEnumerator nextObject]) {
        NSUInteger match = [regex numberOfMatchesInString:file
                                                  options:0
                                                    range:NSMakeRange(0, [file length])];
        
        if (match) {
            [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
        }
    }
}
//

@end
