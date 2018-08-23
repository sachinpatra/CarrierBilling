//
//  IVCarrierSearchViewController.h
//  InstaVoice
//
//  Created by Nivedita Angadi on 21/06/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "BaseUI.h"
#import "Setting.h"
#import "IVSettingsCountryCarrierInfo.h"
#import "IVCarrierSearchProtocol.h"
@interface IVCarrierSearchViewController : BaseUI
@property (nonatomic, strong) NSArray *carrierList;
@property (nonatomic, strong) VoiceMailInfo *voiceMailInfo;
@property (nonatomic, strong) IVSettingsCountryCarrierInfo *selectedCountryCarrierInfo;
@property (nonatomic, weak) id<IVCarrierSearchDelegate> carrierSearchDelegate;
#ifdef REACHME_APP
@property (nonatomic, assign) BOOL isEdit;
#endif
@end
