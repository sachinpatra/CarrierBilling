//
//  Audio.h
//  InstaVoice
//
//  Created by Vivek Mudgil on 29/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

#define HEADPHONES                  @"Headphones"
#define SPEAKAER                    @"Speaker"
#define RECEIVER                    @"Receiver"

@protocol AudioDelegate <NSObject>
-(void)audioDidCompletePlayingData;
//state YES indicates that device is closer to user
-(void)didProximityStateChange:(BOOL)state;
-(void)didAudioRouteChange:(NSInteger)reason;
@end

@class Common;
@interface Audio : NSObject<AVAudioRecorderDelegate, AVAudioPlayerDelegate,AVAudioSessionDelegate>
{
    AVAudioSession      *_session;
    AVAudioRecorder     *_recorder;              //AudioRecorder Object
    AVAudioPlayer       *_player;                //AudioPlayer   Object
}
/* ----------------Properties of Audio sessions------------------------- */
@property BOOL isPlay;
@property BOOL isRecord;
@property (nonatomic,weak) id<AudioDelegate> delegate;

-(void)startRecordingAudioMsgAtFilePath:(NSString*)pathName;
-(NSString *)stopAndGetRecordedFilePath;
-(void) cancelRecording;
-(void)pauseRecording;


-(BOOL)startPlayback:(NSString *)filePath playTime:(int)time playMode:(BOOL)speaker;
-(void)stopPlayback;
-(void)pausePlayBack;


//Function: set Mute/Unmute Mode
-(void)setVolume:(int)mode;
+(BOOL)isHeadsetPluggedIn;

-(void)addObserverForAudioRouteChange;
-(void)removeObserverForAudioRouteChange;

-(void)setCurrentTime:(double)time;
-(double)getCurrentTime;

@end
