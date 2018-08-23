//
//  SettingsMissedCallRecordAudioViewController.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 10/14/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "SettingsMissedCallRecordAudioViewController.h"
#import "MZFormSheetController.h"
#import "MZCustomTransition.h"
#import "IVFileLocator.h"
#import "ScreenUtility.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define INT_9                       9
#define INT_60                      60

@interface SettingsMissedCallRecordAudioViewController ()

@end

@implementation SettingsMissedCallRecordAudioViewController
@synthesize     audioObj;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isRecordingCompleted = NO;
    audioObj =[[Audio alloc]init];
    /* DEC 21
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(cancelTapped:)
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil];
     */

    self.hidesBottomBarWhenPushed  = YES;//KM
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.uiType = MISSED_CALL_SCREEN;
    [appDelegate.stateMachineObj setCurrentPresentedUI:self];
    [self setRecordingTitles];
    [self setupStartRecording:nil];
    [self.view bringSubviewToFront:self.tapToRecordButton];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [appDelegate.stateMachineObj setCurrentUI:nil];//DEC 21
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- View Initial setup
-(void)setRecordingTitles
{
    NSString *welcome = @"Record Welcome Message";
    NSString *name = @"Record Name";
    NSString *welcomeTime = @"(maximum allowed time is 15 seconds)";
    NSString *nameTime = @"(maximum allowed time is 2 seconds)";
    NSString *mobNumber = [appDelegate.confgReader getLoginId];
    self.recordingFileNameForGreetingsName = [NSString stringWithFormat:@"te_mp_name_greeting_%@",mobNumber];
    self.recordingFileNameForGreetingsMessage = [NSString stringWithFormat:@"te_mp_welcome_greeting_%@",mobNumber];
    self.tapMessage.text = @"Tap on mike to begin recording";
    [circleDraw.sendButton addTarget:self action:@selector(startRecordingTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.startOrConfirm.tag = 100;
    switch (self.buttonTag) {
        case 10001:
        case 11001:
        case 10101:
        case 11101:
        case 790:
            self.recordingType.text = name;
            self.recordingDuration.text = nameTime;
            maxVoiceMsgDuration = 2;
            self.recordingFileName = self.recordingFileNameForGreetingsName;
            self.nameOrWelcome = @"name";
            break;
        case 10002:
        case 11002:
        case 10102:
        case 11102:
        case 791:
            self.recordingType.text = welcome;
            self.recordingDuration.text = welcomeTime;
            maxVoiceMsgDuration = 15;
            self.recordingFileName = self.recordingFileNameForGreetingsMessage;
            self.nameOrWelcome = @"welcome";
            break;
            /*case 11001:
             self.recordingType.text = name;
             self.recordingDuration.text = nameTime;
             maxVoiceMsgDuration = 4;
             self.recordingFileName = self.recordingFileNameForGreetingsName;
             self.nameOrWelcome = @"name";
             break;
             case 11002:
             self.recordingType.text = welcome;
             self.recordingDuration.text = welcomeTime;
             maxVoiceMsgDuration = 15;
             self.recordingFileName = self.recordingFileNameForGreetingsMessage;
             self.nameOrWelcome = @"welcome";
             break;
             case 10101:
             self.recordingType.text = name;
             self.recordingDuration.text = nameTime;
             maxVoiceMsgDuration = 4;
             self.recordingFileName = self.recordingFileNameForGreetingsName;
             self.nameOrWelcome = @"name";
             break;
             case 10102:
             self.recordingType.text = welcome;
             self.recordingDuration.text = welcomeTime;
             maxVoiceMsgDuration = 15;
             self.recordingFileName = self.recordingFileNameForGreetingsMessage;
             self.nameOrWelcome = @"welcome";
             break;
             case 11101:
             self.recordingType.text = name;
             self.recordingDuration.text = nameTime;
             maxVoiceMsgDuration = 4;
             self.recordingFileName = self.recordingFileNameForGreetingsName;
             self.nameOrWelcome = @"name";
             break;
             case 11102:
             self.recordingType.text = welcome;
             self.recordingDuration.text = welcomeTime;
             maxVoiceMsgDuration = 15;
             self.recordingFileName = self.recordingFileNameForGreetingsMessage;
             self.nameOrWelcome = @"welcome";
             break;*/
            
        default:
            break;
    }
}

-(void)setupStartRecording:(id)sender
{
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
#ifdef REACHME_APP
        NSString* text = @"ReachMe app needs access to Microphone to record your Voicemail greetings.";
#else
        NSString* text = @"InstaVoice app needs access to Microphone to record your Voicemail greetings.";
#endif
        if(![self checkMicrophonePermission:text])
        {
            return;
        }
    }

    if(circleDraw != nil)
    {
        [circleDraw removeFromSuperview];
    }
    circleDraw = nil;
    if(drawStripTimer != nil)
    {
        [drawStripTimer invalidate];
    }
    recordingView.hidden    = NO;
    [self.view bringSubviewToFront:recordingView];
    
    timerLabel = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_40,SIZE_60,SIZE_70,SIZE_25)];
    [timerLabel setFont:[UIFont fontWithName:HELVETICANEUE_LIGHT size:SIZE_15]];
    [timerLabel setBackgroundColor:[UIColor clearColor]];
    [timerLabel setTextColor:[UIColor whiteColor]];
    [timerLabel setText:@"00:00"];
    headingLabel.text     =  NSLocalizedString(@"RELEASE_TO_SEND",nil);
    CGRect currentFrame = headingLabel.frame;
    CGSize max = CGSizeMake(headingLabel.frame.size.width, SIZE_312);
    headingLabel.numberOfLines = SIZE_0;
    //DC MAY 26 2016
    NSAttributedString *expectedAttributedString;
    if (headingLabel.text.length) {
         expectedAttributedString = [[NSAttributedString alloc]initWithString:headingLabel.text  attributes:@{NSFontAttributeName:headingLabel.font}];
    }
    else
        expectedAttributedString = [[NSAttributedString alloc]initWithString:@""  attributes:@{}];
    
    CGRect expectedStringRect = [expectedAttributedString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGSize expected = expectedStringRect.size;
    
    //CGSize expected = [headingLabel.text sizeWithFont:headingLabel.font constrainedToSize:max lineBreakMode:headingLabel.lineBreakMode];
    currentFrame.size.height = expected.height;
    headingLabel.frame = currentFrame;
    circleDraw =[[CircleProgressView alloc] initWithFrame:CGRectMake(SIZE_100,SIZE_32,SIZE_120,SIZE_120)];
    circleDraw.selectColor = 1;
    circleDraw.backgroundColor = [UIColor clearColor];
    EnLogd(@"Max voice Duration : %d",maxVoiceMsgDuration);
    circleDraw.maxDurationTime = maxVoiceMsgDuration;
    
    [circleDraw.sendButton addTarget:self action:@selector(listenRecording) forControlEvents:UIControlEventTouchUpInside];
    
    circleSubView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:IMG_LOADER_RED_RECORDING]];
    circleSubView.tag = 0;
    circleDraw.sendButton.hidden = YES;
    
    
    [self.view bringSubviewToFront:micButtonView];
    
    
    [recordingView addSubview:circleDraw];
    [circleSubView addSubview:timerLabel];
    [circleDraw setUserInteractionEnabled:YES];
    [circleSubView setUserInteractionEnabled:YES];
    
    
    circleProgressCount = 360/maxVoiceMsgDuration;
    circleDraw.startAngle = DEGREES_TO_RADIANS(-90);
    
    int a = 0;
    if (maxVoiceMsgDuration < 5) {
        a = 1;
    }
    else
    {
        a = .005;
    }
    circleDraw.endAngle   = (circleDraw.startAngle + DEGREES_TO_RADIANS(circleProgressCount))-a;
    circleDraw.duration = 0;
    recordingArea.frame = CGRectMake(0,self.view.frame.size.height-(SIZE_55),DEVICE_WIDTH, SIZE_62);
}

#pragma mark -- View Initial setup End
#pragma mark -- confirm or cancel button action
-(IBAction)cancelTapped:(id)sender
{
    self.isOkTapped = NO;
    [self stopRecordingTimer];
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
    
}
-(IBAction)startRecordingTapped:(id)sender
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    UIButton *btn = (UIButton*)sender;
    if ([[btn titleForState:UIControlStateNormal] isEqualToString:@"Confirm"]) {
        [self sendRecording];
    }
    else {
        [self.tapToRecordButton setHidden:YES];
        [self.beginCancelButton setHidden:YES];
        NSString *storagePath   = [[IVFileLocator getMyProfilePicPath:self.recordingFileName] stringByAppendingPathExtension:@"wav"];
        [audioObj startRecordingAudioMsgAtFilePath:storagePath];
        recorderTimer  =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startRecordTimer) userInfo:nil repeats:YES];
        self.tapMessage.text = @"Tap on mike to finish recording";
        NSMutableString *recordingText = [self.recordingType.text mutableCopy];
        [recordingText replaceOccurrencesOfString:@"Record" withString:@"Recording" options:NSCaseInsensitiveSearch range:NSMakeRange(0, recordingText.length)];
        self.recordingType.text = recordingText;
        
        
        circleDraw.sendButton.hidden = NO;
    }
}

-(NSInteger)getFileDuration:(NSString*)localFilePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attrs = [fm attributesOfItemAtPath: localFilePath error: NULL];
    UInt32 pcmFileSize = [attrs fileSize]/16000;
    KLog(@"%@",attrs);
    return pcmFileSize;
}

-(void)listenRecording
{
    if (self.startOrConfirm.tag == 55) {
        //self.audioObj = [[Audio alloc]init];
        int speakerMode = (CALLER_MODE == [appDelegate.confgReader getVolumeMode])?false:true;
        [self.audioObj startPlayback:[audioObj stopAndGetRecordedFilePath] playTime:-1 playMode:speakerMode];
        
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        if(circleDraw != nil)
        {
            [circleDraw removeFromSuperview];
        }
        circleDraw = nil;
        if(drawStripTimer != nil)
        {
            [drawStripTimer invalidate];
        }
        recordingView.hidden    = NO;
        [self.view bringSubviewToFront:recordingView];
        
        timerLabel = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_40,SIZE_45,SIZE_70,SIZE_25)];
        [timerLabel setFont:[UIFont fontWithName:HELVETICANEUE_LIGHT size:SIZE_15]];
        [timerLabel setBackgroundColor:[UIColor clearColor]];
        [timerLabel setTextColor:[UIColor whiteColor]];
        [timerLabel setText:@"00:00"];
        headingLabel.text     =  NSLocalizedString(@"RELEASE_TO_SEND",nil);
        CGRect currentFrame = headingLabel.frame;
        CGSize max = CGSizeMake(headingLabel.frame.size.width, SIZE_312);
        headingLabel.numberOfLines = SIZE_0;
        //DC MAY 26 2016
        
        NSAttributedString *expectedAttributedString;
        if (headingLabel.text.length) {
            expectedAttributedString = [[NSAttributedString alloc]initWithString:headingLabel.text  attributes:@{NSFontAttributeName:headingLabel.font}];
        }
        else
            expectedAttributedString = [[NSAttributedString alloc]initWithString:@""  attributes:@{}];
        
        CGRect expectedStringRect = [expectedAttributedString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        CGSize expected = expectedStringRect.size;
        //CGSize expected = [headingLabel.text sizeWithFont:headingLabel.font constrainedToSize:max lineBreakMode:headingLabel.lineBreakMode];
        currentFrame.size.height = expected.height;
        headingLabel.frame = currentFrame;
        circleDraw =[[CircleProgressView alloc] initWithFrame:CGRectMake(SIZE_100,SIZE_32,SIZE_120,SIZE_120)];
        circleDraw.selectColor = 1;
        circleDraw.backgroundColor = [UIColor clearColor];
        EnLogd(@"Max voice Duration : %d",maxVoiceMsgDuration);
        circleDraw.maxDurationTime = maxVoiceMsgDuration;
        
        [circleDraw.sendButton addTarget:self action:@selector(listenRecording) forControlEvents:UIControlEventTouchUpInside];
        
        circleSubView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:IMG_LOADER_GREEN_PLAYING]];
        circleSubView.tag = 0;
        circleDraw.sendButton.hidden = YES;
        
        [self.view bringSubviewToFront:micButtonView];
        
        [recordingView addSubview:circleDraw];
        [circleSubView addSubview:timerLabel];
        [circleDraw setUserInteractionEnabled:YES];
        [circleSubView setUserInteractionEnabled:YES];
        
        if (maxVoiceMsgDuration<=0) {
            maxVoiceMsgDuration = 1;
        }
        
        circleProgressCount = 360/maxVoiceMsgDuration;
        circleDraw.startAngle = DEGREES_TO_RADIANS(-90);
        
        int a = 0;
        if (maxVoiceMsgDuration < 5) {
            a = 1;
        }
        else
        {
            a = .005;
        }
        circleDraw.endAngle   = (circleDraw.startAngle + DEGREES_TO_RADIANS(circleProgressCount))-a;
        circleDraw.duration = 0;
        recordingArea.frame = CGRectMake(0,self.view.frame.size.height-(SIZE_55),DEVICE_WIDTH, SIZE_62);
        recorderTimer  =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startRecordTimer) userInfo:nil repeats:YES];
        
    }
    else
    {
        self.startOrConfirm.tag = 55;
        [recorderTimer invalidate];
        recorderTimer = nil;
        [imageTime  invalidate];
        imageTime = nil;
        circleDraw.duration = maxVoiceMsgDuration;
        [audioObj pauseRecording];
        audiofilePath = [audioObj stopAndGetRecordedFilePath];
        
        [circleDraw removeFromSuperview];
        circleDraw =[[CircleProgressView alloc] initWithFrame:CGRectMake(SIZE_100,SIZE_32,SIZE_120,SIZE_120)];
        circleDraw.selectColor = 1;
        circleDraw.backgroundColor = [UIColor clearColor];
        circleSubView.tag = 0;
        
        circleDraw.sendButton.hidden = NO;
        [circleDraw.sendButton addTarget:self action:@selector(listenRecording) forControlEvents:UIControlEventTouchUpInside];
        nameDurationTime = [self getFileDuration:[audioObj stopAndGetRecordedFilePath]];
        KLog(@"File is vinoth %@",[audioObj stopAndGetRecordedFilePath]);
        maxVoiceMsgDuration = nameDurationTime;
        
        NSMutableString *recordingText = [self.recordingType.text mutableCopy];
        [recordingText replaceOccurrencesOfString:@"Recording" withString:@"Set" options:NSCaseInsensitiveSearch range:NSMakeRange(0, recordingText.length)];
        self.recordingType.text = recordingText;
        
        self.recordingDuration.text = [NSString stringWithFormat:@"(current recording: %d seconds long)",maxVoiceMsgDuration];
        
        //For text reflow related
        self.recordingDuration.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
        
        //continue here
        if (maxVoiceMsgDuration <= 0) {
            KLog(@"Recording time is too low, Please record again");
            
            alertView = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Recorded message is less than one second. Please record again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            [audioObj stopAndGetRecordedFilePath];
            [self stopRecordingTimer];
            audiofilePath = nil;
            
            [self setRecordingTitles];
            [self setupStartRecording:nil];
            [self.view bringSubviewToFront:self.tapToRecordButton];
            [self.tapToRecordButton setHidden:NO];
            [self.beginCancelButton setHidden:NO];
            
            return;
        }
        
        [recordingView addSubview:circleDraw];
        
        [circleDraw setUserInteractionEnabled:YES];
        [circleSubView setUserInteractionEnabled:YES];
        
        self.tapMessage.text = @"Tap on the speaker to listen to recording";
        circleSubView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:IMG_LOADER_GREEN_SPEAKER]];
        micButtonView.hidden = YES;
        timerLabel.hidden = YES;
        circleDraw.sendButton.hidden = NO;
        self.isRecordingCompleted = YES;
    }
}

-(void)sendRecording
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
       
    micButtonView.hidden   = YES;
    micButtonView.alpha = 1;
    [timerLabel removeFromSuperview];
    recordingView.hidden    =   YES;
    [recorderTimer invalidate];
    recorderTimer = nil;
    if(([circleDraw duration] != 0) || (audiofilePath != nil && [audiofilePath length] > 0))
    {
        //EnLogd(@"condition circle draw is not zero");
        self.recordingFileLocalPath     =   nil;
        if(audiofilePath != nil && [audiofilePath length]>0)
        {
            self.recordingFileLocalPath = audiofilePath;
        }
        else
        {
            self.recordingFileLocalPath = [audioObj stopAndGetRecordedFilePath];
        }
        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.recordingFileLocalPath] options:nil];
        CMTime audioDuration = audioAsset.duration;
        float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
        NSNumber *recording         = [[NSNumber alloc] initWithInt:roundf(audioDurationSeconds)];
        
        [imageTime invalidate];
        imageTime = nil;
        [recorderTimer invalidate];
        recorderTimer = nil;
        if([recording intValue] == 0)
        {
            EnLogd(@"Record duration is zero and the recorded file : %@",self.recordingFileLocalPath);
            KLog(@"Recording time is too low, Please record again");
            
            alertView = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Recorded message is less than one second. Please record again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            [audioObj stopAndGetRecordedFilePath];
            [self stopRecordingTimer];
            audiofilePath = nil;
            
            [self setRecordingTitles];
            [self setupStartRecording:nil];
            [self.view bringSubviewToFront:self.tapToRecordButton];
            [self.tapToRecordButton setHidden:NO];
            [self.beginCancelButton setHidden:NO];
            
            return;
        }
        
        //DC MEMLEAK MAY 25 2016
        /*
        NSString* fileName = [[self.recordingFileLocalPath lastPathComponent] stringByDeletingPathExtension];
        fileName = [fileName stringByAppendingString:@".wav"];
        */
        EnLogd(@"Audio file duration : %d",[recording intValue]);
    }
    else
    {
        [audioObj stopAndGetRecordedFilePath];
        [self stopRecordingTimer];
        if(!msgSendStatus)
            [ScreenUtility showAlertMessage:NSLocalizedString(@"INSIDE_CON_PRESS_AND_HOLD",nil)];
    }
    audiofilePath = nil;
    
    self.isOkTapped = YES;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}


#pragma mark --  Timer progressbar setup
-(void)startRecordTimer
{
    if(recorderTimer != Nil)
    {
        if(circleDraw.duration == 0){
            circleDraw.endAngle = DEGREES_TO_RADIANS(-90);
        }
        circleDraw.duration = circleDraw.duration + SIZE_1;
        circleDraw.endAngle = DEGREES_TO_RADIANS(circleProgressCount) + circleDraw.endAngle;
        [circleDraw setNeedsDisplay];
        if(circleDraw.duration > INT_9 && circleDraw.duration < INT_60)
        {
            durationString = [NSString stringWithFormat:@"00:%ld",(long)circleDraw.duration];
        }
        else if(circleDraw.duration >= INT_60 )
        {
            int min = circleDraw.duration / INT_60;
            int sec = circleDraw.duration % INT_60;
            if(sec <= INT_9)
                durationString = [NSString stringWithFormat:@"0%d:0%d",min,sec];
            else
                durationString = [NSString stringWithFormat:@"0%d:%d",min,sec];
        }
        else
        {
            durationString = [NSString stringWithFormat:@"00:0%ld",(long)circleDraw.duration];
        }
        
        [timerLabel setText:durationString];
        if(circleDraw.duration == maxVoiceMsgDuration)
        {
            [recorderTimer invalidate];
            recorderTimer = nil;
            [imageTime  invalidate];
            imageTime = nil;
            circleDraw.duration = maxVoiceMsgDuration;
            [audioObj pauseRecording];
            
            NSMutableString *recordingText = [self.recordingType.text mutableCopy];
            [recordingText replaceOccurrencesOfString:@"Recording" withString:@"Set" options:NSCaseInsensitiveSearch range:NSMakeRange(0, recordingText.length)];
            self.recordingType.text = recordingText;
            
            NSMutableString *recordingDuration = [self.recordingDuration.text mutableCopy];
            [recordingDuration replaceOccurrencesOfString:@"maximum allowed time is " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, recordingDuration.length)];
            //[recordingDuration appendString:@" long"];
            self.recordingDuration.text = recordingDuration;
            
            self.tapMessage.text = @"Tap on the speaker to listen to recording";
            circleSubView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:IMG_LOADER_GREEN_SPEAKER]];
            micButtonView.hidden = YES;
            timerLabel.hidden = YES;
            circleDraw.sendButton.hidden = NO;
            self.isRecordingCompleted = YES;
            //CMP
            self.startOrConfirm.tag = 55;
            self.recordingDuration.text = [NSString stringWithFormat:@"(current recording: %d seconds long)",maxVoiceMsgDuration];
            //
        }
    }
    else
    {
        return;
    }
}
-(void)stopRecordingTimer
{
    circleDraw.endAngle     =   SIZE_0;
    circleDraw.startAngle   =   SIZE_0;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [timerLabel removeFromSuperview];
    timerLabel = nil;
    [audioObj cancelRecording];
    recordingView.hidden    =   YES;
    [recorderTimer invalidate];
    recorderTimer           =   nil;
    [imageTime invalidate];
    imageTime = nil;
    micButtonView.hidden    = NO;
    micButtonView.alpha = 1;
}

-(void)dismissThisViewController
{
    if(nil != alertView) {
        [alertView dismissWithClickedButtonIndex:-1 animated:NO];
        alertView = nil;
    }
    
    [ScreenUtility closeAlert];
    [self cancelTapped:nil];
}

@end
