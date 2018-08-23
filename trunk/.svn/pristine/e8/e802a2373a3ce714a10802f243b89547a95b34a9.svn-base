//
//  UpdateAppStatus.m
//  InstaVoice
//
//  Created by Pandian on 27/04/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpdateAppStatus.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ConfigurationReader.h"
#import "Logger.h"

@implementation UpdateAppStatusAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(BOOL) isAppForeground withSuccess:(void (^)(UpdateAppStatusAPI* req , BOOL responseObject))success failure:(void (^)(UpdateAppStatusAPI* req, NSError *error))failure
{
   // NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [NetworkCommon addCommonData:requestDic eventType:APP_STATUS];
    
    if(isAppForeground)
    {
        [requestDic setValue:@"fg" forKey:@"status"];
        long afterID = [[ConfigurationReader sharedConfgReaderObj] getAfterMsgId];
        if(afterID > 0)
        {
            NSNumber *afterNum = [NSNumber numberWithLong:afterID];
            [requestDic setValue:afterNum forKey:@"last_msg_id"];
        }
    }
    else
        [requestDic setValue:@"bg" forKey:@"status"];

    
    KLog(@"Sending app status. req dic = %@",requestDic);
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        success(self,YES);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
