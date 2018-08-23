//
//  FetchContactsAPI.m
//  InstaVoice
//
//  Created by adwivedi on 05/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "FetchContactsAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ContactsApi.h"
#import "ConfigurationReader.h"

@implementation FetchContactsAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(NSMutableDictionary *)requestDic withSuccess:(void (^)(FetchContactsAPI *, NSMutableDictionary *))success failure:(void (^)(FetchContactsAPI *, NSError *))failure
{
   // NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:FETCH_CONTACTS];
    [requestDic setValue:[NSNumber numberWithInt:1] forKey:API_FETCH_PIC_URI_TYPE];
    NSNumber *lasttn = [[ConfigurationReader sharedConfgReaderObj] getLast_trno];
    [requestDic setValue:lasttn forKey:API_FETCH_AFTER_TRNO];
    
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
