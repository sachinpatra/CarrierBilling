//
//  PhoneViewController.h
//  InstaVoice
//
//  Created by Pandian on 7/5/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinphoneManager.h"
#import "PhoneViewControllerDelegate.h"
#import "BaseUI.h"

@interface PhoneViewController : BaseUI  //UIViewController
{
    
    NSString* _fromAddress;
    NSString* _toAddress;
    NSMutableDictionary* _pushDict;
    BOOL isCallConnected;
    //LinphoneCallLog* callLog;
}

@property (weak, nonatomic) IBOutlet UIButton *btnMic;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnSpeaker;
@property (weak, nonatomic) IBOutlet UIButton *btnHangupCall;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UILabel *fromContact;
@property (weak, nonatomic) IBOutlet UIImageView *bgScreen;
@property (weak, nonatomic) IBOutlet UILabel *toContact;
@property (weak, nonatomic) IBOutlet UIButton *btnKeypad;
@property (weak, nonatomic) IBOutlet UIButton *hideButton;

@property (weak, nonatomic) IBOutlet UILabel *lblKeypad;
@property (weak, nonatomic) IBOutlet UILabel *lblMute;
@property (weak, nonatomic) IBOutlet UILabel *lblSpeaker;

@property LinphoneCall* call;
@property NSString* callID;
@property NSString* fromAddress;
@property NSString* toAddress;
@property BOOL isIncomingCall;//APR 16, 2018
@property NSMutableDictionary* pushDict;
@property id<PhoneViewControllerDelegate> delegate;

- (IBAction)gotoIVHome:(id)sender;
- (IBAction)btnHangupTouched:(id)sender;
- (IBAction)btnMicTouched:(id)sender;
- (IBAction)btnSpeakerTouched:(id)sender;
- (IBAction)btnHideTouched:(id)sender;
- (IBAction)btnKeypadTouched:(id)sender;
- (int)getCallDuration;
- (void)changeAudioRoute;
@end
