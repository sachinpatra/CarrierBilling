//
//  SettingModel.h
//  InstaVoice
//
//  Created by adwivedi on 18/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingModelMqtt.h"

//VoiceMail Information
@interface VoiceMailInfo : NSObject
@property (nonatomic, strong) NSString  *phoneNumber;
@property (nonatomic, strong) NSString  *status;
@property (nonatomic, assign) NSInteger availableVocieMailCount;
@property (nonatomic, assign) NSInteger missedCallCount;
@property (nonatomic, assign) NSInteger realVocieMailCount;
@property (nonatomic, assign) NSInteger realMissedCallCount;
@property (nonatomic, assign) NSInteger lastMissedCallTimeStamp;
@property (nonatomic, assign) NSInteger lastVoiceMailCountTimeStamp;
@property (nonatomic, assign) NSInteger latestMessageCount;
@property (nonatomic, assign) NSInteger oldMessageCount;
@property (nonatomic, strong) NSString  *kVSMSKey;
@property (nonatomic, strong) NSString *carrierCountryCode;
@property (nonatomic, strong) NSNumber *vSMSNodeId;
@property (nonatomic, strong) NSString *networkId;
@property (nonatomic, assign) BOOL isVoiceMailEnabled;
@property (nonatomic, assign) BOOL isHLREnabled;
@property (nonatomic, strong) NSString *carrierLogoPath;
@property (nonatomic, assign) BOOL isVoipEnabled;
@property (nonatomic, assign) BOOL voipOBD;
@property (nonatomic, strong) NSString *carrierLogoSupportUrl;
@property (nonatomic, strong) NSString *carrierLogoHomeUrl;
@property (nonatomic, strong) NSString *voipIPAddress; //NOV 2017
@property (nonatomic, strong) NSString *carrierLogoLocalImagePath;
@property (nonatomic, assign) BOOL countryVoicemailSupport;
@property (nonatomic, strong) NSString *carrierThemeColor;
@property (nonatomic, strong) NSString *inAppPromoImageURL;
@property (nonatomic, assign) BOOL showInAppImage;
#ifdef REACHME_APP
@property (nonatomic, assign) BOOL reachMeIntl;
@property (nonatomic, assign) BOOL reachMeHome;
@property (nonatomic, assign) BOOL reachMeVM;
@property (nonatomic, strong) NSString *actiUNCF;
@property (nonatomic, strong) NSString *deactiUNCF;
@property (nonatomic, strong) NSString *actiAll;
@property (nonatomic, strong) NSString *deActiBoth;
@property (nonatomic, strong) NSString *deActiAll;
@property (nonatomic, strong) NSString *actiCnf;
@property (nonatomic, strong) NSString *deActiCnf;
#endif

- (VoiceMailInfo *)initWithVoiceMailInfo:(NSDictionary *)withVoiceMailInfo;
@end


@interface CarrierInfo : NSObject

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *networkId;
@property (nonatomic, strong) NSNumber *vSMSId;
@property (nonatomic, assign) BOOL isVoipEnabled;
@property (nonatomic, assign) BOOL isVoipStatusEnabled;
#ifdef REACHME_APP
@property (nonatomic, assign) BOOL isReachMeIntlActive;
@property (nonatomic, assign) BOOL isReachMeHomeActive;
@property (nonatomic, assign) BOOL isReachMeVMActive;
#endif
//Data Migration related changes.
@property (nonatomic, assign) BOOL shouldUpdateToServer;

- (CarrierInfo *)initWithPhoneNumber:(NSString *)withPhoneNumber withCarrierDetails:(NSString *)withCarrierInfo;
@end

@interface NumberInfo : NSObject

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *imgName;
@property (nonatomic, strong) NSString *titleName;
//Data Migration related changes.
@property (nonatomic, assign) BOOL shouldUpdateToServer;

- (NumberInfo *)initWithPhoneNumber:(NSString *)withPhoneNumber withNumberDetails:(NSString *)withNumberInfo;
@end

typedef enum : NSInteger {
	SettingTypeDisplayLocation = 0,
	SettingTypeMaxRecordTime,
	SettingTypeVoboloEnable,
    SettingTypeVoboloFBAutoPostEnable,
    SettingTypeVoboloTWAutoPostEnable,
    SettingTypeUserManualTrans,
    //Added by Nivedita to update the carrier info in the update_settings api-Date: 17th Dec
    SettingTypeCarrierInfoUpdated,
} SettingType;

@interface SettingModel : NSObject <NSCoding>
{
    BOOL _displayLocation;
    BOOL _fbConnected;
    BOOL _twConnected;
    BOOL _vbEnabled;
    BOOL _fbPostEnabled;
    BOOL _twPostEnabled;
    NSInteger _syncFlag;
    NSInteger _maxRecordTime;
    NSString* _ivUserId;
    SettingModelMqtt* _mqttSetting;
}

@property (nonatomic) BOOL displayLocation;
@property (nonatomic) BOOL fbConnected;
@property (nonatomic) BOOL twConnected;
@property (nonatomic) BOOL vbEnabled;
@property (nonatomic) BOOL fbPostEnabled;
@property (nonatomic) BOOL twPostEnabled;
@property (nonatomic) BOOL userManualTrans;
@property (nonatomic) BOOL countryManualTrans;
@property (nonatomic) NSInteger syncFlag;
@property (nonatomic) NSInteger maxRecordTime;
@property (nonatomic,strong)NSString* ivUserId;
@property (nonatomic,strong)SettingModelMqtt* mqttSetting;

//Data migration related changes.
@property (nonatomic, assign) BOOL shouldUpdateToServer;

//added by Vinoth
@property (nonatomic, assign)BOOL loginMatchesInstaVoiceNumber;
@property (nonatomic,strong)NSString* enableMissedCallNumber;
@property (nonatomic,strong)NSString* networkDefault;

//no need
@property(nonatomic,strong)NSString *checkStatusDialNumber;

//no need
@property(nonatomic,strong)NSString *checkStatusForwardNumber;

//no need
@property(nonatomic,strong)NSString *checkStatusAlternateDialNumber;

@property (nonatomic,strong)NSDictionary* ivUSSDDictSim;
@property (nonatomic,strong)NSDictionary* ivUSSDDictPhone;
@property (nonatomic)BOOL isNetworkSupportedMissedCall;

//newly added
@property (nonatomic,strong)NSString* disableMissedCallNumber;


//Latest added keys : Nivedita - Date 16th Dec
@property (nonatomic, strong) NSString *defaultRecordMode;
@property (nonatomic, strong) NSString *defaultVoiceMode;
@property (nonatomic, strong) NSString *storageLocation;
@property (nonatomic, assign) BOOL showFBFriend;
@property (nonatomic, assign) BOOL showTwitterFriend;
@property (nonatomic, strong) NSArray *carrierInfoList;
@property (nonatomic, strong) id carrierDetails;
@property (nonatomic, strong) NSArray *numberInfoList;
@property (nonatomic, strong) id numberDetails;
@property (nonatomic, strong) NSArray *voiceMailInfo;

@property (nonatomic, strong) NSMutableArray *listOfCarriers;


-(void)updateCallNumbersFromUSSDSim;
-(void)updateCallNumbersFromUSSDPhone;
-(void)updateOnlyNetworkFromUSSDSim:(NSString*)networkName;
-(void)updateOnlyNetworkFromUSSDPhone:(NSString*)networkName;
@end

