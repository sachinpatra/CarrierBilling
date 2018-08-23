//
//  IVChatTableViewCellVBReceived.h
//  InstaVoice
//
//  Created by Pandian on 30/09/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVChatTableViewCell.h"
#include "KAudioSlider.h"

@interface IVChatTableViewCellVBReceived : IVChatTableViewCell
{
    BOOL playing;
    NSString* msgType;
    int msgReadFlag;
}

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadMsgCount;
@property (weak, nonatomic) IBOutlet UIImageView *msgIndicator;
@property (weak, nonatomic) IBOutlet UIView *voiceView;
@property (weak, nonatomic) IBOutlet UIImageView *playButton;
@property (weak, nonatomic) IBOutlet UISlider *audioSlider;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceViewWidth;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadIndicator;

@property BOOL scrubbing;

-(void)configureCellForChatTile:(NSMutableDictionary *)dic forRow:(int)rowValue;
-(void)setupFields;
-(void)updateVoiceView:(NSDictionary *)voiceDic;
-(void)stopPlaying:(id)sender;
-(void)swapPlayPause:(id)sender;
- (IBAction)dragInside:(id)sender;
- (IBAction)touchUpInside:(id)sender;
- (IBAction)touchCancel:(id)sender;
- (IBAction)dragOutside:(id)sender;
- (IBAction)touchUpOutside:(id)sender;

@end
