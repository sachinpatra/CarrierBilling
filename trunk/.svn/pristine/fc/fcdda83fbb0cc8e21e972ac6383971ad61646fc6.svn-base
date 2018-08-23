//
//  AppDelegate.m
//  InstaVoice
//
//  Created by EninovUser on 06/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatGridViewController.h"
#import "CallsViewController.h"
#import "VoiceMailViewController.h"
#import "FriendsScreen.h"
#import "NotificationIds.h"
#import "NotificationBar.h"
#import "Reachability.h"
#import "UIType.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Logger.h"
#import "ImgMacro.h"
#import "InsideConversationScreen.h"
#import "MyNotesScreen.h"
#import "MyVoboloScreen.h"
#import "CreateNewSingleChatViewController.h"
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
#import "AppUpdateUtility.h"
#import "IVFileLocator.h"
#import "ChatActivity.h"
#import "MQTTManager.h"
#import "IVColors.h"
#import "Conversations.h"
//#import "IVAudioLoader.h"

//Settings Related
#import "IVSettingsListViewController.h"

//Related to crashlytics.
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "IVPrimaryNumberVoiceMailViewController.h"
#import "IVLinkedNumberVoiceMailViewController.h"
#import "IVSettingsAboutInstaVoiceViewController.h"
#import "RateUsViewController.h"
#import "InviteFriendsViewController.h"
#import <Intents/Intents.h>

#import "NetworkCommon.h"
#import "InAppPurchaseApi.h"
#import "InstaVoice-Swift.h"

#define LOGFILENAME @"KirusaLog.txt"
#define LAUNCHIMG_TIME  3.0
#define NON_RETINA_IPHONE_HEIGHT  480
#define SPLASH_SCREEN_TIME     3.0
#define kMoreTableCellBottonSpacePadding 20.0
#define kMoreTableCellTopSpacePadding 20.0

#define kNumberOfHoursForSendingiCloudKey  20*60 //20 hours, converted into minutes - 1 hour = 60 mins, so 20*60

@interface AppDelegate () <SettingProtocol>

@property (strong, nonatomic) UIView *redBackgroundView;
@property (nonatomic, strong) NSDate *registerForRemoteNotificationDate;
@property (nonatomic, strong) IVSettingsListViewController *settingsListViewController;
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
- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    //Temporary Commented Because of textview overlapping issue in ios8 when record button tapped
    //[self callConnected:YES];
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
    
    self.confgReader = [ConfigurationReader sharedConfgReaderObj];
    if([self.confgReader getEnableLogFlag]) {
        KLog(@"Enable log");
        logInit(@"KirusaLog.txt",true);
        setLogLevel(DEBUG);
    }
    
    KLog(@"Launch Options =%@", launchOptions);
    EnLogd(@"Launch Options =%@", launchOptions);
    
    //Crashlytics related
#ifndef ENABLE_NSLOG
    KLog(@"**** LOG ENABLED ****");
    [Fabric with:@[[Crashlytics class]]];
#endif
    
    [Contacts sharedContact];
    
    //output what state the app is in. This will be used to see when the app is started in the background
    KLog(@"app launched with state : %li", (long)application.applicationState);
    KLog(@"FINISH LAUNCHING WITH OPTION : %@", launchOptions.description);
    
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
    
    //Check for showing branding screen
    if([Common showBrandingScreenViewController]) {
        self.window.rootViewController=[[BrandingScreenViewController alloc]init];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self navigationAndNotificationWork:remoteNotif];
        });
    }
    else
        [self navigationAndNotificationWork:remoteNotif];
    
    [self clearNotificationList];
    [self.engObj purgeOldData];
    
    if([self.confgReader getIsLoggedIn]) {
        //[self setLocationInfo];
        [self registerForPushNotification];
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [self.engObj fetchMsgRequest:nil];
    
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
    
    return YES;
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
    
    ChatGridViewController *chatsController = [[ChatGridViewController alloc] initWithNibName:@"ChatGridViewController" bundle:[NSBundle mainBundle]];
    CallsViewController *callsController = [[CallsViewController alloc] initWithNibName:@"CallsViewController" bundle:[NSBundle mainBundle]];
    VoiceMailViewController *voiceMailController = [[VoiceMailViewController alloc] initWithNibName:@"VoiceMailViewController" bundle:[NSBundle mainBundle]];
    FriendsScreen *friendsController = [[FriendsScreen alloc] initWithNibName:@"FriendsScreen" bundle:[NSBundle mainBundle]];
    MyNotesScreen *notesController = [[MyNotesScreen alloc]initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    MyVoboloScreen *myVoboloScreen = [[MyVoboloScreen alloc] initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    RateUsViewController *rateUsController = [[RateUsViewController alloc] initWithNibName:@"RateUsViewController" bundle:nil];
    InviteFriendsViewController *inviteFriendsController = [[InviteFriendsViewController alloc] initWithNibName:@"InviteFriendsViewController" bundle:nil];
    
    UIStoryboard *settingsStorybaord = [UIStoryboard storyboardWithName:@"IVSettingsStoryBoard" bundle:[NSBundle mainBundle]];
    self.settingsListViewController = [settingsStorybaord instantiateInitialViewController];
    IVSettingsAboutInstaVoiceViewController *aboutHelpViewController = [[UIStoryboard storyboardWithName:@"IVSettingsStoryBoard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"About_Help"];
    
    
    // create the nav controlers for the tab view.
    UINavigationController *chatsNavController = [[UINavigationController alloc] initWithRootViewController:chatsController];
    UINavigationController *callsNavController = [[UINavigationController alloc] initWithRootViewController:callsController];
    UINavigationController *voiceMailNavController = [[UINavigationController alloc] initWithRootViewController:voiceMailController];
    UINavigationController *friendsNavController = [[UINavigationController alloc] initWithRootViewController:friendsController];
    UINavigationController *notesNavController = [[UINavigationController alloc] initWithRootViewController:notesController];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:self.settingsListViewController];
    UINavigationController *voboloNavController = [[UINavigationController alloc] initWithRootViewController:myVoboloScreen];
    UINavigationController *aboutHelpNavController = [[UINavigationController alloc] initWithRootViewController:aboutHelpViewController];
    UINavigationController *rateUsNavController = [[UINavigationController alloc] initWithRootViewController:rateUsController];
    UINavigationController *inviteFriendsNavController = [[UINavigationController alloc] initWithRootViewController:inviteFriendsController];
    
    //End
    
    
    // update the view controllers in the tab bar controller.
    // If Vobolo is enabled make the settings tab become "More" and contain the vobolos screenz
    BOOL flag = [[Setting sharedSetting] data].vbEnabled;
    if (flag) {
        
        //Start: Nivedita - Date 17th Feb - Changes related to :  In More Screen: Show Settings in the second row after My Blogs
        [tabBarController setViewControllers:@[callsNavController ,voiceMailNavController,chatsNavController,friendsNavController,notesNavController,voboloNavController,inviteFriendsNavController,rateUsNavController,settingsNavController,aboutHelpNavController]];
        //End: Nivedita
        
    } else {
        [tabBarController setViewControllers:@[callsNavController ,voiceMailNavController,chatsNavController,friendsNavController,notesNavController,inviteFriendsNavController,rateUsNavController,settingsNavController,aboutHelpNavController]];
    }
    
    tabBarController.customizableViewControllers = @[];
    
    UIColor *ivRed = [UIColor colorWithRed:233./255 green:88./255 blue:75./255 alpha:1];
    self.window.tintColor = ivRed;
    tabBarController.tabBar.tintColor = ivRed;
    
    self.tabBarController = tabBarController;
    
    // set the tab bar's delegate
    self.tabBarController.delegate = self;
    navController = chatsNavController;
    navController.navigationBar.translucent = YES;
    
    if(isLogin) {
        [[ConfigurationReader sharedConfgReaderObj]setShowContactUploadDlg:NO];
        self.window.rootViewController = tabBarController;
        if(![self.confgReader getContactServerSyncFlag]) {
            [[ConfigurationReader sharedConfgReaderObj]setShowContactUploadDlg:YES];
            [((UITabBarController *)self.window.rootViewController) setSelectedIndex:3];
            [self.tabBarController setSelectedViewController:friendsNavController];
        } else {
            [((UITabBarController *)self.window.rootViewController) setSelectedIndex:2];
            [self.tabBarController setSelectedViewController:chatsNavController];
        }
    }
    else {
        self.window.rootViewController = tabBarController;
        [[ConfigurationReader sharedConfgReaderObj]setShowContactUploadDlg:YES];
        [((UITabBarController *)self.window.rootViewController) setSelectedIndex:3];
        [self.tabBarController setSelectedViewController:friendsNavController];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    KLog(@"applicationWillResignActive");
    
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
    else if (currentUiType == CHAT_GRID_SCREEN) {
        BaseUI *currentUI = [self.stateMachineObj getCurrentUI];
        ChatGridViewController *chatGridScreen = (ChatGridViewController*)currentUI;
        [chatGridScreen stopAudioPlayback];
        KLog(@"Chat grid screen");
    }
}

- (void)prepareContacts {
    
    NSUserDefaults* groupSettings = [ConfigurationReader sharedSettingsForExtension];
    __block NSMutableArray* phoneNumbers = [groupSettings objectForKey:@"PHONE_NUMBERS"];
    __block NSMutableArray* contactNames = [groupSettings objectForKey:@"CONTACT_NAMES"];
    
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

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    KLog(@"applicationDidBecomeActive - START");
    EnLogd(@"applicationDidBecomeActive");
    
    [self.engObj getMissedCallList:TRUE];
    
    //TODO [self checkMicrphoneAccess];
    
#ifdef MQTT_ENABLED
    [[MQTTManager sharedMQTTManager] connectMQTTClient];
#endif
    
    if([self.confgReader getIsLoggedIn]) {
    
        NSString* devID = [self getDeviceID];
        NSString* screenName = [self.confgReader getScreenName];
        if(devID.length) {
            //- TODO: discuss with PM. Do not share user's mobile number into public domain
            //NSString* primaryNumber = [self.confgReader getLoginId];
            [CrashlyticsKit setUserIdentifier:devID];
        }
        if(screenName.length) {
            [CrashlyticsKit setUserName:screenName];
        }
    }
    
    if([self.confgReader getIsLoggedIn]) {
        addMessageHeader = YES;
    }
    
    [self detectCallState];
    [self.engObj sendAllPendingMsg];
    int currentUiType = [self.stateMachineObj getCurrentUIType];
    if(currentUiType == INSIDE_CONVERSATION_SCREEN || currentUiType == NOTES_SCREEN || currentUiType == MY_VOBOLO_SCREEN)
    {
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
    [self clearNotificationList];
    
    if(NOTES_SCREEN == [self.stateMachineObj getCurrentUIType]) {
        [self.engObj getMyNotes:NO];
    }
    else if(MY_VOBOLO_SCREEN == [self.stateMachineObj getCurrentUIType]) {
        [self.engObj getMyVoboloList:NO];
    }
    
    KLog(@"applicationDidBecomeActive - END");
}

-(NSString*) getDeviceID {
    
    SettingModelMqtt* mqttSetting = [[[Setting sharedSetting]data]mqttSetting];
    NSString* deviceID = [mqttSetting.deviceId stringValue];
    if(!deviceID || !deviceID.length)
        deviceID = @"unknown";
    
    return deviceID;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    KLog(@"applicationWillTerminate");

    [[ConfigurationReader sharedConfgReaderObj]setVoipSettingFetched:NO];
    
   
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
    
    if([self.confgReader getIsLoggedIn]) {
        [self registerForPushNotification];
    }
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

#pragma mark -
-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    KLog(@"continueUserActivity");
    /*
    INInteraction *interaction = userActivity.interaction;
    INStartAudioCallIntent *startAudioCallIntent = (INStartAudioCallIntent *)interaction.intent;
    INPerson *contact = startAudioCallIntent.contacts[0];
    INPersonHandle *personHandle = contact.personHandle;
    NSString *phoneNumber = personHandle.value;
    */
    return NO;
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

- (void)uiUpdateMoreViewController {
    return;
}


#pragma mark -- AppDelegate Local Methods

-(void)setLocationInfo
{
    isLogin = [self.confgReader getIsLoggedIn];
    if(isLogin)
    {
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
        }
    }
}

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
    
    if(nil == cloudSecureKey || ![cloudSecureKey isEqualToString:tokenStr]) {
        KLog(@"*** Calling setDeviceInfo");
        EnLogd(@"*** Calling setDeviceInfo");
        [[Setting sharedSetting]setDeviceInfo:tokenStr];
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

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    EnLogd(@"***ERROR: Failed to get token, error: %@", error);
    KLog(@"***ERROR: Failed to get token, error: %@", error);
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
    
    NSMutableDictionary* notifDic = [[NSMutableDictionary alloc]initWithDictionary:userInfo];
    int msgType = [self checkPNForVoiceMailOrMissedCall:notifDic];
    
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
            /* CMP
             if(syncFlag)
             {
             chat = [[ChatGridViewController alloc] initWithNibName:@"ChatGridViewController" bundle:nil];
             navController = [[UINavigationController alloc] initWithRootViewController:chat];
             [navController pushViewController:chat animated:NO];
             }
             else
             {
             friendScreen = [[FriendsScreen alloc] initWithNibName:@"FriendsScreen" bundle:nil];
             navController = [[UINavigationController alloc] initWithRootViewController:friendScreen];
             [navController pushViewController:friendScreen animated:NO];
             }*/
        }
    }
    else {
        KLog(@"Not logged-in");
        
        //- navController must not be nil
        navController = [[UIStateMachine sharedStateMachineObj]getRootViewController];
        self.window.rootViewController = navController;
        self.tabBarController.delegate = self;
    }
}

-(void)handleNotificationeBarClick:(NSDictionary*)notificationDic
{
    NSString *ivUserId = [notificationDic valueForKey:@"user_id"];
    NSString *myIvUserId = [[NSString alloc] initWithFormat:@"%ld",[self.confgReader getIVUserId]];
    if([ivUserId isEqualToString:myIvUserId])
    {
        ChatGridViewController *convScreen = [[ChatGridViewController alloc] initWithNibName:@"ChatGridViewController" bundle:nil];
        navController = [[UINavigationController alloc]initWithRootViewController:convScreen];
    }
    else
    {
        KLog(@"Goto conversation screen");
        [AppDelegate setCurrentChatUserFromNotificationPayload:notificationDic];
        [self gotoConversationScreen];
    }
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
    
    if([base isKindOfClass:[InsideConversationScreen class]]) {
        InsideConversationScreen* convScreen = (InsideConversationScreen*)base;
        if([convScreen respondsToSelector:@selector(cancel)])
            [convScreen cancel];
    }
}

-(void)actionOnNotificationBar:(NSDictionary*)payLoad isAppLaunched:(BOOL)fromBackground
{
    KLog(@"Notification Clicked");
    EnLogd(@"fromBackground:%@",fromBackground?@"YES":@"NO");
    
    //- If contact sync was not done earlier, goto friends screen
    if(fromBackground) {
        if(![self.confgReader getContactServerSyncFlag]) {
            UIViewController* rootVC = self.window.rootViewController;
            if([rootVC isKindOfClass:[BrandingScreenViewController class]]) {
                EnLogd(@"root view controller is now Branding screen.");
            }
            else {
                UITabBarController* tabBarController = (UITabBarController*)rootVC;
                if([tabBarController respondsToSelector:@selector(setSelectedIndex:)]) {
                    [tabBarController setSelectedIndex:3];
                } else {
                    EnLogd(@"*** Shouldn't happen. FIXME.");
                }
            }
        }
    }
    //
    
    //Start
    //HLR_ACTIVATION Local notification Related
    if ([[payLoad valueForKey:@"notification_type"] isEqualToString:@"hlr_activation"]) {
        
        if ([[payLoad valueForKey:@"phone_number"] isEqualToString:[ConfigurationReader sharedConfgReaderObj].getLoginId]) {
         
            IVPrimaryNumberVoiceMailViewController *primaryNumberVoiceMailView = [[UIStoryboard storyboardWithName:@"IVVoiceMailMissedCallSettingsStoryBoard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"IVPrimaryNumberVoiceMail"];
            [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:primaryNumberVoiceMailView animated:YES];
            
        }else{
            IVLinkedNumberVoiceMailViewController *linkedNumberVoiceMailView = [[UIStoryboard storyboardWithName:@"IVVoiceMailMissedCallSettingsStoryBoard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"IVLinkedNumberVoiceMail"];
            linkedNumberVoiceMailView.phoneNumber = [payLoad valueForKey:@"phone_number"];
            [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:linkedNumberVoiceMailView animated:YES];
        }
        return;
    }
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
    
    //TODO: Need to verify this logic. !!!!
    //Start: Nivedita - To indentify the new joinee message type, as per the requirement when user taps on the this kind of notifictaion we should not take any action. Date: 1 Feb 2016
    BOOL isAvsMessage = FALSE;
    if(eventToNotify == NOTIFY_MISSEDCALL || eventToNotify == NOTIFY_VOICEMAIL) {
        isAvsMessage = TRUE;
    }

	EnLogd(@"isAvsMessage:%@",isAvsMessage?@"YES":@"NO");
    KLog(@"isAvsMessage:%@",isAvsMessage?@"YES":@"NO");
    
    //TODO: Need to verify this logic. !!!!
    //Start: Nivedita - To indentify the new joinee message type, as per the requirement when user taps on the this kind of notifictaion we should not take any action. Date: 1 Feb 2016

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
            else if([presentedUI isKindOfClass:[CreateNewSingleChatViewController class]]) {
                CreateNewSingleChatViewController* vc = (CreateNewSingleChatViewController*)presentedUI;
                if([vc respondsToSelector:@selector(dismissThisViewController)]) {
                    [vc dismissThisViewController];
                }
            }
            else if([presentedUI isKindOfClass:[ChatMobileNumberViewController class]]) {
                ChatMobileNumberViewController* vc = (ChatMobileNumberViewController*)presentedUI;
                if([vc respondsToSelector:@selector(dismissThisViewController)]) {
                    [vc dismissThisViewController];
                }
            }
            else if([presentedUI isKindOfClass:[CreateNewGroupViewController class]]) {
                CreateNewGroupViewController* vc = (CreateNewGroupViewController*)presentedUI;
                if([vc respondsToSelector:@selector(dismissThisViewController)]) {
                    [vc dismissThisViewController];
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
    
    if (uiType == NEW_CHAT_SCREEN) {
        [[self.stateMachineObj getCurrentUI] dismissViewControllerAnimated:YES completion:nil];
    }
    
    if([ivUserId isEqualToString:myIvId])
    {
        //TODO: debug. When will this condition be met?. It happens when self missed call/voicemail is received.
        return;
    }
    else if((uiType == NOTES_SCREEN || uiType == MY_VOBOLO_SCREEN) && !isAvsMessage)
    {
        [self setRecordingPause];
        recordingPause = FALSE;
        [AppDelegate setCurrentChatUserFromNotificationPayload:payLoad];
        
        [self.tabBarController setSelectedIndex:2];
        [self.tabBarController setSelectedViewController:self.tabBarController.viewControllers[2]];
        KLog(@"Goto conversation screen");
        [self gotoConversationScreen];
    }
    else if((uiType == INSIDE_CONVERSATION_SCREEN) /*22 MARCH, 2018 && !isAvsMessage*/)
    {
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
                if(ivUserId.length)
                {
                    //new message is iv message
                    if(![ivUserId isEqualToString:currentIvId])
                        changeTheCurrentChat = true;
                }
                else
                {
                    if(![phoneNumber isEqualToString:currentFromUserId])
                        changeTheCurrentChat = true;
                }
            }
            
            if(changeTheCurrentChat)
            {
                KLog(@"ChangedTheCurrentChat");
                [self popChatScreen:eventToNotify];//SEP 7, 2016 TODO
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
                //22 MARCH, 2018 self.stateMachineObj.tabIndex = 1;
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
                
                //22 MARCH, 2018 self.stateMachineObj.tabIndex = 0;
                [self.engObj notifyUI:notifDic];
            }
                break;
                
            case NOTIFY_IVMSG:
            {
                //22 MARCH, 2018 self.stateMachineObj.tabIndex = 2;
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
            [self createChatScreen];
        } else {
            [self createChatScreen];
        }
    } else {
        KLog(@"Chat screen was already pushed.");
    }
}

-(void) createChatScreen {
    
    KLog(@"#createChatScreen");
    BaseUI* uiConversation = [[InsideConversationScreen alloc]initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    BaseUI* curVC = navController.viewControllers[0];
    if(curVC && [curVC isKindOfClass:[ChatGridViewController class]]) {
        [self.tabBarController setSelectedIndex:2];
        [self.tabBarController setSelectedViewController:self.tabBarController.viewControllers[2]];
    }
    
    if([Common showBrandingScreenViewController] && ![curVC isKindOfClass:[ChatGridViewController class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [navController pushViewController:uiConversation animated:NO];
        });
    }else{
        [navController pushViewController:uiConversation animated:NO];
    }
    
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
                [currentChatUser setValue:phoneNumber forKey:FROM_USER_ID];
                [currentChatUser setValue:remoteUserIvId forKey:REMOTE_USER_IV_ID];
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
}


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

#pragma mark SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
        } else if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
            NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
            [requestDic setValue:[self.confgReader getCountryCode] forKey:@"country_code"];
            InAppPurchaseApi* availableProdcutAPI = [[InAppPurchaseApi alloc]initWithRequest:requestDic];
            [NetworkCommon addCommonData:requestDic eventType:FETCH_PURCHASE_PRODUCTS];
            [availableProdcutAPI callNetworkRequestToFetchProductList:requestDic withSuccess:^(InAppPurchaseApi *req, NSMutableDictionary *responseObject) {
                NSArray *productLIst = [responseObject valueForKey:@"product_list"];
                NSMutableDictionary *ivProduct = productLIst.firstObject;
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
                    // [[NSNotificationCenter defaultCenter] postNotificationName:@"purchaseHistoryRefresh" object:nil];
                    
                } failure:^(InAppPurchaseApi *req, NSError *error) {
                    if (error.code == 97) { //Duplicate Purchase
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    }
                    NSLog(@"Error in PURCHASE_PRODUCT: %@", error.localizedDescription);
                }];
                
            } failure:^(InAppPurchaseApi *req, NSError *error) {
                NSLog(@"Error in FETCH_PURCHASE_PRODUCTS: %@", error.localizedDescription);
            }];
            
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
