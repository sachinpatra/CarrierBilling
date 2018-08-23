//
//  ConversationTableCellVMailReceivedNoTrans.m
//  InstaVoice
//
//  Created by Pandian on 06/01/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConversationTableCellVMailReceivedNoTrans.h"
#import "IVColors.h"

@interface ConversationTableCellVMailReceivedNoTrans ()

@end

@implementation ConversationTableCellVMailReceivedNoTrans

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

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
    [self.audioSlider addTarget:self action:@selector(changedThumbPosition) forControlEvents:UIControlEventValueChanged];
    
    //- Sets up taprecognizer for voiceView
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voiceViewbuttonClicked:)];
    [self.voiceView addGestureRecognizer:tap];
    
    if(playedDuration == totalDuration) {
        playedDuration = 0;
    }
    
    //- setup voiceView
    self.voiceView.clipsToBounds = YES;
    self.voiceView.layer.borderWidth = 1;
    self.voiceView.layer.cornerRadius = 10;
    self.voiceView.backgroundColor = [IVColors redFillColor];
    self.voiceView.layer.borderColor = [IVColors redOutlineColor].CGColor;
    self.voiceView.tintColor = [IVColors redOutlineColor];
    self.audioSlider.minimumTrackTintColor = [IVColors redOutlineColor];
    self.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xf3c4c0);
    
    if(MessageReadStatusUnread == msgReadFlag || MessageReadStatusSeen == msgReadFlag) {
        self.duration.textColor = [IVColors redOutlineColor];
        self.timeStamp.textColor = [IVColors redOutlineColor];
        [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-red"] forState:UIControlStateNormal];
    } else {
        self.duration.textColor = UIColorFromRGB(DURATION_AUDIO_LISTENED);
        self.timeStamp.textColor = UIColorFromRGB(DURATION_AUDIO_LISTENED);
        [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-gray"] forState:UIControlStateNormal];
    }
    
    //- Set the playbutton
    NSString* imgButton = @"";
    if(isPlaying && playedDuration) {
        if(MessageReadStatusRead == msgReadFlag)
            imgButton = @"pause-gray";
        else
            imgButton = @"pause-red";
    } else if (playedDuration) {
        self.audioSlider.value = playedDuration;
        if(MessageReadStatusRead == msgReadFlag)
            imgButton = @"play-gray";
        else
            imgButton = @"play-red";
    }
    else {
        self.audioSlider.value = 0.0;
        if(MessageReadStatusRead == msgReadFlag)
            imgButton = @"play-gray";
        else
            imgButton = @"play-red";
    }
    self.playButton.image = [[UIImage imageNamed:imgButton] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //
    
    //- setup duration label
    self.duration.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    self.duration.backgroundColor = [UIColor clearColor];
    self.duration.textAlignment = NSTextAlignmentRight;
    
    if(playedDuration) {
        NSString *formattedDuration = [ScreenUtility durationIntoString:playedDuration];
        self.duration.text = formattedDuration;
    } else {
        self.duration.text = [ScreenUtility durationIntoString:totalDuration];
    }
    
    //Get To and From user name
    NSString* toNumber = [self.dic valueForKey:NATIVE_CONTACT_ID];
    NSString* theToPhoneNumber = [Common getFormattedNumber:toNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    NSString* fromNumber = [self.dic valueForKey:@"FROM_USER_ID"];
    NSString* theFromPhoneNumber = [Common getFormattedNumber:fromNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    
    if(!theToPhoneNumber) {
        if(toNumber.length)
            theToPhoneNumber = toNumber;
        else
            theToPhoneNumber = @"";
    }
    
    if(!theFromPhoneNumber) {
        if(fromNumber.length)
            theFromPhoneNumber = fromNumber;
        else
            theFromPhoneNumber = @"";
    }
    
    //- set the from user name/number
    self.fromUser.backgroundColor = [UIColor clearColor];
    self.fromUser.textColor = UIColorFromRGB(LOCATION_TEXT);
    if(theFromPhoneNumber.length) {
        NSString *fromUser = [NSString stringWithFormat:@"From: %@", theFromPhoneNumber];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fromUser];
        
        NSDictionary *theAttributes = @{NSForegroundColorAttributeName: UIColorFromRGB(FROM_USER_TEXT_COLOR),
                                        NSFontAttributeName: [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]};
        [attributedString setAttributes:theAttributes range:[fromUser rangeOfString:theFromPhoneNumber]];
        self.fromUser.attributedText = attributedString;
        self.fromUser.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    }
    
    //- set the to user name/number and location
    NSString *locationString = [self.dic valueForKey:LOCATION_NAME];
    if(!locationString)
        locationString = @"";
    
    self.toUserAndLocation.backgroundColor = [UIColor clearColor];
    self.toUserAndLocation.textColor = UIColorFromRGB(LOCATION_TEXT);
    if(theToPhoneNumber.length) {
        NSString *toUser = [NSString stringWithFormat:@"To: %@  %@", theToPhoneNumber,locationString];
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:toUser];
        
        NSDictionary* theAttributes = @{NSForegroundColorAttributeName: UIColorFromRGB(LOCATION_TEXT),
                                        NSFontAttributeName: [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]};
        [attributedString setAttributes:theAttributes range:[toUser rangeOfString:theToPhoneNumber]];
        self.toUserAndLocation.attributedText = attributedString;
        self.toUserAndLocation.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    }
    
    self.timeStamp.backgroundColor = [UIColor clearColor];
    self.timeStamp.textAlignment = NSTextAlignmentRight;
    self.timeStamp.font = [UIFont systemFontOfSize:11.0];
    self.timeStamp.contentMode = UIViewContentModeScaleToFill;
    
    NSString* timeString = @"";
    NSNumber *date = [self.dic valueForKey:MSG_DATE];
    timeString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
    self.timeStamp.text = timeString;
    
    if ([msgStatus isEqualToString:API_DOWNLOAD_INPROGRESS]){
        CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        self.downloadIndicator.transform = transform;
        [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
        [self.downloadIndicator startAnimating];
        [self.playButton setImage:nil];
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
    if(vbBool) {
        shareCount++;
        [self setShareImg:[UIImage imageNamed:@"share-icon-vb"]];
    }
    if(fwdBool) {
        shareCount++;
        [self setShareImg:[UIImage imageNamed:@"fwd_msg_white"]];
    }
    
    //self.toUserAndLocation.layer.borderWidth = 1;//DEBUG
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
 float cellWidth = 320.0;
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
        if(MessageReadStatusRead == msgReadFlag)
            imgThumb = @"pause-gray";
        else
            imgThumb = @"pause-red";
    }
    else {
        if(MessageReadStatusRead == msgReadFlag){
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
            imgThumb = @"play-red";
        }
    }
    
    self.playButton.image = [[UIImage imageNamed:imgThumb] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

-(void)updateVoiceView:(NSDictionary *)voiceDic
{
    msgReadFlag = [[voiceDic valueForKey:MSG_READ_CNT]intValue];
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
        sliderImgThumb = @"slide-img-small-red";
        imgThumb = @"pause-red";
        
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
    NSString *imgThumb = @"";
    [self.dic setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAYBACK_STATUS];
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
        imgThumb = @"play-red";
    }
    
    self.playButton.image = [[UIImage imageNamed:imgThumb] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

-(void)setStatusIcon:(NSString *)status isAvs:(int)avsMsg readCount:(int)readCount msgType:(NSString *)msgType
{
    NSString* imgThumb = @"";
    if([status isEqualToString:API_DOWNLOAD_INPROGRESS])
    {
        KLog(@"API_DOWNLOAD_INPROGRESS");
        CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        self.downloadIndicator.transform = transform;
        [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
        
        [self.playButton setImage:nil];
        [self.downloadIndicator startAnimating];
        return;
    }
    else if([status isEqualToString:API_DELIVERED] || [status isEqualToString:API_DOWNLOADED]) {
        KLog(@"API_DOWNLOADED");
    }
    else if([status isEqualToString:API_MSG_PALYING]) {
        if(MessageReadStatusRead == msgReadFlag)
            imgThumb = @"pause-gray";
        else
            imgThumb = @"pause-red";
        
    } else {
        if(MessageReadStatusRead == msgReadFlag)
            imgThumb = @"play-gray";
        else
            imgThumb = @"play-red";
    }
    
    [self. downloadIndicator stopAnimating];
    
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

-(IBAction)transcriptViewButtonClicked:(UIButton *)sender
{
    KLog(@"transcriptViewbuttonClicked");
    id bVoiceToText = [self.dic valueForKey:IS_VOICE_TO_TEXT_HIDDEN];
    if(nil==bVoiceToText) {
        [self.dic setValue:[NSNumber numberWithBool:true] forKey:IS_VOICE_TO_TEXT_HIDDEN];
    }
    else {
        bool bValue = [bVoiceToText boolValue];
        if(bValue)
            [self.dic setValue:[NSNumber numberWithBool:false] forKey:IS_VOICE_TO_TEXT_HIDDEN];
        else
            [self.dic setValue:[NSNumber numberWithBool:true] forKey:IS_VOICE_TO_TEXT_HIDDEN];
    }
    
    [self.baseConversationObj.chatView reloadData];//TODO
}

- (IBAction)callbackButtonAction:(id)sender {
    
    if([self.delegate isAudioRecording])
        return;
    
    [self.delegate resignTextResponder];
    NSString* phoneNum = [self.dic valueForKey:@"FROM_USER_ID"];
#ifdef REACHME_APP
    NSString* remoteUserType = [self.dic valueForKey:REMOTE_USER_TYPE];
    NSString* fromNumber = [self.dic valueForKey:NATIVE_CONTACT_ID];
    [Common callNumber:phoneNum FromNumber:fromNumber UserType:remoteUserType];
#else
    [Common callWithNumber:phoneNum];
#endif
}

#pragma UISlider

-(void)changedThumbPosition {
    KLog(@"changePosition");
    NSString* imgThumb = @"";
    
    if(self.audioSlider.continuous) {
        self.audioSlider.continuous = NO;
        if(MessageReadStatusRead == msgReadFlag)
            imgThumb = @"slide-img-big-gray";
        else
            imgThumb = @"slide-img-big-red";
    } else {
        if(MessageReadStatusRead == msgReadFlag)
            imgThumb = @"slide-img-small-gray";
        else
            imgThumb = @"slide-img-small-red";
        self.audioSlider.continuous = YES;
    }

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

- (IBAction)touchCancel:(id)sender {
    NSString* imgThumb = @"";
    if(MessageReadStatusRead == msgReadFlag) {
        imgThumb = @"slide-img-small-gray";
    } else {
        imgThumb = @"slide-img-small-red";
    }
    [self.audioSlider setThumbImage:[UIImage imageNamed:imgThumb] forState:UIControlStateNormal];
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
