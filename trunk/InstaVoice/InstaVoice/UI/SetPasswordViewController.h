//
//  SetPasswordViewController.h
//  InstaVoice
//
//  Created by Divya Patel on 9/24/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "BaseUI.h"

@interface SetPasswordViewController : BaseUI
@property (strong, nonatomic) IBOutlet UIImageView *ivLogoIcon;
@property (strong, nonatomic) IBOutlet UILabel *resetPasswordLabel;
@property (strong, nonatomic) IBOutlet UIImageView *mobileIcon;
@property (strong, nonatomic) IBOutlet UIImageView *lockImageForEnterPwdIcon;
@property (strong, nonatomic) IBOutlet UIImageView *lockImageForReEnterPwdIcon;
@property (strong, nonatomic) IBOutlet UITextField *enterPasswordField;
@property (strong, nonatomic) IBOutlet UITextField *reEnterPasswordField;
@property (strong, nonatomic) IBOutlet UIButton *cancelButtonLabel;
@property (strong, nonatomic) IBOutlet UIButton *continueButtonLabel;
@property (strong, nonatomic) IBOutlet UILabel *mobileNumberLabel;
@property NSMutableDictionary  *dict;
@property (strong, nonatomic) IBOutlet UIView *cancelContinueView;
@property NSString *mobileNumber;
@property NSString *mobileNumberWithCode;
- (IBAction)cancelAction:(id)sender;
- (IBAction)continueAction:(id)sender;
-(void) createMainTabBarItems;

@end
