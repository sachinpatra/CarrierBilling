//
//  ManageUserContactAPI.m
//  InstaVoice
//
//  Created by kirusa on 12/22/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ManageUserContactAPI.h"
#import "NetworkCommon.h"
#import "ConfigurationReader.h"
#import "ServerApi.h"
#import "EventType.h"

#import "Common.h"

@implementation ManageUserContactAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(ManageUserContactAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(ManageUserContactAPI* req, NSError *error))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:MANAGE_USER_CONTACT];//cmd = "manage_user_contact"
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
