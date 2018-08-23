//
//  RegisterUserAPI.m
//  InstaVoice
//
//  Created by adwivedi on 06/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "RegisterUserAPI.h"
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

@implementation RegisterUserAPI
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

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(RegisterUserAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(RegisterUserAPI* req, NSError *error))failure
{
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:REG_USER];
    
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
    [appDelegate.engObj resetLoginData:NO];
    [appDelegate.confgReader setRegSecureKey:[respDic valueForKey:API_REG_SECURE_KEY]];
    [appDelegate.confgReader setPnsAppID:[respDic valueForKey:API_PNS_APP_ID]];
    [appDelegate.confgReader setDocsUrl:[respDic valueForKey:API_DOCS_URL]];
    [appDelegate registerForPushNotification];
#ifdef REACHME_APP
    [appDelegate registerForVOIPPush];
#endif
}

@end
