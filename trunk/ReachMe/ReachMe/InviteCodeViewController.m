//
//  InviteCodeViewController.m
//  ReachMe
//
//  Created by Bhaskar Munireddy on 30/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "InviteCodeViewController.h"
#import "UserProfileModel.h"
#import "Profile.h"
#import "IVFileLocator.h"
#import "ContactDetailData.h"
#import "Contacts.h"
#import "InsideConversationScreen.h"
#import "InviteCodeSuccessViewController.h"
#import "RefferalCodeAPI.h"

//OnBoarding
#import "InviteCodeViewController.h"
#import "IVCarrierSearchViewController.h"
#import "IVCarrierCircleViewController.h"
#import "FetchCarriersListAPI.h"
#import "ActivateReachMeViewController.h"

#define kErrorCodeForCarrierListNotFound 20

@interface InviteCodeViewController ()<SettingProtocol,UITextFieldDelegate>
@property (nonatomic, strong) NSString *helpText;
@property (nonatomic, strong) NSMutableArray *helpTextArray, *supportContactList;
@property (weak, nonatomic) IBOutlet UILabel *invalidCodeLabel;
@property (weak, nonatomic) IBOutlet UIButton *applyCode;
@property (weak, nonatomic) IBOutlet UITextField *inviteCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *dontHaveCode;
@property (nonatomic, strong) NSArray *currentCarrierList;
@property (nonatomic, strong) IVCarrierSearchViewController *carrierSearchViewController;
@property (nonatomic, strong) IVSettingsCountryCarrierInfo *selectedCountryCarrierInfo;
@property (nonatomic, strong) VoiceMailInfo *voiceMailInfo;
@property (nonatomic, strong) SettingModel *currentSettingsModel;
@end

@implementation InviteCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[[ConfigurationReader sharedConfgReaderObj] setOnBoardingStatus:YES];
    self.title = NSLocalizedString(@"Redeem Code", nil);
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpAction)];
    self.navigationItem.rightBarButtonItem = helpButton;
//    self.navigationController.navigationItem.hidesBackButton = YES;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    [Setting sharedSetting].delegate = self;
    
    [self configureHelpAndSuggestion];
    
    self.inviteCodeTextField.layer.cornerRadius = 2.0;
    self.inviteCodeTextField.layer.borderWidth = 2.0;
    self.inviteCodeTextField.layer.borderColor = [[UIColor colorWithRed:(206.0/255.0) green:(212.0/255.0) blue:(218.0/255.0) alpha:1.0] CGColor];
    self.inviteCodeTextField.tintColor = [UIColor colorWithRed:(0.0/255.0) green:(151.0/255.0) blue:(137.0/255.0) alpha:1.0];
    
    self.inviteCodeTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, self.inviteCodeTextField.frame.size.height)];
    rightView.backgroundColor = self.inviteCodeTextField.backgroundColor;
    self.inviteCodeTextField.rightView = rightView;
    self.inviteCodeTextField.rightViewMode = UITextFieldViewModeAlways;
    
    //Apply Code Button
    self.applyCode.layer.cornerRadius = 22.0;
    self.applyCode.layer.borderWidth = 2.0;
    self.applyCode.layer.borderColor = [[UIColor clearColor] CGColor];
    self.applyCode.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.applyCode.layer.shadowOpacity = 1.0f;
    self.applyCode.layer.shadowRadius = 1.0f;
    self.applyCode.layer.shadowOffset = CGSizeMake(0, 1);
    
    //Dont Have Code Button
    self.dontHaveCode.layer.cornerRadius = 22.0;
    self.dontHaveCode.layer.borderWidth = 2.0;
    self.dontHaveCode.layer.borderColor = [[UIColor clearColor] CGColor];
    self.dontHaveCode.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.dontHaveCode.layer.shadowOpacity = 1.0f;
    self.dontHaveCode.layer.shadowRadius = 1.0f;
    self.dontHaveCode.layer.shadowOffset = CGSizeMake(0, 1);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToResignResponder:)];
    [self.view addGestureRecognizer:tap];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)tapToResignResponder:(UITapGestureRecognizer *)reco
{
    [self.inviteCodeTextField resignFirstResponder];
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
                if([voiceMailInfo.phoneNumber isEqualToString:[[ConfigurationReader sharedConfgReaderObj] getLoginId]]) {
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
        selectCircle.isEdit = NO;
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
                self.carrierSearchViewController.isEdit = NO;
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

- (void)helpAction
{
    self.helpText = @"";
    [self showHelpMessage];
    
}

- (void)configureHelpAndSuggestion
{
    self.helpTextArray = [[NSMutableArray alloc]init];
    self.supportContactList = [[Setting sharedSetting].supportContactList mutableCopy];
    if(self.supportContactList != nil && [self.supportContactList count] > 0)
    {
        NSUInteger count = (NSUInteger)[self.supportContactList count];
        for(NSUInteger  i = 0; i < count; i++)
        {
            NSMutableDictionary *dic = [self.supportContactList objectAtIndex:i];
            NSString *supportName = [dic valueForKey:SUPPORT_NAME];
            if([supportName isEqualToString:MENU_FEEDBACK])
            {
                //do nothing
            }
            else
            {
                [self.helpTextArray addObject:dic];
            }
        }
    }
}


- (void)showHelpMessage
{
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        if (self.helpTextArray != nil && [self.helpTextArray count] > 0) {
            NSUInteger count = [self.helpTextArray count];
            for(NSUInteger  i = 0;i < count; i++) {
                NSDictionary *helpPhoneDic = [self.helpTextArray objectAtIndex:i];
                [self gotoHelpChat:helpPhoneDic];
            }
        }
        else
            [ScreenUtility showAlertMessage:NSLocalizedString(@"NO_SUPPORT_LIST", nil)];
    }
    else {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

-(void)gotoHelpChat:(NSDictionary *)supportDic
{
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
    
    NSString *ivUserId = [supportDic valueForKey:SUPPORT_IV_ID];
    [newDic setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
    [newDic setValue:ivUserId forKey:REMOTE_USER_IV_ID];
    [newDic setValue:[supportDic valueForKey:SUPPORT_DATA_VALUE] forKey:FROM_USER_ID];
    [newDic setValue:[supportDic valueForKey:SUPPORT_NAME] forKey:REMOTE_USER_NAME];
    [newDic setValue:[supportDic valueForKey:SUPPORT_PIC_URI] forKey:REMOTE_USER_PIC];
    [newDic setValue:self.helpText forKey:@"HELP_TEXT"];
    
    
    //- get the pic
    NSNumber* ivID = [NSNumber numberWithLong:[ivUserId longLongValue]];
    NSArray* arr = [[Contacts sharedContact]getContactForIVUserId:ivID usingMainContext:YES];
    ContactDetailData* detailData = Nil;
    if([arr count]>0)
        detailData = [arr objectAtIndex:0];
    
    if(detailData)
        [newDic setValue:[IVFileLocator getNativeContactPicPath:detailData.contactIdParentRelation.contactPic]
                  forKey:REMOTE_USER_PIC];
    
    [appDelegate.dataMgt setCurrentChatUser:newDic];
    
    BaseUI* uiObj = [[InsideConversationScreen alloc]initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    uiObj.isAnyChangesSpecificSubClass = YES;
    [self.navigationController pushViewController:uiObj animated:YES];
    
}

- (IBAction)applyCodeAction:(id)sender {
    self.invalidCodeLabel.hidden = YES;
    [self.inviteCodeTextField resignFirstResponder];
    
    if (!self.inviteCodeTextField.text.length) {
        [ScreenUtility showAlertMessage:@"Please Enter Invite Code"];
        return;
    }
    
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        [self showProgressBar];
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        language = [language stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
        NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
        [requestDic setValue:self.inviteCodeTextField.text forKey:@"referral_code"];
        [requestDic setValue:language forKey:@"locale_str"];

        RefferalCodeAPI* api = [[RefferalCodeAPI alloc]initWithRequest:requestDic];
        [api callNetworkRequest:requestDic withSuccess:^(RefferalCodeAPI *req, NSMutableDictionary *responseObject) {
            if ([[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
                InviteCodeSuccessViewController *inviteCode = [[InviteCodeSuccessViewController alloc]initWithNibName:@"InviteCodeSuccessViewController" bundle:nil];
                inviteCode.url = [responseObject valueForKey:@"p_msg_url"];
                [self.navigationController pushViewController:inviteCode animated:YES];
                [self hideProgressBar];
            }
        }failure:^(RefferalCodeAPI *req, NSError *error) {
            self.invalidCodeLabel.hidden = NO;
            self.invalidCodeLabel.text = [error.userInfo valueForKey:@"error_reason"];
            //Need to check with server team
//            if (error.code > 8000 && error.code < 8005) {
//                self.invalidCodeLabel.text = [error.userInfo valueForKey:@"error_reason"];
//            }
            [self hideProgressBar];
        }];
    }
    else {
         [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.invalidCodeLabel.text = @"error";
    self.invalidCodeLabel.hidden = YES;
}

- (IBAction)dontHavePromoCode:(id)sender {
    /*
    [self loadLatestDataFromServer];
    
    NSString *simMCCMNC =[Common simMCCMNCCode];
    //simMCCMNC = @"40492";
    NSString *simCountry = [Common simCountryCode];
    //simCountry = @"091";
    //We have carrier info - check in the carrier list we have corresponding supported carrier info in the carrier list.
    NSString *countryCode = self.voiceMailInfo.carrierCountryCode;
    NSMutableArray *mccMNCCarrierList = [[NSMutableArray alloc] init];
    NSArray *carrierList = [self carrierListForCountry:countryCode];
    if (carrierList && [carrierList count]) {
        for (NSInteger i=0; i<[carrierList count]; i++) {
            IVSettingsCountryCarrierInfo *carrierInfoInList = [carrierList objectAtIndex:i];
            //check mccmnc list in the carrier info
            if (carrierInfoInList.mccmncList && [carrierInfoInList.mccmncList count]) {
                //We have MCCMNC List, check whether mccmnc sim is in the list.
                BOOL isMCCMNCListInCarrierList = [carrierInfoInList.mccmncList containsObject:simMCCMNC];
                if (isMCCMNCListInCarrierList && [simCountry isEqualToString:carrierInfoInList.countryCode]) {
                    [mccMNCCarrierList addObject:[carrierList objectAtIndex:i]];
                }
            }
            
        }
        
    }
    
    if (mccMNCCarrierList.count == 1) {
        ActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ActivateReachMe"];
        activateReachMe.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
        activateReachMe.isPrimaryNumber = YES;
        activateReachMe.voiceMailInfo = self.voiceMailInfo;
        [self.navigationController pushViewController:activateReachMe animated:YES];
        return;
    }
    
    if (!self.voiceMailInfo || !self.voiceMailInfo.countryVoicemailSupport) {
        //ActivateReachMe
        ActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ActivateReachMe"];
        activateReachMe.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
        activateReachMe.isPrimaryNumber = YES;
        activateReachMe.voiceMailInfo = self.voiceMailInfo;
        [self.navigationController pushViewController:activateReachMe animated:YES];
        return;
    }
    NSArray *listOfCarriers = [[Setting sharedSetting]carrierListForCountry:self.voiceMailInfo.carrierCountryCode];
    if (listOfCarriers && [listOfCarriers count]) {
        self.currentCarrierList = listOfCarriers;
        [self selectCarrier];
    }
    else {
        self.currentCarrierList = nil;
        //We do not have list of carriers - so start fetching list of carriers for the country.
        [[Setting sharedSetting]fetchListOfCarriersForCountry:self.voiceMailInfo.carrierCountryCode];
    }
    */
}

- (NSArray *)carrierListForCountry:(NSString *)withCountryCode {
    
    NSArray *carrierList;
    
    if (withCountryCode) {
        //Get the current country carrier list.
        if ([[Setting sharedSetting].data.listOfCarriers count]) {
            
            NSDictionary *carrierDetails;
            BOOL statusOfExistanceOfCarrierList = NO;
            for (carrierDetails in [Setting sharedSetting].data.listOfCarriers) {
                
                NSString *countryCode = [[carrierDetails allKeys]objectAtIndex:0];
                if([countryCode isKindOfClass:[NSNumber class]]) {
                    countryCode = [NSString stringWithFormat:@"%@",countryCode];
                }
                
                @try {
                    if ([countryCode isEqualToString:withCountryCode]) {
                        statusOfExistanceOfCarrierList = YES;
                        break;
                    }
                    else {
                        statusOfExistanceOfCarrierList = NO;
                    }
                }
                @catch (NSException *exception) {
                    EnLogd(@"FIXME");
                    if([withCountryCode isKindOfClass:[NSNumber class]]) {
                        EnLogd(@"Why withCountryCode is of NSNumber type?");
                    }
                }
            }
            
            if (statusOfExistanceOfCarrierList) {
                carrierList = [carrierDetails objectForKey:withCountryCode];
            }
        }
        else {
            carrierList = nil;
        }
    }
    return carrierList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
