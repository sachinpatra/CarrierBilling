//
//  IVAccountSettingsViewController.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 18/04/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVAccountSettingsViewController.h"
#import "Contacts.h"
#import "IVColors.h"
#import "Profile.h"
#import "IVAccountSettingsProtocol.h"
#import "Common.h"
#import "MZFormSheetController.h"
#import "RegistrationApi.h"

#import "Profile.h"
#import "UserProfileModel.h"
#import "NBPhoneNumberUtil.h"
#import "IVFileLocator.h"
//Api
#import "SignOutAPI.h"
#import "ManageUserContactAPI.h"
#import "FetchUserContactAPI.h"
#import "ScreenUtility.h"

//MQTT
#import "MQTTManager.h"

//TableViewCell
#import "IVAccountSettingsInfoCell.h"
#import "IVAccountSettingsLinkedNumberCell.h"
#import "IVAccountSettingsManageAccountTableViewCell.h"
#import "ChangePrimaryNumberViewController.h"

#import "LinkAdditionalMobileNumberViewController.h"
#import "LinkAdditionalMobileNumberViewController.h"
#import "VerificationOTPViewController.h"
#import "SettingsChatMenuViewController.h"
#import "SettingsSharingMenuViewController.h"

#ifdef REACHME_APP
    #define kAccSettingsVcTitle @"General"
#else
    #import "BlockedChatsViewController.h"
    #define kAccSettingsVcTitle  @"Account"
#endif

#define kPrimaryNumberCanNotDeleteErrorCode 88
#define kNumberOfSections 6
#define kHeaderHeightOffset 22.0
#define kAccountInfoCellIdentifier @"IVAccountSettingsInfoCell"
#define kIVAccountSettingsLinkedNumberCell @"IVAccountSettingsLinkedNumberCell"
#define kIVAccountSettingsManageAccountTableViewCell @"IVAccountSettingsManageAccountTableViewCell"
#define kPasswordCell  @"Password"
#define kChatCell  @"Chat"
#define kSocialSharingCell  @"Social Sharing"
#define kTotalCreditsCell @"InstaVoice credits"
#define kDisconnectCell @"Logout InstaVoice from this device" //As per latest requirement - "Disconnect" replace by "Logout"
#define kShowBlockChatsCell @"Blocked Contacts"
#define kUploadContactsCell @"Upload Contacts to find friends"
#define kButtonTag @"ButtonTag"
#define kShowChangePasswordView @"ShowChangePasswordView"
#define kLinkAdditionalMobileNumberViewIdentifier @"LinkAdditionalMobileNumberView"

#define kContactIdKey @"contact_id"
#define kCountryCodeKey @"country_code"

#define kMaxDistanceFromLabelToAddNumberButton 93.0
#define kMinDistanceFromLabelToAddNumberButton 5.0
//Enums
typedef NS_ENUM(NSUInteger,Sections){
    eManageAccountSection = 0,
    eUploadContactSection,
    eManageBlockedContactsSection,
    eManageLogoutSection
};

typedef NS_ENUM(NSUInteger,RowsInManageAccountSection){
    eChat = 0,
    eSocialSharing,
    ePassword
};

typedef NS_ENUM(NSUInteger, ManagerAccountSectionButtonTags) {
    eChatsButtonTag = 895,
    eSocialSharingButtonTag = 896,
    eUpdatePasswordButtonTag = 897,
    eTotalCreditsButtonTag = 898,
    eLogoutButtonTag = 899,
    eSyncContactsButtonTag = 900,
    eShowBlockedChatsButtonTag = 901
};

typedef NS_ENUM(NSUInteger, AlertviewTags) {
    eLogoutAlertViewTag = 976,
    eContactSyncAlertViewTag = 977
    
};

typedef NS_ENUM(NSUInteger, ContactUpdateType) {
    eContactUpdateType = 0,
    eContactAddType,
    eContactDeleteType
};

@interface IVAccountSettingsViewController () <ProfileProtocol, IVAccountSettingsDelegate, VerificationOTPViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *accountSettingsTableView;
@property (nonatomic, strong) NSArray *sectionTitleArray;
@property (nonatomic, strong) IVAccountSettingsInfoCell *accountSettingsInfoCell;
@property (nonatomic, strong) NSString *primaryPhoneNumber;
@property (nonatomic, assign) BOOL isLinkedNumberVerified;
@property (nonatomic, strong) NSMutableArray *linkedMobileNumbers;
//Array containing the verified numbers - its array of contact numbers
@property (nonatomic, strong) NSMutableArray *verifiedNumbers;
@property (nonatomic, strong) NSMutableArray *verifiedNumberDetails;
@property (nonatomic, strong) NSMutableArray *verifiedSecondaryNumbers;
//Array of non verified numbers - which contains  - "contactId" and "countryCode" information, we are maintaining since we need to send these two information while user verify the number.
@property (nonatomic, strong) NSMutableArray *nonVerifiedNumberDetails;
@property (nonatomic, strong) NSMutableDictionary *linkedMobileNumbersInfo;
@property (nonatomic, assign) NSUInteger linkedNumberDefaultCellRow;
@property (nonatomic, strong) NSMutableArray *manageAccountSectionCellDetails;
@property (nonatomic, assign) BOOL statusOfContactSync;
@end

@implementation IVAccountSettingsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = NSLocalizedString(kAccSettingsVcTitle, nil);
    self.sectionTitleArray = @[@"", @"", @"",@"",@"",@"",@""];
    
    self.accountSettingsTableView.estimatedRowHeight = 120.0;
    self.accountSettingsTableView.rowHeight = UITableViewAutomaticDimension;

    //Get the primary number information.
    self.primaryPhoneNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
    
    [self fetchUserContacts];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.uiType = ACCOUNT_SETTING;
    [appDelegate.stateMachineObj setCurrentUI:self];
    
    self.navigationController.navigationBarHidden = NO;
    appDelegate.tabBarController.tabBar.hidden = YES;
    
    [self initialDataSetUp];
    //[self processLinkedNumbersFromProfileData];
    
    //Settings - TextFlow related changes notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Methods -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


#pragma mark - TableViewDataSource Methods -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    switch (section) {
        case eManageAccountSection:
            numberOfRows = (self.manageAccountSectionCellDetails && [self.manageAccountSectionCellDetails count])? [self.manageAccountSectionCellDetails count]:0;
            break;
        case eManageBlockedContactsSection:
        case eManageLogoutSection:
            numberOfRows = 1;
            break;
        case eUploadContactSection:{
            if (!self.statusOfContactSync)
                numberOfRows = 1;
            else
                numberOfRows = 0;
            break;
        }
        default:
            break;
    }
    return numberOfRows;
    
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    static NSString *cellIdentifier;
    switch (indexPath.section) {
        case eManageBlockedContactsSection:
        case eManageLogoutSection:
        case eManageAccountSection:
        case eUploadContactSection:{
            cellIdentifier = kIVAccountSettingsManageAccountTableViewCell;
            break;
        }
        default:
            break;
    }
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    [cell layoutSubviews];
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfSections;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *titleOfSection;
    if (!self.statusOfContactSync) {
        if (section == eUploadContactSection)
            titleOfSection = @"Upload contacts to find friends";
        else
            titleOfSection = @"";
        
    }else{
        titleOfSection = @"";
    }
    return titleOfSection;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *titleOfSection;
    titleOfSection = [self.sectionTitleArray objectAtIndex:section];
    return titleOfSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(self.statusOfContactSync){
        if (section == eUploadContactSection)
            return 0.0;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(self.statusOfContactSync){
        if (section == eUploadContactSection)
            return 0.0;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
#pragma mark - TableView Delegate Methods -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case eManageAccountSection: {
            switch (indexPath.row) {
                case eChat: {
                    SettingsChatMenuViewController *chatMenuViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"SettingsChatMenuView"];
                    [self.navigationController pushViewController:chatMenuViewController animated:YES];
                    break;
                }
                case eSocialSharing: {
                    SettingsSharingMenuViewController *settingSharingMenuViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"SettingsSharingMenuView"];
                    [self.navigationController pushViewController:settingSharingMenuViewController animated:YES];
                    break;
                }
                case ePassword: {
                    if ([Common isNetworkAvailable] == NETWORK_AVAILABLE)
                        [self performSegueWithIdentifier:kShowChangePasswordView sender:self];
                    else {
                        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
                    }
                    break;
                }
            }
            break;
        }
        case eManageBlockedContactsSection:{
#ifndef REACHME_APP
            BlockedChatsViewController *blockedChatsViewController = [[BlockedChatsViewController alloc] initWithNibName:@"ChatGridViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:blockedChatsViewController animated:YES];
#endif
            break;
        }
        case eManageLogoutSection:{
            
            if ([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
                UIAlertController *alertController =   [UIAlertController
                                                        alertControllerWithTitle:NSLocalizedString(@"DISCONNECT_IV_TEXT",nil)
                                                        message:NSLocalizedString(@"SETTINGS_SIGNOUT_DES", nil)
                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* cancel = [UIAlertAction
                                         actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [alertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"SIGNOUT", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [self logoutUser];
                                         [alertController dismissViewControllerAnimated:YES completion:nil];
                                     }];
                [alertController addAction:ok];
                [alertController addAction:cancel];
                [self presentViewController:alertController animated:YES completion:nil];
                [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
            }else
            {
                [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
            }
            
            break;
        }
        default:
            break;
    }
}


#pragma mark - Profile Delegate Methods -
-(void)fetchProfileCompletedWith:(UserProfileModel*)modelData {
    
}
-(void)updateProfileCompletedWith:(UserProfileModel*)modelData {
    
}

#pragma mark - VerificationOTP Delegate Methods -

- (void)updateAdditionalNumbers {
    
    [self processLinkedNumbersFromProfileData];
    
}
- (void)addingNonVerifiedNumber:(NSString *)nonVerifiedNumber withcountrycode:(NSString *)countryCode {
    // NSLog(@"Additional non verified numbers =%@ and Country Code =%@", nonVerifiedNumber, countryCode);
    
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    
    //Check for the existance of the non verified numbers array - if not create one.
    if (!(self.nonVerifiedNumberDetails && [self.nonVerifiedNumberDetails count])) {
        self.nonVerifiedNumberDetails  = [[NSMutableArray alloc]init];
    }
    //Add non verified number details into the list.
    //Create a dictionary with the "contryCode" and "contactNumber" and add it to the array.
    NSDictionary *nonVerifiedNumberInfo = @{
                                            kContactIdKey : nonVerifiedNumber,
                                            kCountryCodeKey : countryCode,
                                            };
    
    //Check - NonVerified Number already has the number.
    if (![self.nonVerifiedNumberDetails containsObject:nonVerifiedNumberInfo]) {
        [self.nonVerifiedNumberDetails addObject:nonVerifiedNumberInfo];
        currentUserProfileDetails.additionalVerifiedNumbers = self.verifiedNumberDetails;
        currentUserProfileDetails.additionalNonVerifiedNumbers = self.nonVerifiedNumberDetails;
        [[Profile sharedUserProfile]writeProfileDataInFile];
        
    }
    
    //TODO:
    //Sequence of call should be
    // - call the processLinkedListWithProfileData
    // - call the reload table view.
    //But, delegate method it self calls the update list - which needs to be modifeid. !!!
    
    
}


#pragma mark -  IVAccountSettings Delegate Methods -
- (void)didTapOnChangePrimaryNumberButton {
    
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    
    ChangePrimaryNumberViewController *changePrimaryNumberViewController = [[ChangePrimaryNumberViewController alloc]initWithNibName:@"ChangePrimaryNumberViewController" bundle:[NSBundle mainBundle]];
    
    changePrimaryNumberViewController.currentPrimaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
    changePrimaryNumberViewController.verifiedMobileNumberList = self.verifiedNumbers;
    
    changePrimaryNumberViewController.view.frame = CGRectMake(0, 0, 260, CGRectGetHeight([UIScreen mainScreen].applicationFrame)-140);
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:changePrimaryNumberViewController];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.cornerRadius = 8.0;
    formSheet.presentedFormSheetSize = CGSizeMake(260, CGRectGetHeight([UIScreen mainScreen].applicationFrame)-140);
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    
    formSheet.willDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
        
        if(changePrimaryNumberViewController.isSelected) {
            NSMutableDictionary *dataDictionary = [self dataForUpdatationOfContactToServer:eContactUpdateType withPrimaryPhoneNumberStatus:YES withContactNumber:changePrimaryNumberViewController.currentPrimaryNumber withCountryCode:nil];
            ManageUserContactAPI* api = [[ManageUserContactAPI alloc]initWithRequest:dataDictionary];
            [self showProgressBar];
            
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
                    
                    [[Engine sharedEngineObj]updateUserIdFrom:self.primaryPhoneNumber toNew:[@"+" stringByAppendingString:changePrimaryNumberViewController.currentPrimaryNumber]];
                    
                    NSArray *serverResponse = responseObject[@"user_contacts"];
                    
                    if (serverResponse && [serverResponse count]) {
                        if (self.verifiedNumberDetails && [self.verifiedNumberDetails count]) {
                            self.verifiedNumberDetails = nil;
                            
                        }
                        self.verifiedNumberDetails = [[NSMutableArray alloc]init];
                        for (int i=0; i<[serverResponse count]; i++) {
                            NSDictionary *userContact = [serverResponse objectAtIndex:i];
                            
                            if([[userContact valueForKey:@"contact_type"] isEqualToString:@"p"]){
                                int isPrimary = [[userContact valueForKey:@"is_primary"] intValue];
                                
                                NSDictionary *verifiedNumber = @{ @"contact_id" : [userContact valueForKey:@"contact_id"],
                                                                  @"country_code" : [userContact valueForKey:@"country_code"],
                                                                  @"is_primary" : [userContact valueForKey:@"is_primary"]
                                                                  };
                                
                                if(isPrimary == 1){
                                    [self.verifiedNumberDetails insertObject:verifiedNumber  atIndex:0];
                                }
                                else{
                                    [self.verifiedNumberDetails addObject:verifiedNumber];
                                }
                                
                            }
                        }
                        
                    }
                    
                    //Delete the carrier logo - once primary number has been changed.
                    NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
                    NSString* localFileName = [NSString stringWithFormat:@"CarrierLogo_%@.png",loginId];
                    [IVFileLocator deleteFileAtPath:[IVFileLocator getCarrierLogoPath:localFileName]];

                    [[ConfigurationReader sharedConfgReaderObj]setLoginId:changePrimaryNumberViewController.currentPrimaryNumber];
                    
                    //TODO : Change the logic here!!!
                    //Get the primary number information.
                    self.primaryPhoneNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
                    
                    [self.verifiedNumbers exchangeObjectAtIndex:0 withObjectAtIndex:[self.verifiedNumbers indexOfObject:changePrimaryNumberViewController.currentPrimaryNumber]];
                    
                    currentUserProfileDetails.additionalVerifiedNumbers = self.verifiedNumberDetails;
                    [[Profile sharedUserProfile]writeProfileDataInFile];
                    
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
    };
    
    [formSheet presentAnimated:YES completionHandler:nil];
}

- (void)didTapOnVerifyLinkedNumberButtonInRow:(NSInteger)inRow {
    //First verify - the number you are verify cross the limit of secondary numbers.
    if ([self.verifiedSecondaryNumbers count] == 10 ) {
        [ScreenUtility showAlert:@"Limit Exceeded! Only 10 verified numbers can be linked to account"];
        return;
    }
    
    if ([self.verifiedSecondaryNumbers count] < 10) {
        //get the phone number to be verified.
        NSString *numberToBeVerified = [self.linkedMobileNumbers objectAtIndex:inRow];
        
        //Nonverified number info
        NSDictionary *nonVerifiedNumberInfo;
        
        for (NSDictionary *numberInfo in self.nonVerifiedNumberDetails) {
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

- (void)didTapOnDeleteLinkedNumberButtonInRow:(NSInteger)inRow {

    NSString *title = [NSString stringWithFormat:@"Confirm Delete\n %@",[Common getFormattedNumber:[@"+" stringByAppendingString:[self.linkedMobileNumbers objectAtIndex:inRow]] withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
    
    
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
                             [self showProgressBar];
                             [self deletPhoneNumber:inRow];
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alertController addAction:cancel];
    [alertController addAction:ok];

    [self presentViewController:alertController animated:YES completion:nil];
    [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    
}

- (IBAction)logOutAction:(id)sender
{
    if ([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        UIAlertController *alertController =   [UIAlertController
                                                alertControllerWithTitle:NSLocalizedString(@"DISCONNECT_IV_TEXT",nil)
                                                message:NSLocalizedString(@"SETTINGS_SIGNOUT_DES", nil)
                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"SIGNOUT", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self logoutUser];
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alertController addAction:ok];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
        [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        
    }
    else
    {
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

- (void)didTapOnProcessDataButtonWithTag:(NSInteger)withButtonTag {
    
    switch (withButtonTag) {
        case eUpdatePasswordButtonTag: {
            if ([Common isNetworkAvailable] == NETWORK_AVAILABLE)
                [self performSegueWithIdentifier:kShowChangePasswordView sender:self];
            else {
                [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
            }
            break;
        }
        case eChatsButtonTag: {
            SettingsChatMenuViewController *chatMenuViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"SettingsChatMenuView"];
            [self.navigationController pushViewController:chatMenuViewController animated:YES];
            break;
        }
        case eSocialSharingButtonTag: {
            SettingsSharingMenuViewController *settingSharingMenuViewController = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"SettingsSharingMenuView"];
            [self.navigationController pushViewController:settingSharingMenuViewController animated:YES];
            break;
        }
        case eLogoutButtonTag: {
            
            if ([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
                UIAlertController *alertController =   [UIAlertController
                                                        alertControllerWithTitle:NSLocalizedString(@"DISCONNECT_IV_TEXT",nil)
                                                        message:NSLocalizedString(@"SETTINGS_SIGNOUT_DES", nil)
                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* cancel = [UIAlertAction
                                         actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [alertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"SIGNOUT", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [self logoutUser];
                                         [alertController dismissViewControllerAnimated:YES completion:nil];
                                     }];
                [alertController addAction:ok];
                [alertController addAction:cancel];
                [self presentViewController:alertController animated:YES completion:nil];
                [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];

            }
            else
            {
                //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
                [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
            }
            
            
            break;
        }
        case eSyncContactsButtonTag: {
            if([Common isNetworkAvailable] == NETWORK_AVAILABLE)
                [self showPermissionDialouge];
            else {
                //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
                [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
            }
            
            break;
        }
        case eShowBlockedChatsButtonTag: {
#ifndef REACHME_APP
            BlockedChatsViewController *blockedChatsViewController = [[BlockedChatsViewController alloc] initWithNibName:@"ChatGridViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:blockedChatsViewController animated:YES];
#endif
            break;
        }
        default:
            break;
    }
    
}

- (void)didTapOnInfoButton {
    UIAlertController *alertController =   [UIAlertController
                                            alertControllerWithTitle:nil
                                            message:NSLocalizedString(@"InstaVoice credits enables you to send free SMS to your friends even if they do not have InstaVoice.",nil)
                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"Ok", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
    [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    
}
- (void)didTapOnAddLinkedNumberButton {
    
    if ([self.verifiedSecondaryNumbers count] == 10) {
        [ScreenUtility showAlert:@"Limit Exceeded! Only 10 verified numbers can be linked to account"];
        return;
    }
    if ([self.verifiedSecondaryNumbers count] < 10) {
        
        LinkAdditionalMobileNumberViewController *linkAdditionalMobileNumberViewController = [[LinkAdditionalMobileNumberViewController alloc]init];
        
        linkAdditionalMobileNumberViewController.view.frame = CGRectMake(0, 0, 260,190); //CGRectGetHeight([UIScreen mainScreen].applicationFrame)-280);
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:linkAdditionalMobileNumberViewController];
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
        formSheet.cornerRadius = 8.0;
        formSheet.presentedFormSheetSize = CGSizeMake(260, 190);
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

#pragma mark - BaseUI Method Implementation -
- (void)removeOverlayViewsIfAnyOnPushNotification {
    
    KLog(@"Remove PopOver if any open");
    [ScreenUtility closeAlert];
    
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
    [super removeOverlayViewsIfAnyOnPushNotification];
    
}

#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
  
    dispatch_async(dispatch_get_main_queue()
                   , ^{
                       [self.accountSettingsTableView reloadData];
                   });
}

#pragma mark - Private Methods -
- (void)fetchUserContacts {
    if( [Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        //OCT 13, 2016 [ScreenUtility showAlert:@"Network is not connected."];
        //[ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    NSMutableDictionary *userList = [[NSMutableDictionary alloc]init];
    long ivUserId = [[ConfigurationReader sharedConfgReaderObj] getIVUserId];
    NSNumber *num = [NSNumber numberWithLong:ivUserId];
    
    [userList setValue:[appDelegate.confgReader getDeviceUUID] forKey:API_DEVICE_ID];
    [userList setValue:num forKey:IV_USER_ID];
    [userList setValue:[appDelegate.confgReader getUserSecureKey] forKey:API_USER_SECURE_KEY];
    
    FetchUserContactAPI* api = [[FetchUserContactAPI alloc]initWithRequest:userList];
    [api callNetworkRequest:userList withSuccess:^(FetchUserContactAPI *req, NSMutableDictionary *responseObject) {
        if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
            EnLogd(@"Error fetching the user userlist %@ and api request %@",userList,api.request);
        } else {
            [self.linkedMobileNumbers removeAllObjects];
            NSArray *userContacts = [responseObject valueForKey:@"user_contacts"];
            UserProfileModel *model = [[Profile sharedUserProfile]profileData];
            NSMutableArray *additionalNonVerifiedNumbers = [model.additionalNonVerifiedNumbers mutableCopy];
            NSMutableArray *additionalVerifiedNumbers = [model.additionalVerifiedNumbers mutableCopy];
            
            [additionalVerifiedNumbers removeAllObjects];
            
            for (int i=0; i<[userContacts count]; i++) {
                NSDictionary *userContact = [userContacts objectAtIndex:i];
                
                if([[userContact valueForKey:@"contact_type"] isEqualToString:@"p"]){
                    int isPrimary = [[userContact valueForKey:@"is_primary"] intValue];
                    NSArray *filteredNonVerifiedNumbers = [additionalNonVerifiedNumbers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_id = %@",[userContact valueForKey:@"contact_id"]]];
                    
                    NSDictionary *verifiedNumber = @{ @"contact_id" : [userContact valueForKey:@"contact_id"],
                                                      @"country_code" : [userContact valueForKey:@"country_code"],
                                                      @"is_primary" : [userContact valueForKey:@"is_primary"]
                                                      };
                    
                    if(isPrimary == 1){
                        //Its primary number - update the login id
                        //MAR 9, 2017
                        NSString* curPrimNum = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
                        NSString* newPrimNum = verifiedNumber[@"contact_id"];
                        if(![curPrimNum isEqualToString:newPrimNum]) {
                            [[Engine sharedEngineObj]updateUserIdFrom:curPrimNum toNew:[@"+" stringByAppendingString:newPrimNum]];
                        }
                        //
                        [[ConfigurationReader sharedConfgReaderObj]setLoginId:verifiedNumber[@"contact_id"]];
                        [additionalVerifiedNumbers insertObject:verifiedNumber  atIndex:0];
                        
                    }
                    else{
                        [additionalVerifiedNumbers addObject:verifiedNumber];
                    }
                    if(([additionalVerifiedNumbers containsObject:[userContact valueForKey:@"contact_id"]]) && ([filteredNonVerifiedNumbers count] != 0)){
                        [additionalNonVerifiedNumbers removeObjectsInArray:filteredNonVerifiedNumbers];
                    }
                }
            }
            
            model.additionalVerifiedNumbers = additionalVerifiedNumbers;
            model.additionalNonVerifiedNumbers = additionalNonVerifiedNumbers;
            
            [[Profile sharedUserProfile]writeProfileDataInFile];
            
            [self processLinkedNumbersFromProfileData];

            [[Setting sharedSetting]fetchCarrierList];
        }
    }failure:^(FetchUserContactAPI *req, NSError *error) {
        EnLogd(@"*** Error fetching the user: %@, %@",userList,[error description]);
        KLog(@"*** Error fetching the user: %@, %@",userList,[error description]);
        
        /* SEP 28, 2016
        NSInteger errorCode = error.code;
        NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
        if([errorMsg length])
            [ScreenUtility showAlertMessage: errorMsg];
         */
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

- (void)processLinkedNumbersFromProfileData {
    
    //Get the primary number information.
    self.primaryPhoneNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;

    //TODO : reverify the logic of this method - we can optimise!!!
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    //Profile - additionalVerifiedNumbers and additionalNonVerifiedNumbers
    
    NSMutableArray *profileVerifiedNumbers = currentUserProfileDetails.additionalVerifiedNumbers;
    NSMutableArray *profileNonVerifiedNumbers = currentUserProfileDetails.additionalNonVerifiedNumbers;
    
    self.verifiedNumberDetails = profileVerifiedNumbers;
    
    self.nonVerifiedNumberDetails = profileNonVerifiedNumbers;
    
    
    if (!(self.verifiedNumberDetails && [self.verifiedNumberDetails count])) {
        self.verifiedNumberDetails = [[NSMutableArray alloc]init];
        //Add primary number as verified numbers - in the first index
        NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
        NSNumber *countryIsdCode = [phoneUtil extractCountryCode:self.primaryPhoneNumber nationalNumber:nil];
        NSDictionary *verifiedNumber = @{kContactIdKey : self.primaryPhoneNumber,
                                         kCountryCodeKey : countryIsdCode,
                                         };
        [self.verifiedNumberDetails insertObject:verifiedNumber atIndex:0];
    }
    
    //Update profile data with verified and non verified numbers.
    currentUserProfileDetails.additionalVerifiedNumbers = _verifiedNumberDetails;
    currentUserProfileDetails.additionalNonVerifiedNumbers = _nonVerifiedNumberDetails;
    [[Profile sharedUserProfile]writeProfileDataInFile];
    
    //Update the carrier list information in the settings
    [[Setting sharedSetting]fetchCarrierList];
    
    //Reconstruct the linkedNumbers Array
    if (self.linkedMobileNumbers && [self.linkedMobileNumbers count]) {
        [self.linkedMobileNumbers removeAllObjects];
        self.linkedMobileNumbers = nil;
    }
    
    self.linkedMobileNumbers = [[NSMutableArray alloc]init];
    [self.linkedMobileNumbers addObjectsFromArray:[self.verifiedNumberDetails valueForKeyPath:kContactIdKey]];
    [self.linkedMobileNumbers addObjectsFromArray:[self.nonVerifiedNumberDetails valueForKeyPath:kContactIdKey]];
    [self.linkedMobileNumbers removeObject:self.primaryPhoneNumber];
    
    if(self.linkedMobileNumbers.count)
    {
        self.linkedMobileNumbers = [NSMutableArray arrayWithArray:[self.linkedMobileNumbers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    self.verifiedNumbers = [[NSMutableArray alloc]initWithArray:[self.verifiedNumberDetails valueForKeyPath:kContactIdKey]];
    self.verifiedSecondaryNumbers =  [[NSMutableArray alloc]initWithArray:self.verifiedNumbers];
    [self.verifiedSecondaryNumbers removeObject:self.primaryPhoneNumber];
    
    dispatch_async(dispatch_get_main_queue()
                   , ^{
                       
                       //Reload TableView.
                       [self.accountSettingsTableView reloadData];
                       
                   });
    
    
}

- (void)initialDataSetUp {
    
    self.statusOfContactSync = [appDelegate.confgReader getContactSyncPermissionFlag];
    
    NSString *passwordButtonTitle;
    if([appDelegate.confgReader getPassword].length == 0)
        passwordButtonTitle = @"";
    else
        passwordButtonTitle = @"";
    
    self.manageAccountSectionCellDetails = [@[@{kChatCell:@"",kButtonTag:@(eChatsButtonTag)},@{kSocialSharingCell:@"",kButtonTag:@(eSocialSharingButtonTag)},@{kPasswordCell:passwordButtonTitle,kButtonTag:@(eUpdatePasswordButtonTag)}]mutableCopy];
    
    [self.accountSettingsTableView reloadData];
}

- (void)contactSyncAlertNoButtonAction {
    [appDelegate.confgReader setContactSyncPermissionFlag:FALSE];
}

- (void)contactSyncAlertYesButtonAction {
    
    [appDelegate.confgReader setContactSyncPermissionFlag:TRUE];
    
    [self initialDataSetUp];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.accountSettingsTableView reloadData];
    });
    
    [[ConfigurationReader sharedConfgReaderObj]setContactServerSyncFlag:NO];
    //[[ConfigurationReader sharedConfgReaderObj]setContactLocalSyncFlag:NO];//Apr 6, 2018
    [[Contacts sharedContact]setIsSyncInProgress:NO];
    [[Contacts sharedContact]syncPendingContactWithServer];
    [((UITabBarController *)appDelegate.window.rootViewController) setSelectedIndex:3];
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case eManageAccountSection: {
            
            if ([cell isKindOfClass:[IVAccountSettingsManageAccountTableViewCell class]]) {
                IVAccountSettingsManageAccountTableViewCell *manageAccountCell = (IVAccountSettingsManageAccountTableViewCell *)cell;
                manageAccountCell.accountSettingsDelegate = self;
                manageAccountCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                
                NSDictionary *details = (self.manageAccountSectionCellDetails && [self.manageAccountSectionCellDetails count])? [self.manageAccountSectionCellDetails objectAtIndex:indexPath.row]:nil;
                NSString *value;
                for (NSString *key in [details allKeys])
                {
                    if ([key isEqualToString:@"ButtonTag"]) {
                        value = [details objectForKey:key];
                        manageAccountCell.processDataButton.tag = [value integerValue];
                    }
                    else {
                        value = [details objectForKey:key];
                        //show the info button only in the TotalCredits row.
                        manageAccountCell.infoButton.hidden = ([key isEqualToString:kTotalCreditsCell])?NO: YES;
                        [manageAccountCell.infoButton setTintColor:[IVColors redColor]];

                        if ([key isEqualToString:kShowBlockChatsCell])
                            manageAccountCell.processDataButton.tag = eShowBlockedChatsButtonTag;
                        
                        manageAccountCell.titleLabel.text = NSLocalizedString(key, nil);
                        [manageAccountCell.processDataButton setTitle:NSLocalizedString(value, nil) forState:UIControlStateNormal];
                        
                    }
                }
                
                manageAccountCell.logoutButton.hidden = YES;
                manageAccountCell.blockedContactsCount.hidden = YES;
                manageAccountCell.processDataButton.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                manageAccountCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
            
        case eManageBlockedContactsSection:{
            if ([cell isKindOfClass:[IVAccountSettingsManageAccountTableViewCell class]]) {
                IVAccountSettingsManageAccountTableViewCell *manageAccountCell = (IVAccountSettingsManageAccountTableViewCell *)cell;
                NSArray* arrBlockedListFromSettings = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"BLOCKED_TILES"];
                NSString *blockedListNumber;
                if(arrBlockedListFromSettings.count > 0)
                    blockedListNumber = [NSString stringWithFormat:@"%lu contact(s)",(unsigned long)arrBlockedListFromSettings.count];
                else
                    blockedListNumber = @"None";
                
                manageAccountCell.accountSettingsDelegate = self;
                manageAccountCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                manageAccountCell.blockedContactsCount.hidden = NO;
                manageAccountCell.titleLabel.text = NSLocalizedString(@"Blocked contacts", nil);
                manageAccountCell.blockedContactsCount.text = NSLocalizedString(blockedListNumber, nil);
                manageAccountCell.blockedContactsCount.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                manageAccountCell.blockedContactsCount.textColor = [UIColor darkGrayColor];
                manageAccountCell.infoButton.hidden = YES;
                manageAccountCell.processDataButton.hidden = YES;
                manageAccountCell.logoutButton.hidden = YES;
                manageAccountCell.blockedContactsCount.hidden = NO;
                manageAccountCell.titleLabel.hidden = NO;
                manageAccountCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
            break;
        case eManageLogoutSection:{
            if ([cell isKindOfClass:[IVAccountSettingsManageAccountTableViewCell class]]) {
                IVAccountSettingsManageAccountTableViewCell *manageAccountCell = (IVAccountSettingsManageAccountTableViewCell *)cell;
                manageAccountCell.logoutButton.hidden = NO;
                [manageAccountCell.logoutButton setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
                [manageAccountCell.logoutButton addTarget:self action:@selector(logOutAction:) forControlEvents:UIControlEventTouchUpInside];
                [manageAccountCell.logoutButton setTitleColor:[UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f] forState:UIControlStateNormal];
                manageAccountCell.logoutButton.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                manageAccountCell.logoutButton.hidden = NO;
                manageAccountCell.infoButton.hidden = YES;
                manageAccountCell.titleLabel.hidden = YES;
                manageAccountCell.processDataButton.hidden = YES;
                manageAccountCell.blockedContactsCount.hidden = YES;
                manageAccountCell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
        case eUploadContactSection:{
            if ([cell isKindOfClass:[IVAccountSettingsManageAccountTableViewCell class]]) {
                IVAccountSettingsManageAccountTableViewCell *manageAccountCell = (IVAccountSettingsManageAccountTableViewCell *)cell;
                manageAccountCell.accountSettingsDelegate = self;
                [manageAccountCell.processDataButton setTitle:NSLocalizedString(@"Upload", nil) forState:UIControlStateNormal];
                manageAccountCell.titleLabel.text = @"Upload contacts";
                [manageAccountCell.processDataButton setTitleColor:[UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f] forState:UIControlStateNormal];
                manageAccountCell.processDataButton.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                manageAccountCell.processDataButton.tag = eSyncContactsButtonTag;
                manageAccountCell.processDataButton.hidden = NO;
                manageAccountCell.infoButton.hidden = YES;
                manageAccountCell.logoutButton.hidden = YES;
                manageAccountCell.blockedContactsCount.hidden = YES;
                manageAccountCell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
        }
        default:
            break;
    }
    
}

- (IVAccountSettingsInfoCell*)accountSettingsInfoCell {
    if (!_accountSettingsInfoCell)
        _accountSettingsInfoCell = [self.accountSettingsTableView dequeueReusableCellWithIdentifier:kAccountInfoCellIdentifier];
    return _accountSettingsInfoCell;
}

- (void)deletPhoneNumber:(NSInteger)inRow {
    BOOL __block isNumberDeleted = NO;
    
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    
    //We are very sure that this button belongs to the LinkedNumber Row.
    //Check the number is verified or non verified. If number is non verified remove from the - nonverified details and update the profile data.
    
    NSString *phoneNumberToBeDeleted = [self.linkedMobileNumbers objectAtIndex:inRow];//TODO Check bounds
    NSArray *nonVerifiedNumberList = [self.nonVerifiedNumberDetails valueForKeyPath:kContactIdKey];
    
    if ([nonVerifiedNumberList containsObject:phoneNumberToBeDeleted]) {
        //Check nonVerified List contains phoneNumberToBeDeleted.
        for (phoneNumberToBeDeleted in nonVerifiedNumberList) {
            //Yes, Its belonging to non verified number - remove from the local list and update the profile data - nonverified number list.
            for (NSDictionary *numberInfo in self.nonVerifiedNumberDetails) {
                if ([[numberInfo valueForKey:kContactIdKey] isEqualToString:phoneNumberToBeDeleted]) {
                    [self.nonVerifiedNumberDetails removeObject:numberInfo];
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
                    
                    for (NSDictionary *numberInfo in self.verifiedNumberDetails) {
                        if ([[numberInfo valueForKey:kContactIdKey] isEqualToString:phoneNumberToBeDeleted]) {
                            [self.verifiedNumberDetails removeObject:numberInfo];
                            isNumberDeleted = YES;
                            break;
                        }
                    }
                }
                [ScreenUtility showAlert:@"Number has been deleted successfully"];
                currentUserProfileDetails.additionalVerifiedNumbers = self.verifiedNumberDetails;
                currentUserProfileDetails.additionalNonVerifiedNumbers = self.nonVerifiedNumberDetails;
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
    [self hideProgressBar];

    
}


- (void)logoutUser {
    
#ifdef MQTT_ENABLED
    [[MQTTManager sharedMQTTManager]disconnectMQTTClient];
#endif
    
    int newtworkCkeck = [Common isNetworkAvailable];
    if(newtworkCkeck == NETWORK_AVAILABLE)
    {
        [self showProgressBar];
        NSMutableDictionary *signOutDic = [[NSMutableDictionary alloc]init];
        SignOutAPI* api = [[SignOutAPI alloc]initWithRequest:signOutDic];
        [api callNetworkRequest:signOutDic withSuccess:^(SignOutAPI *req, NSMutableDictionary *responseObject) {
            
            [self hideProgressBar];
            [appDelegate.engObj clearNetworkData];
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
            [appDelegate.engObj cancelEvent];
            [appDelegate.confgReader setIsLoggedIn:FALSE];
            [appDelegate.confgReader setUserSecureKey:@""];
            [appDelegate.confgReader setPassword:@"" withTime:nil];
            [[ConfigurationReader sharedConfgReaderObj] removeValueForKey:LAST_MSG_UPDATE_FROM_CONTACT_TIME];
            [[ConfigurationReader sharedConfgReaderObj] removeValueForKey:ENABLE_LOG_FLAG];
            //Jan 31, 2018
            [[ConfigurationReader sharedConfgReaderObj] setVoipPushToken:@""];
            [[ConfigurationReader sharedConfgReaderObj] setCloudSecureKey:@""];
            //
            self.navigationController.navigationBarHidden = YES;
            
            //CMP
            NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
            [navigationArray removeAllObjects];
            [appDelegate.tabBarController removeFromParentViewController];
            //
            
            appDelegate.window.rootViewController = [[UIStateMachine sharedStateMachineObj]getRootViewController];
           
            //Clear the carrier list.
            [[Setting sharedSetting]clearCarrierList];
            
            //Delete the promoimage
            NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            NSString* localFileName = [NSString stringWithFormat:@"PromoImage_%@.png",loginId];
            [IVFileLocator deleteFileAtPath:[IVFileLocator getPromoImagePath:localFileName]];
            
            //Bhaskar --> Clear Blocked Contacts DataBase after logout
            [[ConfigurationReader sharedConfgReaderObj] removeObjectForTheKey:@"BLOCKED_TILES"];
            
        } failure:^(SignOutAPI *req, NSError *error) {
            [self hideProgressBar];
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
            
            //CMP SEP 25 TODO: even if newtork is not available, logout the user
            [appDelegate.engObj clearNetworkData];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
            [appDelegate.engObj cancelEvent];
            [appDelegate.confgReader setIsLoggedIn:FALSE];
            [appDelegate.confgReader setUserSecureKey:@""];
            [[ConfigurationReader sharedConfgReaderObj] removeValueForKey:LAST_MSG_UPDATE_FROM_CONTACT_TIME];
            [[ConfigurationReader sharedConfgReaderObj] removeValueForKey:ENABLE_LOG_FLAG];
            //Jan 31, 2018
            [[ConfigurationReader sharedConfgReaderObj] setVoipPushToken:@""];
            [[ConfigurationReader sharedConfgReaderObj] setCloudSecureKey:@""];
            //
            //Bhaskar --> Clear Blocked Contacts DataBase after logout
            [[ConfigurationReader sharedConfgReaderObj] removeObjectForTheKey:@"BLOCKED_TILES"];
            
            self.navigationController.navigationBarHidden = YES;
            appDelegate.window.rootViewController =[[UIStateMachine sharedStateMachineObj]getRootViewController];
        }];
    }
    else {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}


- (void)showPermissionDialouge {
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
        
        
        UIAlertController *alertController =   [UIAlertController
                                                alertControllerWithTitle:NSLocalizedString(@"PERMISSION_DENIED", nil)
                                                message:NSLocalizedString(@"CONTACT_ACCESS_WARNING", nil)
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
    else {
        
        
        UIAlertController *alertController =   [UIAlertController
                                                alertControllerWithTitle:NSLocalizedString(@"DIALOG_TITLE", nil)
                                                message:NSLocalizedString(@"DIALOG_MESSAGE", nil)
                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"DIALOG_POSITIVE_BUTTON",nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self contactSyncAlertYesButtonAction];
                             }];
        
        UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"DIALOG_NEGATIVE_BUTTON",nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self contactSyncAlertNoButtonAction];
                                     
                                 }];
        [alertController addAction:ok];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
        [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Memory CleanUp Methods -
- (void)dealloc {
    
    //NSLog(@"Dealloc of account settings has been called");
    
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    
}
@end
