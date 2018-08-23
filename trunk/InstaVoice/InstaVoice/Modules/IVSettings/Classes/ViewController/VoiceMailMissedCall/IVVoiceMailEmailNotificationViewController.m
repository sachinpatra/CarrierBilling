//
//  IVVoiceMailEmailNotificationViewController.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 29/06/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "IVVoiceMailEmailNotificationViewController.h"
#import "MyProfileApi.h"
#import "UserProfileModel.h"
#import "InsideConversationScreen.h"
#import "IVFileLocator.h"
#import "IVVoiceMailEmailNotificationTableViewCell.h"
#import "Profile.h"
#import "UpdateUserProfileAPI.h"
#import "TimeZoneViewController.h"
#import "IVVoiceMailListViewController.h"
#import "IVPrimaryNumberVoiceMailViewController.h"

#define kEmailAddressLabelText @"Email Address"
#define kEmailAddressStatusAdd @"Add"
#define kEmailAddressStatusVerified @"Verified"
#define kEmailAddressStatusUnVerified @"Unverified"
#define kVoiceMailEmailNotificationsCellIdentifier @"VoiceMailEmailNotificationCell"
#define kVoiceMailEmailAddressCellIdentifier @"VoiceMailEmailAddressCell"
#define kVoiceMailEmailTimeZoneCellIdentifier @"VoiceMailEmailTimeZoneCell"
#define kNumberSectionsInEmailNotifications 1
#define kNumberOfRowsInEmailNotifications 4
#define kHeightForSections 60.0
#define kVoiceMailEmailNotificationSwitchTag 919
#define kMissedCallEmailNotificationSwitchTag 920
#define kInfoAlertTag 891

typedef NS_ENUM(NSUInteger, EmailNotificationCells){
    eEmailAddressCell = 0,
    eEmailNotificationForVoiceMailCell,
    eEmailNotificationForMissedCallCell,
    eEmailTimeZoneCell
};


@interface IVVoiceMailEmailNotificationViewController ()<IVVoiceMailCarrierSelectionProtocol,SettingProtocol,ProfileProtocol>
@property (nonatomic, strong) VoiceMailInfo *voiceMailInfo;
@property (nonatomic, strong) NSString *currentNetworkName;
@property (nonatomic, strong) NSString *helpText;
@property (nonatomic, strong) NSString *activationDialNumber;
@property (nonatomic, strong) NSMutableArray *helpTextArray;
@property (nonatomic, strong) NSMutableArray *supportContactList;
@property (nonatomic, strong) NSString *currentEmailId;
@property (nonatomic, strong) NSString *primaryNumber;
@property (nonatomic, strong) NSMutableArray *additionalNumbersVoiceMailInfo;
@property (nonatomic, strong) NSArray *additionalNumbers;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, assign) BOOL isEmailNotificationActivatedForVoiceMail;
@property (nonatomic, assign) BOOL isEmailNotificationActivatedForMissedCall;
@property (nonatomic, assign) BOOL isEmailAddressVerified;

@end

@implementation IVVoiceMailEmailNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Get the settings information.
    [Setting sharedSetting].delegate = self;
    [[Setting sharedSetting]getUserSettingFromServer];
    self.title = NSLocalizedString(@"Email Notifications", nil);
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpAction)];
    self.navigationItem.rightBarButtonItem = helpButton;
    [self configureHelpAndSuggestion];
    [self refreshUIWithLatestData];
    self.voiceMailEmailNotificationTableView.tableFooterView = [UIView new];
    self.uiType = VOICEMAIL_EMAIL_NOTIFICATION_SCREEN;
    self.primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[self navigationController] navigationBar] setNeedsLayout];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(applicationWillEnterForeground:)
//                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    self.uiType = VOICEMAIL_EMAIL_NOTIFICATION_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    
    [self checkForVoicemailAdditionalNumbers];
    
    UserProfileModel *model = [[Profile sharedUserProfile]profileData];
    if (![model.emailTimeZone isEqualToString:timeZone]) {
        timeZone = model.emailTimeZone;
        [self refreshUIWithLatestProfileData];
        dispatch_async(dispatch_get_main_queue()
                       , ^{
                           [self.voiceMailEmailNotificationTableView reloadData];
                           
                       });
        [self updateVoicemailSubscriptionInUserProfile];
    }
    //This information we have to fetch fresh - to check out - greeting and welcome message has been changed or not.
    [Profile sharedUserProfile].delegate = self;
    //[[Profile sharedUserProfile]getProfileDataFromServer];
    
}

- (void)helpAction
{
    //self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", self.currentNetworkName, self.activationDialNumber];
    [self showHelpMessage];
}

- (void)configureHelpAndSuggestion
{
    self.helpTextArray       = [[NSMutableArray alloc]init];
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
    [newDic setValue:@"" forKey:@"HELP_TEXT"];
    
    
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

#pragma mark - BaseUI Method Implementation -
- (void)removeOverlayViewsIfAnyOnPushNotification {
    
    KLog(@"Remove PopOver if any open");
    [ScreenUtility closeAlert];
    
    NSArray *subViews = self.view.subviews;
    
    for (UIView *subView in subViews) {
        if (subView.tag == kInfoAlertTag) {
            UIAlertView *alertView = (UIAlertView *)subView;
            [alertView dismissWithClickedButtonIndex:1 animated:YES];
        }
    }
    
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
    [super removeOverlayViewsIfAnyOnPushNotification];
    
}

#pragma mark - UITableView Datasource Methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  kNumberSectionsInEmailNotifications;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRowsInEmailNotifications;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeightForSections;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, DEVICE_WIDTH - 30.0, 60.0)];
    label.text = NSLocalizedString(@"Receive Voicemail & Missed Call Alerts on your email address", nil);
    label.numberOfLines = 4;
    label.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    label.textColor = [UIColor darkGrayColor];
    [tableHeaderView addSubview:label];
    return tableHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *cellIdentifier;
    
    switch (indexPath.row) {
        case eEmailAddressCell:
            cellIdentifier = kVoiceMailEmailAddressCellIdentifier;
            break;
        case eEmailTimeZoneCell:
            cellIdentifier = kVoiceMailEmailTimeZoneCellIdentifier;
            break;
        case eEmailNotificationForVoiceMailCell:
        case eEmailNotificationForMissedCallCell:
            cellIdentifier = kVoiceMailEmailNotificationsCellIdentifier;
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
    switch (indexPath.row) {
        case eEmailNotificationForVoiceMailCell: {
            if ([cell isKindOfClass:[IVVoiceMailEmailNotificationTableViewCell class]]) {
                IVVoiceMailEmailNotificationTableViewCell *mailNotificationCell = (IVVoiceMailEmailNotificationTableViewCell *)cell;
                mailNotificationCell.notificationSwitch.tag = kVoiceMailEmailNotificationSwitchTag;
                mailNotificationCell.emailNotificationTableViewCellDelegate = self;
                mailNotificationCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                mailNotificationCell.titleLabel.text = NSLocalizedString(@"Voicemail", nil);
                [mailNotificationCell.notificationSwitch setOn:self.isEmailNotificationActivatedForVoiceMail animated:YES];
            }
            break;
        }
        case eEmailNotificationForMissedCallCell: {
            if ([cell isKindOfClass:[IVVoiceMailEmailNotificationTableViewCell class]]) {
                IVVoiceMailEmailNotificationTableViewCell *mailNotificationCell = (IVVoiceMailEmailNotificationTableViewCell *)cell;
                mailNotificationCell.notificationSwitch.tag = kMissedCallEmailNotificationSwitchTag;
                mailNotificationCell.emailNotificationTableViewCellDelegate = self;
                mailNotificationCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                mailNotificationCell.titleLabel.text = NSLocalizedString(@"Missed Call", nil);
                [mailNotificationCell.notificationSwitch setOn:self.isEmailNotificationActivatedForMissedCall animated:YES];
            }
            break;
        }
        case eEmailAddressCell: {
            if([cell isKindOfClass:[IVVoiceMailEmailNotificationTableViewCell class]]) {
                
                IVVoiceMailEmailNotificationTableViewCell *mailAddress = (IVVoiceMailEmailNotificationTableViewCell*)cell;
                mailAddress.emailNotificationTableViewCellDelegate = self;
                mailAddress.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                mailAddress.addEmailAddress.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                mailAddress.titleLabel.text = NSLocalizedString(@"Email address", nil);
                
                if (![self.currentEmailId isEqualToString:@""]|| !([self.currentEmailId length]== 0))
                {
                    mailAddress.titleLabel.text = self.currentEmailId;
//                    if(self.isEmailAddressVerified)
//                        [mailAddress.addEmailAddress setTitle:kEmailAddressStatusVerified forState:UIControlStateNormal];
//                    else
//                        [mailAddress.addEmailAddress setTitle:kEmailAddressStatusUnVerified forState:UIControlStateNormal];

                    [mailAddress.addEmailAddress setTitle:@"" forState:UIControlStateNormal];
                    [mailAddress.editButton setHidden:NO];
                    [mailAddress.addEmailAddress setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 50.0)];
                    [mailAddress.addEmailAddress setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    
                }else{
                    [mailAddress.editButton setHidden:YES];
                    [mailAddress.addEmailAddress setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 20.0)];
                    mailAddress.titleLabel.text = kEmailAddressLabelText;
                    mailAddress.addEmailAddress.titleLabel.text = kEmailAddressStatusAdd;
                }
                
                
            }
            break;
        }
        case eEmailTimeZoneCell: {
            if([cell isKindOfClass:[IVVoiceMailEmailNotificationTableViewCell class]]) {
                
                IVVoiceMailEmailNotificationTableViewCell *mailTimeZone = (IVVoiceMailEmailNotificationTableViewCell*)cell;
                mailTimeZone.emailNotificationTableViewCellDelegate = self;
                mailTimeZone.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                mailTimeZone.emailTimeZone.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                mailTimeZone.emailTimeZone.textAlignment = NSTextAlignmentRight;
                mailTimeZone.titleLabel.text = NSLocalizedString(@"Email Time Zone", nil);
                mailTimeZone.emailTimeZone.text = timeZone;
                mailTimeZone.emailTimeZone.textColor = [UIColor grayColor];
                mailTimeZone.emailTimeZone.userInteractionEnabled = YES;
                UITapGestureRecognizer *emailTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnTimeZone:)];
                [mailTimeZone.emailTimeZone addGestureRecognizer:emailTap];
                
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Profile Delegate Methods -
-(void)fetchProfileCompletedWith:(UserProfileModel*)modelData {
    [self refreshUIWithLatestProfileData];
    dispatch_async(dispatch_get_main_queue()
                   , ^{
                       [self.voiceMailEmailNotificationTableView reloadData];
                       
                   });
    
}
-(void)updateProfileCompletedWith:(UserProfileModel*)modelData {
    [self refreshUIWithLatestProfileData];
    dispatch_async(dispatch_get_main_queue()
                   , ^{
                       [self.voiceMailEmailNotificationTableView reloadData];
                       
                   });
    
}

- (void)updateVoicemailSubscriptionInUserProfile{
    UserProfileModel *model = [[Profile sharedUserProfile]profileData];
    model.emailForVSMSAndMissedCall = self.currentEmailId;
    model.enableEmailForMissedCall = self.isEmailNotificationActivatedForMissedCall;
    model.enableEmailForVSMS = self.isEmailNotificationActivatedForVoiceMail;
    model.emailVerifiedForVSMSAndMissedCall = self.isEmailAddressVerified;
    
    if(timeZone == nil || [timeZone length]==0){
        EnLogd(@"Time zone is nil");
        timeZone = @"";
    }
    
    model.emailTimeZone = timeZone;
    
    NSMutableDictionary *userDic = [[NSMutableDictionary alloc]init];
    [userDic setValue:[NSNumber numberWithBool:self.isEmailNotificationActivatedForVoiceMail] forKey:@"vsms_enabled"];
    [userDic setValue:[NSNumber numberWithBool:self.isEmailNotificationActivatedForMissedCall] forKey:@"mc_enabled"];
    [userDic setValue:self.currentEmailId forKey:@"email"];
    [userDic setValue:timeZone forKey:@"time_zone"];
    
    UpdateUserProfileAPI *api = [[UpdateUserProfileAPI alloc]initWithRequest:userDic];
    [self showLoadingIndicator];
    [api updateVoicemailSubscription:userDic withSuccess:^(UpdateUserProfileAPI *req,BOOL responseObject){
        //Profile update successful
        [self hideLoadingIndicator];
        [[Profile sharedUserProfile]writeProfileDataInFile];
        //TODO: Reverify the logic.
        //Update UI
        [self refreshUIWithLatestData];
        //[self reloadData];
        
        dispatch_async(dispatch_get_main_queue()
                       , ^{
                           [self.voiceMailEmailNotificationTableView reloadData];
                           
                       });
        
        
        
    } failure:^(UpdateUserProfileAPI *req,NSError *error){
        [self hideLoadingIndicator];
    }];
    
}

- (void)showLoadingIndicator {
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
}

- (void)hideLoadingIndicator {
    self.loadingIndicator.hidden = YES;
    [self.loadingIndicator stopAnimating];
    
}

- (void)checkForVoicemailAdditionalNumbers
{
    //Refresh UI
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
                    self.voiceMailInfo = voiceMailInfo;
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
                    self.voiceMailInfo = voiceMailInfo;
            }
            self.additionalNumbers = additionalNumberList;
        }
    }
}

#pragma mark - Settings Protocol Methods -
- (void)fetchSettingCompletedWith:(SettingModel*)modelData withFetchStatus:(BOOL)withFetchStatus {
    [self hideLoadingIndicator];
    
    if (withFetchStatus) {
        [self refreshUIWithLatestData];
    }
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
                self.voiceMailInfo = voiceMailInfo;
        }
    }
    
    if (self.additionalNumbers && [self.additionalNumbers count]) {
        self.additionalNumbers = [NSMutableArray arrayWithArray:[self.additionalNumbers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    
    
    if ((self.additionalNumbers && [self.additionalNumbers count]) && (self.additionalNumbersVoiceMailInfo && [self.additionalNumbersVoiceMailInfo count])) {
        
        if (self.additionalNumbers.count > 3) {
            //We have additional numbers - so redirect it to listing page.
            if (![self.navigationController.topViewController isKindOfClass:[IVVoiceMailListViewController class]]) {
                UIStoryboard *voiceMailSettingsStorybaord = [UIStoryboard storyboardWithName:@"IVVoiceMailMissedCallSettingsStoryBoard" bundle:[NSBundle mainBundle]];
                IVVoiceMailListViewController *voiceListViewController = [voiceMailSettingsStorybaord instantiateViewControllerWithIdentifier:@"IVVoiceMailListView"];
                //We have additional numbers - we need to show the voicemail list viewcontroller.
                voiceListViewController.primaryNumberVoiceMailInfo = self.voiceMailInfo;
                voiceListViewController.primaryNumber = self.primaryNumber;
                //NOV 24, 2016 voiceListViewController.additionalNumberVoiceMailInfo = self.additionalNumbersVoiceMailInfo;
                voiceListViewController.additionalNumbersVoiceMailInfo = self.additionalNumbersVoiceMailInfo;
                voiceListViewController.additionalNumbers = self.additionalNumbers;
                voiceListViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:voiceListViewController animated:NO];
            }
        }else{
         
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
    else{
        
        IVPrimaryNumberVoiceMailViewController *primaryNumberVoiceMailView = [[UIStoryboard storyboardWithName:@"IVVoiceMailMissedCallSettingsStoryBoard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"IVPrimaryNumberVoiceMail"];
        primaryNumberVoiceMailView.voiceMailInfo = self.voiceMailInfo;
        [self.navigationController pushViewController:primaryNumberVoiceMailView animated:YES];
    }
    
}

- (void)didChangedNotificationSwitchValue:(BOOL)withStatus withSwitchTag:(NSInteger)withTag {

    if (self.currentEmailId && [self.currentEmailId length] > 0) {
        if (!self.isEmailAddressVerified) {
            [ScreenUtility showAlert:@"You need to verify email Id"];
            [self.voiceMailEmailNotificationTableView reloadData];
            return;
        }
    }
    else{
        //[ScreenUtility showAlert:@"You need to add an email Id first"];
        UIAlertController *addEmail = [UIAlertController alertControllerWithTitle:@"You need to add an email Id first" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        
        [addEmail addAction:ok];
        addEmail.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
        [self.navigationController presentViewController:addEmail animated:YES completion:nil];
        [self.voiceMailEmailNotificationTableView reloadData];
        return;
    }
    
    if ([Common isNetworkAvailable]) {
        
        BOOL isCarrierSelected = NO;
        BOOL isCountryVoicemailSupport = NO;
        BOOL isVoicemailEnabled = NO;
        NSMutableArray *allNumbers = [NSMutableArray arrayWithArray:self.additionalNumbers];
        [allNumbers addObject:self.primaryNumber];
        
        NSMutableArray *allVoiceMailInfo = [NSMutableArray arrayWithArray:self.additionalNumbersVoiceMailInfo];
        [allVoiceMailInfo addObject:self.voiceMailInfo];
        
        for (NSString *number in allNumbers) {
            CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:number];
            if(carrierDetails){
                isCarrierSelected = YES;
                for (int i = 0; i<allVoiceMailInfo.count; i++) {
                    if ([[[allVoiceMailInfo objectAtIndex:i] valueForKey:@"phoneNumber"] isEqualToString:number]) {
                        
                        if ([[Setting sharedSetting]hasSupportedCustomCarrierInfo:number]) {
                            IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:number];
                            if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                                isCountryVoicemailSupport = YES;
                            }
                        }
                        
                        if([[[allVoiceMailInfo objectAtIndex:i] valueForKey:@"isVoiceMailEnabled"] boolValue])
                            isVoicemailEnabled = YES;
                    }
                }
            }else{
                for (int i = 0; i<allVoiceMailInfo.count; i++) {
                    if ([[[allVoiceMailInfo objectAtIndex:i] valueForKey:@"phoneNumber"] isEqualToString:number]) {
                        if([[[allVoiceMailInfo objectAtIndex:i] valueForKey:@"countryVoicemailSupport"] boolValue])
                            isCountryVoicemailSupport = YES;
                    }
                }
            }
        }
        
#ifndef REACHME_APP
        
        if (!isCountryVoicemailSupport) {
            UIAlertController *checkVoicemail = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Activate InstaVoice", nil) message:NSLocalizedString(@"Sorry, InstaVoice Voicemail & Missed Call service is not available for the selected carrier.", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [checkVoicemail addAction:confirmAction];
            [self presentViewController:checkVoicemail animated:YES completion:nil];
            [self.voiceMailEmailNotificationTableView reloadData];
            return;
            
        }
        
        if (isCarrierSelected) {
            if (!isCountryVoicemailSupport) {
                UIAlertController *checkVoicemail = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Activate InstaVoice", nil) message:NSLocalizedString(@"Sorry, InstaVoice Voicemail & Missed Call service is not available for the selected carrier.", nil) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [checkVoicemail addAction:confirmAction];
                [self presentViewController:checkVoicemail animated:YES completion:nil];
                [self.voiceMailEmailNotificationTableView reloadData];
                return;
                
            }else if(!isVoicemailEnabled){
                UIAlertController *checkVoicemail = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Activate InstaVoice", nil) message:NSLocalizedString(@"Kindly activate InstaVoice Voicemail & Missed call to start receiving email notifications.", nil) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Activate" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self redirectVoiceMailAndSettingsScreens];
                }];
                [checkVoicemail addAction:confirmAction];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                [checkVoicemail addAction:cancelAction];
                [self presentViewController:checkVoicemail animated:YES completion:nil];
                [self.voiceMailEmailNotificationTableView reloadData];
                return;
            }
            
        }else{
            UIAlertController *checkVoicemail = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Activate InstaVoice", nil) message:NSLocalizedString(@"Kindly activate InstaVoice Voicemail & Missed call to start receiving email notifications.", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Activate" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self redirectVoiceMailAndSettingsScreens];
            }];
            [checkVoicemail addAction:confirmAction];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [checkVoicemail addAction:cancelAction];
            [self presentViewController:checkVoicemail animated:YES completion:nil];
            [self.voiceMailEmailNotificationTableView reloadData];
            return;
            
        }
        
#endif
        
        if (self.currentEmailId && [self.currentEmailId length] > 0) {
            if (self.isEmailAddressVerified) {
                if (kVoiceMailEmailNotificationSwitchTag == withTag)
                    self.isEmailNotificationActivatedForVoiceMail = withStatus;
                
                else if (kMissedCallEmailNotificationSwitchTag == withTag)
                    self.isEmailNotificationActivatedForMissedCall = withStatus;
                
                //Update the information to server.
                [self updateVoicemailSubscriptionInUserProfile];
            }else{
                [ScreenUtility showAlert:@"You need to verify email Id"];
            }
            
        }
        else{
            UIAlertController *addEmail = [UIAlertController alertControllerWithTitle:@"You need to add an email Id first" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            
            [addEmail addAction:ok];
            addEmail.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
            [self.navigationController presentViewController:addEmail animated:YES completion:nil];
        }
        
        //Reload the cells with latest values.
        dispatch_async(dispatch_get_main_queue()
                       , ^{
                           [self.voiceMailEmailNotificationTableView reloadData];
                           
                       });
        
    }
    else {
        //Reload the cells with latest values.
        dispatch_async(dispatch_get_main_queue()
                       , ^{
                           [self refreshUIWithLatestProfileData];
                           [self.voiceMailEmailNotificationTableView reloadData];
                           
                       });
        
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE",nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    
}

- (void)refreshUIWithLatestData {
    
    //Get the settings information.
    [Setting sharedSetting].delegate = self;
    [self refreshUIWithLatestProfileData];
}

- (void)refreshUIWithLatestProfileData {
    
    //Prifile data
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    self.isEmailNotificationActivatedForMissedCall = currentUserProfileDetails.enableEmailForMissedCall;
    self.isEmailNotificationActivatedForVoiceMail  = currentUserProfileDetails.enableEmailForVSMS;
    self.isEmailAddressVerified = currentUserProfileDetails.emailVerifiedForVSMSAndMissedCall;
    if (!self.isEmailAddressVerified) {
        self.isEmailNotificationActivatedForMissedCall = NO;
        self.isEmailNotificationActivatedForVoiceMail  = NO;
    }
    self.currentEmailId = currentUserProfileDetails.emailForVSMSAndMissedCall;
    if ((currentUserProfileDetails.emailTimeZone == nil) || ![currentUserProfileDetails.emailTimeZone length]) {
        timeZone = [[NSTimeZone defaultTimeZone] name];
    }else{
        timeZone = currentUserProfileDetails.emailTimeZone;
    }
    
}

- (void)didTapOnEditMailButton {
    
    if (NETWORK_NOT_AVAILABLE == [Common isNetworkAvailable]) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    UIAlertController *editEmailOrAdd = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Email address", nil) message:NSLocalizedString(@"Please enter an Email address where you want to receive notifications", nil) preferredStyle:UIAlertControllerStyleAlert];
    [editEmailOrAdd addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.currentEmailId;
        textField.placeholder = @"Write your email address";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.currentEmailId isEqualToString:[[editEmailOrAdd textFields][0] text]]) {
            
        }else if (![[[editEmailOrAdd textFields][0] text] length]){
            [ScreenUtility showAlert:@"Empty Email Id is not allowed"];
            [self presentViewController:editEmailOrAdd animated:YES completion:nil];
        }else if (![Common isValidEmail:[[editEmailOrAdd textFields][0] text]]){
            [ScreenUtility showAlert:@"Please enter valid Email Id"];
            [self presentViewController:editEmailOrAdd animated:YES completion:nil];
        }else{
            self.currentEmailId = [[editEmailOrAdd textFields][0] text];
            //Email Address is not verified.
            //self.isEmailAddressVerified = NO;
            [self updateVoicemailSubscriptionInUserProfile];
            [[editEmailOrAdd textFields][0] resignFirstResponder];
        }
        
    }];
    [editEmailOrAdd addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [editEmailOrAdd addAction:cancelAction];
    editEmailOrAdd.view.tintColor = [UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0];
    [self presentViewController:editEmailOrAdd animated:YES completion:nil];
    
}

- (void)didTapOnTimeZone:(UITapGestureRecognizer *)recognizer
{
    TimeZoneViewController *timeZoneVC = [[TimeZoneViewController alloc]initWithNibName:@"TimeZoneViewController" bundle:nil];
    [self.navigationController pushViewController:timeZoneVC animated:YES];
}

/*
- (void)applicationWillEnterForeground:(NSNotification *)notification {
    NSTimeZone *timeZoneLocal = [NSTimeZone defaultTimeZone];
    NSString *strTimeZoneName = [timeZoneLocal name];
    timeZone = strTimeZoneName;
    UserProfileModel *model = [[Profile sharedUserProfile]profileData];
    model.emailTimeZone = timeZone;
    [self.voiceMailEmailNotificationTableView reloadData];
}
 */

#pragma mark - Memory CleanUp Methods -
- (void)dealloc {
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    self.voiceMailEmailNotificationTableView = nil;
    self.currentEmailId = nil;
    self.currentNetworkName= nil;
    self.helpText = nil;
    self.activationDialNumber = nil;
    self.helpTextArray = nil;
    self.supportContactList = nil;
    self.isEmailNotificationActivatedForVoiceMail = NO;
    self.isEmailNotificationActivatedForMissedCall = NO;
    self.isEmailAddressVerified = NO;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
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
