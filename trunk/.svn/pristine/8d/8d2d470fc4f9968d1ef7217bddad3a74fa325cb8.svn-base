//
//  FetchVoipSettingAPI.m
//  InstaVoice
//
//  Created by Pandian on 7/3/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConversationApi.h" //keys
#import "RegistrationApi.h"
#import "FetchVoipSettingAPI.h"
#import "NetworkCommon.h"
#import "Setting.h"
#import "SettingModel.h"
#import "ConfigurationReader.h"
#import "EventType.h"
#import "Common.h"
#import "Logger.h"


@implementation FetchVoipSettingAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchVoipSettingAPI* req , SettingModelVoip* responseObject))success failure:(void (^)(FetchVoipSettingAPI* req, NSError *error))failure
{
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:FETCH_VOIP_SETTING_REQ];
    
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        EnLogd(@"FetchVoipSetting = %@",responseObject);
        KLog(@"FetchVoipSetting = %@",responseObject);
        self.response=responseObject;
        SettingModelVoip* model = [self createSettingModelVoipObjectFromDictionary:responseObject];
        
        success(self,model);
    } failure:^(NetworkCommon *req, NSError *error) {
        EnLogd(@"FetchVoipSetting failed: %@",error);
        KLog(@"FetchVoipSetting failed: %@",error);
        failure(self,error);
    }];
}

-(SettingModelVoip*) createSettingModelVoipObjectFromDictionary:(NSMutableDictionary*)responseObject {
    
    SettingModelVoip* voipSetting = [[SettingModelVoip alloc]init];
    NSString* status = [responseObject valueForKey:@"status"];
    if([status isEqualToString:@"ok"]) {
        
        NSMutableDictionary* dicVoipInfo = [responseObject valueForKey:API_VOIP_INFO];
        if(dicVoipInfo && dicVoipInfo.count>0) {
            voipSetting.serverUrl = [dicVoipInfo valueForKey:API_IP];
            voipSetting.serverPort = [[dicVoipInfo valueForKey:API_PORT]integerValue];
        }
        
        NSMutableDictionary* dicUserInfo = [responseObject valueForKey:API_USER_INFO];
        if(dicUserInfo && dicUserInfo.count>0) {
            voipSetting.userName = [[dicUserInfo valueForKey:API_USER_ID]stringValue];
            voipSetting.password = [dicUserInfo valueForKey:API_PWD];
            return voipSetting;
        }
    }
    
    return nil;
}
@end
