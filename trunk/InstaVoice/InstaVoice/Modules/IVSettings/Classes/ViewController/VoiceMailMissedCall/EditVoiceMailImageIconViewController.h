//
//  EditVoiceMailImageIconViewController.h
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 28/07/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditVoiceMailImageIconViewController : UIViewController
@property (strong, nonatomic)  UIImageView *workIcon;
@property (strong, nonatomic)  UIImageView *homeIcon;
@property (strong, nonatomic)  UIImageView *mobileRedIcon;
@property (strong, nonatomic)  UIImageView *mobileGreenIcon;
@property (strong, nonatomic)  UIImageView *iPhoneIcon;
@property (strong, nonatomic)  UIImageView *mobilePurpleIcon;
@property (strong, nonatomic)  UIImageView *voiceMailWorkSelected;
@property (strong, nonatomic)  UIImageView *voiceMailPurpleSelected;
@property (strong, nonatomic)  UIImageView *voiceMailGreenSelected;
@property (strong, nonatomic)  UIImageView *voiceMailIphoneSelected;
@property (strong, nonatomic)  UIImageView *voiceMailRedSelected;
@property (strong, nonatomic)  UIImageView *voiceMailHomeSelected;
@property (strong, nonatomic) NSString *iconName;
@property (strong, nonatomic) NSString *phoneNumber;

@end
