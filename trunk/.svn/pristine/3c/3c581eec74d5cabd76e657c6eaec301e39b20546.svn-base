//
//  IVChatTableViewCellVMsgSent.h
//  InstaVoice
//
//  Created by Pandian on 30/09/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVChatTableViewCell.h"
#import "Logger.h"

@interface IVChatTableViewCellVMsgSent : IVChatTableViewCell
{
    int msgReadFlag;
    BOOL playing;
    NSString* msgType;
}

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadMsgCount;
@property (weak, nonatomic) IBOutlet UIImageView *msgIndicator;
@property (weak, nonatomic) IBOutlet UISlider *audioSlider;
@property (weak, nonatomic) IBOutlet UIImageView *playButton;
@property (weak, nonatomic) IBOutlet UIView *voiceView;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceViewWidth;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadIndicator;

@property (weak, nonatomic) IBOutlet UIView *transcriptView;
@property (weak, nonatomic) IBOutlet UIImageView *transcribeImg;

@property BOOL scrubbing;
- (IBAction)touchUpInside:(id)sender;
- (IBAction)dragInside:(id)sender;

-(void)configureCellForChatTile:(NSMutableDictionary *)dic forRow:(int)rowValue;
-(void)setupFields;
-(void)updateVoiceView:(NSDictionary *)voiceDic;
-(void)stopPlaying:(id)sender;
-(void)swapPlayPause:(id)sender;
- (IBAction)touchCancel:(id)sender;
- (IBAction)dragOutside:(id)sender;
- (IBAction)touchUpOutside:(id)sender;

@end
