//
//  IVSettingsListViewController.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 15/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVSettingsListViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "IVSettingsProfileTableViewCell.h"
#import "IVSettingsGeneralTableViewCell.h"
#import "IVSettingsGeneralWithoutSubTitleTableViewCell.h"
#import "IVInstaVoiceInfoTableViewCell.h"
#import "IVSettingsNumbersTableViewCell.h"
#import "IVColors.h"
#import "Common.h"
#import "IVSettingsAboutInstaVoiceViewController.h"
#import "MyProfileTableViewController.h"
#import "SettingsChatMenuViewController.h"
#import "SettingsSharingMenuViewController.h"
//VoiceMail/MissedCallSettings
//#import "IVAccountSettingsViewController.h"
#import "RegistrationApi.h"
#import "FetchUserContactAPI.h"

//VoiceMail/MissedCallSettings
#import "IVVoiceMailListViewController.h"
#import "IVVoiceMailGreetingsViewController.h"
#import "IVVoiceMailEmailNotificationViewController.h"
#import "IVVoiceMailDeActivateViewController.h"
#import "IVVoiceMailActivateViewController.h"

#import "ChangePrimaryNumberViewController.h"
#import "MZFormSheetController.h"
#import "ManageUserContactAPI.h"
#import "NBPhoneNumberUtil.h"
#import "ContactDetailData.h"
#import "InsideConversationScreen.h"
#import "VerifyUserAPI.h"
#import "VerificationOTPViewController.h"
#import "LinkAdditionalMobileNumberViewController.h"

#import "IVPrimaryNumberVoiceMailViewController.h"
#import "IVLinkedNumberVoiceMailViewController.h"
#import "ActivateReachMeViewController.h"
#import "IVSettingsCountryCarrierInfo.h"
#import "IVCarrierSearchViewController.h"
#import "IVCarrierCircleViewController.h"
//Settings
#import "Setting.h"
#import "Profile.h"

#import "IVFileLocator.h"
#import "DownloadProfilePic.h"

#import "Log.h"

#import "LinphoneCoreSettingsStore.h"

#import "InviteCodeViewController.h"

#import "VoiceTotextTableViewController.h"

//Constants
#define kNumberOfSections 5
#define kNumberOfCellsInProfileSection 1
#define kNumberOfCellsInNumbersSection 1
#define kNumberOfCellsInGeneralSection 8
#define kNumbetOfCellsInInstaVoiceInfoSection 1
#define kHeaderHeightOffset 20.0

#define kProfileCellIdentifier @"IVSettingsProfileCell"
#define kGeneralCellIdentifier @"IVSettingsGeneralCell"
#define kGeneralWithoutSubTitleCellIdentifier @"IVSettingsGeneralWithoutSubTitleCell"
#define kInstaVoiceInfoCellIdentifier @"IVInfoCell"
#define kNumbersCellIdentifier @"IVNumbersCell"
#define kPrimaryNumberCellIdentifier @"IVPrimaryNumberCell"
#define kAddNumberCellIdentifier @"IVAddNumberCell"
#define kLinkedNumberCellIdentifier @"LinkedNumbersCell"
#define kChangePrimaryNumberCellIdentifier @"ChangePrimaryNumberCell"

#define kCellImageKey @"cellImage"
#define kCellTitleKey @"cellTitle"
#define kCellSubTitleKey @"cellSubTitle"
#define kCellImageTintColor @"cellImageTintColor"

//Segue identifier
#define kShowAboutInstaVoiceView @"ShowAboutInstaVoiceView"
#define kShowAccountSettingsView @"ShowAccountSettingsView"

#define kContactIdKey @"contact_id"
#define kCountryCodeKey @"country_code"

#define SECTION_GENERAL_TAG     0x679879
#define SECTION_INFO_TAG    0x689789

#define kPrimaryNumberCanNotDeleteErrorCode 88

#define kCarrierNotSupporttedHelpText @"Hi, I'm interested in InstaVoice Voicemail/Missed Call alerts. Please inform me when it's made available for my Carrier:"

//Enums
typedef NS_ENUM(NSUInteger,Sections){
    eProfileInfo = 0,
    ePrimaryNumberSection,
    eChangePrimaryNumberSection,
    eLinkedNumbersSection,
    eGeneralSection,
    eInstaVoiceInfoSection,
};

typedef NS_ENUM(NSUInteger,SettingsCells){
    eReachMeCreditsCell = 0,
    eVoiceToTextCell,
    eVoiceMailGreetingsCell,
    eEmailNotificationsCell,
    eRedeemCodeCell,
    eAccountInfoCell,
    eCarrierSupportCell
};

typedef NS_ENUM(NSUInteger, ContactUpdateType) {
    eContactUpdateType = 0,
    eContactAddType,
    eContactDeleteType
};

@interface IVSettingsListViewController () <SettingProtocol,ProfileProtocol,VerificationOTPViewControllerDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>{
    BOOL isExpanded;
}
@property (weak, nonatomic)  IVSettingsGeneralTableViewCell *settingsGeneralTableViewCell;
@property (weak, nonatomic)  IVInstaVoiceInfoTableViewCell *settingsInstaVoiceInfoTableViewCell;

@property (weak, nonatomic) IBOutlet UITableView *settingsListTableView;
@property (nonatomic, strong) NSArray *sectionTitleArray;
@property (nonatomic, strong) NSArray *profileCellInfoList;
@property (nonatomic, strong) NSArray *generalCellInfoList;
@property (nonatomic, strong) NSArray *instaVoiceInfoList;
//VoiceMailSettings Related
@property (nonatomic, strong) NSString *primaryNumber;
@property (nonatomic, strong) NSArray *customImageName;
@property (nonatomic, strong) VoiceMailInfo *primaryNumberVoiceMailInfo;
@property (nonatomic, strong) NSArray *additionalNumbers;
@property (nonatomic, strong) NSMutableArray *additionalNumbersVoiceMailInfo;
@property (nonatomic, strong) NSMutableArray *additionalLinkedVerifiedNumbers, *additionalLinkedNonVerifiedNumbers, *linkedMobileNumbers;
@property (nonatomic, strong) NSMutableArray *verifiedSecondaryNumbers;
@property (nonatomic, strong) NSMutableArray *verifiedNumbers;
@property (nonatomic, strong) NSMutableArray *verifiedNumberDetails;
@property (nonatomic, assign) BOOL isLogEnabled;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

//NOV 8, 2016
@property (nonatomic, strong) NSString* carrierSupportNetworkName;
@property (nonatomic, strong) NSString* carrierSupportLink;
@property (nonatomic, strong) NSString* carrierSupportLogo;
@property BOOL hideCarrierSupportCell;
//

@property (nonatomic, strong) NSString *currentNetworkName;
@property (nonatomic, strong) NSString *helpText;
@property (nonatomic, strong) NSString *activationDialNumber;
@property (nonatomic, strong) NSMutableArray *helpTextArray;
@property (nonatomic, strong) NSMutableArray *supportContactList;

@property (nonatomic, strong) SettingModel *currentSettingsModel;

@property (nonatomic, strong) NSString *randomImageName;

@property (nonatomic, assign) BOOL isEditingCell;

@property (atomic) BOOL lpRegStatus;

@property (nonatomic, strong) IVCarrierSearchViewController *carrierSearchViewController;

@end

@implementation IVSettingsListViewController

LinphoneCoreSettingsStore* lpSettingsObj;


#pragma mark - View Life Cycle -
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //Setup the title
        self.title = NSLocalizedString(@"Settings", nil);
        
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) image:[UIImage imageNamed:@"settings"] selectedImage:[UIImage imageNamed:@"settings-selected"]]];
        
        self.hideCarrierSupportCell = YES;
        self.carrierSupportLink = @"";
        self.carrierSupportNetworkName = @"";
        self.lpRegStatus = FALSE;
        lpSettingsObj = [LinphoneCoreSettingsStore sharedLinphoneCoreSettingsStore];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isEditingCell = NO;
    isExpanded = NO;
    self.additionalLinkedVerifiedNumbers = [[NSMutableArray alloc]init];
    self.additionalLinkedNonVerifiedNumbers = [[NSMutableArray alloc]init];
    self.linkedMobileNumbers = [[NSMutableArray alloc]init];
    self.sectionTitleArray = @[@"", @"", @"", @"", @""];
    self.profileCellInfoList = [self createDataSourceForCellsInSection:eProfileInfo];
    self.generalCellInfoList = [self createDataSourceForCellsInSection:eGeneralSection];
    self.instaVoiceInfoList = [self createDataSourceForCellsInSection:eInstaVoiceInfoSection];
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc]
                             initWithTarget:self
                             action:@selector(handleLongPress:)];
    
    [self.longPressGesture setNumberOfTouchesRequired:1];
    [self.longPressGesture setMinimumPressDuration:2];
    self.longPressGesture.delegate = self;
    [self.settingsListTableView addGestureRecognizer:self.longPressGesture];
    
    [self.settingsListTableView setNeedsLayout];
    [self.settingsListTableView layoutIfNeeded];
    [self.settingsListTableView setEditing:YES animated:YES];
    self.settingsListTableView.allowsSelectionDuringEditing = YES;
    [[Setting sharedSetting]removeOrAddTestCarrierBasedOnShowCarrierStatus];
    [self viewWillAppear:YES];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appBecameActive)
                                                name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(registrationUpdateEvent:)
                                               name:kLinphoneRegistrationUpdate
                                             object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    self.extendedLayoutIncludesOpaqueBars = YES;
//    if (@available(iOS 11.0, *)) {
//        self. navigationController.navigationBar.prefersLargeTitles = TRUE;
//    } else {
//        // Fallback on earlier versions
//    }
    
    //Fetch User Contact - We need this call to retrieve the - Additional Verified Numbers, this information we save in the profile data.
    //isExpanded = NO;
    [self fetchUserContacts];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = NO;
    [self configureHelpAndSuggestion];
    self.isLogEnabled = [[ConfigurationReader sharedConfgReaderObj] getEnableLogFlag];//NOV 23, 2016
    self.uiType = SETTINGS_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    
    self.primaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
    
    //Fetch current settings.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@NO forKey:kUserSettingsFetched];
    [userDefaults synchronize];
    [Setting sharedSetting].delegate = self;
    [[Setting sharedSetting]getUserSettingFromServer];
    
    [Profile sharedUserProfile].delegate = self;
    [[Profile sharedUserProfile]getProfileDataFromServer];
    
    self.profileCellInfoList = [self createDataSourceForCellsInSection:eProfileInfo];
    self.generalCellInfoList = [self createDataSourceForCellsInSection:eGeneralSection];
    self.instaVoiceInfoList = [self createDataSourceForCellsInSection:eInstaVoiceInfoSection];
    
    [self.settingsGeneralTableViewCell layoutIfNeeded];
    
    [self processLinkedNumbersFromProfileData];
    
    //Settings - TextFlow related changes notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    //self.hideCarrierSupportCell = YES;
    [self showCarrierSupport];
    [self loadLatestDataFromServer];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    [[ConfigurationReader sharedConfgReaderObj] setOnBoardingStatus:NO];
    self.lpRegStatus = [lpSettingsObj isRegistered];
    
    appDelegate.tabBarController.tabBar.hidden = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (@available(iOS 11.0, *)) {
        self. navigationController.navigationBar.prefersLargeTitles = FALSE;
    } else {
        // Fallback on earlier versions
    }
    //Remove ContentSizeCategoryDidChangeNotification
    self.isEditingCell = NO;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

#pragma mark -

#pragma mark Update Registration Status
- (void) appBecameActive {
    self.lpRegStatus = [lpSettingsObj isRegistered];
    [self.settingsListTableView reloadData];
}

-(void) registrationUpdateEvent:(NSNotification*)notif {
    
    LinphoneRegistrationState state =  [[notif.userInfo objectForKey:@"state"] intValue];
    switch (state) {
        case LinphoneRegistrationOk:
            self.lpRegStatus = TRUE;
            [self.settingsListTableView reloadData];
            break;
        case LinphoneRegistrationNone:
        case LinphoneRegistrationCleared:
        case LinphoneRegistrationFailed:
        case LinphoneRegistrationProgress:
            self.lpRegStatus = FALSE;
            break;
            
        default:
            break;
    }
}
#pragma mark -


#pragma mark - Private Methdos -

- (void)loadLatestDataFromServer {
    
    KLog(@"loadLatestDataFromServer");
    
    self.currentSettingsModel = [Setting sharedSetting].data;
    if (self.currentSettingsModel) {
        
        self.additionalNumbersVoiceMailInfo = [[NSMutableArray alloc]init];
        if (self.currentSettingsModel.voiceMailInfo && [self.currentSettingsModel.voiceMailInfo count]) {
            NSMutableArray *additionalNumberList = [[NSMutableArray alloc]init];
            for (VoiceMailInfo *voiceMailInfo in self.currentSettingsModel.voiceMailInfo) {
                if(![voiceMailInfo.phoneNumber isEqualToString:self.primaryNumber]) {
                    [self.additionalNumbersVoiceMailInfo addObject:voiceMailInfo];
                    [additionalNumberList addObject:voiceMailInfo.phoneNumber];
                }
                else
                    self.primaryNumberVoiceMailInfo = voiceMailInfo;
            }
            self.additionalNumbers = additionalNumberList;
            
            for (int i = 0; i<[self.linkedMobileNumbers count]; i++) {
                if (![[self.additionalLinkedVerifiedNumbers valueForKey:kContactIdKey] containsObject:[self.linkedMobileNumbers objectAtIndex:i]]) {
                    [self.additionalNumbersVoiceMailInfo insertObject:@"" atIndex:i];
                }
            }
        }
    }
}

- (BOOL)linkedNumberIsActive:(NSString *)phoneNumber withVoiceMailInfo:(VoiceMailInfo *)withVoiceMailInfo
{
    self.currentSettingsModel = [Setting sharedSetting].data;
    
    //check do we have carrier list for the country.
    NSArray *carrierList = [[Setting sharedSetting]carrierListForCountry:withVoiceMailInfo.carrierCountryCode];
    
    //We have only primary number - based on the voicemail info - decide the next screen.
    //Check whether - voicemail has been already activated? If activated - redirect user to the successfully activated screen.
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
                    //Fetch carrier list for country.
                    [[Setting sharedSetting]fetchListOfCarriersForCountry:withVoiceMailInfo.carrierCountryCode];
                    
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
    
    //We do not have custom settings information. - check for sim information for primary phone only
    else {
        BOOL checkForVoiceMailInfo = YES;
        
        //Its not primary phone number - so check for voice mail info
        if (checkForVoiceMailInfo) {
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
                        //Fetch carrier list for country.
                        [[Setting sharedSetting]fetchListOfCarriersForCountry:withVoiceMailInfo.carrierCountryCode];
                        
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
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDataSource Methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    
    switch (section) {
        case eProfileInfo:
            numberOfRows = kNumberOfCellsInProfileSection;
            break;
        case ePrimaryNumberSection:
            numberOfRows = kNumberOfCellsInNumbersSection;
            break;
        case eChangePrimaryNumberSection:
            numberOfRows = 1;
            break;
        case eLinkedNumbersSection:
            if(isExpanded){
                if (self.linkedMobileNumbers.count == 10)
                    numberOfRows = self.linkedMobileNumbers.count + 1;
                else
                    numberOfRows = self.linkedMobileNumbers.count + 3;
            }else
                numberOfRows = 1;
            break;
        case eGeneralSection:
            numberOfRows = kNumberOfCellsInGeneralSection;
            break;
        case eInstaVoiceInfoSection:
            numberOfRows = kNumbetOfCellsInInstaVoiceInfoSection;
            break;
        default:
            break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    //self.settingsListTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    static NSString *cellIdentifier;
    switch (indexPath.section) {
        case eProfileInfo: {
            cellIdentifier = kProfileCellIdentifier;
            break;
        }
        case ePrimaryNumberSection: {
            cellIdentifier = kPrimaryNumberCellIdentifier;
            break;
        }
        case eChangePrimaryNumberSection: {
            cellIdentifier = kChangePrimaryNumberCellIdentifier;
            break;
        }
        case eLinkedNumbersSection: {
            if(indexPath.row > 0 && indexPath.row <= self.linkedMobileNumbers.count)
                cellIdentifier = kNumbersCellIdentifier;
            else if(indexPath.row == self.linkedMobileNumbers.count + 1 || indexPath.row == self.linkedMobileNumbers.count + 2)
                cellIdentifier = kAddNumberCellIdentifier;
            else
                cellIdentifier = kLinkedNumberCellIdentifier;
            
            break;
        }
        case eGeneralSection: {
            if (indexPath.row == 7) {
                cellIdentifier = kInstaVoiceInfoCellIdentifier;
            }else if(indexPath.row > 5){
                cellIdentifier = kGeneralWithoutSubTitleCellIdentifier;
            }else{
                cellIdentifier = kGeneralCellIdentifier;
            }
            
            break;
        }
        case eInstaVoiceInfoSection: {
            cellIdentifier = kInstaVoiceInfoCellIdentifier;
            break;
        }
        default:
            break;
    }
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    if (indexPath.section == eLinkedNumbersSection) {
        if(indexPath.row == 0)
            [cell setSeparatorInset:UIEdgeInsetsZero];
        else
            [cell setSeparatorInset:UIEdgeInsetsMake(0.0, 61.0, 0.0, 0.0)];
    }else{
        [cell setSeparatorInset:UIEdgeInsetsMake(0.0, 61.0, 0.0, 0.0)];
    }
    
    [cell layoutIfNeeded];
    [cell layoutSubviews];
    [cell setNeedsLayout];
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title;
    title = [self.sectionTitleArray objectAtIndex:section];
    return title;
    
}

#pragma mark - TableView Delegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.settingsListTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == eProfileInfo) {
        
        MyProfileTableViewController* vc = [[MyProfileTableViewController alloc]initWithNibName:@"MyProfileTableViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];//KM
    
    }else if (ePrimaryNumberSection == indexPath.section) {
        
        if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
            //[[Setting sharedSetting]fetchListOfCarriersForCountry:self.primaryNumberVoiceMailInfo.carrierCountryCode];
        }
        
        CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
        if (!carrierDetails && self.primaryNumberVoiceMailInfo.countryVoicemailSupport) {
            [self selectCarrier:self.primaryNumberVoiceMailInfo];
            return;
        }
        
        
        //ActivateReachMe
        ActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ActivateReachMe"];
        activateReachMe.phoneNumber = self.primaryNumber;
        activateReachMe.isPrimaryNumber = YES;
        activateReachMe.voiceMailInfo = self.primaryNumberVoiceMailInfo;
        [self.navigationController pushViewController:activateReachMe animated:YES];
        
    }else if (eLinkedNumbersSection == indexPath.section) {
        
        if (indexPath.row == 0) {
            isExpanded = !isExpanded;
            [self.settingsListTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            return;
        }
        
        if (self.linkedMobileNumbers.count > 0) {
            if(indexPath.row <= self.linkedMobileNumbers.count)
            {
                for (int i = 0; i<[self.linkedMobileNumbers count]; i++) {
                    if (![[self.additionalLinkedVerifiedNumbers valueForKey:kContactIdKey] containsObject:[self.linkedMobileNumbers objectAtIndex:i]]) {
                        [self.additionalNumbersVoiceMailInfo insertObject:@"" atIndex:i];
                    }
                }
                
                VoiceMailInfo *voiceMailInfo;
                NSString *phoneNumber;
                
                if (![[self.additionalLinkedVerifiedNumbers valueForKey:kContactIdKey] containsObject:[self.linkedMobileNumbers objectAtIndex:indexPath.row - 1]]) {
                    return;
                }
                
                if (self.additionalNumbersVoiceMailInfo && [self.additionalNumbersVoiceMailInfo count]) {
                    voiceMailInfo = [self.additionalNumbersVoiceMailInfo objectAtIndex:indexPath.row - 1];
                }
                if (self.additionalNumbers && [self.additionalNumbers count]) {
                    phoneNumber = [self.linkedMobileNumbers objectAtIndex:indexPath.row - 1];
                }
                
                BOOL isReachMeNumber = NO;
                UserProfileModel *model = [[Profile sharedUserProfile]profileData];
                for (NSDictionary *numberInfo in model.additionalVerifiedNumbers) {
                    if ([[numberInfo valueForKey:@"contact_id"] isEqualToString:[self.linkedMobileNumbers objectAtIndex:indexPath.row - 1]]) {
                        isReachMeNumber = [[numberInfo valueForKey:@"is_virtual"] boolValue];
                    }
                }
                
                CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:phoneNumber];
                if (!carrierDetails && voiceMailInfo.countryVoicemailSupport && !isReachMeNumber) {
                    [self selectCarrier:voiceMailInfo];
                    return;
                }
                
                //ActivateReachMe
                ActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ActivateReachMe"];
                activateReachMe.phoneNumber = phoneNumber;
                activateReachMe.isPrimaryNumber = NO;
                activateReachMe.voiceMailInfo = voiceMailInfo;
                [self.navigationController pushViewController:activateReachMe animated:YES];
            }else{
                if (indexPath.row == self.linkedMobileNumbers.count + 1) {
                    [self addLinkedNumber];
                }else if (indexPath.row == self.linkedMobileNumbers.count + 2){
                    //Navigate to buy reachme number page
                    [appDelegate.tabBarController setSelectedIndex:3];
                    [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[3]];
                }
            }
        }else{
            if (indexPath.row == self.linkedMobileNumbers.count + 1) {
                [self addLinkedNumber];
            }else if (indexPath.row == self.linkedMobileNumbers.count + 2){
                //Navigate to buy reachme number page
                [appDelegate.tabBarController setSelectedIndex:3];
                [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[3]];
            }
        }
        
    }else if (eGeneralSection == indexPath.section) {
        
        switch (indexPath.row) {
            case  eAccountInfoCell: {
               [self performSegueWithIdentifier:@"SettingsGeneralSegueID" sender:self];
                break;
            }
                
            case eReachMeCreditsCell:{
                [appDelegate.tabBarController setSelectedIndex:3];
                [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[3]];
                break;
            }
                
            case eVoiceToTextCell:{
                VoiceTotextTableViewController *voiceToTextTableViewController = [[UIStoryboard storyboardWithName:@"IVSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"Voice_To_Text"];
                [self.navigationController pushViewController:voiceToTextTableViewController animated:YES];
                break;
            }
                                
            case eVoiceMailGreetingsCell:{
                IVVoiceMailGreetingsViewController *voiceMailGreetingsViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"VoiceMailGreetingsView"];
                [self.navigationController pushViewController:voiceMailGreetingsViewController animated:YES];
                break;
            }
               
            case eEmailNotificationsCell:{
                IVVoiceMailEmailNotificationViewController *voiceMailEmailNotificationsViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"VoiceMailEmailNotificationsView"];
                [self.navigationController pushViewController:voiceMailEmailNotificationsViewController animated:YES];
                break;
            }
                
            case eRedeemCodeCell:{
                InviteCodeViewController *inviteCode = [[InviteCodeViewController alloc]initWithNibName:@"InviteCodeViewController" bundle:nil];
                inviteCode.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:inviteCode animated:YES];
                break;
            }
                
            case eCarrierSupportCell: {
                if([self.carrierSupportLink length]) {
                    NSURL *url = [NSURL URLWithString:self.carrierSupportLink];
                    [[UIApplication sharedApplication] openURL:url];
                }
                break;
            }
                
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 60.0;
    }else if (section == eChangePrimaryNumberSection){
        if(isExpanded)
            return 10.0;
        else
            return 0.0;
    }else{
        return 20.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSArray *headerTitle = @[@"",@"Primary Number is your USER ID to access ReachMe on all your devices.",@"",@"",@""];
    UIView *tableFooterView = [[UIView alloc]init];
    tableFooterView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 0.0, self.settingsListTableView.frame.size.width - 32.0, 60.0)];
    label.numberOfLines = 0;
    label.text = NSLocalizedString([headerTitle objectAtIndex:section], nil);
    label.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    
    if (section == 1) {
        [tableFooterView addSubview:label];
    }
    return tableFooterView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *headerTitle = @[@"",@"PRIMARY NUMBER",@"",@"",@""];
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 15.0, 250.0, 40.0)];
    label.text = NSLocalizedString([headerTitle objectAtIndex:section], nil);
    label.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    [tableHeaderView addSubview:label];
    return tableHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *titleString = @"";
    CGSize textSize = CGSizeZero;
    textSize = [Common sizeOfViewWithText:titleString withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    CGFloat sectionHeaderHeight =  textSize.height + kHeaderHeightOffset;
    if (section == ePrimaryNumberSection || section == eProfileInfo){
        return sectionHeaderHeight + 10.0;
    }else if (section == eChangePrimaryNumberSection){
        if(isExpanded)
            if(self.linkedMobileNumbers.count > 0)
                return kHeaderHeightOffset;
            else
                return 0;
        else
            return 0.0;
    }else{
        return kHeaderHeightOffset;
    }
    return sectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == eGeneralSection && eCarrierSupportCell == indexPath.row && self.hideCarrierSupportCell)
        return 0;
    
    else if(indexPath.section == eChangePrimaryNumberSection){
        if (!isExpanded) {
            return 0;
        }else{
            if(self.linkedMobileNumbers.count > 0){
                /*
                UserProfileModel *model = [[Profile sharedUserProfile]profileData];
                if (self.linkedMobileNumbers.count == 1) {
                    for (NSDictionary *numberInfo in model.additionalVerifiedNumbers) {
                        if ([[numberInfo valueForKey:@"contact_id"] isEqualToString:[self.linkedMobileNumbers objectAtIndex:0]]) {
                            if ([[numberInfo valueForKey:@"is_virtual"] boolValue]) {
                                return 0.0;
                            }
                        }
                    }
                }
                
                int reachMeNumbersCount = 0;
                for (int i = 0; i < self.linkedMobileNumbers.count; i++) {
                    for (NSDictionary *numberInfo in model.additionalVerifiedNumbers) {
                        if ([[numberInfo valueForKey:@"contact_id"] isEqualToString:[self.linkedMobileNumbers objectAtIndex:i]]) {
                            if ([[numberInfo valueForKey:@"is_virtual"] boolValue]) {
                                reachMeNumbersCount ++;
                            }
                        }
                    }
                }
                
                if (reachMeNumbersCount == self.linkedMobileNumbers.count) {
                    return 0.0;
                }
                */
                return 50.0;
                
            }else
                return 0;
        }
    }else if (indexPath.section == ePrimaryNumberSection) {
        return 56.0;
    }else if (indexPath.section == eProfileInfo) {
        return 86.0;
    }
    return 52.0;
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

- (void)selectCarrier:(VoiceMailInfo *)withVoiceMail
{
    if ([withVoiceMail.carrierCountryCode isEqualToString:@"091"]) {
        [[ConfigurationReader sharedConfgReaderObj] setOTPVerified:YES];
        [[ConfigurationReader sharedConfgReaderObj] setOTPVerifiedNumber:withVoiceMail.phoneNumber];
        IVCarrierCircleViewController *selectCircle = [[IVCarrierCircleViewController alloc]initWithNibName:@"IVCarrierCircleViewController" bundle:nil];
        [self.navigationController pushViewController:selectCircle animated:YES];
        return;
    }
    
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        if (!self.carrierSearchViewController) {
            self.carrierSearchViewController = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"IVCarrierSearchView"];
        }
        [[ConfigurationReader sharedConfgReaderObj] setOTPVerified:YES];
        [[ConfigurationReader sharedConfgReaderObj] setOTPVerifiedNumber:withVoiceMail.phoneNumber];
        if (![self.navigationController.topViewController isKindOfClass:[IVCarrierSearchViewController class]]) {
            self.carrierSearchViewController.voiceMailInfo = withVoiceMail;
            self.carrierSearchViewController.isEdit = NO;
            [self.navigationController pushViewController:self.carrierSearchViewController animated:YES];
            return;
        }
    }else{
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

- (void)helpAction
{
    
    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.primaryNumber];
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
    
    if (self.primaryNumberVoiceMailInfo.countryVoicemailSupport && !self.primaryNumberVoiceMailInfo.isVoiceMailEnabled && [[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
        self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", carrierInfo.networkName, carrierInfo.ussdInfo.actiAll];
    }else if (([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1)|| !self.primaryNumberVoiceMailInfo.countryVoicemailSupport || !carrierInfo.networkName.length) {
        self.helpText = kCarrierNotSupporttedHelpText;
    }else if (self.primaryNumberVoiceMailInfo.isVoiceMailEnabled) {
        if ([self primaryNumberIsActive] && carrierDetails) {
            self.helpText = @"";
        }else if (self.primaryNumberVoiceMailInfo.countryVoicemailSupport && [[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]){
            self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", carrierInfo.networkName, carrierInfo.ussdInfo.actiAll];
        }else if (([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1)|| !self.primaryNumberVoiceMailInfo.countryVoicemailSupport || !carrierInfo.networkName.length) {
            self.helpText = kCarrierNotSupporttedHelpText;
        }else{
            self.helpText = [NSString stringWithFormat:@"%@ %@",kCarrierNotSupporttedHelpText,carrierInfo.networkName];
        }
    }else{
        self.helpText = [NSString stringWithFormat:@"%@ %@",kCarrierNotSupporttedHelpText,carrierInfo.networkName];
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

- (IBAction)primaryNumberInfoIcon:(id)sender
{
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

#pragma mark - VerificationOTP Delegate Methods -

- (void)updateAdditionalNumbers {
    
    [self processLinkedNumbersFromProfileData];
    
}

- (void)addingNonVerifiedNumber:(NSString *)nonVerifiedNumber withcountrycode:(NSString *)countryCode {
    // NSLog(@"Additional non verified numbers =%@ and Country Code =%@", nonVerifiedNumber, countryCode);
    
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    
    //Check for the existance of the non verified numbers array - if not create one.
    if (!(self.additionalLinkedNonVerifiedNumbers && [self.additionalLinkedNonVerifiedNumbers count])) {
        self.additionalLinkedNonVerifiedNumbers  = [[NSMutableArray alloc]init];
    }
    //Add non verified number details into the list.
    //Create a dictionary with the "contryCode" and "contactNumber" and add it to the array.
    NSDictionary *nonVerifiedNumberInfo = @{
                                            kContactIdKey : nonVerifiedNumber,
                                            kCountryCodeKey : countryCode,
                                            };
    
    //Check - NonVerified Number already has the number.
    if (![self.additionalLinkedNonVerifiedNumbers containsObject:nonVerifiedNumberInfo]) {
        [self.additionalLinkedNonVerifiedNumbers addObject:nonVerifiedNumberInfo];
        currentUserProfileDetails.additionalVerifiedNumbers = self.additionalLinkedVerifiedNumbers;
        currentUserProfileDetails.additionalNonVerifiedNumbers = self.additionalLinkedNonVerifiedNumbers;
        [[Profile sharedUserProfile]writeProfileDataInFile];
        
    }
    
}

- (void)addLinkedNumber{
    
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    if ([self.verifiedSecondaryNumbers count] == 10) {
        [ScreenUtility showAlert:@"Limit Exceeded! Only 10 verified numbers can be linked to account"];
        return;
    }
    if ([self.verifiedSecondaryNumbers count] < 10) {
        
        LinkAdditionalMobileNumberViewController *linkAdditionalMobileNumberViewController = [[LinkAdditionalMobileNumberViewController alloc]init];
        
        linkAdditionalMobileNumberViewController.view.frame = CGRectMake(0, 0, 255,220);
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:linkAdditionalMobileNumberViewController];
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
        formSheet.cornerRadius = 8.0;
        formSheet.presentedFormSheetSize = CGSizeMake(255, 220);
        formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
            presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
        };
        
        formSheet.willDismissCompletionHandler = ^(UIViewController *presentedFSViewController){
            LinkAdditionalMobileNumberViewController *linkAdditionalMobileNumberViewController = (LinkAdditionalMobileNumberViewController *)presentedFSViewController;
            if(linkAdditionalMobileNumberViewController.isOkButtonClicked) {
                
                NSMutableDictionary *dataDictionary = [self dataForUpdatationOfContactToServer:eContactAddType withPrimaryPhoneNumberStatus:NO withContactNumber:linkAdditionalMobileNumberViewController.mobileNumberEntered withCountryCode:linkAdditionalMobileNumberViewController.countryCodeEntered];
                
                NSString *mobileNumberEnteredFormatted=[linkAdditionalMobileNumberViewController.mobileNumberEntered stringByReplacingOccurrencesOfString:@"+" withString:@""];
                BOOL isNumberBlocked = [[[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"BLOCKED_TILES"] containsObject:mobileNumberEnteredFormatted];
                if(isNumberBlocked)
                {
                    [ScreenUtility showAlert:@"The number is blocked,first unblock the number"];
                }
                else
                {
                    ManageUserContactAPI* api = [[ManageUserContactAPI alloc]initWithRequest:dataDictionary];
                    [self showProgressBar];
                    [api callNetworkRequest:dataDictionary withSuccess:^(ManageUserContactAPI *req, NSMutableDictionary *responseObject) {
                        if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
                            [self hideProgressBar];
                            EnLogd(@"Error blocking the user userlist %@ and api request %@",dataDictionary,api.request);
                        } else {
                            [self hideProgressBar];
                            VerificationOTPViewController *verify = (VerificationOTPViewController *)[[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"VerifyOTP"];
                            verify.userID = [linkAdditionalMobileNumberViewController.mobileNumberEntered stringByReplacingOccurrencesOfString:@"+" withString:@""];
                            verify.fromSignUp = false;
                            verify.verificationType = MANAGE_USER_CONTACT_TYPE;
                            verify.countryCode = linkAdditionalMobileNumberViewController.countryCodeEntered;
                            verify.delegate = self;
                            NSDate* now = [NSDate date];
                            NSNumber* currentTime = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
                            [appDelegate.confgReader setValidationTimer:currentTime];
                            [self.navigationController pushViewController:verify animated:YES];
                        }
                    } failure:^(ManageUserContactAPI *req, NSError *error) {
                        [self hideProgressBar];
                        if([error.domain isEqualToString:@"IVError"])
                        {
                            EnLogd(@"Error blocking the user: %@, Error",dataDictionary,[error description]);
                            NSInteger errorCode = error.code;
                            NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
                            if([errorMsg length]) {
                                [ScreenUtility showAlertMessage: errorMsg];
                            }
                        }
                        else
                        {
                            if(![Common isNetworkAvailable]) {
                                // [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];//TODO: ERROR
                                [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
                            }
                            else {
                                NSInteger errorCode = error.code;
                                NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
                                if([errorMsg length]) {
                                    [ScreenUtility showAlertMessage: errorMsg];
                                }
                                //TODO: Verify the UI Action after this.
                                //[self buttonAction:sender];
                            }
                        }
                    }];
                }
            }//else of if(isNumberBlocked)
        };
        
        [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
            
            
        }];
    }
    else {
        [ScreenUtility showAlert:@"Limit Exceeded! Only 10 verified numbers can be linked to account"];
        
    }
    
}

- (IBAction)addNewNumber:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.settingsListTableView];
    NSIndexPath *indexPath = [self.settingsListTableView indexPathForRowAtPoint:buttonPosition];
    
    if (eLinkedNumbersSection == indexPath.section) {
        if (indexPath.row == self.linkedMobileNumbers.count + 1) {
            [self addLinkedNumber];
        }else if (indexPath.row == self.linkedMobileNumbers.count + 2){
            //Navigate to buy reachme number page
            [appDelegate.tabBarController setSelectedIndex:3];
            [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[3]];
        }
    }
}

- (IBAction)verifyNumber:(id)sender{
    
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    //First verify - the number you are verify cross the limit of secondary numbers.
    if ([self.verifiedSecondaryNumbers count] == 10 ) {
        [ScreenUtility showAlert:@"Limit Exceeded! Only 10 verified numbers can be linked to account"];
        return;
    }
    
    if ([self.verifiedSecondaryNumbers count] < 10) {
        //get the phone number to be verified.
        NSString *numberToBeVerified = [self.linkedMobileNumbers objectAtIndex:[sender tag]];
        
        //Nonverified number info
        NSDictionary *nonVerifiedNumberInfo;
        
        for (NSDictionary *numberInfo in self.additionalLinkedNonVerifiedNumbers) {
            // NSLog(@"Number is =%@", [numberInfo valueForKey:kContactIdKey]);
            if ([[numberInfo valueForKey:kContactIdKey] isEqualToString:numberToBeVerified]) {
                nonVerifiedNumberInfo = numberInfo;
                break;
            }
        }
        
        //Verify the number.
        VerificationOTPViewController *verify = (VerificationOTPViewController *)[[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"VerifyOTP"];
        verify.userID = numberToBeVerified;
        verify.fromSignUp = false;
        verify.verificationType = MANAGE_USER_CONTACT_TYPE;
        verify.countryCode = [nonVerifiedNumberInfo valueForKey:kCountryCodeKey];
        verify.delegate = self;
        NSDate* now = [NSDate date];
        NSNumber* currentTime = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
        [appDelegate.confgReader setValidationTimer:currentTime];
        [self.navigationController pushViewController:verify animated:YES];
    }
    else {
        [ScreenUtility showAlert:@"Limit Exceeded! Only 10 verified numbers can be linked to account"];
    }
}

- (IBAction)editLinkedNumbers:(id)sender
{
    if (self.isEditingCell)
        self.isEditingCell = NO;
    else
        self.isEditingCell = YES;
    
    [self.settingsListTableView reloadData];
    
}

- (NSString *)primaryNumberInfo
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
    
    NumberInfo *numberDetails = [[Setting sharedSetting]customNumberInfoForPhoneNumber:self.primaryNumber];
    
    NSString* contactNumber = [Common getFormattedNumber:self.primaryNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    NSString *networkName = @"";
    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.primaryNumber];
    if (carrierInfo) {
        networkName = carrierInfo.networkName;
    }else{
        
        if (carrierDetails) {
            
            if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
                networkName = @"Not Listed";
            }else{
                networkName = @"";
            }
        }else{
            networkName = @"";
        }
    }
    
    if (!self.primaryNumberVoiceMailInfo || !self.primaryNumberVoiceMailInfo.countryVoicemailSupport) {
        networkName = @"Not supported";
    }
    
    NSString* titleName = @"";
    NSString *combinedString = @"";
    
    if (numberDetails.titleName.length > 0) {
        titleName = numberDetails.titleName;
        if (networkName.length)
            combinedString = [NSString stringWithFormat:@"%@ . %@",contactNumber,networkName];
        else
            combinedString = contactNumber;
        
    }else{
        titleName = contactNumber;
        combinedString = networkName;
    }
    
    NSString *primaryNumberText = [NSString stringWithFormat:@"%@",contactNumber];
    return primaryNumberText;
    
}

- (NSString *)linkedNumberInfo:(int )index
{
    NSString* contactNumber = [Common getFormattedNumber:[self.linkedMobileNumbers objectAtIndex:index] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    NSString *networkName = @"";
    
    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:[self.linkedMobileNumbers objectAtIndex:index]];
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:[self.linkedMobileNumbers objectAtIndex:index]];
    
    NumberInfo *numberDetails = [[Setting sharedSetting]customNumberInfoForPhoneNumber:[self.linkedMobileNumbers objectAtIndex:index]];
    
    VoiceMailInfo *linkedNumberVoiceMailInfo;
    self.currentSettingsModel = [Setting sharedSetting].data;
    if (self.currentSettingsModel) {
        if (self.currentSettingsModel.voiceMailInfo && [self.currentSettingsModel.voiceMailInfo count]) {
            for (VoiceMailInfo *voiceMailInfo in self.currentSettingsModel.voiceMailInfo) {
                if([voiceMailInfo.phoneNumber isEqualToString:[self.linkedMobileNumbers objectAtIndex:index]]) {
                    linkedNumberVoiceMailInfo = voiceMailInfo;
                }
            }
            
        }
    }
    
    if (carrierInfo) {
        networkName = carrierInfo.networkName;
    }else{
        
        if (carrierDetails) {
            
            if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
                networkName = @"Not Listed";
            }else{
                networkName = @"";
            }
        }else{
            networkName = @"";
        }
    }
    
    if (!linkedNumberVoiceMailInfo || !linkedNumberVoiceMailInfo.countryVoicemailSupport) {
        networkName = @"Not supported";
    }
    
    if(![[self.additionalLinkedVerifiedNumbers valueForKey:kContactIdKey] containsObject:[self.linkedMobileNumbers objectAtIndex:index]])
        networkName = @"";
    
    NSString* titleName = @"";
    NSString *combinedString = @"";
    
    if (numberDetails.titleName.length > 0) {
        titleName = numberDetails.titleName;
        if (networkName.length)
            combinedString = [NSString stringWithFormat:@"%@ . %@",contactNumber,networkName];
        else
            combinedString = contactNumber;
    }else{
        titleName = contactNumber;
        combinedString = networkName;
    }
    
    NSString *linkedNumberText = [NSString stringWithFormat:@"%@",contactNumber];
    return linkedNumberText;
    
}

- (void)callChangePrimaryNumber:(NSString *)withSelectedNumber
{
    
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    NSMutableDictionary *dataDictionary = [self dataForUpdatationOfContactToServer:eContactUpdateType withPrimaryPhoneNumberStatus:YES withContactNumber:withSelectedNumber withCountryCode:nil];
    ManageUserContactAPI* api = [[ManageUserContactAPI alloc]initWithRequest:dataDictionary];
    
    [api callNetworkRequest:api.request withSuccess:^(ManageUserContactAPI *req, NSMutableDictionary *responseObject) {
        
        if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
            [self hideProgressBar];
            EnLogd(@"Error blocking the user userlist %@ and api request %@",dataDictionary,api.request);
        } else {
            [self hideProgressBar];
            
            //Update the User Secure Key - As per the mail conversation on date 14th June.
            if ([responseObject valueForKey:API_USER_SECURE_KEY] && ![[responseObject valueForKey:API_USER_SECURE_KEY] isEqualToString:@""]) {
                [appDelegate.confgReader setUserSecureKey:[responseObject valueForKey:API_USER_SECURE_KEY]];
            }
            
            
            [appDelegate.engObj deleteAllChats:self.verifiedSecondaryNumbers];
            
            [[Engine sharedEngineObj]updateUserIdFrom:self.primaryNumber toNew:[@"+" stringByAppendingString:withSelectedNumber]];
            
            NSArray *serverResponse = responseObject[@"user_contacts"];
            
            if (serverResponse && [serverResponse count]) {
                if (self.additionalLinkedVerifiedNumbers && [self.additionalLinkedVerifiedNumbers count]) {
                    self.additionalLinkedVerifiedNumbers = nil;
                    
                }
                self.additionalLinkedVerifiedNumbers = [[NSMutableArray alloc]init];
                for (int i=0; i<[serverResponse count]; i++) {
                    NSDictionary *userContact = [serverResponse objectAtIndex:i];
                    
                    if([[userContact valueForKey:@"contact_type"] isEqualToString:@"p"]){
                        int isPrimary = [[userContact valueForKey:@"is_primary"] intValue];
                        
                        NSDictionary *verifiedNumber = @{ @"contact_id" : [userContact valueForKey:@"contact_id"],
                                                          @"country_code" : [userContact valueForKey:@"country_code"],
                                                          @"is_primary" : [userContact valueForKey:@"is_primary"],
                                                          @"is_virtual" : [userContact valueForKey:@"is_virtual"]
                                                          };
                        
                        if(isPrimary == 1){
                            [self.additionalLinkedVerifiedNumbers insertObject:verifiedNumber  atIndex:0];
                        }
                        else{
                            [self.additionalLinkedVerifiedNumbers addObject:verifiedNumber];
                        }
                        
                    }
                }
                
            }
            
            //Delete the carrier logo - once primary number has been changed.
            NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            NSString* localFileName = [NSString stringWithFormat:@"CarrierLogo_%@.png",loginId];
            [IVFileLocator deleteFileAtPath:[IVFileLocator getCarrierLogoPath:localFileName]];
            
            NSError *error = nil;
            NSFileManager *filemgr = [[NSFileManager alloc] init];
            NSString *oldNamePath = [IVFileLocator getMyProfilePicPath:[NSString stringWithFormat:@"name_greeting_%@.wav",loginId]];
            NSString *oldGreetingPath = [IVFileLocator getMyProfilePicPath:[NSString stringWithFormat:@"welcome_greeting_%@.wav",loginId]];
            
            [[ConfigurationReader sharedConfgReaderObj]setLoginId:withSelectedNumber];
            
            //TODO : Change the logic here!!!
            //Get the primary number information.
            self.primaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
            
            NSString *newNamePath = [IVFileLocator getMyProfilePicPath:[NSString stringWithFormat:@"name_greeting_%@.wav",self.primaryNumber]];
            
            NSString *newGreetingPath = [IVFileLocator getMyProfilePicPath:[NSString stringWithFormat:@"welcome_greeting_%@.wav",self.primaryNumber]];
            
            // Attempt the move
            if ([filemgr moveItemAtPath:oldNamePath toPath:newNamePath error:&error] != YES){
                EnLogd(@"Unable to move file: %@", [error localizedDescription]);
                //NSLog(@"Unable to move file: %@", [error localizedDescription]);
            }
            
            if ([filemgr moveItemAtPath:oldGreetingPath toPath:newGreetingPath error:&error] != YES){
                EnLogd(@"Unable to move file: %@", [error localizedDescription]);
                //NSLog(@"Unable to move file: %@", [error localizedDescription]);
            }
            
            [self.verifiedNumbers exchangeObjectAtIndex:0 withObjectAtIndex:[self.verifiedNumbers indexOfObject:withSelectedNumber]];
            
            currentUserProfileDetails.additionalVerifiedNumbers = self.additionalLinkedVerifiedNumbers;
            [[Profile sharedUserProfile]writeProfileDataInFile];
            [self loadLatestDataFromServer];
            [self processLinkedNumbersFromProfileData];
            
            [ScreenUtility showAlertMessage:@"Setting Saved"];
        }
        
    } failure:^(ManageUserContactAPI *req, NSError *error) {
        [self hideProgressBar];
        EnLogd(@"Error blocking the user: %@, Error",dataDictionary,[error description]);
        NSInteger errorCode = error.code;
        NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
        if([errorMsg length])
            [ScreenUtility showAlert: errorMsg];
    }];
    
}

- (IBAction)changePrimaryNumber:(id)sender
{
    
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    UIAlertController *changePrimaryNumber = [UIAlertController alertControllerWithTitle:@"Change Primary Number" message:@"Primary Number is your USER ID to access ReachMe on all your devices. " preferredStyle:UIAlertControllerStyleActionSheet];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"Change Primary Number"];
    [attrStr addAttribute:NSFontAttributeName
                  value:[UIFont boldSystemFontOfSize:16.0]
                  range:NSMakeRange(0, 21)];
    [changePrimaryNumber setValue:attrStr forKey:@"attributedTitle"];

    
    UIAlertAction *primaryNumber = [UIAlertAction actionWithTitle:[self primaryNumberInfo] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    [primaryNumber setValue:@true forKey:@"checked"];
    [changePrimaryNumber addAction:primaryNumber];
    BOOL isReachMeNumber = NO;
    
    for (int i = 0; i < self.linkedMobileNumbers.count; i++) {
        
        UserProfileModel *model = [[Profile sharedUserProfile]profileData];
        for (NSDictionary *numberInfo in model.additionalVerifiedNumbers) {
            if ([[numberInfo valueForKey:@"contact_id"] isEqualToString:[self.linkedMobileNumbers objectAtIndex:i]]) {
                isReachMeNumber = [[numberInfo valueForKey:@"is_virtual"] boolValue];
            }
        }
        
        if (!isReachMeNumber) {
            UIAlertAction *linkedNumber = [UIAlertAction actionWithTitle:[self linkedNumberInfo:i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self showProgressBar];
                [self callChangePrimaryNumber:[self.linkedMobileNumbers objectAtIndex:i]];
            }];
            [linkedNumber setValue:[UIColor blackColor] forKey:@"titleTextColor"];
            [changePrimaryNumber addAction:linkedNumber];
        }else{
            UIAlertAction *linkedNumber = [UIAlertAction actionWithTitle:[self linkedNumberInfo:i] style:UIAlertActionStyleDefault handler:nil];
            [linkedNumber setValue:[UIColor grayColor] forKey:@"titleTextColor"];
            linkedNumber.enabled = NO;
            [changePrimaryNumber addAction:linkedNumber];
        }
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    
    [changePrimaryNumber addAction:cancel];
    
    //[[UILabel appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setNumberOfLines:2];
    
    [self.navigationController presentViewController:changePrimaryNumber animated:YES completion:nil];
    
}

- (void)processLinkedNumbersFromProfileData {
    
    //Get the primary number information.
    self.primaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
    
    //TODO : reverify the logic of this method - we can optimise!!!
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    //Profile - additionalVerifiedNumbers and additionalNonVerifiedNumbers
    
    NSMutableArray *profileVerifiedNumbers = currentUserProfileDetails.additionalVerifiedNumbers;
    NSMutableArray *profileNonVerifiedNumbers = currentUserProfileDetails.additionalNonVerifiedNumbers;
    
    self.additionalLinkedVerifiedNumbers = profileVerifiedNumbers;
    
    self.additionalLinkedNonVerifiedNumbers = profileNonVerifiedNumbers;
    
    
    if (!(self.additionalLinkedVerifiedNumbers && [self.additionalLinkedVerifiedNumbers count])) {
        self.additionalLinkedVerifiedNumbers = [[NSMutableArray alloc]init];
        //Add primary number as verified numbers - in the first index
        NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
        NSNumber *countryIsdCode = [phoneUtil extractCountryCode:self.primaryNumber nationalNumber:nil];
        NSDictionary *verifiedNumber = @{kContactIdKey : self.primaryNumber,
                                         kCountryCodeKey : countryIsdCode,
                                         };
        [self.additionalLinkedVerifiedNumbers insertObject:verifiedNumber atIndex:0];
    }
    
    //Update profile data with verified and non verified numbers.
    currentUserProfileDetails.additionalVerifiedNumbers = _additionalLinkedVerifiedNumbers;
    currentUserProfileDetails.additionalNonVerifiedNumbers = _additionalLinkedNonVerifiedNumbers;
    [[Profile sharedUserProfile]writeProfileDataInFile];
    
    //Update the carrier list information in the settings
    [[Setting sharedSetting]fetchCarrierList];
    
    //Reconstruct the linkedNumbers Array
    if (self.linkedMobileNumbers && [self.linkedMobileNumbers count]) {
        [self.linkedMobileNumbers removeAllObjects];
        self.linkedMobileNumbers = nil;
    }
    
    self.linkedMobileNumbers = [[NSMutableArray alloc]init];
    [self.linkedMobileNumbers addObjectsFromArray:[self.additionalLinkedVerifiedNumbers valueForKeyPath:kContactIdKey]];
    //[self.linkedMobileNumbers addObjectsFromArray:[self.additionalLinkedNonVerifiedNumbers valueForKeyPath:kContactIdKey]];
    [self.linkedMobileNumbers removeObject:self.primaryNumber];
    
    if(self.linkedMobileNumbers.count)
    {
        self.linkedMobileNumbers = [NSMutableArray arrayWithArray:[self.linkedMobileNumbers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    
    self.verifiedNumbers = [[NSMutableArray alloc]initWithArray:[self.additionalLinkedVerifiedNumbers valueForKeyPath:kContactIdKey]];
    self.verifiedSecondaryNumbers =  [[NSMutableArray alloc]initWithArray:self.verifiedNumbers];
    [self.verifiedSecondaryNumbers removeObject:self.primaryNumber];
    
    [self.settingsListTableView reloadData];
    
    
}

#pragma mark - StoryBoard Segue Methods -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:kShowAboutInstaVoiceView]) {
        
        IVSettingsAboutInstaVoiceViewController *settingsAvoutInstaVoiceController = segue.destinationViewController;
        //Hides the botton tab bar.
        settingsAvoutInstaVoiceController.hidesBottomBarWhenPushed = YES;
        //if you need to pass data to the next controller do it here
    }
}

#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    [self.settingsListTableView reloadData];
}

#pragma mark - Long Press Getsure Recogniser Methods -
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.settingsListTableView];
    
    NSIndexPath *indexPath = [self.settingsListTableView indexPathForRowAtPoint:touchPoint];
    if (indexPath == nil) {
        KLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        KLog(@"long press on table view at section and row %ld %ld", indexPath.section, indexPath.row);
        if (eGeneralSection == indexPath.section) {
            UITableViewCell *cell = [self.settingsListTableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass: [IVInstaVoiceInfoTableViewCell class]]) {
                self.isLogEnabled = !self.isLogEnabled;
                [[ConfigurationReader sharedConfgReaderObj] setEnableLogFlag:self.isLogEnabled];
                if (self.isLogEnabled) {
                    logInit(@"KirusaLog.txt",true);
                    setLogLevel(DEBUG);
                    [Log enableLogs:YES];
                    [ScreenUtility showAlertMessage:@"Log Enabled"];
                }
                else {
                    logClose();
                    logInit(@"KirusaLog.txt",false);
                    [Log enableLogs:NO];
                    //NOV 23, 2016 setLogLevel(DEBUG);
                    [ScreenUtility showAlertMessage:@"Log Disabled"];
                    if ([MFMailComposeViewController canSendMail])
                        [self showEmail:gestureRecognizer];
                }
            }
            [self.settingsListTableView reloadData];
        }
    } else
        KLog(@"gestureRecognizer.state = %ld", gestureRecognizer.state);
    
}

#pragma mark - MFMailComposer Deleagte Methods -
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            KLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            KLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            KLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            KLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Private Methods -
- (void)fetchUserContacts {
    
    if( [Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        return;
    }
    NSMutableDictionary *req = [[NSMutableDictionary alloc]init];
    long ivUserId = [[ConfigurationReader sharedConfgReaderObj] getIVUserId];
    NSNumber *num = [NSNumber numberWithLong:ivUserId];
    
    [req setValue:[appDelegate.confgReader getDeviceUUID] forKey:API_DEVICE_ID];
    [req setValue:num forKey:IV_USER_ID];
    [req setValue:[appDelegate.confgReader getUserSecureKey] forKey:API_USER_SECURE_KEY];
    
    FetchUserContactAPI* api = [[FetchUserContactAPI alloc]initWithRequest:req];
    [api callNetworkRequest:req withSuccess:^(FetchUserContactAPI *req, NSMutableDictionary *responseObject) {
        if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
            EnLogd(@"Error fetching user contact, %@ and api request %@",req,api.request);
        } else {
            NSArray *userContacts = [responseObject valueForKey:@"user_contacts"];
            UserProfileModel *model = [[Profile sharedUserProfile]profileData];
            NSMutableArray *additionalNonVerifiedNumbers = [model.additionalNonVerifiedNumbers mutableCopy];
            NSMutableArray *additionalVerifiedNumbers = [model.additionalVerifiedNumbers mutableCopy];
            NSArray *verifiedNumbersInProfileData = [model.additionalVerifiedNumbers valueForKeyPath:@"contact_id"];
            
            [additionalVerifiedNumbers removeAllObjects];
            
            for (int i=0; i<[userContacts count]; i++) {
                NSDictionary *userContact = [userContacts objectAtIndex:i];
                if([[userContact valueForKey:@"contact_type"] isEqualToString:@"p"]){
                    NSMutableDictionary *verifiedNumberInfo = [[NSMutableDictionary alloc]init];
                    
                    int isPrimary = [[userContact valueForKey:@"is_primary"] intValue];
                    NSArray *filteredNonVerifiedNumbers = [additionalNonVerifiedNumbers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_id = %@",[userContact valueForKey:@"contact_id"]]];
                    [verifiedNumberInfo setValue:[userContact valueForKey:@"contact_id"] forKey:@"contact_id"];
                    [verifiedNumberInfo setValue:[userContact valueForKey:@"country_code"] forKey:@"country_code"];
                    [verifiedNumberInfo setValue:[userContact valueForKey:@"is_primary"]  forKey:@"is_primary"];
                    [verifiedNumberInfo setValue:[userContact valueForKey:@"is_virtual"]  forKey:@"is_virtual"];
                    if(isPrimary == 1){
                        //Its primary number - update the login id
                        //MAR 9, 2017
                        NSString* curPrimNum = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
                        NSString* newPrimNum = verifiedNumberInfo[@"contact_id"];
                        if(![curPrimNum isEqualToString:newPrimNum]) {
                            [[Engine sharedEngineObj]updateUserIdFrom:curPrimNum toNew:[@"+" stringByAppendingString:newPrimNum]];
                        }
                        //
                        [[ConfigurationReader sharedConfgReaderObj]setLoginId:verifiedNumberInfo[@"contact_id"]];
                        self.primaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
                        [additionalVerifiedNumbers insertObject:verifiedNumberInfo atIndex:0];
                    }
                    else{
                        [additionalVerifiedNumbers addObject:verifiedNumberInfo];
                    }
                    
                    if(([verifiedNumbersInProfileData containsObject:[userContact valueForKey:@"contact_id"]]) && ([filteredNonVerifiedNumbers count] != 0)){
                        [additionalNonVerifiedNumbers removeObjectsInArray:filteredNonVerifiedNumbers];
                    }
                }
            }
            
            model.additionalVerifiedNumbers = additionalVerifiedNumbers;
            model.additionalNonVerifiedNumbers = additionalNonVerifiedNumbers;
            [[Profile sharedUserProfile]writeProfileDataInFile];
            //Check we have secondary numbers - If so start fetching the list_carriers.
            if ([model.additionalVerifiedNumbers count]) {
                [[Setting sharedSetting]fetchCarrierList];
            }
            
            if ([model.additionalVerifiedNumbers count]) {
                NSArray *verifiedNumbers = [model.additionalVerifiedNumbers valueForKeyPath:@"contact_id"];
                NSMutableArray *additionalNumbersList = [[NSMutableArray alloc]init];
                for (NSString* number in verifiedNumbers) {
                    if (![number isEqualToString:self.primaryNumber])
                        [additionalNumbersList addObject: [NSString stringWithString:[@"+" stringByAppendingString:number]]];
                }
                self.additionalNumbers = additionalNumbersList;
            }
            
            self.additionalNumbersVoiceMailInfo = [[NSMutableArray alloc]init];
            //Check for the settings information - Settings response has the information about the user contacts.
            SettingModel *currentSettingsModel = [Setting sharedSetting].data;
            if (currentSettingsModel.voiceMailInfo && [currentSettingsModel.voiceMailInfo count]) {
                for (VoiceMailInfo *voiceMailInfo in currentSettingsModel.voiceMailInfo) {
                    if(![voiceMailInfo.phoneNumber isEqualToString:self.primaryNumber]) {
                        [self.additionalNumbersVoiceMailInfo addObject:voiceMailInfo];
                    }
                    else
                        self.primaryNumberVoiceMailInfo = voiceMailInfo;
                }
            }
        }
        
        [self processLinkedNumbersFromProfileData];
        
    }failure:^(FetchUserContactAPI *req, NSError *error) {
        EnLogd(@"*** Error fetching user contact: %@, %@",req,[error description]);
        KLog(@"*** Error fetching user contact: %@, %@",req,[error description]);
        
        /* SEP 28, 2016
        NSInteger errorCode = error.code;
        NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
        if([errorMsg length])
            [ScreenUtility showAlertMessage: errorMsg];
         */
    }];
}

- (void)showEmail:(UILongPressGestureRecognizer *)sender {
    // Email Subject
    NSString *emailTitle = NSLocalizedString(@"InstaVoice Log", nil);
    // Email Content
    NSString *messageBody = NSLocalizedString(@"The log stored inside this application is being uploaded for debugging purpose!", nil);
    // To address
    NSArray *toRecipents = [NSArray arrayWithObjects:@"iosdebug@instavoice.com",nil];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *txtFilePath = [documentsDirectory stringByAppendingPathComponent:@"KirusaLog.txt"];
    NSData *noteData = [NSData dataWithContentsOfFile:txtFilePath];
    if(noteData)
        [mc addAttachmentData:noteData mimeType:@"text/plain" fileName:@"KirusaLog.txt"];
    
    //- attach linphone1.log
    paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES);
    NSString *libDir = [paths objectAtIndex:0];
    NSString *linphoneFilePath = [libDir stringByAppendingPathComponent:@"Caches/linphone1.log"];
    NSData *logData = [NSData dataWithContentsOfFile:linphoneFilePath];
    if(logData)
        [mc addAttachmentData:logData mimeType:@"text/plain" fileName:@"linphone1.log"];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
    //NOV 23, 2016 - Delete the log file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL removed = [fileManager removeItemAtPath:txtFilePath error:NULL];
    if(removed) {
        KLog(@"log file has been removed");
    } else {
        KLog(@"Error deleting the log file");
    }
    //
}


- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *cellInfoDetailsArray;
    NSDictionary *cellInfoDetails;

    switch (indexPath.section) {
            
        case eProfileInfo: {
            if ([cell isKindOfClass:[IVSettingsProfileTableViewCell class]]) {
                IVSettingsProfileTableViewCell *settingsProfileCell = (IVSettingsProfileTableViewCell *)cell;
                UserProfileModel *profileData = [Profile sharedUserProfile].profileData;
            
                if(self.lpRegStatus) {
                    settingsProfileCell.registrationStatus.hidden = NO;
                    settingsProfileCell.registrationStatus.layer.borderWidth = 2.0;
                    settingsProfileCell.registrationStatus.layer.borderColor = [UIColor whiteColor].CGColor;
                    settingsProfileCell.registrationStatus.layer.cornerRadius = 7.0;
                    settingsProfileCell.registrationStatus.layer.masksToBounds = YES;
                } else {
                    settingsProfileCell.registrationStatus.hidden = YES;
                }
                
                if (profileData) {
                    NSString *pathToPicture = [IVFileLocator getMyProfilePicPath:profileData.localPicPath];
                    if (pathToPicture && pathToPicture.length > 0) {
                        settingsProfileCell.iconImageView.image = [UIImage imageWithContentsOfFile:pathToPicture];
                    }else{
                        [[Profile sharedUserProfile]getProfileDataFromServer];
                        settingsProfileCell.iconImageView.image = [UIImage imageNamed:@"default_profile_img_user"];
                    }
                }
                
                NSString *trimmedString = [profileData.screenName stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
                NSString *name;
                if(![trimmedString length])
                {
                    name = [Common setPlusPrefix:profileData.screenName];
                    name = [Common getFormattedNumber:name withCountryIsdCode:nil withGivenNumberisCannonical:YES];
                }else{
                    name = profileData.screenName;
                }
                settingsProfileCell.iconImageView.layer.cornerRadius = settingsProfileCell.iconImageView.frame.size.height/2;
                settingsProfileCell.iconImageView.layer.masksToBounds = YES;
                settingsProfileCell.titleLabel.text = name;
                settingsProfileCell.subTitleLabel.text = profileData.countryName;
                settingsProfileCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                settingsProfileCell.subTitleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
                
            }
            break;
        }
         
        case ePrimaryNumberSection: {
            if ([cell isKindOfClass:[IVSettingsNumbersTableViewCell class]]) {
                IVSettingsNumbersTableViewCell *primaryNumberCell = (IVSettingsNumbersTableViewCell *)cell;
                
                CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
                
                NumberInfo *numberDetails = [[Setting sharedSetting]customNumberInfoForPhoneNumber:self.primaryNumber];
                
                NSString* contactNumber = [Common getFormattedNumber:self.primaryNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
                NSString *networkName = @"";
                IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.primaryNumber];
                if (carrierInfo) {
                    networkName = carrierInfo.networkName;
                }else{
                    
                    if (carrierDetails) {
                        
                        if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
                            networkName = @"Not Listed";
                        }else{
                            networkName = @"";
                        }
                    }else{
                        networkName = @"";
                    }
                }
                
                if (!self.primaryNumberVoiceMailInfo || !self.primaryNumberVoiceMailInfo.countryVoicemailSupport) {
                    networkName = @"Not supported";
                }
                
                NSString* titleName = @"";
                NSString *combinedString = @"";
                
                if (numberDetails.titleName.length > 0) {
                    titleName = numberDetails.titleName;
                    if (networkName.length)
                        combinedString = [NSString stringWithFormat:@"%@ . %@",contactNumber,networkName];
                    else
                        combinedString = contactNumber;
                    
                }else{
                    titleName = contactNumber;
                    combinedString = networkName;
                }
                
                //Flag Name
                NSString *flagName = [self getFlagFromCountryName:[self getCountryCode:self.primaryNumber]];
                
                primaryNumberCell.titleLabel.text = titleName;
                primaryNumberCell.numberInfoLabel.text = combinedString;
                primaryNumberCell.verifyNumberButton.hidden = YES;
                                
                primaryNumberCell.iconImageView.image = [UIImage imageNamed:flagName];
                primaryNumberCell.iconImageView.layer.cornerRadius = primaryNumberCell.iconImageView.frame.size.height/2;
                
                primaryNumberCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                primaryNumberCell.numberInfoLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
                
            }
            break;
        }
        case eChangePrimaryNumberSection: {
            if ([cell isKindOfClass:[IVSettingsNumbersTableViewCell class]]) {
                IVSettingsNumbersTableViewCell *changePrimaryNumberCell = (IVSettingsNumbersTableViewCell *)cell;
                changePrimaryNumberCell.changePrimaryNumber.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                [changePrimaryNumberCell.changePrimaryNumber addTarget:self action:@selector(changePrimaryNumber:) forControlEvents:UIControlEventTouchUpInside];
            }
            break;
        }
        case eLinkedNumbersSection: {
            if ([cell isKindOfClass:[IVSettingsNumbersTableViewCell class]]) {
                IVSettingsNumbersTableViewCell *additionaNumbersCell = (IVSettingsNumbersTableViewCell *)cell;
                
                if(isExpanded)
                    additionaNumbersCell.expandColapseImage.image = [UIImage imageNamed:@"settings_up_arrow"];
                else
                    additionaNumbersCell.expandColapseImage.image = [UIImage imageNamed:@"down_arrow_settings"];
                
                additionaNumbersCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                additionaNumbersCell.verifyNumberButton.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                additionaNumbersCell.numberInfoLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
                additionaNumbersCell.linkedNumberCount.text = [NSString stringWithFormat:@"%ld",self.linkedMobileNumbers.count];
                additionaNumbersCell.linkedNumberLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                additionaNumbersCell.linkedNumberCount.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                additionaNumbersCell.addNumberButton.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                [additionaNumbersCell.addNumberButton addTarget:self action:@selector(addNewNumber:) forControlEvents:UIControlEventTouchUpInside];
                
                if (indexPath.row == self.linkedMobileNumbers.count + 1) {
                    [additionaNumbersCell.addNumberButton setTitle:@"Link New" forState:UIControlStateNormal];
                }else if (indexPath.row == self.linkedMobileNumbers.count + 2){
                    [additionaNumbersCell.addNumberButton setTitle:@"Buy ReachMe Number" forState:UIControlStateNormal];
                }
                
                NSArray *iconArray = @[@"mobile_red_icon",@"iphone_icon",@"mobile_purple_icon",@"mobile_red_icon",@"iphone_icon",@"mobile_purple_icon",@"mobile_red_icon",@"iphone_icon",@"mobile_purple_icon",@"mobile_red_icon",@"iphone_icon",@"mobile_purple_icon"];
                self.customImageName = iconArray;
                
                if (indexPath.row == self.linkedMobileNumbers.count + 1 || indexPath.row == self.linkedMobileNumbers.count + 2) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }else if (indexPath.row <= self.linkedMobileNumbers.count && indexPath.row > 0){
                    NSString* contactNumber = [Common getFormattedNumber:[self.linkedMobileNumbers objectAtIndex:indexPath.row - 1] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
                    NSString *networkName = @"";
                    
                    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:[self.linkedMobileNumbers objectAtIndex:indexPath.row - 1]];
                    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:[self.linkedMobileNumbers objectAtIndex:indexPath.row - 1]];
                    
                    NumberInfo *numberDetails = [[Setting sharedSetting]customNumberInfoForPhoneNumber:[self.linkedMobileNumbers objectAtIndex:indexPath.row - 1]];
                    
                    VoiceMailInfo *linkedNumberVoiceMailInfo;
                    self.currentSettingsModel = [Setting sharedSetting].data;
                    if (self.currentSettingsModel) {
                        if (self.currentSettingsModel.voiceMailInfo && [self.currentSettingsModel.voiceMailInfo count]) {
                            for (VoiceMailInfo *voiceMailInfo in self.currentSettingsModel.voiceMailInfo) {
                                if([voiceMailInfo.phoneNumber isEqualToString:[self.linkedMobileNumbers objectAtIndex:indexPath.row - 1]]) {
                                    linkedNumberVoiceMailInfo = voiceMailInfo;
                                }
                            }
                            
                        }
                    }
                    
                    if (carrierInfo) {
                        networkName = carrierInfo.networkName;
                    }else{
                        
                        if (carrierDetails) {
                            
                            if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
                                networkName = @"Not Listed";
                            }else{
                                networkName = @"";
                            }
                        }else{
                            networkName = @"";
                        }
                    }
                    
                    if (!linkedNumberVoiceMailInfo || !linkedNumberVoiceMailInfo.countryVoicemailSupport) {
                        networkName = @"Not supported";
                    }
                    
                    if(![[self.additionalLinkedVerifiedNumbers valueForKey:kContactIdKey] containsObject:[self.linkedMobileNumbers objectAtIndex:indexPath.row - 1]])
                        networkName = @"";
                    
                    NSString* titleName = @"";
                    NSString *combinedString = @"";
                    
                    if (numberDetails.titleName.length > 0) {
                        titleName = numberDetails.titleName;
                        if (networkName.length)
                            combinedString = [NSString stringWithFormat:@"%@ . %@",contactNumber,networkName];
                        else
                            combinedString = contactNumber;
                    }else{
                        titleName = contactNumber;
                        combinedString = networkName;
                    }
                    
                    BOOL isReachMeNumber = NO;
                    UserProfileModel *model = [[Profile sharedUserProfile]profileData];
                    for (NSDictionary *numberInfo in model.additionalVerifiedNumbers) {
                        if ([[numberInfo valueForKey:@"contact_id"] isEqualToString:[self.linkedMobileNumbers objectAtIndex:indexPath.row - 1]]) {
                            isReachMeNumber = [[numberInfo valueForKey:@"is_virtual"] boolValue];
                        }
                    }
                    
                    if (isReachMeNumber) {
                        combinedString = @"ReachMe Number";
                    }
                    
                    //Flag Name
                    NSString *flagName = [self getFlagFromCountryName:[self getCountryCode:[self.linkedMobileNumbers objectAtIndex:indexPath.row - 1]]];
                    
                    additionaNumbersCell.titleLabel.text = titleName;
                    additionaNumbersCell.numberInfoLabel.text = combinedString;
                    additionaNumbersCell.verifyNumberButton.hidden = [[self.additionalLinkedVerifiedNumbers valueForKey:kContactIdKey] containsObject:[self.linkedMobileNumbers objectAtIndex:indexPath.row - 1]]? YES: NO;
                    additionaNumbersCell.infoIconButton.hidden = YES;
                    additionaNumbersCell.iconImageView.image = [UIImage imageNamed:flagName];
                    additionaNumbersCell.iconImageView.layer.cornerRadius = additionaNumbersCell.iconImageView.frame.size.height/2;
                    additionaNumbersCell.iconImageView.layer.masksToBounds = YES;
                    
                }
            }
            break;
        }
            
        case eGeneralSection: {
            if ([cell isKindOfClass:[IVSettingsGeneralTableViewCell class]] || [cell isKindOfClass:[IVSettingsGeneralWithoutSubTitleTableViewCell class]] || [cell isKindOfClass:[IVInstaVoiceInfoTableViewCell class]]) {
                
                if (indexPath.row == 7) {
                    
                    if ([cell isKindOfClass:[IVInstaVoiceInfoTableViewCell class]]) {
                        IVInstaVoiceInfoTableViewCell *instaVoiceInfoCell = (IVInstaVoiceInfoTableViewCell *)cell;
                        cellInfoDetailsArray = self.instaVoiceInfoList;
                        cellInfoDetails = [cellInfoDetailsArray objectAtIndex:0];
                        instaVoiceInfoCell.versionNumberLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                        if(cellInfoDetails[kCellSubTitleKey]) {
                            NSString *cellInfoDetailsText = cellInfoDetails[kCellSubTitleKey];
                            cellInfoDetailsText = [NSString stringWithFormat:@"ReachMe %@%@",cellInfoDetailsText,self.isLogEnabled?@" D":@""];;
                            instaVoiceInfoCell.versionNumberLabel.text = NSLocalizedString(cellInfoDetailsText, nil);
                        }
                        instaVoiceInfoCell.accessoryType = UITableViewCellAccessoryNone;
                        NSUserDefaults *appStoreVersion = [NSUserDefaults standardUserDefaults];
                        NSString *currentVersion = [NSString stringWithFormat:@"%@.%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];

                        if (![[appStoreVersion valueForKey:@"APPSTORE_VERSION"] isEqualToString:currentVersion]){
                            instaVoiceInfoCell.updateButton.hidden = NO;
                            [instaVoiceInfoCell.updateButton setTitleColor:[UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f] forState:UIControlStateNormal];
                        }else{
                            instaVoiceInfoCell.updateButton.hidden = YES;
                            instaVoiceInfoCell.accessoryType = UITableViewCellAccessoryNone;
                        }
                        
                    }
                    
                }else if (indexPath.row > 5) {
                    IVSettingsGeneralWithoutSubTitleTableViewCell *settingsGeneralCell = (IVSettingsGeneralWithoutSubTitleTableViewCell *)cell;
                    cellInfoDetailsArray = self.generalCellInfoList;
                    cellInfoDetails = [cellInfoDetailsArray objectAtIndex:indexPath.row];
                    
                    settingsGeneralCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                    
                    if (cellInfoDetails[kCellImageKey]) {
                        UIImage *cellImage = [UIImage imageNamed:cellInfoDetails[kCellImageKey]];
                        settingsGeneralCell.iconImageView.image = cellImage;
                        
                    }
                    
                    NSString* cellTitle = cellInfoDetails[kCellTitleKey];
                    if(eCarrierSupportCell == indexPath.row) {
                        
                        if(self.carrierSupportNetworkName.length) {
                            settingsGeneralCell.titleLabel.text = [self.carrierSupportNetworkName stringByAppendingFormat:@" %@",@"Carrier Support"];
                            if([self.carrierSupportLogo length]) {
                                UIImage *cellImage = [UIImage imageNamed:self.carrierSupportLogo];
                                settingsGeneralCell.iconImageView.image = cellImage;
                                settingsGeneralCell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
                                settingsGeneralCell.iconImageView.clipsToBounds = YES;
                            }
                        } else {
                            settingsGeneralCell.titleLabel.text = cellTitle;
                            UIImage *cellImage = [UIImage imageNamed:cellInfoDetails[kCellImageKey]];
                            settingsGeneralCell.iconImageView.image = cellImage;
                        }
                    }
                    else if([cellTitle length]) {
                        settingsGeneralCell.titleLabel.text = NSLocalizedString(cellInfoDetails[kCellTitleKey], nil);
                    }
                }else{
                    IVSettingsGeneralTableViewCell *settingsGeneralCell = (IVSettingsGeneralTableViewCell *)cell;
                    cellInfoDetailsArray = self.generalCellInfoList;
                    cellInfoDetails = [cellInfoDetailsArray objectAtIndex:indexPath.row];
                    
                    settingsGeneralCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                    settingsGeneralCell.subTitleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
                    
                    if (cellInfoDetails[kCellImageKey]) {
                        UIImage *cellImage = [UIImage imageNamed:cellInfoDetails[kCellImageKey]];
                        settingsGeneralCell.iconImageView.image = cellImage;
                        
                    }
                    
                    NSString* cellTitle = cellInfoDetails[kCellTitleKey];
                    if([cellTitle length]) {
                        settingsGeneralCell.titleLabel.text = NSLocalizedString(cellInfoDetails[kCellTitleKey], nil);
                    }
                    settingsGeneralCell.titleLabel.text = NSLocalizedString(cellInfoDetails[kCellTitleKey], nil);
                    if(cellInfoDetails[kCellSubTitleKey]) {
                        settingsGeneralCell.subTitleLabel.text = NSLocalizedString(cellInfoDetails[kCellSubTitleKey], nil);
                    }
                }
            }
            break;
        }
        case eInstaVoiceInfoSection: {
            
            if ([cell isKindOfClass:[IVInstaVoiceInfoTableViewCell class]]) {
                IVInstaVoiceInfoTableViewCell *instaVoiceInfoCell = (IVInstaVoiceInfoTableViewCell *)cell;
                cellInfoDetailsArray = self.instaVoiceInfoList;
                cellInfoDetails = [cellInfoDetailsArray objectAtIndex:indexPath.row];
                /*
                instaVoiceInfoCell.titleLabel.font =  instaVoiceInfoCell.versionNumberLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                
                if(cellInfoDetails[kCellTitleKey])
                    instaVoiceInfoCell.titleLabel.text = NSLocalizedString(cellInfoDetails[kCellTitleKey], nil) ;
                 */
                
                instaVoiceInfoCell.versionNumberLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                if(cellInfoDetails[kCellSubTitleKey]) {
                    NSString *cellInfoDetailsText = cellInfoDetails[kCellSubTitleKey];
                    cellInfoDetailsText = [NSString stringWithFormat:@"InstaVoice %@%@",cellInfoDetailsText,self.isLogEnabled?@" D":@""];;
                    instaVoiceInfoCell.versionNumberLabel.text = NSLocalizedString(cellInfoDetailsText, nil);
                }
                
                NSString* oldVersion = [[ConfigurationReader sharedConfgReaderObj]getClientAppBuildNumber];
                NSString* currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                if (![oldVersion isEqualToString:currentVersion]){
                    instaVoiceInfoCell.updateButton.hidden = NO;
                }else{
                    instaVoiceInfoCell.accessoryType = UITableViewCellAccessoryNone;
                }
                
            }
            break;
        }
            
        default:
            break;
    }
    
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2){
        if(indexPath.row < self.linkedMobileNumbers.count)
            if (self.isEditingCell)
                return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2){
        
        if (self.linkedMobileNumbers.count > 3) {
            if(indexPath.row < 3)
                if (self.isEditingCell)
                    return YES;
        }else{
            if(indexPath.row < self.linkedMobileNumbers.count)
                if (self.isEditingCell)
                    return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
            NSString *title = [NSString stringWithFormat:@"Confirm Delete\n %@",[Common getFormattedNumber:[@"+" stringByAppendingString:[self.linkedMobileNumbers objectAtIndex:indexPath.row]] withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
            
            
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
                                     [self deleteNumber:[self.linkedMobileNumbers objectAtIndex:indexPath.row]];
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
}

- (void)deleteNumber:(NSString *)phoneNumber
{
    [self showProgressBar];
    NSMutableArray *verifiedNumberDetails;
    NSMutableArray *verifiedNumbers;
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    
    verifiedNumberDetails = currentUserProfileDetails.additionalVerifiedNumbers;
    self.additionalLinkedNonVerifiedNumbers = currentUserProfileDetails.additionalNonVerifiedNumbers;
    verifiedNumbers = [[NSMutableArray alloc]initWithArray:[verifiedNumberDetails valueForKeyPath:kContactIdKey]];
    
    BOOL __block isNumberDeleted = NO;
    //We are very sure that this button belongs to the LinkedNumber Row.
    //Check the number is verified or non verified. If number is non verified remove from the - nonverified details and update the profile data.
    
    NSString *phoneNumberToBeDeleted = phoneNumber;//TODO Check bounds
    NSArray *nonVerifiedNumberList = [self.additionalLinkedNonVerifiedNumbers valueForKeyPath:kContactIdKey];
    
    if ([nonVerifiedNumberList containsObject:phoneNumberToBeDeleted]) {
        //Check nonVerified List contains phoneNumberToBeDeleted.
        for (phoneNumberToBeDeleted in nonVerifiedNumberList) {
            //Yes, Its belonging to non verified number - remove from the local list and update the profile data - nonverified number list.
            for (NSDictionary *numberInfo in self.additionalLinkedNonVerifiedNumbers) {
                if ([[numberInfo valueForKey:kContactIdKey] isEqualToString:phoneNumberToBeDeleted]) {
                    [self.additionalLinkedNonVerifiedNumbers removeObject:numberInfo];
                    isNumberDeleted = YES;
                    break;
                }
            }
            if (isNumberDeleted) {
                [self hideProgressBar];
                break;
            }
        }
    }
    else {
        //Number should be verified number.
        NSMutableDictionary *dataDictionary = [self dataForUpdatationOfContactToServer:eContactDeleteType withPrimaryPhoneNumberStatus:NO withContactNumber:phoneNumberToBeDeleted withCountryCode:nil];
        
        ManageUserContactAPI* api = [[ManageUserContactAPI alloc]initWithRequest:dataDictionary];
        [self showProgressBar];
        
        [api callNetworkRequest:api.request withSuccess:^(ManageUserContactAPI *req, NSMutableDictionary *responseObject) {
            
            if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
                [self hideProgressBar];
                EnLogd(@"Error calling manage_user_contact %@ and api request %@",dataDictionary,api.request);
            } else {
                [self hideProgressBar];
                if ([self.verifiedNumbers containsObject:phoneNumberToBeDeleted]) {
                    [self.verifiedNumbers removeObject:phoneNumberToBeDeleted];
                    
                    for (NSDictionary *numberInfo in verifiedNumberDetails) {
                        if ([[numberInfo valueForKey:kContactIdKey] isEqualToString:phoneNumberToBeDeleted]) {
                            [verifiedNumberDetails removeObject:numberInfo];
                            isNumberDeleted = YES;
                            break;
                        }
                    }
                }
                [ScreenUtility showAlert:@"Number has been deleted successfully"];
                currentUserProfileDetails.additionalVerifiedNumbers = verifiedNumberDetails;
                currentUserProfileDetails.additionalNonVerifiedNumbers = self.additionalLinkedNonVerifiedNumbers;
                [[Profile sharedUserProfile]writeProfileDataInFile];
                
                //Remove Carrier information of the secondary number if any in settings.
                [[Setting sharedSetting]updateCarrierSettingsInfoForDeletedSecondaryNumber:phoneNumberToBeDeleted];
                
                //Remove Number information of the secondary number if any in settings.
                [[Setting sharedSetting]updateNumberSettingsInfoForDeletedSecondaryNumber:phoneNumberToBeDeleted];
                
                isNumberDeleted = YES;
                //Update the linked Numbers array.
                [self processLinkedNumbersFromProfileData];
            }
            
        } failure:^(ManageUserContactAPI *req, NSError *error) {
            
            isNumberDeleted = NO;
            [self hideProgressBar];
            EnLogd(@"Error calling manage_user_contact api: %@, Error",dataDictionary,[error description]);
            NSInteger errorCode = error.code;
            NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
            if(error.code == kPrimaryNumberCanNotDeleteErrorCode){
                [self fetchUserContacts];
                errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
            }
            if([errorMsg length]) {
                //OCT 13, 2016 [ScreenUtility showAlertMessage: errorMsg];
                [ScreenUtility showAlert: errorMsg];
            }
            
        }];
    }
    
    if (isNumberDeleted) {
        //Update the linked Numbers array.
        [self processLinkedNumbersFromProfileData];
    }
    
}

- (IVSettingsGeneralTableViewCell*)settingsGeneralTableViewCell {
    if (!_settingsGeneralTableViewCell)
        _settingsGeneralTableViewCell = [self.settingsListTableView dequeueReusableCellWithIdentifier:kGeneralCellIdentifier];
    
    return _settingsGeneralTableViewCell;
}

- (IVInstaVoiceInfoTableViewCell*)settingsInstaVoiceInfoTableViewCell {
    if (!_settingsInstaVoiceInfoTableViewCell)
        _settingsInstaVoiceInfoTableViewCell = [self.settingsListTableView dequeueReusableCellWithIdentifier:kInstaVoiceInfoCellIdentifier];
    
    return _settingsInstaVoiceInfoTableViewCell;
}

/**
 * Method responsible to set up the datasource for the static details of a cell like image, title and subtitle for cell
 * @param inSection: Indicates the tableview section.
 * @return returns the datasource for a section.
 */
- (NSArray *)createDataSourceForCellsInSection:(NSUInteger)inSection {
    
    NSMutableArray *cellInfoDetails = [[NSMutableArray alloc]init];
    switch (inSection) {
        case eProfileInfo: {
            NSArray *imageInfoArray = @[@""];
            NSArray *titleInfoArray = @[@"Name"];
            for (NSUInteger i=0; i< kNumberOfCellsInProfileSection; i++) {
                NSDictionary *cellInfo = @{kCellImageKey:[imageInfoArray objectAtIndex:i], kCellTitleKey:[titleInfoArray objectAtIndex:i]};
                [cellInfoDetails addObject:cellInfo];
            }
            break;
        }
        case eGeneralSection: {
            
            float creditsConversion = [appDelegate.confgReader getVsmsLimit] / 100.0f;
            NSString *totalCreditsString = [NSString stringWithFormat:@"Available balance - $%.2lf",creditsConversion];
            
            /*if (creditsConversion < 0.0) {
                NSString *negativeValue = [NSString stringWithFormat:@"$%.2lf", creditsConversion];
                negativeValue = [negativeValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
                totalCreditsString = [NSString stringWithFormat:@"Available balance - -%@",negativeValue];
            }*/
            
            NSArray *imageInfoArray = @[@"rm_credits",@"voicetotext", @"settings_voicemail_greetings",@"settings_email_notifications",@"redeem",@"settings_account_icn", @"carrier_support_icn", @"settings_instavoice_icn"];
            
            NSArray *titleInfoArray = @[@"ReachMe Money",@"Voice To Text",@"Voicemail Greetings",@"Email Notifications",@"Redeem Code", @"General", @"Carrier Support",@"InstaVoice version"];
            
            NSArray *subTitleInfoArray = @[totalCreditsString,@"VoiceMail, Voice message transcription",@"Welcome messages", @"Receive Voicemail & Missed Call Alerts", @"Invite codes, Promo codes", @"Password & Ringtone", @"", @""];
            
            //NSArray *tintColorArray = @[[IVColors redColor], [IVColors darkGreyColor], [IVColors greenColor], [IVColors pinkColor], [IVColors tealColor], [IVColors lightGreyColor]];
            
            for (NSUInteger i=0; i< kNumberOfCellsInGeneralSection; i++) {
                NSDictionary *cellInfo = @{kCellImageKey:[imageInfoArray objectAtIndex:i], kCellTitleKey:[titleInfoArray objectAtIndex:i], kCellSubTitleKey:[subTitleInfoArray objectAtIndex:i]};
                [cellInfoDetails addObject:cellInfo];
            }
            break;
        }
        case eInstaVoiceInfoSection: {
            NSArray *titleInfoArray = @[@"InstaVoice version"];
            NSString *bundleIdentifier = [NSString stringWithFormat:@"%@ (%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
            NSArray *subTitleInfoArray = @[bundleIdentifier];
            for (NSUInteger i=0; i<kNumbetOfCellsInInstaVoiceInfoSection; i++) {
                NSDictionary *cellInfo = @{kCellTitleKey:[titleInfoArray objectAtIndex:i], kCellSubTitleKey:[subTitleInfoArray objectAtIndex:i]};
                [cellInfoDetails addObject:cellInfo];
            }
            break;
        }
        default:
            break;
    }
    return cellInfoDetails;
}

- (void)redirectVoiceMailAndSettingsScreens {
    
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    if (nil != currentUserProfileDetails) {
        if ([currentUserProfileDetails.additionalVerifiedNumbers count]) {
            NSArray *verifiedNumbers = [currentUserProfileDetails.additionalVerifiedNumbers valueForKeyPath:@"contact_id"];
            NSMutableArray *additionalNumbersList = [[NSMutableArray alloc]init];
            for (NSString* number in verifiedNumbers) {
                if (![number isEqualToString:self.primaryNumber])
                    // [additionalNumbersList addObject: [NSString stringWithString:[@"+" stringByAppendingString:number]]];
                    [additionalNumbersList addObject: number];
                
            }
            self.additionalNumbers = additionalNumbersList;
        }
    }
    
    self.additionalNumbersVoiceMailInfo = [[NSMutableArray alloc]init];
    //Check for the settings information - Settings response has the information about the user contacts.
    SettingModel *currentSettingsModel = [Setting sharedSetting].data;
    if (currentSettingsModel.voiceMailInfo && [currentSettingsModel.voiceMailInfo count]) {
        for (VoiceMailInfo *voiceMailInfo in currentSettingsModel.voiceMailInfo) {
            if(![voiceMailInfo.phoneNumber isEqualToString:self.primaryNumber]) {
                [self.additionalNumbersVoiceMailInfo addObject:voiceMailInfo];
            }
            else
                self.primaryNumberVoiceMailInfo = voiceMailInfo;
        }
    }
    
    if (self.additionalNumbers && [self.additionalNumbers count]) {
        self.additionalNumbers = [NSMutableArray arrayWithArray:[self.additionalNumbers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    
    if ((self.additionalNumbers && [self.additionalNumbers count]) && (self.additionalNumbersVoiceMailInfo && [self.additionalNumbersVoiceMailInfo count])) {
        //We have additional numbers - so redirect it to listing page.
        if (![self.navigationController.topViewController isKindOfClass:[IVVoiceMailListViewController class]]) {
            UIStoryboard *voiceMailSettingsStorybaord = [UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]];
            IVVoiceMailListViewController *voiceListViewController = [voiceMailSettingsStorybaord instantiateViewControllerWithIdentifier:@"IVVoiceMailListView"];
            //We have additional numbers - we need to show the voicemail list viewcontroller.
            voiceListViewController.primaryNumberVoiceMailInfo = self.primaryNumberVoiceMailInfo;
            voiceListViewController.primaryNumber = self.primaryNumber;
            //NOV 24, 2016 voiceListViewController.additionalNumberVoiceMailInfo = self.additionalNumbersVoiceMailInfo;
            voiceListViewController.additionalNumbersVoiceMailInfo = self.additionalNumbersVoiceMailInfo;
            voiceListViewController.additionalNumbers = self.additionalNumbers;
            voiceListViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:voiceListViewController animated:NO];
        }
    }
}

- (BOOL)primaryNumberIsActive
{
    CarrierInfo *currentSelectedNumberCarrierInfo = [[Setting sharedSetting] customCarrierInfoForPhoneNumber:self.primaryNumber];
    //check do we have carrier list for the country.
    NSArray *carrierList = [[Setting sharedSetting]carrierListForCountry:self.primaryNumberVoiceMailInfo.carrierCountryCode];
    if (currentSelectedNumberCarrierInfo) {
        if ([currentSelectedNumberCarrierInfo.networkId isEqualToString:@"-1"] && [currentSelectedNumberCarrierInfo.countryCode isEqualToString:@"-1" ] && [currentSelectedNumberCarrierInfo.vSMSId integerValue] == -1) {
            //We do not have USSD Info - Redirect screen to Carrier Selection page.
            return NO;
        }
        
        if (self.primaryNumberVoiceMailInfo) {
            //We have voicemail info
            //Check for voicemail enabled ore not.
            if (self.primaryNumberVoiceMailInfo.isVoiceMailEnabled && self.primaryNumberVoiceMailInfo.countryVoicemailSupport) {
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
                    //Fetch carrier list for country.
                    [[Setting sharedSetting]fetchListOfCarriersForCountry:self.primaryNumberVoiceMailInfo.carrierCountryCode];
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
        if (self.primaryNumberVoiceMailInfo) {
            //Yes, we have voicemail info
            if (self.primaryNumberVoiceMailInfo.isVoiceMailEnabled) {
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
                    
                    //Fetch carrier list for country.
                    [[Setting sharedSetting]fetchListOfCarriersForCountry:self.primaryNumberVoiceMailInfo.carrierCountryCode];
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
        if (self.primaryNumberVoiceMailInfo) {
            //Yes, we have voicemail info
            //Check for voice mail enabled or not.
            if (self.primaryNumberVoiceMailInfo.isVoiceMailEnabled) {
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
                    //Fetch carrier list for country.
                    [[Setting sharedSetting]fetchListOfCarriersForCountry:self.primaryNumberVoiceMailInfo.carrierCountryCode];
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

-(void)fetchProfileCompletedWith:(UserProfileModel*)modelData
{
    [self.settingsListTableView reloadData];
}

#pragma mark - Settings Protocol Methods -
- (void)fetchSettingCompletedWith:(SettingModel*)modelData withFetchStatus:(BOOL)withFetchStatus {
    
    //Set up the additional numbers and additionalNumbers VoicemailInfo
    self.additionalNumbersVoiceMailInfo = [[NSMutableArray alloc]init];
    //Check for Verified Numbers.!!!
    SettingModel *currentSettingsModel = [Setting sharedSetting].data;
    if (self.additionalNumbers && [self.additionalNumbers count]) {
        //get the additional voicemail info
        if (currentSettingsModel.voiceMailInfo && [currentSettingsModel.voiceMailInfo count]) {
            for (VoiceMailInfo *voiceMailInfo in currentSettingsModel.voiceMailInfo) {
                if(![voiceMailInfo.phoneNumber isEqualToString:self.primaryNumber])
                    [self.additionalNumbersVoiceMailInfo addObject:voiceMailInfo];
                else
                    self.primaryNumberVoiceMailInfo = voiceMailInfo;
            }
        }
    }
    else {
        //Check for the settings information - Settings response has the information about the user contacts.
        if (currentSettingsModel.voiceMailInfo && [currentSettingsModel.voiceMailInfo count]) {
            NSMutableArray *additionalNumberList = [[NSMutableArray alloc]init];
            for (VoiceMailInfo *voiceMailInfo in currentSettingsModel.voiceMailInfo) {
                if(![voiceMailInfo.phoneNumber isEqualToString:self.primaryNumber]) {
                    [self.additionalNumbersVoiceMailInfo addObject:voiceMailInfo];
                    [additionalNumberList addObject:voiceMailInfo.phoneNumber];
                }
                else
                    self.primaryNumberVoiceMailInfo = voiceMailInfo;
            }
            self.additionalNumbers = additionalNumberList;
        }
    }
    
    [self showCarrierSupport];//NOV 8, 2016
}

-(void)showCarrierSupport {
    
    if(self.primaryNumberVoiceMailInfo) {
            self.carrierSupportLink = self.primaryNumberVoiceMailInfo.carrierLogoSupportUrl;
            if(self.carrierSupportLink.length)
                self.hideCarrierSupportCell = NO;
            else
                self.hideCarrierSupportCell = YES;
            
            IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromVoiceMailInfoForPhoneNumber:self.primaryNumber];
            
            if([carrierInfo.networkName length]) {
                self.carrierSupportNetworkName = carrierInfo.networkName;
            }
            
            NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            NSString* localFileName = [NSString stringWithFormat:@"CarrierLogoSupport_%@.png",loginId];
            NSString *storagePathName = [IVFileLocator getCarrierLogoPath:localFileName];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:storagePathName]) {
                self.carrierSupportLogo = storagePathName;
            } else {
                //TODO download the logo and save it locally
                //DEC 3, 2016
                [Setting sharedSetting].delegate = self;
                [[Setting sharedSetting]downloadAndSaveSupportedCarrierLogoImage:self.primaryNumberVoiceMailInfo.carrierLogoHomeUrl];
                //
                //DEC 3, 2016 [self downloadAndSaveSupportedCarrierLogoImage:self.primaryNumberVoiceMailInfo.carrierLogoHomeUrl];
            }
            
            KLog(@"Debug");
            [self.settingsListTableView reloadData];
        }
    else  {
        if([self.carrierSupportNetworkName length]) {
            self.hideCarrierSupportCell = NO;
        } else {
            self.hideCarrierSupportCell = YES;
        }
    }
}

#pragma mark - BaseUI Method Implementation -
- (void)removeOverlayViewsIfAnyOnPushNotification {
    
    KLog(@"Remove PopOver if any open");
    [ScreenUtility closeAlert];
    [self dismissViewControllerAnimated:YES completion:nil];
    /*
    [self dismissViewControllerAnimated:YES completion:nil];
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0)
            if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]])
                [(UIAlertView *)[subviews objectAtIndex:0] dismissWithClickedButtonIndex:[(UIAlertView *)[subviews objectAtIndex:0] cancelButtonIndex] animated:NO];
    }
    */
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
    [super removeOverlayViewsIfAnyOnPushNotification];
    
}

#pragma mark - Memory CleanUp Methods -
- (void)dealloc {
    
    //NSLog(@"Dealloc of settings list controller has been called");
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kLinphoneRegistrationUpdate object:nil];
    
    self.sectionTitleArray = nil;
    self.profileCellInfoList = nil;
    self.generalCellInfoList = nil;
    self.instaVoiceInfoList = nil;
    self.primaryNumber = nil;
    self.primaryNumberVoiceMailInfo = nil;
    self.additionalNumbers = nil;
    self.additionalNumbersVoiceMailInfo = nil;
    self.longPressGesture = nil;
    //self.isLogEnabled = NO;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//DEC 3, 2016
#ifdef DEC_3_2016
- (void)downloadAndSaveSupportedCarrierLogoImage:(NSString*)carrierLogoImagePath
{
    KLog(@"downloadAndSaveSupportedCarrierLogoImage");
    if (carrierLogoImagePath && ![carrierLogoImagePath isEqualToString:@""]) {
        DownloadProfilePic* api = [[DownloadProfilePic alloc]initWithRequest:Nil];
        [api callNetworkRequest:carrierLogoImagePath withSuccess:^(DownloadProfilePic *req, NSData *responseObject) {
            NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            NSString* localFileName = [NSString stringWithFormat:@"CarrierLogoSupport_%@.png",loginId];
            [IVFileLocator deleteFileAtPath:[IVFileLocator getCarrierLogoPath:localFileName]];
            BOOL isWritten = [responseObject writeToFile:[IVFileLocator getCarrierLogoPath:localFileName] atomically:YES];
            if(isWritten)
            {
                [self.settingsListTableView reloadData];
                //TODO
            }
            
        } failure:^(DownloadProfilePic *req, NSError *error) {
            //TODO
        }];
    }
    else {
        //We do not have carrierLogoImagePath - delete If its already existed.
        NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
        NSString* localFileName = [NSString stringWithFormat:@"CarrierLogoSupport_%@.png",loginId];
        [IVFileLocator deleteFileAtPath:[IVFileLocator getCarrierLogoPath:localFileName]];
        self.carrierSupportLogo = nil;
    }
}
#endif

-(void)fetchSupportedCarrierLogoCompletedWithStatus:(BOOL)withStatus {
    [self.settingsListTableView reloadData];
}


@end
