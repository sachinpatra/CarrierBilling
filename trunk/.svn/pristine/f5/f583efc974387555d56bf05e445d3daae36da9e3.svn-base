//
//  ConversationScreen.m
//  InstaVoice
//
//  Created by Eninov on 13/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "BaseConversationScreen.h"
#import "CircleProgressView.h"
#import "TableColumns.h"
#import "Common.h"
#import "EventType.h"
#import "HttpConstant.h"
#import "UIType.h"
#import "Logger.h"
#import "SizeMacro.h"
#import <QuartzCore/QuartzCore.h>
#import "Setting.h"
#import "Contacts.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "ContactSyncUtility.h"
#import "IVMediaDisplayViewController.h"
#import "IVMediaSendingViewController.h"
#import "IVFileLocator.h"
#import "ChatActivity.h"
#import "IVMediaZoomDisplayViewController.h"
#import "IVImageUtility.h"
#import "IVColors.h"
#import "ConversationTableCellMissedCallReceiver.h"
#import "Logger.h"
#import <CoreTelephony/CTCall.h>
#import "MyNotesScreen.h"
#import <sys/utsname.h>
#import "CustomAlbum.h"
#import "IVMediaLoader.h"
#ifdef REACHME_APP
#import "PhoneViewController.h"
#import "ConversationTableCellReachMeCallSender.h"
#endif

#ifdef TRANSCRIPTION_ENABLED
#import "TranscriptionAPI.h"
#import "MQTTReceivedData.h"
#import "TranscriptionRatingAPI.h"
#ifdef REACHME_APP
    #import "ReachMe-Swift.h"
#else
    #import "InstaVoice-Swift.h"
#endif
#endif

#define CUSTOMALBUM                 @"InstaVoice"
#define actionSheetTag 189
#define alertViewTag 190
#define alertControllerTag 179

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define MIN_WIDTH                   110  // in pixel
#define UNIT_WIDTH                  1.7  // in pixel
#define MAX_WIDTH                   290  // in pixel
#define BUTTON_LEFT_MARGIN          5.0
#define TITLE                       @"title"
#define IMAGE                       @"image"
#define PENDING_MSG_COUNT           50

#define INT_9                       9
#define INT_60                      60
#define MAX_TEXT_SIZE               8000
#define MAX_TEXT_SIZE_NON_IV        90
#define BUTTON_SPACING              10.0

#define DEFAULT_MAX_DURATION        120

#define SECTION_HEIGHT      30.0
#define SECTION_WIDTH       90.0
#define SECTION_BG_COLOR    0xebebeb
#define SECTION_TITLE_COLOR 0x5c5c5c

#define TOOLBAR_XPOS                       0.0
#define TOOLBAR_YPOS                       0.0
#define TOOLBAR_WIDTH                      DEVICE_WIDTH
#define TOOLBAR_HEIGHT                     45.0
#define CONTAINERVIEW_XPOS                 0.0
#define CONTAINERVIEW_YPOS                 0.0
#define CONTAINERVIEW_WIDTH                DEVICE_WIDTH
#define CONTAINERVIEW_HEIGHT               45.0
#define TEXTVIEW_XPOS                      8.0
#define TEXTVIEW_YPOS                      7.0
#define TEXTVIEW_WIDTH_WITH_TEXT           (DEVICE_WIDTH - 55.0)
#define TEXTVIEW_WIDTH_WITHOUT_TEXT        (DEVICE_WIDTH - 135.0)
#define TEXTVIEW_CONSTANT_HEIGHT           31.0
#define MAX_TEXTVIEW_HEIGHT                (DEVICE_HEIGHT - 405.0)
#define MIC_BUTTON_VIEW_LEADING_SPACE      18.0
#define MIC_BUTTON_VIEW_XPOS               (TEXTVIEW_WIDTH_WITHOUT_TEXT + MIC_BUTTON_VIEW_LEADING_SPACE)
#define MIC_BUTTON_VIEW_YPOS               6.0
#define MIC_BUTTON_VIEW_WIDTH              33.0
#define MIC_BUTTON_VIEW_HEIGHT             33.0

#define DELTA_WIDTH  ((DEVICE_WIDTH - 140)/DEVICE_WIDTH)

typedef NS_ENUM(NSUInteger,MessageType){
    eTextMessage = 0,
    eAudioMessage,
    eImageMessage,
    eMissedCall,
    eVoiceMail,
    eVoipCall
};


@interface BaseConversationScreen ()<IVMediaSendingViewControllerDelegate,UIActionSheetDelegate, EZMicrophoneDelegate, ConversationDelegate, FriendInviteListProtocol, UITextInputDelegate>{
    NSLayoutConstraint *bottomAnchor;
#ifdef TRANSCRIPTION_ENABLED
    UIImageView *starView1,*starView2,*starView3,*starView4,*starView5;
    UIViewController *tempViewController;
    UIAlertAction *submit;
    int transRating;
#endif
}

@property (strong, nonatomic) IBOutlet EZAudioPlot *audioPlot;
@property (nonatomic) EZMicrophone *microphone;
@property (nonatomic, assign) MessageType messageType;
@property (weak, nonatomic) IBOutlet UIView *sharingMenuView;
@property (weak, nonatomic) IBOutlet UIView *sharingSocialNetworkView;
@property (nonatomic, assign) BOOL isVoboloPage;
@property (weak, nonatomic) IBOutlet UIButton *shareInVoboloBtn;
@property (weak, nonatomic) IBOutlet UILabel *shareInVoboloLabel;
@property (nonatomic, strong) UITableViewCell *selectedCell;
@property (nonatomic, assign) NSInteger popoverSelectedRow;
//@property (nonatomic, strong) UIAlertController *actionSheet;
@property (nonatomic, strong) UIAlertController *alertViewController;
@end

@implementation CustomView{
    
}

-(CGSize )intrinsicContentSize{
    return CGSizeZero;
}

@end

@implementation BaseConversationScreen
{
    NSInteger selectedRow;
    NSDictionary *keyInfo;
    
    //May 2017
    CGFloat lhtCaption2;
    CGFloat lhtBody;
    CGFloat ptSizeFootnote;
    //
    
    UITextView *msgLabel;
    
    CGFloat maxTextViewHeight;
    BOOL isiPhoneX;
}

@synthesize  msgType;
@synthesize  audioObj;
@synthesize  voiceDic;
@synthesize  chatView, shareMenuSelectedCell;


#pragma mark --  BaseConversationScreen Screen setup
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        drawStripTimer      = Nil;    //This is used to draw overlapping strip
        activeIndexChatView = nil;    //index of chat row which is in action
        voiceCellView       = nil;    //Last clicked voice cell
        circleDraw          = nil;    //View responsbile for animation
        recorderTimer       = nil;    //Circle Timer
        buttonTag           = [NSIndexPath indexPathForRow:-1 inSection:0];  //Played recording button tag
        audioObj            = nil;    //Audio class object
        timerLabel.text     = @"00:00";//Label of circle
        currentChatUserInfo = nil;     //Current chat user dictinary
        isRecordPause       = FALSE;
        _allowMessaging = TRUE;
        _beginRefreshingOldMessages = false;
		self.hidesBottomBarWhenPushed = YES;
        _shareFriendsListVC = nil;
        selectedRow = 0;
    }
    return self;
}

-(void)createInputAccessoryView
{
    containerView = [[CustomView alloc] init];
    containerView.frame = CGRectMake(CONTAINERVIEW_XPOS, CONTAINERVIEW_YPOS, CONTAINERVIEW_WIDTH, CONTAINERVIEW_HEIGHT);
    containerView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0f];
    
    text1 = [[UITextView alloc]initWithFrame:CGRectMake(TEXTVIEW_XPOS, TEXTVIEW_YPOS, TEXTVIEW_WIDTH_WITHOUT_TEXT, TEXTVIEW_CONSTANT_HEIGHT)];
    text1.scrollEnabled = NO;
    text1.layer.cornerRadius = 6.0;
    text1.layer.masksToBounds = YES;
    text1.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    text1.layer.borderColor = [UIColor colorWithWhite:.8 alpha:1].CGColor;
    text1.layer.borderWidth = SIZE_1;
    text1.delegate = self;
    [text1 setTintColor:[UIColor blackColor]];
    text1.enablesReturnKeyAutomatically = YES;
    text1.backgroundColor = [UIColor whiteColor];
    [text1 becomeFirstResponder];
    
    micButtonView1 = [[UIView alloc]initWithFrame:CGRectMake(MIC_BUTTON_VIEW_XPOS, MIC_BUTTON_VIEW_YPOS, MIC_BUTTON_VIEW_WIDTH, MIC_BUTTON_VIEW_HEIGHT)];
    micButton1 = [[UIButton alloc]initWithFrame:CGRectMake(2.0, 1.0, 30.0, 30.0)];
    [micButton1 setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
    [micButton1 addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchDown];
    [micButtonView1 addSubview:micButton1];
    
    recordingArea1 = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, 45.0)];
    recordingArea1.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0f];
    
    swipeToCancelLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(46.0, 12.0, 126.0, 21.0)];
    swipeToCancelLabel1.text = @"Swipe to Cancel";
    swipeToCancelLabel1.textColor = [UIColor lightGrayColor];
    swipeToCancelLabel1.hidden = YES;
    
    cancelVoiceBtn1 = [[UIButton alloc]initWithFrame:CGRectMake(8.0, 7.0, 30.0, 30.0)];
    
    sendTextButton1 = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 43.0, 0.0, 40.0, 40.0)];
    [sendTextButton1 setImage:[UIImage imageNamed:@"sendMsg"] forState:UIControlStateNormal];
    sendTextButton1.hidden = YES;
    [sendTextButton1 addTarget:self action:@selector(sendText:) forControlEvents:UIControlEventTouchUpInside];
    
    sendImageGalleryButton1 = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - sendTextButton1.frame.size.width - 41.0, 6.0, 33.0, 33.0)];
    [sendImageGalleryButton1 setImage:[UIImage imageNamed:@"attachment"] forState:UIControlStateNormal];
    [sendImageGalleryButton1 addTarget:self action:@selector(shareImageClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    sendImageCameraButton1 = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 43.0, 6.0, 33.0, 33.0)];
    [sendImageCameraButton1 setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [sendImageCameraButton1 addTarget:self action:@selector(captureImageClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    sendTextButton1.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    micButtonView1.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    recordingArea1.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    [recordingArea1 addSubview:swipeToCancelLabel1];
    [recordingArea1 addSubview:cancelVoiceBtn1];
    [recordingArea1 addSubview:sendTextButton1];
    [recordingArea1 addSubview:sendImageGalleryButton1];
    [recordingArea1 addSubview:sendImageCameraButton1];
    
    [containerView addSubview:recordingArea1];
    [containerView addSubview:text1];
    [containerView addSubview:micButtonView1];
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    cancelVoiceBtn1.hidden = YES;
    swipeToCancelLabel1.hidden = YES;
    cancelVoiceBtn1.backgroundColor =[UIColor clearColor];
    
    cancelVoiceBtn1.tintColor = [UIColor lightGrayColor];
    [cancelVoiceBtn1 setImage:[[UIImage imageNamed:@"longpress-delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [cancelVoiceBtn1 setImage:[[UIImage imageNamed:@"longpress-delete-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    
    [cancelVoiceBtn1 addTarget:self action:@selector(stopRecordingTimer) forControlEvents:UIControlEventTouchUpInside];
    
    [micButton1 setImage:[UIImage imageNamed:IMG_MIC] forState:UIControlStateNormal];
    [micButton1 addTarget:self action:@selector(sendRecording) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat bottomPadding;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        bottomPadding = window.safeAreaInsets.bottom;
    }else{
        bottomPadding = 0.0f;
    }
    bottomAnchor = [containerView.bottomAnchor constraintEqualToAnchor:self.inputAccessoryView.layoutMarginsGuide.bottomAnchor constant:bottomPadding];
    bottomAnchor.active = YES;
    
    [text1.bottomAnchor constraintEqualToAnchor:containerView.layoutMarginsGuide.bottomAnchor constant:-8.0].active = YES;
    //KLog(@"createInputAccessoryView - END");
}

-(UIView *) inputAccessoryView {
    return containerView;
}

-(BOOL) canBecomeFirstResponder {
    return YES;
}

- (void)createAlbum
{
    [CustomAlbum makeAlbumWithTitle:CUSTOMALBUM onSuccess:^(NSString *AlbumId)
     {
         KLog(@"Album Created");
     }onError:^(NSError *error) {
         
     }];
}

-(void) viewDidLoad
{
    KLog(@"### viewDidLoad - START");
    
    [super viewDidLoad];
    
    //Bhaskar --> single time allocation for heightForRowAtIndexpath
    msgLabel = [[UITextView alloc] init];
    
    if ([[UIScreen mainScreen] bounds].size.height > 800){
        maxTextViewHeight = DEVICE_HEIGHT - 570.0;
        isiPhoneX = YES;
    }else{
        maxTextViewHeight = DEVICE_HEIGHT - 405.0;
        isiPhoneX = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarFrameChanged:)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    isPasteDone = NO;
    hasExpanded = NO;
    keyboardHide = NO;
    
    [self createInputAccessoryView];
    [self handFreeRecording];
    [self setUserSetting];
    if(_displayLoc)
    {
        [self getLocationPermission];
    }
    
    _isAlertPresent = FALSE;
    
    //MAR 29, 2017 panRecognizer.enabled = NO;
    [self setupGestureRecognizerInTableAndMic];
    
    /*--- setting delegates and data-source for chatView ----
    chatView.dataSource =   self;
    chatView.delegate   = self;
     */
    
    //self.automaticallyAdjustsScrollViewInsets = NO;
    msgTextLabel.hidden = YES;
    
    int mode = [appDelegate.confgReader getVolumeMode];
    _speakerMode = true;
    if(mode == CALLER_MODE) {
        _speakerMode = false;
    }
    
    //AVN_TO_DO_IMAGES
    UINib* nibRec = [UINib nibWithNibName:@"ConversationTableCellImageReceiver" bundle:nil];
    [chatView registerNib:nibRec forCellReuseIdentifier:@"ConversationTableCellImageReceiver"];
    UINib* nibSend = [UINib nibWithNibName:@"ConversationTableCellImageSender" bundle:nil];
    [chatView registerNib:nibSend forCellReuseIdentifier:@"ConversationTableCellImageSender"];
    
    UINib* nibGroupInfo = [UINib nibWithNibName:@"GroupChatEventCell" bundle:nil];
    [chatView registerNib:nibGroupInfo forCellReuseIdentifier:@"GroupChatEventCell"];
    
    UINib* nibMCRec = [UINib nibWithNibName:@"ConversationTableCellMissedCallReceiver" bundle:nil];
    [chatView registerNib:nibMCRec forCellReuseIdentifier:@"ConversationTableCellMissedCallReceiver"];
    UINib* nibMCSend = [UINib nibWithNibName:@"ConversationTableCellMissedCallSender" bundle:nil];
    [chatView registerNib:nibMCSend forCellReuseIdentifier:@"ConversationTableCellMissedCallSender"];
    
    UINib* nibRingMCRec = [UINib nibWithNibName:@"ConversationTableCellRingMCReceiver" bundle:nil];
    [chatView registerNib:nibRingMCRec forCellReuseIdentifier:@"ConversationTableCellRingMCReceiver"];
    UINib* nibRingMCSend = [UINib nibWithNibName:@"ConversationTableCellRingMCSender" bundle:nil];
    [chatView registerNib:nibRingMCSend forCellReuseIdentifier:@"ConversationTableCellRingMCSender"];
    
    UINib* nibVMRec = [UINib nibWithNibName:@"ConversationTableCellVMailReceived" bundle:nil];
    [chatView registerNib:nibVMRec forCellReuseIdentifier:@"ConversationTableCellVMailReceived"];
    UINib* nibVMRecNoTrans = [UINib nibWithNibName:@"ConversationTableCellVMailReceivedNoTrans" bundle:nil];
    [chatView registerNib:nibVMRecNoTrans forCellReuseIdentifier:@"ConversationTableCellVMailReceivedNoTrans"];
    
    UINib* nibVMSend = [UINib nibWithNibName:@"ConversationTableCellVMailSent" bundle:nil];
    [chatView registerNib:nibVMSend forCellReuseIdentifier:@"ConversationTableCellVMailSent"];
    
    UINib* nibVMSendNoTrans = [UINib nibWithNibName:@"ConversationTableCellVMailSentNoTrans" bundle:nil];
    [chatView registerNib:nibVMSendNoTrans forCellReuseIdentifier:@"ConversationTableCellVMailSentNoTrans"];
    
    UINib* nibAuRec = [UINib nibWithNibName:@"ConversationTableCellAudioReceived" bundle:nil];
    [chatView registerNib:nibAuRec forCellReuseIdentifier:@"ConversationTableCellAudioReceived"];
    
    UINib* nibAuSend = [UINib nibWithNibName:@"ConversationTableCellAudioSent" bundle:nil];
    [chatView registerNib:nibAuSend forCellReuseIdentifier:@"ConversationTableCellAudioSent"];
    
    UINib* nibReachMeRec = [UINib nibWithNibName:@"ConversationTableCellReachMeCallReceiver" bundle:nil];
    [chatView registerNib:nibReachMeRec forCellReuseIdentifier:@"ConversationTableCellReachMeCallReceiver"];
    
    UINib* nibReachMeSender = [UINib nibWithNibName:@"ConversationTableCellReachMeCallSender" bundle:nil];
    [chatView registerNib:nibReachMeSender forCellReuseIdentifier:@"ConversationTableCellReachMeCallSender"];
    
#ifdef TRANSCRIPTION_ENABLED
    UINib* nibAuSendTrans = [UINib nibWithNibName:@"ConversationTableCellAudioSentTrans" bundle:nil];
    [chatView registerNib:nibAuSendTrans forCellReuseIdentifier:@"ConversationTableCellAudioSentTrans"];
    
    UINib* nibAuReceivedTrans = [UINib nibWithNibName:@"ConversationTableCellAudioReceivedTrans" bundle:nil];
    [chatView registerNib:nibAuReceivedTrans forCellReuseIdentifier:@"ConversationTableCellAudioReceivedTrans"];
#endif
    
    self.hidesBottomBarWhenPushed = YES;
	self.automaticallyAdjustsScrollViewInsets = NO;
    
    circleSubView.layer.cornerRadius = circleSubView.frame.size.width / 2;

    // set up the ez microphone stuff
    self.audioPlot.backgroundColor = [UIColor clearColor];
    self.audioPlot.color = [UIColor colorWithWhite:1 alpha:.8];
    self.audioPlot.plotType = EZPlotTypeBuffer;
    
    self.sharingSocialNetworkView.layer.borderColor = [IVColors lightGreyColor].CGColor;
    self.sharingSocialNetworkView.layer.borderWidth = 1;
    self.sharingSocialNetworkView.layer.cornerRadius = 10;
    self.sharingSocialNetworkView.clipsToBounds = YES;
    
    self.sharingMenuView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appEnterIntoActive:)
                                                name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.chatView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.chatView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
    self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 45, 0);
    
    chatView.bounces = YES;
    chatView.rowHeight = UITableViewAutomaticDimension;
    chatView.estimatedRowHeight = 104.0;//average cell hight
    
    lhtCaption2 = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2].lineHeight;
    lhtBody = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody].lineHeight;
    ptSizeFootnote  = [Common preferredFontForTextStyleInApp:UIFontTextStyleFootnote].pointSize;
    
    self.actionSheet = nil;
    KLog(@"### viewDidLoad - END");
}

-(void)createAudioObj {
    
    KLog(@"createAudioObj");
    audioObj = nil;
    audioObj = [[Audio alloc]init];
    audioObj.delegate = self;
    [audioObj addObserverForAudioRouteChange];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    
    [self dismissActiveAlertController];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    //KLog(@"### keyboardWillShow - START");
    
    isKeyboardPresent = YES;
    keyboardHide = NO;
    height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    keyInfo = [notification userInfo];
    
    NSString * remoteUserType = [currentChatUserInfo valueForKey:REMOTE_USER_TYPE];
    if([remoteUserType isEqualToString:CELEBRITY_TYPE] && !_allowMessaging) {
        self.chatView.contentInset = UIEdgeInsetsZero;
        self.chatView.scrollIndicatorInsets = UIEdgeInsetsZero;
        return;
    }
    
    CGRect keyboardFrame = [[keyInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    keyboardFrame = [self.chatView convertRect:keyboardFrame fromView:nil];
    CGRect intersect = CGRectIntersection(keyboardFrame, self.chatView.bounds);
    
    CGFloat bottomPadding;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        bottomPadding = window.safeAreaInsets.bottom;
    }else{
        bottomPadding = 0.0f;
    }
    
    if(roundf(intersect.size.height) != height && !CGRectIsNull(intersect) && isScrolling) {
        bottomAnchor.constant = 0.0;
        return;
    }else{
        bottomAnchor.constant = bottomPadding;
    }
    
    if (!CGRectIsNull(intersect)) {
        if([arrDatesSorted count]) {
            CGFloat tableViewHeight = chatView.frame.size.height;
            CGFloat contentOffsetY = chatView.contentOffset.y;
            CGFloat distanceFromBottom = chatView.contentSize.height - contentOffsetY + text1.frame.size.height + 14.0;
            
            NSDate* dtDate = [arrDatesSorted objectAtIndex:[arrDatesSorted count]-1];
            NSArray* msgList = [dicSections objectForKey:dtDate];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgList count]-1 inSection:[arrDatesSorted count]-1];
            
            CGRect rowHeight = [self.chatView rectForRowAtIndexPath:indexPath];
            CGFloat lastRowHeight = rowHeight.size.height;
            
            if(distanceFromBottom < tableViewHeight + lastRowHeight)
            {
                [UIView animateWithDuration:0.15 animations:^{
                    self.chatView.contentInset = UIEdgeInsetsMake(0.0, 0.0,(height == 0.0?45.0:height) - (isiPhoneX?35.0:0.0), 0.0);
                    self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, (height == 0?45.0:height) - (isiPhoneX?35.0:0.0), 0.0);
                    
                    CGPoint pointsFromTop = CGPointMake(0.0, chatView.contentSize.height - chatView.frame.size.height + (height == 0.0?45.0:height));
                    
                    if(pointsFromTop.y >= 45.0)
                        [chatView setContentOffset:pointsFromTop];
                    
                    //[self scrollToBottom];
                }];
            }
            else {
                [UIView animateWithDuration:0.15 animations:^{
                    self.chatView.contentInset = UIEdgeInsetsMake(0.0, 0.0, height - (isiPhoneX?35.0:0.0), 0.0);
                    self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, height - (isiPhoneX?35.0:0.0), 0.0);
                    NSArray *visibleRows = [chatView indexPathsForVisibleRows];
                    NSIndexPath *lastRow = [visibleRows lastObject];
                    if (lastRow.row == indexPath.row) {
                        CGPoint pointsFromTop = CGPointMake(0.0, chatView.contentSize.height - chatView.frame.size.height + (height == 0.0?45.0:height));
                        
                        if(pointsFromTop.y >= 45.0)
                            [chatView setContentOffset:pointsFromTop];
                    }
                }];
            }
        }
    }
    
    //KLog(@"### keyboardWillShow - END");
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    keyboardHide = YES;
    [UIView animateWithDuration:0.15 animations:^{
        self.chatView.contentInset = UIEdgeInsetsMake(0, 0, text1.frame.size.height + 14.0, 0);
        self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, text1.frame.size.height + 14.0, 0);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    KLog(@"### viewDidAppear - START");
    
    [super viewDidAppear:animated];
    
    NSString * remoteUserType = [currentChatUserInfo valueForKey:REMOTE_USER_TYPE];
    if([remoteUserType isEqualToString:CELEBRITY_TYPE] && !_allowMessaging) {
        self.chatView.contentInset = UIEdgeInsetsZero;
        self.chatView.scrollIndicatorInsets = UIEdgeInsetsZero;
        return;
    }
    
    [self becomeFirstResponder];
    
    if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] && self.uiType != MY_VOBOLO_SCREEN)
    {
        /*
        if (!isVoicemailHelpSent) {
            isVoicemailHelpSent = YES;
            NSString* helpText = [currentChatUserInfo valueForKey:@"HELP_TEXT"];
            
            if(helpText && [helpText length]) {
                if(MY_VOBOLO_SCREEN == self.uiType) {
                    text1.text = @"";
                }
                else {
                    text1.text = helpText;
                    [text1 becomeFirstResponder];
                    [self textViewFrameChange];
                }
                
                [self alignTextField:text1.text.length];
                [currentChatUserInfo setObject:@"" forKey:@"HELP_TEXT"];
            }
        }
         */
        
        NSString* helpText = [currentChatUserInfo valueForKey:@"HELP_TEXT"];
        if(helpText && [helpText length]) {
            text1.text = helpText;
            [text1 becomeFirstResponder];
            [self textViewFrameChange];
            [self alignTextField:text1.text.length];
            [currentChatUserInfo setObject:@"" forKey:@"HELP_TEXT"];
        }

        containerView.hidden = NO;
        return;
    }
#ifdef REACHME_APP
    else {
        if([[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Help"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
            containerView.hidden = NO;
        else
            containerView.hidden = YES;
    }
#endif
    
    //MAY 11, 2017
    NSMutableDictionary *lastDic = [appDelegate.engObj getLastMsgInfo:msgType];
    if(lastDic != nil)
    {
        NSString *msgContentType = [lastDic valueForKey:MSG_CONTENT_TYPE];
        if([msgContentType isEqualToString:TEXT_TYPE])
        {
            text1.text = [lastDic valueForKey:MSG_CONTENT];
            NSString *rawString = text1.text;
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
            if ([trimmed length]){
                [self textViewFrameChange];
                
            } else {
                text1.text = @"";
                [self inputAccessoryViewFrame];
            }
            
            [self alignTextField:text1.text.length];
        }
        else
        {
            audiofilePath = [lastDic valueForKey:MSG_CONTENT];
            if(audiofilePath != nil && [audiofilePath length]>0)
            {
                [self performSelectorOnMainThread:@selector(alertRecording) withObject:nil waitUntilDone:NO];
            }
        }
    }
    
    //
    KLog(@"### viewDidAppear - END");
}

-(void)swipe:(UIPanGestureRecognizer *)panRecog {
    
    if (isKeyboardPresent) {
        if(panRecog.state == UIGestureRecognizerStateBegan){
            [self performSelector:@selector(resignTextResponder) withObject:nil afterDelay:0.15];
            [text1 resignFirstResponder];
        }
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    //KLog(@"###viewWillAppear - START");

    self.getHeightForRows = YES;
    /*---- create object of audio/footer view setting -----*/
    audioObj = [[Audio alloc]init];
    audioObj.delegate = self;
    
    appDelegate.tabBarController.tabBar.hidden = YES;
    
    [super viewWillAppear:animated];
    isPasteDone = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self registerForKeyboardNotifications];
    
    [audioObj addObserverForAudioRouteChange];
    tableViewFrameWhileLoading = chatView.frame;
    // TODO July 21, 2016
    UIPanGestureRecognizer *ges =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [self.view addGestureRecognizer:ges];
    //

    /*--- Create Navigation Bar View -----*/
#ifdef REACHME_APP
    /*
    if(4 == self.tabBarController.selectedIndex) {
        NSDictionary* helpChat = [[UIDataMgt sharedDataMgtObj]getHelpChat];
        currentChatUserInfo = [[NSMutableDictionary alloc]initWithDictionary:helpChat];
        [appDelegate.dataMgt setCurrentChatUser:currentChatUserInfo];
        dicSections = nil;
        arrDatesSorted = nil;
    }
    else */if(6 == self.tabBarController.selectedIndex) {
        NSDictionary* suggestionChat = [[UIDataMgt sharedDataMgtObj]getHelpChat];
        currentChatUserInfo = [[NSMutableDictionary alloc]initWithDictionary:suggestionChat];
        [appDelegate.dataMgt setCurrentChatUser:currentChatUserInfo];
        dicSections = nil;
        arrDatesSorted = nil;
    }
    else  {
        currentChatUserInfo = [[NSMutableDictionary alloc]initWithDictionary:[appDelegate.dataMgt getCurrentChatUserInfo]];
    }
#else
    currentChatUserInfo = [[NSMutableDictionary alloc]initWithDictionary:[appDelegate.dataMgt getCurrentChatUserInfo]];
#endif
    
    if(!currentChatUserInfo)
        currentChatUserInfo = [[NSMutableDictionary alloc]init];

    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* ivID = [f numberFromString:[currentChatUserInfo valueForKey:REMOTE_USER_IV_ID]];
    if( (!ivID || [ivID longLongValue] <= 0) && [[currentChatUserInfo valueForKey:CONVERSATION_TYPE] isEqualToString:GROUP_TYPE])
        _allowMessaging = TRUE;
    else
        _allowMessaging = [self isIVUser:ivID];
    
    if(MY_VOBOLO_SCREEN == self.uiType || NOTES_SCREEN == self.uiType)
        _allowMessaging = TRUE;
    
    if(_allowMessaging)
        [currentChatUserInfo setValue:@"iv" forKey:REMOTE_USER_TYPE];
    
    if (!containerView.isFirstResponder) {
        containerView.hidden = NO;
        [self becomeFirstResponder];
    }
    
    if( currentChatUserInfo &&
       ([[currentChatUserInfo valueForKey:REMOTE_USER_TYPE] isEqualToString:CELEBRITY_TYPE] || MY_VOBOLO_SCREEN == self.uiType) )
    {
        if(_refreshControl) {
            [_refreshControl removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
            _refreshControl = nil;
        }
        
        //- For Celebrity chats, hide all the micbutton, text, and recoding views
        if(!_allowMessaging) {
            containerView.hidden = YES;
            micButtonView1.hidden = YES;
            micButtonView1.alpha = 0;
            recordingView.hidden = YES;
            recordingView.alpha = 0;
            recordingArea1.hidden = YES;
            recordingArea1.alpha = 0;
            text1.hidden=YES;
        }
    }
    else {
        if(!_refreshControl) {
            _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.chatView];
            [_refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
        }
        
        //- For IV chats, unhide mic, text and recording views
        
        micButtonView1.hidden = NO;
        micButtonView1.alpha = 1;
        recordingView.hidden = NO;
        recordingArea1.hidden = NO;
        recordingArea1.alpha = 1;
        text1.hidden = NO;
        containerView.hidden = NO;
        
        [self hideRecordingView];
    }
    
    // MAY 11, 2017 For Notes Page only
    if (NOTES_SCREEN == self.uiType) {
        NSMutableDictionary *lastDic = [appDelegate.engObj getLastMsgInfo:msgType];
        if(lastDic != nil)
        {
            NSString *msgContentType = [lastDic valueForKey:MSG_CONTENT_TYPE];
            if([msgContentType isEqualToString:TEXT_TYPE])
            {
                text1.text = [lastDic valueForKey:MSG_CONTENT];
                NSString *rawString = text1.text;
                NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
                if ([trimmed length]){
                    [self textViewFrameChange];
                    
                } else {
                    text1.text = @"";
                    [self inputAccessoryViewFrame];
                }
                
                [self alignTextField:text1.text.length];
            }
            else
            {
                audiofilePath = [lastDic valueForKey:MSG_CONTENT];
                if(audiofilePath != nil && [audiofilePath length]>0)
                {
                    [self performSelectorOnMainThread:@selector(alertRecording) withObject:nil waitUntilDone:NO];
                }
            }
        }
    }
    
    self.hidesBottomBarWhenPushed = YES;
    recordingArea1.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
    
#ifndef REACHME_APP
    if (MY_VOBOLO_SCREEN == self.uiType) {
        recordingArea1.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.chatView.contentInset = UIEdgeInsetsMake(0, 0, 45.0, 0);
            self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 45.0, 0);
        }];
    }
#endif
    
    isScrolling = FALSE;
    recvdNewMsg = FALSE;
    sendNewMsg = FALSE;
    
#ifdef REACHME_APP
    containerView.hidden = YES;
#endif
    
    //KLog(@"###viewWillAppear - END");
}

-(BOOL)isIVUser:(NSNumber*)ivID
{
    if([ivID longLongValue] <= 0)
        return FALSE;
    
    NSArray* contactDetailList = [[Contacts sharedContact]getContactForIVUserId:ivID usingMainContext:YES];
    EnLogd(@"IV ID: %@",ivID);
    
    if(contactDetailList && [contactDetailList count]) {
        EnLogd(@"Contact Detail Array: %@",contactDetailList);
        ContactDetailData* detail = [contactDetailList objectAtIndex:0];
        
        ContactData* data = detail.contactIdParentRelation;
        NSSet* all = data.contactIdDetailRelation;
        BOOL isIV = [data.isIV boolValue];
        NSNumber* contactType = data.contactType;
        for(ContactDetailData* obj in all)
        {
            NSNumber* IVUserID = obj.ivUserId;
            int cType = [contactType intValue];
            if(isIV && [ivID isEqualToNumber:IVUserID] &&
               ((cType == ContactTypeMsgSyncContact || cType == ContactTypeNativeContact) ||
                cType == ContactTypeHelpSuggestion)) {
                return TRUE;
            }
        }
    }
    
    return FALSE;
}

/*
-(UILabel *)setTitleLable:(NSString *)userNameString
{
    UILabel *title= nil;
    CGSize size = {0,0};
    
    size = [userNameString sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:HELVETICANEUE_MEDIUM size:SIZE_18]}];
    
    if(size.width >= SIZE_18) {
        title = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_65,SIZE_23,SIZE_210,SIZE_30)];
    }
    else {
        title = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_75,SIZE_23,SIZE_180,SIZE_30)];
    }
    
    return title;
}
*/
 

/*
- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController] && self.uiType != MY_VOBOLO_SCREEN) {
        KLog(@"Back pressed");
    }
}*/

-(void)viewWillDisappear:(BOOL)animated
{
    //KLog(@"### viewWillDisappear START");
    [self closeBannerView:nil];
    
    recordingView.hidden = YES;
    if(audioObj.isPlay) {
        [self stopAudioPlayback];
    }
    buttonTag = [NSIndexPath indexPathForRow:-1 inSection:0];

    if(recorderTimer != nil)
    {
        [recorderTimer invalidate];
    }
    recorderTimer = nil;
    if(drawStripTimer != nil)
    {
        [drawStripTimer invalidate];
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:msgType forKey:MSG_TYPE];
    if(audioObj.isRecord || isRecordPause)
    {
        isRecordPause = FALSE;
        [dic setValue:AUDIO_TYPE forKey:MSG_CONTENT_TYPE];
        [dic setValue:[audioObj stopAndGetRecordedFilePath] forKey:MSG_CONTENT];
    }
    else
    {
        NSString *textMsg  = text1.text;
        if(textMsg != nil && [textMsg length]>0)
        {
            [dic setValue:textMsg forKey:MSG_CONTENT];
            [dic setValue:TEXT_TYPE forKey:MSG_CONTENT_TYPE];
        }
    }
    audiofilePath = nil;
    if(saveLastMsg) {
        [appDelegate.engObj setLastMsgInfo:dic];
    }

    if ([text1 isFirstResponder]) {
        [text1 resignFirstResponder];
    }
    
    if(self.uiType == INSIDE_CONVERSATION_SCREEN) {
    } else{
        if(!self.sharingMenuView.hidden) {
            self.sharingMenuView.hidden = YES;
        }
    }
    
    [audioObj removeObserverForAudioRouteChange];
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        containerView.hidden = YES;
    }
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //KLog(@"### viewWillDisappear END");
}

-(void)dealloc
{
    [self removeKeyboardNotifications];
    [self.microphone stopFetchingAudio];
    /* DEC 22, 2017
    self.microphone.delegate = nil;
    self.microphone = nil;
    */
    [dicSections removeAllObjects];
    [arrDatesSorted removeAllObjects];
    //Clean Up Methods
        
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeOverlayViewsIfAnyOnPushNotification;
{
    //Bhaskar --> no need to resign as we are resiginig in view will disappaer
    //[text1 resignFirstResponder];
    [chatView setContentOffset:chatView.contentOffset animated:NO];
    if(self.actionSheet) {
        [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
        self.actionSheet = nil;
    }
}

-(NSMutableDictionary*)getCurrentChatUserInfo {
    return currentChatUserInfo;
}

-(void)setUserSetting
{
    SettingModel* setting = [Setting sharedSetting].data;
    _maxVoiceMsgDuration = (int)setting.maxRecordTime;
    if(_maxVoiceMsgDuration == 0)
    {
        _maxVoiceMsgDuration = DEFAULT_MAX_DURATION;
    }
    
#ifndef REACHME_APP
    _displayLoc = setting.displayLocation;
#else
    _displayLoc = FALSE;
#endif
}

/*
#pragma mark Setting of Navigation bar
//Function: Type of Header view according to screen i.e Conversation/My Notes/MyVobolo
-(void)customNavigationBar
{
    _topView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0,SIZE_0, DEVICE_WIDTH, SIZE_60)];
    _topView.backgroundColor = [UIColor whiteColor];
}
*/

-(UIImageView *)setImageView
{
    UIImageView *logedInUserImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SIZE_4,SIZE_4,SIZE_32,SIZE_32)];
    logedInUserImageView.layer.cornerRadius = logedInUserImageView.frame.size.height / SIZE_2;
    logedInUserImageView.layer.masksToBounds = YES;
    logedInUserImageView.layer.borderWidth = SIZE_2;
    logedInUserImageView.layer.borderColor = (__bridge CGColorRef)([UIColor blackColor]);
    return logedInUserImageView;
}

-(UIImageView *)setImageViewGroupTitle
{
    UIImageView *logedInUserImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SIZE_3,SIZE_3,SIZE_45,SIZE_45)];
    logedInUserImageView.layer.cornerRadius = logedInUserImageView.frame.size.height / SIZE_2;
    logedInUserImageView.layer.masksToBounds = YES;
    logedInUserImageView.layer.borderWidth = SIZE_2;
    logedInUserImageView.layer.borderColor = (__bridge CGColorRef)([UIColor blackColor]);
    return logedInUserImageView;
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    if (chatView.contentSize.height > chatView.frame.size.height || [activeIndexChatView row] <= 7 || [arrDatesSorted count] <= 0)
    {
        // To fix the bug: 5345.
        // Why do we need to pass dic, since we don't need EVENT_OBJ in MyNotesScreen.m.
        // TODO_CMP: CMP, check for similar cases in the code
        if ([Common isNetworkAvailable] == NETWORK_AVAILABLE)
            _beginRefreshingOldMessages = true;
        else {
            [refreshControl endRefreshing];
            _beginRefreshingOldMessages = false;
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        }
        
        if(audioObj.isPlay) {
            KLog(@"While loading old messages and audio is being played. Pause the audio.");
            [self stopAudioPlayback];
        }
        
        buttonTag = [NSIndexPath indexPathForRow:-1 inSection:0];
        int currentUiType = [appDelegate.stateMachineObj getCurrentUIType];
        NSDictionary *dic = nil;
        
        if(VOBOLO_SCREEN != currentUiType)
        {
            if(arrDatesSorted != nil && [arrDatesSorted count]) {
                NSDate* dtDate = [arrDatesSorted objectAtIndex:0];
                NSArray* msgList = [dicSections objectForKey:dtDate];
                if(msgList.count>0)
                    dic = [msgList objectAtIndex:0];
                else
                    return;
            }
        }
        long beforeMsgId = [[dic objectForKey:MSG_ID]longLongValue];
        if(beforeMsgId > 0)
            [appDelegate.engObj fetchOlderMsgRequest:dic];
        else {
            [refreshControl endRefreshing];
            _beginRefreshingOldMessages = false;
        }
    }
    else {
        [refreshControl endRefreshing];
        _beginRefreshingOldMessages = false;
    }
}

#pragma mark Function call when app goes down
-(void)pausePlayingAction
{
    if(drawStripTimer != nil)
    {
        [drawStripTimer invalidate];
    }
    [self stopAudioPlayback];
    buttonTag = [NSIndexPath indexPathForRow:-1 inSection:0];
}

-(void)pauseRecording
{
    [imageTime invalidate];
    imageTime = nil;
    [recorderTimer invalidate];
    recorderTimer = nil;
    [audioObj pauseRecording];
}

-(void)alertRecording
{
    if(!_isAlertPresent)
    {
        if(self.uiType==NOTES_SCREEN)
        {
            recordAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REC_INTERUPT_TITLE",nil) message:NSLocalizedString(@"SEND_CONFIRMATION_TEXT_NOTES",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL",nil) otherButtonTitles:@"Save", nil];
            
            recordAlertView.delegate= self;
            [recordAlertView show];
            _isAlertPresent = TRUE;
        }
        else {
            recordAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REC_INTERUPT_TITLE",nil) message:NSLocalizedString(@"SEND_CONFIRMATION_TEXT",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL",nil) otherButtonTitles:NSLocalizedString(@"SEND",nil), nil];
            
            recordAlertView.delegate= self;
            [recordAlertView show];
            _isAlertPresent = TRUE;
        }
    }
}

- (void)appStoreConnectToChannels:(UITapGestureRecognizer *)reco
{
    NSString *iTunesLink = @"https://itunes.apple.com/in/app/instavoice-channels/id1172837044?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

- (IBAction)appstoreConnect:(id)sender {
    NSString *iTunesLink = @"https://itunes.apple.com/in/app/instavoice-channels/id1172837044?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

- (IBAction)closeBannerView:(id)sender {
    
    if (self.uiType == MY_VOBOLO_SCREEN)
        containerView.hidden = NO;
    
    self.channelsBannerView.hidden = YES;
    self.bannerBackGroundView.hidden = YES;
    statusBarView.hidden = YES;
}

-(NSString*)getTextFieldValue
{
    return text1.text;
}

-(void)removeTextFromTheTextField
{
    [text1 setText:nil];
}

-(void)hideRecordingView
{
    KLog(@"### hideRecordingView - START");
    circleDraw.endAngle =  SIZE_0;
    circleDraw.startAngle =  SIZE_0;
    [chatView setUserInteractionEnabled:YES];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [timerLabel removeFromSuperview];
    timerLabel = nil;
    
    cancelVoiceBtn1.hidden = YES;
    swipeToCancelLabel1.hidden = YES;
    
    recordingView.hidden = YES;
    [recorderTimer invalidate];
    recorderTimer = nil;
    [imageTime invalidate];
    imageTime = nil;
    
    micButtonView1.hidden = NO;
    micButtonView1.alpha = 1;
    
    [self alignTextField:text1.text.length];
    [self alignVoiceRecordingBarStarted:NO];
    
    KLog(@"### hideRecordingView - END");
}

-(void)setIsRecordingPause:(BOOL)value
{
    isRecordPause = value;
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
            case FORWARD_MSG:
            {
                if([respCode isEqualToString:ENG_SUCCESS])
                {
                    NSDictionary *respDic = [resultDic valueForKey:RESPONSE_DATA];
                    NSString *msgString = [respDic valueForKey:ALERT_SHARE_MSG];
                    [ScreenUtility showAlert:msgString];
                    NSNumber* nuDate = [respDic valueForKey:MSG_DATE];
                    NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
                    dtDate = [self getDateWithDayMonthYear:dtDate];
                    NSArray* msgList = [dicSections objectForKey:dtDate];
                    
                    if(msgList != nil && [msgList count] > 0)
                    {
                        NSNumber* msgId = [respDic valueForKey:MSG_ID];
                        if(msgId.longValue > 0)
                        {
                            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID == %@", msgId];
                            NSArray* resMsgList = [msgList filteredArrayUsingPredicate:predicate];
                            if(msgList.count)
                            {
                                NSMutableDictionary* dic = resMsgList[0];
                                [dic setObject:[NSNumber numberWithBool:YES] forKey:MSG_FORWARD];
                                [chatView reloadData];
                            }
                        }
                    }
                    else
                    {
                        //TODO alert error message to the user
                        //[self unloadData];
                    }
                }
                break;
            }
                
            case CHAT_ACTIVITY:
            {
                self.navigationController.navigationBar.userInteractionEnabled = YES;
                if([respCode isEqual:ENG_SUCCESS])
                {
                    ChatActivityData* activity = [resultDic valueForKey:RESPONSE_DATA];
                    switch (activity.activityType) {
                        case ChatActivityTypeWithdraw:
                        {
                            NSInteger msgId = activity.msgId;
                            NSNumber* dateInMs = [activity.dic valueForKey:MSG_DATE];
                            NSDate* msgDate = [self getDateFromMilliSeconds:dateInMs];
                            NSMutableArray* msgList = [dicSections objectForKey:msgDate];
                            
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID == %d", msgId];
                            NSArray *filteredConversationList = [msgList filteredArrayUsingPredicate:predicate];
                            
                            if([filteredConversationList count]>0) {
                                NSMutableDictionary* selectedDic = [filteredConversationList objectAtIndex:0];
                                [selectedDic setValue:MSG_WITHDRAWN_TEXT forKey:MSG_CONTENT];
                                [selectedDic setValue:API_WITHDRAWN forKey:MSG_STATE];
                                [selectedDic setValue:TEXT_TYPE forKey:MSG_CONTENT_TYPE];
                                [selectedDic setValue:IV_TYPE forKey:MSG_TYPE];
                                [selectedDic setValue:@"" forKey:MSG_SUB_TYPE];
                                [self loadData];
                            }
                            break;
                        }
                            
                        case ChatActivityTypeDelete:
                        {
                            /*TODO: this causes a crash; so "deleteMessageFromDatasource" method will be called when user taps "Delete".
                             Instead of waiting for server response client should delete the message from local database.
                             
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
                            }
                             
                            [self.chatView reloadData];
                            //[self loadData];
                            */
                            
                            break;
                        }
                            
                        case ChatActivityTypeLike:
                        {
                            NSNumber* dateInMs = [activity.dic valueForKey:MSG_DATE];
                            NSDate* msgDate = [self getDateFromMilliSeconds:dateInMs];
                            NSMutableArray* msgList = [dicSections objectForKey:msgDate];
                            
                            NSInteger msgId = activity.msgId;
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID == %d", msgId];
                            NSArray *filteredConversationList = [msgList filteredArrayUsingPredicate:predicate];
                            
                            if([filteredConversationList count]>0) {
                                NSMutableDictionary* selectedDic = [filteredConversationList objectAtIndex:0];
                                [selectedDic setValue:[NSNumber numberWithBool:YES] forKey:MSG_LIKED];
                                [self loadData];
                            }
                            break;
                        }
                            
                        case ChatActivityTypeUnlike:
                        {
                            NSNumber* dateInMs = [activity.dic valueForKey:MSG_DATE];
                            NSDate* msgDate = [self getDateFromMilliSeconds:dateInMs];
                            NSMutableArray* msgList = [dicSections objectForKey:msgDate];
                            
                            NSInteger msgId = activity.msgId;
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID == %d", msgId];
                            NSArray *filteredConversationList = [msgList filteredArrayUsingPredicate:predicate];
                            if([filteredConversationList count]>0) {
                                NSMutableDictionary* selectedDic = [filteredConversationList objectAtIndex:0];
                                [selectedDic setValue:[NSNumber numberWithBool:NO] forKey:MSG_LIKED];
                                [self loadData];
                            }
                            break;
                        }
                            
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
                            
                        case ChatActivityTypeFacebookShare:
                        {
                            NSNumber* dateInMs = [activity.dic valueForKey:MSG_DATE];
                            NSDate* msgDate = [self getDateFromMilliSeconds:dateInMs];
                            NSMutableArray* msgList = [dicSections objectForKey:msgDate];
                            
                            NSInteger msgId = activity.msgId;
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID == %d", msgId];
                            NSArray *filteredConversationList = [msgList filteredArrayUsingPredicate:predicate];
                            
                            if([filteredConversationList count]>0) {
                                NSMutableDictionary* selectedDic = [filteredConversationList objectAtIndex:0];
                                [selectedDic setValue:[NSNumber numberWithBool:YES] forKey:MSG_FB_POST];
                                [self loadData];
                            }
                            break;
                        }
                            
                        case ChatActivityTypeTwitterShare:
                        {
                            NSNumber* dateInMs = [activity.dic valueForKey:MSG_DATE];
                            NSDate* msgDate = [self getDateFromMilliSeconds:dateInMs];
                            NSMutableArray* msgList = [dicSections objectForKey:msgDate];
                            
                            NSInteger msgId = activity.msgId;
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID == %d", msgId];
                            NSArray *filteredConversationList = [msgList filteredArrayUsingPredicate:predicate];
                            
                            if([filteredConversationList count]>0) {
                                NSMutableDictionary* selectedDic = [filteredConversationList objectAtIndex:0];
                                [selectedDic setValue:[NSNumber numberWithBool:YES] forKey:MSG_TW_POST];
                                [self loadData];
                            }
                            break;
                        }
                            
                        case ChatActivityTypeReadMessage:
                        {
                            NSNumber* dateInMs = [activity.dic valueForKey:MSG_DATE];
                            NSDate* msgDate = [self getDateFromMilliSeconds:dateInMs];
                            NSMutableArray* msgList = [dicSections objectForKey:msgDate];
                            
                            NSInteger msgId = activity.msgId;
                            
                            //- If msgId is nil, check the msgDataList if msg id(s) are present.
                            // If so, process that. TDOD: process if array contains more than 1 ids.
                            if(!msgId) {
                                NSArray* msgIdList = activity.msgDataList;
                                if([msgIdList count]>0) {
                                    msgId = [[msgIdList objectAtIndex:0]integerValue];
                                }
                            }
                            
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID == %d", msgId];
                            NSArray *filteredConversationList = [msgList filteredArrayUsingPredicate:predicate];
                            
                            if([filteredConversationList count]>0) {
                                NSMutableDictionary* selectedDic = [filteredConversationList objectAtIndex:0];
                                [selectedDic setValue:[NSNumber numberWithInt:MessageReadStatusRead] forKey:MSG_READ_CNT];
                            }
                            break;

                        }
                            
                        default:
                            break;
                    }
                }
                break;
            }
#ifdef TRANSCRIPTION_ENABLED
            case VOICE_MESSAGE_TRANSCRIPTION_TEXT:
            {
                if([respCode isEqualToString:ENG_SUCCESS])
                {
                    NSDictionary *respDic = [resultDic valueForKey:RESPONSE_DATA];
                    if(respDic.count) {
                        NSNumber* dateInMs = [respDic valueForKey:MSG_DATE];
                        NSDate* msgDate = [self getDateFromMilliSeconds:dateInMs];
                        NSMutableArray* msgList = [dicSections objectForKey:msgDate];
                        NSInteger msgId = [[respDic valueForKey:MSG_ID]integerValue];
                        if(msgId > 0) {
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID == %d", msgId];
                            NSArray *filteredConversationList = [msgList filteredArrayUsingPredicate:predicate];
                            
                            if([filteredConversationList count]>0) {
                                NSMutableDictionary* selectedDic = [filteredConversationList objectAtIndex:0];
                                NSString* transStatus = [respDic valueForKey:MSG_TRANS_STATUS];
                                NSString* transText = [respDic valueForKey:MSG_TRANS_TEXT];
                                NSString* transRating = [respDic valueForKey:MSG_TRANS_RATING];
                                if(transStatus.length)
                                    [selectedDic setValue:transStatus forKey:MSG_TRANS_STATUS];//trans status
                                if(transText)
                                    [selectedDic setValue:transText forKey:MSG_TRANS_TEXT];//trans text
                                if(transRating) {
                                    NSNumber* rating = [NSNumber numberWithInt:[transRating intValue]];
                                    [selectedDic setValue:rating forKey:MSG_TRANS_RATING]; //trans rating
                                }
                            }
                            
                            [self loadData];
                        }
                    }
                }
                break;
            }
#endif
                
            default:
                break;
        }
    }
    return SUCCESS;
}

#pragma mark -- AVAudioSessionRouteChangeNotification

-(void)didAudioRouteChange:(NSInteger)reason
{
    switch (reason)
    {
        case AVAudioSessionRouteChangeReasonUnknown:
        {
            EnLogi(@"routeChangeReason : AVAudioSessionRouteChangeReasonUnknown");
            KLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonUnknown");
        }
            break;
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            // a headset was added
            [self setImageForAudioDevice];
            EnLogi(@"routeChangeReason : AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            KLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNewDeviceAvailable");
        }
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // a headset was removed
            [self setImageForAudioDevice];
            [self performSelectorOnMainThread:@selector(stopAudioPlayback) withObject:nil waitUntilDone:NO];
            EnLogi(@"routeChangeReason : AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            KLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            EnLogi(@"routeChangeReason : AVAudioSessionRouteChangeReasonCategoryChange");
            KLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonCategoryChange");
            break;
            
        case AVAudioSessionRouteChangeReasonOverride:
            EnLogi(@"routeChangeReason : AVAudioSessionRouteChangeReasonOverride");
            KLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOverride");
            break;
            
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            EnLogi(@"routeChangeReason : AVAudioSessionRouteChangeReasonWakeFromSleep");
            KLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonWakeFromSleep");
            break;
            
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            EnLogi(@"routeChangeReason : AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory");
            KLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory");
            break;
            
        default:
            [self setImageForAudioDevice];
            break;
    }
}


- (void)setImageForAudioDevice
{
    //TODO: JUNE 16, 2016
    return;
    
    /*
    // Get array of current audio outputs (there should only be one)
    NSArray *outputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    
    if( !(outputs && [outputs count]) ) {
        EnLogd(@"***ERROR getting current audio i/o route");
        return;
    }
    
    NSString *portName = [[outputs objectAtIndex:0] portName];
    NSString *portType = [[outputs objectAtIndex:0] portType];
    
    if ([portName isEqualToString:HEADPHONES])
    {
        headsetImage.hidden = NO;
        [headsetImage setImage:[UIImage imageNamed:IMG_HEADPHONE]];
    }
    else if([portName isEqualToString:SPEAKAER] || [portName isEqualToString:RECEIVER])
    {
        headsetImage.hidden = YES;
        
        if(_speakerMode) {
            [headsetImage setImage:[UIImage imageNamed:IMG_SPEAKER_ON]];
        }
        else {
            [headsetImage setImage:[UIImage imageNamed:IMG_SPEAKER_OFF]];
        }
        
        //TODO: Implement the logic for - when the curent headset/bluetooth-set-mode is removed, resume to the previous aduio route.
        // The current implementation is -- when headset mode is removed and audio play is in progress, audio is routed to the built-in
        // speaker till the completion. The next play is as per setting.
        
        //[playSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    else if([portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
            [portType isEqualToString:AVAudioSessionPortBluetoothA2DP])
    {
        headsetImage.hidden = NO;
        [headsetImage setImage:[UIImage imageNamed:IMG_BLUETOOTH]];
    }
     */
}


#pragma mark -- Audio Recording and Sending
//Action: Click On recording button for recording
-(IBAction)startRecording:(id)sender
{
    // TODO: should we allow recording while voice call is connected.
    CTCallCenter *ctCallCenter = [[CTCallCenter alloc] init];
    //KLog(@"ctCallCenter.currentCalls = %@",ctCallCenter.currentCalls);
    if (ctCallCenter.currentCalls != nil)
    {
        NSArray* currentCalls = [ctCallCenter.currentCalls allObjects];
        for (CTCall *call in currentCalls)
        {
            if(call.callState == CTCallStateConnected || call.callState == CTCallStateDialing)
            {
                /*TODO: FIXME
                 UIAlertController *callConnected = [UIAlertController alertControllerWithTitle:@"Call Connected" message:@"Mic is in use in call!" preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                 [self becomeFirstResponder];
                 }];
                 [callConnected addAction:ok];
                 [self.navigationController presentViewController:callConnected animated:YES completion:nil];
                 */
                return;
            }
        }
    }
    
    KLog(@"start recording");
    if(audioObj.isPlay) {
        KLog(@"Audio is being played. Pause the audio.");
        [self stopAudioPlayback];
        buttonTag = [NSIndexPath indexPathForRow:-1 inSection:0];
        //DEC 8, 2016 return;
    }
    
    // if we dont' have permissions for the microphone, return
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
#ifdef REACHME_APP
        NSString* text = @"ReachMe app needs access to Microphone to record your audio message.";
#else
        NSString* text = @"InstaVoice app needs access to Microphone to record your audio message.";
#endif
        
        if (![self checkMicrophonePermission:text]) {
            KLog(@"No persmission for microphone access");
            return;
        }
    }
    
    circleSubView.backgroundColor = [UIColor darkGrayColor];
    
    /*
    // check how many times the button was touched.
    NSUInteger numberOfTouches = [panRecognizer numberOfTouches];
    if (numberOfTouches > 1)
    {
        EnLogd(@" Number of touches on mic is more than 1");
        KLog(@" Number of touches on mic is more than 1");
    }
    */
    
    if(!_msgLimitExceeded)
    {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        //[chatView setUserInteractionEnabled:NO];
        
        setState = 1;
        if (circleDraw != nil)
        {
            [circleDraw removeFromSuperview];
        }
        circleDraw = nil;
        if (drawStripTimer != nil)
        {
            [drawStripTimer invalidate];
        }
        
        cancelVoiceBtn1.hidden = NO;
        swipeToCancelLabel1.hidden = NO;
        recordingView.hidden = NO;
        
        [self.view bringSubviewToFront:recordingView];
        
        EnLogd(@"RECORDING VIEW  IS HIDDEN  : %d",recordingView.isHidden);
        recordingView.clipsToBounds = YES;
        [micButtonView1 addGestureRecognizer:panRecognizer];
        micButtonView1.clipsToBounds = YES;
        
        timerLabel = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_40,SIZE_80,SIZE_70,SIZE_25)];
        [timerLabel setFont:[UIFont fontWithName:HELVETICANEUE_LIGHT size:SIZE_15]];
        [timerLabel setBackgroundColor:[UIColor clearColor]];
        [timerLabel setTextColor:[UIColor whiteColor]];
        [timerLabel setText:@"00:00"];
        if(self.uiType==NOTES_SCREEN) {
            headingLabel.text = @"Release to save";
        }
        else {
            headingLabel.text = NSLocalizedString(@"RELEASE_TO_SEND",nil);
        }
        
        CGRect currentFrame = headingLabel.frame;
        CGSize max = CGSizeMake(headingLabel.frame.size.width, SIZE_312);
        headingLabel.numberOfLines = SIZE_0;
        
        //DC MAY 26 2016
        NSAttributedString *offsetAttributedString;
        if (headingLabel.text.length) {
            offsetAttributedString = [[NSAttributedString alloc]initWithString:headingLabel.text   attributes:@{NSFontAttributeName:headingLabel.font}];
        }
        else
            offsetAttributedString = [[NSAttributedString alloc]initWithString:@""   attributes:@{}];
        CGRect offsetTextStringRect = [offsetAttributedString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        CGSize expected = offsetTextStringRect.size;
        
        currentFrame.size.height = expected.height;
        headingLabel.frame = currentFrame;
        circleDraw =[[CircleProgressView alloc] initWithFrame:circleSubView.frame];
        circleDraw.backgroundColor = [UIColor clearColor];
        
        circleDraw.layer.cornerRadius = circleDraw.frame.size.width / 2;
        circleDraw.clipsToBounds = YES;
        
        circleDraw.maxDurationTime = _maxVoiceMsgDuration;
        [circleDraw.sendButton addTarget:self action:@selector(sendRecording) forControlEvents:UIControlEventTouchUpInside];
        
        [recordingView addSubview:circleDraw];
        [self.view bringSubviewToFront:micButtonView1];
        [circleSubView addSubview:timerLabel];
        [circleDraw setUserInteractionEnabled:YES];
        [circleSubView setUserInteractionEnabled:YES];
        
        float circleProgressCount = 360/_maxVoiceMsgDuration;
        circleDraw.startAngle = DEGREES_TO_RADIANS(-90);
        circleDraw.endAngle   = (circleDraw.startAngle + DEGREES_TO_RADIANS(circleProgressCount))-.05;
        circleDraw.duration = 0;
        
        long long  fileName= (long long)([[NSDate date] timeIntervalSince1970] * 1000);
        
        NSString* recordingFileName = [[NSString stringWithFormat:@"%lld",fileName] stringByAppendingString:@".wav"];
        NSString* recordingFilePath = [[IVFileLocator getMediaAudioSentDirectory]
                                       stringByAppendingPathComponent:recordingFileName];
        
        [audioObj startRecordingAudioMsgAtFilePath:recordingFilePath];
        recorderTimer  =  [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(startRecordTimer:)
                                                         userInfo:[NSNumber numberWithFloat:circleProgressCount]
                                                          repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:recorderTimer forMode:NSRunLoopCommonModes];
        /* DEC 22, 2017
        self.microphone = nil;
        self.microphone.delegate = nil;
         */
        self.microphone = [EZMicrophone microphoneWithDelegate:self];
        [self.microphone startFetchingAudio];
        
        cancelVoiceBtn1.hidden = NO;
        swipeToCancelLabel1.hidden = NO;
        
        if (isKeyboardPresent && [text1 isFirstResponder]) {
            circleDraw.state = SIZE_2;
            panRecognizer.enabled = NO;
            [self handFreeRecording];
            circleSubView.backgroundColor = [IVColors redColor];
            circleSubView.tag = 0;
            circleDraw.sendButton.hidden = NO;
        }
        
        [self alignTextField:text1.text.length];
        
        [text1 resignFirstResponder];
        [self alignVoiceRecordingBarStarted:YES];
    }
    else
    {
        [ScreenUtility showAlert:NSLocalizedString(@"VSMS_LIMIT", nil)];
        [micButtonView1 removeGestureRecognizer:panRecognizer];
    }
    
    hasExpanded = NO;
    text1.text = @"";
    [self inputAccessoryViewFrame];
}

//Function: Animation of recording circle and check the timer duation
-(void)startRecordTimer:(NSTimer*)timer
{
    NSString* durationString = @"";
    NSNumber* circleProgressCount = [timer userInfo];
    if(recorderTimer != Nil)
    {
        circleDraw.duration = circleDraw.duration + SIZE_1;
        circleDraw.endAngle = DEGREES_TO_RADIANS([circleProgressCount floatValue]) + circleDraw.endAngle;
        [circleDraw setNeedsDisplay];
        if(circleDraw.duration > INT_9 && circleDraw.duration < INT_60)
        {
            durationString = [NSString stringWithFormat:@"00:%ld",(long)circleDraw.duration];
        }
        else if(circleDraw.duration >= INT_60 )
        {
            int min = (int)circleDraw.duration / INT_60;
            int sec = circleDraw.duration % INT_60;
            if(sec <= INT_9)
                durationString = [NSString stringWithFormat:@"0%d:0%d",min,sec];
            else
                durationString = [NSString stringWithFormat:@"0%d:%d",min,sec];
        }
        else
        {
            durationString = [NSString stringWithFormat:@"00:0%ld",(long)circleDraw.duration];
        }
        
        if(circleDraw.state == SIZE_2)
        {
            circleDraw.state = SIZE_3;
            if(self.uiType == NOTES_SCREEN)
                headingLabel.text = @"Tap the red circle to save";
            else
                headingLabel.text = NSLocalizedString(@"REC_SLIDE_HANDSFREE",nil);
            
            imageTime =[NSTimer scheduledTimerWithTimeInterval:0.33
                                                        target:self
                                                      selector:@selector(timerImage)
                                                      userInfo:nil
                                                       repeats:YES];
        }
        
        [timerLabel setText:durationString];
        if(circleDraw.duration == _maxVoiceMsgDuration)
        {
            recordingView.hidden = YES;
            [recorderTimer invalidate];
            recorderTimer = nil;
            [imageTime  invalidate];
            imageTime = nil;
            circleDraw.duration = _maxVoiceMsgDuration;
            [audioObj pauseRecording];
            containerView.hidden = YES;
            NSString* alertMessage = NSLocalizedString(@"SEND_CONFIRMATION_TEXT", nil);
            NSString* saveBtnCap = NSLocalizedString(@"SEND", nil);
            if(self.uiType == NOTES_SCREEN) {
                alertMessage = NSLocalizedString(@"SEND_CONFIRMATION_TEXT_NOTES",nil);
                saveBtnCap = NSLocalizedString(@"Save", nil);
            }
            
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            
            
            UIAlertController * messageAlert=   [UIAlertController
                                                 alertControllerWithTitle:NSLocalizedString(@"TIME_LIMIT",nil)
                                                 message:alertMessage
                                                 preferredStyle:UIAlertControllerStyleAlert];
            messageAlert.view.tag = alertControllerTag;
            
            UIAlertAction* sendButton = [UIAlertAction
                                         actionWithTitle:saveBtnCap
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [self sendRecording];
                                             containerView.hidden = NO;
                                             [messageAlert dismissViewControllerAnimated:YES completion:nil];
                                         }];
            UIAlertAction* cancelButton = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"CANCEL",nil)
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction * action)
                                           {
                                               if(self.uiType == INSIDE_CONVERSATION_SCREEN)
                                                   _textViewChangeAfterMicIconTap = YES;
                                               [self stopRecordingTimer];
                                               audiofilePath = nil;
                                               containerView.hidden = NO;
                                               [messageAlert dismissViewControllerAnimated:YES completion:nil];
                                           }];
            [messageAlert addAction:sendButton];
            [messageAlert addAction:cancelButton];
            [self presentViewController:messageAlert animated:YES completion:nil];
            [messageAlert.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        }
    }
    else
    {
        return;
    }
}

-(void)timerImage
{
    NSString *imgName = nil;
    //EnLogd(@"circle sub view is hidden = %d",circleSubView.isHidden);
    if(circleDraw.state == SIZE_6)
    {
        imgName = IMG_LOADER_BLACK_A;
        circleDraw.state = SIZE_3;
    }
    else
        if(circleDraw.state == SIZE_3)
        {
            imgName = IMG_LOADER_BLACK_B;
            circleDraw.state = SIZE_4;
        }
        else if(circleDraw.state == SIZE_4)
        {
            imgName = IMG_LOADER_BLACK_C;
            circleDraw.state = SIZE_5;
        }
        else if(circleDraw.state == SIZE_5)
        {
            imgName = IMG_LOADER_BLACK_D;
            circleDraw.state = SIZE_6;
        }
        else
        {
            EnLogd(@"IMG_LOADER_BLACK_COUNTER ");
            imgName = IMG_LOADER_BLACK_COUNTER;
            circleDraw.state = SIZE_3;
        }
}

//Stop the timer of circle to release the button
-(void)stopRecordingTimer
{
    circleDraw.endAngle     =   SIZE_0;
    circleDraw.startAngle   =   SIZE_0;
    [chatView setUserInteractionEnabled:YES];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [timerLabel removeFromSuperview];
    timerLabel = nil;
    
    KLog(@"stopRecordingTimer");
    [self.microphone stopFetchingAudio];
    /* DEC 22, 2017
    self.microphone.delegate = nil;
    self.microphone = nil;
     */
    [audioObj cancelRecording];
    
    [self alignVoiceRecordingBarStarted:NO];
    
    cancelVoiceBtn1.hidden = YES;
    swipeToCancelLabel1.hidden = YES;
    
    recordingView.hidden = YES;
    [recorderTimer invalidate];
    recorderTimer = nil;
    [imageTime invalidate];
    imageTime = nil;
    [self hideSendButtonOnNilText];
    panRecognizer.enabled = YES;
    hasExpanded = NO;
    
    self.chatView.contentInset = UIEdgeInsetsMake(0, 0, (height == 0?45.0:height) - (isiPhoneX?35.0:0.0), 0);
    self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,(height == 0?45.0:height) - (isiPhoneX?35.0:0.0), 0);
    
}

#pragma mark -- Gesture Recognizer
//Setting of  Microphone Pan Gesture events
-(void)setupGestureRecognizerInTableAndMic
{
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userDidTapScreen:)];
    tapGestureRecognizer.delegate=self;
    tapGestureRecognizer.enabled=YES;
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [chatView addGestureRecognizer:tapGestureRecognizer];

    //table view for share menu
    //gestureMenuRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    
   gestureMenuRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showWithdrawPop:)];

    [chatView addGestureRecognizer:gestureMenuRecognizer];
    
    //Mic view for swipe pan and pinch
    micButtonView1.userInteractionEnabled = YES;
    
    pinchRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pichDetected:)];
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    swipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDetected:)];
    
    [micButtonView1 addGestureRecognizer:pinchRecognizer];
    [micButtonView1 addGestureRecognizer:panRecognizer];
    [micButtonView1 addGestureRecognizer:swipeRecognizer];
    
    [panRecognizer setDelegate:self];
}

- (void)swipeDetected:(UISwipeGestureRecognizer *)swipeRecog
{
    KLog(@"swipe  detected with state : %ld",(long)swipeRecog.state);
    [self swipeAndPinchMicSetup:swipeRecog];
}

- (void)pichDetected:(UIPinchGestureRecognizer *)pinchRecog
{
    KLog(@"pinch detected with state : %ld",(long)pinchRecog.state);
    [self swipeAndPinchMicSetup:pinchRecog];
}

-(void)swipeAndPinchMicSetup:(UIGestureRecognizer*)gesture
{
    if(recordingView.hidden)
    {
        EnLogd(@"recording view is hidden");
        return;
    }
    if( gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled)
    {
        circleDraw.sendButton.hidden = FALSE;
        headingLabel.text     = NSLocalizedString(@"HANDFREE_RECRDMODE",nil);
        [cancelVoiceBtn1 setImage:[[UIImage imageNamed:@"longpress-delete-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        circleDraw.state = 1;
        swipeToCancelLabel1.hidden = YES;
        
    }
}

- (void)panDetected:(UIPanGestureRecognizer *)panRecog
{
    if (recordingView.isHidden) {
        return;
    }
    
    if(panRecog.state == UIGestureRecognizerStateChanged || panRecog.state == UIGestureRecognizerStateBegan)
    {
        CGPoint translation = [panRecog translationInView:recordingArea1];
        imageViewPosition = micButtonView1.center;
        imageViewPosition.x += translation.x;
        imageViewPosition.y += translation.y;
        [self micSetupOnPanGesture:panRecog];
    }
    
    if(panRecog.state == UIGestureRecognizerStateEnded || panRecog.state == UIGestureRecognizerStateCancelled)
    {
        //EnLogd(@"end state ");
        EnLogd(@"RECORDING VIEW HIDDEN STATUS 11:%d ",recordingView.isHidden);
        if(setState)
        {
            //EnLogd(@"set  state true");
            if((circleSubView.tag == 1) && (imageViewPosition.x > 80.0))
            {
                EnLogd(@"RECORDING VIEW HIDDEN STATUS :%d ",recordingView.isHidden);
                EnLogd(@"send recording called");
                if(circleDraw.duration != _maxVoiceMsgDuration)
                    [self sendRecording];
                setState = SIZE_0;
                return;
            }
            if(imageViewPosition.x <= 80.0 && circleSubView.tag == 1)
            {
                EnLogd(@"stopRecordingTimer called");
                [self stopRecordingTimer];
                setState = SIZE_0;
                return;
            }
            else
            {
                [self handFreeRecording];
            }
        }
    }
}

- (void)handFreeRecording
{
    EnLogd(@"RECORDING VIEW HIDDEN STATUS :%d ",recordingView.isHidden);
    circleDraw.sendButton.hidden = FALSE;
    headingLabel.text = NSLocalizedString(@"REC_SLIDE_HANDSFREE",nil);
    [cancelVoiceBtn1 setImage:[[UIImage imageNamed:@"longpress-delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [cancelVoiceBtn1 setImage:[[UIImage imageNamed:@"longpress-delete-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    swipeToCancelLabel1.hidden = YES;
    
//    if (self.uiType == NOTES_SCREEN) {
//        [UIView animateWithDuration:0.15 animations:^{
//            self.chatView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//            self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//        }];
//    }
    
}


-(void) micSetupOnPanGesture:(UIPanGestureRecognizer *)panRecog
{
    if (imageViewPosition.y <= -1.0) {
        [UIView animateWithDuration:.125 animations:^{
            circleSubView.backgroundColor = [IVColors redColor];
        }];
        circleDraw.state = SIZE_2;
        headingLabel.text = @"Release to Switch to Hands Free Mode";
        circleSubView.layer.cornerRadius = circleSubView.frame.size.width / 2;
        circleSubView.tag = 0;
        [cancelVoiceBtn1 setImage:[[UIImage imageNamed:@"longpress-delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        
    }else{
        
        circleSubView.tag = 1;
        [UIView animateWithDuration:.125 animations:^{
            circleSubView.backgroundColor = [UIColor darkGrayColor];
        }];
        circleSubView.layer.cornerRadius = circleSubView.frame.size.width / 2;
        cancelVoiceBtn1.contentMode = UIViewContentModeScaleAspectFill;
        
        if(imageViewPosition.x <= 80.0) {
            headingLabel.text = @"Release to Cancel Recording";
            [cancelVoiceBtn1 setImage:[[UIImage imageNamed:@"longpress-delete-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            
        } else {
            if(self.uiType==NOTES_SCREEN)
                headingLabel.text = @"Release to Save";
            else
                headingLabel.text = @"Release to Send";
            [cancelVoiceBtn1 setImage:[[UIImage imageNamed:@"longpress-delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        }
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)sendRecording
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [chatView setUserInteractionEnabled:YES];
    [UIView animateWithDuration:0.15 animations:^{
        self.chatView.contentInset = UIEdgeInsetsMake(0, 0, (height == 0?45.0:height) - (isiPhoneX?35.0:0.0), 0);
        self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,(height == 0?45.0:height) - (isiPhoneX?35.0:0.0), 0);
    }];
    text1.hidden = NO;
    [timerLabel removeFromSuperview];
    [cancelVoiceBtn1 setImage:[[UIImage imageNamed:@"longpress-delete-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [self alignTextField:0];
    recordingView.hidden = YES;
    cancelVoiceBtn1.hidden = YES;
    swipeToCancelLabel1.hidden = YES;
    
    [recorderTimer invalidate];
    recorderTimer = nil;
    if(([circleDraw duration] != 0) || (audiofilePath != nil && [audiofilePath length] > 0))
    {
        //EnLogd(@"condition circle draw is not zero");
        NSString *recordingFileLocalPath = nil;
        [self.microphone stopFetchingAudio];
        /* DEC 22, 2017
        self.microphone = nil;
        self.microphone.delegate = nil;
        */
        //
        if(audiofilePath != nil && [audiofilePath length]>0)
        {
            recordingFileLocalPath = audiofilePath;
        }
        else
        {
            recordingFileLocalPath = [audioObj stopAndGetRecordedFilePath];
        }
        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:recordingFileLocalPath] options:nil];
        CMTime audioDuration = audioAsset.duration;
        float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
        NSNumber *recording = [[NSNumber alloc] initWithInt:roundf(audioDurationSeconds)];
        
        [imageTime invalidate];
        imageTime = nil;
        [recorderTimer invalidate];
        recorderTimer = nil;
        if([recording intValue] == 0)
        {
            EnLogd(@"Record duration is zero and the recorded file : %@",recordingFileLocalPath);
            return;
        }
        
        
        NSString* fileName = [[recordingFileLocalPath lastPathComponent] stringByDeletingPathExtension];
        fileName = [fileName stringByAppendingString:@".wav"];
        
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * SIZE_1000);
        NSNumber *date = [NSNumber numberWithLongLong:milliseconds];
        
        NSMutableDictionary *conversationDic = [[NSMutableDictionary alloc]init];
        [conversationDic setValue:msgType forKey:MSG_TYPE];
        [conversationDic setValue:date forKey:MSG_DATE];
        [conversationDic setValue:SENDER_TYPE forKey:MSG_FLOW];
        [conversationDic setValue:AUDIO_TYPE forKey:MSG_CONTENT_TYPE];
        if(_displayLoc)
        {
            if(location != nil)
            {
                
                [conversationDic setValue:[[NSNumber numberWithFloat:location.coordinate.latitude] stringValue] forKey:LATITUDE];
                [conversationDic setValue:[[NSNumber numberWithFloat:location.coordinate.longitude] stringValue] forKey:LONGITUTE];
            }
            if(locationName != nil)
            {
                [conversationDic setValue:locationName forKey:LOCATION_NAME];
            }
        }
        [conversationDic setValue:fileName forKey:MSG_CONTENT];
        if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE)
            [conversationDic setValue:API_NETUNAVAILABLE forKey:MSG_STATE];
        else
            [conversationDic setValue:API_INPROGRESS forKey:MSG_STATE];
        [conversationDic setValue:recordingFileLocalPath forKey:MSG_LOCAL_PATH];
        [conversationDic setValue:AUDIO_FORMAT forKey:MEDIA_FORMAT];
        [conversationDic setValue:recording forKey:DURATION];
        [self sendMessageToServer:conversationDic];
        circleDraw.duration = 0;
    }
    else
    {
        //[audioObj stopAndGetRecordedFilePath];
        if(!_msgLimitExceeded){
            CTCallCenter *ctCallCenter = [[CTCallCenter alloc] init];
            if (ctCallCenter.currentCalls != nil)
            {
                NSArray* currentCalls = [ctCallCenter.currentCalls allObjects];
                for (CTCall *call in currentCalls)
                {
                    if(call.callState == CTCallStateConnected)
                    {
                        return;
                    }
                }
            }
            [self stopRecordingTimer];
            [ScreenUtility showAlertMessage:NSLocalizedString(@"INSIDE_CON_PRESS_AND_HOLD",nil)];
            containerView.userInteractionEnabled = NO;
        }
        
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(enableUserInteraction) userInfo:nil repeats:NO];
    }
    
    audiofilePath = nil;
    [self alignVoiceRecordingBarStarted:NO];
    panRecognizer.enabled = YES;
    
    if(self.uiType == INSIDE_CONVERSATION_SCREEN)
        _textViewChangeAfterMicIconTap = YES;
    
    hasExpanded = NO;
}

-(void)enableUserInteraction
{
    containerView.userInteractionEnabled = YES;
}

//MAY 9, 2017
- (void)killScroll
{
    CGPoint offset = self.chatView.contentOffset;
    offset.x -= 1.0;
    offset.y -= 1.0;
    [self.chatView setContentOffset:offset animated:NO];
    offset.x += 1.0;
    offset.y += 1.0;
    [self.chatView setContentOffset:offset animated:NO];
}
//

-(void)sendMessageToServer:(NSMutableDictionary*)conversationDic
{
    [self killScroll];
    
    if([appDelegate.stateMachineObj getCurrentUIType] == NOTES_SCREEN)
    {
        [appDelegate.engObj clearCurrentChatUser];
    }
    
    NSMutableArray* arrMsg = [[NSMutableArray alloc]init];
    [conversationDic setValue:[Common getGuid] forKey:MSG_GUID];
    [conversationDic setValue:[currentChatUserInfo valueForKey:FROM_USER_ID] forKey:FROM_USER_ID];
    [conversationDic setValue:[appDelegate.confgReader getLoginId] forKey:LOGGEDIN_USER_ID];
    [arrMsg addObject:conversationDic];
    
    [self prepareDataSourceFromMessages:arrMsg withInsertion:NO MsgType:eNewMessage];
    [appDelegate.engObj sendMsg:conversationDic];
    
    
    //TODO MAY 2017
    //- Delete all the sections except the last section(s) having upto 25 messages.
    //- This is required, because scrollToBottom takes more time if there are 100s of messages in a chat page.
    //- So, keep only last 25 messages in a chat page
    if(!audioObj.isPlay) {
        @synchronized (self) {
            NSInteger asCount = [arrDatesSorted count]-1;
            if(asCount>=0) {
                NSDate* dtDate=nil;
                NSInteger totalMsgs = 0;
                NSInteger msgsInSection = 0;
                for(long ct=asCount;ct>=0;ct--) {
                    dtDate = [arrDatesSorted objectAtIndex:ct];
                    msgsInSection = [[dicSections objectForKey:dtDate]count];
                    if(totalMsgs < 25) {
                        //MAY 11, 2017
                        if( (ct==asCount) && msgsInSection > 25) {
                            [[dicSections objectForKey:dtDate]removeObjectsInRange:NSMakeRange(0, msgsInSection-25)];
                        }
                        //
                        //NSLog(@"totalMsgs = %ld",totalMsgs);
                        totalMsgs += msgsInSection;
                        continue;
                    }
                    [dicSections removeObjectForKey:dtDate];
                }
                
                NSArray *unsortedDates = [dicSections allKeys];
                NSSortDescriptor* descSortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
                NSArray* res = [unsortedDates sortedArrayUsingDescriptors: [NSArray arrayWithObject: descSortOrder]];
                arrDatesSorted = [[NSMutableArray alloc]initWithArray:res];
                self.getHeightForRows = YES;
            }
        }
    }
    //
    
    if(!isScrolling) {
        [self loadData];
        KLog(@"calling scrollToBottom...");
        [self scrollToBottom];
    } else {
        [self.chatView reloadData];
        sendNewMsg = TRUE;
    }
}

#pragma mark -- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != 189147)
    {
        _isAlertPresent = FALSE;
        EnLogi(@"Button: %i, was pressed.", buttonIndex);
        if(buttonIndex == SIZE_0) //Cancel button
        {
            if(self.uiType == INSIDE_CONVERSATION_SCREEN)
                _textViewChangeAfterMicIconTap = YES;
            
            if (alertView.tag != 189159)
            [self stopRecordingTimer];
            
            audiofilePath = nil;
        }
        else if(buttonIndex == SIZE_1) //Send button
        {
            [self sendRecording];
        }
        
        /* SEP 14, 2017
         When audio message recording is interrupted by incoming call, EZMicrophone is failing to resume audio IO.
         Workaround: Recreation of audio object fixes this. TODO: later. */
        [self createAudioObj];
    }
}

-(void)audioButtonClickedAtIndex:(NSIndexPath*)indexPath
{
    if([self isAudioRecording])
        return;
    
    KLog(@"audioButtonClickedAtIndex");
    if(!_beginRefreshingOldMessages) {
        [self voiceMsgAction:indexPath];
    } else {
        EnLogd(@"_beginRefreshingOldMessages:%@",_beginRefreshingOldMessages?@"YES":@"NO");
    }
}

-(void)setCurrentTime:(double)time {
    [self.audioObj setCurrentTime:time];
}

#pragma mark -- Audio Playback and Download
-(void)voiceMsgAction:(NSIndexPath*)cellIndex
{
    NSIndexPath* tag = cellIndex;
    
    if(buttonTag == tag)
    {
        if([self.audioObj isPlay]) {
            [self stopAudioPlayback];
            buttonTag = [NSIndexPath indexPathForRow:-1 inSection:0];
            return;
        }
    }
    else if (buttonTag.row > -1 ) {
        [self stopAudioPlayback];
    }
    
    buttonTag = tag;
    indexForAudioPlayed = tag;
    
    NSDate* dtDate=nil;
    NSArray* msgList=nil;
    if(arrDatesSorted.count>0) {
        dtDate = [arrDatesSorted objectAtIndex:cellIndex.section];
        msgList = [dicSections objectForKey:dtDate];
    }

    if([msgList count]) {
        self.voiceDic = [msgList objectAtIndex:cellIndex.row];
    } else {
        self.voiceDic = nil;
        EnLogd(@"Why self.voiceDic is nil. No action. return.");
        return;
    }
    
    EnLogd(@"clicked on voice strip tag :  sec=%ld, row=%ld",tag.section,tag.row);
    NSString *localPath = [self.voiceDic valueForKey:MSG_LOCAL_PATH];
    
    if(localPath == nil || [localPath isEqualToString:@""])
    {
        KLog(@"local path does not exist : ");
        NSString* msgState = [self.voiceDic valueForKey:MSG_STATE];
        if([msgState isEqualToString:API_DOWNLOAD_INPROGRESS]) {
            EnLogd(@"download in progress. return.");
            KLog(@"download in progress. return.");
        }
        else {
            [self downloadVoiceMsg:self.voiceDic];
        }
    }
    else
    {
        NSString* msgFlow = [self.voiceDic valueForKey:MSG_FLOW];
        NSString* localFilePath = @"";
        
        //- TODO Need to store only the file name into MessageTable: look into NetworkController.m DOWNLOAD_VOICE_MSG
        if([msgFlow isEqualToString:@"s"])
        {
            localFilePath = [IVFileLocator getMediaAudioSentDirectory];
        }
        else
        {
            localFilePath = [IVFileLocator getMediaAudioReceivedDirectory];
        }
        //
        
        NSString* latestFilePath = [localFilePath stringByAppendingPathComponent:[localPath lastPathComponent]];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        if([fileManager fileExistsAtPath: latestFilePath])
        {
            int totalDuration = [[self.voiceDic valueForKey:DURATION] intValue];
            double msgPalyDuration = [[self.voiceDic valueForKey:MSG_PLAY_DURATION]doubleValue];
            
            if(totalDuration == msgPalyDuration)
            {
                [self.voiceDic setValue:[NSNumber numberWithDouble:0.0] forKey:MSG_PLAY_DURATION];
                msgPalyDuration = 0.0;
            }
            
            int speakerMode = CALLER_MODE != [appDelegate.confgReader getVolumeMode];
            if( [Audio isHeadsetPluggedIn] )
                speakerMode = false;
            
            //KLog(@" start the playback");
            int msgReadCnt = [[self.voiceDic valueForKey:MSG_READ_CNT]intValue];
            
            if((MessageReadStatusSeen == msgReadCnt || msgReadCnt == MessageReadStatusUnread) &&
               [[self.voiceDic valueForKey:MSG_FLOW]isEqualToString:MSG_FLOW_R])
            {
                NSNumber* msgId = [self.voiceDic valueForKey:MSG_ID];
                NSMutableArray* msgIdArray = [NSMutableArray arrayWithObjects:msgId, nil];
                
                NSMutableDictionary *readDic = [[NSMutableDictionary alloc]initWithDictionary:self.voiceDic];
                [readDic setValue:msgIdArray forKey:API_MSG_IDS];
                
                [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeReadMessage withData:readDic];
            }
            
            if([self.audioObj startPlayback:latestFilePath playTime:msgPalyDuration playMode:speakerMode])
            {
                ConversationTableCell *cell = (ConversationTableCell *)[self.chatView cellForRowAtIndexPath:indexForAudioPlayed];//TEST Jan 19
                
                if(cell) {
                    [cell.dic setValue:[NSNumber numberWithInt:1] forKey:MSG_PLAYBACK_STATUS];
                    if(cell && [cell respondsToSelector:@selector(setStatusIcon:isAvs:readCount:msgType:)])
                            [cell setStatusIcon:API_MSG_PALYING isAvs:0 readCount:0 msgType:msgType];
                    
                    if(cell && [cell respondsToSelector:@selector(swapPlayPause:)])
                        [cell swapPlayPause:nil];
                }
                
                if(drawStripTimer != nil)
                {
                    [drawStripTimer invalidate];
                }
                
                NSRunLoop *runloop = [NSRunLoop currentRunLoop];
                drawStripTimer = [NSTimer scheduledTimerWithTimeInterval:audioPlayUpdateInterval target:self selector:@selector(playVoiceMsg:)  userInfo:self.voiceDic repeats:YES];
                [runloop addTimer:drawStripTimer forMode:NSRunLoopCommonModes];
                [runloop addTimer:drawStripTimer forMode:UITrackingRunLoopMode];
            } else {
                EnLoge(@"startPlayback failed.");
            }
        }
        else
        {
            KLog(@"file does not exist at local path. Downloading the msg.. ");
            [self downloadVoiceMsg:self.voiceDic];
        }
    }
}

-(void)stopAudioPlayback
{
    KLog(@"stopAudioPlayback");
    if(drawStripTimer != nil) {
        [drawStripTimer invalidate];
    }
    
    if(buttonTag.row < 0) {
        KLog(@"Invalid buttonTag = %@. Return.",buttonTag);
        if([self.audioObj isPlay])
            [self.audioObj stopPlayback];
        return;
    }
    
    NSDate* dtDate=nil;
    NSArray* msgList=nil;
    if(arrDatesSorted.count>0 && buttonTag.section < arrDatesSorted.count) {
        dtDate = [arrDatesSorted objectAtIndex:buttonTag.section];
        msgList = [dicSections objectForKey:dtDate];
    } else {
        return;
    }
    
    if(buttonTag.row >= [msgList count]) {
        if([self.audioObj isPlay])
            [self.audioObj stopPlayback];
        
        //KLog(@"No of objects in _currentFilteredList:%d",[_currentFilteredList count]);
        //KLog(@"Object at the index: %@",buttonTag);
        KLog(@"Invalid object index. Return");
        return;
    }
    
    ConversationTableCell *cell = (ConversationTableCell *)[self.chatView cellForRowAtIndexPath:buttonTag];
    
    NSDictionary* dic = [msgList objectAtIndex:buttonTag.row];//TODO: check
    if(dic) {
        if([self.audioObj isPlay]) {
            [self.audioObj stopPlayback];
        }
        if(cell) {
            
            int totalDuration = [[cell.dic valueForKey:DURATION]intValue];
            double playedDuration = roundf([[cell.dic valueForKey:MSG_PLAY_DURATION] doubleValue]);
        
            if (playedDuration == totalDuration) {
                [cell.dic setValue:[NSNumber numberWithDouble:0.0] forKey:MSG_PLAY_DURATION];
                [self.audioObj stopPlayback];
                 [chatView reloadRowsAtIndexPaths:@[buttonTag] withRowAnimation:UITableViewRowAnimationNone];//JUNE 2017
            }
            
            //KLog(@"row = %lu,stopped playback",(unsigned long)cell.cellIndex);
            if ([cell respondsToSelector:@selector(stopPlaying:)])
                [cell stopPlaying:nil];
        } else {
            //KLog(@"row = %lu is not visble. so empty cell.....!",(unsigned long)cell.cellIndex);
            [dic setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAYBACK_STATUS];
            [dic setValue:[NSNumber numberWithDouble:0.0] forKey:MSG_PLAY_DURATION];
        }
        

        //JUNE, 2017 [chatView reloadRowsAtIndexPaths:@[buttonTag] withRowAnimation:UITableViewRowAnimationNone];
    }
}

/*
//Function for get imageView of cell
-(UIImageView *)getVoiceCellView:(NSArray *)cellSubViews
{
    // NSArray *cellSubViews = [tableViewCell subviews];
    UIImageView *imageView = nil;
    if(cellSubViews != nil && [cellSubViews count] > SIZE_0)
    {
        for (UIView *view in cellSubViews)
        {
            if([view isKindOfClass:[UIImageView class]] && view.tag != TRANSPARENT_VIEW)
            {
                imageView = (UIImageView *)view;
            }
        }
    }
    return imageView;
}
 */

//Function: Download voice Message if Voice Message not exist in Local path
-(void)downloadVoiceMsg:(NSMutableDictionary *)dic
{
    if(dic != nil)
    {
        if(drawStripTimer != nil)
        {
            [drawStripTimer invalidate];
            [audioObj pausePlayBack];
        }
        
        if([Common isNetworkAvailable] == NETWORK_AVAILABLE)
        {
             ConversationTableCell *cell = (ConversationTableCell *)[chatView cellForRowAtIndexPath: indexForAudioPlayed];//TEST Jan 19, 2017
            
            [dic setValue:API_DOWNLOAD_INPROGRESS forKey:MSG_STATE];
            [voiceDic setValue:API_DOWNLOAD_INPROGRESS forKey:MSG_STATE];
            if(cell && [cell respondsToSelector:@selector(setStatusIcon:isAvs:readCount:msgType:)])
                [cell setStatusIcon:API_DOWNLOAD_INPROGRESS isAvs:0 readCount:0 msgType:msgType];
    
            NSMutableDictionary *newDic =[[NSMutableDictionary alloc]initWithDictionary:dic];
            [appDelegate.engObj downloadVoiceMsg:newDic];
        }
        else
        {
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        }
    }
}


//Function for play recording
-(void)playVoiceMsg:(NSTimer *)timerDic
{
    NSMutableDictionary *msgDic = timerDic.userInfo;
    int totalDuration = [[msgDic valueForKey:DURATION] intValue];
    double playedDuration = [[msgDic valueForKey:MSG_PLAY_DURATION] doubleValue];
    
    playedDuration += audioPlayUpdateInterval;
    
    ConversationTableCell *cell = (ConversationTableCell *)[chatView cellForRowAtIndexPath:indexForAudioPlayed];//TEST Jan 19
    if(playedDuration > totalDuration)
    {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        [UIApplication sharedApplication].idleTimerDisabled = NO;

        [drawStripTimer invalidate];
        int isAvsMsg = 0;
        if([[msgDic valueForKey:MSG_SUB_TYPE] isEqualToString:AVS_TYPE])
        {
            isAvsMsg = 1;
        }
        if(cell) {
            [msgDic setValue:[NSNumber numberWithDouble:0.0] forKey:MSG_PLAY_DURATION];
            
            if([cell respondsToSelector:@selector(setStatusIcon:isAvs:readCount:msgType:)]) {
                [cell setStatusIcon:API_DELIVERED isAvs:isAvsMsg readCount:0 msgType:msgType];
            }
            
            if ([cell respondsToSelector:@selector(stopPlaying:)]) {
                [cell stopPlaying:nil];
            }
            if([cell respondsToSelector:@selector(updateVoiceView:)]) {
                    [cell updateVoiceView:msgDic];
            }
        }
        
        //MAY 2017 [chatView reloadData];
        [self.chatView beginUpdates];//JUNE, 2017
        [chatView reloadRowsAtIndexPaths:@[indexForAudioPlayed] withRowAnimation:UITableViewRowAnimationNone];
        [self.chatView endUpdates];
        
        //[self performSelectorOnMainThread:@selector(chatViewReloadData:) withObject:indexForAudioPlayed waitUntilDone:NO];
    }
    else
    {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        [msgDic setValue:[NSNumber numberWithDouble:playedDuration] forKey:MSG_PLAY_DURATION];
        [cell.dic setValue:[NSNumber numberWithDouble:playedDuration] forKey:MSG_PLAY_DURATION];
        if(cell && [cell respondsToSelector:@selector(updateVoiceView:)])
            [cell updateVoiceView:msgDic];
    }
    
}

//MAY 2017
-(void)chatViewReloadData:(NSIndexPath*)index {
    [chatView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
}

//

- (void)alignVoiceRecordingBarStarted:(BOOL)isStarted
{
    if (isStarted) {
        text1.hidden = YES;
        sendImageGalleryButton1.hidden = YES;
        sendImageCameraButton1.hidden = YES;
        sendTextButton1.hidden = YES;
        sendTextButton1.alpha = 0;
        KLog(@"sendTextButton disabled");
        micButtonView1.alpha = 0;
        footerView1.alpha = 0;
        chatToolbar1.hidden = YES;
    }
    else
    {
        text1.hidden = NO;
        sendImageCameraButton1.hidden = NO;
        sendImageGalleryButton1.hidden = NO;
        micButtonView1.alpha = 1;
        footerView1.alpha = 0;
        chatToolbar1.hidden = NO;
    }
}

#pragma mark @missedCallExpandedViewAtIndex
-(void)missedCallExpandedViewAtIndex:(NSIndexPath *)indexPath
{
    [chatView reloadData];
}

//Bhaskar April 13th--> To Show Transcription text which is hiding behind keypad
#pragma mark @transcriptionExpandedViewAtIndex
-(void)transcriptionExpandedViewAtIndex:(NSIndexPath*)indexpath
{
    [chatView reloadData];
}

#ifdef TRANSCRIPTION_ENABLED
#pragma mark @transcriptionExpandedViewAtIndex
-(void)transcriptionButtonTapped:(NSDictionary *)msgDic
{
    NSUInteger totalCredits = [appDelegate.confgReader getVsmsLimit];
    if (totalCredits < 2) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Buy Credits" message:@"You have insufficient credits balance. Please buy credits to avail Voice-To-Text service" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        
        UIAlertAction *buy = [UIAlertAction actionWithTitle:@"Buy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
#ifndef REACHME_APP
            InstaVoiceCreditsTableViewController *instaVoiceCreditsVC = [[UIStoryboard storyboardWithName:@"IVSettingsStoryBoard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"InstaVoiceCreditsVC"];
            [self.navigationController pushViewController:instaVoiceCreditsVC animated:YES];
#else
            [appDelegate.tabBarController setSelectedIndex:3];
            [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[3]];
#endif
            
        }];
        
        [alertController addAction:cancel];
        [alertController addAction:buy];
        
        alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [self.navigationController presentViewController:alertController animated:true completion:nil];
        return;
    }
    
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [requestDic setValue:[msgDic valueForKey:MSG_GUID] forKey:@"guid"];
    [requestDic setValue:[msgDic valueForKey:MSG_ID] forKey:@"msg_id"];
    
    TranscriptionAPI* api = [[TranscriptionAPI alloc]initWithRequest:requestDic];
    [api callNetworkRequest:requestDic withSuccess:^(TranscriptionAPI *req, NSMutableDictionary *responseObject) {
        if ([[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You are charged $0.02 for Voice-To-Text" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            
            [alertController addAction:ok];
            
            alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
            [self.navigationController presentViewController:alertController animated:true completion:nil];
            
            MQTTReceivedData* data = [[MQTTReceivedData alloc]init];
            data.dataType = MQTTReceivedDataTypeTranscriptionStatusAndText;
            data.responseData = responseObject;
            data.errorType = 0;
            data.error = Nil;
            data.requestData = Nil;
            [[Engine sharedEngineObj]addMQTTReceivedDataEvent:data];
        }
    }failure:^(TranscriptionAPI *req, NSError *error) {
        
        NSMutableDictionary *errorResponseObject = [[NSMutableDictionary alloc] init];
        [errorResponseObject setValue:@"api_error" forKey:@"trans_status"];
        
        MQTTReceivedData* data = [[MQTTReceivedData alloc]init];
        data.dataType = MQTTReceivedDataTypeTranscriptionStatusAndText;
        data.responseData = errorResponseObject;
        data.errorType = 0;
        data.error = Nil;
        data.requestData = req.request;
        [[Engine sharedEngineObj]addMQTTReceivedDataEvent:data];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Network error!" message:@"Please, check your network and try agian." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        
        [alertController addAction:ok];
        
        alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [self.navigationController presentViewController:alertController animated:true completion:nil];
        
        
        EnLogd(@"*** Error fetching user contact: %@, %@",req,[error description]);
        KLog(@"*** Error fetching user contact: %@, %@",req,[error description]);
        
    }];
}

#pragma mark @ratingButtonTappedAtIndex
-(void)ratingButtonTappedAtIndex:(NSDictionary *)msgDic
{
    NSString *title = @"";
    if([[msgDic valueForKey:MSG_TYPE] isEqualToString:VSMS_TYPE])
        title = @"Please, rate the transcription quality of this Voicemail. It will help us transcribe better.";
    else
        title = @"Please, rate the transcription quality of this Voice message. It will help us transcribe better.";
    
    UIAlertController *rating = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    tempViewController = [[UIViewController alloc] init];
    tempViewController.preferredContentSize = CGSizeMake(300.0, 44.5);
    tempViewController.view.backgroundColor = [UIColor clearColor];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tempViewController.view.frame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor lightGrayColor];
    [tempViewController.view addSubview:topLine];
    
    starView1 = [[UIImageView alloc] initWithFrame:CGRectMake(65.0, 10.0, 24.0, 24.0)];
    starView1.image = [UIImage imageNamed:@"star_empty"];
    starView2 = [[UIImageView alloc] initWithFrame:CGRectMake(65.0 + 24.0 + 5.0, 10.0, 24.0, 24.0)];
    starView2.image = [UIImage imageNamed:@"star_empty"];
    starView3 = [[UIImageView alloc] initWithFrame:CGRectMake(65.0 + (24.0 * 2) + 10.0, 10.0, 24.0, 24.0)];
    starView3.image = [UIImage imageNamed:@"star_empty"];
    starView4 = [[UIImageView alloc] initWithFrame:CGRectMake(65.0 + (24.0 * 3) + 15.0, 10.0, 24.0, 24.0)];
    starView4.image = [UIImage imageNamed:@"star_empty"];
    starView5 = [[UIImageView alloc] initWithFrame:CGRectMake(65.0 + (24.0 * 4) + 20.0, 10.0, 24.0, 24.0)];
    starView5.image = [UIImage imageNamed:@"star_empty"];
    
    starView1.userInteractionEnabled = YES;
    starView2.userInteractionEnabled = YES;
    starView3.userInteractionEnabled = YES;
    starView4.userInteractionEnabled = YES;
    starView5.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapStar1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(starView1Tapped:)];
    [starView1 addGestureRecognizer:tapStar1];
    
    UITapGestureRecognizer *tapStar2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(starView2Tapped:)];
    [starView2 addGestureRecognizer:tapStar2];
    
    UITapGestureRecognizer *tapStar3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(starView3Tapped:)];
    [starView3 addGestureRecognizer:tapStar3];
    
    UITapGestureRecognizer *tapStar4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(starView4Tapped:)];
    [starView4 addGestureRecognizer:tapStar4];
    
    UITapGestureRecognizer *tapStar5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(starView5Tapped:)];
    [starView5 addGestureRecognizer:tapStar5];
    
    [tempViewController.view addSubview:starView1];
    [tempViewController.view addSubview:starView2];
    [tempViewController.view addSubview:starView3];
    [tempViewController.view addSubview:starView4];
    [tempViewController.view addSubview:starView5];
    
    transRating = 0;
    
    UIPanGestureRecognizer *swipeStarRatingRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(swipeStarRatingSetup:)];
    [tempViewController.view addGestureRecognizer:swipeStarRatingRecognizer];
    
    [rating setValue:tempViewController forKey:@"contentViewController"];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        
    }];
    
    submit = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        
        NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
        [requestDic setValue:[NSNumber numberWithInt:transRating] forKey:@"rating"];
        [requestDic setValue:[msgDic valueForKey:MSG_ID] forKey:@"msg_id"];
        [self showProgressBar];
        
        TranscriptionRatingAPI* api = [[TranscriptionRatingAPI alloc]initWithRequest:requestDic];
        [api callNetworkRequest:requestDic withSuccess:^(TranscriptionRatingAPI *req, NSMutableDictionary *responseObject) {
            if ([[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
                [self hideProgressBar];
                NSString *successMessage = @"";
                if([[msgDic valueForKey:MSG_TYPE] isEqualToString:VSMS_TYPE])
                    successMessage = @"Thank you for rating Voicemail transcription.";
                else
                    successMessage = @"Thank you for rating Voice message transcription.";
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:successMessage message:@"" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    
                }];
                
                [alertController addAction:ok];
                alertController.view.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
                [self.navigationController presentViewController:alertController animated:true completion:nil];
                
                NSMutableDictionary *rating = [[NSMutableDictionary alloc] init];
                [rating setValue:[NSNumber numberWithInt:transRating] forKey:@"transcription_rating"];
                [rating setValue:[responseObject valueForKey:@"msg_id"] forKey:@"msg_id"];
                [rating setValue:[responseObject valueForKey:@"cmd"] forKey:@"cmd"];
                MQTTReceivedData* data = [[MQTTReceivedData alloc]init];
                data.dataType = MQTTReceivedDataTypeTranscriptionStatusAndText;
                data.responseData = rating;
                data.errorType = 0;
                data.error = Nil;
                data.requestData = Nil;
                [[Engine sharedEngineObj]addMQTTReceivedDataEvent:data];
            }
        }failure:^(TranscriptionRatingAPI *req, NSError *error) {
            [self hideProgressBar];
            EnLogd(@"*** Error fetching user contact: %@, %@",req,[error description]);
            KLog(@"*** Error fetching user contact: %@, %@",req,[error description]);
            
        }];
        
    }];
    
    [submit setEnabled:NO];
    
    [rating addAction:cancel];
    [rating addAction:submit];
    rating.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
    [self presentViewController:rating animated:YES completion:nil];
}

-(void)swipeStarRatingSetup:(UIPanGestureRecognizer*)gesture
{
    if(gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gesture locationInView:tempViewController.view];
        if (translation.x > 0.0 && translation.x < 94.0) {
            transRating = 1;
            [submit setEnabled:YES];
            starView1.image = [UIImage imageNamed:@"star_filled"];
            starView2.image = [UIImage imageNamed:@"star_empty"];
            starView3.image = [UIImage imageNamed:@"star_empty"];
            starView4.image = [UIImage imageNamed:@"star_empty"];
            starView5.image = [UIImage imageNamed:@"star_empty"];
        }else if (translation.x > 94.0 && translation.x < 130.0) {
            transRating = 2;
            [submit setEnabled:YES];
            starView1.image = [UIImage imageNamed:@"star_filled"];
            starView2.image = [UIImage imageNamed:@"star_filled"];
            starView3.image = [UIImage imageNamed:@"star_empty"];
            starView4.image = [UIImage imageNamed:@"star_empty"];
            starView5.image = [UIImage imageNamed:@"star_empty"];
        }else if (translation.x > 130.0 && translation.x < 170.0) {
            transRating = 3;
            [submit setEnabled:YES];
            starView1.image = [UIImage imageNamed:@"star_filled"];
            starView2.image = [UIImage imageNamed:@"star_filled"];
            starView3.image = [UIImage imageNamed:@"star_filled"];
            starView4.image = [UIImage imageNamed:@"star_empty"];
            starView5.image = [UIImage imageNamed:@"star_empty"];
        }else if (translation.x > 170.0 && translation.x < 214.0) {
            transRating = 4;
            [submit setEnabled:YES];
            starView1.image = [UIImage imageNamed:@"star_filled"];
            starView2.image = [UIImage imageNamed:@"star_filled"];
            starView3.image = [UIImage imageNamed:@"star_filled"];
            starView4.image = [UIImage imageNamed:@"star_filled"];
            starView5.image = [UIImage imageNamed:@"star_empty"];
        }else if (translation.x > 214.0){
            transRating = 5;
            [submit setEnabled:YES];
            starView1.image = [UIImage imageNamed:@"star_filled"];
            starView2.image = [UIImage imageNamed:@"star_filled"];
            starView3.image = [UIImage imageNamed:@"star_filled"];
            starView4.image = [UIImage imageNamed:@"star_filled"];
            starView5.image = [UIImage imageNamed:@"star_filled"];
        }
    }
}

-(void)starView1Tapped:(UITapGestureRecognizer *)reco
{
    transRating = 1;
    [submit setEnabled:YES];
    starView1.image = [UIImage imageNamed:@"star_filled"];
    starView2.image = [UIImage imageNamed:@"star_empty"];
    starView3.image = [UIImage imageNamed:@"star_empty"];
    starView4.image = [UIImage imageNamed:@"star_empty"];
    starView5.image = [UIImage imageNamed:@"star_empty"];
}

-(void)starView2Tapped:(UITapGestureRecognizer *)reco
{
    transRating = 2;
    [submit setEnabled:YES];
    starView1.image = [UIImage imageNamed:@"star_filled"];
    starView2.image = [UIImage imageNamed:@"star_filled"];
    starView3.image = [UIImage imageNamed:@"star_empty"];
    starView4.image = [UIImage imageNamed:@"star_empty"];
    starView5.image = [UIImage imageNamed:@"star_empty"];
}

-(void)starView3Tapped:(UITapGestureRecognizer *)reco
{
    transRating = 3;
    [submit setEnabled:YES];
    starView1.image = [UIImage imageNamed:@"star_filled"];
    starView2.image = [UIImage imageNamed:@"star_filled"];
    starView3.image = [UIImage imageNamed:@"star_filled"];
    starView4.image = [UIImage imageNamed:@"star_empty"];
    starView5.image = [UIImage imageNamed:@"star_empty"];
}

-(void)starView4Tapped:(UITapGestureRecognizer *)reco
{
    transRating = 4;
    [submit setEnabled:YES];
    starView1.image = [UIImage imageNamed:@"star_filled"];
    starView2.image = [UIImage imageNamed:@"star_filled"];
    starView3.image = [UIImage imageNamed:@"star_filled"];
    starView4.image = [UIImage imageNamed:@"star_filled"];
    starView5.image = [UIImage imageNamed:@"star_empty"];
}

-(void)starView5Tapped:(UITapGestureRecognizer *)reco
{
    transRating = 5;
    [submit setEnabled:YES];
    starView1.image = [UIImage imageNamed:@"star_filled"];
    starView2.image = [UIImage imageNamed:@"star_filled"];
    starView3.image = [UIImage imageNamed:@"star_filled"];
    starView4.image = [UIImage imageNamed:@"star_filled"];
    starView5.image = [UIImage imageNamed:@"star_filled"];
}
#endif

#pragma mark -- TableView appearance and loading
-(void)loadData
{
    KLog1(@"CHECK ME");
    msgTextLabel.hidden = YES;
    chatView.hidden = NO;
    
    if(!isScrolling)
        [chatView reloadData];
    
    if([dicSections count]) {
        [self markReadMessagesFromThisList:nil];
    }
    
    //JUNE, 2017
    int unReadMsg = [[currentChatUserInfo valueForKey:UNREAD_MSG_COUNT]intValue];
    if(unReadMsg>0) {
        KLog(@"########## unread msg");
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:currentChatUserInfo];
        [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeSeenAllMsg withData:dic];
    }
    //
}

-(void)reloadAndScrollToSection:(long)sectionNumber
{
    if(sectionNumber>=0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:sectionNumber];
        [self.chatView scrollToRowAtIndexPath:indexPath
                             atScrollPosition:UITableViewScrollPositionTop
                                     animated:NO];
    }
}

-(void)scrollToBottom
{
    //KLog(@"scrollToBottom START");
    
    if([arrDatesSorted count]) {
        NSInteger lastSection = [arrDatesSorted count];
        if(lastSection)
            lastSection -= 1;
        long rowNumbers = [self.chatView numberOfRowsInSection:lastSection];
        /*
        NSDate* dtDate = [arrDatesSorted objectAtIndex:lastSection];
        NSArray* msgList = [dicSections objectForKey:dtDate];
        long rowNumbers = [msgList count];
        */
        if(rowNumbers>0) {
            rowNumbers -= 1;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowNumbers inSection:lastSection];
            [self.chatView scrollToRowAtIndexPath:indexPath
                                 atScrollPosition:UITableViewScrollPositionBottom
                                         animated:NO];
        }
    }
    
    //KLog(@"scrollToBottom END");
}

-(void)unloadData
{
    msgTextLabel.hidden =  NO;
    chatView.hidden     =  YES;
    msgTextLabel.text   =  NSLocalizedString(@"NO_MESSAGES",nil);
}

#pragma mark -- TableView Delegate and Datasource

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat tblWidth = self.chatView.frame.size.width;
    CGFloat vwX = (tblWidth - SECTION_WIDTH)/2;
    
    UIView* viewSectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 8, tblWidth, SECTION_HEIGHT)];
    viewSectionHeader.backgroundColor = [UIColor clearColor];
    UILabel* lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(vwX,
                                                        viewSectionHeader.frame.origin.y/2,
                                                        SECTION_WIDTH, SECTION_HEIGHT)];
    lbTitle.font = [UIFont boldSystemFontOfSize:12.0f];
    lbTitle.textColor = UIColorFromRGB(SECTION_TITLE_COLOR);
    lbTitle.backgroundColor = UIColorFromRGB(SECTION_BG_COLOR);
    lbTitle.textAlignment = NSTextAlignmentCenter;
    if(arrDatesSorted.count>0) {
        NSDate *dtDate = [arrDatesSorted objectAtIndex:section];
        lbTitle.text = [self getDateString:dtDate];
    }
    lbTitle.layer.masksToBounds = YES;
    lbTitle.layer.cornerRadius = 8.0;
    lbTitle.layer.borderWidth = 0.1;
    
    viewSectionHeader.layer.shadowColor = [[UIColor blackColor] CGColor];
    viewSectionHeader.layer.shadowOffset = CGSizeMake(0, 1.0);
    viewSectionHeader.layer.shadowRadius = 1.0f;
    viewSectionHeader.layer.shadowOpacity = 1.0f;
    
    [viewSectionHeader addSubview:lbTitle];

    return viewSectionHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEIGHT+12;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dicSections count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(arrDatesSorted.count>0) {
        NSDate* dtDate = [arrDatesSorted objectAtIndex:section];
        NSArray* msgList = [dicSections objectForKey:dtDate];
        return [msgList count];
    }
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(arrDatesSorted.count>0) {
        NSDate *dtDate = [arrDatesSorted objectAtIndex:section];
        return [self getDateString:dtDate];
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.getHeightForRows) {
        //NSLog(@"getHeightForRows");
        return [self tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    if([arrDatesSorted count]) {
        NSDate* dtDate = [arrDatesSorted objectAtIndex:indexPath.section];
        NSInteger secCount = [dicSections count];
        if(indexPath.section == (secCount-1)) {
            NSArray* msgList = [dicSections objectForKey:dtDate];
            if([msgList count]<=35) {
                return [self tableView:tableView heightForRowAtIndexPath:indexPath];
            }
        }
    }
    
    if( [arrDatesSorted count]) {
        NSDate* dtDate = [arrDatesSorted objectAtIndex:indexPath.section];
        NSArray* msgList = [dicSections objectForKey:dtDate];
        if([msgList count]) {
            NSMutableDictionary* dic = [msgList objectAtIndex:indexPath.row];
            NSString *msgContentType = [[dic valueForKey:MSG_CONTENT_TYPE] lowercaseString];
            NSString *msgSubType = [[dic valueForKey:MSG_SUB_TYPE] lowercaseString];
            NSString *type = [dic valueForKey:MSG_TYPE];
            NSString *flow = [dic valueForKey:MSG_FLOW];
            
            
            if([msgContentType isEqualToString:TEXT_TYPE])
            {
                if([type isEqualToString:MISSCALL])
                {
                    if([msgSubType isEqualToString:RING_MC])
                    {
                        if([flow isEqualToString:MSG_FLOW_R])
                            return 105.0;
                        else
                            return 110.0;
                    }
                    if(![[dic valueForKey:IS_EXPANDED]boolValue])
                        return 88.0;
                }
            }
            else if([msgContentType isEqualToString:AUDIO_TYPE])
            {
                if([msgSubType isEqualToString:AVS_TYPE] || [msgSubType isEqualToString:VSMS_TYPE]) {
                    return 110.0;
                }
                else {
                    return 97.0;//for voice msg
                }
            }
        }
    }
    
    //return 104.0;//average cell height
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //KLog(@"heightForRowAtIndexPath");
    NSMutableDictionary* dic = nil;
    if( [arrDatesSorted count])
    {
        //- Get the row's dic
        NSDate* dtDate = [arrDatesSorted objectAtIndex:indexPath.section];
        NSArray* msgList = [dicSections objectForKey:dtDate];
        if([msgList count]) {
            dic = [msgList objectAtIndex:indexPath.row];
        }
        
        if(nil == dic || 0 == [dic count])
        {
            EnLogd(@"Conversation dic is nil");
            KLog(@"##### ERROR: FIXME");
            return 0;
        }
        
        NSString *msgContentType = [[dic valueForKey:MSG_CONTENT_TYPE] lowercaseString];
        NSString *msgSubType = [[dic valueForKey:MSG_SUB_TYPE] lowercaseString];
        NSString *type = [dic valueForKey:MSG_TYPE];
        NSString *flow = [dic valueForKey:MSG_FLOW];
        
        if([msgSubType isEqualToString:GROUP_MSG_EVENT_TYPE])
        {
            return 4 * ptSizeFootnote;
        }
        else if([msgContentType isEqualToString:TEXT_TYPE])
        {
            if([type isEqualToString:MISSCALL])
            {
                if([msgSubType isEqualToString:RING_MC])
                {
                    if([flow isEqualToString:MSG_FLOW_R])
                        return 105;
                    else
                        return 110;
                }
                
                //- height for missed call
                if([[dic valueForKey:IS_EXPANDED]boolValue]) {
                    NSMutableArray *msgList = [dic valueForKey:MSG_LIST];
                    long count = [msgList count];//JUNE, 2017
                    NSString *fullString = @"Received on JAN 31 at 99:99 PM";
                    CGFloat mcTextsHeight = 18.0;
                    
                    //- Calculate height for single line text for a missed call and then multiple with count
                    if(count>=1) {
                        mcTextsHeight = ([ScreenUtility sizeOfString:fullString
                                                            withFont:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]].height) * count;
                    }
                    
                    return (mcTextsHeight + lhtCaption2 + lhtBody + 80);
                }
                else {
                    return SIZE_88;
                }
            }
            else if ([type isEqualToString:VOIP_TYPE] || [type isEqualToString:VOIP_OUT]) {
                return SIZE_120;
            }
            else
            {
                //- height for text message
                NSString *msgContent = [dic valueForKey:MSG_CONTENT];
                NSNumber *valueToCheck = [dic valueForKey:@"toShowMore"];
                msgLabel.text = msgContent;
                msgLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                if(msgContent.length > SHOW_MORE_LEN && (valueToCheck == nil || [valueToCheck intValue] == 1)) {
                    NSRange stringRange = {0, MIN(msgContent.length, SHOW_MORE_LEN)};
                    msgContent = [msgContent substringWithRange:stringRange];
                    msgLabel.text = [NSString stringWithFormat:@"%@....", msgContent];
                }
                
                CGSize stringSize;
                //Height calculations R&D Bhaskar Feb 7
                CGSize lableWidth = CGSizeMake(DEVICE_WIDTH - 80, CGFLOAT_MAX);
                CGSize neededSize = [msgLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
                stringSize = neededSize;
                stringSize.height += 20;
                
                /*
                BOOL vbBool = [[dic valueForKey:MSG_VB_POST] boolValue];
                BOOL isFwd = [[dic valueForKey:MSG_FORWARD] boolValue];
                BOOL isFwdMsg = FALSE;
                NSString *linkedOPR = [dic valueForKey:LINKED_OPR];
                if(isFwd || [linkedOPR isEqualToString:IS_FORWORD_MSG])
                {
                    isFwdMsg = TRUE;
                }
                if([[dic valueForKey:MSG_TYPE] isEqualToString:VB_TYPE])
                {
                    vbBool = NO;
                }*/
                
                if(/*fbBool || vbBool || twBool || isFwdMsg ||*/ (msgContent.length >= SHOW_MORE_LEN)) {
                    return stringSize.height + SIZE_45;
                } else {
                    if ([[dic valueForKey:CONVERSATION_TYPE] isEqualToString:GROUP_TYPE]) {
                        return stringSize.height + SIZE_37;
                    } else {
                        return stringSize.height + SIZE_30;
                    }
                }
            }
        }
        else if([msgContentType isEqualToString:AUDIO_TYPE])
        {
            //- height for voicemail message
            if([msgSubType isEqualToString:AVS_TYPE] || [msgSubType isEqualToString:VSMS_TYPE]) {
                /*
                 if([[dic valueForKey:MSG_ID]longLongValue] == 8452196) {
                 KLog(@"Debug");
                 }*/
                
#ifndef TRANSCRIPTION_ENABLED
                return 114;
#else
                if(![[dic valueForKey:IS_VOICE_TO_TEXT_HIDDEN]boolValue])
                    return 114;
                
                CGFloat deltaWidth = DELTA_WIDTH; //(DEVICE_WIDTH - 120 - 20)/DEVICE_WIDTH refer the XIB file for transTextView's width & -20 is the margins set on both left and right side of textview
                CGFloat tranViewWidth = DEVICE_WIDTH * deltaWidth;
                UITextView *voiceToText = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, tranViewWidth, 500)];
                voiceToText.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
                NSString* transcript = [dic valueForKey:MSG_TRANS_TEXT];
                if(transcript == nil)
                    transcript = @"";
                
                NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:transcript];
                UIFont *fontBoldConfidence = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];
                UIFont *fontRegularText = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
                
                NSString *quedString;
                if (!transcript.length) {
                    if ([[dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"]){
                        quedString = @"Sorry, Voice-To-Text is not available";
                    }else{
                        quedString = @"Voice-To-Text is in progress...";
                    }
                    attString=[[NSMutableAttributedString alloc] initWithString:quedString];
                    [attString addAttribute:NSFontAttributeName value:fontBoldConfidence range:NSMakeRange(0, quedString.length)];
                }else{
                    attString=[[NSMutableAttributedString alloc] initWithString:transcript];
                    if ([[dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"]){
                        quedString = @"Sorry, Voice-To-Text is not available";
                    }else{
                        quedString = @"Transcription Confidence: 5";
                    }
                    
                    [attString addAttribute:NSFontAttributeName value:fontBoldConfidence range:NSMakeRange(0, quedString.length)];
                    [attString addAttribute:NSFontAttributeName value:fontRegularText range:NSMakeRange(quedString.length, transcript.length - quedString.length)];
                }
                
                [voiceToText setAttributedText:attString];
                [voiceToText sizeToFit];
                
                int transRating = [[dic valueForKey:MSG_TRANS_RATING] intValue];
                
                if (transcript.length && transRating < 1)
                    return voiceToText.frame.size.height + 140 + deltaWidth;
                
                return voiceToText.frame.size.height + 115 + deltaWidth;
#endif
            }
            else {
#ifndef TRANSCRIPTION_ENABLED
                return 97;
#else
                
                if([[dic valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE])
                    return 97;
                
                if(![[dic valueForKey:IS_VOICE_TO_TEXT_HIDDEN]boolValue])
                    return 115;
                
                CGFloat deltaWidth = DELTA_WIDTH; //(DEVICE_WIDTH - 120 - 20)/DEVICE_WIDTH refer the XIB file for transTextView's width & -20 is the margins set on both left and right side of textview
                CGFloat tranViewWidth = DEVICE_WIDTH * deltaWidth;
                UITextView *voiceToText = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, tranViewWidth, 500)];
                voiceToText.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
                NSString* transcript = [dic valueForKey:MSG_TRANS_TEXT];
                if(transcript == nil)
                    transcript = @"";
                
                NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:transcript];
                UIFont *fontBoldConfidence = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];
                UIFont *fontRegularText = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
                
                NSString *quedString;
                if (!transcript.length) {
                    if ([[dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"]){
                        quedString = @"Sorry, Voice-To-Text is not available";
                    }else{
                        quedString = @"Voice-To-Text is in progress...";
                    }
                    attString=[[NSMutableAttributedString alloc] initWithString:quedString];
                    [attString addAttribute:NSFontAttributeName value:fontBoldConfidence range:NSMakeRange(0, quedString.length)];
                }else{
                    attString=[[NSMutableAttributedString alloc] initWithString:transcript];
                    if ([[dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"]){
                        quedString = @"Sorry, Voice-To-Text is not available";
                    }else{
                        quedString = @"Transcription Confidence: 5";
                    }
                    
                    [attString addAttribute:NSFontAttributeName value:fontBoldConfidence range:NSMakeRange(0, quedString.length)];
                    [attString addAttribute:NSFontAttributeName value:fontRegularText range:NSMakeRange(quedString.length, transcript.length - quedString.length)];
                }
                
                [voiceToText setAttributedText:attString];
                [voiceToText sizeToFit];
                
                int transRating = [[dic valueForKey:MSG_TRANS_RATING] intValue];
                
                if (transcript.length && transRating < 1)
                    return voiceToText.frame.size.height + 140 + deltaWidth;
                
                return voiceToText.frame.size.height + 115 + deltaWidth;
#endif
            }
        }
        else
        {
            //- height for image message
            /*
            if(![msgContentType isEqualToString:IMAGE_TYPE]) {
                NSLog(@"############# FIXME. %@",type);
            }*/
            
            float iHeight = [self getCellHeightForImageCell:dic];
            NSString* annotString = [[dic valueForKey:ANNOTATION] stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(annotString.length) {
                int annotLength = (int)[[dic valueForKey:ANNOTATION]length];
                int pointSize = (int)[UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize;
                CGFloat annotationViewHeight = [self annotationTextViewHeight:annotLength :pointSize];
                return (iHeight + (annotationViewHeight * 1.5));
            }
            else {
                return iHeight;
            }
        }
    }
    else {
        //NSLog(@"############# FIXME.");
        return 0;
    }
}

// To get exact height of image view while annotation text font size increases with system font
- (CGFloat)annotationTextViewHeight:(int)stringLength :(int)fontPointSize
{
    /*
     Font Point Size - Number of charactors in one line
     53 - 6
     47 - 7
     40 - 8
     33 - 10
     28 - 11
     23 - 14
     21 - 15
     19 - 17
     17 - 19
     16 - 21
     15 - 22
     14 - 23
    */
    int numberOfLines = 0;
    CGFloat annoTationHeight = 0.0;
    switch (fontPointSize) {
        case 53:
            numberOfLines = stringLength/6;
            annoTationHeight = (53*numberOfLines) + 5;
            break;
        case 47:
            numberOfLines = stringLength/7;
            annoTationHeight = (47*numberOfLines) + 5;
            break;
        case 40:
            numberOfLines = stringLength/8;
            annoTationHeight = (40*numberOfLines) + 5;
            break;
        case 33:
            numberOfLines = stringLength/10;
            annoTationHeight = (33*numberOfLines) + 5;
            break;
        case 28:
            numberOfLines = stringLength/11;
            annoTationHeight = (28*numberOfLines) + 5;
            break;
        case 23:
            numberOfLines = stringLength/14;
            annoTationHeight = (23*numberOfLines) + 5;
            break;
        case 21:
            numberOfLines = stringLength/15;
            annoTationHeight = (21*numberOfLines) + 5;
            break;
        case 19:
            numberOfLines = stringLength/17;
            annoTationHeight = (19*numberOfLines) + 5;
            break;
        case 17:
            numberOfLines = stringLength/19;
            annoTationHeight = (17*numberOfLines) + 5;
            break;
        case 16:
            numberOfLines = stringLength/21;
            annoTationHeight = (16*numberOfLines) + 5;
            break;
        case 15:
            numberOfLines = stringLength/22;
            annoTationHeight = (15*numberOfLines) + 5;
            break;
        case 14:
            numberOfLines = stringLength/23;
            annoTationHeight = (14*numberOfLines) + 5;
            break;
        
            
        default:
            break;
    }
    return annoTationHeight;
}

// called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    KLog(@"scrollViewDidEndDecelerating");
    [self performSelectorOnMainThread:@selector(updateData) withObject:nil waitUntilDone:NO];
}

-(void)updateData {
    
    if(recvdNewMsg) {
        KLog(@"New Msg");
        recvdNewMsg = FALSE;
        [self.chatView reloadData];
    }
    if(sendNewMsg) {
        sendNewMsg = FALSE;
        //NSLog(@"calling scrollToBottom...");
        [self scrollToBottom];
    }

    if(self.getHeightForRows)
        self.getHeightForRows = NO;
    isScrolling = FALSE;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    isScrolling = FALSE;
    
    if (!keyboardHide)
        [self toolBarFrame];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isScrolling = TRUE;
    NSString * remoteUserType = [currentChatUserInfo valueForKey:REMOTE_USER_TYPE];
    if([remoteUserType isEqualToString:CELEBRITY_TYPE] && !_allowMessaging) {
        self.chatView.contentInset = UIEdgeInsetsZero;
        self.chatView.scrollIndicatorInsets = UIEdgeInsetsZero;
        return;
    }
    
    if([self isAudioRecording]){
        self.chatView.contentInset = UIEdgeInsetsMake(0, 0, (height == 0?45.0:height) - (isiPhoneX?35.0:0.0) + recordingView.frame.size.height, 0);
        self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,(height == 0?45.0:height) - (isiPhoneX?35.0:0.0) + recordingView.frame.size.height, 0);
    }
}

-(float)getCellHeightForImageCell:(NSMutableDictionary*)imageDic
{
    NSString* msgLocalPath = [imageDic valueForKey:MSG_LOCAL_PATH];
    if(!msgLocalPath || msgLocalPath.length == 0)
    {
        msgLocalPath = [[imageDic valueForKey:MSG_ID]stringValue];//MAY 8, 2017 TODO: Test
    }
    
    //TODO: later
    NSString* extn = nil;
    @try {
        extn = [msgLocalPath pathExtension];
    }@catch(...) {
        //NSLog(@"Debug");
    }
    NSString* localPath = msgLocalPath;
    if(extn == nil || extn.length < 2)
    {
        @try {
            localPath = [msgLocalPath stringByAppendingPathExtension:@"jpg"];
        } @catch(...) {
            //NSLog(@"Debug");
        }
    }
    //
    
    localPath = [IVFileLocator getMediaImagePath:localPath];
    CGSize size = [IVImageUtility getImageDimensions:localPath];
    if(size.height < 1 || size.width < 1)
    {
        NSString *msgContent = [imageDic valueForKey:MSG_CONTENT];
        if(msgContent != nil) {
            NSData *data = [msgContent dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *imageData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSMutableArray* imageArr = [imageData valueForKey:@"img"];
            for(NSMutableDictionary* imageDic in imageArr)
            {
                if([imageDic valueForKey:@"url_height"])
                    size.height = [[imageDic valueForKey:@"url_height"]floatValue];
                if([imageDic valueForKey:@"url_width"])
                    size.width = [[imageDic valueForKey:@"url_width"]floatValue];
            }
        }
    }
    
    if(size.height == 0 || size.width == 0)
        return 245;
    
    return  MAX(245, 245*(size.height/size.width));
}

//Override the delegate Method of tableView:To insert the value in each row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self getCurrentCellTypeForRowAtIndexPath:indexPath];
    ConversationTableCell* cell = nil;
    
    if([cellIdentifier isEqualToString:@"ConversationTableCellTextSender"] ||
       [cellIdentifier isEqualToString:@"ConversationTableCellTextReceiver"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    }
    
    NSDate *dtDate = [arrDatesSorted objectAtIndex:indexPath.section];
    NSMutableArray *msgList = [dicSections objectForKey:dtDate];
    NSMutableDictionary* dic = [msgList objectAtIndex:indexPath.row];
    
    if(cell != nil &&
       ([cellIdentifier isEqualToString:@"ConversationTableCellTextSender"] ||
        [cellIdentifier isEqualToString:@"ConversationTableCellTextReceiver"])) {
           if ([cell.contentView subviews]){
               for (UIView *subview in [cell.contentView subviews]) {
                   [subview removeFromSuperview];
               }
           }
           cell = nil;
    }

    if(cell != nil && ([cellIdentifier isEqualToString:@"ConversationTableCellMissedCallReceiver"]||
                            [cellIdentifier isEqualToString:@"ConversationTableCellMissedCallSender"] ||
                            [cellIdentifier isEqualToString:@"ConversationTableCellRingMCReceiver"] ||
                            [cellIdentifier isEqualToString:@"ConversationTableCellRingMCSender"] ||
                            [cellIdentifier isEqualToString:@"ConversationTableCellImageReceiver"] ||
                            [cellIdentifier isEqualToString:@"ConversationTableCellReachMeCallReceiver"] ||
                            [cellIdentifier isEqualToString:@"ConversationTableCellReachMeCallSender"]
                            )) {
        if([cell.contentView subviews]) {
            for(UIView* tView in [cell.contentView subviews]) {
                if(tView.tag == TICK_VIEW_ID || tView.tag == FROMTO_LBL_TAG || tView.tag == LOCATION_LBL_TAG)
                    [tView removeFromSuperview];
            }
        }
    }
    
    if (cell == nil)
    {
        //KLog(@"BaseConv. Empty cell for %@",cellIdentifier);
        @try {
            cell = [[NSClassFromString(cellIdentifier) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        } @catch (NSException *exception) {
            KLog(@"Exception thrown: %@",exception);
            EnLogd(@"Exception thrown: %@",exception);//What to do?
            return nil;
        }
    } else {
        [cell imageSetup];
    }
    
    if(cell) {
        cell.baseConversationObj = self;//TODO
        cell.delegate = self;
        cell.dic = dic;
        cell.cellIndex = indexPath;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell contentView].backgroundColor = [UIColor clearColor];
        [cell configureCellForConversationListArray:msgList cellForRowAtIndexPath:indexPath idType:self withAddingEmptyCell:false];
    }
    else {
        EnLogd(@"***ERROR: cell is empty.");
    }

    activeIndexChatView = indexPath;
    [cell layoutIfNeeded];
    return cell;
}


-(NSString*)getCurrentCellTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellAudioReceiver = @"ConversationTableCellAudioReceived";
    static NSString *cellAudioSender = @"ConversationTableCellAudioSent";
    static NSString *cellTextReceiver = @"ConversationTableCellTextReceiver";
    static NSString *cellTextSender = @"ConversationTableCellTextSender";
    static NSString *cellImageReceiver = @"ConversationTableCellImageReceiver";
    static NSString *cellImageSender = @"ConversationTableCellImageSender";
    static NSString *cellMissedCallReceiver = @"ConversationTableCellMissedCallReceiver";
    static NSString *cellMissedCallSender = @"ConversationTableCellMissedCallSender";
    static NSString *cellRingMCReceiver = @"ConversationTableCellRingMCReceiver";
    static NSString *cellRingMCSender = @"ConversationTableCellRingMCSender";
    static NSString *cellVoicemailReceiver = @"ConversationTableCellVMailReceived";
    static NSString *cellVoicemailReceiverNoTrans = @"ConversationTableCellVMailReceivedNoTrans";
    static NSString *cellVoicemailSender = @"ConversationTableCellVMailSent";
    static NSString *cellVoicemailSenderNoTrans = @"ConversationTableCellVMailSentNoTrans";
    static NSString *cellGroupInfo = @"GroupChatEventCell";
    static NSString *cellReachMeReceiver = @"ConversationTableCellReachMeCallReceiver";
    static NSString *cellReachMeSender = @"ConversationTableCellReachMeCallSender";
    
#ifdef TRANSCRIPTION_ENABLED
    static NSString *cellAudioSenderTrans = @"ConversationTableCellAudioSentTrans";
    static NSString *cellAudioReceiverTrans = @"ConversationTableCellAudioReceivedTrans";
#endif
    
    NSDate* dtDate=nil;
    NSArray* msgList=nil;
    NSMutableDictionary *dic=nil;
    if(arrDatesSorted.count>0) {
        dtDate = [arrDatesSorted objectAtIndex:indexPath.section];
        msgList = [dicSections objectForKey:dtDate];
        dic = [msgList objectAtIndex:indexPath.row];
    } else {
        //TODO FIXME; Returning nil will lead to a crash.
        //Display a proper msg to the user to exit the app gracefully. Cannot recover from this error.
        return nil;
    }
    
    if(dic != nil || [dic count] > 0)
    {
        NSString *flowMsg = [dic valueForKey:MSG_FLOW];
        NSString *msgContentType = [[dic valueForKey:MSG_CONTENT_TYPE] lowercaseString];
        NSString *msgSubType = [[dic valueForKey:MSG_SUB_TYPE] lowercaseString];
        NSString *mesgType = [[dic valueForKey:MSG_TYPE] lowercaseString];
        NSString *transScript = [dic valueForKey:ANNOTATION];
        
#ifdef TRANSCRIPTION_ENABLED
        SettingModel *currentSettingsModel = [Setting sharedSetting].data;
#endif
        if([msgSubType isEqualToString:GROUP_MSG_EVENT_TYPE])
        {
            return cellGroupInfo;
        }
        else if ([flowMsg isEqualToString:RECEIVER_TYPE] && [mesgType isEqualToString:VSMS_TYPE] &&
                 [msgContentType isEqualToString:AUDIO_TYPE])
        {
#ifndef TRANSCRIPTION_ENABLED
            return cellVoicemailReceiverNoTrans;
#else
            if (currentSettingsModel.userManualTrans) {
                return cellVoicemailReceiver;
            }else{
                if(transScript.length || [[dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"])
                    return cellVoicemailReceiver;
                else
                    return cellVoicemailReceiverNoTrans;
            }
#endif
        }
        else if ([flowMsg isEqualToString:SENDER_TYPE] && [mesgType isEqualToString:VSMS_TYPE] &&
                 [msgContentType isEqualToString:AUDIO_TYPE])
        {
            if([msgSubType isEqualToString:AVS_TYPE] || [msgSubType isEqualToString:VSMS_TYPE]) {
                
#ifndef TRANSCRIPTION_ENABLED
                return cellVoicemailSenderNoTrans;
#else
                if (currentSettingsModel.userManualTrans) {
                    return cellVoicemailSender;
                }else{
                    if(transScript.length || [[dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"])
                        return cellVoicemailSender;
                    else
                        return cellVoicemailSenderNoTrans;
                }
#endif
            }else{
#ifndef TRANSCRIPTION_ENABLED
                return cellAudioSender;
#else
                
                if (([mesgType isEqualToString:VB_TYPE]) || ([mesgType isEqualToString:NOTES_TYPE])) {
                    return cellAudioSender;
                }
                
                long transMsgId  = [[dic valueForKey:MSG_ID] longLongValue];
                NSString *msgID = nil;
                if(transMsgId>0)
                    msgID = [[NSNumber numberWithLong:transMsgId] stringValue];
                if(!msgID.length)
                    return cellAudioSender;
                
                if (currentSettingsModel.userManualTrans) {
                    return cellAudioSenderTrans;
                }else{
                    if(transScript.length || [[dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"])
                        return cellAudioSenderTrans;
                    else
                        return cellAudioSender;
                }
#endif
            }
        }
        else if([flowMsg isEqualToString:RECEIVER_TYPE] && ([msgContentType isEqualToString:AUDIO_TYPE]))
        {
#ifndef TRANSCRIPTION_ENABLED
            return cellAudioReceiver;
#else
            if([[dic valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE])
                return cellAudioReceiver;
            
            if (currentSettingsModel.userManualTrans) {
                return cellAudioReceiverTrans;
            }else{
                if(transScript.length || [[dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"])
                    return cellAudioReceiverTrans;
                else
                    return cellAudioReceiver;
            }
#endif
        }
        else if([flowMsg isEqualToString:SENDER_TYPE] && [msgContentType isEqualToString:AUDIO_TYPE])
        {
#ifndef TRANSCRIPTION_ENABLED
            return cellAudioSender;
#else
            if (([mesgType isEqualToString:VB_TYPE]) || ([mesgType isEqualToString:NOTES_TYPE])) {
                return cellAudioSender;
            }
            
            long transMsgId  = [[dic valueForKey:MSG_ID] longLongValue];
            NSString *msgID = nil;
            if(transMsgId>0)
                msgID = [[NSNumber numberWithLong:transMsgId] stringValue];
            if(!msgID.length)
                return cellAudioSender;
            
            if (currentSettingsModel.userManualTrans) {
                return cellAudioSenderTrans;
            }else{
                if(transScript.length || [[dic valueForKey:MSG_TRANS_STATUS] isEqualToString:@"e"])
                    return cellAudioSenderTrans;
                else
                    return cellAudioSender;
            }
#endif
        }
        else if([flowMsg isEqualToString:RECEIVER_TYPE] && ([msgContentType isEqualToString:IMAGE_TYPE]))
        {
            return cellImageReceiver;
        }
        else if([flowMsg isEqualToString:SENDER_TYPE] && [msgContentType isEqualToString:IMAGE_TYPE])
        {
            return cellImageSender;
        }
        else if ([flowMsg isEqualToString:RECEIVER_TYPE] && [mesgType isEqualToString:MISSCALL])
        {
            if([msgSubType isEqualToString:RING_MC])
                return cellRingMCReceiver;
            else
                return cellMissedCallReceiver;
        }
        else if ([flowMsg isEqualToString:SENDER_TYPE] && [mesgType isEqualToString:MISSCALL])
        {
            if([msgSubType isEqualToString:RING_MC])
                return cellRingMCSender;
            else
                return cellMissedCallSender;
        }
        else if([flowMsg isEqualToString:RECEIVER_TYPE] && [msgContentType isEqualToString:TEXT_TYPE])
        {
            if([mesgType isEqualToString:VOIP_TYPE] || [mesgType isEqualToString:VOIP_OUT])
                return cellReachMeReceiver;
            
            return cellTextReceiver;
        }
        else if([flowMsg isEqualToString:SENDER_TYPE] && [msgContentType isEqualToString:TEXT_TYPE])
        {
            if([mesgType isEqualToString:VOIP_OUT])
                return cellReachMeSender;
            
            return cellTextSender;
        }
        else
        {
            return nil;
        }
    }
    return nil;//SHOULD NOT HAPPEN
}

- (void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

/*MAY 2017
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    KLog(@"didEndDisplayingCell");
    //NSLog(@"didEndDisplayingCell");
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) {
        if(self.getHeightForRows) {
            self.getHeightForRows = NO;
        }
    }
}
*/

//- Call this method when keyboardWillAppear was not called,
//   esp. when app enters to foreground with keyboard open
-(void)updateTableView
{
    //Bhaskar --> no need to update the table frame as keyboardwillshow will get called and table contents will update
    
//    KLog(@"updateTableView");
//    CGRect tableViewFrame = tableViewFrameWhileLoading;
//    tableViewFrame.size.height = tableViewFrame.size.height - _kbSheetSize.height ;
//    
//    chatView.frame = tableViewFrame;
    isKeyboardPresent = YES;
    //DC
    //OCT 18, 2016 ;
    //[self performSelectorOnMainThread:@selector(updateTextViewSize) withObject:nil waitUntilDone:NO];
}

#pragma mark -- Text message setup and sending

-(void)alignTextField:(NSUInteger)newLength
{
    if (newLength > 0) {
        [UIView animateWithDuration:0.15 animations:^{
            sendImageCameraButton1.alpha = 0;
            sendImageGalleryButton1.alpha = 0;
            micButtonView1.alpha = 0;
            micButtonView1.hidden = YES;
            sendTextButton1.hidden = NO;
            sendTextButton1.alpha = 1;
            
            [recordingArea1 bringSubviewToFront:sendTextButton1];
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.15 animations:^{
            [self hideSendButtonOnNilText];
            
        }];
    }
}

#pragma mark -- UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string
{
    if ([textView.text isEqualToString:@""]) {
        [UIView animateWithDuration:0.15 delay:0.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self hideSendButtonOnNilText];
        }completion:nil];
        isPasteDone = NO;
        
        [UIView animateWithDuration:0.15 animations:^{
            [self inputAccessoryViewFrame];
            hasExpanded = NO;
            
        }];
    }
    
    NSUInteger newLength = [text1.text length] + [string length] - range.length;
    
    if (newLength > MAX_TEXT_SIZE)
    {
        UIAlertController *textLimit = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"TEXT_MSG_LIMIT",nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [textLimit addAction:ok];
        [self.navigationController presentViewController:textLimit animated:YES completion:nil];
        
        //Crash Fix
        //[ScreenUtility showAlert:NSLocalizedString(@"TEXT_MSG_LIMIT",nil)];
        
        return 0;
    }
    else
        return 1;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    [text1 resignFirstResponder];
    return YES;
}

-(void) adjustFrames:(UITextView *)textView
{
    CGRect textFrame = textView.frame;
    textFrame.size.height = textView.contentSize.height;
    textView.frame = textFrame;
}

-(void)toolBarFrame
{
//    [UIView animateWithDuration:0.15 animations:^{
//        if(frame.origin.y != 0.0)
//            containerView.frame = frame;
//    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self toolBarFrame];
    [containerView reloadInputViews];
    keyboardHide = NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self textViewFrameChange];
}

- (void)textViewFrameChange
{
    text1.scrollEnabled = YES;
    text1.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSString *rawString = text1.text;
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    NSArray *whiteSpaceArray = [text1.text componentsSeparatedByCharactersInSet:whitespace];
    
    if ([trimmed isEqualToString:@"\U0000fffc"]) {
        
        if (!([whiteSpaceArray count] > 0)) {
            
            [self hideSendButtonOnNilText];
            
            [UIView animateWithDuration:0.15 animations:^{
                [self inputAccessoryViewFrame];
                hasExpanded = NO;
            }];
        }
    }
    else if ([trimmed length]) {
        
        if (!hasExpanded) {
            hasExpanded = YES;
            text1.frame = CGRectMake(TEXTVIEW_XPOS, TEXTVIEW_YPOS, TEXTVIEW_WIDTH_WITH_TEXT, text1.frame.size.height);
        }
        
        CGFloat fixedWidth = text1.frame.size.width;
        CGSize newSize = [text1 sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = text1.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        
        if (maxTextViewHeight > newSize.height + 14.0) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self adjustFrames:text1];
                [UIView animateWithDuration:0.15 animations:^{
                    
//                    text1.frame = CGRectMake(TEXTVIEW_XPOS, TEXTVIEW_YPOS, TEXTVIEW_WIDTH_WITH_TEXT, text1.frame.size.height);
//                    containerView.frame = CGRectMake(CONTAINERVIEW_XPOS, - newSize.height + 31.0, DEVICE_WIDTH, newSize.height + 14.0);
//                    frame = containerView.frame;
                }completion:^(BOOL finished) {
                    CGPoint bottomOffset = CGPointMake(0, text1.contentSize.height - text1.frame.size.height);
                    [text1 setContentOffset:bottomOffset];
                }];
            });
        }
        else {
            if (!isPasteDone) {
                isPasteDone = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.15 animations:^{
                        [self adjustFrames:text1];
                        text1.frame = CGRectMake(TEXTVIEW_XPOS, TEXTVIEW_YPOS, newFrame.size.width, (maxTextViewHeight));
                    } completion:nil];
                });
            }
        }
        
        sendImageCameraButton1.alpha = 0;
        sendImageGalleryButton1.alpha = 0;
        micButtonView1.alpha = 0;
        micButtonView1.hidden = YES;
        sendTextButton1.hidden = NO;
        sendTextButton1.alpha = 1;
        
        [recordingArea1 bringSubviewToFront:sendTextButton1];
        
    }else if ([whiteSpaceArray count] > 1) {
        
        [UIView animateWithDuration:0.15 delay:0.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self hideSendButtonOnNilText];
        }completion:nil];
        
        
        CGFloat fixedWidth = text1.frame.size.width;
        CGSize newSize = [text1 sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = text1.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        
        if (maxTextViewHeight > newSize.height + 14.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self adjustFrames:text1];
                [UIView animateWithDuration:0.15 animations:^{
                    //[self adjustFrames:text1];
//                    containerView.frame = CGRectMake(CONTAINERVIEW_XPOS, - newSize.height + 31.0, DEVICE_WIDTH, newSize.height + 14.0);
//                    text1.frame = CGRectMake(TEXTVIEW_XPOS, TEXTVIEW_YPOS, TEXTVIEW_WIDTH_WITHOUT_TEXT, text1.frame.size.height);
//                    frame = containerView.frame;
                    hasExpanded = NO;
                    isPasteDone = NO;
                }];
            });
        
        }else{
            isPasteDone = YES;
        }
        
        [UIView animateWithDuration:0.15 animations:^{
            if (hasExpanded) {
                if (text1.frame.size.height == 31) {
                    text1.frame = CGRectMake(TEXTVIEW_XPOS, TEXTVIEW_YPOS, TEXTVIEW_WIDTH_WITHOUT_TEXT, TEXTVIEW_CONSTANT_HEIGHT);
                }
                hasExpanded = NO;
            }
            
            text1.frame = CGRectMake(TEXTVIEW_XPOS, TEXTVIEW_YPOS, TEXTVIEW_WIDTH_WITHOUT_TEXT, text1.frame.size.height);
            
        }completion:nil];
        
    } else {
        
        [UIView animateWithDuration:0.15 delay:0.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self hideSendButtonOnNilText];
            hasExpanded = NO;
        } completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.15 animations:^{
                [self inputAccessoryViewFrame];
                hasExpanded = NO;
                isPasteDone = NO;
            }];
        });
    }
    
    if([arrDatesSorted count]) {
        CGFloat height2 = chatView.frame.size.height;
        CGFloat contentYoffset = chatView.contentOffset.y;
        CGFloat distanceFromBottom = chatView.contentSize.height - contentYoffset + text1.frame.size.height + 14.0;
        
        NSDate* dtDate = [arrDatesSorted objectAtIndex:[arrDatesSorted count]-1];
        NSArray* msgList = [dicSections objectForKey:dtDate];
        NSIndexPath* indexPath = nil;
        if([msgList count]) {
            indexPath = [NSIndexPath indexPathForRow:[msgList count]-1 inSection:[arrDatesSorted count]-1];
        }
        
        CGRect rowHeight = [self.chatView rectForRowAtIndexPath:indexPath];
        CGFloat lastRowHeight = rowHeight.size.height;
        
        if(distanceFromBottom < (height2 + lastRowHeight - height + 45.0))
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!keyboardHide) {
                    
                    if([[currentChatUserInfo valueForKey:REMOTE_USER_TYPE] isEqualToString:CELEBRITY_TYPE] && !_allowMessaging) {
                        self.chatView.contentInset = UIEdgeInsetsZero;
                        self.chatView.frame = self.view.bounds;
                    }else{
                        [UIView animateWithDuration:0.15 animations:^{
                            self.chatView.contentInset = UIEdgeInsetsMake(0, 0, (height == 0?45.0:height) - (isiPhoneX?35.0:0.0), 0);
                            self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,(height == 0?45.0:height) - (isiPhoneX?35.0:0.0), 0);
                            
                            CGPoint pointsFromTop = CGPointMake(0, chatView.contentSize.height - chatView.frame.size.height + height);

                            if(pointsFromTop.y >= 45.0)
                                [chatView setContentOffset:pointsFromTop];
                            
                            //[self scrollToBottom];
                        }];
                    }
                }
            });
        }
    }
}

- (void)inputAccessoryViewFrame
{
    NSString *rawString = text1.text;
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    text1.scrollEnabled = NO;
    containerView.frame = CGRectMake(CONTAINERVIEW_XPOS, CONTAINERVIEW_YPOS, CONTAINERVIEW_WIDTH, CONTAINERVIEW_HEIGHT);
    text1.frame = CGRectMake(TEXTVIEW_XPOS, TEXTVIEW_YPOS, trimmed.length?TEXTVIEW_WIDTH_WITH_TEXT:TEXTVIEW_WIDTH_WITHOUT_TEXT, TEXTVIEW_CONSTANT_HEIGHT);
    micButtonView1.frame = CGRectMake(MIC_BUTTON_VIEW_XPOS, MIC_BUTTON_VIEW_YPOS, MIC_BUTTON_VIEW_WIDTH, MIC_BUTTON_VIEW_HEIGHT);
    if (trimmed.length) {
        sendImageCameraButton1.alpha = 0;
        sendImageGalleryButton1.alpha = 0;
        micButtonView1.alpha = 0;
        micButtonView1.hidden = YES;
        sendTextButton1.hidden = NO;
        sendTextButton1.alpha = 1;
        [recordingArea1 bringSubviewToFront:sendTextButton1];
    }
    
}

- (void)hideSendButtonOnNilText
{
    sendImageCameraButton1.hidden = NO;
    sendImageGalleryButton1.hidden = NO;
    micButtonView1.hidden = NO;
    sendImageCameraButton1.alpha = 1;
    sendImageGalleryButton1.alpha = 1;
    micButtonView1.alpha = 1;
    sendTextButton1.hidden = YES;
    sendTextButton1.alpha = 0;
}

- (void)userDidTapScreen:(UITapGestureRecognizer *)recognizer {
    
    KLog(@"userDidTapScreen");

    BOOL isAudioViewClicked=NO;
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint swipeLocation = [recognizer locationInView:chatView];
        NSIndexPath *swipedIndexPath = [self.chatView indexPathForRowAtPoint:swipeLocation];
        UITableViewCell* swipedCell = [self.chatView cellForRowAtIndexPath:swipedIndexPath];
        for(UIView* vw in [swipedCell.contentView subviews]) {
            //KLog(@"vw.tag = %ld",vw.tag);
            if(vw.tag == 987689) {
                CGPoint point = [vw convertPoint:swipeLocation fromView:chatView];
                if (CGRectContainsPoint(vw.bounds, point)) {
                    //KLog(@"YES..Within range");
                    isAudioViewClicked = YES;
                }
            }
        }
    }
    
    if(!isAudioViewClicked)
    {
        [text1 resignFirstResponder];
    }

    if(!self.sharingMenuView.hidden) {
        [self removeSharingMenuView:recognizer];
    }
}

//Function: Send text message
-(IBAction)sendText:(id)sender
{
    KLog(@"Send Text Button Pressed");
    if(_msgLimitExceeded)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"VSMS_LIMIT", nil)];
        [micButtonView1 removeGestureRecognizer:panRecognizer];
    }
    else
    {
        NSString* msgTextString = text1.text;
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        long len = [msgTextString length];
        if(msgTextString != nil && len > SIZE_0)
        {
            msgTextString = [msgTextString stringByTrimmingCharactersInSet:set];
            text1.text = nil;
            len =  [msgTextString length];
            if( len > SIZE_0 )
            {
                long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * SIZE_1000);
                NSNumber *date = [NSNumber numberWithLongLong:milliseconds];
                EnLogi(@"msg = %@",msgTextString);
                NSMutableDictionary *conversationDic =  nil;
                if (len > MAX_TEXT_SIZE )
                {
                    [ScreenUtility showAlert:NSLocalizedString(@"TEXT_MSG_LIMIT",nil)];
                }
                else
                {
                    conversationDic=[[NSMutableDictionary alloc]init];
                    [conversationDic setValue:date forKey:MSG_DATE];
                    [conversationDic setValue:SENDER_TYPE forKey:MSG_FLOW];
                    [conversationDic setValue:TEXT_TYPE forKey:MSG_CONTENT_TYPE];
                    if(_displayLoc)
                    {
                        if(location != nil)
                        {
                            [conversationDic setValue:[[NSNumber numberWithFloat:location.coordinate.latitude] stringValue] forKey:LATITUDE];
                            [conversationDic setValue:[[NSNumber numberWithFloat:location.coordinate.longitude] stringValue] forKey:LONGITUTE];
                        }
                        if(locationName != nil)
                        {
                            [conversationDic setValue:locationName forKey:LOCATION_NAME];
                        }
                    }
                    [conversationDic setValue:msgType forKey:MSG_TYPE];
                    if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE)
                        [conversationDic setValue:API_NETUNAVAILABLE forKey:MSG_STATE];
                    else
                        [conversationDic setValue:API_INPROGRESS forKey:MSG_STATE];
                    [conversationDic setValue:msgTextString forKey:MSG_CONTENT];
                    [self sendMessageToServer:conversationDic];
                    KLog(@"SendText END");
                }
            }
            else {
                [self resignTextResponder];
                if(NOTES_SCREEN==self.uiType) {
                    [ScreenUtility showAlertMessage:@"Blank Note cannot be saved"];
                }
                else {
                    [ScreenUtility showAlertMessage:NSLocalizedString(@"EMPTY_STRING",nil)];
                }
            }
        }
        else
        {
            [self resignTextResponder];
            if(NOTES_SCREEN==self.uiType) {
                [ScreenUtility showAlertMessage:@"Blank Note cannot be saved"];
            }
            else {
                [ScreenUtility showAlertMessage:NSLocalizedString(@"EMPTY_STRING",nil)];
            }
        }
    }
    
    hasExpanded = NO;
    isPasteDone = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self hideSendButtonOnNilText];
        
        [UIView animateWithDuration:0.15 animations:^{
            [self inputAccessoryViewFrame];
            self.chatView.contentInset = UIEdgeInsetsMake(0, 0, height - (isiPhoneX?35.0:0.0), 0);
            self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, height - (isiPhoneX?35.0:0.0), 0);
        }];
        
        if(_msgLimitExceeded)
        {
            [self textViewFrameChange];
        }
    });
    
}

#pragma mark -- Image Capture and Send
-(IBAction)captureImageClicked:(id)sender
{
    [text1 resignFirstResponder];
    text1.text = @"";
    [self inputAccessoryViewFrame];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self presentImageSendingViewControllerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        [ScreenUtility showAlertMessage:@"Camera is not available"];
    }
    tableViewFrameForImage = chatView.frame;
}

-(IBAction)shareImageClicked:(id)sender
{
    [text1 resignFirstResponder];
    text1.text = @"";
    [self inputAccessoryViewFrame];
    
    UIActionSheet* _addImageSheet = Nil;
    _addImageSheet = [[UIActionSheet alloc]initWithTitle:@"Image Selection" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Photo Library",@"Saved Photos Album", nil];
    [_addImageSheet showFromRect:CGRectMake(0, 0, 100, 100) inView:self.view animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self presentImageSelectionViewOnUserSelection:buttonIndex];
    tableViewFrameForImage = chatView.frame;
}

-(void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [self presentImageSelectionViewOnUserSelection:-1];
    chatView.frame = tableViewFrameForImage;
}

-(void)presentImageSelectionViewOnUserSelection:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType = 0;
    
    BOOL presentView = YES;
    switch (buttonIndex) {
        case 0:
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 1:
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            break;
        default:
            presentView = NO;
            break;
    }
    if(presentView)
    {
        [self presentImageSendingViewControllerWithSourceType:sourceType];
    }
}

-(void)presentImageSendingViewControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    containerView.hidden = YES;
    IVMediaSendingViewController *vController = [[IVMediaSendingViewController alloc]initWithNibName:@"IVMediaSendingViewController" bundle:nil];
    vController.delegate=self;
    if([currentChatUserInfo valueForKey:FROM_USER_ID])
        vController.fromUserId = [currentChatUserInfo valueForKey:FROM_USER_ID];
    else
        vController.fromUserId = [appDelegate.confgReader getLoginId];
    vController.sourceType = sourceType;
    //dp 3/12/15
    if(self.uiType==NOTES_SCREEN)
        vController.screenType=NOTES_SCREEN;
    [self presentViewController:vController animated:NO completion:nil];
}

#pragma mark -- ImageSending -- IVMediaSendingViewControllerDelegate
-(void)ivMediaSendingViewControllerDidCompleteSelectingImages:(NSMutableArray *)imageList shouldSetFrame:(BOOL)shouldSetFrame
{
    
    if(!_allowMessaging) {
        if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
            containerView.hidden = YES;
        else
            containerView.hidden = NO;
    } else {
        containerView.hidden = NO;
    }
    
    if (shouldSetFrame) {
        chatView.frame = tableViewFrameForImage;
        return;
    }
    
    for(IVMediaData* data in imageList)
    {
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * SIZE_1000);
        NSNumber *date = [NSNumber numberWithLongLong:milliseconds];
        
        NSMutableDictionary *conversationDic = [[NSMutableDictionary alloc]init];
        if(data.annotation)
            [conversationDic setValue:data.annotation forKey:ANNOTATION];
        [conversationDic setValue:msgType forKey:MSG_TYPE];
        [conversationDic setValue:date forKey:MSG_DATE];
        [conversationDic setValue:SENDER_TYPE forKey:MSG_FLOW];
        [conversationDic setValue:IMAGE_TYPE forKey:MSG_CONTENT_TYPE];
        if(_displayLoc)
        {
            if(location != nil)
            {
                [conversationDic setValue:[[NSNumber numberWithFloat:location.coordinate.latitude] stringValue] forKey:LATITUDE];
                [conversationDic setValue:[[NSNumber numberWithFloat:location.coordinate.longitude] stringValue] forKey:LONGITUTE];
            }
            if(locationName != nil)
            {
                [conversationDic setValue:locationName forKey:LOCATION_NAME];
            }
        }
        
        [conversationDic setValue:data.picName forKey:MSG_CONTENT];
        if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE)
            [conversationDic setValue:API_NETUNAVAILABLE forKey:MSG_STATE];
        else
            [conversationDic setValue:API_INPROGRESS forKey:MSG_STATE];
        [conversationDic setValue:data.picName forKey:MSG_LOCAL_PATH];
        [conversationDic setValue:data.picType forKey:MEDIA_FORMAT];
        
        chatView.frame = tableViewFrameForImage;
        [self sendMessageToServer:conversationDic];
    }
    
#ifdef REACHME_APP
    if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
        containerView.hidden = NO;
    else
        containerView.hidden = YES;
#endif
    
}

//Image viewing
-(void)imageTappedAtIndex:(NSIndexPath *)indexPath
{
    if([self isAudioRecording])
        return;
    
    [text1 resignFirstResponder];
    NSDate* dtDate = [arrDatesSorted objectAtIndex:indexPath.section];
    NSArray* msgList = [dicSections objectForKey:dtDate];
    if(!msgList.count)
        return;
    
    if(indexPath.row > msgList.count || indexPath.row < 0)
        return;
    
    //TODO check for large number of messages.
    NSMutableArray* filtered = [[NSMutableArray alloc]init];
    for(NSDate* date in arrDatesSorted) {
        NSArray *msgs = [dicSections objectForKey:date];
        NSArray *result = [msgs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(MSG_CONTENT_TYPE = %@)", IMAGE_TYPE]];
        if([result count]) {
            [filtered addObjectsFromArray:result];
        }
    }
    //
    //Apr 17, 2017 NSArray *filtered = [msgList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(MSG_CONTENT_TYPE == %@)", IMAGE_TYPE]];
    
    //present a new view controller.
    IVMediaZoomDisplayViewController *vController = [[IVMediaZoomDisplayViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    vController.mediaList = filtered;
    vController.currentMedia = [msgList objectAtIndex:indexPath.row];
    
    selectedRow = indexPath.row;
    
    if([[currentChatUserInfo valueForKey:REMOTE_USER_TYPE] isEqualToString:CELEBRITY_TYPE])
        vController.isCeleb = YES;
    else
        vController.isCeleb = NO;
    
    [self.view addSubview:vController.view];
    vController.view.transform = CGAffineTransformMakeScale(0.05, 0.05);
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Grow!
                         vController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     }
                     completion:^(BOOL finished){
                         // remove from temp super view
                         [self presentViewController:vController animated:NO completion:NULL]; // present VC
                     }];
    [vController.view removeFromSuperview];
    containerView.hidden = YES;
}

-(void)deleteWithdrawn:(NSMutableDictionary *)dic withIndexPath:(NSIndexPath *)index {
    
    EnLogd(@"DeleteWithdrawn");
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        [self pausePlayingAction];
        [self deleteMessageFromDataSource:dic];
        [appDelegate.engObj deleteMSG:dic];
    } else {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}
//

#pragma mark -- ConversationDelegate for showMore, exapanding MC,..
- (void)showMore:(NSMutableDictionary*)dic withIndexPath:(NSIndexPath*)index {
    NSNumber *value = [dic valueForKey:@"toShowMore"];
    
    if(value != nil && [value intValue]!=2) {
        if([value intValue]==1) {
            [dic setValue:[NSNumber numberWithInt:0] forKey:@"toShowMore"];
        } else if([value intValue]==0){
            [dic setValue:[NSNumber numberWithInt:1] forKey:@"toShowMore"];
            
        }
        
        NSDate* dtDate = [arrDatesSorted objectAtIndex:index.section];
        NSMutableArray* msgList = [dicSections objectForKey:dtDate];
        
        [msgList replaceObjectAtIndex:index.row withObject:dic];//TODO TEST Jan 19
        [chatView reloadData];
        chatView.scrollEnabled = YES;
//        if (chatView.contentSize.height < chatView.frame.size.height) {
//            [chatView setContentOffset:CGPointMake(SIZE_0, (chatView.contentSize.height-chatView.frame.size.height))];
//        }
//        else {
//            chatView.scrollEnabled = YES;
//        }
    }
}

#pragma mark -- Sharing Functionality
//bring sharing menu.
- (void)showWithdrawPop:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSMutableDictionary *dic=nil;
        CGPoint locationIndex = [recognizer locationInView:chatView];
        NSIndexPath* indexPath = [chatView indexPathForRowAtPoint:locationIndex];
        if(nil == indexPath) {
            EnLogd(@"***ERROR: Could not get row index. Return.");
            return;
        }
        
        UITableViewCell* cell = [chatView cellForRowAtIndexPath:indexPath];
        
        if(nil == cell) {
            EnLogd(@"***ERROR: Could not get cell. Return.");
            return;
        }
        
        NSDate* msgDate = [arrDatesSorted objectAtIndex:indexPath.section];
        NSMutableArray* msgList = [dicSections objectForKey:msgDate];
        if(indexPath.row >= [msgList count]) {
            EnLogd(@"***ERROR: indexPath.row is out of range.");
            return;
        }
        
        dic = [msgList objectAtIndex:indexPath.row];
        if ([[dic valueForKey:MSG_SUB_TYPE] isEqualToString:GROUP_MSG_EVENT_TYPE]) {
            EnLogd(@"Got group event cell. return.");
            return;
        }
        
        NSString* msgStatus =[dic valueForKey:MSG_STATE];
        if([msgStatus isEqualToString:API_INPROGRESS]) {
            EnLogd(@"***WARN:Msg is in sending state. return");
            return;
        }
        
        if([msgStatus isEqualToString:API_WITHDRAWN]) {
            KLog(@"*** Msg has been withdrawn. return");
            EnLogd(@"*** Msg has been withdrawn. return");
            return;
        }
        
        if (!([msgStatus isEqualToString:API_INPROGRESS] || [msgStatus isEqualToString:API_MSG_REQ_SENT])) {
            self.shareMenuSelectedCell = cell;
        }
        
        [self determineMessageTypeAndShowActionSheetInPage:self.uiType withMessageDetails:dic inCell:cell];
    }
}

- (void)determineMessageTypeAndShowActionSheetInPage:(NSInteger)inPage withMessageDetails:(NSMutableDictionary *)withMessageDeatils inCell:(UITableViewCell *)cell
{
    if([self isAudioRecording])
        return;
    
    [text1 resignFirstResponder];
    self.selectedCell = cell;
    cell.contentView.backgroundColor = [UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:0.5];
    
    containerView.hidden = YES;
    
    BOOL isNotesPage = NO;
    BOOL isGroupMessage = NO;
    BOOL isVoiceMailRecieverType = NO;
    BOOL isVoiceMailSenderType = NO;
    BOOL isAudioSenderType = NO;
    BOOL isAudioRecieverType = NO;
    BOOL isImageRecieverType = NO;
    BOOL isImageSenderType = NO;
    BOOL isRingMissCallRecieverType = NO;
    BOOL isRingMissCallSenderType = NO;
    BOOL isMissCallSenderType = NO;
    BOOL isMissCallRecieverType = NO;
    BOOL isTextRecieverType = NO;
    BOOL isTextSenderType = NO;
    BOOL isMsgSendingFailed = NO;
    BOOL isReachMeCall = NO;
    
    self.isVoboloPage = (self.uiType == MY_VOBOLO_SCREEN)? YES: NO;
    isNotesPage = (self.uiType == NOTES_SCREEN)? YES: NO;
    NSString *messageState = nil;
    
    NSMutableDictionary  *dic = withMessageDeatils;
    if(dic != nil || [dic count] > 0)
    {
        messageState = [dic valueForKey:MSG_STATE];
        
        if([messageState isEqualToString:API_NETUNAVAILABLE] || [messageState isEqualToString:API_UNSENT])
            isMsgSendingFailed = YES;
        
        NSString *flowMsg = [dic valueForKey:MSG_FLOW];
        NSString *msgContentType = [[dic valueForKey:MSG_CONTENT_TYPE] lowercaseString];
        NSString *msgSubType = [[dic valueForKey:MSG_SUB_TYPE] lowercaseString];
        NSString *mesgType = [[dic valueForKey:MSG_TYPE] lowercaseString];
        
        if([msgSubType isEqualToString:GROUP_MSG_EVENT_TYPE])
        {
            isGroupMessage = YES;
        }
        else if ([flowMsg isEqualToString:RECEIVER_TYPE] && [mesgType isEqualToString:VSMS_TYPE] &&
                 [msgContentType isEqualToString:AUDIO_TYPE])
        {
            isVoiceMailRecieverType = YES;
            self.messageType = eVoiceMail;
        }
        else if ([flowMsg isEqualToString:SENDER_TYPE] && [mesgType isEqualToString:VSMS_TYPE] &&
                 [msgContentType isEqualToString:AUDIO_TYPE])
        {
            if([msgSubType isEqualToString:AVS_TYPE]) {
                self.messageType = eVoiceMail;
                isVoiceMailSenderType = YES;
            }
            else {
                isAudioSenderType = YES;
                self.messageType = eAudioMessage;
            }
        }
        else if([flowMsg isEqualToString:RECEIVER_TYPE] && ([msgContentType isEqualToString:AUDIO_TYPE]))
        {
            isAudioRecieverType = YES;
            self.messageType = eAudioMessage;
        }
        else if([flowMsg isEqualToString:SENDER_TYPE] && [msgContentType isEqualToString:AUDIO_TYPE])
        {
            isAudioSenderType = YES;
            self.messageType = eAudioMessage;
        }
        else if([flowMsg isEqualToString:RECEIVER_TYPE] && ([msgContentType isEqualToString:IMAGE_TYPE]))
        {
            isImageRecieverType = YES;
            self.messageType = eImageMessage;
        }
        else if([flowMsg isEqualToString:SENDER_TYPE] && [msgContentType isEqualToString:IMAGE_TYPE])
        {
            isImageSenderType = YES;
            self.messageType = eImageMessage;
        } //AVN_TO_DO_IMAGES
        else if ([flowMsg isEqualToString:RECEIVER_TYPE] && [mesgType isEqualToString:MISSCALL])
        {
            self.messageType = eMissedCall;
            
            if([msgSubType isEqualToString:RING_MC]) {
                isRingMissCallRecieverType = YES;
            }
            else {
                isMissCallRecieverType = YES;
            }
        }
        else if ([flowMsg isEqualToString:SENDER_TYPE] && [mesgType isEqualToString:MISSCALL])
        {
            self.messageType = eMissedCall;
            
            if([msgSubType isEqualToString:RING_MC]) {
                isRingMissCallSenderType = YES;
            }
            else {
                isMissCallSenderType = YES;
            }
        }
        else if([flowMsg isEqualToString:RECEIVER_TYPE] && [msgContentType isEqualToString:TEXT_TYPE] && ![mesgType isEqualToString:VOIP_TYPE])
        {
            self.messageType = eTextMessage;
            isTextRecieverType = YES;
        }
        else if([flowMsg isEqualToString:SENDER_TYPE] && [msgContentType isEqualToString:TEXT_TYPE])
        {
            self.messageType = eTextMessage;
            isTextSenderType = YES;
        }
        else if([flowMsg isEqualToString:RECEIVER_TYPE] && [mesgType isEqualToString:VOIP_TYPE])
        {
            self.messageType = eVoipCall;
            isReachMeCall = YES;
        }
        
    }
    
    //Show Share Action Sheet.
    self.actionSheet =  [UIAlertController
                         alertControllerWithTitle:nil
                         message:nil
                         preferredStyle:UIAlertControllerStyleActionSheet];
    self.actionSheet.view.tag = actionSheetTag;
    
#define DISABLE_LIKE_MESSAGE
#ifdef DISABLE_LIKE_MESSAGE
    UIAlertAction* likeMessage = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Like Message", nil)
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [self shareMenuButtonAction:menuOptionLikeMessage];
                                      [UIView animateWithDuration:0.5 animations:^{
                                          cell.contentView.backgroundColor = [UIColor clearColor];
                                      }];
                                      if(!_allowMessaging) {
                                          if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
                                              containerView.hidden = YES;
                                          else
                                              containerView.hidden = NO;
                                      }else{
                                          containerView.hidden = NO;
                                      }
                                      
                                      [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
                                  }];
    
#endif
    
    UIAlertAction* saveImage = [UIAlertAction
                                        actionWithTitle:NSLocalizedString(@"Save",nil)
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            [self createAlbum];
                                            [self shareMenuButtonAction:menuOptionSaveImage];
                                            [UIView animateWithDuration:0.5 animations:^{
                                                cell.contentView.backgroundColor = [UIColor clearColor];
                                            }];
                                            if(!_allowMessaging) {
                                                if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
                                                    containerView.hidden = YES;
                                                else
                                                    containerView.hidden = NO;
                                            }else{
                                                containerView.hidden = NO;
                                            }
#ifdef REACHME_APP
                                            if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
                                                containerView.hidden = NO;
                                            else
                                                containerView.hidden = YES;
#endif
                                            text1.scrollEnabled = YES;
                                            [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
                                        }];
    
    UIAlertAction* shareImage = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"Share",nil)
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self shareMenuButtonAction:menuOptionShareImage];
                                    [UIView animateWithDuration:0.5 animations:^{
                                        cell.contentView.backgroundColor = [UIColor clearColor];
                                    }];
                                    if(!_allowMessaging) {
                                        if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
                                            containerView.hidden = YES;
                                        else
                                            containerView.hidden = NO;
                                    }else{
                                        containerView.hidden = NO;
                                    }
#ifdef REACHME_APP
                                    if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
                                        containerView.hidden = NO;
                                    else
                                        containerView.hidden = YES;
#endif
                                    text1.scrollEnabled = YES;
                                    [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
                                }];
    
    UIAlertAction* shareInInstaVoice = [UIAlertAction
                                        actionWithTitle:isImageSenderType || isImageRecieverType? NSLocalizedString(@"Forward",nil):NSLocalizedString(@"Share in InstaVoice",nil)
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            [self shareMenuButtonAction:menuOptionShareMessage];
                                            [UIView animateWithDuration:0.5 animations:^{
                                                cell.contentView.backgroundColor = [UIColor clearColor];
                                            }];
                                            if(!_allowMessaging) {
                                                if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
                                                    containerView.hidden = YES;
                                                else
                                                    containerView.hidden = NO;
                                            }else{
                                                containerView.hidden = NO;
                                            }
#ifdef REACHME_APP
                                            if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
                                                containerView.hidden = NO;
                                            else
                                                containerView.hidden = YES;
#endif
                                            text1.scrollEnabled = YES;
                                            [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
                                        }];
    
    UIAlertAction* shareInSocialNetwork  = [UIAlertAction
                                            actionWithTitle:isImageSenderType || isImageRecieverType? NSLocalizedString(@"Share on Blogs",nil):NSLocalizedString(@"Share on Social Network",nil)
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action)
                                            {
                                                if (isImageRecieverType || isImageSenderType) {
                                                    [self shareMenuButtonAction:menuOptionPostOnVobolo];
                                                }else{
                                                    [self hideSharingMenuView:NO inCell:self.selectedCell ];
                                                    containerView.userInteractionEnabled = NO;
                                                    containerView.hidden = YES;
                                                }
                                            
                                                [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                
                                            }];
    
    UIAlertAction* copyMessage = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Copy Message", nil)
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [self shareMenuButtonAction:menuOptionCopy];
                                      [UIView animateWithDuration:0.5 animations:^{
                                          cell.contentView.backgroundColor = [UIColor clearColor];
                                      }];
                                      if(!_allowMessaging) {
                                          if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
                                              containerView.hidden = YES;
                                          else
                                              containerView.hidden = NO;
                                      }else{
                                          containerView.hidden = NO;
                                      }
#ifdef REACHME_APP
                                      if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
                                          containerView.hidden = NO;
                                      else
                                          containerView.hidden = YES;
#endif
                                      [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
                                  }];
    
    UIAlertAction* copyNumber = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Copy Number", nil)
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [self shareMenuButtonAction:menuOptionCopyNumber];
                                      [UIView animateWithDuration:0.5 animations:^{
                                          cell.contentView.backgroundColor = [UIColor clearColor];
                                      }];
                                      if(!_allowMessaging) {
                                          if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
                                              containerView.hidden = YES;
                                          else
                                              containerView.hidden = NO;
                                      }else{
                                          containerView.hidden = NO;
                                      }
#ifdef REACHME_APP
                                      if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
                                          containerView.hidden = NO;
                                      else
                                          containerView.hidden = YES;
#endif
                                      [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
                                  }];
    
    UIAlertAction* withdrawMessage = [UIAlertAction
                                      actionWithTitle:NSLocalizedString(@"Withdraw Message", nil)
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [self showAlertWithMessageType:self.messageType actionType:menuOptionWithdraw inCell:cell];
                                          if(!_allowMessaging) {
                                              if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
                                                  containerView.hidden = YES;
                                              else
                                                  containerView.hidden = NO;
                                          } else {
                                              containerView.hidden = NO;
                                          }
                                
#ifdef REACHME_APP
                                          if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
                                              containerView.hidden = NO;
                                          else
                                              containerView.hidden = YES;
#endif
                                          [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
                            
                                      }];
    
    UIAlertAction* deleteMessageAction = [UIAlertAction
                                          actionWithTitle:NSLocalizedString(@"Delete Message", nil)
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                                          {
                                              [self showAlertWithMessageType:self.messageType actionType:menuOptionDelete inCell:cell];
                                              if(!_allowMessaging) {
                                                  if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
                                                      containerView.hidden = YES;
                                                  else
                                                      containerView.hidden = NO;
                                              } else{
                                                  containerView.hidden = NO;
                                              }
                                        
#ifdef REACHME_APP
                                              if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
                                                  containerView.hidden = NO;
                                              else
                                                  containerView.hidden = YES;
#endif
                                              
                                              [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
                                          }];
    
    UIAlertAction* retryMessageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Try Again", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [self retryMessageSend];
        [UIView animateWithDuration:0.5 animations:^{
            cell.contentView.backgroundColor = [UIColor clearColor];
        }];
        if(!_allowMessaging) {
            if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
                containerView.hidden = YES;
            else
                containerView.hidden = NO;
        } else{
            containerView.hidden = NO;
        }
#ifdef REACHME_APP
        if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
            containerView.hidden = NO;
        else
            containerView.hidden = YES;
#endif
        [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
//#ifdef DISABLE_LIKE_MESSAGE
//    [likeMessage setValue:[[UIImage imageNamed:@"longpress-like-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//#endif
//    [shareInInstaVoice setValue:[[UIImage imageNamed:@"longpress-iv_icons"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//    [shareInSocialNetwork setValue:[[UIImage imageNamed:@"longpress-share-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//    [copyMessage setValue:[[UIImage imageNamed:@"longpress-copy-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//    [withdrawMessage setValue:[[UIImage imageNamed:@"longpress-undo-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//    [deleteMessageAction setValue:[[UIImage imageNamed:@"longpress-delete-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    //Message sending failed - show only delete option for any kind of messages.
    if ([messageState isEqualToString:API_WITHDRAWN]) {
        [self.actionSheet addAction:deleteMessageAction];
    }else if(isMsgSendingFailed){
        [self.actionSheet addAction:retryMessageAction];
        [self.actionSheet addAction:deleteMessageAction];
    }
    
    else if (isNotesPage || self.isVoboloPage){
        
        if (isAudioSenderType || isAudioRecieverType) {
            //TODO [self.actionSheet addAction:likeMessage];
            [self.actionSheet addAction:shareInInstaVoice];
            [self.actionSheet addAction:shareInSocialNetwork];
            [self.actionSheet addAction:deleteMessageAction];
        }
        else if (isTextRecieverType|| isTextSenderType) {
            //TODO [self.actionSheet addAction:likeMessage];
            [self.actionSheet addAction:shareInInstaVoice];
            [self.actionSheet addAction:shareInSocialNetwork];
            [self.actionSheet addAction:copyMessage];
            [self.actionSheet addAction:deleteMessageAction];
        }else if (isImageSenderType || isImageRecieverType){
            [self.actionSheet addAction:saveImage];
            [self.actionSheet addAction:shareImage];
            [self.actionSheet addAction:shareInInstaVoice];
            if(isNotesPage)
                [self.actionSheet addAction:shareInSocialNetwork];
            
            [self.actionSheet addAction:deleteMessageAction];
        }
    }
    
    //Check for message type and determine the options.
    else if (isMissCallSenderType || isMissCallRecieverType || isRingMissCallSenderType || isRingMissCallRecieverType || isReachMeCall) {
        
        UIAlertAction* callAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Call", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [self shareMenuButtonAction:menuOptionMakeCall];
                                         [UIView animateWithDuration:0.5 animations:^{
                                             cell.contentView.backgroundColor = [UIColor clearColor];
                                         }];
                                         if(!_allowMessaging) {
                                             if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
                                                 containerView.hidden = YES;
                                             else
                                                 containerView.hidden = NO;
                                         }else{
                                             containerView.hidden = NO;
                                         }
#ifdef REACHME_APP
                                         if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
                                             containerView.hidden = NO;
                                         else
                                             containerView.hidden = YES;
#endif
                                         [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
        [self.actionSheet addAction:callAction];
        [self.actionSheet addAction:copyNumber];
        [self.actionSheet addAction:deleteMessageAction];
        
//        [callAction setValue:[[UIImage imageNamed:@"return-call-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
    }
    //If the messages are other then missed call
    else
    {
        //Image Messages
        if  (isImageSenderType)
        {
#ifdef REACHME_APP
            [self.actionSheet addAction:saveImage];
            [self.actionSheet addAction:shareImage];
            [self.actionSheet addAction:withdrawMessage];
            [self.actionSheet addAction:deleteMessageAction];
#else
            //TODO [self.actionSheet addAction:likeMessage];
            [self.actionSheet addAction:saveImage];
            [self.actionSheet addAction:shareImage];
            [self.actionSheet addAction:shareInInstaVoice];
            [self.actionSheet addAction:shareInSocialNetwork];
            [self.actionSheet addAction:withdrawMessage];
            [self.actionSheet addAction:deleteMessageAction];
#endif
        }
        else if (isImageRecieverType)
        {
#ifdef REACHME_APP
            [self.actionSheet addAction:saveImage];
            [self.actionSheet addAction:shareImage];
            [self.actionSheet addAction:deleteMessageAction];
#else
            //TODO [self.actionSheet addAction:likeMessage];
            [self.actionSheet addAction:saveImage];
            [self.actionSheet addAction:shareImage];
            [self.actionSheet addAction:shareInInstaVoice];
            [self.actionSheet addAction:shareInSocialNetwork];
            [self.actionSheet addAction:deleteMessageAction];
#endif
        }
        
        //Text Message type
        else if (isTextSenderType)
        {
#ifdef REACHME_APP
            if([[[dic valueForKey:MSG_TYPE] lowercaseString] isEqualToString:@"voip_out"]){
                [self.actionSheet addAction:copyNumber];
                [self.actionSheet addAction:deleteMessageAction];
            }else{
                [self.actionSheet addAction:withdrawMessage];
                [self.actionSheet addAction:copyMessage];
                [self.actionSheet addAction:deleteMessageAction];
            }
            
#else
            //TODO [self.actionSheet addAction:likeMessage];
            [self.actionSheet addAction:shareInInstaVoice];
            [self.actionSheet addAction:shareInSocialNetwork];
            [self.actionSheet addAction:copyMessage];
            [self.actionSheet addAction:withdrawMessage];
            [self.actionSheet addAction:deleteMessageAction];
#endif
        }
        else if (isTextRecieverType)
        {
#ifdef REACHME_APP
            if([[[dic valueForKey:MSG_TYPE] lowercaseString] isEqualToString:@"voip_out"]){
                [self.actionSheet addAction:copyNumber];
                [self.actionSheet addAction:deleteMessageAction];
            }else{
                [self.actionSheet addAction:copyMessage];
                [self.actionSheet addAction:deleteMessageAction];
            }
#else
            //TODO [self.actionSheet addAction:likeMessage];
            [self.actionSheet addAction:shareInInstaVoice];
            [self.actionSheet addAction:shareInSocialNetwork];
            [self.actionSheet addAction:copyMessage];
            [self.actionSheet addAction:deleteMessageAction];
#endif
        }
        
        //Audio Message type
        else if (isAudioSenderType)
        {
#ifdef REACHME_APP
            [self.actionSheet addAction:withdrawMessage];
            [self.actionSheet addAction:deleteMessageAction];
#else
            //TODO [self.actionSheet addAction:likeMessage];
            [self.actionSheet addAction:shareInInstaVoice];
            [self.actionSheet addAction:shareInSocialNetwork];
            [self.actionSheet addAction:withdrawMessage];
            [self.actionSheet addAction:deleteMessageAction];
#endif
        }
        else if (isAudioRecieverType)
        {
#ifdef REACHME_APP
            [self.actionSheet addAction:deleteMessageAction];
#else
            //TODO [self.actionSheet addAction:likeMessage];
            [self.actionSheet addAction:shareInInstaVoice];
            [self.actionSheet addAction:shareInSocialNetwork];
            [self.actionSheet addAction:deleteMessageAction];
#endif
        }
        else if (isVoiceMailRecieverType)
        {
#ifdef REACHME_APP
            [self.actionSheet addAction:copyNumber];
            [self.actionSheet addAction:deleteMessageAction];
#else
            //TODO [self.actionSheet addAction:likeMessage];
            [self.actionSheet addAction:copyNumber];
            [self.actionSheet addAction:shareInInstaVoice];
            [self.actionSheet addAction:shareInSocialNetwork];
            [self.actionSheet addAction:deleteMessageAction];
#endif
        }
        else if (isVoiceMailSenderType) {
#ifdef REACHME_APP
            [self.actionSheet addAction:copyNumber];
            [self.actionSheet addAction:withdrawMessage];
            [self.actionSheet addAction:deleteMessageAction];
#else
            //TODO DEC 26, 2016 [self.actionSheet addAction:likeMessage];
            [self.actionSheet addAction:copyNumber];
            [self.actionSheet addAction:shareInInstaVoice];
            [self.actionSheet addAction:shareInSocialNetwork];
            [self.actionSheet addAction:withdrawMessage];
            [self.actionSheet addAction:deleteMessageAction];
#endif
        }
    }
    
    UIAlertAction*cancel = [UIAlertAction
                            actionWithTitle:@"Cancel"
                            style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction * action)
                            {
                                [UIView animateWithDuration:0.5 animations:^{
                                    cell.contentView.backgroundColor = [UIColor clearColor];
                                }];
                                if(!_allowMessaging) {
                                    if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
                                        containerView.hidden = YES;
                                    else
                                        containerView.hidden = NO;
                                }else{
                                    containerView.hidden = NO;
                                }
                                
#ifdef REACHME_APP
                                if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
                                    containerView.hidden = NO;
                                else
                                    containerView.hidden = YES;
#endif
                                
                                [self.actionSheet dismissViewControllerAnimated:YES completion:^{
                                }];
                            }];
    [self.actionSheet addAction:cancel];
    
    
    /*TODO DEC, 26, 2016
    if([[dic valueForKey:@"MSG_LIKED"]intValue] == 0)
        //Like
        [likeMessage setValue:NSLocalizedString(@"Like Message", nil) forKey:@"title"];
    else
        //Unlike
        [likeMessage setValue:NSLocalizedString(@"Unlike Message", nil) forKey:@"title"];
     */
    
    [self presentViewController:self.actionSheet animated:YES completion:nil];
    self.actionSheet.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
}


- (void)showAlertWithMessageType:(MessageType)messageType actionType:(SliderMenuOption)withActionType inCell:(UITableViewCell *)cell{
    
    NSString *alertTitle, *alertMessage, *actionTitle;
    
    self.alertViewController =  [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    self.alertViewController.view.tag = alertViewTag;
    
    
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"Delete"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 switch (withActionType) {
                                     case menuOptionWithdraw:
                                         [self shareMenuButtonAction:menuOptionWithdraw];
                                         break;
                                     case menuOptionDelete:
                                         [self shareMenuButtonAction:menuOptionDelete];
                                         break;
                                     default:
                                         break;
                                 }
                                 [UIView animateWithDuration:0.5 animations:^{
                                     cell.contentView.backgroundColor = [UIColor clearColor];
                                 }];
                                 
                                 [self.alertViewController dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    switch (withActionType) {
        case menuOptionDelete: {
            
            switch (messageType) {
                case eTextMessage:
                case eAudioMessage:
                case eImageMessage:
                {
                    alertTitle = NSLocalizedString(@"Delete message?", nil);
                    alertMessage = NSLocalizedString(@"This message will be deleted from your account.",nil);
                    
                    break;
                }
                    
                case eVoiceMail: {
                    
                    alertTitle = NSLocalizedString(@"Delete voicemail?", nil);
                    alertMessage = NSLocalizedString(@"This voicemail will be deleted from your account.", nil);
                    
                    break;
                }
                    
                case eMissedCall: {
                    
                    alertTitle = NSLocalizedString(@"Delete missed call?", nil);
                    alertMessage = NSLocalizedString(@"This missed call will be deleted from your account.", nil);
                    
                    break;
                }
                case eVoipCall: {
                    
                    alertTitle = NSLocalizedString(@"Delete message?", nil);
                    alertMessage = NSLocalizedString(@"This message will be deleted from your account.", nil);
                    
                    break;
                }
                default:
                    break;
            }
            actionTitle = NSLocalizedString(@"Delete", nil);
            break;
        }
            
        case menuOptionWithdraw: {
            
            switch (messageType) {
                case eTextMessage:
                case eAudioMessage:
                case eImageMessage:
                {
                    alertTitle = NSLocalizedString(@"Withdraw message?", nil);
                    alertMessage = NSLocalizedString(@"This message will be deleted from your account and the recipient's account.", nil);
                    break;
                }
                case eVoiceMail: {
                    alertTitle = NSLocalizedString(@"Withdraw voicemail?", nil);
                    alertMessage = NSLocalizedString(@"This voicemail will be deleted from your account and the recipient's account.", nil);
                    break;
                }
                case eMissedCall: {
                    alertTitle = NSLocalizedString(@"Withdraw missed call?", nil);
                    alertMessage = NSLocalizedString(@"This missed call will be deleted from your account and the recipient's account.", nil);
                    break;
                }
                default:
                    break;
            }
            actionTitle = NSLocalizedString(@"Withdraw", nil);
            break;
        }
            
        default:
            break;
    }
    
    
    [self.alertViewController addAction:action];
    [action setValue:actionTitle forKey:@"title"];
    
    [self.alertViewController setValue:alertTitle forKey:@"title"];
    [self.alertViewController setValue:alertMessage forKey:@"message"];
    
    UIAlertAction*cancel = [UIAlertAction
                            actionWithTitle:@"Cancel"
                            style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction * action)
                            {
                                [UIView animateWithDuration:0.5 animations:^{
                                    cell.contentView.backgroundColor = [UIColor clearColor];
                                }];
                                
                                
                                [self.alertViewController dismissViewControllerAnimated:YES completion:nil];
                            }];
    [self.alertViewController addAction:cancel];
    
    [self presentViewController:self.alertViewController animated:YES completion:nil];
    self.alertViewController.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
    
}

- (void)retryMessageSend
{
    EnLogd(@"retry sending failed msgs.");
    [[Engine sharedEngineObj] sendAllPendingMsg];
}

#pragma mark ShareMessageDelegate
//called after sharing menu selection.
-(void)shareMessageAction:(SliderMenuOption)userSelection
{
    //NSString *str = (NSString*)sender;
    [self shareMenuButtonAction:userSelection];
}

-(void)voiceToTextButtonAction:(NSString *)convertedText {
    KLog(@"NO_IMPL");
}

- (IBAction) shareMenuButtonAction:(SliderMenuOption)option
{
    NSMutableDictionary  *dic;
    if(self.shareMenuSelectedCell == nil) {
        EnLoge(@"ERROR: Incorrect row index for the selected cell.");
        return;
    }
    
    NSIndexPath *indexPath = [chatView indexPathForCell:self.shareMenuSelectedCell];
    _curIndexPath = indexPath;
    
    if(indexPath.section >= arrDatesSorted.count) {
        EnLogd(@"*** Invalid section. FIXME");
        KLog(@"*** FIXME");
        return;
    }
    
    NSDate* dtDate = [arrDatesSorted objectAtIndex:indexPath.section];
    NSArray* msgList = [dicSections objectForKey:dtDate];
    
    if( !(indexPath.row < [msgList count]) ) {
        EnLogd(@"*** Invalid row. FIXME");
        KLog(@"*** FIXME");
        return;
    }
    
    dic = [msgList objectAtIndex:[indexPath row]];//TODO: check
    NSString *msgStatus =[dic valueForKey:MSG_STATE];
    if([msgStatus isEqualToString:API_UNSENT] || [msgStatus isEqualToString:API_NETUNAVAILABLE])
    {
        if(menuOptionDelete == option)
        {
            [self pausePlayingAction];
            [self deleteMessageFromDataSource:dic];
            [appDelegate.engObj deleteMSG:dic];
        }
    }
    else {
        NSNumber *boolTrue =  [NSNumber numberWithBool:YES];
        if([Common isNetworkAvailable] == NETWORK_AVAILABLE)
        {
            if(dic != nil && [dic count] )
            {
                switch (option) {
                    case menuOptionDelete: {
                        [self pausePlayingAction];
                        [self deleteMessageFromDataSource:dic];
                        [appDelegate.engObj deleteMSG:dic];
                        break;
                    }
                        
                    case menuOptionWithdraw: {
                        [self pausePlayingAction];
                        [appDelegate.engObj withdrawMSG:dic];
                        break;
                    }
                        
                    case menuOptionMakeCall: {
                        [self pausePlayingAction];
                        NSString* fromUser = [dic valueForKey:FROM_USER_ID];
                       
#ifdef REACHME_APP
                        NSString* remoteUserType = [dic valueForKey:REMOTE_USER_TYPE];
                        [Common callNumber:fromUser FromNumber:nil UserType:remoteUserType];
#else
                         [Common callWithNumber:fromUser];
#endif
                        break;
                    }
                        
                    case menuOptionPostOnTW: {
                        BOOL twConnected = [[[Setting sharedSetting]data]twConnected];
                        if(twConnected) {
                            NSMutableDictionary* reqDic = [[NSMutableDictionary alloc]initWithDictionary:dic];
                            [reqDic setValue:API_TW forKey:POST_TYPE];
                            [reqDic setValue:boolTrue forKey:MSG_TW_POST];
                            [appDelegate.engObj postOnWall:reqDic];
                            [ScreenUtility showAlertMessage:@"Message Posted"];
                        }
                        else {
                            [ScreenUtility showAlert:NSLocalizedString(@"TW_NOT_CONNECTED",nil)];
                        }
                        break;
                    }
                        
                    case menuOptionPostOnFB: {
                        BOOL fbConnected = [[[Setting sharedSetting]data]fbConnected];
                        if(fbConnected) {
                            NSMutableDictionary* reqDic = [[NSMutableDictionary alloc]initWithDictionary:dic];
                            [reqDic setValue:API_FB forKey:POST_TYPE];
                            [reqDic setValue:boolTrue forKey:MSG_FB_POST];
                            [appDelegate.engObj postOnWall:reqDic];
                            [ScreenUtility showAlertMessage:@"Message Posted"];
                        }
                        else {
                            [ScreenUtility showAlert:NSLocalizedString(@"FB_NOT_CONNECTED",nil)];
                        }
                        break;
                    }
                    case menuOptionPostOnVobolo: {
                        NSMutableDictionary* reqDic = [[NSMutableDictionary alloc]initWithDictionary:dic];
                        [reqDic setValue:API_VB forKey:POST_TYPE];
                        [reqDic setValue:boolTrue forKey:MSG_VB_POST];
                        [appDelegate.engObj postOnWall:reqDic];
                        [ScreenUtility showAlertMessage:@"Message Posted"];
                        containerView.hidden = NO;
#ifdef REACHME_APP
                        if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
                            containerView.hidden = NO;
                        else
                            containerView.hidden = YES;
#endif
                        break;
                    }
                        
                    case menuOptionShareMessage: {
                        [appDelegate.dataMgt setMessageDic:dic];
                        [self showProgressBar];
                        [self shareMessageFunction];
                        [self hideProgressBar];
                        //DC
                        
                        if( [[[appDelegate.dataMgt getMessageDic] valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE]) {
                            if(_allowMessaging) {
                                micButtonView1.hidden = NO;
                                micButtonView1.alpha = 1;
                            } else {
                                micButtonView1.hidden = YES;
                                micButtonView1.alpha = 0;
                            }
                        }
                        break;
                    }
                       
                    case menuOptionSaveImage: {
                        [appDelegate.dataMgt setMessageDic:dic];
                        [self performSelector:@selector(saveImageToPhotoAlbum) withObject:nil afterDelay:1.0];
                        if( [[[appDelegate.dataMgt getMessageDic] valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE]) {
                            if(_allowMessaging) {
                                micButtonView1.hidden = NO;
                                micButtonView1.alpha = 1;
                            } else {
                                micButtonView1.hidden = YES;
                                micButtonView1.alpha = 0;
                            }
                        }
                        break;
                    }
                      
                    case menuOptionShareImage: {
                        [appDelegate.dataMgt setMessageDic:dic];
                        [self saveImageToCloud];
                        if( [[[appDelegate.dataMgt getMessageDic] valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE]) {
                            if(_allowMessaging) {
                                micButtonView1.hidden = NO;
                                micButtonView1.alpha = 1;
                            } else {
                                micButtonView1.hidden = YES;
                                micButtonView1.alpha = 0;
                            }
                        }
                        break;
                    }
                        
                    case menuOptionLikeMessage: {
                        [appDelegate.engObj msgActivity:dic];
                        break;
                    }
                        
                    case menuOptionCopyNumber: {
                        [ScreenUtility showAlertMessage:@"Number Copied"];
                        NSString *str = [dic valueForKey:FROM_USER_ID];
                        [[UIPasteboard generalPasteboard] setString:str.length>0 ? str : @""];
                        break;
                    }
                        
                    case menuOptionCopy: {
                        if ([[dic valueForKey:MSG_CONTENT_TYPE] isEqualToString:@"t"]) {
                            [ScreenUtility showAlertMessage:@"Message Copied"];
                            NSString *str = [dic valueForKey:MSG_CONTENT];
                            [[UIPasteboard generalPasteboard] setString:str.length>0 ? str : @""];
                        }
                        else {
                            [ScreenUtility showAlertMessage:NSLocalizedString(@"Copy is supported only for text message",nil)];
                        }
                        break;
                    }
                    default:
                        KLog(@"Undefined user option - should not happen");
                        break;
                }
            }
            else
            {
                EnLogd(@"ERROR: %d cell dic is nil",indexPath.row);
                KLog(@"ERROR: %ld cell dic is nil",(long)indexPath.row);
            }
        }
        else
        {
            if(dic != nil && [dic count] )
            {
                switch (option) {
                    case menuOptionMakeCall: {
                        [self pausePlayingAction];
                        [Common callWithNumber:[dic valueForKey:FROM_USER_ID]];
                        return;
                        break;
                    }
                       
                    case menuOptionSaveImage: {
                        [appDelegate.dataMgt setMessageDic:dic];
                        [self saveImageToPhotoAlbum];
                        if( [[[appDelegate.dataMgt getMessageDic] valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE]) {
                            if(_allowMessaging) {
                                micButtonView1.hidden = NO;
                                micButtonView1.alpha = 1;
                            } else {
                                micButtonView1.hidden = YES;
                                micButtonView1.alpha = 0;
                            }
                        }
                        return;
                        break;
                    }
                       
                    case menuOptionShareImage: {
                        [appDelegate.dataMgt setMessageDic:dic];
                        [self saveImageToCloud];
                        if( [[[appDelegate.dataMgt getMessageDic] valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE]) {
                            if(_allowMessaging) {
                                micButtonView1.hidden = NO;
                                micButtonView1.alpha = 1;
                            } else {
                                micButtonView1.hidden = YES;
                                micButtonView1.alpha = 0;
                            }
                        }
                        return;
                        break;
                    }
                        
                    case menuOptionCopy: {
                        if ([[dic valueForKey:MSG_CONTENT_TYPE] isEqualToString:@"t"]) {
                            [ScreenUtility showAlertMessage:@"Message Copied"];
                            NSString *str = [dic valueForKey:MSG_CONTENT];
                            [[UIPasteboard generalPasteboard] setString:str.length>0 ? str : @""];
                        }
                        else {
                            [ScreenUtility showAlertMessage:NSLocalizedString(@"Copy is supported only for text message",nil)];
                        }
                        return;
                        break;
                    }
                    default:
                        break;
                }
                
            }
            
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        }
    }
    
    UITableViewCell* cell = [chatView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
}

//May 2017
-(void)deleteMessageFromDataSource:(NSDictionary*)dic {

    NSString* msgGuid = [dic valueForKey:MSG_GUID];
    NSInteger msgID = [[dic valueForKey:MSG_ID]integerValue];
    
    NSPredicate *predicate;
    NSNumber* dateInMs = [dic valueForKey:MSG_DATE];
    NSDate* msgDate = [self getDateFromMilliSeconds:dateInMs];
    NSMutableArray* msgList = [dicSections objectForKey:msgDate];
    
    if(msgGuid.length)
        predicate = [NSPredicate predicateWithFormat:@"self.MSG_GUID != %@", msgGuid];
    else
        predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID != %@", [NSNumber numberWithInteger:msgID]];
    
    [msgList filterUsingPredicate:predicate];
    
    if(![msgList count]) {
        [dicSections removeObjectForKey:msgDate];
        [arrDatesSorted removeObject:msgDate];
    }
    
    [UIView animateWithDuration:0.0 animations:^{
        [self.chatView reloadData];
    } completion:^(BOOL finished) {
//        if([arrDatesSorted count]) {
//            CGFloat tableViewHeight = chatView.frame.size.height;
//            CGFloat contentOffsetY = chatView.contentOffset.y;
//            CGFloat distanceFromBottom = chatView.contentSize.height - contentOffsetY + text1.frame.size.height + 14.0;
//
//            NSDate* dtDate = [arrDatesSorted objectAtIndex:[arrDatesSorted count]-1];
//            NSArray* msgList = [dicSections objectForKey:dtDate];
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[msgList count]-1 inSection:[arrDatesSorted count]-1];
        
//            CGRect rowHeight = [self.chatView rectForRowAtIndexPath:indexPath];
//            CGFloat lastRowHeight = rowHeight.size.height;
            
//            if(distanceFromBottom < tableViewHeight + lastRowHeight)
//            {
//                CGPoint pointsFromTop = CGPointMake(0.0, chatView.contentSize.height - chatView.frame.size.height + (height == 0.0?45.0:height) + text1.frame.size.height - 31.0);
//
//                if(pointsFromTop.y >= 45.0)
//                    [chatView setContentOffset:pointsFromTop];
//            }
//        }
    }];
}
//

-(void)saveImageToCloud
{
    NSDictionary *dic = [appDelegate.dataMgt getMessageDic];
    NSString* msgLocalPath = [dic valueForKey:MSG_LOCAL_PATH];
    UIImage *image = nil;
    if(msgLocalPath && msgLocalPath.length > 1)
    {
        NSString* localPath = [[IVFileLocator getMediaImagePath:msgLocalPath]stringByAppendingPathExtension:@"jpg"];
        if(localPath != nil)
        {
            image = [UIImage imageWithContentsOfFile:localPath];
            if(image)
            {
                NSData *compressedImage = UIImageJPEGRepresentation(image, 1.0);
                NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *imagePath = [docsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"img_%ld.jpg",[[dic valueForKey:MSG_ID] integerValue]]];
                NSURL *imageUrl = [NSURL fileURLWithPath:imagePath];
                
                [compressedImage writeToURL:imageUrl atomically:YES]; // save the file
                UIActivityViewController * activity =[[UIActivityViewController alloc] initWithActivityItems:@[imageUrl] applicationActivities:nil];
                activity.excludedActivityTypes = @[];
                activity.completionWithItemsHandler = ^(NSString *activityType,
                                                        BOOL completed,
                                                        NSArray *returnedItems,
                                                        NSError *error){
                    [self becomeFirstResponder];
                    if (completed) {
                        
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSError *error;
                        [fileManager removeItemAtPath:imagePath error:&error];
                        
                    } else {
                        
                        // user cancelled
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSError *error;
                        [fileManager removeItemAtPath:imagePath error:&error];
                    }
                    
                    if (error) {
                        KLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
                    }
                };
                [self presentViewController:activity animated:true completion:nil];
                
            }else{
                [ScreenUtility showAlert:@"Downloading Image..."];
            }
        }
    }
    
    if(image == Nil)
    {
        NSString *msgContent = [dic valueForKey:MSG_CONTENT];
        NSData *data = [msgContent dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSMutableDictionary *imageData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSMutableArray* imageArr = [imageData valueForKey:@"img"];
        for(NSMutableDictionary* imageDic in imageArr)
        {
            NSString* imageUrl = [imageDic valueForKey:@"url"];
            NSString* msgLocalPath = [dic valueForKey:MSG_LOCAL_PATH];
            if(!msgLocalPath || msgLocalPath.length == 0)
            {
                msgLocalPath = [[dic valueForKey:MSG_ID]stringValue];
            }
            
            UIImage* imgMain = [[IVMediaLoader sharedIVMediaLoader]getImageForLocalPath:msgLocalPath serverPath:imageUrl];
            
            if(imgMain)
            {
                NSData *compressedImage = UIImageJPEGRepresentation(imgMain, 1.0 );
                NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *imagePath = [docsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"img_%ld.jpg",[[dic valueForKey:MSG_ID] integerValue]]];
                NSURL *imageUrl = [NSURL fileURLWithPath:imagePath];
                
                [compressedImage writeToURL:imageUrl atomically:YES]; // save the file
                UIActivityViewController * activity =[[UIActivityViewController alloc] initWithActivityItems:@[imageUrl] applicationActivities:nil];
                activity.excludedActivityTypes = @[];
                activity.completionWithItemsHandler = ^(NSString *activityType,
                                                        BOOL completed,
                                                        NSArray *returnedItems,
                                                        NSError *error){
                    [self becomeFirstResponder];
                    if (completed) {
                        
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSError *error;
                        [fileManager removeItemAtPath:imagePath error:&error];
                        
                    } else {
                        
                        // user cancelled
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSError *error;
                        [fileManager removeItemAtPath:imagePath error:&error];
                        KLog(@"We didn't want to share anything after all.");
                    }
                    
                    if (error) {
                        KLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
                    }
                };
                [self presentViewController:activity animated:true completion:nil];
            }else{
                [ScreenUtility showAlert:@"Downloading Image..."];
            }
            
        }
        
    }
    
}

-(void)saveImageToPhotoAlbum
{
    NSDictionary *dic = [appDelegate.dataMgt getMessageDic];
    NSString* msgLocalPath = [dic valueForKey:MSG_LOCAL_PATH];
    UIImage *image = nil;
    if(msgLocalPath && msgLocalPath.length > 1)
    {
        NSString* localPath = [[IVFileLocator getMediaImagePath:msgLocalPath]stringByAppendingPathExtension:@"jpg"];
        if(localPath != nil)
        {
            image = [UIImage imageWithContentsOfFile:localPath];
            if(image)
            {
                NSUserDefaults *imageIdentifier = [NSUserDefaults standardUserDefaults];
                NSString *msgID = [NSString stringWithFormat:@"%ld",[[dic valueForKey:MSG_ID] integerValue]];
                
                __block PHAssetCollection *collection;
                PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
                fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@",CUSTOMALBUM];
                collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions].firstObject;
                fetchOptions.predicate = [NSPredicate predicateWithFormat:@"localIdentifier = %@",[imageIdentifier valueForKey:msgID]];
                PHFetchResult *collectionResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
                
                if (collectionResult.count == 0) {
                    [CustomAlbum addNewAssetWithImage:image toAlbum:[CustomAlbum getMyAlbumWithName:CUSTOMALBUM] onSuccess:^(NSString *ImageId) {
                        [imageIdentifier setValue:ImageId forKey:msgID];
                        [imageIdentifier synchronize];
                    } onError:^(NSError *error) {
                        KLog(@"probelm in saving image");
                    }];
                }
                
            }else{
                
                NSString *msgContent = [dic valueForKey:MSG_CONTENT];
                NSData *data = [msgContent dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSMutableDictionary *imageData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSMutableArray* imageArr = [imageData valueForKey:@"img"];
                NSUserDefaults *imageLocalPath = [NSUserDefaults standardUserDefaults];
                for(NSMutableDictionary* imageDic in imageArr)
                {
                    NSString* imageUrl = [imageDic valueForKey:@"url"];
                    [imageLocalPath setObject:dic forKey:imageUrl];
                }
                [imageLocalPath setBool:YES forKey:localPath];
                [imageLocalPath synchronize];
            }
        }
    }
    if(image == Nil)
    {
        NSString *msgContent = [dic valueForKey:MSG_CONTENT];
        NSData *data = [msgContent dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSMutableDictionary *imageData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSMutableArray* imageArr = [imageData valueForKey:@"img"];
        for(NSMutableDictionary* imageDic in imageArr)
        {
            NSString* imageUrl = [imageDic valueForKey:@"url"];
            NSString* msgLocalPath = [dic valueForKey:MSG_LOCAL_PATH];
            if(!msgLocalPath || msgLocalPath.length == 0)
            {
                msgLocalPath = [[dic valueForKey:MSG_ID]stringValue];
            }
            
            UIImage* imgMain = [[IVMediaLoader sharedIVMediaLoader]getImageForLocalPath:msgLocalPath serverPath:imageUrl];
            
            NSString* localPath = msgLocalPath;
            localPath = [[localPath stringByDeletingPathExtension]stringByAppendingPathExtension:@"jpg"];
            localPath = [IVFileLocator getMediaImagePath:localPath];
            
            if(imgMain)
            {
                NSUserDefaults *imageIdentifier = [NSUserDefaults standardUserDefaults];
                NSString *msgID = [NSString stringWithFormat:@"%ld",[[dic valueForKey:MSG_ID] integerValue]];

                __block PHAssetCollection *collection;
                PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
                fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@",CUSTOMALBUM];
                collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions].firstObject;
                fetchOptions.predicate = [NSPredicate predicateWithFormat:@"localIdentifier = %@",[imageIdentifier valueForKey:msgID]];
                PHFetchResult *collectionResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
                
                if (collectionResult.count == 0) {
                    [CustomAlbum addNewAssetWithImage:imgMain toAlbum:[CustomAlbum getMyAlbumWithName:CUSTOMALBUM] onSuccess:^(NSString *ImageId) {
                        [imageIdentifier setValue:ImageId forKey:msgID];
                        [imageIdentifier synchronize];
                    } onError:^(NSError *error) {
                        KLog(@"probelm in saving image");
                    }];
                }
                
            }else{
                NSString *msgContent = [dic valueForKey:MSG_CONTENT];
                NSData *data = [msgContent dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSMutableDictionary *imageData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSMutableArray* imageArr = [imageData valueForKey:@"img"];
                NSUserDefaults *imageLocalPath = [NSUserDefaults standardUserDefaults];
                for(NSMutableDictionary* imageDic in imageArr)
                {
                    NSString* imageUrl = [imageDic valueForKey:@"url"];
                    [imageLocalPath setObject:dic forKey:imageUrl];
                }
                [imageLocalPath setBool:YES forKey:localPath];
                [imageLocalPath synchronize];
            }
        }
    }
}

//for IV share brings the friend list.
-(void)shareMessageFunction
{
    recordingView.hidden    =   YES;
    [text1 resignFirstResponder];
    
    NSDictionary *shareMessageDictionary = [appDelegate.dataMgt getMessageDic];
    if( [[shareMessageDictionary valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE]) {
        if(!_allowMessaging) {
            containerView.hidden = YES;
            
            footerView1.hidden = YES;
            footerView1.alpha=0;
            micButtonView1.hidden = YES;
            micButtonView1.alpha = 0;
            recordingView.hidden = YES;
            recordingView.alpha = 0;
            recordingArea1.hidden = YES;
            recordingArea1.alpha = 0;
        }
    }
    
    _shareMessage = YES;
    
    UIStoryboard *voiceMailSettingsStorybaord = [UIStoryboard storyboardWithName:@"IVFriendsStoryboard" bundle:[NSBundle mainBundle]];
    ShareFriendsListViewController *shareFriendsViewController  = [voiceMailSettingsStorybaord instantiateViewControllerWithIdentifier:@"ShareFriendsListView"];
    shareFriendsViewController.shareMessageDelegate = self;
    shareFriendsViewController.messageDictionary = shareMessageDictionary;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:shareFriendsViewController];
    [self.navigationController presentViewController:navController animated:YES completion:^{
        
    }];
}

//for IV share gets the selected friend and forward the msg.
-(void)shareFriendListDidFinishSelectingList:(NSMutableArray *)shareFriendList forMessage:(NSDictionary *)msgDictionary
{
    if([Common isNetworkAvailable])
    {
        if(shareFriendList != nil && [shareFriendList count] > SIZE_0)
        {
            // [self showProgressBar];
            NSMutableArray *sharePersonArray = [[NSMutableArray alloc] init];
            
            for (ContactDetailData* data in shareFriendList) {
                if([data.contactIdParentRelation.contactType integerValue] == ContactTypeIVGroup)
                {
                    NSMutableDictionary* personDic = [[NSMutableDictionary alloc]init];
                    [personDic setValue:GROUP_TYPE forKey:@"shareMsgType"];
                    [personDic setValue:data.contactIdParentRelation.groupId forKey:@"shareMsgDataValue"];
                    [sharePersonArray addObject:personDic];
                }
                else
                {
                    NSMutableDictionary* personDic = [[NSMutableDictionary alloc]init];
                    if([data.ivUserId integerValue] > 0)
                    {
                        [personDic setValue:IV_TYPE forKey:@"shareMsgType"];
                        [personDic setValue:data.ivUserId forKey:@"shareMsgDataValue"];
                        [sharePersonArray addObject:personDic];
                    } else {
                        [personDic setValue:PHONE_MODE forKey:@"shareMsgType"];
                        [personDic setValue:data.contactDataValue forKey:@"shareMsgDataValue"];
                        [sharePersonArray addObject:personDic];
                    }
                }
            }
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:msgDictionary];
            [dic setValue:sharePersonArray forKey:CONTACT_LIST];
            [appDelegate.engObj forwardMessage:dic];
        }
        else
        {
            EnLogd(@"_inviteList is nil");
            [ScreenUtility showAlertMessage:NSLocalizedString(@"PLZ_SELECT_FRND_TO_SHARE_SELECTED_MSG",nil)];
        }
    }
    else
    {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

#pragma mark UINavigationController releated
-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark Audio Plot Delegate
- (void)microphone:(EZMicrophone *)microphone hasAudioReceived:(float **)buffer withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels
{
    //JUNE 17, 2016
    //TODO sometime this call causes a crash.
    //KLog(@"hasAudioReceived");
    //[self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    
    //NOV 2017
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            [weakSelf.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
        } @catch(...) {
            KLog(@"Exception occurred.");
        }
    });
    //
}

#pragma mark new functions OCT 9
- (void) resignTextResponder
{
    [text1 resignFirstResponder];
}

-(void)enableFirstResponder {
    
    [self becomeFirstResponder];
}

- (BOOL) isAudioRecording
{
    if(self.audioObj.isRecord)
        return YES;
    else
        return NO;
}

#pragma mark AudioDelegate implementation
-(void)didProximityStateChange:(BOOL)state
{
    if(state) {
        KLog(@"Device is close to user.");
    }
    else {
        [self stopAudioPlayback];
        KLog(@"Device is not closer to user.");
    }
}

-(void) audioDidCompletePlayingData
{
    if([self.audioObj isPlay]) {//APR 5, 2019
        [self stopAudioPlayback];
    } else {
        KLog(@"Debug");
    }
}

- (IBAction)removeSharingMenuView:(id)sender {
    
    KLog(@"removeSharingMenuView");
    if(!_allowMessaging) {
        if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
            containerView.hidden = YES;
        else
            containerView.hidden = NO;
    }else{
        containerView.hidden = NO;
    }
    
#ifdef REACHME_APP
    if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
        containerView.hidden = NO;
    else
        containerView.hidden = YES;
#endif
    
    UIGestureRecognizer *tapGesture = (UIGestureRecognizer *)sender;
    CGPoint tapLocation = [tapGesture locationInView:self.sharingSocialNetworkView];
    
    if (!(CGRectContainsPoint(self.sharingSocialNetworkView.bounds, tapLocation))) {
        // Point outside  the bounds.
        [self hideSharingMenuView:YES inCell:self.selectedCell];
    }
}

- (IBAction)shareWithFacebookBtnTapped:(id)sender {
    [self shareMenuButtonAction:menuOptionPostOnFB];
    [self hideSharingMenuView:YES inCell:self.selectedCell];
}

- (IBAction)shareWithTwitterBtnTapped:(id)sender {
    [self shareMenuButtonAction:menuOptionPostOnTW];
    [self hideSharingMenuView:YES inCell:self.selectedCell];
}

- (IBAction)shareInVoboloBtnTapped:(id)sender {
    [self shareMenuButtonAction:menuOptionPostOnVobolo];
    [self hideSharingMenuView:YES inCell:self.selectedCell];
}

- (void)hideSharingMenuView:(BOOL)hideSharingMenuView inCell:(UITableViewCell *)cell {
    
    if(!_allowMessaging) {
        if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
            containerView.hidden = YES;
        else
            containerView.hidden = NO;
    }else{
        containerView.hidden = NO;
    }
#ifdef REACHME_APP
    if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
        containerView.hidden = NO;
    else
        containerView.hidden = YES;
#endif
    containerView.userInteractionEnabled = YES;
    self.sharingMenuView.hidden =  hideSharingMenuView;
    [self.sharingMenuView bringSubviewToFront:self.sharingSocialNetworkView];
    BOOL flag = [[Setting sharedSetting] data].vbEnabled;

    self.sharingMenuView.center = self.sharingMenuView.superview.center;
    [self.view bringSubviewToFront:self.sharingSocialNetworkView];

    self.shareInVoboloBtn.hidden = self.shareInVoboloLabel.hidden = (self.isVoboloPage || !flag)?YES:NO;
    [UIView animateWithDuration:0.5 animations:^{
        cell.contentView.backgroundColor = (cell && hideSharingMenuView)?[UIColor clearColor]:[UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:0.5];
    }];
}

#pragma mark - Notification Methods -

- (void)statusBarFrameChanged:(NSNotification*)notification {
    
    KLog(@"### statusBarFrameChanged");
    [self becomeFirstResponder];
    if (keyboardHide) {
        [UIView animateWithDuration:0.15 animations:^{
            self.chatView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        }];
    }
}

- (void)appEnterIntoActive:(NSNotification *)withNotification {
    
    CGFloat fixedWidth = text1.frame.size.width;
    CGSize newSize = [text1 sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = text1.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    
    if (maxTextViewHeight > newSize.height + 14.0) {
        isPasteDone = NO;
    }
    [self performSelector:@selector(toolBarFrame) withObject:nil afterDelay:0.05];
    [self textViewFrameChange];
    [self dismissActiveAlertController];
}

- (void)dismissActiveAlertController {

    UIViewController *presentedViewController = self.presentedViewController;
    if ([presentedViewController isKindOfClass:[UIAlertController class]]) {
        [self.chatView reloadData];
    
        if(!_allowMessaging) {
            if(![VSMS_TYPE isEqualToString:msgType] && ![msgType isEqualToString:IV_TYPE])
                containerView.hidden = YES;
            else
                containerView.hidden = NO;
        } else {
            containerView.hidden = NO;
        }
#ifdef REACHME_APP
        if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
            containerView.hidden = NO;
        else
            containerView.hidden = YES;
#endif
        if (presentedViewController.view.tag == actionSheetTag) {
            [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
        }
        else if (presentedViewController.view.tag == alertViewTag) {
            [self.alertViewController dismissViewControllerAnimated:YES completion:nil];
        }else if (presentedViewController.view.tag == groupInfoAlertViewTag) {
            containerView.hidden = YES;
        }else if (presentedViewController.view.tag == alertControllerTag) {
            containerView.hidden = YES;
        }
    }
    
#ifdef REACHME_APP
    UIViewController* presentdVC = appDelegate.window.rootViewController;
    if( [presentdVC isKindOfClass:[PhoneViewController class]]) {
        containerView.hidden = YES;
    }
#endif
    
}

-(void)dismissAlertRecordView {

    UIViewController *presentedViewController = self.presentedViewController;
    if (presentedViewController.view.tag == alertControllerTag) {
        [presentedViewController dismissViewControllerAnimated:YES completion:nil];
        [self hideRecordingView];
        containerView.hidden = NO;
#ifdef REACHME_APP
        if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
            containerView.hidden = NO;
        else
            containerView.hidden = YES;
#endif
    }
    
    if(presentedViewController.view.tag == ringAlertControllerTag) {
        [presentedViewController dismissViewControllerAnimated:YES completion:nil];
        //containerView.hidden = NO;
    }
    
    if(recordAlertView) {
        [recordAlertView dismissWithClickedButtonIndex:0 animated:NO];
        recordAlertView = nil;
    }
}

#pragma mark - Date Conversion

- (NSString*)getDateString:(NSDate *)msgDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:NSLocalizedString(@"dd MMM, yyyy",nil)];
    
    if([calendar isDateInToday:msgDate]) {
        return @"Today";
    }
    else if([calendar isDateInYesterday:msgDate]) {
        return @"Yesterday";
    } else {
        NSInteger iYearOfMsg = [calendar component:NSCalendarUnitYear fromDate:msgDate];
        NSInteger iThisYear = [calendar component:NSCalendarUnitYear fromDate:[NSDate date]];
        if((iThisYear-iYearOfMsg)<=0) {
            [formatter setDateFormat:NSLocalizedString(@"dd MMM",nil)];
            return ([formatter stringFromDate:msgDate]);
        }
        return ([formatter stringFromDate:msgDate]);
    }
}

-(NSDate*) getDateWithDayMonthYear:(NSDate*)inDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:inDate];
    
    NSDate *dtResult = [calendar dateFromComponents:dateComps];
    return dtResult;
}

-(NSDate*)getDateFromMilliSeconds:(NSNumber*)dateInMilliSecs {
    
    double fVal = ([dateInMilliSecs doubleValue])/1000;
    NSDate* dtActualDate = [NSDate dateWithTimeIntervalSince1970:fVal];
    NSDate* dtDate = [self getDateWithDayMonthYear:dtActualDate];
    return dtDate;
}


/* 
When bInsertMsg is false:
 For older msg list insert the msg at index 0
 For new sent msg, add at the end
*/
-(void)prepareDataSourceFromMessages:(NSArray*)list withInsertion:(BOOL)bInsertMsg MsgType:(DSMessageType)eMessageType
{
    KLog(@"prepareDataSourceFromMessages: START");
    NSArray* sortedList = list;
    if(bInsertMsg) {
        KLog(@"prepareDataSourceFromMessages: clear and build new sections");
        dicSections = nil;
    } else {
       KLog(@"prepareDataSourceFromMessages: update the existing sections");
        NSSortDescriptor* descSortOrder = [NSSortDescriptor sortDescriptorWithKey: @"MSG_DATE" ascending: NO];
        sortedList = [list sortedArrayUsingDescriptors: [NSArray arrayWithObject: descSortOrder]];

        /* DEBUG
        for(NSDictionary* dic in sortedList) {
            NSNumber* nu = [dic valueForKey:MSG_DATE];
            NSString* dateString = [ScreenUtility dateConverter:nu dateFormateString:NSLocalizedString(@"DATE_FORMATE_CONVERSATION",nil)];
            NSLog(@"*** sortedList = %@", dateString);
        }*/
    }
    
    if(!dicSections.count)
        dicSections = [NSMutableDictionary dictionary];
    
    for (NSDictionary* dicMsg in sortedList)
    {
        NSNumber* nuDate = [dicMsg valueForKey:MSG_DATE];
        double fVal = ([nuDate doubleValue])/1000;
        NSDate* dtActualDate = [NSDate dateWithTimeIntervalSince1970:fVal];
        NSDate* dtDate = [self getDateWithDayMonthYear:dtActualDate];
        
        NSMutableArray *arrMsgsForTheDate = [dicSections objectForKey:dtDate];
        if (arrMsgsForTheDate == nil) {
            arrMsgsForTheDate = [NSMutableArray array];
            [dicSections setObject:arrMsgsForTheDate forKey:dtDate];
        } else {
            // MAR 23, 2017
            if([self isMessagePresent:dicMsg inMsgs:arrMsgsForTheDate])
                continue;
        }
        
        if(bInsertMsg)
            [arrMsgsForTheDate addObject:dicMsg];
        else {
            /* DEBUG
            NSNumber* nd = [dicMsg valueForKey:MSG_DATE];
            NSString* dateString = [ScreenUtility dateConverter:nd dateFormateString:NSLocalizedString(@"DATE_FORMATE_CONVERSATION",nil)];
            NSLog(@"*** DATE = %@", dateString);
             */
            if(eNewMessage == eMessageType)
                [arrMsgsForTheDate addObject:dicMsg];
            else
                [arrMsgsForTheDate insertObject:dicMsg atIndex:0];
        }
    }
    
    NSArray *unsortedDates = [dicSections allKeys];
    NSSortDescriptor* descSortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
    NSArray* res = [unsortedDates sortedArrayUsingDescriptors: [NSArray arrayWithObject: descSortOrder]];
    arrDatesSorted = [[NSMutableArray alloc]initWithArray:res];
    
    //KLog(@"all keys of dicSections: %@", [dicSections allKeys]);
    KLog(@"prepareDataSourceFromMessages: END");
}

/*TODO MAR 23, 2017
This method is required, because, msg_id for blog messages can be greater in numberic value than msg_id for iv-msg.
 This could happen When a chat has both blog msgs and iv-msgs.
 Discuss with AJay, why msg-id for blog msgs and iv-msgs are not consistent w.r.t date.
 For, e.g:
 <msg_id> <date>
 999   10,Jan
 222   20,Jan
 
 This will create a trouble for fetching older messages w.r.t blog msgs, and hence inserting duplicate of the last msg in a chat tile.
*/
-(BOOL)isMessagePresent:(NSDictionary*)msgDic inMsgs:(NSMutableArray*)arrMsgs {
    
    long long lMsgID = [[msgDic valueForKey:MSG_ID] longLongValue];
    if(lMsgID > 0 ) {
        /*
        NSDictionary* dic = [arrMsgs lastObject];
        if(lMsgID == [[dic valueForKey:MSG_ID]longLongValue])
            return YES;
        */
        for(NSDictionary* dic in arrMsgs) {
            if(lMsgID == [[dic valueForKey:MSG_ID]longLongValue])
                return YES;
        }
    }
    return NO;
}
//

#pragma mark UITextInputDelegate
- (void)selectionWillChange:(nullable id <UITextInput>)textInput {}
- (void)selectionDidChange:(nullable id <UITextInput>)textInput {}
- (void)textWillChange:(nullable id <UITextInput>)textInput {}
- (void)textDidChange:(nullable id <UITextInput>)textInput {}
@end
