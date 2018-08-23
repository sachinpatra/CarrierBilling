//
//  VerifyScreen.h
//  InstaVoice
//
//  Created by EninovUser on 20/09/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
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

/* CMP
@protocol VerificationOTPViewControllerDelegate <NSObject>

-(void)updateAdditionalNumbers;
-(void)addingNonVerifiedNumber:(NSString *)nonVerifiedNumber withcountrycode:(NSString *)countryCode;

@end
 */

@interface VerificationOTPViewController : BaseUI
{
    IBOutlet UIButton *validateBtn;
    IBOutlet UITextField *pinTextFiledFirst;
    IBOutlet UITextField *pinTextFiledSecond;
    IBOutlet UITextField *pinTextFiledThird;
    IBOutlet UITextField *pinTextFiledFourth;
    IBOutlet UILabel     *regenVidateCodeLabl;
    IBOutlet UIButton    *reqPinBtn;
    IBOutlet UILabel     *firstLbl;
    IBOutlet UILabel     *secLbl;
    IBOutlet UIButton    *nextOrSkipButton;
    IBOutlet UIView    *bottomView;
    IBOutlet UILabel    *timerLabel;
    IBOutlet UILabel    *didNotRecieveSMSLabel;
    UIView *topView;
    UITextField  *activeField;
    CGPoint validatePos;
    GenderView *genderView;
    DateOfBirthView *dateOfBirthView;
    ProfilePicView *profilePictureView;
    DatePickerView *    datePicker;
    int count;
    int selected;               //Edited JAtin
    int timeToShow ;
    UIAlertView *alertVw;
}

@property (nonatomic,strong) NSString *verificationType;
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *countryCode;

@property (nonatomic) id<VerificationOTPViewControllerDelegate> delegate;

@property BOOL fromSignUp;

/**
 * This function is used to verify the pin code which entered by the user in four text fields.
 */
-(IBAction)validatioAction:(id)sender;
-(IBAction)reqNewPinAction:(id)sender;
-(IBAction)nextButtonAction;
@end
