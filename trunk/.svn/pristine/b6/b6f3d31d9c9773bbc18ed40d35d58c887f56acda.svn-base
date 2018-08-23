//
//  JoinUserAPI.m
//  InstaVoice
//
//  Created by adwivedi on 22/09/15.
//  Copyright © 2015 Kirusa. All rights reserved.
//

#import "JoinUserAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "SettingModel.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "RegistrationApi.h"

@implementation JoinUserAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(JoinUserAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(JoinUserAPI* req, NSError *error))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:JOIN_USER];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        
        if ([responseObject[@"new_user"]boolValue]) {
            [[ConfigurationReader sharedConfgReaderObj]setIsFreshSignUpStatus:YES];
            [[ConfigurationReader sharedConfgReaderObj]setInAppPromoImageShownStatus:NO];

        }
        else
            [[ConfigurationReader sharedConfgReaderObj]setIsFreshSignUpStatus:NO];

#ifdef REACHME_APP
        if ([responseObject[@"new_rm_user"]boolValue]) {
            [[ConfigurationReader sharedConfgReaderObj]setIsRMFreshSignUpStatus:YES];
            [[ConfigurationReader sharedConfgReaderObj]setInAppPromoImageShownStatus:NO];
            
        }
        else
            [[ConfigurationReader sharedConfgReaderObj]setIsRMFreshSignUpStatus:NO];
#endif
        
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
