//
//  MobileEntryViewController.h
//  InstaVoice
//
//  Created by adwivedi on 21/09/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "BaseUI.h"
#import "PasswordEntryViewController.h"
#define PWD_MIN 6
#define PWD_MAX 25

@interface MobileEntryViewController : BaseUI<UIAlertViewDelegate> {
    NSString                *countryIsdCode;
    NSString                *countryName;
    NSInteger               minPhoneLen;
    NSInteger               maxPhoneLen;
    NSString                *numberWithoutFormat;
    NSString                *numberWithoutPlus;
    NSString                *numberE164format;
    BOOL                    isPossible;
    UIImage                 *worldIconImg;
    UIAlertView             *alertNumberValidation;
    UIAlertView             *alertMultipleDeviceLogging;
    UIAlertView             *alertEnterValidNumber;
    NSString                *loggedInId;
}
@property (strong, nonatomic) IBOutlet UIImageView *ivImageIcon;
@property (strong, nonatomic) IBOutlet UIImageView *selectedCountryIcon;
@property (strong, nonatomic) IBOutlet UIButton *countryButton;
@property (strong, nonatomic) IBOutlet UIImageView *mobileIcon;
@property (strong, nonatomic) IBOutlet UILabel *selectedCountryCodeLabel;
@property (strong, nonatomic) IBOutlet UITextField *enterMobileNumberField;
@property (strong, nonatomic) IBOutlet UILabel *acknowledgementLabel;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIView *countryMobileView;

@property  NSString *mobileNumber;
@property  NSDictionary *dictForMultipleLogin;

- (IBAction)selectCountry:(id)sender;
- (IBAction)signInButtonAction:(id)sender;
- (IBAction)termsOfUseAction:(id)sender;



@end
