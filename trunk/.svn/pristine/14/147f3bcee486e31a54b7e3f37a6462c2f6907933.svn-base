//
//  DeleteMessageAPI.m
//  InstaVoice
//
//  Created by adwivedi on 16/03/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "DeleteMessageAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "ConversationApi.h"
#import "ChatActivity.h"

@implementation DeleteMessageAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(ChatActivityData*) activity withSuccess:(void (^)(DeleteMessageAPI* req , BOOL responseObject))success failure:(void (^)(DeleteMessageAPI* req, NSError *error))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [NetworkCommon addCommonData:requestDic eventType:DELETE_MSG];
    [requestDic setValue:[NSNumber numberWithInteger:activity.msgId] forKey:API_MSG_ID];
    [requestDic setValue:activity.msgType forKey:API_MSG_TYPE];
    
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        success(self,YES);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
