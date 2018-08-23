//
//  BaseUI.h
//  InstaVoice
//
//  Created by EninovUser on 27/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif

#import "TableColumns.h"
#import "UIEventType.h"
#import "UIType.h"
#import "ImgMacro.h"
#import "Macro.h"
#import "EventType.h"
#import "ServerErrorMsg.h"
#import "HttpConstant.h"
#import "Common.h"
#import "CustomIOS7AlertView.h"
#import <CoreLocation/CoreLocation.h>
#import "Setting.h"
#define CHAT_GRID  @"chat_grid"


//Should Animate during Push or Pop navigation controller
#define shouldAnimatePushPop NO

#ifndef NSFoundationVersionNumber_iOS_6_1
#define NSFoundationVersionNumber_iOS_6_1 993.00
#endif

@interface BaseUI : UIViewController<MBProgressHUDDelegate,CLLocationManagerDelegate, UIScrollViewDelegate>
{
    CustomIOS7AlertView *customAlert;
    MBProgressHUD *progressBar;
    AppDelegate *appDelegate;
    CLLocationManager       *locationManager;           //Location Management Varible
    CLGeocoder              *geocoder;                  //Provide the address string
    CLLocation              *location;                  //Loction varible for get latitude,longitude
    NSString                *locationName;              //String of address
    UIAlertController* acMicrophone;
}

// this adjust's the scroll view's contents insets properly so the top of the scroll view is at the proper y location. 
@property (nonatomic) BOOL alreadyLoaded;
@property(nonatomic,assign)int uiType;

/**
 * This function handles Event from engine thread
 * @param resultDic : NSMutableDictionary contains EventType and ResponseData
 */
-(int)handleEvent :(NSMutableDictionary *)resultDic;


/**
 *This fuction show Progress bar
 
 */
-(void)showProgressBar;

/**
 *This function hides progress bar
 */
-(void)hideProgressBar;
-(void)getLocationPermission;


/* 
 *stop updating location
 */
-(void)stopUpdatingLocation;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *verticalConstant;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *verticalBottomConstant;
-(void)updateViewConstraintsForStoryBoard;
@property(nonatomic,assign) BOOL isFromStoryboard;
@property(nonatomic,assign) BOOL isAnyChangesSpecificSubClass;
@property(nonatomic,strong)NSArray *fetchServiceResultArray;

- (void)createTopViewStoryBoardWithTitle: (NSString*)nonLocalizedString;
- (void)removeOverlayViewsIfAnyOnPushNotification;
- (void)dismissViewController;
- (void)updateViewBackGroundColor;
- (void)updateNaviagtionBarButtonTintColor;
#ifndef REACHME_APP
- (void)showInAppPromoImage;
#endif
- (void)hideKeyBoardDisplayed;
- (BOOL)checkMicrophonePermission:(NSString*)text;

@end
