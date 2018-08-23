//
//  InAppPurchaseApi.m
//  InstaVoice
//
//  Created by Gundala Yaswanth on 12/5/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "InAppPurchaseApi.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ConfigurationReader.h"
#import "RegistrationApi.h"

@implementation InAppPurchaseApi
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(InAppPurchaseApi* req , NSMutableDictionary* responseObject))success failure:(void (^)(InAppPurchaseApi* req, NSError *error))failure
{
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];    
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

- (void)callNetworkRequestToFetchProductList:(NSMutableDictionary*) requestDic withSuccess:(void (^)(InAppPurchaseApi* req , NSMutableDictionary* responseObject))success failure:(void (^)(InAppPurchaseApi* req, NSError *error))failure
{
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
