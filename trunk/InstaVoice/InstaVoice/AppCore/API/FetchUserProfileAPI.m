//
//  FetchUserProfileAPI.m
//  InstaVoice
//
//  Created by adwivedi on 05/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "FetchUserProfileAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "MyProfileApi.h"
#import "Profile.h"
#import "Common.h"
#import "Setting.h"

@implementation FetchUserProfileAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchUserProfileAPI* req , UserProfileModel* responseObject))success failure:(void (^)(FetchUserProfileAPI* req, NSError *error))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:GET_USER_PROFILE_REQ];
    self.request = requestDic;
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        UserProfileModel* model = [self createProfileModelObjectFromDictionary:responseObject];
        success(self,model);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

-(UserProfileModel*)createProfileModelObjectFromDictionary:(NSMutableDictionary*)userDic
{
    UserProfileModel* model = [[Profile sharedUserProfile] getUserProfile];
    
    if(userDic != nil && [userDic count]>0)
    {
        
        NSData *vsmsLimitData = [[userDic valueForKey:@"vsms_limits"] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *vsmsLimitDic;
        if(vsmsLimitData)
            vsmsLimitDic = [NSJSONSerialization JSONObjectWithData:vsmsLimitData options:0 error:&error];
        
        if(error == nil || vsmsLimitDic != nil)
        {
            NSNumber *limit = [vsmsLimitDic valueForKey:@"limit"];
            [[ConfigurationReader sharedConfgReaderObj] setVsmsLimit:[limit intValue]];
        }
        
        
        NSString *loginId = [userDic valueForKey:API_LOGIN_ID];
        if(loginId != nil && [loginId length]>0)
        {
            model.loginId = loginId;
        }
        else //Start: Added by Nivedita - Date Apr 28
        {
            loginId = [[ConfigurationReader sharedConfgReaderObj]getCurrentLoggedInPhoneNumber];
            model.loginId = loginId;
        }
        //End
        
        NSString *countryCode = [userDic valueForKey:API_COUNTRY_CODE];
        if(countryCode != nil && [countryCode length]>0)
        {
            NSString *value = [countryCode substringToIndex:1];
            NSString *newStr;
            if([value isEqualToString:@"0"])
            {
                newStr = [countryCode substringFromIndex:1];
            }
            else
            {
                newStr = countryCode;
            }
            model.countryCode = countryCode;
            
            
            NSString* countryName = [[Setting sharedSetting]getCountryNameFromCountryCode:countryCode];
            model.countryName = countryName;
        }
        
        NSString *state = [userDic valueForKey:API_STATE];
        if(state != nil && [state length]>0)
        {
            model.stateName = state;
        }
        
        NSString *city = [userDic valueForKey:API_CITY];
        if(city != nil && [city length]>0)
        {
            model.cityName = city;
        }
        
        NSString *gen = [userDic valueForKey:API_GENDER];
        if(gen != nil && [gen length]>0)
        {
            model.gender = gen;
        }
        
        NSDictionary *dobDic = [userDic valueForKey:API_DATE_OF_BIRTH];
        if(dobDic != nil && [dobDic count]>0)
        {
            NSString *dayOfMonth = [dobDic valueForKey:API_DAY_OF_MONTH];
            NSString *hourOfDay = [dobDic valueForKey:API_HOUR_OF_DAY];
            NSString *minute = [dobDic valueForKey:API_MINUTE];
            NSString *month = [dobDic valueForKey:API_MONTH];
            NSString *second = [dobDic valueForKey:API_SECOND];
            NSString *year = [dobDic valueForKey:API_YEAR];
            int intDayofmonth = [dayOfMonth intValue];
            int inthourOfDay = [hourOfDay intValue];
            int intMinute = [minute intValue];
            int intMonth = [month intValue];
            int intSec = [second intValue];
            int intYear = [year intValue];
            NSDate *dob = [Common getDateAndTimeInMiliSec:intYear month:(intMonth+1) dateOfMonth:intDayofmonth hourOfDay:inthourOfDay minute:intMinute second:intSec];
            //Commented by Vinoth for VinothtimeIntervalSince1970
            //NSNumber *num = [NSNumber numberWithDouble:[dob  timeIntervalSince1970]];
            NSNumber *num = [NSNumber numberWithDouble:[dob  timeIntervalSinceDate:IVDOBreferenceDate]];
            
            model.dob = num;
        }
        
        NSString *primaryContactNumber = userDic[API_PRIMARY_CONTACT];
        if(primaryContactNumber)
            model.primaryContactNumber = primaryContactNumber;
        
        NSString *screenName = [userDic valueForKey:API_SCREEN_NAME];
        if(screenName != nil && [screenName length]>0)
        {
            model.screenName = screenName;
        }
        
        NSString *profileEmail = [userDic valueForKey:API_PROFILE_EMAIL];
        if(profileEmail != nil && [profileEmail length]>0)
        {
            model.profileEmailId = profileEmail;
        }
        
        NSString *profilePicPath = [userDic valueForKey:API_PROFILE_PIC_URI];
        if(profilePicPath != nil && [profilePicPath length]>0)
        {
            model.profilePicPath = profilePicPath;
        }
        
        NSNumber *ivID = [NSNumber  numberWithLongLong:[[ConfigurationReader sharedConfgReaderObj] getIVUserId]];
        model.ivUserId = [ivID stringValue];
        
        NSString *responseGreetingName = [userDic valueForKey:API_GREETING_NAME];
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
        
        NSString *responseGreetingWelcome = [userDic valueForKey:API_GREETING_WELCOME];
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
        
        NSString* inviteSmsText = [userDic valueForKey:API_INVITE_SMS_TEXT];
        if(inviteSmsText != nil || inviteSmsText.length > 0)
            model.inviteSmsText = inviteSmsText;
        
        NSString* voiceMailStr = [userDic valueForKey:API_VOICEMAIL];
        if(voiceMailStr && voiceMailStr.length > 1)
        {
            NSData *data = [voiceMailStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *voiceMail = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            model.enableEmailForVSMS = [[voiceMail valueForKey:@"vsms_enabled"] boolValue];
            model.enableEmailForMissedCall = [[voiceMail valueForKey:@"mc_enabled"] boolValue];
            model.emailForVSMSAndMissedCall = [voiceMail valueForKey:@"email"];
            model.emailTimeZone = [voiceMail valueForKey:@"time_zone"];
        }
        
        //NSNumber* voicemailVerified =[userDic valueForKey:API_VOICEMAIL_VERIFIED];
        //model.emailVerifiedForVSMSAndMissedCall = [voicemailVerified boolValue];
        model.emailVerifiedForVSMSAndMissedCall = YES;
    }
    return model;
}

@end
