//
//  ConversationTableCellAudioSent.m
//  InstaVoice
//
//  Created by Pandian on 12/12/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConversationTableCellAudioSent.h"
#import "IVColors.h"

@interface ConversationTableCellAudioSent()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tickMarkConstraints;
@property (weak, nonatomic) IBOutlet UIView *voiceView;
@property (weak, nonatomic) IBOutlet UIImageView *playButton;
@property (weak, nonatomic) IBOutlet UISlider *audioSlider;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UIImageView *tickImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadIndicator;
@end

@implementation ConversationTableCellAudioSent

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
    msgStatus = [self.dic valueForKey:MSG_STATE];
    msgType = [self.dic valueForKey:MSG_TYPE];
    
    int totalDuration = [[self.dic valueForKey:DURATION]intValue];
    int playedDuration = [[self.dic valueForKey:MSG_PLAY_DURATION] intValue];
    BOOL isPlaying = [[self.dic valueForKey:MSG_PLAYBACK_STATUS]intValue];

    self.audioSlider.continuous = YES;
    self.audioSlider.maximumValue = totalDuration;
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
    
    self.duration.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    self.duration.backgroundColor = [UIColor clearColor];
    //
    self.duration.textAlignment = NSTextAlignmentRight;
    
    if([msgType isEqualToString:VSMS_TYPE]) {
        self.voiceView.backgroundColor = [IVColors grayFillColor];
        self.voiceView.layer.borderColor = [IVColors grayOutlineColor].CGColor;
        self.voiceView.tintColor = [IVColors grayOutlineColor];
        self.audioSlider.minimumTrackTintColor = [IVColors grayOutlineColor];
        self.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xcfcfcf);
        [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-gray"] forState:UIControlStateNormal];
        self.duration.textColor = UIColorFromRGB(DURATION_AUDIO_NONIV);
    }else if ([msgType isEqualToString:VB_TYPE]){
        self.voiceView.backgroundColor = [IVColors orangeFillColor];
        self.voiceView.layer.borderColor = [IVColors orangeOutlineColor].CGColor;
        self.voiceView.tintColor = [IVColors orangeFillColor];
        self.audioSlider.minimumTrackTintColor = [IVColors orangeOutlineColor];
        self.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xf7d090);
        [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-orange"] forState:UIControlStateNormal];
        self.duration.textColor = [IVColors orangeOutlineColor];
    }
    else {
        if (MessageReadStatusRead == msgReadFlag){
            self.voiceView.backgroundColor = [IVColors greenFillColor];
            self.voiceView.layer.borderColor = [IVColors greenOutlineColor].CGColor;
            self.voiceView.tintColor = [IVColors greenOutlineColor];
            self.audioSlider.minimumTrackTintColor = [IVColors grayOutlineColor];
            self.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xcfcfcf);
            [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-gray"] forState:UIControlStateNormal];
            self.duration.textColor = UIColorFromRGB(DURATION_AUDIO_NONIV);
        }else{
            self.voiceView.backgroundColor = [IVColors greenFillColor];
            self.voiceView.layer.borderColor = [IVColors greenOutlineColor].CGColor;
            self.voiceView.tintColor = [IVColors greenOutlineColor];
            self.audioSlider.minimumTrackTintColor = [IVColors greenOutlineColor];
            self.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xb8fd9f);
            [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-green"] forState:UIControlStateNormal];
            self.duration.textColor = UIColorFromRGB(DURATION_AUDIO_SENT);
        }
    }
    
    //- Set the playbutton
    NSString* imgThumb = @"";
    if(isPlaying && playedDuration) {
        if([msgType isEqualToString:VSMS_TYPE]){
            imgThumb = @"pause-gray";
        }else if ([msgType isEqualToString:VB_TYPE]){
            imgThumb = @"pause-orange";
        }else{
            if (MessageReadStatusRead == msgReadFlag)
                imgThumb = @"pause-gray";
            else
                imgThumb = @"pause-green";
        }
        
    } else if (playedDuration) {
        self.audioSlider.value = playedDuration;
        if([msgType isEqualToString:VSMS_TYPE]){
            imgThumb = @"play-gray";
        }else if ([msgType isEqualToString:VB_TYPE]){
            imgThumb = @"play-orange";
        }else{
            if (MessageReadStatusRead == msgReadFlag)
                imgThumb = @"play-gray";
            else
                imgThumb = @"play-green";
        }
    }
    else {
        self.audioSlider.value = 0.0;
        if([msgType isEqualToString:VSMS_TYPE]){
            imgThumb = @"play-gray";
        }else if ([msgType isEqualToString:VB_TYPE]){
            imgThumb = @"play-orange";
        }else{
            if (MessageReadStatusRead == msgReadFlag)
                imgThumb = @"play-gray";
            else
                imgThumb = @"play-green";
        }
    }
    
    self.playButton.image = [[UIImage imageNamed:imgThumb] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //
    
    if(playedDuration) {
        NSString *formattedDuration = [ScreenUtility durationIntoString:playedDuration];
        self.duration.text = formattedDuration;
    } else {
        self.duration.text = [ScreenUtility durationIntoString:totalDuration];
    }
    
    self.location.textAlignment = NSTextAlignmentRight;
    self.location.backgroundColor = [UIColor clearColor];
    self.location.textColor = UIColorFromRGB(LOCATION_TEXT);
    self.location.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    
    //self.timeStamp.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    self.timeStamp.backgroundColor = [UIColor clearColor];
    self.timeStamp.textAlignment = NSTextAlignmentRight;
    self.timeStamp.font = [UIFont systemFontOfSize:11.0];
    
    if([msgType isEqualToString:VSMS_TYPE]){
        self.timeStamp.textColor = UIColorFromRGB(DURATION_AUDIO_NONIV);
    }else if ([msgType isEqualToString:VB_TYPE]){
        self.timeStamp.textColor = [IVColors orangeOutlineColor];
    }else{
        self.timeStamp.textColor = MessageReadStatusRead == msgReadFlag?UIColorFromRGB(DURATION_AUDIO_NONIV):UIColorFromRGB(DURATION_AUDIO_SENT);
    }
    
    NSString* locationString = @"";
    NSString* timeString = @"";
   
    /*
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
    else*/
    if ([msgStatus isEqualToString:API_DOWNLOAD_INPROGRESS]){
        CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        self.downloadIndicator.transform = transform;
        [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
        [self.downloadIndicator startAnimating];
        [self.playButton setImage:nil];
    }
    {
        NSNumber *date = [self.dic valueForKey:MSG_DATE];
        timeString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
    
        self.timeStamp.text = timeString;
        self.timeStamp.contentMode = UIViewContentModeScaleToFill;
        
        locationString = [self.dic valueForKey:LOCATION_NAME];
        if(locationString) {
            self.location.text = locationString;
        } else {
            self.location.text = @"";
        }
    }
    
    //- set up tick image or hour glass
    NSString* tickImageName = @"";
    if (MessageReadStatusRead == msgReadFlag) {
        if ([[self.dic valueForKey:CONVERSATION_TYPE] isEqualToString:GROUP_TYPE])
            tickImageName = @"single_tick";
        else
            tickImageName = @"double_tick";
    }
    else if([msgStatus isEqualToString:API_DELIVERED] ||
            [msgStatus isEqualToString:API_DOWNLOADED] || [msgStatus isEqualToString:API_DOWNLOAD_INPROGRESS] ) {
        tickImageName = @"single_tick";
    }
    else if([msgStatus isEqualToString:API_NETUNAVAILABLE] || [msgStatus isEqualToString:API_UNSENT]) {
        tickImageName = @"failed-msg";
    }
    else {
        tickImageName = @"hour-glass";
    }
    
    self.tickImage.image = [[UIImage imageNamed:tickImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tickImage.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    BOOL is24Hour = ([format rangeOfString:@"a"].location == NSNotFound);
    
    if (is24Hour) {
        self.tickMarkConstraints.constant = -20;
    }else{
        self.tickMarkConstraints.constant = 0;
    }
    
    //Bhaskar Attachment of Tick icon/Hour Glass icon to timestamp as per the mocks March 20 2017
    //And Hidden tickimage view in Xib file
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    if(![msgStatus isEqualToString:API_WITHDRAWN]) {
        attachment.image = [UIImage imageNamed:tickImageName];
    }
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *timeAttrString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",timeString]];
    [timeAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11]range:NSMakeRange(0, timeString.length)];
    [timeAttrString insertAttributedString:attachmentString atIndex:0];
    self.timeStamp.attributedText = timeAttrString;
    
    //self.timeStamp.layer.borderWidth = 1;//DEBUG
    /*
    NSMutableString* dateString = [[NSMutableString alloc]initWithString:@" "];
    [dateString appendString:self.timeStamp.text];
    
    //combine image and label
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    if(![msgState isEqualToString:API_WITHDRAWN]) {
        attachment.image = [UIImage imageNamed:tickImageName];
    }
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:dateString];
    [myString insertAttributedString:attachmentString atIndex:0];
    self.timeStamp.attributedText = myString;
     */
    //
    
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
    
    shareCount = 0;
    likeBool = 0;
    ivBool = 0;
    fbBool = 0;
    twBool = 0;
    fbBool = 0;
    fwdBool = 0;
    if(likeBool) {
         shareCount++;
        [self setShareImg:[UIImage imageNamed:@"share-icon-like"]];
    }
    if (ivBool) {
        shareCount++;
        [self setShareImg:[UIImage imageNamed:@"share-icon-iv"]];
    }
    if(fbBool) {
        shareCount++;
        [self setShareImg:[UIImage imageNamed:@"share-icon-fb"]];
    }
    if(twBool) {
        shareCount++;
        [self setShareImg:[UIImage imageNamed:@"share-icon-tw"]];
    }
    if(vbBool && ![msgType isEqualToString:VB_TYPE]) {
        shareCount++;
        [self setShareImg:[UIImage imageNamed:@"share-icon-vb"]];
    }
    if(fwdBool) {
        shareCount++;
        [self setShareImg:[UIImage imageNamed:@"fwd_msg_white"]];
    }
#endif
    
}

-(void)setShareImg:(UIImage *)name
{
    switch(shareCount) {
        case 1:
            [self.icon1 setImage:name];
            self.icon1.hidden = NO;
            break;
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
}
*/

- (IBAction)swapPlayPause:(id)sender
{
    KLog(@"swapPlayPause");
    
    BOOL isPlaying = [[self.dic valueForKey:MSG_PLAYBACK_STATUS]intValue];
    NSString* imgThumb = @"";
    if (isPlaying) {
        if([msgType isEqualToString:VSMS_TYPE]){
            imgThumb = @"pause-gray";
        }else if ([msgType isEqualToString:VB_TYPE]){
            imgThumb = @"pause-orange";
        }else{
            if (MessageReadStatusRead == msgReadFlag)
                imgThumb = @"pause-gray";
            else
                imgThumb = @"pause-green";
        }
    }
    else {
        if([msgType isEqualToString:VSMS_TYPE]){
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
        }else if ([msgType isEqualToString:VB_TYPE]){
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
        }else{
            if (MessageReadStatusRead == msgReadFlag){
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
                imgThumb = @"play-green";
            }
                
        }
    }
    self.playButton.image = [[UIImage imageNamed:imgThumb] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

-(void)updateVoiceView:(NSDictionary *)voiceDic
{
    //int totalDuration = [[voiceDic valueForKey:DURATION] intValue];
    double playedDuration = [[voiceDic valueForKey:MSG_PLAY_DURATION] doubleValue];
    //KLog(@"updateVoiceView: tot = %d, cur = %f",totalDuration,playedDuration);

    NSString *imgThumb = @"";
    if([msgType isEqualToString:VSMS_TYPE]){
        imgThumb = @"pause-gray";
    }else if ([msgType isEqualToString:VB_TYPE]){
        imgThumb = @"pause-orange";
    }else{
        if (MessageReadStatusRead == msgReadFlag)
            imgThumb = @"pause-gray";
        else
            imgThumb = @"pause-green";
    }
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
    if([msgType isEqualToString:VSMS_TYPE]){
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
    }else if ([msgType isEqualToString:VB_TYPE]){
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
    }else{
        if (MessageReadStatusRead == msgReadFlag)
            imgThumb = @"play-gray";
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
        imgThumb = @"play-green";
        }
    }
    self.playButton.image = [[UIImage imageNamed:imgThumb] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

-(void)setStatusIcon:(NSString *)status isAvs:(int)avsMsg readCount:(int)readCount msgType:(NSString *)mesgType
{
    NSString* imgThumb = @"";
    if([status isEqualToString:API_DOWNLOAD_INPROGRESS])
    {
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
        if([msgType isEqualToString:VSMS_TYPE]){
            imgThumb = @"pause-gray";
        }else if ([msgType isEqualToString:VB_TYPE]){
            imgThumb = @"pause-orange";
        }else{
            if (MessageReadStatusRead == msgReadFlag)
                imgThumb = @"pause-gray";
            else
                imgThumb = @"pause-green";
        }
        
    } else {
        if([msgType isEqualToString:VSMS_TYPE]){
            imgThumb = @"play-gray";
        }else if ([msgType isEqualToString:VB_TYPE]){
            imgThumb = @"play-orange";
        }else{
            if (MessageReadStatusRead == msgReadFlag)
                imgThumb = @"play-gray";
            else
                imgThumb = @"play-green";
        }
    }
    
    [self.downloadIndicator stopAnimating];
    KLog(@"setStatuIcon: imgThumb = %@",imgThumb);
    if(imgThumb.length) {
        self.playButton.image = [[UIImage imageNamed:imgThumb] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.playButton setNeedsDisplay];
    }
}

- (IBAction)voiceViewbuttonClicked:(UIButton *)sender
{
    KLog(@"voiceViewbuttonClicked");
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioButtonClickedAtIndex:)]) {
        [self.delegate audioButtonClickedAtIndex:self.cellIndex];
    }
}

#pragma UISlider

- (IBAction)touchCancel:(id)sender {
    
    NSString* imgThumb = @"";
    if([msgType isEqualToString:VSMS_TYPE]){
        imgThumb = @"slide-img-small-gray";
    }else if ([msgType isEqualToString:VB_TYPE]){
        imgThumb = @"slide-img-small-orange";
    }else{
        if (MessageReadStatusRead == msgReadFlag)
            imgThumb = @"slide-img-small-gray";
        else
            imgThumb = @"slide-img-small-green";
    }
    
    [self.audioSlider setThumbImage:[UIImage imageNamed:imgThumb] forState:UIControlStateNormal];
    
}

-(void)changedThumbPosition {
    
    NSString* imgThumb = @"";
    if(self.audioSlider.continuous) {
        self.audioSlider.continuous = NO;
        if([msgType isEqualToString:VSMS_TYPE]){
            imgThumb = @"slide-img-big-gray";
        }else if ([msgType isEqualToString:VB_TYPE]){
            imgThumb = @"slide-img-big-orange";
        }else{
            if (MessageReadStatusRead == msgReadFlag)
                imgThumb = @"slide-img-big-gray";
            else
                imgThumb = @"slide-img-big-green";
        }
        
    } else {
        if([msgType isEqualToString:VSMS_TYPE]){
            imgThumb = @"slide-img-small-gray";
        }else if ([msgType isEqualToString:VB_TYPE]){
            imgThumb = @"slide-img-small-orange";
        }else{
            if (MessageReadStatusRead == msgReadFlag)
                imgThumb = @"slide-img-small-gray";
            else
                imgThumb = @"slide-img-small-green";
        }
        
        self.audioSlider.continuous = YES;
    }
    KLog(@"changePosition: %@",imgThumb);
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
    KLog(@"touchUpOutside");
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
    KLog(@"dragInside");
    [self dragInsideOrOutside];
}

@end
