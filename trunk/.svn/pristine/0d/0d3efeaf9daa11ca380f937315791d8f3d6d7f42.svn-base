//
//  Audio.m
//  InstaVoice
//
//  Created by Vivek Mudgil on 29/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "Audio.h"
#import "SizeMacro.h"
#import "Macro.h"
#import "Logger.h"

@interface Audio ()
@end

@implementation Audio

@synthesize isPlay;
@synthesize isRecord;

-(id)init
{
    if(self = [super init])
    {
        _session = [AVAudioSession sharedInstance];
        [_session setCategory:AVAudioSessionCategoryPlayAndRecord
                  withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        BOOL result = [_session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error: nil];
        if(!result) {
            KLog(@"init -- Error setActive:NO");
        }
    }
    return self;
}

-(void)startRecordingAudioMsgAtFilePath:(NSString*)pathName
{
    KLog(@"startRecordingAudioMsgAtFilePath:%@",pathName);
    
    if([self setRecorderWithFileName:pathName])
    {
        if (_player.playing)
        {
            [_player pause];
        }
        if (!_recorder.recording)
        {
            isRecord = TRUE;
            NSError *error= nil;
            [_session setActive:YES error:&error];
            if(error != nil)
            {
                KLog(@"ERROR: AVAudioSession activation failed: %@",[error localizedDescription]);
            }
            // Start recording
            [_recorder record];
        }
        else
        {
            [_recorder pause];
        }
    }
}

-(BOOL)setRecorderWithFileName:(NSString*)outputFilePath
{
    NSURL *outputFileURL = [NSURL fileURLWithPath:outputFilePath isDirectory:NO];
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
#ifdef OPUS_ENABLED
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
#else
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatALaw] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:SIZE_8000] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt:8] forKey:AVEncoderBitRateKey];
#endif
    
    NSError* error = nil;
    // Initiate and prepare the recorder
    _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:&error];
    _recorder.delegate = self;
    //recorder.meteringEnabled = YES;
    if (error)
    {
        KLog(@"ERROR - AVAudioRecorder obj initialization failed:%@", [error localizedDescription]);
        return false;
    }
    
    return true;
}

-(NSString*) stopAndGetRecordedFilePath
{
    [_recorder stop];
    isRecord = FALSE;
    
    BOOL result =  [_session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error: nil];
    if(!result) {
        KLog(@"stopAndGetRecordedFilePath -- Error setActive:NO");
    }
    
    return [[_recorder url]path];//_recordingFilePath;
}

-(void)cancelRecording
{
    [_recorder stop];
    isRecord = FALSE;
    KLog(@"Delete recording");
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_recorder.url.path]) {
        if(![_recorder deleteRecording]) {
            KLog(@"Error deleting audio file");
        }
    }
    else {
        KLog(@"file is not present.");
    }
    
    BOOL result = [_session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error: nil];
    if(!result) {
        KLog(@"cancelRecording -- Error setActive:NO");
    }
    KLog(@"delete recording -- end");
}

-(void)pauseRecording
{
    if(_recorder.recording)
    {
        isRecord = FALSE;
        [_recorder stop];
        
        BOOL result =  [_session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error: nil];
        if(!result) {
            KLog(@"pauseRecording -- Error setActive:NO");
        }
    }
}

-(BOOL)startPlayback:(NSString *)filePath playTime:(int)time playMode:(BOOL)speaker
{
    //KLog(@"Start Playing");
    NSError *error = nil;
    
    if(_recorder.recording) {
        [_recorder stop];
    }
    
    // Set the audio file
    if (!_recorder.recording)
    {
        isPlay = TRUE;
        if(_player.isPlaying)
        {
            [_player pause];
        }
        NSURL *outputFileURL = [NSURL fileURLWithPath:filePath];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:outputFileURL error:&error];
        if(error)
        {
            KLog(@"ERROR: Initializing AVAudioPlayer failed. %@", [error localizedDescription]);
            return FALSE;
        }
        else
        {
            //KLog(@"Audio Player created");
            //DEC 7, 15 [_player prepareToPlay];
            //DEC 1, 15 _player.volume = 0.7;
            _player.delegate = self;
            _player.numberOfLoops = 0;
            _player.currentTime = time;
            
            NSError* error = nil;
            BOOL success = [_session setActive:YES error:nil];
            if(!success) {
                KLog(@"Error in setting AV session active");
            }
            if( speaker ) {
                KLog(@"Playing in speaker mode");
                success = [_session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
                if(!success) {
                    KLog(@"Error routing audio to sepaker %@",error);
                }
            }
            else {
                KLog(@"Playing in caller mode");
                success = [_session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
                if(!success) {
                    KLog(@"Error routing audio to sepaker %@",error);
                }
            }
            [_player play];
            
            BOOL isHeadPhonePluggedin = [Audio isHeadsetPluggedIn];
            
            if(!isHeadPhonePluggedin) {
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
            }
        }
    }
    else
    {
        KLog(@"Recorder is active.");
        return false;
    }
    return true;
}

- (void)didSensorStateChange:(NSNotificationCenter *)notification
{
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        KLog(@"Device is close to user.");
        [self setVolume:CALLER_MODE];
        
        if([self.delegate respondsToSelector:@selector(didProximityStateChange:)])
            [self.delegate didProximityStateChange:YES];
    }
    else
    {
        KLog(@"Device is not closer to user.");
        if([self.delegate respondsToSelector:@selector(didProximityStateChange:)])
            [self.delegate didProximityStateChange:NO];
        
        //[self setVolume:SPEAKER_MODE];
    }
}

-(void)pausePlayBack
{
    KLog(@"pausePlayBack");
    if(_player.isPlaying)
    {
        isPlay = FALSE;
        [_player pause];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    BOOL result = [_session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    if(!result) {
        KLog(@"pausePlayback -- Error setActive:NO");
    }
}

-(void)stopPlayback
{
    KLog(@"stopPlayback");
    isPlay = FALSE;
    [_player stop];

    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    BOOL result = [_session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];

    if(!result) {
        KLog(@"stopPlayback -- Error setActive:NO");
    }
}


#pragma mark -- AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    KLog(@"audioPlayerDidFinishPlaying");
    
    [_player stop];
    isPlay = FALSE;
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    //LinphoneCall *call = linphone_core_get_current_call(LC);
    BOOL result = [_session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error: nil];
    if(!result) {
        KLog(@"audioPlayerDidFinishPlaying -- Error setActive:NO");
    }
    
    if([self.delegate respondsToSelector:@selector(audioDidCompletePlayingData)])
        [self.delegate audioDidCompletePlayingData];
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    KLog(@"audioPlayerDecodeErrorDidOccur: %@",error);
}

//
//-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
//{
//    [_player stop];
//    [_recorder stop];
//    
//    BOOL result = [_session setActive:YES error:nil];
//    if(!result) {
//        KLog(@"stopAndGetRecordedFilePath -- Error setActive:NO");
//    }
//    KLog(@"Audio recording finished.");
//}


//-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
//{
//    EnLoge(@"ERROR: AudioRecorder Encode Error: %@",[error localizedDescription]);
//}
//
//-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
//{
//   EnLoge(@"ERROR: AudioPlayer Decode Error occurred: %@",[error localizedDescription]);
//}
//-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
//{
//    EnLoge(@"ERROR AudioPlayer Interrupt Error occurred");
//}

-(void)setVolume:(int)mode
{
    NSError *error=nil;
    if(mode == SPEAKER_MODE)
    {
        KLog(@"Set Speaker mode");
        if(![_session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error]) {
            KLog(@"***ERROR*** enable speaker mode");
        }
    }
    else {
        KLog(@"Set caller mode");
        if(![_session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error]) {
            KLog(@"***ERROR*** disable speaker mode");
        }
    }
}

+(BOOL)isHeadsetPluggedIn
{
    BOOL bRet = FALSE;
    // Get array of current audio outputs (there should only be one)
    NSArray *outputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    NSString *portName=nil;
    NSString *portType=nil;
    if(outputs.count>0) {
        portName = [[outputs objectAtIndex:0] portName];
        portType = [[outputs objectAtIndex:0] portType];
    }
    
    if ([portName isEqualToString:HEADPHONES])
    {
        bRet = TRUE;
    }
    else if([portType isEqualToString:AVAudioSessionPortBluetoothHFP] || [portType isEqualToString:AVAudioSessionPortBluetoothA2DP])
    {
        bRet = TRUE;
    }
     
    /*
    NSArray *arrayInputs = [[AVAudioSession sharedInstance] availableInputs];
    for (AVAudioSessionPortDescription *port in arrayInputs)
    {
        if ([port.portType isEqualToString:AVAudioSessionPortBluetoothHFP])
        {
            bRet = YES;
            break;
        }
    }*/
    
    return bRet;
}

#pragma mark AVAudioSessionRouteChangeNotification

-(void)addObserverForAudioRouteChange
{
    KLog(@"addObserverForAudioRouteChange");
    //EnLogd(@"addObserverForAudioRouteChange");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
}

-(void)removeObserverForAudioRouteChange
{
    KLog(@"removeObserverForAudioRouteChange");
    //EnLogd(@"removeObserverForAudioRouteChange");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionRouteChangeNotification
                                                  object:nil];
}

- (void)routeChange:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    if([self.delegate respondsToSelector:@selector(didAudioRouteChange:)]) {
        [self.delegate didAudioRouteChange:routeChangeReason];
    }
}

-(void)setCurrentTime:(double)time {
     _player.currentTime = time;
}

-(double)getCurrentTime
{
    return _player.currentTime;
}

@end
