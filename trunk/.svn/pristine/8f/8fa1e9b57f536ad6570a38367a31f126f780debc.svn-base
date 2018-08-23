//
//  SettingsMissedCallRecordAudioViewController.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 10/14/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
#import "CircleProgressView.h"
#import "Audio.h"

@interface SettingsMissedCallRecordAudioViewController:BaseUI
{
    CircleProgressView      *circleDraw;                //View responsbile for animation
    IBOutlet UIView         *recordingView;             //recording view
    NSTimer                 *drawStripTimer;        //This is used to draw overlapping strip
    UILabel                 *timerLabel;                //Recording Timer Lable
    IBOutlet UILabel        *headingLabel;              //heading label for Recording View
    int maxVoiceMsgDuration;        //Maximum Recording Limit
    IBOutlet UIView         *circleSubView;             //recording circle view
    IBOutlet UIView         *micButtonView;             //recording footer view
    float                    circleProgressCount;        //Manages Animation Progress
    NSTimer                 *recorderTimer;                     //Timer For recording
    IBOutlet UIView         *recordingArea;             //Animation Area Of recording
    NSString                *durationString;            //Recording Timer string
    NSTimer                 *imageTime;
    NSString                *audiofilePath;
    BOOL                     msgSendStatus;
    NSInteger               nameDurationTime;
    UIAlertView*            alertView;
}
@property(nonatomic)    Audio             *audioObj;
@property(nonatomic,assign)NSInteger buttonTag;
@property (weak, nonatomic) IBOutlet UILabel *recordingType;
@property (weak, nonatomic) IBOutlet UILabel *recordingDuration;
@property (weak, nonatomic) IBOutlet UIButton *startOrConfirm;
@property (weak, nonatomic) IBOutlet UIButton *beginCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *tapToRecordButton;
@property (weak, nonatomic) IBOutlet UILabel *tapMessage;
@property (assign, nonatomic)BOOL isOkTapped;
@property (assign, nonatomic)BOOL isRecordingCompleted;
@property (strong, nonatomic)NSString* recordingFileName;
@property (strong, nonatomic)NSString* nameOrWelcome;
@property (strong, nonatomic)NSString *recordingFileNameForGreetingsName;
@property (strong, nonatomic)NSString *recordingFileNameForGreetingsMessage;
@property (strong, nonatomic)NSString *recordingFileLocalPath;

-(IBAction)startRecordingTapped:(id)sender;
-(IBAction)cancelTapped:(id)sender;

-(void)dismissThisViewController;
@end
