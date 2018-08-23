//
//  AppDelegate_rm.m
//  ReachMe
//
//  Created by Pandian on 16/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Intents/Intents.h>

#import "AppDelegate_rm.h"
#import "InviteFriendsViewController.h"
#import "CallsViewController.h"
#import "VoiceMailViewController.h"
#import "NotificationIds.h"
#import "NotificationBar.h"
#import "Reachability.h"
#import "UIType.h"
#import "CallLog.h"
#import "Logger.h"
#import "ImgMacro.h"
#import "InsideConversationScreen.h"
#import "AppUpdateUtility_rm.h"
#import "ReachMeIntroViewController.h"
#import "SignOutAPI.h"

#import "SettingsMissedCallRecordAudioViewController.h"
#import "IVMediaSendingViewController.h"
#import "IVMediaZoomDisplayViewController.h"
#import "BrandingScreenViewController.h"
#import "SettingsMissedCallRecordAudioViewController.h"

#import "BaseConversationScreen.h"
#import "Setting.h"
#import "VoipSetting.h"
#import "Profile.h"
#import "Contacts.h"
#import "IVFileLocator.h"
#import "ChatActivity.h"
#import "MQTTManager.h"
#import "IVColors.h"
#import "Conversations.h"

#import "NetworkCommon.h"
#import "InAppPurchaseApi.h"
#import "ReachMe-Swift.h"
#import "DebitRates.h"

//Settings Related
#import "IVSettingsListViewController.h"

//Related to crashlytics.
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "IVPrimaryNumberVoiceMailViewController.h"
#import "IVLinkedNumberVoiceMailViewController.h"
#import "IVSettingsAboutInstaVoiceViewController.h"
#import "RateUsViewController.h"
#import "InviteFriendsViewController.h"

//- VOIP
#import "LinphoneCoreSettingsStore.h"
#include "LinphoneManager.h"
#include "linphone/linphonecore.h"
#import "Log.h"
#import "CallDirectoryHandler.h"
#import "PhoneViewController.h"
//

#import "IVCarrierSearchViewController.h"
#import "IVCarrierCircleViewController.h"
#import "FetchCarriersListAPI.h"
#import "ActivateReachMeViewController.h"
#import "InviteCodeViewController.h"
#import "PersonalisationViewController.h"
#import "ReachMe-Swift.h"

//DialPad
#import "DialPadViewController.h"
#import "CustomCallViewController.h"
#import "FetchObdDebitPolicyAPI.h"

NSString *const kVOIPCallReceived = @"kVoipCallReceived";

#define LOGFILENAME @"KirusaLog.txt"
#define LAUNCHIMG_TIME  3.0
#define NON_RETINA_IPHONE_HEIGHT  480
#define SPLASH_SCREEN_TIME     3.0
#define kMoreTableCellBottonSpacePadding 20.0
#define kMoreTableCellTopSpacePadding 20.0
#define kErrorCodeForCarrierListNotFound 20

#define kNumberOfHoursForSendingiCloudKey  20*60 //20 hours, converted into minutes - 1 hour = 60 mins, so 20*60

@interface AppDelegate () <SettingProtocol>

@property (strong, nonatomic) UIView *redBackgroundView;
@property (nonatomic, strong) NSDate *registerForRemoteNotificationDate;
@property (nonatomic, strong) IVSettingsListViewController *settingsListViewController;

@property (nonatomic, strong) NSArray *currentCarrierList;
@property (nonatomic, strong) IVCarrierSearchViewController *carrierSearchViewController;
@property (nonatomic, strong) IVSettingsCountryCarrierInfo *selectedCountryCarrierInfo;
@property (nonatomic, strong) VoiceMailInfo *voiceMailInfo;
@property (nonatomic, strong) SettingModel *currentSettingsModel;
@end

@implementation AppDelegate
@synthesize deviceHeight,time;


static NSManagedObjectContext* _mainQueueContext=nil;
static NSManagedObjectContext* _privateQueueContext=nil;

#pragma mark -- UIApplication Delegate callback
- (void)detectCallState
{
    //DC
    __weak typeof(self) weakSelf = self;
    _callCenter = [[CTCallCenter alloc] init];
    [_callCenter setCallEventHandler:^(CTCall *call)
     {
         NSString *callStatusCurrently;
         if ([call.callState isEqualToString: CTCallStateConnected])
         {
             callStatusCurrently = @"Connected";
             KLog1(@"Connected");
             dispatch_async(dispatch_get_main_queue(), ^{
                 if([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)
                     [weakSelf callConnected:YES];
             });
         }
         else if ([call.callState isEqualToString: CTCallStateDialing])
         {
             callStatusCurrently = @"Dialing";
             KLog1(@"Dialing");
         }
         else if ([call.callState isEqualToString: CTCallStateDisconnected])
         {
             callStatusCurrently = @"Disconnected";
             KLog1(@"Disconnected");
             dispatch_async(dispatch_get_main_queue(), ^{
                 if([[UIApplication sharedApplication] applicationState]
                    != UIApplicationStateBackground)
                     [weakSelf callConnected:NO];
             });
         }
         else if ([call.callState isEqualToString: CTCallStateIncoming])
         {
             callStatusCurrently = @"Incoming";
             KLog1(@"Incoming");
         }
         [[UIStateMachine sharedStateMachineObj]setCurrentCallStatus:callStatusCurrently];
     }];
}

-(void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

-(void)callConnected:(BOOL)connected {
    int currentUiType = [self.stateMachineObj getCurrentUIType];
    if(INSIDE_CONVERSATION_SCREEN == currentUiType || MY_VOBOLO_SCREEN == currentUiType || NOTES_SCREEN == currentUiType) {
        BaseUI *currentUI = [self.stateMachineObj getCurrentUI];
        BaseConversationScreen  *baseConversationObj = (BaseConversationScreen *)currentUI;
        baseConversationObj.setTextViewWhenAppGoesInBG= YES;
        if(connected)
            baseConversationObj.callConnected = YES;
    }
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    isRequested = FALSE;
    appBecomeActive = 0;
    self.confgReader = [ConfigurationReader sharedConfgReaderObj];
    if([self.confgReader getEnableLogFlag]) {
        KLog(@"Enable log");
        logInit(@"KirusaLog.txt",true);
        setLogLevel(DEBUG);
    }
    
    self.sendCloudKey = TRUE;
    self.sendVoipKey = TRUE;
    
    if([self.confgReader getIsLoggedIn]) {
        [self registerForPushNotification];
        [self registerForVOIPPush];
    }
    
    KLog(@"Launch Options =%@", launchOptions);
    EnLogd(@"Launch Options =%@", launchOptions);
    LOGD(@"Launch Options =%@", launchOptions);
    
    //Crashlytics related 
#ifndef ENABLE_NSLOG
    KLog(@"**** LOG ENABLED ****");
    [Fabric with:@[[Crashlytics class]]];
#endif
    //DEC 22, 2017
    /*
     bgStartId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
     LOGW(@"Background task for application launching expired.");
     [[UIApplication sharedApplication] endBackgroundTask:bgStartId];
     }];
     */
    
    [Contacts sharedContact];
    [LinphoneManager instance];
    self.lphoneCoreSettings = [LinphoneCoreSettingsStore sharedLinphoneCoreSettingsStore];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
        self.providerDelegate = [[ProviderDelegate alloc] init];
        [LinphoneManager.instance setProviderDelegate:self.providerDelegate];
    };
    
    [LinphoneManager.instance startLinphoneCore];
    
    /* DEC 22, 2017
     if (bgStartId != UIBackgroundTaskInvalid)
     [[UIApplication sharedApplication] endBackgroundTask:bgStartId];
     */
    
    //output what state the app is in. This will be used to see when the app is started in the background
    LOGI(@"app launched with state : %li", (long)application.applicationState);
    LOGI(@"FINISH LAUNCHING WITH OPTION : %@", launchOptions.description);
    
    self.chatScreenPushed = FALSE;
    [[ConfigurationReader sharedConfgReaderObj] setShowBrandingScreen:YES];
    
    deviceHeight = [[UIScreen mainScreen] bounds].size;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.fastNetworkInfo = [IVFastNetworkInfo sharedIVFastNetworkInfo];
    //[self.fastNetworkInfo registerForRadioAccessChange];
    [self.fastNetworkInfo updateFastNetworkStatus];
    [Database sharedDBObj]; //this will open the database connection
    self.dataMgt = [UIDataMgt sharedDataMgtObj];
    self.stateMachineObj = [UIStateMachine sharedStateMachineObj];
    self.engObj = [Engine sharedEngineObj];
    self.shortNetObj = [[NetworkController alloc]init];
    self.longNetObj = [[NetworkController alloc]init];
    self.preemptedNetObj = [[NetworkController alloc]init];
    self.picDownloadNetObj = [[NetworkController alloc]init];
    [AppUpdateUtility upgradeAppData];
    
    [[Setting sharedSetting] setCountryInfo];
    recordingPause = false;
    
#ifdef MQTT_ENABLED
    [[MQTTManager sharedMQTTManager]connectMQTTClient];
#endif
    
    BACKGROUNDSTATE = FALSE;
    
    // Set up Reachability
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNetworkStatus:)
                                                 name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tapOnNotificationBar:)
                                                 name:kNotificationBarTapReceivedNotification object:nil];
    
    
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    [self.window makeKeyAndVisible];
    
     if([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus]){
         if([Common showBrandingScreenViewController]) {
             self.window.rootViewController=[[BrandingScreenViewController alloc]init];
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self loadOnboardingScreen];
             });
         }else
             [self loadOnboardingScreen];
     } else {
         //Check for showing branding screen
         if([Common showBrandingScreenViewController] && !remoteNotif.count) {
             self.window.rootViewController=[[BrandingScreenViewController alloc]init];
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self navigationAndNotificationWork:remoteNotif];
             });
         }
         else
             [self navigationAndNotificationWork:remoteNotif];
     }
    
    [self clearNotificationList];
    [self.engObj purgeOldData];
    
    if([self.confgReader getIsLoggedIn]) {
        [self setLocationInfo];
        [self.engObj fetchObdDebitPolicy:NO];
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [self sendDataToStunServer];
    [self.engObj fetchMsgRequest:nil];
    
    //- AppsFlyer
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"EHn4HeeUdFi3Fn6r75q3XY";
    [AppsFlyerTracker sharedTracker].appleAppID = @"1345352747";
    [AppsFlyerTracker sharedTracker].delegate = self;
#ifdef ENABLE_NSLOG
    [AppsFlyerTracker sharedTracker].isDebug = true;
#endif
    //
    
    [self performSelectorInBackground:@selector(prepareContacts) withObject:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString* appID = infoDictionary[@"CFBundleIdentifier"];
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
        NSData* data = [NSData dataWithContentsOfURL:url];
        if (data) {
            NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if ([lookup[@"resultCount"] integerValue] == 1){
                NSString *appStoreVer = lookup[@"results"][0][@"version"];
                NSUserDefaults *appStoreVersion = [NSUserDefaults standardUserDefaults];
                [appStoreVersion setValue:appStoreVer forKey:@"APPSTORE_VERSION"];
                [appStoreVersion synchronize];
            }
        }
    });

    //- check if user tapped ReachMe call action from phonebook contact, Reent call list
    NSDictionary* userActivityDic =  [launchOptions objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey];
    if(userActivityDic) {
        id activity = [userActivityDic objectForKey:@"UIApplicationLaunchOptionsUserActivityKey"];
        
        if (activity && [activity isKindOfClass:[NSUserActivity class]]) {
            [self performuserActivity:activity];
        }
    }
    return YES;
}

#pragma AppsFlyer delegate
- (void) onConversionDataReceived:(NSDictionary*) installData {
    KLog(@"onConversionDataReceived:%@",installData);
}

- (void) onConversionDataRequestFailure:(NSError *)error {
     KLog(@"onConversionDataRequestFailure:%@",error);
}

- (void) onAppOpenAttribution:(NSDictionary*) attributionData {
    KLog(@"onAppOpenAttribution:%@",attributionData);
}

- (void) onAppOpenAttributionFailure:(NSError *)error {
    KLog(@"onAppOpenAttributionFailure:%@",error);
}


#pragma -


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

- (void)loadOnboardingScreen
{
    if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus]) {
        [self loadLatestDataFromServer];
        /*
        if ([[[ConfigurationReader sharedConfgReaderObj] getClassName] isEqualToString:@"InviteCodeViewController"]) {
            InviteCodeViewController *inviteCode = [[InviteCodeViewController alloc]initWithNibName:@"InviteCodeViewController" bundle:nil];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:inviteCode];
            navigationController.navigationBar.tintColor = [IVColors redColor];
            [[UIApplication sharedApplication].keyWindow setRootViewController:navigationController];
            return;
        }
        */
        
        if ([[[ConfigurationReader sharedConfgReaderObj] getClassName] isEqualToString:@"PersonalisationViewController"]) {
            PersonalisationViewController *personalisation = [[PersonalisationViewController alloc]initWithNibName:@"PersonalisationViewController" bundle:nil];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:personalisation];
            navigationController.navigationBar.tintColor = [IVColors redColor];
            [[UIApplication sharedApplication].keyWindow setRootViewController:navigationController];
            return;
        }
        
        CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:[[ConfigurationReader sharedConfgReaderObj] getLoginId]];
        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: [[ConfigurationReader sharedConfgReaderObj] getLoginId]];
        
        if (!self.voiceMailInfo || !self.voiceMailInfo.countryVoicemailSupport || carrierInfo || carrierDetails) {
            //ActivateReachMe
            ActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ActivateReachMe"];
            activateReachMe.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            activateReachMe.isPrimaryNumber = YES;
            activateReachMe.voiceMailInfo = self.voiceMailInfo;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:activateReachMe];
            navigationController.navigationBar.tintColor = [IVColors redColor];
            [[UIApplication sharedApplication].keyWindow setRootViewController:navigationController];
            return;
        }
        
        [self selectCarrier];
        
//        NSArray *listOfCarriers = [[Setting sharedSetting]carrierListForCountry:self.voiceMailInfo.carrierCountryCode];
//        if (listOfCarriers && [listOfCarriers count]) {
//            //We have list of carriers.
//            self.currentCarrierList = listOfCarriers;
//            [self selectCarrier];
//        }
//        else {
//            self.currentCarrierList = nil;
//            //We do not have list of carriers - so start fetching list of carriers for the country.
//            [[Setting sharedSetting]fetchListOfCarriersForCountry:self.voiceMailInfo.carrierCountryCode];
//        }
    }
}

- (void)fetchSettingCompletedWith:(SettingModel*)modelData withFetchStatus:(BOOL)withFetchStatus {
    
    if(withFetchStatus) {
        //Update the location status - YES
        if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus]) {
            [self loadLatestDataFromServer];
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
}

-(void)fetchSettingCompleteWithStatus:(BOOL)fetchStatus {
    //July 18, 2018
    if(fetchStatus) {
        KLog(@"Calling getVoipSetting");
        EnLogd(@"Calling getVoipSettings");
        VoipSetting* voipSettingObj = [VoipSetting sharedVoipSetting];
        voipSettingObj.delegate = self;
        [voipSettingObj getVoipSetting];
    } else {
        EnLogd(@"Fetch user settings failed. Calling it again.");
        [[Setting sharedSetting]getUserSettingFromServer];
    }
    //
}

- (void)fetchListOfCarriersForCountry:(SettingModel *)modelData withFetchStatus:(BOOL)withFetchStatus {
    
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
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCircle];
        navigationController.navigationBar.tintColor = [IVColors redColor];
        [[UIApplication sharedApplication].keyWindow setRootViewController:navigationController];
        return;
    }
    
    if (!self.carrierSearchViewController) {
        self.carrierSearchViewController = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"IVCarrierSearchView"];
    }
    self.carrierSearchViewController.carrierList = self.currentCarrierList;
    self.carrierSearchViewController.voiceMailInfo = self.voiceMailInfo;
    self.carrierSearchViewController.selectedCountryCarrierInfo = self.selectedCountryCarrierInfo;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.carrierSearchViewController];
    navigationController.navigationBar.tintColor = [IVColors redColor];
    [[UIApplication sharedApplication].keyWindow setRootViewController:navigationController];
}

- (void)retrieveCarrierDetails {
    
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    if (self.voiceMailInfo) {
        
        NSMutableDictionary *requestData = [[NSMutableDictionary alloc]init];
        if(self.voiceMailInfo.carrierCountryCode) {
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

- (void)showControllers:(id)remoteNotif {
    
    //call navigation controllers
    [self navigationAndNotificationWork:remoteNotif];
}

- (void)createTabBarControllerItems
{
    KLog(@"createTabBarControllerItems");
    EnLogd(@"createTabBarControllerItems");
    
    if (!_mainQueueContext || !_privateQueueContext) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSavePrivateQueueContext:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[AppDelegate sharedPrivateQueueContext]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSaveMainQueueContext:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[AppDelegate sharedMainQueueContext]];
    }
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    /* - create all the required view controllers to put inside the nav controllers for the tabbing.
     - Tabs: 1)Calls 2)Voicemail 3)Chats 4)Contacts 5)Notes 6)My Blogs 7)Invite friends 8)Rate Us 9)Settings 10)about & Help
     */
    
   
    CallsViewController *callsController = [[CallsViewController alloc] initWithNibName:@"CallsViewController_rm" bundle:[NSBundle mainBundle]];
    VoiceMailViewController *voiceMailController = [[VoiceMailViewController alloc] initWithNibName:@"VoiceMailViewController_rm" bundle:[NSBundle mainBundle]];
    InviteFriendsViewController *inviteFriendsController = [[InviteFriendsViewController alloc] initWithNibName:@"InviteFriendsViewController" bundle:nil];
    
    DialPadViewController *dialPadViewController = [[DialPadViewController alloc] initWithNibName:@"DialPadViewController" bundle:nil];
    
    BaseUI* helpChatViewController = [[InsideConversationScreen alloc]initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    
    UIStoryboard *settingsStorybaord = [UIStoryboard storyboardWithName:@"IVSettings_rm" bundle:[NSBundle mainBundle]];
    self.settingsListViewController = [settingsStorybaord instantiateInitialViewController];
    IVSettingsAboutInstaVoiceViewController *aboutHelpViewController = [[UIStoryboard storyboardWithName:@"IVSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"About_Help"];
    
    
    // create the nav controlers for the tab view.
    UINavigationController *callsNavController = [[UINavigationController alloc] initWithRootViewController:callsController];
    UINavigationController *voiceMailNavController = [[UINavigationController alloc] initWithRootViewController:voiceMailController];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:self.settingsListViewController];
    UINavigationController *aboutHelpNavController = [[UINavigationController alloc] initWithRootViewController:aboutHelpViewController];
    UINavigationController *inviteFriendsNavController = [[UINavigationController alloc] initWithRootViewController:inviteFriendsController];
    UINavigationController *helpChatNavController = [[UINavigationController alloc] initWithRootViewController:helpChatViewController];
    UINavigationController *dialPadNavController = [[UINavigationController alloc] initWithRootViewController:dialPadViewController];
    UINavigationController *storeNavVC = [[UIStoryboard storyboardWithName:@"Store" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"StoreViewControllerNavStoryID"];

    //TODO [self.engObj setHelpAsCurrentChat];
    
    [tabBarController
     setViewControllers:@[callsNavController,
                          voiceMailNavController,
                          dialPadNavController,
                          storeNavVC,
                          inviteFriendsNavController,
                          settingsNavController,
                          helpChatNavController,
                          aboutHelpNavController]];
    
    tabBarController.customizableViewControllers = @[];
    
    UIColor *ivRed = [UIColor colorWithRed:233./255 green:88./255 blue:75./255 alpha:1];
    self.window.tintColor = ivRed;
    tabBarController.tabBar.tintColor = ivRed;
    
    self.tabBarController = tabBarController;
    
    // set the tab bar's delegate
    self.tabBarController.delegate = self;
    navController = callsNavController;
    navController.navigationBar.translucent = YES;
    
    isLogin = [self.confgReader getIsLoggedIn];
    if(isLogin) {
        [self.engObj fetchObdDebitPolicy:NO];
        //[[ConfigurationReader sharedConfgReaderObj]setShowContactUploadDlg:NO];
        self.window.rootViewController = tabBarController;
        [((UITabBarController *)self.window.rootViewController) setSelectedIndex:0];
        [self.tabBarController setSelectedViewController:callsNavController];
        
        [[ConfigurationReader sharedConfgReaderObj]setVoipSettingFetched:NO];
        /* July 18, 2018
        VoipSetting* voipSettingObj = [VoipSetting sharedVoipSetting];
        voipSettingObj.delegate = self;
        [voipSettingObj getVoipSetting];
        */
    }
    else {
        //TODO
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    KLog(@"applicationWillResignActive");
    appBecomeActive = 0;
    LinphoneCall *call = linphone_core_get_current_call(LC);
    
    if (call) {
        /* save call context */
        LinphoneManager *instance = LinphoneManager.instance;
        instance->currentCallContextBeforeGoingBackground.call = call;
        instance->currentCallContextBeforeGoingBackground.cameraIsEnabled = linphone_call_camera_enabled(call);
        
        const LinphoneCallParams *params = linphone_call_get_current_params(call);
        if (linphone_call_params_video_enabled(params)) {
            linphone_call_enable_camera(call, false);
        }
    }
    
    if (![LinphoneManager.instance resignActive]) {
    }
    //
    
    [time invalidate];
    
    int currentUiType = [self.stateMachineObj getCurrentUIType];
    if(currentUiType == INSIDE_CONVERSATION_SCREEN || currentUiType == NOTES_SCREEN || currentUiType == MY_VOBOLO_SCREEN)
    {
        BaseUI *currentUI = [self.stateMachineObj getCurrentUI];
        BaseConversationScreen  *baseConversationObj = (BaseConversationScreen *)currentUI;
        if([[baseConversationObj audioObj]isRecord])
        {
            recordingPause = TRUE;
            [baseConversationObj pauseRecording];
            [baseConversationObj hideRecordingView];
        }
        else if([[baseConversationObj audioObj]isPlay])
        {
            [baseConversationObj pausePlayingAction];
        }
        else if([baseConversationObj respondsToSelector:@selector(dismissAlertRecordView)]) {
            [baseConversationObj dismissAlertRecordView];
        }
    }
    else if (currentUiType == VOICEMAIL_SCREEN) {
        BaseUI *currentUI = [self.stateMachineObj getCurrentUI];
        VoiceMailViewController *voiceMailVC = (VoiceMailViewController*)currentUI;
        if(voiceMailVC && [voiceMailVC respondsToSelector:@selector(pausePlayingAction)])
            [voiceMailVC pausePlayingAction];
        KLog(@"VoiceMailViewController");
    }
}


- (void)prepareContacts {
    
    NSUserDefaults* groupSettings = [ConfigurationReader sharedSettingsForExtension];
    __block NSMutableArray* phoneNumbers = [groupSettings objectForKey:@"PHONE_NUMBERS"];
    __block NSMutableArray* contactNames = [groupSettings objectForKey:@"CONTACT_NAMES"];
    
    /*
     if(phoneNumbers.count && contactNames.count) {
     KLog(@"CallDirExt already loaded.");
     return;
     }*/
    
    [_privateQueueContext performBlockAndWait:^{ //NOV 2017
        
        NSArray* contactList = [[Contacts sharedContact]getPBContactList:_privateQueueContext];
        if(!contactList) {
            KLog(@"*** No contacts from PB");
            return;
        }
        
        NSMutableDictionary* contact = [[NSMutableDictionary alloc]init];
        phoneNumbers = [[NSMutableArray alloc]init];
        contactNames = [[NSMutableArray alloc]init];
        
        for(ContactData* contactData in contactList) {
            NSString* name = contactData.contactName;
            //KLog(@"contact Name = %@",name);
            if(contactData.groupId.length) continue;
            NSSet* all = contactData.contactIdDetailRelation;
            for(ContactDetailData* contactDetail in all) {
                NSString* sPhoneNum = contactDetail.contactDataValue;
                NSString* type = contactDetail.contactDataType;
                if(name.length && sPhoneNum.length && [type isEqualToString:@"tel"]) {
                    //KLog(@"Name = %@, phone num = %@", name, phoneNum);
                    //sPhoneNum = [Common getFormattedNumber:sPhoneNum withCountryIsdCode:nil withGivenNumberisCannonical:TRUE];
                    NSNumber* phoneNum = [NSNumber numberWithLongLong:[sPhoneNum longLongValue]];
                    [contact setObject:name forKey:phoneNum];
                }
            }
        }
        
        NSArray *unsortedKeys = [contact allKeys];
        NSSortDescriptor* descSortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
        NSArray* res = [unsortedKeys sortedArrayUsingDescriptors: [NSArray arrayWithObject: descSortOrder]];
        NSArray* arrKeysSorted = [[NSMutableArray alloc]initWithArray:res];
        
        /*
         NSInteger keyIndex = 0;
         NSString* keyNamePhoneNum = @"PHONE_NUMBERS_";
         NSString* keyNameName = @"CONTACT_NAMES_";
         */
        
        EnLogd(@"Check if valid phone num - STARTS");
        for(NSNumber* num in arrKeysSorted) {
            NSString* sNum = [NSString stringWithFormat:@"%@",num];
            if([Common isPossibleNumber:sNum withContryISDCode:nil showAlert:NO]) {
                KLog(@"Valid Number: %@",sNum);
            } else {
                KLog(@"Invalid Number: %@",sNum);
                continue;
            }
            
            [phoneNumbers addObject:num];
            NSString* name = [contact objectForKey:num];
            [contactNames addObject:name];
            KLog(@"%@ - %@",num,name);
        }
        EnLogd(@"Check if valid phone num - ENDS");
        
        //-- {DEBUG
        /*
         [phoneNumbers removeAllObjects];
         [contactNames removeAllObjects];
         NSString* name = @"VOIP Testing 050";
         NSNumber* phoneNum = [NSNumber numberWithLongLong:19086566050];
         [phoneNumbers addObject:phoneNum];
         [contactNames addObject:name];
         */
        //-- }DEBUG
    }];
    
    [groupSettings setObject:phoneNumbers forKey:@"PHONE_NUMBERS"];
    [groupSettings setObject:contactNames forKey:@"CONTACT_NAMES"];
    [groupSettings synchronize];
    
    [self prepareBlockedContacts];
}

-(void)prepareBlockedContacts {
    
    NSArray* arrBlockedListFromSettings = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"BLOCKED_TILES"];
    NSUserDefaults* groupSettings = [ConfigurationReader sharedSettingsForExtension];
    NSMutableArray* contacts = [[NSMutableArray alloc]init];
    
    
    if(!arrBlockedListFromSettings.count) {
        [groupSettings setObject:contacts forKey:@"PHONE_NUMBERS_BLKD"];
        [groupSettings synchronize];
        KLog(@"No blocked contacts");
        return;
    }
    
    for (NSString *contactID in arrBlockedListFromSettings) {
        
        NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber* numIvId = [f numberFromString:contactID];
        
        NSArray* contactList = [[Contacts sharedContact]getContactForIVUserId:numIvId usingMainContext:NO];
        
        for(ContactDetailData* contactDetail in contactList) {
            NSString* sPhoneNum = contactDetail.contactDataValue  ;
            NSString* type = contactDetail.contactDataType;
            
            if(sPhoneNum.length && [type isEqualToString:@"tel"]) {
                //KLog(@"Name = %@, phone num = %@", name, phoneNum);
                NSNumber* phoneNum = [NSNumber numberWithLongLong:[sPhoneNum integerValue]];
                [contacts addObject:phoneNum];
            }
        }
    }
    
    KLog(@"Blocked contact: %@",contacts);
    
    NSSortDescriptor* descSortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
    NSArray* res = [contacts sortedArrayUsingDescriptors: [NSArray arrayWithObject: descSortOrder]];
    NSArray* arrSorted = [[NSMutableArray alloc]initWithArray:res];
    
    NSMutableArray* phoneNumbers = [[NSMutableArray alloc]init];
    
    for(NSNumber* num in arrSorted) {
        NSString* sNum = [NSString stringWithFormat:@"%@",num];
        if([Common isPossibleNumber:sNum withContryISDCode:nil showAlert:NO]) {
            KLog(@"Valid Number: %@",sNum);
        } else {
            KLog(@"Invalid Number: %@",sNum);
            continue;
        }
        
        [phoneNumbers addObject:num];
        
        KLog(@"BLOCKED: %@",num);
    }
    
    [groupSettings setObject:phoneNumbers forKey:@"PHONE_NUMBERS_BLKD"];
    [groupSettings synchronize];
}

//
//- Get all the numbers which are voipcall enabled but disabled to receive reachMe calls
#if ENABLE_LATER
-(void)prepareVoipCallBlockedNumbers
{
    KLog(@"prepareVoipCallBlockedNumbers");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray* voipCallBlocked = [[NSMutableArray alloc]init];
        
        UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
        
        NSString *primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
        CarrierInfo *carrierInfo = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:primaryNumber];
        if(!carrierInfo.isVoipStatusEnabled) {
            [voipCallBlocked addObject:primaryNumber];
            KLog(@"VOIP status not enabled for primary num:%@",primaryNumber);
            EnLogd(@"VOIP status not enabled for primary num:%@",primaryNumber);
        }
        
        if (currentUserProfileDetails)
        {
            for (int i = 0; i < currentUserProfileDetails.additionalVerifiedNumbers.count; i++) {
                //NSString* theNumber = [currentUserProfileDetails.additionalVerifiedNumbers objectAtIndex:i];
                
                NSDictionary* dicObj = [currentUserProfileDetails.additionalVerifiedNumbers objectAtIndex:i];
                NSString* theNumber = @"";
                if(dicObj && dicObj.count>0) {
                    theNumber = [dicObj valueForKey:API_CONTACT_ID];
                }
                //
                carrierInfo = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:theNumber];
                if([carrierInfo.phoneNumber isEqualToString:theNumber]) {
                    if (!carrierInfo.isVoipStatusEnabled) {
                        [voipCallBlocked addObject:theNumber];
                        KLog(@"VOIP status not enabled for additnl num:%@",theNumber);
                        EnLogd(@"VOIP status not enabled for additnl  num:%@",theNumber);
                    }
                }
            }
        }
        
        
        KLog(@"VOIP call blocked for :%@",voipCallBlocked);
        EnLogd(@"VOIP call blocked for :%@",voipCallBlocked);
       [LinphoneManager.instance setVoipCallBlockedContacts:voipCallBlocked];
    });
}
 #endif


-(void)reloadCallDirExt {
    
    KLog(@"reloadCallDirExt");
    
    [[CXCallDirectoryManager sharedInstance] reloadExtensionWithIdentifier:@"com.kirusa.InstaVoice.CallDirectory"
                                                         completionHandler:^(NSError * _Nullable error) {
                                                             if(!error) {
                                                                 //CMP NSLog(@"CallDirectoryExtenstion loaded successfully");
                                                             }
                                                             if(error) {
                                                                 //CMP NSLog(@"CallDirectoryExtenstion load error %@",error);
                                                                 switch(error.code) {
                                                                     case CXErrorCodeCallDirectoryManagerErrorUnknown:
                                                                         KLog(@"CXErrorCodeCallDirectoryManagerErrorUnknown");
                                                                         break;
                                                                     case CXErrorCodeCallDirectoryManagerErrorNoExtensionFound:
                                                                         KLog(@"CXErrorCodeCallDirectoryManagerErrorNoExtensionFound");
                                                                         break;
                                                                     case CXErrorCodeCallDirectoryManagerErrorLoadingInterrupted:
                                                                         KLog(@"CXErrorCodeCallDirectoryManagerErrorLoadingInterrupted");
                                                                         break;
                                                                         
                                                                     case CXErrorCodeCallDirectoryManagerErrorEntriesOutOfOrder:
                                                                         KLog(@"CXErrorCodeCallDirectoryManagerErrorEntriesOutOfOrder");
                                                                         break;
                                                                         
                                                                     case CXErrorCodeCallDirectoryManagerErrorDuplicateEntries:
                                                                         KLog(@"CXErrorCodeCallDirectoryManagerErrorDuplicateEntries");
                                                                         break;
                                                                         
                                                                     case CXErrorCodeCallDirectoryManagerErrorMaximumEntriesExceeded:
                                                                         KLog(@"CXErrorCodeCallDirectoryManagerErrorMaximumEntriesExceeded");
                                                                         break;
                                                                     case CXErrorCodeCallDirectoryManagerErrorExtensionDisabled:
                                                                         KLog(@"CXErrorCodeCallDirectoryManagerErrorExtensionDisabled");
                                                                         break;
                                                                         
                                                                     case CXErrorCodeCallDirectoryManagerErrorCurrentlyLoading:
                                                                         KLog(@"CXErrorCodeCallDirectoryManagerErrorCurrentlyLoading");
                                                                         break;
                                                                     default:
                                                                         KLog(@"unkonw error");
                                                                         break;
                                                                 }
                                                             }
                                                         }];
    
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    KLog(@"applicationDidBecomeActive - START");
    EnLogd(@"applicationDidBecomeActive");
    
    //- AppsFlyer - Track Installs, updates & sessions(app opens)
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    
    [self.engObj getMissedCallList:TRUE];
    //[self.engObj getVoicemailList:TRUE];
    
    //TODO [self checkMicrphoneAccess];
    /* TEST
     SettingModelVoip* fromVoipSettings = [[SettingModelVoip alloc]init];
     fromVoipSettings.userName = @"CMP";
     fromVoipSettings.password = @"testpwd";
     KLog(@"fromVoicemailInfo=%@",fromVoipSettings);
     [self.lphoneCoreSettings setVoipInfo:fromVoipSettings];
     
     NSString* fromPN = @"52.10.41.228:udp:5061:tcp:5226:tcp";
     KLog(@"fromPN=%@",fromPN);
     [self.lphoneCoreSettings setVoipInfoFromPN:fromPN];
     [self.lphoneCoreSettings refreshRegister:NO];
     */
    
#ifdef MQTT_ENABLED
    [[MQTTManager sharedMQTTManager] connectMQTTClient];
#endif
    
    if([self.confgReader getIsLoggedIn]) {
        
        if (linphone_core_get_calls_nb(LC) >= 1) {
            KLog(@"There is ongoing call");
        }
        else {
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
                [self registerForVOIPPush];//DEC 22, 2017 -- TODO - do we need here?
                [self sendDataToStunServer];
                /* NOV 2017
                 [self performSelectorInBackground:@selector(prepareContacts) withObject:nil];
                 [self reloadCallDirExt];
                 */
            }
        }
        
        /* July 18, 2018
        KLog(@"Calling getVoipSetting");
        VoipSetting* voipSettingObj = [VoipSetting sharedVoipSetting];
        voipSettingObj.delegate = self;
        [voipSettingObj getVoipSetting];
        */
        
        LinphoneCall *call = linphone_core_get_current_call(LC);
        LinphoneManager* instance = LinphoneManager.instance;
        if (call) {
            if (call == instance->currentCallContextBeforeGoingBackground.call) {
                const LinphoneCallParams *params = linphone_call_get_current_params(call);
                if (linphone_call_params_video_enabled(params)) {
                    linphone_call_enable_camera(call, instance->currentCallContextBeforeGoingBackground.cameraIsEnabled);
                }
                instance->currentCallContextBeforeGoingBackground.call = 0;
            } else if (linphone_call_get_state(call) == LinphoneCallIncomingReceived) {
                LinphoneCallAppData *data = (__bridge LinphoneCallAppData *)linphone_call_get_user_data(call);
                if (data && data->timer) {
                    [data->timer invalidate];
                    data->timer = nil;
                }
            }
        } else {
            if(appBecomeActive>0) {
                /* Sometime iOS calls applicationDidBecomeActive twice that causes sending registration request
                 twice within very short period */
                /*
                KLog(@"appBecomeActive = %ld",appBecomeActive);
                if(!self.lphoneCoreSettings.isRegistered) {
                    [self.lphoneCoreSettings setRegAttempt:0];
                    [self.lphoneCoreSettings refreshRegister:YES];
                }*/
                return;
            } else {
                /*
                [self.lphoneCoreSettings setRegAttempt:0];
                [self.lphoneCoreSettings refreshRegister:NO];
                 */
                appBecomeActive++;;
            }
            KLog(@"appBecomeActive = %ld",appBecomeActive);
            if(!self.lphoneCoreSettings.isRegistered) {
                EnLogd(@"RefreshRegister:YES");
                [LinphoneManager.instance setUserAgentString];
                [self.lphoneCoreSettings setRegAttempt:0];
                [self.lphoneCoreSettings refreshRegister:YES];
            } else {
                KLog(@"VOIP client has already been registered");
                EnLogd(@"VOIP client has already been registered");
            }
        }
        
        NSString* devID = [self.lphoneCoreSettings getDeviceID];
        NSString* screenName = [self.confgReader getScreenName];
        
        if(devID.length) {
            //- TODO: discuss with PM. Do not share user's mobile number into public domain
            //NSString* primaryNumber = [self.confgReader getLoginId];
            [CrashlyticsKit setUserIdentifier:devID];
        }
        if(screenName.length) {
            [CrashlyticsKit setUserName:screenName];
        }
        
        [self registerForPushNotification];
        [self registerForVOIPPush];
    }
    
    if([self.confgReader getIsLoggedIn]) {
        addMessageHeader = YES;
    }
    
    [self detectCallState];
    [self.engObj sendAllPendingMsg];
    int currentUiType = [self.stateMachineObj getCurrentUIType];
    if(currentUiType == INSIDE_CONVERSATION_SCREEN || currentUiType == NOTES_SCREEN || currentUiType == MY_VOBOLO_SCREEN)
    {
        if(!linphone_core_get_current_call(LC)) {
            BaseUI *currentUI = [self.stateMachineObj getCurrentUI];
            BaseConversationScreen  *baseConversationObj = (BaseConversationScreen *)currentUI;
            if(recordingPause)
            {
                recordingPause = false;
                [baseConversationObj alertRecording];
            } else {
                [baseConversationObj createAudioObj];
            }
        }
    }
    [self clearNotificationList];
    
    if(NOTES_SCREEN == [self.stateMachineObj getCurrentUIType]) {
        [self.engObj getMyNotes:NO];
    }
    else if(MY_VOBOLO_SCREEN == [self.stateMachineObj getCurrentUIType]) {
        [self.engObj getMyVoboloList:NO];
    }
    
    
    UIViewController* curVC = self.window.rootViewController;
    if ([curVC isKindOfClass:[PhoneViewController class]]) {
        PhoneViewController* pvc = (PhoneViewController*)curVC;
        if([pvc respondsToSelector:@selector(changeAudioRoute)])
            [pvc changeAudioRoute];
    }
    
    [[Engine sharedEngineObj] sendCallStatsLog];
    KLog(@"applicationDidBecomeActive - END");
}

//VOIP
- (void)fixRing {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        // iOS7 fix for notification sound not stopping.
        // see http://stackoverflow.com/questions/19124882/stopping-ios-7-remote-notification-sound
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}
//

- (void)applicationWillTerminate:(UIApplication *)application
{
    KLog(@"applicationWillTerminate");
    
    if([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus]){
        UIViewController *vc = [self topViewController];
        NSString *vcName = NSStringFromClass(vc.classForCoder);
        [[ConfigurationReader sharedConfgReaderObj] setClassName:vcName];
    }
    
    appBecomeActive = 0;
    //VOIP ----
    LinphoneManager.instance.conf = TRUE;
    linphone_core_terminate_all_calls(LC);
    [[ConfigurationReader sharedConfgReaderObj]setVoipSettingFetched:NO];
    
    // destroyLinphoneCore automatically unregister proxies but if we are using
    // remote push notifications, we want to continue receiving them
    if (LinphoneManager.instance.pushNotificationToken != nil) {
        // trick me! setting network reachable to false will avoid sending unregister
        const MSList *proxies = linphone_core_get_proxy_config_list(LC);
        BOOL pushNotifEnabled = NO;
        while (proxies) {
            const char *refkey = linphone_proxy_config_get_ref_key(proxies->data);
            pushNotifEnabled = pushNotifEnabled || (refkey && strcmp(refkey, "push_notification") == 0);
            proxies = proxies->next;
        }
        // but we only want to hack if at least one proxy config uses remote push..
        if (pushNotifEnabled) {
            linphone_core_set_network_reachable(LC, FALSE);
        }
    }
    
    [LinphoneManager.instance destroyLinphoneCore];
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [time invalidate];
    
    //Start: Nivedita Date: 12th Jan
    //Remove oberser of font changes.
    @try{
        [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:UIContentSizeCategoryDidChangeNotification];
    }@catch(id anException){
        
    }
    //End: Nivedita
}


-(void)applicationDidEnterBackground:(UIApplication *)application
{
    KLog(@"applicationDidEnterBackground");
    EnLogd(@"applicationDidEnterBackground");
    
    isRequested = FALSE;
    appBecomeActive = 0;
    
    [LinphoneManager.instance enterBackgroundMode];
    
    [[UIApplication sharedApplication] ignoreSnapshotOnNextApplicationLaunch];
    [time invalidate];
    
#ifdef MQTT_ENABLED
    [[MQTTManager sharedMQTTManager]publishAppStatusInBackground];
    if([[MQTTManager sharedMQTTManager]isConnected])
    {
        [[MQTTManager sharedMQTTManager] disconnectMQTTClient];
    }
#endif
    
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    KLog(@"applicationWillEnterForeground - START");
    EnLogd(@"applicationWillEnterForeground");
    //DEBUG [Common enumeateIfAddresses];
    
    if(self.fastNetworkInfo) {
        [self.fastNetworkInfo updateFastNetworkStatus];
    }
    
    if(![Common isNetworkAvailable] && ![[ConfigurationReader sharedConfgReaderObj]getContactServerSyncFlag]) {
        [ScreenUtility showAlert:@"Network is not connected."];
    }
    
    [self clearNotificationList];
    [self.engObj fetchMsgRequest:nil];
    if([self.confgReader getIsLoggedIn]) {
        [[Contacts sharedContact] syncPendingContactWithServer];
        [[ChatActivity sharedChatActivity] startProcessActivity];
    }
    
#ifdef MQTT_ENABLED
    [[MQTTManager sharedMQTTManager] connectMQTTClient];
#endif
    
    KLog(@"applicationWillEnterForeground - END");
}

-(void)performuserActivity:(NSUserActivity*)userActivity {
    
    INInteraction *interaction = userActivity.interaction;
    INStartAudioCallIntent *startAudioCallIntent = (INStartAudioCallIntent *)interaction.intent;
    INPerson *contact = startAudioCallIntent.contacts[0];
    INPersonHandle *personHandle = contact.personHandle;
    NSString* tempPhoneNumber = personHandle.value;
    
    NSString* phoneNumber = [tempPhoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]"
                                                                       withString:@""
                                                                          options:NSRegularExpressionSearch
                                                                            range:NSMakeRange(0, [tempPhoneNumber length])];
    
    KLog(@"PhoneNumber tapped: %@",phoneNumber);
    EnLogd(@"PhoneNumber tapped: %@", phoneNumber);
    
    self.tappedContact = phoneNumber;
}

#pragma mark - User Activity Continuation protocol dopted by UIApplication delegate
-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    KLog(@"continueUserActivity");
    
    //- AppsFlyer - Reports app open from a Universal Link for iOS 9 or above
    [[AppsFlyerTracker sharedTracker] continueUserActivity:userActivity restorationHandler:restorationHandler];
    
    //
    INInteraction *interaction = userActivity.interaction;
    INStartAudioCallIntent *startAudioCallIntent = (INStartAudioCallIntent *)interaction.intent;
    INPerson *contact = startAudioCallIntent.contacts[0];
    INPersonHandle *personHandle = contact.personHandle;
    NSString* tempPhoneNumber = personHandle.value;
    //NSString* phoneNumber = [tempPhoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString* phoneNumber = [tempPhoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]"
                                                                       withString:@""
                                                                          options:NSRegularExpressionSearch
                                                                            range:NSMakeRange(0, [tempPhoneNumber length])];
    
    KLog(@"PhoneNumber tapped: %@",phoneNumber);
    EnLogd(@"PhoneNumber tapped: %@", phoneNumber);
    
    if ([phoneNumber length] > 0) {
        [LinphoneManager.instance makeCall:phoneNumber FromAddress:nil UserType:nil CalleeInfo:nil];
    }
    
    return YES;
}

-(void)fetchAllDataFromServer
{
    if([self.confgReader getIsLoggedIn]) {
        
        KLog(@"fetchAllDataFromServer");
        [Setting sharedSetting].delegate = self;
        [[Contacts sharedContact] fetchSecondaryNumbers];
        [[Profile sharedUserProfile] fetchBlockedUserList];
        [[Contacts sharedContact] syncPendingContactWithServer];
        [[ChatActivity sharedChatActivity] startProcessActivity];
        //Freshly fetch the user settings
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@NO forKey:kUserSettingsFetched];
        [userDefaults synchronize];
        [[Setting sharedSetting] getUserSettingFromServer];
    }
}

//Start: Nivedita
//Update more button - tableview cell - title label font.
- (void)uiUpdateMoreViewController {
    
    return;
    
    //    if([self.tabBarController.moreNavigationController.topViewController isKindOfClass:NSClassFromString(@"UIMoreListController")]){
    //        UITableView *moreTableView = (UITableView *)self.tabBarController.moreNavigationController.topViewController.view;
    //        moreTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //        if ([[moreTableView subviews] count]) {
    //            for (UITableViewCell *cell in [moreTableView visibleCells]) {
    //                cell.textLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    //                CGSize rect = [Common sizeOfViewWithText:cell.textLabel.text withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    //                moreTableView.rowHeight = rect.height + kMoreTableCellBottonSpacePadding + kMoreTableCellTopSpacePadding;
    //            }
    //        }
    //    }
}

/** Notification method for text size changes via settings
 * @param withNotification: Indicates the instance of notification
 */
/*- (void)preferredContentSizeChanged:(NSNotification *)withNotification {
 
 [self uiUpdateMoreViewController];
 }*/


//End: Nivedita


#pragma mark -- AppDelegate Local Methods

-(void)setLocationInfo
{
    isLogin = [self.confgReader getIsLoggedIn];
    if(isLogin)
    {
#ifdef REACHME_APP
         [self.confgReader setUserLocationAccess:NO];
#else
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if(![CLLocationManager locationServicesEnabled] ||(status == kCLAuthorizationStatusNotDetermined) ||(status == kCLAuthorizationStatusDenied))
        {
            BaseUI *base = [self.stateMachineObj getCurrentUI];
            [base stopUpdatingLocation];
            
            [self.confgReader setUserLocationAccess:NO];
            //Start: Nivedita
            //Instead of updating the settings via api, we can update it once we recieve the settings details from the server.
            //[[Setting sharedSetting]updateUserSettingType:SettingTypeDisplayLocation andValue:NO];
            NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
            [standardDefaults setValue:@NO forKey:kShareLocationSettingsValue];
            [standardDefaults synchronize];
            //End
        }
        
        if([CLLocationManager locationServicesEnabled] && (status == kCLAuthorizationStatusAuthorizedAlways))
        {
            KLog(@"LS: LS enabled");
            BOOL locationFlag = [self.confgReader getUserLocationAccess];
            //Start: Nivedita
            //Instead of updating the settings via api, we can update it once we recieve the settings details from the server.
            //[[Setting sharedSetting]updateUserSettingType:SettingTypeDisplayLocation andValue:locationFlag];
            NSString *flag = [NSString stringWithFormat:@"%d", locationFlag];
            NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
            [standardDefaults setValue:flag forKey:kShareLocationSettingsValue];
            [standardDefaults synchronize];
            //End
        }
#endif
    }
}

- (void)checkNetworkStatus:(NSNotification*)notify
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            KLog(@"The internet is down.");
            [self.engObj stopSenddingAllMsg];
            [[ChatActivity sharedChatActivity]stopProcessActivity];
            [self.engObj notifyUIOfNetConnection:NO];
            [[Contacts sharedContact]clearTheOperations];
            [[Contacts sharedContact]setIsSyncInProgress:NO];
            break;
        }
        case ReachableViaWiFi:
        case ReachableViaWWAN:
        {
            KLog(@"The internet is working via WIFI");
            [self.engObj sendAllPendingMsg];
            [[ChatActivity sharedChatActivity]startProcessActivity];
            if([[UIApplication sharedApplication]applicationState] != UIApplicationStateBackground) {
                KLog(@"Calling fetchMsgRequest...");
                [self.engObj fetchMsgRequest:nil];
            }
            [self.engObj notifyUIOfNetConnection:YES];
            
            if(![[ConfigurationReader sharedConfgReaderObj]getContactServerSyncFlag] &&
               [[ConfigurationReader sharedConfgReaderObj]getContactLocalSyncFlag]) {
                if([[ConfigurationReader sharedConfgReaderObj]getIsLoggedIn]) {
                    AppDelegate *appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
                    NSUInteger selectedTab = [((UITabBarController *)appDelegate.window.rootViewController)selectedIndex];
                    if(3==selectedTab) {//if friendsScreen is already on...
                        //[[Contacts sharedContact]syncContactFromNativeContact];
                        KLog(@"Calling syncPendingContactWithServer");
                        [[Contacts sharedContact]syncPendingContactWithServer];
                    } else {
                        KLog(@"Set friendsViewController tab");
                        [((UITabBarController *)appDelegate.window.rootViewController) setSelectedIndex:3];
                    }
                }
            }
            
            break;
        }
    }
}

#pragma mark --  Remote Notification Related work
#pragma mark --  Remote Notification Related work -- App Delegate Callback
-(void)registerForPushNotification
{
    if([self.confgReader getIsLoggedIn])
    {
        KLog(@"registerForPushNotification");
        /*
        float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
        if(ver >= 8) {
            if([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
            {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                                     |UIUserNotificationTypeSound
                                                                                                     |UIUserNotificationTypeAlert) categories:nil];
                
                EnLogd(@"*** Calling registerUserNotificationSettings (Badge, Alert and Sound)");
                KLog(@"*** Calling registerUserNotificationSettings (Badge, Alert and Sound)");
                [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            }
        }*/
        
        BOOL isRegistered = [[UIApplication sharedApplication]isRegisteredForRemoteNotifications];
        //if(!isRegistered)
        {
            if(isRequested) return;
            isRequested = TRUE;
            [[UNUserNotificationCenter currentNotificationCenter]
             requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
             completionHandler:^(BOOL granted, NSError *_Nullable error) {
                 // Enable or disable features based on authorization.
                 if (error) {
                     EnLogd(@"ERROR: %@",error.description);
                 }
                 
                 if(granted) {
                     [self performSelectorOnMainThread:@selector(doRegisterForRemoteNotifications) withObject:nil waitUntilDone:NO];
                 } else {
                     //TODO show permission dialog
                     KLog(@"SHOW PERMISSION DLG");
                     [self performSelectorOnMainThread:@selector(showRemoteNotificationWarning) withObject:nil waitUntilDone:NO];
                 }
             }];
        }
        
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }
}

-(void)doRegisterForRemoteNotifications {
    
     [[UIApplication sharedApplication]registerForRemoteNotifications];
}

-(void)showRemoteNotificationWarning
{
    UIAlertController* acRemoteNotif = [UIAlertController alertControllerWithTitle:@"Turn On Notifications"
                                                                           message:@"To receive Voicemail and Missed call instantly, Notifications must be enabled for ReachMe app. Tap Settings to turn on Notifications."
                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction* settingsBtn = [UIAlertAction actionWithTitle:@"Settings"
                                                    style:(UIAlertActionStyleDefault)
                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                                                         options:@{}
                                                                               completionHandler:^(BOOL success) {
                                                                                   //KLog(@"success = %d", success);
                                                                               }];
                                                  }];
    
    UIAlertAction* cancelBtn = [UIAlertAction actionWithTitle:@"Cancel"
                                                        style:(UIAlertActionStyleCancel)
                                                      handler:nil];
    
    [acRemoteNotif addAction:settingsBtn];
    [acRemoteNotif addAction:cancelBtn];
    acRemoteNotif.view.tintColor = [UIColor blueColor];
    [self.getNavController presentViewController:acRemoteNotif animated:YES completion:nil];
    
}

#pragma mark - UNUserNotifications Framework

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionAlert);
    KLog(@"willPresentNotification");
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    
    KLog(@"didReceiveNotificationResponse:%@",response.notification.request.content.userInfo);
    EnLogd(@"PN clicked when app is background");
    KLog(@"PN clicked when app is background");
    
    NSDictionary* dic = [[NSDictionary alloc]initWithDictionary:response.notification.request.content.userInfo];
    
    //Reached here if push notification is clicked when App is in background.
    [[MQTTManager sharedMQTTManager]processAPNSPushNotificationData:dic showOnBar:NO];
    [self actionOnNotificationBar:dic isAppLaunched:YES];
    [self clearNotificationList];
    
    completionHandler();
}

#pragma -

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    EnLogd(@"didRegisterUserNotificationSettings");
    self.registerForRemoteNotificationDate = [NSDate date];
}

- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void(^)())completionHandler
{
    //Handle actions
    KLog(@"Handle actions");
    
    EnLogd(@"handleActionWithIdentifier: %@",identifier);
}

/*
 At app launch time, the client gets the new device token and if the new token is different from cached token,
 it will send the device token to the server, otherwise, it will not.
 Also, server can ask the client to send the current device token via events.
 */
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    /* - AppsFlyer - The following line will enable to track uninstalls.
         pushNotifications certificate has to be configured at AppsFlyer dashboard to send push notifications
     */
    //[[AppsFlyerTracker sharedTracker] registerUninstall:deviceToken];
    
    KLog(@"New device token:\n%@", deviceToken);
    NSString *tokenStr = [[NSString alloc] initWithFormat:@"%@",deviceToken];
    tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *hyphens = @"<>";
    NSCharacterSet *hyphensCharSet = [NSCharacterSet characterSetWithCharactersInString:hyphens];
    tokenStr = [[tokenStr componentsSeparatedByCharactersInSet:hyphensCharSet] componentsJoinedByString:@""];
    KLog(@"New Device token:(space,<,> removed):\n%@",tokenStr);
    EnLogd(@"New Device token:(space,<,> removed):\n%@",tokenStr);
    
    NSString *cloudSecureKey = [self.confgReader getCloudSecureKey];
    KLog(@"Cached device token =\n%@",cloudSecureKey);
    EnLogd(@"Cached device token =\n%@",cloudSecureKey);
    
    if(nil == cloudSecureKey || ![cloudSecureKey isEqualToString:tokenStr] || self.sendCloudKey) {
        KLog(@"*** Calling setDeviceInfo");
        EnLogd(@"*** Calling setDeviceInfo");
        [[Setting sharedSetting]setDeviceInfo:tokenStr];
        self.sendCloudKey = NO;
    } else {
        KLog(@"*** New and Cached device tokens are same.");
        EnLogd(@"*** New and Cached device tokens are same.");
    }
}

//Did recieve local notification.
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    KLog(@"DdidReceiveLocalNotification");
    
    int uiType = [[UIStateMachine sharedStateMachineObj] getCurrentUIType];
    if (uiType != VOICEMAIL_LINKED_NUMBER_SCREEN && uiType!= VOICEMAIL_PRIMARY_NUMBER_SCREEN) {
        if ([[notification.userInfo valueForKey:@"notification_type"] isEqualToString:@"hlr_activation"]) {
            if (application.applicationState == UIApplicationStateActive) {
                [NotificationBar notifyWithText:notification.alertTitle detail:notification.alertBody image:[UIImage imageNamed:@"launcher_Icon"] andDuration:2.0 msgPayLoad:notification.userInfo];
            }
        }
    }
}


//- AppsFlyer  Reports app open from deep link for iOS 10
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *) options
{
    [[AppsFlyerTracker sharedTracker] handleOpenUrl:url options:options];
    return YES;
}

-(int)checkPNForVoiceMailOrMissedCall:(NSMutableDictionary*)notifDic
{
    EnLogd(@"checkPNForVoiceMailOrMissedCall");
    int eventToNotif = NOTIFY_IVMSG;
    if([[notifDic valueForKey:@"msg_content_type"]isEqualToString:@"t"])
    {
        if([[notifDic valueForKey:@"msg_type"]isEqualToString:@"mc"]) {
            eventToNotif = NOTIFY_MISSEDCALL;
            EnLogd(@"Its MC");
        }
    }
    else if([[notifDic valueForKey:@"msg_content_type"]isEqualToString:@"a"])
    {
        if(/*APR 18 [[notifDic valueForKey:@"msg_subtype"]isEqualToString:@"avs"] &&*/
           [[notifDic valueForKey:@"msg_type"]isEqualToString:@"vsms"] ) {
            eventToNotif = NOTIFY_VOICEMAIL;
            EnLogd(@"Its VM");
        }
    }
    else
    {
        eventToNotif = NOTIFY_IVMSG;
        EnLogd(@"Its IV");
        KLog(@"what else");
    }
    [notifDic setValue:[NSNumber numberWithInt:eventToNotif] forKey:@"NOTIFY_UI"];
    
    return eventToNotif;
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    EnLogd(@"Notification Dic: %@",userInfo);
    KLog(@"Push Notification received is =%@", userInfo);
    
    BOOL showNotification = FALSE;
    NSMutableDictionary* alert = [userInfo valueForKeyPath:@"aps.alert"];
    NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:userInfo];
    if(alert && [alert count]) {
        showNotification = TRUE;
    }
    
    if(application.applicationState == UIApplicationStateActive)
    {
        [[MQTTManager sharedMQTTManager]processAPNSPushNotificationData:dic showOnBar:showNotification];
    }
    else
    {
        //- Reached here if push notification is clicked when App is in background.
        [[MQTTManager sharedMQTTManager]processAPNSPushNotificationData:dic showOnBar:NO];
        [self actionOnNotificationBar:userInfo isAppLaunched:YES];
    }
    [self clearNotificationList];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    KLog(@"Push Notification received in completion handler. userInfo = %@", userInfo);
    EnLogd(@"Push Notification received in completion handler. userInfo = %@", userInfo);
    
    //NSMutableDictionary* notifDic = [[NSMutableDictionary alloc]initWithDictionary:userInfo];
    //int msgType = [self checkPNForVoiceMailOrMissedCall:notifDic];
    
    BOOL showNotification = TRUE;
    
    /* NOV 2017
     NSMutableDictionary* alert = [userInfo valueForKeyPath:@"aps.alert"];
     if(userInfo && userInfo.count && [alert count] && addMessageHeader) {
     [self.engObj addMessageHeaderIntoTable:userInfo];
     } else {
     showNotification = FALSE;
     KLog(@"Not a new msg");
     }*/
    addMessageHeader = YES;
    
    NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:userInfo];
    if(application.applicationState == UIApplicationStateActive)
    {
        KLog(@"UIApplicationStateActive");
        EnLogd(@"UIApplicationStateActive");
        
        //- NOV 2017
        NSMutableDictionary* alert = [userInfo valueForKeyPath:@"aps.alert"];
        if(userInfo && userInfo.count && [alert count] && addMessageHeader) {
            EnLogd(@"Calling addMessageHeader..");
            [self.engObj addMessageHeaderIntoTable:userInfo];
        } else {
            showNotification = FALSE;
            KLog(@"Not a new msg");
        }//
        
        [[MQTTManager sharedMQTTManager]processAPNSPushNotificationData:dic showOnBar:showNotification];
        [self clearNotificationList];
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if(application.applicationState == UIApplicationStateBackground)
    {
        KLog(@"UIApplicationStateBackground Notification");
        EnLogd(@"UIApplicationStateBackground Notification");
        
        [[Conversations sharedConversations]fetchMessageFromServerInBackgroundWithNotification:userInfo fetchCompletionHandler:completionHandler];
    }
    else
    {
        EnLogd(@"PN clicked when app is background");
        KLog(@"PN clicked when app is background");
        
        //Reached here if push notification is clicked when App is in background.
        [[MQTTManager sharedMQTTManager]processAPNSPushNotificationData:dic showOnBar:NO];
        
        [self actionOnNotificationBar:userInfo isAppLaunched:YES];
        [self clearNotificationList];
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

-(void)popChatScreen:(NSInteger)msgType
{
    KLog(@"popChatScreen");
    EnLogd(@"popChatScreen");
    
    int uiType = [[UIStateMachine sharedStateMachineObj] getCurrentUIType];
    BaseUI* curUI = [self.stateMachineObj getCurrentUI];
    
    switch (msgType)
    {
            
        case NOTIFY_MISSEDCALL:
        {
            if(uiType == INSIDE_CONVERSATION_SCREEN) {
                EnLogd(@"pop InsideConversation");
                KLog(@"pop InsideConversation");
                
                InsideConversationScreen* convVC = (InsideConversationScreen*)curUI;
                if([convVC respondsToSelector:@selector(cancel)]) {
                    [convVC cancel];
                }
            }
        }
            break;
            
        case NOTIFY_VOICEMAIL:
        {
            if(uiType == INSIDE_CONVERSATION_SCREEN) {
                EnLogd(@"pop InsideConversation");
                KLog(@"pop InsideConversation");
                
                InsideConversationScreen* convVC = (InsideConversationScreen*)curUI;
                if([convVC respondsToSelector:@selector(cancel)]) {
                    [convVC cancel];
                }
            }
        }
            break;
            
        default:
        {
            if(uiType == INSIDE_CONVERSATION_SCREEN) {
                EnLogd(@"pop InsideConversation");
                KLog(@"pop InsideConversation");
                
                InsideConversationScreen* convVC = (InsideConversationScreen*)curUI;
                if([convVC respondsToSelector:@selector(cancel)]) {
                    [convVC cancel];
                }
            }
            
        }
            break;
    }
}

-(void)clearNotificationList
{
    KLog(@"clearNotificationList");
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
}

#pragma mark --  Remote Notification Related work -- Notification clicked on background or closed state
-(void)navigationAndNotificationWork:(NSDictionary*)remoteNotif
{
    isLogin = [self.confgReader getIsLoggedIn];
    
    if (isLogin) {
        KLog(@"Already logged-in");

        [[ConfigurationReader sharedConfgReaderObj]setIsFreshSignUpStatus:NO];
        [[ConfigurationReader sharedConfgReaderObj]setIsRMFreshSignUpStatus:NO];
        [self createTabBarControllerItems];
        [self fetchAllDataFromServer];
        
        if(remoteNotif.count) {
            [[MQTTManager sharedMQTTManager]processAPNSPushNotificationData:remoteNotif showOnBar:NO];
            EnLoge(@"Notification Dic: %@",remoteNotif);
            KLog(@"Notification Dic: %@",remoteNotif);
            [self handleNotificationeBarClick:remoteNotif];
            addMessageHeader = NO;
        }
        else {
            //TODO
        }
    }
    else {
        KLog(@"Not logged-in");
        
        //- navController must not be nil
        //navController = [[UIStateMachine sharedStateMachineObj]getRootViewController];
        navController = [self getPromoViewController];
        self.window.rootViewController = navController;
        self.tabBarController.delegate = self;
    }
}


-(UINavigationController*)getPromoViewController
{
    ReachMeIntroViewController* vc = [[ReachMeIntroViewController alloc]initWithNibName:@"ReachMeIntroViewController" bundle:nil];
    return ([[UINavigationController alloc]initWithRootViewController:vc]);
}


-(void)handleNotificationeBarClick:(NSDictionary*)notificationDic
{
    EnLogd(@"handleNotificationeBarClick:%@",notificationDic);
    /*
    NSString *ivUserId = [notificationDic valueForKey:@"user_id"];
    NSString *myIvUserId = [[NSString alloc] initWithFormat:@"%ld",[self.confgReader getIVUserId]];
    if([ivUserId isEqualToString:myIvUserId])
    {
        //TODO
    }
    else
    {
        NSString* msgType = [notificationDic valueForKey:@"msg_type"];
        if([msgType isEqualToString:VSMS_TYPE])
            [self.tabBarController setSelectedIndex:1];
        else
            [self.tabBarController setSelectedIndex:0];
        
        [AppDelegate setCurrentChatUserFromNotificationPayload:notificationDic];
        [self gotoConversationScreen];
    }*/
}

#pragma mark --  Remote Notification Related work NSNotificationCenter -- kNotificationBarTapReceivedNotification
-(void)tapOnNotificationBar:(NSNotification*)notify
{
    NotificationBar *bar = (NotificationBar*)notify.object;
    NSDictionary *newDic = bar.msgPayLoad;
    [self removeOverlayViews];
    [self actionOnNotificationBar:newDic isAppLaunched:NO];
}

-(void)removeOverlayViews
{
    BaseUI *base = (BaseUI*)[self.stateMachineObj getCurrentUI];
    if ([base respondsToSelector:@selector(removeOverlayViewsIfAnyOnPushNotification)]) {
        [base removeOverlayViewsIfAnyOnPushNotification];
    }
    
    if([base isKindOfClass:[InviteFriendsViewController class]]) {
        InviteFriendsViewController* inv = (InviteFriendsViewController*)base;
        if([inv respondsToSelector:@selector(dismissAlert)]) {
            [inv dismissAlert];
        }
    }
    /*
    if([base isKindOfClass:[InsideConversationScreen class]]) {
        InsideConversationScreen* convScreen = (InsideConversationScreen*)base;
        if([convScreen respondsToSelector:@selector(cancel)])
            [convScreen cancel];
    }*/
}

-(void)actionOnNotificationBar:(NSDictionary*)payLoad isAppLaunched:(BOOL)fromBackground
{
    KLog(@"Notification Clicked");
    EnLogd(@"fromBackground:%@",fromBackground?@"YES":@"NO");
    
    //Start
    //RM Switch Local notification Related
    if ([[payLoad valueForKey:@"notification_type"] isEqualToString:@"rm_switch"])
        return;
    //End
    
    self.stateMachineObj.pnClicked = 1;
    int eventToNotify = [[payLoad valueForKey:@"NOTIFY_UI"] intValue];
    NSMutableDictionary* notifDic=nil;
    if(!eventToNotify) {
        notifDic = [[NSMutableDictionary alloc]initWithDictionary:payLoad];
        [self checkPNForVoiceMailOrMissedCall:notifDic];
        eventToNotify = [[notifDic valueForKey:@"NOTIFY_UI"] intValue];
    }
    if(eventToNotify) {
        if(!notifDic)
            notifDic = [[NSMutableDictionary alloc]init];
        [notifDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
        [notifDic setValue:[NSNumber numberWithInt:eventToNotify] forKey:EVENT_TYPE];
    }
    
    BOOL isAvsMessage = FALSE;
    if(eventToNotify == NOTIFY_MISSEDCALL || eventToNotify == NOTIFY_VOICEMAIL) {
        isAvsMessage = TRUE;
    }
    
    EnLogd(@"isAvsMessage:%@",isAvsMessage?@"YES":@"NO");
    KLog(@"isAvsMessage:%@",isAvsMessage?@"YES":@"NO");
    
    NSString *messageType = [payLoad valueForKey:@"msg_type"];
    if (messageType && [messageType isEqualToString:kNewJoineeMessageType]) {
        //Do not do anything, so return it.
        return;
    }
    
    UIViewController* currentVC = [self getCurrentViewController];
    if( currentVC && [currentVC isKindOfClass:[IVMediaZoomDisplayViewController class]]) {
        IVMediaZoomDisplayViewController* IvMediaZoomDisplayVC = (IVMediaZoomDisplayViewController*)currentVC;
        if([IvMediaZoomDisplayVC respondsToSelector:@selector(cancel)])
            [IvMediaZoomDisplayVC cancel];
    }
    
    if ([[UIStateMachine sharedStateMachineObj]getCurrentPresentedUI]) {
        KLog(@"***** Presented UI %@",[[UIStateMachine sharedStateMachineObj]getCurrentPresentedUI]);
        
        if ([[UIStateMachine sharedStateMachineObj]getCurrentPresentedUI]) {
            KLog(@"***** Presented UI %@",[[UIStateMachine sharedStateMachineObj]getCurrentPresentedUI]);
            
            BaseUI* presentedUI = [self.stateMachineObj getCurrentPresentedUI];
            if( [presentedUI isKindOfClass:[IVMediaSendingViewController class]]) {
                IVMediaSendingViewController* vc = (IVMediaSendingViewController*)presentedUI;
                if([vc respondsToSelector:@selector(cancel)]) {
                    [vc cancel];
                }
            }
            else if([presentedUI isKindOfClass:[SettingsMissedCallRecordAudioViewController class]]) {
                SettingsMissedCallRecordAudioViewController* vc = (SettingsMissedCallRecordAudioViewController*)presentedUI;
                if([vc respondsToSelector:@selector(dismissThisViewController)])
                    [vc dismissThisViewController];
            }
            else if([presentedUI isKindOfClass:[ShareFriendsListViewController class]]) {
                ShareFriendsListViewController* vc = (ShareFriendsListViewController*)presentedUI;
                if([vc respondsToSelector:@selector(dismissViewController)]) {
                    [vc dismissViewController];
                }
            }
            else {
                KLog(@"Return");
                return;
            }
        }
    }
    
    NSString *ivUserId = [payLoad valueForKey:@"user_id"];
    NSString *myIvId = [[NSString alloc] initWithFormat:@"%ld",[[ConfigurationReader sharedConfgReaderObj] getIVUserId]];
    int uiType = [[UIStateMachine sharedStateMachineObj] getCurrentUIType];
    
    if([ivUserId isEqualToString:myIvId])
    {
        //TODO: debug. When will this condition be met?. It happens when self missed call/voicemail is received.
        return;
    }
    else if(uiType == INSIDE_CONVERSATION_SCREEN /*&& !isAvsMessage*/)
    {
        BaseUI* curUI = (BaseUI*)[self.stateMachineObj getCurrentUI];
        if( curUI && [curUI isKindOfClass:[InsideConversationScreen class]]) {
            InsideConversationScreen* curVC = (InsideConversationScreen*)curUI;
            if([curVC respondsToSelector:@selector(dismissAlert)]) {
                [curVC dismissAlert];
            }
        }
        
        NSMutableDictionary *currentChatUser = [[Engine sharedEngineObj] getCurrentChatUser];
        BOOL changeTheCurrentChat = false;
        if(currentChatUser != nil)
        {
            NSString *currentIvId = [currentChatUser valueForKey:REMOTE_USER_IV_ID];
            NSString *currentFromUserId = [currentChatUser valueForKey:FROM_USER_ID];
            
            NSString* groupId = [payLoad valueForKey:@"group_id"];
            if(groupId.length)
            {
                if(![groupId isEqualToString:currentFromUserId])
                    changeTheCurrentChat = true;
            }
            else
            {
                // one to one chat
                NSString* ivUserId = [payLoad valueForKey:@"user_id"];
                NSString* phoneNumber = [payLoad valueForKey:@"ph"];
                
                if(ivUserId.length && ![ivUserId isEqualToString:currentIvId] && currentIvId.length && ![currentIvId isEqualToString:@"0"])
                        changeTheCurrentChat = true;
                else if(![phoneNumber isEqualToString:currentFromUserId])
                            changeTheCurrentChat = true;
            }
            
            if(changeTheCurrentChat)
            {
                KLog(@"ChangedTheCurrentChat");
                [self popChatScreen:eventToNotify];
                NSMutableDictionary *recordDic = [self stopRecordingAndSave];
                if(recordDic != nil)
                {
                    [recordDic setValue:IV_TYPE forKey:MSG_TYPE];
                    [[Engine sharedEngineObj] setLastMsgInfo:recordDic];
                }
                
                recordingPause = FALSE;
                [AppDelegate setCurrentChatUserFromNotificationPayload:payLoad];
            }
        }
        else
        {
            EnLogd(@"*** getCurrentChatUser() returned nil. Check.");
            [AppDelegate setCurrentChatUserFromNotificationPayload:payLoad];
        }
        
        if(changeTheCurrentChat) {
            KLog(@"Goto conversation screen");
            if(NOTIFY_MISSEDCALL == eventToNotify)
                [self.tabBarController setSelectedIndex:0];
            else if(NOTIFY_VOICEMAIL == eventToNotify)
                [self.tabBarController setSelectedIndex:1];
            
            [self gotoConversationScreen];
        }
    }
    else if (uiType == VOICEMAIL_SCREEN) {
        BaseUI* curUI = (BaseUI*)[self.stateMachineObj getCurrentUI];
        if( curUI && [curUI isKindOfClass:[VoiceMailViewController class]]) {
            VoiceMailViewController* curVC = (VoiceMailViewController*)curUI;
            if([curVC respondsToSelector:@selector(dismissAlert)]) {
                [curVC dismissAlert];
            }
        }
    }
    else if(uiType == CALLS_SCREEN) {
        BaseUI* curUI = (BaseUI*)[self.stateMachineObj getCurrentUI];
        if( curUI && [curUI isKindOfClass:[CallsViewController class]]) {
            CallsViewController* curVC = (CallsViewController*)curUI;
            if([curVC respondsToSelector:@selector(dismissAlert)]) {
                [curVC dismissAlert];
            }
        }
    }
    else
    {
        BaseUI* curUI = [self.stateMachineObj getCurrentUI];
        
        //- Cancel the Greetings record view.
        if (uiType == MISSED_CALL_SCREEN)
        {
            if( [curUI isKindOfClass:[SettingsMissedCallRecordAudioViewController class]]) {
                SettingsMissedCallRecordAudioViewController* vc = (SettingsMissedCallRecordAudioViewController*)curUI;
                if([vc respondsToSelector:@selector(cancelTapped:)]) {
                    [vc cancelTapped:nil];
                }
            }
        }
        
        if (uiType == VOICEMAIL_PRIMARY_NUMBER_SCREEN || uiType == VOICEMAIL_LINKED_NUMBER_SCREEN
            || uiType == VOICEMAIL_LIST_VIEWCONTROLLER) {
            
            if( [curUI isKindOfClass:[IVPrimaryNumberVoiceMailViewController class]]) {
                IVPrimaryNumberVoiceMailViewController* primaryNumberVoicemailController = (IVPrimaryNumberVoiceMailViewController*)curUI;
                if([primaryNumberVoicemailController respondsToSelector:@selector(removeOverlayViewsIfAnyOnPushNotification)]) {
                    [primaryNumberVoicemailController removeOverlayViewsIfAnyOnPushNotification];
                }
            }
            
            if( [curUI isKindOfClass:[IVLinkedNumberVoiceMailViewController class]]) {
                IVLinkedNumberVoiceMailViewController* linkedNumberVoicemailController = (IVLinkedNumberVoiceMailViewController*)curUI;
                if([linkedNumberVoicemailController respondsToSelector:@selector(removeOverlayViewsIfAnyOnPushNotification)]) {
                    [linkedNumberVoicemailController removeOverlayViewsIfAnyOnPushNotification];
                }
            }
            
            if ([curUI respondsToSelector:@selector(removeOverlayViewsIfAnyOnPushNotification)]) {
                [curUI removeOverlayViewsIfAnyOnPushNotification];
            }
        }
        
        [AppDelegate setCurrentChatUserFromNotificationPayload:payLoad];
        
        if(NOTIFY_VOICEMAIL == eventToNotify) {
            [self.tabBarController setSelectedIndex:1];
        } else {
            [self.tabBarController setSelectedIndex:0];
        }
        
        EnLogd(@"uiType = %d",uiType);
        EnLogd(@"payload = %@",payLoad);
        EnLogd(@"eventToNoty = %d",eventToNotify);
        
        KLog(@"uiType = %d",uiType);
        KLog(@"payload = %@",payLoad);
        KLog(@"eventToNoty = %d",eventToNotify);
        
        switch (eventToNotify)
        {
            case NOTIFY_MISSEDCALL:
            {
                if(uiType == INSIDE_CONVERSATION_SCREEN) {
                    EnLogd(@"pop InsideConversation");
                    KLog(@"pop InsideConversation");
                    
                    InsideConversationScreen* convVC = (InsideConversationScreen*)curUI;
                    if([convVC respondsToSelector:@selector(cancel)]) {
                        [convVC cancel];
                    }
                }
                self.stateMachineObj.tabIndex = 1;
                [self.engObj notifyUI:notifDic];
            }
                break;
                
            case NOTIFY_VOICEMAIL:
            {
                if(uiType == INSIDE_CONVERSATION_SCREEN) {
                    EnLogd(@"pop InsideConversation");
                    KLog(@"pop InsideConversation");
                    
                    InsideConversationScreen* convVC = (InsideConversationScreen*)curUI;
                    if([convVC respondsToSelector:@selector(cancel)]) {
                        [convVC cancel];
                    }
                }
                
                self.stateMachineObj.tabIndex = 0;
                [self.engObj notifyUI:notifDic];
            }
                break;
                
            case NOTIFY_IVMSG:
            {
                self.stateMachineObj.tabIndex = 2;
                KLog(@"Goto conversation screen");
                [self gotoConversationScreen];
            }
                break;
                
            default:
                EnLogd(@"***ERROR*** Unknown event");
                break;
        }
    }
}

-(void)gotoConversationScreen
{
    BaseUI* vc = (InsideConversationScreen*)[self getCurrentViewController];
    KLog(@"### vc= %@",vc);
    
    if(vc && [vc isKindOfClass:[UIAlertController class]]) {
        KLog(@"##### alertController");
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
    
    if(vc && [vc isKindOfClass:[InsideConversationScreen class]] ) {
        KLog(@"###### Chat screen alread present");
    }
    
    if(!self.chatScreenPushed) {
        KLog(@"Push the chat screen.");
        BaseUI* curVC = (InsideConversationScreen*)[self.stateMachineObj getCurrentUI];
        if(curVC && [curVC isKindOfClass:[InsideConversationScreen class]] &&
           [curVC respondsToSelector:@selector(dismissViewController)]) {
            KLog(@"#dismissViewController of InsideConversationScreen");
            [curVC dismissViewController];
        }
        [self createChatScreen];
    } else {
        KLog(@"Chat screen was already pushed.");
    }
}

-(void) createChatScreen {
    
    KLog(@"#createChatScreen");
    BaseUI* uiConversation = [[InsideConversationScreen alloc]initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    UINavigationController *currentVC = self.tabBarController.selectedViewController;
    [currentVC pushViewController:uiConversation animated:NO];
    
    self.chatScreenPushed = TRUE;
}

+(void)setCurrentChatUserFromNotificationPayload:(NSDictionary*)notificationDic
{
    NSString* groupId = [notificationDic valueForKey:@"group_id"];
    NSMutableDictionary* currentChatUser = [[NSMutableDictionary alloc]init];
    if(groupId.length)
    {
        //get group info and set current chat user
        NSArray* groupContactData = [[Contacts sharedContact]getContactForPhoneNumber:groupId];
        if(groupContactData != Nil && [groupContactData count] > 0)
        {
            ContactDetailData* detail = [groupContactData objectAtIndex:0];
            ContactData* data = detail.contactIdParentRelation;
            [currentChatUser setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
            [currentChatUser setValue:GROUP_TYPE forKey:CONVERSATION_TYPE];
            [currentChatUser setValue:data.groupId forKey:FROM_USER_ID];
            [currentChatUser setValue:@"0" forKey:REMOTE_USER_IV_ID];
            [currentChatUser setValue:data.contactName forKey:REMOTE_USER_NAME];
            [currentChatUser setValue:[IVFileLocator getNativeContactPicPath:data.contactPic] forKey:REMOTE_USER_PIC];
        }
        else
        {
            [currentChatUser setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
            [currentChatUser setValue:GROUP_TYPE forKey:CONVERSATION_TYPE];
            [currentChatUser setValue:groupId forKey:FROM_USER_ID];
            [currentChatUser setValue:groupId forKey:REMOTE_USER_NAME];
        }
    }
    else
    {
        NSString* remoteUserIvId = [notificationDic valueForKey:@"user_id"];
        NSString* phoneNumber = [notificationDic valueForKey:@"ph"];
        if(remoteUserIvId.length)
        {
            //get contact from iv id and set the current chat
            NSNumber* ivID = [NSNumber numberWithLong:[remoteUserIvId longLongValue]];
            NSArray* contactDetailArray = [[Contacts sharedContact]getContactForIVUserId:ivID usingMainContext:YES];
            if(contactDetailArray && contactDetailArray.count > 0)
            {
                ContactDetailData* detail = [contactDetailArray objectAtIndex:0];
                [currentChatUser setValue:detail.contactDataValue forKey:FROM_USER_ID];
                [currentChatUser setValue:detail.contactIdParentRelation.contactName forKey:REMOTE_USER_NAME];
                [currentChatUser setValue:[IVFileLocator getNativeContactPicPath:detail.contactIdParentRelation.contactPic] forKey:REMOTE_USER_PIC];
                [currentChatUser setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
                [currentChatUser setValue:remoteUserIvId forKey:REMOTE_USER_IV_ID];
            }
            else
            {
                NSArray* msgs = [notificationDic objectForKey:API_MSGS];
                NSString* senderId = @"";
                if(1==msgs.count) {//Will server send multiple msg objects?
                    NSDictionary* msgDic = [msgs objectAtIndex:0];
                    senderId = [msgDic valueForKey:API_SENDER_ID];
                }
                
                [currentChatUser setValue:phoneNumber forKey:FROM_USER_ID];
                [currentChatUser setValue:remoteUserIvId forKey:REMOTE_USER_IV_ID];
                if(senderId.length)
                    [currentChatUser setValue:senderId forKey:REMOTE_USER_NAME];
                else
                    [currentChatUser setValue:phoneNumber forKey:REMOTE_USER_NAME];
                [currentChatUser setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
            }
        }
        else
        {
            //get contact from phone number and set the current chat
            NSArray* contactData = [[Contacts sharedContact]getContactForPhoneNumber:phoneNumber];
            [currentChatUser setValue:phoneNumber forKey:FROM_USER_ID];
            [currentChatUser setValue:@"0" forKey:REMOTE_USER_IV_ID];
            [currentChatUser setValue:phoneNumber forKey:REMOTE_USER_NAME];
            [currentChatUser setValue:VSMS_TYPE forKey:REMOTE_USER_TYPE];
            if(contactData.count)
            {
                ContactDetailData* detail = [contactData objectAtIndex:0];
                ContactData* data = detail.contactIdParentRelation;
                [currentChatUser setValue:data.contactName forKey:REMOTE_USER_NAME];
                [currentChatUser setValue:[IVFileLocator getNativeContactPicPath:data.contactPic] forKey:REMOTE_USER_PIC];
            }
        }
    }
    //CMP [[Engine sharedEngineObj]setCurrentChatUser:currentChatUser];
    [[UIDataMgt sharedDataMgtObj]setCurrentChatUser:currentChatUser];
    [AppDelegate unhideCurrentChatUser:notificationDic];
}

+(void)unhideCurrentChatUser:(NSDictionary*)notificationDic
{
    NSArray* hiddenListFromSettings = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"HIDDEN_TILES"];
    NSMutableArray* hiddenList = [[NSMutableArray alloc]init];
    if(hiddenListFromSettings && [hiddenListFromSettings count])
        [hiddenList addObjectsFromArray:hiddenListFromSettings];
    
    if( ![hiddenList count] )
        return;
    
    NSString* remoteUserID = nil;
    NSString* groupId = [notificationDic valueForKey:@"group_id"];
    if(groupId.length) {
        remoteUserID = groupId;
    } else {
        remoteUserID = [notificationDic valueForKey:@"user_id"];
        if(!remoteUserID || ![remoteUserID length] || [remoteUserID isEqualToString:@"0"])
            remoteUserID = [notificationDic valueForKey:@"ph"];
    }
    if([hiddenList containsObject:remoteUserID]) {
        [hiddenList removeObject:remoteUserID];
        [[ConfigurationReader sharedConfgReaderObj]setObject:hiddenList forTheKey:@"HIDDEN_TILES"];
    }
}

-(void)setRecordingPause
{
    if(recordingPause)
    {
        BaseConversationScreen *base = (BaseConversationScreen*)[self.stateMachineObj getCurrentUI];
        [base setIsRecordingPause:TRUE];
    }
}

-(NSMutableDictionary*)stopRecordingAndSave
{
    NSMutableDictionary *dic = nil;
    BaseConversationScreen *base = (BaseConversationScreen*)[self.stateMachineObj getCurrentUI];
    if(![base isKindOfClass:[InsideConversationScreen class]]) {
        return nil;
    }
    
    if(base.audioObj.isRecord || recordingPause)
    {
        dic = [[NSMutableDictionary alloc] init];
        [dic setValue:AUDIO_TYPE forKey:MSG_CONTENT_TYPE];
        [dic setValue:[base.audioObj stopAndGetRecordedFilePath] forKey:MSG_CONTENT];
    }
    else
    {
        NSString *textMsg  = [base getTextFieldValue];
        if(textMsg != nil && [textMsg length]>0)
        {
            dic = [[NSMutableDictionary alloc] init];
            [dic setValue:textMsg forKey:MSG_CONTENT];
            [dic setValue:TEXT_TYPE forKey:MSG_CONTENT_TYPE];
        }
        [base removeTextFromTheTextField];
    }
    return dic;
}

#pragma mark -- Watch Kit Extension
/*
-(void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply
{
    NSString* theCommand = [userInfo valueForKey:@"theRequestString"];
    KLog(@"Request Notification: %@",userInfo);
    NSString* phoneNumber = [userInfo valueForKey:@"PHONE"];
    if(phoneNumber.length || theCommand.length)
    {
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
        {
            __block UIBackgroundTaskIdentifier background_task; //Create a task object
            
            background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
                [application endBackgroundTask: background_task]; //Tell the system that we are done with the tasks
                background_task = UIBackgroundTaskInvalid; //Set the task to be invalid
            }];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //Perform your tasks that your application requires
                [Common callWithNumberWithoutPrompt:phoneNumber];
                NSDictionary* response = @{@"PHONE":phoneNumber,@"STATUS":@"SUCCESS",@"STATE":@"BACKGROUND"};
                reply(response);
                
                [application endBackgroundTask: background_task]; //End the task so the system knows that you are done with what you need to perform
                background_task = UIBackgroundTaskInvalid; //Invalidate the background_task
            });
        }
        else
        {
            [Common callWithNumberWithoutPrompt:phoneNumber];
            NSDictionary* response = @{@"PHONE":phoneNumber,@"STATUS":@"SUCCESS",@"STATE":@"FOREGROUND"};
            reply(response);
        }
    }
}*/


/////////////////////////////////
#pragma mark - Singleton Access

+ (NSManagedObjectContext *)sharedMainQueueContext
{
    //return [self mainQueueContext];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        KLog(@"mainQueueContext");
        _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainQueueContext.persistentStoreCoordinator = [[CoreDataSetup sharedCoredDataSetup] persistentStoreCoordinator];
    });
    return _mainQueueContext;
}

+ (NSManagedObjectContext *)sharedPrivateQueueContext
{
    //return [self privateQueueContext];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        KLog(@"privateQueueContext");
        _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateQueueContext.persistentStoreCoordinator = [[CoreDataSetup sharedCoredDataSetup] persistentStoreCoordinator];
    });
    return _privateQueueContext;
}

#pragma mark - Getters
/*
 - (NSManagedObjectContext *)mainQueueContext
 {
 if (!_mainQueueContext) {
 KLog(@"mainQueueContext");
 _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
 _mainQueueContext.persistentStoreCoordinator = [[CoreDataSetup sharedCoredDataSetup] persistentStoreCoordinator];
 }
 return _mainQueueContext;
 }
 
 - (NSManagedObjectContext *)privateQueueContext
 {
 if (!_privateQueueContext) {
 KLog(@"privateQueueContext");
 _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
 _privateQueueContext.persistentStoreCoordinator = [[CoreDataSetup sharedCoredDataSetup] persistentStoreCoordinator];
 }
 return _privateQueueContext;
 }*/

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSavePrivateQueueContext:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[AppDelegate sharedPrivateQueueContext]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSaveMainQueueContext:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[AppDelegate sharedMainQueueContext]];
    }
    return self;
}

#pragma mark - Notifications

- (void)contextDidSavePrivateQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [[AppDelegate sharedMainQueueContext] performBlock:^{
            [[AppDelegate sharedMainQueueContext] mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (void)contextDidSaveMainQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [[AppDelegate sharedPrivateQueueContext] performBlock:^{
            [[AppDelegate sharedPrivateQueueContext] mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
/////////////////////////////////

-(UIViewController*) getCurrentViewController {
    
    UIViewController *vc = [self.window.rootViewController presentedViewController];
    return vc;
}

-(UINavigationController*)getNavController {
    return navController;
}

-(void)setNavController:(UINavigationController *)newController {
    navController = newController;
}

#pragma mark PushKit -- VOIP Regisration
/*
 Registers for VoIP notifications
 */
- (void) registerForVOIPPush
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    // Create a push registry object
    self.voipRegistry = [[PKPushRegistry alloc] initWithQueue: mainQueue];
    // Set the registry's delegate to self
    self.voipRegistry.delegate = self;
    // Set the push type to VoIP and place an async request for voip
    self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

#pragma mark PushKit -- PKPushRegistryDelegate

/*
 Notifies that a push token has been invalidated
 */
-(void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    KLog(@"PushKit: PushKit Token invalidated");
    EnLogd(@"PushKit: PushKit Token invalidated");
    dispatch_async(dispatch_get_main_queue(), ^{
        /* Clear the VOIP token in user settings
         Remove binding (deREGISTER) with the proxy server. Specify Expires:0 in REGISTER request
         */
        [[Setting sharedSetting]setDeviceInfoWithVoipToken:@""];
    });
}

/*
 - Notifies when the push credentials have been updated
 - Registers VoIP push token (a property of PKPushCredentials) with the server
 */
-(void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type {
    
    KLog(@"PushKit: VOIP token %@",credentials.token);
    EnLogd(@"PushKit: VOIP token %@",credentials.token);
    dispatch_async(dispatch_get_main_queue(), ^{
        /* - Remove -, < and > chars from token
         - Save the latest token in UserSettings persistently
         - Notifies the push token to the server
         - Set contact URI param for SIP REGISTER request
         The main use case for this function is provide the proxy additional information regarding the user agent, like for example unique identifier or apple push id.
         As an example, the contact address in the SIP register sent will look like <sip:joe@15.128.128.93:50421;apple-push-id=43143-DFE23F-2323-FA2232>.
         */
        KLog(@"PushKit: New voip token:\n%@", credentials.token);
        NSString *tokenStr = [[NSString alloc] initWithFormat:@"%@",credentials.token];
        tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *hyphens = @"<>";
        NSCharacterSet *hyphensCharSet = [NSCharacterSet characterSetWithCharactersInString:hyphens];
        tokenStr = [[tokenStr componentsSeparatedByCharactersInSet:hyphensCharSet] componentsJoinedByString:@""];
        KLog(@"PushKit: New voip token:(space,<,> removed):\n%@",tokenStr);
        EnLogd(@"PushKit: New voip token:(space,<,> removed):\n%@",tokenStr);
        
        NSString *voipSecureKey = [self.confgReader getVoipPushToken];
        KLog(@"PushKit: Cached voip token =\n%@",voipSecureKey);
        EnLogd(@"PushKit: Cached voip token =\n%@",voipSecureKey);
        
        if(nil == voipSecureKey || ![voipSecureKey isEqualToString:tokenStr] || self.sendVoipKey)
        {
            if([self.confgReader getIsLoggedIn]) {
                KLog(@"PushKit: *** Calling setDeviceInfo");
                EnLogd(@"PushKit: *** Calling setDeviceInfo");
                [[Setting sharedSetting]setDeviceInfoWithVoipToken:tokenStr];
                self.sendVoipKey = NO;
            }
        } else {
            KLog(@"PushKit: *** New and Cached voip tokens are same.");
            EnLogd(@"PushKit: *** New and Cached voip tokens are same.");
        }
    });
}

/*
 Handles incoming VOIP push notification
 */
-(void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    
    KLog(@"PushKit: Incoming VOIP notification: %@",payload.dictionaryPayload);
    EnLogd(@"PushKit: Incoming VOIP notification: %@",payload.dictionaryPayload);
    /* - Process the notification
     - Call SIP REGISTERATION request
     - Upon Registration success, report an incoming call to CXProvider
     - Create UUID and CXCallUpdate object to uniquely identify the call and the caller, and pass them both to the
     provider using the reportNewIncomingCallWithUUID:update:completion:  method.
     */
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self processVoipPushNotification:payload.dictionaryPayload];
        });
    }
}

-(void)processVoipPushNotification:(NSDictionary*)userInfo {
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSString *callId = [aps objectForKey:@"call_id"];
    NSString *toNumber = [aps objectForKey:@"to_phone"];
    NSString *mcReason = [aps objectForKey:@"reason"];
    
    [self updateMissedCallReasonFor:toNumber WithReason:mcReason];
    
    //TODO: later -- use VOIP push for new iv msg notifications
#ifdef VOIP_PN_FOR_NEW_MSG
    NSDictionary* alert = [aps objectForKey:@"alert"];
    NSString* category = [aps objectForKey:@"category"];
    if(nil != alert && nil != category) {
        [self processNewMessageNotification:userInfo];
    }
    else
#endif
    {
        [NSNotificationCenter.defaultCenter postNotificationName:kVOIPCallReceived
                                                          object:self
                                                        userInfo:nil];
        
        KLog(@"processVoipPushNotification: call_id = %@",callId);
        if (linphone_core_get_calls(LC) == NULL) { // if there are calls, obviously our TCP socket shall be working
            
            [self getVoipInfoFromVoipPush:aps];
            [self.lphoneCoreSettings setRegAttempt:1];//TODO 1
            [LinphoneManager.instance setUserAgentString];
            KLog(@"Call refreshRegister: YES");
            [self.lphoneCoreSettings refreshRegister:YES];
            
            if (!linphone_core_is_network_reachable(LC)) {
                LinphoneManager.instance.connectivity = none; //Force connectivity to be discovered again
                [LinphoneManager.instance setupNetworkReachabilityCallback];
            }
            if(callId.length) {
                [LinphoneManager.instance addPushCallId:callId pushPayload:userInfo];
            }
        }
        
        if (callId && [self addLongTaskIDforCallID:callId]) {
            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive &&
                index > 0) {
                [LinphoneManager.instance startPushLongRunningTask:FALSE callId:callId];
                //OCT 2017 [self fixRing];
            }
        }
        
        if(callId.length) {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithDictionary:aps];
            long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * SIZE_1000);
            NSNumber *date = [NSNumber numberWithLongLong:milliseconds];
            [dic setValue:date forKey:PN_RECIEVED_AT];
            [LinphoneManager.instance addToNumber:callId pushPayload:dic];
        } else {
            EnLogd(@"Call-id is not present in PN. Fix it.");
        }
    }
}

-(void)updateMissedCallReasonFor:(NSString*)toNumber  WithReason:(NSString*) reason {
    
    if(toNumber.length && reason.length) {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        [dic setValue:toNumber forKey:NATIVE_CONTACT_ID];
        [dic setValue:reason forKey:API_MISSEDCALL_REASON];
        [self.engObj updateMissedCallReason:dic];
    } else {
        KLog(@"toNumber:%@, reason:%@",toNumber, reason);
        if(toNumber.length<=0) {
            EnLogd(@"ERROR: to_number is missing");
        }
        if(reason.length<=0) {
            EnLogd(@"ERROR: reason is missing");
        }
    }
}

- (BOOL)addLongTaskIDforCallID:(NSString *)callId {
    NSDictionary *dict = LinphoneManager.instance.pushDict;
    if ([[dict allKeys] indexOfObject:callId] != NSNotFound) {
        return FALSE;
    }
    
    LOGI(@"Adding long running task for call id : %@ with index : 1", callId);
    [dict setValue:[NSNumber numberWithInt:1] forKey:callId];
    return TRUE;
}

/*
 Returns 1, on success.
 Returns 0, otherwise.
 */
-(NSInteger) getVoipInfoFromVoipPush:(NSDictionary*)aps {
    
    /*
     voipInfo would be: ipaddress = "ip_address:udp:port:tcp:port:tcp|udp"
     last value indicates proto that should be used at first.
     ex: "54.148.51.116:udp:5060:tcp:5228:tcp"
     */
    NSString* voipInfo = [aps objectForKey:@"ipaddress"];
    if(voipInfo.length) {
        return ([self.lphoneCoreSettings setVoipInfoFromPN:voipInfo]);
    }
    
    KLog(@"***ERR:No ipaddress key found");
    return 0;
}

#pragma mark -
#pragma mark process new message

-(void)processNewMessageNotification:(NSDictionary*)userInfo {
    
    // Schedule the notification
    /*
     KLog(@"processNewMessageNotification:%@",userInfo);
     NSDictionary *aps = [userInfo objectForKey:@"aps"];
     NSString* body = [aps valueForKeyPath:@"alert.body"];
     NSInteger badge = [[aps objectForKey:@"badge"]integerValue];
     KLog(@"badge:%ld",(long)badge);
     
     UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
     //content.title = NSLocalizedString(@"InstaVoice", nil);
     content.body = body;
     content.sound = [UNNotificationSound soundNamed:@"InstavoiceNotificationTone.caf"];
     content.categoryIdentifier = @"ivMsg";
     content.userInfo = userInfo;
     UNNotificationRequest *req =
     [UNNotificationRequest requestWithIdentifier:@"NewMsg" content:content trigger:NULL];
     [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:req
     withCompletionHandler:^(NSError *err){
     }];
     
     */
    //- Process notification payload for new messages
    {
        /*
         KLog(@"Push Notification. userInfo = %@", userInfo);
         EnLogd(@"Push Notification. userInfo = %@", userInfo);
         
         NSMutableDictionary* notifDic = [[NSMutableDictionary alloc]initWithDictionary:userInfo];
         int msgType = [self checkPNForVoiceMailOrMissedCall:notifDic];
         
         BOOL showNotification = TRUE;
         NSMutableDictionary* alert = [userInfo valueForKeyPath:@"aps.alert"];
         if(userInfo && userInfo.count && [alert count] && addMessageHeader) {
         [self.engObj addMessageHeaderIntoTable:userInfo];
         } else {
         showNotification = FALSE;
         KLog(@"Not a new msg");
         }
         addMessageHeader = YES;
         
         NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:userInfo];
         
         if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
         {
         KLog(@"UIApplicationStateActive");
         EnLogd(@"UIApplicationStateActive");
         
         [[MQTTManager sharedMQTTManager]processAPNSPushNotificationData:dic showOnBar:NO];
         }
         else if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
         {
         KLog(@"UIApplicationStateBackground Notification Dic: %@",[userInfo valueForKeyPath:@"aps.alert.body"]);
         EnLogd(@"UIApplicationStateBackground Notification Dic: %@",[userInfo valueForKeyPath:@"aps.alert.body"]);
         
         [[Conversations sharedConversations]fetchMessageFromServerInBackgroundWithNotification:userInfo fetchCompletionHandler:nil];
         }*/
    }
    //
}

#pragma mark VoipSettingDelegate

-(void)fetchVoipSettingCompletWith:(SettingModelVoip *)info withFetchStatus:(BOOL)fetchStatus {
    
    KLog(@"VOIP info=%@, fetchStatus=%d",info,fetchStatus);
    EnLogd(@"VOIP info=%@, fetchStatus=%d",info,fetchStatus);
     dispatch_async(dispatch_get_main_queue(), ^{
         if(fetchStatus) {
             KLog(@"getVoipSetting succeeded.");
             if (linphone_core_get_calls_nb(LC) >= 1) {
                 EnLogd(@"There is ongoing call, ignore the voip info.");
             } else {
                 if([self.confgReader getIsLoggedIn]) {
                     EnLogd(@"call setVoipInfo");
                     [self.lphoneCoreSettings setVoipInfo:info];
                     [self.lphoneCoreSettings setRegAttempt:1];
                     [LinphoneManager.instance setUserAgentString];
                     KLog(@"Call refreshRegister:YES");
                     [self.lphoneCoreSettings refreshRegister:YES];
                 }
             }
         } else {
             KLog(@"getVoipSetting failed.");
             EnLogd(@"getVoipSetting failed.");
         }
     });
}

#pragma mark -
#pragma mark STUN request

-(void)sendDataToStunServer {
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
        KLog(@"STUN request to find public IP and port");
        [self.lphoneCoreSettings setNatType:NATType_unknown];
        // request public IP and Port through STUN
        [stunClient stopSendIndicationMessage];
        udpSocket = nil;
        stunClient = nil;
        stunClient = [[STUNClient alloc] init];
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:stunClient delegateQueue:dispatch_get_main_queue()];
        [stunClient requestPublicIPandPortWithUDPSocket:udpSocket delegate:self];
    }
}

#pragma mark -
#pragma mark STUNClientDelegate

-(void)didReceivePublicIPandPort:(NSDictionary *) data {
    
    NSString* publicIPAddr = [data objectForKey:publicIPKey];
    NSString* publicPort = [data objectForKey:publicPortKey];
    BOOL portRandmization = [[data objectForKey:isPortRandomization]boolValue];
    
    KLog(@"Public IP=%@, public Port=%@, NAT is Symmetric: %d", publicIPAddr, publicPort, portRandmization);
    EnLogd(@"Public IP=%@, public Port=%@, NAT is Symmetric: %d",publicIPAddr, publicPort, portRandmization);
    
    NATType type = NATType_unknown;
    if(portRandmization>0)
        type = NATType_symmetric;
    else
        type = NATType_nonSymmetric;
    
    //type = NATType_nonSymmetric;//Debug
    [self.lphoneCoreSettings setNatType:type];
    
    //July 23, 2018
    [self.lphoneCoreSettings setPublicIPAddr:publicIPAddr];
    [self.lphoneCoreSettings setPublicPort:publicPort];
    //
    
    /*
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"result" message:[data description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
     [alert show];
     [stunClient startSendIndicationMessage];
     */
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [stunClient stopSendIndicationMessage];
        udpSocket = nil;
        stunClient = nil;
    });
}
#pragma mark -

- (void)canSignout
{
    
    NSString* alertDetails = [NSString stringWithFormat:@"If you don’t want to use ReachMe, please go to settings and deactivate any active service(s) before logging out.\n\nAre you sure you want to log out?"];
    
    UIAlertController *alertController =   [UIAlertController
                                            alertControllerWithTitle:@"Logout?"
                                            message:NSLocalizedString(alertDetails, nil)
                                            preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *alertMessage = [[NSMutableAttributedString alloc] initWithString:alertDetails];
    [alertMessage addAttribute:NSFontAttributeName
                         value:[UIFont systemFontOfSize:16.0]
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
                              actionWithTitle:NSLocalizedString(@"Ok", nil)
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self signout];
                                  [alertController dismissViewControllerAnimated:YES completion:nil];
                              }];
    
    [alertController addAction:turnOff];
    [alertController addAction:cancel];
    [self.window.rootViewController  presentViewController:alertController animated:YES completion:nil];
    [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
}

//TODO -- make this method in common file
- (void)signout {
    
    [LinphoneManager.instance resetUserAgentString];
#ifdef MQTT_ENABLED
    [[MQTTManager sharedMQTTManager]disconnectMQTTClient];
#endif
    
    __block MBProgressHUD* progressBar = [[MBProgressHUD alloc] initWithView:self.window];
    
    int newtworkCkeck = [Common isNetworkAvailable];
    if(newtworkCkeck == NETWORK_AVAILABLE)
    {
        [self.window addSubview:progressBar];
        [progressBar show:YES];
        NSMutableDictionary *signOutDic = [[NSMutableDictionary alloc]init];
        SignOutAPI* api = [[SignOutAPI alloc]initWithRequest:signOutDic];
        [api callNetworkRequest:signOutDic withSuccess:^(SignOutAPI *req, NSMutableDictionary *responseObject) {
            
            [progressBar hide:YES];
            [progressBar removeFromSuperview];
            KLog(@"SignOut success");
            [self.engObj clearNetworkData];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
            [self.engObj cancelEvent];
            [self.confgReader setIsLoggedIn:FALSE];
            [self.confgReader setUserSecureKey:@""];
            [self.confgReader setPassword:@"" withTime:nil];
            [self.confgReader removeValueForKey:LAST_MSG_UPDATE_FROM_CONTACT_TIME];
            [self.confgReader removeValueForKey:ENABLE_LOG_FLAG];
            [self.confgReader setVoipPushToken:@""];
            [self.confgReader setCloudSecureKey:@""];
            [self.confgReader setIVUserId:-1];
            navController.navigationBarHidden = YES;
            
            NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: navController.viewControllers];
            [navigationArray removeAllObjects];
            [self.tabBarController removeFromParentViewController];
            
            self.window.rootViewController = [[UIStateMachine sharedStateMachineObj]getRootViewController];
            
            //Clear the carrier list.
            [[Setting sharedSetting]clearCarrierList];
            
            //Delete the promoimage
            NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            NSString* localFileName = [NSString stringWithFormat:@"PromoImage_%@.png",loginId];
            [IVFileLocator deleteFileAtPath:[IVFileLocator getPromoImagePath:localFileName]];
            [self.confgReader removeObjectForTheKey:@"BLOCKED_TILES"];
            
        } failure:^(SignOutAPI *req, NSError *error) {
            [progressBar hide:YES];
            [progressBar removeFromSuperview];
            KLog(@"SignOut failed.");
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
            [self.engObj clearNetworkData];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
            [self.engObj cancelEvent];
            [self.confgReader setIsLoggedIn:FALSE];
            [self.confgReader setUserSecureKey:@""];
            [self.confgReader removeValueForKey:LAST_MSG_UPDATE_FROM_CONTACT_TIME];
            [self.confgReader removeValueForKey:ENABLE_LOG_FLAG];
            [self.confgReader setVoipPushToken:@""];
            [self.confgReader setCloudSecureKey:@""];
            [self.confgReader removeObjectForTheKey:@"BLOCKED_TILES"];
            [self.confgReader setIVUserId:-1];
            navController.navigationBarHidden = YES;
            self.window.rootViewController = [[UIStateMachine sharedStateMachineObj]getRootViewController];
        }];
    }
    else {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

/*
 It is not good to re-create the ProviderDelegate to set the newly selected ringtone.
 We can't change the Configuration object of CXProvider dynamically.
 In order to have the selected ring tone in use, we have to re-create the CXProvider object with new Configuration object.
 */
-(void)setRingTone
{
    KLog(@"setRingTone");
    [self.providerDelegate.provider invalidate];
    self.providerDelegate = [[ProviderDelegate alloc] init];
    [LinphoneManager.instance setProviderDelegate:self.providerDelegate];
    NSString* ringTone = Constants.RINGTONE_NAME;
    if ([self.confgReader isRingtoneSet])
        ringTone = nil;
    [self.providerDelegate config:ringTone];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (viewController == tabBarController.moreNavigationController)
    {
        self.isMoreTabClicked = YES;
    } else {
        self.isMoreTabClicked = NO;
    }
}

#pragma mark SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
        } else if (transaction.transactionState == SKPaymentTransactionStatePurchased && [self.confgReader getIsLoggedIn]) {
            
            if ([transaction.payment.productIdentifier hasPrefix:@"com.kirusa.ReachMe.reachme_"]) {// Identify ReachMe Credits product
                NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
                [requestDic setValue:[self.confgReader getCountryCode] forKey:@"country_code"];
                InAppPurchaseApi* availableProdcutAPI = [[InAppPurchaseApi alloc]initWithRequest:requestDic];
                [NetworkCommon addCommonData:requestDic eventType:FETCH_PURCHASE_PRODUCTS];
                [availableProdcutAPI callNetworkRequestToFetchProductList:requestDic withSuccess:^(InAppPurchaseApi *req, NSMutableDictionary *responseObject) {
                    NSArray *productLIst = [responseObject valueForKey:@"product_list"];
                    NSMutableDictionary *ivProduct = productLIst.lastObject;
                    NSData *dataReceipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
                    NSString *receipt = [dataReceipt base64EncodedStringWithOptions:0];
                    
                    NSMutableDictionary* responseDisc = [[NSMutableDictionary alloc]init];
                    [responseDisc setValue:receipt forKey:@"purchaseToken"];
                    [responseDisc setValue:transaction.transactionIdentifier forKey:@"ios_trans_id"];
                    
                    NSError *error;
                    NSData *receiptJSONData = [NSJSONSerialization dataWithJSONObject:responseDisc
                                                                              options:NSJSONWritingPrettyPrinted
                                                                                error:&error];
                    NSError *jsonError;
                    id receiptJSONType = [NSJSONSerialization JSONObjectWithData:receiptJSONData options:kNilOptions error:&jsonError];
                    NSMutableDictionary* purchaseProductReqDic = [[NSMutableDictionary alloc]init];
                    [purchaseProductReqDic setValue:[ivProduct valueForKey:@"product_id"] forKey:@"product_id"];
                    [purchaseProductReqDic setValue:@"AppleStore" forKey:@"purchase_source"];
                    [purchaseProductReqDic setValue:[ivProduct valueForKey:@"country_code"] forKey:@"country_code"];
                    [purchaseProductReqDic setValue:receiptJSONType forKey:@"purchase_app_response"];
                    
                    InAppPurchaseApi* purchaseAPI = [[InAppPurchaseApi alloc]initWithRequest:purchaseProductReqDic];
                    [NetworkCommon addCommonData:purchaseProductReqDic eventType:PURCHASE_PRODUCT];
                    [purchaseAPI callNetworkRequest:purchaseProductReqDic withSuccess:^(InAppPurchaseApi *req, NSMutableDictionary *responseObject) {
                        
                        NSString *vsmsLimitsJsonString = [responseObject valueForKey:@"vsms_limits"];
                        NSDictionary *vsmsInfo = [ReachMeUtility parseJSONToDictionaryWithInputString:vsmsLimitsJsonString];
                        NSNumber *vsmsLimit = [vsmsInfo valueForKey:@"limit"];
                        [self.confgReader setVsmsLimit: [vsmsLimit intValue]];
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                        
                    } failure:^(InAppPurchaseApi *req, NSError *error) {
                        if (error.code == 97) { //Duplicate Purchase
                            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                        }
                        NSLog(@"Error in PURCHASE_PRODUCT: %@", error.debugDescription);
                    }];
                    
                } failure:^(InAppPurchaseApi *req, NSError *error) {
                    NSLog(@"Error in FETCH_PURCHASE_PRODUCTS: %@", error.localizedDescription);
                }];
                
            } else if (transaction.payment.applicationUsername != nil && [self.confgReader getIsLoggedIn]) { //Subscription Product
                
                NSData *purchaseProductReqInfo = [transaction.payment.applicationUsername dataUsingEncoding:NSUTF8StringEncoding];
                NSMutableDictionary *purchaseProductReqDic = [[NSJSONSerialization JSONObjectWithData:purchaseProductReqInfo options:NSJSONReadingAllowFragments error:nil] mutableCopy];
                NSLog(@"Application Username = %@", purchaseProductReqDic);
                
                NSData *dataReceipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
                NSString *receipt = [dataReceipt base64EncodedStringWithOptions:0];
                NSMutableDictionary* responseDisc = [[NSMutableDictionary alloc]init];
                [responseDisc setValue:receipt forKey:@"purchaseToken"];
                [responseDisc setValue:transaction.transactionIdentifier forKey:@"ios_trans_id"];
                if (transaction.originalTransaction.transactionIdentifier == nil) {
                    [responseDisc setValue:transaction.transactionIdentifier forKey:@"ios_orig_trans_id"];
                } else {
                    [responseDisc setValue:transaction.originalTransaction.transactionIdentifier forKey:@"ios_orig_trans_id"];
                }
                NSError *error;
                NSData *receiptJSONData = [NSJSONSerialization dataWithJSONObject:responseDisc
                                                                          options:NSJSONWritingPrettyPrinted
                                                                            error:&error];
                NSError *jsonError;
                id receiptJSONType = [NSJSONSerialization JSONObjectWithData:receiptJSONData options:kNilOptions error:&jsonError];
                [purchaseProductReqDic setValue:receiptJSONType forKey:@"purchase_app_response"];
                
                InAppPurchaseApi* purchaseAPI = [[InAppPurchaseApi alloc]initWithRequest:purchaseProductReqDic];
                [NetworkCommon addCommonData:purchaseProductReqDic eventType:VIRTUALNUMBER_SUBSCRIPTION];
                [purchaseAPI callNetworkRequest:purchaseProductReqDic withSuccess:^(InAppPurchaseApi *req, NSMutableDictionary *responseObject) {
                    
                    NSString *purchasedNumber = [responseObject valueForKey:@"virtual_num"];
                    NSLog(@"%@ purchased", purchasedNumber);
                    
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    
                } failure:^(InAppPurchaseApi *req, NSError *error) {
                    if (error.code == 97) { //Duplicate Purchase
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    } else if (error.code == 9008) { //Validation Failed
                        [ScreenUtility showAlert:[error.userInfo valueForKey:@"error_reason"]];
                    }
                    NSLog(@"Error in PURCHASE_PRODUCT: %@", error.debugDescription);
                }];
                
            } else  {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
        }
    }
}

@end

#pragma mark UINavigationController releated
@implementation UINavigationController (OrientationSettings_IOS6)

-(BOOL)shouldAutorotate {
    //CMP return [[self.viewControllers lastObject] shouldAutorotate];
    
    UIViewController* vc = [self.viewControllers lastObject];
    if(!vc)
        return FALSE;
    
    return  [vc shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations {
    //CMP return [[self.viewControllers lastObject] supportedInterfaceOrientations];
    
    UIViewController* vc = [self.viewControllers lastObject];
    if(!vc) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return [vc supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    //CMP return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
    
    UIViewController* vc = [self.viewControllers lastObject];
    if(!vc) {
        return UIDeviceOrientationPortrait;
    }
    return [vc preferredInterfaceOrientationForPresentation];
}

#pragma mark -
#pragma mark - Settings Protocol Related Methods -
- (void)fetchSettingCompletedWith:(SettingModel*)modelData withFetchStatus:(BOOL)withFetchStatus {
    
    if(withFetchStatus) {
        //Update the location status - YES
        NSUserDefaults *standarDefaults = [NSUserDefaults standardUserDefaults];
        BOOL locationUpdateStatus = [[standarDefaults valueForKey:kUserLocationAccessPermissionStatus]boolValue];
        if (locationUpdateStatus) {
            [[Setting sharedSetting]updateUserSettingType:SettingTypeDisplayLocation andValue:locationUpdateStatus];
        }
    }
}
- (void)updateSettingCompletedWith:(SettingModel*)modelData withUpdateStatus:(BOOL)withUpdateStatus {
    if(withUpdateStatus)
        KLog(@"Location status updated");
}

@end