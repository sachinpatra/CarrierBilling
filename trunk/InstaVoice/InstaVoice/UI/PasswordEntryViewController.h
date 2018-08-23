//
//  PasswordEntryViewController.h
//  InstaVoice
//
//  Created by adwivedi on 21/09/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "BaseUI.h"
#import "MobileEntryViewController.h"
#import "IVLoginViewProtocol.h"

@interface PasswordEntryViewController : BaseUI
{
    BOOL isPossible;
    CGFloat _initialHeight;
    BOOL _isToolbarCreated;
}
@property (weak, nonatomic) IBOutlet UIButton *forgotOrSetPassword;
@property (strong, nonatomic) IBOutlet UIView *cancelContinueView;
@property (strong, nonatomic) IBOutlet UIImageView *ivLogoIcon;
@property (strong, nonatomic) IBOutlet UIImageView *mobileIcon;
@property (strong, nonatomic) IBOutlet UILabel *mobileNumberLabel;
@property (strong, nonatomic) IBOutlet UIImageView *passwordKeyIcon;
@property (strong, nonatomic) IBOutlet UITextField *enterPassword;
@property (strong, nonatomic) NSString *mobileNumber;
@property (strong, nonatomic) NSString  *mobileNumberWithCode;
@property (strong, nonatomic) NSMutableDictionary *dict;
@property (strong, nonatomic) IBOutlet UIButton *cancelButtonText;
@property (strong, nonatomic) IBOutlet UIButton *continueButtonText;
@property (strong, nonatomic) IBOutlet UILabel *enterPasswordLbl;
@property (nonatomic, weak) id<IVLoginViewDelegate> loginViewDelegate; 
@property BOOL *scrollView;
- (IBAction)forgetPasswordAction:(id)sender;

- (IBAction)loginWithPassword:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
