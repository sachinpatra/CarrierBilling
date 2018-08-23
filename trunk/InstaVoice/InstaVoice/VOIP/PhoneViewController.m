//
//  PhoneViewController.m
//  InstaVoice
//
//  Created by Pandian on 7/5/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "PhoneViewController.h"
#import "LinphoneCoreSettingsStore.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif

#import "Contacts.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "IVFileLocator.h"
#import "Common.h"
#import "TableColumns.h"

#define GSM_CALL_DURATION_LIMIT     600      //in seconds; Allowed duration for App-to-Gsm call

@interface PhoneViewController () {
    UIView *dialpadView;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property BOOL speakerEnabled;
@property BOOL micEnabled;
@property (atomic) BOOL isNetReachable;

@end

@implementation PhoneViewController
{
    NSString* imageURLString;
    NSString* contactName;
    NSNumber* ivUserId;
    int callDuration;
    NSTimer *updateTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat topPadding;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        topPadding = window.safeAreaInsets.top;
    }else{
        topPadding = 0.0f;
    }
    
    if(topPadding == 0.0)
        topPadding = 20.0;
    
    _topConstraint.constant = topPadding;
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = UIColorFromRGB(0x535B5B);//  [UIColor colorWithRed:0x1c green:0x43 blue:0x44 alpha:1.0];
    
    self.speakerEnabled = FALSE;
    self.micEnabled = TRUE;
    self.isNetReachable = TRUE;
    isCallConnected = FALSE;
    
    self.uiType = PHONE_VIEW_CONTROLLER;
    [appDelegate.stateMachineObj setCurrentUI:self];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    KLog(@"viewWillAppear");
    
    [super viewWillAppear:animated];
    
    self.hideButton.hidden = YES;
    isCallConnected = NO;
    
    [self createDialpad];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(callUpdate:)
                                               name:kLinphoneCallUpdate
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(NetworkStatusUpdate:)
                                               name:kLinphoneNetworkReachable
                                             object:nil];
    
    self.uiType = PHONE_VIEW_CONTROLLER;
    [appDelegate.stateMachineObj setCurrentUI:self];
    
    if (updateTimer != nil) {
        [updateTimer invalidate];
    }
    
    [self.view sendSubviewToBack:self.bgScreen];
    
    if(self.isIncomingCall) {
        self.toContact.hidden = NO;
    } else {
        self.toContact.hidden = YES;
    }
    
    self.fromContact.text = self.fromAddress;
    self.toContact.text = self.toAddress;
    
    //- Format the fromAddress if it is number
    NSString *name = [Common setPlusPrefix:self.fromAddress];//Returns nil if it is not a number
    if(name != nil){
        NSString* fName = [Common getFormattedNumber:name withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        if(!fName)
            fName = self.fromAddress;
        self.fromContact.text = fName;
    }else {
        self.fromContact.text = self.fromAddress;
    }
    //
    
    //- Format the toAddress if it is number
    name = [Common setPlusPrefix:self.toAddress];//Returns nil if it is not a number
    if(name != nil){
        NSString* fName = [Common getFormattedNumber:name withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        if(!fName)
            fName = self.toAddress;
        self.toContact.text = fName;
    }else {
        self.toContact.text = self.toAddress;
    }
    if(self.toContact.text.length) {
        self.toContact.text = [@"To: " stringByAppendingString:self.toContact.text];
    }
    //
    
    //Contact PIC
    NSArray* arr = [[Contacts sharedContact]getContactForPhoneNumber:self.fromAddress];
    ContactDetailData* detail = Nil;
    if([arr count]>0)
        detail = [arr objectAtIndex:0];
    if (detail)  {
        ContactData *data = detail.contactIdParentRelation;
        if(data.isIV)
            ivUserId = detail.ivUserId;
        else
            ivUserId = 0;
        
        if(data.contactName || data.contactName.length)
            contactName = [NSString stringWithString:data.contactName];
        if(contactName.length)
            self.fromContact.text = contactName;
    
        imageURLString = [IVFileLocator getNativeContactPicPath:data.contactPic];
        UIImage *profilePicture = [ScreenUtility getPicImage:imageURLString];
        //self.profilePictureView.image = profilePicture ? profilePicture : nil;
        if (profilePicture) {
            self.imgProfile.image = profilePicture;
        }
        else if(data.contactPicURI)
        {
            [[Contacts sharedContact]downloadAndSavePicWithURL:data.contactPicURI picPath:imageURLString];
        }
        else
        {
            self.imgProfile.image = [UIImage imageNamed:@"vc_imgPerson"];
        }
    } else {
        self.imgProfile.image = [UIImage imageNamed:@"vc_imgPerson"];
    }
    
    //- make the pic frame circular
    self.imgProfile.layer.masksToBounds = YES;
    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width/2;
    self.imgProfile.layer.borderWidth = 0.1;
    //
    
    [self setSpeakerImage:self.speakerEnabled];
    [self setMicImage:self.micEnabled];
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(callDurationUpdate)
                                   userInfo:nil
                                    repeats:YES];
    
    [self changeAudioRoute];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSNotificationCenter.defaultCenter removeObserver:self];
    
    if (updateTimer != nil) {
        [updateTimer invalidate];
    }
}

#pragma mark -

#pragma mark Dialpad View
-(void)createDialpad
{
    if(nil!=dialpadView) {
        return;
    }
    
    CGFloat height = (DEVICE_HEIGHT - 280.0)/5;
    BOOL iPhoneX = NO;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.top > 0.0) {
            iPhoneX = YES;
            height = 70.0;
        }
    }
    
    UIView *onCallView1 = [[UIView alloc]initWithFrame:CGRectMake(0.0, 48.0, DEVICE_WIDTH, height)];
    onCallView1.backgroundColor = [UIColor clearColor];
    
    UIButton *one = [[UIButton alloc] initWithFrame:CGRectMake(48.0, 0.0, height, height)];
    [one setImage:[UIImage imageNamed:@"1_duringCall"] forState:UIControlStateNormal];
    
    UIButton *two = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_WIDTH/2) - (height/2), 0.0, height, height)];
    [two setImage:[UIImage imageNamed:@"2_duringCall"] forState:UIControlStateNormal];
    
    UIButton *three = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH - height - 48.0, 0.0, height, height)];
    [three setImage:[UIImage imageNamed:@"3_duringCall"] forState:UIControlStateNormal];
    
    [onCallView1 addSubview:one];
    [onCallView1 addSubview:two];
    [onCallView1 addSubview:three];
    
    UIView *onCallView2 = [[UIView alloc]initWithFrame:CGRectMake(0.0, onCallView1.frame.size.height + onCallView1.frame.origin.y + 8.0, DEVICE_WIDTH, height)];
    onCallView2.backgroundColor = [UIColor clearColor];
    
    UIButton *four = [[UIButton alloc] initWithFrame:CGRectMake(48.0, 0.0, height, height)];
    [four setImage:[UIImage imageNamed:@"4_duringCall"] forState:UIControlStateNormal];
    
    UIButton *five = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_WIDTH/2) - (height/2), 0.0, height, height)];
    [five setImage:[UIImage imageNamed:@"5_duringCall"] forState:UIControlStateNormal];
    
    UIButton *six = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH - height - 48.0, 0.0, height, height)];
    [six setImage:[UIImage imageNamed:@"6_duringCall"] forState:UIControlStateNormal];
    
    [onCallView2 addSubview:four];
    [onCallView2 addSubview:five];
    [onCallView2 addSubview:six];
    
    UIView *onCallView3 = [[UIView alloc]initWithFrame:CGRectMake(0.0, onCallView2.frame.size.height + onCallView2.frame.origin.y + 8.0, DEVICE_WIDTH, height)];
    onCallView3.backgroundColor = [UIColor clearColor];
    
    UIButton *seven = [[UIButton alloc] initWithFrame:CGRectMake(48.0, 0.0, height, height)];
    [seven setImage:[UIImage imageNamed:@"7_duringCall"] forState:UIControlStateNormal];
    
    UIButton *eight = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_WIDTH/2) - (height/2), 0.0, height, height)];
    [eight setImage:[UIImage imageNamed:@"8_duringCall"] forState:UIControlStateNormal];
    
    UIButton *nine = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH - height - 48.0, 0.0, height, height)];
    [nine setImage:[UIImage imageNamed:@"9_duringCall"] forState:UIControlStateNormal];
    
    [onCallView3 addSubview:seven];
    [onCallView3 addSubview:eight];
    [onCallView3 addSubview:nine];
    
    UIView *onCallView4 = [[UIView alloc]initWithFrame:CGRectMake(0.0, onCallView3.frame.size.height + onCallView3.frame.origin.y + 8.0, DEVICE_WIDTH, height)];
    onCallView4.backgroundColor = [UIColor clearColor];
    
    UIButton *asterisk = [[UIButton alloc] initWithFrame:CGRectMake(48.0, 0.0, height, height)];
    [asterisk setImage:[UIImage imageNamed:@"*_duringCall"] forState:UIControlStateNormal];
    
    UIButton *zero = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_WIDTH/2) - (height/2), 0.0, height, height)];
    [zero setImage:[UIImage imageNamed:@"0_duringCall"] forState:UIControlStateNormal];
    
    UIButton *hash = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH - height - 48.0, 0.0, height, height)];
    [hash setImage:[UIImage imageNamed:@"#_duringCall"] forState:UIControlStateNormal];
    
    [onCallView4 addSubview:asterisk];
    [onCallView4 addSubview:zero];
    [onCallView4 addSubview:hash];
    
    dialpadView = [[UIView alloc]initWithFrame:CGRectMake(0.0, iPhoneX?280.0:140.0, DEVICE_WIDTH, onCallView4.frame.size.height + onCallView4.frame.origin.y)];
    //dialpadView.backgroundColor = [UIColor blackColor];
    //dialpadView.alpha = 0.5;
    dialpadView.hidden = YES;
    
    [dialpadView addSubview:onCallView1];
    [dialpadView addSubview:onCallView2];
    [dialpadView addSubview:onCallView3];
    [dialpadView addSubview:onCallView4];
    
    [self.view addSubview:dialpadView];
    
    
    //- dtmf keys
    
    [one addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [two addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [three addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [four addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [five addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [six addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [seven addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [eight addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [nine addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [zero addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [asterisk addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [hash addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    
    [one addTarget:self action:@selector(oneTouchDown:) forControlEvents:UIControlEventTouchDown];
    [two addTarget:self action:@selector(twoTouchDown:) forControlEvents:UIControlEventTouchDown];
    [three addTarget:self action:@selector(threeTouchDown:) forControlEvents:UIControlEventTouchDown];
    [four addTarget:self action:@selector(fourTouchDown:) forControlEvents:UIControlEventTouchDown];
    [five addTarget:self action:@selector(fiveTouchDown:) forControlEvents:UIControlEventTouchDown];
    [six addTarget:self action:@selector(sixTouchDown:) forControlEvents:UIControlEventTouchDown];
    [seven addTarget:self action:@selector(sevenTouchDown:) forControlEvents:UIControlEventTouchDown];
    [eight addTarget:self action:@selector(eightTouchDown:) forControlEvents:UIControlEventTouchDown];
    [nine addTarget:self action:@selector(nineTouchDown:) forControlEvents:UIControlEventTouchDown];
    [zero addTarget:self action:@selector(zeroTouchDown:) forControlEvents:UIControlEventTouchDown];
    [asterisk addTarget:self action:@selector(asteriskTouchDown:) forControlEvents:UIControlEventTouchDown];
    [hash addTarget:self action:@selector(hashTouchDown:) forControlEvents:UIControlEventTouchDown];
}

#pragma mark -
#pragma mark DTMF Keys

-(IBAction)touchUp:(id)sender {
    linphone_core_stop_dtmf(LC);
}

- (IBAction)oneTouchDown:(id)sender {
    [self playDigit:'1'];
}

- (IBAction)twoTouchDown:(id)sender {
    [self playDigit:'2'];
}

- (IBAction)threeTouchDown:(id)sender {
    [self playDigit:'3'];
}

- (IBAction)fourTouchDown:(id)sender {
    [self playDigit:'4'];
}

- (IBAction)fiveTouchDown:(id)sender {
    [self playDigit:'5'];
}

- (IBAction)sixTouchDown:(id)sender {
    [self playDigit:'6'];
}

- (IBAction)sevenTouchDown:(id)sender {
    [self playDigit:'7'];
}

- (IBAction)eightTouchDown:(id)sender {
    [self playDigit:'8'];
}

- (IBAction)nineTouchDown:(id)sender {
    [self playDigit:'9'];
}

- (IBAction)zeroTouchDown:(id)sender {
    [self playDigit:'0'];
}

- (IBAction)asteriskTouchDown:(id)sender {
    [self playDigit:'*'];
}

- (IBAction)hashTouchDown:(id)sender {
    [self playDigit:'#'];
}

-(void)playDigit:(char)digit {
    
    if (!linphone_core_in_call(LC)) {
        linphone_core_play_dtmf(LC, digit, -1);
    } else {
        LinphoneStatus ret = linphone_call_send_dtmf(linphone_core_get_current_call(LC), digit);
        linphone_core_play_dtmf(LC, digit, 100);
        if(0 == ret)  {
            KLog(@"digit \'%c\' sent",digit);
            EnLogd(@"digit \'%c\' sent",digit);
        } else {
            KLog(@"Error in sending digit \'%c\'",digit);
            EnLogd(@"Error in sending digit \'%c\'",digit);
        }
    }
}

#pragma mark -


-(void)callUpdate:(NSNotification *)notif  {
    
    if(!self.isIncomingCall) {
        [self updateOutgoingCall:notif];
        return;
    }
    
    //
    //- update incoming call status
    LinphoneCall *call = [[notif.userInfo objectForKey:@"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey:@"state"] intValue];
    NSString *message = [notif.userInfo objectForKey:@"message"];
    NSString* callID = [notif.userInfo objectForKey:@"callId"];
    
    KLog(@"callUpdate: state = %d",state);
    KLog(@"callUpdate: message = %@",message);
    
    switch (state) {
            
        case LinphoneCallConnected:
            self.lblDuration.text = @"call connecting...";
            isCallConnected = YES;
            break;
        
        case LinphoneCallStreamsRunning:
            KLog(@"Call connected");
            isCallConnected = YES;
            self.lblDuration.text = @"call connected";
            break;
            
        case LinphoneCallEnd:
            KLog(@"call ended");
            if(linphone_core_get_calls_nb(LC)<=0) {
                self.lblDuration.text = @"call ended";
                isCallConnected = NO;
            }
            break;
            
        case LinphoneCallPaused:
        case LinphoneCallPausing:
            isCallConnected = NO;
            self.lblDuration.text = @"call on hold";
            break;
            
        case LinphoneCallResuming:
        {
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max && call) {
                NSUUID *uuid = (NSUUID *)[LinphoneManager.instance.providerDelegate.uuids
                                          objectForKey:[NSString stringWithUTF8String:linphone_call_log_get_call_id(
                                                                                                                    linphone_call_get_call_log(call))]];
                if (!uuid) {
                    return;
                }
                KLog(@"Calling performSetHeldCallAction");
                isCallConnected = YES;
                CXSetHeldCallAction *act = [[CXSetHeldCallAction alloc] initWithCallUUID:uuid onHold:NO];
                CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];
                [LinphoneManager.instance.providerDelegate.controller requestTransaction:tr
                                                                              completion:^(NSError *err){
                                                                              }];
            }
            break;
        }
            
        default:
        {
            KLog(@"callUpdate: Not handled");
            break;
        }
    }
}

-(void)updateOutgoingCall:(NSNotification*)notif {
    
    LinphoneCall *call = [[notif.userInfo objectForKey:@"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey:@"state"] intValue];
    NSString *message = [notif.userInfo objectForKey:@"message"];
    NSString* callID = [notif.userInfo objectForKey:@"callId"];
    
    if(callID.length && self.callID.length && ![callID isEqualToString:self.callID]) {
        KLog(@"Different callID");
        return;
    }
    
    KLog(@"callUpdate: state = %d",state);
    KLog(@"callUpdate: message = %@",message);
    
    switch (state) {
            
        case LinphoneCallOutgoingInit:
            self.lblDuration.text  = @"Calling...";
            isCallConnected = NO;
            break;
            
        case LinphoneCallOutgoingEarlyMedia:
        case LinphoneCallOutgoingProgress: {
            self.lblDuration.text  = @"Calling...";
            isCallConnected = NO;
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max && call &&
                (linphone_core_get_calls_nb(LC) < 2)) {
                // Link call ID to UUID
                NSString *callId =
                [NSString stringWithUTF8String:linphone_call_log_get_call_id(linphone_call_get_call_log(call))];
                NSUUID *uuid = [LinphoneManager.instance.providerDelegate.uuids objectForKey:@""];
                if (uuid) {
                    [LinphoneManager.instance.providerDelegate.uuids removeObjectForKey:@""];
                    [LinphoneManager.instance.providerDelegate.uuids setObject:uuid forKey:callId];
                    [LinphoneManager.instance.providerDelegate.calls setObject:callId forKey:uuid];
                    self.call = call;
                    self.callID = callId;
                    //May 23, 2018
                    NSMutableDictionary* callLog = [[NSMutableDictionary alloc]init];
                    [callLog setValue:self.toAddress forKey:FROM_PHONE];
                    [callLog setValue:self.fromAddress forKey:TO_PHONE];
                    NSMutableDictionary* pushDic = [[NSMutableDictionary alloc]init];
                    [pushDic setObject:callLog forKey:callId];
                    [LinphoneManager.instance.providerDelegate.lastCallInfo addObject:pushDic];
                    if([LinphoneManager.instance.providerDelegate.lastCallInfo count] > 10)
                        [LinphoneManager.instance.providerDelegate.lastCallInfo removeObjectAtIndex:0];
                    
                    KLog(@"callInfo = %@",LinphoneManager.instance.providerDelegate.lastCallInfo);
                    EnLogd(@"callInfo = %@",LinphoneManager.instance.providerDelegate.lastCallInfo);
                    //
                }
            }
            break;
        }
            
        case LinphoneCallPausedByRemote: {
            self.lblDuration.text = @"call pasused.";
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max && call) {
                NSString *callId =
                [NSString stringWithUTF8String:linphone_call_log_get_call_id(linphone_call_get_call_log(call))];
                NSUUID *uuid = [LinphoneManager.instance.providerDelegate.uuids objectForKey:callId];
                if (uuid) {
                    [LinphoneManager.instance.providerDelegate.provider reportOutgoingCallWithUUID:uuid
                                                                           startedConnectingAtDate:nil];
                    isCallConnected = NO;
                }
            }
        }
            break;
            
        case LinphoneCallConnected: {
            self.lblDuration.text = @"call connecting...";
            //callLog = linphone_call_get_call_log(self.call);
            isCallConnected = NO;
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max && call) {
                NSString *callId =
                [NSString stringWithUTF8String:linphone_call_log_get_call_id(linphone_call_get_call_log(call))];
                NSUUID *uuid = [LinphoneManager.instance.providerDelegate.uuids objectForKey:callId];
                if (uuid) {
                    [LinphoneManager.instance.providerDelegate.provider reportOutgoingCallWithUUID:uuid
                                                                           startedConnectingAtDate:nil];
                }
            }
        }
            break;
            
        case LinphoneCallStreamsRunning: {
            KLog(@"Call connected");
            self.lblDuration.text = @"call connected";
            isCallConnected = YES;
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max && call) {
                NSString *callId =
                [NSString stringWithUTF8String:linphone_call_log_get_call_id(linphone_call_get_call_log(call))];
                NSUUID *uuid = [LinphoneManager.instance.providerDelegate.uuids objectForKey:callId];
                if (uuid) {
                    [LinphoneManager.instance.providerDelegate.provider reportOutgoingCallWithUUID:uuid
                                                                                   connectedAtDate:nil];
                    //NSString *address = [FastAddressBook displayNameForAddress:linphone_call_get_remote_address(call)];
                    CXCallUpdate *update = [[CXCallUpdate alloc] init];
                    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:self.fromContact.text];
                    update.supportsGrouping = TRUE;
                    update.supportsDTMF = TRUE;
                    update.supportsHolding = TRUE;
                    update.supportsUngrouping = TRUE;
                    [LinphoneManager.instance.providerDelegate.provider reportCallWithUUID:uuid updated:update];
                }
            }
        }
            break;
            
        case LinphoneCallError: {
            KLog(@":ERROR -- cannot make call");
            isCallConnected = NO;
            break;
        }
        case LinphoneCallEnd:
            KLog(@"call ended");
            if(linphone_core_get_calls_nb(LC)<=0) {
                self.lblDuration.text = @"call ended";
                isCallConnected = NO;
            }
            break;
            
        case LinphoneCallPaused:
        case LinphoneCallPausing:
            self.lblDuration.text = @"call on hold";
            isCallConnected = NO;
            break;
            
        case LinphoneCallResuming:
        {
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max && call) {
                NSUUID *uuid = (NSUUID *)[LinphoneManager.instance.providerDelegate.uuids
                                          objectForKey:[NSString stringWithUTF8String:linphone_call_log_get_call_id(
                                                                                                                    linphone_call_get_call_log(call))]];
                if (!uuid) {
                    return;
                }
                KLog(@"Calling performSetHeldCallAction");
                CXSetHeldCallAction *act = [[CXSetHeldCallAction alloc] initWithCallUUID:uuid onHold:NO];
                CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];
                [LinphoneManager.instance.providerDelegate.controller requestTransaction:tr
                                                                              completion:^(NSError *err){
                                                                              }];
                isCallConnected = YES;
            }
            break;
        }
            
        default:
        {
            KLog(@"callUpdate: Not handled");
            break;
        }
    }
}

-(void)NetworkStatusUpdate:(NSNotification*)notif {
    
    self.isNetReachable = [[notif.userInfo objectForKey:@"NetReachable"]boolValue];
    KLog(@"notif=%@",notif);
    EnLogd(@"notif=%@",notif);
    
    if(!self.isNetReachable) {
        KLog(@"Reconnecting...");
        self.lblDuration.text = @"Reconnecting...";
    } else {
        self.lblDuration.text = @"";
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

- (NSString *)durationToString:(int)duration {
    
    NSMutableString *result = [[NSMutableString alloc] init];
    if (duration / 3600 > 0) {
        [result appendString:[NSString stringWithFormat:@"%02i:", duration / 3600]];
        duration = duration % 3600;
    }
    return [result stringByAppendingString:[NSString stringWithFormat:@"%02i:%02i", (duration / 60), (duration % 60)]];
}

- (void)callDurationUpdate {
    
    if(!self.call) {
        return;
    }
    
    LinphoneCallState state = linphone_call_get_state(self.call);
    
    KLog(@"state = %@",[LinphoneCoreSettingsStore getCallStateString:state]);
    EnLogd(@"state = %d",state);
    
    KLog(@"connectivity = %d, reachable = %d",LinphoneManager.instance.connectivity, self.isNetReachable);
    if(LinphoneManager.instance.connectivity == none && !self.isNetReachable) {
        KLog(@"Reconnecting...");
        EnLogd(@"Reconnecting...");
        self.lblDuration.text = @"Reconnecting...";
    } else if(LinphoneCallPausedByRemote == state) {
        KLog(@"Call on hold");
        EnLogd(@"Call on hold");
        self.lblDuration.text = @"Call on hold";
    }
    else if (LinphoneCallPaused == state) {
        callDuration++;
        self.lblDuration.text = @"Call on hold";
    }
    else if(LinphoneCallConnected == state || LinphoneCallStreamsRunning == state
            || LinphoneCallUpdating == state || LinphoneCallUpdatedByRemote == state) {
        //int duration = linphone_call_log_get_duration(callLog);
        if(callDuration >= GSM_CALL_DURATION_LIMIT && [LinphoneManager.instance.callType isEqualToString:@"gsm"]) {
            KLog(@"Reached the max duration for GSM call. Terminate the call.");
            linphone_call_terminate(self.call);
            //TODO -- Do we need to display any popup message stating the current call is terminated.
        }
        callDuration++;
        self.lblDuration.text = [self durationToString:callDuration];
    }
    else if(LinphoneCallOutgoing == state || LinphoneCallOutgoingInit == state ||
            LinphoneCallOutgoingRinging == state || LinphoneCallOutgoingProgress == state ||
            LinphoneCallOutgoingEarlyMedia == state) {
        self.lblDuration.text = @"Calling...";
    }
    else if(LinphoneCallEnd == state) {
    }
    else {
        KLog(@"Reconnecting...");
        self.lblDuration.text = @"Reconnecting...";
    }
}

- (IBAction)gotoIVHome:(id)sender {
    
    /*
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setRootViewControllerWithPhoneView:NO];
     */
}

- (IBAction)btnHangupTouched:(id)sender {
    
    /*
    const LinphoneAddress* toAddress =  linphone_call_get_to_address(self.call);
    const char *lUserName = linphone_address_get_username(toAddress);
    NSString* toContact = [NSString stringWithUTF8String:lUserName];
    KLog(@"toContact = %@",toContact);
    */
    
    KLog(@"CallDuration1: %d",callDuration);
    callDuration =
        linphone_core_get_current_call(LC) ? linphone_call_get_duration(linphone_core_get_current_call(LC)) : 0;
    
    KLog(@"CallDuration2: %d",callDuration);
    
    self.lblDuration.text = @"call ending...";
    if(updateTimer != nil)
       [updateTimer invalidate];
    /* MAY 22, 2018
    if(self.call) {
        linphone_call_terminate(self.call);
    } else {
        KLog(@"ERROR:call obj is nil");
    }*/
    
    NSMutableDictionary* dic = nil;
    if(!self.pushDict) {
        //Probably, delayed push notification
        dic = [[NSMutableDictionary alloc]init];
        [dic setValue:contactName forKey:REMOTE_USER_NAME];
        [dic setValue:ivUserId forKey:REMOTE_USER_IV_ID];
        [dic setValue:imageURLString forKey:REMOTE_USER_PIC];
        [dic setValue:self.callID forKey:VOIP_CALL_ID];
    } else {
        [self.pushDict setValue:contactName forKey:REMOTE_USER_NAME];
        [self.pushDict setValue:ivUserId forKey:REMOTE_USER_IV_ID];
        [self.pushDict setValue:imageURLString forKey:REMOTE_USER_PIC];
        [self.pushDict setValue:self.callID forKey:VOIP_CALL_ID];
    }
    
    [self.delegate callEnded:callDuration UserInfo:dic];
    
    //May 22, 2018
    if(self.call) {
        linphone_call_terminate(self.call);
    } else {
        KLog(@"ERROR:call obj is nil");
        linphone_core_terminate_all_calls([LinphoneManager getLc]);
    }
    //
}

- (IBAction)btnMicTouched:(id)sender {
    
    self.micEnabled = !self.micEnabled;
    [self setMicImage:self.micEnabled];
}

- (IBAction)btnSpeakerTouched:(id)sender {

    self.speakerEnabled = !self.speakerEnabled;
    [self setSpeakerImage:self.speakerEnabled];
    [self performSelector:@selector(changeAudioRoute) withObject:nil afterDelay:0.1];
}

- (IBAction)btnHideTouched:(id)sender {
    [self hideKeypad];
}

- (IBAction)btnKeypadTouched:(id)sender {
    [self showKeypad];
}

-(void) showKeypad {
    if(!isCallConnected) {
        return;
    }
    
    self.hideButton.hidden = NO;
    
    self.lblMute.hidden = YES;
    self.lblKeypad.hidden = YES;
    self.lblSpeaker.hidden = YES;
    
    self.btnMic.hidden = YES;
    self.btnKeypad.hidden = YES;
    self.btnSpeaker.hidden = YES;
    self.imgProfile.hidden = YES;
    
    if(self.isIncomingCall) {
        self.toContact.hidden = YES;
    }
    
    dialpadView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView animateWithDuration:0.2
                     animations:^{
                         dialpadView.hidden = NO;
                         dialpadView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

-(void) hideKeypad {
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         dialpadView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.3, 0.3);
                     } completion:^(BOOL finished) {
                         dialpadView.hidden = YES;
                         self.hideButton.hidden = YES;
                         
                         self.lblMute.hidden = NO;
                         self.lblKeypad.hidden = NO;
                         self.lblSpeaker.hidden = NO;
                         
                         self.btnMic.hidden = NO;
                         self.btnKeypad.hidden = NO;
                         self.btnSpeaker.hidden = NO;
                         self.imgProfile.hidden = NO;
                         
                         if(self.isIncomingCall) {
                             self.toContact.hidden = YES;
                         }
                     }];
}

-(void)changeAudioRoute {
    
    [LinphoneManager.instance setSpeakerEnabled:self.speakerEnabled];
}

- (void)setSpeakerImage:(BOOL)speakerEnabled {

    UIImage* imgSpk=nil;
    if(speakerEnabled) {
        imgSpk = [UIImage imageNamed:@"vc_speaker_on"];
    }
    else {
        imgSpk = [UIImage imageNamed:@"vc_speaker_off"];
    }
    [self.btnSpeaker setImage:imgSpk forState:UIControlStateNormal];
}

- (void)setMicImage:(BOOL)micEnabled {
    
    UIImage* imgMic=nil;
    if(micEnabled)
        imgMic = [UIImage imageNamed:@"vc_mute_off"];
    else
        imgMic = [UIImage imageNamed:@"vc_mute_on"];
    
    [self.btnMic setImage:imgMic forState:UIControlStateNormal];
    linphone_core_enable_mic(LC,self.micEnabled);
}

-(int)getCallDuration {
    return callDuration;
}

- (IBAction)hideButton:(id)sender {
    
}
@end
