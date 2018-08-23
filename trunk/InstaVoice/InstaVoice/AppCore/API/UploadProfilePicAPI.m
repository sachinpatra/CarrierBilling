//
//  UploadProfilePicAPI.m
//  InstaVoice
//
//  Created by adwivedi on 13/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "UploadProfilePicAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "SettingModel.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "RegistrationApi.h"
#import "Profile.h"
#import "Common.h"
#import "MyProfileApi.h"


@implementation UploadProfilePicAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(NSMutableDictionary *)picDic withSuccess:(void (^)(UploadProfilePicAPI *, NSMutableDictionary *))success failure:(void (^)(UploadProfilePicAPI *, NSError *))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    NSString *filePath = [picDic valueForKey:LOCAL_PIC_PATH];
    NSString* fileName =[[ConfigurationReader sharedConfgReaderObj] getLoginId];
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setValue:fileName forKey:API_FILE_NAME];
    [requestDic setValue:[picDic valueForKey:PIC_TYPE] forKey:API_FILE_TYPE];
    [NetworkCommon addCommonData:requestDic eventType:UPLOAD_PROFILE_PIC];
    

    [req uploadDataWithRequest:requestDic fileName:fileName filePath:filePath withSuccess:^(NetworkCommon *req, id responseObject) {
    } failure:^(NetworkCommon *req, NSError *error) {
    }];
}

@end
