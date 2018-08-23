//
//  ReachMeActivatedViewController.h
//  InstaVoice
//
//  Created by Bhaskar Munireddy on 24/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"

@interface ReachMeActivatedViewController : BaseUI
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *reachMeType;
@property (nonatomic, strong) VoiceMailInfo *voiceMailInfo;

@end
