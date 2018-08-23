//
//  ReachMeActivationViewController.h
//  InstaVoice
//
//  Created by Bhaskar Munireddy on 23/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
#import "Setting.h"

@interface ReachMeActivationViewController : BaseUI
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *reachMeType;
@property (nonatomic, assign) BOOL isActivationProcess;
@property (nonatomic, assign) BOOL isSwitchToInternational;
@property (nonatomic, assign) BOOL isSwitchProcess;
@property (nonatomic, assign) BOOL isOnBoardingProcess;
@property (nonatomic, strong) VoiceMailInfo *voiceMailInfo;
@end
