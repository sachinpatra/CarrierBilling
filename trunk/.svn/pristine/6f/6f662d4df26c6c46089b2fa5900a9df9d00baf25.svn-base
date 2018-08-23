//
//  ForgotPasswordViewController.m
//  InstaVoice
//
//  Created by Divya Patel on 10/12/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//


#import "OTPValidationViewController.h"
#import "IVColors.h"
#import "LinkButton.h"
#import "macro.h"
#import "HttpConstant.h"
#import "EventType.h"
#import "Common.h"
#import "ServerErrorMsg.h"
#import "ConfigurationReader.h"
#import "VerificationOTPViewController.h"
#import "TableColumns.h"
#import "UIType.h"
#import "AboutUsWebViewScreen.h"
#import "SizeMacro.h"
#import "ScreenUtility.h"
#import "Setting.h"
#import "RegistrationApi.h"
#import "RegisterUserAPI.h"
#import "LoginAPI.h"
#import "NBPhoneNumberUtil.h"
#import "NBAsYouTypeFormatter.h"
#import "MyNotesScreen.h"

#ifndef REACHME_APP
    #import "ChatGridViewController.h"
#endif

#import "FriendsScreen.h"
#import "IVColors.h"
#import "MyVoboloScreen.h"
#import "Profile.h"
#import "SetPasswordViewController.h"

#import "GenerateNewPwdAPI.h"
#import "ForgotPasswordViewController.h"
#import "GetDeviceModel.h"

@interface ForgotPasswordViewController ()
@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLabel;

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[IVColors redColor];
    //DC MEMLEAK MAY 25 2016
    //NSString *countryISD = [appDelegate.confgReader getCountryISD];
    
    NSString *countryFlag = [appDelegate.confgReader getCountryName];
    self.selectedCountryFlag.backgroundColor =[IVColors redColor];
    self.mobileIcon.backgroundColor=[IVColors redColor];
    self.ivLogoIcon.backgroundColor=[IVColors redColor];
    countryFlag = [countryFlag stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    [self.selectedCountryFlag setImage:[UIImage imageNamed:countryFlag]];
    [self.country setText:[[NSString alloc] initWithFormat:@"%@",countryFlag]];
    self.mobileNumberLabel.text=self.mobileNumber;
    // Do any  additional setup after loading the view from its nib.
    
    [self updateViewBackGroundColor];
    self.mobileIcon.backgroundColor=[UIColor clearColor];
    self.ivLogoIcon.backgroundColor=[UIColor clearColor];
    self.selectedCountryFlag.backgroundColor =[UIColor clearColor];
    
    if ([[self.userDic valueForKey:@"action"] isEqualToString:@"set_primary_pwd"]) {
        self.forgotPasswordLabel.text = @"Set Password";
    }else{
        self.forgotPasswordLabel.text = @"Forgot Password";
    }


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    GetDeviceModel *deviceModel=[[GetDeviceModel alloc]init];
    NSString *model=deviceModel.platformString;
    
    // NSString *model = [self platformString];
    if([model isEqualToString:@"iPhone 6 Plus"]||[model isEqualToString:@"iPhone 6 Plus"])
        self.view.transform =CGAffineTransformScale(CGAffineTransformIdentity, 1.25,1.25 );
    [self.navigationController setNavigationBarHidden:YES animated:NO];
   // self.uiType = LOGIN_SCREEN;
   // [appDelegate.stateMachineObj setCurrentUI:self];
    _initialHeight = self.view.frame.origin.y;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [super viewWillDisappear:animated];
}



-(void)keyboardWillAppear:(NSNotification *)note
{
    CGRect currentFrame = self.view.frame;
    CGRect newFrame = CGRectMake(currentFrame.origin.x, _initialHeight-150, currentFrame.size.width, currentFrame.size.height);
    CGFloat keyboardHeight = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGRect rectButton = self.cancelContinueView.frame;
    CGFloat height=rectButton.origin.y+rectButton.size.height;
    if(keyboardHeight<(height))
    {
        [UIView animateWithDuration:1.0 animations:^{
            self.view.frame = newFrame;
        }];
    }
}

-(void)keyboardWillDisappear:(NSNotification *)note
{
    CGRect currentFrame = self.view.frame;
    CGRect newFrame = CGRectMake(currentFrame.origin.x, _initialHeight, currentFrame.size.width, currentFrame.size.height);
    
    [UIView animateWithDuration:1.0 animations:^{
        self.view.frame = newFrame;
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

- (IBAction)haveOTPaction:(id)sender {
//    NSDate* now = [NSDate date];
//    NSNumber* currentTime = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
//    [appDelegate.confgReader setValidationTimer:currentTime];
    OTPValidationViewController* targetController = [[OTPValidationViewController alloc]initWithNibName:@"OTPValidationViewController" bundle:nil];
    targetController.otpViewDict=[NSMutableDictionary dictionaryWithDictionary:self.otpViewDict];
    targetController.verificationType = FORGOT_TYPE;
    targetController.fromAlreadyReceivedPassword=false;
    targetController.cameForFirstTimeRegistration=FALSE;
    targetController.mobileNumber=self.mobileNumber;
    [self.navigationController pushViewController:targetController animated:YES];
}
- (IBAction)cancelAction:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)continueAction:(id)sender {
    [self generateNewPwd:self.otpViewDict];
}
-(void)generateNewPwd:(NSMutableDictionary*)userDic
{
    NSMutableDictionary *generatePwdDic = [[NSMutableDictionary alloc] init];
    [generatePwdDic setValue:[userDic valueForKey:API_PHONE_NUM] forKey:API_LOGIN_ID];
    
    GenerateNewPwdAPI* api = [[GenerateNewPwdAPI alloc]initWithRequest:generatePwdDic];
    [self showProgressBar];
    [api callNetworkRequest:generatePwdDic withSuccess:^(GenerateNewPwdAPI *req, NSMutableDictionary *responseObject) {
        
        [self hideProgressBar];
        
        [appDelegate.confgReader setUserNumberForValidation:[userDic valueForKey:API_PHONE_NUM]];//txtField.text]];
        NSDate* now = [NSDate date];
        NSNumber* currentTime = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
        [appDelegate.confgReader setValidationTimer:currentTime];
        
       // [ScreenUtility showAlert:NSLocalizedString(@"VALIDATION_CALL", nil)];
        OTPValidationViewController* targetController = [[OTPValidationViewController alloc]initWithNibName:@"OTPValidationViewController" bundle:nil];
        targetController.otpViewDict=[NSMutableDictionary dictionaryWithDictionary:self.otpViewDict];
        targetController.verificationType = FORGOT_TYPE;
        targetController.fromAlreadyReceivedPassword=true;
        targetController.cameForFirstTimeRegistration=FALSE;
        targetController.mobileNumber=self.mobileNumber;
        
        [self.navigationController pushViewController:targetController animated:YES];
        
        
    } failure:^(GenerateNewPwdAPI *req, NSError *error) {
        [self hideProgressBar];
        NSInteger errorCode = error.code;
        NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
        if([errorMsg isEqualToString:@""])
        {
            [ScreenUtility showAlert:NSLocalizedString(@"INVALID_PHONE_NUMBER", nil)];
        }else if(errorCode == 86){
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
        }else if (errorCode == 91)
        {
            [ScreenUtility showAlert:ERROR_CODE_91];
        }
        else
        {
            [ScreenUtility showAlert: errorMsg];
        }
    }];
}




@end
