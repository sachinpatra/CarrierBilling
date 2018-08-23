//
//  IVChatTableViewCellVMailReceived.m
//  InstaVoice
//
//  Created by Pandian on 30/09/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "IVChatTableViewCellVMailReceived.h"
#import "IVColors.h"
#import "Macro.h"
#import "TableColumns.h"
#import "Common.h"
#import "ChatGridViewController.h"
#import "ImgMacro.h"
#import "ConversationApi.h"
#import "ScreenUtility.h"
#import "Setting.h"

@interface IVChatTableViewCellVMailReceived()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transcriptViewWidth;
@end

@implementation IVChatTableViewCellVMailReceived

/*
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}*/


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
    
    NSString* conversationType = [self.dic valueForKey:@"CONVERSATION_TYPE"];
    if([conversationType isEqualToString:@"g"]) {
        self.profilePictureView.image = [UIImage imageNamed:@"default_profile_img_group"];
    }
    else {
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
        //self.profilePictureView.image = profilePicture ? profilePicture : nil;
        if (profilePicture) {
            self.profilePictureView.image = profilePicture;
        }
        else if(data.contactPicURI)
        {
            [[Contacts sharedContact]downloadAndSavePicWithURL:data.contactPicURI picPath:imageURLString];
        }
    }
    
    // set up the cell's profile picture view constraints
    self.profilePictureView.clipsToBounds = YES;
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2;
    self.profilePictureView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    // set up the date label on the cell
    msgReadFalg = [[self.dic valueForKey:MSG_READ_CNT]intValue];
    NSNumber *remoteDate  = [self.dic valueForKey:@"MSG_DATE"];
    if (remoteDate) {
        /*Debug
        if([remoteUserName isEqualToString:@"918765768658"]) {
            KLog(@"yes");
        }*/
        
        self.dateLabel.text = [ScreenUtility dateConverter:remoteDate dateFormateString:NSLocalizedString(@"DATE_FORMATE_CHATGRID",nil)];
        
        if(!msgReadFalg) {
            self.dateLabel.textColor = [UIColor blackColor];
            [self.dateLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
        } else {
            self.dateLabel.textColor = [IVColors colorWithHexString:@"666666"];
            [self.dateLabel setFont:[UIFont systemFontOfSize:13.0]];
        }
        
        if ( /*ChatTypeAll*/2 != [(ChatGridViewController*)self.delegate getChatType] && msgReadFalg == MessageReadStatusSeen) {
            
            self.dateLabel.textColor = [UIColor blackColor];
            [self.dateLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
            
        }
        
    }
    
    self.transcriptView.backgroundColor = [UIColor whiteColor];
    self.transcriptView.clipsToBounds = YES;
    self.transcriptView.layer.borderWidth = 1;
    self.transcriptView.layer.borderColor = [IVColors redOutlineColor].CGColor;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transcriptViewButtonClicked:)];
    [self.transcriptView addGestureRecognizer:tap1];
    
    NSString* transcript = [self.dic valueForKey:MSG_TRANS_TEXT];
    
    self.transcribeImg.image = [UIImage imageNamed:@"ic_transcribe"];
    
    if(transcript.length)
        self.transcribeImg.image = [[UIImage imageNamed:@"ic_transcribed"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    else if ([[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"])
        self.transcribeImg.image = [[UIImage imageNamed:@"ic_no_transcription"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    else if ([[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"q"])
        self.transcribeImg.image = [[UIImage imageNamed:@"ic_transcribing"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
}

-(void)configureCellForChatTile:(NSMutableDictionary *)dic forRow:(int)rowValue
{
    [self setupFields];
    [self.messageContentLabel sizeToFit];
    
    if ( /*ChatTypeAll*/ 2 != [(ChatGridViewController*)self.delegate getChatType]) {
        self.unreadMsgCount.hidden = YES;
        self.callbackIndicator.hidden = NO;
    } else {
        self.callbackIndicator.hidden = YES;
        self.unreadMsgCount.backgroundColor = [UIColor redColor];
        self.unreadMsgCount.textColor = [UIColor whiteColor];
        self.unreadMsgCount.font = [UIFont systemFontOfSize:SIZE_12];
        self.unreadMsgCount.layer.masksToBounds = YES;
        self.unreadMsgCount.textAlignment = NSTextAlignmentCenter;
        self.unreadMsgCount.text = [self.dic valueForKey:UNREAD_MSG_COUNT];
        
        NSString* strUnreadMsgCount = [self.dic valueForKey:UNREAD_MSG_COUNT];
        int unreadMsgCount = [strUnreadMsgCount intValue];
        if(!unreadMsgCount) {
            self.unreadMsgCount.hidden = YES;
        }
        else {
            self.unreadMsgCount.hidden = NO;
            self.unreadMsgCount.text = strUnreadMsgCount;
            if([self.unreadMsgCount.text length]>2) {
                self.unreadMsgCount.text = @"99+";
                self.unreadMsgCount.layer.cornerRadius = 9;
            }
            else
                self.unreadMsgCount.layer.cornerRadius = self.unreadMsgCount.frame.size.width / 2;
        }
    }
    
    [self.msgIndicator setImage:[UIImage imageNamed:@"voicemail_icon_r"]];
    
    BOOL isPlaying = [[self.dic valueForKey:MSG_PLAYBACK_STATUS]intValue];
    int totalDuration = [[self.dic valueForKey:DURATION]intValue];
    int playedDuration = [[self.dic valueForKey:MSG_PLAY_DURATION] intValue];
    
    //- Adjust the voiceView according to the duration
    int newWidth = VOICEVIEW_WIDTH (totalDuration);
    if(newWidth > VOICEVIEW_MIN_WIDTH) {
        self.voiceViewWidth.constant = newWidth;
    } else {
        self.voiceViewWidth.constant = VOICEVIEW_MIN_WIDTH;
    }
    //KLog(@"VMAIL-RECVD = duration = %d, newWidth = %d", totalDuration,newWidth);
    //

    SettingModel *currentSettingsModel = [Setting sharedSetting].data;
    NSString *transScript = [self.dic valueForKey:MSG_TRANS_TEXT];
    
    if (currentSettingsModel.userManualTrans) {
        self.transcriptViewWidth.constant = 40.0;
    }else{
        if(transScript.length || [[self.dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"])
            self.transcriptViewWidth.constant = 40.0;
        else
            self.transcriptViewWidth.constant = 1.0;
    }
    
#ifndef TRANSCRIPTION_ENABLED
    self.transcriptViewWidth.constant = 1.0;
#endif
    
    
    if(totalDuration == playedDuration) {
        playedDuration = 0;
    }
    
    /*
    if(!totalDuration) {
        KLog(@"why tottalDuration is zero?");
    }*/

    //- slider set up
    self.audioSlider.continuous = YES;
    self.audioSlider.maximumValue = totalDuration;
    self.audioSlider.minimumTrackTintColor = [IVColors redOutlineColor];
    self.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xf3c4c0);
    
    [self.audioSlider addTarget:self action:@selector(changedThumbPosition) forControlEvents:UIControlEventValueChanged];
    
    //- Sets up taprecognizer for voiceView
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voiceViewbuttonClicked:)];
    [self.voiceView addGestureRecognizer:tap];
    
    self.voiceView.backgroundColor = [IVColors redFillColor];
    self.voiceView.layer.borderColor = [IVColors redOutlineColor].CGColor;
    self.voiceView.layer.borderWidth = 1;
    self.voiceView.layer.cornerRadius= 7;
    self.voiceView.tintColor = [IVColors redFillColor];
    self.voiceView.clipsToBounds = YES;
    
    //- color for the voice message view
    if(MessageReadStatusUnread == msgReadFalg || MessageReadStatusSeen == msgReadFalg) {
        [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-red"] forState:UIControlStateNormal];
        self.playButton.image = [[UIImage imageNamed:@"play-red"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        [self.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-gray"] forState:UIControlStateNormal];
        self.playButton.image = [[UIImage imageNamed:@"play-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    //- play/pause button
    NSString* buttonImage = @"";
    if(isPlaying && playedDuration) {
        buttonImage = @"pause-";
    } else if (playedDuration) {
        self.audioSlider.value = playedDuration;
        buttonImage = @"play-";
    }
    else {
        self.audioSlider.value = 0.0;
        buttonImage = @"play-";
    }
    
    if(MessageReadStatusUnread == msgReadFalg || MessageReadStatusSeen == msgReadFalg)
        buttonImage = [buttonImage stringByAppendingString:@"red"];
    else
        buttonImage = [buttonImage stringByAppendingString:@"gray"];
    
    self.playButton.image = [[UIImage imageNamed:buttonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //
    
    //- duration label
    self.durationLabel.backgroundColor = [UIColor clearColor];
    self.durationLabel.textAlignment= NSTextAlignmentRight;
    
    if(MessageReadStatusSeen == msgReadFalg || MessageReadStatusUnread == msgReadFalg) {
        self.durationLabel.textColor = [IVColors redOutlineColor];
        self.durationLabel.font = [UIFont systemFontOfSize:SIZE_12];
    }
    else {
        self.durationLabel.textColor = UIColorFromRGB(DURATION_AUDIO_LISTENED);
        self.durationLabel.font = [UIFont systemFontOfSize:SIZE_12];
    }
    
    if(playedDuration) {
        NSString *formattedDuration = [ScreenUtility durationIntoString:playedDuration];
        self.durationLabel.text = formattedDuration;
    } else {
        self.durationLabel.text = [ScreenUtility durationIntoString:totalDuration];
    }
}

-(IBAction)callbackButtonClicked:(id)sender {
    
    NSString* phoneNum = [self.dic valueForKey:@"FROM_USER_ID"];
#ifdef REACHME_APP
    NSString* remoteUserType = [self.dic valueForKey:REMOTE_USER_TYPE];
    [Common callNumber:phoneNum FromNumber:nil UserType:remoteUserType];
#else
    [Common callWithNumber:phoneNum];
#endif
}

-(void)swapPlayPause:(id)sender
{
    BOOL isPlaying = [[self.dic valueForKey:MSG_PLAYBACK_STATUS]intValue];
    NSString* buttonImage = @"";
    if (isPlaying) {
        if(MessageReadStatusUnread == msgReadFalg || MessageReadStatusSeen == msgReadFalg)
            buttonImage = @"pause-red";
        else
            buttonImage = @"pause-gray";
    }
    else {
        if(MessageReadStatusUnread == msgReadFalg || MessageReadStatusSeen == msgReadFalg)
            buttonImage = @"play-red";
        else
            buttonImage = @"play-gray";
    }
    
    self.playButton.image = [[UIImage imageNamed:buttonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

-(void)setStatusIcon:(NSString *)status isAvs:(int)avsMsg readCount:(int)readCount msgType:(NSString *)msgType
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
        if(MessageReadStatusUnread == msgReadFalg || MessageReadStatusSeen == msgReadFalg)
            buttonImage = @"pause-red";
        else
            buttonImage = @"pause-gray";
    }
    else {
        if(MessageReadStatusUnread == msgReadFalg || MessageReadStatusSeen == msgReadFalg)
            buttonImage = @"play-red";
        else
            buttonImage = @"play-gray";
    }
    
    [self.downloadIndicator stopAnimating];
    if(buttonImage.length) {
        self.playButton.image = [[UIImage imageNamed:buttonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.playButton setNeedsDisplay];
    }
}

-(IBAction)transcriptViewButtonClicked:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(transcriptButtonClickedAtIndex:withMsgDic:)]) {
        [self.delegate transcriptButtonClickedAtIndex:self.cellIndex withMsgDic:self.dic];
    }
}

-(void)updateVoiceView:(NSDictionary *)voiceDic {
    
    double playedDuration = [[voiceDic valueForKey:MSG_PLAY_DURATION] doubleValue];
    NSString *formattedDuration = [ScreenUtility durationIntoString:playedDuration];
    [self.durationLabel setText:formattedDuration];
    NSString* buttonImage = @"";
    if(MessageReadStatusUnread == msgReadFalg || MessageReadStatusSeen == msgReadFalg)
        buttonImage = @"pause-red";
    else
        buttonImage = @"pause-gray";
    self.playButton.image = [[UIImage imageNamed:buttonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.audioSlider.value = playedDuration;
    
    //KLog(@"updateVoiceView %lf",playedDuration);
}

-(void)stopPlaying:(id)sender
{
    NSString* buttonImage = @"";
    [self.dic setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAYBACK_STATUS];
    if(MessageReadStatusUnread == msgReadFalg || MessageReadStatusSeen == msgReadFalg)
        buttonImage = @"play-red";
    else
        buttonImage = @"play-gray";
    
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
    NSString* imgThumb=@"";
    if(self.audioSlider.continuous) {
        self.audioSlider.continuous = NO;
        if(MessageReadStatusUnread == msgReadFalg || MessageReadStatusSeen == msgReadFalg)
            imgThumb = @"slide-img-big-red";
        else
            imgThumb = @"slide-img-big-gray";
        [self.audioSlider setThumbImage:[UIImage imageNamed:imgThumb] forState:UIControlStateNormal];
    } else {
        if(MessageReadStatusUnread == msgReadFalg || MessageReadStatusSeen == msgReadFalg)
            imgThumb = @"slide-img-small-red";
        else
            imgThumb = @"slide-img-small-gray";
        
        [self.audioSlider setThumbImage:[UIImage imageNamed:imgThumb] forState:UIControlStateNormal];
        self.audioSlider.continuous = YES;
    }
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
    [self.durationLabel setText:formattedDuration];
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
    NSString* imgThumb=@"";
    if(MessageReadStatusUnread == msgReadFalg || MessageReadStatusSeen == msgReadFalg)
        imgThumb = @"slide-img-small-red";
    else
        imgThumb = @"slide-img-small-gray";
    
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
    [self.durationLabel setText:formattedDuration];
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
