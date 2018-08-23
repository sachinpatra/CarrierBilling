//
//  IVLinkedNumberVoiceMailViewController.h
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 01/08/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingModel.h"
#import "BaseUI.h"

@interface IVLinkedNumberVoiceMailViewController : BaseUI
@property (nonatomic, strong) VoiceMailInfo *voiceMailInfo;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *selectedImageName;
@property (nonatomic, strong) NSString *imageName;
@end
