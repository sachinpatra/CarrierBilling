//
//  IVChatTableViewCellVMsgSent.m
//  InstaVoice
//
//  Created by Pandian on 30/09/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "IVChatTableViewCellVMsgSent.h"
#import "IVColors.h"
#import "Macro.h"
#import "TableColumns.h"
#import "ImgMacro.h"
#import "ConversationApi.h"
#import "Common.h"
#import "ScreenUtility.h"
#import "Setting.h"

@interface IVChatTableViewCellVMsgSent()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transcriptViewWidth;
@end

@implementation IVChatTableViewCellVMsgSent

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupFields
{
    //- remote user name
    NSString *remoteUserName = [self.dic valueForKey:REMOTE_USER_NAME];
    if(!remoteUserName || ![remoteUserName length]) {
        remoteUserName = [self.dic valueForKey:FROM_USER_ID];
    }
    
    //- format the number
    //TODO performance
    NSString* formattedString = [self formatPhoneNumberString:remoteUserName];
    if([formattedString length])
        self.usernameLabel.text = formattedString;
    else
        self.usernameLabel.text = remoteUserName;
    //
    /*
    if( [[self.dic valueForKey:REMOTE_USER_NAME] isEqualToString:@"cmp"]) {
        KLog(@"Debug");
    }*/
    
    NSString* conversationType = [self.dic valueForKey:@"CONVERSATION_TYPE"];
    
    /*
    if(![conversationType length]) {
       //KLog(@"conv type is nil");
    }*/
    
    if([conversationType isEqualToString:@"g"])
    {
        self.profilePictureView.image = [UIImage imageNamed:@"default_profile_img_group"];
    }
    else
    {
        self.profilePictureView.image = [UIImage imageNamed:@"default_profile_img_user"];
    }
    
    // load the user's profile picture, if they have one. If they don't, load the view to display instead
    NSArray* arr = [[Contacts sharedContact]getContactForPhoneNumber:[self.dic valueForKey:FROM_USER_ID]];
    ContactDetailData* detail = Nil;
    if([arr count]>0)
        detail = [arr objectAtIndex:0];
    
    if (detail)  {
        ContactData *data = detail.contactIdParentRelation;
        NSString *imageURLString = [IVFileLocator getNativeContactPicPath:data.contactPic];
        UIImage *profilePicture = [ScreenUtility getPicImage:imageURLString];
        if (profilePicture) {
            self.profilePictureView.image = profilePicture;
        }
        else if(data.contactPicURI)
        {
            [[Contacts sharedContact]downloadAndSavePicWithURL:data.contactPicURI picPath:imageURLString];
        }
    } else {
        KLog(@"No detail");
    }
    
    // set up the cell's profile picture view constraints
    self.profilePictureView.clipsToBounds = YES;
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2;
    self.profilePictureView.contentMode = UIViewContentModeScaleAspectFill;
    
    // set up the date label on the cell
    NSNumber *remoteDate  = [self.dic valueForKey:@"MSG_DATE"];
    if (remoteDate) {
        /*Debug
        if([remoteUserName isEqualToString:@"918765768658"]) {
            KLog(@"yes");
        }*/
        
        self.dateLabel.text = [ScreenUtility dateConverter:remoteDate
                                         dateFormateString:NSLocalizedString(@"DATE_FORMATE_CHATGRID",nil)];

        NSString* tickImage = @"";
        int readCount = [[self.dic valueForKey:MSG_READ_CNT]intValue];
        NSString* msgState = [self.dic valueForKey:MSG_STATE];
        if(readCount>0) {
            if ([conversationType isEqualToString:GROUP_TYPE])
                tickImage = @"single_tick";
            else
                tickImage = @"double_tick";
        }
        else if([msgState isEqualToString:API_DELIVERED] ||
                [msgState isEqualToString:API_DOWNLOADED] ||
                [msgState isEqualToString:API_DOWNLOAD_INPROGRESS]) {
            tickImage = @"single_tick";
        }
        else if([msgState isEqualToString:API_NETUNAVAILABLE] || [msgState isEqualToString:API_UNSENT]) {
            tickImage = @"failed-msg";
        }
        else {
            tickImage = @"hour-glass";
        }
        
        self.dateLabel.textColor = UIColorFromRGB(MSG_TIME_TEXT);
        [self.dateLabel setFont:[UIFont systemFontOfSize:13.0]];
        
        NSMutableString* dateString = [[NSMutableString alloc]initWithString:@" "];
        [dateString appendString:self.dateLabel.text];
        
        //combine image and label
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        if(![msgState isEqualToString:API_WITHDRAWN]) {
            attachment.image = [UIImage imageNamed:tickImage];
        }
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:dateString];
        [myString insertAttributedString:attachmentString atIndex:0];
        self.dateLabel.attributedText = myString;
        //
    }
}

-(void)configureCellForChatTile:(NSMutableDictionary *)dic forRow:(int)rowValue
{
    [self setupFields];
    msgReadFlag = [[self.dic valueForKey:MSG_READ_CNT]intValue];
    if(msgReadFlag > 1)
        msgReadFlag = 1;
    
    [self.messageContentLabel sizeToFit];
    
    msgType = [self.dic valueForKey:MSG_TYPE];
    // unread message count
    self.unreadMsgCount.backgroundColor = [UIColor redColor];
    self.unreadMsgCount.textColor = [UIColor whiteColor];
    self.unreadMsgCount.font = [UIFont systemFontOfSize:SIZE_12];
    self.unreadMsgCount.textAlignment = NSTextAlignmentCenter;
    self.unreadMsgCount.layer.masksToBounds = YES;
    self.unreadMsgCount.text = [self.dic valueForKey:UNREAD_MSG_COUNT];
    
    NSString* strUnreadMsgCount = [self.dic valueForKey:UNREAD_MSG_COUNT];
    int unreadMsgCount = [strUnreadMsgCount intValue];
    if(!unreadMsgCount) {
        self.unreadMsgCount.hidden = YES;
    }
    else {
        self.unreadMsgCount.hidden = NO;
        self.unreadMsgCount.text = strUnreadMsgCount;
        if([self.unreadMsgCount.text length]>2)
            self.unreadMsgCount.layer.cornerRadius = 9;
        else
            self.unreadMsgCount.layer.cornerRadius = self.unreadMsgCount.frame.size.width / 2;
    }
    
    [self.msgIndicator setImage:[UIImage imageNamed:@"voicemsg_icon"]];
    
    BOOL isPlaying = [[self.dic valueForKey:MSG_PLAYBACK_STATUS]intValue];
    int totalDuration = [[self.dic valueForKey:DURATION]intValue];
    double playedDuration = [[self.dic valueForKey:MSG_PLAY_DURATION] doubleValue];
    
    //- Adjust the voiceView according to the duration
    int newWidth = VOICEVIEW_WIDTH (totalDuration);
    if(newWidth > VOICEVIEW_MIN_WIDTH) {
        self.voiceViewWidth.constant = newWidth;
    } else {
        self.voiceViewWidth.constant = VOICEVIEW_MIN_WIDTH;
    }
    //KLog(@"VMSG-SENT = duration = %d, newWidth = %d", totalDuration,newWidth);
    //
    
    SettingModel *currentSettingsModel = [Setting sharedSetting].data;
    NSString *transScript = [self.dic valueForKey:MSG_TRANS_TEXT];
    
    if (currentSettingsModel.userManualTrans || transScript.length || [[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"]) {
        self.transcriptViewWidth.constant = 40.0;
    }else{
        self.transcriptViewWidth.constant = 1.0;
    }
    
#ifndef TRANSCRIPTION_ENABLED
    self.transcriptViewWidth.constant = 1.0;
#endif
    
    NSString* msgState = [self.dic valueForKey:MSG_STATE];
    if((([msgState isEqualToString:API_DELIVERED] || [msgState isEqualToString:API_DOWNLOADED] || [msgState isEqualToString:API_DOWNLOAD_INPROGRESS]) && currentSettingsModel.userManualTrans) || (transScript.length || [[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"])) {
        self.transcriptViewWidth.constant = 40.0;
    }else {
        self.transcriptViewWidth.constant = 1.0;
    }
    
    if(totalDuration == playedDuration) {
        playedDuration = 0;
    }
    
    //slider set up
    self.audioSlider.continuous = YES;
    self.audioSlider.maximumValue = totalDuration;
    
    [self.audioSlider addTarget:self action:@selector(changedThumbPosition) forControlEvents:UIControlEventValueChanged];
    
    //- Sets up taprecognizer for voiceView
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voiceViewbuttonClicked:)];
    [self.voiceView addGestureRecognizer:tap];
    
    self.voiceView.layer.borderWidth = 1;
    self.voiceView.layer.cornerRadius= 7;
    self.voiceView.clipsToBounds = YES;
    //- voice view
    //- color for the voice message view
    if([msgType isEqualToString:VSMS_TYPE]) {
        self.voiceView.backgroundColor = [IVColors grayFillColor];
        self.voiceView.layer.borderColor = [IVColors grayOutlineColor].CGColor;
        self.voiceView.tintColor = [IVColors grayOutlineColor];
        self.audioSlider.minimumTrackTintColor = [IVColors grayOutlineColor];
        self.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xcfcfcf);
        [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-gray"] forState:UIControlStateNormal];
        self.duration.textColor = UIColorFromRGB(DURATION_AUDIO_NONIV);
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
    
    self.transcriptView.backgroundColor = [UIColor whiteColor];
    self.transcriptView.clipsToBounds = YES;
    self.transcriptView.layer.borderWidth = 1;
    if([msgType isEqualToString:VSMS_TYPE])
        self.transcriptView.layer.borderColor = [IVColors grayOutlineColor].CGColor;
    else
        self.transcriptView.layer.borderColor = [IVColors greenOutlineColor].CGColor;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transcriptViewButtonClicked:)];
    [self.transcriptView addGestureRecognizer:tap1];
    
    NSString* transcript = [self.dic valueForKey:MSG_TRANS_TEXT];
    self.transcribeImg.image = [UIImage imageNamed:@"ic_transcription_green"];
    
    if([msgType isEqualToString:VSMS_TYPE])
        self.transcribeImg.image = [[UIImage imageNamed:@"ic_transcribed"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    if(transcript.length)
        self.transcribeImg.image = [[UIImage imageNamed:@"ic_transcribed"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    else if ([[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"])
        self.transcribeImg.image = [[UIImage imageNamed:@"ic_no_transcription"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    else if ([[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"q"]){
        if([msgType isEqualToString:VSMS_TYPE])
            self.transcribeImg.image = [[UIImage imageNamed:@"ic_transcribing_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        else
            self.transcribeImg.image = [[UIImage imageNamed:@"ic_transcribing_green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    //- play/pause button
    NSString* buttonImage = @"";
    if(isPlaying && playedDuration) {
        buttonImage = @"pause-";
    }
    else if (playedDuration) {
        self.audioSlider.value = playedDuration;
        buttonImage = @"play-";
    }
    else {
        self.audioSlider.value = 0.0;
        buttonImage = @"play-";
    }
    
    if([msgType isEqualToString:VSMS_TYPE])
        buttonImage = [buttonImage stringByAppendingString:@"gray"];
    else
        if (MessageReadStatusRead == msgReadFlag)
            buttonImage = [buttonImage stringByAppendingString:@"gray"];
        else
            buttonImage = [buttonImage stringByAppendingString:@"green"];
    
    self.playButton.image = [[UIImage imageNamed:buttonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //
    
    //- duration label
    self.duration.font = [UIFont systemFontOfSize:SIZE_12];
    self.duration.text = [ScreenUtility durationIntoString:totalDuration];
    if(playedDuration) {
        NSString *formattedDuration = [ScreenUtility durationIntoString:playedDuration];
        self.duration.text = formattedDuration;
    }
    else {
        self.duration.text = [ScreenUtility durationIntoString:totalDuration];
    }
}

-(IBAction)transcriptViewButtonClicked:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(transcriptButtonClickedAtIndex:withMsgDic:)]) {
        [self.delegate transcriptButtonClickedAtIndex:self.cellIndex withMsgDic:self.dic];
    }
}

-(void)swapPlayPause:(id)sender
{
    BOOL isPlaying = [[self.dic valueForKey:MSG_PLAYBACK_STATUS]intValue];
    NSString* buttonImage = @"";
    if (isPlaying) {
        if([msgType isEqualToString:VSMS_TYPE])
            buttonImage = @"pause-gray";
        else
            if (MessageReadStatusRead == msgReadFlag)
                buttonImage = @"pause-gray";
            else
                buttonImage = @"pause-green";
    }
    else {
        if([msgType isEqualToString:VSMS_TYPE])
            buttonImage = @"play-gray";
        else
            if (MessageReadStatusRead == msgReadFlag)
                buttonImage = @"play-gray";
            else
                buttonImage = @"play-green";
    }
    
    self.playButton.image = [[UIImage imageNamed:buttonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

-(void)setStatusIcon:(NSString *)status isAvs:(int)avsMsg readCount:(int)readCount msgType:(NSString *)mesgType
{
    NSString* buttonImage = @"";
    if([status isEqualToString:API_DOWNLOAD_INPROGRESS])
    {
        CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        self.downloadIndicator.transform = transform;
        [self.downloadIndicator setColor:self.audioSlider.minimumTrackTintColor];
        
        [self.playButton setImage:nil];
        [self.downloadIndicator startAnimating];
        return;
    }
    if([status isEqualToString:API_DELIVERED] || [status isEqualToString:API_DOWNLOADED]) {
        KLog(@"API_DOWNLOADED");
    }
    else if([status isEqualToString:API_MSG_PALYING]) {
        if([msgType isEqualToString:VSMS_TYPE])
            buttonImage = @"pause-gray";
        else
            if (MessageReadStatusRead == msgReadFlag)
                buttonImage = @"pause-gray";
            else
                buttonImage = @"pause-green";
    }
    else {
        if([msgType isEqualToString:VSMS_TYPE])
            buttonImage = @"play-gray";
        else
            if (MessageReadStatusRead == msgReadFlag)
                buttonImage = @"play-gray";
            else
                buttonImage = @"play-green";
    }
    
    [self. downloadIndicator stopAnimating];
    if(buttonImage.length) {
        self.playButton.image = [[UIImage imageNamed:buttonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.playButton setNeedsDisplay];
    }
}

-(void)updateVoiceView:(NSDictionary *)voiceDic {
    
    double playedDuration = [[voiceDic valueForKey:MSG_PLAY_DURATION] doubleValue];
    NSString *formattedDuration = [ScreenUtility durationIntoString:playedDuration];
    [self.duration setText:formattedDuration];
    self.audioSlider.value = playedDuration;
    NSString* buttonImage = @"";
    if([msgType isEqualToString:VSMS_TYPE])
        buttonImage = @"pause-gray";
    else
        if (MessageReadStatusRead == msgReadFlag)
            buttonImage = @"pause-gray";
        else
            buttonImage = @"pause-green";
    
    if(buttonImage.length) {
        self.playButton.image = [[UIImage imageNamed:buttonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.playButton setNeedsDisplay];
    }
    //KLog(@"updateVoiceView %lf",playedDuration);
}

-(void)stopPlaying:(id)sender
{
    NSString* buttonImage = @"";
    if([msgType isEqualToString:VSMS_TYPE])
        buttonImage = @"play-gray";
    else
        if (MessageReadStatusRead == msgReadFlag)
            buttonImage = @"play-gray";
        else
            buttonImage = @"play-green";
    
    [self.dic setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAYBACK_STATUS];
    self.playButton.image = [[UIImage imageNamed:buttonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
    KLog(@"changePosition");
    NSString* imgThumb = @"";
    if(self.audioSlider.continuous) {
        self.audioSlider.continuous = NO;
        if([msgType isEqualToString:VSMS_TYPE])
            imgThumb = @"slide-img-big-gray";
        else
            if (MessageReadStatusRead == msgReadFlag)
                imgThumb = @"slide-img-big-gray";
            else
                imgThumb = @"slide-img-big-green";
    } else {
        self.audioSlider.continuous = YES;
        if([msgType isEqualToString:VSMS_TYPE])
            imgThumb = @"slide-img-small-gray";
        else
            if (MessageReadStatusRead == msgReadFlag)
                imgThumb = @"slide-img-small-gray";
            else
                imgThumb = @"slide-img-small-green";
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

- (IBAction)touchCancel:(id)sender {
    NSString* imgThumb = @"";
    if([msgType isEqualToString:VSMS_TYPE])
        imgThumb = @"slide-img-small-gray";
    else
        if (MessageReadStatusRead == msgReadFlag)
            imgThumb = @"slide-img-small-gray";
        else
            imgThumb = @"slide-img-small-green";
    
    [self.audioSlider setThumbImage:[UIImage imageNamed:imgThumb] forState:UIControlStateNormal];
}

@end
