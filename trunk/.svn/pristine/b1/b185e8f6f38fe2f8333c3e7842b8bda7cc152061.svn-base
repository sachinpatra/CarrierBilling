//
//  FetchObdDebitPolicyAPI.m
//  ReachMe
//
//  Created by Pandian on 03/07/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FetchObdDebitPolicyAPI.h"

@implementation FetchObdDebitPolicyAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*)requestDic
               withSuccess:(void (^)(FetchObdDebitPolicyAPI* req , NSMutableDictionary* responseObject))success
                   failure:(void (^)(FetchObdDebitPolicyAPI* req, NSError *error))failure
{
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:FETCH_OBD_CALL_DEBIT]; //cmd = "fetch_obd_call_debit"
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        //KLog(@"API Failure %@ %@", error, [error localizedDescription]);
        failure(self,error);
    }];
}

@end
