

//
//  BaseUI.m
//  InstaVoice
//
//  Created by EninovUser on 27/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "BaseUI.h"
#import <QuartzCore/CALayer.h>
#import "IVColors.h"
#import "IVFileLocator.h"
#import "Setting.h"
#import "IVInAppPromoViewController.h"
#import "Audio.h"

@interface BaseUI () <SettingProtocol>

@end

@implementation BaseUI

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.uiType = -1;
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)APP_DELEGATE;
    
    [self setModalPresentationStyle:UIModalPresentationOverFullScreen];
    self.definesPresentationContext = YES;

    
    [Setting sharedSetting].delegate = self;
   	// Do any additional setup after loading the view.

    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];//KM
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBar.translucent = NO;

#ifndef REACHME_APP
    if (! (self.uiType == LOGIN_SCREEN || self.uiType == VERIFICATION_SCREEN || self.uiType == FRIENDS_SCREEN)) {
        if ([[Setting sharedSetting]shouldShowInAppPromoImage]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showInAppPromoImage];
            });
            
        }
    }
#endif
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    EnLoge(@"Memory Warning.");
    // Dispose of any resources that can be rec reated.
}

-(int)handleEvent :(NSMutableDictionary *)resultDic
{
    return 0;
}

#pragma mark - ProgressBar 
-(void)showProgressBar
{
    if(progressBar == nil)
    {
        progressBar = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:progressBar];
        progressBar.delegate = self;
        [progressBar show:YES];
    }
}

-(void)hideProgressBar
{
    [progressBar hide:YES];
    [progressBar removeFromSuperview];
    progressBar = nil;
}

#pragma mark - Get The Current Loction & Address

-(void) getLocationPermission
{
#ifndef REACHME_APP
    /*---- For get location and address of the user -----*/
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [self getCurrentLocation];
#endif
}


-(void)getCurrentLocation
{
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
}


-(void)stopUpdatingLocation
{
    [locationManager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    location = [locations lastObject];
    [locationManager stopUpdatingLocation];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            EnLoge(@"%@", error.debugDescription);
            return;
        }
        locationName = [Common getLocationName:placemarks];
    } ];
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

-(void)updateViewConstraintsForStoryBoard
{
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        [self.verticalConstant setConstant:44];
    }
    else
    {
        [self.verticalConstant setConstant:54];
    }
}



//KM
-(void)createTopViewStoryBoardWithTitle:(NSString*)nonLocalizedString
{
//    self.navigationItem.hidesBackButton = NO;
//    self.navigationController.navigationBarHidden = YES;
//
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    UILabel *title = nil;
//    UIView *topView = nil;
//    UIView *borderView = nil;
//    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
//    {
//        topView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0, SIZE_0, SIZE_320, SIZE_44)];
//        backButton.frame = CGRectMake(SIZE_8, SIZE_0,SIZE_50, SIZE_44);
//        title = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_60, SIZE_7, SIZE_200, SIZE_30)];
//        borderView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0, SIZE_43, SIZE_320, SIZE_1)];
//        
//    }
//    else
//    {
//        topView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0, SIZE_0, SIZE_320, SIZE_54)];
//        backButton.frame = CGRectMake(SIZE_8, SIZE_15,SIZE_50, SIZE_44);
//        title = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_60, SIZE_22, SIZE_200, SIZE_30)];
//        borderView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0, SIZE_53, SIZE_320, SIZE_1)];
//    }
//    [borderView setBackgroundColor:[UIColor colorWithRed:(230/255.f) green:(230/255.f) blue:(230/255.f) alpha:1.0f]];
//    [backButton setImage:[UIImage imageNamed:IMG_BACK] forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
//    
//    [title setTextAlignment:NSTextAlignmentCenter];
//    [title setFont:[UIFont fontWithName:HELVETICANEUE_MEDIUM size:SIZE_18]];
//    
//    if([nonLocalizedString isEqualToString:@"Voicemail/Missed Call Settings"]){
//        [title setFrame:CGRectMake(title.frame.origin.x, title.frame.origin.y, SIZE_260, title.frame.size.height)];
//        [title setFont:[UIFont fontWithName:HELVETICANEUE_MEDIUM size:SIZE_17]];
//        [title setTextAlignment:NSTextAlignmentLeft];
//    }
//    
//    [title setTextColor:[UIColor blackColor]];
//    title.backgroundColor = [UIColor clearColor];
//    title.text = NSLocalizedString(nonLocalizedString, nil);
//    //    [topView setBackgroundColor:[UIColor colorWithWhite:.88 alpha:1.0]];
//    [topView addSubview:backButton];
//    [topView addSubview:title];
//    [topView addSubview:borderView];
//    [self.view addSubview:topView];
}
//

- (void)removeOverlayViewsIfAnyOnPushNotification
{
    //KLog(@"Parent implementation called removeOverlayViewsIfAnyOnPushNotification");
    if(acMicrophone) {
        [acMicrophone dismissViewControllerAnimated:YES completion:nil];
        acMicrophone = nil;
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return (UIInterfaceOrientationMaskPortrait);
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

//Method responsible to set the background color - based on the enable status of default color, settings carrier theme color.
- (void)updateViewBackGroundColor {
#if DEFAULT_THEMECOLOR_ENABLED
    self.view.backgroundColor = [IVColors redColor];
    
#else
    {
       // NSString *primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
        
        NSString *carrierThemeColor = [[ConfigurationReader sharedConfgReaderObj]getLatestCarrierThemeColor];
        
        //[[Setting sharedSetting]getCarrierThemeColorForNumber:primaryNumber];
       
        if (carrierThemeColor && [carrierThemeColor length])
            self.view.backgroundColor = [IVColors convertHexValueToUIColor:carrierThemeColor];
        else
            self.view.backgroundColor = [IVColors redColor];

    }
    
#endif
}

- (void)updateNaviagtionBarButtonTintColor {
    
#if DEFAULT_THEMECOLOR_ENABLED
    self.navigationController.navigationBar.tintColor = [IVColors redColor];
    
#else
    {
       // NSString *primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
        NSString *carrierThemeColor = [[ConfigurationReader sharedConfgReaderObj]getLatestCarrierThemeColor];

        //NSString *carrierThemeColor = [[Setting sharedSetting]getCarrierThemeColorForNumber:primaryNumber];
        if (carrierThemeColor && [carrierThemeColor length])
            self.navigationController.navigationBar.tintColor = [IVColors convertHexValueToUIColor:carrierThemeColor];
        else
            self.navigationController.navigationBar.tintColor = [IVColors redColor];
        
    }
    
#endif
}

#ifndef REACHME_APP
- (void)fetchPromoImageCompletedWithStatus: (BOOL)withFetchStatus {
    
    if (withFetchStatus) {
        if (! (self.uiType == LOGIN_SCREEN || self.uiType == VERIFICATION_SCREEN || self.uiType == FRIENDS_SCREEN)) {
            if ([[Setting sharedSetting]shouldShowInAppPromoImage]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self showInAppPromoImage];
                });
                
            }
        }
    }
}

- (void)showInAppPromoImage {
    
    UIStoryboard *friendsStoryBoard = [UIStoryboard storyboardWithName:@"IVFriendsStoryboard" bundle:[NSBundle mainBundle]];
    IVInAppPromoViewController *inAppPromoViewController = [friendsStoryBoard instantiateViewControllerWithIdentifier:@"IVInAppPromoView"];
    inAppPromoViewController.view.frame = [UIScreen mainScreen].bounds;
    inAppPromoViewController.view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [inAppPromoViewController setModalPresentationStyle:UIModalPresentationOverFullScreen];
    [self presentViewController:inAppPromoViewController animated:NO completion:nil];
}
#endif


-(BOOL)checkMicrophonePermission:(NSString*)text
{
    __block BOOL value = FALSE;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted)
        {
            value = TRUE;
        }
        else
        {
            [self performSelectorOnMainThread:@selector(showMicrophoneAccessWarning:) withObject:text waitUntilDone:NO];
        }
    }];
    return value;
}


-(void)showMicrophoneAccessWarning:(NSString*)text
{
    NSString* msg = @"Callers won't be able to hear your voice when you answer the ReachMe call. Tap Settings to turn on Microphone.";
    if(text.length)
        msg = [NSString stringWithString:text];
    
#ifdef REACHME_APP
    NSString* alertTitle = @"You Denied Microphone Access to \"ReachMe\"";
    
#else
    NSString* alertTitle = @"You Denied Microphone Access to \"InstaVoice\"";
#endif
    
    acMicrophone = [UIAlertController alertControllerWithTitle:alertTitle
                                                       message:msg
                                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okBtn = [UIAlertAction actionWithTitle:@"Settings"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                     if ([[UIDevice currentDevice].systemVersion floatValue] < 10.0) {
                                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                      } else {
                                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                                                             options:@{}
                                                                                   completionHandler:^(BOOL success) {
                                                                                       //KLog(@"success = %d", success);
                                                                                   }];
                                                      }
                                                  }];
    
    UIAlertAction* cancelBtn = [UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil];
    [acMicrophone addAction:okBtn];
    [acMicrophone addAction:cancelBtn];
    acMicrophone.view.tintColor = [UIColor blueColor];
    [self presentViewController:acMicrophone animated:YES completion:nil];
}

-(void)dismisAlerController {
    [acMicrophone dismissViewControllerAnimated:YES completion:nil];
}

@end
