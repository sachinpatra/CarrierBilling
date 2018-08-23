//
//  ReachMeActivationViewController.m
//  InstaVoice
//
//  Created by Bhaskar Munireddy on 23/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "ReachMeActivationViewController.h"
#import "ReachMeActivationTableViewCell.h"
#import "UserProfileModel.h"
#import "Profile.h"
#import "IVFileLocator.h"
#import "ContactDetailData.h"
#import "BaseConversationScreen.h"
#import "Contacts.h"
#import "InsideConversationScreen.h"
#import "ManageUserContactAPI.h"
#import "PersonalisationViewController.h"
#import "IVColors.h"
#import "ActivateReachMeViewController.h"

#import <CallKit/CXCallObserver.h>

#define kReachMeDialCodeCellIdentifier @"ReachMeDialCodeCell"
#define kReachMeBundleValueCellIdentifier @"ReachMeBundleValueCell"
#define kReachMeCopyShareInstructionsCellIdentifier @"ReachMeCopyShareInstructionsCell"
#define kReachMeDialCodeCopyShareCellIdentifier @"ReachMeDialCodeCopyShareCell"
#define kReachMeInstructionsCellIdentifier @"ReachMeInstructionsCell"
#define kReachMeFinishSetupCellIdentifier @"FinishSetup"

@interface ReachMeActivationViewController ()<SettingProtocol,UITextViewDelegate,CXCallObserverDelegate>{
    UIAlertController *alertController;
    BOOL isShare;
}
@property (weak, nonatomic) IBOutlet UITableView *reachMeActivationTable;
@property (nonatomic, strong) NSMutableArray *supportContactList;
@property (nonatomic, strong) NSString *helpText, *titleName, *carrierName;
@property (nonatomic, strong) NSString *activationDialNumber;
@property (nonatomic, strong) NSString *deactivateDialNumber;
@property (nonatomic, strong) NSMutableArray *helpTextArray;
@property (nonatomic, strong) NSString *additionalActiInfo;
@property (nonatomic, strong) CXCallObserver* callObserver;
@end

@implementation ReachMeActivationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Setting sharedSetting].delegate = self;
    if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
        self.title = NSLocalizedString(@"ReachMe International", nil);
    else if ([self.reachMeType isEqualToString:REACHME_HOME])
        self.title = NSLocalizedString(@"ReachMe Home", nil);
    else
        self.title = NSLocalizedString(@"ReachMe VoiceMail", nil);
    
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpAction)];
    self.navigationItem.rightBarButtonItem = helpButton;
    
    CXCallObserver *callObserver = [[CXCallObserver alloc] init];
    [callObserver setDelegate:self queue:nil];
    // Don't forget to store reference to callObserver, to prevent it from being released
    self.callObserver = callObserver;
    
    [self performSelector:@selector(showAlertController) withObject:nil afterDelay:20.0];
//    if(self.isActivationProcess)
//        [self performSelector:@selector(showAlertController) withObject:nil afterDelay:20.0];
    // Do any additional setup after loading the view.
}

- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    if (call.hasConnected) {
        [self.navigationController dismissViewControllerAnimated:alertController completion:nil];
    }/*else if (call.hasEnded){
        [self showAlertController];
    }*/
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (void)showAlertController
{
    UIViewController *vc = [self topViewController];
    NSString *vcName = NSStringFromClass(vc.classForCoder);
    
    if(![vcName isEqualToString:@"ReachMeActivationViewController"] && vcName.length)
        return;
    
    NSString *dialCode = @"";
    if (self.isActivationProcess) {
        if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            dialCode = self.voiceMailInfo.actiUNCF;
        else{
            CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
            if (carrierDetails) {
                if (carrierDetails.isReachMeIntlActive)
                    dialCode = self.voiceMailInfo.deactiUNCF;
                else
                    dialCode = self.voiceMailInfo.actiCnf;
            }
        }
    }else{
        if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            dialCode = self.voiceMailInfo.deActiBoth;
        else
            dialCode = self.voiceMailInfo.deActiCnf;
    }
    
    if(!dialCode)
        return;
    
    dialCode = [dialCode stringByReplacingOccurrencesOfString:@";" withString:@"\n"];
    dialCode = [NSString stringWithFormat:@"\n%@",dialCode];
    alertController = [UIAlertController alertControllerWithTitle:@"Did You dial the code below?" message:dialCode preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:dialCode];
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:20.0]
                    range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[IVColors redColor]
                    range:NSMakeRange(0, attrStr.length)];
    [alertController setValue:attrStr forKey:@"attributedMessage"];
    
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self codeDialed];
    }];
    
    [alertController addAction:no];
    [alertController addAction:yes];
    
    alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [self.navigationController presentViewController:alertController animated:true completion:nil];
    
}

- (void)codeDialed
{
    NSString *title = @"";
    NSString *message = @"";
    
    NSString *dialCode = @"";
    if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
        dialCode = self.voiceMailInfo.actiUNCF;
    else{
        CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
        //IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
        //NSString *activeString = [[ConfigurationReader sharedConfgReaderObj] getMissedCallReasonForTheNumber:self.phoneNumber];
        if (carrierDetails) {
            if (carrierDetails.isReachMeIntlActive)
                dialCode = self.voiceMailInfo.deactiUNCF;
            else
                dialCode = self.voiceMailInfo.actiCnf;
        }
    }
    
    if ([dialCode containsString:@"#"]) {
        title = @"Did you see a positive response after dialing?";
        if(self.isActivationProcess)
            message = @"When you dial the code which is a USSD command, your carrier sends a response that pops up after the code is successfully dialed. It usually says “Successful”, “Active”, or “Activated”, indicating that command was successful.";
        else
            message = @"After dialing the deactivation MMI code, did you see a positive confirmation that says “Successful”, “Erasure”, or “DeActivated”? This indicates deactivation is successful";
    }else{
        title = @"Did you hear a positive response after dialing?";
        if(self.isActivationProcess)
            message = @"When you dial the call forwarding number, You will hear a positive confirmation that says “Successful”, “Active”, or “Activated”, indicating that command was successful.";
        else
            message = @"After dialing the deactivation number. Did you hear a positive confirmation that says “Successful”, “Removed”, “DeActivated”? or long tone, indicating that deactivation is successful.";
    }
    
    alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:message];
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:13.0]
                    range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor colorWithRed:3.0/255.0 green:3.0/255.0 blue:3.0/255.0 alpha:1.0]
                    range:NSMakeRange(0, attrStr.length)];
    [alertController setValue:attrStr forKey:@"attributedMessage"];
    
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self failureCase];
    }];
    
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self successFullActivated];
    }];
    
    [alertController addAction:no];
    [alertController addAction:yes];
    
    alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [self.navigationController presentViewController:alertController animated:true completion:nil];
}

- (void)successFullActivated
{
    NSString *reason = @"";
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    
    CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
    currentCarrierInfo.phoneNumber = self.phoneNumber;
    if(carrierDetails) {
        currentCarrierInfo.countryCode = carrierDetails.countryCode;
        currentCarrierInfo.networkId = carrierDetails.networkId;
        currentCarrierInfo.vSMSId = carrierDetails.vSMSId;
        if (self.isActivationProcess) {
            if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL]){
                currentCarrierInfo.isReachMeIntlActive = YES;
                currentCarrierInfo.isReachMeHomeActive = NO;
                currentCarrierInfo.isReachMeVMActive = NO;
                reason = @"unconditional";
                [[ConfigurationReader sharedConfgReaderObj] setActiveForNumber:self.phoneNumber reachMeType:REACHME_INTERNATIONAL];
            }else if ([self.reachMeType isEqualToString:REACHME_HOME]){
                currentCarrierInfo.isReachMeIntlActive = NO;
                currentCarrierInfo.isReachMeHomeActive = YES;
                currentCarrierInfo.isReachMeVMActive = NO;
                reason = @"busy";
                [[ConfigurationReader sharedConfgReaderObj] setActiveForNumber:self.phoneNumber reachMeType:REACHME_HOME];
            }else{
                currentCarrierInfo.isReachMeIntlActive = NO;
                currentCarrierInfo.isReachMeHomeActive = NO;
                currentCarrierInfo.isReachMeVMActive = YES;
                reason = @"busy";
                [[ConfigurationReader sharedConfgReaderObj] setActiveForNumber:self.phoneNumber reachMeType:REACHME_VOICEMAIL];
            }
        }else{
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = NO;
            reason = @"";
            [[ConfigurationReader sharedConfgReaderObj] setActiveForNumber:self.phoneNumber reachMeType:@""];
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
    NSMutableDictionary* mcReasonDic = [[NSMutableDictionary alloc]init];
    [mcReasonDic setValue:reason forKey:self.phoneNumber];
    [[ConfigurationReader sharedConfgReaderObj]setObject:mcReasonDic forTheKey:MISSED_CALL_REASON];
    
}

-(void)updateSettingCompletedWith:(SettingModel*)modelData withUpdateStatus:(BOOL)withUpdateStatus
{
    if (!withUpdateStatus) {
        [[ConfigurationReader sharedConfgReaderObj] setCarrierInfoUpdateStatus:YES];
    }
    [self hideProgressBar];
    
    if (!self.isActivationProcess) {
        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        for (UIViewController *aViewController in allViewControllers) {
            if ([aViewController isKindOfClass:[ActivateReachMeViewController class]]) {
                [self.navigationController popToViewController:aViewController animated:YES];
            }
        }
        return;
    }
    
    NSString *message = @"\nReachMe is activated for your number. you can test the service by dialing this number from any other phone and you will get a ReachMe call on the app.\n";
    
    if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
        message = @"\nReachMe International is activated for your number. you can test the service by dialing this number from any other phone and you will get a ReachMe call on the app.\n";
    else
        message = @"\nReachMe Home is activated for your number.You can test the service by putting your phone on flight mode and dialing it from any other phone. You will get a ReachMe Call on the app\n";
    
    alertController = [UIAlertController alertControllerWithTitle:@"Congratulations" message:message preferredStyle:UIAlertControllerStyleAlert];
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
                if (self.isSwitchProcess) {
                    [self fireLocalNotification];
                }
            }
        }
    }];
    
    [alertController addAction:ok];
    
    alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [self.navigationController presentViewController:alertController animated:true completion:nil];
}

- (void)fireLocalNotification
{
    NSString *notificationInfo = @"";
    if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL]) {
        notificationInfo = [NSString stringWithFormat:@"ReachMe International is active on %@",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
    }else{
        notificationInfo = [NSString stringWithFormat:@"ReachMe Home is active on %@",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
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

- (void)failureCase
{
    NSString *message = @"\nWe believe there may be some issues with forwarding your calls to ReachMe servers & our support team will help you troubleshoot the problem to get you started, right away.";
    
    if(!self.isActivationProcess)
        message = @"\nWe believe there may be some issues with cancelling the forwarding of  your calls to ReachMe servers & our support team will help you to troubleshoot the problem to get your service deactivated, right away.";
    
    alertController = [UIAlertController alertControllerWithTitle:@"Contact Support" message:message preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:message];
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:13.0]
                    range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor colorWithRed:3.0/255.0 green:3.0/255.0 blue:3.0/255.0 alpha:1.0]
                    range:NSMakeRange(0, attrStr.length)];
    [alertController setValue:attrStr forKey:@"attributedMessage"];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    
    UIAlertAction *liveSupport = [UIAlertAction actionWithTitle:@"REQUEST SUPPORT" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self helpAction];
    }];
    
    [alertController addAction:cancel];
    [alertController addAction:liveSupport];
    
    alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [self.navigationController presentViewController:alertController animated:true completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isShare = NO;
    [Setting sharedSetting].delegate = self;
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@NO forKey:kUserSettingsFetched];
        [userDefaults synchronize];
        [[Setting sharedSetting]getUserSettingFromServer];
        [[Profile sharedUserProfile] getProfileDataFromServer];
        [self configureHelpAndSuggestion];
    }
    
    IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
    self.additionalActiInfo = ccInfo.ussdInfo.additionalActiInfo;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!isShare) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)helpAction
{
    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.phoneNumber];
    
    NSString *dialCode = @"";
    if (self.isActivationProcess) {
        if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            dialCode = self.voiceMailInfo.actiUNCF;
        else{
            CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
            //IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:self.phoneNumber];
            //NSString *activeString = [[ConfigurationReader sharedConfgReaderObj] getMissedCallReasonForTheNumber:self.phoneNumber];
            if (carrierDetails) {
                if (carrierDetails.isReachMeIntlActive)
                    dialCode = self.voiceMailInfo.deactiUNCF;
                else
                    dialCode = self.voiceMailInfo.actiCnf;
            }
        }
    }else{
        if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            dialCode = self.voiceMailInfo.deActiBoth;
        else
            dialCode = self.voiceMailInfo.deActiCnf;
    }
    dialCode = [dialCode stringByReplacingOccurrencesOfString:@";" withString:@"\n"];
    self.helpText = [NSString stringWithFormat:@"I'm having problems in %@ ReachMe Service. My carrier is %@ and the %@ number is %@", self.isActivationProcess?@"activating":@"deactivation", carrierInfo.networkName, self.isActivationProcess?@"activation":@"deactivation", dialCode];
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
        return  3;
    else{
        if (self.isActivationProcess)
            return 2;
        else
            return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *dialCode = @"";
    if (self.isActivationProcess) {
        if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            dialCode = self.voiceMailInfo.actiUNCF;
        else{
            CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
            if (carrierDetails) {
                if (carrierDetails.isReachMeIntlActive)
                    dialCode = self.voiceMailInfo.deactiUNCF;
                else
                    dialCode = self.voiceMailInfo.actiCnf;
            }
        }
    }else{
        if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            dialCode = self.voiceMailInfo.deActiBoth;
        else
            dialCode = self.voiceMailInfo.deActiCnf;
    }
    NSArray *dialCodeArray = [dialCode componentsSeparatedByString:@";"];
    if (section == 0) {
        if(dialCodeArray.count > 0)
            return dialCodeArray.count + 3;
        else
            return 4;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        NSString *infoString = @"Incoming calls will come to the app when your phone is unreachable or switched off. In case you need assistance please contact support.";
        if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            infoString = @"All your incoming calls will come on the ReachMe app. In case you need assistance please contact support";
        else
            infoString = @"Incoming calls will come to the app when your phone is unreachable or switched off. In case you need assistance please contact support.";
        
        UITextView *msgLabel = [[UITextView alloc] init];
        msgLabel.text = infoString;
        msgLabel.font = [UIFont systemFontOfSize:14.0];
        [msgLabel sizeToFit];
        CGSize lableWidth = CGSizeMake(DEVICE_WIDTH - 90.0, CGFLOAT_MAX);
        CGSize neededSize = [msgLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
        return neededSize.height + 20.0;
        
    }else if (indexPath.section  == 2){
        return 100.0;
    }else if(indexPath.section == 0){
        NSString *infoString = [NSString stringWithFormat:@"Call Forwarding \n%@",self.additionalActiInfo];
        UITextView *msgLabel = [[UITextView alloc] init];
        msgLabel.text = infoString;
        msgLabel.font = [UIFont systemFontOfSize:16.0];
        [msgLabel sizeToFit];
        CGSize lableWidth = CGSizeMake(DEVICE_WIDTH, CGFLOAT_MAX);
        CGSize neededSize = [msgLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
        switch (indexPath.row) {
            case 0:
                return 190;
                break;
            case 1:
                if(self.additionalActiInfo.length && self.isActivationProcess)
                    return neededSize.height + 10.0;
                else
                    return 1.0;
                break;
            case 2:
                return 100;
                break;
            default:
                return 110;
                break;
        }
    }
    return 450.0;
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
        switch (indexPath.row) {
            case 0:
                cellIdentifier = kReachMeDialCodeCellIdentifier;
                break;
            case 1:
                cellIdentifier = kReachMeBundleValueCellIdentifier;
                break;
            case 2:
                cellIdentifier = kReachMeCopyShareInstructionsCellIdentifier;
                break;
            default:
                cellIdentifier = kReachMeDialCodeCopyShareCellIdentifier;
                break;
        }
    }else if (indexPath.section == 1){
        cellIdentifier = kReachMeInstructionsCellIdentifier;
    }else{
        cellIdentifier = kReachMeFinishSetupCellIdentifier;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([cell isKindOfClass:[ReachMeActivationTableViewCell class]]) {
        ReachMeActivationTableViewCell *activateReachMeCell = (ReachMeActivationTableViewCell *)cell;
        
        if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            activateReachMeCell.reachMeTypeLabel.text = [NSString stringWithFormat:@"How to %@ ReachMe International?",self.isActivationProcess?@"activate":@"deactivate"];
        else if ([self.reachMeType isEqualToString:REACHME_HOME])
            activateReachMeCell.reachMeTypeLabel.text = [NSString stringWithFormat:@"How to %@ ReachMe Home?",self.isActivationProcess?@"activate":@"deactivate"];
        else
            activateReachMeCell.reachMeTypeLabel.text = [NSString stringWithFormat:@"How to %@ ReachMe Voicemail?",self.isActivationProcess?@"activate":@"deactivate"];
        
        NSString *dialCode = @"";
        if (self.isActivationProcess) {
            if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
                dialCode = self.voiceMailInfo.actiUNCF;
            else{
                CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
                if (carrierDetails) {
                    if (carrierDetails.isReachMeIntlActive)
                        dialCode = self.voiceMailInfo.deactiUNCF;
                    else
                        dialCode = self.voiceMailInfo.actiCnf;
                }
            }
        }else{
            if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
                dialCode = self.voiceMailInfo.deActiBoth;
            else
                dialCode = self.voiceMailInfo.deActiCnf;
        }
        
        NSArray *dialCodeArray = [dialCode componentsSeparatedByString:@";"];
        
        if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            activateReachMeCell.reachMeTypeLabel.text = [NSString stringWithFormat:@"How to %@ ReachMe International?",self.isActivationProcess?@"activate":@"deactivate"];
        else if ([self.reachMeType isEqualToString:REACHME_HOME])
            activateReachMeCell.reachMeTypeLabel.text = [NSString stringWithFormat:@"How to %@ ReachMe Home?",self.isActivationProcess?@"activate":@"deactivate"];
        else
            activateReachMeCell.reachMeTypeLabel.text = [NSString stringWithFormat:@"How to %@ ReachMe Voicemail?",self.isActivationProcess?@"activate":@"deactivate"];
        
        NSString *description = @"";
        
        if (dialCodeArray.count > 1)
            description = [NSString stringWithFormat:@"Dial following %@ code (including * and #) on device containing the SIM associated with %@. Dial the codes one after the other. There will be no charges incurred for dialing this code either from ReachMe or your Carrier.",self.isActivationProcess?@"activation":@"deactivation",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        else
            description = [NSString stringWithFormat:@"Dial following %@ code (including * and #) on device containing the SIM associated with %@. There will be no charges incurred for dialing this code either from ReachMe or your Carrier.",self.isActivationProcess?@"activation":@"deactivation",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        
        NSMutableParagraphStyle *lineSpacingStyle = [[NSMutableParagraphStyle alloc] init];
        lineSpacingStyle.lineSpacing = 4;
        NSMutableAttributedString * detailString = [[NSMutableAttributedString alloc] initWithString:description];
        [detailString addAttribute:NSParagraphStyleAttributeName value:lineSpacingStyle range:NSMakeRange(0, detailString.length)];
        activateReachMeCell.dialCodeDetailsLabel.attributedText = detailString;
        
        if(dialCodeArray.count > 0 && indexPath.row > 2)
            activateReachMeCell.dialCodeText.text = [dialCodeArray objectAtIndex:indexPath.row - 3];
        else
            activateReachMeCell.dialCodeText.text = dialCode;
        
        activateReachMeCell.dialCodeText.layer.cornerRadius = 2.0;
        activateReachMeCell.dialCodeText.textContainerInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
        
        if(!dialCode.length)
            activateReachMeCell.dialCodeText.hidden = YES;
        
        NSString *infoString = @"Incoming calls will come to the app when your phone is unreachable or switched off. In case you need assistance please contact support.";
        
        if([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            infoString = @"All your incoming calls will come on the ReachMe app. In case you need assistance please contact support";
        else
            infoString = @"Incoming calls will come to the app when your phone is unreachable or switched off. In case you need assistance please contact support.";
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4;
        NSURL *URL = [NSURL URLWithString: @""];
        NSMutableAttributedString * linkStr = [[NSMutableAttributedString alloc] initWithString:infoString];
        [linkStr addAttribute: NSLinkAttributeName value:URL range: NSMakeRange(infoString.length - 16, 16)];
        [linkStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, infoString.length)];
        activateReachMeCell.infoTextView.attributedText = linkStr;
        activateReachMeCell.infoTextView.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.54f];
        activateReachMeCell.infoTextView.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
        activateReachMeCell.infoTextView.font = [UIFont systemFontOfSize:14.0];
        activateReachMeCell.infoTextView.textContainerInset = UIEdgeInsetsZero;
        
        
        if (self.additionalActiInfo.length && self.isActivationProcess) {
            activateReachMeCell.metroPCSTextView.hidden = NO;
            NSString *textViewText = [NSString stringWithFormat:@"Call Forwarding \n%@",self.additionalActiInfo];
            
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:textViewText];
            [attributedText addAttribute:NSFontAttributeName
                                   value:[UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold]
                                   range:[textViewText rangeOfString:@"Call Forwarding"]];
            [attributedText addAttribute:NSForegroundColorAttributeName
                                   value:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f]
                                   range:[textViewText rangeOfString:@"Call Forwarding"]];
            
            [attributedText addAttribute:NSFontAttributeName
                                   value:[UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular]
                                   range:[textViewText rangeOfString:self.additionalActiInfo]];
            [attributedText addAttribute:NSForegroundColorAttributeName
                                   value:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.54f]
                                   range:[textViewText rangeOfString:self.additionalActiInfo]];
            
            activateReachMeCell.metroPCSTextView.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
            activateReachMeCell.metroPCSTextView.attributedText = attributedText;
            activateReachMeCell.metroPCSTextView.dataDetectorTypes = UIDataDetectorTypeAll;
            activateReachMeCell.metroPCSTextView.textAlignment = NSTextAlignmentCenter;
            activateReachMeCell.metroPCSTextView.textContainerInset = UIEdgeInsetsMake(10.0, 15.0, 10.0, 15.0);
        }else{
            activateReachMeCell.metroPCSTextView.hidden = YES;
        }
        
        [activateReachMeCell.dialCodeCopyButton addTarget:self action:@selector(dialCodeCopy:) forControlEvents:UIControlEventTouchUpInside];
        [activateReachMeCell.dialCodeShareButton addTarget:self action:@selector(shareDialCode:) forControlEvents:UIControlEventTouchUpInside];
        
        activateReachMeCell.dialCodeCopyButton.tag = indexPath.row;
        activateReachMeCell.dialCodeShareButton.tag = indexPath.row;
        
        activateReachMeCell.finishSetupButton.layer.cornerRadius = 22.0;
        [activateReachMeCell.finishSetupButton addTarget:self action:@selector(finishSetup:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    [self helpAction];
    return YES;
}

- (IBAction)finishSetup:(id)sender
{
    PersonalisationViewController *personalisation = [[PersonalisationViewController alloc]initWithNibName:@"PersonalisationViewController" bundle:nil];
    [self.navigationController pushViewController:personalisation animated:YES];
}

- (IBAction)dialCodeCopy:(id)sender
{
    NSString *dialCode = @"";
    if (self.isActivationProcess) {
        if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            dialCode = self.voiceMailInfo.actiUNCF;
        else{
            CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
            if (carrierDetails) {
                if (carrierDetails.isReachMeIntlActive)
                    dialCode = self.voiceMailInfo.deactiUNCF;
                else
                    dialCode = self.voiceMailInfo.actiCnf;
            }
        }
    }else{
        if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            dialCode = self.voiceMailInfo.deActiBoth;
        else
            dialCode = self.voiceMailInfo.deActiCnf;
    }
    if(!dialCode.length || [dialCode isEqualToString:@""])
        return;
    
    NSArray *dialCodeArray = [dialCode componentsSeparatedByString:@";"];
    
    if(dialCodeArray.count > 0)
        dialCode = [dialCodeArray objectAtIndex:[sender tag] - 3];
    
    [[UIPasteboard generalPasteboard] setString:dialCode];
    [ScreenUtility showAlertMessage:@"Dial Code Copied"];
}

- (IBAction)shareDialCode:(id)sender
{
    NSString *dialCode = @"";
    if (self.isActivationProcess) {
        if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            dialCode = self.voiceMailInfo.actiUNCF;
        else{
            CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
            if (carrierDetails) {
                if (carrierDetails.isReachMeIntlActive)
                    dialCode = self.voiceMailInfo.deactiUNCF;
                else
                    dialCode = self.voiceMailInfo.actiCnf;
            }
        }
    }else{
        if ([self.reachMeType isEqualToString:REACHME_INTERNATIONAL])
            dialCode = self.voiceMailInfo.deActiBoth;
        else
            dialCode = self.voiceMailInfo.deActiCnf;
    }
    if(!dialCode.length || [dialCode isEqualToString:@""])
        return;
    
    NSArray *dialCodeArray = [dialCode componentsSeparatedByString:@";"];
    
    if(dialCodeArray.count > 0)
        dialCode = [dialCodeArray objectAtIndex:[sender tag] - 3];
    
    UIActivityViewController * activity =[[UIActivityViewController alloc] initWithActivityItems:@[dialCode] applicationActivities:nil];
    activity.excludedActivityTypes = @[];
    activity.completionWithItemsHandler = ^(NSString *activityType,
                                            BOOL completed,
                                            NSArray *returnedItems,
                                            NSError *error){
    };
    isShare = YES;
    [self presentViewController:activity animated:true completion:nil];
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
