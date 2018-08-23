//
//  ShareMessageAPI.m
//  InstaVoice
//
//  Created by Jatin Mitruka on 3/23/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "ShareMessageAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "ConversationApi.h"
#import "ChatActivity.h"
#import "Macro.h"

@implementation ShareMessageAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(ChatActivityData *)activity withSuccess:(void (^)(ShareMessageAPI *, BOOL))success failure:(void (^)(ShareMessageAPI *, NSError *))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];

    if(activity.activityType == ChatActivityTypeVoboloShare)
        [requestDic setValue:VB_TYPE forKey:API_APP];
    else if(activity.activityType == ChatActivityTypeFacebookShare)
        [requestDic setValue:FB_TYPE forKey:API_APP];
    else if(activity.activityType == ChatActivityTypeTwitterShare)
        [requestDic setValue:TW_TYPE forKey:API_APP];

    NSString* msgType = activity.msgType;
    if([msgType isEqualToString:CELEBRITY_TYPE]) {
        [requestDic setValue:@"vb" forKey:API_MSG_CONTENT_TYPE];
    }
    [requestDic setValue:[NSNumber numberWithInt:activity.msgId] forKey:API_MSG_ID];
    [NetworkCommon addCommonData:requestDic eventType:POST_ON_WALL];
    
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        success(self,YES);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
