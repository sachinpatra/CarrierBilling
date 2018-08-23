//
//  AppDelegate.h
//  InstaVoice
//
//  Created by EninovUser on 06/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <PushKit/PushKit.h>
//#import <CallKit/CXError.h>

#import "UIDataMgt.h"
#import "ConfigurationReader.h"
#import "Engine.h"

#import "NetworkController.h"
#import "UIStateMachine.h"
#import "Database.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

//#import "NotificationData.h"
#import "IVFastNetworkInfo.h"
#import <StoreKit/StoreKit.h>

@class ChatGridViewController;
@class FriendsScreen;
@class Reachability;

@class BaseConversationScreen;

#define APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UITabBarDelegate, SKPaymentTransactionObserver>
{
    UINavigationController      *navController;
    BOOL                        isLogin;
    ChatGridViewController      *chat;
    FriendsScreen               *friendScreen;
    Reachability                *internetReachable;
    BOOL                        CLOSEDSTATE;
    BOOL                        BACKGROUNDSTATE;
    BOOL                        recordingPause;
    BOOL                        addMessageHeader;
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

@property (strong,nonatomic)NSTimer *time;

@property CGSize deviceHeight;
@property(nonatomic, strong) CTCallCenter *callCenter;
@property (nonatomic, assign) BOOL chatScreenPushed;
@property (nonatomic, strong) IVFastNetworkInfo *fastNetworkInfo;

//VOIP
//@property PKPushRegistry* voipRegistry;
//

-(void) makeCall;
-(void) uiUpdateMoreViewController;
-(void) registerForPushNotification;

- (UINavigationController*)getNavController;
- (void)setNavController:(UINavigationController*)newController;

-(void)createTabBarControllerItems;
-(void)resetQueueContexts;
-(void)prepareBlockedContacts;

+(NSManagedObjectContext *)sharedMainQueueContext;
+(NSManagedObjectContext *)sharedPrivateQueueContext;

@end
