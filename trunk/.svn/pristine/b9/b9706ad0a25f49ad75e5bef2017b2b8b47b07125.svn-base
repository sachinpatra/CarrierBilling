//
//  SetDeviceInfoAPI.m
//  InstaVoice
//
//  Created by adwivedi on 06/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "SetDeviceInfoAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "SettingModel.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "RegistrationApi.h"

#import "Logger.h"

@implementation SetDeviceInfoAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(SetDeviceInfoAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(SetDeviceInfoAPI* req, NSError *error))failure
{
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:SET_DEVICE_INFO];
    
    NSString* usk = [requestDic valueForKey:API_USER_SECURE_KEY];
    if(![usk length]) {
        EnLogd(@"user_secure_key is nill.");
    }
    
    //EnLogd(@"cmd:SET_DEVICE_INFO req:%@",requestDic);
    //KLog(@"cmd:SET_DEVICE_INFO req:%@",requestDic);
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
        EnLogd(@"cmd:set_device_info Error:%@",error);
        KLog(@"cmd:set_device_info Error:%@",error);
    }];
}

@end
