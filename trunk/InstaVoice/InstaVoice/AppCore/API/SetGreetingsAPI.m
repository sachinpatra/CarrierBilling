//
//  SetGreetingsAPI.m
//  InstaVoice
//
//  Created by adwivedi on 14/10/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "SetGreetingsAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "SettingModel.h"
#import "ConfigurationReader.h"
#import "Profile.h"
#import "MyProfileApi.h"

@implementation SetGreetingsAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(NSMutableDictionary *)requestDic withSuccess:(void (^)(SetGreetingsAPI *, NSMutableDictionary *))success failure:(void (^)(SetGreetingsAPI *, NSError *))failure
{
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    NSString *filePath = [requestDic valueForKey:@"greeting_file_path"];
    NSString* fileName = [requestDic valueForKey:@"greeting_file_name"];
    
    [NetworkCommon addCommonData:requestDic eventType:SET_GREETINGS];
    
    [req uploadDataWithRequest:requestDic fileName:fileName filePath:filePath withSuccess:^(NetworkCommon *req, id responseObject) {
        UserProfileModel* model = [[Profile sharedUserProfile] profileData];
        NSString *responseGreetingName = [responseObject valueForKey:API_GREETING_NAME];
        MissedCallGreetingMessage* greetingName = [[MissedCallGreetingMessage alloc]init];
        if(responseGreetingName != Nil){
            NSData *data = [responseGreetingName dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *greetingDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            greetingName.mediaDuration = [greetingDic valueForKey:API_GREETING_DURATION];
            greetingName.mediaFormat = [greetingDic valueForKey:API_GREETING_FORMAT];
            greetingName.mediaUrl = [greetingDic valueForKey:API_GREETING_URI];
        }
        model.greetingName = greetingName;
        
        NSString *responseGreetingWelcome = [responseObject valueForKey:API_GREETING_WELCOME];
        MissedCallGreetingMessage* greetingWelcome = [[MissedCallGreetingMessage alloc]init];
        if(responseGreetingWelcome != Nil){
            NSData *data = [responseGreetingWelcome dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *greetingDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            greetingWelcome.mediaDuration = [greetingDic valueForKey:API_GREETING_DURATION];
            greetingWelcome.mediaFormat = [greetingDic valueForKey:API_GREETING_FORMAT];
            greetingWelcome.mediaUrl = [greetingDic valueForKey:API_GREETING_URI];
        }
        model.greetingWelcome = greetingWelcome;
        [[Profile sharedUserProfile]writeProfileDataInFile];
    } failure:^(NetworkCommon *req, NSError *error) {
    }];
}

-(void)deleteFileForRequest:(NSMutableDictionary *)requestDic withSuccess:(void (^)(SetGreetingsAPI *, NSMutableDictionary *))success failure:(void (^)(SetGreetingsAPI *, NSError *))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:SET_GREETINGS];
    
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary *responseObject) {
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
