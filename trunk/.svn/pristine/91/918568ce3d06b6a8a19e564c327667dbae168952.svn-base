//
//  IVPrimaryNumberVoiceMailViewController.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 28/07/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "IVPrimaryNumberVoiceMailViewController.h"
#import "IVVoiceMailCarrierSelectionProtocol.h"
#import "IVPrimaryNumberVoiceMailTableViewCell.h"
#import "IVVoiceMailDeActivateViewController.h"
#import "IVVoiceMailVerifyInstaVoiceViewController.h"
#import "EditVoiceMailImageIconViewController.h"
#import "IVVoiceMailActivateViewController.h"

#import "IVSettingsCountryCarrierInfo.h"
#import "Common.h"

#import "ManageUserContactAPI.h"
#import "NBPhoneNumberUtil.h"
#import "ContactDetailData.h"
#import "InsideConversationScreen.h"
#import "IVFileLocator.h"

#import "FetchCarriersListAPI.h"
#import "MZFormSheetController.h"
#import "UserProfileModel.h"
#import "UpdateUserProfileAPI.h"
#import "MyProfileApi.h"

#import "IVCarrierSearchViewController.h"
#import "IVCarrierSearchProtocol.h"

#import "NetworkCommon.h"

//Settings
#import "Setting.h"

#import "Profile.h"

//HLR API
#import "VoiceMailHLRAPI.h"

#define kCarrierNotSupporttedText @"Sorry, InstaVoice Voicemail Service is not available in your region at the moment. We are working hard to make it available very soon."

#define kCarrierNotSupporttedHelpText @"Hi, I'm interested in InstaVoice Voicemail/Missed Call alerts. Please inform me when it's made available for my Carrier:"

#define kErrorCodeForCarrierListNotFound 20
#define kPrimaryNumberVoiceMailCellIdentifier @"IVPrimaryNumberCell"
#define kPrimaryNumberVoiceMailInfoCellIdentifier @"IVPrimaryNumberInfoCell"
#define kPrimaryNumberVoiceMailActivateCellIdentifier @"IVPrimaryNumberActivateCell"
#define kPrimaryNumberReachMeCellIdentifier @"IVPrimaryNumberReachMeCell"

#define kNumberOfSections 4
#define kNumberOfRows 1
#define kHeaderHeight 54
#define kRowHeight 44
#define kContactIdKey @"contact_id"
#define kCountryCodeKey @"country_code"

#define kSelectCarrierButtonTitle @"Select Your Carrier"
#define kNotListedButtonTitle @"Not listed"

//Enums
typedef NS_ENUM(NSUInteger,PrimaryNumberSections){
    ePrimaryNumberSection = 0,
    ePhoneNumberCarrierSection,
    eVoiceMailAndMissedCallAlertSection,
    eActivateOrVerifyInstaVoiceSection,
    eReachMeEnableOrDisable
};

@interface IVPrimaryNumberVoiceMailViewController ()<IVVoiceMailCarrierSelectionProtocol, SettingProtocol, UIAlertViewDelegate, ProfileProtocol, IVCarrierSearchDelegate,UITextViewDelegate,UITextFieldDelegate>{
    NSInteger numberOfSections;
    CGFloat sectionFooterHeight;
    UIView *activateBackGroundView;
}

- (IBAction)deActivateVoiceMail:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *deActivateButton;
@property (weak, nonatomic) IBOutlet UITableView *primaryNumberVoiceMailTableView;
@property (nonatomic, strong) SettingModel *currentSettingsModel;
@property (nonatomic, strong) UserProfileModel *currentUserProfileDetails;

@property (nonatomic, strong) IVCarrierSearchViewController *carrierSearchViewController;
@property (nonatomic, strong) IVSettingsCountryCarrierInfo *selectedCountryCarrierInfo;

@property (nonatomic, strong) NSString *currentNetworkName;
@property (nonatomic, strong) NSString *helpText;
@property (nonatomic, strong) NSString *activationDialNumber;
@property (nonatomic, strong) NSMutableArray *helpTextArray;
@property (nonatomic, strong) NSMutableArray *supportContactList;
@property (nonatomic, strong) NSArray *currentCarrierList;
@property (nonatomic, strong) NSArray *sectionTitleArray;
@property (nonatomic, strong) NSString *deactivateDialNumber;

@property (nonatomic, assign) BOOL isValidCarrierName;
@property (nonatomic, assign) BOOL anyMCanyTime;
@property (nonatomic, assign) BOOL anyMClast30Days;
@property (nonatomic, assign) BOOL hasCarrierSelectedFromSim;
@property (nonatomic, assign) BOOL hasShownSimCarrierAlert;
@property (nonatomic, assign) BOOL isActivationRequested;
@property (nonatomic, assign) BOOL isActivationFailed;
@property (nonatomic, assign) BOOL isActivationSuccess;
@property (nonatomic, assign) BOOL isReachMeCallEnabled;

@property (nonatomic, strong) NSString *carrierSelectionOrEnableStatus;
@property (nonatomic, assign) BOOL isCarrierSupportedForVoiceMailSetup;
@property (nonatomic, assign) BOOL isVoiceMailAndMissedCallDeactivated;
@property (nonatomic, strong) NSString *carrierDetailsText;
@property (nonatomic, strong) NSString *additionalActiInfo;
@property (nonatomic, strong) NSString *titleName;
@property (nonatomic, strong) NSString *imageName;

@end

@implementation IVPrimaryNumberVoiceMailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isValidCarrierName = NO;
    numberOfSections = 5;
    
    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@NO forKey:kUserSettingsFetched];
    [userDefaults synchronize];
    
    //Get the missed call information.
    self.primaryNumber = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
    //[appDelegate.engObj getMissedCallInfo:self.primaryNumber];
    
    self.isValidCarrierName = NO;
    
    BOOL isVoicemailSupported = [[ConfigurationReader sharedConfgReaderObj]getVoicemailSupportedFlag];
    if(isVoicemailSupported) {
        self.carrierDetailsText =  NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
        self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
        numberOfSections = 5;
    } else {
        self.carrierDetailsText =  NSLocalizedString(kCarrierNotSupporttedText, nil);
        self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
        numberOfSections = 3;
    }
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer: tapRec];
    
    self.title = NSLocalizedString(@"Primary Number", nil);
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpAction)];
    self.navigationItem.rightBarButtonItem = helpButton;
    
    self.currentNetworkName = NSLocalizedString(kSelectCarrierButtonTitle, nil);
    self.sectionTitleArray = @[@"", @"", @"", @""];
    
    // Do any additional setup after loading the view.
}

- (NSString *)getCountryCode
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
        if ([[[phoneNumberDetails objectAtIndex:i] valueForKey:@"contact_id"] isEqualToString:self.primaryNumber]) {
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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.isActivationFailed = NO;
    self.isActivationRequested = NO;
    self.isActivationSuccess = NO;
    
    //For Testing Purpose
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:4];
//    notification.alertTitle = @"ACTIVATION SUCCESSFULL";
//    notification.alertBody = [NSString stringWithFormat:@"InstaVoice is active on %@",[Common getFormattedNumber:self.primaryNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.primaryNumber,@"phone_number",@"hlr_activation",@"notification_type", nil];
//    notification.userInfo = userInfo;
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    //Get the settings information.
    [Setting sharedSetting].delegate = self;
    
    [Profile sharedUserProfile].delegate = self;
    
    self.uiType = VOICEMAIL_PRIMARY_NUMBER_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    
    [self loadLatestDataFromServer];
    
    NumberInfo *numberDetails = [[Setting sharedSetting]customNumberInfoForPhoneNumber:self.primaryNumber];
    
    if(numberDetails.imgName.length > 0){
        self.imageName = numberDetails.imgName;
    }else{
        self.imageName = @"iphone";
    }
    
    if (numberDetails.titleName.length > 0) {
        self.titleName = numberDetails.titleName;
    }else{
        self.titleName = [NSString stringWithFormat:@"%@ Number", [self getCountryCode]];
    }
    
    [[[self navigationController] navigationBar] setNeedsLayout];
    
    NSArray *listOfCarriers = [[Setting sharedSetting]carrierListForCountry:self.voiceMailInfo.carrierCountryCode];
    if (listOfCarriers && [listOfCarriers count]) {
        //We have list of carriers.
        self.currentCarrierList = listOfCarriers;
        //Reload Data - Current Network Name and reload the tableView.
        //Determine the network name from the network ID.
        self.currentNetworkName = [self currentCarrierName:self.primaryNumber withCarrierList:self.currentCarrierList];
        
        //OCT 27, 2016
        IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.primaryNumber];
        self.additionalActiInfo = ccInfo.ussdInfo.additionalActiInfo;
        if(!self.additionalActiInfo.length) {
            KLog(@"Debug");
            //self.AdditionalActiInfo = @"Please goto the website www.metrpcs.com and add the value bundle to enable the call.";
        }
        //
        
        //TODO: Need to check the logic.!!
        [self updateUIBasedOnVoiceMailInfo:self.voiceMailInfo];
        
    }
    else {
        self.currentCarrierList = nil;
        //We do not have list of carriers - so start fetching list of carriers for the country.
        [[Setting sharedSetting]fetchListOfCarriersForCountry:self.voiceMailInfo.carrierCountryCode];
    }
    
    if(!self.voiceMailInfo.countryVoicemailSupport) {
        self.carrierDetailsText = NSLocalizedString(@"Sorry, InstaVoice Voicemail service is not available in your region at the moment. We are working hard to make it available very soon.", nil);
        self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not supported", nil);
        numberOfSections = 2;
    }
    
    //Settings - TextFlow related changes notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@NO forKey:kUserSettingsFetched];
        [userDefaults synchronize];
        [[Setting sharedSetting]getUserSettingFromServer];
        [[Profile sharedUserProfile] getProfileDataFromServer];
        [self configureHelpAndSuggestion];
    }
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    NumberInfo *currentNumberInfo = [[NumberInfo alloc]init];
    currentNumberInfo.phoneNumber = self.primaryNumber;
    currentNumberInfo.imgName = self.imageName;
    currentNumberInfo.titleName = self.titleName;
    [[Setting sharedSetting]updateNumberSettingsInfo:currentNumberInfo];
    
}

#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    [self.primaryNumberVoiceMailTableView reloadData];
}

- (void)showDeactivateButton
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
    
    if ([self primaryNumberIsActive] && carrierDetails && self.voiceMailInfo.countryVoicemailSupport)
        self.deActivateButton.hidden = NO;
    else
        self.deActivateButton.hidden = YES;

}

#pragma mark - Carrier Search Delegate Methods -
- (void)didSelectCarrier:(IVSettingsCountryCarrierInfo *)selectedCarrierInfo {
    //If its nil - send server NETWORK ID: -1,NODE ID: -1,COUNTRY CODE: -1, USSD String: Null
    CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
    currentCarrierInfo.phoneNumber = self.primaryNumber;
    self.selectedCountryCarrierInfo = selectedCarrierInfo;
    if(selectedCarrierInfo) {
        currentCarrierInfo.countryCode = self.selectedCountryCarrierInfo.countryCode;
        currentCarrierInfo.networkId = self.selectedCountryCarrierInfo.networkId;
        currentCarrierInfo.vSMSId = self.selectedCountryCarrierInfo.vsmsNodeId;
        currentCarrierInfo.isVoipEnabled = self.voiceMailInfo.isVoipEnabled;
        currentCarrierInfo.isVoipStatusEnabled = self.isReachMeCallEnabled;
        //END
    }
    else {
        currentCarrierInfo.countryCode = [NSString stringWithFormat:@"%d", -1];
        currentCarrierInfo.networkId = [NSString stringWithFormat:@"%d", -1];
        currentCarrierInfo.vSMSId = [NSNumber numberWithInteger:-1];
        currentCarrierInfo.isVoipEnabled = self.voiceMailInfo.isVoipEnabled;
        currentCarrierInfo.isVoipStatusEnabled = self.isReachMeCallEnabled;
    }
    //Update the carrier info
    [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
    [self updateUIBasedOnVoiceMailInfo:self.voiceMailInfo];
}

#pragma mark - Profile Delegate Methods -
- (void)fetchProfileCompletedWith:(UserProfileModel*)modelData {
    IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.primaryNumber];
    self.additionalActiInfo = ccInfo.ussdInfo.additionalActiInfo;
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
        if ([primaryNumber isEqualToString:self.primaryNumber]) {
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
                        
                        if ([[Setting sharedSetting]hasSupportedVoiceMailInfo:self.primaryNumber]) {
                            
                            IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromVoiceMailInfoForPhoneNumber:self.primaryNumber];
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
    
    return carrierName;
    
}


- (void)updateUIBasedOnVoiceMailInfo:(VoiceMailInfo *)withVoiceMailInfo {
    
    //Get the current custom carrier details
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
    
    IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.primaryNumber];
    self.additionalActiInfo = ccInfo.ussdInfo.additionalActiInfo;
    
    //NOV 17, 2016
    // If no carrier is supported voicemail, just return
    // Server is giving bunch of data which are not needed when no carrier is suppotted.
    // TODO: Check with Ajay.
    if(!self.voiceMailInfo.countryVoicemailSupport) {
        self.carrierDetailsText = NSLocalizedString(@"Sorry, InstaVoice Voicemail service is not available in your region at the moment. We are working hard to make it available very soon.", nil);
        self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not supported", nil);
        numberOfSections = 2;
        [self.primaryNumberVoiceMailTableView reloadData];
        return;
    }
    //
    
    //NOV 24, 2016
//    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
//        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
//    }
    //
    
    //Check for carrierdetails
    if (carrierDetails) {
        if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
            
            //No, We do not have ussd string info
            self.isVoiceMailAndMissedCallDeactivated = NO;
            self.isCarrierSupportedForVoiceMailSetup = NO;
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
            self.carrierDetailsText = NSLocalizedString(@"Sorry, InstaVoice Voicemail service is not available in your region at the moment. We are working hard to make it available very soon.", nil);
            numberOfSections = 3;
            [self.primaryNumberVoiceMailTableView reloadData];
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
                    
                    if ([[Setting sharedSetting]hasSupportedCustomCarrierInfo:self.primaryNumber]) {
                        
                        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.primaryNumber];
                        if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                            //Yes, We have supported carrier info
                            self.isVoiceMailAndMissedCallDeactivated = YES;
                            self.isCarrierSupportedForVoiceMailSetup = YES;
                            numberOfSections = 5;
                            [self.primaryNumberVoiceMailTableView reloadData];
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
                
                if ([[Setting sharedSetting]hasSupportedCustomCarrierInfo:self.primaryNumber]) {
                    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.primaryNumber];
                    
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
                [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.primaryNumber];
                self.activationDialNumber = supportedCarrierInfo.ussdInfo.actiAll;
                self.deactivateDialNumber = supportedCarrierInfo.ussdInfo.deactiAll;
            }
            
            if (!self.isValidCarrierName) {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
                self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
                numberOfSections = 5;
                [self.primaryNumberVoiceMailTableView reloadData];
                return;
            }
            
            if (self.isValidCarrierName && self.isCarrierSupportedForVoiceMailSetup && self.isVoiceMailAndMissedCallDeactivated && !self.voiceMailInfo.isVoiceMailEnabled) {
                //Set the current screen based on the voice mail configured status
                //self.currentScreen = eCarrierSupportedScreen;
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not Enabled", nil);
                self.carrierDetailsText = NSLocalizedString(@"Activate InstaVoice to start receiving voicemails and missed calls", nil);
                numberOfSections = 5;
            }
            else if (self.isValidCarrierName && !self.isCarrierSupportedForVoiceMailSetup && !self.isVoiceMailAndMissedCallDeactivated){
                //self.currentScreen = eCarrierNotSupportedScreen;
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
                self.carrierDetailsText = NSLocalizedString(@"Sorry, InstaVoice Voicemail service is not available in your region at the moment. We are working hard to make it available very soon.", nil);
                numberOfSections = 3;
            }
            else {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
                self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
                numberOfSections = 5;
                
            }
        }
        else {
            //voicemail is not enabled. - check for the USSD string of custom settings.
            if (self.currentCarrierList && [self.currentCarrierList count]) {
                
                if ([[Setting sharedSetting] hasSupportedCustomCarrierInfo:self.primaryNumber]) {
                    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.primaryNumber];
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
                
                IVSettingsCountryCarrierInfo *supportedCarrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.primaryNumber];
                self.activationDialNumber = supportedCarrierInfo.ussdInfo.actiAll;
                self.deactivateDialNumber = supportedCarrierInfo.ussdInfo.deactiAll;
            }
            
            if (!self.isValidCarrierName) {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
                self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
                numberOfSections = 5;
                [self.primaryNumberVoiceMailTableView reloadData];
                return;
            }
            if (self.isValidCarrierName && self.isCarrierSupportedForVoiceMailSetup && self.isVoiceMailAndMissedCallDeactivated && !self.voiceMailInfo.isVoiceMailEnabled) {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not Enabled", nil);
                self.carrierDetailsText = NSLocalizedString(@"Activate InstaVoice to start receving voicemails and missed calls", nil);
                numberOfSections = 5;
                
            }
            else if (self.isValidCarrierName && !self.isCarrierSupportedForVoiceMailSetup && !self.isVoiceMailAndMissedCallDeactivated) {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
                self.carrierDetailsText = NSLocalizedString(@"Sorry, InstaVoice Voicemail service is not available in your region at the moment. We are working hard to make it available very soon.", nil);
                numberOfSections = 3;
            }
            else {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
                self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
                numberOfSections = 5;
                
            }
        }
    }
    else {
        
        BOOL checkForVoiceMailInfo = NO;
        //Check for the primary number
        NSString *primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
        if ([primaryNumber isEqualToString:self.primaryNumber]) {
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
                                numberOfSections = 5;
                                [self.primaryNumberVoiceMailTableView reloadData];
                                return;
                            }
                            else {
                                self.isVoiceMailAndMissedCallDeactivated = YES;
                                self.isCarrierSupportedForVoiceMailSetup = YES;
                                self.hasCarrierSelectedFromSim = YES;
                                IVSettingsCountryCarrierInfo *supportedCarrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromSimInfoForPhoneNumber:self.primaryNumber];
                                self.activationDialNumber = supportedCarrierInfo.ussdInfo.actiAll;
                                self.deactivateDialNumber = supportedCarrierInfo.ussdInfo.deactiAll;
                                self.additionalActiInfo = supportedCarrierInfo.ussdInfo.additionalActiInfo;
                                
                                //                                //Update the server about the carrier selected by sim.
                                //                                [self didSelectCarrier:[[Setting sharedSetting]supportedCarrierInfoFromSimInfoForPhoneNumber:self.phoneNumber]];
                            }
                        }
                        else {
                            self.isVoiceMailAndMissedCallDeactivated = YES;
                            self.isCarrierSupportedForVoiceMailSetup = YES;
                            self.hasCarrierSelectedFromSim = YES;
                            //                            //Update the server about the carrier selected by sim.
                            //                            [self didSelectCarrier:[[Setting sharedSetting]supportedCarrierInfoFromSimInfoForPhoneNumber:self.phoneNumber]];
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
                        
                        if ([[Setting sharedSetting]hasSupportedVoiceMailInfo:self.primaryNumber]) {
                            
                            IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromVoiceMailInfoForPhoneNumber:self.primaryNumber];
                            if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                                //Yes, we have supported carrier info in the carrier list.
                                self.isVoiceMailAndMissedCallDeactivated = YES;
                                self.isCarrierSupportedForVoiceMailSetup = YES;
                                self.isValidCarrierName = YES;
                                //[self loadSucessfullyActivatedController];
                                numberOfSections = 5;
                                [self.primaryNumberVoiceMailTableView reloadData];
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
            numberOfSections = 5;
            [self.primaryNumberVoiceMailTableView reloadData];
            return;
        }
        
        if (self.isValidCarrierName && self.isCarrierSupportedForVoiceMailSetup && self.isVoiceMailAndMissedCallDeactivated && !self.voiceMailInfo.isVoiceMailEnabled)  {
            
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not Enabled", nil);
            self.carrierDetailsText = NSLocalizedString(@"Activate InstaVoice to start receiving voicemails and missed calls", nil);
            numberOfSections = 5;
        }
        else if (self.isValidCarrierName && !self.isCarrierSupportedForVoiceMailSetup && !self.isVoiceMailAndMissedCallDeactivated){
            //self.currentScreen = eCarrierNotSupportedScreen;
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
            self.carrierDetailsText = NSLocalizedString(@"Sorry, InstaVoice Voicemail service is not available in your region at the moment. We are working hard to make it available very soon.", nil);
            numberOfSections = 3;
        }
        else {
            
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
            self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
            numberOfSections = 5;
        }
        
        if (self.hasCarrierSelectedFromSim && !self.hasShownSimCarrierAlert) {
            //Show the alert
            //Update the server about the carrier selected by sim.
            [self didSelectCarrier:[[Setting sharedSetting]supportedCarrierInfoFromSimInfoForPhoneNumber:self.primaryNumber]];
            
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
    [self.primaryNumberVoiceMailTableView reloadData];
}

#pragma mark - Settings Protocol Methods -

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
        self.currentNetworkName = [self currentCarrierName:self.primaryNumber withCarrierList:self.currentCarrierList];
    }
}

- (void)fetchSettingCompletedWith:(SettingModel*)modelData withFetchStatus:(BOOL)withFetchStatus {
    //Settings has been updated successfully, update the UI.
    if (withFetchStatus) {
        //Determine the network name from the network ID.
        self.currentNetworkName = [self currentCarrierName:self.primaryNumber withCarrierList:self.currentCarrierList];
        [self loadLatestDataFromServer];
        [self updateUIBasedOnVoiceMailInfo:self.voiceMailInfo];
        [self hideProgressBar];
        [self closeActivateBackgroundView];
    }
}

- (void)updateSettingCompletedWith:(SettingModel*)modelData withUpdateStatus:(BOOL)withUpdateStatus {
    
    //hide loading Indicator
    //[self hideLoadingIndicator];
    
    if(withUpdateStatus) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@NO forKey:kUserSettingsFetched];
        [userDefaults synchronize];
        [[Setting sharedSetting]getUserSettingFromServer];
        self.currentNetworkName = [self currentCarrierName:self.primaryNumber withCarrierList:self.currentCarrierList];
    }
}

#pragma mark - BaseUI Method Implementation -
- (void)removeOverlayViewsIfAnyOnPushNotification {
    
    KLog(@"Remove PopOver if any open");
    [ScreenUtility closeAlert];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0)
            if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]])
                [(UIAlertView *)[subviews objectAtIndex:0] dismissWithClickedButtonIndex:[(UIAlertView *)[subviews objectAtIndex:0] cancelButtonIndex] animated:NO];
    }
    
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
    [super removeOverlayViewsIfAnyOnPushNotification];
    
}

- (void)helpAction
{
    
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
    
    if (self.voiceMailInfo.countryVoicemailSupport && !self.voiceMailInfo.isVoiceMailEnabled && self.isCarrierSupportedForVoiceMailSetup) {
        self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", [self currentCarrierName:self.primaryNumber withCarrierList:self.currentCarrierList], self.activationDialNumber];
    }else if (!self.isValidCarrierName || !self.voiceMailInfo.countryVoicemailSupport) {
        self.helpText = kCarrierNotSupporttedHelpText;
    }else if (self.voiceMailInfo.isVoiceMailEnabled) {
        if ([self primaryNumberIsActive] && carrierDetails) {
            self.helpText = @"";
        }else if (self.voiceMailInfo.countryVoicemailSupport && self.isCarrierSupportedForVoiceMailSetup){
            self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", [self currentCarrierName:self.primaryNumber withCarrierList:self.currentCarrierList], self.activationDialNumber];
        }else if (!self.isValidCarrierName || !self.voiceMailInfo.countryVoicemailSupport) {
            self.helpText = kCarrierNotSupporttedHelpText;
        }else{
            if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
                self.helpText = kCarrierNotSupporttedHelpText;
            }else{
                self.helpText = [NSString stringWithFormat:@"%@ %@",kCarrierNotSupporttedHelpText,[self currentCarrierName:self.primaryNumber withCarrierList:self.currentCarrierList]];
            }
        }
    }else{
        self.helpText = [NSString stringWithFormat:@"%@ %@",kCarrierNotSupporttedHelpText,[self currentCarrierName:self.primaryNumber withCarrierList:self.currentCarrierList]];
    }
    
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
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE",nil)];
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
    
    //    [appDelegate.stateMachineObj setNavigationController:appDelegate.tabBarController.viewControllers[0]];
    //    [appDelegate.tabBarController setSelectedIndex:0];
    //    [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[0]];
    
    BaseUI* uiObj = [[InsideConversationScreen alloc]initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    uiObj.isAnyChangesSpecificSubClass = YES;
    [self.navigationController pushViewController:uiObj animated:YES];
    //[appDelegate.getNavController pushViewController:uiObj animated:YES];
    
}

#pragma mark - Private Methdos -

- (void)loadLatestDataFromServer {
    
    KLog(@"loadLatestDataFromServer");
    
    self.currentSettingsModel = [Setting sharedSetting].data;
    if (self.currentSettingsModel) {
        if (self.currentSettingsModel.voiceMailInfo && [self.currentSettingsModel.voiceMailInfo count]) {
            for (VoiceMailInfo *voiceMailInfo in self.currentSettingsModel.voiceMailInfo) {
                if([voiceMailInfo.phoneNumber isEqualToString:self.primaryNumber]) {
                    self.voiceMailInfo = voiceMailInfo;
                }
            }
        }
    }
}


#pragma mark - UITableView Datasource Methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(numberOfSections == 5)
        return numberOfSections = 4;
    
    return  numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
    if (!self.voiceMailInfo.isVoipEnabled || ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1)) {
        if (section == eReachMeEnableOrDisable) {
            return 0;
        }
    }
    return kNumberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
    if (!self.voiceMailInfo.isVoipEnabled || ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1)) {
        if (section == eReachMeEnableOrDisable || section == eActivateOrVerifyInstaVoiceSection) {
            return 0.0;
        }
    }
    return kHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    NSString *titleOfSection;
    
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
    
    if (numberOfSections == 3 || numberOfSections == 2) {
        
        if (section == ePhoneNumberCarrierSection)
            titleOfSection = @"Sorry, InstaVoice service is not available in your region at the moment. We are working hard to make it available very soon.";
        else
            titleOfSection = @"";
        
    }else{
     
        if(self.additionalActiInfo.length) {
            
            if (section == ePhoneNumberCarrierSection){
            
                titleOfSection = self.additionalActiInfo;
                
            }else if (section == eVoiceMailAndMissedCallAlertSection){
                if ([self primaryNumberIsActive] && carrierDetails)
                    titleOfSection = @"Received in last 30 days";
                else
                    titleOfSection = @"Activate InstaVoice to allow your callers to leave a Missed Call or a Voicemail when you are busy or your phone is not reachable";
            }else
                titleOfSection = @"";
        }else{
            if (section == eVoiceMailAndMissedCallAlertSection){
                if ([self primaryNumberIsActive] && carrierDetails)
                    titleOfSection = @"Received in last 30 days";
                else
                    titleOfSection = @"Activate InstaVoice to allow your callers to leave a Missed Call or a Voicemail when you are busy or your phone is not reachable";
            }else
                titleOfSection = @"";
        }
        
    }
    
    if (self.voiceMailInfo.isVoipEnabled) {
        if (section == eReachMeEnableOrDisable){
            NSString *detailText = @"";
            
            if([[[UIDevice currentDevice] systemVersion] integerValue] < 10)
                detailText = @"ReachMe allows you to receive regular phone calls in the App over Wi-Fi or a mobile data connection.\n\nReachMe calls are supported only in iOS 10.0 or later version.";
            else
                detailText = @"ReachMe allows you to receive regular phone calls in the App over Wi-Fi or a mobile data connection.";
            
            titleOfSection = detailText;
        }
    }
    
    UITextView *msgLabel = [[UITextView alloc] init];
    msgLabel.text = titleOfSection;
    msgLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    [msgLabel sizeToFit];
    
    CGSize stringSize;
    CGSize lableWidth = CGSizeMake(DEVICE_WIDTH - 20.0, CGFLOAT_MAX);
    CGSize neededSize = [msgLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
    stringSize = neededSize;
    stringSize.height += 10.0;
    sectionFooterHeight = stringSize.height;
    if(!titleOfSection.length)
        sectionFooterHeight = 10.0;
    
    return sectionFooterHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 88.0;
    }else if (indexPath.section == eReachMeEnableOrDisable) {
        return 60.0;
    }
    return kRowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
    
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    NSString *titleOfSection;
    if (numberOfSections == 3 || numberOfSections == 2) {
        
        if (section == ePhoneNumberCarrierSection)
            titleOfSection = @"Sorry, InstaVoice service is not available in your region at the moment. We are working hard to make it available very soon.";
        else
            titleOfSection = @"";
        
    }else{
        
        if(self.additionalActiInfo.length) {
            
            if (section == ePhoneNumberCarrierSection){
                
                titleOfSection = self.additionalActiInfo;
                
            }else if (section == eVoiceMailAndMissedCallAlertSection){
                if ([self primaryNumberIsActive] && carrierDetails)
                    titleOfSection = @"Received in last 30 days";
                else if (self.isActivationFailed)
                    titleOfSection = @"Activation failed, please check SIM carrier and try again";
                else
                    titleOfSection = @"Activate InstaVoice to allow your callers to leave a Missed Call or a Voicemail when you are busy or your phone is not reachable";
            }else
                titleOfSection = @"";
        }else{
            if (section == eVoiceMailAndMissedCallAlertSection){
                if ([self primaryNumberIsActive] && carrierDetails)
                    titleOfSection = @"Received in last 30 days";
                else if (self.isActivationFailed)
                    titleOfSection = @"Activation failed, please check SIM carrier and try again";
                else
                    titleOfSection = @"Activate InstaVoice to allow your callers to leave a Missed Call or a Voicemail when you are busy or your phone is not reachable";
            }else
                titleOfSection = @"";
        }
        
    }
    
    if (self.voiceMailInfo.isVoipEnabled) {
        if (section == eReachMeEnableOrDisable){
            
            NSString *detailText = @"";
            if([[[UIDevice currentDevice] systemVersion] integerValue] < 10)
                detailText = @"ReachMe allows you to receive regular phone calls in the App over Wi-Fi or a mobile data connection.\n\nReachMe calls are supported only in iOS 10.0 or later version.";
            else
                detailText = @"ReachMe allows you to receive regular phone calls in the App over Wi-Fi or a mobile data connection.";
            
            titleOfSection = detailText;
        }
    }
    
    UITextView *label = [[UITextView alloc] initWithFrame:CGRectMake(12.0, 0.0, DEVICE_WIDTH - 20.0, sectionFooterHeight)];
    label.text = NSLocalizedString(titleOfSection, nil);
    label.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    label.editable = NO;
    label.dataDetectorTypes = UIDataDetectorTypeLink;
    label.backgroundColor = [UIColor clearColor];
    label.tintColor = [UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f];
    label.textColor = self.isActivationFailed?[UIColor colorWithRed:(255.0/255.0) green:(50.0/255.0) blue:(56.0/255.0) alpha:1.0f]:[UIColor darkGrayColor];
    if (self.voiceMailInfo.isVoipEnabled) {
        if (section == eReachMeEnableOrDisable){
            if([[[UIDevice currentDevice] systemVersion] integerValue] < 10){
                NSString *reachMeSupportString = @"ReachMe allows you to receive regular phone calls in the App over Wi-Fi or a mobile data connection.";
                NSString *reachMeNotSupportString = @"\n\nReachMe calls are supported only in iOS 10.0 or later version.";
                
                UIColor *normalColor = [UIColor darkGrayColor];
                UIColor *highlightColor = [UIColor redColor];
                UIFont *font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
                NSDictionary *normalAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor};
                NSDictionary *highlightAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:highlightColor};
                
                NSAttributedString *normalText = [[NSAttributedString alloc] initWithString:reachMeSupportString attributes:normalAttributes];
                NSAttributedString *highlightedText = [[NSAttributedString alloc] initWithString:reachMeNotSupportString attributes:highlightAttributes];
                
                NSMutableAttributedString *finalAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:normalText];
                [finalAttributedString appendAttributedString:highlightedText];
                
                label.attributedText = finalAttributedString;
            }else{
                label.textColor = [UIColor darkGrayColor];
            }
        }
    }
    
    label.scrollEnabled = NO;
    [label sizeToFit];
    [tableHeaderView addSubview:label];
    
    return tableHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *headerTitle = @[@"PRIMARY NUMBER",@"PHONE NUMBER CARRIER",@"VOICEMAIL AND MISSED CALL ALERTS",@"",@""];
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 20.0, section == 2?DEVICE_WIDTH - 32.0:(!self.voiceMailInfo.countryVoicemailSupport?DEVICE_WIDTH - 32.0:DEVICE_WIDTH - 170.0), 40.0)];
    label.text = NSLocalizedString([headerTitle objectAtIndex:section], nil);
    label.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    
    NSString *buttonName = @"";
    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.primaryNumber];
    if (carrierInfo) {
        buttonName = @"Change carrier";
    }else{
        CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
        if (carrierDetails) {
            buttonName = @"Change carrier";
        }else{
            buttonName = @"Select carrier";
        }
    }
    
    UIButton *changeCarrier = [UIButton buttonWithType:UIButtonTypeSystem];
    changeCarrier.frame = CGRectMake(DEVICE_WIDTH - 160.0, 18.0, 150.0, 40.0);
    [changeCarrier setTitle:buttonName forState:UIControlStateNormal];
    [changeCarrier setTitleColor:[UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f] forState:UIControlStateNormal];
    changeCarrier.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    [changeCarrier addTarget:self action:@selector(changeCarrier:) forControlEvents:UIControlEventTouchUpInside];
    changeCarrier.hidden = YES;
    changeCarrier.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    if (section == 1) {
        if(!self.voiceMailInfo.countryVoicemailSupport)
            changeCarrier.hidden = YES;
        else
            changeCarrier.hidden = NO;
    }
    
    UIButton *reachMeInfo = [UIButton buttonWithType:UIButtonTypeSystem];
    reachMeInfo.frame = CGRectMake(DEVICE_WIDTH - 40.0, 23.0, 30.0, 30.0);
    [reachMeInfo setImage:[UIImage imageNamed:@"settings_info_icon"] forState:UIControlStateNormal];
    reachMeInfo.tintColor = [UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f];
    [reachMeInfo addTarget:self action:@selector(reachMeInfoIcon:) forControlEvents:UIControlEventTouchUpInside];
    reachMeInfo.hidden = YES;
    
    if (section == eReachMeEnableOrDisable) {
        if (!self.voiceMailInfo.isVoipEnabled)
            reachMeInfo.hidden = YES;
        else
            reachMeInfo.hidden = NO;
    }else{
        reachMeInfo.hidden = YES;
    }
    
    [tableHeaderView addSubview:reachMeInfo];
    [tableHeaderView addSubview:label];
    [tableHeaderView addSubview:changeCarrier];
    
    return tableHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *cellIdentifier;
    
    switch (indexPath.section) {
        case ePrimaryNumberSection:
            cellIdentifier = kPrimaryNumberVoiceMailCellIdentifier;
            break;
        case ePhoneNumberCarrierSection:
        case eVoiceMailAndMissedCallAlertSection:
            cellIdentifier = kPrimaryNumberVoiceMailInfoCellIdentifier;
            break;
        case eReachMeEnableOrDisable:
            cellIdentifier = kPrimaryNumberReachMeCellIdentifier;
            break;
        case eActivateOrVerifyInstaVoiceSection:
            cellIdentifier = kPrimaryNumberVoiceMailActivateCellIdentifier;
            break;
        default:
            break;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell layoutIfNeeded];
    [cell layoutSubviews];
    [cell setNeedsLayout];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self primaryNumberIsActive]) {
        if (![[ConfigurationReader sharedConfgReaderObj] reachMeVoipStatus:self.primaryNumber] && self.voiceMailInfo.isVoipEnabled) {
            [self updateReachMeStatusToServer:YES];
            [[ConfigurationReader sharedConfgReaderObj] setReachMeVoipStatus:YES forNumber:self.primaryNumber];
        }
    }else{
        [[ConfigurationReader sharedConfgReaderObj] setReachMeVoipStatus:NO forNumber:self.primaryNumber];
    }
    
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
    
    switch (indexPath.section) {
        case ePrimaryNumberSection: {
            if ([cell isKindOfClass:[IVPrimaryNumberVoiceMailTableViewCell class]]) {
                IVPrimaryNumberVoiceMailTableViewCell *primaryNumberSectionCell = (IVPrimaryNumberVoiceMailTableViewCell *)cell;
                [primaryNumberSectionCell.infoIconButton addTarget:self action:@selector(numberInfoIcon:) forControlEvents:UIControlEventTouchUpInside];
                primaryNumberSectionCell.titleTextField.text = self.titleName;
                primaryNumberSectionCell.iconImageView.image = [UIImage imageNamed:self.imageName];
                primaryNumberSectionCell.primaryNumberInfo.text = [Common getFormattedNumber:self.primaryNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
                
                UITapGestureRecognizer *editImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editImageIcon:)];
                [primaryNumberSectionCell.iconImageView addGestureRecognizer:editImage];
                
                primaryNumberSectionCell.titleTextField.delegate = self;
                primaryNumberSectionCell.titleTextField.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                primaryNumberSectionCell.primaryNumberInfo.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
                
            }
            break;
        }
        case ePhoneNumberCarrierSection: {
            if ([cell isKindOfClass:[IVPrimaryNumberVoiceMailTableViewCell class]]) {
                IVPrimaryNumberVoiceMailTableViewCell *primaryNumberCarrierSelectionCell = (IVPrimaryNumberVoiceMailTableViewCell *)cell;
                
                NSString *networkName = @"";
                IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.primaryNumber];
                if (carrierInfo) {
                    networkName = carrierInfo.networkName;
                }else{
                    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
                    
                    if (carrierDetails) {
                        
                        if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
                            networkName = @"Not Listed";
                        }else{
                            networkName = @"Select Your Carrier";
                        }
                    }else{
                        networkName = @"Select Your Carrier";
                    }
                }
              
                if (!self.voiceMailInfo || !self.voiceMailInfo.countryVoicemailSupport) {
                    networkName = self.carrierSelectionOrEnableStatus;
                }else{
                    UITapGestureRecognizer *selectCarrier = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeCarrier:)];
                    [primaryNumberCarrierSelectionCell addGestureRecognizer:selectCarrier];
                    
                    primaryNumberCarrierSelectionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                
                primaryNumberCarrierSelectionCell.titleLabel.text = networkName;
                primaryNumberCarrierSelectionCell.activeStatus.hidden = YES;
                primaryNumberCarrierSelectionCell.activeStatusLabel.hidden = YES;
                
                primaryNumberCarrierSelectionCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                
            }
            break;
        }
        case eVoiceMailAndMissedCallAlertSection: {
            if ([cell isKindOfClass:[IVPrimaryNumberVoiceMailTableViewCell class]]) {
                IVPrimaryNumberVoiceMailTableViewCell *primaryNumberAlertSectionCell = (IVPrimaryNumberVoiceMailTableViewCell *)cell;
                NSString *voiceMailAndMissedCallCount = @"";
                NSString *voiceMailCount = [NSString stringWithFormat:@"%ld Voicemail(s)",(long)self.voiceMailInfo.realVocieMailCount];
                NSString *missedCallCount = [NSString stringWithFormat:@"%ld Missed Call(s)",(long)self.voiceMailInfo.realMissedCallCount];
                
                if (self.voiceMailInfo.realVocieMailCount == 0 && self.voiceMailInfo.realMissedCallCount == 0) {
                    voiceMailAndMissedCallCount = @"0 Voicemails & 0 Missed Calls";
                }else if(self.voiceMailInfo.realVocieMailCount > 0 && self.voiceMailInfo.realMissedCallCount == 0){
                    voiceMailAndMissedCallCount = voiceMailCount;
                }else if(self.voiceMailInfo.realVocieMailCount == 0 && self.voiceMailInfo.realMissedCallCount > 0){
                    voiceMailAndMissedCallCount = missedCallCount;
                }else{
                    voiceMailAndMissedCallCount = [NSString stringWithFormat:@"%@ & %@",voiceMailCount,missedCallCount];
                }
                
                if(![self primaryNumberIsActive] && carrierDetails)
                    voiceMailAndMissedCallCount = @"Not Active";
                
                if(!self.isCarrierSupportedForVoiceMailSetup)
                    primaryNumberAlertSectionCell.titleLabel.text = self.carrierSelectionOrEnableStatus;
                else
                    primaryNumberAlertSectionCell.titleLabel.text = voiceMailAndMissedCallCount;
                
                if ([self primaryNumberIsActive] && carrierDetails) {
                    primaryNumberAlertSectionCell.activeStatus.image = [UIImage imageNamed:@"voicemail_active"];
                    primaryNumberAlertSectionCell.activeStatusLabel.text = @"Active";
                }else{
                    primaryNumberAlertSectionCell.activeStatus.image = [UIImage imageNamed:@"voicemail_not_active"];
                    primaryNumberAlertSectionCell.activeStatusLabel.text = @"Not active";
                }
                
                primaryNumberAlertSectionCell.accessoryType = UITableViewCellAccessoryNone;
                
            }
            break;
        }
        case eReachMeEnableOrDisable: {
            if ([cell isKindOfClass:[IVPrimaryNumberVoiceMailTableViewCell class]]) {
                IVPrimaryNumberVoiceMailTableViewCell *primaryNumberReachMeSectionCell = (IVPrimaryNumberVoiceMailTableViewCell *)cell;
                [primaryNumberReachMeSectionCell.reachMeStatus addTarget:self action:@selector(enableOrDisableReachMe:) forControlEvents:UIControlEventValueChanged];
                
                if (carrierDetails.isVoipStatusEnabled) {
                    [primaryNumberReachMeSectionCell.reachMeStatus setOn:YES];
                    self.isReachMeCallEnabled = YES;
                }else{
                    [primaryNumberReachMeSectionCell.reachMeStatus setOn:NO];
                    self.isReachMeCallEnabled = NO;
                }
                
                if (![self primaryNumberIsActive]){
                    [primaryNumberReachMeSectionCell.reachMeStatus setOn:NO];
                    self.isReachMeCallEnabled = NO;
                }
                
                primaryNumberReachMeSectionCell.reachMeLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
            }
            break;
        }
        case eActivateOrVerifyInstaVoiceSection: {
            if ([cell isKindOfClass:[IVPrimaryNumberVoiceMailTableViewCell class]]) {
                IVPrimaryNumberVoiceMailTableViewCell *primaryNumberActivateSectionCell = (IVPrimaryNumberVoiceMailTableViewCell *)cell;
                [primaryNumberActivateSectionCell.verifyOrActivateButton addTarget:self action:@selector(verifyInstaVoice:) forControlEvents:UIControlEventTouchUpInside];
                [primaryNumberActivateSectionCell.verifyOrActivateButton setTitleColor:[UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f] forState:UIControlStateNormal];
                if ([self primaryNumberIsActive] && carrierDetails) {
                    [primaryNumberActivateSectionCell.verifyOrActivateButton setTitle:@"VERIFY INSTAVOICE IS WORKING" forState:UIControlStateNormal];
                    self.primaryNumberVoiceMailTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 45.0, 0.0);
                    self.primaryNumberVoiceMailTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 45.0, 0.0);
                    
                }else if (self.isActivationRequested){
                    [primaryNumberActivateSectionCell.verifyOrActivateButton setTitle:@"ACTIVATION REQUESTED" forState:UIControlStateNormal];
                }else{
                    [primaryNumberActivateSectionCell.verifyOrActivateButton setTitle:@"ACTIVATE INSTAVOICE" forState:UIControlStateNormal];
                }
            }
            break;
        }
        default:
            break;
    }
    
    
    if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
        self.deActivateButton.hidden = YES;
    }else{
        [self performSelector:@selector(showDeactivateButton) withObject:nil afterDelay:1.0];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.primaryNumberVoiceMailTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case ePrimaryNumberSection:
            break;
        case ePhoneNumberCarrierSection:
            break;
        case eVoiceMailAndMissedCallAlertSection:
            break;
        case eActivateOrVerifyInstaVoiceSection:
            break;
        default:
            break;
    }
    
}

- (IBAction)numberInfoIcon:(id)sender
{
    [[self view] endEditing:YES];
    UIAlertController *alertController =   [UIAlertController
                                            alertControllerWithTitle:nil
                                            message:NSLocalizedString(@"Primary number is the login number of your InstaVoice account.\n\nInstaVoice message (text, audio & image) sent to the contacts not on the InstaVoice App will receive the message as an SMS from the primary number.\n\nYou can set any of the linked numbers as your primary number by clicking on Change primary number in the linked number list.", nil)
                                            preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *alertMessage = [[NSMutableAttributedString alloc] initWithString:@"Primary number is the login number of your InstaVoice account.\n\nInstaVoice message (text, audio & image) sent to the contacts not on the InstaVoice App will receive the message as an SMS from the primary number.\n\nYou can set any of the linked numbers as your primary number by clicking on Change primary number in the linked number list."];
    [alertMessage addAttribute:NSFontAttributeName
                         value:[UIFont systemFontOfSize:13.0]
                         range:NSMakeRange(0, alertMessage.length)];
    [alertController setValue:alertMessage forKey:@"attributedMessage"];
    
    UIAlertAction *gotIt = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"Got It", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [alertController dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    UIAlertAction *liveHelp = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Get Live Help", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [self helpAction];
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alertController addAction:liveHelp];
    [alertController addAction:gotIt];
    [self presentViewController:alertController animated:YES completion:nil];
    [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
}

- (IBAction)reachMeInfoIcon:(id)sender
{
    [[self view] endEditing:YES];
    UIAlertController *alertController =   [UIAlertController
                                            alertControllerWithTitle:nil
                                            message:NSLocalizedString(@"ReachMe allows you to receive calls in the InstaVoice App over Wi-Fi or a mobile data connection.\n\nYou can receive phone calls with ReachMe when your phone number is unreachable i.e. out of coverage. SIM not in phone, or switched off.\n\nAdditionally, you can choose to receive all calls with ReachMe. In such a case, your phone will not ring.", nil)
                                            preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *alertMessage = [[NSMutableAttributedString alloc] initWithString:@"ReachMe allows you to receive calls in the InstaVoice App over Wi-Fi or a mobile data connection.\n\nYou can receive phone calls with ReachMe when your phone number is unreachable i.e. out of coverage. SIM not in phone, or switched off.\n\nAdditionally, you can choose to receive all calls with ReachMe. In such a case, your phone will not ring."];
    [alertMessage addAttribute:NSFontAttributeName
                         value:[UIFont systemFontOfSize:13.0]
                         range:NSMakeRange(0, alertMessage.length)];
    [alertController setValue:alertMessage forKey:@"attributedMessage"];
    
    UIAlertAction *gotIt = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"Got It", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [alertController dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    UIAlertAction *liveHelp = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Get Live Help", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [self helpAction];
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alertController addAction:liveHelp];
    [alertController addAction:gotIt];
    [self presentViewController:alertController animated:YES completion:nil];
    [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
}

- (IBAction)changeCarrier:(id)sender{
    
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        self.isActivationFailed = NO;
        self.isActivationRequested = NO;
        if(self.currentCarrierList && self.currentCarrierList.count) {
            if (!self.carrierSearchViewController) {
                UIStoryboard *voiceMailSettingsStorybaord = [UIStoryboard storyboardWithName:@"IVVoiceMailMissedCallSettingsStoryBoard" bundle:[NSBundle mainBundle]];
                self.carrierSearchViewController = [voiceMailSettingsStorybaord instantiateViewControllerWithIdentifier:@"IVCarrierSearchView"];
            }
            
            if (![self.navigationController.topViewController isKindOfClass:[IVCarrierSearchViewController class]]) {
                self.carrierSearchViewController.carrierList = nil;
                self.carrierSearchViewController.voiceMailInfo = self.voiceMailInfo;
                self.carrierSearchViewController.selectedCountryCarrierInfo = self.selectedCountryCarrierInfo;
                self.carrierSearchViewController.carrierSearchDelegate = self;
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
        
        //[self hideLoadingIndicator];
        
        //OCT 4, 2016  [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE",nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        
        //We do not have network - load the default screen of carrier selection.
        //Voicemail not enabled.
        [self.primaryNumberVoiceMailTableView reloadData];
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

- (BOOL)primaryNumberIsActive
{
    CarrierInfo *currentSelectedNumberCarrierInfo = [[Setting sharedSetting] customCarrierInfoForPhoneNumber:self.primaryNumber];
    //check do we have carrier list for the country.
    NSArray *carrierList = [[Setting sharedSetting]carrierListForCountry:self.voiceMailInfo.carrierCountryCode];
    if (currentSelectedNumberCarrierInfo) {
        if ([currentSelectedNumberCarrierInfo.networkId isEqualToString:@"-1"] && [currentSelectedNumberCarrierInfo.countryCode isEqualToString:@"-1" ] && [currentSelectedNumberCarrierInfo.vSMSId integerValue] == -1) {
            //We do not have USSD Info - Redirect screen to Carrier Selection page.
            return NO;
        }
        
        if (self.voiceMailInfo) {
            //We have voicemail info
            //Check for voicemail enabled ore not.
            if (self.voiceMailInfo.isVoiceMailEnabled && self.voiceMailInfo.countryVoicemailSupport) {
                if (carrierList && [carrierList count]) {
                    //We have custom settings - carrier info - which takes a highest priority in deciding the voicemail and settings page.
                    //Check we have supported carrierInfo in the carrier list.
                    if ([[Setting sharedSetting]hasSupportedCustomCarrierInfo:self.primaryNumber]) {
                        
                        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.primaryNumber];
                        
                        //Yes, we have valid carrier info in the carrier list
                        //Check for valid USSD Info required - actilAll and deactiAll.
                        if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                            //Yes, We have valid USSD Info.
                            return YES;
                        }
                        else {
                            //We do not have USSD info.
                            return NO;
                        }
                    }
                    else {
                        return NO;
                    }
                }
                else {
                    return YES;
                }
            }
            else { //voicemail is not enabled - show the default screen
                return NO;
            }
        }
        else {
            return NO;
        }
    }
    //Check for Sim - MCCMNC and countryCode.
    else if ([[Setting sharedSetting]hasValidSimInfoForPhoneNumber:self.primaryNumber]) {
        //Yes, we have valid sim info.
        //Check for voicemail info
        if (self.voiceMailInfo) {
            //Yes, we have voicemail info
            if (self.voiceMailInfo.isVoiceMailEnabled) {
                if (carrierList && [carrierList count]) {
                    //Yes, we have carrier list.
                    //Check for the supported carrier info.
                    if ([[Setting sharedSetting]hasSupportedSimCarrierInfo:self.primaryNumber]) {
                        //Yes, we have supported carrier info.
                        //Check for the valid USSD info for the carrier.
                        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromSimInfoForPhoneNumber:self.primaryNumber];
                        if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                            return YES;
                        }
                        else {
                            return NO;
                        }
                    }
                    else {
                        //We do not have supported carrier info - so redirect it to select your carrier info page.
                        return NO;
                    }
                }
                else {
                    return YES;
                }
                
            }
            else {
                //Voicemail Info not enabled.
                return NO;
            }
        }
        else {
            //No, we do not have voicemail info. Redirect user to the carrier selection page.
            return NO;
            
        }
    }
    else {
        //We do not have supporting sim info - check for the voice mail info
        if (self.voiceMailInfo) {
            //Yes, we have voicemail info
            //Check for voice mail enabled or not.
            if (self.voiceMailInfo.isVoiceMailEnabled) {
                if (carrierList && [carrierList count]) {
                    
                    if ([[Setting sharedSetting]hasSupportedVoiceMailInfo:self.primaryNumber]) {
                        //We have supported carrier
                        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromVoiceMailInfoForPhoneNumber:self.primaryNumber];
                        //Check for USSD info
                        if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                            
                            return YES;
                        }
                        else {
                            
                            return NO;
                        }
                    }
                    else {
                        //We do not have supported carrier
                        //Voice mail has not enabled - so redirect it to carrier selection page.
                        
                        return NO;
                    }
                }
                else {
                    return YES;
                }
            }
            else {
                //Voice mail has not enabled - so redirect it to carrier selection page.
                return NO;
            }
        }
        else {
            //We do not have voice mail info - so redirect it to carrier selection page.
            return NO;
        }
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [textField resignFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.titleName = newString;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    self.titleName = textField.text;
    NumberInfo *currentNumberInfo = [[NumberInfo alloc]init];
    currentNumberInfo.phoneNumber = self.primaryNumber;
    currentNumberInfo.imgName = self.imageName;
    currentNumberInfo.titleName = self.titleName;
    [[Setting sharedSetting]updateNumberSettingsInfo:currentNumberInfo];
    [textField resignFirstResponder];
    return NO;
}

//- (void)textViewDidChange:(UITextView *)textView
//{
//    self.titleName = textView.text;
//}
//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    
//    if([text isEqualToString:@"\n"]) {
//        self.titleName = textView.text;
//        CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
//        currentCarrierInfo.phoneNumber = self.primaryNumber;
//        currentCarrierInfo.countryCode = self.selectedCountryCarrierInfo.countryCode;
//        currentCarrierInfo.networkId = self.selectedCountryCarrierInfo.networkId;
//        currentCarrierInfo.vSMSId = self.selectedCountryCarrierInfo.vsmsNodeId;
//        currentCarrierInfo.imgName = self.imageName;
//        currentCarrierInfo.titleName = self.titleName;
//        [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
//        [textView resignFirstResponder];
//        return NO;
//    }
//    
//    return YES;
//}

-(void)tap:(UITapGestureRecognizer *)tapRec{
    NumberInfo *currentNumberInfo = [[NumberInfo alloc]init];
    currentNumberInfo.phoneNumber = self.primaryNumber;
    currentNumberInfo.imgName = self.imageName;
    currentNumberInfo.titleName = self.titleName;
    [[Setting sharedSetting]updateNumberSettingsInfo:currentNumberInfo];
    [[self view] endEditing: YES];
}

- (void)editImageIcon:(UITapGestureRecognizer *)rec
{
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    EditVoiceMailImageIconViewController *editImageIconViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"EditVoiceMailImageIcon"];
    editImageIconViewController.phoneNumber = self.primaryNumber;
    editImageIconViewController.iconName = self.imageName;
    [self.navigationController pushViewController:editImageIconViewController animated:YES];
}

- (void)turnOffReachMe
{
    [[self view] endEditing:YES];
    
    NSString* alertDetails = [NSString stringWithFormat:@"You will no longer receive calls in the app when your phone number %@ is unreachable i.e. out of coverage, SIM not in phone, or switched off\n\nNote: You will continue receiving Voicemail & Missed Call Alerts",[Common getFormattedNumber:self.primaryNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
    
    UIAlertController *alertController =   [UIAlertController
                                            alertControllerWithTitle:@"Turn off receiving unreachable calls?"
                                            message:NSLocalizedString(alertDetails, nil)
                                            preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *alertMessage = [[NSMutableAttributedString alloc] initWithString:alertDetails];
    [alertMessage addAttribute:NSFontAttributeName
                         value:[UIFont systemFontOfSize:13.0]
                         range:NSMakeRange(0, alertMessage.length)];
    [alertController setValue:alertMessage forKey:@"attributedMessage"];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    UIAlertAction *turnOff = [UIAlertAction
                              actionWithTitle:NSLocalizedString(@"Turn Off", nil)
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self updateReachMeStatusToServer:NO];
                                  [alertController dismissViewControllerAnimated:YES completion:nil];
                              }];
    
    [alertController addAction:turnOff];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
    [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
}

- (void)activateInstaVoice
{
    [[self view] endEditing:YES];
    UIAlertController *alertController =   [UIAlertController
                                            alertControllerWithTitle:@"Receive only unreachable calls with ReachMe"
                                            message:NSLocalizedString(@"You can receive calls with ReachMe even when your phone number is unreachable i.e. out of coverage, SIM not in phone, or switched off.", nil)
                                            preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *alertMessage = [[NSMutableAttributedString alloc] initWithString:@"You can receive calls with ReachMe even when your phone number is unreachable i.e. out of coverage, SIM not in phone, or switched off."];
    [alertMessage addAttribute:NSFontAttributeName
                         value:[UIFont systemFontOfSize:13.0]
                         range:NSMakeRange(0, alertMessage.length)];
    [alertController setValue:alertMessage forKey:@"attributedMessage"];
    
    UIAlertAction *gotIt = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"Cancel", nil)
                            style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction * action)
                            {
                                
                                [alertController dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    UIAlertAction *liveHelp = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"ACTIVATE", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [self verifyInstaVoice:nil];
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alertController addAction:liveHelp];
    [alertController addAction:gotIt];
    [self presentViewController:alertController animated:YES completion:nil];
    [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
}

- (void)updateReachMeStatusToServer:(BOOL)isEnabled
{
    CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
    currentCarrierInfo.phoneNumber = self.primaryNumber;
    currentCarrierInfo.countryCode = self.selectedCountryCarrierInfo.countryCode;
    currentCarrierInfo.networkId = self.selectedCountryCarrierInfo.networkId;
    currentCarrierInfo.vSMSId = self.selectedCountryCarrierInfo.vsmsNodeId;
    currentCarrierInfo.isVoipEnabled = self.voiceMailInfo.isVoipEnabled;
    currentCarrierInfo.isVoipStatusEnabled = isEnabled;
    //Update the carrier info
    [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
    [self.primaryNumberVoiceMailTableView reloadData];
    
#ifdef ENABLE_LATER
    [appDelegate prepareVoipCallBlockedNumbers];
#endif
    
}

- (IBAction)enableOrDisableReachMe:(id)sender
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
    
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [self.primaryNumberVoiceMailTableView reloadData];
        return;
    }
    
    if (![self primaryNumberIsActive]) {
        [self activateInstaVoice];
    }else{
        if (carrierDetails.isVoipStatusEnabled) {
            [self turnOffReachMe];
        }else{
            [self updateReachMeStatusToServer:YES];
        }
    }
    
    [self.primaryNumberVoiceMailTableView reloadData];
}

- (IBAction)verifyInstaVoice:(id)sender
{
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        
        IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.primaryNumber];
        
        CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
        
        if (!ccInfo) {
            [ScreenUtility showAlert:@"Please select carrier to activate"];
            return;
        }
        
        if ([self primaryNumberIsActive] && carrierDetails) {
            IVVoiceMailVerifyInstaVoiceViewController *voiceMailVerifyInstaVoiceViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"VoiceMailVerifyInstaVoice"];
            voiceMailVerifyInstaVoiceViewController.phoneNumber = self.primaryNumber;
            [self.navigationController pushViewController:voiceMailVerifyInstaVoiceViewController animated:YES];
        }else if (ccInfo.ussdInfo.isHLREnabled){
            self.isActivationRequested = YES;
            [self.primaryNumberVoiceMailTableView reloadData];
            [self showActivateBackgroundView];
            [self showProgressBar];
            
            [NSTimer scheduledTimerWithTimeInterval:3.0
                                             target:self
                                           selector:@selector(activationTimeLapsed:)
                                           userInfo:nil
                                            repeats:NO];
            
            NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
            [requestDic setValue:self.primaryNumber forKey:@"phone_num"];
            [requestDic setValue:@"enable" forKey:@"action"];
            
            VoiceMailHLRAPI* api = [[VoiceMailHLRAPI alloc]initWithRequest:requestDic];
            [api callNetworkRequest:requestDic withSuccess:^(VoiceMailHLRAPI *req, NSMutableDictionary *responseObject) {
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                if ([[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setValue:@NO forKey:kUserSettingsFetched];
                    [userDefaults synchronize];
                    [[Setting sharedSetting]getUserSettingFromServer];
                    [self hideProgressBar];
                    self.isActivationFailed = NO;
                    self.isActivationRequested = NO;
                    self.isActivationSuccess = YES;
                    
                    [self showDeactivateButton];
                    [self closeActivateBackgroundView];
                }
            }failure:^(VoiceMailHLRAPI *req, NSError *error) {
                
                [self hideProgressBar];
                [self closeActivateBackgroundView];
                self.isActivationFailed = YES;
                self.isActivationRequested = NO;
                self.isActivationSuccess = NO;
                [self.primaryNumberVoiceMailTableView reloadData];
                
                EnLogd(@"*** Error fetching user contact: %@, %@",req,[error description]);
                KLog(@"*** Error fetching user contact: %@, %@",req,[error description]);
                
            }];
            
        }else{
            IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.primaryNumber];
            
            IVVoiceMailActivateViewController *voiceMailActivateViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"VoiceMailActivate"];
            voiceMailActivateViewController.phoneNumber = self.primaryNumber;
            voiceMailActivateViewController.activationCode = carrierInfo.ussdInfo.actiAll;
            [self.navigationController pushViewController:voiceMailActivateViewController animated:YES];
        }
    }else{
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

- (void)showActivateBackgroundView
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    activateBackGroundView = [[UIView alloc]initWithFrame:rect];
    activateBackGroundView.backgroundColor = [UIColor blackColor];
    activateBackGroundView.alpha = 0.5f;
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [[[window subviews] objectAtIndex:0] addSubview:activateBackGroundView];
    
}

- (void)closeActivateBackgroundView
{
    activateBackGroundView.hidden = YES;
}

- (void)activationTimeLapsed:(NSTimer *)timer{
    [self hideProgressBar];
    [self closeActivateBackgroundView];
}

- (IBAction)deActivateVoiceMail:(id)sender {
    
    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.primaryNumber];
    
    IVVoiceMailDeActivateViewController *voiceMailDeActivateViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"VoiceMailDeActivate"];
    voiceMailDeActivateViewController.phoneNumber = self.primaryNumber;
    voiceMailDeActivateViewController.deActivationCode = carrierInfo.ussdInfo.deactiAll;
    [self.navigationController pushViewController:voiceMailDeActivateViewController animated:YES];
    
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
