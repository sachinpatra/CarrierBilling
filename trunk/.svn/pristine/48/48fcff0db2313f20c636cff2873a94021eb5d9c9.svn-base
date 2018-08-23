//
//  VerifyPasswordAPI.m
//  InstaVoice
//
//  Created by adwivedi on 06/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "VerifyPasswordAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "SettingModel.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "RegistrationApi.h"


@implementation VerifyPasswordAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(VerifyPasswordAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(VerifyPasswordAPI* req, NSError *error))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:VERIFY_PWD];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        [[ConfigurationReader sharedConfgReaderObj] setUserSecureKey:[responseObject valueForKey:API_USER_SECURE_KEY]];
        NSNumber *ivid = [responseObject valueForKey:API_IV_USER_ID];
        [[ConfigurationReader sharedConfgReaderObj] setIVUserId:[ivid longValue]];
        self.response=responseObject;
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
