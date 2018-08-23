//
//  FetchMessageActivityAPI.m
//  InstaVoice
//
//  Created by adwivedi on 18/05/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "FetchMessageActivityAPI.h"
#import "FetchMessageAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ConversationApi.h"
#import "ConfigurationReader.h"

@implementation FetchMessageActivityAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(NSMutableDictionary *)requestDic withSuccess:(void (^)(FetchMessageActivityAPI*, NSMutableDictionary *))success failure:(void (^)(FetchMessageActivityAPI*, NSError *))failure
{
    [NetworkCommon addCommonData:requestDic eventType:FETCH_MSG_ACTIVITY];
    long afterID = [[ConfigurationReader sharedConfgReaderObj] getAfterMsgActivityId];
    NSNumber *afterNum = [NSNumber numberWithLong:afterID];
    [requestDic setValue:afterNum forKey:API_FETCH_AFTER_MSG_ACTIVITY_ID];
    NSNumber *maxRow = [NSNumber numberWithInt:1000];
    [requestDic setValue:maxRow forKey:API_FETCH_MAX_ROWS];
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
