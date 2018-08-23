//
//  FetchStatesAPI.m
//  InstaVoice
//
//  Created by adwivedi on 05/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "FetchStatesAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "SettingModel.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "RegistrationApi.h"
#import "Profile.h"
#import "Common.h"

@implementation FetchStatesAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchStatesAPI* req , NSMutableArray* responseObject))success failure:(void (^)(FetchStatesAPI* req, NSError *error))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:FETCH_STATES];
    [requestDic setValue:[requestDic valueForKey:COUNTRY_CODE] forKey:API_COUNTRY_CODE];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        NSMutableArray* stateList = [[NSMutableArray alloc]init];
        NSArray *states = [responseObject valueForKey:API_STATES];
        if(states != nil && [states count])
        {
            int count = (int)[states count];
            for (int i =0; i<count; i++)
            {
                NSMutableDictionary *statedic = [states objectAtIndex:i];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setValue:[statedic valueForKey:API_STATE_ID] forKey:STATE_ID];
                [dic setValue:[statedic valueForKey:API_STATE_NM] forKey:STATE_NAME];
                [dic setValue:[requestDic valueForKey:API_COUNTRY_CODE] forKey:COUNTRY_CODE];
                [stateList addObject:dic];
            }
        }
        success(self,stateList);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
