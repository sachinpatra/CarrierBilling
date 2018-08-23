//
//  UsageSummaryAPI.m
//  ReachMe
//
//  Created by Bhaskar Munireddy on 07/02/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "UsageSummaryAPI.h"
#import "NetworkCommon.h"
#import "ConfigurationReader.h"
#import "ServerApi.h"
#import "EventType.h"
#import "Common.h"

@implementation UsageSummaryAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(UsageSummaryAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(UsageSummaryAPI* req, NSError *error))failure
{
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:USAGE_SUMMARY];//cmd = "usage_summary"
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        success(self,responseObject);
        
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
        
    }];
}

@end
