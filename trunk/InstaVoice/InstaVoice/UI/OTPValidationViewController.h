//
//  OTPValidationViewController.h
//  InstaVoice
//
//  Created by Divya Patel on 9/24/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "BaseUI.h"
#import "GenderView.h"
#import "DateOfBirthView.h"
#import "ProfilePicView.h"
#import "DatePickerView.h"
#import "IVLoginViewProtocol.h"

#define COLOR182_255 182/255.0
#define COLOR183_255 183/255.0
#define COLOR216_255 216/255.0
#define COLOR220_255 220/255.0
#define COLOR30_255  30/255.0
#define COLOR144_255 144/255.0
#define COLOR251_255 251/255.0


/*
@protocol VerificationOTPViewControllerDelegate <NSObject>

-(void)updateAdditionalNumbers;
-(void)addingNonVerifiedNumber:(NSString *)nonVerifiedNumber withcountrycode:(NSString *)countryCode;

@end
 */

typedef enum:NSInteger
{
calledFromSignUP=0,
calledFromForgetPassword

}otpViewControllerCalledFrom;


@interface OTPValidationViewController : BaseUI
{

     IBOutlet UIButton *validateBtn;
    UIView *topView;
    UITextField  *activeField;
    CGPoint validatePos;
    GenderView *genderView;
    IBOutlet UILabel     *regenVidateCodeLabl;

    DateOfBirthView *dateOfBirthView;
    ProfilePicView *profilePictureView;
    DatePickerView *    datePicker;
    int count;
    int selected;               //Edited JAtin
    int timeToShow ;
     UIAlertView             *alertNumberValidation;
    UIAlertView             *alertNumberValidationSecondaryNumber;
    UIAlertView             *alertNumberValidationRegisterTypeNumber;
    BOOL _isToolbarCreated;//FEB 6
    BOOL _isRMFreshSignUpHomeActivated;
}
@property (strong, nonatomic) IBOutlet UIView *callMeView;
@property (strong, nonatomic) IBOutlet UIButton *reqPinBtn;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UIImageView *ivLogoIcon;
@property (strong, nonatomic) IBOutlet UILabel *enterValidationCodeLabel;
@property (strong, nonatomic) IBOutlet UILabel *didNotRecievedCodeLabel;
@property (strong, nonatomic) IBOutlet UITextField *pinTextFiledFirst;
@property (strong, nonatomic) IBOutlet UITextField *pinTextFiledSecond;
@property (strong, nonatomic) IBOutlet UITextField *pinTextFiledThird;
@property (strong, nonatomic) IBOutlet UITextField *pinTextFiledFourth;
@property (nonatomic) id<VerificationOTPViewControllerDelegate> delegate;
@property (nonatomic, assign) id<IVLoginViewDelegate> loginViewDelegate;
 @property  otpViewControllerCalledFrom *otpViewCalledFrom;
-(IBAction)validatioAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *validateButton;
@property BOOL cameForFirstTimeRegistration;


-(IBAction)reqNewPinAction:(id)sender;
@property (nonatomic,strong) NSString *verificationType;
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *countryCode;
@property (nonatomic) NSString *mobileNumber;
@property (nonatomic) NSString *mobileNumberWithCode;
@property (nonatomic,strong)  NSMutableDictionary *otpViewDict;
@property BOOL fromSignUp;
@property BOOL fromAlreadyReceivedPassword;

@end
