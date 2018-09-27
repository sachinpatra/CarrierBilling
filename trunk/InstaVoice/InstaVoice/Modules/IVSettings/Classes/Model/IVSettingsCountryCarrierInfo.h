//
//  IVSettingsCountryCarrierInfo.h
//  InstaVoice
//
//  Created by Nivedita Angadi on 23/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IVSettingsUSSDInfo : NSObject
@property (nonatomic, strong) NSString *networkName;
@property (nonatomic, strong) NSString *chkPhone;
@property (nonatomic, strong) NSString *chkAll;
@property (nonatomic, strong) NSString *chkBusy;
@property (nonatomic, strong) NSString *chkNoReplay;
@property (nonatomic, strong) NSString *chkOff;
@property (nonatomic, strong) NSString *actiAll;
@property (nonatomic, strong) NSString *actiBusy;
@property (nonatomic, strong) NSString *actiNoReply;
@property (nonatomic, strong) NSString *actiOff;
@property (nonatomic, strong) NSString *deactiAll;
@property (nonatomic, strong) NSString *deactiBusy;
@property (nonatomic, strong) NSString *deactiNoReplay;
@property (nonatomic, strong) NSString *deactioff;
@property (nonatomic, strong) NSString *skip;
@property (nonatomic, strong) NSString *test;
@property (nonatomic, strong) NSString *additionalActiInfo;//OCT 26, 2016
@property (nonatomic, assign) BOOL isHLREnabled; // Aug 2017
- (IVSettingsUSSDInfo *)initWithUSSDInfo:(NSDictionary *)withUSSDInfo;

//Sachin
@property (nonatomic, assign) BOOL isBundleIntl;
@property (nonatomic, assign) BOOL isBundleHome;
@property (nonatomic, assign) BOOL isBundleVM;

@end


@interface IVSettingsCountryCarrierInfo : NSObject

@property (nonatomic, strong) NSNumber *vsmsNodeId;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *networkId;
@property (nonatomic, strong) NSString *networkName;
@property (nonatomic, strong) NSString *carrierName;
@property (nonatomic, strong) NSNumber* displayOrder;//NOV 14
@property (nonatomic, strong) NSArray  *mccmncList;
@property (nonatomic, strong) IVSettingsUSSDInfo *ussdInfo;

- (IVSettingsCountryCarrierInfo *)initWithCountryCarrierInfo:(NSDictionary *)withCarrierInfo;

@end
