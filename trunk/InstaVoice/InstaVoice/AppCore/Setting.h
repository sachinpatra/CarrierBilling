//
//  Setting.h
//  InstaVoice
//
//  Created by adwivedi on 24/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingModel.h"
#import "ConfigurationReader.h"
#import "IVSettingsCountryCarrierInfo.h"

@protocol SettingProtocol <NSObject>
@optional 
- (void)fetchSettingCompletedWith:(SettingModel*)modelData withFetchStatus:(BOOL)withFetchStatus;
- (void)updateSettingCompletedWith:(SettingModel*)modelData withUpdateStatus:(BOOL)withUpdateStatus;
- (void)fetchListOfCarriersForCountry:(SettingModel *)modelData withFetchStatus:(BOOL)withFetchStatus;
- (void)fetchCarrierLogoPathCompletedWithStatus:(BOOL)withFetchStatus;
#ifndef REACHME_APP
- (void)fetchPromoImageCompletedWithStatus: (BOOL)withFetchStatus;
#endif
- (void)fetchSupportedCarrierLogoCompletedWithStatus: (BOOL)withStatus;

@end

@interface Setting : NSObject {
    SettingModel* _data;
    NSArray* _supportContactList;
    NSMutableArray *_countryList;
}

@property (nonatomic,strong)SettingModel* data;
@property (nonatomic,weak)id<SettingProtocol> delegate;
@property (nonatomic,strong)NSArray* supportContactList;
@property (nonatomic,assign) BOOL isVoicemailSupported;//NOV 16, 2016

+ (Setting*)sharedSetting;
- (void)resetSettingData;

- (void)getUserSettingFromServer;
- (void)updateUserSettingType:(SettingType)type andValue:(NSUInteger)value;
- (void)disconnectFBTwitter:(NSString*) type;
- (void)writeSettingDataInFile;
- (void)saveSupportContacts:(NSArray *)list;
- (NSMutableArray*)getCountryList;
- (void)setCountryInfo;
- (NSString*)getCountryNameFromCountryCode:(NSString*)countryCode;
- (NSString*)getCountryCodeFromCountryIsd:(NSString *)countryIsd;
- (NSString*)getCountrySimIsoFromCountryIsd:(NSString *)countryIsd;
- (void)setDeviceInfo:(NSString*)token;;
- (void)setDeviceInfoWithVoipToken:(NSString*)token;




//Nivedita : Method to update carrier details

- (void)updateCarrierSettingsInfo:(CarrierInfo *)carrierDetails numberSettingsInfo:(NumberInfo *)numberDetails;

- (void)updateCarrierSettingsInfo:(CarrierInfo *)carrierDetails;

- (void)updateNumberSettingsInfo:(NumberInfo *)numberDetails;

- (void)updateUserSettingsWithDefaultValueOfCustomSettingsForUserType:(enum LoggedInUserType)withLoginUserType;

- (void)clearUpdateSettingsStatus;

- (void)resetFetchAndUpdateStatus;

- (void)fetchCarrierList;

- (void)fetchListOfCarriersForCountry:(NSString *)countryCode;

- (void)updateCarrierSettingsInfoForDeletedSecondaryNumber:(NSString *)deletedSecondaryNumber;

- (void)updateNumberSettingsInfoForDeletedSecondaryNumber:(NSString *)deletedSecondaryNumber;

- (NSArray *)carrierListForCountry:(NSString *)withCountryCode;

- (CarrierInfo *)customCarrierInfoForPhoneNumber:(NSString *)phoneNumber; 

- (NumberInfo *)customNumberInfoForPhoneNumber:(NSString *)phoneNumber;

- (void)checkAndDownloadLatestCarrierLogo:(NSMutableDictionary *)serverResponse;

- (VoiceMailInfo *)voiceMailInfoForPhoneNumber:(NSString *)withPhoneNumber;

- (void)downloadAndSaveCarrierLogoImage:(NSString*)carrierLogoImagePath;

- (BOOL)shouldShowEnableVoiceMailInHomeTab;

- (BOOL)hasSupportedCustomCarrierInfo:(NSString *)phoneNumber;

- (BOOL)hasSupportedVoiceMailInfo:(NSString *)phoneNumber;

- (BOOL)hasValidSimInfoForPhoneNumber:(NSString *)phoneNumber;

- (BOOL)hasSupportedSimCarrierInfo:(NSString *)phoneNumber;

- (IVSettingsCountryCarrierInfo *)supportedCarrierInfoFromCustomSettingsForPhoneNumber:(NSString *)phoneNumber;

- (IVSettingsCountryCarrierInfo *)supportedCarrierInfoFromVoiceMailInfoForPhoneNumber:(NSString *)phoneNumber;

- (IVSettingsCountryCarrierInfo *)supportedCarrierInfoFromSimInfoForPhoneNumber:(NSString *)phoneNumber;

//Carrier theme color set and get method
- (NSString *)getCarrierThemeColorForNumber:(NSString *)phoneNumber;

- (void)setCarrierThemeColorForNumber:(NSString *)themeColor number:(NSString *)phoneNumber;

- (BOOL)hasCarrierContainsValidUSSDInfo:(IVSettingsCountryCarrierInfo *)carrierInfo; 

- (void)clearCarrierList;

- (void)removeOrAddTestCarrierBasedOnShowCarrierStatus;

#ifndef REACHME_APP
- (void)checkAndDownloadPromoImage:(SettingModel *)serverResponse;
- (BOOL)shouldShowInAppPromoImage;
#endif

- (void)downloadAndSaveSupportedCarrierLogoImage:(NSString*)carrierLogoImagePath;

@end
