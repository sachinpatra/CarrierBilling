//
//  ConversationTableCellVMailSentNoTrans.m
//  InstaVoice
//
//  Created by Pandian on 05/01/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConversationTableCellVMailSentNoTrans.h"
#import "IVColors.h"

@interface ConversationTableCellVMailSentNoTrans ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tickMarkConstraints;
@end

@implementation ConversationTableCellVMailSentNoTrans

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
    
    if (MessageReadStatusRead == msgReadFlag){
        self.voiceView.backgroundColor = [IVColors redFillColor];
        self.voiceView.layer.borderColor = [IVColors redOutlineColor].CGColor;
        self.voiceView.tintColor = [IVColors redOutlineColor];
        self.audioSlider.minimumTrackTintColor = [IVColors grayOutlineColor];
        self.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xcfcfcf);
        [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-gray"] forState:UIControlStateNormal];
        self.duration.textColor = [IVColors grayOutlineColor];
    }else{
        self.voiceView.backgroundColor = [IVColors redFillColor];
        self.voiceView.layer.borderColor = [IVColors redOutlineColor].CGColor;
        self.voiceView.tintColor = [IVColors redOutlineColor];
        self.audioSlider.minimumTrackTintColor = [IVColors redOutlineColor];
        self.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xf3c4c0);
        [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-red"] forState:UIControlStateNormal];
        self.duration.textColor = [IVColors redOutlineColor];
    }
    
    //- Set the playbutton
    NSString* imgThumb = @"";
    if(isPlaying && playedDuration) {
        if (MessageReadStatusRead == msgReadFlag)
            imgThumb = @"pause-gray";
        else
            imgThumb = @"pause-red";
    } else if (playedDuration) {
        self.audioSlider.value = playedDuration;
        if (MessageReadStatusRead == msgReadFlag)
            imgThumb = @"play-gray";
        else
            imgThumb = @"play-red";
    }
    else {
        self.audioSlider.value = 0.0;
        if (MessageReadStatusRead == msgReadFlag)
            imgThumb = @"play-gray";
        else
            imgThumb = @"play-red";
    }
    self.playButton.image = [[UIImage imageNamed:imgThumb] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //
    
    //- setup duration label
    self.duration.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    self.duration.backgroundColor = [UIColor clearColor];
    self.duration.textAlignment = NSTextAlignmentRight;
    self.duration.textColor = MessageReadStatusRead == msgReadFlag?[IVColors grayOutlineColor]:[IVColors redOutlineColor];
    
    if(playedDuration) {
        NSString *formattedDuration = [ScreenUtility durationIntoString:playedDuration];
        self.duration.text = formattedDuration;
    } else {
        self.duration.text = [ScreenUtility durationIntoString:totalDuration];
    }
    
    //Get To and From user name
    NSString *fromNumber = [self.dic valueForKey:NATIVE_CONTACT_ID];
    NSString *theFromPhoneNumber = [Common getFormattedNumber:fromNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    NSString *toNumber = [self.dic valueForKey:@"FROM_USER_ID"];
    NSString *theToPhoneNumber = [Common getFormattedNumber:toNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    
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
    NSString *locationString = [self.dic valueForKey:LOCATION_NAME];
    if(!locationString)
        locationString = @"";
    
    if(theFromPhoneNumber.length) {
        NSString *fromUser = [NSString stringWithFormat:@"From: %@  %@", theFromPhoneNumber,locationString];
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:fromUser];
        
        NSDictionary* theAttributes = @{NSForegroundColorAttributeName: UIColorFromRGB(LOCATION_TEXT),
                                        NSFontAttributeName: [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]};
        [attributedString setAttributes:theAttributes range:[fromUser rangeOfString:theFromPhoneNumber]];
        self.fromUser.attributedText = attributedString;
        self.fromUser.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    }

    self.toUserAndLocation.backgroundColor = [UIColor clearColor];
    self.toUserAndLocation.textColor = UIColorFromRGB(LOCATION_TEXT);
    if(theToPhoneNumber.length) {
        NSString *toUser = [NSString stringWithFormat:@"To: %@", theToPhoneNumber];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:toUser];
        
        NSDictionary *theAttributes = @{NSForegroundColorAttributeName: UIColorFromRGB(TO_USER_TEXT_COLOR),
                                        NSFontAttributeName: [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]};
        [attributedString setAttributes:theAttributes range:[toUser rangeOfString:theToPhoneNumber]];
        self.toUserAndLocation.attributedText = attributedString;
        self.toUserAndLocation.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
        
    }
    
    self.timeStamp.backgroundColor = [UIColor clearColor];
    self.timeStamp.textAlignment = NSTextAlignmentRight;
    self.timeStamp.font = [UIFont systemFontOfSize:11.0];
    self.timeStamp.textColor = MessageReadStatusRead == msgReadFlag?[IVColors grayOutlineColor]:[IVColors redOutlineColor];
    self.timeStamp.contentMode = UIViewContentModeScaleToFill;
    
    NSString* timeString = @"";
    NSNumber *date = [self.dic valueForKey:MSG_DATE];
    timeString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
    self.timeStamp.text = timeString;
    self.timeStamp.contentMode = UIViewContentModeScaleToFill;
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
    else
    {
        NSNumber *date = [self.dic valueForKey:MSG_DATE];
        timeString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
        self.timeStamp.text = timeString;
        self.timeStamp.contentMode = UIViewContentModeScaleToFill;
    }*/
    
    if ([msgStatus isEqualToString:API_DOWNLOAD_INPROGRESS]){
        CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        self.downloadIndicator.transform = transform;
        [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
        [self.downloadIndicator startAnimating];
        [self.playButton setImage:nil];
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
            [msgStatus isEqualToString:API_DOWNLOADED]||
            [msgStatus isEqualToString:API_DOWNLOAD_INPROGRESS]) {
        tickImageName = @"single_tick";
    }
    else {
        tickImageName = @"hour-glass";
    }
    
    self.tickImage.image = [[UIImage imageNamed:tickImageName]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
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
    
    /*
    NSMutableString* dateString = [[NSMutableString alloc]initWithString:@" "];
    [dateString appendString:self.timeStamp.text];
    
    //combine image and label
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    if(![msgState isEqualToString:API_WITHDRAWN]) {
        attachment.image = [UIImage imageNamed:tickImageName];
    }
    
    NSAttributedString* tempString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    //NSMutableAttributedString *attachmentString = [NSMutableAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *attachmentString = [[NSMutableAttributedString alloc]initWithAttributedString:tempString];
    
    [attachmentString addAttribute:NSForegroundColorAttributeName
                             value:UIColorFromRGB(TIMESTAMP_AUDIO_SENT)
                             range:NSMakeRange(0, attachmentString.length)];
    
    
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
    
    //self.toUserAndLocation.layer.borderWidth = 1;//DEBUG
    KLog(@"VMailSentNoTrans: self.voiceView %@", self.voiceView);
    
    //self.timeStamp.layer.borderWidth = 1; //DEBUG
    
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
    if (isPlaying)
        if (MessageReadStatusRead == msgReadFlag)
            imgThumb = @"pause-gray";
        else
            imgThumb = @"pause-red";
        else
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

-(void)updateVoiceView:(NSDictionary *)voiceDic
{
    //int totalDuration = [[voiceDic valueForKey:DURATION] intValue];
    double playedDuration = [[voiceDic valueForKey:MSG_PLAY_DURATION] doubleValue];
    //KLog(@"updateVoiceView: tot = %d, cur = %f",totalDuration,playedDuration);
    NSString *imgThumb = @"";
    if (MessageReadStatusRead == msgReadFlag)
            imgThumb = @"pause-gray";
        else
            imgThumb = @"pause-red";
    
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
    //[self.audioSlider setThumbImage:[UIImage imageNamed:imgThumb] forState:UIControlStateNormal];
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
        if (MessageReadStatusRead == msgReadFlag)
            imgThumb = @"pause-gray";
        else
            imgThumb = @"pause-red";
        
    } else {
        if (MessageReadStatusRead == msgReadFlag)
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
        if (MessageReadStatusRead == msgReadFlag)
            imgThumb = @"slide-img-big-gray";
        else
            imgThumb = @"slide-img-big-red";
    } else {
        if (MessageReadStatusRead == msgReadFlag)
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
    NSString *imgThumb = @"";
    if (MessageReadStatusRead == msgReadFlag)
        imgThumb = @"slide-img-small-gray";
    else
        imgThumb = @"slide-img-small-red";
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

