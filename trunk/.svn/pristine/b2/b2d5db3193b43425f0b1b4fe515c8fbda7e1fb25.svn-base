//
//  VoiceMailHLRAPI.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 03/08/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "VoiceMailHLRAPI.h"
#import "NetworkCommon.h"
#import "ConfigurationReader.h"
#import "ServerApi.h"
#import "EventType.h"
#import "Common.h"

@implementation VoiceMailHLRAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(VoiceMailHLRAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(VoiceMailHLRAPI* req, NSError *error))failure
{
    
    phoneNumber = [requestDic valueForKey:@"phone_num"];
    counter = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(activationTimeExceeds:)
                                   userInfo:requestDic
                                    repeats:YES];
    
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:VOICEMAIL_SETTINGS];//cmd = "voicemail_setting"
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        success(self,responseObject);
#ifndef REACHME_APP
        [self showSuccessOrFailure:@"success"];
#endif
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
#ifndef REACHME_APP
        [self showSuccessOrFailure:@"error"];
#endif
    }];
}

- (void)activationTimeExceeds:(NSTimer *)timer{
    counter ++;
}

- (void)showSuccessOrFailure:(NSString *)response
{
    [timer invalidate];
    
    if (counter < 31 && [response isEqualToString:@"success"]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        notification.alertTitle = @"ACTIVATION SUCCESSFULL";
        notification.alertBody = [NSString stringWithFormat:@"InstaVoice is active on %@",[Common getFormattedNumber:phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:phoneNumber,@"phone_number",@"hlr_activation",@"notification_type", nil];
        notification.userInfo = userInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }else{
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        notification.alertTitle = @"ACTIVATION FAILED";
        notification.alertBody = [NSString stringWithFormat:@"Sorry, we were unable to activate your voicemail. Please try again."];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:phoneNumber,@"phone_number",@"hlr_activation",@"notification_type", nil];
        notification.userInfo = userInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
}

@end
