//
//  SettingModel.m
//  InstaVoice
//
//  Created by adwivedi on 18/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "SettingModel.h"
#import "Logger.h"
#import "Setting.h"


//VoiceMailInfo Class
@implementation VoiceMailInfo

- (id)init {
    
    self = [super init];
    if(self) {
        self.phoneNumber = nil;
        self.status = nil;
        self.availableVocieMailCount = 0;
        self.missedCallCount = 0;
        self.realVocieMailCount = 0;
        self.realMissedCallCount = 0;
        self.lastMissedCallTimeStamp = 0;
        self.lastVoiceMailCountTimeStamp = 0;
        self.latestMessageCount = 0;
        self.oldMessageCount = 0;
        self.kVSMSKey = nil;
        self.carrierCountryCode = 0;
        self.vSMSNodeId = 0;
        self.networkId = 0;
        self.isVoiceMailEnabled = NO;
        self.isHLREnabled = NO;
        self.isVoipEnabled = NO;
#ifdef REACHME_APP
        self.reachMeIntl = NO;
        self.reachMeHome = NO;
        self.reachMeVM = NO;
        self.actiUNCF = nil;
        self.deactiUNCF = nil;
        self.actiAll = nil;
        self.deActiAll = nil;
        self.deActiBoth = nil;
        self.actiCnf = nil;
        self.deActiCnf = nil;
        self.voipOBD = NO;
#endif
    }
    
    return self;
}

#pragma mark - Memory CleanUp Methods -
- (void) cleanUp {
    self.phoneNumber = nil;
    self.status = nil;
    self.availableVocieMailCount = 0;
    self.missedCallCount = 0;
    self.realMissedCallCount = 0;
    self.realVocieMailCount = 0;
    self.lastMissedCallTimeStamp = 0;
    self.lastVoiceMailCountTimeStamp = 0;
    self.latestMessageCount = 0;
    self.oldMessageCount = 0;
    self.kVSMSKey = nil;
    self.carrierCountryCode = 0;
    self.vSMSNodeId = 0;
    self.networkId = 0;
    self.isVoiceMailEnabled = NO;
    self.isHLREnabled = NO;
    self.countryVoicemailSupport = NO;
    self.isVoipEnabled = NO;
#ifdef REACHME_APP
    self.reachMeIntl = NO;
    self.reachMeHome = NO;
    self.reachMeVM = NO;
    self.actiUNCF = nil;
    self.deactiUNCF = nil;
    self.actiAll = nil;
    self.deActiAll = nil;
    self.deActiBoth = nil;
    self.actiCnf = nil;
    self.deActiCnf = nil;
    self.voipOBD = NO;
#endif
}

- (void)dealloc {
    
  //  NSLog(@"Voicemail info dealloc");
    [self cleanUp];
    
    
}

/**
 * Designated initilizer method responsible for the creation of the voicemailinfo object.
 * @param withVoiceMailInfo : Instance indicates the voicemail information.
 * @return returns the instance of voicemail info.
 */
- (VoiceMailInfo *)initWithVoiceMailInfo:(NSDictionary *)withVoiceMailInfo {
    self = [super init];
    if (self) {
        
        self.phoneNumber = withVoiceMailInfo[@"phone"];
        //self.phoneNumber = [@"+" stringByAppendingString:self.phoneNumber];
        self.status = withVoiceMailInfo[@"status"];
        self.availableVocieMailCount = [withVoiceMailInfo[@"avs_cnt"]integerValue];
        self.missedCallCount = [withVoiceMailInfo[@"mca_cnt"]integerValue];
        self.realVocieMailCount = [withVoiceMailInfo[@"real_avs_cnt"]integerValue];
        self.realMissedCallCount = [withVoiceMailInfo[@"real_mca_cnt"]integerValue];
        self.lastMissedCallTimeStamp = [withVoiceMailInfo[@"mca_timestamp"]integerValue];
        self.lastVoiceMailCountTimeStamp = [withVoiceMailInfo[@"avs_timestamp"]integerValue];
        self.latestMessageCount = [withVoiceMailInfo[@"new_msg_cnt"]integerValue];;
        self.oldMessageCount = [withVoiceMailInfo[@"old_msg_cnt"]integerValue];
        NSNumber *voiceMailEnabled =  withVoiceMailInfo[@"enabled"];
        if(voiceMailEnabled != nil)
            self.isVoiceMailEnabled = [voiceMailEnabled boolValue];
        else
            self.isVoiceMailEnabled = NO;
        
        //Start Bhaskar HLR Flag & Voip flag
        if (withVoiceMailInfo[@"ussd_string"]) {
            NSString *str=withVoiceMailInfo[@"ussd_string"];
            NSError *err = nil;
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
            
            self.isHLREnabled = [[arr valueForKey:@"is_hlr_callfwd_enabled"] boolValue];
            
            if ([arr valueForKey:@"voip_enabled"]) {
                self.isVoipEnabled = [[arr valueForKey:@"voip_enabled"] boolValue];
            }else{
                self.isVoipEnabled = NO;
            }
            
#ifdef REACHME_APP
            if( [arr valueForKey:@"voip_obd"]) {
                self.voipOBD = [[arr valueForKey:@"voip_obd"]boolValue];
            } else {
                self.voipOBD = NO;
            }
            
            if ([arr valueForKey:@"rm_intl"]) {
                self.reachMeIntl = [[arr valueForKey:@"rm_intl"] boolValue];
            }else{
                self.reachMeIntl = NO;
            }
            
            if ([arr valueForKey:@"rm_home"]) {
                self.reachMeHome = [[arr valueForKey:@"rm_home"] boolValue];
            }else{
                self.reachMeHome = NO;
            }
            
            if ([arr valueForKey:@"rm_vm"]) {
                self.reachMeVM = [[arr valueForKey:@"rm_vm"] boolValue];
            }else{
                self.reachMeVM = NO;
            }
            
            //Dial Codes
            if ([arr valueForKey:@"acti_uncf"]) {
                self.actiUNCF = [arr valueForKey:@"acti_uncf"];
            }else{
                self.actiUNCF = nil;
            }
            
            if ([arr valueForKey:@"deacti_uncf"]) {
                self.deactiUNCF = [arr valueForKey:@"deacti_uncf"];
            }else{
                self.deactiUNCF = nil;
            }
            
            if ([arr valueForKey:@"acti_all"]) {
                self.actiAll = [arr valueForKey:@"acti_all"];
            }else{
                self.actiAll = nil;
            }
            
            if ([arr valueForKey:@"deacti_all"]) {
                self.deActiAll = [arr valueForKey:@"deacti_all"];
            }else{
                self.deActiAll = nil;
            }
            
            if ([arr valueForKey:@"deacti_both"]) {
                self.deActiBoth = [arr valueForKey:@"deacti_both"];
            }else{
                self.deActiBoth = nil;
            
            }
            
            if ([arr valueForKey:@"acti_cnf"]) {
                self.actiCnf = [arr valueForKey:@"acti_cnf"];
            }else{
                self.actiCnf = nil;
            }
            
            if ([arr valueForKey:@"deacti_cnf"]) {
                self.deActiCnf = [arr valueForKey:@"deacti_cnf"];
            }else{
                self.deActiCnf = nil;
            }
#endif
            
        }
        //End Bhaskar
        
        //NOV 16, 2016
        NSNumber *voiceMailSupport = withVoiceMailInfo[@"country_voicemail_support"];
        if(nil!=voiceMailSupport)
            self.countryVoicemailSupport = [voiceMailSupport boolValue];
        //

        self.kVSMSKey = withVoiceMailInfo[@"kvsms_key"];
        self.carrierCountryCode = withVoiceMailInfo[@"carrier_country_code"];;
        self.vSMSNodeId = withVoiceMailInfo[@"vsms_node_id"];;
        self.networkId = withVoiceMailInfo[@"network_id"];
    
        NSString *carrierInfoJSONString = withVoiceMailInfo[@"carrier_info"];
        
        if (carrierInfoJSONString) {
            NSData *carrierInfo = [carrierInfoJSONString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *carrierInfoDetails = [NSJSONSerialization JSONObjectWithData:carrierInfo options:0 error:&error];
            if (carrierInfoDetails && [carrierInfoDetails allKeys]) {
                self.carrierLogoPath = carrierInfoDetails[@"logo"];
                self.carrierLogoSupportUrl = carrierInfoDetails[@"logo_support_url"];
                self.carrierLogoHomeUrl = carrierInfoDetails[@"logo_home_url"];
                self.voipIPAddress = carrierInfoDetails[@"voip_ip"];//NOV 2017
                self.carrierThemeColor = carrierInfoDetails[@"logo_theme_color"];
                id inAppPromo = carrierInfoDetails[@"in_app_promo"];
                if (inAppPromo && [inAppPromo isKindOfClass:[NSArray class]]) {
                    
                    NSDictionary *details = inAppPromo[0];
                    NSNumber *showImage =  details[@"show_image"];

                    if(showImage != nil)
                        self.showInAppImage = [showImage boolValue];
                    else
                        self.showInAppImage = NO;
                    
                    self.inAppPromoImageURL = details[@"image_url"];
                }
                else {
                    self.showInAppImage = nil;
                    self.inAppPromoImageURL = nil;

                }
                
            }
            else {
                self.carrierLogoPath = nil;
                self.carrierLogoSupportUrl = nil;
                self.carrierLogoHomeUrl = nil;
                self.voipIPAddress = nil;//NOV 2017
                self.carrierThemeColor = nil;
                self.showInAppImage = nil;
                self.inAppPromoImageURL = nil;
            }
        }
        else {
            self.carrierLogoPath = nil;
            self.carrierLogoSupportUrl = nil;
            self.carrierLogoHomeUrl = nil;
            self.voipIPAddress = nil;//NOV 2017
            self.carrierThemeColor = nil;
            self.showInAppImage = nil;
            self.inAppPromoImageURL = nil;
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    if (self) {
        self.phoneNumber = [aDecoder decodeObjectForKey:@"PHONENUMBER"];
        self.status = [aDecoder decodeObjectForKey:@"STATUS"];
        self.availableVocieMailCount = [aDecoder decodeIntForKey:@"AVAILABLE_VOICEMAIL_COUNT"];
        self.missedCallCount = [aDecoder decodeIntegerForKey:@"MISSEDCALL_COUNT"];
        self.realVocieMailCount = [aDecoder decodeIntForKey:@"REAL_VOICEMAIL_COUNT"];
        self.realMissedCallCount = [aDecoder decodeIntegerForKey:@"REAL_MISSEDCALL_COUNT"];
        self.lastMissedCallTimeStamp = [aDecoder decodeIntegerForKey:@"LAST_MISSEDCALL_TIMESTAMP"];
        self.lastVoiceMailCountTimeStamp = [aDecoder decodeIntegerForKey:@"LAST_VOICEMAIL_TIMESTAMP"];
        self.latestMessageCount = [aDecoder decodeIntegerForKey:@"LATEST_MESSAGE_COUNT"];
        self.oldMessageCount = [aDecoder decodeIntegerForKey:@"OLD_MESSAGE_COUNT"];
        self.kVSMSKey = [aDecoder decodeObjectForKey:@"KVSMSKEY"];
        self.carrierCountryCode = [aDecoder decodeObjectForKey:@"CARRIER_COUNTRY_CODE"];
        self.vSMSNodeId = [aDecoder decodeObjectForKey:@"VSMS_NODE_ID"];
        self.networkId = [aDecoder decodeObjectForKey:@"NETWORKID"];
        self.isVoiceMailEnabled = [aDecoder decodeBoolForKey:@"VOICEMAILENABLED"];
        self.isHLREnabled = [aDecoder decodeBoolForKey:@"HLRENABLED"];
        self.isVoipEnabled = [aDecoder decodeBoolForKey:@"VOIPENABLED"];
        self.countryVoicemailSupport = [aDecoder decodeBoolForKey:@"CountryVoicemailSupport"];
        self.carrierLogoPath = [aDecoder decodeObjectForKey:@"CarrierLogoPath"];
        self.carrierLogoSupportUrl = [aDecoder decodeObjectForKey:@"CarrierLogoSupportUrl"];
        self.carrierLogoHomeUrl = [aDecoder decodeObjectForKey:@"CarrierLogoHomeUrl"];
        self.voipIPAddress = [aDecoder decodeObjectForKey:@"VoipIPAddress"];//NOV 2017
        self.carrierThemeColor = [aDecoder decodeObjectForKey:@"CarrierThemeColor"];
        self.inAppPromoImageURL = [aDecoder decodeObjectForKey:@"InAppPromoImageURL"];
        self.showInAppImage = [aDecoder decodeBoolForKey:@"ShowInAppImage"];
#ifdef REACHME_APP
        self.reachMeIntl = [aDecoder decodeBoolForKey:@"REACHMEINTL"];
        self.reachMeHome = [aDecoder decodeBoolForKey:@"REACHMEHOME"];
        self.reachMeVM = [aDecoder decodeBoolForKey:@"REACHMEVM"];
        self.actiUNCF = [aDecoder decodeObjectForKey:@"ACTIUNCF"];
        self.deactiUNCF = [aDecoder decodeObjectForKey:@"DEACTIUNCF"];
        self.actiAll = [aDecoder decodeObjectForKey:@"ACTIALL"];
        self.deActiAll = [aDecoder decodeObjectForKey:@"DEACTIALL"];
        self.deActiBoth = [aDecoder decodeObjectForKey:@"DEACTIBOTH"];
        self.actiCnf = [aDecoder decodeObjectForKey:@"ACTICNF"];
        self.deActiCnf = [aDecoder decodeObjectForKey:@"DEACTICNF"];
        self.voipOBD = [aDecoder decodeBoolForKey:@"VOIP_OBD"];
#endif
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.phoneNumber forKey:@"PHONENUMBER"];
    [aCoder encodeObject:self.status forKey:@"STATUS"];
    [aCoder encodeInteger:self.availableVocieMailCount forKey:@"AVAILABLE_VOICEMAIL_COUNT"];
    [aCoder encodeInteger:self.realMissedCallCount forKey:@"REAL_MISSEDCALL_COUNT"];
    [aCoder encodeInteger:self.realVocieMailCount forKey:@"REAL_VOICEMAIL_COUNT"];
    [aCoder encodeInteger:self.missedCallCount forKey:@"MISSEDCALL_COUNT"];
    
    [aCoder encodeInteger:self.lastMissedCallTimeStamp forKey:@"LAST_MISSEDCALL_TIMESTAMP"];
    [aCoder encodeInteger:self.lastVoiceMailCountTimeStamp forKey:@"LAST_VOICEMAIL_TIMESTAMP"];
    [aCoder encodeInteger:self.latestMessageCount forKey:@"LATEST_MESSAGE_COUNT"];
    [aCoder encodeInteger:self.oldMessageCount forKey:@"OLD_MESSAGE_COUNT"];
    [aCoder encodeObject:self.kVSMSKey forKey:@"KVSMSKEY"];
    [aCoder encodeObject:self.carrierCountryCode forKey:@"CARRIER_COUNTRY_CODE"];
    [aCoder encodeObject:self.vSMSNodeId forKey:@"VSMS_NODE_ID"];
    [aCoder encodeObject:self.networkId forKey:@"NETWORKID"];
    [aCoder encodeBool:self.isVoiceMailEnabled forKey:@"VOICEMAILENABLED"];
    [aCoder encodeBool:self.isHLREnabled forKey:@"HLRENABLED"];
    [aCoder encodeBool:self.countryVoicemailSupport forKey:@"CountryVoicemailSupport"];
    [aCoder encodeBool:self.isVoipEnabled forKey:@"VOIPENABLED"];
    [aCoder encodeObject:self.carrierLogoPath forKey:@"CarrierLogoPath"];
    [aCoder encodeObject:self.carrierLogoSupportUrl forKey:@"CarrierLogoSupportUrl"];
    [aCoder encodeObject:self.carrierLogoHomeUrl forKey:@"CarrierLogoHomeUrl"];
    [aCoder encodeObject:self.voipIPAddress forKey:@"VoipIPAddress"];//NOV 2017
    [aCoder encodeObject:self.carrierThemeColor forKey:@"CarrierThemeColor"];
    [aCoder encodeObject:self.inAppPromoImageURL forKey:@"InAppPromoImageURL"];
    [aCoder encodeBool:self.showInAppImage forKey:@"ShowInAppImage"];
    
#ifdef REACHME_APP
    [aCoder encodeBool:self.reachMeIntl forKey:@"REACHMEINTL"];
    [aCoder encodeBool:self.reachMeHome forKey:@"REACHMEHOME"];
    [aCoder encodeBool:self.reachMeVM forKey:@"REACHMEVM"];
    [aCoder encodeObject:self.actiUNCF forKey:@"ACTIUNCF"];
    [aCoder encodeObject:self.deactiUNCF forKey:@"DEACTIUNCF"];
    [aCoder encodeObject:self.actiAll forKey:@"ACTIALL"];
    [aCoder encodeObject:self.deActiAll forKey:@"DEACTIALL"];
    [aCoder encodeObject:self.deActiBoth forKey:@"DEACTIBOTH"];
    [aCoder encodeObject:self.actiCnf forKey:@"ACTICNF"];
    [aCoder encodeObject:self.deActiCnf forKey:@"DEACTICNF"];
    [aCoder encodeBool:self.voipOBD forKey:@"VOIP_OBD"];
#endif
}



@end

@implementation CarrierInfo

- (id)init {
    
    self = [super init];
    if(self) {
        self.phoneNumber = nil;
        self.countryCode = nil;
        self.networkId = 0;
        self.shouldUpdateToServer = NO;
        self.isVoipEnabled = NO;
        self.isVoipStatusEnabled = NO;
#ifdef REACHME_APP
        self.isReachMeIntlActive = NO;
        self.isReachMeHomeActive = NO;
        self.isReachMeVMActive = NO;
#endif
        
    }
    
    return self;
}

/**
 * Designated initilizer method responsible for the creation of the carrierinfo object.
 * @param withPhoneNumber : Instance indicates the phone number
 * @param withCarrierInfo : Instance indicates the carrier information.
 * @return returns the instance of carrier info.
 */
- (CarrierInfo *)initWithPhoneNumber:(NSString *)withPhoneNumber withCarrierDetails:(id)withCarrierInfo {
    self = [super init];
    if (self) {
        
        NSRange range = [withPhoneNumber rangeOfString:@"+"];
        if(range.location != NSNotFound){
            self.shouldUpdateToServer = YES;
            withPhoneNumber = [withPhoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
        }
        self.phoneNumber = withPhoneNumber;
        
        if(withCarrierInfo) {
            //Start: Nivedita: Observed the json format changes in some of the accounts - to avoid the crash, checking is it type of string. Date:31st Dec.
            if([withCarrierInfo isKindOfClass:[NSString class]]) {
                NSError *error;
                NSData *jsonData = [withCarrierInfo dataUsingEncoding:NSUTF8StringEncoding];
                withCarrierInfo = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&error];
            }
            //End
            
            //- June, 2017
            NSString* sCountryCode = withCarrierInfo[@"country_cd"];
            if(!sCountryCode.length)
                sCountryCode = withCarrierInfo[@"country_code"];
            
            if(!sCountryCode.length)
                sCountryCode = @"000";
            
            self.countryCode = sCountryCode;
            //
            
            /* June, 2017
            self.countryCode = withCarrierInfo[@"country_cd"]?withCarrierInfo[@"country_cd"]:(withCarrierInfo[@"country_code"]?withCarrierInfo[@"country_code"]:@"000");
            */
            self.networkId = withCarrierInfo[@"network_id"];
            if([self.networkId length] == 1) {
                self.shouldUpdateToServer = YES;
                self.networkId = [NSString stringWithFormat:@"0%@", self.networkId];
            }
            self.vSMSId = withCarrierInfo[@"vsms_id"];
        }
#ifdef REACHME_APP
        if (withCarrierInfo[@"rm_intl_acti"]) {
            self.isReachMeIntlActive = [withCarrierInfo[@"rm_intl_acti"] boolValue];
        }else{
            self.isReachMeIntlActive = NO;
        }
        
        if (withCarrierInfo[@"rm_home_acti"]) {
            self.isReachMeHomeActive = [withCarrierInfo[@"rm_home_acti"] boolValue];
        }else{
            self.isReachMeHomeActive = NO;
        }
        
        if (withCarrierInfo[@"vm_acti"]) {
            self.isReachMeVMActive = [withCarrierInfo[@"vm_acti"] boolValue];
        }else{
            self.isReachMeVMActive = NO;
        }
        
//        if (![[ConfigurationReader sharedConfgReaderObj] getMissedCallReasonForNumber:self.phoneNumber]) {
//            NSMutableDictionary* mcReasonDic = [[NSMutableDictionary alloc]init];
//            if(!self.isReachMeIntlActive && !self.isReachMeHomeActive){
//                [mcReasonDic setValue:@"" forKey:self.phoneNumber];
//                [[ConfigurationReader sharedConfgReaderObj]setObject:mcReasonDic forTheKey:MISSED_CALL_REASON];
//            }else if(self.isReachMeIntlActive){
//                [mcReasonDic setValue:@"unconditional" forKey:self.phoneNumber];
//                [[ConfigurationReader sharedConfgReaderObj]setObject:mcReasonDic forTheKey:MISSED_CALL_REASON];
//            }else if(self.isReachMeHomeActive){
//                [mcReasonDic setValue:@"busy" forKey:self.phoneNumber];
//                [[ConfigurationReader sharedConfgReaderObj]setObject:mcReasonDic forTheKey:MISSED_CALL_REASON];
//            }
//        }
        
        
#else
        VoiceMailInfo *voiceMailInfoForPhoneNumber = [[Setting sharedSetting] voiceMailInfoForPhoneNumber:withPhoneNumber];
        
        //Start Bhaskar Reach Me Settings
        //Reach Me status
        self.isVoipEnabled = [withCarrierInfo[@"vp_enbld"] boolValue];
        
        //Toggle status
        if (withCarrierInfo[@"voip_status"]) {
            self.isVoipStatusEnabled = [withCarrierInfo[@"voip_status"] boolValue];
        }else{
            if(voiceMailInfoForPhoneNumber.isVoipEnabled && voiceMailInfoForPhoneNumber.isVoiceMailEnabled)
                self.isVoipStatusEnabled = YES;
            else
                self.isVoipStatusEnabled = NO;
        }
        //End
#endif
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.phoneNumber = [aDecoder decodeObjectForKey:@"CarrierInfoPhoneNumber"];
        self.countryCode = [aDecoder decodeObjectForKey:@"CarrierInfoCountryCode"];
        self.networkId = [aDecoder decodeObjectForKey:@"CarrierInfoNetworkId"];
        self.vSMSId = [aDecoder decodeObjectForKey:@"CarrierInfoVSMSID"];
        self.shouldUpdateToServer = [aDecoder decodeBoolForKey:@"CarrierInfoShouldUpdateToServer"];
        self.isVoipEnabled = [aDecoder decodeBoolForKey:@"CarrierInfoIsVoipEnabled"];
        self.isVoipStatusEnabled = [aDecoder decodeBoolForKey:@"CarrierInfoIsVoipStatusEnabled"];
#ifdef REACHME_APP
        self.isReachMeIntlActive = [aDecoder decodeBoolForKey:@"CarrierInfoIsIntlActive"];
        self.isReachMeHomeActive = [aDecoder decodeBoolForKey:@"CarrierInfoIsHomeActive"];
        self.isReachMeVMActive = [aDecoder decodeBoolForKey:@"CarrierInfoIsVmActive"];
#endif
    }
    return self;
    
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.phoneNumber forKey:@"CarrierInfoPhoneNumber"];
    [aCoder encodeObject:self.countryCode forKey:@"CarrierInfoCountryCode"];
    [aCoder encodeObject:self.networkId forKey:@"CarrierInfoNetworkId"];
    [aCoder encodeObject:self.vSMSId forKey:@"CarrierInfoVSMSID"];
    [aCoder encodeBool:self.shouldUpdateToServer forKey:@"CarrierInfoShouldUpdateToServer"];
    [aCoder encodeBool:self.isVoipEnabled forKey:@"CarrierInfoIsVoipEnabled"];
    [aCoder encodeBool:self.isVoipStatusEnabled forKey:@"CarrierInfoIsVoipStatusEnabled"];
#ifdef REACHME_APP
    [aCoder encodeBool:self.isReachMeIntlActive forKey:@"CarrierInfoIsIntlActive"];
    [aCoder encodeBool:self.isReachMeHomeActive forKey:@"CarrierInfoIsHomeActive"];
    [aCoder encodeBool:self.isReachMeVMActive forKey:@"CarrierInfoIsVmActive"];
#endif
}


#pragma mark - Memory CleanUp Methods -
- (void) cleanUp {
    self.phoneNumber = nil;
    self.countryCode = nil;
    self.networkId = 0;
    self.shouldUpdateToServer = NO;
    self.isVoipEnabled = NO;
    self.isVoipStatusEnabled = NO;
#ifdef REACHME_APP
    self.isReachMeIntlActive = NO;
    self.isReachMeHomeActive = NO;
    self.isReachMeVMActive = NO;
#endif
}

- (void)dealloc {
  //  NSLog(@"Carrier info dealloc");
    [self cleanUp];
}

@end

@implementation NumberInfo

- (id)init {
    
    self = [super init];
    if(self) {
        self.imgName = nil;
        self.titleName = nil;
        self.phoneNumber = nil;
        self.shouldUpdateToServer = NO;
        
    }
    
    return self;
}

- (NumberInfo *)initWithPhoneNumber:(NSString *)withPhoneNumber withNumberDetails:(id)withNumberInfo {
    self = [super init];
    if (self) {
        
        NSRange range = [withPhoneNumber rangeOfString:@"+"];
        if(range.location != NSNotFound){
            self.shouldUpdateToServer = YES;
            withPhoneNumber = [withPhoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
        }
        self.phoneNumber = withPhoneNumber;
        
        if(withNumberInfo) {
            if([withNumberInfo isKindOfClass:[NSString class]]) {
                NSError *error;
                NSData *jsonData = [withNumberInfo dataUsingEncoding:NSUTF8StringEncoding];
                withNumberInfo = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&error];
            }
            
            
            //-Number Specific Name & Image, July 2017
            NSString* imageName = withNumberInfo[@"img_nm"];
            
            if(!imageName.length)
                imageName = @"";
            
            self.imgName = imageName;
            
            NSString* titleName = withNumberInfo[@"title_nm"];
            
            if(!titleName.length)
                titleName = @"";
            
            self.titleName = titleName;
            //
            
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.imgName = [aDecoder decodeObjectForKey:@"CarrierInfoImageName"];
        self.titleName = [aDecoder decodeObjectForKey:@"CarrierInfoTitleName"];
        self.phoneNumber = [aDecoder decodeObjectForKey:@"CarrierInfoPhoneNumber"];
        self.shouldUpdateToServer = [aDecoder decodeBoolForKey:@"CarrierInfoShouldUpdateToServer"];
    }
    return self;
    
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.imgName forKey:@"CarrierInfoImageName"];
    [aCoder encodeObject:self.titleName forKey:@"CarrierInfoTitleName"];
    [aCoder encodeObject:self.phoneNumber forKey:@"CarrierInfoPhoneNumber"];
    [aCoder encodeBool:self.shouldUpdateToServer forKey:@"CarrierInfoShouldUpdateToServer"];
}


#pragma mark - Memory CleanUp Methods -
- (void) cleanUp {
    self.imgName = nil;
    self.titleName = nil;
    self.phoneNumber = nil;
    self.shouldUpdateToServer = NO;
}

- (void)dealloc {
    //  NSLog(@"Carrier info dealloc");
    [self cleanUp];
}

@end

@implementation SettingModel

-(id)init
{
    if(self = [super init])
    {
        _displayLocation = TRUE; // FALSE; //Based on the converstaion with the Andriod Team and Ajay changing the default value to "TRUE" - Fresh SignUp
        _fbConnected = FALSE;
        _twConnected = FALSE;
        _vbEnabled = TRUE; // FALSE; //Based on the converstaion with the Andriod Team and Ajay changing the default value to "TRUE" - Fresh SignUp
        _fbPostEnabled = FALSE;
        _twPostEnabled = FALSE;
        _userManualTrans = FALSE;
        _countryManualTrans = FALSE;
        
        _syncFlag = 0;
        _maxRecordTime = 120;
        _ivUserId = @"";
        _mqttSetting = [[SettingModelMqtt alloc]init];
        
        //Added  by Nivedita - Dec 16th : TODO: Reverify the initial values.
        self.defaultRecordMode = @"Release to send";
        self.defaultVoiceMode = @"Speaker";
        self.storageLocation = @"Device Cache";
        self.showTwitterFriend = TRUE;
        self.showFBFriend = TRUE;
        self.carrierDetails = nil;
        self.numberDetails = nil;
        self.listOfCarriers = nil;
        //by Vinoth
        self.loginMatchesInstaVoiceNumber = NO;
        self.shouldUpdateToServer = NO;
        //        self.enableMissedCallNumber = @"004*77007777#";
        //        self.checkStatusDialNumber = @"*#62#";
        //        self.checkStatusForwardNumber = @"7700770077";
        //        self.checkStatusAlternateDialNumber = @"*#61# or *67#";
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [self init]) {
        
        /*
         kDefaultRecordMode      @"default_record_mode"
         kDefaultVoiceMode       @"default_voice_mode"
         kShareLocation          @"share_location"
         kCarrierInfo            @"carrier" //Key responsi
         ork_name etc. Please refer the JSON response for
         kShowFBFriend         @"show_fb_frnd"
         kShowTwitterFriend    @"show_tw_frnd"
         */
        _displayLocation = [aDecoder decodeBoolForKey:@"DISPLAY_LOCATION"];
        _fbConnected = [aDecoder decodeBoolForKey:@"FB_CONNECTED"];
        _twConnected = [aDecoder decodeBoolForKey:@"TW_CONNECTED"];
        _vbEnabled = [aDecoder decodeBoolForKey:@"VB_ENABLE"];
        _fbPostEnabled = [aDecoder decodeBoolForKey:@"FB_POST_ENABLED"];
        _twPostEnabled = [aDecoder decodeBoolForKey:@"TW_POST_ENABLED"];
        _userManualTrans = [aDecoder decodeBoolForKey:@"USER_MANUAL_TRANS_ENABLED"];
        _countryManualTrans = [aDecoder decodeBoolForKey:@"COUNTRY_MANUAL_TRANS_ENABLED"];
        _syncFlag = [aDecoder decodeIntegerForKey:@"SYNCFLAG"];
        _maxRecordTime = [aDecoder decodeIntegerForKey:@"MAX_RECORD_TIME"];
        _ivUserId = [aDecoder decodeObjectForKey:@"IV_USER_ID"];
        _mqttSetting = [aDecoder decodeObjectForKey:@"MQTT_SETTING"];
        
        
        //by Vinoth
        self.ivUSSDDictPhone = [aDecoder decodeObjectForKey:@"IV_USSD_DICT_PHONE"];
        self.ivUSSDDictSim = [aDecoder decodeObjectForKey:@"IV_USSD_DICT_SIM"];
        
        //Added by Nivedita: Date 17th Dec, to support Fetch Settings API changes. //Commented to maintain the same information as we recieved from the server
        
        self.defaultRecordMode = [aDecoder decodeObjectForKey:@"kDefaultRecordMode"];
        self.defaultVoiceMode = [aDecoder decodeObjectForKey:@"kDefaultVoiceMode"];
        self.showFBFriend = [aDecoder decodeBoolForKey:@"kShowFBFriend"];
        self.showTwitterFriend = [aDecoder decodeBoolForKey:@"kShowTwitterFriend"];
        self.storageLocation = [aDecoder decodeObjectForKey:@"kStorageLocation"];
        self.carrierDetails = [aDecoder decodeObjectForKey:@"kCarrierInfo"];
        self.voiceMailInfo = [aDecoder decodeObjectForKey:@"VoiceMailInfo"];
        
        //CarrierInfoList.
        self.carrierInfoList = [aDecoder decodeObjectForKey:@"kCarrierInfoList"];
        self.shouldUpdateToServer = [aDecoder decodeBoolForKey:@"kShouldUpdateToServer"];
        self.listOfCarriers = [aDecoder decodeObjectForKey:@"LIST_CARRIERS"];
        
        self.numberInfoList = [aDecoder decodeObjectForKey:@"kNumberInfoList"];
        self.numberDetails = [aDecoder decodeObjectForKey:@"kNumberInfo"];
        
    }
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:_displayLocation forKey:@"DISPLAY_LOCATION"];
    [aCoder encodeBool:_fbConnected forKey:@"FB_CONNECTED"];
    [aCoder encodeBool:_twConnected forKey:@"TW_CONNECTED"];
    [aCoder encodeBool:_vbEnabled forKey:@"VB_ENABLE"];
    [aCoder encodeBool:_fbPostEnabled forKey:@"FB_POST_ENABLED"];
    [aCoder encodeBool:_twPostEnabled forKey:@"TW_POST_ENABLED"];
    [aCoder encodeBool:_userManualTrans forKey:@"USER_MANUAL_TRANS_ENABLED"];
    [aCoder encodeBool:_countryManualTrans forKey:@"COUNTRY_MANUAL_TRANS_ENABLED"];
    [aCoder encodeInteger:_syncFlag forKey:@"SYNCFLAG"];
    [aCoder encodeInteger:_maxRecordTime forKey:@"MAX_RECORD_TIME"];
    [aCoder encodeObject:_ivUserId forKey:@"IV_USER_ID"];
    [aCoder encodeObject:_mqttSetting forKey:@"MQTT_SETTING"];
    
    //by Vinoth
    [aCoder encodeObject:self.ivUSSDDictPhone forKey:@"IV_USSD_DICT_PHONE"];
    [aCoder encodeObject:self.ivUSSDDictSim forKey:@"IV_USSD_DICT_SIM"];
    
    //Added by Nivedita: Date 17th Dec, to support Fetch Settings API changes.
    
    [aCoder encodeObject:self.defaultRecordMode forKey:@"kDefaultRecordMode"];
    [aCoder encodeObject:self.defaultVoiceMode forKey:@"kDefaultVoiceMode"];
    [aCoder encodeBool:self.showFBFriend forKey:@"kShowFBFriend"];
    [aCoder encodeBool:self.showTwitterFriend forKey:@"kShowTwitterFriend"];
    [aCoder encodeObject:self.storageLocation forKey:@"kStorageLocation"];
    [aCoder encodeObject:self.carrierDetails forKey:@"kCarrierInfo"];
    [aCoder encodeObject:self.carrierInfoList forKey:@"kCarrierInfoList"];
    [aCoder encodeObject:self.voiceMailInfo forKey:@"VoiceMailInfo"];
    [aCoder encodeBool:self.shouldUpdateToServer forKey:@"kShouldUpdateToServer"];
    [aCoder encodeObject:self.listOfCarriers forKey:@"LIST_CARRIERS"];
    [aCoder encodeObject:self.numberDetails forKey:@"kNumberInfo"];
    [aCoder encodeObject:self.numberInfoList forKey:@"kNumberInfoList"];
    
}

- (void)updateCallNumbersFromUSSDSim
{
    //KLog(@"%s -- dic=%@",self.ivUSSDDictSim);
    EnLogd(@" -- dic=%@",self.ivUSSDDictSim);
    self.networkDefault = [self.ivUSSDDictSim objectForKey:@"network"];
    self.enableMissedCallNumber = [self.ivUSSDDictSim objectForKey:@"acti_all"];
    self.checkStatusDialNumber = [self.ivUSSDDictSim objectForKey:@"chk_all"];
    self.checkStatusAlternateDialNumber = [self.ivUSSDDictSim objectForKey:@"chk_busy"];
    self.checkStatusForwardNumber = [self.ivUSSDDictSim objectForKey:@"chk_noreply"];
    self.disableMissedCallNumber = [self.ivUSSDDictSim objectForKey:@"deacti_all"];
}

- (void)updateCallNumbersFromUSSDPhone
{
    //KLog(@"%s -- dic=%@",self.ivUSSDDictPhone);
    EnLogd(@" -- dic=%@",self.ivUSSDDictPhone);
    self.networkDefault = [self.ivUSSDDictPhone objectForKey:@"network"];
    
    self.enableMissedCallNumber = [self.ivUSSDDictPhone objectForKey:@"acti_all"];
    self.checkStatusDialNumber = [self.ivUSSDDictPhone objectForKey:@"chk_all"];
    self.checkStatusAlternateDialNumber = [self.ivUSSDDictPhone objectForKey:@"chk_busy"];
    self.checkStatusForwardNumber = [self.ivUSSDDictPhone objectForKey:@"chk_noreply"];
    self.disableMissedCallNumber = [self.ivUSSDDictPhone objectForKey:@"deacti_all"];
    
}

- (void)updateOnlyNetworkFromUSSDSim:(NSString*)networkName
{
    self.networkDefault = networkName;
    self.loginMatchesInstaVoiceNumber = YES;
}

- (void)updateOnlyNetworkFromUSSDPhone:(NSString*)networkName
{
    self.networkDefault = networkName;
    self.loginMatchesInstaVoiceNumber = NO;
}

- (void)dealloc
{
   // NSLog(@"Settings Model dealloc");
}
@end
