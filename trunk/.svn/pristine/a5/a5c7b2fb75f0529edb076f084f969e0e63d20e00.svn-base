//
//  IVVoiceMailGreetingsViewController.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 29/06/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "IVVoiceMailGreetingsViewController.h"
#import "IVVoiceMailGreetingsRecordTableViewCell.h"
#import "IVFileLocator.h"
#import "Audio.h"
#import "SettingsMissedCallRecordAudioViewController.h"
#import "MZFormSheetController.h"
#import "SetGreetingsAPI.h"
#import "MyProfileApi.h"
#import "UserProfileModel.h"
#import "InsideConversationScreen.h"
#import "IVColors.h"
#import "Profile.h"

#define kVoiceMailGreetingsCellIdentifier @"VoiceMailGreetingsCell"
#define kNumberSectionsInGreetings 2
#define kNumberOfRowsInGreetings 2
#define kHeightForSections 110.0
#define kNameGreetingsRecordButtonTag 790
#define kWelcomeMessageRecordButtonTag 791
#define kNameGreetingsCancelButtonTag 490
#define kWelcomeMessageCancelButtonTag 491
#define kNameGreetingsPlayRecordButtonTag 531
#define kWelcomeGreetingsPlayRecordButtonTag 532
#define kNameGreetingsSliderRecordButtonTag 631
#define kWelcomeGreetingsSliderRecordButtonTag 632
#define kInfoAlertTag 891

typedef NS_ENUM(NSUInteger, GreetingsRecordCells) {
    eNameRecordCell = 0,
    eWelComeMessaegRecordCell = 1
};

@interface IVVoiceMailGreetingsViewController ()<IVVoiceMailCarrierSelectionProtocol,AudioDelegate,ProfileProtocol,SettingProtocol>{
    NSMutableDictionary *namePlayStatus, *welcomePlayStatus;
    NSInteger sliderIndexPathRow, nameSliderIndexTag, welcomeSliderIndexTag;
    NSTimer *timeInterval;
    BOOL playing;
}
@property (nonatomic, assign) NSInteger nameDurationTime;
@property (nonatomic, assign) NSInteger welcomeDurationTime;
@property (nonatomic, strong) NSString *recordingFileNameForGreetingsName;
@property (nonatomic, strong) NSString *recordingFileNameForGreetingsMessage;
@property (nonatomic, strong) NSString *storagePathName;
@property (nonatomic, strong) NSString *storagePathWelcome;
@property (nonatomic, strong) NSString *currentNetworkName;
@property (nonatomic, strong) NSString *helpText;
@property (nonatomic, strong) NSString *activationDialNumber;
@property (nonatomic, strong) UIImageView *transparentView;
@property (nonatomic, assign) BOOL isNameRecordingAvailable;
@property (nonatomic, assign) BOOL isWelcomeRecordingAvailable;
@property (nonatomic, strong) Audio *audioObj;
@property (nonatomic, strong) IVVoiceMailGreetingsRecordTableViewCell *voiceMailGreetingsRecordTableViewCell;
@property (nonatomic, strong) UISlider *audioSlider;
@property (nonatomic, strong) NSMutableArray *helpTextArray;
@property (nonatomic, strong) NSMutableArray *supportContactList;
@property BOOL scrubbing;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *playButton;

@end

@implementation IVVoiceMailGreetingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Voicemail Greetings", nil);
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpAction)];
    self.navigationItem.rightBarButtonItem = helpButton;
    
    namePlayStatus = [[NSMutableDictionary alloc]init];
    welcomePlayStatus = [[NSMutableDictionary alloc]init];
    [namePlayStatus setValue:[NSNumber numberWithDouble: 0.0] forKey:@"play_duration"];
    [welcomePlayStatus setValue:[NSNumber numberWithDouble: 0.0] forKey:@"play_duration"];
    self.audioObj = [[Audio alloc]init];
    self.audioObj.delegate = self;
    [self updateGreetingSpecificChanges];
    [self configureHelpAndSuggestion];
    self.voiceMailGreetingsTableView.tableFooterView = [UIView new];
    self.uiType = VOICEMAIL_GREETINGS_SCREEN;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[self navigationController] navigationBar] setNeedsLayout];
    
    //Get the settings information.
    [Setting sharedSetting].delegate = self;
    
    self.uiType = VOICEMAIL_GREETINGS_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    
    //Update the greetings messages
    [self updateGreetingSpecificChanges];
    
    [Profile sharedUserProfile].delegate = self;
    
    //This information we have to fetch fresh - to check out - greeting and welcome message has been changed or not.
    [[Profile sharedUserProfile]getProfileDataFromServer];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackGround:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}

- (void)applicationDidEnterBackGround:(NSNotification *)notification
{
    [self stopAudioPlayback];
}

- (void)helpAction
{
    //self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", self.currentNetworkName, self.activationDialNumber];
    [self stopAudioPlayback];
    [namePlayStatus setValue:[NSNumber numberWithDouble: 0.0] forKey:@"play_duration"];
    [welcomePlayStatus setValue:[NSNumber numberWithDouble: 0.0] forKey:@"play_duration"];
    [self.voiceMailGreetingsTableView reloadData];
    [self showHelpMessage];
}

- (void)configureHelpAndSuggestion
{
    self.helpTextArray       = [[NSMutableArray alloc]init];
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
    [newDic setValue:@"" forKey:@"HELP_TEXT"];
    
    //- get the pic
    NSNumber* iVID = [NSNumber numberWithLong:[ivUserId longLongValue]];
    NSArray* arr = [[Contacts sharedContact]getContactForIVUserId:iVID usingMainContext:YES];
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

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    //Stop playback If any
    if (self.audioObj)
        [self.audioObj stopPlayback];
    
    if (sliderIndexPathRow == 0) {
        NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
        nameCell.playButton.image = [UIImage imageNamed:@"play-red"];
    }
    else if (sliderIndexPathRow == 1)
    {
        NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
        welcomeCell.playButton.image = [UIImage imageNamed:@"play-red"];
    }
    
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

#pragma mark - BaseUI Method Implementation -
- (void)removeOverlayViewsIfAnyOnPushNotification {
    
    KLog(@"Remove PopOver if any open");
    [ScreenUtility closeAlert];
    
    NSArray *subViews = self.view.subviews;
    
    for (UIView *subView in subViews) {
        if (subView.tag == kInfoAlertTag) {
            UIAlertView *alertView = (UIAlertView *)subView;
            [alertView dismissWithClickedButtonIndex:1 animated:YES];
        }
    }
    
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
    [super removeOverlayViewsIfAnyOnPushNotification];
    
}

#pragma mark - UITableView Datasource Methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  kNumberSectionsInGreetings;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return kNumberOfRowsInGreetings;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITextView *msgLabel = [[UITextView alloc] init];
    switch (indexPath.row) {
        case eNameRecordCell: {
            msgLabel.text = @"Record your name for your callers when you are unavailable";
            msgLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
            [msgLabel sizeToFit];
            CGSize lableWidth = CGSizeMake(DEVICE_WIDTH - 140.0, CGFLOAT_MAX);
            CGSize neededSize = [msgLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
            if(self.isNameRecordingAvailable)
                return neededSize.height + 90.0;
            else
                return neededSize.height + 30.0;
            break;
        }
        case eWelComeMessaegRecordCell: {
            msgLabel.text = @"Record a welcome message for your callers when you are unavailable";
            msgLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
            [msgLabel sizeToFit];
            CGSize lableWidth = CGSizeMake(DEVICE_WIDTH - 140.0, CGFLOAT_MAX);
            CGSize neededSize = [msgLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
            if(self.isWelcomeRecordingAvailable)
                return neededSize.height + 90.0;
            else
                return neededSize.height + 30.0;
            break;
        }
        default:
            break;
    }
    return 150;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeightForSections;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *title = @"";
#ifdef REACHME_APP
    title = @"Note: Greetings will only work if your carrier is supported and ReachMe is activated on your number(s)";
#else
    title = @"Note: Greetings will only work if your carrier is supported and InstaVoice is activated on your number(s)";
#endif
    
    NSArray *headerTitle = @[@"Greeting will be played to your callers when you are busy or when your phone is not reachable",title];
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, section == 0?30.0:16.0, DEVICE_WIDTH - 30.0, 40.0)];
    label.text = NSLocalizedString([headerTitle objectAtIndex:section], nil);
    label.numberOfLines = 0;
    label.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    label.textColor = [UIColor darkGrayColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [label sizeToFit];
    [tableHeaderView addSubview:label];
    return tableHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *cellIdentifier;
    cellIdentifier = kVoiceMailGreetingsCellIdentifier;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    [cell layoutSubviews];
    [cell setNeedsLayout];
    return cell;
}

- (void)updateGreetingSpecificChanges
{
    AppDelegate *appdelegate = (AppDelegate *)APP_DELEGATE;
    
    self.recordingFileNameForGreetingsName = [NSString stringWithFormat:@"name_greeting_%@.wav",[appdelegate.confgReader getLoginId]];
    self.recordingFileNameForGreetingsMessage = [NSString stringWithFormat:@"welcome_greeting_%@.wav",[appdelegate.confgReader getLoginId]];
    
    self.isWelcomeRecordingAvailable = NO;
    self.isNameRecordingAvailable = NO;
    self.storagePathName   = [IVFileLocator getMyProfilePicPath:self.recordingFileNameForGreetingsName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.storagePathName]) {
        self.isNameRecordingAvailable = YES;
    }
    
    self.storagePathWelcome   = [IVFileLocator getMyProfilePicPath:self.recordingFileNameForGreetingsMessage];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.storagePathWelcome]) {
        self.isWelcomeRecordingAvailable = YES;
    }
    
    self.nameDurationTime = [self getFileDuration:self.storagePathName];
    self.welcomeDurationTime = [self getFileDuration:self.storagePathWelcome];
}

- (NSInteger)getFileDuration:(NSString*)localFilePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attrs = [fm attributesOfItemAtPath: localFilePath error: NULL];
    UInt32 pcmFileSize = (UInt32)[attrs fileSize]/16000;
    return pcmFileSize;
}


- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case eNameRecordCell: {
            
            if ([cell isKindOfClass:[IVVoiceMailGreetingsRecordTableViewCell class]]) {
                IVVoiceMailGreetingsRecordTableViewCell *recoridngCell = (IVVoiceMailGreetingsRecordTableViewCell *)cell;
                recoridngCell.recordButton.tag = kNameGreetingsRecordButtonTag;
                recoridngCell.cancelButton.tag = kNameGreetingsCancelButtonTag;
                recoridngCell.currentRecorindgButton.tag = kNameGreetingsPlayRecordButtonTag;
                recoridngCell.currentRecorindgButton.exclusiveTouch = YES;
                recoridngCell.greetingsRecordTableViewCellDelegate = self;
                recoridngCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                recoridngCell.titleLabel.text = NSLocalizedString(@"Name", nil);
                recoridngCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                recoridngCell.recordDetailsLabel.text = NSLocalizedString(@"Record your name for your callers when you are unavailable", nil);
                recoridngCell.recordDetailsLabel.font = recoridngCell.recordingLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
                NSString *currentRecordingText = [NSString stringWithFormat:@"0:%.2ld",(long)self.nameDurationTime];
                
                
                [recoridngCell.currentRecorindgButton setTitle:currentRecordingText forState:UIControlStateNormal];
                
                recoridngCell.recordInfoTitleLabel.text = (self.nameDurationTime)? NSLocalizedString(@"Re-Record", nil): NSLocalizedString(@"Record", nil);
                recoridngCell.recordInfoTitleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
                
                recoridngCell.voiceView.hidden = (self.nameDurationTime)?NO:YES;
                recoridngCell.cancelButton.hidden = (self.nameDurationTime)?NO:YES;
                
                recoridngCell.voiceView.backgroundColor = [IVColors redFillColor];
                recoridngCell.voiceView.layer.borderColor = [IVColors redOutlineColor].CGColor;
                recoridngCell.voiceView.tintColor = [IVColors redOutlineColor];
                recoridngCell.voiceView.clipsToBounds = YES;
                recoridngCell.voiceView.layer.borderWidth = 1;
                recoridngCell.voiceView.layer.cornerRadius = 5;
                recoridngCell.voiceView.tag = kNameGreetingsPlayRecordButtonTag;
                
                recoridngCell.audioSlider.minimumTrackTintColor = [IVColors redOutlineColor];
                recoridngCell.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xf3c4c0);
                [recoridngCell.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-red"] forState:UIControlStateNormal];
                recoridngCell.audioSlider.continuous = YES;
                recoridngCell.audioSlider.maximumValue = self.nameDurationTime;
                recoridngCell.audioSlider.value = 0;
                recoridngCell.audioSlider.tag = kNameGreetingsSliderRecordButtonTag;
                nameSliderIndexTag = kNameGreetingsSliderRecordButtonTag;
                recoridngCell.playButton.tag = kNameGreetingsPlayRecordButtonTag;
                
                recoridngCell.audioDuration.text = currentRecordingText;
                recoridngCell.audioDuration.textColor = [IVColors redOutlineColor];
                recoridngCell.audioDuration.textAlignment = NSTextAlignmentRight;
                recoridngCell.audioDuration.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voiceViewbuttonClicked:)];
                [recoridngCell.voiceView addGestureRecognizer:tap];
                
            }
            
            break;
        }
        case eWelComeMessaegRecordCell: {
            
            if ([cell isKindOfClass:[IVVoiceMailGreetingsRecordTableViewCell class]]) {
                IVVoiceMailGreetingsRecordTableViewCell *recoridngCell = (IVVoiceMailGreetingsRecordTableViewCell *)cell;
                recoridngCell.recordButton.tag = kWelcomeMessageRecordButtonTag;
                recoridngCell.cancelButton.tag = kWelcomeMessageCancelButtonTag;
                recoridngCell.currentRecorindgButton.tag = kWelcomeGreetingsPlayRecordButtonTag;
                recoridngCell.currentRecorindgButton.exclusiveTouch = YES;
                recoridngCell.selectionStyle = UITableViewCellSelectionStyleNone;
                recoridngCell.greetingsRecordTableViewCellDelegate = self;
                recoridngCell.titleLabel.text = NSLocalizedString(@"Welcome Message", nil);
                recoridngCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                recoridngCell.recordDetailsLabel.text = NSLocalizedString(@"Record a welcome message for your callers when you are unavailable", nil);
                recoridngCell.recordDetailsLabel.font = recoridngCell.recordingLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
                
                NSString *currentRecoringText = [NSString stringWithFormat:@"0:%.2ld",(long)self.welcomeDurationTime];
                [recoridngCell.currentRecorindgButton setTitle:currentRecoringText forState:UIControlStateNormal];
                
                recoridngCell.recordInfoTitleLabel.text = (self.welcomeDurationTime)? NSLocalizedString(@"Re-Record", nil): NSLocalizedString(@"Record", nil);
                
                recoridngCell.recordInfoTitleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
                
                recoridngCell.voiceView.hidden = (self.welcomeDurationTime)?NO:YES;
                recoridngCell.cancelButton.hidden = (self.welcomeDurationTime)?NO:YES;
                
                recoridngCell.voiceView.backgroundColor = [IVColors redFillColor];
                recoridngCell.voiceView.layer.borderColor = [IVColors redOutlineColor].CGColor;
                recoridngCell.voiceView.tintColor = [IVColors redOutlineColor];
                recoridngCell.voiceView.clipsToBounds = YES;
                recoridngCell.voiceView.layer.borderWidth = 1;
                recoridngCell.voiceView.layer.cornerRadius = 5;
                recoridngCell.voiceView.tag = kWelcomeGreetingsPlayRecordButtonTag;
                
                recoridngCell.playButton.tag = kWelcomeGreetingsPlayRecordButtonTag;
                
                recoridngCell.audioSlider.minimumTrackTintColor = [IVColors redOutlineColor];
                recoridngCell.audioSlider.maximumTrackTintColor = UIColorFromRGB(0xf3c4c0);
                [recoridngCell.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-red"] forState:UIControlStateNormal];
                recoridngCell.audioSlider.continuous = YES;
                recoridngCell.audioSlider.value = 0;
                recoridngCell.audioSlider.maximumValue = self.welcomeDurationTime;
                recoridngCell.audioSlider.tag = kWelcomeGreetingsSliderRecordButtonTag;
                welcomeSliderIndexTag = kWelcomeGreetingsSliderRecordButtonTag;
                recoridngCell.audioDuration.text = currentRecoringText;
                recoridngCell.audioDuration.textColor = [IVColors redOutlineColor];
                recoridngCell.audioDuration.textAlignment = NSTextAlignmentRight;
                recoridngCell.audioDuration.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voiceViewbuttonClicked:)];
                [recoridngCell.voiceView addGestureRecognizer:tap];
                
            }
            break;
        }
        default:
            break;
    }
}

- (void)voiceViewbuttonClicked:(UITapGestureRecognizer *)sender
{
    int speakerMode;
    if( [Audio isHeadsetPluggedIn] )
        speakerMode = false;
    else
        speakerMode = true;
    
    if (sender.view.tag == kNameGreetingsPlayRecordButtonTag) {
        sliderIndexPathRow = 0;
        if (self.storagePathName) {
            NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
            if ([nameCell.playButton.image isEqual:[UIImage imageNamed:@"pause-red"]]) {
                playing = NO;
                nameCell.playButton.image = [UIImage imageNamed:@"play-red"];
                if ([self.audioObj isPlay])
                    [self.audioObj pausePlayBack];
                
                if(timeInterval != nil)
                    [timeInterval invalidate];
                
                return;
            }else
                nameCell.playButton.image = [UIImage imageNamed:@"pause-red"];
            
            NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
            welcomeCell.playButton.image = [UIImage imageNamed:@"play-red"];
            
            if(timeInterval != nil)
                [timeInterval invalidate];
            
            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
            timeInterval = [NSTimer scheduledTimerWithTimeInterval:audioPlayUpdateInterval target:self selector:@selector(updateTime:)  userInfo:nil repeats:YES];
            [runloop addTimer:timeInterval forMode:NSRunLoopCommonModes];
            [runloop addTimer:timeInterval forMode:UITrackingRunLoopMode];
            
            double playedDuration = [[namePlayStatus valueForKey:@"play_duration"] doubleValue];
            [self.audioObj startPlayback:self.storagePathName playTime:playedDuration playMode:speakerMode];
            
        }
        return;
    }
    if (sender.view.tag == kWelcomeGreetingsPlayRecordButtonTag)
    {
        sliderIndexPathRow = 1;
        if (self.storagePathWelcome) {
            NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
            if ([welcomeCell.playButton.image isEqual:[UIImage imageNamed:@"pause-red"]]) {
                playing = NO;
                welcomeCell.playButton.image = [UIImage imageNamed:@"play-red"];
                if ([self.audioObj isPlay])
                    [self.audioObj pausePlayBack];
                
                if(timeInterval != nil)
                    [timeInterval invalidate];
                
                return;
            }else
                welcomeCell.playButton.image = [UIImage imageNamed:@"pause-red"];
            
            NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
            nameCell.playButton.image = [UIImage imageNamed:@"play-red"];
            
            if(timeInterval != nil)
                [timeInterval invalidate];
            
            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
            timeInterval = [NSTimer scheduledTimerWithTimeInterval:audioPlayUpdateInterval target:self selector:@selector(updateTime:)  userInfo:nil repeats:YES];
            [runloop addTimer:timeInterval forMode:NSRunLoopCommonModes];
            [runloop addTimer:timeInterval forMode:UITrackingRunLoopMode];
            
            double playedDuration = [[welcomePlayStatus valueForKey:@"play_duration"] doubleValue];
            [self.audioObj startPlayback:self.storagePathWelcome playTime:playedDuration playMode:speakerMode];
            
        }
        return;
    }
}

- (void)didEndSliderDrag:(id)sender
{
    playing = NO;
    int speakerMode;
    if( [Audio isHeadsetPluggedIn] )
        speakerMode = false;
    else
        speakerMode = true;
    
    if ([sender tag] == kNameGreetingsSliderRecordButtonTag) {
        sliderIndexPathRow = 0;
        if (self.storagePathName) {
            NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
            if ([nameCell.playButton.image isEqual:[UIImage imageNamed:@"pause-red"]]) {
                nameCell.playButton.image = [UIImage imageNamed:@"play-red"];
                if ([self.audioObj isPlay])
                    [self.audioObj pausePlayBack];
                
                if(timeInterval != nil)
                    [timeInterval invalidate];
                
                return;
            }else
                nameCell.playButton.image = [UIImage imageNamed:@"pause-red"];
            
            NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
            welcomeCell.playButton.image = [UIImage imageNamed:@"play-red"];
            
            if(timeInterval != nil)
                [timeInterval invalidate];
            
            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
            timeInterval = [NSTimer scheduledTimerWithTimeInterval:audioPlayUpdateInterval target:self selector:@selector(updateTime:)  userInfo:nil repeats:YES];
            [runloop addTimer:timeInterval forMode:NSRunLoopCommonModes];
            [runloop addTimer:timeInterval forMode:UITrackingRunLoopMode];
            
            double playedDuration = [[namePlayStatus valueForKey:@"play_duration"] doubleValue];
            [self.audioObj startPlayback:self.storagePathName playTime:playedDuration playMode:speakerMode];
            
        }
        return;
    }
    if ([sender tag] == kWelcomeGreetingsSliderRecordButtonTag)
    {
        sliderIndexPathRow = 1;
        if (self.storagePathWelcome) {
            NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
            if ([welcomeCell.playButton.image isEqual:[UIImage imageNamed:@"pause-red"]]) {
                welcomeCell.playButton.image = [UIImage imageNamed:@"play-red"];
                if ([self.audioObj isPlay])
                    [self.audioObj pausePlayBack];
                
                if(timeInterval != nil)
                    [timeInterval invalidate];
                
                return;
            }else
                welcomeCell.playButton.image = [UIImage imageNamed:@"pause-red"];
            
            NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
            nameCell.playButton.image = [UIImage imageNamed:@"play-red"];
            
            if(timeInterval != nil)
                [timeInterval invalidate];
            
            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
            timeInterval = [NSTimer scheduledTimerWithTimeInterval:audioPlayUpdateInterval target:self selector:@selector(updateTime:)  userInfo:nil repeats:YES];
            [runloop addTimer:timeInterval forMode:NSRunLoopCommonModes];
            [runloop addTimer:timeInterval forMode:UITrackingRunLoopMode];
            
            double playedDuration = [[welcomePlayStatus valueForKey:@"play_duration"] doubleValue];
            [self.audioObj startPlayback:self.storagePathWelcome playTime:playedDuration playMode:speakerMode];
            
        }
        return;
    }
}

- (void)updateTime:(NSTimer *)timer {
    double playDuration = 0.0;
    if (sliderIndexPathRow == 0) {
        NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
        nameCell.audioSlider.value = self.audioObj.getCurrentTime;
        playDuration = nameCell.audioSlider.value;
        [namePlayStatus setValue:[NSNumber numberWithDouble:playDuration] forKey:@"play_duration"];
        NSString *formattedDuration = [ScreenUtility durationIntoString:playDuration];
        [nameCell.audioDuration setText:formattedDuration];
    }
    else if (sliderIndexPathRow == 1)
    {
        NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
        welcomeCell.audioSlider.value = self.audioObj.getCurrentTime;
        playDuration = welcomeCell.audioSlider.value;
        [welcomePlayStatus setValue:[NSNumber numberWithDouble:playDuration] forKey:@"play_duration"];
        NSString *formattedDuration = [ScreenUtility durationIntoString:playDuration];
        [welcomeCell.audioDuration setText:formattedDuration];
    }
}

- (void)stopAudioPlayback
{
    if(timeInterval != nil)
        [timeInterval invalidate];
    
    if([self.audioObj isPlay])
        [self.audioObj pausePlayBack];
    
    if (sliderIndexPathRow == 0) {
        NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
        nameCell.playButton.image = [UIImage imageNamed:@"play-red"];
    }
    else if (sliderIndexPathRow == 1)
    {
        NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
        welcomeCell.playButton.image = [UIImage imageNamed:@"play-red"];
    }
}

#pragma UISlider
- (void)touchCancel:(id)sender {
    
    if ([sender tag] == kNameGreetingsSliderRecordButtonTag) {
        NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
        [nameCell.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-red"] forState:UIControlStateNormal];
    }
    else if ([sender tag] == kWelcomeGreetingsSliderRecordButtonTag)
    {
        NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
        [welcomeCell.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-red"] forState:UIControlStateNormal];
    }
    
}

-(void)changedThumbPosition
{
    if (sliderIndexPathRow == 0) {
        NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
        nameCell.audioSlider.continuous = YES;
        [nameCell.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-red"] forState:UIControlStateNormal];
    }else{
        NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
        welcomeCell.audioSlider.continuous = YES;
        [welcomeCell.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-small-red"] forState:UIControlStateNormal];
    }
    
}

-(void)changedSliderPosition:(id)sender {
    
    if ([sender tag] == kNameGreetingsSliderRecordButtonTag) {
        NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
        nameCell.audioSlider.continuous = NO;
        [nameCell.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-big-red"] forState:UIControlStateNormal];
    }
    else if ([sender tag] == kWelcomeGreetingsSliderRecordButtonTag)
    {
        NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
        welcomeCell.audioSlider.continuous = NO;
        [welcomeCell.audioSlider setThumbImage:[UIImage imageNamed:@"slide-img-big-red"] forState:UIControlStateNormal];
    }
}

-(void)touchUpInsideOrOutside:(id)sender {
    
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(changedThumbPosition)
                                   userInfo:nil
                                    repeats:NO];
    double playDuration = 0.0;
    if ([sender tag] == kNameGreetingsSliderRecordButtonTag) {
        sliderIndexPathRow = 0;
        NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
        playDuration = nameCell.audioSlider.value;
        NSString *formattedDuration = [ScreenUtility durationIntoString:playDuration];
        [nameCell.audioDuration setText:formattedDuration];
        [namePlayStatus setValue:[NSNumber numberWithDouble:playDuration] forKey:@"play_duration"];
        [self.audioObj setCurrentTime:playDuration];
    }
    else if ([sender tag] == kWelcomeGreetingsSliderRecordButtonTag)
    {
        sliderIndexPathRow = 1;
        NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
        playDuration = welcomeCell.audioSlider.value;
        NSString *formattedDuration = [ScreenUtility durationIntoString:playDuration];
        [welcomeCell.audioDuration setText:formattedDuration];
        [welcomePlayStatus setValue:[NSNumber numberWithDouble:playDuration] forKey:@"play_duration"];
        [self.audioObj setCurrentTime:playDuration];
    }
    
    if(playing)
        [self didEndSliderDrag:sender];
    
}

- (void)touchUpOutside:(id)sender {
    KLog(@"touchUpOutside");
    [self touchUpInsideOrOutside:sender];
}

- (void)touchUpInside:(id)sender {
    KLog(@"touchUpInside");
    [self touchUpInsideOrOutside:sender];
}

-(void)dragInsideOrOutside:(id)sender {
    if([self.audioObj isPlay]){
        playing = YES;
        [self stopAudioPlayback];
    }
    double playDuration = 0.0;
    if ([sender tag] == kNameGreetingsSliderRecordButtonTag) {
        sliderIndexPathRow = 0;
        NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
        nameCell.audioSlider.continuous = YES;
        playDuration = nameCell.audioSlider.value;
        NSString *formattedDuration = [ScreenUtility durationIntoString:playDuration];
        [nameCell.audioDuration setText:formattedDuration];
        [namePlayStatus setValue:[NSNumber numberWithDouble:playDuration] forKey:@"play_duration"];
    }else if ([sender tag] == kWelcomeGreetingsSliderRecordButtonTag){
        sliderIndexPathRow = 1;
        NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
        welcomeCell.audioSlider.continuous = YES;
        playDuration = welcomeCell.audioSlider.value;
        NSString *formattedDuration = [ScreenUtility durationIntoString:playDuration];
        [welcomeCell.audioDuration setText:formattedDuration];
        [welcomePlayStatus setValue:[NSNumber numberWithDouble:playDuration] forKey:@"play_duration"];
    }
    
}

- (void)sliderDragOutside:(id)sender {
    KLog(@"dragOutside");
    [self dragInsideOrOutside:sender];
}

- (void)sliderDragInside:(id)sender {
    KLog(@"dragInside");
    [self dragInsideOrOutside:sender];
}

- (void)deleteGreetingDataForType:(NSString*)type
{
    
    [self stopAudioPlayback];
    
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    
    if([type isEqualToString:@"name"]){
        [requestDic setValue:[NSNumber numberWithBool:YES] forKey:@"delete_nm"];
        [namePlayStatus setValue:[NSNumber numberWithDouble: 0.0] forKey:@"play_duration"];
    }else{
        [requestDic setValue:[NSNumber numberWithBool:YES] forKey:@"delete_gr"];
        [welcomePlayStatus setValue:[NSNumber numberWithDouble: 0.0] forKey:@"play_duration"];
    }
    SetGreetingsAPI* api = [[SetGreetingsAPI alloc]initWithRequest:requestDic];
    [api deleteFileForRequest:requestDic withSuccess:^(SetGreetingsAPI *req, NSMutableDictionary *responseObject) {
    } failure:^(SetGreetingsAPI *req, NSError *error) {
    }];
    
}

- (void)didTapOnPlayRecordingButton:(id)withSender {
    
    UIButton *btn = (UIButton*)withSender;
    //self.audioObj = [[Audio alloc]init];
    int speakerMode;
    if( [Audio isHeadsetPluggedIn] )
        speakerMode = false;
    else
        speakerMode = true;
    
    if (btn.tag == kNameGreetingsPlayRecordButtonTag) {
        if (self.storagePathName) {
            [self.audioObj startPlayback:self.storagePathName playTime:-1 playMode:speakerMode];
            self.transparentView = [[UIImageView alloc]init];
            self.transparentView.frame = CGRectMake(btn.bounds.origin.x, btn.bounds.origin.y, 1, btn.bounds.size.height);
            [self.transparentView setImage:[UIImage imageNamed:IMG_TRANSPARENT_STRIPE_READ]];
            [btn addSubview:self.transparentView];
            self.view.userInteractionEnabled = NO;
            [UIView animateWithDuration:self.nameDurationTime
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveLinear
                             animations:^{
                                 self.transparentView.frame = CGRectMake(btn.bounds.origin.x, btn.bounds.origin.y, btn.bounds.size.width, btn.bounds.size.height);
                             }
                             completion:^(BOOL finished){
                                 self.transparentView.frame = CGRectMake(self.transparentView.frame.origin.x, self.transparentView.frame.origin.y, 0, self.transparentView.frame.size.height);
                                 self.view.userInteractionEnabled = YES;
                             }];  // no completion handler
            
            
        }
        return;
    }
    if (btn.tag == kWelcomeGreetingsPlayRecordButtonTag)
    {
        if (self.storagePathWelcome) {
            [self.audioObj startPlayback:self.storagePathWelcome playTime:-1 playMode:speakerMode];
            self.transparentView = [[UIImageView alloc]init];
            self.transparentView.frame = CGRectMake(btn.bounds.origin.x, btn.bounds.origin.y, 1, btn.bounds.size.height);;
            [self.transparentView setImage:[UIImage imageNamed:IMG_TRANSPARENT_STRIPE_READ]];
            [btn addSubview:self.transparentView];
            self.view.userInteractionEnabled = NO;
            [UIView animateWithDuration:self.welcomeDurationTime
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveLinear
                             animations:^{
                                 self.transparentView.frame = CGRectMake(btn.bounds.origin.x, btn.bounds.origin.y, btn.bounds.size.width, btn.bounds.size.height);
                             }
                             completion:^(BOOL finished){
                                 self.transparentView.frame = CGRectMake(self.transparentView.frame.origin.x, self.transparentView.frame.origin.y, 0, self.transparentView.frame.size.height);
                                 self.view.userInteractionEnabled = YES;
                             }];  // no completion handler
        }
        return;
    }
    
}

- (void)didTapOnCancelRecordButtonWithTag:(NSInteger)withButtonTag {
    
    if ([self.audioObj isPlay])
        [self.audioObj stopPlayback];
    
    if ([Common isNetworkAvailable]) {
        if (withButtonTag == kNameGreetingsCancelButtonTag) {
            
            if (self.storagePathName) {
                [self deleteGreetingDataForType:@"name"];
                if ([IVFileLocator deleteFileAtPath:self.storagePathName]) {
                    self.isNameRecordingAvailable = NO;
                    self.recordingFileNameForGreetingsName = nil;
                    self.storagePathName = nil;
                    [self updateGreetingSpecificChanges];
                    dispatch_async(dispatch_get_main_queue()
                                   , ^{
                                       [self.voiceMailGreetingsTableView reloadData];
                                       UIView *headerView = [self.voiceMailGreetingsTableView headerViewForSection:0];
                                       //... update your view properties here
                                       [headerView setNeedsDisplay];
                                       [headerView setNeedsLayout];
                                       
                                       [self.voiceMailGreetingsTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:NO];
                                   });
                    
                    
                    return;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:eNameRecordCell inSection:0];
                    [self.voiceMailGreetingsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }
        else if (withButtonTag == kWelcomeMessageCancelButtonTag) {
            
            if (self.storagePathWelcome) {
                [self deleteGreetingDataForType:@"welcome"];
                if ([IVFileLocator deleteFileAtPath:self.storagePathWelcome]) {
                    self.isWelcomeRecordingAvailable = NO;
                    self.recordingFileNameForGreetingsMessage = nil;
                    self.storagePathWelcome = nil;
                    [self updateGreetingSpecificChanges];
                    dispatch_async(dispatch_get_main_queue()
                                   , ^{
                                       [self.voiceMailGreetingsTableView reloadData];
                                       UIView *headerView = [self.voiceMailGreetingsTableView headerViewForSection:0];
                                       //... update your view properties here
                                       [headerView setNeedsDisplay];
                                       [headerView setNeedsLayout];
                                       [self.voiceMailGreetingsTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:NO];
                                       
                                       
                                   });
                    
                    return;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:eWelComeMessaegRecordCell inSection:0];
                    [self.voiceMailGreetingsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    
                }
            }
        }
    }
    else {
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE",nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}


- (void)didTapOnRecordButtonWithTag:(NSInteger)withButtonTag {
    
    [self stopAudioPlayback];
    
    if(withButtonTag == kNameGreetingsRecordButtonTag){
        [namePlayStatus setValue:[NSNumber numberWithDouble: 0.0] forKey:@"play_duration"];
    }else{
        [welcomePlayStatus setValue:[NSNumber numberWithDouble: 0.0] forKey:@"play_duration"];
    }
    
    if ([Common isNetworkAvailable]) {
        if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
#ifdef REACHME_APP
            NSString* text = @"ReachMe app needs access to Microphone to record your Voicemail greetings.";
#else
            NSString* text = @"InstaVoice app needs access to Microphone to record your Voicemail greetings.";
#endif
            
            if(![self checkMicrophonePermission:text])
                return;
        }
        [self presentRecordScreen:withButtonTag];
        
    }
    else {
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE",nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

- (void)presentRecordScreen:(NSInteger)withButtonTag {
    SettingsMissedCallRecordAudioViewController *objRecordingViewController = [[SettingsMissedCallRecordAudioViewController alloc]init];
    objRecordingViewController.buttonTag = withButtonTag;
    //    objRecordingViewController.view.frame = CGRectMake(0, 0, 280, CGRectGetHeight([UIScreen mainScreen].applicationFrame)-295);
    objRecordingViewController.view.frame = CGRectMake(0, 0, 280, 253);
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:objRecordingViewController];
    formSheet.shouldDismissOnBackgroundViewTap = NO;//DEC 21
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.cornerRadius = 8.0;
    formSheet.presentedFormSheetSize = CGSizeMake(280,253);
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    
    formSheet.willDismissCompletionHandler = ^(UIViewController *presentedFSViewController){
        SettingsMissedCallRecordAudioViewController *objReturnViewController = (SettingsMissedCallRecordAudioViewController*)presentedFSViewController;
        if (objReturnViewController.isOkTapped) {
            if(objRecordingViewController.recordingFileLocalPath != Nil) {
                //do file deletion and updation
                [self performSelectorOnMainThread:@selector(updateFileNames:) withObject:objReturnViewController.recordingFileLocalPath waitUntilDone:YES];
                
                objReturnViewController.recordingFileLocalPath = [objReturnViewController.recordingFileLocalPath stringByReplacingOccurrencesOfString:@"te_mp_" withString:@""];
                objReturnViewController.recordingFileName = [objReturnViewController.recordingFileName stringByReplacingOccurrencesOfString:@"te_mp_" withString:@""];
                
                
                NSDictionary *aDict = [self convertWAVtoOpus:objReturnViewController.recordingFileLocalPath];
                KLog(@"New dict is %@",aDict);
                [self uploadGreetingDataWithFileName:[objReturnViewController.recordingFileName stringByAppendingPathExtension:@"iv"] filePath:[aDict valueForKey:@"FILEPATH"] duration:[[aDict valueForKey:@"DURATION"] integerValue] type:objReturnViewController.nameOrWelcome];
            }
            dispatch_async(dispatch_get_main_queue()
                           , ^{
                               [self updateGreetingSpecificChanges];
                               [self.voiceMailGreetingsTableView reloadData];
                               return;
                           });
        }
        else
        {
            return;
        }
    };
    
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
    }];
    
}

-(void)uploadGreetingDataWithFileName:(NSString*)fileName filePath:(NSString*)filePath duration:(NSInteger)duration type:(NSString*)type
{
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [requestDic setValue:fileName forKey:@"greeting_file_name"];
    [requestDic setValue:filePath forKey:@"greeting_file_path"];
    
    if([type isEqualToString:@"name"])
        [requestDic setValue:[NSNumber numberWithInteger:duration] forKey:API_NAME_DURATION];
    else
        [requestDic setValue:[NSNumber numberWithInteger:duration] forKey:API_WELCOME_DURATION];
    
    SetGreetingsAPI* api = [[SetGreetingsAPI alloc]initWithRequest:requestDic];
    [api callNetworkRequest:requestDic withSuccess:^(SetGreetingsAPI *req, NSMutableDictionary *responseObject) {
        //
    } failure:^(SetGreetingsAPI *req, NSError *error) {
        //unable to upload
    }];
    
}

- (NSMutableDictionary*)convertWAVtoOpus:(NSString*)localFilePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attrs = [fm attributesOfItemAtPath: localFilePath error: NULL];
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc]init];
    UInt32 pcmFileSize = (UInt32)[attrs fileSize]/16000;
    [mutDict setValue:[NSNumber numberWithInteger:pcmFileSize] forKey:@"DURATION"];
    //OpusCoder *_opusCoder = [[OpusCoder alloc]init];
    NSString* opusFileWithPath = [[NSString alloc]initWithString:[localFilePath stringByDeletingPathExtension]];
    opusFileWithPath = [opusFileWithPath stringByAppendingPathExtension:@"iv"];
    
    const char* cWavFileName = [localFilePath UTF8String];
    const char* cOpusFileName = [opusFileWithPath UTF8String];
    
    int iResult = [OpusCoder EncodeAudio:8000 Bitrate:12000 Bandwidth:OPUS_BANDWIDTH_SUPERWIDEBAND
                                 PCMFile:cWavFileName OPUSFile:cOpusFileName];
    if(SUCCESS == iResult) {
        [mutDict setValue:opusFileWithPath forKey:@"FILEPATH"];
        return mutDict;
    }
    else {
        EnLoge(@"ERROR: Encoding failed.")
        //TODO error : what to do?
        return mutDict;
    }
}

- (void)updateFileNames:(NSString*)localPath
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSString *oldLocalPath = [localPath stringByReplacingOccurrencesOfString:@"te_mp_" withString:@""];
    NSError *error;
    if([fileManger fileExistsAtPath:oldLocalPath])
    {
        BOOL success = [fileManger removeItemAtPath:oldLocalPath error:&error];
        if (!success) {
            KLog(@"Error: %@", [error localizedDescription]);
        }
    }
    
    if([fileManger fileExistsAtPath:localPath])
    {
        BOOL result = [fileManger moveItemAtPath:localPath toPath:oldLocalPath error:&error];
        if(!result)
            KLog(@"Error: %@", error);
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
            /*
             if ([self.audioObj isPlay])
             [self.audioObj stopPlayback];
             */
            
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
    if(timeInterval != nil)
    {
        [timeInterval invalidate];
    }
    
    if (sliderIndexPathRow == 0) {
        NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *nameCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:nameIndexPath];
        nameCell.playButton.image = [UIImage imageNamed:@"play-red"];
        nameCell.audioSlider.value = 0.0;
        NSString *currentRecordingText = [NSString stringWithFormat:@"0:%.2ld",(long)self.nameDurationTime];
        [nameCell.audioDuration setText:currentRecordingText];
        [namePlayStatus setValue:[NSNumber numberWithDouble:0.0] forKey:@"play_duration"];
    }
    else if (sliderIndexPathRow == 1)
    {
        NSIndexPath *welcomeIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        IVVoiceMailGreetingsRecordTableViewCell *welcomeCell = (IVVoiceMailGreetingsRecordTableViewCell *)[self.voiceMailGreetingsTableView cellForRowAtIndexPath:welcomeIndexPath];
        welcomeCell.playButton.image = [UIImage imageNamed:@"play-red"];
        welcomeCell.audioSlider.value = 0.0;
        NSString *currentRecordingText = [NSString stringWithFormat:@"0:%.2ld",(long)self.welcomeDurationTime];
        [welcomeCell.audioDuration setText:currentRecordingText];
        [welcomePlayStatus setValue:[NSNumber numberWithDouble:0.0] forKey:@"play_duration"];
    }
}

#pragma mark - Memory CleanUp Methods -
- (void)dealloc {
    
    //NSLog(@"Dealloc of voicemail activated controller has been called");
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.voiceMailGreetingsTableView = nil;
    self.voiceMailGreetingsRecordTableViewCell = nil;
    self.helpText = nil;
    self.recordingFileNameForGreetingsName = nil;
    self.recordingFileNameForGreetingsMessage = nil;
    self.storagePathName = nil;
    self.storagePathWelcome = nil;
    self.nameDurationTime = 0;
    self.welcomeDurationTime = 0;
    self.helpTextArray = nil;
    self.supportContactList = nil;
    self.audioObj = nil;
    self.transparentView  = nil;
    self.isNameRecordingAvailable = NO;
    self.isWelcomeRecordingAvailable = NO;
    
}

- (IVVoiceMailGreetingsRecordTableViewCell *)voiceMailGreetingsRecordTableViewCell {
    
    if (!_voiceMailGreetingsRecordTableViewCell)
        _voiceMailGreetingsRecordTableViewCell = [self.voiceMailGreetingsTableView dequeueReusableCellWithIdentifier:kVoiceMailGreetingsCellIdentifier];
    return _voiceMailGreetingsRecordTableViewCell;
}

#pragma mark - Profile Delegate Methods -
-(void)fetchProfileCompletedWith:(UserProfileModel*)modelData {
    
    [self updateGreetingSpecificChanges];
    
    dispatch_async(dispatch_get_main_queue()
                   , ^{
                       [self.voiceMailGreetingsTableView reloadData];
                       
                   });
    
}

-(void)updateProfileCompletedWith:(UserProfileModel*)modelData {
    [self updateGreetingSpecificChanges];
    dispatch_async(dispatch_get_main_queue()
                   , ^{
                       [self.voiceMailGreetingsTableView reloadData];
                       
                   });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
