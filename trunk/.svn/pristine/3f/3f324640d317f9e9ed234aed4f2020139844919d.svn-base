//
//  UserProfileModel.m
//  InstaVoice
//
//  Created by adwivedi on 02/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "UserProfileModel.h"

@implementation MissedCallGreetingMessage

-(id)init
{
    if(self = [super init])
    {
        _mediaFormat = @"";
        _mediaUrl = @"";
        _mediaDuration = [NSNumber numberWithDouble:0];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [self init])
    {
        _mediaDuration = [aDecoder decodeObjectForKey:@"MEDIA_DURATION"];
        _mediaUrl = [aDecoder decodeObjectForKey:@"MEDIA_URL"];
        _mediaFormat = [aDecoder decodeObjectForKey:@"MEDIA_FORMAT"];
    }
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_mediaDuration forKey:@"MEDIA_DURATION"];
    [aCoder encodeObject:_mediaUrl forKey:@"MEDIA_URL"];
    [aCoder encodeObject:_mediaFormat forKey:@"MEDIA_FORMAT"];
}

-(NSString*)description
{
    NSString *myProfile = [NSString stringWithFormat:@"MissedCallGreetingMessage : uri %@, duration %d, format = %@ ",_mediaUrl,[_mediaDuration intValue],_mediaFormat];
    return myProfile;
}

-(NSString*)debugDescription
{
    NSString *myProfile = [NSString stringWithFormat:@"MissedCallGreetingMessage : uri %@, duration %d, format = %@ ",_mediaUrl,[_mediaDuration intValue],_mediaFormat];
    return myProfile;
}

@end

@implementation UserProfileModel

-(id)init
{
    if(self = [super init])
    {
        _ivUserId = @"";
        _loginId = @"";
        _countryCode = @"";
        _countryName = @"";
        _cityName = @"";
        _stateName = @"";
        _gender = @"";
        _dob = [NSNumber numberWithDouble:0];
        _screenName = @"";
        _profilePicPath = @"";
        _cropProfilePicPath = @"";
        _localPicPath = @"";
        _picType = @"";
        _profileSyncFlag = YES;
        _picSyncFlag = YES;
        _greetingName = [[MissedCallGreetingMessage alloc]init];
        _greetingWelcome = [[MissedCallGreetingMessage alloc]init];
        _inviteSmsText = @"";
        
        _emailForVSMSAndMissedCall = @"";
        _emailTimeZone = @"";
        _emailVerifiedForVSMSAndMissedCall = NO;
        _enableEmailForMissedCall = NO;
        _enableEmailForVSMS = NO;
        _profileEmailId = @"";
        
        _additionalNonVerifiedNumbers = [[NSMutableArray alloc]init];
        _additionalVerifiedNumbers    = [[NSMutableArray alloc]init];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [self init])
    {
        _profileSyncFlag = [aDecoder decodeBoolForKey:@"PROFILE_SYNC_FLAG"];
        _picSyncFlag = [aDecoder decodeBoolForKey:@"PIC_SYNC_FLAG"];
        
        _ivUserId = [aDecoder decodeObjectForKey:@"IV_USER_ID"];
        _loginId = [aDecoder decodeObjectForKey:@"LOGIN_ID"];
        _countryCode = [aDecoder decodeObjectForKey:@"COUNTRY_CODE"];
        _countryName = [aDecoder decodeObjectForKey:@"COUNTRY_NAME"];
        _cityName = [aDecoder decodeObjectForKey:@"CITY_NAME"];
        _stateName = [aDecoder decodeObjectForKey:@"STATE_NAME"];
        _gender = [aDecoder decodeObjectForKey:@"GENDER"];
        _dob = [aDecoder decodeObjectForKey:@"DOB"];
        _screenName = [aDecoder decodeObjectForKey:@"SCREEN_NAME"];
        _profilePicPath = [aDecoder decodeObjectForKey:@"PROFILE_PIC_PATH"];
        _cropProfilePicPath = [aDecoder decodeObjectForKey:@"CROP_PROFILE_PIC_PATH"];
        _localPicPath = [aDecoder decodeObjectForKey:@"LOCAL_PIC_PATH"];
        _picType = [aDecoder decodeObjectForKey:@"PIC_TYPE"];
        _greetingWelcome = [aDecoder decodeObjectForKey:@"GREETING_WELCOME"];
        _greetingName = [aDecoder decodeObjectForKey:@"GREETING_NAME"];
        _inviteSmsText = [aDecoder decodeObjectForKey:@"INVITE_SMS_TEXT"];
        
        _additionalVerifiedNumbers = [aDecoder decodeObjectForKey:@"ADDITIONAL_VERIFIED_NUMBERS"];
        _additionalNonVerifiedNumbers = [aDecoder decodeObjectForKey:@"ADDITIONAL_NON_VERIFIED_NUMBERS"];
        
        _emailForVSMSAndMissedCall = [aDecoder decodeObjectForKey:@"EMAIL_VSMS_MISSEDCALL"];
        _emailTimeZone = [aDecoder decodeObjectForKey:@"EMAIL_TIMEZONE"];
        
        _emailVerifiedForVSMSAndMissedCall = [aDecoder decodeBoolForKey:@"EMAIL_VERIFIED_VSMS_MISSEDCALL"];
        _enableEmailForMissedCall = [aDecoder decodeBoolForKey:@"ENABLE_EMAIL_MISSEDCALL"];
        _enableEmailForVSMS = [aDecoder decodeBoolForKey:@"ENABLE_EMAIL_VSMS"];
        
        _profileEmailId = [aDecoder decodeObjectForKey:@"PROFILE_EMAIL_ID"];
        self.primaryContactNumber = [aDecoder decodeObjectForKey:@"PRIMARY_CONTACT_NUMBER"];

    }
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:_profileSyncFlag forKey:@"PROFILE_SYNC_FLAG"];
    [aCoder encodeBool:_picSyncFlag forKey:@"PIC_SYNC_FLAG"];

    [aCoder encodeObject:_ivUserId forKey:@"IV_USER_ID"];
    [aCoder encodeObject:_loginId forKey:@"LOGIN_ID"];
    [aCoder encodeObject:_countryCode forKey:@"COUNTRY_CODE"];
    [aCoder encodeObject:_countryName forKey:@"COUNTRY_NAME"];
    [aCoder encodeObject:_cityName forKey:@"CITY_NAME"];
    [aCoder encodeObject:_stateName forKey:@"STATE_NAME"];
    [aCoder encodeObject:_gender forKey:@"GENDER"];
    [aCoder encodeObject:_dob forKey:@"DOB"];
    [aCoder encodeObject:_screenName forKey:@"SCREEN_NAME"];
    [aCoder encodeObject:_profilePicPath forKey:@"PROFILE_PIC_PATH"];
    [aCoder encodeObject:_cropProfilePicPath forKey:@"CROP_PROFILE_PIC_PATH"];
    [aCoder encodeObject:_localPicPath forKey:@"LOCAL_PIC_PATH"];
    [aCoder encodeObject:_picType forKey:@"PIC_TYPE"];
    [aCoder encodeObject:_greetingWelcome forKey:@"GREETING_WELCOME"];
    [aCoder encodeObject:_greetingName forKey:@"GREETING_NAME"];
    [aCoder encodeObject:_inviteSmsText forKey:@"INVITE_SMS_TEXT"];
    
    [aCoder encodeObject:_additionalVerifiedNumbers forKey:@"ADDITIONAL_VERIFIED_NUMBERS"];
    [aCoder encodeObject:_additionalNonVerifiedNumbers forKey:@"ADDITIONAL_NON_VERIFIED_NUMBERS"];
    
    [aCoder encodeObject:_emailForVSMSAndMissedCall forKey:@"EMAIL_VSMS_MISSEDCALL"];
    
    [aCoder encodeObject:_emailTimeZone forKey:@"EMAIL_TIMEZONE"];
    
    [aCoder encodeBool:_emailVerifiedForVSMSAndMissedCall forKey:@"EMAIL_VERIFIED_VSMS_MISSEDCALL"];
    [aCoder encodeBool:_enableEmailForMissedCall forKey:@"ENABLE_EMAIL_MISSEDCALL"];
    [aCoder encodeBool:_enableEmailForVSMS forKey:@"ENABLE_EMAIL_VSMS"];
    
    [aCoder encodeObject:_profileEmailId forKey:@"PROFILE_EMAIL_ID"];
    
    [aCoder encodeObject:self.primaryContactNumber forKey:@"PRIMARY_CONTACT_NUMBER"];

}

- (void)dealloc {
  //  NSLog(@"Profile dealloc");
}


@end
