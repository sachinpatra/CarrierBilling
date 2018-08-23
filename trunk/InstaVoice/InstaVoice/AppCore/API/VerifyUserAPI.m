//
//  VerifyUserAPI.m
//  InstaVoice
//
//  Created by adwivedi on 06/05/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "VerifyUserAPI.h"
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
#import "Profile.h"
#import "Setting.h"
#import "Contacts.h"

@implementation VerifyUserAPI
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

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(VerifyUserAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(VerifyUserAPI* req, NSError *error))failure
{
   // NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:VERIFY_USER];
    
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
    NSString *loginId = [respDic valueForKey:API_LOGIN_ID];
    [appDelegate.confgReader setVolumeMode:SPEAKER_MODE];
    [appDelegate.confgReader setUserSecureKey:[respDic valueForKey:API_USER_SECURE_KEY]];
    NSNumber *ivid = [respDic valueForKey:API_IV_USER_ID];
    [appDelegate.confgReader setIVUserId:[ivid longValue]];
    [appDelegate.confgReader setFBConnectUrl:[respDic valueForKey:API_FB_CONNECT_URL]];
    [appDelegate.confgReader setTWConnectUrl:[respDic valueForKey:API_TW_CONNECT_URL]];
    //Start: Added by Nivedita - Date Apr 28
    if (nil == loginId) {
        loginId = [[ConfigurationReader sharedConfgReaderObj]getCurrentLoggedInPhoneNumber];
    }
    //End
    [appDelegate.confgReader setLoginId:loginId];
    [appDelegate.confgReader setIsLoggedIn:TRUE];
    [appDelegate registerForPushNotification];
#ifdef REACHME_APP
    [appDelegate registerForVOIPPush];
#endif
    //[appDelegate.engObj deleteMsgTable];
    [appDelegate.confgReader setISSignUp:YES];
    [appDelegate.confgReader setVsmsLimit:0];
    
    [[Profile sharedUserProfile]getProfileDataFromServer];
    
    //Added by Nivedita - Fetch Secondary Numbers
    //Nivedita - Call fetch Secondary Numbers
    [[Contacts sharedContact]fetchSecondaryNumbers];

    /* NOV 20
    NSString *supportIDs = [respDic valueForKey:API_IV_SUPPORT_CONTACT_IDS];
    NSData *data = [supportIDs dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSMutableArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    */
    
    BOOL isFB = [[respDic valueForKey:API_FB_CONNECTED] boolValue];
    BOOL isTW = [[respDic valueForKey:API_TW_CONNECTED]boolValue];
    [appDelegate.confgReader setIsFBConnected:isFB];
    [appDelegate.confgReader setIsTWConnected:isTW];
    
    UserProfileModel* model = [[Profile sharedUserProfile]getUserProfile];
    NSMutableDictionary *profilePicdic = [[NSMutableDictionary alloc] init];
    NSString* localPicPath = [appDelegate.confgReader getUserProfilePicPath];
    if(localPicPath){
        [profilePicdic setValue:localPicPath forKey:LOCAL_PIC_PATH];
        [profilePicdic setValue:@"png" forKey:PIC_TYPE];
        model.localPicPath = localPicPath;
        [[Profile sharedUserProfile]uploadProfilePicWithPath:localPicPath fileName:@""];
    }
}

-(NSMutableDictionary*)createDic
{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:@"" forKey:SCREEN_NAME];
    [dic setValue:@"" forKey:COUNTRY_NAME];
    [dic setValue:@"" forKey:COUNTRY_CODE];
    [dic setValue:@"" forKey:STATE_NAME];
    [dic setValue:@"" forKey:CITY_NAME];
    if([appDelegate.confgReader getUserGender])
        [dic setValue:[appDelegate.confgReader getUserGender] forKey:GENDER];
    else
        [dic setValue:@"" forKey:GENDER];
    NSNumber *dob = [appDelegate.confgReader getUserDob];
    if(dob)
        [dic setValue:dob forKey:DOB];
    else
        [dic setValue:[NSNumber numberWithLongLong:0] forKey:DOB];
    return dic;
}

@end
