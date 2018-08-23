//
//  FetchMessageAPI.m
//  InstaVoice
//
//  Created by adwivedi on 18/05/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "FetchMessageAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ConversationApi.h"
#import "ConfigurationReader.h"

#define MAX_ROWS  1000
#define VSMS_LIMIT  50

@implementation FetchMessageAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(NSMutableDictionary *)requestDic withSuccess:(void (^)(FetchMessageAPI*, NSMutableDictionary *))success failure:(void (^)(FetchMessageAPI*, NSError *))failure
{
    [NetworkCommon addCommonData:requestDic eventType:FETCH_MSG];
    long afterID = [[ConfigurationReader sharedConfgReaderObj] getAfterMsgId];
    NSNumber *afterNum = [NSNumber numberWithLong:afterID];
    [requestDic setValue:afterNum forKey:API_FETCH_AFTER_MSGS_ID];
    
    NSNumber *maxRow = [NSNumber numberWithInt:MAX_ROWS];
    [requestDic setValue:maxRow forKey:API_FETCH_MAX_ROWS];

    [requestDic setValue:[NSNumber numberWithBool:YES] forKey:API_FETCH_OPPONENT_CONTACTIDS];
    self.request = requestDic;
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
