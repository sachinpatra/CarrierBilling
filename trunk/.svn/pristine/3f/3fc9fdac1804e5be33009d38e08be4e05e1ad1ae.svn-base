//
//  FetchBlockedUsersAPI.m
//  InstaVoice
//
//  Created by adwivedi on 11/12/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "FetchBlockedUsersAPI.h"

@implementation FetchBlockedUsersAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchBlockedUsersAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(FetchBlockedUsersAPI* req, NSError *error))failure
{
    [requestDic setValue:[NSNumber numberWithBool:YES] forKey:@"fetch_blocked_user_list"];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:FETCH_BLOCK_USER_LIST];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
