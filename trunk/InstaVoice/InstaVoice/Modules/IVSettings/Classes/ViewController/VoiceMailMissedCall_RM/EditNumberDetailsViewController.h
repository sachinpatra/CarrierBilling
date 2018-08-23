//
//  EditNumberDetailsViewController.h
//  InstaVoice
//
//  Created by Bhaskar Munireddy on 19/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
#import "SettingModel.h"

@interface EditNumberDetailsViewController : BaseUI
@property (nonatomic, strong) NSString *phoneNumber, *carrierName, *titleName;
@property (nonatomic, strong) VoiceMailInfo *voiceMailInfo;
@property (nonatomic, assign) BOOL isReachMeNumber;
@end
