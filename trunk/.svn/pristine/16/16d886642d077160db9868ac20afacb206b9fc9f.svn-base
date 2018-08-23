//
//  UpdateUserProfileAPI.m
//  InstaVoice
//
//  Created by adwivedi on 05/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "UpdateUserProfileAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "UserProfileModel.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "MyProfileApi.h"

@implementation UpdateUserProfileAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}
-(void)callNetworkRequest:(UserProfileModel *)model withSuccess:(void (^)(UpdateUserProfileAPI *, BOOL))success failure:(void (^)(UpdateUserProfileAPI *, NSError *))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [NetworkCommon addCommonData:requestDic eventType:UPDATE_PROFILE_INFO];
    [self updateReqDic:requestDic with:model];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        success(self,YES);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
    
}

- (void)updateVoicemailSubscription:(NSDictionary*)dic withSuccess:(void (^)(UpdateUserProfileAPI* req , BOOL responseObject))success failure:(void (^)(UpdateUserProfileAPI* req, NSError *error))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [NetworkCommon addCommonData:requestDic eventType:UPDATE_PROFILE_INFO];
    [requestDic setValue:dic forKey:API_VOICEMAIL];
    [requestDic setValue:[NSNumber numberWithBool:YES] forKey:@"voicemail_auto"];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        success(self,YES);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

- (void)updatePassword:(NSString*)newPassword withSuccess:(void (^)(UpdateUserProfileAPI* req , BOOL responseObject))success failure:(void (^)(UpdateUserProfileAPI* req, NSError *error))failure;
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [NetworkCommon addCommonData:requestDic eventType:UPDATE_PROFILE_INFO];
    [requestDic setValue:newPassword forKey:API_PWD];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        success(self,YES);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

-(void)updateReqDic:(NSMutableDictionary*)updateUserPro with:(UserProfileModel*)model
{
    [updateUserPro setValue:model.loginId forKey:API_LOGIN_ID];
    [updateUserPro setValue:model.countryCode forKey:API_COUNTRY_CODE];
    [updateUserPro setValue:model.cityName forKey:API_CITY];
    [updateUserPro setValue:model.stateName forKey:API_STATE];
    [updateUserPro setValue:model.gender forKey:API_GENDER];
    NSNumber *dob = model.dob;
    if([dob doubleValue] >0)
   {
        //Commented by Vinoth for VinothtimeIntervalSince1970
        //NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dob doubleValue]];
        NSDate *date = [NSDate dateWithTimeInterval:[dob doubleValue] sinceDate:IVDOBreferenceDate];

        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd-yyyy"];
        NSString *dateStr = [formatter stringFromDate:date];
        [updateUserPro setValue:dateStr forKey:API_DATE_OF_BIRTH];
        [updateUserPro setValue:@"MM-dd-yyyy" forKey:API_DOB_FORMAT];
    }
    else
    {
        [updateUserPro setValue:@"" forKey:API_DATE_OF_BIRTH];
        [updateUserPro setValue:@"MM-dd-yyyy" forKey:API_DOB_FORMAT];
    }
    [updateUserPro setValue:model.screenName forKey:API_SCREEN_NAME];
    [updateUserPro setValue:model.profileEmailId forKey:API_PROFILE_EMAIL];
    
   

}

@end
