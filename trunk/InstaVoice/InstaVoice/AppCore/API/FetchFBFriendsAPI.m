//
//  FetchFBFriendsAPI.m
//  InstaVoice
//
//  Created by adwivedi on 26/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "FetchFBFriendsAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"

@implementation FetchFBFriendsAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(NSMutableDictionary *)requestDic withSuccess:(void (^)(FetchFBFriendsAPI *, NSMutableDictionary *))success failure:(void (^)(FetchFBFriendsAPI *, NSError *))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:FETCH_FRIENDS];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
