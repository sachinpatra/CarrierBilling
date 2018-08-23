//
//  WithdrawMessageAPI.m
//  InstaVoice
//
//  Created by Pandian on 29/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WithdrawMessageAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "ConversationApi.h"
#import "ChatActivity.h"

@implementation WithdrawMessageAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(ChatActivityData*) activity withSuccess:(void (^)(WithdrawMessageAPI* req , BOOL responseObject))success failure:(void (^)(WithdrawMessageAPI* req, NSError *error))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [NetworkCommon addCommonData:requestDic eventType:WITHDRAW_MSG];
    [requestDic setValue:@"true" forKey:@"is_revoke"];
    [requestDic setValue:[NSNumber numberWithInteger:activity.msgId] forKey:API_MSG_ID];
    [requestDic setValue:activity.msgType forKey:API_MSG_TYPE];
    
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        success(self,YES);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
