//
//  RefferalCodeAPI.m
//  ReachMe
//
//  Created by Bhaskar Munireddy on 30/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "RefferalCodeAPI.h"
#import "NetworkCommon.h"
#import "ConfigurationReader.h"
#import "ServerApi.h"
#import "EventType.h"
#import "Common.h"

@implementation RefferalCodeAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(RefferalCodeAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(RefferalCodeAPI* req, NSError *error))failure
{
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:REFFERAL_CODE];//cmd = "validate_coupon"
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        success(self,responseObject);
        
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
        
    }];
}

@end
