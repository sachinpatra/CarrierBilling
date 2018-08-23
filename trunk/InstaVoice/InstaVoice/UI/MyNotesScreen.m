//
//  MyNotesScreen.m
//  InstaVoice
//
//  Created by Eninov User on 08/10/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "MyNotesScreen.h"
#import "SizeMacro.h"
#import "IVFileLocator.h"
#import "Profile.h"
#import "IVImageUtility.h"
#import "MZFormSheetController.h"
#import "MZFormSheetBackgroundWindowViewController.h"
#import "MZFormSheetBackgroundWindow.h"
#import "MZFormSheetSegue.h"
#import "IVColors.h"
#import "ChatActivity.h"

#define MYNOTES @"My Notes"

@interface MyNotesScreen ()

@property (strong, nonatomic) UIButton *enableSpeakerButton;

@end


@interface MyNotesScreen ()
{
    NSUInteger _countOfList;
    BOOL scrollDown;
}

@end

@implementation MyNotesScreen

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Notes";
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Notes" image:[UIImage imageNamed:@"notes"] selectedImage:[UIImage imageNamed:@"notes-selected"]]];
        
        /*
        if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
            self.hidesBottomBarWhenPushed = NO;
         */
    }
    return self;
}

-(void)setupEnableSpeakerButton
{
    switch ([[ConfigurationReader sharedConfgReaderObj]getVolumeMode]) {
        case 1:
            EnLogd(@"Speaker On");
            [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-closed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
            [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [self.enableSpeakerButton setTintColor:[IVColors redColor]];
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

-(void)setFontForContentSizeChange:(NSNotification*)notificatio
{
//    [text setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
//    CGFloat fixedWidth = text.frame.size.width;
//    CGSize newSize = [text sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
//    
//    if (newSize.height < 210.0)
//        if (isKeyboardPresent)
//            [self updateTextViewSize];
}

-(void)viewDidLoad
{
    //TO hide Back Button
    //Bhaskar April 19th --> Called in ViewWillappear
    //    self.navigationItem.hidesBackButton = YES;
    //    self.navigationItem.leftBarButtonItem = nil;
    //    self.navigationController.navigationBar.topItem.title = @"";
    
    //Bhaskar April 19th --> Need to register/Add observer only once
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
     */
    scrollDown = YES;
    
    //Bhaskar April 18th --> Called in viewWillAppear
//    self.uiType = NOTES_SCREEN;
//    self.msgType = NOTES_TYPE;
//    [appDelegate.stateMachineObj setCurrentUI:self];
    
    [super viewDidLoad];
    // set up the audio switching button in the top of the screen
    UIButton *audioButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.enableSpeakerButton = audioButton;
    [audioButton addTarget:self action:@selector(audioModeTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *secondRightBarButton = [[UIBarButtonItem alloc] initWithCustomView:audioButton];
    self.navigationItem.rightBarButtonItem = secondRightBarButton;

    [self setupEnableSpeakerButton];
    self.title = @"Notes";
    
    [UIView animateWithDuration:0.25 animations:^{
        self.chatView.contentInset = UIEdgeInsetsMake(0, 0, 45.0, 0);
        self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 45.0, 0);
    }];
    
}

-(void)backButtonTapped
{
    //NOV 22, 2016
    //Workaround -- recreate the MyNotesScreen view controller so that InputAccessory view is called the next time
    //NoteScreen is selected
//    NSMutableArray* newArray = [NSMutableArray arrayWithArray:appDelegate.tabBarController.viewControllers];
//    MyNotesScreen *myNotesScreen = [[MyNotesScreen alloc] initWithNibName:@"BaseConversationScreen_4.0_ios7Master"
//                                                                      bundle:nil];
//    UINavigationController *notesNavController = [[UINavigationController alloc] initWithRootViewController:myNotesScreen];
//    [newArray removeObjectAtIndex:1];
//    [newArray insertObject:notesNavController atIndex:1];
//    [appDelegate.tabBarController setViewControllers:newArray animated:NO];
//    appDelegate.tabBarController.customizableViewControllers = @[];
//    //
//
//    [appDelegate.tabBarController setSelectedIndex:0];
//    [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[0]];
//
//    dicSections=0;
//    arrDatesSorted=0;
}

-(void)viewWillAppear:(BOOL)animated
{
    KLog(@"viewWillAppear");
    
    //TO hide Back Button
//    self.navigationItem.hidesBackButton = YES;
//    self.navigationController.navigationBar.topItem.title = @"";
//    self.navigationItem.leftBarButtonItem = nil;
    //
    
    saveLastMsg = YES;
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
//    [self.navigationItem setLeftBarButtonItem:backButton animated:YES];
    
    self.uiType = NOTES_SCREEN;
    self.msgType = NOTES_TYPE;
    [appDelegate.stateMachineObj setCurrentUI:self];
    [super viewWillAppear:animated];
    
    if(!dicSections.count || !arrDatesSorted.count)
    {
        msgTextLabel.hidden = NO;
        self.chatView.hidden = YES;
        msgTextLabel.text = NSLocalizedString(@"LOADING", nil);
        //TODO: when the YES is passed, getMyNotes returns nil always, since it is a async call. Refactor it.
        [appDelegate.dataMgt getMyNotes:YES];
    }
    else
    {
        NSArray* arrAllDateKeys = [dicSections allKeys];
        long count = 0;
        for(NSDate* dtDate in arrAllDateKeys) {
            NSArray* msgList = [dicSections objectForKey:dtDate];
            count += [msgList count];
        }
        
        NSString *title = [NSLocalizedString(@"Notes ", nil)stringByAppendingString:
                           [NSString stringWithFormat:@"(%ld)",count]];
        self.title = title;
        self.tabBarItem.title = @"Notes";
    }

    if (self.enableSpeakerButton) {
        [self setupEnableSpeakerButton];
    }
    
    [self hideRecordingView];
    
    self.chatView.scrollEnabled = YES;
    self.hidesBottomBarWhenPushed = YES;
    [appDelegate.dataMgt setCurrentChatUser:nil];
}

/*
-(void)keyboardWillShow:(NSNotification *)notification
{
    isKeyboardPresent = YES;
    keyboardHide = NO;
    height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSDictionary *keyInfo = [notification userInfo];
    CGRect keyboardFrame = [[keyInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    keyboardFrame = [self.chatView convertRect:keyboardFrame fromView:nil];
    CGRect intersect = CGRectIntersection(keyboardFrame, self.chatView.bounds);
    if (!CGRectIsNull(intersect)) {
        if([arrDatesSorted count]) {
            CGFloat height2 = self.chatView.frame.size.height;
            CGFloat contentYoffset = self.chatView.contentOffset.y;
            CGFloat distanceFromBottom = self.chatView.contentSize.height - contentYoffset + height;
            
            NSDate* dtDate = [arrDatesSorted objectAtIndex:[arrDatesSorted count]-1];
            NSArray* msgList = [dicSections objectForKey:dtDate];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgList count]-1 inSection:[arrDatesSorted count]-1];
            //
            CGRect rowHeight = [self.chatView rectForRowAtIndexPath:indexPath];
            CGFloat lastRowHeight = rowHeight.size.height;
            
            if(distanceFromBottom < height2 + lastRowHeight)
            {
                [UIView animateWithDuration:0.15 animations:^{
                    self.chatView.contentInset = UIEdgeInsetsMake(0.0, 0.0,
                                                                  text1.frame.size.height + (height == 0.0?45.0:height) - 45.0 + 14.0, 0.0);
                    self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0,
                                                                           text1.frame.size.height + (height == 0?45.0:height) - 45.0 + 14.0, 0.0);
                    [self scrollToBottom];
                }];
                
            }else{
                
                NSTimeInterval duration = [[keyInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
                [UIView animateWithDuration:duration animations:^{
                    self.chatView.contentInset = UIEdgeInsetsMake(0, 0, intersect.size.height, 0);
                    self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, intersect.size.height, 0);
                }];
            }
        }
    }
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    keyboardHide = YES;
    [self performSelector:@selector(toolBarFrame) withObject:nil afterDelay:0.75];
}
*/
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    /*
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
     */
    containerView.hidden = YES;
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
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
        //NSLog(@"@**** MyNotesScreen = %d",evType);
        NSString *respCode = [resultDic valueForKey:RESPONSE_CODE];
        switch (evType)
        {
            case GET_NOTES:
                KLog(@"GET_NOTES");
                
                if([respCode isEqual:ENG_SUCCESS])
                {
                    NSArray* msgList  = [appDelegate.dataMgt getMyNotes:NO];
                    [self prepareDataSourceFromMessages:msgList withInsertion:YES MsgType:eOtherMessage];
                    _countOfList = [msgList count];
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
                KLog(@"DOWNLOAD_VOICE_MSG");
                
                if([respCode isEqualToString:ENG_SUCCESS])
                {
                    NSMutableDictionary *respMsgDic =[resultDic valueForKey:RESPONSE_DATA];
                    int retVal = [self handleDownloadVoiceMsg:respMsgDic];
                    if(retVal<=0) {
                        EnLogd(@"***ERROR: handleDownloadVoiceMsg");
                    }
                }
            }
                break;
                
            case FETCH_OLDER_MSG:
            {
                KLog(@"FETCH_OLDER_MSG");
                [_refreshControl endRefreshing];
                _beginRefreshingOldMessages = false;
                if([respCode isEqualToString:ENG_SUCCESS]) {
                    [self handleFetchOlderNotes:resultDic];
                }
            }
                break;
                
            case NOTIFY_UI_ON_ACTIVITY:
            {
                KLog(@"NOTIFY_UI_ON_ACTIVITY");
                
                [self handleNotifyUIOnActivity:resultDic];
                break;
            }
                
            case CHAT_ACTIVITY:
            {
                KLog(@"CHAT_ACTIVITY");
                
                if([respCode isEqual:ENG_SUCCESS])
                {
                    ChatActivityData* activity = [resultDic valueForKey:RESPONSE_DATA];
                    switch (activity.activityType) {

                        /* The selected message is first deleted from local Message table and then send the msgID to server.
                           So no need to delete the message from datasource again. Refer BaseConversationScreen:SendMessageToServer
                         
                        case ChatActivityTypeDelete:
                        {
                            NSString* msgGuid = activity.msgGuid;
                            NSPredicate *predicate;
                            NSNumber* dateInMs = [activity.dic valueForKey:MSG_DATE];
                            NSDate* msgDate = [self getDateFromMilliSeconds:dateInMs];
                            NSMutableArray* msgList = [dicSections objectForKey:msgDate];
                            
                            if(msgGuid.length)
                                predicate = [NSPredicate predicateWithFormat:@"self.MSG_GUID != %@", msgGuid];
                            else
                                predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID != %@", [NSNumber numberWithInteger:activity.msgId]];
                            
                            [msgList filterUsingPredicate:predicate];
                            
                            if(![msgList count]) {
                                [dicSections removeObjectForKey:msgDate];
                                [arrDatesSorted removeObject:msgDate];
                            }
                            [self loadData];
                            
                            break;
                        }*/
                            
                        case ChatActivityTypeVoboloShare:
                        {
                            NSNumber* dateInMs = [activity.dic valueForKey:MSG_DATE];
                            NSDate* msgDate = [self getDateFromMilliSeconds:dateInMs];
                            NSMutableArray* msgList = [dicSections objectForKey:msgDate];
                            
                            NSInteger msgId = activity.msgId;
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID == %d", msgId];
                            NSArray *filteredConversationList = [msgList filteredArrayUsingPredicate:predicate];
                            
                            if( [filteredConversationList count]>0) {
                                NSMutableDictionary* selectedDic = [filteredConversationList objectAtIndex:0];
                                [selectedDic setValue:[NSNumber numberWithBool:YES] forKey:MSG_VB_POST];
                                [self loadData];
                            }
                            break;
                        }
                            
                        default: break;
                    }
                }
                break;
            }
                
            case FETCH_MSG:
            {
                KLog(@"FETCH_MSG");
                if([respCode isEqualToString:ENG_SUCCESS])
                {
                    [self processResponseFromServer:resultDic forEventType:FETCH_MSG];
                }
                //[appDelegate.dataMgt getMyNotes:YES];
                break;
            }
                
            case SEND_MSG:
            {
                KLog(@"SEND_MSG");
                
                [self handleSendMsg:resultDic];
            }
                break;
                
            default: {
                KLog(@"default");
                
                [super handleEvent:resultDic];
                break;
            }
        }
    }
    
    [self setNotesCount];
    self.tabBarItem.title = @"Notes";
    
    return SUCCESS;
}


-(int)handleDownloadVoiceMsg:(NSMutableDictionary*)respDic
{
    ConversationTableCell *cell = [self.chatView cellForRowAtIndexPath:indexForAudioPlayed];//TODO TEST
    if(nil == respDic || ![respDic count]) {
        EnLogd(@"*ERROR: Msg Dic for downloaded msg is null.");
        //KLog(@"*ERROR: Msg Dic for downloaded msg is null.");
        return -1;
    }
    
    if(nil == self.voiceDic) {
        EnLogd(@"*ERROR: Selected voice msg. dic is null");
        //KLog(@"*ERROR: Selected voice msg. dic is null");
        return -2;
    }
    
    NSString *curMsgGuid = [self.voiceDic valueForKey:MSG_GUID];
    NSString *cellMsgGuid = [cell.dic valueForKey:MSG_GUID];
    NSString* respMsgGuid = [respDic valueForKey:MSG_GUID];
    NSString* respMsgState  = [respDic valueForKey:MSG_STATE];
    NSString* respMsgLocalPath = [respDic valueForKey:MSG_LOCAL_PATH];
    int retVal = 0;
    BOOL isMsgMatched = FALSE;
    
    if(![cellMsgGuid isEqualToString:curMsgGuid]) {
        KLog(@"Msg could have been deleted. Return.");
        return -5;
    }
    
    //- NOTE: Celebriry message does not have MSG_GUID
    if(respMsgGuid && curMsgGuid) {
        //- update the cur cell dic
        isMsgMatched = [curMsgGuid isEqualToString:respMsgGuid];
        if(isMsgMatched) {
            [self.voiceDic setValue:respMsgState forKey:MSG_STATE];
            [self.voiceDic setValue:respMsgLocalPath forKey:MSG_LOCAL_PATH];
            [self.voiceDic setValue:API_DOWNLOADED forKey:MSG_STATE];
        }
        
        NSNumber* nuDate = [respDic valueForKey:MSG_DATE];
        if(!nuDate) {
            KLog(@"Debug");
        }
        NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
        dtDate = [self getDateWithDayMonthYear:dtDate];
        NSMutableArray* msgList = [dicSections objectForKey:dtDate];
        
        long maxConv = [msgList count];
        for(long i=0; i<maxConv; i++) {
            if([[msgList[i] valueForKey:MSG_GUID] isEqualToString:respMsgGuid]) {
                [msgList[i] setValue:respMsgState forKey:MSG_STATE];
                [msgList[i] setValue:respMsgLocalPath forKey:MSG_LOCAL_PATH];
                [msgList[i] setValue:API_DOWNLOADED forKey:MSG_STATE];
                retVal = 1;
                break;
            }
        }
    }
    else {
        NSNumber* curMsgID = [self.voiceDic valueForKey:MSG_ID];
        NSNumber* respMsgID = [respDic valueForKey:MSG_ID];
        isMsgMatched = [curMsgID isEqualToNumber:respMsgID];
        if(isMsgMatched) {
            [self.voiceDic setValue:respMsgState forKey:MSG_STATE];
            [self.voiceDic setValue:respMsgLocalPath forKey:MSG_LOCAL_PATH];
            [self.voiceDic setValue:API_DOWNLOADED forKey:MSG_STATE];
        }
        
        NSNumber* nuDate = [respDic valueForKey:MSG_DATE];
        if(!nuDate) {
            KLog(@"Debug");
        }
        NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
        dtDate = [self getDateWithDayMonthYear:dtDate];
        NSMutableArray* msgList = [dicSections objectForKey:dtDate];
        
        long maxConv = [msgList count];
        for(long i=0; i<maxConv; i++) {
            if([[msgList[i] valueForKey:MSG_ID] isEqualToNumber:respMsgID]) {
                [msgList[i] setValue:respMsgState forKey:MSG_STATE];
                [msgList[i] setValue:respMsgLocalPath forKey:MSG_LOCAL_PATH];
                [msgList[i] setValue:API_DOWNLOADED forKey:MSG_STATE];
                retVal = 2;
                break;
            }
        }
    }
    
    if(0==retVal) {
        EnLogd(@"msg GUID/ID does not match. May cause crash. FIXME");
        //KLog(@"msg GUID/ID does not match");
        if(isMsgMatched) {
            EnLogd(@"*ERROR: Msg was NOT DOWNLOADED");
            //KLog(@"*ERROR: Msg was NOT DOWNLOADED");
            [self.voiceDic setValue:API_NOT_DOWNLOADED forKey:MSG_STATE];
            if(cell)
                [cell setStatusIcon:API_NOT_DOWNLOADED isAvs:0 readCount:0 msgType:nil];
            
            return -4;
        }
    }
    
    if(retVal>0 && isMsgMatched)
    {
        NSString* playStatus = [self.voiceDic valueForKey:MSG_PLAYBACK_STATUS];
        if([playStatus intValue]) {
            KLog(@"Msg is already being played");
            return -5;//Msg is already being played
        }
        
        [self.voiceDic setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAY_DURATION];
        int playDuration = 0;
        int speakerMode = (CALLER_MODE == [appDelegate.confgReader getVolumeMode])?false:true;
        if( [Audio isHeadsetPluggedIn] )
            speakerMode = false;
        
        if(_beginRefreshingOldMessages) {
            return 1;
        }
        
        if([self.audioObj isRecord]) {
            KLog(@"Audio is already in play-state");
            if(cell) {
                [cell setStatusIcon:API_DOWNLOADED isAvs:0 readCount:0 msgType:nil];
            }
            return 1;
        }
        
        EnLogd(@"Call to startPlayback");
        
        if([self.audioObj startPlayback:respMsgLocalPath playTime:playDuration playMode:speakerMode])
        {
            if(cell) {
                [cell.dic setValue:[NSNumber numberWithInt:1] forKey:MSG_PLAYBACK_STATUS];
                [cell setStatusIcon:API_MSG_PALYING isAvs:0 readCount:0 msgType:nil];
                [cell swapPlayPause:nil];
            }
            
            if(drawStripTimer != nil)
                [drawStripTimer invalidate];
            
            drawStripTimer = [NSTimer scheduledTimerWithTimeInterval:audioPlayUpdateInterval target:self
                                                            selector:@selector(playVoiceMsg:) userInfo:respDic repeats:YES];
        }
    }
    
    return retVal;
}

-(void) handleFetchOlderNotes:(NSMutableDictionary*)resultDic
{

    KLog(@"### handleFetchOlderNotes START");
    
    if(![resultDic valueForKey:RESPONSE_DATA])
    {
        [text1 resignFirstResponder];
        [ScreenUtility showAlertMessage:@"No further older messages"];
    }
    else
    {
        NSMutableArray* oldMsgList = [resultDic valueForKey:RESPONSE_DATA];
        //NSDictionary* reqDic = [resultDic valueForKey:REQUEST_DIC];
        
        if(oldMsgList.count) {
            long  oldSections = [arrDatesSorted count];
            [self prepareDataSourceFromMessages:oldMsgList withInsertion:NO MsgType:eOtherMessage];
            long newSections = [arrDatesSorted count];
            
            [self.chatView reloadData];
            long sectionToScroll = oldSections<newSections?(newSections-oldSections-1):0;
            [self reloadAndScrollToSection:sectionToScroll];
            
            _countOfList += oldMsgList.count;
        }
    }
    
    KLog(@"### handleFetchOlderNotes - END");
}

-(void)handleNotifyUIOnActivity:(NSMutableDictionary*)resultDic
{
    //NSString *respCode = [resultDic valueForKey:RESPONSE_CODE];
    NSMutableArray* msgActivityList = [resultDic valueForKey:RESPONSE_DATA];
    BOOL reloadRequired=false;
    if(msgActivityList.count && dicSections.count)
    {
        for(ChatActivityData* data in msgActivityList)
        {
            NSUInteger secIndex=0;
            NSMutableArray* msgList = nil;
            NSArray* filteredMsgList = nil;
            NSInteger msgId = data.msgId;;
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID = %ld", msgId];
            NSArray* arrAllDateKeys = [dicSections allKeys];
            for(NSDate* dtDate in arrAllDateKeys) {
                msgList = [dicSections objectForKey:dtDate];
                filteredMsgList = [msgList filteredArrayUsingPredicate:predicate];
                if([filteredMsgList count]) break;
                secIndex++;
            }
            
            if(filteredMsgList.count)
            {
                reloadRequired = true;
                switch (data.activityType) {
                    case ChatActivityTypeUnlike:
                        [filteredMsgList[0] setValue:[NSNumber numberWithInt:0] forKey:MSG_LIKED];
                        break;
                    case ChatActivityTypeLike:
                        [filteredMsgList[0] setValue:[NSNumber numberWithInt:1] forKey:MSG_LIKED];
                        break;
                        
                    case ChatActivityTypeDelete: {
                        reloadRequired = NO;
                        NSUInteger rowIndex=0;
                        NSNumber* nuDate=nil;
                        for(NSDictionary* dic in msgList) {
                            if(msgId == [[dic valueForKey:MSG_ID]integerValue]) {
                                NSString* msgContentType = [dic valueForKey:MSG_CONTENT_TYPE];
                                nuDate = [dic valueForKey:MSG_DATE];
                                [msgList removeObjectAtIndex:rowIndex];
                                if([msgContentType isEqualToString:AUDIO_TYPE]) {
                                    NSInteger playBackStatus = [[dic valueForKey:MSG_PLAYBACK_STATUS]integerValue];
                                    [self stopAudioPlayback];
                                    reloadRequired = YES;
                                    if(playBackStatus>0 ) {
                                        [self performSelectorOnMainThread:@selector(showWithdrawnAlert)
                                                               withObject:nil waitUntilDone:NO];
                                    }
                                }
                                break;
                            }
                            rowIndex++;
                        }
                       
                        if([msgList count]<=0) {
                            NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
                            dtDate = [self getDateWithDayMonthYear:dtDate];
                            [dicSections removeObjectForKey:dtDate];
                            [arrDatesSorted removeObject:dtDate];
                        }
                        
                        [self.chatView reloadData];
                        //dismiss the action sheet displayed.
                        [self dismissActiveAlertController];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
}

-(void)handleSendMsg:(NSMutableDictionary*)resultDic
{
    NSString *respCode = [resultDic valueForKey:RESPONSE_CODE];
    
    if([respCode isEqualToString:ENG_SUCCESS])
    {
        [self processResponseFromServer:resultDic forEventType:SEND_MSG];
    }
    else
    {
        NSMutableDictionary* errorData = [resultDic valueForKey:ERROR_DATA];
        if(errorData)
        {
            int errorCode = [[errorData valueForKey:ERROR_CODE]intValue];
            if(84 == errorCode) {
                [ScreenUtility showAlert: NSLocalizedString(@"ERROR_CODE_84", nil)];
                [self.chatView reloadData];
            }
            else if(85 == errorCode) {
                [ScreenUtility showAlert: NSLocalizedString(@"ERROR_CODE_85", nil)];
            }
            else {
                //Unknown error from server
                //TODO: display a specific error string for this error: "err_code" = 69; "error_reason" = "Data is not saved on the server."
                NSString* errorReason = [errorData valueForKey:ERROR_REASON];
                EnLogd(@"errorReason:%@",errorReason);
                [ScreenUtility showAlert: errorReason];
            }
            
            //- Delete the msg from current data source
            NSUInteger index = 0;
            NSMutableDictionary* reqDic = [resultDic valueForKey:REQUEST_DIC];
            NSString* sentMsgGUID = [reqDic valueForKey:MSG_GUID];
            
            NSArray* allDateKeys = [dicSections allKeys];
            NSMutableArray* msgList = nil;
            NSArray* filterMsgList = nil;
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"MSG_GUID = %@", sentMsgGUID];;
            
            for(NSDate* dtDate in allDateKeys) {
                msgList = [dicSections objectForKey:dtDate];
                filterMsgList = [msgList filteredArrayUsingPredicate:predicate];
                if([filterMsgList count]) break;
            }
            
            if(filterMsgList.count) {
                for(NSDictionary* dic in msgList) {
                    NSString* msgGUID = [dic valueForKey:MSG_GUID];
                    if([msgGUID isEqualToString:sentMsgGUID]) break;
                    index++;
                }
                
                if(msgList.count) {
                    if(msgList.count == 1) {
                        NSNumber* nuDate = [[msgList objectAtIndex:0] valueForKey:MSG_DATE];
                        NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
                        dtDate = [self getDateWithDayMonthYear:dtDate];
                        [dicSections removeObjectForKey:dtDate];
                        [arrDatesSorted removeObject:dtDate];
                    }
                    else {
                        [msgList removeObjectAtIndex:index];
                    }
                    [self.chatView reloadData];
                }
            }
        }
        else
        {
            //- Network failure case.
            BOOL isReloadRequired = NO;
            NSArray* allDateKeys = [dicSections allKeys];
            for(NSDate* dtDate in allDateKeys) {
                NSArray* msgList = [dicSections objectForKey:dtDate];
                for(NSMutableDictionary* msgData in msgList)
                {
                    if(![[msgData valueForKey:MSG_STATE]isEqualToString:API_DELIVERED])
                    {
                        [msgData setValue:API_NETUNAVAILABLE forKey:MSG_STATE];
                        isReloadRequired = YES;
                    }
                }
            }
            if(isReloadRequired)
            {
                [self.chatView reloadData];
                KLog(@"Send Text Reload done.");
            }
        }
    }
}

-(void)processResponseFromServer:(NSMutableDictionary*)resultDic forEventType:(int)eventType
{
    KLog(@"### processResponseFromServer - START");

    NSMutableArray* newMsgList = [[NSMutableArray alloc]init];
    
    BOOL reloadRequired = NO;
    if(eventType == SEND_MSG)
    {
        NSMutableDictionary* sendMsgResp = [resultDic valueForKey:RESPONSE_DATA];

        newMsgList = [sendMsgResp valueForKey:@"MSG_LIST_FROM_SERVER"];
        
        NSMutableDictionary* reqstDic = [sendMsgResp valueForKey:@"MSG_SENT_BY_USER"];
        NSString* msgGuid = [reqstDic valueForKey:MSG_GUID];
        
        NSNumber* nuDate = [reqstDic valueForKey:MSG_DATE];
        NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
        [self getDateWithDayMonthYear:dtDate];
        NSMutableArray* msgList = [dicSections objectForKey:dtDate];
        
        //Find sent msg in conversation list and new msg list from server based on guid.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.MSG_GUID == %@", msgGuid];
        NSArray* sentMsgFromClient = [msgList filteredArrayUsingPredicate:predicate];
        NSArray* sentMsgFromServer = [newMsgList filteredArrayUsingPredicate:predicate];
        
        if(sentMsgFromClient.count > 0 && sentMsgFromServer.count > 0)
        {
            reloadRequired = YES;
            //user has not changed the tile. Filter the message from conversation list.
            //sentMsgFromClient may contain duplicate objects.
            for(NSDictionary* dic in sentMsgFromClient)
                [msgList removeObject:dic];

        } else {
            if(!sentMsgFromClient.count) {
                KLog(@"ERROR: sentMsgFromClient is null");
            }
            else {
                KLog(@"ERROR: sentMsgFromServer is null");
            }
        }
    }
    else
    {
        newMsgList = [resultDic valueForKey:RESPONSE_DATA];
    }
    
    for(NSMutableDictionary* msgDic in newMsgList)
    {
        NSString* msgType = [msgDic valueForKey:MSG_TYPE];
        if(![msgType isEqualToString:NOTES_TYPE]) {
            KLog(@"Not notes-type");
            continue;
        }
        
        //check if message already exist in the list.
        NSInteger respMsgID = [[msgDic valueForKey:MSG_ID]integerValue];
        
        NSNumber* nuDate = [msgDic valueForKey:MSG_DATE];
        NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
        dtDate = [self getDateWithDayMonthYear:dtDate];
        NSMutableArray* msgList = [dicSections objectForKey:dtDate];
        
        bool bAddANewMsg = true;
        for(NSMutableDictionary* msg in msgList)
        {
            NSInteger msgID = [[msg valueForKey:MSG_ID]integerValue];
            if(msgID == respMsgID) {
                NSString* msgContentTypeInDataSrc = [msg valueForKey:MSG_CONTENT_TYPE];
                NSString* msgContentInDataSrc = [msg valueForKey:MSG_CONTENT];
                NSString* msgContentInResp = [msgDic valueForKey:MSG_CONTENT];
                NSString* msgLocationName = [msgDic valueForKey:LOCATION_NAME];
                
                if(msgLocationName.length && ([msgContentTypeInDataSrc isEqualToString:TEXT_TYPE] ||
                                              [msgContentTypeInDataSrc isEqualToString:AUDIO_TYPE] ||
                                              [msgContentTypeInDataSrc isEqualToString:IMAGE_TYPE]) ) {
                    [msg setValue:msgLocationName forKey:LOCATION_NAME];
                    [self loadData];
                }
                
                if([msgContentTypeInDataSrc isEqualToString:TEXT_TYPE] &&
                   ([msgContentInResp length] > [msgContentInDataSrc length])) {
                    [msg setValue:msgContentInResp forKey:MSG_CONTENT];
                }
                
                bAddANewMsg=false;
                break;
            }
        }
        if(bAddANewMsg) {
            NSMutableArray* newMsg = [[NSMutableArray alloc]init];
            [newMsg addObject:msgDic];
            [self prepareDataSourceFromMessages:newMsg withInsertion:NO MsgType:eNewMessage];
            //NSLog(@"*** processResponseFromServer");
            reloadRequired = YES;
        }
    }
    if(reloadRequired)
    {
        [self loadData];
        
        if(!(eventType == SEND_MSG && newMsgList.count == 1))
            [self scrollToBottom];
        KLog(@"Send/Fetch Text Reload done.");
    } else {
        KLog(@"ERROR: reloadRequired is false");
    }
    
    KLog(@"### processResponseFromServer - END");
}

-(NSInteger)setNotesCount
{
    NSArray* arrAllDateKeys = [dicSections allKeys];
    NSInteger count = 0;
    NSArray* msgList = nil;
    //NSLog(@"*** keys = %ld, sections = %ld",[arrAllDateKeys count], [dicSections count]);
    for(NSDate* dtDate in arrAllDateKeys) {
        msgList = [dicSections objectForKey:dtDate];
        count += [msgList count];
    }
    
    NSString *title = [NSLocalizedString(@"Notes ", nil)stringByAppendingString:[NSString stringWithFormat:@"(%ld)",count]];
    self.title = title;
    
    return count;
}

-(void)audioModeTapped:(id)sender
{
    if( [Audio isHeadsetPluggedIn]) {
        EnLogd(@"Headset plugged-in. No mode change.");
        KLog(@"Headset plugged-in. No mode change.");
        return;
    }
    
    if(_speakerMode) {
        //turns the speaker off
        EnLogd(@"Speaker Off");
        
        [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-closed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
        [self.enableSpeakerButton setTintColor:[IVColors grayOutlineColor]];
        
        _speakerMode = false;
        [appDelegate.confgReader setVolumeMode:CALLER_MODE];
        [self.audioObj setVolume:CALLER_MODE];
    }
    else {
        //turns the speaker on
        EnLogd(@"Speaker On");
        
        [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-closed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
        [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.enableSpeakerButton setTintColor:[IVColors redColor]];
        
        _speakerMode = true;
        [appDelegate.confgReader setVolumeMode:SPEAKER_MODE];
        [self.audioObj setVolume:SPEAKER_MODE];
    }
}

-(void)markReadMessagesFromThisList:(NSArray *)list
{
    KLog(@"*** NO IMPL");
}

//Clean Up Methods
-(void)dealloc
{
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}
@end
