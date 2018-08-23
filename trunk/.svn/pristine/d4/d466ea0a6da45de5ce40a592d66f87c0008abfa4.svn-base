//
//  ReachMeActivatedViewController.m
//  InstaVoice
//
//  Created by Bhaskar Munireddy on 24/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "ReachMeActivatedViewController.h"
#import "ReachMeActivatedTableViewCell.h"
#import "UserProfileModel.h"
#import "Profile.h"
#import "IVFileLocator.h"
#import "ContactDetailData.h"
#import "BaseConversationScreen.h"
#import "Contacts.h"
#import "InsideConversationScreen.h"
#import "ManageUserContactAPI.h"
#import "ReachMeActivationViewController.h"
#import "PersonalisationViewController.h"
#import "ActivateReachMeViewController.h"
#import "VoiceMailHLRAPI.h"

#define kReachMeInfoCellIdentifier @"ReachMeInfoCell"
#define kSwitchToReachMeModeCellIdentifier @"SwitchToReachMeModeCell"

@interface ReachMeActivatedViewController ()<SettingProtocol>{
    BOOL isSwitch, isActivateAgain;
}
@property (weak, nonatomic) IBOutlet UITableView *reachMeActivationTable;
@property (nonatomic, strong) NSMutableArray *supportContactList;
@property (nonatomic, strong) NSString *helpText, *titleName, *carrierName;
@property (nonatomic, strong) NSString *activationDialNumber;
@property (nonatomic, strong) NSString *deactivateDialNumber;
@property (nonatomic, strong) NSMutableArray *helpTextArray;

@end

@implementation ReachMeActivatedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
        self.title = NSLocalizedString(@"ReachMe International", nil);
    else if ([self.reachMeType isEqualToString:REACHME_HOME])
        self.title = NSLocalizedString(@"ReachMe Home", nil);
    else
        self.title = NSLocalizedString(@"ReachMe VoiceMail", nil);
    
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpAction)];
    self.navigationItem.rightBarButtonItem = helpButton;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Setting sharedSetting].delegate = self;
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

- (void)helpAction
{
    //    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    //
    //    if (self.voiceMailInfo.countryVoicemailSupport && !self.voiceMailInfo.isVoiceMailEnabled && self.isCarrierSupportedForVoiceMailSetup) {
    //        self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList], self.activationDialNumber];
    //    }else if (!self.isValidCarrierName || !self.voiceMailInfo.countryVoicemailSupport) {
    //        self.helpText = kCarrierNotSupporttedHelpText;
    //    }else if (self.voiceMailInfo.isVoiceMailEnabled) {
    //        if ([self numberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && carrierDetails) {
    //            self.helpText = @"";
    //        }else if (self.voiceMailInfo.countryVoicemailSupport && self.isCarrierSupportedForVoiceMailSetup){
    //            self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList], self.activationDialNumber];
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

#pragma TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus])
        return  1;
    else
        return  2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *infoString = @"You must be connected to data to receive calls in the app. Your carrier may charge for local airtime at local calling tariff (part of minute bundles) for ReachMe calls.";
        
        UITextView *msgLabel = [[UITextView alloc] init];
        msgLabel.text = infoString;
        msgLabel.font = [UIFont systemFontOfSize:14.0];
        [msgLabel sizeToFit];
        CGSize lableWidth = CGSizeMake(DEVICE_WIDTH - 90.0, CGFLOAT_MAX);
        CGSize neededSize = [msgLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
        if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus])
            return neededSize.height + 210.0;
        else
            return neededSize.height + 130.0;
    }
    return 375.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *cellIdentifier;
    if (indexPath.section == 0) {
        cellIdentifier = kReachMeInfoCellIdentifier;
    }else if (indexPath.section == 1){
        cellIdentifier = kSwitchToReachMeModeCellIdentifier;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([cell isKindOfClass:[ReachMeActivatedTableViewCell class]]) {
        ReachMeActivatedTableViewCell *activateReachMeCell = (ReachMeActivatedTableViewCell *)cell;
        
        if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            activateReachMeCell.reachMeTypeLabel.text = @"You are getting all calls in the app at zero roaming charges";
        else if ([self.reachMeType isEqualToString:REACHME_HOME])
            activateReachMeCell.reachMeTypeLabel.text = @"You are getting call in the app if number is unreachable.";
        else
            activateReachMeCell.reachMeTypeLabel.text = @"You are getting all calls in the app at zero roaming charges";
        
        activateReachMeCell.reachMeInfoLabel.textContainerInset = UIEdgeInsetsZero;
        
        if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL]){
            activateReachMeCell.switchToModeWidthConstraint.constant = 210.0;
            [activateReachMeCell.switchToModeButton setTitle:@"SWITCH TO REACHME HOME" forState:UIControlStateNormal];
        }else if ([self.reachMeType isEqualToString:REACHME_HOME]){
            activateReachMeCell.switchToModeWidthConstraint.constant = 290.0;
            [activateReachMeCell.switchToModeButton setTitle:@"SWITCH TO REACHME INTERNATIONAL" forState:UIControlStateNormal];
        }
        
        activateReachMeCell.activateAgainButton.layer.cornerRadius = 2.0;
        activateReachMeCell.activateAgainButton.layer.borderWidth = 2.0;
        activateReachMeCell.activateAgainButton.layer.borderColor = [[UIColor clearColor] CGColor];
        activateReachMeCell.activateAgainButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        activateReachMeCell.activateAgainButton.layer.shadowOpacity = 1.0f;
        activateReachMeCell.activateAgainButton.layer.shadowRadius = 1.0f;
        activateReachMeCell.activateAgainButton.layer.shadowOffset = CGSizeMake(0, 1);
        
        activateReachMeCell.switchToModeButton.layer.cornerRadius = 2.0;
        activateReachMeCell.switchToModeButton.layer.borderWidth = 2.0;
        activateReachMeCell.switchToModeButton.layer.borderColor = [[UIColor clearColor] CGColor];
        activateReachMeCell.switchToModeButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        activateReachMeCell.switchToModeButton.layer.shadowOpacity = 1.0f;
        activateReachMeCell.switchToModeButton.layer.shadowRadius = 1.0f;
        activateReachMeCell.switchToModeButton.layer.shadowOffset = CGSizeMake(0, 1);
        
        NSString *countryName = @"";
        if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL]){
            activateReachMeCell.satisfiedLabel.text = @"Not satisfied with ReachMe International Service?";
            activateReachMeCell.countryFlag.layer.cornerRadius = activateReachMeCell.countryFlag.frame.size.height/2;
            activateReachMeCell.countryFlag.image = [UIImage imageNamed:[self getFlagFromCountryName:[self getCountryCode:self.phoneNumber]]];
            countryName = [NSString stringWithFormat:@"Back to %@?",[self getFlagFromCountryName:[self getCountryCode:self.phoneNumber]]];
            activateReachMeCell.backToCountryLabel.text = countryName;
        }else if ([self.reachMeType isEqualToString:REACHME_HOME]){
            activateReachMeCell.satisfiedLabel.text = @"Not satisfied with ReachMe Home Service?";
            activateReachMeCell.countryFlag.layer.cornerRadius = 1.0;
            activateReachMeCell.countryFlag.image = [UIImage imageNamed:@"rm_international"];
            countryName = [NSString stringWithFormat:@"Planning to Travel outside of %@?",[self getFlagFromCountryName:[self getCountryCode:self.phoneNumber]]];
            activateReachMeCell.backToCountryLabel.text = countryName;
        }else{
            activateReachMeCell.satisfiedLabel.text = @"Not satisfied with ReachMe Voicemail Service?";
        }
        
        [activateReachMeCell.activateAgainButton addTarget:self action:@selector(activateAgain:) forControlEvents:UIControlEventTouchUpInside];
        [activateReachMeCell.switchToModeButton addTarget:self action:@selector(switchToReachMeMode:) forControlEvents:UIControlEventTouchUpInside];
        [activateReachMeCell.deActivateReachMe addTarget:self action:@selector(deActivateReachMe:) forControlEvents:UIControlEventTouchUpInside];
        [activateReachMeCell.contactSupport addTarget:self action:@selector(contactSupport:) forControlEvents:UIControlEventTouchUpInside];
        
        activateReachMeCell.finishSetup.layer.cornerRadius = 22.0;
        activateReachMeCell.finishSetup.layer.borderWidth = 2.0;
        activateReachMeCell.finishSetup.layer.borderColor = [[UIColor clearColor] CGColor];
        activateReachMeCell.finishSetup.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        activateReachMeCell.finishSetup.layer.shadowOpacity = 1.0f;
        activateReachMeCell.finishSetup.layer.shadowRadius = 1.0f;
        activateReachMeCell.finishSetup.layer.shadowOffset = CGSizeMake(0, 1);
        
        [activateReachMeCell.finishSetup addTarget:self action:@selector(finishSetupToPersonalisation:) forControlEvents:UIControlEventTouchUpInside];
        
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

- (IBAction)activateAgain:(id)sender
{
    isActivateAgain = YES;
    isSwitch = NO;
    IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
    
    if (ccInfo.ussdInfo.isHLREnabled){
        if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
            [self showProgressBar];
            [NSTimer scheduledTimerWithTimeInterval:3.0
                                             target:self
                                           selector:@selector(activationTimeLapsed:)
                                           userInfo:nil
                                            repeats:NO];
            
            NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
            [requestDic setValue:self.phoneNumber forKey:@"phone_num"];
            [requestDic setValue:@"enable" forKey:@"action"];
            
            if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL]) {
                [requestDic setValue:@"I" forKey:@"mode"];
            }else if ([self.reachMeType isEqualToString:REACHME_HOME]){
                [requestDic setValue:@"H" forKey:@"mode"];
            }
            
            VoiceMailHLRAPI* api = [[VoiceMailHLRAPI alloc]initWithRequest:requestDic];
            [api callNetworkRequest:requestDic withSuccess:^(VoiceMailHLRAPI *req, NSMutableDictionary *responseObject) {
                if ([[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
                    [self updateCarrierSettingsOnHLRSuccess];
                }
            }failure:^(VoiceMailHLRAPI *req, NSError *error) {
                [self hideProgressBar];
//                ReachMeActivationViewController *reachMeActivate = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ReachMeActivation"];
//                reachMeActivate.phoneNumber = self.phoneNumber;
//                reachMeActivate.voiceMailInfo = self.voiceMailInfo;
//                reachMeActivate.reachMeType = self.reachMeType;
//                reachMeActivate.isActivationProcess = YES;
//                reachMeActivate.isSwitchProcess = NO;
//                [self.navigationController pushViewController:reachMeActivate animated:YES];
                [ScreenUtility showAlert:@"Oops!  Something went wrong. Please, check carrier & reactivate OR tap on ‘Help’ to get assistance."];
                EnLogd(@"*** Error in activation of HLR: %@, %@",req,[error description]);
                KLog(@"*** Error in activation of HLR: %@, %@",req,[error description]);
                
            }];
            
        }else{
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        }
        
    }else{
        ReachMeActivationViewController *reachMeActivate = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ReachMeActivation"];
        reachMeActivate.phoneNumber = self.phoneNumber;
        reachMeActivate.voiceMailInfo = self.voiceMailInfo;
        reachMeActivate.reachMeType = self.reachMeType;
        reachMeActivate.isActivationProcess = YES;
        reachMeActivate.isSwitchProcess = NO;
        [self.navigationController pushViewController:reachMeActivate animated:YES];
    }
}

- (IBAction)switchToReachMeMode:(id)sender
{
    isSwitch = YES;
    isActivateAgain = NO;
    IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
    
    if (ccInfo.ussdInfo.isHLREnabled){
        if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
            [self showProgressBar];
            [NSTimer scheduledTimerWithTimeInterval:3.0
                                             target:self
                                           selector:@selector(activationTimeLapsed:)
                                           userInfo:nil
                                            repeats:NO];
            
            NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
            [requestDic setValue:self.phoneNumber forKey:@"phone_num"];
            [requestDic setValue:@"switch" forKey:@"action"];
            CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
            if (carrierDetails) {
                if (carrierDetails.isReachMeIntlActive){
                    [requestDic setValue:@"H" forKey:@"mode"];
                }else if (carrierDetails.isReachMeHomeActive){
                    [requestDic setValue:@"I" forKey:@"mode"];
                }
            }
            
            VoiceMailHLRAPI* api = [[VoiceMailHLRAPI alloc]initWithRequest:requestDic];
            [api callNetworkRequest:requestDic withSuccess:^(VoiceMailHLRAPI *req, NSMutableDictionary *responseObject) {
                if ([[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
                    [self updateCarrierSettingsOnHLRSuccess];
                }
            }failure:^(VoiceMailHLRAPI *req, NSError *error) {
                [self hideProgressBar];
//                ReachMeActivationViewController *reachMeActivate = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ReachMeActivation"];
//                reachMeActivate.phoneNumber = self.phoneNumber;
//                reachMeActivate.voiceMailInfo = self.voiceMailInfo;
//                reachMeActivate.isActivationProcess = YES;
//                reachMeActivate.isSwitchProcess = YES;
//                if ([self.reachMeType isEqualToString:REACHME_HOME]){
//                    reachMeActivate.isSwitchToInternational = YES;
//                    reachMeActivate.reachMeType = REACHME_INTERNATIONAL;
//                }else{
//                    reachMeActivate.isSwitchToInternational = NO;
//                    reachMeActivate.reachMeType = REACHME_HOME;
//                }
//
//                [self.navigationController pushViewController:reachMeActivate animated:YES];
                [ScreenUtility showAlert:@"Oops!  Something went wrong. Please, check carrier & reactivate OR tap on ‘Help’ to get assistance."];
                EnLogd(@"*** Error in activation of HLR: %@, %@",req,[error description]);
                KLog(@"*** Error in activation of HLR: %@, %@",req,[error description]);
                
            }];
            
        }else{
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        }
        
    }else{
        ReachMeActivationViewController *reachMeActivate = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ReachMeActivation"];
        reachMeActivate.phoneNumber = self.phoneNumber;
        reachMeActivate.voiceMailInfo = self.voiceMailInfo;
        reachMeActivate.isActivationProcess = YES;
        reachMeActivate.isSwitchProcess = YES;
        if ([self.reachMeType isEqualToString:REACHME_HOME]){
            reachMeActivate.isSwitchToInternational = YES;
            reachMeActivate.reachMeType = REACHME_INTERNATIONAL;
        }else{
            reachMeActivate.isSwitchToInternational = NO;
            reachMeActivate.reachMeType = REACHME_HOME;
        }
        
        [self.navigationController pushViewController:reachMeActivate animated:YES];
    }
}

- (IBAction)deActivateReachMe:(id)sender
{
    isSwitch = NO;
    isActivateAgain = NO;
    IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
    
    if (ccInfo.ussdInfo.isHLREnabled){
        if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
            [self showProgressBar];
            [NSTimer scheduledTimerWithTimeInterval:3.0
                                             target:self
                                           selector:@selector(activationTimeLapsed:)
                                           userInfo:nil
                                            repeats:NO];
            
            NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
            [requestDic setValue:self.phoneNumber forKey:@"phone_num"];
            [requestDic setValue:@"disable" forKey:@"action"];
            
            CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
            if (carrierDetails) {
                if (carrierDetails.isReachMeIntlActive){
                    [requestDic setValue:@"I" forKey:@"mode"];
                }else if (carrierDetails.isReachMeHomeActive){
                    [requestDic setValue:@"H" forKey:@"mode"];
                }
            }
            
            VoiceMailHLRAPI* api = [[VoiceMailHLRAPI alloc]initWithRequest:requestDic];
            [api callNetworkRequest:requestDic withSuccess:^(VoiceMailHLRAPI *req, NSMutableDictionary *responseObject) {
                if ([[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
                    [self updateCarrierSettingsOnHLRSuccess];
                }
            }failure:^(VoiceMailHLRAPI *req, NSError *error) {
                [self hideProgressBar];
//                ReachMeActivationViewController *reachMeActivate = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ReachMeActivation"];
//                reachMeActivate.phoneNumber = self.phoneNumber;
//                reachMeActivate.voiceMailInfo = self.voiceMailInfo;
//                reachMeActivate.reachMeType = self.reachMeType;
//                reachMeActivate.isActivationProcess = NO;
//                reachMeActivate.isSwitchProcess = NO;
//                [self.navigationController pushViewController:reachMeActivate animated:YES];
                [ScreenUtility showAlert:@"Oops!  Something went wrong. Please, check carrier & deactivate OR tap on ‘Help’ to get assistance."];
                EnLogd(@"*** Error in activation of HLR: %@, %@",req,[error description]);
                KLog(@"*** Error in activation of HLR: %@, %@",req,[error description]);
                
            }];
            
        }else{
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        }
        
    }else{
        ReachMeActivationViewController *reachMeActivate = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ReachMeActivation"];
        reachMeActivate.phoneNumber = self.phoneNumber;
        reachMeActivate.voiceMailInfo = self.voiceMailInfo;
        reachMeActivate.reachMeType = self.reachMeType;
        reachMeActivate.isActivationProcess = NO;
        reachMeActivate.isSwitchProcess = NO;
        [self.navigationController pushViewController:reachMeActivate animated:YES];
    }
}

- (void)updateCarrierSettingsOnHLRSuccess
{
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    
    CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
    currentCarrierInfo.phoneNumber = self.phoneNumber;
    if(carrierDetails) {
        currentCarrierInfo.countryCode = carrierDetails.countryCode;
        currentCarrierInfo.networkId = carrierDetails.networkId;
        currentCarrierInfo.vSMSId = carrierDetails.vSMSId;
        if (isSwitch) {
            if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL]){
                currentCarrierInfo.isReachMeIntlActive = NO;
                currentCarrierInfo.isReachMeHomeActive = YES;
                currentCarrierInfo.isReachMeVMActive = NO;
            }else if ([self.reachMeType isEqualToString:REACHME_HOME]){
                currentCarrierInfo.isReachMeIntlActive = YES;
                currentCarrierInfo.isReachMeHomeActive = NO;
                currentCarrierInfo.isReachMeVMActive = NO;
            }else{
                currentCarrierInfo.isReachMeIntlActive = NO;
                currentCarrierInfo.isReachMeHomeActive = NO;
                currentCarrierInfo.isReachMeVMActive = YES;
            }
        }else if (isActivateAgain) {
            if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL]){
                currentCarrierInfo.isReachMeIntlActive = YES;
                currentCarrierInfo.isReachMeHomeActive = NO;
                currentCarrierInfo.isReachMeVMActive = NO;
            }else if ([self.reachMeType isEqualToString:REACHME_HOME]){
                currentCarrierInfo.isReachMeIntlActive = NO;
                currentCarrierInfo.isReachMeHomeActive = YES;
                currentCarrierInfo.isReachMeVMActive = NO;
            }else{
                currentCarrierInfo.isReachMeIntlActive = NO;
                currentCarrierInfo.isReachMeHomeActive = NO;
                currentCarrierInfo.isReachMeVMActive = YES;
            }
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
    [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
}

-(void)updateSettingCompletedWith:(SettingModel*)modelData withUpdateStatus:(BOOL)withUpdateStatus
{
    if (!withUpdateStatus) {
        [[ConfigurationReader sharedConfgReaderObj] setCarrierInfoUpdateStatus:YES];
    }
    [self hideProgressBar];
    
    NSString *message = @"\nReachMe is activated for your number. you can test the service by dialing this number from any other phone and you will get a ReachMe call on the app.\n";
    
    if (isSwitch || isActivateAgain) {
        
        if (isSwitch) {
            if([self.reachMeType isEqualToString:REACHME_HOME])
                message = @"\nReachMe International is activated for your number. you can test the service by dialing this number from any other phone and you will get a ReachMe call on the app.\n";
            else
                message = @"\nReachMe Home is activated for your number.You can test the service by putting your phone on flight mode and dialing it from any other phone. You will get a ReachMe Call on the app\n";
        }else if (isActivateAgain){
            if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
                message = @"\nReachMe International is activated for your number. you can test the service by dialing this number from any other phone and you will get a ReachMe call on the app.\n";
            else
                message = @"\nReachMe Home is activated for your number.You can test the service by putting your phone on flight mode and dialing it from any other phone. You will get a ReachMe Call on the app\n";
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Congratulations" message:message preferredStyle:UIAlertControllerStyleAlert];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:message];
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:13.0]
                        range:NSMakeRange(0, attrStr.length)];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor colorWithRed:3.0/255.0 green:3.0/255.0 blue:3.0/255.0 alpha:1.0]
                        range:NSMakeRange(0, attrStr.length)];
        [alertController setValue:attrStr forKey:@"attributedMessage"];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController *aViewController in allViewControllers) {
                if ([aViewController isKindOfClass:[ActivateReachMeViewController class]]) {
                    [self.navigationController popToViewController:aViewController animated:YES];
                    if (isSwitch) {
                        [self fireLocalNotification];
                    }
                }
            }
        }];
        
        [alertController addAction:ok];
        
        alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [self.navigationController presentViewController:alertController animated:true completion:nil];
        
    }else{
        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        for (UIViewController *aViewController in allViewControllers) {
            if ([aViewController isKindOfClass:[ActivateReachMeViewController class]]) {
                [self.navigationController popToViewController:aViewController animated:YES];
            }
        }
    }
    
}

- (void)fireLocalNotification
{
    NSString *notificationInfo = @"";
    if (isSwitch) {
        if ([self.reachMeType isEqualToString:REACHME_HOME]) {
            notificationInfo = [NSString stringWithFormat:@"ReachMe International is active on %@",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        }else{
            notificationInfo = [NSString stringWithFormat:@"ReachMe Home is active on %@",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        }
    }else if (isActivateAgain){
        if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL]) {
            notificationInfo = [NSString stringWithFormat:@"ReachMe International is active on %@",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        }else{
            notificationInfo = [NSString stringWithFormat:@"ReachMe Home is active on %@",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        }
    }

    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"ACTIVATION SUCCESSFULL" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:notificationInfo
                                                         arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"rm_switch",@"notification_type", nil];
    content.userInfo = userInfo;
    
    // Deliver the notification in two seconds.
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:2 repeats:NO];
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"TwoSecond"
                                                                          content:content trigger:trigger];
    
    // Schedule the notification.
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:nil];
}

- (void)activationTimeLapsed:(NSTimer *)timer{
    
}

- (IBAction)contactSupport:(id)sender
{
    [self helpAction];
}

- (IBAction)finishSetupToPersonalisation:(id)sender
{
    PersonalisationViewController *personalisation = [[PersonalisationViewController alloc]initWithNibName:@"PersonalisationViewController" bundle:nil];
    [self.navigationController pushViewController:personalisation animated:YES];
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
