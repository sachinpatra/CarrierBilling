//
//  ChatGridViewController.m
//  InstaVoice
//
//  Created by adwivedi on 30/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "ChatGridViewController.h"
#import "EventType.h"
#import "HttpConstant.h"
#import "UIType.h"
#import "SizeMacro.h"
#import "IVFileLocator.h"
#import "BlockUnblockUserAPI.h"
#import "ContactsApi.h"
#import "BrandingScreenViewController.h"
#import "IVChatTableViewCell.h"
#import "IVImageUtility.h"
#import "IVColors.h"
#import "InsideConversationScreen.h"
#import "BlockedChatsViewController.h"
#import "ChatActivity.h"
#import "ContactTableViewCell.h"
#import "CreateNewSingleChatViewController.h"

#import "IVChatTableViewCellTextReceived.h"
#import "IVChatTableViewCellTextSent.h"
#import "IVChatTableViewCellImageReceived.h"
#import "IVChatTableViewCellImageSent.h"
#import "IVChatTableViewCellMissedCallReceived.h"
#import "IVChatTableViewCellMissedCallSent.h"
#import "IVChatTableViewCellVBReceived.h"
#import "IVChatTableViewCellVMsgReceived.h"
#import "IVChatTableViewCellVMsgSent.h"
#import "IVChatTableViewCellVMailReceived.h"
#import "IVChatTableViewCellVMailSent.h"
#import "Common.h"

#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"
#import "IVInAppPromoViewController.h"

#import "Profile.h"
#import "IVVoiceMailListViewController.h"
#import "IVSettingsListViewController.h"
#import "IVPrimaryNumberVoiceMailViewController.h"

#import "UIImage+animatedGIF.h"

#define CHAT_GRID_USE_CONTACT_DETAIL_DATA 1

extern NSString* const kGroupDataUpdated;

#ifdef REACHME_APP
extern NSString* kVOIPCallReceived;
#endif

@interface ChatGridViewController () <ChatGridCellDelegate, UISearchBarDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, SettingProtocol, NSFetchedResultsControllerDelegate, UIActionSheetDelegate>
{
    NSIndexPath* listIndex;
    NSMutableArray* multipleContact;
    UIActionSheet* actionSheetContactSelect;
    BOOL isVoiceMailEnabled, isVoipEnabled;
    UIImage *loadingImage;
    NSNumberFormatter *phoneNumberFormatter;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchRequest* fetchRequest;
@property (nonatomic, strong) NSString* sectionNameKeyPath;
@property (weak, nonatomic) IBOutlet UIView *enableVoiceMailSettingsView;
@property (nonatomic, assign) BOOL isCarrierSelectedSupported;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfEnableVoiceMailSettingsView;
@property (nonatomic, assign) NSInteger defaultHeightOfEnableVoiceMailSettings;
@property (nonatomic, assign) NSInteger defaultWidthOfEnableVoiceMailSettingsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraintsOfVoiceMailSettingsView;

@property (weak, nonatomic) IBOutlet UIView *carrierNotSupportedView;

@property (nonatomic, strong) SettingModel *currentSettingsModel;

@end

@implementation ChatGridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        _currentFilteredList = nil;
        self.uiType = CHAT_GRID_SCREEN;
        _activeConversationDictionary = Nil;
        
        isSearching = NO;
        _hiddenUserIDList = [[NSMutableArray alloc]init];
        _searchString = @"";
        
        self.audioObj = nil;
        _buttonTag = -1;
        drawStripTimer = nil;
        _needToUpdateTable = NO;
        _delAlertView = nil;
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Chats" image:[UIImage imageNamed:@"chats"] selectedImage:[UIImage imageNamed:@"chats_selected"]]];
        
        self.sectionHeaderViewOthers = nil;
        self.sectionHeaderViewChats = nil;
        self.managedObjectContext = [AppDelegate sharedMainQueueContext];
        
        self.showFromToNumber = NO;
        
        cc = [ChatsCommon sharedChatsCommon];
    }
    return self;
}

-(void)viewDidLoad
{
    KLog(@"viewDidLoad");
    EnLogd(@"viewDidLoad");
    
    self.audioObj =[[Audio alloc]init];
    self.audioObj.delegate = self;
    isVoiceMailEnabled = NO;
    isVoipEnabled = NO;
    
    //Hide the enable voice mail settings view
    self.enableVoiceMailSettingsView.hidden = YES;
    self.carrierNotSupportedView.hidden = YES;
    self.defaultHeightOfEnableVoiceMailSettings  = self.heightOfEnableVoiceMailSettingsView.constant;
    self.defaultWidthOfEnableVoiceMailSettingsView = [UIScreen mainScreen].bounds.size.width;
    
    _displayUserType = ChatTypeAll;
    self.uiType = CHAT_GRID_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    
    [super viewDidLoad];

    [Setting sharedSetting].delegate = self;

    self.title = @"Chats";
    self.msgLabel.alpha = 0;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellTextSent" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellTextSent"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellTextReceived" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellTextReceived"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellVMsgReceived" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellVMsgReceived"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellVMsgSent" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellVMsgSent"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellVMailReceived" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellVMailReceived"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellVMailSent" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellVMailSent"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellVBReceived" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellVBReceived"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellImageReceived" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellImageReceived"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellImageSent" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellImageSent"];
    
    
    UINib* nib = [UINib nibWithNibName:@"ContactTableViewCellIv" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ContactTableViewCellIv"];
    
    UINib* nib1 = [UINib nibWithNibName:@"ContactTableViewCellNonIv" bundle:nil];
    [self.tableView registerNib:nib1 forCellReuseIdentifier:@"ContactTableViewCellNonIv"];
    
    UINib* nibReachMeEx = [UINib nibWithNibName:@"IVChatTableViewCellReachMeCallReceivedEx" bundle:nil];
    [self.tableView registerNib:nibReachMeEx forCellReuseIdentifier:@"ConversationCellReachMeCallReceivedEx"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellRingMCReceivedEx" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellRingMCReceivedEx"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellRingMCSentEx" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellRingMCSentEx"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellMissedCallReceivedEx" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellMissedCallReceivedEx"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellMissedCallSentEx" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellMissedCallSentEx"];
    
    
    UINib* nibReachMe = [UINib nibWithNibName:@"IVChatTableViewCellReachMeCallReceived" bundle:nil];
    [self.tableView registerNib:nibReachMe forCellReuseIdentifier:@"ConversationCellReachMeCallReceived"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellRingMCReceived" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellRingMCReceived"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellRingMCSent" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellRingMCSent"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellMissedCallReceived" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellMissedCallReceived"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellMissedCallSent" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellMissedCallSent"];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.topViewHeight.constant = 0;
    
    if([appDelegate.confgReader getObjectForTheKey:CONFG_LOCATION_FALG] == Nil)
        [self checkForLocationPermission];

    // set up the tab bar info
    [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Chats" image:[UIImage imageNamed:@"chats"] selectedImage:[UIImage imageNamed:@"chats_selected"]]];

    if ([self.tableView indexPathForSelectedRow] != nil) {
        // remove the table view's selected elements
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }

    //self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pinstripe"]];
    
    _fetchedResultsController = Nil;
}

- (IBAction)composeNewMessage:(id)sender
{
    [cc composeNewMessage];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

-(void)viewWillAppear:(BOOL)animated
{
    KLog(@"viewWillAppear");
    EnLogd(@"viewWillAppear");
    [cc setDelegate:self];
    loadingImage = nil;
    
#ifdef REACHME_APP
    [appDelegate prepareVoipCallBlockedNumbers];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(voipCallReceived)
                                               name:kVOIPCallReceived
                                             object:nil];
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackGround:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [self.audioObj addObserverForAudioRouteChange];
    [self.tableView setUserInteractionEnabled:YES];
    
    self.uiType = CHAT_GRID_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    [super viewWillAppear:animated];

    if([_searchString length]) {
        isSearching = YES;
        _isNumber = [self isNumber:_searchString];
    }
    
    self.msgLabel.alpha = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    phoneNumberFormatter = [[NSNumberFormatter alloc] init];

    if ([self.tableView indexPathForSelectedRow] != nil) {
        // remove the table view's selected elements
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }

    [cc prepareHiddenUsers];
    [cc prepareBlockedUsers];
    
    /*
     KLog(@"Hidden users' IDs: %@",cc.hiddenUserIDList);
     KLog(@"Blocked users's IDs: %@",cc.blockedUserIDList);
     for( NSMutableDictionary* userDic in _savedCompleteList) {
     NSString* fromUserID = [userDic valueForKey:FROM_USER_ID];
     KLog(@"ALL Users' IDs: %@",fromUserID);
     }
     */
    
    [cc.allMsgsList removeAllObjects];
    [cc.allMsgsList addObjectsFromArray:[appDelegate.engObj getActiveConversationList:TRUE]];
    
    /* DEC 28, 2017
    [appDelegate.engObj getMissedCallList:TRUE];
    [appDelegate.engObj getVoicemailList:TRUE];
     */
    
    _displayTypeFilteredList = [cc filterChatsForDisplayType:_displayUserType];
    _currentFilteredList = _displayTypeFilteredList;
    
    if(_currentFilteredList != nil && [_currentFilteredList count] > 0)
    {
        if(isSearching) {
            NSPredicate *resultPredicate =
            [NSPredicate predicateWithFormat:@"(REMOTE_USER_NAME BEGINSWITH[cd] %@) OR (FROM_USER_ID BEGINSWITH[cd] %@) OR (REMOTE_USER_NAME CONTAINS[c] %@) OR (FROM_USER_ID CONTAINS[c] %@)",
             _searchString,_searchString,_searchString,_searchString];
        
            _currentFilteredList = [NSMutableArray arrayWithArray:
                                    [_displayTypeFilteredList filteredArrayUsingPredicate:resultPredicate]];
        }
        [self loadData];
    }
    else
    {
        if([[self currentActiveResultController].fetchedObjects count]<=0)
            [self unloadData];

        if([cc.allMsgsList count]) {
            if (ChatTypeBlocked == _displayUserType) {
                self.msgLabel.text = NSLocalizedString(@"No Blocked Contacts in List",nil);
            }
            else {
                KLog(@"No Chats");
                self.msgLabel.text = NSLocalizedString(@"NO_CONVERSATION",nil);
            }
        } else {
            KLog(@"No Chats");
            self.msgLabel.text = NSLocalizedString(@"NO_CONVERSATION", nil);
        }
    }

    [self.tableView reloadData];
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                         initWithTarget:self action:@selector(onLongPress:)];
    [self.tableView addGestureRecognizer:longPressRecognizer];
    [self updateUIWithShowOrHideStatusOfEnableVoiceMailButton];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 6, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 6, 0);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if (ChatTypeBlocked != _displayUserType) {
        UIBarButtonItem* composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeNewMessage:)];
        self.navigationItem.rightBarButtonItem = composeButton;
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(updateGroupData)
                                               name:kGroupDataUpdated
                                             object:nil];
}

- (void)appDidBecomeActive:(NSNotification *)notification
{
    self.audioObj = nil;
    self.audioObj = [[Audio alloc]init];
    self.audioObj.delegate = self;
    [self.audioObj addObserverForAudioRouteChange];
}

-(void)viewWillDisappear:(BOOL)animated
{
    KLog(@"viewWillDisappear");
    
    if(drawStripTimer != nil) {
        [drawStripTimer invalidate];
    }
    
    [self stopAudioPlayback];
    [self.audioObj removeObserverForAudioRouteChange];
    
    [super viewWillDisappear:animated];
#ifdef REACHME_APP
    [cc markReadMessagesFromThisList:_currentFilteredList];
#endif
    self.navigationController.navigationBarHidden = NO;
    appDelegate.tabBarController.tabBar.hidden = NO;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)voipCallReceived {
    [self killScroll];
}

- (void)killScroll {
    [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
}

-(void)dealloc {
    
    KLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kGroupDataUpdated
                                                  object:nil];
    
#ifdef REACHME_APP
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kVOIPCallReceived
                                                  object:nil];
#endif
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MAY 11, 2018
-(void)updateGroupData {
    KLog(@"updateGroupData");
    [self performSelectorOnMainThread:@selector(loadData) withObject:nil waitUntilDone:NO];
}
//

-(void)onLongPress:(UILongPressGestureRecognizer*)pGesture
{
    /*
    if (pGesture.state == UIGestureRecognizerStateRecognized)
    {
        KLog(@"Long press on row");
    }*/
    
    CGPoint p = [pGesture locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        KLog(@"long press on table view but not on a row");
    } else if (pGesture.state == UIGestureRecognizerStateBegan) {
        KLog(@"long press on table view at row %ld", (long)indexPath.row);
        IVChatTableViewCell *cell = (IVChatTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        if(cell && [cell respondsToSelector:@selector(setStatusIcon)]) {
            [cell setStatusIcon:nil isAvs:0 readCount:0 msgType:nil];
        }
    } else {
        KLog(@"gestureRecognizer.state = %ld", (long)pGesture.state);
    }
}

- (IBAction)clickToEnableVoiceMailSettingsButtonTapped:(id)sender {
    
    KLog(@"NO IMPL");
}

- (void)updateUIWithShowOrHideStatusOfEnableVoiceMailButton {
   
    self.carrierNotSupportedView.hidden = YES;
    self.tableView.hidden = NO;
    
    //To fix the bug - 10324 - start
    self.enableVoiceMailSettingsView.translatesAutoresizingMaskIntoConstraints = YES;
    self.heightOfEnableVoiceMailSettingsView.constant = self.defaultHeightOfEnableVoiceMailSettings;
    self.widthConstraintsOfVoiceMailSettingsView.constant = self.defaultWidthOfEnableVoiceMailSettingsView;
    self.enableVoiceMailSettingsView.frame = CGRectMake(self.enableVoiceMailSettingsView.frame.origin.x, self.enableVoiceMailSettingsView.frame.origin.y, self.defaultWidthOfEnableVoiceMailSettingsView, self.defaultHeightOfEnableVoiceMailSettings);
    //End.
    
    self.enableVoiceMailSettingsView.hidden = YES;
    self.msgLabel.hidden = (_currentFilteredList && [_currentFilteredList count])?YES:NO;
}

#pragma mark -- Engine Event handling after getting the data
-(int)handleEvent:(NSMutableDictionary *)resultDic
{
    if(resultDic != nil)
    {
        int evType = [[resultDic valueForKey:EVENT_TYPE] intValue];
        NSString *respCode = [resultDic valueForKey:RESPONSE_CODE];
        switch (evType)
        {
            case SEND_MSG:
            {
                NSDictionary* dicResp =  [resultDic valueForKey:RESPONSE_DATA];
                NSArray* sentByServer = [dicResp valueForKey:@"MSG_LIST_FROM_SERVER"];
                if(sentByServer.count) {
                    NSDictionary* dic = sentByServer[0];
                    NSString* msgState = [sentByServer[0] valueForKey:MSG_STATE];
                    if([msgState isEqualToString:API_DELIVERED]) {
                        NSString* msgGuid = [dic valueForKey:MSG_GUID];
                        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.MSG_GUID == %@", msgGuid];
                        NSArray* res = [cc.allMsgsList filteredArrayUsingPredicate:predicate];
                        if(1==res.count) {
                            [res[0] setValue:API_DELIVERED forKey:MSG_STATE];
                            [self loadData];
                        }
                    }
                }
            }
                break;
                
            case GET_ACTIVE_CONVERSATION_LIST:
                KLog(@"GET_ACTIVE_CONVERSATION_LIST");
                if([respCode isEqual:ENG_SUCCESS])
                {
                    [cc.allMsgsList removeAllObjects];
                    [cc.allMsgsList addObjectsFromArray:[appDelegate.engObj getActiveConversationList:FALSE]];
                    _displayTypeFilteredList = [cc filterChatsForDisplayType:_displayUserType];
                    if(!isSearching) {
                        _currentFilteredList = _displayTypeFilteredList;
                    }
                    else {
                        _currentFilteredList = _displayTypeFilteredList;
                        EnLogd(@"Check the code.");
                    }
                    
                    if(_currentFilteredList != nil && [_currentFilteredList count] > 0)
                    {
                        [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeAll]];
                        [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeCalls]];
                        [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeVoiceMail]];
                        [self loadData];
                    }
                    else
                    {
                        [self unloadData];
                    }
                }
                else
                {
                    //CMP TODO [self unloadData];
                }
                break;
                
            /* DEC 28, 2017
            case GET_MISSEDCALL_LIST:
            {
                EnLogd(@"ChatGridViewController - GET_MISSEDCALL_LIST");
                KLog(@"ChatGridViewController - GET_MISSEDCALL_LIST");
                if([respCode isEqualToString:ENG_SUCCESS])
                {
                    _hiddenUserIDList = [[NSMutableArray alloc]initWithArray:[[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"HIDDEN_TILES"]];
                    
                    NSMutableArray *missedCallList = [resultDic valueForKey:RESPONSE_DATA];
                    if(missedCallList) {
                        [appDelegate.engObj getActiveConversationList:TRUE];
                        [_missedCallList removeAllObjects];
                        [_missedCallList addObjectsFromArray:missedCallList];
                        _missedCallList = [self filterChatGridWithElement:_missedCallList forDisplayType:chatTypes.ChatTypeMissedCalls];
                        
                        [self updateBadgeValues:chatTypes.ChatTypeMissedCalls];
                        if(chatTypes.ChatTypeMissedCalls == _displayUserType) {
                            _currentFilteredList = _missedCallList;
                            [self loadData];
                            [self updateUIWithShowOrHideStatusOfEnableVoiceMailButton];
                        }
                    }
                }
                
                break;
            }*/
            
            /* DEC 28, 2017
            case GET_VOICEMAIL_LIST:
            {
                EnLogd(@"ChatGridViewController - GET_VOICEMAIL_LIST");
                KLog(@"ChatGridViewController - GET_VOICEMAIL_LIST");
                if([respCode isEqualToString:ENG_SUCCESS])
                {
                    _hiddenUserIDList = [[NSMutableArray alloc]initWithArray:[[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"HIDDEN_TILES"]];
                    
                    NSMutableArray *voicemailList = [resultDic valueForKey:RESPONSE_DATA];
                    if(voicemailList) {
                        [appDelegate.engObj getActiveConversationList:TRUE];
                        [_voicemailList removeAllObjects];
                        [_voicemailList addObjectsFromArray:voicemailList];
                        _voicemailList = [self filterChatGridWithElement:_voicemailList forDisplayType:chatTypes.ChatTypeVoiceMail];
                        
                        [self updateBadgeValues:chatTypes.ChatTypeVoiceMail];
                        if(chatTypes.ChatTypeVoiceMail == _displayUserType)
                        {
                            _currentFilteredList = _voicemailList;
                            [self loadData];
                            [self updateUIWithShowOrHideStatusOfEnableVoiceMailButton];
                        }
                    }
                }
                
                break;
            }*/
                
            case DOWNLOAD_VOICE_MSG:
            {
                EnLogd(@"ChatGridViewController - DOWNLOAD_VOICE_MSG");
                
                if([respCode isEqualToString:ENG_SUCCESS])
                {
                    NSMutableDictionary *respMsgDic =[resultDic valueForKey:RESPONSE_DATA];
                    int retVal = [self handleDownloadVoiceMsg:respMsgDic];
                    if(retVal<=0) {
                        EnLogd(@"***ERROR: handleDownloadVoiceMsg");
                    }
                }
                break;
            }
            
            /* DEC 28, 2017
            case NOTIFY_MISSEDCALL:
                KLog(@"MissedCall notify");
                if(_displayUserType != chatTypes.ChatTypeBlocked && ![self.audioObj isPlay] ) {
                    _displayUserType = chatTypes.ChatTypeMissedCalls;
                    if([_missedCallList count]) {
                        [self performSelectorOnMainThread:@selector(updateCurrentFilteredList:)
                                               withObject:_missedCallList waitUntilDone:NO];
                    }
                    
                    if(_isAlertShown) {
                        [_delAlertView dismissWithClickedButtonIndex:0 animated:NO];
                    }
                    [appDelegate.stateMachineObj setNavigationController:appDelegate.tabBarController.viewControllers[0]];
                    [appDelegate.tabBarController setSelectedIndex:0];
                    [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[0]];
                }
                break;
             */
               
            /* DEC 28, 2017
            case NOTIFY_VOICEMAIL:
                KLog(@"Voicemail notify");
                if(_displayUserType != chatTypes.ChatTypeBlocked && ![self.audioObj isPlay]) {
                    _displayUserType = chatTypes.ChatTypeVoiceMail;
                    if([_voicemailList count]) {
                        [self performSelectorOnMainThread:@selector(updateCurrentFilteredList:)
                                               withObject:_voicemailList waitUntilDone:NO];
                    }
                    
                    if(_isAlertShown) {
                        [_delAlertView dismissWithClickedButtonIndex:0 animated:NO];
                    }
                    [appDelegate.stateMachineObj setNavigationController:appDelegate.tabBarController.viewControllers[1]];
                    [appDelegate.tabBarController setSelectedIndex:1];
                    [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[1]];
                }
                break;
            */
            case NOTIFY_IVMSG:
                KLog(@"ivmsg notify");
                if(_displayUserType != ChatTypeBlocked && ![self.audioObj isPlay]) {
                    _displayUserType = ChatTypeAll;
                    
                    if([cc.allMsgsList count]) {
                        [self performSelectorOnMainThread:@selector(updateCurrentFilteredList:)
                                               withObject:cc.allMsgsList waitUntilDone:NO];
                    }
                    
                    if(_isAlertShown) {
                        [_delAlertView dismissWithClickedButtonIndex:0 animated:NO];
                    }
                }
                
                break;
                
            case INTERNET_DOWN:
                KLog(@"ChatGridViewController: Internet is down");
                [self.tableView reloadData];
                break;
            
            case CHAT_ACTIVITY:
            {
                KLog(@"CHAT_ACTIVITY");
                if([respCode isEqual:ENG_SUCCESS])
                {
                    ChatActivityData* activity = [resultDic valueForKey:RESPONSE_DATA];
                    
                    NSString* msgGuid = activity.msgGuid;
                    NSPredicate *predicate;
                    if(msgGuid.length)
                        predicate = [NSPredicate predicateWithFormat:@"self.MSG_GUID != %@", msgGuid];
                    else
                        predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID != %@", [NSNumber numberWithInteger:activity.msgId]];
                    
                    switch (activity.activityType)
                    {
                        case ChatActivityTypeWithdraw:
                        case ChatActivityTypeDelete:
                        {
                            [_currentFilteredList filterUsingPredicate:predicate];
                            
                            /* DEC 28, 2017
                            if(chatTypes.ChatTypeMissedCalls == _displayUserType) {
                                NSArray* resMissedCallList = [_missedCallList filteredArrayUsingPredicate:predicate];
                                _missedCallList = [[NSMutableArray alloc] initWithArray:resMissedCallList];
                            }
                            if(_displayUserType == chatTypes.ChatTypeVoiceMail) {
                               NSArray* resVoicemailList = [_voicemailList filteredArrayUsingPredicate:predicate];
                                _voicemailList = [[NSMutableArray alloc] initWithArray:resVoicemailList];
                            }
                            */
                            
                            NSArray* resAll = [cc.allMsgsList filteredArrayUsingPredicate:predicate];
                            cc.allMsgsList = [[NSMutableArray alloc]initWithArray:resAll];
                            [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeAll]];
                            
                            if(_currentFilteredList != nil && [_currentFilteredList count] > 0)
                                [self loadData];
                            else
                                [self unloadData];
                            
                            [appDelegate.engObj getActiveConversationList:TRUE];
                            break;
                        }
                        
                        case ChatActivityTypeReadMessage:
                        {
                            [cc.allMsgsList filteredArrayUsingPredicate:predicate];
                            if(cc.allMsgsList != nil && [cc.allMsgsList count] > 0)
                                [self loadData];
                            else
                                [self unloadData];
                            
                            break;
                        }
                            
                        default: break;
                    }
                }
                break;
            }
            
            case NOTIFY_UI_ON_ACTIVITY:
            {
                KLog(@"NOTIFY_UI_ON_ACTIVITY");
                NSMutableArray* msgActivityList = [resultDic valueForKey:RESPONSE_DATA];
                BOOL reloadRequired = false;
                if(msgActivityList.count && _currentFilteredList.count)
                {
                    for(ChatActivityData* data in msgActivityList)
                    {
                        NSInteger msgId = data.msgId;
                        NSString* msgGUID = data.msgGuid;
                       
                        /* MSG_ID will be zero for the message being sent */
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.MSG_GUID = %@ OR self.MSG_ID = %ld",msgGUID, msgId];
                
                        NSArray* filteredMsgList = [_currentFilteredList filteredArrayUsingPredicate:predicate];
                        
                            
                        if(filteredMsgList.count)
                        {
                            reloadRequired = true;
                            KLog(@"activityType = %ld",(long)data.activityType);
                            
                            switch (data.activityType)
                            {
                                case ChatActivityTypeReadMessage:
                                {
                                    [appDelegate.engObj getActiveConversationList:TRUE];
                                    
                                    /* DEC 28, 2017
                                    if(chatTypes.ChatTypeVoiceMail ==  _displayUserType)
                                        [appDelegate.engObj getVoicemailList:TRUE];
                                    if(chatTypes.ChatTypeMissedCalls == _displayUserType)
                                        [appDelegate.engObj getMissedCallList:TRUE];
                                    */
                                    
                                    break;
                                }
                                    
                                case ChatActivityTypeDelete:
                                {
                                    if([self.audioObj isPlay] ) {
                                        [self stopAudioPlayback];
                                        NSInteger curMsgId = [[self.voiceDic valueForKey:MSG_ID]integerValue];
                                        if(curMsgId>0 && (curMsgId == msgId)) {
                                            [self performSelectorOnMainThread:@selector(showWithdrawnAlert)
                                                                   withObject:nil waitUntilDone:NO];
                                        }
                                    }
                                    
                                    /* DEC 28, 2017
                                    [self deleteMissedCall:msgId];
                                    [self deleteVoicemail:msgId];
                                    */
                                    
                                    [appDelegate.engObj getActiveConversationList:TRUE];
                                    
                                    /* DEC 28, 2017
                                    if(chatTypes.ChatTypeVoiceMail ==  _displayUserType)
                                        [appDelegate.engObj getVoicemailList:TRUE];
                                    if(chatTypes.ChatTypeMissedCalls == _displayUserType)
                                        [appDelegate.engObj getMissedCallList:TRUE];
                                     */
                                    
                                    break;
                                }
                                    
                                case ChatActivityTypeRing:
                                {
                                    if([respCode isEqualToString:ENG_SUCCESS]) {
                                        NSString* msgContent = [NSString stringWithFormat:RING_MC_SUCCESS];
                                        if(data.dic) {
                                            msgContent = [data.dic valueForKey:MSG_CONTENT];
                                        }
                                        [filteredMsgList[0] setValue:msgContent forKey:MSG_CONTENT];
                                    }
                                    else {
                                        [filteredMsgList[0] setValue:RING_MC_FAILED forKey:MSG_CONTENT];
                                    }
                                    break;
                                }
                                    
                                case ChatActivityTypeWithdraw:
                                {
                                    if ([self.audioObj isPlay]) {
                                        if(msgId == [[self.voiceDic valueForKey:MSG_ID]integerValue]) {
                                            [self stopAudioPlayback];
                                            [self performSelectorOnMainThread:@selector(showWithdrawnAlert)
                                                                   withObject:nil waitUntilDone:NO];
                                        }
                                    }
                                    /* DEC 28, 2017
                                    [self deleteMissedCall:msgId];
                                    [self deleteVoicemail:msgId];
                                    */
                                    
                                    [appDelegate.engObj getActiveConversationList:TRUE];
                                    
                                    /* DEC 28, 2017
                                    if(chatTypes.ChatTypeVoiceMail == _displayUserType)
                                        [appDelegate.engObj getVoicemailList:TRUE];
                                    if(chatTypes.ChatTypeMissedCalls == _displayUserType)
                                        [appDelegate.engObj getMissedCallList:TRUE];
                                     */
                                    
                                    break;
                                }
                                    
                                default: break;
                            }
                        }
                        else {
                            // If we receive a new audio message while the current one is being played, the _currentFilteredList
                            // will only contain the dic of the new message received.
                            if ([self.audioObj isPlay]) {
                                if(msgId == [[self.voiceDic valueForKey:MSG_ID]integerValue]) {
                                    [self stopAudioPlayback];
                                    [self performSelectorOnMainThread:@selector(showWithdrawnAlert)
                                                           withObject:nil waitUntilDone:NO];
                                    [appDelegate.engObj getActiveConversationList:TRUE];
                                }
                            }
                        }
                    }
                }
                
                if(reloadRequired) {
                    [self reloadDataOnMainThread];
                    //[self @selector(reloadDataOnMainThread) withObject:nil waitUntilDone:NO];
                }
                
                break;
            }
                
            default: break;
        }
    }
    return SUCCESS;
}



/* This method should be called from handleEvent only in order to make _missedCallList thread-safe
   Delete a missedcall msg from the instance variable _missedCallList
 */
/*
-(void)deleteMissedCall:(NSUInteger)msgID
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"!(MSG_ID = %ld)", msgID];
    _missedCallList = [NSMutableArray arrayWithArray:[_missedCallList filteredArrayUsingPredicate:resultPredicate]];
    KLog(@"Debug");
}*/

/* This method should be called from handleEvent only in order to make _missedCallList thread-safe
   Delete a voicemail msg from the instance variable _voicemailList
 */
/*
-(void)deleteVoicemail:(NSUInteger)msgID
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"!(MSG_ID = %ld)", msgID];
    _voicemailList = [NSMutableArray arrayWithArray:[_voicemailList filteredArrayUsingPredicate:resultPredicate]];
    KLog(@"Debug");
}*/
//

-(void)reloadDataOnMainThread {
    [self.tableView reloadData];
}

-(void)showWithdrawnAlert
{
    UIAlertView *commonAlert = [[UIAlertView alloc]initWithTitle:@"Message Withdrawn"
                                                         message:@"Sorry, message has been withdrawn."
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"Ok", nil];
    [commonAlert show];
}

-(void)updateCurrentFilteredList:(NSMutableArray*)list
{
    BOOL doRefreshTable = NO;
    if(ChatTypeAll == _displayUserType) {
        if(list!=nil) {
            _displayTypeFilteredList = list;
            self.tableView.hidden = NO;
            self.enableVoiceMailSettingsView.hidden = YES;
            KLog(@"updateCurrentFilteredList : ChatTypeAll");
        }
    }
    /*DEC 29, 2017
    else if(ChatTypeCalls == _displayUserType) {
        if([_displayTypeFilteredList count] != [_missedCallList count]) {
            doRefreshTable = YES;
        }
        _displayTypeFilteredList = _missedCallList;
        [self updateBadgeValues:ChatTypeAll];
        KLog(@"updateCurrentFilteredList : ChatTypeMissedCalls");
    }
    else if(ChatTypeVoiceMail == _displayUserType) {
        if([_displayTypeFilteredList count] != [_missedCallList count]) {
            doRefreshTable = YES;
        }
        _displayTypeFilteredList = _voicemailList;
        [self updateBadgeValues:ChatTypeAll];
        KLog(@"updateCurrentFilteredList : ChatTypeVoiceMail");
    }*/

    // If audio is already being played, don't update the table, till it is finised playing.
    // Reload the table once it is over.
    if([self.audioObj isPlay]) {
        _needToUpdateTable = YES;
        //TODO: need to stop audio and update the table?
        return;
    }
    
    _currentFilteredList = _displayTypeFilteredList;
    
    if(doRefreshTable) {
        [self.tableView reloadData];
    }
}

-(void)loadData
{
    KLog(@"loadData");
    
#if CHAT_GRID_USE_CONTACT_DETAIL_DATA
    NSMutableArray* phoneNumList = [[NSMutableArray alloc]init];
    NSString* fromUserID=nil;
    for(NSMutableDictionary* dic in _currentFilteredList)
    {
        fromUserID = [dic valueForKey:FROM_USER_ID];
        if(fromUserID && fromUserID.length)
            [phoneNumList addObject:fromUserID];
        else {
            EnLogd(@"FROM_USER_ID is nil");
        }
    }
    _activeConversationDictionary = [[Contacts sharedContact]getContactDictionaryForChatGridScreen:phoneNumList];
#endif
    
    [self updateRemoteUserNameOfActiveConversation:_currentFilteredList Info:_activeConversationDictionary];
    
    if([_currentFilteredList count])
        self.msgLabel.hidden = YES;
    
    if(_needToUpdateTable) {
        if([_displayTypeFilteredList count])
            _currentFilteredList = _displayTypeFilteredList;
        _needToUpdateTable = 0;
    }
    
    if([_searchString length]) {
        NSString* searchText = _searchString;
        NSString *textWithoutPlus = [searchText hasPrefix:@"+"] ? [searchText substringFromIndex:1] : [NSString stringWithString:searchText];
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(REMOTE_USER_NAME BEGINSWITH[cd] %@) OR (FROM_USER_ID BEGINSWITH[cd] %@) OR (REMOTE_USER_NAME CONTAINS[c] %@) OR (FROM_USER_ID CONTAINS[c] %@)", textWithoutPlus, textWithoutPlus, textWithoutPlus, textWithoutPlus];
        _currentFilteredList = [NSMutableArray arrayWithArray:[_displayTypeFilteredList filteredArrayUsingPredicate:resultPredicate]];
    }
    
    
     /*
     int unReadMsgCount = [appDelegate.engObj getUnreadMsgCount];
     [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unReadMsgCount];
     */
    
    // Once the clicked voice msg is downloaded, don't update the table with new query result having msg_read_cnt 1.
    // Update the table after playback of voice msg is done.
    BOOL isPlaying = [[self.voiceDic valueForKey:MSG_PLAYBACK_STATUS]intValue];
    if(!isPlaying) {
        [self.tableView reloadData];
    }
    if(isPlaying && ![self.audioObj isPlay]) {
        [self.voiceDic setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAYBACK_STATUS];
        [self.tableView reloadData];
    } else {
        if(isPlaying && [self.audioObj isPlay]) {
            KLog(@"Refresh only the new msg received");
            [self.tableView reloadData];
        }
    }
    
    [cc updateBadgeValues:[NSNumber numberWithInt:_displayUserType]];
}

-(void)unloadData
{
    self.msgLabel.hidden = NO;
    self.msgLabel.alpha = 1;
    [UIView animateWithDuration:.25 animations:^{
        self.msgLabel.alpha = 1;
    }];

    if(!isSearching)
    {
        if (ChatTypeBlocked == _displayUserType) {
            self.msgLabel.text = NSLocalizedString(@"No Blocked Contacts in List",nil);
        }
        else {
            KLog(@"No Chats");
            self.msgLabel.text = NSLocalizedString(@"NO_CONVERSATION", nil);
        }
    }
    else
    {
        if (ChatTypeBlocked == _displayUserType) {
            self.msgLabel.text = NSLocalizedString(@"No Blocked Contacts in List",nil);
        }
        else if(![cc.allMsgsList count]) {
            KLog(@"No Chats");
            self.msgLabel.text = NSLocalizedString(@"NO_CONVERSATION", nil);
        }
        else {
            self.msgLabel.text = NSLocalizedString(@"NO_RESULT", nil);
        }
    }

    [self.tableView reloadData];
}

//- Gets the Contact Name from the Contacts DB and updates the name in the current active conversation list
-(void) updateRemoteUserNameOfActiveConversation:(NSMutableArray*)chatUserList Info:(NSMutableDictionary*)conversationDic
{
    //KLog(@"updateRemoteUserNameOfActiveConversation");
    
    for(NSMutableDictionary* msgDic in chatUserList) {
        ContactDetailData* detail = [conversationDic valueForKey:[msgDic valueForKey:FROM_USER_ID]];
        NSString* contactName = detail.contactIdParentRelation.contactName;//TODO: Check. crash at this line.
        if(contactName && [contactName length]) {
            /*
            KLog(@"%@: contactName = %@",[msgDic valueForKey:FROM_USER_ID], contactName);
            if([contactName containsString:@"8892724917"]) {
                KLog(@"Debug");
            }*/
            
            [msgDic setValue:detail.contactIdParentRelation.contactName forKey:REMOTE_USER_NAME];
        }
        else {
            EnLogd(@"Empty contact name from Contacts DB");
        }
    }
}

-(NSString*)getCellIndentifierForRow:(int)rowValue CellDic:(NSMutableDictionary*)dic
{
    static NSString *cellAudioReceiver = @"ConversationCellVMsgReceived";
    static NSString *cellAudioSender = @"ConversationCellVMsgSent";
    static NSString *cellTextReceiver = @"ConversationCellTextReceived";
    static NSString *cellTextSender = @"ConversationCellTextSent";
    static NSString *cellImageReceiver = @"ConversationCellImageReceived";
    static NSString *cellImageSender = @"ConversationCellImageSent";
    static NSString *cellVoicemailReceiver = @"ConversationCellVMailReceived";
    static NSString *cellVoicemailSender = @"ConversationCellVMailSent";
    static NSString *cellMissedCallReceiver = @"ConversationCellMissedCallReceived";
    static NSString *cellMissedCallReceiverEx = @"ConversationCellMissedCallReceivedEx";
    static NSString *cellMissedCallSender = @"ConversationCellMissedCallSent";
    static NSString *cellMissedCallSenderEx = @"ConversationCellMissedCallSentEx";
    static NSString *cellRingMissedCallReceiver = @"ConversationCellRingMCReceived";
    static NSString *cellRingMissedCallReceiverEx = @"ConversationCellRingMCReceivedEx";
    static NSString *cellRingMissedCallSender = @"ConversationCellRingMCSent";
    static NSString *cellRingMissedCallSenderEx = @"ConversationCellRingMCSentEx";
    static NSString *cellVoboloReceiver = @"ConversationCellVBReceived";
    static NSString *cellReachMe = @"ConversationCellReachMeCallReceived";
    static NSString *cellReachMeEx = @"ConversationCellReachMeCallReceivedEx";
    
    NSString* msgContentType = [dic valueForKey:MSG_CONTENT_TYPE];
    NSString* msgFlow = [dic valueForKey:MSG_FLOW];
    NSString* msgType = [dic valueForKey:MSG_TYPE];
    NSString* msgSubType = [dic valueForKey:MSG_SUB_TYPE];
   
   /*
    NSString* fromUserID = [dic valueForKey:FROM_USER_ID];
    if( [fromUserID isEqualToString:@"919972598999"]) {
        KLog(@"Check this");
    }
    */
    
    if([msgContentType isEqualToString:AUDIO_TYPE])
    {
        if([msgType isEqualToString:CELEBRITY_TYPE]) {
            return cellVoboloReceiver;
        }
        else if([msgType isEqualToString:VSMS_TYPE] &&
                ([msgSubType isEqualToString:AVS_TYPE] || [msgSubType isEqualToString:VSMS_TYPE])) {
            if([msgFlow isEqualToString:MSG_FLOW_R]) {
                return cellVoicemailReceiver;
            }
            else {
                return cellVoicemailSender;
            }
        }
        else if([msgType isEqualToString:IV_TYPE]) {
            if([msgFlow isEqualToString:MSG_FLOW_R]) {
                return cellAudioReceiver;
            }
            else {
                return cellAudioSender;
            }
        }
        else if(!msgSubType.length || [msgFlow isEqualToString:MSG_FLOW_S]) {
            return cellAudioSender;
        }
    }
    else if([msgContentType isEqualToString:IMAGE_TYPE])
    {
        if([msgFlow isEqualToString:MSG_FLOW_R]) {
            return cellImageReceiver;
        }
        else {
            return cellImageSender;
        }
    }
    else if([msgContentType isEqualToString:TEXT_TYPE]) {
        
        if([msgType isEqualToString:MISSCALL]) {
            if([msgFlow isEqualToString:MSG_FLOW_R]) {
                if([msgSubType isEqualToString:RING_MC]) {
                    if(self.showFromToNumber)
                        return cellRingMissedCallReceiverEx;
                    else
                        return cellRingMissedCallReceiver;
                }
                else {
                    if(self.showFromToNumber)
                        return cellMissedCallReceiverEx;
                    else
                        return cellMissedCallReceiver;
                }
            }
            else {
                if([msgSubType isEqualToString:RING_MC]) {
                    if(self.showFromToNumber)
                        return cellRingMissedCallSenderEx;
                    else
                        return cellRingMissedCallSender;
                }
                else {
                    if(self.showFromToNumber)
                        return cellMissedCallSenderEx;
                    else
                        return cellMissedCallSender;
                }
            }
        }
        else if([msgType isEqualToString:VOIP_TYPE]) {
            if(self.showFromToNumber)
                return cellReachMeEx;
            else
                return cellReachMe;
        }
        else if([msgType isEqualToString:AVS_TYPE]) {
            KLog(@"***** TEXT AVS TYPE CELL...NO IMPL");
        }
        else if([msgType isEqualToString:VSMS_TYPE]) {
            if([msgFlow isEqualToString:MSG_FLOW_R]) {
                return cellTextReceiver;
            }
            else {
                return cellTextSender;
            }
        }
        else {
            if([msgFlow isEqualToString:MSG_FLOW_R]) {
                return cellTextReceiver;
            }
            else {
                return cellTextSender;
            }
        }
    }
    
    EnLogd(@"cell identifier is nil. FIXME");
    return nil;
}

#pragma mark - Table View Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(0 == indexPath.section) {
        // get the object whose data we are displaying in this cell
        if(![_currentFilteredList count] || indexPath.row > [_currentFilteredList count]) {
            //TODO: FIXME; Returning nil will lead to a crash. cannot recover from this error.
            //Provide a proper UI to the user to exit the app gracefully.
            EnLogd(@"***Going to crash. arr count: %ld",[_currentFilteredList count]);
            return nil;
        }
        
        NSMutableDictionary *cellObject = [_currentFilteredList objectAtIndex:indexPath.row];
        NSString* cellIdentifier = [self getCellIndentifierForRow:(int)indexPath.row CellDic:cellObject];
        if(!cellIdentifier) {
            KLog(@"**** ERROR: cellIdenitifier is nil");
        }
        
        IVChatTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if(cell) {
            cell.cellIndex = indexPath.row;
            cell.delegate = self;
            cell.dic = cellObject;
            if(!cell.dic) {
                KLog(@"row = %lu, DIC is nil, *** ERROR ***, check the code.",(unsigned long)cell.cellIndex);
                return nil;
            }
            
            [cell configureCellForChatTile:cellObject forRow:(int)indexPath.row];
        }
        else {
            KLog(@"*** ERROR: Why empty cell?");
        }
    
        return cell;
    }
    else {
        id dic = nil;
        NSInteger fetchedObjectsCount = [[self currentActiveResultController].fetchedObjects count];
        
        if(indexPath.row < fetchedObjectsCount) {
            NSIndexPath* newIP = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            dic = [[self currentActiveResultController] objectAtIndexPath:newIP];
        }
        ContactTableViewCell* cell = nil;
        ContactDetailData* contactDetailData = dic;
        if([contactDetailData.ivUserId boolValue]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCellIv" forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCellNonIv" forIndexPath:indexPath];
        }
        
        cell.delegate = self;
        cell.selectedRowIndex = indexPath;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if(nil != dic && _searchString.length) {
            NSManagedObject* mOb = dic;
            NSError* error = nil;
            if([self.managedObjectContext existingObjectWithID:mOb.objectID error:&error]) {
                    [cell configurePBCellWithDetailData:dic];
            } else {
                KLog(@"ManagedObject does not exist. Might have been deleted..!! Error:%@",error);
            }
        } else {
            KLog(@"ManagedObject is nil");
        }
        
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(0==section) {
        return  [_currentFilteredList count];
    }
    else {
        NSInteger numberOfRows = 0;
        
        if ([[[self currentActiveResultController] sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[[self currentActiveResultController] sections] objectAtIndex:0];
            numberOfRows = [sectionInfo numberOfObjects];
        }
        
        return numberOfRows;
    }
}

- (BOOL)isContactBlocked:(NSString *)contactNumberID
{
    NSArray* arrBlockedListFromSettings = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"BLOCKED_TILES"];
    
    for (NSString *contactID in arrBlockedListFromSettings) {
        if ([contactNumberID isEqualToString:contactID]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (ChatTypeBlocked == _displayUserType) {
        
        UIAlertController *blockedInfo = [UIAlertController alertControllerWithTitle:@"Unblock your friend" message:@"Do you want to Unblock the user?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            UIButton *btn = [UIButton new];
            btn.tag = 1;
            
            [self buttonTappedRespond:btn withUniqueIdentifier:@"chatGrid_menuTapped"];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            
        }];
        
        [blockedInfo addAction:ok];
        [blockedInfo addAction:cancel];
        
        [self presentViewController:blockedInfo animated:YES completion:nil];
        [blockedInfo.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        
        return;
    }
    
    if(indexPath.section != 0) {
        
        NSIndexPath* newIP = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        ContactDetailData* selectedContact = nil;
        if ([self currentActiveResultController].fetchedObjects.count > newIP.row) {
            selectedContact = [[self currentActiveResultController] objectAtIndexPath:newIP];
        }
        
        if ([self isContactBlocked:[NSString stringWithFormat:@"%@",selectedContact.contactId]] || [self isContactBlocked:[NSString stringWithFormat:@"%@",selectedContact.ivUserId]] || [self isContactBlocked:[NSString stringWithFormat:@"%@",selectedContact.contactDataValue]]) {
            UIAlertController *blockedInfo = [UIAlertController alertControllerWithTitle:@"User blocked" message:@"Please unblock the user in Settings -> Account -> Blocked contacts." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                
            }];
            
            [blockedInfo addAction:ok];
            
            [self presentViewController:blockedInfo animated:YES completion:nil];
            [blockedInfo.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
            
            return;
        }
    }
    
    [self.tableView setUserInteractionEnabled:NO];
    
    if(0==indexPath.section) {
        if(_buttonTag > -1) {
            [self stopAudioPlayback];
        }
        
        NSString* remoteUserIvId = @"";
        //NSString* contactName = @"";
        //NSString* contactPic = @"";
        if(indexPath.row < [_currentFilteredList count]) {
            NSMutableDictionary* chatConversationList = [_currentFilteredList objectAtIndex:indexPath.row];
            NSMutableDictionary* copyConversationList = [[NSMutableDictionary alloc]initWithDictionary:chatConversationList];
            
            //Get the contact detail
            NSString* fromUserId = [copyConversationList valueForKey:FROM_USER_ID];
            ContactDetailData* detail = [_activeConversationDictionary valueForKey:fromUserId];
            NSArray* contactDetailList = [[Contacts sharedContact]getContactForPhoneNumber:fromUserId];
            if([contactDetailList count]) {
                for(ContactDetailData* detailData in contactDetailList) {
                    ContactData* contactData = detailData.contactIdParentRelation;
                    KLog(@"isIV = %@",contactData.isIV);
                    KLog(@"ivUserId = %@",detailData.ivUserId);
                    KLog(@"contactDataValue = %@",detailData.contactDataValue);
                    KLog(@"contactName = %@",contactData.contactName);
                    KLog(@"contactPic = %@", contactData.contactPic);
                    
                    if([fromUserId isEqualToString:detailData.contactDataValue]) {
                        //contactName = contactData.contactName;
                        //contactPic = contactData.contactPic;
                    
                        if(contactData.isIV) {
                            remoteUserIvId = [detailData.ivUserId stringValue];
                            break;
                        }
                    }
                }
            }
            //
            //FEB 21, 2017 if(detail != Nil)
            {
                if(!remoteUserIvId.length || [remoteUserIvId integerValue]<=0)
                {
                    [copyConversationList setValue:[[NSNumber numberWithBool:NO]stringValue] forKey:REMOTE_USER_IV_ID];
                    [copyConversationList setValue:PHONE_MODE forKey:REMOTE_USER_TYPE];
                    [copyConversationList setValue:VSMS_TYPE forKey:MSG_TYPE];
                }
                else
                {
                    [copyConversationList setValue:remoteUserIvId forKey:REMOTE_USER_IV_ID];
                    if(NO == [[copyConversationList valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE]) {
                        [copyConversationList setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
                        [copyConversationList setValue:IV_TYPE forKey:MSG_TYPE];
                    }
                }
                [copyConversationList setValue:detail.contactIdParentRelation.contactName forKey:REMOTE_USER_NAME];
                [copyConversationList setValue:[IVFileLocator getNativeContactPicPath:detail.contactIdParentRelation.contactPic] forKey:REMOTE_USER_PIC];
            }
            
            if(copyConversationList != nil && [copyConversationList count] > 0)
            {
                [[UIDataMgt sharedDataMgtObj] setCurrentChatUser:copyConversationList];
                BaseUI* uiObj = [[InsideConversationScreen alloc]
                                 initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
                
                [self.navigationController pushViewController:uiObj animated:YES];
            }
        }
        else {
            EnLogd(@"Should not happen. Check the code.");
        }
    }
    else {
        NSIndexPath* newIP = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        ContactDetailData* selectedContact = [[self currentActiveResultController] objectAtIndexPath:newIP];
        if([selectedContact.contactIdParentRelation.contactType integerValue] == ContactTypeIVGroup)
        {
            [self moveToGroupChatScreen:selectedContact.contactIdParentRelation];
        }
        else
        {
            [self moveToConversationScreen:selectedContact];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   if(0==indexPath.section)
       return 86;
   else
       return 60;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //To remove extra grey lines at the end of table viiew
    return 0.01f;
}*/

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(0 == indexPath.section)
        return YES;
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
        //If your data source is an NSMutableArray, do this
//        [self.dataArr ay removeObjectAtIndex:indexPath.row];
//        [tableView reloadData]; // tell table to refresh now
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    if(0 == indexPath.section) {
        currentIndexPath = indexPath;
        _currentTile = (int)indexPath.row;
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            UIButton *btn = [UIButton new];
            btn.tag = 3;
            [self buttonTappedRespond:btn withUniqueIdentifier:@"chatGrid_menuTapped"];
        }];
        UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Block" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            
            UIAlertController *blockedInfo = [UIAlertController alertControllerWithTitle:@"Block the user" message:@"Do you want to Block the user?" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // flag the row
                UIButton *btn = [UIButton new];
                btn.tag = 1;
                [self buttonTappedRespond:btn withUniqueIdentifier:@"chatGrid_menuTapped"];
            }];
            
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self.tableView reloadData];
            }];
            
            [blockedInfo addAction:yesAction];
            [blockedInfo addAction:noAction];
            
            [self presentViewController:blockedInfo animated:YES completion:nil];
            [blockedInfo.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        }];
        
        //DC
        UITableViewRowAction *withdrawAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Withdraw" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            UIButton *btn = [UIButton new];
            btn.tag = 2;
            [self buttonTappedRespond:btn withUniqueIdentifier:@"chatGrid_menuTapped"];
        }];
        UITableViewRowAction *closeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Close" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            UIButton *btn = [UIButton new];
            btn.tag = 0;
            [self buttonTappedRespond:btn withUniqueIdentifier:@"chatGrid_menuTapped"];
        }];
        
        //for Chats Tab
        if([_currentFilteredList count] > indexPath.row) {
            NSMutableDictionary* dic = [_currentFilteredList objectAtIndex:indexPath.row];
            NSString* conversationType = [dic valueForKey:CONVERSATION_TYPE];
            if(![conversationType isEqualToString:GROUP_TYPE]) {
                return @[closeAction, blockAction];
            } else {
                return @[closeAction];
            }
        }
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(0==section) {
        if(!_currentFilteredList.count)
            return 0.0;
        
        if(ChatTypeBlocked == _displayUserType)
            return 1.0;
        
        return self.sectionHeaderViewChats.frame.size.height;
    }
    else {
        return self.sectionHeaderViewOthers.frame.size.height;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.sectionHeaderViewOthers && self.sectionHeaderViewChats)
        return 2;
    
    return 1;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(0==section) {
        if(!_currentFilteredList.count)
            return nil;
        
        UILabel *headerLabel = [self.sectionHeaderViewChats viewWithTag:SECTION_CHAT_TAG];
        headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
        return self.sectionHeaderViewChats;
    }
    else {
        UILabel *headerLabel = [self.sectionHeaderViewChats viewWithTag:SECTION_OTHER_TAG];
        headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
        return self.sectionHeaderViewOthers;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
 
    NSString* title = @"Chats";
    if(0==section) {
        if(!_currentFilteredList.count)
            return nil;
        
        else if(ChatTypeBlocked == _displayUserType)
            title = @"";
    }
    else {
        title = @"Other contacts";
    }
    
    return title;
}

#pragma mark -- ChatGridCellDelegate
-(void)audioButtonClickedAtIndex:(NSInteger)index
{
    [self voiceMsgAction:index];
}

#pragma mark -- ChatGridCellDelegate
-(void)transcriptButtonClickedAtIndex:(NSInteger)index withMsgDic:(NSDictionary *)msgDic
{
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow: index inSection:0]];
}

-(void)callbackIndicatorClickedAtIndex:(NSInteger)index
{
    KLog(@"displayType %ld",(long)_displayUserType);
}

-(void)setCurrentTime:(double)time {
    [self.audioObj setCurrentTime:time];
}

#pragma mark -- ChatMobileNumberProtocol delegate
-(void)dismissedChatMobileNumberViewController:(id)sender
{
    NSMutableDictionary *newDic = sender;
    // if the sender object is nil or has nothing in it, the user has asked to chat with his own phone number, so simply go to the notes screen.
    if(newDic == nil && [newDic count] == 0) {
        self.tabBarController.selectedIndex = 4;//Nots Tab
    }
    else
    {
        //Set Chats Tab
        [appDelegate.tabBarController setSelectedIndex:2];
        [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[2]];
        
        [appDelegate.dataMgt setCurrentChatUser:newDic];
        InsideConversationScreen *conversationScreen = [[InsideConversationScreen alloc]initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
        
        [appDelegate.getNavController pushViewController:conversationScreen animated:YES];
    }
}

#pragma mark -- IVDropDownDelegate User selection handling
-(void)buttonTappedRespond:(id)sender withUniqueIdentifier:(NSString*)uniqueIdentifier
{
    isDeleteVoiceMail = NO;
    isDeleteMissedCall = NO;
    isWithDrawSentMissedCall = NO;
    isWithDrawSentVoiceMail = NO;
    
    if([self.audioObj isPlay]) {
        [self stopAudioPlayback];
    }
    
    UIButton *btn = (UIButton*)sender;
    if(!btn && !uniqueIdentifier) {
        return;
    }
    
    if([uniqueIdentifier isEqualToString:@"chatGrid_menuTapped"])
    {
        if( _currentTile >= [_currentFilteredList count]) {
            EnLogd(@"FIXME: Wrong Tile index");
            return;
        }

        if ([btn tag] == 0) {
            //- Close option is selected

            NSMutableDictionary* curTitle = [_currentFilteredList objectAtIndex:_currentTile];
            NSString* remoteUserID = nil;
            NSString* convType = [curTitle valueForKey:CONVERSATION_TYPE];
            BOOL isRemoteUserId = FALSE;
            
            if( [convType isEqualToString:GROUP_TYPE]) {
                remoteUserID = [curTitle valueForKey:FROM_USER_ID];
            }
            else {
                remoteUserID = [curTitle valueForKey:REMOTE_USER_IV_ID];
                if(!remoteUserID || ![remoteUserID length] || [remoteUserID isEqualToString:@"0"]) {
                    remoteUserID = [curTitle valueForKey:FROM_USER_ID];
                } else {
                    isRemoteUserId = TRUE;
                }
            }
            
            if(remoteUserID != nil && [remoteUserID length]) {
                [_hiddenUserIDList addObject:remoteUserID];
                [[ConfigurationReader sharedConfgReaderObj] setObject:_hiddenUserIDList forTheKey:@"HIDDEN_TILES"];
                
                //TODO: CMP, may cause crash when _currentFilteredList gets modified. Check.
                NSPredicate *predicate=nil;
                if(isRemoteUserId)
                    predicate = [NSPredicate predicateWithFormat:@"(REMOTE_USER_IV_ID != %@)", remoteUserID];
                else
                    predicate = [NSPredicate predicateWithFormat:@"(FROM_USER_ID != %@)", remoteUserID];
                    
                _currentFilteredList = [NSMutableArray arrayWithArray:[_currentFilteredList filteredArrayUsingPredicate:predicate]];
                
                [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeAll]];
                [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeCalls]];
                [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeVoiceMail]];
                [self.tableView reloadData];
                
            } else {
                //TODO handle the error
                EnLogd(@"HIDE: ERROR");
            }
        }
        else if ([btn tag] == 1) {
            //- Block option is selected
            
            NSMutableDictionary* curTitle = [_currentFilteredList objectAtIndex:_currentTile];
            NSMutableString* remoteUserIVID = [curTitle valueForKey:REMOTE_USER_IV_ID];
            NSMutableString* fromUserID = [curTitle valueForKey:FROM_USER_ID];
            NSString* convType = [curTitle valueForKey:CONVERSATION_TYPE];
            bool isGroup = (convType && [convType isEqualToString:GROUP_TYPE]);

            if([fromUserID isEqualToString:@"912222222222"]||[fromUserID isEqualToString:@"911111111111"])
            {
                [ScreenUtility showAlert:@"Help and Suggestion can not be blocked"];
                return;
            }

            if ([Common isNetworkAvailable] != NETWORK_AVAILABLE){
                [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
                return;
            }
            
            if(!remoteUserIVID || ![remoteUserIVID length] || [remoteUserIVID isEqualToString:@"0"])
                remoteUserIVID = [curTitle valueForKey:FROM_USER_ID];
            
            if(remoteUserIVID != nil && [remoteUserIVID length] && !isGroup ) {
                [_currentFilteredList removeObjectAtIndex:_currentTile];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_currentTile inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeAll]];
                [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeCalls]];
                [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeVoiceMail]];
                [self.tableView reloadData];

                NSMutableDictionary* req =  [self prepareRequestForBlockUnblockUser:([self isKindOfClass:[BlockedChatsViewController class]] ? @"u" : @"b") ForTheUsers:curTitle];
                if(req)
                {
                    if([[req valueForKey:BLOCKED_FLAG]isEqualToString:@"non_block"])
                    {
                        [ScreenUtility showAlertMessage:@"Help and Suggestion can not be blocked"];
                    }
                    else
                    {
                        [req setValue:remoteUserIVID forKey:REMOTE_USER_IV_ID];
                        [req setValue:fromUserID forKey:FROM_USER_ID];
                        [self blockUnblockUser:req];
                    }
                }
            }
            else {
                //TODO handle the error
                EnLogd(@"BLOCK: ERROR");
            }
        }
        else if ([btn tag] == 3)
        {
            //Delete is selected
            
            if ([[[_currentFilteredList objectAtIndex:_currentTile] valueForKey:MSG_TYPE] isEqualToString:@"vsms"]){
                [self commonAlert:@"Delete voicemail?":@"This voicemail will be deleted from your account.":@"Delete"];
                isDeleteVoiceMail = YES;
                
            } else if ([[[_currentFilteredList objectAtIndex:_currentTile] valueForKey:MSG_TYPE] isEqualToString:@"mc"]){
                [self commonAlert:@"Delete missed call?" : @"This missed call will be deleted from your account." :@"Delete"];
                isDeleteMissedCall = YES;
            }
            else if ([[[_currentFilteredList objectAtIndex:_currentTile] valueForKey:MSG_TYPE] isEqualToString:VOIP_TYPE]) {
                [self commonAlert:@"Delete message?" : @"This message will be deleted from your account." :@"Delete"];
            }
        }
        else if (btn.tag == 2) {
            if ([[[_currentFilteredList objectAtIndex:_currentTile] valueForKey:MSG_TYPE] isEqualToString:@"vsms"]){
                
                [self commonAlert:@"Withdraw voicemail?":@"This voicemail will be deleted from yours and the recipient's account.":@"Withdraw"];
                isWithDrawSentVoiceMail = YES;
                
            }else if ([[[_currentFilteredList objectAtIndex:_currentTile] valueForKey:MSG_TYPE] isEqualToString:@"mc"]){
                [self commonAlert:@"Withdraw missed call?" : @"This missed call will be deleted from your account and the recipient's account." :@"Withdraw"];
                isWithDrawSentMissedCall = YES;
            }
        }
    }
}

-(void)commonAlert:(NSString*) alertTitle : (NSString*) alertMessage :(NSString*)okButton
{
    if(!_isAlertShown) {
        _delAlertView = [[UIAlertView alloc]initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:okButton, nil];
        [_delAlertView show];
        _isAlertShown = YES;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([Common isNetworkAvailable]) {
    
        if( _currentTile >= [_currentFilteredList count]) {
            EnLogd(@"Wrong Index:%ld/%ld",_currentTile,[_currentFilteredList count]);
            return;
        }
        
        NSMutableDictionary* cellDic = [_currentFilteredList objectAtIndex:_currentTile];
        if ([[cellDic valueForKey:MSG_TYPE] isEqualToString:@"vsms"])
        {
            // Delete Alert Action
            if (buttonIndex != [alertView cancelButtonIndex])
            {
                if (isWithDrawSentVoiceMail) {
                    KLog(@"Withdraw SentVoiceMail");
                    [appDelegate.engObj withdrawMSG:cellDic];
                }
                else if (isDeleteVoiceMail) {
                    KLog(@"Delete VoiceMail");
                    [appDelegate.engObj deleteMSG:cellDic];
                }
            }
        }
        else if ([[cellDic valueForKey:MSG_TYPE] isEqualToString:@"mc"])
        {
            // Missed Call Delete Alert Action
            if (buttonIndex != [alertView cancelButtonIndex])
            {
                if (isWithDrawSentMissedCall) {
                    KLog(@"Withdraw SentMissedCall");
                    [appDelegate.engObj withdrawMSG:cellDic];
                }
                else if (isDeleteMissedCall) {
                    KLog(@"Delete MissedCall");
                    [appDelegate.engObj deleteMSG:cellDic];
                }
            }
        }
        else if([[cellDic valueForKey:MSG_TYPE] isEqualToString:VOIP_TYPE]) {
            if (buttonIndex != [alertView cancelButtonIndex]) {
                KLog(@"Delete reachMe call");
                [appDelegate.engObj deleteMSG:cellDic];
            }
        }
    }
    else {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    
    [self refreshCell];
    _isAlertShown = NO;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _isAlertShown = NO;
}

-(void)refreshCell
{
    if(nil != currentIndexPath) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

-(NSMutableDictionary*)prepareRequestForBlockUnblockUser:(NSString*)operation ForTheUsers:(NSDictionary*)list
{
    NSMutableArray* contactList = [[NSMutableArray alloc]init];
    NSMutableDictionary* contactDic = [[NSMutableDictionary alloc]init];
    NSMutableDictionary* req = [[NSMutableDictionary alloc]init];
    NSString* remoteUserType = [list valueForKey:REMOTE_USER_TYPE];
    if( [remoteUserType isEqualToString:PHONE_MODE] ) {
        [contactDic setValue:[list valueForKey:FROM_USER_ID] forKey:API_CONTACT_ID];
        [contactDic setValue:remoteUserType forKey:API_CONTACT_TYPE];
        [req setValue:@"block" forKey:BLOCKED_FLAG];
    }
    else if( [remoteUserType isEqualToString:CELEBRITY_TYPE]) {
        [contactDic setValue:[list valueForKey:FROM_USER_ID] forKey:API_CONTACT_ID];
        [contactDic setValue:@"iv" forKey:API_CONTACT_TYPE];
        [req setValue:@"block" forKey:BLOCKED_FLAG];
    }
    else if([remoteUserType isEqualToString:IV_TYPE]) {
        [contactDic setValue:[list valueForKey:REMOTE_USER_IV_ID] forKey:API_CONTACT_ID];
         NSString *Id=[[NSString alloc] initWithString:[list valueForKey:FROM_USER_ID]];
        if([Id isEqualToString:@"912222222222"]||[Id isEqualToString:@"911111111111"])
            [req setValue:@"non_block" forKey:BLOCKED_FLAG];
        else
            [req setValue:@"block" forKey:BLOCKED_FLAG];
       // [contactDic setValue:[list valueForKey:FROM_USER_ID] forKey:API_CONTACT_ID];
        [contactDic setValue:remoteUserType forKey:API_CONTACT_TYPE];
    }
    else {
        //TODO: handle the error
        EnLogd(@"ERROR preparing req dic for %@",operation);
        return nil;
    }
    [contactDic setValue:operation forKey:API_OPERATION];
    [contactDic setValue:[list valueForKey:REMOTE_USER_NAME] forKey:API_CONTACT_NUMBER];
    [contactList addObject:contactDic];
    [req setValue:contactList forKey:API_CONTACTS];
    return req;
}

-(void)blockUnblockUser:(NSMutableDictionary*)userList
{
    if( [Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    BlockUnblockUserAPI* api = [[BlockUnblockUserAPI alloc]initWithRequest:userList];
    [api callNetworkRequest:userList withSuccess:^(BlockUnblockUserAPI *req, NSMutableDictionary *responseObject) {
        if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
            EnLogd(@"Error blocking the user userlist %@ and api request %@",userList,api.request);
        } else {
            NSString* fromUserID = [userList valueForKey:REMOTE_USER_IV_ID];
            NSMutableArray* contacts = [userList valueForKey:API_CONTACTS];
            NSString* operation = nil;
            if(contacts && [contacts count]) {
                operation = [contacts[0] valueForKey:API_OPERATION];
            }
            if(operation && [operation isEqualToString:@"b"]) {
                [cc.blockedUserIDList addObject:fromUserID];
                [[ConfigurationReader sharedConfgReaderObj]setObject:cc.blockedUserIDList forTheKey:@"BLOCKED_TILES"];
            }
            else if(operation && [operation isEqualToString:@"u"]) {
               [cc.blockedUserIDList removeObject:fromUserID];
                [[ConfigurationReader sharedConfgReaderObj]setObject:cc.blockedUserIDList forTheKey:@"BLOCKED_TILES"];
            }
            //- to recalculate the new message count from blocked users
            NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
            [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
            [eventObj setValue:[NSNumber numberWithInt:GET_ACTIVE_CONVERSATION_LIST] forKey:EVENT_TYPE];
            [appDelegate.engObj addEvent:eventObj];
            [appDelegate prepareBlockedContacts];
            //
        }
    } failure:^(BlockUnblockUserAPI *req, NSError *error) {
        EnLogd(@"Error blocking the user: %@, Error",userList,[error description]);
        NSInteger errorCode = error.code;
        NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
        if([errorMsg length])
            [ScreenUtility showAlertMessage: errorMsg];
    }];
}

-(void)unBlockUserFromContactPage:(NSMutableDictionary*)userList
{
    if( [Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    BlockUnblockUserAPI* api = [[BlockUnblockUserAPI alloc]initWithRequest:userList];
    [api callNetworkRequest:userList withSuccess:^(BlockUnblockUserAPI *req, NSMutableDictionary *responseObject) {
        if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
            EnLogd(@"Error blocking the user userlist %@ and api request %@",userList,api.request);
        } else {
            NSString* fromUserID = [userList valueForKey:REMOTE_USER_IV_ID];
            NSMutableArray* contacts = [userList valueForKey:API_CONTACTS];
            NSString* operation = nil;
            if(contacts && [contacts count]) {
                operation = [contacts[0] valueForKey:API_OPERATION];
            }
            if(operation && [operation isEqualToString:@"b"]) {
                [cc.blockedUserIDList addObject:fromUserID];
                [[ConfigurationReader sharedConfgReaderObj]setObject:cc.blockedUserIDList forTheKey:@"BLOCKED_TILES"];
            }
            else if(operation && [operation isEqualToString:@"u"]) {
                [cc.blockedUserIDList removeObject:fromUserID];
                [[ConfigurationReader sharedConfgReaderObj]setObject:cc.blockedUserIDList forTheKey:@"BLOCKED_TILES"];
            }
            //- to recalculate the new message count from blocked users
            NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
            [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
            [eventObj setValue:[NSNumber numberWithInt:GET_ACTIVE_CONVERSATION_LIST] forKey:EVENT_TYPE];
            [appDelegate.engObj addEvent:eventObj];
            [ScreenUtility showAlert:@"User Unblocked Successful"];
            [appDelegate prepareBlockedContacts];
            //
        }
    } failure:^(BlockUnblockUserAPI *req, NSError *error) {
        EnLogd(@"Error blocking the user: %@, Error",userList,[error description]);
        NSInteger errorCode = error.code;
        NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
        if([errorMsg length])
            [ScreenUtility showAlertMessage: errorMsg];
    }];
}

-(int)getChatType
{
    return _displayUserType;
}

/*
-(NSMutableArray*)filterChatGridWithElement:(NSMutableArray*)conversationList forDisplayType:(int)displayType
{
    EnLogd(@"Current Display type: %ld",displayType);
    NSMutableArray* filteredArray = [[NSMutableArray alloc]init];
    if(displayType == ChatTypeVoiceMail)
    {
        for(NSMutableDictionary* msgDic in _voicemailList) {
            NSString* fromUserID = [msgDic valueForKey:REMOTE_USER_IV_ID];
            NSString* msgType = [msgDic valueForKey:MSG_TYPE];
            NSString* msgContentType = [msgDic valueForKey:MSG_CONTENT_TYPE];
            if(![msgType isEqualToString:VSMS_TYPE] ||
               ![msgContentType isEqualToString:AUDIO_TYPE])
                continue;
            
            if(!fromUserID || ![fromUserID length] || [fromUserID isEqualToString:@"0"])
                fromUserID = [msgDic valueForKey:FROM_USER_ID];
            
            //- Don't add hidden and blocked users into the filteredArray
            if([_hiddenUserIDList containsObject:fromUserID] || [_blockedUserIDList containsObject:fromUserID])
                continue;
            [filteredArray addObject:msgDic];
        }
    }
    else if(displayType == ChatTypeCalls) {
        
        for(NSMutableDictionary* msgDic in _missedCallList) {
            NSString* fromUserID = [msgDic valueForKey:REMOTE_USER_IV_ID];
            NSString* msgType = [msgDic valueForKey:MSG_TYPE];
            if(!([msgType isEqualToString:MISSCALL] || [msgType isEqualToString:VOIP_TYPE]))
                continue;
            
            if(!fromUserID || ![fromUserID length] || [fromUserID isEqualToString:@"0"])
                fromUserID = [msgDic valueForKey:FROM_USER_ID];
            
            //- Don't add hidden and blocked users into the filteredArray
            if([_hiddenUserIDList containsObject:fromUserID] || [_blockedUserIDList containsObject:fromUserID])
                continue;
            [filteredArray addObject:msgDic];
        }
    }
    
    else if(displayType == ChatTypeAll) {
        for(NSMutableDictionary* msgDic in conversationList) {
            NSString* fromUserID = [msgDic valueForKey:REMOTE_USER_IV_ID];
            if(!fromUserID || ![fromUserID length] || [fromUserID isEqualToString:@"0"])
                fromUserID = [msgDic valueForKey:FROM_USER_ID];
            
            //- Don't add hidden and blocked users into the filteredArray
            if([_hiddenUserIDList containsObject:fromUserID] || [_blockedUserIDList containsObject:fromUserID])
                continue;
            [filteredArray addObject:msgDic];
        }
    }
    
    else if(displayType == ChatTypeBlocked) {
        for (NSMutableDictionary* msgDic in conversationList) {
            NSString* fromUserID = [msgDic valueForKey:REMOTE_USER_IV_ID];
            if(!fromUserID || ![fromUserID length] || [fromUserID isEqualToString:@"0"])
                fromUserID = [msgDic valueForKey:FROM_USER_ID];
            
            if([_blockedUserIDList containsObject:fromUserID]) {
                [filteredArray addObject:msgDic];
            }
        }
    }
    else {
        EnLogd(@"Current Display type: Unknow -- SHOULD NOT HAPPEN");
    }
    
    return filteredArray;
}*/

#pragma mark -- Remove overlay view to avoid crash
-(void)removeOverlayViewsIfAnyOnPushNotification
{
    [super removeOverlayViewsIfAnyOnPushNotification];

    if([self.audioObj isPlay]) {
        return;
    }
}

#pragma mark -- Location Permission
-(void)checkForLocationPermission
{
    BOOL  flag = [CLLocationManager locationServicesEnabled];
    if(flag)
    {
        EnLogd(@"Location Services Enabled");
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
        {
            [self getLocationPermission];
            return;
        }
        else
        {
            if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
            {
                UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOCATION_PERMISSION_DENIED", nil) message:NSLocalizedString(@"LOCATION_PERMISSION_MSG",nil) delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                                       otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
        
    }
    else
    {
        UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"LOCATION_SERVICE_OFF", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alert show];
        return;
    }
}

-(void) getLocationPermission
{
    /*---- For get location and address of the user -----*/
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [self getCurrentLocation];
}

-(void)getCurrentLocation
{
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    KLog(@"LS: Error: %@",[error localizedDescription]);
    
    EnLogd(@"Error: %@",[error localizedDescription]);
    NSString* errorString = @"";
    BOOL locationSettingFlag = NO;
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            errorString = @"Access to Location Services denied by user";
            //Do something...
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = @"Location data unavailable";
            locationSettingFlag = YES;
            //Do something else...
            break;
        default:
            errorString = @"An unknown error has occurred";
            break;
    }

    [self stopUpdatingLocation];
    [appDelegate.confgReader setUserLocationAccess:locationSettingFlag];
    
    //Update the Location status in the Userdefaults.
    NSString *flag = [NSString stringWithFormat:@"%d", locationSettingFlag];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setValue:flag forKey:kShareLocationSettingsValue];
    [standardDefaults synchronize];
    
    [[Setting sharedSetting]updateUserSettingType:SettingTypeDisplayLocation andValue:locationSettingFlag];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    KLog(@"LS: didUpdateLocations: %@",locations);
    
    [self stopUpdatingLocation];
    [appDelegate.confgReader setUserLocationAccess:YES];
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setValue:@YES forKey:kShareLocationSettingsValue];
    [standardDefaults synchronize];
    
    [[Setting sharedSetting]updateUserSettingType:SettingTypeDisplayLocation andValue:YES];
}

-(void)stopUpdatingLocation
{
    [locationManager stopUpdatingLocation];
}


#pragma mark - Search Bar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

    _fetchedResultsController = Nil;
    // if the user has typed in nothing into the searchbar or the user just typed a "+" into the
    // search bar (signifying the first character of a phone number, the user isn't searching.
    // Otherwise, find what he is searching for.

    if (searchText.length == 0 || ((searchText.length == 1) && [searchText hasPrefix:@"+"])) {
        isSearching = NO;
        //DEC 9, 15 TODO check any performance or usability issue
        [self stopAudioPlayback];
        KLog((@"Reset the play status of all cells"));
        for(int i = 0; i < [cc.allMsgsList count]; i++) {
            [cc.allMsgsList[i] setValue:[NSNumber numberWithDouble:0] forKey:MSG_PLAY_DURATION];
            [cc.allMsgsList[i] setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAYBACK_STATUS];
        }
        //
        _searchString = @"";
        [self setFetchRequestForSearch:Nil];
        
        //KLog(@"searchString - textDidChange: searchText=%@, searchString=%@",searchText,_searchString);
        
        _currentFilteredList = [cc filterChatsForDisplayType:_displayUserType];
        if(_searchString.length<=0) {
            [self performSelectorOnMainThread:@selector(refreshTableOnMainThread)
                                   withObject:nil waitUntilDone:NO];
        }
        
    } else {
        _currentFilteredList = [cc filterChatsForDisplayType:_displayUserType];
        isSearching = YES;
        _searchString = searchText;
        
        [self setFetchRequestForSearch:_searchString];
        
        [self stopAudioPlayback];
        
        // get rid of the "+" in front of the search string, in case there is one.
        NSString *textWithoutPlus = [searchText hasPrefix:@"+"] ? [searchText substringFromIndex:1] : [NSString stringWithString:searchText];
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(REMOTE_USER_NAME BEGINSWITH[cd] %@) OR (FROM_USER_ID BEGINSWITH[cd] %@) OR (REMOTE_USER_NAME CONTAINS[c] %@) OR (FROM_USER_ID CONTAINS[c] %@)", textWithoutPlus, textWithoutPlus, textWithoutPlus, textWithoutPlus];
        _currentFilteredList = [NSMutableArray arrayWithArray:[_currentFilteredList filteredArrayUsingPredicate:resultPredicate]];
    }


    if (_currentFilteredList.count > 0) {
        if (self.msgLabel.alpha == 1) {
            [UIView animateWithDuration:.25 animations:^{
                self.msgLabel.alpha = 0;
                self.msgLabel.backgroundColor = [UIColor clearColor];
            }];
        }

        [self.tableView reloadData];
        [searchBar becomeFirstResponder];
    } else {
        if (self.msgLabel.alpha == 0) {
            [UIView animateWithDuration:.25 animations:^{
                self.msgLabel.alpha = 1;
            }];
        }
        if([[self currentActiveResultController].fetchedObjects count]<=0)
            [self unloadData];
    }
    
    if(isSearching) {
        if(!self.sectionHeaderViewChats) {
            self.sectionHeaderViewChats = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
            self.sectionHeaderViewChats.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
            UILabel *labelChat = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.tableView.frame.size.width, 44)];
            labelChat.tag = SECTION_CHAT_TAG;
            labelChat.font = [UIFont boldSystemFontOfSize:20.0f];
            labelChat.textColor = [UIColor darkTextColor];
            
            NSString *stringChat = @"Chats";
    
            [labelChat setText:stringChat];
            [self.sectionHeaderViewChats addSubview:labelChat];
        }
        
        if(!self.sectionHeaderViewOthers) {
            self.sectionHeaderViewOthers = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
            self.sectionHeaderViewOthers.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.tableView.frame.size.width, 44)];
            label.tag = SECTION_OTHER_TAG;
            label.font = [UIFont boldSystemFontOfSize:20.0f];
            label.textColor = [UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1.0];
            NSString *string = @"Other contacts";
            [label setText:string];
            label.textColor = [UIColor darkTextColor];
            [self.sectionHeaderViewOthers addSubview:label];
        }
    }
    else {
        [self setFetchRequestForSearch:Nil];
        self.sectionHeaderViewChats = nil;
        self.sectionHeaderViewOthers = nil;
    }
    
    if([[self currentActiveResultController].fetchedObjects count]<=0) {
        KLog(@"CGVC:Debug");
        if(!_currentFilteredList.count) {
            self.sectionHeaderViewChats = nil;
            self.sectionHeaderViewOthers = nil;
            [self unloadData];
        } else {
            self.sectionHeaderViewOthers = nil;
        }
        
    } else {
        self.msgLabel.alpha = 0;
    }
    
    [self.tableView reloadData];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    KLog(@"searchBarTextDidEndEditing");
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    KLog(@"searchBarTextBeginEditing");
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar
{
    KLog(@"searchBarShouldBeginEditing");
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar*)searchBar
{
    KLog(@"searchBarShouldEndEditing");
    if(!isSearching && ![_searchString length]) {
        self.sectionHeaderViewChats = nil;
        self.sectionHeaderViewOthers = nil;
    }
    return YES;
}

-(void)refreshTableOnMainThread {
    
    [self loadData];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string
{
    NSUInteger newLength = [_searchString length] + [string length] - range.length;
    //KLog(@"newLength = %d",newLength);
    if(newLength <= 0) {
        _searchString = @"";
        [self setFetchRequestForSearch:Nil];
        [self loadData];
    }
    
   // KLog(@"searchString - shouldChangeTextInRange %@",_searchString);

    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self stopAudioPlayback];
    if([_searchString length] || [searchBar.text length]) {
        KLog((@"Reset the play status of all cells"));
        for(int i = 0; i < [cc.allMsgsList count]; i++) {
            [cc.allMsgsList[i] setValue:[NSNumber numberWithDouble:0] forKey:MSG_PLAY_DURATION];
            [cc.allMsgsList[i] setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAYBACK_STATUS];
        }
        [self.tableView reloadData];
    }
    [searchBar setText:@""];
    _searchString = @"";
    [searchBar.delegate searchBar:searchBar textDidChange:@""];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self loadData];
    [self updateUIWithShowOrHideStatusOfEnableVoiceMailButton];
    
    //KLog(@"searchString - searchBarCancelButtonClicked %@",_searchString);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(int)unReadMessageCount:(NSArray*)msgList {
    int unreadMsgCount = 0;
    for(NSDictionary* dic in msgList) {
        unreadMsgCount += [[dic valueForKey:UNREAD_MSG_COUNT]intValue];
    }
    return unreadMsgCount;
}

- (void)applicationDidEnterBackGround:(NSNotification *)notification
{
#ifdef REACHME_APP
    if(!linphone_core_get_calls(LC) && [self.audioObj isPlay])
#endif
        [self.audioObj stopPlayback];
}

#pragma mark new functions
-(void)voiceMsgAction:(NSInteger)cellIndex
{
    
    long tag = cellIndex;
    NSString* msgType = nil;
    
    if(_buttonTag == tag)
    {
        if([self.audioObj isPlay]) {
            [self stopAudioPlayback];
            if(_needToUpdateTable) {
                [self loadData];
                _needToUpdateTable = 0;
            }
            _buttonTag = -1;
            return;
        }
    }
    else if (_buttonTag > -1 ) {
        [self stopAudioPlayback];
        if(_needToUpdateTable) {
            [self loadData];
            _needToUpdateTable = 0;
        }
    }
    
    _buttonTag = tag;
    _indexForAudioPlayed = tag;
    
    EnLogd(@"clicked on voice strip tag :  %ld",tag);
    if(tag >= _currentFilteredList.count) {
        EnLogd(@"Invalid row index. FIXME.");
        return;
    }
    
    self.voiceDic = [_currentFilteredList objectAtIndex:tag];
    KLog(@"voiceDic = %@", self.voiceDic);
    //TODO: why DIC is nil
    if(!self.voiceDic)
        self.voiceDic = [_currentFilteredList objectAtIndex:tag];
    //
    
    NSString *localPath = [self.voiceDic valueForKey:MSG_LOCAL_PATH];
    
    if(localPath == nil || [localPath isEqualToString:@""])
    {
        EnLogd(@"local path does not exist : ");
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
                [self.voiceDic setValue:[NSNumber numberWithDouble:0] forKey:MSG_PLAY_DURATION];
                msgPalyDuration = 0;
            }
            
            int speakerMode = CALLER_MODE != [appDelegate.confgReader getVolumeMode];
            if( [Audio isHeadsetPluggedIn] )
                speakerMode = false;
            
            //KLog(@" start the playback");
            int msgReadStatus = [[self.voiceDic valueForKey:MSG_READ_CNT]intValue];
            if((MessageReadStatusSeen == msgReadStatus || MessageReadStatusUnread == msgReadStatus) &&
               [[self.voiceDic valueForKey:MSG_FLOW]isEqualToString:MSG_FLOW_R])
            {
                NSNumber* msgId = [self.voiceDic valueForKey:MSG_ID];
                NSMutableArray* msgIdArray = [NSMutableArray arrayWithObjects:msgId, nil];
                
                NSMutableDictionary *readDic = [[NSMutableDictionary alloc]init];
                [readDic setValue:[self.voiceDic valueForKey:MSG_TYPE] forKey:MSG_TYPE];
                [readDic setValue:msgIdArray forKey:API_MSG_IDS];
                
                [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeReadMessage withData:readDic];
            }
            
            if([self.audioObj startPlayback:latestFilePath playTime:msgPalyDuration playMode:speakerMode])
            {
                IVChatTableViewCell *cell = (IVChatTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_indexForAudioPlayed inSection:0]];
                
                if(cell) {
                    [cell.dic setValue:[NSNumber numberWithInt:1] forKey:MSG_PLAYBACK_STATUS];
                    [cell setStatusIcon:API_MSG_PALYING isAvs:0 readCount:0 msgType:msgType];
                    [cell swapPlayPause:cell.dic];
                }
                
                if(drawStripTimer != nil)
                {
                    [drawStripTimer invalidate];
                }
                
                NSRunLoop *runloop = [NSRunLoop currentRunLoop];
                drawStripTimer = [NSTimer scheduledTimerWithTimeInterval:audioPlayUpdateInterval
                                                                  target:self
                                                                selector:@selector(playVoiceMsg:)
                                                                userInfo:self.voiceDic repeats:YES];
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

-(void)downloadVoiceMsg:(NSMutableDictionary *)dic
{
    if(dic != nil)
    {
        if(drawStripTimer != nil)
        {
            [drawStripTimer invalidate];
            [self.audioObj pausePlayBack];
        }
        
        if([Common isNetworkAvailable] == NETWORK_AVAILABLE)
        {
            IVChatTableViewCell *cell = (IVChatTableViewCell *)[self.tableView cellForRowAtIndexPath:
                                                                    [NSIndexPath indexPathForRow:_indexForAudioPlayed
                                                                                       inSection:0]];
            
            NSString* msgType = [dic valueForKey:MSG_STATE];
            [dic setValue:API_DOWNLOAD_INPROGRESS forKey:MSG_STATE];
            [self.voiceDic setValue:API_DOWNLOAD_INPROGRESS forKey:MSG_STATE];
            if(cell)
                [cell setStatusIcon:API_DOWNLOAD_INPROGRESS isAvs:0 readCount:0 msgType:msgType];
            
            NSMutableDictionary *newDic = [[NSMutableDictionary alloc]initWithDictionary:dic];
            [appDelegate.engObj downloadVoiceMsg:newDic];
        }
        else
        {
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        }
    }
}

-(void)playVoiceMsg:(NSTimer *)timerDic
{
    NSMutableDictionary *msgDic = timerDic.userInfo;
    int totalDuration = [[msgDic valueForKey:DURATION] intValue];
    double playedDuration = [[msgDic valueForKey:MSG_PLAY_DURATION] doubleValue];
    NSString* msgType = [msgDic valueForKey:MSG_TYPE];
    
    playedDuration += audioPlayUpdateInterval;
    IVChatTableViewCell *cell = (IVChatTableViewCell *)[self.tableView cellForRowAtIndexPath:
                                                            [NSIndexPath indexPathForRow:_indexForAudioPlayed
                                                                               inSection:0]];
    if(playedDuration > totalDuration)
    {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        [drawStripTimer invalidate];
        //Jan 31, 2017_buttonTag = -1;
        int isAvsMsg = 0;
        if([[msgDic valueForKey:MSG_SUB_TYPE] isEqualToString:AVS_TYPE])
        {
            isAvsMsg = 1;
        }
        
        if(cell) {
            [msgDic setValue:[NSNumber numberWithDouble:0.0] forKey:MSG_PLAY_DURATION];
            
            if([cell respondsToSelector:@selector(setStatusIcon:isAvs:readCount:msgType:)])
                [cell setStatusIcon:API_DELIVERED isAvs:isAvsMsg readCount:0 msgType:msgType];
        
            if ([cell respondsToSelector:@selector(stopPlaying:)])
                [cell  stopPlaying:nil];
            
            if([cell respondsToSelector:@selector(updateVoiceView:)])
                [cell updateVoiceView:msgDic];
        }
        [self stopAudioPlayback];
        [self.tableView reloadData];
    }
    else
    {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        [msgDic setValue:[NSNumber numberWithDouble:playedDuration] forKey:MSG_PLAY_DURATION];
        
        [msgDic setValue:[NSNumber numberWithInt:1] forKey:MSG_PLAYBACK_STATUS];
        [cell.dic setValue:[NSNumber numberWithInt:1] forKey:MSG_PLAYBACK_STATUS];
        [cell.dic setValue:[NSNumber numberWithDouble:playedDuration] forKey:MSG_PLAY_DURATION];
        
        if(cell && [cell respondsToSelector:@selector(updateVoiceView:)]) {
            [cell updateVoiceView:msgDic];
        }
    }
}


-(int)handleDownloadVoiceMsg:(NSMutableDictionary*)respDic
{
    IVChatTableViewCell *cell = [self.tableView cellForRowAtIndexPath:
                                   [NSIndexPath indexPathForRow:_indexForAudioPlayed
                                                      inSection:0]];
    NSMutableDictionary* theDic = nil;
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
    
    NSString* contentType = [cell.dic valueForKey:MSG_CONTENT_TYPE];
    if([contentType isEqualToString:TEXT_TYPE]) {
        EnLogd(@"Voice msg has been withdrawn. DONT play.");
        return -6;
    }
    
    //KLog(@"voiceDic = %@",self.voiceDic);
    NSString* curChatUserId = [self.voiceDic valueForKey:FROM_USER_ID];
    NSString* userIdFromRespDic = [respDic valueForKey:FROM_USER_ID];
    
    if(curChatUserId && (userIdFromRespDic && [userIdFromRespDic length]) &&
       ![curChatUserId isEqualToString:userIdFromRespDic]) {
        EnLogd(@"Not cur chat user. Do nothing, just return. curChatUserId = %@, userIdFromRespDic=%@",
               curChatUserId,
               userIdFromRespDic);
        return -3;
    }

    NSString *curMsgGuid = [self.voiceDic valueForKey:MSG_GUID];
    NSString* respMsgGuid = [respDic valueForKey:MSG_GUID];
    NSString* respMsgState  = [respDic valueForKey:MSG_STATE];
    NSString* respMsgLocalPath = [respDic valueForKey:MSG_LOCAL_PATH];
    int retVal = 0;
    BOOL isMsgMatched = FALSE;
    
    //- NOTE: Celebriry message does not have MSG_GUID
    if(respMsgGuid) {
        //- update the cur cell dic
        isMsgMatched = [curMsgGuid isEqualToString:respMsgGuid];
        if(isMsgMatched) {
            [self.voiceDic setValue:respMsgState forKey:MSG_STATE];
            [self.voiceDic setValue:respMsgLocalPath forKey:MSG_LOCAL_PATH];
            [self.voiceDic setValue:API_DOWNLOADED forKey:MSG_STATE];
        }
        
        long maxConv = [_currentFilteredList count];
        for(long i=0; i<maxConv; i++) {
            theDic = _currentFilteredList[i];
            if([[theDic valueForKey:MSG_GUID] isEqualToString:respMsgGuid]) {
                [theDic setValue:respMsgState forKey:MSG_STATE];
                [theDic setValue:respMsgLocalPath forKey:MSG_LOCAL_PATH];
                [theDic setValue:API_DOWNLOADED forKey:MSG_STATE];
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
        
        long maxConv = [_currentFilteredList count];
        for(long i=0; i<maxConv; i++) {
            theDic = _currentFilteredList[i];
            if([[theDic valueForKey:MSG_ID] isEqualToNumber:respMsgID]) {
                [theDic setValue:respMsgState forKey:MSG_STATE];
                [theDic setValue:respMsgLocalPath forKey:MSG_LOCAL_PATH];
                [theDic setValue:API_DOWNLOADED forKey:MSG_STATE];
                retVal = 2;
                break;
            }
        }
    }
    
    if(0==retVal) {
        EnLogd(@"msg GUID/ID does not match");
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
        
        [self.voiceDic setValue:[NSNumber numberWithDouble:0] forKey:MSG_PLAY_DURATION];
        int playDuration = 0;
        int speakerMode = (CALLER_MODE == [appDelegate.confgReader getVolumeMode])?false:true;
        if( [Audio isHeadsetPluggedIn] )
            speakerMode = false;
        
        EnLogd(@"Call to startPlayback");
        
        int msgReadStatus = [[self.voiceDic valueForKey:MSG_READ_CNT]intValue];
        
        if((MessageReadStatusUnread == msgReadStatus || MessageReadStatusSeen == msgReadStatus) &&
           [[self.voiceDic valueForKey:MSG_FLOW]isEqualToString:MSG_FLOW_R])
        {
            NSArray *msgId = [[NSArray alloc]initWithObjects:[self.voiceDic valueForKey:MSG_ID], nil];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:[self.voiceDic valueForKey:MSG_TYPE] forKey:MSG_TYPE];
            [dic setValue:msgId forKey:API_MSG_IDS];
            
            [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeReadMessage withData:dic];
        }
        
        if([self.audioObj startPlayback:respMsgLocalPath playTime:playDuration playMode:speakerMode]) //TODO crash nil string passed
        {
            if(cell) {
                [cell.dic setValue:[NSNumber numberWithInt:1] forKey:MSG_PLAYBACK_STATUS];
                [self.voiceDic setValue:[NSNumber numberWithInt:1] forKey:MSG_PLAYBACK_STATUS];
                [theDic setValue:[NSNumber numberWithInt:1] forKey:MSG_PLAYBACK_STATUS];
                [cell setStatusIcon:API_MSG_PALYING isAvs:0 readCount:0 msgType:nil];
                [cell swapPlayPause:cell.dic];
            }
            
            if(drawStripTimer != nil)
                [drawStripTimer invalidate];
            
            drawStripTimer = [NSTimer scheduledTimerWithTimeInterval:audioPlayUpdateInterval target:self
                                                            selector:@selector(playVoiceMsg:)
                                                            userInfo:self.voiceDic repeats:YES];
        }
    }
    
    return retVal;
}

-(void)stopAudioPlayback
{
    if(drawStripTimer != nil) {
        [drawStripTimer invalidate];
    }
    
    if(_buttonTag < 0) {
        KLog(@"Invalid _buttonTag = %ld. Return.",_buttonTag);
        if([self.audioObj isPlay])
            [self.audioObj stopPlayback];
        return;
    }
    
    if(_buttonTag >= [_currentFilteredList count]) {
        if([self.audioObj isPlay])
            [self.audioObj stopPlayback];
        
        //KLog(@"No of objects in _currentFilteredList:%d",[_currentFilteredList count]);
        //KLog(@"Object at the index: %ld",_buttonTag);
        KLog(@"Invalid object index. Return");
        return;
    }
    
    if(![self.audioObj isPlay]) {
        KLog(@"Audio is not in play-state");
    }
    
    IVChatTableViewCell *cell = (IVChatTableViewCell *)[self.tableView cellForRowAtIndexPath:
                                                        [NSIndexPath indexPathForRow:_buttonTag
                                                                           inSection:0]];
    
    NSDictionary* dic = [_currentFilteredList objectAtIndex:_buttonTag];
    if(dic) {
        if([self.audioObj isPlay]) {
            [self.audioObj pausePlayBack];
        }
        
        if(cell) {
            
            int totalDuration = [[cell.dic valueForKey:DURATION]intValue];
            double playedDuration = roundf([[cell.dic valueForKey:MSG_PLAY_DURATION] doubleValue]);
            
            if (playedDuration == totalDuration) {
                [cell.dic setValue:[NSNumber numberWithDouble:0.0] forKey:MSG_PLAY_DURATION];
                [self.audioObj stopPlayback];
            }
            
            //KLog(@"row = %lu,stopped playback",(unsigned long)cell.cellIndex);
            if ([cell respondsToSelector:@selector(stopPlaying:)])
                [cell stopPlaying:nil];
        } else {
            //KLog(@"row = %lu is not visble. so empty cell.....!",(unsigned long)cell.cellIndex);
            [dic setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAYBACK_STATUS];
             [dic setValue:[NSNumber numberWithDouble:0.0] forKey:MSG_PLAY_DURATION];
        }
    }
    
    [self loadData];
}

-(void)markReadMessagesFromThisList:(NSArray *)list
{
    [cc markReadMessagesFromThisList:list];
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
            EnLogi(@"routeChangeReason : AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            KLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNewDeviceAvailable");
        }
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // a headset was removed
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
                break;
    }
}

-(void) audioDidCompletePlayingData
{
    KLog(@"NO IMPL");
}

#pragma mark Other contacts and CoreData related

-(NSFetchedResultsController*)fetchedResultsController
{
    if(_fetchedResultsController != Nil && [[_fetchedResultsController fetchedObjects]count])
        return _fetchedResultsController;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:
                                 self.fetchRequest managedObjectContext:_managedObjectContext
                                                                     sectionNameKeyPath:Nil cacheName:Nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    
    if (![_fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        KLog(@"Unresolved error %@, %@", error, [error userInfo]);
        EnLogd(@"FIXME: Error: %@, Do a graceful exit",error);
        //JUNE, 2017 abort();
        return nil;
    }
    
    return _fetchedResultsController;
}

-(void)setFetchRequestForSearch:(NSString*)searchString
{
    _fetchRequest = [[NSFetchRequest alloc] init];
    _fetchRequest.fetchBatchSize = 20;
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSMutableArray* phoneNumList = [[NSMutableArray alloc]init];
    NSString* fromUserID = nil;
    for(NSMutableDictionary* dic in _currentFilteredList)
    {
        fromUserID = [dic valueForKey:FROM_USER_ID];
        if(fromUserID && fromUserID.length)
            [phoneNumList addObject:fromUserID];
    }
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
    [_fetchRequest setEntity:entityDescription];
    
    NSSortDescriptor *sortName = [[NSSortDescriptor alloc]initWithKey:@"contactIdParentRelation.contactName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSString* contactDataType = PHONE_MODE;
    //_sectionNameKeyPath = Nil;
    if(isSearching && searchString != Nil && [searchString length] > 0)
    {
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"(contactDataType = %@ AND contactIdParentRelation.contactType != %@ AND ((contactIdParentRelation.contactName CONTAINS[cd] %@) OR (contactIdParentRelation.lastName CONTAINS[cd] %@) OR (contactDataValue CONTAINS[cd] %@)) AND !(ANY contactDataValue IN %@) )",contactDataType,[NSNumber numberWithInteger:ContactTypeCelebrity],searchString,searchString,searchString,phoneNumList];
        [_fetchRequest setPredicate:condition];
    }
    else
    {
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"(((contactIdParentRelation.isIV = 1 AND contactIdParentRelation.contactType != %d) OR (contactIdParentRelation.isIV = 0 AND contactIdParentRelation.contactType != %@)) AND (contactDataType == %@ OR contactIdParentRelation.groupId!=NULL))",ContactTypeCelebrity,[NSNumber numberWithInteger:ContactTypeMsgSyncContact],PHONE_MODE];
        [_fetchRequest setPredicate:condition];
    }
    
    [_fetchRequest setSortDescriptors:@[sortName]];
}

-(BOOL)isNumber:(NSString*)text
{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber* number = [numberFormatter numberFromString:text];
    
    if (number != nil)
        return TRUE;
    
    return FALSE;
}

-(NSFetchedResultsController*)currentActiveResultController
{
    if(isSearching)
        return self.fetchedResultsController;
    
    return nil;
}

-(void)moveToConversationScreen:(ContactDetailData*)contactDetail
{
    if(!contactDetail) {
        KLog(@"***ERR: contactDetial is nil");
        //TODO display error to the user
        [self.tableView setUserInteractionEnabled:YES];
        return;
    }
    
    NSMutableDictionary *newDic = [self setUserInfoForConversation:contactDetail];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if(newDic == nil && [newDic count] == 0)
    {
        [appDelegate.tabBarController setSelectedIndex:4];
        [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[4]];
    }
    else
    {
        [appDelegate.dataMgt setCurrentChatUser:newDic];
        BaseUI* uiObj = [[InsideConversationScreen alloc] initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
        [appDelegate.getNavController pushViewController:uiObj animated:YES];
    }
}

-(NSMutableDictionary *)setUserInfoForConversation:(ContactDetailData *)detailData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    if([self moveToNotesScreen:detailData])
    {
        dic = nil;
    }
    else
    {
        NSNumber *ivUserId = detailData.ivUserId;
        [dic setValue:detailData.contactDataType forKey:REMOTE_USER_TYPE];
        if([ivUserId longLongValue]>0)
        {
            [dic setValue:[NSString stringWithFormat:@"%@",ivUserId] forKey:REMOTE_USER_IV_ID];
            [dic setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
        }
        else
        {
            [dic setValue:@"0" forKey:REMOTE_USER_IV_ID];
        }
        
        [dic setValue:detailData.contactDataValue forKey:FROM_USER_ID];
        [dic setValue:detailData.contactIdParentRelation.contactName forKey:REMOTE_USER_NAME];
        [dic setValue:[IVFileLocator getNativeContactPicPath:detailData.contactIdParentRelation.contactPic] forKey:REMOTE_USER_PIC];
    }
    
    return dic;
}

-(void)moveToGroupChatScreen:(ContactData*)data
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    [dic setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
    [dic setValue:GROUP_TYPE forKey:CONVERSATION_TYPE];
    
    
    [dic setValue:data.groupId forKey:FROM_USER_ID];
    [dic setValue:data.contactName forKey:REMOTE_USER_NAME];
    [dic setValue:[IVFileLocator getNativeContactPicPath:data.contactPic] forKey:REMOTE_USER_PIC];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [appDelegate.dataMgt setCurrentChatUser:dic];
    
    BaseUI* uiObj = [[InsideConversationScreen alloc]
                     initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    [self.navigationController pushViewController:uiObj animated:YES];
}

-(BOOL)moveToNotesScreen:(ContactDetailData*)userDic
{
    BOOL result = NO;
    NSString *loginID = [appDelegate.confgReader getLoginId];
    long ivID = [appDelegate.confgReader getIVUserId];
    
    NSNumber *ivIDNum = userDic.ivUserId;
    if(ivIDNum !=  nil)
    {
        long value = [ivIDNum longValue];
        if(value == ivID)
        {
            result = YES;
        }
    }
    else
    {
        NSString *value = userDic.contactDataValue;
        if([value isEqualToString:loginID])
        {
            result = YES;
        }
    }
    return result;
}

-(void)manyIdView : (ContactData *)contactData
{
    //filtered detail list
    NSArray *sortedArray;
    sortedArray = [[contactData.contactIdDetailRelation allObjects] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(ContactDetailData*)a ivUserId];
        NSNumber *second = [(ContactDetailData*)b ivUserId];
        return [second compare:first];
    }];
    
    multipleContact = [NSMutableArray arrayWithArray:sortedArray];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.contactDataType != %@",EMAIL_MODE];
    [multipleContact filterUsingPredicate:predicate];
    
    actionSheetContactSelect = [[UIActionSheet alloc]initWithTitle:@"Select a phone number to send an InstaVoice to."
                                                          delegate:self
                                                 cancelButtonTitle:nil destructiveButtonTitle:Nil otherButtonTitles:nil];
    
    int buttonIndex = 0;
    for (ContactDetailData* detail in multipleContact)
    {
        if (detail.ivUserId.longValue)
        {
            NSString* str = [self formatPhoneNumberString:detail.contactDataValue];
            
            if( [detail.contactDataSubType length]) {
                [actionSheetContactSelect addButtonWithTitle:[NSString stringWithFormat:@"%@: %@",
                                                              detail.contactDataSubType, str]];
            }
            else
                [actionSheetContactSelect addButtonWithTitle:[NSString stringWithFormat:@"Instavoice: %@",detail.contactDataValue]];
        }
        else
        {
            NSString* str = [self formatPhoneNumberString:detail.contactDataValue];
            
            if( [detail.contactDataSubType length]) {
                [actionSheetContactSelect addButtonWithTitle:[NSString stringWithFormat:@"%@: %@",
                                                              detail.contactDataSubType, str]];
            }
            else {
                [actionSheetContactSelect addButtonWithTitle:[NSString stringWithFormat:@"     Phone: %@",str]];
            }
        }
        
        buttonIndex++;
    }
    
    [self.view endEditing:YES];
    actionSheetContactSelect.cancelButtonIndex = [actionSheetContactSelect addButtonWithTitle:@"Cancel"];
    [actionSheetContactSelect showInView:self.view];
}

-(NSString*)formatPhoneNumberString:(NSString *)strNumber
{
    return [cc formatPhoneNumber:strNumber];
}


#pragma mark -- UIActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex < multipleContact.count)
    {
        ContactDetailData* selectedDetail = [multipleContact objectAtIndex:buttonIndex];
        KLog(@"Selected contact %@ at index %ld",selectedDetail.contactDataValue,(long)buttonIndex);
        [self moveToConversationScreen:selectedDetail];
    }
    
    [self.tableView setUserInteractionEnabled:YES];
}

-(void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [self.tableView setUserInteractionEnabled:YES];
}

-(void)closeActionSheet
{
    [actionSheetContactSelect dismissWithClickedButtonIndex:-1 animated:NO];
    actionSheetContactSelect = nil;
}

-(void)clearSearch {
    [self performSelectorOnMainThread:@selector(clearSearchOnMainThread) withObject:nil waitUntilDone:NO];
}

-(void)clearSearchOnMainThread {
    [self.tableView setUserInteractionEnabled:YES];
    _fetchedResultsController = nil;
}


- (BOOL)redirectVoiceMailAndSettingsScreens {
    
    return [cc redirectToVoicemailOrSettingsScreen];
}

@end
