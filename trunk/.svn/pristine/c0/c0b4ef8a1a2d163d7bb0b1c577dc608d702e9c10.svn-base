//
//  IVSettingsCountryCarrierInfo.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 23/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVSettingsCountryCarrierInfo.h"

@implementation IVSettingsUSSDInfo

- (id)init {
    
    self = [super init];
    if(self) {
        self.networkName = nil;
        self.chkPhone = nil;
        self.chkAll = nil;
        self.chkBusy = nil;
        self.chkNoReplay = nil;
        self.chkOff = nil;
        self.actiAll = nil;
        self.actiBusy = nil;
        self.actiNoReply = nil;
        self.actiOff = nil;
        self.deactiAll = nil;
        self.deactiBusy = nil;
        self.deactiNoReplay = nil;
        self.deactioff = nil;
        self.skip = nil;
        self.isHLREnabled = nil;
    }
    
    return self;
}

#pragma mark - Memory CleanUp Methods -
- (void) cleanUp {
    self.networkName = nil;
    self.chkPhone = nil;
    self.chkAll = nil;
    self.chkBusy = nil;
    self.chkNoReplay = nil;
    self.chkOff = nil;
    self.actiAll = nil;
    self.actiBusy = nil;
    self.actiNoReply = nil;
    self.actiOff = nil;
    self.deactiAll = nil;
    self.deactiBusy = nil;
    self.deactiNoReplay = nil;
    self.deactioff = nil;
    self.skip = nil;
    self.isHLREnabled = nil;
}

- (void)dealloc {
    
    //NSLog(@"IVSettingsUSSDInfo dealloc");
    [self cleanUp];
}

/**
 * Designated initilizer method responsible for the creation of the voicemailinfo object.
 * @param withVoiceMailInfo : Instance indicates the voicemail information.
 * @return returns the instance of voicemail info.
 */
- (IVSettingsUSSDInfo *)initWithUSSDInfo:(NSDictionary *)withUSSDInfo {
    self = [super init];
    if (self) {
        self.networkName = withUSSDInfo[@"network"];
        self.chkPhone = withUSSDInfo[@"chk_ph"];
        self.chkAll = withUSSDInfo[@"chk_all"];
        self.chkBusy = withUSSDInfo[@"chk_busy"];
        self.chkNoReplay = withUSSDInfo[@"chk_noreply"];
        self.chkOff = withUSSDInfo[@"chk_off"];
        self.actiAll = withUSSDInfo[@"acti_all"];
        self.actiBusy = withUSSDInfo[@"acti_busy"];
        self.actiNoReply = withUSSDInfo[@"acti_noreply"];
        self.actiOff = withUSSDInfo[@"acti_off"];
        self.deactiAll = withUSSDInfo[@"deacti_all"];
        self.deactiBusy = withUSSDInfo[@"deacti_busy"];
        self.deactiNoReplay = withUSSDInfo[@"deacti_noreply"];
        self.deactioff = withUSSDInfo[@"deacti_off"];
        self.isHLREnabled = [withUSSDInfo[@"is_hlr_callfwd_enabled"] boolValue];
        if(withUSSDInfo[@"add_acti_info"])
            self.additionalActiInfo = withUSSDInfo[@"add_acti_info"];
        if (withUSSDInfo[@"skip"]) {
            self.skip = withUSSDInfo[@"skip"];
        }
        
        if (withUSSDInfo[@"test"]) {
            self.test = withUSSDInfo[@"test"];
        }
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [self init]) {

        _networkName = [aDecoder decodeObjectForKey:@"NETWORK_NAME"];
        _chkPhone = [aDecoder decodeObjectForKey:@"CHK_PH"];
        _chkAll = [aDecoder decodeObjectForKey:@"CHK_ALL"];
        _chkBusy = [aDecoder decodeObjectForKey:@"CHK_BUSY"];
        _chkNoReplay = [aDecoder decodeObjectForKey:@"CHK_NOREPLY"];
        _chkOff = [aDecoder decodeObjectForKey:@"CHK_OFF"];
        _actiAll = [aDecoder decodeObjectForKey:@"ACTI_ALL"];
        _actiBusy = [aDecoder decodeObjectForKey:@"ACTI_BUSY"];
        _actiNoReply = [aDecoder decodeObjectForKey:@"ACTI_NOREPLY"];
        _actiOff = [aDecoder decodeObjectForKey:@"ACTI_OFF"];
        _deactiAll = [aDecoder decodeObjectForKey:@"DEACTI_ALL"];
        _deactiBusy = [aDecoder decodeObjectForKey:@"DEACTI_BUSY"];
        _deactiNoReplay = [aDecoder decodeObjectForKey:@"DEACTI_NO_REPLY"];
        _deactioff = [aDecoder decodeObjectForKey:@"DEACTI_OFF"];
        _additionalActiInfo = [aDecoder decodeObjectForKey:@"ADD_ACTI_INFO"];
        _skip = [aDecoder decodeObjectForKey:@"SKIP"];
        _test = [aDecoder decodeObjectForKey:@"TEST"];
        _isHLREnabled = [aDecoder decodeBoolForKey:@"IS_HLR_CALLFWD_ENABLED"];
        
        
    }
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_networkName forKey:@"NETWORK_NAME"];
    [aCoder encodeObject:_chkPhone forKey:@"CHK_PH"];
    [aCoder encodeObject:_chkAll forKey:@"CHK_ALL"];
    [aCoder encodeObject:_chkBusy forKey:@"CHK_BUSY"];
    [aCoder encodeObject:_chkNoReplay forKey:@"CHK_NOREPLY"];
    [aCoder encodeObject:_chkOff forKey:@"CHK_OFF"];
    [aCoder encodeObject:_actiAll forKey:@"ACTI_ALL"];
    [aCoder encodeObject:_actiBusy forKey:@"ACTI_BUSY"];
    [aCoder encodeObject:_actiNoReply forKey:@"ACTI_NOREPLY"];
    [aCoder encodeObject:_actiOff forKey:@"ACTI_OFF"];
    [aCoder encodeObject:_deactiAll forKey:@"DEACTI_ALL"];
    [aCoder encodeObject:_deactiNoReplay forKey:@"DEACTI_NO_REPLY"];
    [aCoder encodeObject:_deactioff forKey:@"DEACTI_OFF"];
    [aCoder encodeObject:_additionalActiInfo forKey:@"ADD_ACTI_INFO"];
    [aCoder encodeObject:_skip forKey:@"SKIP"];
    [aCoder encodeObject:_test forKey:@"TEST"];
    [aCoder encodeBool:_isHLREnabled forKey:@"IS_HLR_CALLFWD_ENABLED"];
}

@end


@implementation IVSettingsCountryCarrierInfo

- (id)init {
    
    self = [super init];
    if(self) {
        self.vsmsNodeId = 0;
        self.countryCode = 0;
        self.networkId = 0;
        self.networkName = nil;
        self.mccmncList = 0;
        self.ussdInfo = nil;
        self.carrierName = nil;
        
    }
    
    return self;
}

#pragma mark - Memory CleanUp Methods -
- (void) cleanUp {
    self.vsmsNodeId = 0;
    self.countryCode = nil;
    self.networkId = 0;
    self.networkName = nil;
    self.mccmncList = 0;
    self.ussdInfo = nil;
    self.carrierName = nil;
}

- (void)dealloc {
   // NSLog(@"IVSettingsCountryCarrierInfo dealloc");
    [self cleanUp];
}

/**
 * Designated initilizer method responsible for the creation of the voicemailinfo object.
 * @param withVoiceMailInfo : Instance indicates the voicemail information.
 * @return returns the instance of voicemail info.
 */
- (IVSettingsCountryCarrierInfo *)initWithCountryCarrierInfo:(NSDictionary *)withCarrierInfo {
    self = [super init];
    if (self) {
        self.vsmsNodeId = withCarrierInfo[@"vsms_node_id"];
        self.countryCode = withCarrierInfo[@"country_code"];
        self.networkId = withCarrierInfo[@"network_id"];
        self.networkName = withCarrierInfo[@"network_name"];
        self.displayOrder = withCarrierInfo[@"display_order"];
        self.carrierName = withCarrierInfo[@"carrier_name"];
        
        if (withCarrierInfo[@"mccmnc_list"]) {
            
            NSString *mccmncString = withCarrierInfo[@"mccmnc_list"];
            if (mccmncString && ![mccmncString isEqualToString:@""] && [mccmncString length]) {
                self.mccmncList = [mccmncString componentsSeparatedByString:@","];
            }
            else
                self.mccmncList = nil;
        }
        else
            self.mccmncList = nil;
        
        //NSArray *items = [theString componentsSeparatedByString:@","];

        NSString *ussdJSONString = withCarrierInfo[@"ussd_string"];
        
        if (ussdJSONString) {
            NSData *ussdInfo = [ussdJSONString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *ussdInfoDictionary = [NSJSONSerialization JSONObjectWithData:ussdInfo options:0 error:&error];
            if (ussdInfoDictionary && [ussdInfoDictionary allKeys]) {
                self.ussdInfo = [[IVSettingsUSSDInfo alloc]initWithUSSDInfo:ussdInfoDictionary];
            }
        }
        else
            self.ussdInfo = nil;
        
    }
    
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [self init]) {
        _vsmsNodeId = [aDecoder decodeObjectForKey:@"VSMS_NODE_ID"];
        _countryCode = [aDecoder decodeObjectForKey:@"COUNTRY_CODE"];
        _networkId = [aDecoder decodeObjectForKey:@"NETWORK_ID"];
        _networkName = [aDecoder decodeObjectForKey:@"NETWORK_NAME"];
        _displayOrder = [aDecoder decodeObjectForKey:@"DISPLAY_ORDER"];
        _carrierName = [aDecoder decodeObjectForKey:@"CARRIER_NAME"];
        _mccmncList = [aDecoder decodeObjectForKey:@"MCCMNC_LIST"];
        _ussdInfo = [aDecoder decodeObjectForKey:@"USSD_INFO"];
        
    }
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_vsmsNodeId forKey:@"VSMS_NODE_ID"];
    [aCoder encodeObject:_countryCode forKey:@"COUNTRY_CODE"];
    [aCoder encodeObject:_networkId forKey:@"NETWORK_ID"];
    [aCoder encodeObject:_networkName forKey:@"NETWORK_NAME"];
    [aCoder encodeObject:_displayOrder forKey:@"DISPLAY_ORDER"];
    [aCoder encodeObject:_carrierName forKey:@"CARRIER_NAME"];
    [aCoder encodeObject:_mccmncList forKey:@"MCCMNC_LIST"];
    [aCoder encodeObject:_ussdInfo forKey:@"USSD_INFO"];
}



@end
