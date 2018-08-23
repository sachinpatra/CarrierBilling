//
//  MobileEntryViewController.m
//  InstaVoice
//
//  Created by adwivedi on 21/09/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#define PLACEHOLDERTEXT @"_placeholderLabel.textColor"
#import "MobileEntryViewController.h"
#import "ProfileFieldSelectionTableViewController.h"
#import "SelectCountryViewController.h"
#import "JoinUserAPI.h"
#import "Common.h"
#import "ChatMobileNumberViewController.h"
#import "ConfigurationReader.h"
#import "AboutUsWebViewScreen.h"
#import "RegistrationApi.h"
#import "IVColors.h"
#import "BrandingScreenViewController.h"
#import "Common.h"
#import "GetDeviceModel.h"
#import "OTPValidationViewController.h"
#import "IVLoginViewProtocol.h"
#import "IVFileLocator.h"
#import "ScreenUtility.h"
#import "ForgotPasswordViewController.h"

#define ACCEPTABLE_CHARACTERS @"0123456789"


@interface MobileEntryViewController ()<ProfileFieldSelectionDelegate,SelectCountryViewControllerDelegate,UITextFieldDelegate, IVLoginViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInButtonBottomConstraint;

@end

@implementation MobileEntryViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    loggedInId = @"";
    NSString* str = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
    NSString* ccode = [[ConfigurationReader sharedConfgReaderObj]getCountryISD];
    if([str length] && [ccode length]) {
        NSRange replaceRange = [str rangeOfString:ccode];
        if (replaceRange.location != NSNotFound){
            loggedInId = [str stringByReplacingCharactersInRange:replaceRange withString:@""];
            numberWithoutFormat = loggedInId;
        }
    }
    
    [self.enterMobileNumberField setTintColor:[UIColor whiteColor]];
    GetDeviceModel *deviceModel=[[GetDeviceModel alloc]init];
    NSString *model=deviceModel.platformString;
    
    // NSString *model = [self platformString];
    if([model isEqualToString:@"iPhone 6 Plus"]||[model isEqualToString:@"iPhone 6 Plus"])
        self.view.transform =CGAffineTransformScale(CGAffineTransformIdentity, 1.25,1.25 );
    //    NSUUID *myDevice = [NSUUID UUID];
    //    NSString *deviceUDID = myDevice.UUIDString;
    // Do any additional setup after loading the view from its nib.
    [self setDefaultFlag];
    numberWithoutFormat = @"";
    
    //  numberWithoutFormat=self.mobileNumber;
    //  self.enterMobileNumberField.text=self.mobileNumber;
    self.view.backgroundColor = [IVColors redColor];
    self.enterMobileNumberField.backgroundColor =[IVColors redColor];
    self.mobileIcon.backgroundColor =[IVColors redColor];
    self.countryButton.backgroundColor=[IVColors redColor];
    self.ivImageIcon.clipsToBounds = YES;
    self.ivImageIcon.layer.cornerRadius = 10.0f;
    self.ivImageIcon.backgroundColor = [IVColors redColor];
    UIImageView *yourPlusSign = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow"]];
    yourPlusSign.frame = CGRectMake(200, 12, 10, 10);//choose values that fit properly inside the frame of your baseButton
    //or grab the width and height of yourBaseButton and change accordingly
    yourPlusSign.contentMode=UIViewContentModeScaleAspectFill;//or whichever mode works best for you
    [self.countryButton addSubview:yourPlusSign];
    self.signInButton.layer.cornerRadius = 10.0f;
    
    [self updateViewBackGroundColor];
    
    self.enterMobileNumberField.backgroundColor =[UIColor clearColor];
    self.mobileIcon.backgroundColor =[UIColor clearColor];
    self.countryButton.backgroundColor=[UIColor clearColor];
    self.ivImageIcon.backgroundColor = [UIColor clearColor];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setPlaceHolderForTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    /*
    NSString* str = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
    NSString* ccode = [[ConfigurationReader sharedConfgReaderObj]getCountryISD];
    if([str length] && [ccode length]) {
        NSRange replaceRange = [str rangeOfString:ccode];
        if (replaceRange.location != NSNotFound){
            loggedInId = [str stringByReplacingCharactersInRange:replaceRange withString:@""];
            self.enterMobileNumberField.text = [Common getFormattedNumberForTextFieldWithNumber:loggedInId andCountryIsdCode:countryIsdCode];
            numberWithoutFormat = loggedInId;
        }
    }*/
}

-(void)appHasGoneInActive:(NSNotification *)note
{
    [self.enterMobileNumberField resignFirstResponder];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
   
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
}


-(void)setPlaceHolderForTextField
{
    [self.enterMobileNumberField setValue:[UIColor whiteColor] forKeyPath:PLACEHOLDERTEXT];
    //CMP
    self.enterMobileNumberField.text = [Common getFormattedNumberForTextFieldWithNumber:loggedInId andCountryIsdCode:countryIsdCode];
    numberWithoutFormat = loggedInId;
    //
}

-(void)keyboardWillAppear:(NSNotification *)note
{
    CGRect currentFrame = self.view.frame;
    CGFloat keyboardHeight = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect newFrame = CGRectMake(currentFrame.origin.x, 66.0 - keyboardHeight, currentFrame.size.width, currentFrame.size.height);
    
    CGRect rectButton = self.signInButton.frame;
    CGFloat height=rectButton.origin.y+rectButton.size.height;
    
    if(keyboardHeight<(height) && keyboardHeight > 0)
    {
        [UIView animateWithDuration:0.25 animations:^{
            if (DEVICE_HEIGHT < 800.0) {
                self.view.frame = newFrame;
            }else{
                self.signInButtonBottomConstraint.constant = keyboardHeight - 30.0;
            }
        }];
    }
}

-(void)keyboardWillDisappear:(NSNotification *)note
{
    CGRect currentFrame = self.view.frame;
    CGRect newFrame = CGRectMake(currentFrame.origin.x, 0, currentFrame.size.width, currentFrame.size.height);
    
    [UIView animateWithDuration:1.0 animations:^{
        if (DEVICE_HEIGHT < 800.0) {
            self.view.frame = newFrame;
        }else{
            self.signInButtonBottomConstraint.constant = 30.0;
        }
    }];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)selectCountry:(id)sender {
    [self.enterMobileNumberField resignFirstResponder];
    self.navigationController.navigationBar.tintColor = [IVColors redColor];
    SelectCountryViewController* svc = [[UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"SelectCountry"];
    svc.profileFieldData = [[Setting sharedSetting]getCountryList];
    svc.topFiveCountryList = [Common topFiveCountryList];
    svc.countrySelectionDelegate = self;
    [self.navigationController pushViewController:svc animated:YES];
    
//    ProfileFieldSelectionTableViewController* svc = [[ProfileFieldSelectionTableViewController alloc]initWithNibName:@"ProfileFieldSelectionTableViewController" bundle:Nil];
//    svc.profileFieldTitle = @"Select Country";
//    svc.profileFieldType = ProfileFieldTypeCountry;
//    svc.profileFieldData = [[Setting sharedSetting]getCountryList];
//    svc.topFiveCountryList = [Common topFiveCountryList];
//    svc.profileFieldSelectionDelegate = self;
//    [self.navigationController pushViewController:svc animated:YES];
    
}

- (IBAction)signInButtonAction:(id)sender {
    
    [LinphoneManager.instance resetUserAgentString];
    //to fix the bug of update phone number issue.
    //loggedInId = [self.enterMobileNumberField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    numberWithoutFormat = loggedInId;
    [self.enterMobileNumberField resignFirstResponder];
    
    [self showProgressBar];
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        
        if([self emptyFieldValidation])
        {
            [self hideProgressBar];
            if(isPossible)
            {
                NSString *msg = @"\nIs this OK,\nor would you like to change it?";
                NSString *title = [@"Confirm mobile number\n\n" stringByAppendingString:[Common getFormattedNumber:numberWithoutFormat withCountryIsdCode:countryIsdCode withGivenNumberisCannonical:NO]];
                
                alertNumberValidation = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Change" otherButtonTitles:@"Confirm", nil];
                [alertNumberValidation show];
                //  isPossible=false;
            }
            else
            {     NSString *msg = @"\nIs this OK,\nor would you like to change it?";
                NSString *title = [@"Confirm mobile number\n\n" stringByAppendingString:[Common getFormattedNumber:numberWithoutFormat withCountryIsdCode:countryIsdCode withGivenNumberisCannonical:NO]];
                
                alertNumberValidation = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Change" otherButtonTitles:@"Continue", nil];
                [alertNumberValidation show];
                /*   NSMutableDictionary *userDic = [[NSMutableDictionary alloc]init];
                 [userDic setValue:countryIsdCode forKey:COUNTRY_SIM_ISO];
                 [userDic setValue:numberE164format forKey:USER_ID];
                 [appDelegate.confgReader setCountryName:countryName];
                 [appDelegate.confgReader setMinPhoneLen:minPhoneLen];
                 [appDelegate.confgReader setMaxPhoneLen:maxPhoneLen];
                 
                 [self loginUser:userDic];
                 */
            }
            
            isPossible=false;
            
        }//end of outer if
        [self hideProgressBar];
    });
    
}


-(void)loginUser:(NSMutableDictionary*)userDic
{
    [[Setting sharedSetting]setCountryInfo];
    
    if(userDic != NULL)
    {
        NSMutableDictionary *signINDic = [[NSMutableDictionary alloc] init];
        NSString *countryIso = [userDic valueForKey:COUNTRY_SIM_ISO];
        NSString *canonicalNum = [[userDic valueForKey:USER_ID] stringByReplacingOccurrencesOfString:@"+" withString:@""];//[countryIso
        [[ConfigurationReader sharedConfgReaderObj]setCurrentLoggedInPhoneNumber:canonicalNum];
        [signINDic setValue:canonicalNum forKey:API_PHONE_NUM];
        [signINDic setValue:[NSNumber numberWithBool:YES] forKey:API_PHONE_NUM_EDITED];
        [signINDic setValue:[NSNumber numberWithBool:YES] forKey:API_OPR_INFO_EDITED];
        
        NSString *uuid = [appDelegate.confgReader getDeviceUUID];
        if(uuid == nil || [uuid length]==0)
        {
            uuid = [Common getUniqueDeviceID];
            [appDelegate.confgReader setDeviceUUID:uuid];
        }
        [signINDic setValue:uuid forKey:API_DEVICE_ID];
        
        [signINDic setValue:countryIso forKey:API_SIM_COUNTRY_ISO];
        NSString *mccmnc = [appDelegate.confgReader getCountryMCCMNC];
        if(mccmnc != nil && [mccmnc length] >0)
        {
            [signINDic setValue:mccmnc forKey:API_SIM_OPR_MCC_MNC];
        }
        else
        {
            // [signINDic setValue:@"na" forKey:API_SIM_OPR_MCC_MNC];
        }
        
        [signINDic setValue:@"" forKey:API_SIM_SERIAL_NUM];
        self.mobileNumber=[Common getFormattedNumber:numberWithoutFormat withCountryIsdCode:countryIsdCode withGivenNumberisCannonical:NO];
        
        //OCT 18, 2016
        if(self.mobileNumber)
            [[ConfigurationReader sharedConfgReaderObj]setScreenName:self.mobileNumber];
        else
            [[ConfigurationReader sharedConfgReaderObj]setScreenName:@""];
        //
        
        JoinUserAPI* api = [[JoinUserAPI alloc]initWithRequest:signINDic];
        [self showProgressBar];
        [api callNetworkRequest:signINDic withSuccess:^(JoinUserAPI *req, NSMutableDictionary *responseObject) {
            
            [self hideProgressBar];
            
            NSString* action = [responseObject valueForKey:@"action"];
            if([action isEqualToString:@"pwd_set"])
            {
#ifdef REACHME_APP
                if ([[ConfigurationReader sharedConfgReaderObj] isRMFreshSignUp]) {
                    NSString *message = @"\nYou're using this number on your InstaVoice account. You can use the same account to login to ReachMe\n";
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"InstaVoice User" message:message preferredStyle:UIAlertControllerStyleAlert];
                    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:message];
                    [attrStr addAttribute:NSForegroundColorAttributeName
                                    value:[UIColor redColor]
                                    range:NSMakeRange(attrStr.length - 8, 8)];
                    [alertController setValue:attrStr forKey:@"attributedMessage"];
                    
                    UIAlertAction *forgotPassword = [UIAlertAction actionWithTitle:@"Forgot password" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        int64_t delayInSeconds = 1.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            
                            ForgotPasswordViewController* targetController = [[ForgotPasswordViewController alloc]initWithNibName:@"ForgotPasswordViewController" bundle:nil];
                            targetController.otpViewDict=[NSMutableDictionary dictionaryWithDictionary:signINDic];
                            targetController.userDic=[NSMutableDictionary dictionaryWithDictionary:signINDic];
                            targetController.verificationType = FORGOT_TYPE;
                            targetController.mobileNumber=self.mobileNumber;
                            [self.navigationController pushViewController:targetController animated:YES];
                            [self hideProgressBar];
                        });
                    }];
                    
                    UIAlertAction *continueToLogin = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *continueAction){
                        PasswordEntryViewController *targetController=[[PasswordEntryViewController alloc] initWithNibName:@"PasswordEntryViewController" bundle:nil];
                        targetController.dict=[NSMutableDictionary dictionaryWithDictionary:signINDic];
                        targetController.mobileNumber=self.mobileNumber;
                        targetController.loginViewDelegate = self;
                        targetController.mobileNumberWithCode=numberWithoutPlus;
                        [self.navigationController pushViewController:targetController animated:YES];
                    }];
                    
                    [alertController addAction:forgotPassword];
                    [alertController addAction:continueToLogin];
                    
                    alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
                    [self.navigationController presentViewController:alertController animated:true completion:nil];
                }else{
                    PasswordEntryViewController *targetController=[[PasswordEntryViewController alloc] initWithNibName:@"PasswordEntryViewController" bundle:nil];
                    targetController.dict=[NSMutableDictionary dictionaryWithDictionary:signINDic];
                    targetController.mobileNumber=self.mobileNumber;
                    targetController.loginViewDelegate = self;
                    targetController.mobileNumberWithCode=numberWithoutPlus;
                    [self.navigationController pushViewController:targetController animated:YES];
                }
#else
                PasswordEntryViewController *targetController=[[PasswordEntryViewController alloc] initWithNibName:@"PasswordEntryViewController" bundle:nil];
                targetController.dict=[NSMutableDictionary dictionaryWithDictionary:signINDic];
                targetController.mobileNumber=self.mobileNumber;
                targetController.loginViewDelegate = self;
                targetController.mobileNumberWithCode=numberWithoutPlus;
                [self.navigationController pushViewController:targetController animated:YES];
#endif
                
            }
            else if([action isEqualToString:@"otp_sent"])
            {
                
#ifdef REACHME_APP
                if ([[ConfigurationReader sharedConfgReaderObj] isRMFreshSignUp] && ![[ConfigurationReader sharedConfgReaderObj] isFreshSignUp]) {
                    NSString *message = @"\nYou're using this number on your InstaVoice account. You can use the same account to login to ReachMe\n";
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"InstaVoice User" message:message preferredStyle:UIAlertControllerStyleAlert];
                    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:message];
                    [attrStr addAttribute:NSForegroundColorAttributeName
                                    value:[UIColor redColor]
                                    range:NSMakeRange(attrStr.length - 8, 8)];
                    [alertController setValue:attrStr forKey:@"attributedMessage"];
                    
                    UIAlertAction *continueToLogin = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *continueAction){
                        //otp flow
                        OTPValidationViewController* targetController = [[OTPValidationViewController alloc]initWithNibName:@"OTPValidationViewController" bundle:nil];
                        
                        NSString *loginId = [signINDic valueForKey:API_PHONE_NUM];
                        NSString *prevLoginId = [appDelegate.confgReader getLoginId];
                        if(prevLoginId != nil && [prevLoginId length]>0)
                        {
                            if(![prevLoginId isEqualToString:loginId])
                            {
                                [targetController updateViewBackGroundColor];
                                [appDelegate.engObj resetLoginData:NO];
                            }
                        }
                        
                        [appDelegate.confgReader setRegSecureKey:[responseObject valueForKey:API_REG_SECURE_KEY]];
                        [appDelegate.confgReader setPnsAppID:[responseObject valueForKey:API_PNS_APP_ID]];
                        [appDelegate.confgReader setDocsUrl:[responseObject valueForKey:API_DOCS_URL]];
                        [appDelegate registerForPushNotification];
#ifdef REACHME_APP
                        [appDelegate registerForVOIPPush];
#endif
                        
                        [appDelegate.confgReader setUserNumberForValidation:[userDic valueForKey:API_PHONE_NUM]];
                        NSDate* now = [NSDate date];
                        NSNumber* currentTime = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
                        [appDelegate.confgReader setValidationTimer:currentTime];
                        
                        targetController.otpViewDict=[NSMutableDictionary dictionaryWithDictionary:signINDic];
                        targetController.verificationType = REGISTER_TYPE;
                        targetController.cameForFirstTimeRegistration=TRUE;
                        targetController.loginViewDelegate = self;
                        targetController.mobileNumber=self.mobileNumber;
                        targetController.fromAlreadyReceivedPassword=true;
                        targetController.mobileNumberWithCode=numberWithoutPlus;
                        
                        [self.navigationController pushViewController:targetController animated:YES];
                    }];
                    
                    [alertController addAction:continueToLogin];
                    
                    alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
                    [self.navigationController presentViewController:alertController animated:true completion:nil];
                }else{
                    //otp flow
                    OTPValidationViewController* targetController = [[OTPValidationViewController alloc]initWithNibName:@"OTPValidationViewController" bundle:nil];
                    
                    NSString *loginId = [signINDic valueForKey:API_PHONE_NUM];
                    NSString *prevLoginId = [appDelegate.confgReader getLoginId];
                    if(prevLoginId != nil && [prevLoginId length]>0)
                    {
                        if(![prevLoginId isEqualToString:loginId])
                        {
                            [targetController updateViewBackGroundColor];
                            [appDelegate.engObj resetLoginData:NO];
                        }
                    }
                    
                    [appDelegate.confgReader setRegSecureKey:[responseObject valueForKey:API_REG_SECURE_KEY]];
                    [appDelegate.confgReader setPnsAppID:[responseObject valueForKey:API_PNS_APP_ID]];
                    [appDelegate.confgReader setDocsUrl:[responseObject valueForKey:API_DOCS_URL]];
                    [appDelegate registerForPushNotification];
#ifdef REACHME_APP
                    [appDelegate registerForVOIPPush];
#endif
                    
                    [appDelegate.confgReader setUserNumberForValidation:[userDic valueForKey:API_PHONE_NUM]];
                    NSDate* now = [NSDate date];
                    NSNumber* currentTime = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
                    [appDelegate.confgReader setValidationTimer:currentTime];
                    
                    targetController.otpViewDict=[NSMutableDictionary dictionaryWithDictionary:signINDic];
                    targetController.verificationType = REGISTER_TYPE;
                    targetController.cameForFirstTimeRegistration=TRUE;
                    targetController.loginViewDelegate = self;
                    targetController.mobileNumber=self.mobileNumber;
                    targetController.fromAlreadyReceivedPassword=true;
                    targetController.mobileNumberWithCode=numberWithoutPlus;
                    
                    [self.navigationController pushViewController:targetController animated:YES];
                }
#else
                //otp flow
                OTPValidationViewController* targetController = [[OTPValidationViewController alloc]initWithNibName:@"OTPValidationViewController" bundle:nil];
                
                NSString *loginId = [signINDic valueForKey:API_PHONE_NUM];
                NSString *prevLoginId = [appDelegate.confgReader getLoginId];
                if(prevLoginId != nil && [prevLoginId length]>0)
                {
                    if(![prevLoginId isEqualToString:loginId])
                    {
                        [targetController updateViewBackGroundColor];
                        [appDelegate.engObj resetLoginData:NO];
                    }
                }
                
                [appDelegate.confgReader setRegSecureKey:[responseObject valueForKey:API_REG_SECURE_KEY]];
                [appDelegate.confgReader setPnsAppID:[responseObject valueForKey:API_PNS_APP_ID]];
                [appDelegate.confgReader setDocsUrl:[responseObject valueForKey:API_DOCS_URL]];
                [appDelegate registerForPushNotification];
                
                [appDelegate.confgReader setUserNumberForValidation:[userDic valueForKey:API_PHONE_NUM]];
                NSDate* now = [NSDate date];
                NSNumber* currentTime = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
                [appDelegate.confgReader setValidationTimer:currentTime];
                
                targetController.otpViewDict=[NSMutableDictionary dictionaryWithDictionary:signINDic];
                targetController.verificationType = REGISTER_TYPE;
                targetController.cameForFirstTimeRegistration=TRUE;
                targetController.loginViewDelegate = self;
                targetController.mobileNumber=self.mobileNumber;
                targetController.fromAlreadyReceivedPassword=true;
                targetController.mobileNumberWithCode=numberWithoutPlus;
                
                [self.navigationController pushViewController:targetController animated:YES];
#endif
            }
            else if([action isEqualToString:@"set_primary_pwd"]) {
                //Multiple login
                
#ifdef REACHME_APP
                if ([[ConfigurationReader sharedConfgReaderObj] isRMFreshSignUp] && ![[ConfigurationReader sharedConfgReaderObj] isFreshSignUp]) {
                    NSString *message = @"\nYou're using this number on your InstaVoice account. You can use the same account to login to ReachMe\n";
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"InstaVoice User" message:message preferredStyle:UIAlertControllerStyleAlert];
                    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:message];
                    [attrStr addAttribute:NSForegroundColorAttributeName
                                    value:[UIColor redColor]
                                    range:NSMakeRange(attrStr.length - 8, 8)];
                    [alertController setValue:attrStr forKey:@"attributedMessage"];
                    
                    UIAlertAction *continueToLogin = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *continueAction){
                        
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Multi Login" message:@"\nYou are already logged into your account on different device\n\nPlease set password on your first device\n\nGo to Settings -> Account -> Set Password" preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *continueToSetPassword = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *continueAction){
                            PasswordEntryViewController *targetController=[[PasswordEntryViewController alloc] initWithNibName:@"PasswordEntryViewController" bundle:nil];
                            self.dictForMultipleLogin=[NSMutableDictionary dictionaryWithDictionary:signINDic];
                            [self.dictForMultipleLogin setValue:@"set_primary_pwd" forKey:@"action"];
                            targetController.dict=[NSMutableDictionary dictionaryWithDictionary:self.dictForMultipleLogin];
                            targetController.mobileNumber=self.mobileNumber;
                            targetController.mobileNumberWithCode=numberWithoutPlus;
                            [self.navigationController pushViewController:targetController animated:YES];
                        }];
                        [alertController addAction:continueToSetPassword];
                        
                        alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
                        [self.navigationController presentViewController:alertController animated:true completion:nil];
                    }];
                    
                    [alertController addAction:continueToLogin];
                    
                    alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
                    [self.navigationController presentViewController:alertController animated:true completion:nil];
                }else{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Multi Login" message:@"\nYou are already logged into your account on different device\n\nPlease set password on your first device\n\nGo to Settings -> Account -> Set Password" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *continueToSetPassword = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *continueAction){
                        PasswordEntryViewController *targetController=[[PasswordEntryViewController alloc] initWithNibName:@"PasswordEntryViewController" bundle:nil];
                        self.dictForMultipleLogin=[NSMutableDictionary dictionaryWithDictionary:signINDic];
                        [self.dictForMultipleLogin setValue:@"set_primary_pwd" forKey:@"action"];
                        targetController.dict=[NSMutableDictionary dictionaryWithDictionary:self.dictForMultipleLogin];
                        targetController.mobileNumber=self.mobileNumber;
                        targetController.mobileNumberWithCode=numberWithoutPlus;
                        [self.navigationController pushViewController:targetController animated:YES];
                    }];
                    [alertController addAction:continueToSetPassword];
                    
                    alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
                    [self.navigationController presentViewController:alertController animated:true completion:nil];
                }
#else
                
                //Alert message for 1.x screen.
                /*
                 UIFont *font = [UIFont fontWithName:@"Arial" size:14.0];
                 NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                 forKey:NSFontAttributeName];
                 NSMutableAttributedString *attrString1 = [[NSMutableAttributedString alloc] initWithString:@"You are already logged into your account on different device" attributes:attrsDictionary];
                 UIFont *font2 = [UIFont fontWithName:@"Arial" size:12.0];
                 NSDictionary *attrsDictionary2 = [NSDictionary dictionaryWithObject:font2
                 forKey:NSFontAttributeName];
                 NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:@"Please set password on your first device" attributes:attrsDictionary2];
                 
                 UIFont *font3 = [UIFont fontWithName:@"Arial" size:15.0];
                 NSDictionary *attrsDictionary3 = [NSDictionary dictionaryWithObject:font3
                 forKey:NSFontAttributeName];
                 NSMutableAttributedString *attrString3 = [[NSMutableAttributedString alloc] initWithString:@"Go to Settings -> Account -> Set Password" attributes:attrsDictionary3];
                 
                 
                 
                 
                 [attrString2 appendAttributedString:attrString3];
                 [attrString1 appendAttributedString:attrString2];
                 */
                
                NSString *msg = @"\nYou are already logged into your account on different device\n\nPlease set password on your first device\n\nGo to Settings -> Account -> Set Password";
                NSString *title = @"Multi Login";
                self.dictForMultipleLogin=[NSMutableDictionary dictionaryWithDictionary:signINDic];
                
                
                alertMultipleDeviceLogging = [[UIAlertView alloc] initWithTitle:title
                                                                        message:msg
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"OK", nil];
                [alertMultipleDeviceLogging show];
                
#endif
                
            }
            else
            {
                //Server error
            }
            
        } failure:^(JoinUserAPI *req, NSError *error) {
            
            int64_t delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                NSInteger errorCode = error.code;
                NSString *errorMsg = [Common convertErrorCodeToErrorString:errorCode];
                int netAvailable = [Common isNetworkAvailable];
                [self hideProgressBar];
                if(netAvailable == NETWORK_NOT_AVAILABLE)
                {
                    //OCT 4, 2016 [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
                    [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
                    
                }
                else if(errorCode == 86){
                    NSString *errorString = [NSLocalizedString(@"NOT_PRIMARY_NUMBER", nil) stringByAppendingString:[(error.userInfo) valueForKey:NSLocalizedString(@"PRIMARY_PHONE_MASK", nil)]];
#ifdef REACHME_APP
                    errorString = [errorString stringByAppendingString:@". If you don't recognize this number contact support at reachme@instavoice.com"];
#endif
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:errorString preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        
                    }];
                    
                    [alertController addAction:ok];
                    
                    alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
                    [self.navigationController presentViewController:alertController animated:true completion:nil];
                }
                else
                {
                    [ScreenUtility showAlert: errorMsg];
                }
            });
        }];
    }
}

- (IBAction)termsOfUseAction:(id)sender {
    
    int netAvailable = [Common isNetworkAvailable];
    if(netAvailable == NETWORK_NOT_AVAILABLE)
    {
        //OCT 4, 2016 [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    AboutUsWebViewScreen *webview = [[AboutUsWebViewScreen alloc]initWithNibName:@"BaseWebViewScreen" bundle:nil];
    webview.webViewType = TERMS_N_CONDN;
    webview.title = @"Terms of Use";
    [self.navigationController pushViewController:webview animated:YES];
}

-(void)countrySelection:(SelectCountryViewController*)countrySelected didSelectCountry:(NSMutableDictionary*)country
{
    KLog(@"Country %@",country);
    loggedInId = @"";
    [self.countryButton setTitle:[country valueForKey:COUNTRY_NAME] forState:UIControlStateNormal];
    [self processCountrySelection:country];
    [self setDefaultFlag];
}

-(void)profileFieldSelectionViewController:(ProfileFieldSelectionTableViewController *)profileViewController didSelectCountry:(NSMutableDictionary *)country
{
    KLog(@"Country %@",country);
    loggedInId = @"";
    [self.countryButton setTitle:[country valueForKey:COUNTRY_NAME] forState:UIControlStateNormal];
    [self processCountrySelection:country];
    [self setDefaultFlag];
}

-(void)setDefaultFlag
{
    NSString *countryISD = [appDelegate.confgReader getCountryISD];
    NSString *countryFlag = [appDelegate.confgReader getCountryName];
    [self.selectedCountryIcon setImage:[UIImage imageNamed:countryFlag]];
    
    if(countryISD != nil && [countryISD length]>0 && countryFlag != nil && [countryFlag length]>0)
    {
        maxPhoneLen = [appDelegate.confgReader getMaxPhoneLen];
        minPhoneLen = [appDelegate.confgReader getMinPhoneLen];
        [self.countryButton setTitle:countryFlag forState:UIControlStateNormal];
        countryName = countryFlag;
        //countryFlag = [countryFlag stringByAppendingString:@".png"];
        countryFlag = [countryFlag stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        [self.selectedCountryIcon setImage:[UIImage imageNamed:countryFlag]];
        [self.selectedCountryCodeLabel setText:[[NSString alloc] initWithFormat:@"+%@",countryISD]];
        if(countryIsdCode == nil)
        {
            countryIsdCode = @"";
        }
        if([countryIsdCode isEqualToString:countryISD])
        {
            self.enterMobileNumberField.text = self.enterMobileNumberField.text;
        }
        countryIsdCode= countryISD;
    }
    else
    {
        self.selectedCountryIcon.image = [UIImage imageNamed:@"world_icon.jpg"];
        self.selectedCountryCodeLabel.text= @"+";
        self.enterMobileNumberField.text= @"";
    }
    
    self.enterMobileNumberField.text = loggedInId;
    numberWithoutFormat = loggedInId;
    
}

- (void)processCountrySelection:(NSDictionary*)tempDic
{
    countryName =  [tempDic valueForKey:COUNTRY_NAME];
    maxPhoneLen = [[tempDic valueForKey:COUNTRY_MAX_PHONE_LENGTH] integerValue];
    minPhoneLen = [[tempDic valueForKey:COUNTRY_MIN_PHONE_LENGTH] integerValue];
    countryIsdCode = [tempDic valueForKey:COUNTRY_ISD_CODE];
    
    NSString* ccode = [tempDic valueForKey:COUNTRY_CODE];
    
    
    if(countryIsdCode != nil && [countryIsdCode length] > 0)
    {
        NSString *tempStr = [[NSString alloc] initWithFormat:@"+%@",countryIsdCode];
        self.selectedCountryCodeLabel.text = tempStr;
    }
    
    [[ConfigurationReader sharedConfgReaderObj]setCountryName:countryName];
    [[ConfigurationReader sharedConfgReaderObj]setCountryISD:countryIsdCode];
    if(ccode && [ccode length]) {
        [[ConfigurationReader sharedConfgReaderObj]setCountryCode:ccode];
    }
    self.enterMobileNumberField.text = @"";
    numberWithoutFormat = @"";
}


#pragma mark - TextField Delegate
//to fix the bug of update phone number issue.

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(countryIsdCode == nil || [countryIsdCode length]==0)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"ALERT_COUTRY_CODE", nil)];
        return NO;
    }

    loggedInId = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    
    NSString *filtered = [[loggedInId componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    numberWithoutFormat = loggedInId = filtered;

    return YES;
    
}

//to fix the bug of update phone number issue.
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(countryIsdCode == nil || [countryIsdCode length]==0)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"ALERT_COUTRY_CODE", nil)];
        return;
    }
    
    if(textField == self.enterMobileNumberField){
        if(([textField.text length] != 0) ){
            loggedInId = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
            
            NSString *filtered = [[loggedInId componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
            
            numberWithoutFormat = loggedInId = filtered;

            self.enterMobileNumberField.text = [Common getFormattedNumberForTextFieldWithNumber:textField.text andCountryIsdCode:countryIsdCode];
        }
    }
}

//to fix the bug of update phone number issue.
- (void)textFieldDidEndEditing:(UITextField *)textField {

    if(textField == self.enterMobileNumberField){
        if(([textField.text length] != 0) ){
            loggedInId = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
            
            NSString *filtered = [[loggedInId componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
            
            numberWithoutFormat = loggedInId =  filtered;

            self.enterMobileNumberField.text = [Common getFormattedNumberForTextFieldWithNumber:textField.text andCountryIsdCode:countryIsdCode];

        }
    }
}

-(void)showAlertInvalidNumber
{
    NSString *msg = @"\nPlease Enter Valid Phone Number";
    
    alertEnterValidNumber= [[UIAlertView alloc] initWithTitle:nil
                                                      message:msg
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"OK", nil];
    [alertEnterValidNumber show];
}


-(BOOL)emptyFieldValidation
{
    BOOL result = YES;
    
    int netAvailable = [Common isNetworkAvailable];
    if(netAvailable == NETWORK_NOT_AVAILABLE)
    {
        //OCT 4, 2016 [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return NO;
    }
    
    if(countryIsdCode == nil || [countryIsdCode length]==0)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"ALERT_COUTRY_CODE", nil)];
        return NO;
    }
    
    if([self.enterMobileNumberField.text isEqualToString:@""])
    {
        [ScreenUtility showAlert:NSLocalizedString(@"ENTER_PHONE_NUMBER", nil)];
        return NO;
    }
    else
    {
        numberE164format = [Common getE164FormatNumber:numberWithoutFormat withCountryIsdCode:countryIsdCode];
        numberWithoutPlus = [numberE164format substringFromIndex:1];
        
        if ([Common isPossibleNumber:numberWithoutFormat withContryISDCode:countryIsdCode showAlert:YES])
        {
            isPossible = true;
            if ([Common isValidNumber:numberWithoutFormat withContryISDCode:countryIsdCode]){
                
            }
        }
        else if([[[ConfigurationReader sharedConfgReaderObj]getPossibleNumber] isEqual:@"YES"])
        {
            [ScreenUtility showAlert:NSLocalizedString(@"ENTER_CORRECT_NUMBER", nil)];
            return NO;
        }
        else
            return NO;
    }
    
    return result;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:))
        return NO;
    return [super canPerformAction:action withSender:sender];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (alertView == alertNumberValidation)
    {
        if(buttonIndex == 0) {
            
            
        } else if(buttonIndex == 1) {
    
            [self.view endEditing:YES];
            NSMutableDictionary *userDic = [[NSMutableDictionary alloc]init];
            [userDic setValue:countryIsdCode forKey:COUNTRY_SIM_ISO];
            [userDic setValue:numberE164format forKey:USER_ID];
            [userDic setValue:PHONE_MODE forKey:LOGIN_MODE];
            
            
            [appDelegate.confgReader setCountryName:countryName];
            [appDelegate.confgReader setMinPhoneLen:minPhoneLen];
            [appDelegate.confgReader setMaxPhoneLen:maxPhoneLen];
            //Edited by Jatin
            
            [self loginUser:userDic];
        }
    }
    
    if(alertView==alertMultipleDeviceLogging)
    {
        if(buttonIndex==0)
        {
            [self.enterMobileNumberField resignFirstResponder];
            PasswordEntryViewController *targetController=[[PasswordEntryViewController alloc] initWithNibName:@"PasswordEntryViewController" bundle:nil];
            [self.dictForMultipleLogin setValue:@"set_primary_pwd" forKey:@"action"];
            targetController.dict=[NSMutableDictionary dictionaryWithDictionary:self.dictForMultipleLogin];
            targetController.mobileNumber=self.mobileNumber;
            targetController.mobileNumberWithCode=numberWithoutPlus;
            [self.navigationController pushViewController:targetController animated:YES];
        }
        
    }
    if(alertView==alertEnterValidNumber)
    {
        
    }
}


#pragma mark - LoginView Protocol -
- (void)changedNumberInTextField:(NSString *)withPhoneNumber {
    NSString* ccode = [[ConfigurationReader sharedConfgReaderObj]getCountryISD];
    if([withPhoneNumber length] && [ccode length]) {
        NSRange replaceRange = [withPhoneNumber rangeOfString:ccode];
        if (replaceRange.location != NSNotFound){
            loggedInId = [withPhoneNumber stringByReplacingCharactersInRange:replaceRange withString:@""];
            numberWithoutFormat = loggedInId;
        }
    }
    [self setPlaceHolderForTextField];
}

- (IBAction)tapRecognized:(id)sender
{
    [self.enterMobileNumberField resignFirstResponder];
}

@end
