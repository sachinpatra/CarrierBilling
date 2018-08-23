//
//  BlockUnblockUserAPI.m
//  InstaVoice
//
//  Created by adwivedi on 03/12/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "BlockUnblockUserAPI.h"
#import "NetworkCommon.h"
#import "ConfigurationReader.h"
#import "ServerApi.h"
#import "EventType.h"

#import "Common.h"

@implementation BlockUnblockUserAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(BlockUnblockUserAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(BlockUnblockUserAPI* req, NSError *error))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:BLOCK_UNBLOCK];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
