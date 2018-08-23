//
//  SendFriendInviteAPI.m
//  InstaVoice
//
//  Created by adwivedi on 16/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "SendFriendInviteAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ConversationApi.h"
#import "ConfigurationReader.h"
#import "Macro.h"
#import "Common.h"

@implementation SendFriendInviteAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(NSMutableDictionary *)requestDic withSuccess:(void (^)(SendFriendInviteAPI *, NSMutableDictionary *))success failure:(void (^)(SendFriendInviteAPI *, NSError *))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:SEND_TEXT_MSG];
    [requestDic setValue:@"t" forKey:API_MSG_CONTENT_TYPE];
    [requestDic setValue:INV_TYPE forKey:API_MSG_TYPE];
    [requestDic setValue:[NSNumber numberWithBool:NO] forKey:API_FETCH_MSGS];
    [requestDic setValue:@"Hello" forKey:API_MSG_TEXT];
    [requestDic setValue:[Common getGuid] forKey:API_GUID];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
