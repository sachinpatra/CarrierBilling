//
//  LikeUnlikeMessageAPI.m
//  InstaVoice
//
//  Created by Jatin Mitruka on 3/23/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "LikeUnlikeMessageAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ConfigurationReader.h"
#import "TableColumns.h"
#import "HttpConstant.h"
#import "ConversationApi.h"
#import "ChatActivity.h"
#import "Macro.h"

@implementation LikeUnlikeMessageAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(ChatActivityData *)activity withSuccess:(void (^)(LikeUnlikeMessageAPI *, BOOL))success failure:(void (^)(LikeUnlikeMessageAPI *, NSError *))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [NetworkCommon addCommonData:requestDic eventType:MSG_ACTIVITY];
    NSString* type = activity.msgType;
    
    if([type isEqualToString:CELEBRITY_TYPE]) {
        [requestDic setValue:VB_TYPE forKey:API_MSG_CONTENT_TYPE];
    } else {
        [requestDic setValue:type forKey:API_MSG_TYPE];
    }
    
    [requestDic setValue:[NSNumber numberWithInt:activity.msgId] forKey:API_MSG_ID];
    
    if(activity.activityType == ChatActivityTypeLike)
        [requestDic setValue:API_LIKE forKey:API_ACTIVITY];
    else
        [requestDic setValue:API_UNLIKE forKey:API_ACTIVITY];
    
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        success(self,YES);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end

