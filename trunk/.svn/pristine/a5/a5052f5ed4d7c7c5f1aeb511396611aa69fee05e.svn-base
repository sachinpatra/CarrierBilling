//
//  ActivateReachMeViewController.m
//  InstaVoice
//
//  Created by Bhaskar Munireddy on 18/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "ActivateReachMeViewController.h"
#import "ActivatereachMeTableViewCell.h"
#import "UserProfileModel.h"
#import "Profile.h"
#import "IVFileLocator.h"
#import "ContactDetailData.h"
#import "BaseConversationScreen.h"
#import "Contacts.h"
#import "InsideConversationScreen.h"
#import "EditNumberDetailsViewController.h"
#import "ManageUserContactAPI.h"
#import "HowToActivateReachMeViewController.h"
#import "ReachMeActivatedViewController.h"
#import "InviteCodeViewController.h"
#import "IVSettingsListViewController.h"
#import "IVColors.h"
#import "PersonalisationViewController.h"
#import "UsageSummaryAPI.h"
#import "CountryCallingRatesViewController.h"
#import "ReachMeStatusViewController.h"
#import "ReachMe-Swift.h"

#define kReachMeNumberTitleCellIdentifier @"ReachMeNumberTitleCell"
#define kReachMeNumberEnableCellIdentifier @"ReachMeNumberEnableCell"
#define kReachMedNumberInfoCellIdentifier @"ReachMeNumberInfoCell"
#define kReachMedNumberContinueCellIdentifier @"ContinueToPersonalisation"
#define kReachMeUnlinkNumberCellIdentifier @"ReachMeUnlinkNumberCell"

#define kContactIdKey @"contact_id"
#define kCountryCodeKey @"country_code"
#define kPrimaryNumberCanNotDeleteErrorCode 88
#define kErrorCodeForCarrierListNotFound 20
#define kSelectCarrierButtonTitle @"Select Your Carrier"
#define kNotListedButtonTitle @"Unknown Carrier"
#define kCarrierNotSupporttedHelpText @"Hi, I'm interested in ReachMe Voicemail/Missed Call alerts. Please inform me when it's made available for my Carrier:"

typedef NS_ENUM(NSUInteger, ContactUpdateType) {
    eContactUpdateType = 0,
    eContactAddType,
    eContactDeleteType
};

@interface ActivateReachMeViewController ()<UITableViewDelegate, UITableViewDataSource,SettingProtocol,UITextViewDelegate>
{
    CGFloat heightForRow;
    BOOL isReachMeSupported, isCarrierNotListed, isReachMeHomeActive, isInternationalActive, isReachMeVMActive, isReachMeNumber;
    NSMutableArray *topFiveList, *allCountriesList;
}
@property (nonatomic, strong) SettingModel *currentSettingsModel;
@property (nonatomic, strong) NSString *additionalActiInfo;
@property (nonatomic, assign) BOOL isCarrierSupportedForVoiceMailSetup;
@property (nonatomic, assign) BOOL isVoiceMailAndMissedCallDeactivated;
@property (nonatomic, assign) BOOL isValidCarrierName;
@property (nonatomic, strong) NSArray *currentCarrierList;
@property (nonatomic, strong) NSString *carrierSelectionOrEnableStatus;
@property (nonatomic, strong) NSString *carrierDetailsText;
@property (nonatomic, assign) BOOL hasCarrierSelectedFromSim;
@property (nonatomic, assign) BOOL hasShownSimCarrierAlert;
@property (nonatomic, strong) IVSettingsCountryCarrierInfo *selectedCountryCarrierInfo;
@property (nonatomic, strong) NSString *currentNetworkName;

@property (nonatomic, strong) NSMutableArray *supportContactList;
@property (nonatomic, strong) NSString *helpText, *titleName, *carrierName;
@property (nonatomic, strong) NSString *activationDialNumber;
@property (nonatomic, strong) NSString *deactivateDialNumber;
@property (nonatomic, strong) NSMutableArray *helpTextArray;
@property (weak, nonatomic) IBOutlet UITableView *activateReachMeTable;
@property (nonatomic, strong) ActivatereachMeTableViewCell *activateReachMeCell;
@property (nonatomic, strong) NSDictionary *usageSummary;

@end

@implementation ActivateReachMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    heightForRow = 0.0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self prepareCountryListDictionary];
    });
    self.title = NSLocalizedString(@"Activate ReachMe", nil);
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpAction)];
    self.navigationItem.rightBarButtonItem = helpButton;
    
    if([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus])
        [[ConfigurationReader sharedConfgReaderObj] setOTPVerified:NO];
    
    NSDictionary *callSummary = [[ConfigurationReader sharedConfgReaderObj] getUsageSummaryForNumber:[NSString stringWithFormat:@"SummaryFor:%@",self.phoneNumber]];
    if(callSummary)
        self.usageSummary = callSummary;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UserProfileModel *model = [[Profile sharedUserProfile]profileData];
    for (NSDictionary *numberInfo in model.additionalVerifiedNumbers) {
        if ([[numberInfo valueForKey:@"contact_id"] isEqualToString:self.phoneNumber]) {
            isReachMeNumber = [[numberInfo valueForKey:@"is_virtual"] boolValue];
        }
    }
    
    if (self.isPrimaryNumber) {
        isReachMeNumber = NO;
    }
    
    if (isReachMeNumber) {
        self.title = NSLocalizedString(@"ReachMe Number", nil);
    }
    
    [self loadLatestDataFromServer];
    
    if(self.voiceMailInfo.reachMeVM || self.voiceMailInfo.reachMeHome || self.voiceMailInfo.reachMeIntl || isReachMeNumber)
        [self getUsageSummary];
    
    if ([self.phoneNumber isEqualToString:[[ConfigurationReader sharedConfgReaderObj] getLoginId]] || [[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus])
        self.isPrimaryNumber = YES;
    else
        self.isPrimaryNumber = NO;
    
    isReachMeSupported = NO;
    isCarrierNotListed = NO;
    isReachMeHomeActive = NO;
    isReachMeVMActive = NO;
    isInternationalActive = NO;
    
    [self reachMeServiceActiveWithUpdateStatus];
    
    [Setting sharedSetting].delegate = self;
    
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    
    if (carrierDetails) {
        
        if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
            isCarrierNotListed = YES;
        }
        
    }
    
    if (!self.voiceMailInfo || !self.voiceMailInfo.countryVoicemailSupport) {
        self.currentNetworkName = @"Not supported";
    }else{
        NSArray *listOfCarriers = [[Setting sharedSetting]carrierListForCountry:self.voiceMailInfo.carrierCountryCode];
        if (listOfCarriers && [listOfCarriers count]) {
            //We have list of carriers.
            self.currentCarrierList = listOfCarriers;
            //Reload Data - Current Network Name and reload the tableView.
            //Determine the network name from the network ID.
            self.currentNetworkName = [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList];
            
            //OCT 27, 2016
            IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
            self.additionalActiInfo = ccInfo.ussdInfo.additionalActiInfo;
            //TODO: Need to check the logic.!!
            [self updateUIBasedOnVoiceMailInfo:self.voiceMailInfo];
            
        }
        else {
            self.currentCarrierList = nil;
            //We do not have list of carriers - so start fetching list of carriers for the country.
            [[Setting sharedSetting]fetchListOfCarriersForCountry:self.voiceMailInfo.carrierCountryCode];
        }
    }
    
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@NO forKey:kUserSettingsFetched];
        [userDefaults synchronize];
        [self showProgressBar];
        [[Setting sharedSetting]getUserSettingFromServer];
        [[Profile sharedUserProfile] getProfileDataFromServer];
        [self configureHelpAndSuggestion];
    }
    self.titleName = [self titleName];
    self.carrierName = [self carrierName];
    [self.activateReachMeTable reloadData];
    
    if ([[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP]) {
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setFrame:CGRectMake(0.0, 0.0, 80.0, 44.0)];
        [backButton setExclusiveTouch:YES];
        UIImage *image = [[UIImage imageNamed:@"back_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [backButton setImage:image forState:UIControlStateNormal];
        backButton.tintColor = [IVColors redColor];
        [backButton setTitle:@"Settings" forState:UIControlStateNormal];
        [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
        [backButton setContentEdgeInsets:UIEdgeInsetsMake(0.0, -5.0, 0.0, 0.0)];
        backButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [backButton setTitleColor:[IVColors redColor] forState:UIControlStateNormal];
        UIBarButtonItem *backMenuBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backMenuBarButton;
        [[ConfigurationReader sharedConfgReaderObj] setOTPVerified:NO];
    }
    
    if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus])
        self.navigationItem.hidesBackButton = YES;
    else
        self.navigationItem.hidesBackButton = NO;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)reachMeServiceActiveWithUpdateStatus
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    if (carrierDetails.isReachMeIntlActive) {
        isInternationalActive = YES;
        isReachMeHomeActive = NO;
        isReachMeVMActive = NO;
    }else if (carrierDetails.isReachMeHomeActive){
        isInternationalActive = NO;
        isReachMeHomeActive = YES;
        isReachMeVMActive = NO;
    }else if (carrierDetails.isReachMeVMActive){
        isInternationalActive = NO;
        isReachMeHomeActive = NO;
        isReachMeVMActive = YES;
    }else{
        /*
         if (([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus] && ([self.usageSummary valueForKey:@"mca_count"] > 0 || [self.usageSummary valueForKey:@"reachme_count"] > 0 || [self.usageSummary valueForKey:@"vsms_count"] > 0))) {
         if (self.voiceMailInfo.reachMeHome){
         isInternationalActive = NO;
         isReachMeHomeActive = YES;
         isReachMeVMActive = NO;
         }else if (self.voiceMailInfo.reachMeVM){
         isInternationalActive = NO;
         isReachMeHomeActive = NO;
         isReachMeVMActive = YES;
         }
         reason = @"busy";
         }*/
    }
    
    
//    IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
//    NSString *activeString = [[ConfigurationReader sharedConfgReaderObj] getMissedCallReasonForTheNumber:self.phoneNumber];
//    NSString *reason = @"";
//    if (carrierDetails || (activeString.length && ccInfo)) {
//        if (activeString.length && ccInfo) {
//            if ([activeString isEqualToString:@"unconditional"]) {
//                isInternationalActive = YES;
//                isReachMeHomeActive = NO;
//                isReachMeVMActive = NO;
//            }else if (self.voiceMailInfo.reachMeHome){
//                isInternationalActive = NO;
//                isReachMeHomeActive = YES;
//                isReachMeVMActive = NO;
//            }else if (self.voiceMailInfo.reachMeVM){
//                isInternationalActive = NO;
//                isReachMeHomeActive = NO;
//                isReachMeVMActive = YES;
//            }
//            reason = activeString;
//        }else{
//            if (carrierDetails.isReachMeIntlActive) {
//                isInternationalActive = YES;
//                isReachMeHomeActive = NO;
//                isReachMeVMActive = NO;
//                reason = @"unconditional";
//            }else if (carrierDetails.isReachMeHomeActive){
//                isInternationalActive = NO;
//                isReachMeHomeActive = YES;
//                isReachMeVMActive = NO;
//                reason = @"busy";
//            }else if (carrierDetails.isReachMeVMActive){
//                isInternationalActive = NO;
//                isReachMeHomeActive = NO;
//                isReachMeVMActive = YES;
//                reason = @"busy";
//            }else{
//                /*
//                if (([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus] && ([self.usageSummary valueForKey:@"mca_count"] > 0 || [self.usageSummary valueForKey:@"reachme_count"] > 0 || [self.usageSummary valueForKey:@"vsms_count"] > 0))) {
//                    if (self.voiceMailInfo.reachMeHome){
//                        isInternationalActive = NO;
//                        isReachMeHomeActive = YES;
//                        isReachMeVMActive = NO;
//                    }else if (self.voiceMailInfo.reachMeVM){
//                        isInternationalActive = NO;
//                        isReachMeHomeActive = NO;
//                        isReachMeVMActive = YES;
//                    }
//                    reason = @"busy";
//                }*/
//            }
//        }
//    }else{
//        isInternationalActive = NO;
//        isReachMeHomeActive = NO;
//        isReachMeVMActive = NO;
//        reason = @"";
//    }
    
//    [self updateCarrierSettingsForReason:reason];
    
    [self.activateReachMeTable reloadData];
}

- (void)updateCarrierSettingsForReason:(NSString *)activeString
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    
    CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
    currentCarrierInfo.phoneNumber = self.phoneNumber;
    if(carrierDetails) {
        currentCarrierInfo.countryCode = carrierDetails.countryCode;
        currentCarrierInfo.networkId = carrierDetails.networkId;
        currentCarrierInfo.vSMSId = carrierDetails.vSMSId;
        if([activeString isEqualToString:@"unconditional"]){
            currentCarrierInfo.isReachMeIntlActive = YES;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = NO;
        }else if (self.voiceMailInfo.reachMeHome && activeString.length > 0){
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = YES;
            currentCarrierInfo.isReachMeVMActive = NO;
        }else{
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = NO;
        }
    }else{
        currentCarrierInfo.countryCode = [NSString stringWithFormat:@"%d", -1];
        currentCarrierInfo.networkId = [NSString stringWithFormat:@"%d", -1];
        currentCarrierInfo.vSMSId = [NSNumber numberWithInteger:-1];
        currentCarrierInfo.isReachMeIntlActive = NO;
        currentCarrierInfo.isReachMeHomeActive = NO;
        currentCarrierInfo.isReachMeVMActive = NO;
    }
    [self showProgressBar];
    [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
    
}

- (void)getUsageSummary
{
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        [self showProgressBar];
        NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
        [requestDic setValue:self.phoneNumber forKey:@"phone"];
        
        UsageSummaryAPI* api = [[UsageSummaryAPI alloc]initWithRequest:requestDic];
        [api callNetworkRequest:requestDic withSuccess:^(UsageSummaryAPI *req, NSMutableDictionary *responseObject) {
            if ([[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
                if ([responseObject valueForKey:@"summary"]) {
                    NSArray *summary = [responseObject valueForKey:@"summary"];
                    if (summary.count > 0) {
                        //TODO:CHECK
                        if ([[[summary objectAtIndex:0] valueForKey:@"msg_flow"] isEqualToString:@"r"]) {
                            self.usageSummary = [summary objectAtIndex:0];
                        }else if(summary.count > 1) {
                            self.usageSummary = [summary objectAtIndex:1];
                        }
                        
                        //Out Going calls Summary
                        if (summary.count == 1 && [[[summary objectAtIndex:0] valueForKey:@"msg_flow"] isEqualToString:@"s"]) {
                            self.usageSummary = [summary objectAtIndex:0];
                            [self.usageSummary setValue:[[summary objectAtIndex:0] valueForKey:@"reachme_count"] forKey:@"reachme_outgoing_count"];
                            [self.usageSummary setValue:[[summary objectAtIndex:0] valueForKey:@"obd_count"] forKey:@"obd_sender_count"];
                        } else {
                            if ([[[summary objectAtIndex:0] valueForKey:@"msg_flow"] isEqualToString:@"s"]) {
                                [self.usageSummary setValue:[[summary objectAtIndex:0] valueForKey:@"reachme_count"] forKey:@"reachme_outgoing_count"];
                                [self.usageSummary setValue:[[summary objectAtIndex:0] valueForKey:@"obd_count"] forKey:@"obd_sender_count"];
                            }else if (summary.count > 1){
                                [self.usageSummary setValue:[[summary objectAtIndex:1] valueForKey:@"reachme_count"] forKey:@"reachme_outgoing_count"];
                                [self.usageSummary setValue:[[summary objectAtIndex:1] valueForKey:@"obd_count"] forKey:@"obd_sender_count"];
                            }
                        }
                        
                        if(self.usageSummary)
                            [[ConfigurationReader sharedConfgReaderObj] setUsageSummaryForNumber:[NSString stringWithFormat:@"SummaryFor:%@",self.phoneNumber] usageSummary:self.usageSummary];
                        
                        [self.activateReachMeTable reloadData];
                    }
                }
            }
        }failure:^(UsageSummaryAPI *req, NSError *error) {
            
            //[ScreenUtility showAlert:[error description]];//TODO:FIXME -- Should display the error string based on error code.
            EnLogd(@"*** Error fetching user contact: %@, %@",req,[error description]);
            KLog(@"*** Error fetching user contact: %@, %@",req,[error description]);
            
        }];
        
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"NET_NOT_AVAILABLE", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        
        [alertController addAction:ok];
        
        alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [self.navigationController presentViewController:alertController animated:true completion:nil];
    }
}

-(IBAction)backButtonAction:(id)sender
{
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[IVSettingsListViewController class]]) {
            [[ConfigurationReader sharedConfgReaderObj] setOTPVerified:NO];
            [self.navigationController popToViewController:aViewController animated:YES];
        }
    }
}

#pragma mark - Settings Protocol Methods -

- (void)fetchListOfCarriersForCountry:(SettingModel *)modelData withFetchStatus:(BOOL)withFetchStatus {
    
    //hide loading Indicator
    
    //NOV 24, 2016
    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    //
    
    if (withFetchStatus) {
        NSArray *listOfCarriers = [[Setting sharedSetting]carrierListForCountry:self.voiceMailInfo.carrierCountryCode];
        self.currentCarrierList = listOfCarriers;
        self.currentNetworkName = [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList];
    }
    [self.activateReachMeTable reloadData];
}

- (void)updateSettingCompletedWith:(SettingModel *)modelData withUpdateStatus:(BOOL)withUpdateStatus
{
//    if(withUpdateStatus)
//        [[ConfigurationReader sharedConfgReaderObj] setMissedCallReasonForNumber:self.phoneNumber shouldUpdate:NO];
//
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setValue:@NO forKey:kUserSettingsFetched];
//    [userDefaults synchronize];
//    [[Setting sharedSetting]getUserSettingFromServer];
}

- (void)fetchSettingCompletedWith:(SettingModel*)modelData withFetchStatus:(BOOL)withFetchStatus {
    
    //Settings has been updated successfully, update the UI.
    [self hideProgressBar];
    if (withFetchStatus) {
        //Determine the network name from the network ID.
        self.currentNetworkName = [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList];
        [self loadLatestDataFromServer];
        [self updateUIBasedOnVoiceMailInfo:self.voiceMailInfo];
    }
    [self reachMeServiceActiveWithUpdateStatus];
    
}

- (void)updateCarrierSettingsForMisscallReason:(NSString *)activeString
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    
    CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
    currentCarrierInfo.phoneNumber = self.phoneNumber;
    if(carrierDetails) {
        currentCarrierInfo.countryCode = carrierDetails.countryCode;
        currentCarrierInfo.networkId = carrierDetails.networkId;
        currentCarrierInfo.vSMSId = carrierDetails.vSMSId;
        if([activeString isEqualToString:@"unconditional"]){
            currentCarrierInfo.isReachMeIntlActive = YES;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = NO;
        }else if (self.voiceMailInfo.reachMeHome){
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = YES;
            currentCarrierInfo.isReachMeVMActive = NO;
        }else{
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = YES;
        }
    }else{
        currentCarrierInfo.countryCode = [NSString stringWithFormat:@"%d", -1];
        currentCarrierInfo.networkId = [NSString stringWithFormat:@"%d", -1];
        currentCarrierInfo.vSMSId = [NSNumber numberWithInteger:-1];
        currentCarrierInfo.isReachMeIntlActive = NO;
        currentCarrierInfo.isReachMeHomeActive = NO;
        currentCarrierInfo.isReachMeVMActive = NO;
    }
    [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
    
}

- (void)helpAction
{
//    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
//
//    if (self.voiceMailInfo.countryVoicemailSupport && !self.voiceMailInfo.isVoiceMailEnabled && self.isCarrierSupportedForVoiceMailSetup) {
//        self.helpText = [NSString stringWithFormat:@"I'm having problems in activating ReachMe Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList], self.activationDialNumber];
//    }else if (!self.isValidCarrierName || !self.voiceMailInfo.countryVoicemailSupport) {
//        self.helpText = kCarrierNotSupporttedHelpText;
//    }else if (self.voiceMailInfo.isVoiceMailEnabled) {
//        if ((isInternationalActive || isReachMeVMActive || isReachMeHomeActive) && carrierDetails) {
//            self.helpText = @"";
//        }else if (self.voiceMailInfo.countryVoicemailSupport && self.isCarrierSupportedForVoiceMailSetup){
//            self.helpText = [NSString stringWithFormat:@"I'm having problems in activating ReachMe Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList], self.activationDialNumber];
//        }else if (!self.isValidCarrierName || !self.voiceMailInfo.countryVoicemailSupport || !carrierDetails) {
//            self.helpText = kCarrierNotSupporttedHelpText;
//        }else{
//            if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
//                self.helpText = kCarrierNotSupporttedHelpText;
//            }else{
//                self.helpText = [NSString stringWithFormat:@"%@ %@",kCarrierNotSupporttedHelpText,[self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList]];
//            }
//
//        }
//    }else{
//
//        self.helpText = [NSString stringWithFormat:@"%@ %@",kCarrierNotSupporttedHelpText,[self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList]];
//    }
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    if (section == 1) {
        if (carrierDetails && (![carrierDetails.networkId isEqualToString:@"-1"] && ![carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] != -1) && (self.voiceMailInfo.reachMeHome || self.voiceMailInfo.reachMeIntl || self.voiceMailInfo.reachMeVM)) {
            isReachMeSupported = YES;
            if ((!self.voiceMailInfo.reachMeIntl && !self.voiceMailInfo.reachMeHome && self.voiceMailInfo.reachMeVM) || (!self.voiceMailInfo.reachMeIntl && self.voiceMailInfo.reachMeHome && !self.voiceMailInfo.reachMeVM) || (self.voiceMailInfo.reachMeIntl && !self.voiceMailInfo.reachMeHome && !self.voiceMailInfo.reachMeVM)) {
                return 1;
            }else{
                if (!isReachMeNumber) {
                    return 2;
                }else{
                    return 1;
                }
            }
        }else{
            if (isReachMeNumber) {
                isReachMeSupported = YES;
                return 1;
            }
            isReachMeSupported = NO;
            return 3;
        }
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        NSString *infoString;
        
        if ([self isActive] && [[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus])
            return 50.0;
        
        if(isReachMeSupported)
            infoString = @"InstaVoice ReachMe makes it possible to receive calls over data, when you’re on international roaming, unreachable or even without a SIM. Learn more";
        else
            infoString = @"ReachMe International & RechMe Home is not supported for selected carrier. Learn More";

        if (isReachMeNumber) {
            infoString = @"Your monthly subscription of ReachMe Number is active and next payment is due on 17-Apr-2018.";
        }
        
        UITextView *msgLabel = [[UITextView alloc] init];
        msgLabel.text = infoString;
        msgLabel.font = [UIFont systemFontOfSize:14.0];
        [msgLabel sizeToFit];
        
        CGSize stringSize;
        CGSize lableWidth = CGSizeMake(DEVICE_WIDTH - 100.0, CGFLOAT_MAX);
        CGSize neededSize = [msgLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
        stringSize = neededSize;
        stringSize.height += 10.0;
        if(self.isPrimaryNumber){
            if(isReachMeSupported)
                return stringSize.height + 10.0;
            else
                return 60.0;
        }else{
            if(isReachMeSupported){
                if (isReachMeNumber) {
                    return stringSize.height + 120.0;
                }else{
                    return stringSize.height + 160.0;
                }
            }else{
                return 60.0;
            }
            
        }
        
    }else if (indexPath.section == 1){
        NSString *infoString = [self infoString:indexPath];
        
        UITextView *msgLabel = [[UITextView alloc] init];
        msgLabel.text = infoString;
        msgLabel.font = [UIFont systemFontOfSize:16.0];
        if (!isReachMeSupported && indexPath.row != 0) {
            msgLabel.font = [UIFont systemFontOfSize:14.0];
        }
        [msgLabel sizeToFit];
        CGSize lableWidth = CGSizeMake(DEVICE_WIDTH - (isReachMeSupported?130.0:90.0), CGFLOAT_MAX);
        CGSize neededSize = [msgLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
        if (isReachMeNumber) {
            return neededSize.height + 25.0;
        }else{
            if (!isReachMeSupported) {
                return neededSize.height + 35.0;
            }
            return neededSize.height + 15.0;
        }
    }else{
        if(isReachMeSupported){
            if([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus])
                return 150.0;
            else
                return 180.0;
        }else
            return 150.0;
    }
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return 1.0f;
    }else if (section == 2){
        if(isReachMeSupported)
            return 20.0f;
        else
            return 1.0f;
    }else{
        if(isReachMeSupported){
            if (![[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus]){
                if (!isReachMeNumber) {
                    return 145.0f;
                }else{
                    return 105.0f;
                }
            }else
                return 50.0f;
        }else
            return 10.0f;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.backgroundColor = [UIColor whiteColor];
    
    NSString *rmMissedCallCount=@"0";
    NSString *rmVoiceMailCount=@"0";
    NSString *rmIncomigCallCount=@"0";
    NSString *rmOutGoingCallCount=@"0";
    
    if (self.usageSummary) {
        rmMissedCallCount = [[self.usageSummary valueForKey:@"mca_count"] stringValue];
        rmVoiceMailCount = [[self.usageSummary valueForKey:@"vsms_count"] stringValue];
        
        if ([[self.usageSummary valueForKey:@"msg_flow"] isEqualToString:@"r"]) {
            int rmIncomingCount = [[self.usageSummary valueForKey:@"reachme_count"] intValue] + [[self.usageSummary valueForKey:@"obd_count"] intValue];
            
            rmIncomigCallCount = [NSString stringWithFormat:@"%d",rmIncomingCount];
        }
        
        if ([self.usageSummary valueForKey:@"reachme_outgoing_count"] || [self.usageSummary valueForKey:@"obd_sender_count"]) {
            int rmOutgoingCount = [[self.usageSummary valueForKey:@"reachme_outgoing_count"] intValue] + [[self.usageSummary valueForKey:@"obd_sender_count"] intValue];
            rmOutGoingCallCount = [NSString stringWithFormat:@"%d",rmOutgoingCount];
        }else{
            rmOutGoingCallCount=@"0";
        }
    }
    /*
    else{
        rmMissedCallCount = @"0";
        rmVoiceMailCount = @"0";
        rmIncomigCallCount = @"0";
    }*/
    
    UIView *usageSummaryView = [[UIView alloc] initWithFrame:CGRectMake(26.0, -30.0, DEVICE_WIDTH - 54.0, 120.0)];
    usageSummaryView.backgroundColor = [UIColor whiteColor];
    usageSummaryView.layer.cornerRadius = 2.0;
    usageSummaryView.layer.borderWidth = 2.0;
    usageSummaryView.layer.borderColor = [[UIColor clearColor] CGColor];
    usageSummaryView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    usageSummaryView.layer.shadowOpacity = 1.0f;
    usageSummaryView.layer.shadowRadius = 1.0f;
    usageSummaryView.layer.shadowOffset = CGSizeMake(0, 1);
    
    UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 7.0, usageSummaryView.frame.size.width - 120.0, 16.0)];
    summaryLabel.text = NSLocalizedString(@"ReachMe Calls", nil);
    summaryLabel.textColor = [UIColor colorWithRed:(0.0/255.0) green:(151.0/255.0) blue:(137.0/255.0) alpha:1.0];
    summaryLabel.font = [UIFont boldSystemFontOfSize:14.0];
    summaryLabel.backgroundColor = [UIColor clearColor];
    summaryLabel.textAlignment = NSTextAlignmentCenter;
    [usageSummaryView addSubview:summaryLabel];
    
    UILabel *lastXDays = [[UILabel alloc] initWithFrame:CGRectMake(usageSummaryView.frame.size.width - 75.0, 7.0, 70.0, 16.0)];
    lastXDays.text = NSLocalizedString(@"last 30 days", nil);
    lastXDays.textColor = [UIColor colorWithRed:(0.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:0.54f];
    lastXDays.font = [UIFont systemFontOfSize:12.0];
    lastXDays.backgroundColor = [UIColor clearColor];
    lastXDays.textAlignment = NSTextAlignmentRight;
    [usageSummaryView addSubview:lastXDays];
    
    UIButton *dropDown = [[UIButton alloc]initWithFrame:CGRectMake(usageSummaryView.frame.size.width - 30.0, 6.0, 24.0, 20.0)];
    [dropDown setImage:[UIImage imageNamed:@"down_arrow_settings"] forState:UIControlStateNormal];
    //[usageSummaryView addSubview:dropDown];
    
    UIView *incomingCallView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 20.0, usageSummaryView.frame.size.width/4, usageSummaryView.frame.size.height - 20.0)];
    incomingCallView.backgroundColor = [UIColor clearColor];
    [usageSummaryView addSubview:incomingCallView];
    
    UIView *incomingCallMiddleLine = [[UIView alloc] initWithFrame:CGRectMake(usageSummaryView.frame.size.width/4, 10.0, 1.0, incomingCallView.frame.size.height - 40.0)];
    incomingCallMiddleLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [incomingCallView addSubview:incomingCallMiddleLine];
    
    UILabel *incomingCallLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, incomingCallView.frame.size.height - 40.0, usageSummaryView.frame.size.width/4, 40.0)];
    incomingCallLabel.text = NSLocalizedString(@"Incoming", nil);
    incomingCallLabel.textColor = [UIColor colorWithRed:(0.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:0.54f];
    incomingCallLabel.font = [UIFont systemFontOfSize:12.0];
    incomingCallLabel.backgroundColor = [UIColor clearColor];
    incomingCallLabel.textAlignment = NSTextAlignmentCenter;
    incomingCallLabel.numberOfLines = 2;
    [incomingCallView addSubview:incomingCallLabel];
    
    UILabel *incomingCallCount = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, usageSummaryView.frame.size.width/4, incomingCallView.frame.size.height - 40.0)];
    if(self.voiceMailInfo.reachMeVM && !self.voiceMailInfo.reachMeIntl && !self.voiceMailInfo.reachMeHome)
        incomingCallCount.text = NSLocalizedString(@"-", nil);
    else
        incomingCallCount.text = NSLocalizedString(rmIncomigCallCount, nil);
    
    incomingCallCount.textColor = [UIColor colorWithRed:(218.0/255.0) green:(67.0/255.0) blue:(54.0/255.0) alpha:1.0f];
    incomingCallCount.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
    incomingCallCount.backgroundColor = [UIColor clearColor];
    incomingCallCount.textAlignment = NSTextAlignmentCenter;
    [incomingCallView addSubview:incomingCallCount];
    
    UIView *outGoingCallView = [[UIView alloc] initWithFrame:CGRectMake(usageSummaryView.frame.size.width/4, 20.0, usageSummaryView.frame.size.width/4, usageSummaryView.frame.size.height - 20.0)];
    outGoingCallView.backgroundColor = [UIColor clearColor];
    [usageSummaryView addSubview:outGoingCallView];
    
    UIView *outGoingCallMiddleLine = [[UIView alloc] initWithFrame:CGRectMake(usageSummaryView.frame.size.width/4, 10.0, 1.0, outGoingCallView.frame.size.height - 40.0)];
    outGoingCallMiddleLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [outGoingCallView addSubview:outGoingCallMiddleLine];
    
    UILabel *outGoingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, incomingCallView.frame.size.height - 40.0, usageSummaryView.frame.size.width/4, 40.0)];
    outGoingLabel.text = NSLocalizedString(@"OutGoing", nil);
    outGoingLabel.textColor = [UIColor colorWithRed:(0.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:0.54f];
    outGoingLabel.font = [UIFont systemFontOfSize:12.0];
    outGoingLabel.backgroundColor = [UIColor clearColor];
    outGoingLabel.textAlignment = NSTextAlignmentCenter;
    outGoingLabel.numberOfLines = 2;
    [outGoingCallView addSubview:outGoingLabel];
    
    UILabel *outGoingCallCount = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, usageSummaryView.frame.size.width/4, outGoingCallView.frame.size.height - 40.0)];
    if(self.voiceMailInfo.reachMeVM && !self.voiceMailInfo.reachMeIntl && !self.voiceMailInfo.reachMeHome)
        outGoingCallCount.text = NSLocalizedString(@"-", nil);
    else
        outGoingCallCount.text = NSLocalizedString(rmOutGoingCallCount, nil);
    
    outGoingCallCount.textColor = [UIColor colorWithRed:(218.0/255.0) green:(67.0/255.0) blue:(54.0/255.0) alpha:1.0f];
    outGoingCallCount.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
    outGoingCallCount.backgroundColor = [UIColor clearColor];
    outGoingCallCount.textAlignment = NSTextAlignmentCenter;
    [outGoingCallView addSubview:outGoingCallCount];
    
    UIView *missedCallView = [[UIView alloc] initWithFrame:CGRectMake((usageSummaryView.frame.size.width/4) * 2, 20.0, usageSummaryView.frame.size.width/4, usageSummaryView.frame.size.height - 20.0)];
    missedCallView.backgroundColor = [UIColor clearColor];
    [usageSummaryView addSubview:missedCallView];
    
    UIView *missedCalllMiddleLine = [[UIView alloc] initWithFrame:CGRectMake(usageSummaryView.frame.size.width/4, 10.0, 1.0, missedCallView.frame.size.height - 40.0)];
    missedCalllMiddleLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [missedCallView addSubview:missedCalllMiddleLine];
    
    UILabel *missedCallLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, missedCallView.frame.size.height - 40.0, usageSummaryView.frame.size.width/4, 40.0)];
    missedCallLabel.text = NSLocalizedString(@"Missed", nil);
    missedCallLabel.textColor = [UIColor colorWithRed:(0.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:0.54f];
    missedCallLabel.font = [UIFont systemFontOfSize:12.0];
    missedCallLabel.backgroundColor = [UIColor clearColor];
    missedCallLabel.textAlignment = NSTextAlignmentCenter;
    missedCallLabel.numberOfLines = 2;
    [missedCallView addSubview:missedCallLabel];
    
    UILabel *missedCallCount = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, usageSummaryView.frame.size.width/4, missedCallView.frame.size.height - 40.0)];
    missedCallCount.text = NSLocalizedString(rmMissedCallCount, nil);
    missedCallCount.textColor = [UIColor colorWithRed:(218.0/255.0) green:(67.0/255.0) blue:(54.0/255.0) alpha:1.0f];
    missedCallCount.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
    missedCallCount.backgroundColor = [UIColor clearColor];
    missedCallCount.textAlignment = NSTextAlignmentCenter;
    [missedCallView addSubview:missedCallCount];
    
    UIView *voiceMailView = [[UIView alloc] initWithFrame:CGRectMake((usageSummaryView.frame.size.width/4) * 3, 20.0, usageSummaryView.frame.size.width/4, usageSummaryView.frame.size.height - 20.0)];
    voiceMailView.backgroundColor = [UIColor clearColor];
    [usageSummaryView addSubview:voiceMailView];
    
    UILabel *voiceMailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, voiceMailView.frame.size.height - 40.0, usageSummaryView.frame.size.width/4, 40.0)];
    voiceMailLabel.text = NSLocalizedString(@"VoiceMails", nil);
    voiceMailLabel.textColor = [UIColor colorWithRed:(0.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:0.54f];
    voiceMailLabel.font = [UIFont systemFontOfSize:12.0];
    voiceMailLabel.backgroundColor = [UIColor clearColor];
    voiceMailLabel.textAlignment = NSTextAlignmentCenter;
    voiceMailLabel.numberOfLines = 2;
    [voiceMailView addSubview:voiceMailLabel];
    
    UILabel *voiceMailCount = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, usageSummaryView.frame.size.width/4, voiceMailView.frame.size.height - 40.0)];
    voiceMailCount.text = NSLocalizedString(rmVoiceMailCount, nil);
    voiceMailCount.textColor = [UIColor colorWithRed:(218.0/255.0) green:(67.0/255.0) blue:(54.0/255.0) alpha:1.0f];
    voiceMailCount.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
    voiceMailCount.backgroundColor = [UIColor clearColor];
    voiceMailCount.textAlignment = NSTextAlignmentCenter;
    [voiceMailView addSubview:voiceMailCount];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 20.0, DEVICE_WIDTH - 100.0, 20.0)];
    if(isReachMeSupported){
        if (![[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus])
            label.frame = CGRectMake(70.0, 115.0, DEVICE_WIDTH - 100.0, 20.0);
    }
    else
        label.frame = CGRectMake(70.0, 20.0, DEVICE_WIDTH - 100.0, 20.0);
    
    label.text = NSLocalizedString(@"Select ReachMe Mode", nil);
    label.textColor = [UIColor colorWithRed:(81.0/255.0) green:(80.0/255.0) blue:(80.0/255.0) alpha:1.0];
    label.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    label.backgroundColor = [UIColor clearColor];
    
    UIImageView *reachMeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(26.0, 17.0, 31.0, 21.0)];
    if(isReachMeSupported){
        if (![[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus])
            reachMeIcon.frame = CGRectMake(26.0, 112.0, 31.0, 21.0);
    }else
        reachMeIcon.frame = CGRectMake(26.0, 17.0, 31.0, 21.0);
    
    reachMeIcon.image = [UIImage imageNamed:@"reach_me"];
    
    if (section == 1){
        if(isReachMeSupported){
            if (![[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus])
                [tableHeaderView addSubview:usageSummaryView];
            
            if (!isReachMeNumber) {
                [tableHeaderView addSubview:label];
                [tableHeaderView addSubview:reachMeIcon];
            }
        }
    }
    
    return tableHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *cellIdentifier;
    if (indexPath.section == 0) {
        cellIdentifier = kReachMeNumberTitleCellIdentifier;
    }else if (indexPath.section == 1){
        cellIdentifier = kReachMeNumberEnableCellIdentifier;
    }else{
        if (!isReachMeSupported) {
            cellIdentifier = kReachMeUnlinkNumberCellIdentifier;
        }else{
            if ([self isActive] && [[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus])
                cellIdentifier = kReachMedNumberContinueCellIdentifier;
            else
                cellIdentifier = kReachMedNumberInfoCellIdentifier;
        }
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([cell isKindOfClass:[ActivatereachMeTableViewCell class]]) {
        ActivatereachMeTableViewCell *activateReachMeCell = (ActivatereachMeTableViewCell *)cell;
        
        //Number Details Section
        NumberInfo *numberDetails = [[Setting sharedSetting]customNumberInfoForPhoneNumber:self.phoneNumber];
        if (numberDetails.titleName.length) {
            activateReachMeCell.numberLable.text = self.titleName;
            activateReachMeCell.nameLable.text = [Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        }else{
            activateReachMeCell.numberLable.text = [Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
            activateReachMeCell.nameLable.text = [self getCountryCode:self.phoneNumber];
        }
        
        //Carrier Name
        activateReachMeCell.carrierName.text = isReachMeNumber?@" ReachMe  ":self.currentNetworkName;
        activateReachMeCell.carrierName.layer.cornerRadius = 14.0;
        activateReachMeCell.carrierName.textContainerInset = UIEdgeInsetsMake(3.0, 5.0, 0.0, 5.0);
        
        //Flag Image
        activateReachMeCell.flagImage.layer.cornerRadius = activateReachMeCell.flagImage.frame.size.height/2;
        activateReachMeCell.flagImage.image = [UIImage imageNamed:[self getFlagFromCountryName:[self getCountryCode:self.phoneNumber]]];
        
        //ReachMe Mode Section
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(forwardToDidSelect:)];
        activateReachMeCell.reachMeDetailsTextView.tag = indexPath.row;
        [activateReachMeCell.reachMeDetailsTextView addGestureRecognizer: tap];
        activateReachMeCell.reachMeDetailsTextView.textContainerInset = UIEdgeInsetsMake(3.0, -5.0, 0.0, 0.0);
        activateReachMeCell.reachMeDetailsTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        if (indexPath.section == 1) {
            if (isReachMeSupported) {
                activateReachMeCell.reachMeDetailsTextView.font = [UIFont systemFontOfSize:14.0];
                activateReachMeCell.reachMeDetailsTextView.tintColor = [UIColor grayColor];
                activateReachMeCell.activeStatus.hidden = NO;
                activateReachMeCell.reachMeDetailsTextViewTopConstraint.constant = 1.0;
                activateReachMeCell.reachMeTypeSubLable.hidden = NO;
                if (self.voiceMailInfo.reachMeIntl && self.voiceMailInfo.reachMeHome) {
                    if (indexPath.row == 1) {
                        activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"rm_home"];
                        activateReachMeCell.reachMeTypeLable.text = @"ReachMe Home";
                        activateReachMeCell.reachMeTypeSubLable.text = @"Activate to get calls when number is unreachable >";
                        activateReachMeCell.reachMeDetailsTextView.text = @"Get calls in the app when phone is switched off or out of coverage when in home country.";
                        
                        if(!isReachMeHomeActive)
                            activateReachMeCell.activeStatus.text = @"Switch";
                        else
                            activateReachMeCell.activeStatus.text = @"Active";
                        
                    }else{
                        activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"rm_international"];
                        activateReachMeCell.reachMeTypeLable.text = @"ReachMe International";
                        activateReachMeCell.reachMeTypeSubLable.text = @"Activate to save International roaming charges >";
                        activateReachMeCell.reachMeDetailsTextView.text = @"Get all calls in the app at zero roaming charges when traveling internationally.";
                        
                        if(!isInternationalActive)
                            activateReachMeCell.activeStatus.text = @"Switch";
                        else
                            activateReachMeCell.activeStatus.text = @"Active";
                        
                    }
                }else if (self.voiceMailInfo.reachMeIntl && self.voiceMailInfo.reachMeVM) {
                    if (indexPath.row == 1) {
                        activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"voicemail_support"];
                        activateReachMeCell.reachMeTypeLable.text = @"ReachMe Voicemail";
                        activateReachMeCell.reachMeTypeSubLable.text = @"Activate if traveling or planning to travel >";
                        activateReachMeCell.reachMeDetailsTextView.text = @"Get visual voicemails in the app. Manage, transcribe and withdraw sent voicemails.";
                        
                        if(!isReachMeVMActive)
                            activateReachMeCell.activeStatus.text = @"Switch";
                        else
                            activateReachMeCell.activeStatus.text = @"Active";
                        
                    }else{
                        activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"rm_international"];
                        activateReachMeCell.reachMeTypeLable.text = @"ReachMe International";
                        activateReachMeCell.reachMeTypeSubLable.text = @"Activate to save International roaming charges >";
                        activateReachMeCell.reachMeDetailsTextView.text = @"Get all calls in the app at zero roaming charges when traveling internationally.";
                        
                        if(!isInternationalActive)
                            activateReachMeCell.activeStatus.text = @"Switch";
                        else
                            activateReachMeCell.activeStatus.text = @"Active";
                        
                    }
                }else if (self.voiceMailInfo.reachMeHome && self.voiceMailInfo.reachMeVM) {
                    if (indexPath.row == 1) {
                        activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"voicemail_support"];
                        activateReachMeCell.reachMeTypeLable.text = @"ReachMe Voicemail";
                        activateReachMeCell.reachMeTypeSubLable.text = @"Activate if traveling or planning to travel >";
                        activateReachMeCell.reachMeDetailsTextView.text = @"Get visual voicemails in the app. Manage, transcribe and withdraw sent voicemails.";
                        
                        if(!isReachMeVMActive)
                            activateReachMeCell.activeStatus.text = @"Switch";
                        else
                            activateReachMeCell.activeStatus.text = @"Active";
                        
                    }else{
                        activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"rm_home"];
                        activateReachMeCell.reachMeTypeLable.text = @"ReachMe Home";
                        activateReachMeCell.reachMeTypeSubLable.text = @"Activate to get calls when number is unreachable >";
                        activateReachMeCell.reachMeDetailsTextView.text = @"Get calls in the app when phone is switched off or out of coverage when in home country.";
                        
                        if(!isReachMeHomeActive)
                            activateReachMeCell.activeStatus.text = @"Switch";
                        else
                            activateReachMeCell.activeStatus.text = @"Active";
                        
                    }
                }else if (self.voiceMailInfo.reachMeIntl && !self.voiceMailInfo.reachMeHome && !self.voiceMailInfo.reachMeVM) {
                    activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"rm_international"];
                    activateReachMeCell.reachMeTypeLable.text = @"ReachMe International";
                    activateReachMeCell.reachMeTypeSubLable.text = @"Activate to save International roaming charges >";
                    activateReachMeCell.reachMeDetailsTextView.text = @"Get all calls in the app at zero roaming charges when traveling internationally.";
                    
                    if(!isInternationalActive)
                        activateReachMeCell.activeStatus.text = @"Switch";
                    else
                        activateReachMeCell.activeStatus.text = @"Active";
                    
                }else if (!self.voiceMailInfo.reachMeIntl && self.voiceMailInfo.reachMeHome && !self.voiceMailInfo.reachMeVM) {
                    activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"rm_home"];
                    activateReachMeCell.reachMeTypeLable.text = @"ReachMe Home";
                    activateReachMeCell.reachMeTypeSubLable.text = @"Activate to get calls when number is unreachable >";
                    activateReachMeCell.reachMeDetailsTextView.text = @"Get calls in the app when phone is switched off or out of coverage when in home country.";
                    
                    if(!isReachMeHomeActive)
                        activateReachMeCell.activeStatus.text = @"Switch";
                    else
                        activateReachMeCell.activeStatus.text = @"Active";
                    
                }else if (!self.voiceMailInfo.reachMeIntl && !self.voiceMailInfo.reachMeHome && self.voiceMailInfo.reachMeVM) {
                    activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"voicemail_support"];
                    activateReachMeCell.reachMeTypeLable.text = @"ReachMe Voicemail";
                    activateReachMeCell.reachMeTypeSubLable.text = @"Activate if traveling or planning to travel >";
                    activateReachMeCell.reachMeDetailsTextView.text = @"Get visual voicemails in the app. Manage, transcribe and withdraw sent voicemails.";
                    
                    if(!isReachMeVMActive)
                        activateReachMeCell.activeStatus.text = @"Switch";
                    else
                        activateReachMeCell.activeStatus.text = @"Active";
                    
                }
                
                if ([self isActive]){
                    activateReachMeCell.activateButton.hidden = YES;
                }else{
                    activateReachMeCell.activateButton.hidden = NO;
                    activateReachMeCell.activeStatus.hidden = YES;
                }
                
                if (isReachMeNumber) {
                    activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"reach_me"];
                    activateReachMeCell.reachMeTypeLable.text = @"ReachMe Number";
                    activateReachMeCell.reachMeTypeSubLable.hidden = YES;
                    
                    NSString *labelStringWithCarrierName = @"Receive unlimited incoming calls over WiFi or mobile data. Make calls from primary number at cheaper rates, using ReachMe Wallet. View Calling Rates";
                    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                    style.lineSpacing = 1;
                    NSURL *URL = [NSURL URLWithString: @""];
                    NSMutableAttributedString * linkStr = [[NSMutableAttributedString alloc] initWithString:labelStringWithCarrierName];
                    [linkStr addAttribute: NSLinkAttributeName value:URL range: NSMakeRange(linkStr.length - 18, 18)];
                    [linkStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, labelStringWithCarrierName.length)];
                    activateReachMeCell.reachMeDetailsTextView.attributedText = linkStr;
                    activateReachMeCell.reachMeDetailsTextView.delegate = self;
                    activateReachMeCell.reachMeDetailsTextView.font = [UIFont systemFontOfSize:14.0];
                    activateReachMeCell.reachMeDetailsTextView.textColor = [UIColor grayColor];
                    activateReachMeCell.reachMeDetailsTextViewTopConstraint.constant = -10.0;
                    activateReachMeCell.reachMeDetailsTextView.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
                    activateReachMeCell.activateButton.hidden = YES;
                    activateReachMeCell.activeStatus.hidden = NO;
                    activateReachMeCell.activeStatus.text = @"GOLD";
                    activateReachMeCell.activeStatus.backgroundColor = [UIColor colorWithRed:212.0/255.0 green:175.0/255.0 blue:55.0/255.0 alpha:1.0f];
                    
                }
                
            }else{
                activateReachMeCell.activateButton.hidden = YES;
                activateReachMeCell.activeStatus.hidden = YES;
                activateReachMeCell.reachMeTypeSubLable.hidden = YES;
                activateReachMeCell.reachMeTypeSubLable.text = @"";
                
                NSString *detailsStringWithCarrierName = @"";
                NSString *labelStringWithCarrierName = @"";
        
                if (indexPath.row == 0) {
                    activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"error_outline"];
                    if (!self.voiceMailInfo.countryVoicemailSupport) {
                        detailsStringWithCarrierName = @"";
                        labelStringWithCarrierName = [NSString stringWithFormat:@"ReachMe Roaming feature is not available in %@ Country at present. Contact support",[self getCountryCode:self.phoneNumber]];
                    }else{
                        detailsStringWithCarrierName = @"";
                        labelStringWithCarrierName = [NSString stringWithFormat:@"ReachMe Roaming feature is not available with %@ at present. Contact support",self.currentNetworkName];
                    }
                    
                    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                    style.lineSpacing = 2;
                    NSURL *URL = [NSURL URLWithString: @""];
                    NSMutableAttributedString * linkStr = [[NSMutableAttributedString alloc] initWithString:labelStringWithCarrierName];
                    [linkStr addAttribute: NSLinkAttributeName value:URL range: NSMakeRange(linkStr.length - 15, 15)];
                    [linkStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, labelStringWithCarrierName.length)];
                    activateReachMeCell.reachMeTypeLable.text = detailsStringWithCarrierName;
                    activateReachMeCell.reachMeDetailsTextView.attributedText = linkStr;
                    activateReachMeCell.reachMeDetailsTextView.delegate = self;
                    activateReachMeCell.reachMeDetailsTextView.font = [UIFont systemFontOfSize:16.0];
                    activateReachMeCell.reachMeDetailsTextViewTopConstraint.constant = -5.0;
                    activateReachMeCell.reachMeDetailsTextView.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
                    
                }else if (indexPath.row == 1){
                    activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"reach_me"];
                    activateReachMeCell.reachMeTypeLable.text = @"Get a ReachMe Number";
                    activateReachMeCell.reachMeDetailsTextView.text = @"Get a new SIM-less number to make and receive calls over WiFi or mobile data. Numbers are available for select countries.";
                    
                }else{
                    activateReachMeCell.reachMeTypeIcon.image = [UIImage imageNamed:@"reach_me_out"];
                    activateReachMeCell.reachMeTypeLable.text = @"Make Calls on ReachMe";
                    activateReachMeCell.reachMeDetailsTextView.text = @"Make calls over WiFi or mobile data. Same rates apply even when you are travelling internationally.";
                }
            }
        }
        
        activateReachMeCell.activeStatus.layer.cornerRadius = 2.0;
        //activateReachMeCell.activeStatus.textContainerInset = UIEdgeInsetsMake(3.0, 3.0, 0.0, 3.0);
        
        activateReachMeCell.activateButton.layer.cornerRadius = 2.0;
        activateReachMeCell.activateButton.tag = indexPath.row;
        
        //Reach Mode View
        if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus] && isReachMeSupported) {
            activateReachMeCell.reachMeModeView.layer.cornerRadius = 2.0;
            activateReachMeCell.reachMeModeView.layer.borderWidth = 1.0;
            activateReachMeCell.reachMeModeView.layer.borderColor = [[UIColor colorWithRed:(218.0/255.0) green:(67.0/255.0) blue:(54.0/255.0) alpha:1.0] CGColor];
            activateReachMeCell.reachMeModeView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
            activateReachMeCell.reachMeModeView.layer.shadowOpacity = 5.0f;
            activateReachMeCell.reachMeModeView.layer.shadowRadius = 5.0f;
            activateReachMeCell.reachMeModeView.layer.shadowOffset = CGSizeMake(0, 2);
        }else{
            if (!isReachMeSupported){
                activateReachMeCell.reachMeModeView.layer.cornerRadius = 5.0;
                activateReachMeCell.reachMeModeView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
                activateReachMeCell.reachMeModeView.layer.shadowOpacity = 5.0f;
                activateReachMeCell.reachMeModeView.layer.shadowRadius = 5.0f;
                if (indexPath.row == 1) {
                    activateReachMeCell.reachMeModeView.layer.shadowOffset = CGSizeMake(0, 2);
                }else if (indexPath.row == 2) {
                    activateReachMeCell.reachMeModeView.layer.shadowOffset = CGSizeMake(0, 5);
                }else{
                    [[activateReachMeCell.reachMeModeView layer] setMasksToBounds:YES];
                    [[activateReachMeCell.reachMeModeView layer] setCornerRadius:1.0f];
                    [[activateReachMeCell.reachMeModeView layer] setBorderColor:[[UIColor colorWithRed:(206.0/255.0) green:(212.0/255.0) blue:(218.0/255.0) alpha:1.0] CGColor]];
                    [[activateReachMeCell.reachMeModeView layer] setBorderWidth:1.0f];
                }
            }else{
                if (isReachMeNumber) {
                    activateReachMeCell.reachMeModeView.layer.cornerRadius = 5.0;
                    activateReachMeCell.reachMeModeView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
                    activateReachMeCell.reachMeModeView.layer.shadowOpacity = 5.0f;
                    activateReachMeCell.reachMeModeView.layer.shadowRadius = 5.0f;
                    activateReachMeCell.reachMeModeView.layer.shadowOffset = CGSizeMake(0, 2);
                }else{
                    [[activateReachMeCell.reachMeModeView layer] setMasksToBounds:YES];
                    [[activateReachMeCell.reachMeModeView layer] setCornerRadius:1.0f];
                    [[activateReachMeCell.reachMeModeView layer] setBorderColor:[[UIColor colorWithRed:(206.0/255.0) green:(212.0/255.0) blue:(218.0/255.0) alpha:1.0] CGColor]];
                    [[activateReachMeCell.reachMeModeView layer] setBorderWidth:1.0f];
                }
            }
        }
        
        //Info Text
        NSString *infoString;
        if(isReachMeSupported){
            
            if (isReachMeNumber) {
                infoString = @"Your monthly subscription of ReachMe Number is active. For more details Click here";
                
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 4;
                NSURL *URL = [NSURL URLWithString: @"ReachMeNumber"];
                NSMutableAttributedString * linkStr = [[NSMutableAttributedString alloc] initWithString:infoString];
                [linkStr addAttribute: NSLinkAttributeName value:URL range: NSMakeRange(linkStr.length - 11, 11)];
                [linkStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, infoString.length)];
                activateReachMeCell.infoText.attributedText = linkStr;
            }else{
                infoString = @"InstaVoice ReachMe makes it possible to receive calls over data, when you’re on international roaming, unreachable or even without a SIM. Learn more";
                
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 4;
                NSURL *URL = [NSURL URLWithString: @"https://reachme.instavoice.com"];
                NSMutableAttributedString * linkStr = [[NSMutableAttributedString alloc] initWithString:infoString];
                if(!isCarrierNotListed)
                    [linkStr addAttribute: NSLinkAttributeName value:URL range: NSMakeRange(linkStr.length - 11, 11)];
                [linkStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, infoString.length)];
                activateReachMeCell.infoText.attributedText = linkStr;
            }
            
            activateReachMeCell.infoText.delegate = self;
            activateReachMeCell.infoText.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.54f];
            activateReachMeCell.infoText.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
            activateReachMeCell.infoText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
            activateReachMeCell.infoText.textContainerInset = UIEdgeInsetsZero;
            activateReachMeCell.lineView.hidden = NO;
            
        }else{
            activateReachMeCell.infoText.text = @"";
        }
        
        if (!isReachMeSupported && indexPath.section == 2) {
            activateReachMeCell.infoText.backgroundColor = [UIColor clearColor];
            activateReachMeCell.infoIcon.hidden = YES;
            activateReachMeCell.lineView.hidden = YES;
            activateReachMeCell.infoTextLeadingConstraint.constant = -20.0;
            if(self.isPrimaryNumber){
                activateReachMeCell.unLinkNumber.hidden = YES;
                activateReachMeCell.requestSupport.hidden = YES;
            }else{
                activateReachMeCell.unLinkNumber.hidden = NO;
                activateReachMeCell.requestSupport.hidden = YES;
                activateReachMeCell.unlinkNumberTopConstraint.constant = activateReachMeCell.infoTextBottomConstraint.constant - 60.0;
            }
        }else{
            if (indexPath.section == 2) {
                activateReachMeCell.infoText.hidden = NO;
                if(self.isPrimaryNumber){
                    activateReachMeCell.unLinkNumber.hidden = YES;
                    activateReachMeCell.requestSupport.hidden = YES;
                }else{
                    activateReachMeCell.unLinkNumber.hidden = NO;
                    activateReachMeCell.requestSupport.hidden = YES;
                    activateReachMeCell.unlinkNumberTopConstraint.constant = activateReachMeCell.infoTextBottomConstraint.constant - 60.0;
                }
                activateReachMeCell.infoIcon.hidden = NO;
                activateReachMeCell.infoTextLeadingConstraint.constant = 23.0;
                activateReachMeCell.backgroundColor = [UIColor clearColor];
            }
        }
        
        //Unlink Button
        activateReachMeCell.unLinkNumber.layer.cornerRadius = 2.0;
        activateReachMeCell.unLinkNumber.layer.borderWidth = 2.0;
        activateReachMeCell.unLinkNumber.layer.borderColor = [[UIColor clearColor] CGColor];
        activateReachMeCell.unLinkNumber.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        activateReachMeCell.unLinkNumber.layer.shadowOpacity = 1.0f;
        activateReachMeCell.unLinkNumber.layer.shadowRadius = 1.0f;
        activateReachMeCell.unLinkNumber.layer.shadowOffset = CGSizeMake(0, 1);
        
        //Request Support Button
        activateReachMeCell.requestSupport.layer.cornerRadius = 2.0;
        activateReachMeCell.requestSupport.layer.borderWidth = 2.0;
        activateReachMeCell.requestSupport.layer.borderColor = [[UIColor clearColor] CGColor];
        activateReachMeCell.requestSupport.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        activateReachMeCell.requestSupport.layer.shadowOpacity = 1.0f;
        activateReachMeCell.requestSupport.layer.shadowRadius = 1.0f;
        activateReachMeCell.requestSupport.layer.shadowOffset = CGSizeMake(0, 1);
        
        //Finish Setup Button
        activateReachMeCell.finishSetupButton.layer.cornerRadius = 2.0;
        activateReachMeCell.finishSetupButton.layer.borderWidth = 2.0;
        activateReachMeCell.finishSetupButton.layer.borderColor = [[UIColor clearColor] CGColor];
        activateReachMeCell.finishSetupButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        activateReachMeCell.finishSetupButton.layer.shadowOpacity = 1.0f;
        activateReachMeCell.finishSetupButton.layer.shadowRadius = 1.0f;
        activateReachMeCell.finishSetupButton.layer.shadowOffset = CGSizeMake(0, 1);
        
        //Finish Setup Button
        activateReachMeCell.continueToPersonalisation.layer.cornerRadius = 2.0;
        activateReachMeCell.continueToPersonalisation.layer.borderWidth = 2.0;
        activateReachMeCell.continueToPersonalisation.layer.borderColor = [[UIColor clearColor] CGColor];
        activateReachMeCell.continueToPersonalisation.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        activateReachMeCell.continueToPersonalisation.layer.shadowOpacity = 1.0f;
        activateReachMeCell.continueToPersonalisation.layer.shadowRadius = 1.0f;
        activateReachMeCell.continueToPersonalisation.layer.shadowOffset = CGSizeMake(0, 1);
        
        //Activate Button
        activateReachMeCell.activateButton.layer.cornerRadius = 2.0;
        activateReachMeCell.activateButton.layer.borderWidth = 2.0;
        activateReachMeCell.activateButton.layer.borderColor = [[UIColor clearColor] CGColor];
        activateReachMeCell.activateButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        activateReachMeCell.activateButton.layer.shadowOpacity = 1.0f;
        activateReachMeCell.activateButton.layer.shadowRadius = 1.0f;
        activateReachMeCell.activateButton.layer.shadowOffset = CGSizeMake(0, 1);
        
        [activateReachMeCell.editDetailsButton addTarget:self action:@selector(editDetails:) forControlEvents:UIControlEventTouchUpInside];
        
        [activateReachMeCell.unLinkNumber addTarget:self action:@selector(unLinkNumber:) forControlEvents:UIControlEventTouchUpInside];
        
        [activateReachMeCell.requestSupport addTarget:self action:@selector(requestSupport:) forControlEvents:UIControlEventTouchUpInside];
        
        [activateReachMeCell.finishSetupButton addTarget:self action:@selector(finishSetup:) forControlEvents:UIControlEventTouchUpInside];
        
        [activateReachMeCell.continueToPersonalisation addTarget:self action:@selector(finishSetup:) forControlEvents:UIControlEventTouchUpInside];
        
        [activateReachMeCell.activateButton addTarget:self action:@selector(activateReachMe:) forControlEvents:UIControlEventTouchUpInside];
        
        if([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus]){
            if (!isReachMeSupported) {
                activateReachMeCell.finishSetupButton.hidden = YES;
                activateReachMeCell.requestSupport.hidden = YES;
                activateReachMeCell.unLinkNumber.hidden = NO;
                activateReachMeCell.unLinkNumber.backgroundColor = [IVColors redColor];
                [activateReachMeCell.unLinkNumber setTitle:@"Finish" forState:UIControlStateNormal];
                [activateReachMeCell.unLinkNumber setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else{
                activateReachMeCell.finishSetupButton.hidden = YES;
                activateReachMeCell.requestSupport.hidden = NO;
            }
        }else{
            activateReachMeCell.finishSetupButton.hidden = YES;
            activateReachMeCell.editDetailsButton.hidden = NO;
        }
        
        if (isReachMeNumber) {
            activateReachMeCell.unLinkNumber.hidden = NO;
            activateReachMeCell.unLinkNumber.backgroundColor = [IVColors redColor];
            [activateReachMeCell.unLinkNumber setTitle:@"Cancel Subscription" forState:UIControlStateNormal];
            [activateReachMeCell.unLinkNumber setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            activateReachMeCell.unlinkNumberTopConstraint.constant = -20.0;
        }
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isReachMeNumber) {
        return;
    }
    
    if (indexPath.section == 1) {
        if (isInternationalActive && indexPath.row == 1) {
            NSString *countryName = [NSString stringWithFormat:@"Are you back to %@",[self getFlagFromCountryName:[self getCountryCode:self.phoneNumber]]];
            UIAlertController *backToHome = [UIAlertController alertControllerWithTitle:countryName message:@"If you switch to ReachMe Home when you are outside the home country, International roaming charges will be applicable. Do you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            
            UIAlertAction *continueToActivate = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                HowToActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"HowActivateReachMe"];
                activateReachMe.phoneNumber = self.phoneNumber;
                activateReachMe.voiceMailInfo = self.voiceMailInfo;
                activateReachMe.reachMeType = REACHME_HOME;
                [self.navigationController pushViewController:activateReachMe animated:YES];
            }];
            
            [backToHome addAction:cancel];
            [backToHome addAction:continueToActivate];
            backToHome.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
            [self.navigationController presentViewController:backToHome animated:YES completion:nil];
            return;
        }
        
        ReachMeActivatedViewController *activatedReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ReachMeActivated"];
        activatedReachMe.voiceMailInfo = self.voiceMailInfo;
        activatedReachMe.phoneNumber = self.phoneNumber;
        if (self.voiceMailInfo.reachMeIntl && self.voiceMailInfo.reachMeHome) {
            if (indexPath.row == 1) {
                if (isReachMeHomeActive) {
                    activatedReachMe.reachMeType = REACHME_HOME;
                    [self.navigationController pushViewController:activatedReachMe animated:YES];
                    return;
                }
            }else{
                if (isInternationalActive) {
                    activatedReachMe.reachMeType = REACHME_INTERNATIONAL;
                    [self.navigationController pushViewController:activatedReachMe animated:YES];
                    return;
                }
            }
        }else if (self.voiceMailInfo.reachMeIntl && self.voiceMailInfo.reachMeVM) {
            if (indexPath.row == 1) {
                if (isReachMeVMActive) {
                    activatedReachMe.reachMeType = REACHME_VOICEMAIL;
                    [self.navigationController pushViewController:activatedReachMe animated:YES];
                    return;
                }
            }else{
                if (isInternationalActive) {
                    activatedReachMe.reachMeType = REACHME_INTERNATIONAL;
                    [self.navigationController pushViewController:activatedReachMe animated:YES];
                    return;
                }
            }
        }else if (self.voiceMailInfo.reachMeHome && self.voiceMailInfo.reachMeVM) {
            if (indexPath.row == 1) {
                if (isReachMeVMActive) {
                    activatedReachMe.reachMeType = REACHME_VOICEMAIL;
                    [self.navigationController pushViewController:activatedReachMe animated:YES];
                    return;
                }
            }else{
                if (isReachMeHomeActive) {
                    activatedReachMe.reachMeType = REACHME_HOME;
                    [self.navigationController pushViewController:activatedReachMe animated:YES];
                    return;
                }
            }
        }else if (self.voiceMailInfo.reachMeIntl && !self.voiceMailInfo.reachMeHome && !self.voiceMailInfo.reachMeVM) {
            if (isInternationalActive) {
                activatedReachMe.reachMeType = REACHME_INTERNATIONAL;
                [self.navigationController pushViewController:activatedReachMe animated:YES];
                return;
            }
        }else if (!self.voiceMailInfo.reachMeIntl && self.voiceMailInfo.reachMeHome && !self.voiceMailInfo.reachMeVM) {
            if (isReachMeHomeActive) {
                activatedReachMe.reachMeType = REACHME_HOME;
                [self.navigationController pushViewController:activatedReachMe animated:YES];
                return;
            }
        }else if (!self.voiceMailInfo.reachMeIntl && !self.voiceMailInfo.reachMeHome && self.voiceMailInfo.reachMeVM) {
            if (isReachMeVMActive) {
                activatedReachMe.reachMeType = REACHME_VOICEMAIL;
                [self.navigationController pushViewController:activatedReachMe animated:YES];
                return;
            }
        }
        
        if (!isReachMeSupported && indexPath.section == 1) {
            if (indexPath.row == 1) {
                if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus]) {
                    StoreViewController *storeNavVC = [[UIStoryboard storyboardWithName:@"Store" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"StoreViewController"];
                    [self.navigationController pushViewController:storeNavVC animated:YES];
                }else{
                    [appDelegate.tabBarController setSelectedIndex:3];
                    [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[3]];
                }
            }else if (indexPath.row == 2) {
                [self callingRates];
            }
            return;
        }
        
        if(!isReachMeSupported || isCarrierNotListed || !self.voiceMailInfo.countryVoicemailSupport)
            return;
        
        //IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
        CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
        
        if (!carrierDetails) {
            [ScreenUtility showAlert:@"Please select carrier to activate"];
            return;
        }
        
        HowToActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"HowActivateReachMe"];
        activateReachMe.phoneNumber = self.phoneNumber;
        activateReachMe.voiceMailInfo = self.voiceMailInfo;
        if (indexPath.row == 0) {
            if(isReachMeSupported)
                activateReachMe.reachMeType = REACHME_INTERNATIONAL;
            else
                activateReachMe.reachMeType = REACHME_VOICEMAIL;
        }else{
            if (self.voiceMailInfo.reachMeVM && !self.voiceMailInfo.reachMeHome)
                activateReachMe.reachMeType = REACHME_VOICEMAIL;
            else
                activateReachMe.reachMeType = REACHME_HOME;
        }
        
        if (self.voiceMailInfo.reachMeIntl && !self.voiceMailInfo.reachMeHome && !self.voiceMailInfo.reachMeVM) {
            activateReachMe.reachMeType = REACHME_INTERNATIONAL;
        }else if (!self.voiceMailInfo.reachMeIntl && self.voiceMailInfo.reachMeHome && !self.voiceMailInfo.reachMeVM) {
            activateReachMe.reachMeType = REACHME_HOME;
        }else if (!self.voiceMailInfo.reachMeIntl && !self.voiceMailInfo.reachMeHome && self.voiceMailInfo.reachMeVM) {
            activateReachMe.reachMeType = REACHME_VOICEMAIL;
        }
        
        [self.navigationController pushViewController:activateReachMe animated:YES];
    }
}

- (void)callingRates {
    CountryCallingRatesViewController *callingRateVC = [[UIStoryboard storyboardWithName:@"IVSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"CountryCallingRate"];
    callingRateVC.profileFieldData = allCountriesList;
    callingRateVC.topFiveCountryList = topFiveList;
    [self.navigationController pushViewController:callingRateVC animated:YES];
}

- (void)prepareCountryListDictionary {
    
    KLog(@"prepareCountryListDictionary - START");
    
    BOOL hasPrefixValues;
    float debitRates = 0.0;
    float minDebitRate = 0.0;
    float maxDebitRate = 0.0;
    NSArray *obdDebitRatesArray;
    NSArray* tmp = [[Engine sharedEngineObj]fetchObdDebitPolicy:NO];
    if(tmp.count)
    {
        obdDebitRatesArray = [[NSArray alloc] initWithArray:tmp];
    }
    
    topFiveList = [[NSMutableArray alloc] init];
    
    for (NSMutableDictionary *country in [Common topFiveCountryList]) {
        hasPrefixValues = NO;
        NSString *isd =[country valueForKey:@"COUNTRY_SIM_ISO"];
        if (obdDebitRatesArray.count > 0) {
            
            NSArray* res = [obdDebitRatesArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.country_iso2 = %@",isd]];
            NSDictionary* iso=nil;
            if(res.count)
                iso = [res objectAtIndex:0];
            
            //for (NSDictionary *iso in obdDebitRatesArray)
            {
                //if ([[iso valueForKey:@"country_iso2"] isEqualToString:isd])
                if(iso.count)
                {
                    NSArray *prefixArray = [iso valueForKey:@"prefix_debits"];
                    NSNumber *max, *min;
                    long maxPrefix;
                    long minPrefix;
                    if (prefixArray.count > 0) {
                        hasPrefixValues = YES;
                        NSMutableArray *prefixDebitValues = [NSMutableArray arrayWithArray:[[iso valueForKey:@"prefix_debits"] allValues]];
                        max = [prefixDebitValues valueForKeyPath:@"@max.doubleValue"];
                        min = [prefixDebitValues valueForKeyPath:@"@min.doubleValue"];
                    }
                    
                    long callingRate = [[iso valueForKey:@"debits"] longValue];
                    
                    if (callingRate == -1) {
                        [country setValue:@"Not Supported" forKey:@"CALLING_RATE"];
                    }else{
                        if (hasPrefixValues) {
                            maxPrefix = [max longValue];
                            minPrefix = [min longValue];
                            minDebitRate = minPrefix / 100.0f;
                            maxDebitRate = maxPrefix / 100.0f;
                            if (0.00 == minDebitRate) {
                                minDebitRate = 0.01;
                            }
                            [country setValue:[NSString stringWithFormat:@"$ %.2lf - %.2lf /min",minDebitRate,maxDebitRate] forKey:@"CALLING_RATE"];
                            [country setValue:prefixArray forKey:@"prefix_debits"];
                        }else{
                            debitRates = callingRate / 100.0f;
                            [country setValue:[NSString stringWithFormat:@"$ %.2lf /min",debitRates] forKey:@"CALLING_RATE"];
                            [country setValue:@"" forKey:@"prefix_debits"];
                        }
                    }
                }
            }
        }else{
            [country setValue:@"Not Supported" forKey:@"CALLING_RATE"];
        }
        if (![country valueForKey:@"CALLING_RATE"]) {
            [country setValue:@"Not Supported" forKey:@"CALLING_RATE"];
        }
        [topFiveList addObject:country];
    }
    
    allCountriesList = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *country in [[Setting sharedSetting]getCountryList]) {
        hasPrefixValues = NO;
        NSString *isd =[country valueForKey:@"COUNTRY_SIM_ISO"];
        if (obdDebitRatesArray.count > 0) {
            for (NSDictionary *iso in obdDebitRatesArray) {
                if ([[iso valueForKey:@"country_iso2"] isEqualToString:isd]) {
                    NSArray *prefixArray = [iso valueForKey:@"prefix_debits"];
                    NSNumber *max, *min;
                    long maxPrefix;
                    long minPrefix;
                    if (prefixArray.count > 0) {
                        hasPrefixValues = YES;
                        NSMutableArray *prefixDebitValues = [NSMutableArray arrayWithArray:[[iso valueForKey:@"prefix_debits"] allValues]];
                        max = [prefixDebitValues valueForKeyPath:@"@max.doubleValue"];
                        min = [prefixDebitValues valueForKeyPath:@"@min.doubleValue"];
                    }
                    
                    long callingRate = [[iso valueForKey:@"debits"] longValue];
                    
                    if (callingRate == -1) {
                        [country setValue:@"Not Supported" forKey:@"CALLING_RATE"];
                    }else{
                        if (hasPrefixValues) {
                            maxPrefix = [max longValue];
                            minPrefix = [min longValue];
                            minDebitRate = minPrefix / 100.0f;
                            maxDebitRate = maxPrefix / 100.0f;
                            if (0.00 == minDebitRate) {
                                minDebitRate = 0.01;
                            }
                            [country setValue:[NSString stringWithFormat:@"$ %.2lf - %.2lf /min",minDebitRate,maxDebitRate] forKey:@"CALLING_RATE"];
                            [country setValue:prefixArray forKey:@"prefix_debits"];
                        }else{
                            debitRates = callingRate / 100.0f;
                            [country setValue:[NSString stringWithFormat:@"$ %.2lf /min",debitRates] forKey:@"CALLING_RATE"];
                            [country setValue:@"" forKey:@"prefix_debits"];
                        }
                    }
                }
            }
        }else{
            [country setValue:@"Not Supported" forKey:@"CALLING_RATE"];
        }
        if (![country valueForKey:@"CALLING_RATE"]) {
            [country setValue:@"Not Supported" forKey:@"CALLING_RATE"];
        }
        [allCountriesList addObject:country];
    }
    
    KLog(@"prepareCountryListDictionary - END");
}

- (IBAction)activateReachMe:(id)sender
{
    [self tableView: self.activateReachMeTable didSelectRowAtIndexPath: [NSIndexPath indexPathForRow: [sender tag] inSection: 1]];
}

- (void) forwardToDidSelect: (UITapGestureRecognizer *) tap
{
    [self tableView: self.activateReachMeTable didSelectRowAtIndexPath: [NSIndexPath indexPathForRow: tap.view.tag inSection: 1]];
}

- (NSString *)infoString:(NSIndexPath *)indexPath
{
    NSString *detailsString = @"";
    
    if (isReachMeSupported) {
        if (self.voiceMailInfo.reachMeIntl && self.voiceMailInfo.reachMeHome) {
            if (indexPath.row == 1) {
                detailsString = @"ReachMe Home Activate to get calls when number is unreachable > Get calls in the app when phone is switched off or out of coverage when in home country.";
            }else{
                detailsString = @"ReachMe International Activate to save International roaming charges > Get all calls in the app at zero roaming charges when traveling internationally.";
                
            }
        }else if (self.voiceMailInfo.reachMeIntl && self.voiceMailInfo.reachMeVM) {
            if (indexPath.row == 1) {
                detailsString = @"ReachMe Voicemail Activate if traveling or planning to travel > Get visual voicemails in the app. Manage, transcribe and withdraw sent voicemails.";
                
            }else{
                detailsString = @"ReachMe International Activate to save International roaming charges > Get all calls in the app at zero roaming charges when traveling internationally.";
                
            }
        }else if (self.voiceMailInfo.reachMeHome && self.voiceMailInfo.reachMeVM) {
            if (indexPath.row == 1) {
                detailsString = @"ReachMe Voicemail Activate if traveling or planning to travel > Get visual voicemails in the app. Manage, transcribe and withdraw sent voicemails.";
                
            }else{
                detailsString = @"ReachMe Home Activate to get calls when number is unreachable > Get calls in the app when phone is switched off or out of coverage when in home country.";
            }
        }else if (self.voiceMailInfo.reachMeIntl && !self.voiceMailInfo.reachMeHome && !self.voiceMailInfo.reachMeVM) {
            detailsString = @"ReachMe International Activate to save International roaming charges > Get all calls in the app at zero roaming charges when traveling internationally.";
        }else if (!self.voiceMailInfo.reachMeIntl && self.voiceMailInfo.reachMeHome && !self.voiceMailInfo.reachMeVM) {
            detailsString = @"ReachMe Home Activate to get calls when number is unreachable > Get calls in the app when phone is switched off or out of coverage when in home country.";
        }else if (!self.voiceMailInfo.reachMeIntl && !self.voiceMailInfo.reachMeHome && self.voiceMailInfo.reachMeVM) {
            detailsString = @"ReachMe Voicemail Activate if traveling or planning to travel > Get visual voicemails in the app. Manage, transcribe and withdraw sent voicemails.";
        }
        
        if (isReachMeNumber) {
            detailsString = @"Receive unlimited incoming calls over WiFi or mobile data. Make calls from primary number at cheaper rates, using ReachMe Wallet. View Calling Rates";
        }
        
    }else{
        if (indexPath.row == 0) {
            detailsString = [NSString stringWithFormat:@"ReachMe Roaming feature is not available with %@ at present. Contact support",self.currentNetworkName];
        }else if (indexPath.row == 1){
            detailsString = @"Get a ReachMe Number\n\nGet a new SIM-less number to make and receive calls over WiFi or mobile data. Numbers are available for select countries.";
        }else{
            detailsString = @"Make Calls on ReachMe\n\nMake calls over WiFi or mobile data. Same rates apply even when you are travelling internationally. ";
        }
    }
    
    return detailsString;
}

- (IBAction)editDetails:(id)sender
{
    NumberInfo *numberDetails = [[Setting sharedSetting]customNumberInfoForPhoneNumber:self.phoneNumber];
    EditNumberDetailsViewController *editNumberDetails = [[EditNumberDetailsViewController alloc]initWithNibName:@"EditNumberDetailsViewController" bundle:nil];
    editNumberDetails.phoneNumber = self.phoneNumber;
    editNumberDetails.titleName = numberDetails.titleName.length?numberDetails.titleName:@"";
    editNumberDetails.carrierName = self.currentNetworkName;
    editNumberDetails.voiceMailInfo = self.voiceMailInfo;
    editNumberDetails.isReachMeNumber = isReachMeNumber;
    [self.navigationController pushViewController:editNumberDetails animated:YES];
//    ReachMeStatusViewController *rmStatusVC = [[UIStoryboard storyboardWithName:@"IVSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ReachMeStatus"];
//    [self.navigationController pushViewController:rmStatusVC animated:YES];
//    PersonalisationViewController *personalisation = [[PersonalisationViewController alloc]initWithNibName:@"PersonalisationViewController" bundle:nil];
//    [self.navigationController pushViewController:personalisation animated:YES];
}

- (IBAction)requestSupport:(id)sender
{
    [self helpAction];
}

- (IBAction)finishSetup:(id)sender
{
    //[[ConfigurationReader sharedConfgReaderObj] setOnBoardingStatus:NO];
    PersonalisationViewController *personalisation = [[PersonalisationViewController alloc]initWithNibName:@"PersonalisationViewController" bundle:nil];
    [self.navigationController pushViewController:personalisation animated:YES];
    //[appDelegate createTabBarControllerItems];
}

- (BOOL)isActive
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
//    IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
//    NSString *activeString = [[ConfigurationReader sharedConfgReaderObj] getMissedCallReasonForTheNumber:self.phoneNumber];
    
    if (carrierDetails.isReachMeIntlActive || carrierDetails.isReachMeHomeActive || carrierDetails.isReachMeVMActive) {
        return YES;
    }
    
//    if (activeString.length && ccInfo) {
//        return YES;
//    }else if (carrierDetails.isReachMeIntlActive || carrierDetails.isReachMeHomeActive || carrierDetails.isReachMeVMActive) {
//        return YES;
//    }
    
    return NO;
}

- (IBAction)unLinkNumber:(id)sender
{
    
    if([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus]){
        if (!isReachMeSupported) {
            PersonalisationViewController *personalisation = [[PersonalisationViewController alloc]initWithNibName:@"PersonalisationViewController" bundle:nil];
            [self.navigationController pushViewController:personalisation animated:YES];
        }
        return;
    }
    
    if (isReachMeNumber) {
        //Navigate to cancel subscription page
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/instavoice-reachme/id1345352747?mt=8"] options:@{} completionHandler:nil];
        return;
    }
    
    if ([self isActive]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unlink number from account?" message:@"If you are unlinking the number from account, we will deactivate ReachMe For this number." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        
        UIAlertAction *continueToUnlink = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if([Common isNetworkAvailable] == NETWORK_AVAILABLE)
                [self deleteNumber];
            else
                [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        }];
        
        [alertController addAction:cancel];
        [alertController addAction:continueToUnlink];
        
        alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [self.navigationController presentViewController:alertController animated:true completion:nil];
    }
    
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        NSString *title = [NSString stringWithFormat:@"Confirm Delete\n %@",[Common getFormattedNumber:[@"+" stringByAppendingString:self.phoneNumber] withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        
        
        UIAlertController *alertController =   [UIAlertController
                                                alertControllerWithTitle:NSLocalizedString(title,nil)
                                                message:NSLocalizedString(@"You are about to delete this number from your account, are you sure?", nil)
                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Confirm", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self deleteNumber];
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alertController addAction:cancel];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    }else{
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    
}

- (void)deleteNumber
{
    [self showProgressBar];
    NSMutableArray *verifiedNumberDetails;
    NSMutableArray *verifiedNumbers;
    NSMutableArray *nonVerifiedNumberDetails;
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    
    verifiedNumberDetails = currentUserProfileDetails.additionalVerifiedNumbers;
    nonVerifiedNumberDetails = currentUserProfileDetails.additionalNonVerifiedNumbers;
    verifiedNumbers = [[NSMutableArray alloc]initWithArray:[verifiedNumberDetails valueForKeyPath:kContactIdKey]];
    
    NSString *phoneNumberToBeDeleted = self.phoneNumber;
    //Number should be verified number.
    NSMutableDictionary *dataDictionary = [self dataForUpdatationOfContactToServer:eContactDeleteType withPrimaryPhoneNumberStatus:NO withContactNumber:phoneNumberToBeDeleted withCountryCode:nil];
    
    ManageUserContactAPI* api = [[ManageUserContactAPI alloc]initWithRequest:dataDictionary];
    
    [api callNetworkRequest:api.request withSuccess:^(ManageUserContactAPI *req, NSMutableDictionary *responseObject) {
        [self hideProgressBar];
        if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
            //[self hideProgressBar];
            EnLogd(@"Error calling manage_user_contact %@ and api request %@",dataDictionary,api.request);
        } else {
            //[self hideProgressBar];
            if ([verifiedNumbers containsObject:phoneNumberToBeDeleted]) {
                [verifiedNumbers removeObject:phoneNumberToBeDeleted];
                
                for (NSDictionary *numberInfo in verifiedNumberDetails) {
                    if ([[numberInfo valueForKey:kContactIdKey] isEqualToString:phoneNumberToBeDeleted]) {
                        [verifiedNumberDetails removeObject:numberInfo];
                        break;
                    }
                }
            }
            [ScreenUtility showAlert:@"Number has been deleted successfully"];
            currentUserProfileDetails.additionalVerifiedNumbers = verifiedNumberDetails;
            currentUserProfileDetails.additionalNonVerifiedNumbers = nonVerifiedNumberDetails;
            [[Profile sharedUserProfile]writeProfileDataInFile];
            
            //Remove Carrier information of the secondary number if any in settings.
            [[Setting sharedSetting]updateCarrierSettingsInfoForDeletedSecondaryNumber:phoneNumberToBeDeleted];
            
            //Remove Number information of the secondary number if any in settings.
            [[Setting sharedSetting]updateNumberSettingsInfoForDeletedSecondaryNumber:phoneNumberToBeDeleted];
            
            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController *aViewController in allViewControllers) {
                if ([aViewController isKindOfClass:[IVSettingsListViewController class]]) {
                    [[ConfigurationReader sharedConfgReaderObj] setOTPVerified:NO];
                    [self.navigationController popToViewController:aViewController animated:YES];
                }
            }
        }
        
    } failure:^(ManageUserContactAPI *req, NSError *error) {
        [self hideProgressBar];
        EnLogd(@"Error calling manage_user_contact api: %@, Error",dataDictionary,[error description]);
        NSInteger errorCode = error.code;
        NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
        if(error.code == kPrimaryNumberCanNotDeleteErrorCode){
            //[self fetchUserContacts];
            errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
        }
        if([errorMsg length]) {
            //OCT 13, 2016 [ScreenUtility showAlertMessage: errorMsg];
            [ScreenUtility showAlert: errorMsg];
        }
        
    }];
    
}

- (NSMutableDictionary *)dataForUpdatationOfContactToServer:(NSInteger)withUpdationType withPrimaryPhoneNumberStatus:(BOOL)withPhoneNumberStatus withContactNumber:(NSString *)withContactNumber withCountryCode:(NSString *)withCountryCode{
    
    NSString *operation;
    NSNumber *isPrimaryStatus = [NSNumber numberWithBool:withPhoneNumberStatus];
    NSMutableDictionary *dataInfo = [[NSMutableDictionary alloc]init];
    
    switch (withUpdationType) {
        case eContactAddType: {
            operation = @"a";
            [dataInfo setValue:withCountryCode forKey:@"country_code"];
            break;
        }
        case eContactDeleteType:
            operation = @"d";
            break;
        case eContactUpdateType:
            operation = @"u";
            break;
        default:
            break;
    }
    NSString *phoneNumber = [withContactNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [dataInfo setValue:phoneNumber forKey:@"contact"];
    [dataInfo setValue:@"p" forKey:@"contact_type"];
    [dataInfo setValue:operation forKey:@"operation"];
    [dataInfo setValue:isPrimaryStatus forKey:@"set_as_primary"];
    return dataInfo;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)url inRange:(NSRange)characterRange
{
    NSString *urlString = [NSString stringWithFormat:@"%@",url];
    if (isReachMeNumber) {
        if ([urlString isEqualToString:@"ReachMeNumber"]) {
            [appDelegate.tabBarController setSelectedIndex:3];
            [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[3]];
        }else{
            [self callingRates];
        }
    }else{
        if (!urlString.length) {
            [self helpAction];
        }
    }
    return YES;
}

- (NSString *)carrierName
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    NSString *networkName = @"";
    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.phoneNumber];
    if (carrierInfo) {
        networkName = carrierInfo.networkName;
    }else{
        
        if (carrierDetails) {
            
            if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
                networkName = @"Unknown Carrier";
            }else{
                networkName = @"";
            }
        }else{
            networkName = @"Carrier not Selected";
        }
    }
    
    if (!self.voiceMailInfo || !self.voiceMailInfo.countryVoicemailSupport) {
        networkName = @"Not supported";
    }
    
    return networkName;
}

- (NSString *)titleName
{
    NumberInfo *numberDetails = [[Setting sharedSetting]customNumberInfoForPhoneNumber:self.phoneNumber];
    NSString* contactNumber = [Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    NSString* titleName = @"";
    if (numberDetails.titleName.length > 0) {
        titleName = numberDetails.titleName;
    }else{
        titleName = contactNumber;
    }
    
    return titleName;
}

- (NSString *)getCountryCode:(NSString *)phoneNumber
{
    NSArray *countryList;
    NSString* archiveFilePathCountry = [[IVFileLocator getDocumentDirectoryPath]
                                        stringByAppendingPathComponent:@"Country.dat"];
    @try {
        countryList = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePathCountry];
    }
    @catch (NSException *exception) {
        KLog(@"Unable to create object from archive file");
    }
    
    NSString *countryCode = @"";
    
    UserProfileModel *model = [[Profile sharedUserProfile]profileData];
    NSMutableArray *phoneNumberDetails = model.additionalVerifiedNumbers;
    for (int i = 0; i < phoneNumberDetails.count; i++) {
        if ([[[phoneNumberDetails objectAtIndex:i] valueForKey:@"contact_id"] isEqualToString:phoneNumber]) {
            countryCode = [[phoneNumberDetails objectAtIndex:i] valueForKey:@"country_code"];
        }
    }
    
    NSMutableArray *countries = [NSMutableArray arrayWithArray:countryList];
    NSString* countryISO = @"";
    if(countries != nil && [countries count] >0)
    {
        for(NSMutableDictionary* dic in countries)
        {
            NSString *code = [dic valueForKey:COUNTRY_CODE];
            if([code isEqualToString:countryCode])
            {
                countryISO = [dic valueForKey:COUNTRY_NAME];
            }
        }
    }
    
    return countryISO;
}

-(NSString *) getFlagFromCountryName : (NSString *)countryName
{
    NSString *country_flag = countryName;
    
    for(int i=0;i<[country_flag length];i++)
    {
        if([country_flag characterAtIndex:i]==' ')
        {
            country_flag = [country_flag stringByReplacingOccurrencesOfString:@" "
                                                                   withString:@"-"];
        }
    }
    
    return country_flag;
}

#pragma mark - Private Methdos -

- (void)loadLatestDataFromServer {
    
    KLog(@"loadLatestDataFromServer");
    
    self.currentSettingsModel = [Setting sharedSetting].data;
    if (self.currentSettingsModel) {
        if (self.currentSettingsModel.voiceMailInfo && [self.currentSettingsModel.voiceMailInfo count]) {
            for (VoiceMailInfo *voiceMailInfo in self.currentSettingsModel.voiceMailInfo) {
                if([voiceMailInfo.phoneNumber isEqualToString:self.phoneNumber]) {
                    self.voiceMailInfo = voiceMailInfo;
                }
            }
            
        }
    }
}

- (NSString *)currentCarrierName:(NSString *)withPhoneNumber withCarrierList:(NSArray *)withCarrierList {
    
    NSString *carrierName = kSelectCarrierButtonTitle;
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:withPhoneNumber];
    
    if (carrierDetails) {
        
        if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
            self.selectedCountryCarrierInfo = nil;
            self.currentNetworkName = kNotListedButtonTitle;
            carrierName = self.currentNetworkName;
            return carrierName;
        }
        
        
        if (self.currentCarrierList && [self.currentCarrierList count]) {
            
            //We have carrier list and also custom settings - get the name of custom settings carrier name.
            for (IVSettingsCountryCarrierInfo *countryCarrierInfo in self.currentCarrierList) {
                if ([countryCarrierInfo.networkId isEqualToString:carrierDetails.networkId] && [countryCarrierInfo.vsmsNodeId isEqual:carrierDetails.vSMSId]&& [countryCarrierInfo.countryCode isEqualToString:carrierDetails.countryCode]) {
                    self.selectedCountryCarrierInfo = countryCarrierInfo;
                    self.currentNetworkName = countryCarrierInfo.networkName;
                    carrierName = self.currentNetworkName;
                    self.isValidCarrierName = YES;
                    break;
                }
            }
        }
        else {
            self.currentNetworkName = kSelectCarrierButtonTitle;
            carrierName = self.currentNetworkName;
            self.isValidCarrierName = NO;
            self.selectedCountryCarrierInfo = nil;
            //[self showLoadingIndicator];
            [[Setting sharedSetting]fetchListOfCarriersForCountry:self.voiceMailInfo.carrierCountryCode];
        }
    }
    else {
        BOOL checkForVoiceMailInfo = NO;
        //Check for the primary number
        NSString *primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
        if ([primaryNumber isEqualToString:self.phoneNumber]) {
            //Yes, phone number is same as the primary phone number.
            //Check for the SIM info.
            if ([[Setting sharedSetting]hasValidSimInfoForPhoneNumber:primaryNumber]) {
                
                if ([[Setting sharedSetting]hasSupportedSimCarrierInfo:primaryNumber]) {
                    //Yes, we have supported carrier info in the carrier list.
                    self.isValidCarrierName = YES;
                    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromSimInfoForPhoneNumber:primaryNumber];
                    self.currentNetworkName = carrierInfo.networkName;
                    self.selectedCountryCarrierInfo = carrierInfo;
                    carrierName = self.currentNetworkName;
                }
                else {
                    self.currentNetworkName = kSelectCarrierButtonTitle;
                    checkForVoiceMailInfo = YES;
                    self.isValidCarrierName = NO;
                    self.selectedCountryCarrierInfo = nil;
                }
            }
            else {
                //We do not have carrier list.
                self.currentNetworkName = kSelectCarrierButtonTitle;
                checkForVoiceMailInfo = YES;
            }
        }
        
        if (checkForVoiceMailInfo) {
            //We do not have custom carrier information.
            //Check do we have voicemail info.
            if (self.voiceMailInfo) {
                if (self.voiceMailInfo.isVoiceMailEnabled) {
                    //Check do we have carrier list
                    if (self.currentCarrierList && [self.currentCarrierList count]) {
                        //We have only voice mail info - custom carrier information we do not have, so Voicemail information takes higher priority.
                        
                        if ([[Setting sharedSetting]hasSupportedVoiceMailInfo:self.phoneNumber]) {
                            
                            IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromVoiceMailInfoForPhoneNumber:self.phoneNumber];
                            carrierName = carrierInfo.networkName;
                            self.currentNetworkName = carrierName;
                            self.isValidCarrierName = YES;
                            self.selectedCountryCarrierInfo = carrierInfo;
                        }
                        else {
                            self.currentNetworkName = kSelectCarrierButtonTitle;
                            self.isValidCarrierName = NO;
                            self.selectedCountryCarrierInfo = nil;
                        }
                    }
                    else {
                        //We do not have carrier list
                        self.currentNetworkName = kSelectCarrierButtonTitle;
                        carrierName = self.currentNetworkName;
                        self.isValidCarrierName = NO;
                        self.selectedCountryCarrierInfo = nil;
                        //[self showLoadingIndicator];
                        [[Setting sharedSetting]fetchListOfCarriersForCountry:self.voiceMailInfo.carrierCountryCode];
                    }
                }
                else
                {
                    self.currentNetworkName = kSelectCarrierButtonTitle;
                    carrierName = self.currentNetworkName;
                    self.isValidCarrierName = NO;
                    self.selectedCountryCarrierInfo = nil;
                }
            }
            else {
                self.currentNetworkName = kSelectCarrierButtonTitle;
                carrierName = self.currentNetworkName;
                self.isValidCarrierName = NO;
                self.selectedCountryCarrierInfo = nil;
            }
        }
    }
    if (!self.voiceMailInfo || !self.voiceMailInfo.countryVoicemailSupport) {
        carrierName = @"Not supported";
    }
    return carrierName;
    
}

- (void)updateUIBasedOnVoiceMailInfo:(VoiceMailInfo *)withVoiceMailInfo {
    
    //Get the current custom carrier details
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    
    IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
    self.additionalActiInfo = ccInfo.ussdInfo.additionalActiInfo;
    
    //NOV 17, 2016
    // If no carrier is supported voicemail, just return
    // Server is giving bunch of data which are not needed when no carrier is suppotted.
    // TODO: Check with Ajay.
    if(!self.voiceMailInfo.countryVoicemailSupport) {
        self.carrierDetailsText = NSLocalizedString(@"Sorry, ReachMe Voicemail service is not available in your region at the moment. We are working hard to make it available for every carrier in the world,  you can help us prioritise <carrier name> by requesting support below.", nil);
        self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not supported", nil);
        [self.activateReachMeTable reloadData];
        return;
    }
    //
    
    //Check for carrierdetails
    if (carrierDetails) {
        if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
            
            //No, We do not have ussd string info
            self.isVoiceMailAndMissedCallDeactivated = NO;
            self.isCarrierSupportedForVoiceMailSetup = NO;
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
            self.carrierDetailsText = NSLocalizedString(@"Sorry, ReachMe Voicemail service is not available in your region at the moment. We are working hard to make it available for every carrier in the world,  you can help us prioritise <carrier name> by requesting support below.", nil);
            [self.activateReachMeTable reloadData];
            return;
        }
        //Yes, we have carrier details
        //check for voicemail info
        if (withVoiceMailInfo) {
            //we have voicemail info.
            if (withVoiceMailInfo.isVoiceMailEnabled) {
                //voicemail enabled- check for custom settings -  USSD string
                //Check we have ussd info
                if (self.currentCarrierList && [self.currentCarrierList count]) {
                    
                    if ([[Setting sharedSetting]hasSupportedCustomCarrierInfo:self.phoneNumber]) {
                        
                        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
                        if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                            //Yes, We have supported carrier info
                            self.isVoiceMailAndMissedCallDeactivated = YES;
                            self.isCarrierSupportedForVoiceMailSetup = YES;
                            [self.activateReachMeTable reloadData];
                            return;
                        }
                        else {
                            //No, We do not have ussd string info
                            self.isVoiceMailAndMissedCallDeactivated = NO;
                            self.isCarrierSupportedForVoiceMailSetup = NO;
                        }
                    }
                    else {
                        self.isVoiceMailAndMissedCallDeactivated = NO;
                        self.isCarrierSupportedForVoiceMailSetup = NO;
                    }
                }
                else {
                    //No, We do not have ussd string info
                    self.isVoiceMailAndMissedCallDeactivated = NO;
                    self.isCarrierSupportedForVoiceMailSetup = NO;
                }
            }
            else {
                
                if ([[Setting sharedSetting]hasSupportedCustomCarrierInfo:self.phoneNumber]) {
                    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
                    
                    if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                        //Yes, We have supported carrier info
                        self.isVoiceMailAndMissedCallDeactivated = YES;
                        self.isCarrierSupportedForVoiceMailSetup = YES;
                        
                    } else {
                        self.isVoiceMailAndMissedCallDeactivated = NO;
                        self.isCarrierSupportedForVoiceMailSetup = NO;
                    }
                }
                else {
                    self.isVoiceMailAndMissedCallDeactivated = NO;
                    self.isCarrierSupportedForVoiceMailSetup = NO;
                }
            }
            
            if (self.isCarrierSupportedForVoiceMailSetup && self.isVoiceMailAndMissedCallDeactivated) {
                IVSettingsCountryCarrierInfo *supportedCarrierInfo =
                [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
                self.activationDialNumber = supportedCarrierInfo.ussdInfo.actiAll;
                self.deactivateDialNumber = supportedCarrierInfo.ussdInfo.deactiAll;
            }
            
            if (!self.isValidCarrierName) {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
                self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
                [self.activateReachMeTable reloadData];
                return;
            }
            
            if (self.isValidCarrierName && self.isCarrierSupportedForVoiceMailSetup && self.isVoiceMailAndMissedCallDeactivated && !self.voiceMailInfo.isVoiceMailEnabled) {
                //Set the current screen based on the voice mail configured status
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not Enabled", nil);
                self.carrierDetailsText = NSLocalizedString(@"Activate ReachMe to start receiving voicemails and missed calls", nil);
            }
            else if (self.isValidCarrierName && !self.isCarrierSupportedForVoiceMailSetup && !self.isVoiceMailAndMissedCallDeactivated){
                //self.currentScreen = eCarrierNotSupportedScreen;
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
                self.carrierDetailsText = NSLocalizedString(@"Sorry, ReachMe Voicemail service is not available in your region at the moment. We are working hard to make it available for every carrier in the world,  you can help us prioritise <carrier name> by requesting support below.", nil);
            }
            else {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
                self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
                
            }
        }
        else {
            //voicemail is not enabled. - check for the USSD string of custom settings.
            if (self.currentCarrierList && [self.currentCarrierList count]) {
                
                if ([[Setting sharedSetting] hasSupportedCustomCarrierInfo:self.phoneNumber]) {
                    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
                    if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                        self.isVoiceMailAndMissedCallDeactivated = YES;
                        self.isCarrierSupportedForVoiceMailSetup = YES;
                    }
                    else {
                        self.isVoiceMailAndMissedCallDeactivated = NO;
                        self.isCarrierSupportedForVoiceMailSetup = NO;
                    }
                }
                else {
                    self.isVoiceMailAndMissedCallDeactivated = NO;
                    self.isCarrierSupportedForVoiceMailSetup = NO;
                }
            }
            else {
                self.isVoiceMailAndMissedCallDeactivated = NO;
                self.isCarrierSupportedForVoiceMailSetup = NO;
            }
            
            if (self.isCarrierSupportedForVoiceMailSetup && self.isVoiceMailAndMissedCallDeactivated) {
                
                IVSettingsCountryCarrierInfo *supportedCarrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
                self.activationDialNumber = supportedCarrierInfo.ussdInfo.actiAll;
                self.deactivateDialNumber = supportedCarrierInfo.ussdInfo.deactiAll;
            }
            
            if (!self.isValidCarrierName) {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
                self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
                [self.activateReachMeTable reloadData];
                return;
            }
            if (self.isValidCarrierName && self.isCarrierSupportedForVoiceMailSetup && self.isVoiceMailAndMissedCallDeactivated && !self.voiceMailInfo.isVoiceMailEnabled) {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not Enabled", nil);
                self.carrierDetailsText = NSLocalizedString(@"Activate ReachMe to start receving voicemails and missed calls", nil);
                
            }
            else if (self.isValidCarrierName && !self.isCarrierSupportedForVoiceMailSetup && !self.isVoiceMailAndMissedCallDeactivated) {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
                self.carrierDetailsText = NSLocalizedString(@"Sorry, ReachMe Voicemail service is not available in your region at the moment. We are working hard to make it available for every carrier in the world,  you can help us prioritise <carrier name> by requesting support below.", nil);
            }
            else {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
                self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
                
            }
        }
    }
    else {
        
        BOOL checkForVoiceMailInfo = NO;
        //Check for the primary number
        NSString *primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
        if ([primaryNumber isEqualToString:self.phoneNumber]) {
            //Yes, phone number is same as the primary phone number.
            //Check for the SIM info.
            if ([[Setting sharedSetting]hasValidSimInfoForPhoneNumber:primaryNumber]) {
                
                if ([[Setting sharedSetting]hasSupportedSimCarrierInfo:primaryNumber]) {
                    
                    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromSimInfoForPhoneNumber:primaryNumber];
                    if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                        
                        if (withVoiceMailInfo) {
                            if (withVoiceMailInfo.isVoiceMailEnabled) {
                                //Yes, we have supported carrier info in the carrier list.
                                self.isVoiceMailAndMissedCallDeactivated = YES;
                                self.isCarrierSupportedForVoiceMailSetup = YES;
                                self.isValidCarrierName = YES;
                                [self.activateReachMeTable reloadData];
                                return;
                            }
                            else {
                                self.isVoiceMailAndMissedCallDeactivated = YES;
                                self.isCarrierSupportedForVoiceMailSetup = YES;
                                self.hasCarrierSelectedFromSim = YES;
                                IVSettingsCountryCarrierInfo *supportedCarrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromSimInfoForPhoneNumber:self.phoneNumber];
                                self.activationDialNumber = supportedCarrierInfo.ussdInfo.actiAll;
                                self.deactivateDialNumber = supportedCarrierInfo.ussdInfo.deactiAll;
                                self.additionalActiInfo = supportedCarrierInfo.ussdInfo.additionalActiInfo;
                            }
                        }
                        else {
                            self.isVoiceMailAndMissedCallDeactivated = YES;
                            self.isCarrierSupportedForVoiceMailSetup = YES;
                            self.hasCarrierSelectedFromSim = YES;
                        }
                        
                    }
                    else {
                        self.isVoiceMailAndMissedCallDeactivated = YES;
                        self.isCarrierSupportedForVoiceMailSetup = YES;
                        self.hasCarrierSelectedFromSim = YES;
                    }
                }
                else {
                    self.isVoiceMailAndMissedCallDeactivated = NO;
                    self.isCarrierSupportedForVoiceMailSetup = NO;
                }
            }
            
            else {
                checkForVoiceMailInfo = YES;
            }
        }
        
        if (checkForVoiceMailInfo) {
            
            if (withVoiceMailInfo) {
                
                if (withVoiceMailInfo.isVoiceMailEnabled) {
                    
                    if (self.currentCarrierList && [self.currentCarrierList count]) {
                        
                        if ([[Setting sharedSetting]hasSupportedVoiceMailInfo:self.phoneNumber]) {
                            
                            IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromVoiceMailInfoForPhoneNumber:self.phoneNumber];
                            if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                                //Yes, we have supported carrier info in the carrier list.
                                self.isVoiceMailAndMissedCallDeactivated = YES;
                                self.isCarrierSupportedForVoiceMailSetup = YES;
                                self.isValidCarrierName = YES;
                                [self.activateReachMeTable reloadData];
                                return;
                            }
                            else {
                                self.isVoiceMailAndMissedCallDeactivated = NO;
                                self.isCarrierSupportedForVoiceMailSetup = NO;
                            }
                        }
                        else {
                            self.isVoiceMailAndMissedCallDeactivated = NO;
                            self.isCarrierSupportedForVoiceMailSetup = NO;
                        }
                    }
                    else {
                        self.isVoiceMailAndMissedCallDeactivated = NO;
                        self.isCarrierSupportedForVoiceMailSetup = NO;
                    }
                }
                else {
                    self.isVoiceMailAndMissedCallDeactivated = NO;
                    self.isCarrierSupportedForVoiceMailSetup = NO;
                }
            }
            else {
                self.isVoiceMailAndMissedCallDeactivated = NO;
                self.isCarrierSupportedForVoiceMailSetup = NO;
            }
        }
        
        if (!self.isValidCarrierName) {
            
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
            self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
            [self.activateReachMeTable reloadData];
            return;
        }
        
        if (self.isValidCarrierName && self.isCarrierSupportedForVoiceMailSetup && self.isVoiceMailAndMissedCallDeactivated && !self.voiceMailInfo.isVoiceMailEnabled)  {
            
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not Enabled", nil);
            self.carrierDetailsText = NSLocalizedString(@"Activate ReachMe to start receiving voicemails and missed calls", nil);
        }
        else if (self.isValidCarrierName && !self.isCarrierSupportedForVoiceMailSetup && !self.isVoiceMailAndMissedCallDeactivated){
            //self.currentScreen = eCarrierNotSupportedScreen;
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
            self.carrierDetailsText = NSLocalizedString(@"Sorry, ReachMe Voicemail service is not available in your region at the moment. We are working hard to make it available for every carrier in the world,  you can help us prioritise <carrier name> by requesting support below.", nil);
        }
        else {
            
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
            self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
        }
        
        if (self.hasCarrierSelectedFromSim && !self.hasShownSimCarrierAlert) {
            //Show the alert
            //Update the server about the carrier selected by sim.
            [self didSelectCarrier:[[Setting sharedSetting]supportedCarrierInfoFromSimInfoForPhoneNumber:self.phoneNumber]];
            
            self.hasShownSimCarrierAlert = YES;
            NSString *message = [NSString stringWithFormat:@"%@ identified through SIM", self.currentNetworkName];
            UIAlertController *alertController =   [UIAlertController
                                                    alertControllerWithTitle:nil
                                                    message:message
                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"OK", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alertController dismissViewControllerAnimated:NO completion:nil];
                                     
                                 }];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
            [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        }
    }
    //Reload tableView
    [self.activateReachMeTable reloadData];
}

#pragma mark - Carrier Search Delegate Methods -
- (void)didSelectCarrier:(IVSettingsCountryCarrierInfo *)selectedCarrierInfo {
    //If its nil - send server NETWORK ID: -1,NODE ID: -1,COUNTRY CODE: -1, USSD String: Null
    CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
    currentCarrierInfo.phoneNumber = self.phoneNumber;
    self.selectedCountryCarrierInfo = selectedCarrierInfo;
    if(selectedCarrierInfo) {
        currentCarrierInfo.countryCode = self.selectedCountryCarrierInfo.countryCode;
        currentCarrierInfo.networkId = self.selectedCountryCarrierInfo.networkId;
        currentCarrierInfo.vSMSId = self.selectedCountryCarrierInfo.vsmsNodeId;
        
        //END
    }
    else {
        currentCarrierInfo.countryCode = [NSString stringWithFormat:@"%d", -1];
        currentCarrierInfo.networkId = [NSString stringWithFormat:@"%d", -1];
        currentCarrierInfo.vSMSId = [NSNumber numberWithInteger:-1];
        
    }
    self.currentNetworkName = selectedCarrierInfo.networkName;
    [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
    //Update the carrier info
    [self updateUIBasedOnVoiceMailInfo:self.voiceMailInfo];
}

- (ActivatereachMeTableViewCell *)activateReachMeCell {
    
    if (!_activateReachMeCell)
        _activateReachMeCell = [self.activateReachMeTable dequeueReusableCellWithIdentifier:kReachMeNumberEnableCellIdentifier];
    
    return _activateReachMeCell;
    
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
