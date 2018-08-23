//
//  UserProfileModel.h
//  InstaVoice
//
//  Created by adwivedi on 02/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MissedCallGreetingMessage : NSObject <NSCoding>
{
    NSNumber* _mediaDuration;
    NSString* _mediaFormat;
    NSString* _mediaUrl;
}
@property (nonatomic,strong)NSNumber* mediaDuration;
@property (nonatomic,strong)NSString* mediaFormat;
@property (nonatomic,strong)NSString* mediaUrl;
@end


@interface UserProfileModel : NSObject <NSCoding>
{
    NSString* _ivUserId;
    NSString* _loginId;
    NSString* _countryCode;
    NSString* _countryName;
    NSString* _cityName;
    NSString* _stateName;
    NSString* _gender;
    NSNumber* _dob;
    NSString* _screenName;
    NSString* _profilePicPath;
    NSString* _cropProfilePicPath;
    NSString* _localPicPath;
    NSString* _picType;
    BOOL _profileSyncFlag;
    BOOL _picSyncFlag;
    MissedCallGreetingMessage* _greetingName;
    MissedCallGreetingMessage* _greetingWelcome;
    NSString* _inviteSmsText;
    
    NSMutableArray *_additionalVerifiedNumbers;
    NSMutableArray *_additionalNonVerifiedNumbers;
    
    BOOL _enableEmailForVSMS;
    BOOL _enableEmailForMissedCall;
    NSString* _profileEmailId;
    NSString* _emailForVSMSAndMissedCall;
    BOOL _emailVerifiedForVSMSAndMissedCall;
}

@property (nonatomic,strong)NSString* ivUserId;
@property (nonatomic,strong)NSString* loginId;
@property (nonatomic,strong)NSString* countryCode;
@property (nonatomic,strong)NSString* countryName;
@property (nonatomic,strong)NSString* cityName;
@property (nonatomic,strong)NSString* stateName;
@property (nonatomic,strong)NSString* gender;
@property (nonatomic,strong)NSNumber* dob;
@property (nonatomic,strong)NSString* screenName;
@property (nonatomic,strong)NSString* profilePicPath;
@property (nonatomic,strong)NSString* cropProfilePicPath;
@property (nonatomic,strong)NSString* localPicPath;
@property (nonatomic,strong)NSString* picType;
@property (nonatomic,strong)MissedCallGreetingMessage* greetingName;
@property (nonatomic,strong)MissedCallGreetingMessage* greetingWelcome;
@property (nonatomic,strong)NSString* inviteSmsText;

@property (nonatomic,strong)NSMutableArray *additionalVerifiedNumbers;
@property (nonatomic,strong)NSMutableArray *additionalNonVerifiedNumbers;

@property(nonatomic) BOOL enableEmailForVSMS;
@property(nonatomic) BOOL enableEmailForMissedCall;
@property(nonatomic) BOOL emailVerifiedForVSMSAndMissedCall;
@property(nonatomic,strong) NSString* profileEmailId;
@property(nonatomic,strong) NSString* emailForVSMSAndMissedCall;
@property(nonatomic,strong) NSString* emailTimeZone;

@property (nonatomic) BOOL profileSyncFlag;
@property (nonatomic) BOOL picSyncFlag;

//Primary Number
@property (nonatomic, strong) NSString* primaryContactNumber;


@end
