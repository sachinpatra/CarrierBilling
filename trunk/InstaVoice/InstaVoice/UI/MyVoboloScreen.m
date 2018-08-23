//
//  MyVoboloScreen.m
//  InstaVoice
//
//  Created by Eninov User on 08/10/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "MyVoboloScreen.h"
#import "SizeMacro.h"
#import "Profile.h"
#import "IVFileLocator.h"
#import "IVImageUtility.h"
#import "IVColors.h"

@interface MyVoboloScreen () <UINavigationControllerDelegate>{
    BOOL scrollDown;
}

@property (strong, nonatomic) UIButton *enableSpeakerButton;

@end

@implementation MyVoboloScreen

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"My Blogs";
        self.tabBarItem.image = [UIImage imageNamed:@"menu_blog_icon"];
       
        if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
            self.hidesBottomBarWhenPushed = NO;
        
        self.tabBarController.tabBar.hidden = NO;
    }
    return self;
}

- (void)setupEnableSpeakerButton
{
    switch ([[ConfigurationReader sharedConfgReaderObj]getVolumeMode]) {
        case 1:
            EnLogd(@"Speaker On");
            [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-closed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
            [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [self.enableSpeakerButton setTintColor:[IVColors redColor]];
            //[speakerButton setTag:1];
            _speakerMode = true;
            break;
        case 2:
            EnLogd(@"Speaker Off");
            [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-closed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
            [self.enableSpeakerButton setTintColor:[IVColors grayOutlineColor]];
            //[speakerButton setTag:SIZE_2];
            _speakerMode = false;
            break;
        default:
            break;
    }
}

- (void)viewDidLoad
{
    scrollDown = YES;
    self.msgType = VB_TYPE;
    self.uiType = MY_VOBOLO_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    [super viewDidLoad];

    // set up the audio switching button in the top of the screen
    UIButton *audioButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.enableSpeakerButton = audioButton;
    [audioButton addTarget:self action:@selector(audioModeTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *secondRightBarButton = [[UIBarButtonItem alloc] initWithCustomView:audioButton];
    self.navigationItem.rightBarButtonItem = secondRightBarButton;

    [self setupEnableSpeakerButton];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    saveLastMsg = YES;
    
    [appDelegate.engObj clearCurrentChatUser];
    self.uiType = MY_VOBOLO_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    //[appDelegate.dataMgt getMyVoboloList:NO];
    [_refreshControl removeFromSuperview];
    
    self.needToHideKeyboard = NO;
    [self setMyVoboloHeader];
    if(!dicSections.count || !arrDatesSorted.count)
    {
        msgTextLabel.hidden = NO;
        self.chatView.hidden = YES;
        msgTextLabel.text = NSLocalizedString(@"LOADING", nil);
        [appDelegate.dataMgt getMyVoboloList:YES];
    }

    if (self.enableSpeakerButton) {
        [self setupEnableSpeakerButton];
    }
    
    [self hideRecordingView];
    self.chatView.scrollEnabled = YES;
    self.tabBarController.tabBar.hidden = YES;
    self.hidesBottomBarWhenPushed = NO;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if([[[UIDevice currentDevice] systemVersion]floatValue]<9.0)
        [self hideKeayboard];
}

-(void)hideKeayboard
{
    if (self.needToHideKeyboard) {
        [text1 resignFirstResponder];
    }
}

-(void)keyboardWillAppearForVoboloScreen:(NSNotification*)note
{
//    //DC WAK
//    self.needToHideKeyboard = YES;
//    if(self.uiType == MY_VOBOLO_SCREEN)
//    {
//        self.tabBarController.tabBar.hidden = YES;
//        CGFloat keyboardHeight = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//        if(!isKeyboardPresent)
//        {
//            //DC
//            CGRect rect = text.frame;
//            rect.origin.y -=keyboardHeight;
//            text.frame = rect;
//            
//            CGRect rectChatView = self.chatView.frame;
//            rectChatView.size.height -=  keyboardHeight;
//            self.chatView.frame = rectChatView;
//            
//            CGRect rectRecordingArea = recordingArea.frame;
//            rectRecordingArea.origin.y -= keyboardHeight;
//            recordingArea.frame = rectRecordingArea;
//            
//            CGRect rectMicButtonView = micButtonView.frame;
//            rectMicButtonView.origin.y -= keyboardHeight;
//            micButtonView.frame = rectMicButtonView;
//            
//            _kbSheetSize.height = keyboardHeight;
//            _kbSheetSize.width = rectChatView.size.width;
//            
//            isKeyboardPresent = YES;
//            
//            [self scrollToBottom];
//        }
//        else
//        {
//            KLog(@"Predictive text resized");
//            CGFloat deltaHeight = keyboardHeight - _kbSheetSize.height;
//            _kbSheetSize.height = keyboardHeight;
//            
//            CGRect rectChatView = self.chatView.frame;
//            CGRect rectRecordingArea = recordingArea.frame;
//            CGRect rectMicButtonView = micButtonView.frame;
//            //DC
//            CGRect rectTextView = text.frame;
//            
//            if(deltaHeight>0)
//            {
//                rectChatView.size.height -= deltaHeight;
//                rectRecordingArea.origin.y -= deltaHeight;
//                rectMicButtonView.origin.y -= deltaHeight;
//                rectTextView.origin.y -= deltaHeight;
//
//            }
//            else
//            {
//                rectChatView.size.height += deltaHeight*-1;
//                rectRecordingArea.origin.y += deltaHeight*-1;
//                rectMicButtonView.origin.y += deltaHeight*-1;
//                rectTextView.origin.y += deltaHeight*-1;
//            }
//            
//            self.chatView.frame = rectChatView;
//            recordingArea.frame = rectRecordingArea;
//            micButtonView.frame = rectMicButtonView;
//            //DC
//            text.frame = rectTextView;
//            [self scrollToBottom];//July 19, 2016
//        }
//    }
}

//NOV 5
-(void)keyboardWillDisappearForVoboloScreen:(NSNotification*)note
{
//    //DC WAK
//    self.needToHideKeyboard = NO;
//
//    if(self.uiType == MY_VOBOLO_SCREEN)
//    {
//       // if(_shareMessage) return;
//        CGFloat keyboardHeight = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//        if(isKeyboardPresent) {
//            KLog(@"Keyboard is hidden");
//            if(!keyboardHeight) keyboardHeight = _kbSheetSize.height;
//
//            CGRect rectChatView = self.chatView.frame;
//            rectChatView.size.height += keyboardHeight;
//            self.chatView.frame = rectChatView;
//            
//            CGRect rectRecordingArea = recordingArea.frame;
//            rectRecordingArea.origin.y += keyboardHeight;
//            recordingArea.frame = rectRecordingArea;
//            
//            CGRect rectMicButtonView = micButtonView.frame;
//            rectMicButtonView.origin.y += keyboardHeight;
//            micButtonView.frame = rectMicButtonView;
//          
//            ///DC
//            CGRect rect = text.frame;
//            rect.origin.y += keyboardHeight;
//            text.frame = rect;
//            
//            //DC
//            UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//            self.chatView.contentInset = contentInsets;
//            self.chatView.scrollIndicatorInsets = contentInsets;
//            
//            isKeyboardPresent = NO;
//        }
//    }
}
//DC
-(void)setFontForContentSizeChange:(NSNotification*)notificatio
{
//    [text setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
//    CGFloat fixedWidth = text.frame.size.width;
//    CGSize newSize = [text sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
//    if (newSize.height < 210.0) {
//        [self updateTextViewSize];
    
//    }
}
//Function:Setting of Header View for InsideConversation Screen
-(void)setMyVoboloHeader
{
    DrawCircle  *drawCircleViewBack = nil;
    UIButton *backButton = nil;
    UserProfileModel* userProfile = [Profile sharedUserProfile].profileData;
    NSString *loggedInUserName = nil;
    UIImage *loggedInUserPic = nil;
    UILabel *titleLabel  = nil;
    NSString *imgPath = nil;
    UIImageView *remoteUserView = nil;
    
    loggedInUserName = [appDelegate.confgReader getLoginId];
    if(userProfile != nil)
    {
        NSString *userName = userProfile.screenName;//[loggedInUserProfile valueForKey:SCREEN_NAME];
        if(userName != nil && [userName length]>0)
        {
            loggedInUserName = userName;
        }
        imgPath = [IVFileLocator getMyProfilePicPath:userProfile.localPicPath];//[loggedInUserProfile valueForKey:LOCAL_PIC_PATH];
    }
    
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        backButton = [[UIButton alloc] initWithFrame:CGRectMake(SIZE_8, SIZE_0, SIZE_50, SIZE_44)];
        drawCircleViewBack =[[DrawCircle alloc] initWithFrame:CGRectMake(SIZE_275,SIZE_2,SIZE_40,SIZE_40) color:loggedInUserName radius:17.5];
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_65,SIZE_8,194, SIZE_30)];
    }
    else
    {
        backButton = [[UIButton alloc] initWithFrame:CGRectMake(SIZE_8, SIZE_15, SIZE_50, SIZE_44)];
        drawCircleViewBack =[[DrawCircle alloc] initWithFrame:CGRectMake(SIZE_275,SIZE_20,SIZE_40,SIZE_40) color:loggedInUserName radius:17.5];
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_59, SIZE_23, SIZE_201, SIZE_30)];
    }
    
    drawCircleViewBack.backgroundColor =[UIColor clearColor];
    
    if(imgPath != nil && ![imgPath isEqualToString:@""])
    {
        loggedInUserPic = [IVImageUtility getUIImageFromFilePath:imgPath];
    }
    if(loggedInUserPic == nil)
    {
        UILabel *remoteUserName = [[UILabel alloc] initWithFrame:CGRectMake(SIZE_10,SIZE_5,SIZE_20,SIZE_30)];
        remoteUserName.backgroundColor=[UIColor clearColor];
        remoteUserName.textColor=[UIColor blackColor];
        remoteUserName.font =[UIFont systemFontOfSize:SIZE_13];
        remoteUserName.textAlignment = NSTextAlignmentCenter;
        remoteUserName.text =[loggedInUserName substringWithRange:NSMakeRange(0, 1)];
        [drawCircleViewBack addSubview:remoteUserName];
    }
    else
    {
        remoteUserView = [self setImageView];
        [remoteUserView setImage:loggedInUserPic];
        [drawCircleViewBack addSubview:remoteUserView];
    }
    
    
    [backButton setImage:[UIImage imageNamed:IMG_BACK] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    //Setting for middle title of navigation Bar
    [titleLabel setFont:[UIFont fontWithName:HELVETICANEUE_MEDIUM size:SIZE_18]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setTextColor:[UIColor blackColor]];
    NSString *title = NSLocalizedString(@"MY_VOBOLOS", nil);
    titleLabel.text = title;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    [super viewWillDisappear:animated];
    ConversationTableCell *cell = [self.chatView cellForRowAtIndexPath:indexForAudioPlayed];
    [cell.dic setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAY_DURATION];
    
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Event Manager

-(int)handleEvent:(NSMutableDictionary *)resultDic
{
    if(resultDic != nil)
    {
        int evType = [[resultDic valueForKey:EVENT_TYPE] intValue];
        NSString *respCode = [resultDic valueForKey:RESPONSE_CODE];
        switch (evType)
        {
            case GET_MYVOBOLO_MSG:
                
                if([respCode isEqual:ENG_SUCCESS])
                {
                    NSArray* msgList = [appDelegate.dataMgt getMyVoboloList:NO];
                    [self prepareDataSourceFromMessages:msgList withInsertion:YES MsgType:eOtherMessage];
                    if(dicSections.count)
                    {
                        [self loadData];
                        if (scrollDown) {
                            [self scrollToBottom];
                            scrollDown = NO;
                        }
                    }
                    else
                    {
                        [self unloadData];
                    }
                }
                else
                {
                    [self unloadData];
                }
                break;
                
                
            case DOWNLOAD_VOICE_MSG:
            {
                if([respCode isEqualToString:ENG_SUCCESS])
                {
                    ConversationTableCell *cell = [self.chatView cellForRowAtIndexPath:indexForAudioPlayed];//Jan 19
                    
                    NSMutableDictionary *respMsgDic =[resultDic valueForKey:RESPONSE_DATA];
                    NSArray* msgList = [appDelegate.dataMgt getMyVoboloList:NO];
                    [self prepareDataSourceFromMessages:msgList withInsertion:YES MsgType:eOtherMessage];
                    
                    if(respMsgDic != nil && self.voiceDic != nil )
                    {
                        NSString *msgGuid = [self.voiceDic valueForKey:MSG_GUID];
                        [self.voiceDic setValue:API_DOWNLOADED forKey:MSG_STATE];
                        NSString *msgRespGuid = [respMsgDic valueForKey:MSG_GUID];
                        NSString *msgState  = [respMsgDic valueForKey:MSG_STATE];
                        if([msgGuid isEqualToString:msgRespGuid])
                        {
                            if([msgState isEqualToString:API_DOWNLOADED])
                            {
                                
                                int speakerMode = (CALLER_MODE == [appDelegate.confgReader getVolumeMode])?false:true;
                                if( [Audio isHeadsetPluggedIn] )
                                    speakerMode = false;
                                
                                if([self.audioObj startPlayback:[respMsgDic valueForKey:MSG_LOCAL_PATH] playTime:[[respMsgDic valueForKey:MSG_PLAY_DURATION] intValue] playMode:speakerMode ])
                                {
                                    if(cell)
                                    {
                                        [cell setStatusIcon:API_MSG_PALYING isAvs:0 readCount:0 msgType:nil];
                                        [cell.dic setValue:[NSNumber numberWithInt:1] forKey:MSG_PLAYBACK_STATUS];
                                        [cell swapPlayPause:nil];
                                    }
                                    
                                    if(drawStripTimer != nil)
                                    {
                                        [drawStripTimer invalidate];
                                    }
                                    drawStripTimer = [NSTimer scheduledTimerWithTimeInterval:audioPlayUpdateInterval target:self selector:@selector(playVoiceMsg:) userInfo:respMsgDic repeats:YES];
                                }
                                self.voiceDic = respMsgDic;
                            }
                            else
                            {
                                [self.voiceDic setValue:API_NOT_DOWNLOADED forKey:MSG_STATE];
                                if(cell)
                                    [cell setStatusIcon:API_NOT_DOWNLOADED isAvs:0 readCount:0 msgType:nil];
                            }
                        }
                        else
                        {
                            [self loadData];
                        }
                    }
                    else
                    {
                        EnLogd(@"Dowloaded Dic is nil.");
                    }
                }
            }
                break;
                
            case NOTIFY_UI_ON_ACTIVITY:
                break;
                
            case FETCH_MSG:
            {
                [appDelegate.dataMgt getMyVoboloList:YES];
                break;
            }
                
            case SEND_MSG:
            {
                NSArray* msgList = [appDelegate.dataMgt getMyVoboloList:NO];
                [self prepareDataSourceFromMessages:msgList withInsertion:YES MsgType:eOtherMessage];
                if(dicSections.count)
                {
                    [self loadData];
                }
                else
                {
                    [self unloadData];
                }
            }
                break;
                
            default:
                [super handleEvent:resultDic];
                break;
        }
    }
    return SUCCESS;
}


- (void)audioModeTapped:(id)sender {
    //TODO:
    int tag = 2;
    if(_speakerMode) tag = 1;
    
    if( [Audio isHeadsetPluggedIn]) {
        EnLogd(@"Headset plugged-in. No mode change.");
        KLog(@"Headset plugged-in. No mode change.");
        return;
    }
    
    switch (tag) {
            
        case 2: // this turns the speaker on
        {
            EnLogd(@"Speaker On");
            
            [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-closed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
            [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [self.enableSpeakerButton setTintColor:[IVColors redColor]];

            _speakerMode = true;
            [appDelegate.confgReader setVolumeMode:SPEAKER_MODE];
            [self.audioObj setVolume:SPEAKER_MODE];
            break;
        }
            
        case 1: // this turns the speaker off
        {
            EnLogd(@"Speaker Off");
            
            [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-closed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
            [self.enableSpeakerButton setTintColor:[IVColors grayOutlineColor]];

            _speakerMode = false;
            [appDelegate.confgReader setVolumeMode:CALLER_MODE];
            [self.audioObj setVolume:CALLER_MODE];
            break;
        }
        default:
            break;
    }
}

-(void)markReadMessagesFromThisList:(NSArray *)list {
    KLog(@"*** NO IMPL");
}

//DC
//Clean Up Methods
- (void)dealloc {
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}
@end
