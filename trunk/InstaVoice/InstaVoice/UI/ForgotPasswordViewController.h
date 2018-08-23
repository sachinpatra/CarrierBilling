//
//  ForgotPasswordViewController.h
//  InstaVoice
//
//  Created by Divya Patel on 10/12/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "BaseUI.h"
#import "MobileEntryViewController.h"

@interface ForgotPasswordViewController : BaseUI
{
    BOOL isPossible;
    CGFloat _initialHeight;
}
@property (strong, nonatomic) IBOutlet UIView *cancelContinueView;
@property (strong, nonatomic) IBOutlet UIImageView *ivLogoIcon;
@property (strong, nonatomic) IBOutlet UIImageView *mobileIcon;
@property (strong, nonatomic) IBOutlet UILabel *mobileNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *country;

@property (strong, nonatomic) IBOutlet UIImageView *selectedCountryFlag;

@property (strong, nonatomic) NSMutableDictionary *dict;
@property (strong, nonatomic) IBOutlet UIButton *cancelButtonText;
@property (strong, nonatomic) IBOutlet UIButton *continueButtonText;
@property (strong, nonatomic) IBOutlet UIButton *alreadyRecievedCodeButton;
- (IBAction)haveOTPaction:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *enterPasswordLbl;
@property (nonatomic) NSString *mobileNumber;
@property (nonatomic,strong)  NSMutableDictionary *otpViewDict;
@property (nonatomic,strong)  NSMutableDictionary *userDic;
@property (nonatomic,strong) NSString *verificationType;
- (IBAction)continueAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *continueAction;
- (IBAction)cancelAction:(id)sender;



@end
