//
//  DownloadProfilePic.m
//  InstaVoice
//
//  Created by adwivedi on 08/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "DownloadProfilePic.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "SettingModel.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "RegistrationApi.h"
#import "Profile.h"
#import "Common.h"

@implementation DownloadProfilePic
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSString*) filePath withSuccess:(void (^)(DownloadProfilePic* req , NSData* responseObject))success failure:(void (^)(DownloadProfilePic* req, NSError *error))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [req downloadDataWithURLString:filePath withSuccess:^(NetworkCommon *req, id responseObject) {
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
    
}
@end
