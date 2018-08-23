//
//  IVLinkedNumberVoiceMailViewController.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 01/08/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "IVLinkedNumberVoiceMailViewController.h"
#import "IVVoiceMailCarrierSelectionProtocol.h"
#import "IVLinkedNumberVoiceMailTableViewCell.h"
#import "IVVoiceMailDeActivateViewController.h"
#import "IVVoiceMailVerifyInstaVoiceViewController.h"
#import "EditVoiceMailImageIconViewController.h"

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

#import "IVVoiceMailActivateViewController.h"

#import "NetworkCommon.h"

//Settings
#import "Setting.h"

#import "Profile.h"

//HLR API
#import "VoiceMailHLRAPI.h"

#import<CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


#define kCarrierNotSupporttedText @"Sorry, InstaVoice Voicemail Service is not available in your region at the moment. We are working hard to make it available very soon."

#define kCarrierNotSupporttedHelpText @"Hi, I'm interested in InstaVoice Voicemail/Missed Call alerts. Please inform me when it's made available for my Carrier:"

#define kPrimaryNumberCanNotDeleteErrorCode 88
#define kErrorCodeForCarrierListNotFound 20
#define kLinkedNumberVoiceMailCellIdentifier @"IVLinkedNumberCell"
#define kLinkedNumberVoiceMailInfoCellIdentifier @"IVLinkedNumberInfoCell"
#define kLinkedNumberVoiceMailActivateCellIdentifier @"IVLinkedNumberActivateCell"
#define kLinkedNumberReachMeCellIdentifier @"IVLinkedNumberReachMeCell"

#define kNumberOfSections 4
#define kNumberOfRows 1
#define kHeaderHeight 54
#define kRowHeight 44
#define kContactIdKey @"contact_id"
#define kCountryCodeKey @"country_code"

#define kSelectCarrierButtonTitle @"Select Your Carrier"
#define kNotListedButtonTitle @"Not listed"

//Enums
typedef NS_ENUM(NSUInteger,LinkedNumberSections){
    eLinkedNumberSection = 0,
    ePhoneNumberCarrierSection,
    eVoiceMailAndMissedCallAlertSection,
    eActivateOrVerifyInstaVoiceSection,
    eDeleteLinkedNumberSection,
    eReachMeEnableOrDisable
};

typedef NS_ENUM(NSUInteger, ContactUpdateType) {
    eContactUpdateType = 0,
    eContactAddType,
    eContactDeleteType
};

@interface IVLinkedNumberVoiceMailViewController ()<IVVoiceMailCarrierSelectionProtocol, SettingProtocol, UIAlertViewDelegate, ProfileProtocol, IVCarrierSearchDelegate,UITextViewDelegate,UITextFieldDelegate>{
    NSInteger numberOfSections;
    CGFloat sectionFooterHeight;
    UIView *activateBackGroundView;
    int countryCodeCount;
}

- (IBAction)deActivateVoiceMail:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *deActivateButton;
@property (weak, nonatomic) IBOutlet UITableView *linkedNumberVoiceMailTableView;
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

@end

@implementation IVLinkedNumberVoiceMailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isValidCarrierName = NO;
    numberOfSections = 6;
    //Get the missed call information.
    //[appDelegate.engObj getMissedCallInfo:self.phoneNumber];
    
    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    
    self.isValidCarrierName = NO;
    
    BOOL isVoicemailSupported = [[ConfigurationReader sharedConfgReaderObj]getVoicemailSupportedFlag];
    if(isVoicemailSupported) {
        self.carrierDetailsText =  NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
        self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
        numberOfSections = 6;
    } else {
        self.carrierDetailsText =  NSLocalizedString(kCarrierNotSupporttedText, nil);
        self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
        numberOfSections = 5;
    }
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer: tapRec];
    
    self.title = NSLocalizedString(@"Linked mobile number", nil);
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpAction)];
    self.navigationItem.rightBarButtonItem = helpButton;
    
    self.currentNetworkName = NSLocalizedString(kSelectCarrierButtonTitle, nil);
    self.sectionTitleArray = @[@"", @"", @"", @""];
    [Setting sharedSetting].delegate = self;
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
        if ([[[phoneNumberDetails objectAtIndex:i] valueForKey:@"contact_id"] isEqualToString:self.phoneNumber]) {
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

- (void)getCountryCodeCount
{
 
    NSString *countryCode = @"";
    
    UserProfileModel *model = [[Profile sharedUserProfile]profileData];
    NSMutableArray *phoneNumberDetails = model.additionalVerifiedNumbers;
    for (int i = 0; i < phoneNumberDetails.count; i++) {
        if ([[[phoneNumberDetails objectAtIndex:i] valueForKey:@"contact_id"] isEqualToString:self.phoneNumber]) {
            countryCode = [[phoneNumberDetails objectAtIndex:i] valueForKey:@"country_code"];
        }
    }
    
    countryCodeCount = 0;
    
    for (int i = 0; i < phoneNumberDetails.count; i++) {
        if ([[[phoneNumberDetails objectAtIndex:i] valueForKey:@"country_code"] isEqualToString:countryCode]) {
            countryCodeCount ++;
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    //Get the settings information.
    
    self.isActivationFailed = NO;
    self.isActivationRequested = NO;
    self.isActivationSuccess = NO;
    
    //For Testing Purpose
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:4];
//    notification.alertTitle = @"ACTIVATION SUCCESSFULL";
//    notification.alertBody = [NSString stringWithFormat:@"InstaVoice is active on %@",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.phoneNumber,@"phone_number",@"hlr_activation",@"notification_type", nil];
//    notification.userInfo = userInfo;
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    [Setting sharedSetting].delegate = self;
    
    [Profile sharedUserProfile].delegate = self;
    
    [self loadLatestDataFromServer];
    
    self.uiType = VOICEMAIL_LINKED_NUMBER_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    
    NumberInfo *numberDetails = [[Setting sharedSetting]customNumberInfoForPhoneNumber:self.phoneNumber];
    
    if(numberDetails.imgName.length > 0){
        self.imageName = numberDetails.imgName;
    }else{
        if (self.imageName.length > 0)
            self.imageName = [self.imageName stringByReplacingOccurrencesOfString:@"_icon" withString:@""];
        else
            self.imageName = @"iphone";
        
    }
    
    [self getCountryCodeCount];
    
//    if (countryCodeCount > 1) {
//        NSLog(@"%@",[NSString stringWithFormat:@"%@ Number %d", [self getCountryCode], countryCodeCount]);
//    }else{
//        NSLog(@"%@",[NSString stringWithFormat:@"%@ Number", [self getCountryCode]]);
//    }
    
    if (numberDetails.titleName.length > 0) {
        self.titleName = numberDetails.titleName;
    }else{
        
        NSString *numberTitleName;
        if (countryCodeCount > 1) {
            numberTitleName = [NSString stringWithFormat:@"%@ Number %d", [self getCountryCode], countryCodeCount];
        }else{
            numberTitleName = [NSString stringWithFormat:@"%@ Number", [self getCountryCode]];
        }
        
        self.titleName = numberTitleName;
    }
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    [[[self navigationController] navigationBar] setNeedsLayout];
    
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
        if(!self.additionalActiInfo.length) {
            KLog(@"Debug");
            //self.AdditionalActiInfo = @"Please goto the website www.metrpcs.com and add the value bundle to enable the call.";
        }
        
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
        numberOfSections = 3;
    }
    
    //
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
    
    if ([[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP]) {
        [self showProgressBar];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    NumberInfo *currentNumberInfo = [[NumberInfo alloc]init];
    currentNumberInfo.phoneNumber = self.phoneNumber;
    currentNumberInfo.imgName = self.imageName;
    currentNumberInfo.titleName = self.titleName;
    [[Setting sharedSetting]updateNumberSettingsInfo:currentNumberInfo];
    
}

#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    [self.linkedNumberVoiceMailTableView reloadData];
}

- (void)showDeactivateButton
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    
    if ([self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && carrierDetails && self.voiceMailInfo.countryVoicemailSupport)
        self.deActivateButton.hidden = NO;
    else
        self.deActivateButton.hidden = YES;
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
    IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
    self.additionalActiInfo = ccInfo.ussdInfo.additionalActiInfo;
    if(!self.additionalActiInfo.length) {
        KLog(@"Debug");
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
        self.carrierDetailsText = NSLocalizedString(@"Sorry, InstaVoice Voicemail service is not available in your region at the moment. We are working hard to make it available very soon.", nil);
        self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not supported", nil);
        numberOfSections = 3;
        [self.linkedNumberVoiceMailTableView reloadData];
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
            numberOfSections = 5;
            [self.linkedNumberVoiceMailTableView reloadData];
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
                            numberOfSections = 6;
                            [self.linkedNumberVoiceMailTableView reloadData];
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
                numberOfSections = 6;
                [self.linkedNumberVoiceMailTableView reloadData];
                return;
            }
            
            if (self.isValidCarrierName && self.isCarrierSupportedForVoiceMailSetup && self.isVoiceMailAndMissedCallDeactivated && !self.voiceMailInfo.isVoiceMailEnabled) {
                //Set the current screen based on the voice mail configured status
                //self.currentScreen = eCarrierSupportedScreen;
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not Enabled", nil);
                self.carrierDetailsText = NSLocalizedString(@"Activate InstaVoice to start receiving voicemails and missed calls", nil);
                numberOfSections = 6;
            }
            else if (self.isValidCarrierName && !self.isCarrierSupportedForVoiceMailSetup && !self.isVoiceMailAndMissedCallDeactivated){
                //self.currentScreen = eCarrierNotSupportedScreen;
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
                self.carrierDetailsText = NSLocalizedString(@"Sorry, InstaVoice Voicemail service is not available in your region at the moment. We are working hard to make it available very soon.", nil);
                numberOfSections = 5;
            }
            else {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
                self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
                numberOfSections = 6;
                
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
                numberOfSections = 6;
                [self.linkedNumberVoiceMailTableView reloadData];
                return;
            }
            if (self.isValidCarrierName && self.isCarrierSupportedForVoiceMailSetup && self.isVoiceMailAndMissedCallDeactivated && !self.voiceMailInfo.isVoiceMailEnabled) {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not Enabled", nil);
                self.carrierDetailsText = NSLocalizedString(@"Activate InstaVoice to start receving voicemails and missed calls", nil);
                numberOfSections = 6;
                
            }
            else if (self.isValidCarrierName && !self.isCarrierSupportedForVoiceMailSetup && !self.isVoiceMailAndMissedCallDeactivated) {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
                self.carrierDetailsText = NSLocalizedString(@"Sorry, InstaVoice Voicemail service is not available in your region at the moment. We are working hard to make it available very soon.", nil);
                numberOfSections = 5;
            }
            else {
                
                self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
                self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
                numberOfSections = 6;
                
            }
        }
    }
    else {
        
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
                            //[self loadSucessfullyActivatedController];
                            numberOfSections = 6;
                            [self.linkedNumberVoiceMailTableView reloadData];
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
        
        if (!self.isValidCarrierName) {
            
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
            self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
            numberOfSections = 6;
            [self.linkedNumberVoiceMailTableView reloadData];
            return;
        }
        
        if (self.isValidCarrierName && self.isCarrierSupportedForVoiceMailSetup && self.isVoiceMailAndMissedCallDeactivated && !self.voiceMailInfo.isVoiceMailEnabled)  {
            
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Not Enabled", nil);
            self.carrierDetailsText = NSLocalizedString(@"Activate InstaVoice to start receiving voicemails and missed calls", nil);
            numberOfSections = 6;
        }
        else if (self.isValidCarrierName && !self.isCarrierSupportedForVoiceMailSetup && !self.isVoiceMailAndMissedCallDeactivated){
            //self.currentScreen = eCarrierNotSupportedScreen;
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not supported", nil);
            self.carrierDetailsText = NSLocalizedString(@"Sorry, InstaVoice Voicemail service is not available in your region at the moment. We are working hard to make it available very soon.", nil);
            numberOfSections = 5;
        }
        else {
            
            self.carrierSelectionOrEnableStatus = NSLocalizedString(@"Carrier not selected", nil);
            self.carrierDetailsText = NSLocalizedString(@"Select a carrier to enable voicemail and missed call service", nil);
            numberOfSections = 6;
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
    [self.linkedNumberVoiceMailTableView reloadData];
}

#pragma mark - Settings Protocol Methods -

- (void)fetchListOfCarriersForCountry:(SettingModel *)modelData withFetchStatus:(BOOL)withFetchStatus {
    
    //hide loading Indicator
    //[self hideLoadingIndicator];
    
    //NOV 24, 2016
    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    //
    
    if (withFetchStatus) {
        //Update UI.
        NSArray *listOfCarriers = [[Setting sharedSetting]carrierListForCountry:self.voiceMailInfo.carrierCountryCode];
        self.currentCarrierList = listOfCarriers;
        self.currentNetworkName = [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList];
    }
    
}

- (void)fetchSettingCompletedWith:(SettingModel*)modelData withFetchStatus:(BOOL)withFetchStatus {
    
    //Settings has been updated successfully, update the UI.
    if (withFetchStatus) {
        //Determine the network name from the network ID.
        self.currentNetworkName = [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList];
        [self loadLatestDataFromServer];
        [self updateUIBasedOnVoiceMailInfo:self.voiceMailInfo];
        [self hideProgressBar];
        [self closeActivateBackgroundView];
        
        if(self.voiceMailInfo.countryVoicemailSupport)
            [self pushToSelectCarrierScreen];
        else
            [[ConfigurationReader sharedConfgReaderObj] setOTPVerified:NO];
    }
}

- (void)pushToSelectCarrierScreen
{
    if ([[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP] && self.voiceMailInfo.countryVoicemailSupport) {
        [[ConfigurationReader sharedConfgReaderObj] setOTPVerified:NO];
        self.currentSettingsModel = [Setting sharedSetting].data;
        for (VoiceMailInfo *voiceMailInfo in self.currentSettingsModel.voiceMailInfo) {
            if([voiceMailInfo.phoneNumber isEqualToString:[[ConfigurationReader sharedConfgReaderObj] getVerifiedOTPNumber]]) {
                IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:[[ConfigurationReader sharedConfgReaderObj] getVerifiedOTPNumber]];
                NSArray *listOfCarriers = [[Setting sharedSetting]carrierListForCountry:voiceMailInfo.carrierCountryCode];
                if(listOfCarriers && listOfCarriers.count) {
                    if (!self.carrierSearchViewController) {
                        UIStoryboard *voiceMailSettingsStorybaord = [UIStoryboard storyboardWithName:@"IVVoiceMailMissedCallSettingsStoryBoard" bundle:[NSBundle mainBundle]];
                        self.carrierSearchViewController = [voiceMailSettingsStorybaord instantiateViewControllerWithIdentifier:@"IVCarrierSearchView"];
                    }
                    
                    if (![self.navigationController.topViewController isKindOfClass:[IVCarrierSearchViewController class]]) {
                        self.carrierSearchViewController.carrierList = listOfCarriers;
                        self.carrierSearchViewController.voiceMailInfo = voiceMailInfo;
                        self.carrierSearchViewController.selectedCountryCarrierInfo = ccInfo;
                        self.carrierSearchViewController.carrierSearchDelegate = self;
                        [self.navigationController pushViewController:self.carrierSearchViewController animated:YES];
                    }
                }
            }
        }
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
        self.currentNetworkName = [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList];
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
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    
    if (self.voiceMailInfo.countryVoicemailSupport && !self.voiceMailInfo.isVoiceMailEnabled && self.isCarrierSupportedForVoiceMailSetup) {
        self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList], self.activationDialNumber];
    }else if (!self.isValidCarrierName || !self.voiceMailInfo.countryVoicemailSupport) {
        self.helpText = kCarrierNotSupporttedHelpText;
    }else if (self.voiceMailInfo.isVoiceMailEnabled) {
        if ([self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && carrierDetails) {
            self.helpText = @"";
        }else if (self.voiceMailInfo.countryVoicemailSupport && self.isCarrierSupportedForVoiceMailSetup){
            self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList], self.activationDialNumber];
        }else if (!self.isValidCarrierName || !self.voiceMailInfo.countryVoicemailSupport || !carrierDetails) {
            self.helpText = kCarrierNotSupporttedHelpText;
        }else{
            if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
                self.helpText = kCarrierNotSupporttedHelpText;
            }else{
                self.helpText = [NSString stringWithFormat:@"%@ %@",kCarrierNotSupporttedHelpText,[self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList]];
            }
            
        }
    }else{
        
        self.helpText = [NSString stringWithFormat:@"%@ %@",kCarrierNotSupporttedHelpText,[self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList]];
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
                if([voiceMailInfo.phoneNumber isEqualToString:self.phoneNumber]) {
                    self.voiceMailInfo = voiceMailInfo;
                }
            }
            
        }
    }
}


#pragma mark - UITableView Datasource Methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(numberOfSections == 6 || numberOfSections == 5)
        return numberOfSections - 1;
    
    return  numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    if (!self.voiceMailInfo.isVoipEnabled || ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1)) {
        if (section == eReachMeEnableOrDisable) {
            return 0;
        }
    }
    return kNumberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == eDeleteLinkedNumberSection || section == eActivateOrVerifyInstaVoiceSection) {
        return 30.0;
    }
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    if (!self.voiceMailInfo.isVoipEnabled || ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1)) {
        if (section == eReachMeEnableOrDisable || section == eActivateOrVerifyInstaVoiceSection) {
            return 0.0;
        }
    }
    return kHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    NSString *titleOfSection;
    
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    
    if (numberOfSections == 3 || numberOfSections == 5) {
        
        if (section == ePhoneNumberCarrierSection)
            titleOfSection = @"Sorry, InstaVoice service is not available in your region at the moment. We are working hard to make it available very soon.";
        else
            titleOfSection = @"";
        
    }else{
        
        if(self.additionalActiInfo.length) {
            
            if (section == ePhoneNumberCarrierSection){
                
                titleOfSection = self.additionalActiInfo;
                
            }else if (section == eVoiceMailAndMissedCallAlertSection){
                if ([self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && carrierDetails)
                    titleOfSection = @"Received in last 30 days";
                else
                    titleOfSection = @"Activate InstaVoice to allow your callers to leave a Missed Call or a Voicemail when you are busy or your phone is not reachable";
            }else
                titleOfSection = @"";
        }else{
            if (section == eVoiceMailAndMissedCallAlertSection){
                if ([self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && carrierDetails)
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
            if([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1){
                titleOfSection = @"";
            }else{
                NSString *detailText = @"";
                if([[[UIDevice currentDevice] systemVersion] integerValue] < 10)
                    detailText = @"ReachMe allows you to receive regular phone calls in the App over Wi-Fi or a mobile data connection.\n\nReachMe calls are supported only in iOS 10.0 or later version.";
                else
                    detailText = @"ReachMe allows you to receive regular phone calls in the App over Wi-Fi or a mobile data connection.";
                
                titleOfSection = detailText;
            }
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
    
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    NSString *titleOfSection;
    if (numberOfSections == 3 || numberOfSections == 5) {
        
        if (section == ePhoneNumberCarrierSection)
            titleOfSection = @"Sorry, InstaVoice service is not available in your region at the moment. We are working hard to make it available very soon.";
        else
            titleOfSection = @"";
        
    }else{
        
        if(self.additionalActiInfo.length) {
            
            if (section == ePhoneNumberCarrierSection){
                
                titleOfSection = self.additionalActiInfo;
                
            }else if (section == eVoiceMailAndMissedCallAlertSection){
                if ([self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && carrierDetails)
                    titleOfSection = @"Received in last 30 days";
                else if (self.isActivationFailed)
                    titleOfSection = @"Activation failed, please check SIM carrier and try again";
                else
                    titleOfSection = @"Activate InstaVoice to allow your callers to leave a Missed Call or a Voicemail when you are busy or your phone is not reachable";
            }else
                titleOfSection = @"";
        }else{
            if (section == eVoiceMailAndMissedCallAlertSection){
                if ([self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && carrierDetails)
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
            if([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1){
                titleOfSection = @"";
            }else{
                NSString *detailText = @"";
                if([[[UIDevice currentDevice] systemVersion] integerValue] < 10)
                    detailText = @"ReachMe allows you to receive regular phone calls in the App over Wi-Fi or a mobile data connection.\n\nReachMe calls are supported only in iOS 10.0 or later version.";
                else
                    detailText = @"ReachMe allows you to receive regular phone calls in the App over Wi-Fi or a mobile data connection.";
                
                titleOfSection = detailText;
            }
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
    label.scrollEnabled = NO;
    [label sizeToFit];
    
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
    
    [tableHeaderView addSubview:label];
    
    return tableHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *countryNotSupported;
    if(numberOfSections == 3)
        countryNotSupported = @"";
    else
        countryNotSupported = @"VOICEMAIL AND MISSED CALL ALERTS";
    
    NSArray *headerTitle = @[@"LINKED NUMBER",@"PHONE NUMBER CARRIER",countryNotSupported,@"",@"",@""];
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 20.0, section == 2?DEVICE_WIDTH - 32.0:(!self.voiceMailInfo.countryVoicemailSupport?DEVICE_WIDTH - 32.0:DEVICE_WIDTH - 170.0), 40.0)];
    label.text = NSLocalizedString([headerTitle objectAtIndex:section], nil);
    label.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    
    NSString *buttonName = @"";
    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.phoneNumber];
    if (carrierInfo) {
        buttonName = @"Change carrier";
    }else{
        CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
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
        case eLinkedNumberSection:
            cellIdentifier = kLinkedNumberVoiceMailCellIdentifier;
            break;
        case ePhoneNumberCarrierSection:
        case eVoiceMailAndMissedCallAlertSection:
            cellIdentifier = kLinkedNumberVoiceMailInfoCellIdentifier;
            break;
        case eReachMeEnableOrDisable:
            cellIdentifier = kLinkedNumberReachMeCellIdentifier;
            break;
        case eActivateOrVerifyInstaVoiceSection:
        case eDeleteLinkedNumberSection:
            cellIdentifier = kLinkedNumberVoiceMailActivateCellIdentifier;
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
    
    if ([self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && self.voiceMailInfo.isVoipEnabled) {
        if (![[ConfigurationReader sharedConfgReaderObj] reachMeVoipStatus:self.phoneNumber]) {
            [self updateReachMeStatusToServer:YES];
            [[ConfigurationReader sharedConfgReaderObj] setReachMeVoipStatus:YES forNumber:self.phoneNumber];
        }
    }else{
        [[ConfigurationReader sharedConfgReaderObj] setReachMeVoipStatus:NO forNumber:self.phoneNumber];
    }
    
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    
    switch (indexPath.section) {
        case eLinkedNumberSection: {
            if ([cell isKindOfClass:[IVLinkedNumberVoiceMailTableViewCell class]]) {
                IVLinkedNumberVoiceMailTableViewCell *linkedNumberSectionCell = (IVLinkedNumberVoiceMailTableViewCell *)cell;
                linkedNumberSectionCell.titleTextField.text = self.titleName;
                linkedNumberSectionCell.iconImageView.image = [UIImage imageNamed:self.imageName];
                linkedNumberSectionCell.linkedNumberInfo.text = [Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
                
                UITapGestureRecognizer *editImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editImageIcon:)];
                [linkedNumberSectionCell.iconImageView addGestureRecognizer:editImage];
                
                linkedNumberSectionCell.titleTextField.delegate = self;
                linkedNumberSectionCell.titleTextField.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                linkedNumberSectionCell.linkedNumberInfo.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
                
            }
            break;
        }
        case ePhoneNumberCarrierSection: {
            if ([cell isKindOfClass:[IVLinkedNumberVoiceMailTableViewCell class]]) {
                IVLinkedNumberVoiceMailTableViewCell *linkedNumberCarrierSelectionCell = (IVLinkedNumberVoiceMailTableViewCell *)cell;
                
                NSString *networkName = @"";
                IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.phoneNumber];
                if (carrierInfo) {
                    networkName = carrierInfo.networkName;
                }else{
                    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
                    
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
                    [linkedNumberCarrierSelectionCell addGestureRecognizer:selectCarrier];
                    
                    linkedNumberCarrierSelectionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                
                linkedNumberCarrierSelectionCell.titleLabel.text = networkName;
                linkedNumberCarrierSelectionCell.activeStatus.hidden = YES;
                linkedNumberCarrierSelectionCell.activeStatusLabel.hidden = YES;
                
                linkedNumberCarrierSelectionCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                
            }
            break;
        }
        case eVoiceMailAndMissedCallAlertSection: {
            if ([cell isKindOfClass:[IVLinkedNumberVoiceMailTableViewCell class]]) {
                IVLinkedNumberVoiceMailTableViewCell *linkedNumberAlertSectionCell = (IVLinkedNumberVoiceMailTableViewCell *)cell;
                
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
                
                if (![self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && carrierDetails)
                    voiceMailAndMissedCallCount = @"Not Active";
            
                if(!self.isCarrierSupportedForVoiceMailSetup)
                    linkedNumberAlertSectionCell.titleLabel.text = self.carrierSelectionOrEnableStatus;
                else
                    linkedNumberAlertSectionCell.titleLabel.text = voiceMailAndMissedCallCount;
                
                if ([self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && carrierDetails) {
                    linkedNumberAlertSectionCell.activeStatus.image = [UIImage imageNamed:@"voicemail_active"];
                    linkedNumberAlertSectionCell.activeStatusLabel.text = @"Active";
                }else{
                    linkedNumberAlertSectionCell.activeStatus.image = [UIImage imageNamed:@"voicemail_not_active"];
                    linkedNumberAlertSectionCell.activeStatusLabel.text = @"Not active";
                }
                
                if (numberOfSections == 3) {
                    [linkedNumberAlertSectionCell.deleteNumber addTarget:self action:@selector(deleteLinkedNumber:) forControlEvents:UIControlEventTouchUpInside];
                    linkedNumberAlertSectionCell.deleteNumber.hidden = NO;
                    linkedNumberAlertSectionCell.activeStatus.hidden = YES;
                    linkedNumberAlertSectionCell.activeStatusLabel.hidden = YES;
                    linkedNumberAlertSectionCell.titleLabel.hidden = YES;
                }else{
                    linkedNumberAlertSectionCell.deleteNumber.hidden = YES;
                    linkedNumberAlertSectionCell.activeStatus.hidden = NO;
                    linkedNumberAlertSectionCell.activeStatusLabel.hidden = NO;
                    linkedNumberAlertSectionCell.titleLabel.hidden = NO;
                }
                
                linkedNumberAlertSectionCell.accessoryType = UITableViewCellAccessoryNone;
                
            }
            break;
        }
        case eReachMeEnableOrDisable: {
            if ([cell isKindOfClass:[IVLinkedNumberVoiceMailTableViewCell class]]) {
                IVLinkedNumberVoiceMailTableViewCell *linkedNumberReachMeSectionCell = (IVLinkedNumberVoiceMailTableViewCell *)cell;
                [linkedNumberReachMeSectionCell.reachMeStatus addTarget:self action:@selector(enableOrDisableReachMe:) forControlEvents:UIControlEventValueChanged];
                
                if (carrierDetails.isVoipStatusEnabled) {
                    [linkedNumberReachMeSectionCell.reachMeStatus setOn:YES];
                    self.isReachMeCallEnabled = YES;
                }else{
                    [linkedNumberReachMeSectionCell.reachMeStatus setOn:NO];
                    self.isReachMeCallEnabled = NO;
                }
                
                if (![self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo]){
                    [linkedNumberReachMeSectionCell.reachMeStatus setOn:NO];
                    self.isReachMeCallEnabled = NO;
                }
                
                linkedNumberReachMeSectionCell.reachMeLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
            }
            break;
        }
        case eActivateOrVerifyInstaVoiceSection: {
            if ([cell isKindOfClass:[IVLinkedNumberVoiceMailTableViewCell class]]) {
                IVLinkedNumberVoiceMailTableViewCell *linkedNumberActivateSectionCell = (IVLinkedNumberVoiceMailTableViewCell *)cell;
                [linkedNumberActivateSectionCell.verifyOrActivateButton addTarget:self action:@selector(verifyInstaVoice:) forControlEvents:UIControlEventTouchUpInside];
                
                if(numberOfSections == 5){
                    [linkedNumberActivateSectionCell.verifyOrActivateButton setTitleColor:[UIColor colorWithRed:(255.0/255.0) green:(50.0/255.0) blue:(56.0/255.0) alpha:1.0f] forState:UIControlStateNormal];
                    [linkedNumberActivateSectionCell.verifyOrActivateButton setTitle:@"DELETE" forState:UIControlStateNormal];
                }else{
                    [linkedNumberActivateSectionCell.verifyOrActivateButton setTitleColor:[UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f] forState:UIControlStateNormal];
                    if ([self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && carrierDetails) {
                        [linkedNumberActivateSectionCell.verifyOrActivateButton setTitle:@"VERIFY INSTAVOICE IS WORKING" forState:UIControlStateNormal];
                        self.linkedNumberVoiceMailTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 45.0, 0.0);
                        self.linkedNumberVoiceMailTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 45.0, 0.0);
                        
                    }else if (self.isActivationRequested){
                        [linkedNumberActivateSectionCell.verifyOrActivateButton setTitle:@"ACTIVATION REQUESTED" forState:UIControlStateNormal];
                    }else{
                        [linkedNumberActivateSectionCell.verifyOrActivateButton setTitle:@"ACTIVATE INSTAVOICE" forState:UIControlStateNormal];
                    }
                }
                
            }
            break;
        }
        case eDeleteLinkedNumberSection: {
            if ([cell isKindOfClass:[IVLinkedNumberVoiceMailTableViewCell class]]) {
                IVLinkedNumberVoiceMailTableViewCell *linkedNumberActivateSectionCell = (IVLinkedNumberVoiceMailTableViewCell *)cell;
                [linkedNumberActivateSectionCell.verifyOrActivateButton addTarget:self action:@selector(deleteLinkedNumber:) forControlEvents:UIControlEventTouchUpInside];
                [linkedNumberActivateSectionCell.verifyOrActivateButton setTitle:@"DELETE" forState:UIControlStateNormal];
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
    [self.linkedNumberVoiceMailTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case eLinkedNumberSection:
            break;
        case ePhoneNumberCarrierSection:
            break;
        case eVoiceMailAndMissedCallAlertSection:
            break;
        case eActivateOrVerifyInstaVoiceSection:
            break;
        case eDeleteLinkedNumberSection:
            break;
        default:
            break;
    }
    
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
        if(self.currentCarrierList && self.currentCarrierList.count) {
            if (!self.carrierSearchViewController) {
                self.carrierSearchViewController = [[UIStoryboard storyboardWithName:@"IVVoiceMailMissedCallSettingsStoryBoard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"IVCarrierSearchView"];
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
        [self.linkedNumberVoiceMailTableView reloadData];
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

- (BOOL)linkedNumberIsActive:(NSString *)phoneNumber withVoiceMailInfo:(VoiceMailInfo *)withVoiceMailInfo
{
    self.currentSettingsModel = [Setting sharedSetting].data;
    
    //check do we have carrier list for the country.
    NSArray *carrierList = [[Setting sharedSetting]carrierListForCountry:withVoiceMailInfo.carrierCountryCode];
    //Get the carrier information for the number.
    CarrierInfo *currentSelectedNumberCarrierInfo = [[Setting sharedSetting] customCarrierInfoForPhoneNumber:phoneNumber];
    if (currentSelectedNumberCarrierInfo) {
        if ([currentSelectedNumberCarrierInfo.networkId isEqualToString:@"-1"] && [currentSelectedNumberCarrierInfo.countryCode isEqualToString:@"-1" ] && [currentSelectedNumberCarrierInfo.vSMSId integerValue] == -1) {
            //We do not have USSD Info - Redirect screen to Carrier Selection page.
            return NO;
        }
        //We have custom settings carrier info
        //Check for the voice mail info
        if (withVoiceMailInfo) {
            //Yes, we have voicemail info
            //check for the voicemail info enabled.
            if (withVoiceMailInfo.isVoiceMailEnabled) {
                
                if (carrierList && [carrierList count]) {
                    //Yes, we have carrier list. Check for the valid carrier in the carrier list.
                    if ([[Setting sharedSetting]hasSupportedCustomCarrierInfo:phoneNumber]) {
                        //Yes, we have valid carrier info
                        
                        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:phoneNumber];
                        if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                            return YES;
                        }
                        else {
                            
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
            else {
                
                return NO;
            }
        }
        else {
            
            return NO;
        }
    }
    else {
        if (withVoiceMailInfo) {
            
            if (withVoiceMailInfo.isVoiceMailEnabled && withVoiceMailInfo.countryVoicemailSupport) {
                
                if (carrierList && [carrierList count]) {
                    
                    if ([[Setting sharedSetting]hasSupportedVoiceMailInfo:phoneNumber]) {
                        
                        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromVoiceMailInfoForPhoneNumber:phoneNumber];
                        if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                            
                            return YES;
                        }
                        else {
                            
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
            else {
                
                
                return NO;
                
            }
            
        }
        else {
            
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
    currentNumberInfo.phoneNumber = self.phoneNumber;
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
//        currentCarrierInfo.phoneNumber = self.phoneNumber;
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
    currentNumberInfo.phoneNumber = self.phoneNumber;
    currentNumberInfo.imgName = self.imageName;
    currentNumberInfo.titleName = self.titleName;
    [[Setting sharedSetting]updateNumberSettingsInfo:currentNumberInfo];
    [[self view] endEditing: YES];
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

- (void)editImageIcon:(UITapGestureRecognizer *)rec
{
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    EditVoiceMailImageIconViewController *editImageIconViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"EditVoiceMailImageIcon"];
    editImageIconViewController.phoneNumber = self.phoneNumber;
    editImageIconViewController.iconName = self.imageName;
    [self.navigationController pushViewController:editImageIconViewController animated:YES];
}

- (IBAction)deleteLinkedNumber:(id)sender
{
    
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
    
    //We are very sure that this button belongs to the LinkedNumber Row.
    //Check the number is verified or non verified. If number is non verified remove from the - nonverified details and update the profile data.
    
    NSString *phoneNumberToBeDeleted = self.phoneNumber;
    //Number should be verified number.
    NSMutableDictionary *dataDictionary = [self dataForUpdatationOfContactToServer:eContactDeleteType withPrimaryPhoneNumberStatus:NO withContactNumber:phoneNumberToBeDeleted withCountryCode:nil];
    
    ManageUserContactAPI* api = [[ManageUserContactAPI alloc]initWithRequest:dataDictionary];
    
    [api callNetworkRequest:api.request withSuccess:^(ManageUserContactAPI *req, NSMutableDictionary *responseObject) {
        
        if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
            [self hideProgressBar];
            EnLogd(@"Error calling manage_user_contact %@ and api request %@",dataDictionary,api.request);
        } else {
            [self hideProgressBar];
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
            
            [self.navigationController popViewControllerAnimated:YES];
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

- (void)turnOffReachMe
{
    [[self view] endEditing:YES];
    
    NSString* alertDetails = [NSString stringWithFormat:@"You will no longer receive calls in the app when your phone number %@ is unreachable i.e. out of coverage, SIM not in phone, or switched off\n\nNote: You will continue receiving Voicemail & Missed Call Alerts",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
    
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
                                   UIButton *btn = [UIButton new];
                                   btn.tag = 1;
                                   [self verifyInstaVoice:btn];
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
    currentCarrierInfo.phoneNumber = self.phoneNumber;
    currentCarrierInfo.countryCode = self.selectedCountryCarrierInfo.countryCode;
    currentCarrierInfo.networkId = self.selectedCountryCarrierInfo.networkId;
    currentCarrierInfo.vSMSId = self.selectedCountryCarrierInfo.vsmsNodeId;
    currentCarrierInfo.isVoipEnabled = self.voiceMailInfo.isVoipEnabled;
    currentCarrierInfo.isVoipStatusEnabled = isEnabled;
    //Update the carrier info
    [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
    [self.linkedNumberVoiceMailTableView reloadData];
#ifdef ENABLE_LATER
    [appDelegate prepareVoipCallBlockedNumbers];
#endif
}

- (IBAction)enableOrDisableReachMe:(id)sender
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [self.linkedNumberVoiceMailTableView reloadData];
        return;
    }
    
    if (![self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo]) {
        [self activateInstaVoice];
    }else{
        if (carrierDetails.isVoipStatusEnabled) {
            [self turnOffReachMe];
        }else{
            [self updateReachMeStatusToServer:YES];
        }
    }
    
    [self.linkedNumberVoiceMailTableView reloadData];
}

- (IBAction)verifyInstaVoice:(id)sender
{
    
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        
        IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
        
        CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
        
        if (numberOfSections == 5) {
            UIButton *btn = (UIButton*)sender;
            if (btn.tag != 1) {
              [self deleteLinkedNumber:nil];  
            }
        }else{
            
            if (!ccInfo) {
                [ScreenUtility showAlert:@"Please select carrier to activate"];
                return;
            }
            
            if ([self linkedNumberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && carrierDetails) {
                IVVoiceMailVerifyInstaVoiceViewController *voiceMailVerifyInstaVoiceViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"VoiceMailVerifyInstaVoice"];
                voiceMailVerifyInstaVoiceViewController.phoneNumber = self.phoneNumber;
                [self.navigationController pushViewController:voiceMailVerifyInstaVoiceViewController animated:YES];
            }else if (ccInfo.ussdInfo.isHLREnabled){
                self.isActivationRequested = YES;
                [self.linkedNumberVoiceMailTableView reloadData];
                [self showActivateBackgroundView];
                [self showProgressBar];
                
                [NSTimer scheduledTimerWithTimeInterval:3.0
                                                 target:self
                                               selector:@selector(activationTimeExceeds:)
                                               userInfo:nil
                                                repeats:YES];
                
                NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
                [requestDic setValue:self.phoneNumber forKey:@"phone_num"];
                [requestDic setValue:@"enable" forKey:@"action"];
                
                VoiceMailHLRAPI* api = [[VoiceMailHLRAPI alloc]initWithRequest:requestDic];
                [api callNetworkRequest:requestDic withSuccess:^(VoiceMailHLRAPI *req, NSMutableDictionary *responseObject) {
                    //CMP NSLog(@"Success:%@",responseObject);
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
                    [self.linkedNumberVoiceMailTableView reloadData];
                    
                    EnLogd(@"*** Error fetching user contact: %@, %@",req,[error description]);
                    KLog(@"*** Error fetching user contact: %@, %@",req,[error description]);
                    
                }];
                
            }else{
                IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.phoneNumber];
                
                IVVoiceMailActivateViewController *voiceMailActivateViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"VoiceMailActivate"];
                voiceMailActivateViewController.phoneNumber = self.phoneNumber;
                voiceMailActivateViewController.activationCode = carrierInfo.ussdInfo.actiAll;
                [self.navigationController pushViewController:voiceMailActivateViewController animated:YES];
            }
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

- (void)activationTimeExceeds:(NSTimer *)timer{
    [self closeActivateBackgroundView];
}

- (IBAction)deActivateVoiceMail:(id)sender {
    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.phoneNumber];
    
    IVVoiceMailDeActivateViewController *voiceMailDeActivateViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"VoiceMailDeActivate"];
    voiceMailDeActivateViewController.phoneNumber = self.phoneNumber;
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
