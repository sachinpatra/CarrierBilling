//
//  ProviderDelegate.h
//  linphone
//
//  Created by REIS Benjamin on 29/11/2016.
//
//

#ifndef ProviderDelegate_h
#define ProviderDelegate_h

#import <CallKit/CallKit.h>
#import <linphone/types.h>
#import "PhoneViewControllerDelegate.h"

#define PROVIDER_NAME @"ReachMe"

@class AppDelegate;

@interface ProviderDelegate : NSObject <CXProviderDelegate, CXCallObserverDelegate, PhoneViewControllerDelegate>
{
    AppDelegate* appDelegate;
    NSString* _fromContact;
    NSString* _toContact;
    NSInteger lastSelectedTab;
    UIViewController* lastVC;
}

@property CXProvider *provider;
@property CXCallObserver *observer;
@property CXCallController *controller;
@property NSMutableDictionary *calls;
@property NSMutableDictionary *uuids;
@property LinphoneCall *pendingCall;
@property LinphoneAddress *pendingAddr;
@property BOOL pendingCallVideo;
@property int callKitCalls;
@property BOOL isMicOn;
@property NSString* fromContact;
@property NSString* toContact;
@property NSString* contactName;
@property NSMutableDictionary* pushDict;
@property NSMutableArray* lastCallInfo;
@property BOOL hangupTapped;

- (void)reportIncomingCallwithUUID:(NSUUID *)uuid handle:(NSString *)handle video:(BOOL)video;
- (void)makeCall:(NSString*)toNumber FromNumber:(NSString*)fromNumber;
- (void)config:(NSString*)ringTone;
- (void)configAudioSession:(AVAudioSession *)audioSession;
- (void)onCallStateChanged:(NSDictionary*)info;
//- (NSMutableDictionary*)getCallLog:(NSString*)callId;

-(NSString*)getIVUserNameFromPhoneNumber:(NSString*)number;
@end

#endif /* ProviderDelegate_h */
