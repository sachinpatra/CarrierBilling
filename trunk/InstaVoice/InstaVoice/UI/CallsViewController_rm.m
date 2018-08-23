//
//  CallsViewController.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 26/12/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "CallsViewController.h"
#import "EventType.h"
#import "HttpConstant.h"
#import "UIType.h"
#import "SizeMacro.h"
#import "IVFileLocator.h"
#import "ContactsApi.h"
#import "BrandingScreenViewController.h"
#import "IVChatTableViewCell.h"
#import "IVImageUtility.h"
#import "IVColors.h"
#import "InsideConversationScreen.h"

#ifndef REACHME_APP
    #import "BlockedChatsViewController.h"
#endif

#import "ChatActivity.h"
#import "ContactTableViewCell.h"
#import "Common.h"

#import "IVInAppPromoViewController.h"

#import "Profile.h"
#import "IVVoiceMailListViewController.h"
#import "IVSettingsListViewController.h"
#import "IVPrimaryNumberVoiceMailViewController.h"
#import "ActivateReachMeViewController.h"
#import "CountryCallingRatesViewController.h"

#import "UIImage+animatedGIF.h"

#define CHAT_GRID_USE_CONTACT_DETAIL_DATA 1
extern NSString* kVOIPCallReceived;
extern NSString* const kLowBalance;
extern NSString* const kLowBalanceTitle;
extern NSString* const kLowBalanceWarning;

@interface CallsViewController ()<ChatGridCellDelegate, UISearchBarDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, SettingProtocol,NSFetchedResultsControllerDelegate,UIActionSheetDelegate,UITextViewDelegate>
{
    NSIndexPath* listIndex;
    NSMutableArray* multipleContact;
    UIActionSheet* actionSheetContactSelect;
    BOOL isVoiceMailEnabled, isVoipEnabled;
    NSNumberFormatter *phoneNumberFormatter;
    UIAlertController* uiAlertView;
    NSMutableArray *topFiveList, *allCountriesList;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchRequest* fetchRequest;
@property (nonatomic, strong) NSString* sectionNameKeyPath;
@property (weak, nonatomic) IBOutlet UIView *enableVoiceMailSettingsView;
@property (nonatomic, assign) BOOL voiceMailSettingsEnableButtonShowStatus;
@property (nonatomic, assign) BOOL isCarrierSelectedSupported;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfEnableVoiceMailSettingsView;
@property (nonatomic, assign) NSInteger defaultHeightOfEnableVoiceMailSettings;
@property (nonatomic, assign) NSInteger defaultWidthOfEnableVoiceMailSettingsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraintsOfVoiceMailSettingsView;

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UIButton *activateButton;
@property (weak, nonatomic) IBOutlet UIButton *buyRmNumberButton;
@property (weak, nonatomic) IBOutlet UIView *unsupportedEmptyStateView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (nonatomic, strong) NSMutableArray *supportContactList;
@property (nonatomic, strong) NSString *helpText;
@property (nonatomic, strong) NSMutableArray *helpTextArray;

@property (nonatomic, strong) SettingModel *currentSettingsModel;

@end

@implementation CallsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        _currentFilteredList = nil;
        self.uiType = CALLS_SCREEN;
        _activeConversationDictionary = Nil;
        
        isSearching = NO;
        cc = [ChatsCommon sharedChatsCommon];
        _searchString = @"";
        
        _needToUpdateTable = NO;
        _delAlertView = nil;
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Calls" image:[UIImage imageNamed:@"calls"] selectedImage:[UIImage imageNamed:@"calls_selected"]]];
        
        self.sectionHeaderViewOthers = nil;
        self.sectionHeaderViewChats = nil;
        self.managedObjectContext = [AppDelegate sharedMainQueueContext];
        self.showFromToNumber = NO;
    }
    return self;
}

-(void)viewDidLoad
{
    KLog(@"viewDidLoad");
    EnLogd(@"viewDidLoad");
    
    [cc setDelegate:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self prepareCountryListDictionary];
    });
    
    isVoiceMailEnabled = NO;
    isVoipEnabled = NO;
    
    //Hide the enable voice mail settings view
    self.defaultHeightOfEnableVoiceMailSettings  = self.heightOfEnableVoiceMailSettingsView.constant;
    self.defaultWidthOfEnableVoiceMailSettingsView = [UIScreen mainScreen].bounds.size.width;
    self.uiType = CHAT_GRID_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    [super viewDidLoad];
    
    [Setting sharedSetting].delegate = self;
    
    self.title = @"Calls";
    self.msgLabel.alpha = 0;
    
#ifdef COMPOSE_BUTTON
    UIBarButtonItem* composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeNewMessage:)];
    
    self.navigationItem.rightBarButtonItem = composeButton;
#endif
    
    UINib* nib = [UINib nibWithNibName:@"ContactTableViewCellIv" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ContactTableViewCellIv"];
    
    UINib* nib1 = [UINib nibWithNibName:@"ContactTableViewCellNonIv" bundle:nil];
    [self.tableView registerNib:nib1 forCellReuseIdentifier:@"ContactTableViewCellNonIv"];
    
    
    UINib* nibReachMeEx = [UINib nibWithNibName:@"IVChatTableViewCellReachMeCallReceivedEx" bundle:nil];
    [self.tableView registerNib:nibReachMeEx forCellReuseIdentifier:@"ConversationCellReachMeCallReceivedEx"];
    
    UINib* nibReachMeDialedEx = [UINib nibWithNibName:@"IVChatTableViewCellReachMeCallDialedEx" bundle:nil];
    [self.tableView registerNib:nibReachMeDialedEx forCellReuseIdentifier:@"ConversationCellReachMeCallDialedEx"];
    
    /*
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellRingMCReceivedEx" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellRingMCReceivedEx"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellRingMCSentEx" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellRingMCSentEx"];
    */
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellMissedCallReceivedEx" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellMissedCallReceivedEx"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellMissedCallSentEx" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellMissedCallSentEx"];
    
    UINib* nibReachMe = [UINib nibWithNibName:@"IVChatTableViewCellReachMeCallReceived" bundle:nil];
    [self.tableView registerNib:nibReachMe forCellReuseIdentifier:@"ConversationCellReachMeCallReceived"];
    
    UINib* nibReachMeDialed = [UINib nibWithNibName:@"IVChatTableViewCellReachMeCallDialed" bundle:nil];
    [self.tableView registerNib:nibReachMeDialed forCellReuseIdentifier:@"ConversationCellReachMeCallDialed"];
    
    /*
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellRingMCReceived" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellRingMCReceived"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellRingMCSent" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellRingMCSent"];
    */
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellMissedCallReceived" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellMissedCallReceived"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IVChatTableViewCellMissedCallSent" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationCellMissedCallSent"];
   
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.topViewHeight.constant = 0;
    
#ifndef REACHME_APP
    if([appDelegate.confgReader getObjectForTheKey:CONFG_LOCATION_FALG] == Nil)
        [self checkForLocationPermission];
#endif
    
    // set up the tab bar info
    [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Calls" image:[UIImage imageNamed:@"calls"] selectedImage:[UIImage imageNamed:@"calls_selected"]]];
    
    if ([self.tableView indexPathForSelectedRow] != nil) {
        // remove the table view's selected elements
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pinstripe_"]];
    _fetchedResultsController = Nil;
}

//Compose Action
#ifdef COMPOSE_BUTTON
- (IBAction)composeNewMessage:(id)sender
{
    [cc composeNewMessage];
}
#endif


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

-(void)viewWillAppear:(BOOL)animated
{
    KLog(@"viewWillAppear");
    EnLogd(@"viewWillAppear");
    
#ifdef ENABLE_LATER
    [appDelegate prepareVoipCallBlockedNumbers];
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackGround:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(voipCallReceived)
                                               name:kVOIPCallReceived
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(displayLowBalance)
                                               name:kLowBalanceWarning
                                             object:nil];
    
#ifdef REACHME_APP
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
     */
#endif
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [self.tableView setUserInteractionEnabled:YES];
    
    self.uiType = CALLS_SCREEN;
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
    
#ifndef REACHME_APP
    [cc.allMsgsList addObjectsFromArray:[appDelegate.engObj getActiveConversationList:TRUE]];
#endif
    
    [appDelegate.engObj getMissedCallList:TRUE];
    [appDelegate.engObj getVoicemailList:TRUE];
    
    _displayTypeFilteredList = [cc filterChatsForDisplayType:ChatTypeCalls];
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
        
        if(!cc.allMsgsList.count) {
            KLog(@"No Calls");
            //self.msgLabel.text = NSLocalizedString(@"NO_CALLS", nil);
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
    
#ifdef REACHME_APP
    [self syncContact];
#endif
    
    [self configureHelpAndSuggestion];
    appDelegate.tabBarController.tabBar.hidden = NO;
    [super checkMicrophonePermission:nil];
    
    if(appDelegate.tappedContact.length) {
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(),^{
            [LinphoneManager.instance makeCall:appDelegate.tappedContact FromAddress:nil UserType:nil CalleeInfo:nil];
            appDelegate.tappedContact = @"";
        });
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    KLog(@"viewWillDisappear");
    [super viewWillDisappear:animated];
    
    [cc markReadMessagesFromThisList:_currentFilteredList];
    self.navigationController.navigationBarHidden = NO;
    appDelegate.tabBarController.tabBar.hidden = NO;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)voipCallReceived {
    [self killScroll];
}

-(void)displayLowBalance {
    
    uiAlertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(kLowBalanceTitle, nil)
                                                      message:NSLocalizedString(kLowBalance, nil)
                                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction* action) {
                                                              KLog(@"Cancel");
                                                          }];
    
    UIAlertAction* addMoneyActtion = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Money", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction* action) {
                                                                //TODO call purchase credit VC
                                                                KLog(@"Add Money");
                                                            }];
    
    [uiAlertView addAction:defaultAction];
    [uiAlertView addAction:addMoneyActtion];
    [self presentViewController:uiAlertView animated:YES completion:nil];
}

- (void)killScroll {
    [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
}

-(void)dealloc {
    KLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kVOIPCallReceived
                                                  object:nil];
#ifdef REACHME_APP
    /*
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
     */
#endif
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (void)helpAction
{
    //    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.phoneNumber];
    //
    //    if (self.voiceMailInfo.countryVoicemailSupport && !self.voiceMailInfo.isVoiceMailEnabled && self.isCarrierSupportedForVoiceMailSetup) {
    //        self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList], self.activationDialNumber];
    //    }else if (!self.isValidCarrierName || !self.voiceMailInfo.countryVoicemailSupport) {
    //        self.helpText = kCarrierNotSupporttedHelpText;
    //    }else if (self.voiceMailInfo.isVoiceMailEnabled) {
    //        if ([self numberIsActive:self.phoneNumber withVoiceMailInfo:self.voiceMailInfo] && carrierDetails) {
    //            self.helpText = @"";
    //        }else if (self.voiceMailInfo.countryVoicemailSupport && self.isCarrierSupportedForVoiceMailSetup){
    //            self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", [self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList], self.activationDialNumber];
    //        }else if (!self.isValidCarrierName || !self.voiceMailInfo.countryVoicemailSupport || !carrierDetails) {
    //            self.helpText = kCarrierNotSupporttedHelpText;
    //        }else{
    //            if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
    //                self.helpText = kCarrierNotSupporttedHelpText;
    //            }else{
    //                self.helpText = [NSString stringWithFormat:@"%@ %@",kCarrierNotSupporttedHelpText,[self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList]];
    //            }
    //
    //        }
    //    }else{
    //
    //        self.helpText = [NSString stringWithFormat:@"%@ %@",kCarrierNotSupporttedHelpText,[self currentCarrierName:self.phoneNumber withCarrierList:self.currentCarrierList]];
    //    }
    self.helpText = @"";
    [self showHelpMessage];
    
}

- (void)configureHelpAndSuggestion
{
    self.helpTextArray = [[NSMutableArray alloc]init];
    self.supportContactList = [[Setting sharedSetting].supportContactList mutableCopy];
    if(self.supportContactList != nil && [self.supportContactList count] > 0)
    {
        NSUInteger count = (NSUInteger)[self.supportContactList count];
        for(NSUInteger  i = 0; i < count; i++)
        {
            NSMutableDictionary *dic = [self.supportContactList objectAtIndex:i];
            NSString *supportName = [dic valueForKey:SUPPORT_NAME];
            if([supportName isEqualToString:MENU_FEEDBACK])
            {
                //do nothing
            }
            else
            {
                [self.helpTextArray addObject:dic];
            }
        }
    }
}


- (void)showHelpMessage
{
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        if (self.helpTextArray != nil && [self.helpTextArray count] > 0) {
            NSUInteger count = [self.helpTextArray count];
            for(NSUInteger  i = 0;i < count; i++) {
                NSDictionary *helpPhoneDic = [self.helpTextArray objectAtIndex:i];
                [self gotoHelpChat:helpPhoneDic];
            }
        }
        else
            [ScreenUtility showAlertMessage:NSLocalizedString(@"NO_SUPPORT_LIST", nil)];
    }
    else {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

-(void)gotoHelpChat:(NSDictionary *)supportDic
{
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
    
    NSString *ivUserId = [supportDic valueForKey:SUPPORT_IV_ID];
    [newDic setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
    [newDic setValue:ivUserId forKey:REMOTE_USER_IV_ID];
    [newDic setValue:[supportDic valueForKey:SUPPORT_DATA_VALUE] forKey:FROM_USER_ID];
    [newDic setValue:[supportDic valueForKey:SUPPORT_NAME] forKey:REMOTE_USER_NAME];
    [newDic setValue:[supportDic valueForKey:SUPPORT_PIC_URI] forKey:REMOTE_USER_PIC];
    [newDic setValue:self.helpText forKey:@"HELP_TEXT"];
    
    
    //- get the pic
    NSNumber* ivID = [NSNumber numberWithLong:[ivUserId longLongValue]];
    NSArray* arr = [[Contacts sharedContact]getContactForIVUserId:ivID usingMainContext:YES];
    ContactDetailData* detailData = Nil;
    if([arr count]>0)
        detailData = [arr objectAtIndex:0];
    
    if(detailData)
        [newDic setValue:[IVFileLocator getNativeContactPicPath:detailData.contactIdParentRelation.contactPic]
                  forKey:REMOTE_USER_PIC];
    
    [appDelegate.dataMgt setCurrentChatUser:newDic];
    
    BaseUI* uiObj = [[InsideConversationScreen alloc]initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    uiObj.isAnyChangesSpecificSubClass = YES;
    [self.navigationController pushViewController:uiObj animated:YES];
    
}

- (IBAction)clickToEnableVoiceMailSettingsButtonTapped:(id)sender {
    
    if (![self isVoiceMailSupported]) {
        [self helpAction];
        return;
    }
    
    if(![self redirectVoiceMailAndSettingsScreens]) {
        //Get the Voicemail Info of Primary Number and Show Voicemail Settings Page.
        NSString *primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
        VoiceMailInfo *primaryNumberVoiceMailInfo = [[Setting sharedSetting]voiceMailInfoForPhoneNumber:primaryNumber];
        ActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ActivateReachMe"];
        activateReachMe.phoneNumber = primaryNumber;
        activateReachMe.isPrimaryNumber = YES;
        activateReachMe.voiceMailInfo = primaryNumberVoiceMailInfo;
        [self.navigationController pushViewController:activateReachMe animated:YES];
    }
}

- (BOOL)isVoiceMailSupported
{
    NSString* primaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
    
    NSMutableArray* additionalNumbers = [[NSMutableArray alloc]init];
    
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    if (nil != currentUserProfileDetails) {
        if ([currentUserProfileDetails.additionalVerifiedNumbers count]) {
            NSArray *verifiedNumbers = [currentUserProfileDetails.additionalVerifiedNumbers valueForKeyPath:@"contact_id"];
            NSMutableArray *additionalNumbersList = [[NSMutableArray alloc]init];
            for (NSString* number in verifiedNumbers) {
                if (![number isEqualToString:primaryNumber])
                    [additionalNumbersList addObject: number];
            }
            additionalNumbers = additionalNumbersList;
        }
    }
    
    //Check for the settings information - Settings response has the information about the user contacts.
    SettingModel *currentSettingsModel = [Setting sharedSetting].data;
    if (currentSettingsModel.voiceMailInfo && [currentSettingsModel.voiceMailInfo count]) {
        for (VoiceMailInfo *voiceMailInfo in currentSettingsModel.voiceMailInfo) {
            if(![voiceMailInfo.phoneNumber isEqualToString:primaryNumber]) {
                if(voiceMailInfo.reachMeVM || voiceMailInfo.reachMeHome || voiceMailInfo.reachMeIntl)
                    return YES;
            }
            else{
                if(voiceMailInfo.reachMeVM || voiceMailInfo.reachMeHome || voiceMailInfo.reachMeIntl)
                    return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)isReachMeActive
{
    //Check for the settings information - Settings response has the information about the user contacts.
    SettingModel *currentSettingsModel = [Setting sharedSetting].data;
    if (currentSettingsModel.voiceMailInfo && [currentSettingsModel.voiceMailInfo count]) {
        for (VoiceMailInfo *voiceMailInfo in currentSettingsModel.voiceMailInfo) {
            CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:voiceMailInfo.phoneNumber];
            if (carrierDetails.isReachMeIntlActive || carrierDetails.isReachMeHomeActive || carrierDetails.isReachMeVMActive) {
                return YES;
            }
//            IVSettingsCountryCarrierInfo *ccInfo =  [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:voiceMailInfo.phoneNumber];
//            NSString *activeString = [[ConfigurationReader sharedConfgReaderObj] getMissedCallReasonForTheNumber:voiceMailInfo.phoneNumber];
//            if (activeString.length && ccInfo) {
//                return YES;
//            }else{
//                if (carrierDetails.isReachMeIntlActive || carrierDetails.isReachMeHomeActive || carrierDetails.isReachMeVMActive) {
//                    return YES;
//                }
//            }
        }
    }
    
    return NO;
}

- (IBAction)buyRmNumber:(id)sender {
    [appDelegate.tabBarController setSelectedIndex:3];
    [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[3]];
}

- (void)updateUIWithShowOrHideStatusOfEnableVoiceMailButton {
    
    NSInteger numberOfRows = 0;
    self.unsupportedEmptyStateView.hidden = YES;
    if ([[[self currentActiveResultController] sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self currentActiveResultController] sections] objectAtIndex:0];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    if ((_currentFilteredList && [_currentFilteredList count] > 0) || (numberOfRows > 0)) {
        self.msgLabel.hidden = YES;
        self.tableView.hidden = NO;
        self.enableVoiceMailSettingsView.hidden = YES;
        return;
    }else if(isSearching){
        self.msgLabel.hidden = NO;
        self.tableView.hidden = YES;
        self.msgLabel.text = @"No search result";
        self.enableVoiceMailSettingsView.hidden = YES;
        return;
    }
    
    if ([self isVoiceMailSupported]) {
        if ([self isReachMeActive]) {
            self.enableVoiceMailSettingsView.hidden = YES;
            if ((_currentFilteredList && [_currentFilteredList count] > 0) || (numberOfRows > 0)) {
                self.msgLabel.hidden = YES;
                self.tableView.hidden = NO;
            }else{
                self.msgLabel.hidden = NO;
                if([cc.missedCallList count])
                    self.msgLabel.text = @"No search result";
                else
                    self.msgLabel.text = @"Once you get a ReachMe call or a Missed call, you'll see it listed here.";
            }
        }else{
            self.enableVoiceMailSettingsView.hidden = NO;
            self.headerLabel.text = @"Stay Connected, always!";
            self.detailsLabel.text = @"Activate InstaVoice ReachMe and receive calls on data network, while traveling abroad or when your number is unreachable.";
            [self.activateButton setTitle:@"ACTIVATE" forState:UIControlStateNormal];
            self.msgLabel.hidden = YES;
        }
    }else{
        self.enableVoiceMailSettingsView.hidden = YES;
        self.unsupportedEmptyStateView.hidden = NO;
        
        NSString *labelStringWithLink = @"However, you can buy a ReachMe Number to receive calls over WiFi or mobile data. You can also make calls from your mobile number over WiFi or mobile data. View calling rates";
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 1;
        NSURL *URL = [NSURL URLWithString: @""];
        NSMutableAttributedString * linkStr = [[NSMutableAttributedString alloc] initWithString:labelStringWithLink];
        [linkStr addAttribute: NSLinkAttributeName value:URL range: NSMakeRange(linkStr.length - 18, 18)];
        [linkStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, labelStringWithLink.length)];
        self.descriptionTextView.attributedText = linkStr;
        self.descriptionTextView.delegate = self;
        self.descriptionTextView.font = [UIFont systemFontOfSize:14.0];
        self.descriptionTextView.textAlignment = NSTextAlignmentCenter;
        self.descriptionTextView.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.54];
        self.descriptionTextView.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
        
        self.buyRmNumberButton.layer.cornerRadius = 5.0;
        self.msgLabel.hidden = YES;
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)url inRange:(NSRange)characterRange
{
    CountryCallingRatesViewController *callingRateVC = [[UIStoryboard storyboardWithName:@"IVSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"CountryCallingRate"];
    callingRateVC.profileFieldData = allCountriesList;
    callingRateVC.topFiveCountryList = topFiveList;
    [self.navigationController pushViewController:callingRateVC animated:YES];
    return YES;
}

- (void)prepareCountryListDictionary {
    
    KLog(@"prepareCountryListDictionary - START");
    
    BOOL hasPrefixValues;
    float debitRates = 0.0;
    float minDebitRate = 0.0;
    float maxDebitRate = 0.0;
    NSArray *obdDebitRatesArray;
    NSArray* tmp = [[Engine sharedEngineObj]fetchObdDebitPolicy:NO];
    if(tmp.count)
    {
        obdDebitRatesArray = [[NSArray alloc] initWithArray:tmp];
    }
    
    topFiveList = [[NSMutableArray alloc] init];
    
    for (NSMutableDictionary *country in [Common topFiveCountryList]) {
        hasPrefixValues = NO;
        NSString *isd =[country valueForKey:@"COUNTRY_SIM_ISO"];
        if (obdDebitRatesArray.count > 0) {
            
            NSArray* res = [obdDebitRatesArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.country_iso2 = %@",isd]];
            NSDictionary* iso=nil;
            if(res.count)
            iso = [res objectAtIndex:0];
            
            //for (NSDictionary *iso in obdDebitRatesArray)
            {
                //if ([[iso valueForKey:@"country_iso2"] isEqualToString:isd])
                if(iso.count)
                {
                    NSArray *prefixArray = [iso valueForKey:@"prefix_debits"];
                    NSNumber *max, *min;
                    long maxPrefix;
                    long minPrefix;
                    if (prefixArray.count > 0) {
                        hasPrefixValues = YES;
                        NSMutableArray *prefixDebitValues = [NSMutableArray arrayWithArray:[[iso valueForKey:@"prefix_debits"] allValues]];
                        max = [prefixDebitValues valueForKeyPath:@"@max.doubleValue"];
                        min = [prefixDebitValues valueForKeyPath:@"@min.doubleValue"];
                    }
                    
                    long callingRate = [[iso valueForKey:@"debits"] longValue];
                    
                    if (callingRate == -1) {
                        [country setValue:@"Not Supported" forKey:@"CALLING_RATE"];
                    }else{
                        if (hasPrefixValues) {
                            maxPrefix = [max longValue];
                            minPrefix = [min longValue];
                            minDebitRate = minPrefix / 100.0f;
                            maxDebitRate = maxPrefix / 100.0f;
                            if (0.00 == minDebitRate) {
                                minDebitRate = 0.01;
                            }
                            [country setValue:[NSString stringWithFormat:@"$ %.2lf - %.2lf /min",minDebitRate,maxDebitRate] forKey:@"CALLING_RATE"];
                            [country setValue:prefixArray forKey:@"prefix_debits"];
                        }else{
                            debitRates = callingRate / 100.0f;
                            [country setValue:[NSString stringWithFormat:@"$ %.2lf /min",debitRates] forKey:@"CALLING_RATE"];
                            [country setValue:@"" forKey:@"prefix_debits"];
                        }
                    }
                }
            }
        }else{
            [country setValue:@"Not Supported" forKey:@"CALLING_RATE"];
        }
        if (![country valueForKey:@"CALLING_RATE"]) {
            [country setValue:@"Not Supported" forKey:@"CALLING_RATE"];
        }
        [topFiveList addObject:country];
    }
    
    allCountriesList = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *country in [[Setting sharedSetting]getCountryList]) {
        hasPrefixValues = NO;
        NSString *isd =[country valueForKey:@"COUNTRY_SIM_ISO"];
        if (obdDebitRatesArray.count > 0) {
            for (NSDictionary *iso in obdDebitRatesArray) {
                if ([[iso valueForKey:@"country_iso2"] isEqualToString:isd]) {
                    NSArray *prefixArray = [iso valueForKey:@"prefix_debits"];
                    NSNumber *max, *min;
                    long maxPrefix;
                    long minPrefix;
                    if (prefixArray.count > 0) {
                        hasPrefixValues = YES;
                        NSMutableArray *prefixDebitValues = [NSMutableArray arrayWithArray:[[iso valueForKey:@"prefix_debits"] allValues]];
                        max = [prefixDebitValues valueForKeyPath:@"@max.doubleValue"];
                        min = [prefixDebitValues valueForKeyPath:@"@min.doubleValue"];
                    }
                    
                    long callingRate = [[iso valueForKey:@"debits"] longValue];
                    
                    if (callingRate == -1) {
                        [country setValue:@"Not Supported" forKey:@"CALLING_RATE"];
                    }else{
                        if (hasPrefixValues) {
                            maxPrefix = [max longValue];
                            minPrefix = [min longValue];
                            minDebitRate = minPrefix / 100.0f;
                            maxDebitRate = maxPrefix / 100.0f;
                            if (0.00 == minDebitRate) {
                                minDebitRate = 0.01;
                            }
                            [country setValue:[NSString stringWithFormat:@"$ %.2lf - %.2lf /min",minDebitRate,maxDebitRate] forKey:@"CALLING_RATE"];
                            [country setValue:prefixArray forKey:@"prefix_debits"];
                        }else{
                            debitRates = callingRate / 100.0f;
                            [country setValue:[NSString stringWithFormat:@"$ %.2lf /min",debitRates] forKey:@"CALLING_RATE"];
                            [country setValue:@"" forKey:@"prefix_debits"];
                        }
                    }
                }
            }
        }else{
            [country setValue:@"Not Supported" forKey:@"CALLING_RATE"];
        }
        if (![country valueForKey:@"CALLING_RATE"]) {
            [country setValue:@"Not Supported" forKey:@"CALLING_RATE"];
        }
        [allCountriesList addObject:country];
    }
    
    KLog(@"prepareCountryListDictionary - END");
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
            case GET_MISSEDCALL_LIST:
            {
                EnLogd(@"CallsViewController - GET_MISSEDCALL_LIST");
                KLog(@"CallsViewController - GET_MISSEDCALL_LIST");
                if([respCode isEqualToString:ENG_SUCCESS])
                {
                    [cc prepareBlockedUsers];
                    
                    NSMutableArray *missedCallList = [resultDic valueForKey:RESPONSE_DATA];
                    if(missedCallList.count) {
                        [appDelegate.engObj getActiveConversationList:TRUE];
                        [cc.missedCallList removeAllObjects];
                        [cc.missedCallList addObjectsFromArray:missedCallList];
                        cc.missedCallList = [cc filterChatsForDisplayType:ChatTypeCalls];
                        [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeCalls]];
                        _currentFilteredList = cc.missedCallList;
                        [self loadData];
                        [self updateUIWithShowOrHideStatusOfEnableVoiceMailButton];
                    } else {
                        [cc.missedCallList removeAllObjects];
                        [_currentFilteredList removeAllObjects];
                        [self unloadData];
                    }
                }
                
                break;
            }
                
            case NOTIFY_MISSEDCALL:
                KLog(@"MissedCall notify");
                if([cc.missedCallList count]) {
                    [self performSelectorOnMainThread:@selector(updateCurrentFilteredList:)
                                           withObject:cc.missedCallList waitUntilDone:NO];
                }
                
                if(_isAlertShown) {
                    [_delAlertView dismissWithClickedButtonIndex:0 animated:NO];
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
                            
                            NSArray* resMissedCallList = [cc.missedCallList filteredArrayUsingPredicate:predicate];
                            cc.missedCallList = [[NSMutableArray alloc] initWithArray:resMissedCallList];
                            
#ifndef REACHME_APP
                            NSArray* resAll = [cc.allMsgsList filteredArrayUsingPredicate:predicate];
                            cc.allMsgsList = [[NSMutableArray alloc]initWithArray:resAll];
                            [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeAll]];
#endif
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
                                    [appDelegate.engObj getMissedCallList:TRUE];
                                    break;
                                }
                                    
                                case ChatActivityTypeDelete:
                                {
                                    NSInteger curMsgId = [[self.voiceDic valueForKey:MSG_ID]integerValue];
                                    if(curMsgId>0 && (curMsgId == msgId)) {
                                        [self performSelectorOnMainThread:@selector(showWithdrawnAlert)
                                                               withObject:nil waitUntilDone:NO];
                                    }
                                    
                                    [self deleteMissedCall:msgId];
                                    [appDelegate.engObj getActiveConversationList:TRUE];
                                    [appDelegate.engObj getMissedCallList:TRUE];
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
                                    break;
                                }
                                    
                                default: break;
                            }
                        }
                        else {
                            // If we receive a new audio message while the current one is being played, the _currentFilteredList
                            // will only contain the dic of the new message received.
                            if(msgId == [[self.voiceDic valueForKey:MSG_ID]integerValue]) {
                                [self performSelectorOnMainThread:@selector(showWithdrawnAlert)
                                                       withObject:nil waitUntilDone:NO];
                                [appDelegate.engObj getActiveConversationList:TRUE];
                            }
                        }
                    }
                }
                
                if(reloadRequired) {
                    [self performSelectorOnMainThread:@selector(reloadDataOnMainThread) withObject:nil waitUntilDone:NO];
                }
                
                break;
            }
                
            default: break;
        }
    }
    return SUCCESS;
}


//July 19, 2016
/* This method should be called from handleEvent only in order to make _missedCallList thread-safe
 Delete a missedcall msg from the instance variable _missedCallList
 */
-(void)deleteMissedCall:(NSUInteger)msgID
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"!(MSG_ID = %ld)", msgID];
    cc.missedCallList = [NSMutableArray arrayWithArray:[cc.missedCallList filteredArrayUsingPredicate:resultPredicate]];
    KLog(@"Debug");
}

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
    
    if([_displayTypeFilteredList count] != [cc.missedCallList count]) {
        doRefreshTable = YES;
    }
    
    _displayTypeFilteredList = cc.missedCallList;
    
#ifndef REACHME_APP
    [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeAll]];
    KLog(@"updateCurrentFilteredList : ChatTypeCalls");
#endif
    
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
    
    [self.tableView reloadData];
    [cc updateBadgeValues:[NSNumber numberWithInt:ChatTypeCalls]];
}

-(void)unloadData
{
    [[self.tabBarController.tabBar.items objectAtIndex:ChatTypeCalls] setBadgeValue:nil];
    self.msgLabel.hidden = NO;
    self.msgLabel.alpha = 1;
    [UIView animateWithDuration:.25 animations:^{
        self.msgLabel.alpha = 1;
    }];
    
    if(!isSearching)
    {
        [self updateUIWithShowOrHideStatusOfEnableVoiceMailButton];
    }
    else
    {
        if(![cc.missedCallList count])
            [self updateUIWithShowOrHideStatusOfEnableVoiceMailButton];
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
    static NSString *cellMissedCallReceiver = @"ConversationCellMissedCallReceived";
    static NSString *cellMissedCallReceiverEx = @"ConversationCellMissedCallReceivedEx";
    static NSString *cellMissedCallSender = @"ConversationCellMissedCallSent";
    static NSString *cellMissedCallSenderEx = @"ConversationCellMissedCallSentEx";
    
    /*
    static NSString *cellRingMissedCallReceiver = @"ConversationCellRingMCReceived";
    static NSString *cellRingMissedCallReceiverEx = @"ConversationCellRingMCReceivedEx";
    static NSString *cellRingMissedCallSender = @"ConversationCellRingMCSent";
    static NSString *cellRingMissedCallSenderEx = @"ConversationCellRingMCSentEx";
    */
    
    static NSString *cellReachMe = @"ConversationCellReachMeCallReceived";
    static NSString *cellReachMeEx = @"ConversationCellReachMeCallReceivedEx";
    static NSString *cellReachMeDialed = @"ConversationCellReachMeCallDialed";
    static NSString *cellReachMeDialedEx = @"ConversationCellReachMeCallDialedEx";
    
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
    
    if([msgContentType isEqualToString:TEXT_TYPE]) {
        if([msgType isEqualToString:MISSCALL]) {
            if([msgFlow isEqualToString:MSG_FLOW_R]) {
                /*
                if([msgSubType isEqualToString:RING_MC]) {
                    if(self.showFromToNumber)
                        return cellRingMissedCallReceiverEx;
                    else
                        return cellRingMissedCallReceiver;
                }
                else
                */
                {
                    if(self.showFromToNumber)
                        return cellMissedCallReceiverEx;
                    else
                        return cellMissedCallReceiver;
                }
            }
            else {
                /*
                if([msgSubType isEqualToString:RING_MC]) {
                    if(self.showFromToNumber)
                        return cellRingMissedCallSenderEx;
                    else
                        return cellRingMissedCallSender;
                }
                else
                */
                {
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
        else if([msgType isEqualToString:VOIP_OUT]) {
            if([msgFlow isEqualToString:MSG_FLOW_R]) {
                if(self.showFromToNumber)
                    return cellReachMeEx;
                else
                    return cellReachMe;
            }
            else {
                if(self.showFromToNumber)
                    return cellReachMeDialed;
                else
                    return cellReachMeDialedEx;
            }
        }
        else if([msgType isEqualToString:AVS_TYPE]) {
            KLog(@"***** TEXT AVS TYPE CELL...NO IMPL");
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
        
        NSString* remoteUserIvId = @"";
        //NSString* contactName = @"";
        //NSString* contactPic = @"";
        if(indexPath.row < [_currentFilteredList count]) {
            NSMutableDictionary* chatConversationList = [_currentFilteredList objectAtIndex:indexPath.row];
            NSMutableDictionary* copyConversationList = [[NSMutableDictionary alloc]initWithDictionary:chatConversationList];
            
            //Get the contact detail
            NSString* fromUserId = [copyConversationList valueForKey:FROM_USER_ID];
            //FEB 21, 2017
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
            [cc moveToGroupChatScreen:selectedContact.contactIdParentRelation];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(0 == indexPath.section)
        return YES;
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        
        if(_currentTile < [_currentFilteredList count] ) {
            return @[deleteAction];
        } else {
            KLog(@"should not happen");
            EnLogd(@"should not happen");
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(0==section) {
        if(!_currentFilteredList.count)
            return 0.0;
        
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
        
        title = @"Calls";
    }
    else {
        title = @"Other contacts";
    }
    
    return title;
}

#pragma mark -- ChatGridCellDelegate
-(void)audioButtonClickedAtIndex:(NSInteger)index
{
     KLog(@"NO IMPL");
}

-(void)callbackIndicatorClickedAtIndex:(NSInteger)index
{
    KLog(@"NO IMPL");
}

-(void)setCurrentTime:(double)time
{
    KLog(@"NO IMPL");
}

#pragma mark -- ChatMobileNumberProtocol delegate
-(void)dismissedChatMobileNumberViewController:(id)sender
{
    NSMutableDictionary *newDic = sender;
    // if the sender object is nil or has nothing in it, the user has asked to chat with his own phone number, so simply go to the notes screen.
    if(newDic == nil && [newDic count] == 0) {
        self.tabBarController.selectedIndex = 1;
    }
    else
    {
        [appDelegate.dataMgt setCurrentChatUser:newDic];
        InsideConversationScreen *conversationScreen = [[InsideConversationScreen alloc]initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
        
        [self.navigationController pushViewController:conversationScreen animated:YES];
    }
}

#pragma mark -- IVDropDownDelegate User selection handling
-(void)buttonTappedRespond:(id)sender withUniqueIdentifier:(NSString*)uniqueIdentifier
{
    isDeleteMissedCall = NO;
    
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
        
        if ([btn tag] == 3) {
            //Delete is selected
            if ([[[_currentFilteredList objectAtIndex:_currentTile] valueForKey:MSG_TYPE] isEqualToString:@"mc"]){
                [self commonAlert:@"Delete missed call?" : @"This missed call will be deleted from your account." :@"Delete"];
                isDeleteMissedCall = YES;
            }
            else if ([[[_currentFilteredList objectAtIndex:_currentTile] valueForKey:MSG_TYPE] isEqualToString:VOIP_TYPE] || [[[_currentFilteredList objectAtIndex:_currentTile] valueForKey:MSG_TYPE] isEqualToString:VOIP_OUT]) {
                [self commonAlert:@"Delete message?" : @"This message will be deleted from your account." :@"Delete"];
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
        if ([[cellDic valueForKey:MSG_TYPE] isEqualToString:@"mc"])
        {
            // Missed Call Delete Alert Action
            if (buttonIndex != [alertView cancelButtonIndex])
            {
                if (isDeleteMissedCall) {
                    KLog(@"Delete MissedCall");
                    [appDelegate.engObj deleteMSG:cellDic];
                }
            }
        }
        else if([[cellDic valueForKey:MSG_TYPE] isEqualToString:VOIP_TYPE] || [[cellDic valueForKey:MSG_TYPE] isEqualToString:VOIP_OUT]) {
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

-(int)getChatType
{
    return ChatTypeCalls;
}

#pragma mark -- Remove overlay view to avoid crash
-(void)removeOverlayViewsIfAnyOnPushNotification
{
    [super removeOverlayViewsIfAnyOnPushNotification];
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
        _searchString = @"";
        [self setFetchRequestForSearch:Nil];
        
        //KLog(@"searchString - textDidChange: searchText=%@, searchString=%@",searchText,_searchString);
        
        _currentFilteredList = [cc filterChatsForDisplayType:ChatTypeCalls];
        if(_searchString.length<=0) {
            [self performSelectorOnMainThread:@selector(refreshTableOnMainThread)
                                   withObject:nil waitUntilDone:NO];
        }
        
    } else {
        _currentFilteredList = [cc filterChatsForDisplayType:ChatTypeCalls];
        isSearching = YES;
        _searchString = searchText;
        
        [self setFetchRequestForSearch:_searchString];
        
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
            
            NSString *stringChat = @"Calls";
            
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
    [self updateUIWithShowOrHideStatusOfEnableVoiceMailButton];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    KLog(@"searchBarTextDidEndEditing");
    [searchBar setShowsCancelButton:NO animated:YES];
    [self updateUIWithShowOrHideStatusOfEnableVoiceMailButton];
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
    [self updateUIWithShowOrHideStatusOfEnableVoiceMailButton];
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
    if([_searchString length] || [searchBar.text length]) {
        KLog((@"Reset the play status of all cells"));
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

-(int)unReadMessageCount:(NSArray*)msgList
{
    int unreadMsgCount = 0;
    for(NSDictionary* dic in msgList) {
        unreadMsgCount += [[dic valueForKey:UNREAD_MSG_COUNT]intValue];
    }
    return unreadMsgCount;
}

- (void)applicationDidEnterBackGround:(NSNotification *)notification
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
    
    NSMutableDictionary *newDic = [cc setUserInfoForConversation:contactDetail];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if(newDic == nil && [newDic count] == 0)
    {
        [appDelegate.tabBarController setSelectedIndex:5];
        [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[5]];
    }
    else
    {
        [appDelegate.dataMgt setCurrentChatUser:newDic];
        BaseUI* uiObj = [[InsideConversationScreen alloc] initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
        [self.navigationController pushViewController:uiObj animated:YES];
    }
}

-(void)manyIdView:(ContactData *)contactData
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

-(void)clearSearch
{
    [self performSelectorOnMainThread:@selector(clearSearchOnMainThread) withObject:nil waitUntilDone:NO];
}

-(void)clearSearchOnMainThread
{
    [self.tableView setUserInteractionEnabled:YES];
    _fetchedResultsController = nil;
}

- (BOOL)redirectVoiceMailAndSettingsScreens
{
    return [cc redirectToVoicemailOrSettingsScreen];
}

#ifdef REACHME_APP

//- read all contacts from phonebook and store into the app's DB
-(void)syncContact
{
    BOOL localSyncFlag = [appDelegate.confgReader getContactLocalSyncFlag];
    if(localSyncFlag) {
        return;
    }
    //
    // Contact Aceess Permission
    /*
    if(![appDelegate.confgReader getContactPermissionAlertFlag])
    {
        BOOL nativeAccessPermission = [appDelegate.confgReader getContactAccessPermissionFlag];
        
        if(!nativeAccessPermission)
        {
            nativeAccessPermission = [Common getNativeContactAccessPermission];
            [appDelegate.confgReader setContactAccessPermissionFlag:nativeAccessPermission];
        }
        
        if(nativeAccessPermission)
        {
             [[Contacts sharedContact]syncContactFromNativeContact];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PERMISSION_DIALOG", nil) message:NSLocalizedString(@"CONTACT_ACCESS_WARNING", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
            
            [appDelegate.confgReader setContactSyncPermissionFlag:FALSE];
            [appDelegate.confgReader setContactServerSyncFlag:TRUE];
            [appDelegate.confgReader setContactSyncPermissionFlag:FALSE];
        }
    }
    */
    
    [appDelegate.engObj fetchMsgRequest:nil];
    
    /*
    NSError* error;
    if (![self.managedObjectContext save:&error]) {
        KLog(@"CoreData: Error %@",[error localizedDescription]);
    }*/
    
    //- Save support contacts into DB
    NSArray* supportContact = [Setting sharedSetting].supportContactList;
    BOOL saveSupportContact = YES;
    NSString* phoneNum = @"";
    for(NSDictionary* dic in supportContact) {
        phoneNum = [dic valueForKey:SUPPORT_DATA_VALUE];
        if(phoneNum.length) {
            NSArray* res =  [[Contacts sharedContact]getContactForPhoneNumber:phoneNum];
            if(res.count)
                saveSupportContact = NO;
        }
    }
    if(saveSupportContact) {
        if(supportContact && [supportContact count] > 0)
            [[Contacts sharedContact]saveIVSupportContact:supportContact];
    }
    //
}

-(void)dismissAlert
{
    if(_delAlertView) {
        [_delAlertView dismissWithClickedButtonIndex:0 animated:NO];
        _delAlertView = nil;
    }
    
    if(uiAlertView) {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        uiAlertView = nil;
    }
}

#endif

@end
