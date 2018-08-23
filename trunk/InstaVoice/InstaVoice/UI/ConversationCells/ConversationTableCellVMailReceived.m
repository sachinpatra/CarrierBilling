//
//  ConversationTableCellVMailReceived.m
//  InstaVoice
//
//  Created by Pandian on 06/01/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConversationTableCellVMailReceived.h"
#import "IVColors.h"

@interface ConversationTableCellVMailReceived ()

@end

@implementation ConversationTableCellVMailReceived

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
    
    self.transTextView.editable = NO;
    self.transTextView.scrollEnabled = NO;
    self.transTextView.textContainerInset = UIEdgeInsetsMake(10, 12, 10, 10);
    self.transTextViewHeight.constant = 0;
    self.voiceViewHeight.constant = 57;
    
    self.audioSlider.continuous = YES;
    self.audioSlider.maximumValue = totalDuration;
    [self.audioSlider addTarget:self action:@selector(changedThumbPosition) forControlEvents:UIControlEventValueChanged];
    
    //- Sets up taprecognizer for voiceView
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voiceViewbuttonClicked:)];
    [self.voiceView addGestureRecognizer:tap];
    
    //- sets up taprecognizer for transcriptView
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transcriptViewButtonClicked:)];
    [self.transcriptView addGestureRecognizer:tap1];
    
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
    
    
    //- set up transcript image view
    self.transcriptView.backgroundColor = [UIColor whiteColor];
    self.transcriptView.clipsToBounds = YES;
    self.transcriptView.layer.borderWidth = 1;
    self.transcriptView.layer.borderColor = [IVColors redOutlineColor].CGColor;
    
    
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
    self.timeStamp.contentMode = UIViewContentModeScaleToFill;
    
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
    
#endif
    
    NSString* transcript = [self.dic valueForKey:MSG_TRANS_TEXT];
    bool bVoiceToText = [[self.dic valueForKey:IS_VOICE_TO_TEXT_HIDDEN]boolValue];
    
    if(bVoiceToText) {
        
        NSMutableAttributedString *attString;
        UIFont *fontBoldConfidence = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];
        UIFont *fontRegularText = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        
        NSString *quedString;
        if (!transcript.length) {
            if ([[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"]){
                quedString = @"Sorry, Voice-To-Text is not available";
            }else{
                quedString = @"Voice-To-Text is in progress...";
            }
            attString=[[NSMutableAttributedString alloc] initWithString:quedString];
            NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, quedString.length)];
            [attString addAttribute:NSFontAttributeName value:fontBoldConfidence range:NSMakeRange(0, quedString.length)];
        }else{
            attString=[[NSMutableAttributedString alloc] initWithString:transcript];
            if ([[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"]){
                quedString = @"Sorry, Voice-To-Text is not available";
            }else{
                quedString = @"Transcription Confidence: 1";
            }
            
            NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, quedString.length)];
            [attString addAttribute:NSFontAttributeName value:fontBoldConfidence range:NSMakeRange(0, quedString.length)];
            [attString addAttribute:NSFontAttributeName value:fontRegularText range:NSMakeRange(quedString.length, transcript.length - quedString.length)];
        }
        
        [self.transTextView setAttributedText:attString];
        self.transTextView.textContainerInset = UIEdgeInsetsMake(10.0, 0.0, 10.0, 3.0);
        
        //Calculate height for the trans text
        CGFloat fixedWidth = self.transTextView.frame.size.width;
        CGSize newSize = [self.transTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = self.transTextView.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        
        self.transTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        self.transTextView.textColor = [UIColor grayColor];
        self.transTextView.layer.borderWidth = 1;
        self.transTextView.layer.borderColor = [IVColors redOutlineColor].CGColor;
        self.transTextView.clipsToBounds = YES;
        self.transTextViewHeight.constant = newFrame.size.height+2;
        
        int transRating = [[self.dic valueForKey:MSG_TRANS_RATING] intValue];
        
        if (transcript.length && transRating < 1) {
            self.voiceViewHeight.constant += self.transTextViewHeight.constant + 25.0;
            for (UIView *subView in self.voiceView.subviews)
            {
                if (subView.tag == 99)
                {
                    [subView removeFromSuperview];
                }
            }
            
            for (UIButton *subView in self.voiceView.subviews)
            {
                if (subView.tag == 199)
                {
                    [subView removeFromSuperview];
                }
            }
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, newFrame.size.height + 50.0, self.voiceView.frame.size.width, 1.0)];
            lineView.backgroundColor = [IVColors redOutlineColor];
            lineView.tag = 99;
            [self.voiceView addSubview:lineView];
            
            UIButton *rating = [[UIButton alloc] initWithFrame:CGRectMake(0.0, newFrame.size.height + 50.0, self.voiceView.frame.size.width, 35.0)];
            rating.tag = 199;
            [rating setTitle:@"RATE TRANSCRIPTION QUALITY" forState:UIControlStateNormal];
            [rating setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            rating.titleLabel.font = [UIFont systemFontOfSize:10.0];
            [rating addTarget:self action:@selector(ratingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.voiceView addSubview:rating];
        }else{
            
            for (UIView *subView in self.voiceView.subviews)
            {
                if (subView.tag == 99)
                {
                    [subView removeFromSuperview];
                }
            }
            
            for (UIButton *subView in self.voiceView.subviews)
            {
                if (subView.tag == 199)
                {
                    [subView removeFromSuperview];
                }
            }
            
            self.voiceViewHeight.constant += self.transTextViewHeight.constant;
        }
        
        self.transcriptImg.image = [[UIImage imageNamed:@"ic_transcribing"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        if(transcript.length)
            self.transcriptImg.image = [[UIImage imageNamed:@"ic_transcribed"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        else if ([[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"])
            self.transcriptImg.image = [[UIImage imageNamed:@"ic_no_transcription"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
    } else {
        
        self.transcriptImg.image = [[UIImage imageNamed:@"ic_transcribe"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        if(transcript.length)
            self.transcriptImg.image = [[UIImage imageNamed:@"ic_transcribed"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        else if ([[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"])
            self.transcriptImg.image = [[UIImage imageNamed:@"ic_no_transcription"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        else if ([[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"q"])
            self.transcriptImg.image = [[UIImage imageNamed:@"ic_transcribing"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    UITapGestureRecognizer *transcriptionText = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(transcriptionTextClicked:)];
    self.transTextView.userInteractionEnabled = YES;
    [self.transTextView addGestureRecognizer:transcriptionText];
    
    //self.toUserAndLocation.layer.borderWidth = 1;//DEBUG
    KLog(@"VMailReceived: voiceView = %@",self.voiceView);
    
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
    }
    else {
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
    NSString *transcriptText = [self.dic valueForKey:MSG_TRANS_TEXT];
    
    NSUInteger totalCredits = [[ConfigurationReader sharedConfgReaderObj] getVsmsLimit];
    if(!transcriptText.length && ![[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"] && ![[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"q"]){
        [self.delegate transcriptionButtonTapped:self.dic];
        
        if (totalCredits < 2)
            return;
        
        [self.dic setValue:@"q" forKey:MSG_TRANS_STATUS];
    }
    
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
    
    //Bhaskar April 13th--> To Show Transcription text which is hiding behind keypad
    //Bug ID --> 12526
    [self.delegate transcriptionExpandedViewAtIndex:self.cellIndex];
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

- (IBAction)ratingButtonAction:(id)sender {
    [self.delegate ratingButtonTappedAtIndex:self.dic];
}

- (void)transcriptionTextClicked:(UITapGestureRecognizer *)reco
{
    KLog(@"Transcription Text Clicked");
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


-(void)dragInisdeOrOutside {
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
    [self dragInisdeOrOutside];
}

- (IBAction)dragInside:(id)sender {
    KLog(@"dragInside");
    [self dragInisdeOrOutside];
}

@end
