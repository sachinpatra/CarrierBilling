//
//  ConversationTableCellAudioReceived.m
//  InstaVoice
//
//  Created by Pandian on 19/12/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConversationTableCellAudioReceived.h"
#import "IVColors.h"

@interface ConversationTableCellAudioReceived()
@property (weak, nonatomic) IBOutlet UIView *voiceView;
@property (weak, nonatomic) IBOutlet UIImageView *playButton;
@property (weak, nonatomic) IBOutlet UISlider *audioSlider;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadIndicator;
@end

@implementation ConversationTableCellAudioReceived

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark ChatView Sender

-(void)configureCell
{
    msgReadFlag = [[self.dic valueForKey:MSG_READ_CNT]intValue];
    if(msgReadFlag > 1)
        msgReadFlag = 1;
    
    NSString* msgStatus = [self.dic valueForKey:MSG_STATE];
    msgType = [self.dic valueForKey:MSG_TYPE];
    
    int totalDuration = [[self.dic valueForKey:DURATION]intValue];
    int playedDuration = [[self.dic valueForKey:MSG_PLAY_DURATION] intValue];
    BOOL isPlaying = [[self.dic valueForKey:MSG_PLAYBACK_STATUS]intValue];
    
    self.audioSlider.continuous = YES;
    self.audioSlider.maximumValue = totalDuration;
    self.audioSlider.minimumValue = 0.0;
    [self.audioSlider addTarget:self action:@selector(changedThumbPosition) forControlEvents:UIControlEventValueChanged];
    
    //- Sets up taprecognizer for voiceView
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voiceViewbuttonClicked:)];
    [self.voiceView addGestureRecognizer:tap];
    
    self.voiceView.clipsToBounds = YES;
    self.voiceView.layer.borderWidth = 1;
    self.voiceView.layer.cornerRadius = 10;
    
    if(playedDuration == totalDuration) {
        playedDuration = 0;
    }
    
    //
    if([msgType isEqualToString:CELEBRITY_TYPE]) {
        self.voiceView.backgroundColor = [IVColors orangeFillColor];
        self.voiceView.layer.borderColor = [IVColors orangeOutlineColor].CGColor;
        self.audioSlider.minimumTrackTintColor = [IVColors orangeOutlineColor];
        self.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xf7d090);
        /*
        if(NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_9_0)
            [UISlider appearance].maximumTrackTintColor = UIColorFromRGB(0xf7d090);
        */
    
        if(MessageReadStatusUnread == msgReadFlag || MessageReadStatusSeen == msgReadFlag) {
            [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-orange"] forState:UIControlStateNormal];
            self.duration.textColor = [IVColors orangeOutlineColor];
            self.timeStamp.textColor = [IVColors orangeOutlineColor];
        }
        else {
            [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-gray"] forState:UIControlStateNormal];
            self.duration.textColor = UIColorFromRGB(DURATION_AUDIO_LISTENED);
            self.timeStamp.textColor = UIColorFromRGB(DURATION_AUDIO_LISTENED);
        }
    }
    else if([msgType isEqualToString:VSMS_TYPE]) {
        self.voiceView.backgroundColor = [IVColors redFillColor];
        self.voiceView.layer.borderColor = [IVColors redOutlineColor].CGColor;
        self.voiceView.tintColor = [IVColors redOutlineColor];
    }
    else {
        
        if(MessageReadStatusUnread == msgReadFlag || MessageReadStatusSeen == msgReadFlag) {
            self.voiceView.backgroundColor = [IVColors blueFillColor];
            self.voiceView.layer.borderColor = [IVColors blueOutlineColor].CGColor;
            self.duration.textColor = [IVColors blueOutlineColor];
            self.timeStamp.textColor = [IVColors blueOutlineColor];
            [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-blue"] forState:UIControlStateNormal];
        } else {
            self.voiceView.backgroundColor = [IVColors blueFillColor];
            self.voiceView.layer.borderColor = [IVColors blueOutlineColor].CGColor;
            self.duration.textColor = UIColorFromRGB(DURATION_AUDIO_LISTENED);
            self.timeStamp.textColor = UIColorFromRGB(DURATION_AUDIO_LISTENED);
            [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-gray"] forState:UIControlStateNormal];
        }
        
        self.audioSlider.minimumTrackTintColor = [IVColors blueOutlineColor];
        self.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xa9dffe);
    }
    
    //- Set the playbutton
    NSString* imgButton = @"";
    if(isPlaying && playedDuration) {
        imgButton = @"pause-";
    } else if (playedDuration) {
        self.audioSlider.value = playedDuration;
        imgButton = @"play-";
    }else {
        self.audioSlider.value = 0.0;
        imgButton = @"play-";
    }
    
    if(MessageReadStatusRead == msgReadFlag) {
        imgButton = [imgButton stringByAppendingString:@"gray"];
    } else {
        if([msgType isEqualToString:CELEBRITY_TYPE])
            imgButton = [imgButton stringByAppendingString:@"orange"];
        else
            imgButton = [imgButton stringByAppendingString:@"blue"];
    }
    
    self.playButton.image = [[UIImage imageNamed:imgButton] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //
    
    if(playedDuration) {
        NSString *formattedDuration = [ScreenUtility durationIntoString:playedDuration];
        self.duration.text = formattedDuration;
        if([msgType isEqualToString:CELEBRITY_TYPE])
            self.audioSlider.value = playedDuration;
        
    } else {
        self.duration.text = [ScreenUtility durationIntoString:totalDuration];
    }
    
    NSString* locationString = @"";
    NSString* timeString = @"";
    if([msgStatus isEqualToString:API_INPROGRESS] || [msgStatus isEqualToString:API_MSG_REQ_SENT])
    {
        KLog(@"Sending...");
    }
    else if([msgStatus isEqualToString:API_NETUNAVAILABLE])
    {
        KLog(@"*** Failed to send. Data connection error.");
    }
    else if([msgStatus isEqualToString:API_UNSENT])
    {
        KLog(@"*** Failed to send");
    }
    else if ([msgStatus isEqualToString:API_DOWNLOAD_INPROGRESS]){
        CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        self.downloadIndicator.transform = transform;
        [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
        [self.downloadIndicator startAnimating];
        [self.playButton setImage:nil];
    }
    else
    {
        NSNumber *date = [self.dic valueForKey:MSG_DATE];
        timeString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
        
        self.timeStamp.text = timeString;
        self.timeStamp.contentMode = UIViewContentModeScaleToFill;
        
        locationString = [self.dic valueForKey:LOCATION_NAME];
        if(locationString) {
            self.location.hidden = NO;
            self.location.text = locationString;
        } else {
            self.location.text = @"";
            self.location.hidden = YES;
        }
    }

    self.location.textAlignment = NSTextAlignmentLeft;
    self.location.backgroundColor = [UIColor clearColor];
    self.location.textColor = UIColorFromRGB(LOCATION_TEXT);
    self.location.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    
    self.timeStamp.backgroundColor = [UIColor clearColor];
    self.timeStamp.textAlignment = NSTextAlignmentRight;
    self.timeStamp.font = [UIFont systemFontOfSize:11.0];
    self.timeStamp.contentMode = UIViewContentModeScaleToFill;
    
    self.duration.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    self.duration.backgroundColor = [UIColor clearColor];
    self.duration.textAlignment = NSTextAlignmentRight;
    
    self.fromName.textAlignment = NSTextAlignmentLeft;
    self.fromName.backgroundColor = [UIColor clearColor];
    self.fromName.textColor = UIColorFromRGB(FROM_USER_TEXT);
    self.fromName.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    
    if([[self.dic valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE]) {
        self.fromName.hidden = NO;
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithDictionary:self.dic];
        self.fromName.text = [self getGroupMemberNameFromDic:dic];
    } else {
        self.fromName.hidden = YES;
    }
    
    //share images
    /*DEBUG
     [self.icon6 setImage:[[UIImage imageNamed:@"fwd_msg_white"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
     [self.icon5 setImage:[UIImage imageNamed:@"share-icon-vb"]];
     [self.icon4 setImage:[UIImage imageNamed:@"share-icon-tw"]];
     [self.icon3 setImage:[UIImage imageNamed:@"share-icon-fb"]];
     [self.icon2 setImage:[UIImage imageNamed:@"share-icon-iv"]];
     [self.icon1 setImage:[UIImage imageNamed:@"share-icon-like"]];
     */
    
#ifndef REACHME_APP
    NSString *linkedOPR = [self.dic valueForKey:LINKED_OPR];
    
    BOOL likeBool = [[self.dic valueForKey:MSG_LIKED] boolValue];
    BOOL ivBool = [[self.dic valueForKey:MSG_FORWARD] boolValue];
    BOOL fbBool = [[self.dic valueForKey:MSG_FB_POST] boolValue];
    BOOL twBool = [[self.dic valueForKey:MSG_TW_POST] boolValue];
    BOOL vbBool = [[self.dic valueForKey:MSG_VB_POST] boolValue];
    BOOL fwdBool = [linkedOPR isEqualToString:IS_FORWORD_MSG];
    
    /* DEBUG
     BOOL likeBool = YES;
     BOOL ivBool = YES;
     BOOL fbBool = NO;
     BOOL twBool = NO;
     BOOL vbBool = YES;
     BOOL fwdBool = NO;
     */
    
    self.icon1.hidden = YES;
    
    likeBool = 0;
    ivBool = 0;
    fbBool = 0;
    twBool = 0;
    fwdBool = 0;
    
    shareCount = 0;
    if(likeBool) {
        shareCount++;
        [self setShareImg:@"share-icon-like"];
    }
    if (ivBool) {
        shareCount++;
        [self setShareImg:@"share-icon-iv"];
    }
    if(fbBool) {
        shareCount++;
        [self setShareImg:@"share-icon-fb"];
    }
    if(twBool) {
        shareCount++;
        [self setShareImg:@"share-icon-tw"];
    }
    if(vbBool) {
        shareCount++;
        [self setShareImg:@"share-icon-vb"];
    }
    if(fwdBool) {
        shareCount++;
        [self setShareImg:@"fwd_msg_white"];
    }
    
    //KLog(@"AudioReceived: voiceView = %@",self.voiceView);
#endif
    
}

-(void)setShareImg:(NSString*)name
{
    UIImageView* imageView = nil;
    switch(shareCount) {
        case 1:
            imageView = self.icon1;
            break;
    }
    
    if(nil != imageView) {
        if([name length]) {
            UIImage* img = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [imageView setImage:img];
            imageView.hidden = NO;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
}

/*
- (void)setFrame:(CGRect)frame {
    
    if (self.superview) {
        float cellWidth = 320.0;//[[UIScreen mainScreen] bounds].size.width;
        frame.origin.x = (self.superview.frame.size.width - cellWidth);
        frame.size.width = cellWidth;
    }
    
    [super setFrame:frame];
}*/

- (IBAction)swapPlayPause:(id)sender
{
    KLog(@"swapPlayPause");
    
    BOOL isPlaying = [[self.dic valueForKey:MSG_PLAYBACK_STATUS]intValue];
    NSString* imgThumb = @"";
    if (isPlaying) {
        if(MessageReadStatusRead == msgReadFlag) {
            imgThumb = @"pause-gray";
        }
        else {
            if([msgType isEqualToString:CELEBRITY_TYPE])
                imgThumb = @"pause-orange";
            else
                imgThumb = @"pause-blue";
        }
    }
    else {
        if(MessageReadStatusRead == msgReadFlag) {
            if([[self.dic valueForKey:MSG_STATE] isEqualToString:API_DOWNLOAD_INPROGRESS]) {
                KLog(@"API_DOWNLOAD_INPROGRESS");
                CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
                self.downloadIndicator.transform = transform;
                [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
                [self.downloadIndicator startAnimating];
                [self.playButton setImage:nil];
                return;
            }
            imgThumb = @"play-gray";
        }
        else {
            if([msgType isEqualToString:CELEBRITY_TYPE]){
                if([[self.dic valueForKey:MSG_STATE] isEqualToString:API_DOWNLOAD_INPROGRESS]) {
                    KLog(@"API_DOWNLOAD_INPROGRESS");
                    CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
                    self.downloadIndicator.transform = transform;
                    [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
                    [self.downloadIndicator startAnimating];
                    [self.playButton setImage:nil];
                    return;
                }
                imgThumb = @"play-orange";
            }
            else{
                if([[self.dic valueForKey:MSG_STATE] isEqualToString:API_DOWNLOAD_INPROGRESS]) {
                    KLog(@"API_DOWNLOAD_INPROGRESS");
                    CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
                    self.downloadIndicator.transform = transform;
                    [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
                    [self.downloadIndicator startAnimating];
                    [self.playButton setImage:nil];
                    return;
                }
                imgThumb = @"play-blue";
            }
            
        }
    }
    
    self.playButton.image = [[UIImage imageNamed:imgThumb] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

-(void)updateVoiceView:(NSDictionary *)voiceDic
{
    msgReadFlag = [[voiceDic valueForKey:MSG_READ_CNT] intValue];
    if(msgReadFlag > 1)
        msgReadFlag = 1;
    
    double playedDuration = [[voiceDic valueForKey:MSG_PLAY_DURATION] doubleValue];
    NSString *imgThumb = @"";
    NSString *sliderImgThumb = @"";
    if(MessageReadStatusRead == msgReadFlag) {
        imgThumb = @"pause-gray";
        sliderImgThumb = @"slide-img-small-gray";
        self.duration.textColor = UIColorFromRGB(DURATION_AUDIO_LISTENED);
        self.timeStamp.textColor = UIColorFromRGB(DURATION_AUDIO_LISTENED);
    }
    else {
        if([msgType isEqualToString:CELEBRITY_TYPE]){
            sliderImgThumb = @"slide-img-small-orange";
            imgThumb = @"pause-orange";
        }
        else{
            sliderImgThumb = @"slide-img-small-blue";
            imgThumb = @"pause-blue";
        }
        
    }
    [self.audioSlider setThumbImage:[UIImage imageNamed:sliderImgThumb] forState:UIControlStateNormal];
    self.playButton.image = [[UIImage imageNamed:imgThumb] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSString *formattedDuration = [ScreenUtility durationIntoString:playedDuration];
    [self.duration setText:formattedDuration];
    self.audioSlider.value = playedDuration;
}

-(IBAction)stopPlaying:(id)sender
{
    KLog(@"stopPlaying");
    [self.dic setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAYBACK_STATUS];
    
    NSString* imgThumb = @"";
    if(MessageReadStatusRead == msgReadFlag) {
        if([[self.dic valueForKey:MSG_STATE] isEqualToString:API_DOWNLOAD_INPROGRESS]) {
            KLog(@"API_DOWNLOAD_INPROGRESS");
            CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
            self.downloadIndicator.transform = transform;
            [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
            [self.downloadIndicator startAnimating];
            [self.playButton setImage:nil];
            return;
        }
        imgThumb = @"play-gray";
    }
    else {
        if([msgType isEqualToString:CELEBRITY_TYPE]){
            if([[self.dic valueForKey:MSG_STATE] isEqualToString:API_DOWNLOAD_INPROGRESS]) {
                KLog(@"API_DOWNLOAD_INPROGRESS");
                CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
                self.downloadIndicator.transform = transform;
                [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
                [self.downloadIndicator startAnimating];
                [self.playButton setImage:nil];
                return;
            }
            imgThumb = @"play-orange";
        }
        else{
            if([[self.dic valueForKey:MSG_STATE] isEqualToString:API_DOWNLOAD_INPROGRESS]) {
                KLog(@"API_DOWNLOAD_INPROGRESS");
                CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
                self.downloadIndicator.transform = transform;
                [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
                [self.downloadIndicator startAnimating];
                [self.playButton setImage:nil];
                return;
            }
            imgThumb = @"play-blue";
        }
        
    }
    self.playButton.image = [[UIImage imageNamed:imgThumb] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

-(void)setStatusIcon:(NSString *)status isAvs:(int)avsMsg readCount:(int)readCount msgType:(NSString *)msgType
{
    NSString* imgThumb = @"";
    if([status isEqualToString:API_DOWNLOAD_INPROGRESS]) {
        KLog(@"API_DOWNLOAD_INPROGRESS");
        CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        self.downloadIndicator.transform = transform;
        [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
        [self.downloadIndicator startAnimating];
        [self.playButton setImage:nil];
        return;
    }
    else if([status isEqualToString:API_DELIVERED] || [status isEqualToString:API_DOWNLOADED]) {
        KLog(@"API_DOWNLOADED");
    }
    else if([status isEqualToString:API_MSG_PALYING]) {
        if(MessageReadStatusRead == msgReadFlag)
            imgThumb = @"pause-gray";
        else
            imgThumb = @"pause-blue";
        
    } else {
        if(MessageReadStatusRead == msgReadFlag)
            imgThumb = @"play-gray";
        else
            imgThumb = @"play-blue";
    }
    
    [self.downloadIndicator stopAnimating];
    KLog(@"setStatuIcon: imgThumb = %@",imgThumb);
    self.playButton.image = [[UIImage imageNamed:imgThumb] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.playButton setNeedsDisplay];
}

- (IBAction)voiceViewbuttonClicked:(UIButton *)sender
{
    KLog(@"voiceViewbuttonClicked");
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioButtonClickedAtIndex:)]) {
        [self.delegate audioButtonClickedAtIndex:self.cellIndex];
    }
}

#pragma UISlider

-(void)changedThumbPosition {
    
    KLog(@"changePosition:%f",self.audioSlider.value);
    NSString* imgThumb = @"";
    if(self.audioSlider.continuous) {
        self.audioSlider.continuous = NO;
       
        if(MessageReadStatusUnread == msgReadFlag || MessageReadStatusSeen == msgReadFlag) {
            if([msgType isEqualToString:CELEBRITY_TYPE])
                imgThumb = @"slide-img-big-orange";
            else
                imgThumb = @"slide-img-big-blue";
        }
        else
            imgThumb = @"slide-img-big-gray";
        
    } else {
        if(MessageReadStatusUnread == msgReadFlag || MessageReadStatusSeen == msgReadFlag) {
            if([msgType isEqualToString:CELEBRITY_TYPE])
                imgThumb = @"slide-img-small-orange";
            else
                imgThumb = @"slide-img-small-blue";
        }
        else
            imgThumb = @"slide-img-small-gray";
        
        self.audioSlider.continuous = YES;
    }
    
    [self.audioSlider setThumbImage:[UIImage imageNamed:imgThumb] forState:UIControlStateNormal];
}

- (IBAction)touchCancel:(id)sender {
    
    KLog(@"touchCancel");
    NSString* imgThumb = @"";
    if(MessageReadStatusUnread == msgReadFlag || MessageReadStatusSeen == msgReadFlag) {
        if([msgType isEqualToString:CELEBRITY_TYPE])
            imgThumb = @"slide-img-small-orange";
        else
            imgThumb = @"slide-img-small-blue";
    }
    else
        imgThumb = @"slide-img-small-gray";
    
    [self.audioSlider setThumbImage:[UIImage imageNamed:imgThumb] forState:UIControlStateNormal];
    
}

-(void)touchUpInsideOrOutside {
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(changedThumbPosition)
                                   userInfo:nil
                                    repeats:NO];
    
    double playDuration = self.audioSlider.value;
    [self.dic setValue:[NSNumber numberWithDouble:playDuration] forKey:MSG_PLAY_DURATION];
    NSString *formattedDuration = [ScreenUtility durationIntoString:playDuration];
    [self.duration setText:formattedDuration];
    self.scrubbing = FALSE;
    
    if(playing)
    {
        KLog(@"playing..");
        [self.delegate setCurrentTime:playDuration];
        [self voiceViewbuttonClicked:nil];
    }
}

- (IBAction)touchUpOutside:(id)sender {
    KLog(@"touchUpInsideOrOutside");
    [self touchUpInsideOrOutside];
}

- (IBAction)touchUpInside:(id)sender {
    KLog(@"touchUpInside");
    [self touchUpInsideOrOutside];
}

-(void)dragInsideOrOutside {
    self.scrubbing = TRUE;
    self.audioSlider.continuous = YES;
    
    double playDuration = self.audioSlider.value;
    BOOL isPlaying = [[self.dic valueForKey:MSG_PLAYBACK_STATUS]intValue];
    if(isPlaying) {
        KLog(@"playing..");
        playing = YES;
        [self voiceViewbuttonClicked:nil];
    }
    
    [self.dic setValue:[NSNumber numberWithDouble:playDuration] forKey:MSG_PLAY_DURATION];
    NSString *formattedDuration = [ScreenUtility durationIntoString:playDuration];
    [self.duration setText:formattedDuration];
}

- (IBAction)dragOutside:(id)sender {
    KLog(@"dragOutside");
    [self dragInsideOrOutside];
}

- (IBAction)dragInside:(id)sender {
    KLog(@"audioReceived:dragInside");
    [self dragInsideOrOutside];
}

@end
