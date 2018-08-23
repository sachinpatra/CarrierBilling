//
//  VerifyScreen.m
//  InstaVoice
//
//  Created by EninovUser on 20/09/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "VerificationOTPViewController.h"
#import "ServerErrorMsg.h"
#import "HttpConstant.h"
#import "EventType.h"
#import "Common.h"
#import "Macro.h"
#import "LinkButton.h"
#import "SizeMacro.h"
#import "ScreenUtility.h"
#import "RegistrationApi.h"
#import "VerifyPasswordAPI.h"
#import "VerifyUserAPI.h"
#import "GenerateNewPwdAPI.h"
#import "RegenerateNewVeificationCodeAPI.h"
#import "ManageUserContactAPI.h"
#import "Profile.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"

#ifndef REACHME_APP
    #import "MyNotesScreen.h"
    #import "MyVoboloScreen.h"
    #import "ChatGridViewController.h"
#endif

//Linked Number Process
#ifdef REACHME_APP
#import "IVCarrierSearchViewController.h"
#import "IVCarrierCircleViewController.h"
#import "FetchCarriersListAPI.h"
#import "ActivateReachMeViewController.h"
#define kErrorCodeForCarrierListNotFound 20
#endif

#import "IVLinkedNumberVoiceMailViewController.h"

//Settings related
#import "IVSettingsListViewController.h"

#define FILETYPE           @"png"
#define NON_RETINA_IPHONE_HEIGHT  480

@interface VerificationOTPViewController () <GenderViewDelegate,ProfilePicViewDelegate,DateOfBirthViewDelegate,DatePickerViewDelegate,SettingProtocol>

#ifdef REACHME_APP
@property (nonatomic, strong) NSArray *currentCarrierList;
@property (nonatomic, strong) IVCarrierSearchViewController *carrierSearchViewController;
@property (nonatomic, strong) IVSettingsCountryCarrierInfo *selectedCountryCarrierInfo;
@property (nonatomic, strong) VoiceMailInfo *voiceMailInfo;
@property (nonatomic, strong) SettingModel *currentSettingsModel;
#endif

@end

@implementation VerificationOTPViewController
@synthesize verificationType,userID,fromSignUp;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        topView = nil;
        activeField = nil;
        validatePos = CGPointMake(SIZE_0, SIZE_0);
        verificationType = nil;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        topView = nil;
        activeField = nil;
        validatePos = CGPointMake(0, 0);
        verificationType = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    didNotRecieveSMSLabel.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ShowTimer)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ShowTimer)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    self.uiType = VERIFICATION_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    count = 1;
    selected = 0;       //Edited by Jatin
    
    UIImage *image = [UIImage imageNamed:@"app_logo"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
   secLbl.text = [Common getFormattedNumber:[NSString stringWithFormat:@"+%@",userID] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    if (fromSignUp) {
        [pinTextFiledFirst resignFirstResponder];
    }
     
    [super viewDidLoad];
    [self createTopView];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.uiType = VERIFICATION_SCREEN;
    didNotRecieveSMSLabel.hidden = NO;

    [[ConfigurationReader sharedConfgReaderObj] setOTPVerified:NO];
    [appDelegate.stateMachineObj setCurrentUI:self];
    [super viewWillAppear:animated];
 
//    self.navigationController.navigationBarHidden = YES;
//    [self.view addSubview:topView];
    
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    if (!fromSignUp) {
        [pinTextFiledFirst becomeFirstResponder];
    }
    [self ShowTimer];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [topView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setTheBottomSubView {
    genderView = [[GenderView alloc]initWithFrame:CGRectMake(20, 48-22, 280, 125)];
    genderView.delegate=self;
    dateOfBirthView = [[DateOfBirthView alloc]initWithFrame:CGRectMake(360, 48-22, 280, 125)];
    dateOfBirthView.delegate=self;
    profilePictureView = [[ProfilePicView alloc]initWithFrame:CGRectMake(360, 48-22, 280, 125)];
    profilePictureView.delegate=self;
    [bottomView addSubview:genderView];
    [bottomView addSubview:dateOfBirthView];
    [bottomView addSubview:profilePictureView];
}

- (void)setDatePicker {
    if(appDelegate.deviceHeight.height > NON_RETINA_IPHONE_HEIGHT)
    {
        datePicker = [[DatePickerView alloc] initWithFrame:CGRectMake(0, 289, 320, 260)];
    } else {
        datePicker = [[DatePickerView alloc] initWithFrame:CGRectMake(0, 202, 320, 260)];
    }
    datePicker.delegate = self;
    [self.view addSubview:datePicker];
    datePicker.hidden = YES;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


-(void)createLink
{
    CGSize constraintSize = CGSizeMake(SIZE_0, SIZE_0);;
    constraintSize.width  = DEVICE_WIDTH;
    constraintSize.height = SIZE_40;
    CGRect frme = regenVidateCodeLabl.frame;
    NSString *reqHere = NSLocalizedString(@"REQ_NEW_PIN", nil);
    
    //DC MAY 26 2016
    NSAttributedString *offsetAttributedString ;
    if (reqHere.length) {
        offsetAttributedString = [[NSAttributedString alloc]initWithString:reqHere  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:SIZE_12]}];
    }
    else
        offsetAttributedString = [[NSAttributedString alloc]initWithString:@""  attributes:@{NSFontAttributeName:@""}];
    CGRect offsetTextStringRect = [offsetAttributedString boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGSize offset = offsetTextStringRect.size;

    //CGSize offset = [reqHere sizeWithFont:[UIFont systemFontOfSize:SIZE_12] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    CGRect touFrme = CGRectMake((frme.origin.x+frme.size.width), frme.origin.y, offset.width, offset.height);
    LinkButton *request = [[LinkButton alloc] initWithFrame:touFrme red:COLOR30_255 green:COLOR144_255 blue:COLOR251_255 alpha:SIZE_1];
    
    [request setTitle:reqHere forState:UIControlStateNormal];
    [request setTitleColor:[[UIColor alloc]initWithRed:COLOR30_255 green:COLOR144_255 blue:COLOR251_255 alpha:SIZE_1] forState:UIControlStateNormal];
    
    request.titleLabel.font = [UIFont systemFontOfSize:SIZE_12];
    [request addTarget:self action:@selector(reqNewPinAction)forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:request];
}


#pragma mark - create top view
-(void)createTopView
{
}

#pragma mark -  button's action

-(IBAction)reqNewPinAction:(id)sender
{
    if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    if([verificationType isEqualToString:REGISTER_TYPE])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:PHONE_MODE forKey:LOGIN_MODE];
        [self reGenVerifyCode:dic];
    }
    else if([verificationType isEqualToString:MANAGE_USER_CONTACT_TYPE]){
        [self reGenVerificationCodeForSecondaryNumber];
    }else
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setValue:self.userID forKey:USER_ID];
        [self generateNewPwd:dic];
    }
    //[self showProgressBar];
}

-(void)reGenVerificationCodeForSecondaryNumber
{
    NSMutableDictionary *verifyCodeDic = [[NSMutableDictionary alloc] init];
    
    [verifyCodeDic setValue:userID forKey:@"contact"];
    [verifyCodeDic setValue:@"p" forKey:@"contact_type"];
    [verifyCodeDic setValue:_countryCode forKey:@"country_code"];
    [verifyCodeDic setValue:@"r" forKey:@"operation"];
    [verifyCodeDic setValue:[NSNumber numberWithBool:NO] forKey:@"set_as_primary"];
    [verifyCodeDic setValue:@"obd" forKey:SEND_PIN_BY];
    
    ManageUserContactAPI* api = [[ManageUserContactAPI alloc]initWithRequest:verifyCodeDic];
    [self showProgressBar];
    [api callNetworkRequest:verifyCodeDic withSuccess:^(ManageUserContactAPI *req, NSMutableDictionary *responseObject) {
        [self hideProgressBar];
        NSDate* now = [NSDate date];
        NSNumber* currentTime = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
        [appDelegate.confgReader setValidationTimer:currentTime];
        [self ShowTimer];
        //FEB 20, 2018 [ScreenUtility showAlert:NSLocalizedString(@"VALIDATION_CALL", nil)];
        [self showAlert:NSLocalizedString(@"VALIDATION_CALL", nil)];
    } failure:^(ManageUserContactAPI *req, NSError *error) {
        [self hideProgressBar];
        NSInteger errorCode = error.code;
        NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
        [ScreenUtility showAlert: errorMsg];
    }];
}

-(void)generateNewPwd:(NSMutableDictionary*)userDic
{
    NSMutableDictionary *generatePwdDic = [[NSMutableDictionary alloc] init];
    [generatePwdDic setValue:[userDic valueForKey:USER_ID] forKey:API_LOGIN_ID];
    [generatePwdDic setValue:@"obd" forKey:SEND_PIN_BY];
    
    GenerateNewPwdAPI* api = [[GenerateNewPwdAPI alloc]initWithRequest:generatePwdDic];
    [self showProgressBar];
    [api callNetworkRequest:generatePwdDic withSuccess:^(GenerateNewPwdAPI *req, NSMutableDictionary *responseObject) {
        [appDelegate.confgReader setUserNumberForValidation:[userDic valueForKey:USER_ID]];
        [self hideProgressBar];
        NSDate* now = [NSDate date];
        NSNumber* currentTime = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
        [appDelegate.confgReader setValidationTimer:currentTime];
        [self ShowTimer];

        //FEB 20, 2018 [ScreenUtility showAlert:NSLocalizedString(@"VALIDATION_CALL", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"VALIDATION_CALL", nil)];
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
        }
        else
        {
            [ScreenUtility showAlert: errorMsg];
        }
    }];
}

-(void)reGenVerifyCode:(NSMutableDictionary*)userDic
{
    NSMutableDictionary *verifyCodeDic = [[NSMutableDictionary alloc] init];
    NSString *regSecureKey = [appDelegate.confgReader getRegSecureKey];
    if( regSecureKey != nil || [regSecureKey length]>0)
    {
        [verifyCodeDic setValue:regSecureKey forKey:API_REG_SECURE_KEY];
    }
    if([[userDic valueForKey:LOGIN_MODE] isEqualToString:PHONE_MODE])
    {
        NSString *mccmnc = [appDelegate.confgReader getCountryMCCMNC];
        if(mccmnc != nil && [mccmnc length] >0)
        {
            [verifyCodeDic setValue:mccmnc forKey:API_SIM_OPR_MCC_MNC];
        }
        else
        {
           // [verifyCodeDic setValue:@"na" forKey:API_SIM_OPR_MCC_MNC];
        }
    }
    
    [verifyCodeDic setValue:@"obd" forKey:SEND_PIN_BY];
    
    RegenerateNewVeificationCodeAPI* api = [[RegenerateNewVeificationCodeAPI alloc]initWithRequest:verifyCodeDic];
    [self showProgressBar];
    [api callNetworkRequest:verifyCodeDic withSuccess:^(RegenerateNewVeificationCodeAPI *req, NSMutableDictionary *responseObject) {
        [self hideProgressBar];
        NSDate* now = [NSDate date];
        NSNumber* currentTime = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
        [appDelegate.confgReader setValidationTimer:currentTime];
        [self ShowTimer];
        //[ScreenUtility showAlert:NSLocalizedString(@"VALIDATION_CALL", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"VALIDATION_CALL", nil)];
    } failure:^(RegenerateNewVeificationCodeAPI *req, NSError *error) {
        [self hideProgressBar];
        NSInteger errorCode = error.code;
        NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
        [ScreenUtility showAlert: errorMsg];
        
    }];
    
}

-(IBAction)backAction
{
    [appDelegate.time invalidate];
    //TODO: Check - should it be commented or not.
    //[topView removeFromSuperview];
#ifndef REACHME_APP
    NSString *currentNonVerifiedNumber = [userID stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [self.delegate addingNonVerifiedNumber:currentNonVerifiedNumber withcountrycode:_countryCode];
    [self.delegate updateAdditionalNumbers];
#endif
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)validatioAction:(id)sender
{
    if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE)
    {
        //OCT 4, 2016 [ScreenUtility showAlert: NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    NSString *pinCode;
    if( (pinTextFiledFirst.text != nil) && ([pinTextFiledFirst.text length] > 0) )
    {
        pinCode = [NSString stringWithString:pinTextFiledFirst.text];
        
    }
    else
    {
        [ScreenUtility showAlert: NSLocalizedString(@"ENTER_PIN", nil)];
        return;
    }
    if( (pinTextFiledFirst.text != nil) && ([pinTextFiledFirst.text length] > 0) )
    {
        pinCode = [pinCode stringByAppendingString:pinTextFiledSecond.text];
    }
    else
    {
        [ScreenUtility showAlert: NSLocalizedString(@"ENTER_PIN", nil)];
        return;
        
    }
    if( (pinTextFiledFirst.text != nil) && ([pinTextFiledFirst.text length] > 0) )
    {
        pinCode = [pinCode stringByAppendingString:pinTextFiledThird.text];
    }
    else
    {
        [ScreenUtility showAlert: NSLocalizedString(@"ENTER_PIN", nil)];
        return;
        
    }
    if( (pinTextFiledFirst.text != nil) && ([pinTextFiledFirst.text length] > 0) )
    {
        pinCode = [pinCode stringByAppendingString:pinTextFiledFourth.text];
    }
    else
    {
        [ScreenUtility showAlert: NSLocalizedString(@"ENTER_PIN", nil)];
        return;
        
    }
    
    NSMutableDictionary *userDic = [[NSMutableDictionary alloc]init];
    
    [userDic setValue:pinCode forKey:VERIFY_PIN];
    [userDic setValue:self.userID forKey:USER_ID];
    
    if(verificationType != nil && [verificationType length] > 0)
    {
        if([verificationType isEqualToString:REGISTER_TYPE])
        {
            [self verifyUser:userDic];
        }
        else if([verificationType isEqualToString:MANAGE_USER_CONTACT_TYPE])
        {
            [self verifyUserContact:userDic];
        }
        else
        {
            [self verifyPassword:userDic];
        }
    }
    [activeField resignFirstResponder];
    
    //[self showProgressBar];
}

-(void)verifyUser:(NSMutableDictionary*)userDic
{
    NSMutableDictionary *verifyUserDic = nil;
    if(userDic != nil && [userDic count]>0)
    {
        verifyUserDic = [[NSMutableDictionary alloc] init];
        
        [verifyUserDic setValue:[appDelegate.confgReader getRegSecureKey] forKey:API_REG_SECURE_KEY];
        [verifyUserDic setValue:[userDic valueForKey:VERIFY_PIN] forKey:API_PIN];
        [verifyUserDic setValue:[appDelegate.confgReader getCloudSecureKey] forKey:API_CLOUD_SECURE_KEY];
        
        VerifyUserAPI* api = [[VerifyUserAPI alloc]initWithRequest:verifyUserDic];
        [self showProgressBar];
        [api callNetworkRequest:verifyUserDic withSuccess:^(VerifyUserAPI *req, NSMutableDictionary *responseObject) {
            [self hideProgressBar];
            [[ConfigurationReader sharedConfgReaderObj] setOTPVerified:YES];
            [appDelegate.time invalidate];
            [self createMainTabBarItems];
            
        } failure:^(VerifyUserAPI *req, NSError *error) {
            [self hideProgressBar];
            NSInteger errorCode = error.code;
            NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
            if([errorMsg isEqualToString:@""])
            {
                [ScreenUtility showAlert:NSLocalizedString(@"INVALID_PIN", nil)];
                pinTextFiledFirst.text=@"";
                pinTextFiledSecond.text=@"";
                pinTextFiledThird.text=@"";
                pinTextFiledFourth.text=@"";
                [pinTextFiledFirst becomeFirstResponder];
            }
            else
            {
                [ScreenUtility showAlert: errorMsg];
                pinTextFiledFirst.text=@"";
                pinTextFiledSecond.text=@"";
                pinTextFiledThird.text=@"";
                pinTextFiledFourth.text=@"";
                [pinTextFiledFirst becomeFirstResponder];
            }
        }];
    }
}

- (void) createMainTabBarItems
{
    //Bhaskar 2017 Dec
    [appDelegate createTabBarControllerItems];
    return;
}

-(void)verifyPassword:(NSMutableDictionary*)userDic
{
    if(userDic != nil && [userDic count] >0)
    {
        NSMutableDictionary *verifyPwdDic = [[NSMutableDictionary alloc] init];
        NSString *uuid = [appDelegate.confgReader getDeviceUUID];
        if(uuid == nil || [uuid length]==0)
        {
            uuid = [Common getUniqueDeviceID];
            [appDelegate.confgReader setDeviceUUID:uuid];
        }
        [verifyPwdDic setValue:uuid forKey:API_DEVICE_ID];
        [verifyPwdDic setValue:[userDic valueForKey:VERIFY_PIN] forKey:API_PWD];
        [verifyPwdDic setValue:[userDic valueForKey:USER_ID] forKey:API_LOGIN_ID];
        
        VerifyPasswordAPI* api = [[VerifyPasswordAPI alloc]initWithRequest:verifyPwdDic];
        [self showProgressBar];
        [api callNetworkRequest:verifyPwdDic withSuccess:^(VerifyPasswordAPI *req, NSMutableDictionary *responseObject) {
            [self hideProgressBar];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            UIViewController *nextController = [storyBoard instantiateViewControllerWithIdentifier:@"ResetPwd"];
            [self.navigationController pushViewController:nextController animated:YES];
        } failure:^(VerifyPasswordAPI *req, NSError *error) {
            [self hideProgressBar];
            NSInteger errorCode = error.code;
            NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
            if([errorMsg isEqualToString:@""])
            {
                [ScreenUtility showAlert:NSLocalizedString(@"INVALID_PIN", nil)];
                
                pinTextFiledFirst.text=@"";
                pinTextFiledSecond.text=@"";
                pinTextFiledThird.text=@"";
                pinTextFiledFourth.text=@"";
               [pinTextFiledFirst becomeFirstResponder];
            }
            else
            {
                [ScreenUtility showAlert: errorMsg];
                pinTextFiledFirst.text=@"";
                pinTextFiledSecond.text=@"";
                pinTextFiledThird.text=@"";
                pinTextFiledFourth.text=@"";
                [pinTextFiledFirst becomeFirstResponder];
            }
        }];
    }
}

-(void)verifyUserContact:(NSMutableDictionary*)userDic{
    if( [Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        //OCT 13, 2016 [ScreenUtility showAlert:@"Network is not connected."];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    NSMutableDictionary *userList = [[NSMutableDictionary alloc]init];
    [userList setValue:userID forKey:@"contact"];
    [userList setValue:@"p" forKey:@"contact_type"];
    [userList setValue:_countryCode forKey:@"country_code"];
    [userList setValue:@"v" forKey:@"operation"];
    
    [userList setValue:[NSNumber numberWithBool:NO] forKey:@"set_as_primary"];
    [userList setValue:[userDic valueForKey:VERIFY_PIN] forKey:@"validation_code"];
    
    ManageUserContactAPI* api = [[ManageUserContactAPI alloc]initWithRequest:userList];
    [self showProgressBar];
    [api callNetworkRequest:userList withSuccess:^(ManageUserContactAPI *req, NSMutableDictionary *responseObject) {
        if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
            [self hideProgressBar];
            [[ConfigurationReader sharedConfgReaderObj] setOTPVerified:YES];
            EnLogd(@"Error blocking the user userlist %@ and api request %@",userList,api.request);
            NSArray *userContacts = [responseObject valueForKey:@"user_contacts"];
            UserProfileModel *model = [[Profile sharedUserProfile]profileData];
            NSMutableArray *additionalNonVerifiedNumbers = [model.additionalNonVerifiedNumbers mutableCopy];
            NSMutableArray *additionalVerifiedNumbers = [model.additionalVerifiedNumbers mutableCopy];
            
            for (int i=0; i<[userContacts count]; i++) {
                NSDictionary *userContact = [userContacts objectAtIndex:i];
                if([[userContact valueForKey:@"contact_type"] isEqualToString:@"p"]){
                    int isPrimary = [[userContact valueForKey:@"is_primary"] intValue];
                    
                     NSArray *filteredNonverifiedNumbers = [additionalNonVerifiedNumbers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_id = %@",[userContact valueForKey:@"contact_id"]]];
                    
                    if(isPrimary == 1){
                        if(([filteredNonverifiedNumbers count] == 0) && (![additionalVerifiedNumbers containsObject:[userContact valueForKey:@"contact_id"]])){
                            NSDictionary *newNonVerifiedNumber = @{
                                                                   @"contact_id" : [userContact valueForKey:@"contact_id"],
                                                                   @"country_code" : _countryCode,
                                                                   };
                            //Its primary number - update the login id
                            [[ConfigurationReader sharedConfgReaderObj]setLoginId:newNonVerifiedNumber[@"contact_id"]];
                            [additionalNonVerifiedNumbers insertObject:newNonVerifiedNumber atIndex:0];
                        }
                    }else{
                            if(([filteredNonverifiedNumbers count] == 0) && (![additionalVerifiedNumbers containsObject:[userContact valueForKey:@"contact_id"]])){
                               
                                NSDictionary *newNonVerifiedNumber = @{
                                                                       @"contact_id" : [userContact valueForKey:@"contact_id"],
                                                                       @"country_code" : _countryCode,
                                                                       };
                                [additionalNonVerifiedNumbers addObject:newNonVerifiedNumber];
                            }
                    }
                }
            }
            model.additionalVerifiedNumbers = additionalVerifiedNumbers;
            model.additionalNonVerifiedNumbers = additionalNonVerifiedNumbers;
            [[Profile sharedUserProfile]writeProfileDataInFile];
        } else {
            //- Delete all the chats, if any, from DB for this secondary number added.
            NSArray* userIdList = [[NSArray alloc]initWithObjects:userID, nil];
            [appDelegate.engObj deleteAllChats:userIdList];
            
            NSArray *userContacts = [responseObject valueForKey:@"user_contacts"];
            UserProfileModel *model = [[Profile sharedUserProfile]profileData];
            NSMutableArray *additionalNonVerifiedNumbers = [model.additionalNonVerifiedNumbers mutableCopy];
            NSMutableArray *additionalVerifiedNumbers = [model.additionalVerifiedNumbers mutableCopy];
            NSArray *verifiedNumbersInProfileData = [model.additionalVerifiedNumbers valueForKeyPath:@"contact_id"];
            
            for (int i=0; i<[userContacts count]; i++) {
                NSDictionary *userContact = [userContacts objectAtIndex:i];
                if([[userContact valueForKey:@"contact_type"] isEqualToString:@"p"]){
                    int isPrimary = [[userContact valueForKey:@"is_primary"] intValue];
                    NSDictionary *verifiedNumber = @{
                                                     @"contact_id" : [userContact valueForKey:@"contact_id"],
                                                     @"country_code" : _countryCode,
                                                     @"is_primary" : [userContact valueForKey:@"is_primary"],
                                                     @"is_virtual" : [userContact valueForKey:@"is_virtual"]
                                                     };

                    if(isPrimary == 1){
                        if(![verifiedNumbersInProfileData containsObject:[userContact valueForKey:@"contact_id"]]){
                            //Its primary number - update the login id
                            [[ConfigurationReader sharedConfgReaderObj]setLoginId:verifiedNumber[@"contact_id"]];
                            [additionalVerifiedNumbers insertObject:verifiedNumber atIndex:0];
                        }
                    }else{
                       if(![verifiedNumbersInProfileData containsObject:[userContact valueForKey:@"contact_id"]]){
                             [additionalVerifiedNumbers addObject:verifiedNumber];
                        }
                    }

                    NSArray *filtered = [additionalNonVerifiedNumbers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_id = %@",[userContact valueForKey:@"contact_id"]]];
                    
                    if([filtered count] != 0){
                        [additionalNonVerifiedNumbers removeObjectsInArray:filtered];
                    }
                }
            }
            model.additionalVerifiedNumbers = additionalVerifiedNumbers;
            model.additionalNonVerifiedNumbers = additionalNonVerifiedNumbers;
            
            [[Profile sharedUserProfile]writeProfileDataInFile];
            
            [self.delegate updateAdditionalNumbers];
            [[ConfigurationReader sharedConfgReaderObj] setOTPVerified:YES];
            [[ConfigurationReader sharedConfgReaderObj] setOTPVerifiedNumber:userID];
            //Update is successful. We are in need of latest settings data - initiate the settings data fetch.
            [[Setting sharedSetting]resetFetchAndUpdateStatus];
            [[Setting sharedSetting]getUserSettingFromServer];
            
            [self performSelector:@selector(processLinkedNumber) withObject:nil afterDelay:1.0];
            
        }
    } failure:^(ManageUserContactAPI *req, NSError *error) {
        [self hideProgressBar];
        EnLogd(@"Error blocking the user: %@, Error",userList,[error description]);
        NSInteger errorCode = error.code;
        NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
        if(errorCode == 34){
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Call me"];
            
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1]
                                     range:NSMakeRange(0, [@"Call me" length])];
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [@"Call me" length])];
            [reqPinBtn setAttributedTitle:attributedString forState:UIControlStateNormal];
            reqPinBtn.userInteractionEnabled = YES;
            timerLabel.text = [NSString stringWithFormat:@"00:00"];
            [reqPinBtn setEnabled:YES];
        }
        if([errorMsg length])
        {
            [ScreenUtility showAlertMessage: errorMsg];
            pinTextFiledFirst.text=@"";
            pinTextFiledSecond.text=@"";
            pinTextFiledThird.text=@"";
            pinTextFiledFourth.text=@"";
            [pinTextFiledFirst becomeFirstResponder];
        }
        
        UserProfileModel *model = [[Profile sharedUserProfile]profileData];
        NSMutableArray *additionalNonVerifiedNumbers = [model.additionalNonVerifiedNumbers mutableCopy];
        NSDictionary *newNonVerifiedNumber = @{
                                               @"contact_id" : userID,
                                               @"country_code" : _countryCode,
                                               };
        
        NSArray *filteredNonverifiedNumbers = [additionalNonVerifiedNumbers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_id = %@",userID]];
        
        if([filteredNonverifiedNumbers count] == 0)
        {
            [additionalNonVerifiedNumbers addObject:newNonVerifiedNumber];
        }
        
        model.additionalNonVerifiedNumbers = additionalNonVerifiedNumbers;
        
        [[Profile sharedUserProfile]writeProfileDataInFile];
        [self.delegate updateAdditionalNumbers];
    }];
}


-(void)processLinkedNumber
{
    [self hideProgressBar];
    [ScreenUtility showAlertMessage:@"Number linked successfully"];
    
#ifdef REACHME_APP
    [Setting sharedSetting].delegate = self;
    [[Setting sharedSetting] getUserSettingFromServer];
#endif
    
#ifndef REACHME_APP
    [self.navigationController popViewControllerAnimated:YES];
#endif
    
}

#ifdef REACHME_APP
- (void)fetchSettingCompletedWith:(SettingModel*)modelData withFetchStatus:(BOOL)withFetchStatus {
    
    //Settings has been updated successfully, update the UI.
    if (withFetchStatus) {
        //Determine the network name from the network ID.
        [self loadLatestDataFromServer];
        if (!self.voiceMailInfo || !self.voiceMailInfo.countryVoicemailSupport) {
            //ActivateReachMe
            ActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ActivateReachMe"];
            activateReachMe.phoneNumber = userID;
            activateReachMe.isPrimaryNumber = NO;
            activateReachMe.voiceMailInfo = self.voiceMailInfo;
            [self.navigationController pushViewController:activateReachMe animated:YES];
            return;
        }
        
        CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:userID];
        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: userID];
        if (carrierInfo && carrierDetails) {
            //ActivateReachMe
            ActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ActivateReachMe"];
            activateReachMe.phoneNumber = userID;
            activateReachMe.isPrimaryNumber = NO;
            activateReachMe.voiceMailInfo = self.voiceMailInfo;
            [self.navigationController pushViewController:activateReachMe animated:YES];
            return;
        }
        
        NSArray *listOfCarriers = [[Setting sharedSetting]carrierListForCountry:self.voiceMailInfo.carrierCountryCode];
        if (listOfCarriers && [listOfCarriers count]) {
            //We have list of carriers.
            self.currentCarrierList = listOfCarriers;
            [self selectCarrier];
        }
        else {
            self.currentCarrierList = nil;
            //We do not have list of carriers - so start fetching list of carriers for the country.
            [[Setting sharedSetting]fetchListOfCarriersForCountry:self.voiceMailInfo.carrierCountryCode];
        }
    }
}

- (void)fetchListOfCarriersForCountry:(SettingModel *)modelData withFetchStatus:(BOOL)withFetchStatus {
    
    //hide loading Indicator
    [self hideProgressBar];
    
    //NOV 24, 2016
    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    //
    
    if (withFetchStatus) {
        NSArray *listOfCarriers = [[Setting sharedSetting]carrierListForCountry:self.voiceMailInfo.carrierCountryCode];
        self.currentCarrierList = listOfCarriers;
        [self selectCarrier];
    }
}

- (void)loadLatestDataFromServer {
    
    KLog(@"loadLatestDataFromServer");
    
    self.currentSettingsModel = [Setting sharedSetting].data;
    if (self.currentSettingsModel) {
        if (self.currentSettingsModel.voiceMailInfo && [self.currentSettingsModel.voiceMailInfo count]) {
            for (VoiceMailInfo *voiceMailInfo in self.currentSettingsModel.voiceMailInfo) {
                if([voiceMailInfo.phoneNumber isEqualToString:userID]) {
                    self.voiceMailInfo = voiceMailInfo;
                }
            }
            
        }
    }
}

- (void)selectCarrier
{
    if ([self.voiceMailInfo.carrierCountryCode isEqualToString:@"091"]) {
        IVCarrierCircleViewController *selectCircle = [[IVCarrierCircleViewController alloc]initWithNibName:@"IVCarrierCircleViewController" bundle:nil];
        selectCircle.carrierList = self.currentCarrierList;
        [self.navigationController pushViewController:selectCircle animated:YES];
        return;
    }
    
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        if(self.currentCarrierList && self.currentCarrierList.count) {
            if (!self.carrierSearchViewController) {
                self.carrierSearchViewController = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"IVCarrierSearchView"];
            }
            
            if (![self.navigationController.topViewController isKindOfClass:[IVCarrierSearchViewController class]]) {
                self.carrierSearchViewController.carrierList = self.currentCarrierList;
                self.carrierSearchViewController.voiceMailInfo = self.voiceMailInfo;
                self.carrierSearchViewController.selectedCountryCarrierInfo = self.selectedCountryCarrierInfo;
                [self.navigationController pushViewController:self.carrierSearchViewController animated:YES];
                return;
            }
        }
        else
            //Fetch the carrier list.
            [self retrieveCarrierDetails];
    }else{
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}


- (void)retrieveCarrierDetails {
    
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    if (self.voiceMailInfo) {
        
        NSMutableDictionary *requestData = [[NSMutableDictionary alloc]init];
        if(self.voiceMailInfo.carrierCountryCode) {
            //[self showLoadingIndicator];
            [requestData setObject:self.voiceMailInfo.carrierCountryCode forKey:@"country_code"];
            [requestData setValue:[NSNumber numberWithBool:1] forKey:@"fetch_voicemails_info"]; //NOV 16, 2016
            FetchCarriersListAPI* fetchCarrierListRequest = [[FetchCarriersListAPI alloc]initWithRequest:requestData];
            
            [fetchCarrierListRequest callNetworkRequest:requestData withSuccess:^(FetchCarriersListAPI *req, NSMutableDictionary *responseObject) {
                
                //Hide the loading indicator
                //[self hideLoadingIndicator];
                self.currentCarrierList = responseObject[@"country_list"];
                
                //Reload Data - Current Network Name and reload the tableView.
                //[self reloadData];
                //[self redirectToAppropriateVoiceMailSettingsView];
                
            } failure:^(FetchCarriersListAPI *req, NSError *error) {
                KLog(@"Failure in fetching carrier list");
                //Hide the loading indicator
                //[self hideLoadingIndicator];
                
                NSInteger errorCode = 0;
                NSString *errorReason;
                if (error.userInfo) {
                    errorCode = [error.userInfo[@"error_code"]integerValue];
                    errorReason = error.userInfo[@"error_reason"];
                }
                if (kErrorCodeForCarrierListNotFound == errorCode)
                    [ScreenUtility showAlert:errorReason];
            }];
        }
    }
}
#endif

#pragma mark - UITextField's delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = textField.text;//[textField.text stringByReplacingCharactersInRange:range withString:string];
    if((newString == nil || [newString length]==0) || (string == nil || string.length ==0))
    {
        newString = string;
    }
    
    if(textField == pinTextFiledFirst)
    {
        
        if(newString.length == 1 )
        {
            pinTextFiledFirst.text = newString;
            [pinTextFiledSecond becomeFirstResponder];
        }
        else
        {
            pinTextFiledFirst.text = @"";
        }
    }
    else if(textField == pinTextFiledSecond)
    {
        if(newString.length == 1 )
        {
            
            pinTextFiledSecond.text = newString;
            [pinTextFiledThird becomeFirstResponder];
        }
        else
        {
            pinTextFiledSecond.text = @"";
            [pinTextFiledFirst becomeFirstResponder];
        }
    }
    else if(textField == pinTextFiledThird)
    {
        if(newString.length == 1 )
        {
            pinTextFiledThird.text = newString;
            [pinTextFiledFourth becomeFirstResponder];
        }
        else
        {
            pinTextFiledThird.text = @"";
            [pinTextFiledSecond becomeFirstResponder];
        }
    }
    else if(textField == pinTextFiledFourth)
    {
        if(newString.length ==1 )
        {
            pinTextFiledFourth.text = newString;
            [pinTextFiledFourth resignFirstResponder];
            
        }
        else
        {
            pinTextFiledFourth.text = @"";
            [pinTextFiledThird becomeFirstResponder];
        }
    }
    
    return NO;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    /*
     if(textField == pinTextFiledFirst)
     {
     pinTextFiledFirst.backgroundColor = [[UIColor alloc] initWithRed:COLOR182_255 green:COLOR183_255 blue:COLOR183_255 alpha:SIZE_1];
     pinTextFiledSecond.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     pinTextFiledThird.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     pinTextFiledFourth.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     }
     else if(textField == pinTextFiledSecond)
     {
     pinTextFiledSecond.backgroundColor = [[UIColor alloc] initWithRed:COLOR182_255 green:COLOR183_255 blue:COLOR183_255 alpha:SIZE_1];
     pinTextFiledFirst.backgroundColor =[[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     pinTextFiledThird.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     pinTextFiledFourth.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     }
     else if(textField == pinTextFiledThird)
     {
     pinTextFiledThird.backgroundColor = [[UIColor alloc] initWithRed:COLOR182_255 green:COLOR183_255 blue:COLOR183_255 alpha:SIZE_1];
     pinTextFiledFirst.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     pinTextFiledSecond.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     pinTextFiledFourth.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     }
     else if(textField == pinTextFiledFourth)
     {
     pinTextFiledFourth.backgroundColor = [[UIColor alloc] initWithRed:COLOR182_255 green:COLOR183_255 blue:COLOR183_255 alpha:SIZE_1];
     pinTextFiledFirst.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     pinTextFiledSecond.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     pinTextFiledThird.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     }
     */
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    /*
     if(textField == pinTextFiledFourth)
     {
     pinTextFiledFourth.backgroundColor =  [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     pinTextFiledFirst.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     pinTextFiledSecond.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     pinTextFiledThird.backgroundColor = [[UIColor alloc] initWithRed:COLOR216_255 green:COLOR220_255 blue:COLOR220_255 alpha:SIZE_1];
     }
     */
}

-(void)setContentForiOS7
{
    CGRect validateBtnRect = validateBtn.frame;
    validateBtn.frame = CGRectMake(validateBtnRect.origin.x, validateBtnRect.origin.y+16, validateBtnRect.size.width, validateBtnRect.size.height);
    
    CGRect pinTextFiledFirstRect = pinTextFiledFirst.frame;
    pinTextFiledFirst.frame = CGRectMake(pinTextFiledFirstRect.origin.x, pinTextFiledFirstRect.origin.y+16, pinTextFiledFirstRect.size.width, pinTextFiledFirstRect.size.height);
    CGRect pinTextFiledSecondRect = pinTextFiledSecond.frame;
    pinTextFiledSecond.frame = CGRectMake(pinTextFiledSecondRect.origin.x, pinTextFiledSecondRect.origin.y+16, pinTextFiledSecondRect.size.width, pinTextFiledSecondRect.size.height);
    CGRect pinTextFiledThirdRect = pinTextFiledThird.frame;
    pinTextFiledThird.frame = CGRectMake(pinTextFiledThirdRect.origin.x, pinTextFiledThirdRect.origin.y+16, pinTextFiledThirdRect.size.width, pinTextFiledThirdRect.size.height);
    CGRect pinTextFiledFourthRect = pinTextFiledFourth.frame;
    pinTextFiledFourth.frame = CGRectMake(pinTextFiledFourthRect.origin.x, pinTextFiledFourthRect.origin.y+16, pinTextFiledFourthRect.size.width, pinTextFiledFourthRect.size.height);
    CGRect regenVidateCodeLablRect = regenVidateCodeLabl.frame;
    regenVidateCodeLabl.frame = CGRectMake(regenVidateCodeLablRect.origin.x, regenVidateCodeLablRect.origin.y+16, regenVidateCodeLablRect.size.width, regenVidateCodeLablRect.size.height);
    CGRect reqPinBtnRect = reqPinBtn.frame;
    reqPinBtn.frame = CGRectMake(reqPinBtnRect.origin.x, reqPinBtnRect.origin.y+16, reqPinBtnRect.size.width, reqPinBtnRect.size.height);
    CGRect firstLblRect = firstLbl.frame;
    firstLbl.frame = CGRectMake(firstLblRect.origin.x, firstLblRect.origin.y+16, firstLblRect.size.width, firstLblRect.size.height);
    CGRect secLblRect = secLbl.frame;
    secLbl.frame = CGRectMake(secLblRect.origin.x, secLblRect.origin.y+16, secLblRect.size.width, secLblRect.size.height);
    
}
/**New ui implementation**/


-(IBAction)nextButtonAction {
    /* CMP SEP
    if(count == 1) {
        count = 2;
        [self animationEffect:genderView newview:dateOfBirthView ];
    }
    else if(count == 2) {
        count = 3;
        [self animationEffect:dateOfBirthView newview:profilePictureView ];
    } else {
        [self animationEffect:bottomView newview:nil ];
        bottomView.hidden = YES;
    }
    
    [nextOrSkipButton setTitle:@"Skip" forState:UIControlStateNormal];
     */
}

- (void)animationEffect:(UIView *)oldView newview:(UIView *)newView {
    [UIView animateWithDuration:1
                     animations:^{
                         oldView.frame=CGRectMake(-360.0, oldView.frame.origin.y, oldView.frame.size.width, oldView.frame.size.height);
                         newView.frame=CGRectMake(20.0, oldView.frame.origin.y, newView.frame.size.width, newView.frame.size.height);
                     }];
}


-(void) profilePickerController:(ProfilePicView*)view withImagePicker:(UIImagePickerController*)imagePickerView {
    selected = 1;
    [self presentViewController:imagePickerView animated:NO completion:nil];
    [nextOrSkipButton setTitle:@"Save" forState:UIControlStateNormal];
}

-(void) profilePickerController:(NSString*)selectedOrCancelled
{
    if (selected==0)
    {
        [nextOrSkipButton setTitle:selectedOrCancelled forState:UIControlStateNormal];
    }else
    {
        [nextOrSkipButton setTitle:@"Save" forState:UIControlStateNormal];
    }
}   //Edited by Jatin


-(void)genderView:(GenderView *)view didSelectGender:(NSString *)gender
{
    [appDelegate.confgReader setUserGender:gender];
    [nextOrSkipButton setTitle:@"Next" forState:UIControlStateNormal];
}

-(void) dateOfBirth:(DateOfBirthView*)view {
    [self setDatePicker];
    datePicker.hidden = NO;
    [nextOrSkipButton setTitle:@"Next" forState:UIControlStateNormal];
}

-(void) datePickerController:(DatePickerView*)view withDateString:(NSString *)dateString withDate:(NSDate *)dateValue withError:(bool)error{
    if(error) {
        [ScreenUtility showAlert: @"You must be atleast 13 year old to use InstaVoice"];
    } else {
        dateOfBirthView.dateShowLabel.text = dateString;
        
        //Commented by Vinoth for VinothtimeIntervalSince1970
        //NSNumber* dateOfBirth = [NSNumber numberWithDouble:[dateValue timeIntervalSince1970]];
        NSNumber* dateOfBirth = [NSNumber numberWithDouble:[dateValue timeIntervalSinceDate:IVDOBreferenceDate]];

        
        [appDelegate.confgReader setUserDob: dateOfBirth];
    }
}

-(void) pathToSendTheFile:(NSString *)path {
    [appDelegate.confgReader setUserProfilePicPath:path];
}

- (void)ShowTimer {
    NSDate* now = [NSDate date];
    [appDelegate.time invalidate];
    NSNumber* currentTime = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
    //    if([appDelegate.confgReader getValidationTimer] == nil) {
    //        [appDelegate.confgReader setValidationTimer:currentTime];
    //        timeToShow = MAX_TIME_ON_VARIFICATION_SCREEN;
    //    }
    long int time = [[appDelegate.confgReader getValidationTimer]intValue];
    long int timeLeft = [currentTime intValue] - time;
    if (timeLeft <= MAX_TIME_ON_VARIFICATION_SCREEN) {
        //[reqPinBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Call me"];
        
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor lightGrayColor]
                                 range:NSMakeRange(0, [@"Call me" length])];
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [@"Call me" length])];
        [reqPinBtn setAttributedTitle:attributedString forState:UIControlStateNormal];
        
        timeToShow = MAX_TIME_ON_VARIFICATION_SCREEN -  (int)timeLeft;
        reqPinBtn.userInteractionEnabled = NO;
        [reqPinBtn setEnabled:NO];
        appDelegate.time = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCountDown) userInfo:nil repeats:YES];
        
    }else {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Call me"];
        
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1]
                                 range:NSMakeRange(0, [@"Call me" length])];
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [@"Call me" length])];
        [reqPinBtn setAttributedTitle:attributedString forState:UIControlStateNormal];
        reqPinBtn.userInteractionEnabled = YES;
        timerLabel.text = [NSString stringWithFormat:@"00:00"];
        [reqPinBtn setEnabled:YES];
    }
    
    
}

- (void)timerCountDown
{
    if(timeToShow > 0 ) {
        timeToShow -- ;
        
        int minutes = timeToShow / 60;
        int seconds = timeToShow % 60;
        //timerLabel.text = [NSString stringWithFormat:@"%d%d:%d",0,minutes,seconds];
        if(seconds < 10)
            timerLabel.text = [NSString stringWithFormat:@"%d%d:%d%d",0,minutes,0,seconds];
        else
            timerLabel.text = [NSString stringWithFormat:@"%d%d:%d",0,minutes,seconds];
    } else {
        [appDelegate.time invalidate];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Call me"];
        
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1]
                                 range:NSMakeRange(0, [@"Call me" length])];
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [@"Call me" length])];
        [reqPinBtn setAttributedTitle:attributedString forState:UIControlStateNormal];
        timerLabel.text = [NSString stringWithFormat:@"00:00"];
        reqPinBtn.userInteractionEnabled = YES;
        [reqPinBtn setEnabled:YES];
        didNotRecieveSMSLabel.hidden = NO;
    }
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BaseUI Method Implementation -
- (void)removeOverlayViewsIfAnyOnPushNotification {
    
    KLog(@"Remove PopOver if any open");
    [alertVw dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)showAlert:(NSString*)alertMsg {

    if(alertMsg.length > 0) {
        alertVw = [[UIAlertView alloc] initWithTitle:nil message:alertMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertVw show];
    }
}
@end
