//
//  ReadMessageCountAPI.m
//  InstaVoice
//
//  Created by Jatin Mitruka on 3/27/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "ReadMessageCountAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "ConversationApi.h"
#import "ChatActivity.h"
#import "Macro.h"

@implementation ReadMessageCountAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(ChatActivityData *)activity withSuccess:(void (^)(ReadMessageCountAPI *, BOOL))success failure:(void (^)(ReadMessageCountAPI *, NSError *))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    
    [requestDic setValue:activity.msgDataList forKey:API_MSG_IDS];
    [requestDic setValue:activity.msgType forKey:API_MSG_IDS_TYPE];
    [NetworkCommon addCommonData:requestDic eventType:INCREMENT_READ_COUNT];
    
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        //NOV 2017 TODO: check later
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            success(self,YES);
        });
        
        //NOV 2017 success(self,YES);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
