//
//  AppDelegate_rm.h
//  ReachMe
//
//  Created by Pandian on 16/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PushKit/PushKit.h>
#import <CallKit/CXError.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <UserNotifications/UserNotifications.h>
#import <AppsFlyerLib/AppsFlyerTracker.h>

#import "UIDataMgt.h"
#import "ConfigurationReader.h"
#import "Engine.h"
#import "NetworkController.h"
#import "UIStateMachine.h"
#import "Database.h"
#import "IVFastNetworkInfo.h"
#import "LinphoneCoreSettingsStore.h"
#import "ProviderDelegate.h"
#import "VoipSetting.h"

#import "STUNClient.h"
#import "GCDAsyncUdpSocket.h"
#import <StoreKit/StoreKit.h>


@class ChatGridViewController;
@class FriendsScreen;
@class Reachability;
@class BaseConversationScreen;

#define APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])


@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, UITabBarControllerDelegate, UITabBarDelegate, PKPushRegistryDelegate, VoipSettingDelegate, STUNClientDelegate, AppsFlyerTrackerDelegate, SKPaymentTransactionObserver>
{
    UINavigationController      *navController;
    BOOL                        isLogin;
    /*
    ChatGridViewController      *chat;
    FriendsScreen               *friendScreen;
     */
    Reachability                *internetReachable;
    BOOL                        CLOSEDSTATE;
    BOOL                        BACKGROUNDSTATE;
    BOOL                        recordingPause;
    BOOL                        addMessageHeader;
    NSInteger                   appBecomeActive;
    GCDAsyncUdpSocket *udpSocket;
    STUNClient *stunClient;
    BOOL isRequested;
    NSString* _tappedContact; //User clicks the ReachMe contact when App is not active or not running in background
    //UIBackgroundTaskIdentifier bgStartId;//DEC 22, 2017
}

@property (strong,nonatomic)UIWindow *window;
@property (strong,nonatomic)ConfigurationReader *confgReader;
@property (strong,nonatomic)UIDataMgt *dataMgt;
@property (strong,nonatomic)Engine *engObj;
@property (strong,nonatomic)NetworkController *shortNetObj;
@property (strong,nonatomic)NetworkController *longNetObj;
@property (strong,nonatomic)NetworkController *preemptedNetObj;
@property (strong,nonatomic)NetworkController *picDownloadNetObj;
@property (strong,nonatomic)UIStateMachine *stateMachineObj;
@property (strong, nonatomic)UITabBarController *tabBarController;
@property BOOL sendCloudKey;
@property BOOL sendVoipKey;
@property (strong, nonatomic) NSString* tappedContact;

@property (strong,nonatomic)NSTimer *time;

@property CGSize deviceHeight;
@property(nonatomic, strong) CTCallCenter *callCenter;
@property (nonatomic, assign) BOOL chatScreenPushed;
@property (nonatomic, strong) IVFastNetworkInfo *fastNetworkInfo;

@property PKPushRegistry* voipRegistry;
@property ProviderDelegate* providerDelegate;
@property LinphoneCoreSettingsStore* lphoneCoreSettings;

@property BOOL isMoreTabClicked;

//- (void) makeCall;
- (void) uiUpdateMoreViewController;
- (void) registerForPushNotification;
- (void) registerForVOIPPush;

- (UINavigationController*)getNavController;
- (void)setNavController:(UINavigationController*)newController;

-(void)createTabBarControllerItems;
//-(void)resetQueueContexts;
//-(void)setRootViewControllerWithPhoneView:(BOOL)isPhoneView FromContact:(NSString*)address;
-(void)sendDataToStunServer;

-(void)fetchSettingCompleteWithStatus:(BOOL)fetchStatus;

#ifdef ENABLE_LATER
-(void)prepareBlockedContacts;
-(void)prepareVoipCallBlockedNumbers;
#endif

-(void)signout;
-(void)canSignout;
-(void)setRingTone;

+(NSManagedObjectContext *)sharedMainQueueContext;
+(NSManagedObjectContext *)sharedPrivateQueueContext;

@end
