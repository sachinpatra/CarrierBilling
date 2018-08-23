//
//  AudioMessageInterfaceController.h
//  InstaVoice
//
//  Created by adwivedi on 13/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "Audio.h"
@interface AudioMessageInterfaceController : WKInterfaceController<AudioDelegate>
{
    double _duration;
    NSString* _contactNumber;
}
@property (weak, nonatomic) IBOutlet WKInterfaceImage *brandImage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *audioLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *remoteUserImage;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *playButton;
@property (weak, nonatomic) IBOutlet WKInterfaceTimer *audioTimer;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *remoteUserName;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *callButton;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *groupForImage;

- (IBAction)playAction;
- (IBAction)callAction;
- (IBAction)forceTouceButtonAction;
@property (strong,nonatomic)NSString* audioFilePath;
//Deepak_Carpenter : Declared here as delegates methods were not working earlier
@property(nonatomic,strong) Audio* audioObj;

@end
