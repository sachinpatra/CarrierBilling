//
//  HowToActivateReachMeViewController.h
//  InstaVoice
//
//  Created by Bhaskar Munireddy on 23/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
#import "SettingModel.h"

@interface HowToActivateReachMeViewController : BaseUI
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *reachMeType;
@property (nonatomic, strong) VoiceMailInfo *voiceMailInfo;
@end
