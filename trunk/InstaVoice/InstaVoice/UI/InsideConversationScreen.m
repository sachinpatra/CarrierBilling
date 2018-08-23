//
//  InsideConversationScreen.m
//  InstaVoice
//
//  Created by Eninov User on 04/10/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "InsideConversationScreen.h"
#import "SizeMacro.h"
#import "CircleProgressView.h"
#import "Profile.h"
#import "ViewForContactScreen.h"
#import "IVFileLocator.h"
#import "IVMediaLoader.h"

#ifndef REACHME_APP
#import "UpdateGroupAPI.h"
#endif

#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"
#import "ChatActivity.h"
#import "IVImageUtility.h"
#import "IVColors.h"
#import "MyNotesScreen.h"

#define SIZE_17_5       17.5

#define CombineMCBenchMark1   10000
#define CombineMCBenchMark2   120000


#ifdef REACHME_APP
extern NSString* const kLowBalanceWarning;
extern NSString* const kLowBalance;
extern NSString* const kLowBalanceTitle;
#endif

@interface InsideConversationScreen () <IVMediaLoaderDelegate>
{
    BOOL shouldDismissCoachView;
#ifdef REACHME_APP
    UIAlertController* uiAlertView;
#endif
}

@property (strong, nonatomic) NSString *ringAlertNameString;
@property (strong, nonatomic) UIButton *enableSpeakerButton;

@end

@implementation InsideConversationScreen

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.uiType = INSIDE_CONVERSATION_SCREEN;
        voiceMsgDic = nil;
        // Custom initialization
#ifdef REACHME_APP
        self.title = NSLocalizedString(SUPPORT_HELP, nil);
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(SUPPORT_HELP, nil)
                                                          image:[UIImage imageNamed:@"live_help"]
                                                  selectedImage:[UIImage imageNamed:@"live_help"]]];
#endif
        
    }
    return self;
}

- (void)viewDidLoad
{
    KLog(@"viewDidLoad");
    
    addOrDeleteMemeber = NO;
    
    [self.navigationController.navigationBar setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
    [self.chatView setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
    
    self.uiType = INSIDE_CONVERSATION_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    
    _msgLimitExceeded = NO;
    voiceMsgFlag  = FALSE;
    [super viewDidLoad];
    inviteList = [[NSMutableArray alloc]init];
    dicSections = nil;
    acWithdraw = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    KLog(@"ViewWillAppear");
    saveLastMsg = YES;
    //Temporary disabling swipe gesture to move back hhome screen 
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self.navigationController.navigationBar setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
    [self.chatView setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
    
    self.uiType = INSIDE_CONVERSATION_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];

    [super viewWillAppear:animated];

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:currentChatUserInfo];
    [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeSeenAllMsg withData:dic];
    
    if(!dicSections.count || !arrDatesSorted.count)
    {
        NSArray* msgList = [appDelegate.dataMgt getCurrentChat];
        if(msgList.count)
        {
            [self prepareDataSourceFromMessages:msgList withInsertion:YES MsgType:eOtherMessage];
            [self markReadMessagesFromThisList:msgList];
            [self loadData];
            [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.01];
        }
        else
        {
            self.chatView.hidden = YES;
            msgTextLabel.hidden = YES;
        }
    }

    [self setConversationHeader];
    NSString * remoteUserType = [currentChatUserInfo valueForKey:REMOTE_USER_TYPE];
    if([remoteUserType isEqualToString:PHONE_MODE])
    {
        self.msgType = VSMS_TYPE;
    }
    else if ([remoteUserType isEqualToString:CELEBRITY_TYPE]) {
        self.msgType = CELEBRITY_TYPE;
    }
    else
    {
        self.msgType = IV_TYPE;
    }
    
    [[IVMediaLoader sharedIVMediaLoader]setDelegate:self];
    [self reloadTableViewBasedOnOrNotCelebrity];
    
#ifdef REACHME_APP
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(onPresenceChanged:)
                                               name:kLinphoneNotifyPresenceReceivedForUriOrTel
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(displayLowBalance)
                                               name:kLowBalanceWarning
                                             object:nil];
#endif
}

-(void) updateRemoteUserNameOfActiveConversation:(NSMutableArray*)chatUserList Info:(NSMutableDictionary*)conversationDic
{
   // KLog(@"updateRemoteUserNameOfActiveConversation");
    NSArray* allDateKeys = [dicSections allKeys];
    NSArray* msgList = nil;
    for(NSDate* dtDate in allDateKeys)
    {
        if(!chatUserList) {
            msgList = [dicSections objectForKey:dtDate];
        } else {
            msgList = chatUserList;
        }
        
        for(NSMutableDictionary* msgDic in msgList) {
            ContactDetailData* detail = [conversationDic valueForKey:[msgDic valueForKey:NATIVE_CONTACT_ID]];
            NSString* contactName = detail.contactIdParentRelation.contactName;
            if(contactName && [contactName length]) {
                /*DEBUG
                if([contactName containsString:@"rakesh"]) {
                    KLog(@"Debug");
                }*/
                [msgDic setValue:detail.contactIdParentRelation.contactName forKey:REMOTE_USER_NAME];
            }
            else {
                EnLogd(@"Empty contact name from Contacts DB");
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (addOrDeleteMemeber) {
        if([indexPath isEqual:((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject])]) {
            KLog(@"willDisplayCell");
            [self scrollToBottom];
            addOrDeleteMemeber = NO;
        }
    }
}

-(void)reloadTableViewBasedOnOrNotCelebrity
{
    NSString * remoteUserType = [currentChatUserInfo valueForKey:REMOTE_USER_TYPE];
    
    //if the user type is a celebrity, the entire screen should be the chat screen
    if([remoteUserType isEqualToString:CELEBRITY_TYPE] && !_allowMessaging) {
        self.chatView.contentInset = UIEdgeInsetsZero;
        self.chatView.frame = self.view.bounds;
    }
    else
    {
        if(isKeyboardPresent && [text1 isFirstResponder]) {
            [self updateTableView];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    KLog(@"viewWillDisappear - START");
    [appDelegate setChatScreenPushed:FALSE];
    
    [super viewWillDisappear:animated];
    
    if (shouldDismissCoachView) {
        shouldDismissCoachView = NO;
        //[self dismissCoachView];
    }
    
    [[IVMediaLoader sharedIVMediaLoader]setDelegate:Nil];
    if(popUp != nil)
    {
        [popUp close];
    }
    
    if(nil != viewAfterTap) {
        [viewAfterTap removeFromSuperview];
        viewAfterTap = nil;
    }
    
#ifndef REACHME_APP
    if(nil != viewForGroupChatMembers) {
        [viewForGroupChatMembers removeFromSuperview];
        viewForGroupChatMembers = nil;
    }
#endif
    
    KLog(@"viewWillDisappear - END");
}

//Function:Setting of Header View for InsideConversation Screen
-(void)setConversationHeader
{
    // To get help screen status
    BOOL HelpScreen = NO;
    NSString* UserId = [currentChatUserInfo valueForKey:FROM_USER_ID];
    NSArray* supportCont = [Setting sharedSetting].supportContactList;
    for(NSDictionary* diction in supportCont) {
        NSString* number = [diction valueForKey:SUPPORT_DATA_VALUE];
        if([number isEqualToString:UserId])
            HelpScreen = YES;
    }
    
    if(currentChatUserInfo != nil)
	{
        NSString* fromUserId = [currentChatUserInfo valueForKey:FROM_USER_ID];
        NSString *userName = [currentChatUserInfo valueForKey:REMOTE_USER_NAME];
        NSString *localUserPicPath = [currentChatUserInfo valueForKey:REMOTE_USER_PIC];

        if(fromUserId)
		{
            NSArray* contactDetailArray = [[Contacts sharedContact]getContactForPhoneNumber:fromUserId];
            if(contactDetailArray && [contactDetailArray count] > 0)
			{
                ContactDetailData* contactDetailData = [contactDetailArray objectAtIndex:0];
                ContactData* data = contactDetailData.contactIdParentRelation;
                userName = data.contactName;
                if(!userName || !userName.length)
                    userName = contactDetailData.contactDataValue;
                
                localUserPicPath = [IVFileLocator getNativeContactPicPath:data.contactPic];
                
                if([[currentChatUserInfo valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE])
                {
                    [currentChatUserInfo setValue:userName forKey:REMOTE_USER_NAME];
                    [currentChatUserInfo setValue:localUserPicPath forKey:REMOTE_USER_PIC];
                }
            }
            else {
                //TODO: CMP: check FEB 21
                NSNumber* ivID = [NSNumber numberWithLong:[fromUserId longLongValue]];
                NSArray* contactDetailArray = [[Contacts sharedContact]getContactForIVUserId:ivID usingMainContext:YES];
                if(contactDetailArray && contactDetailArray.count > 0)
                {
                    ContactDetailData* detail = [contactDetailArray objectAtIndex:0];
                    [currentChatUserInfo setValue:detail.contactDataValue forKey:FROM_USER_ID];
                    [currentChatUserInfo setValue:[IVFileLocator getNativeContactPicPath:detail.contactIdParentRelation.contactPic] forKey:REMOTE_USER_PIC];
                }
            }
        }

        
        // Set up the Navigation bar
#ifndef REACHME_APP
        self.title=nil;
#endif
        
        UIButton *labelButton = nil;
        /*
        if( [[currentChatUserInfo valueForKey:REMOTE_USER_TYPE] isEqualToString:CELEBRITY_TYPE])
            labelButton = [[UIButton alloc]initWithFrame:CGRectMake(20,0,DEVICE_WIDTH/2,44)];
        else*/
            labelButton = [[UIButton alloc]initWithFrame:CGRectMake(20.0,0.0,(DEVICE_WIDTH/2.0)-2,44.0)];
        /*
        CGSize size = CGSizeMake(140,44);
        [labelButton sizeThatFits:size];
         */
        labelButton.backgroundColor = [UIColor whiteColor];
        [labelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        labelButton.titleLabel.font = [UIFont systemFontOfSize:17];
        labelButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        labelButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        labelButton.clipsToBounds = YES;
        //labelButton.backgroundColor = [UIColor grayColor];//TODO
        //KLog(@"labelButton = %@",labelButton);
        
        if([[currentChatUserInfo valueForKey:REMOTE_USER_TYPE] isEqualToString:CELEBRITY_TYPE])
        {
            [labelButton removeTarget:self action:@selector(labelToShowView) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [labelButton addTarget:self action:@selector(labelToShowView) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if([currentChatUserInfo valueForKey:CONVERSATION_TYPE] && [[currentChatUserInfo valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE]) {
            //self.title = userName;dp
            [labelButton setTitle:userName forState:UIControlStateNormal];
        } else {
            NSString *name = [currentChatUserInfo valueForKey:REMOTE_USER_NAME];
            if(!name || !name.length)
                name = [currentChatUserInfo valueForKey:FROM_USER_ID];

            if (name) {
                NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
                NSNumber *countryIsdCode = [phoneUtil extractCountryCode:([Common addPlus:name]) nationalNumber:nil];
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
                NSString *countryIsdCodeString = [formatter stringFromNumber:countryIsdCode];
                
                NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCodeString];
                
                NSString* strResult=nil;
                NBPhoneNumber *theNumber = [phoneUtil parse:name
                                             defaultRegion:countrySimIso error:nil];
                if([phoneUtil isValidNumber:theNumber]) {
                    NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:countrySimIso];
                    strResult = [f inputString:[Common addPlus:name]];
                } else
                    strResult = name;
                // set the acutal title
                NSString *buttonDisplay=strResult;//[f inputString:[Common addPlus:name]];
               [labelButton setTitle:buttonDisplay forState:UIControlStateNormal];
            } else {
                [labelButton setTitle:userName forState:UIControlStateNormal];
            }
        }
        
        _ringAlertNameString = labelButton.titleLabel.text;
        // set up the "info" button in the top right of the screen]
    
        UIView *infoButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        UIButton *infoButton = nil;
        UIImage *groupImage = [ScreenUtility getPicImage:[currentChatUserInfo valueForKey:REMOTE_USER_PIC]];

#ifdef REACHME_APP
        if(!groupImage && userName.length && ([userName isEqualToString:SUPPORT_HELP] || [userName isEqualToString:MENU_FEEDBACK])) {
            NSString* supportPic = [currentChatUserInfo valueForKey:SUPPORT_PIC_URI];
            if(supportPic.length)
                groupImage = [ScreenUtility getPicImage:supportPic];
        }
#endif
        if (groupImage) {
            infoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
            [infoButton setBackgroundImage: groupImage forState:UIControlStateNormal];
            [infoButton setFrame:CGRectMake(0, 0, 24, 24)];
            infoButton.layer.cornerRadius = infoButton.frame.size.height / 2;
            infoButton.clipsToBounds = YES;
        } else {
            infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        }
        [infoButtonView addSubview:infoButton];
        [infoButton addTarget:self action:@selector(labelToShowView) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationItem setTitleView:labelButton];
        
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButtonView];
        
        // set up the audio switching button in the top of the screen
        UIButton *audioButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        self.enableSpeakerButton = audioButton;
        [audioButton addTarget:self action:@selector(audioModeTapped:) forControlEvents:UIControlEventTouchUpInside];
         UIBarButtonItem *secondRightBarButton = [[UIBarButtonItem alloc] initWithCustomView:audioButton];
        
        //
        //RingButton
#ifndef REACHME_APP
        UIView *ringButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        UIButton *ringButton;
        ringButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        ringButton.layer.cornerRadius = infoButton.frame.size.height / 2;
        ringButton.clipsToBounds = YES;
        [ringButton setImage:[UIImage imageNamed:@"ringIcon"] forState:UIControlStateNormal];
        [ringButton addTarget:self action:@selector(ringAlertView) forControlEvents:UIControlEventTouchUpInside];
        [ringButtonView addSubview:ringButton];
        UIBarButtonItem *ringBarButton = [[UIBarButtonItem alloc] initWithCustomView:ringButtonView];
#endif
        // set up the audio switching modes
        // speaker is currently on
        if(_speakerMode) {
            [audioButton setImage:[[UIImage imageNamed:@"speaker-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [audioButton setImage:[[UIImage imageNamed:@"speaker-closed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
            
            [audioButton setTintColor:[IVColors redColor]];
        }
        else {
            // speaker is currently off
            [audioButton setImage:[[UIImage imageNamed:@"speaker-closed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [audioButton setImage:[[UIImage imageNamed:@"speaker-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
            [audioButton setTintColor:[IVColors grayOutlineColor]];
        }
        
#ifndef REACHME_APP
        if(![[currentChatUserInfo valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE] && !HelpScreen)
            [self.navigationItem setRightBarButtonItems:([[currentChatUserInfo valueForKey:REMOTE_USER_TYPE] isEqualToString:CELEBRITY_TYPE]? @[secondRightBarButton] : @[rightBarButton, secondRightBarButton,ringBarButton]) animated:YES];
        else
            [self.navigationItem setRightBarButtonItems:([[currentChatUserInfo valueForKey:REMOTE_USER_TYPE] isEqualToString:CELEBRITY_TYPE] ? @[secondRightBarButton] : @[rightBarButton, secondRightBarButton]) animated:YES];
#else
        [self.navigationItem setRightBarButtonItems:@[rightBarButton, secondRightBarButton] animated:YES];
        if(HelpScreen) {
            containerView.hidden = NO;
        }
#endif
    }

    HelpScreen = NO;
}



#ifdef REMOVE_LATER
//TODO:
-(void)displayCoach
{
    //KLog(@"Bundle Version is %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortxVersionString"]);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ( ![userDefaults valueForKey:@"version"] )
    {
        // CALL your Function;
        [self coachView];
        shouldDismissCoachView = YES;
        // Adding version number to NSUserDefaults for first version:
        [userDefaults setFloat:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue] forKey:@"version"];
    }
    
    
    if ([[NSUserDefaults standardUserDefaults] floatForKey:@"version"] == [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue] )
    {
        /// Same Version so dont run the function
    }
    else
    {
        // Call Your Function;
        [self coachView];
        shouldDismissCoachView = YES;
        // Update version number to NSUserDefaults for other versions:
        [userDefaults setFloat:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue] forKey:@"version"];
    }
}

-(void)coachView
{
    containerView.userInteractionEnabled = NO;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //MainView
    coachMarkViewButton = [[UIButton alloc]initWithFrame:screenRect];
    coachMarkViewButton.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.8];
    [coachMarkViewButton addTarget:self action:@selector(dismissCoachView) forControlEvents:UIControlEventTouchCancel];
    [coachMarkViewButton addTarget:self action:@selector(dismissCoachView) forControlEvents:UIControlEventTouchDown];
    [coachMarkViewButton addTarget:self action:@selector(dismissCoachView) forControlEvents:UIControlEventTouchDownRepeat];
    [coachMarkViewButton addTarget:self action:@selector(dismissCoachView) forControlEvents:UIControlEventTouchDragEnter];
    [coachMarkViewButton addTarget:self action:@selector(dismissCoachView) forControlEvents:UIControlEventTouchDragExit];
    [coachMarkViewButton addTarget:self action:@selector(dismissCoachView) forControlEvents:UIControlEventTouchDragInside];
    [coachMarkViewButton addTarget:self action:@selector(dismissCoachView) forControlEvents:UIControlEventTouchDragOutside];
    [coachMarkViewButton addTarget:self action:@selector(dismissCoachView) forControlEvents:UIControlEventTouchUpOutside];
    [coachMarkViewButton addTarget:self action:@selector(dismissCoachView) forControlEvents:UIControlEventTouchCancel];
    //navigationView
    coachMarkNavigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    coachMarkNavigationView.backgroundColor =  [[UIColor blackColor] colorWithAlphaComponent:0.8];
    //TextView
    UITextView *coachTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.frame.size.width - 194, -8, 200, 100.0)];
    coachTextView.backgroundColor = [UIColor clearColor];
    coachTextView.textAlignment = NSTextAlignmentCenter;
    coachTextView.textColor= [UIColor whiteColor];
    //
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    NSMutableParagraphStyle *paragraphStyle1 = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle1 setAlignment:NSTextAlignmentCenter];
    paragraphStyle1.lineHeightMultiple = 40.0f;
    paragraphStyle1.maximumLineHeight = 20.0f;
    //
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"InstaVoice Ring"];
    [attString addAttribute:(NSString*)NSUnderlineStyleAttributeName
                      value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                      range:(NSRange){0,[attString length]}];
    //[attString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(0, attString.length)];
    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Comic Sans MS" size:20] range:NSMakeRange(0, attString.length)];

    
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attString.length)];
    [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attString length])];

    
    NSMutableAttributedString *newAttString = [[NSMutableAttributedString alloc] initWithString:@"\nTap to place a Missed Call \nto your friend over data" attributes:nil];
    [newAttString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Comic Sans MS" size:15.0] range:NSMakeRange(0, newAttString.length)];
    [newAttString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttString.length)];
    [newAttString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [newAttString length])];
    
    [attString appendAttributedString:newAttString];

    coachTextView.attributedText = attString;
    [coachTextView setUserInteractionEnabled:NO];
    //[NSString stringWithFormat:@"%@\nTap to place a Missed Call\n to your friend over data",attString];
    //
    
    //
   UIButton *ringButton = [[UIButton alloc]initWithFrame:CGRectMake(self.navigationController.navigationBar.frame.size.width - 107, 6 , 32, 32)
    ];
    ringButton.backgroundColor = [UIColor whiteColor];
    [ringButton setImage:[UIImage imageNamed:@"ringIcon"] forState:UIControlStateNormal];
    
    ringButton.layer.cornerRadius = 15;
    ringButton.layer.borderColor = [UIColor whiteColor].CGColor;
    ringButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    ringButton.layer.shadowRadius = 15.0f;
    ringButton.layer.shadowOpacity = 1.0f;
    ringButton.layer.shadowOffset = CGSizeZero;
    //to animate button
    [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction  animations:^{
        
        [UIView setAnimationRepeatCount:25];
        
        ringButton.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        
        
    } completion:^(BOOL finished) {
    
        ringButton.layer.shadowRadius = 15.0f;
        ringButton.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
    //
    [ringButton setUserInteractionEnabled:NO];
    [coachMarkNavigationView addSubview:ringButton];
    //
    //DismissButton
    UIButton *dismissButton = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH/2-45, DEVICE_HEIGHT/2-85, 90, 90)];
    dismissButton.backgroundColor = [UIColor whiteColor];
    dismissButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    dismissButton.layer.shadowRadius = 10.0f;
    dismissButton.layer.shadowOpacity = 0.4f;
    dismissButton.layer.shadowOffset = CGSizeZero;
    
    [dismissButton setTitle:@"Got It" forState:UIControlStateNormal];
    [dismissButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlEventTouchUpInside];
    [dismissButton addTarget:self action:@selector(dismissCoachView) forControlEvents:UIControlEventTouchUpInside];
    dismissButton.layer.cornerRadius = 45;
    
    [coachMarkViewButton addSubview:dismissButton];
    
    [self.view addSubview:coachMarkViewButton];
    [coachMarkViewButton addSubview:coachTextView];
    [self.navigationController.navigationBar addSubview:coachMarkNavigationView];
    self.navigationItem.hidesBackButton = YES;
}

-(void)dismissCoachView
{
    [UIView animateWithDuration:0.4
                          delay:0.3
                        options: UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         coachMarkViewButton.alpha=0;
                         coachMarkNavigationView .alpha=0;
                         self.navigationItem.hidesBackButton = NO;
                     } completion:^(BOOL finished) {
                         [coachMarkViewButton removeFromSuperview];
                         [coachMarkNavigationView removeFromSuperview];
                         containerView.userInteractionEnabled = YES;
                     }];
    
}
#endif


+(UILabel *)setTitleLable:(NSString *)userNameString
{
    UILabel *title= nil;
    CGSize size = {0,0};
    
    size = [userNameString sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:HELVETICANEUE_MEDIUM size:SIZE_18]}];
    
    if(size.width >= SIZE_18)
    {
        title = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_65,SIZE_23,SIZE_210,SIZE_30)];
    }
    else
    {
        title = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_75,SIZE_23,SIZE_180,SIZE_30)];
    }
    
    return title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark Comnbine MissedCall messages
-(void)combineMissedCallMessages:(NSMutableArray *)list
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if(list.count)
    {
        NSMutableArray *currentChat = [[NSMutableArray alloc] initWithArray:list];
        long count = [currentChat count];
        
        for(int i =0; i <count; i++)
        {
            NSMutableArray *tempRecArry = [[NSMutableArray alloc]init];
            NSMutableArray *tempSendArry = [[NSMutableArray alloc]init];
            
            for(int j =i;j<count;j++)
            {
                NSMutableDictionary *dic = [list objectAtIndex:j];
                //JUNE, 2017
                NSMutableDictionary* prevDic = nil;
                NSString* msgFlow = nil;
                NSString* nativeContactID = nil;//JUNE, 2017
                if(j>0) {
                    prevDic = [currentChat objectAtIndex:j-1];
                    msgFlow = [prevDic valueForKey:MSG_FLOW];
                    nativeContactID = [prevDic valueForKey:NATIVE_CONTACT_ID];//JUNE, 2017
                }
                //
                
                if([[dic valueForKey:MSG_TYPE] isEqualToString:MISSCALL] &&
                   ![[dic valueForKey:MSG_SUB_TYPE] isEqualToString:RING_MC] &&
                    ([[dic valueForKey:NATIVE_CONTACT_ID] isEqualToString:nativeContactID]))
                {
                    i = j;
                    
                    if([[dic valueForKey:MISSED_CALL_COUNT]integerValue]>1)
                    {
                        break;
                    }
                    
                    if([[dic valueForKey:MSG_FLOW] isEqualToString:MSG_FLOW_R])
                    {
                        [tempRecArry addObject:dic];
                    }
                    else
                    {
                        [tempSendArry addObject:dic];
                    }
                }
                else
                {
                    break;
                }
            }
            
            if([tempRecArry count] > 0)
            {
                long cnt = [tempRecArry count];
                NSMutableDictionary *tempDic = [tempRecArry objectAtIndex:0];
                [tempDic setValue:[NSNumber numberWithLong:cnt] forKey:MISSED_CALL_COUNT];
                [tempRecArry removeObject:tempDic];
                [tempDic setValue:tempRecArry forKey:MSG_LIST];
                [arr addObjectsFromArray:tempRecArry];
            }
            if([tempSendArry count] > 0)
            {
                long cnt = [tempSendArry count];
                NSMutableDictionary *tempDic = [tempSendArry objectAtIndex:0];
                [tempDic setValue:[NSNumber numberWithLong:cnt] forKey:MISSED_CALL_COUNT];
                [tempSendArry removeObject:tempDic];
                [tempDic setValue:tempSendArry forKey:MSG_LIST];
                [arr addObjectsFromArray:tempSendArry];
            }
        }
        if([arr count] >0)
        {
            [list removeObjectsInArray:arr];
        }
    }
}

-(void)groupingOfMissedCallMessages:(NSMutableArray *)list
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSMutableArray *currentChat = [[NSMutableArray alloc] initWithArray:list];
    long count = [currentChat count];
    if(count)
    {
        for(int i =0; i <count; i++)
        {
            NSMutableArray *tempaArry = [[NSMutableArray alloc]init];
            NSMutableArray *tempbArry = [[NSMutableArray alloc]init];
            NSMutableArray *tempcArry = [[NSMutableArray alloc]init];
            
            NSMutableDictionary *dic = [list objectAtIndex:i];
            
            if([[dic valueForKey:MSG_TYPE] isEqualToString:MISSCALL] && [[dic valueForKey:MISSED_CALL_COUNT]integerValue]>1)
            {
                NSString *timeValue = [dic valueForKey:MSG_DATE];
                
                NSArray *othersMissedCalls = [dic valueForKey:MSG_LIST];
                long countOfMissedCalls = [othersMissedCalls count];
                
                for(int j=0;j<countOfMissedCalls;j++)
                {
                    NSMutableDictionary *otherMCdic = [othersMissedCalls objectAtIndex:j];
                    
                    NSString *tempTimeValue = [otherMCdic valueForKey:MSG_DATE];
                    
                    if(([timeValue intValue] - [tempTimeValue intValue]) < CombineMCBenchMark1*1000)
                    {
                        [tempaArry addObject:otherMCdic];
                    }
                    else if((([timeValue intValue] - [tempTimeValue intValue]) > CombineMCBenchMark1*1000) && (([timeValue intValue] - [tempTimeValue intValue]) < CombineMCBenchMark2*1000)){
                        [tempbArry addObject:otherMCdic];
                    }
                    else{
                        [tempcArry addObject:otherMCdic];
                    }
                }
            }
            
            if([tempcArry count] > 0)
            {
                long cnt = [tempcArry count];
                NSMutableDictionary *tempDic = [tempcArry objectAtIndex:0];
                [arr addObjectsFromArray:tempcArry];
                [tempDic setValue:[NSNumber numberWithLong:cnt] forKey:MISSED_CALL_COUNT];
                [tempcArry removeObject:tempDic];
                [tempDic setValue:tempcArry forKey:MSG_LIST];
                [list insertObject:tempDic atIndex:[list indexOfObject:dic]];
            }
            
            if([tempbArry count] > 0)
            {
                long cnt = [tempbArry count];
                NSMutableDictionary *tempDic = [tempbArry objectAtIndex:0];
                [arr addObjectsFromArray:tempbArry];
                [tempDic setValue:[NSNumber numberWithLong:cnt] forKey:MISSED_CALL_COUNT];
                [tempbArry removeObject:tempDic];
                [tempDic setValue:tempbArry forKey:MSG_LIST];
                [list insertObject:tempDic atIndex:[list indexOfObject:dic]];
            }
            
            if([tempaArry count] > 0)
            {
                [dic setValue:tempaArry forKey:MSG_LIST];
            }
            
            if([arr count] >0)
            {
                [dic setValue:[NSNumber numberWithLong:([tempaArry count]+1)] forKey:MISSED_CALL_COUNT];
                [[dic valueForKey:MSG_LIST] removeObjectsInArray:arr];
            }
        }
    }
}

#pragma mark Event Manager
//Function:Event Manager
-(int)handleEvent:(NSMutableDictionary *)resultDic
{
    if(nil == resultDic)
    {
        return SUCCESS;
    }

    int evType = [[resultDic valueForKey:EVENT_TYPE] intValue];
    //NSLog(@"*** evType = %d",evType);
    NSString *respCode = [resultDic valueForKey:RESPONSE_CODE];
    
    switch (evType)
    {
        //case SEND_VOIP_CALL_LOG:
        //    break;
            
        case GET_CURRENT_CHAT:
        {
            if([respCode isEqual:ENG_SUCCESS]) {
                [self handleGetCurrentChat];
            }
            else {
                EnLogd(@"Inside conversation: GETCURRENT CHAT - ENG_FAILURE");
                [self unloadData];
            }
        }
            break;
            
        case SEND_VOIP_CALL_LOG:
        case FETCH_MSG:
        {
            EnLogd(@"Event type = FETCH_MSG");
            if([respCode isEqualToString:ENG_SUCCESS])
            {
                [self processResponseFromServer:resultDic forEventType:evType];
                [self updateRemoteUserNameOfActiveConversation:nil Info:_activeConversationDictionary];
            }
            
            break;
        }
            
        case FETCH_OLDER_MSG:
        {
            [_refreshControl endRefreshing];
            _beginRefreshingOldMessages = false;

            if([respCode isEqualToString:ENG_SUCCESS]) {
                [self handleFetchOlderMsg:resultDic];
            }
            [self updateRemoteUserNameOfActiveConversation:nil Info:_activeConversationDictionary];
        }
            break;
            
        case DOWNLOAD_VOICE_MSG:
        {
            EnLogd(@"Inside Conversation - DOWNLOAD_VOICE_MSG");
            KLog(@"Inside Conversation - DOWNLOAD_VOICE_MSG");
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
        
        case SEND_MC:
        {
            if([respCode isEqualToString:ENG_SUCCESS])
            {
                [self processResponseFromServer:resultDic forEventType:SEND_MC];
            } else {
                [self handleSendMCError:resultDic];
            }
            break;
        }
        /*
        case SEND_VOIP_CALL_LOG:
        {
            if([respCode isEqualToString:ENG_SUCCESS])
            {
                //[self processVoipCallLog:resultDic];
            } else {
                //[self handleVoipCallLogError:resultDic];
            }
            break;
        }*/
    
        case SEND_MSG:
        {
            [self handleSendMsg:resultDic];
            break;
        }
            
        case GET_VSMS_LIMIT:
        {
            if([respCode isEqualToString:ENG_SUCCESS])
            {
                [self vsmsLimitWork];
            }
        }
            break;
            
        case NOTIFY_UI_ON_ACTIVITY:
            [self handleNotifyUIOnActivity:resultDic];
            break;

            
        default:
            [super handleEvent:resultDic];
            break;
    }
    
    return SUCCESS;
}


-(void)handleGetCurrentChat
{
    NSMutableArray* newConversationList = [appDelegate.dataMgt getCurrentChat];
    
    [self combineMissedCallMessages:newConversationList];
    [self groupingOfMissedCallMessages:newConversationList];
    
    if(newConversationList != nil && [newConversationList count] > 0)
    {
        NSMutableArray* phoneNumList = [[NSMutableArray alloc]init];
        for(NSMutableDictionary* dic in newConversationList)
        {
            NSString* msgType = [dic valueForKey:MSG_TYPE];
            NSString* msgSubType = [dic valueForKey:MSG_SUB_TYPE];
            if([msgType isEqualToString:VOIP_TYPE] && ![msgSubType isEqualToString:VOIP_CALL_ACCEPTED]) {
                continue;
            }
            
            if([dic objectForKey:@"NATIVE_CONTACT_ID"] != nil) {
                NSString* nativeContactID = [dic valueForKey:NATIVE_CONTACT_ID];
                if(nativeContactID && nativeContactID.length)
                    [phoneNumList addObject:nativeContactID];
            }
            else {
                NSString* phoneNum = [dic valueForKey:FROM_USER_ID];
                if(phoneNum && phoneNum.length)
                    [phoneNumList addObject:phoneNum];
            }
        }
        
        //NSLog(@"*** handleGetCurrentChat");
        [self prepareDataSourceFromMessages:newConversationList withInsertion:YES MsgType:eOtherMessage];//JAN 16, 2017
        _activeConversationDictionary = [[Contacts sharedContact]getContactDictionaryForChatGridScreen:phoneNumList];
        
        [self updateRemoteUserNameOfActiveConversation:newConversationList Info:_activeConversationDictionary];
        if(voiceMsgDic != nil)
        {
            NSString *voiceGuid = [voiceMsgDic  valueForKey:MSG_GUID];
            for (int i=0; i<[newConversationList count]; i++)
            {
                NSMutableDictionary *dic = [newConversationList objectAtIndex:i];
                NSString *msgGuid  = [dic valueForKey:MSG_GUID];
                if([msgGuid isEqualToString:voiceGuid])
                {
                    [dic setValue:API_DOWNLOAD_INPROGRESS forKey:MSG_STATE];
                    voiceMsgDic = dic;
                    break;
                }
            }
        }
        [self loadData];
        [self scrollToBottom];
        
        /* TODO -- do we need to play the last received voice msg
        if(!voiceMsgFlag)
        {
           [self playLatestVoiceMsg];
        }*/
         
        [self reloadTableViewBasedOnOrNotCelebrity];
        [self markReadMessagesFromThisList:newConversationList];//DEC 2017
    }
    else
    {
        EnLogd(@"HANDLE EVENT : CONVERSATION LIST IS NIL");
        [self unloadData];
    }
}

-(void)handleFetchOlderMsg:(NSMutableDictionary*)resultDic
{
    KLog(@"### handleFetchOlderMsg START");
    
    if(![resultDic valueForKey:RESPONSE_DATA])
    {
        //[text1 resignFirstResponder];
        [ScreenUtility showAlertMessage:@"No further older messages"];
    }
    else
    {
        NSMutableArray* oldMsgList = [resultDic valueForKey:RESPONSE_DATA];
        NSDictionary* reqDic = [resultDic valueForKey:REQUEST_DIC];
        BOOL isResponseForTheCurrentUser = [self isTheCurrentUserMadeTheRequest:reqDic];
        if(!isResponseForTheCurrentUser) {
            return;
        }
        
        if(oldMsgList.count) {
            long  oldSections = [arrDatesSorted count];
            [self combineMissedCallMessages:oldMsgList];
            [self groupingOfMissedCallMessages:oldMsgList];
            [self prepareDataSourceFromMessages:oldMsgList withInsertion:NO MsgType:eOtherMessage];
            long newSections = [arrDatesSorted count];
            
            [self.chatView reloadData];
            long sectionToScroll = oldSections<newSections?(newSections-oldSections-1):0;
            [self reloadAndScrollToSection:sectionToScroll];
            [self  markReadMessagesFromThisList:nil];//MAY 11,2017
        }
    }
    
    KLog(@"### handleFetchOlderMsg - END");
}

/*
 Before processing the server response for the request FETCH_OLDER_MSG, the user can change the current user chat tile.
 So, it is required to check if the response being processed by the current user is the user who requested the cmd.
 
 */
-(BOOL)isTheCurrentUserMadeTheRequest:(NSDictionary*)request
{
    BOOL result = TRUE;
    
    long long theRequestedUserIvId = [[request valueForKey:@"for_iv_user_id"]longLongValue];
    if(theRequestedUserIvId>0) {
        long long theCurrentUserIvId = [[currentChatUserInfo valueForKey:REMOTE_USER_IV_ID]longLongValue];
        if(theRequestedUserIvId != theCurrentUserIvId) {
            result = FALSE;
        }
    }
    else {
        NSString* theRequestedUserContactId = [request valueForKey:@"for_contact_id"];
        if(theRequestedUserContactId && [theRequestedUserContactId length]) {
            NSString* theCurrentUserContactId = [currentChatUserInfo valueForKey:FROM_USER_ID];
            if(![theRequestedUserContactId isEqualToString:theCurrentUserContactId]) {
                result = FALSE;
            }
        }
    }
    
    return result;
}


-(void)handleNotifyUIOnActivity:(NSMutableDictionary*)resultDic
{
    NSString *respCode = [resultDic valueForKey:RESPONSE_CODE];
    NSMutableArray* msgActivityList = [resultDic valueForKey:RESPONSE_DATA];
    BOOL reloadRequired=false;
    if(msgActivityList.count && dicSections.count)
    {
        for(ChatActivityData* data in msgActivityList)
        {
            //Jan 20, 2017
            NSUInteger secIndex=0;
            NSMutableArray* msgList = nil;
            NSArray* filteredMsgList = nil;
            NSInteger msgId = data.msgId;;
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.MSG_ID = %ld", msgId];
            NSArray* arrAllDateKeys = [dicSections allKeys];
            for(NSDate* dtDate in arrAllDateKeys) {
                msgList = [dicSections objectForKey:dtDate];
                //if(![msgList count]) continue;
                filteredMsgList = [msgList filteredArrayUsingPredicate:predicate];
                if([filteredMsgList count]) break;
                secIndex++;
            }
            //
            
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
                    case ChatActivityTypeReadMessage:
                        [filteredMsgList[0] setValue:[NSNumber numberWithInt:1] forKey:MSG_READ_CNT];
                        reloadRequired = YES;
                        break;
                        
                    case ChatActivityTypeWithdraw:
                    {
                        NSMutableDictionary* selectedDic = [filteredMsgList objectAtIndex:0];
                        NSString* msgContentType = [selectedDic valueForKey:MSG_CONTENT_TYPE];
                        if([msgContentType isEqualToString:AUDIO_TYPE]) {
                            NSInteger playBackStatus = [[selectedDic valueForKey:MSG_PLAYBACK_STATUS]integerValue];
                            [self stopAudioPlayback];
                            if(playBackStatus>0 ) {
                                [self performSelectorOnMainThread:@selector(showWithdrawnAlert)
                                                       withObject:nil waitUntilDone:NO];
                            }
                        }
                        [selectedDic setValue:MSG_WITHDRAWN_TEXT forKey:MSG_CONTENT];
                        [selectedDic setValue:API_WITHDRAWN forKey:MSG_STATE];
                        [selectedDic setValue:TEXT_TYPE forKey:MSG_CONTENT_TYPE];
                        [selectedDic setValue:IV_TYPE forKey:MSG_TYPE];
                        [selectedDic setValue:@"" forKey:MSG_SUB_TYPE];
                        reloadRequired=YES;
                        
                        break;
                    }
                        
                    case ChatActivityTypeDelete: {
                        reloadRequired = NO;
                        NSUInteger rowIndex=0;
                        NSNumber* nuDate=nil;
                        for(NSDictionary* dic in msgList) {
                            if(msgId == [[dic valueForKey:MSG_ID]integerValue]) {
                                NSString* msgContentType = [dic valueForKey:MSG_CONTENT_TYPE];
                                nuDate = [dic valueForKey:MSG_DATE];
                                //[self.chatView beginUpdates];
                                [msgList removeObjectAtIndex:rowIndex];
                                /* Jan 20, 2017
                                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:secIndex];
                                NSArray* deleteIndexPath = [[NSArray alloc] initWithObjects:indexPath, nil];
                                [self.chatView deleteRowsAtIndexPaths:deleteIndexPath
                                                     withRowAnimation:UITableViewRowAnimationMiddle];
                                */
                                //[self.chatView endUpdates];
                                
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
                        //Jan 20, 2017
                        if([msgList count]<=0) {
                            NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
                            dtDate = [self getDateWithDayMonthYear:dtDate];
                            [dicSections removeObjectForKey:dtDate];
                            [arrDatesSorted removeObject:dtDate];
                        }
                        //
                        [self.chatView reloadData];
                        //dismiss the action sheet displayed.
                        [self dismissActiveAlertController];
                    }
                        break;
                        
                    case ChatActivityTypeRing: {
                        if([respCode isEqualToString:ENG_SUCCESS]) {
                            NSString* msgContent = [NSString stringWithFormat:RING_MC_SUCCESS];
                            if(data.dic) {
                                msgContent = [data.dic valueForKey:MSG_CONTENT];
                            }
                            if([filteredMsgList count])
                                [filteredMsgList[0] setValue:msgContent forKey:MSG_CONTENT];
                        }
                        else {
                            if([filteredMsgList count])
                                [filteredMsgList[0] setValue:RING_MC_FAILED forKey:MSG_CONTENT];
                        }
                        KLog(@"Debug");
                        break;
                    }
                        
                    default:
                        break;
                }
            }
        }
    }
    
    if(reloadRequired)
        [self.chatView reloadData];
}


-(void)handleSendMsg:(NSMutableDictionary*)resultDic
{
    NSString *respCode = [resultDic valueForKey:RESPONSE_CODE];
    
    //dp : code to handle insufficient credit balance in case for sending to non-iv users//
    if([resultDic objectForKey:INSUFFICIENT_CREDITS] != nil)
    {
        NSNumber *insufficientCredits=[resultDic objectForKey:INSUFFICIENT_CREDITS];
        if([insufficientCredits isEqualToNumber:@1])
        {
            [text1 resignFirstResponder];
            
            NSString *message = @"You have insufficient InstaVoice Out credits and will not be able to send messages to users not on the InstaVoice app. Please contact Help if you need more credits.";
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"InstaVoice out limit reached"                                                           message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [toast show];
            [self becomeFirstResponder];
            [UIView animateWithDuration:0.25 animations:^{
                self.chatView.contentInset = UIEdgeInsetsMake(0, 0, 45.0, 0);
                self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 45.0, 0);
                [self scrollToBottom];
            }];
            
        }
    }
    
    if([self.msgType isEqualToString:VSMS_TYPE]) {
        [self vsmsLimitWork];
    }
    
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
                //[ScreenUtility showAlert: [NSString stringWithFormat: @"You have used all your InstaVoice credits. Please contact help if you need more credits."]];
                [ScreenUtility showAlert: errorReason];
            }
            
            //- Delete the msg from current data source
            NSUInteger index = 0;
            NSMutableDictionary* reqDic = [resultDic valueForKey:REQUEST_DIC];
            NSString* sentMsgGUID = [reqDic valueForKey:MSG_GUID];
            //Jan 20, 2017
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
                    //APR, 2017
                    if(msgList.count == 1) {
                        NSNumber* nuDate = [[msgList objectAtIndex:0] valueForKey:MSG_DATE];
                        NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
                        dtDate = [self getDateWithDayMonthYear:dtDate];
                        [dicSections removeObjectForKey:dtDate];
                        [arrDatesSorted removeObject:dtDate];
                    }//
                    else {
                        [msgList removeObjectAtIndex:index];
                    }
                    [self.chatView reloadData];
                }
            }
            //
        }
        else
        {
            //- Network failure case.
            BOOL isReloadRequired = NO;
            //JAN 20, 2017
            NSArray* allDateKeys = [dicSections allKeys];
            for(NSDate* dtDate in allDateKeys) {
                NSArray* msgList = [dicSections objectForKey:dtDate];
                
                //
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
                KLog(@"AVN: Send Text Reload done.");
            }
        }
    }
}

-(void)handleSendMCError:(NSMutableDictionary*)response
{
    if(!response || ![response count]) {
        //TODO log the error
        return;
    }
    
    NSMutableDictionary* errorData = [response valueForKey:ERROR_DATA];
    
    if(!errorData || ![errorData count]) {
        //TODO log the error
    }
    
    NSInteger errorCode = [[errorData valueForKey:ERROR_CODE]intValue];
    KLog(@"Error code: %ld", (long)errorCode);
    
    switch(errorCode) {
        case 32:
            KLog(@"TODO: Display the error");
            break;
            
        default: break;
    }
}

-(void)showWithdrawnAlert
{
    /*
    UIAlertView *commonAlert = [[UIAlertView alloc]initWithTitle:@"Message Withdrawn"
                                                         message:@"Sorry, message has been withdrawn."
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"Ok", nil];
    commonAlert.tag = 189159;
    [commonAlert show];
    */
    acWithdraw = [UIAlertController alertControllerWithTitle:@"Message Withdrawn"
                                                     message:@"Sorry, message has been withdrawn"
                                              preferredStyle:(UIAlertControllerStyleAlert)];
    acWithdraw.view.tag = 189159;
    UIAlertAction* okBtn = [UIAlertAction actionWithTitle:@"Ok" style:(UIAlertActionStyleDefault) handler:nil];
    [acWithdraw addAction:okBtn];
    [self.navigationController presentViewController:acWithdraw animated:YES completion:nil];
}

-(void)processResponseFromServer:(NSMutableDictionary*)resultDic forEventType:(int)eventType
{
    KLog(@"### processResponseFromServer - START");
    
    //- TODO: Refactor this code for updating the status of the msg being sent, sent, failed.
    NSMutableArray* newMsgList = [[NSMutableArray alloc]init];
    
    BOOL reloadRequired = NO;
    if(eventType == SEND_MSG || eventType == SEND_MC || eventType == SEND_VOIP_CALL_LOG)
    {
        NSMutableDictionary* sendMsgResp = [resultDic valueForKey:RESPONSE_DATA];
        
        newMsgList = [sendMsgResp valueForKey:@"MSG_LIST_FROM_SERVER"];
        if(newMsgList.count) {
            if(!newMsgList[0])
                return;
        }
        
        NSMutableDictionary* reqstDic = [sendMsgResp valueForKey:@"MSG_SENT_BY_USER"];
        NSString* msgGuid = [reqstDic valueForKey:MSG_GUID];
        //Jan 18, 2017
        NSNumber* nuDate = [reqstDic valueForKey:MSG_DATE];
        NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
        [self getDateWithDayMonthYear:dtDate];
        NSMutableArray* msgList = [dicSections objectForKey:dtDate];
        //
        
        //Find sent msg in conversation list and new msg list from server based on guid.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.MSG_GUID == %@", msgGuid];
        NSArray* sentMsgFromClient = [msgList filteredArrayUsingPredicate:predicate];
        NSArray* sentMsgFromServer = [newMsgList filteredArrayUsingPredicate:predicate];
        
        BOOL doReturn = YES;
        if(sentMsgFromClient.count > 0 && sentMsgFromServer.count > 0)
        {
            //NOV 2017 reloadRequired = YES;
            //user has not changed the tile. Filter the message from conversation list.
            //sentMsgFromClient may contain duplicate objects.
            
            for(NSDictionary* dic in sentMsgFromClient) {
                NSString* mState = [sentMsgFromServer[0] valueForKey:MSG_STATE];
                NSString* mID = [sentMsgFromServer[0] valueForKey:MSG_ID];
                NSString* mRC = [sentMsgFromServer[0] valueForKey:MSG_READ_CNT];
                NSString* remIVID = [sentMsgFromServer[0] valueForKey:REMOTE_USER_IV_ID];
                NSString* remIVName = [sentMsgFromServer[0] valueForKey:REMOTE_USER_NAME];
                NSString* remUserType = [sentMsgFromServer[0] valueForKey: REMOTE_USER_TYPE];
                NSString* nativeContactID = [sentMsgFromServer[0] valueForKey:NATIVE_CONTACT_ID];
                NSString* convType = [sentMsgFromServer[0] valueForKey:CONVERSATION_TYPE];
                if(nativeContactID.length)
                    [dic setValue:nativeContactID forKey:NATIVE_CONTACT_ID];
                [dic setValue:mState forKey:MSG_STATE];
                [dic setValue:mID forKey:MSG_ID];
                [dic setValue:mRC forKey:MSG_READ_CNT];
                [dic setValue:remIVID forKey:REMOTE_USER_IV_ID];
                [dic setValue:remIVName forKey:REMOTE_USER_NAME];
                [dic setValue:remUserType forKey:REMOTE_USER_TYPE];
                [dic setValue:convType forKey:CONVERSATION_TYPE];
            }
            
            if([self.msgType isEqualToString:VSMS_TYPE] && [[sentMsgFromServer[0] valueForKey:MSG_TYPE] isEqualToString:IV_TYPE])
            {
                //update current chat user type.
                [currentChatUserInfo setValue:[sentMsgFromServer[0] valueForKey:REMOTE_USER_IV_ID] forKey:REMOTE_USER_IV_ID];
                [currentChatUserInfo setValue:[sentMsgFromServer[0] valueForKey:REMOTE_USER_TYPE] forKey:REMOTE_USER_TYPE];
                self.msgType = IV_TYPE;
                _msgLimitExceeded = NO;
            }
            [self loadData];
        } else {
            
            if(!sentMsgFromClient.count) {
                if(newMsgList.count>0) {
                    NSString* convType = [newMsgList[0] valueForKey:CONVERSATION_TYPE];
                    NSString* msgSubType = [newMsgList[0] valueForKey:MSG_SUB_TYPE];
                    if([convType isEqualToString:GROUP_TYPE] &&
                       [msgSubType isEqualToString:GROUP_MSG_EVENT_TYPE]) {
                        doReturn = NO;
                    }
                }
                KLog(@"ERROR: sentMsgFromClient is null");
            }
            else {
                KLog(@"ERROR: sentMsgFromServer is null");
            }
        }
        
        if(doReturn)
            return;
    }
    else
    {
        newMsgList = [resultDic valueForKey:RESPONSE_DATA];
    }
    
    NSString* filterMatch = FROM_USER_ID;
    if([self.msgType isEqualToString:IV_TYPE])
    {
        filterMatch = REMOTE_USER_IV_ID;
    }
    if([[currentChatUserInfo valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE])
    {
        filterMatch = FROM_USER_ID;
    }
    
    NSString* currentUserMatchId = [currentChatUserInfo valueForKey:filterMatch];
    if(currentUserMatchId.length > 1)
    {
        for(NSMutableDictionary* msgDic in newMsgList)
        {
            NSString* msgUserMatchId = [msgDic valueForKey:filterMatch];
            bool isUserIDMatched = (msgUserMatchId.length > 1 && [msgUserMatchId isEqualToString:currentUserMatchId]);
            if(!isUserIDMatched) {
                KLog(@"User ID did not match");
                continue;
            }
            
            //check if message already exist in the list.
            NSInteger respMsgID = [[msgDic valueForKey:MSG_ID]integerValue];
            
            //Dont add, if message is voip and it is subtype is not voip_call_accepted
            NSString* msgType = [msgDic valueForKey:MSG_TYPE];
            NSString* msgSubType = [msgDic valueForKey:MSG_SUB_TYPE];
            if([msgType isEqualToString:VOIP_TYPE] && ![msgSubType isEqualToString:VOIP_CALL_ACCEPTED]) {
                continue;
            }
            //
            
            //Jan 18, 2017
            NSNumber* nuDate = [msgDic valueForKey:MSG_DATE];
            NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
            dtDate = [self getDateWithDayMonthYear:dtDate];
            NSMutableArray* msgList = [dicSections objectForKey:dtDate];
            //
            
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
                    
                    NSString* msgType = [msg valueForKey:MSG_TYPE];
                    NSString* msgFlow = [msg valueForKey:MSG_FLOW];
                    
                    if([msgContentTypeInDataSrc isEqualToString:TEXT_TYPE]) {
                        if(([msgContentInResp length] > [msgContentInDataSrc length])) {
                            [msg setValue:msgContentInResp forKey:MSG_CONTENT];
                        }
                        if([msgFlow isEqualToString:MSG_FLOW_R] && [msgType isEqualToString:MISSCALL]) {
                            NSString* nativeContactID = [msgDic valueForKey:NATIVE_CONTACT_ID];
                            if(nativeContactID.length) {
                                reloadRequired = YES;
                                [msg setValue:nativeContactID forKey:NATIVE_CONTACT_ID];
                            }
                        }
                    }
                    
                    if([msgContentTypeInDataSrc isEqualToString:AUDIO_TYPE]) {
                        if([msgType isEqualToString:VSMS_TYPE] && [msgFlow isEqualToString:MSG_FLOW_R]) {
                            NSString* nativeContactID = [msgDic valueForKey:NATIVE_CONTACT_ID];
                            if(nativeContactID.length) {
                                reloadRequired = YES;
                                [msg setValue:nativeContactID forKey:NATIVE_CONTACT_ID];
                            }
                        }
                    }
                    
                    bAddANewMsg=false;
                    break;
                }
                //NOV 2017
                else if(!msgID && respMsgID) {
                    NSString* msgFlow = [msgDic valueForKey:MSG_FLOW];
                    NSString* msgGUID = [msgDic valueForKey:MSG_GUID];
                    
                    if([msgFlow isEqualToString:MSG_FLOW_S] && [msgGUID isEqualToString:[msg valueForKey:MSG_GUID]]) {
                        
                        NSString* remoteUserType = [msgDic valueForKey:REMOTE_USER_TYPE];
                        NSString* msgDate = [msgDic valueForKey:MSG_DATE];
                        NSString* remoteIvUserID = [msgDic valueForKey:REMOTE_USER_IV_ID];
                        NSString* remoteUserName = [msgDic valueForKey:REMOTE_USER_NAME];
                        
                        [msg setValue:remoteUserType forKey:REMOTE_USER_TYPE];
                        [msg setValue:msgDate forKey:MSG_DATE];
                        [msg setValue:API_DELIVERED forKey:MSG_STATE];
                        [msg setValue:remoteIvUserID forKey:REMOTE_USER_IV_ID];
                        [msg setValue:remoteUserName forKey:REMOTE_USER_NAME];
                        
                        bAddANewMsg = FALSE;
                        reloadRequired = YES;
                    }
                }
            }
            if(bAddANewMsg) {
                recvdNewMsg = YES;
                NSString* msgFlow = [msgDic valueForKey:MSG_FLOW];
                
                NSMutableArray* newMsg = [[NSMutableArray alloc]init];
                [newMsg addObject:msgDic];
                [self prepareDataSourceFromMessages:newMsg withInsertion:NO MsgType:eNewMessage];
                
                //NOV 2017
                if([msgFlow isEqualToString:MSG_FLOW_R] && !isScrolling) {
                    [self loadData];
                    [self scrollToBottom];
                } else {
                    reloadRequired = YES;
                }
                //
            }
        }
        if(reloadRequired)
        {
            [self loadData];
            
        } else {
            KLog(@"ERROR: reloadRequired is false");
        }
    }
    else {
        KLog(@"ERROR: currentUserMatchId is null");
        if(reloadRequired)
            [self loadData];
    }
    
    KLog(@"### processResponseFromServer - END");
}

-(int)handleDownloadVoiceMsg:(NSMutableDictionary*)respDic
{
    ConversationTableCell *cell = [self.chatView cellForRowAtIndexPath:indexForAudioPlayed];//TEST Jan 19
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
    
    NSString* contenType = [self.voiceDic valueForKey:MSG_CONTENT_TYPE];
    if([contenType isEqualToString:TEXT_TYPE]) {
        EnLogd(@"Voice msg was withdrawn. So, do not play it.");
        //Voice msg has been withdrawn before completion of download
        return -5;
    }
    
    NSString* curChatUserId = [currentChatUserInfo valueForKey:FROM_USER_ID];
    NSString* userIdFromRespDic = [respDic valueForKey:FROM_USER_ID];
    
    if([[respDic valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE]) {
        //For celebrity type, the FROM_USER_ID of respDic from conversation object will be IV User ID
        //so, get the IV user ID from REMOTE_USER_ID of currentChatUserInfo and check if they are equal
        NSString* curChatIvUserID = [currentChatUserInfo valueForKey:REMOTE_USER_IV_ID];
        NSString* ivUserIdFromRespDic = [respDic valueForKey:REMOTE_USER_IV_ID];
        if(curChatIvUserID && ![curChatIvUserID isEqualToString:ivUserIdFromRespDic]) {
            EnLogd(@"Not the cur user of cl type. Do nothing. return.");
            return -3;
        }
    }
    else
    if(curChatUserId && (userIdFromRespDic && [userIdFromRespDic length]) &&
       ![curChatUserId isEqualToString:userIdFromRespDic]) {
        EnLogd(@"Not cur chat user. Do nothing, just return. curChatUserId = %@, userIdFromRespDic=%@",
               curChatUserId,
               userIdFromRespDic);
        return -3;
    }
    
    
    NSString *curMsgGuid = [self.voiceDic valueForKey:MSG_GUID];
    NSString *cellMsgGuid = [cell.dic valueForKey:MSG_GUID];
    NSString* respMsgGuid = [respDic valueForKey:MSG_GUID];
    NSString* respMsgState  = [respDic valueForKey:MSG_STATE];
    NSString* respMsgLocalPath = [respDic valueForKey:MSG_LOCAL_PATH];
    int retVal = 0;
    BOOL isMsgMatched = FALSE;
    
    if(cellMsgGuid && curMsgGuid && ![cellMsgGuid isEqualToString:curMsgGuid]) {
        KLog(@"Msg could have been deleted. Return.");
        return -6;
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
        
        //Jan 20, 2017
        NSNumber* nuDate = [respDic valueForKey:MSG_DATE];
        if(!nuDate) {
            KLog(@"Debug");
        }
        NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
        dtDate = [self getDateWithDayMonthYear:dtDate];
        NSMutableArray* msgList = [dicSections objectForKey:dtDate];
        //
        
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
        
        //Jan 20, 2017
        NSNumber* nuDate = [respDic valueForKey:MSG_DATE];
        if(!nuDate) {
            KLog(@"Debug");
        }
        NSDate* dtDate = [self getDateFromMilliSeconds:nuDate];
        dtDate = [self getDateWithDayMonthYear:dtDate];
        NSMutableArray* msgList = [dicSections objectForKey:dtDate];
        //
        
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
        EnLogd(@"msg GUID/ID does not match. May cause crash. FIXME.");
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
        
        
        int msgReadStatus = [[self.voiceDic valueForKey:MSG_READ_CNT]intValue];
        
        if( (MessageReadStatusSeen == msgReadStatus || MessageReadStatusUnread == msgReadStatus) &&
           [[self.voiceDic valueForKey:MSG_FLOW]isEqualToString:MSG_FLOW_R] )
        {
            NSArray *msgId = [[NSArray alloc]initWithObjects:[self.voiceDic valueForKey:MSG_ID], nil];
            
            //Jan 29, 2017 NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:self.voiceDic];
            //JAN 29, 2017 [dic setValue:[self.voiceDic valueForKey:MSG_TYPE] forKey:MSG_TYPE];
            [dic setValue:msgId forKey:API_MSG_IDS];
            
            [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeReadMessage withData:dic];
        }
        
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
            
            [self performSelectorOnMainThread:@selector(callPlayVoiceMsg) withObject:nil waitUntilDone:NO];
        }
    }
    [self.chatView beginUpdates];
    [self.chatView reloadRowsAtIndexPaths:[self.chatView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    [self.chatView endUpdates];
    
    return retVal;
}

-(void)callPlayVoiceMsg {
    drawStripTimer = [NSTimer scheduledTimerWithTimeInterval:audioPlayUpdateInterval target:self
                                                    selector:@selector(playVoiceMsg:)
                                                    userInfo:self.voiceDic repeats:YES];
}


#ifndef REACHME_APP
-(void)ringAlertView {
    
    if(!recordingView.hidden) {
        return;
    }
    
    if( ![self canPlaceRingMC]) {
        return;
    }
    
    [text1 resignFirstResponder];
    UIAlertController * iOS8RingAlert=   [UIAlertController
                                          alertControllerWithTitle:[NSString stringWithFormat:@"Do you want to place a Ring Missed Call to %@?",_ringAlertNameString] message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    iOS8RingAlert.view.tag = ringAlertControllerTag;
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self ringIconTapped];
                             [iOS8RingAlert dismissViewControllerAnimated:YES completion:nil];
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [self becomeFirstResponder];
                                 [iOS8RingAlert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [iOS8RingAlert addAction:ok];
    [iOS8RingAlert addAction:cancel];
    [self presentViewController:iOS8RingAlert animated:YES completion:nil];
    [iOS8RingAlert.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
}
#endif


#pragma mark -- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
//    if (alertView.tag == 189197){
//        [self becomeFirstResponder];
//        if (buttonIndex == [alertView cancelButtonIndex])
//        {
//            [UIView animateWithDuration:0.25 animations:^{
//                self.chatView.contentInset = UIEdgeInsetsMake(0, 0, 45.0, 0);
//                self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 45.0, 0);
//                [self scrollToBottom];
//            }];
//        }
//        
//    }
}

/* TODO --  check whether we really need this function
-(void)playLatestVoiceMsg
{
    if(voiceMsgDic != nil)
    {
        voiceMsgFlag = TRUE;
        self.voiceDic = voiceMsgDic;
        NSUInteger index = [conversationList indexOfObject:voiceMsgDic];
        NSIndexPath *indexpath= [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell *cell = [self.chatView cellForRowAtIndexPath:indexpath];
        if(cell != nil)
        {
            NSArray *cellSubViews = [cell.contentView subviews];
            voiceCellView = [self getVoiceCellView:cellSubViews];
        }
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc]initWithDictionary:voiceMsgDic];
        [appDelegate.engObj downloadVoiceMsg:newDic];
    }
}
*/

-(void)vsmsLimitWork
{
    int vsmsCreditLimit = [[ConfigurationReader sharedConfgReaderObj]getVsmsLimit];
    EnLogd(@"VSMS credit: %ld",vsmsCreditLimit);
    
    if(vsmsCreditLimit>0) {
        _msgLimitExceeded = NO;
    }
    else {
        if([[currentChatUserInfo valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE]) {
            _msgLimitExceeded = NO;
        }
        else {
            if([VSMS_TYPE isEqualToString:self.msgType])
                _msgLimitExceeded = YES;
        }
    }
}


-(void)ringIconTapped
{
    [self becomeFirstResponder];
    KLog(@"ring icon tapped.");
    
    NSMutableDictionary* conversationDic=[[NSMutableDictionary alloc]init];
    long long currentTime = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    NSNumber *date = [NSNumber numberWithLongLong:currentTime];
    
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
    
    [conversationDic setValue:MISSCALL forKey:MSG_TYPE];
    [conversationDic setValue:RING_MC forKey:MSG_SUB_TYPE];
    
    if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE)
        [conversationDic setValue:API_NETUNAVAILABLE forKey:MSG_STATE];
    else
        [conversationDic setValue:API_INPROGRESS forKey:MSG_STATE];
    [conversationDic setValue:RING_MC_REQUESTED forKey:MSG_CONTENT];
    
    [conversationDic setValue:[Common getGuid] forKey:MSG_GUID];
    [conversationDic setValue:[currentChatUserInfo valueForKey:FROM_USER_ID] forKey:FROM_USER_ID];
    [conversationDic setValue:[appDelegate.confgReader getLoginId] forKey:LOGGEDIN_USER_ID];
    
    NSArray* msgList = [[NSArray alloc]initWithObjects:conversationDic, nil];
    [self prepareDataSourceFromMessages:msgList withInsertion:NO MsgType:eNewMessage];
    
    [appDelegate.engObj sendRingMissedCall:conversationDic];
    [self loadData];
    
    [UIView animateWithDuration:0.15 animations:^{
        self.chatView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 14.0 + text1.frame.size.height, 0.0);
        self.chatView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, text1.frame.size.height + 14.0, 0.0);
        [self scrollToBottom];
    }];
    
}

-(BOOL)canPlaceRingMC
{
    //- If Ring MC is already in "INPROGRESS" state, don't allow another missed call.
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"MSG_TYPE = \"mc\" AND MSG_SUB_TYPE = \"ring\" AND MSG_STATE=\"INPROGRESS\""];
    
    NSArray* sendingRingMsg = nil;
    NSArray* arrAllKeys = [dicSections allKeys];
    for(NSDate* dtDate in arrAllKeys) {
        NSArray* msgList = [dicSections objectForKey:dtDate];
        sendingRingMsg = [msgList filteredArrayUsingPredicate:predicate];
        if([sendingRingMsg count]) break;
    }
    //Jan 19, 2017
    if([sendingRingMsg count]) {
        [ScreenUtility showAlert:@"Ring Missed Call Already Requested"];
        KLog(@"Can't place a RING");
        EnLogd(@"Can't place a RING");
        return NO;
    }
    //
    
    //- Get current epoch time
    long long currentTime = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    
    //- Get all the missed calls in RING_MC_REQUESTED state
    predicate = [NSPredicate predicateWithFormat:@"MSG_TYPE = \"mc\" AND MSG_SUB_TYPE = \"ring\" AND MSG_CONTENT=%@",RING_MC_REQUESTED];
    NSArray* requestedRingMsg = nil;
    
    //Jan 19, 2017
    arrAllKeys = [dicSections allKeys];
    for(NSDate* dtDate in arrAllKeys) {
        NSArray* msgList = [dicSections objectForKey:dtDate];
        requestedRingMsg = [msgList filteredArrayUsingPredicate:predicate];
        if([requestedRingMsg count]) break;
    }
    //
    
    NSInteger ringMcInRequestedState = [requestedRingMsg count];
    if(ringMcInRequestedState > 1) {
        KLog(@"*** No. of RING_MC msg in requested state: %ld",(long)ringMcInRequestedState);
        EnLogd(@"*** No. of RING_MC msg in requested state: %ld",ringMcInRequestedState);
    }
    
    NSMutableDictionary* dic=nil;
    long long lastRingRequestedTime = 0;
    if(ringMcInRequestedState>0)
    {
        dic = [requestedRingMsg objectAtIndex:(ringMcInRequestedState - 1)];
        lastRingRequestedTime = [[dic valueForKey:MSG_DATE]longLongValue]; //time (in ms) at which Ring MC requested
        
        long long expiryTimeConfigured = [[ConfigurationReader sharedConfgReaderObj]getRingExpiryTime]*60000;
        if(expiryTimeConfigured <= 0)
            expiryTimeConfigured = 15*60000;
        
        if((lastRingRequestedTime+expiryTimeConfigured) >= currentTime) {
            [ScreenUtility showAlert:@"Ring Missed Call Already Requested"];
            EnLogd(@"Can't place a RING");
            return NO;
        } else {
            EnLogd(@"Time to receive resp for the sent ring expired.");
            KLog(@"Time to receive resp for the sent ring expired.");
            /* No response from the server, within the allowed expiry time, since the last ring requested.
               So allow to send a ring mc. */
        }
    }
    
    return YES;
}

//
// Show group info
- (void) labelToShowView
{
    KLog(@"labelToShowView");
    appDelegate.tabBarController.tabBar.hidden = YES;
    // if we are currently recording, don't show this screen
    if(!recordingView.hidden) {
		return;
	}

    // close the keybaord
    [text1 resignFirstResponder];

    // set up the background view to display. This is the black view that fades in
    if (viewToShowBackgroundAsTransparent == nil) {
        viewToShowBackgroundAsTransparent = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        viewToShowBackgroundAsTransparent.backgroundColor = [UIColor blackColor];
        viewToShowBackgroundAsTransparent.alpha = 0;
    } else {
        viewToShowBackgroundAsTransparent.hidden = NO;
    }

    // add a tap and swipe gesture recognizer to this screen, that way if the user taps in the black area, the screen disappears
    UIGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] init];
    [viewToShowBackgroundAsTransparent addGestureRecognizer:tapToDismiss];
    UISwipeGestureRecognizer *swipeToDismiss = [[UISwipeGestureRecognizer alloc] init];
    swipeToDismiss.direction = UISwipeGestureRecognizerDirectionRight;
    [viewToShowBackgroundAsTransparent addGestureRecognizer:swipeToDismiss];

    // check if the chat is a group chat or not
    NSString *fromGroupValue = [currentChatUserInfo valueForKey:@"CONVERSATION_TYPE"];

    // if it is show the group chat screen
    if ([fromGroupValue isEqualToString:@"g"]) {
#ifndef REACHME_APP
        // if this view hasn't been created before, create it - otherwise just unhide the current view that is htere
        if(viewForGroupChatMembers == nil) {
            NSString* fromUserId = [currentChatUserInfo valueForKey:FROM_USER_ID];
            NSArray* supportContacts = [Setting sharedSetting].supportContactList;

            // if the user is the current user, don't show the screen
            for(NSDictionary* dic in supportContacts) {
                NSString* number = [dic valueForKey:SUPPORT_DATA_VALUE];
                if([number isEqualToString:fromUserId])
					return;
            }
			// instantiate the view
            viewForGroupChatMembers = [[ViewForGroupChatContactScreen alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.navigationController.view.frame.size.width * .8, self.navigationController.view.frame.size.height) withPhoneNumber:fromUserId];
            
			// only do the loading part of the screen when the view is first being instantiated
            [viewForGroupChatMembers initializeVariable];
            
            // set up the title for the screen
            NSString *userName = [currentChatUserInfo valueForKey:REMOTE_USER_NAME];
            viewForGroupChatMembers.titleLabelText = userName;
            viewForGroupChatMembers.groupImage = [ScreenUtility getPicImage:[currentChatUserInfo valueForKey:REMOTE_USER_PIC]];

            // set up a swipe gesture recognizer to be able to dismiss the view
            UISwipeGestureRecognizer *swipeToDismiss = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideViewGroupChat:)];
            swipeToDismiss.direction = UISwipeGestureRecognizerDirectionRight;
            [viewForGroupChatMembers addGestureRecognizer:swipeToDismiss];

            // set up the cancel button and edit/leave button
            viewForGroupChatMembers.cancelButton.target = self;
            viewForGroupChatMembers.cancelButton.action = @selector(hideViewGroupChat:);
            viewForGroupChatMembers.editLeaveButton.target = self;
            viewForGroupChatMembers.editLeaveButton.action = @selector(editOrLeave:);

            // set the delegate
            [viewForGroupChatMembers setDelegate:self];
        }
        else {
            // unhide the view
            viewForGroupChatMembers.hidden = NO;
            NSString* fromUserId = [currentChatUserInfo valueForKey:FROM_USER_ID];
            [viewForGroupChatMembers fetchGroupInfo:fromUserId];
            NSString *userName = [currentChatUserInfo valueForKey:REMOTE_USER_NAME];
            viewForGroupChatMembers.titleLabelText = userName;
        }

        // load the table
        [viewForGroupChatMembers forReloadingOfTable];

        // enable tap to dismiss in the background view
        [tapToDismiss addTarget:self action:@selector(hideViewGroupChat:)];
        [swipeToDismiss addTarget:self action:@selector(hideViewGroupChat:)];
        
        // display the view on screen
        // the view is displayed on the navigation controller's view because we want the screne to come above the navigation controller's top bar.
        [viewForGroupChatMembers setUserInteractionEnabled:YES];
        
        [self.navigationController.view addSubview:viewToShowBackgroundAsTransparent];
        [self.navigationController.view addSubview:viewForGroupChatMembers];
        [UIView animateWithDuration:.25 animations:^{
            viewForGroupChatMembers.frame = CGRectMake(self.navigationController.view.frame.size.width * .2, 0, self.navigationController.view.frame.size.width * .8, self.navigationController.view.frame.size.height);
            viewToShowBackgroundAsTransparent.alpha = .5;
        } completion:^(BOOL finished) {
            if (finished) {
                self.navigationItem.backBarButtonItem.enabled = NO;
                self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            }
        }];
#endif
    }
	//
    // in this case, the individual chat info screen is shown
    else {
        if(viewAfterTap == nil) {
            //Don't display view-profile for Help and Suggestions
            NSString* fromUserId = [currentChatUserInfo valueForKey:FROM_USER_ID];
            NSArray* supportContacts = [Setting sharedSetting].supportContactList;
            for(NSDictionary* dic in supportContacts) {
                NSString* number = [dic valueForKey:SUPPORT_DATA_VALUE];
                if([number isEqualToString:fromUserId])
                    return;
            }

            // set up the phone number string ofr the new frame
            NSString *phoneNumber = [[currentChatUserInfo valueForKey:REMOTE_USER_TYPE] isEqualToString:CELEBRITY_TYPE] ? CELEBRITY_TYPE : fromUserId;
            //TODO:FIXME sometime phoneNumber will be nil. CHECK it.
            
            viewAfterTap = [[ViewForContactScreen alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.navigationController.view.frame.size.width * .8, self.navigationController.view.frame.size.height)
                                                       withPhoneNumber:phoneNumber];

        } else {
            viewAfterTap.hidden = NO;
        }
        
        // set up the top bar of the view
        NSString *userName = [currentChatUserInfo valueForKey:REMOTE_USER_NAME];
        if(!userName || !userName.length)
            userName = [currentChatUserInfo valueForKey:FROM_USER_ID];
        
        NSString *name = [Common setPlusPrefixChatWithMobile:userName];

        // is the name isn't nil set up the screen with the phone number - otherwise use the user's username
        if (name != nil) {
            // set up the user's phone number
            NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
            NSNumber *countryIsdCode = [phoneUtil extractCountryCode:([Common addPlus:name]) nationalNumber:nil];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSString *countryIsdCodeString = [formatter stringFromNumber:countryIsdCode];
            NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCodeString];
            NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:countrySimIso];
            viewAfterTap.nameLabel.text = [f inputString:[Common addPlus:name]];
        } else {
            viewAfterTap.nameLabel.text = userName;
        }
        NSArray* arr = [[Contacts sharedContact]getContactForPhoneNumber:[currentChatUserInfo valueForKey:FROM_USER_ID]];
        ContactDetailData* detail = Nil;
        if([arr count]>0)
            detail = [arr objectAtIndex:0];
        if (detail) {
            ContactData *data = detail.contactIdParentRelation;
            NSString *imageURLString = [IVFileLocator getNativeContactPicPath:data.contactPic];
            UIImage *profilePicture = [ScreenUtility getPicImage:imageURLString];
            if (profilePicture) {
                viewAfterTap.profilePicture=profilePicture;
            }
            else if(data.contactPicURI) {
                [[Contacts sharedContact]downloadAndSavePicWithURL:data.contactPicURI picPath:imageURLString];
            }
        }

        // set the picture to display on the top of the info screen. If this is null, the screen will automatically display a colored background with text on it.
        viewAfterTap.profilePicture = [ScreenUtility getPicImage:[currentChatUserInfo valueForKey:REMOTE_USER_PIC]];
        CGImageRef cgref = [viewAfterTap.profilePicture CGImage];
        CIImage *cim = [viewAfterTap.profilePicture CIImage];
        
        if (cim == nil && cgref == NULL)
        {
            KLog(@"no underlying data");
        }
        // set up the cancel button's target and action
        viewAfterTap.cancelButton.target = self;
        viewAfterTap.cancelButton.action = @selector(hideView:);
        
        [tapToDismiss addTarget:self action:@selector(hideView:)];
        [swipeToDismiss addTarget:self action:@selector(hideView:)];

        UISwipeGestureRecognizer *swipeRightToDismiss = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideView:)];
        swipeRightToDismiss.direction = UISwipeGestureRecognizerDirectionRight;
        [viewAfterTap addGestureRecognizer:swipeRightToDismiss];

        // reload the data for the view and set the delegate
        [viewAfterTap forReloadingOfTable];
        [viewAfterTap setDelegate:self];

        // present the view
        // The view is presented in the navigation controller's view becuase we want this view to appear above the navigation bar
        [self.navigationController.view addSubview:viewToShowBackgroundAsTransparent];
        [self.navigationController.view addSubview:viewAfterTap];
        viewAfterTap.frame = CGRectMake(self.navigationController.view.frame.size.width, 0, self.navigationController.view.frame.size.width * .8, self.navigationController.view.frame.size.height);
        [UIView animateWithDuration:.25 animations:^{
            viewToShowBackgroundAsTransparent.alpha = .5;
            viewAfterTap.frame = CGRectMake(self.navigationController.view.frame.size.width * .2, 0, self.navigationController.view.frame.size.width * .8, self.navigationController.view.frame.size.height);
            
        } completion:^(BOOL finished) {
            if (finished) {
                self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            }
        }];
    }
    
    containerView.hidden = YES;
}

- (void)hideView:(id)sender 
{
    [UIView animateWithDuration:0.15 delay:0.75 options:UIViewAnimationOptionCurveEaseIn animations:^{
        containerView.hidden = NO;
#ifdef REACHME_APP
        if ([currentChatUserInfo valueForKey:@"HELP_TEXT"] || [[currentChatUserInfo valueForKey:REMOTE_USER_NAME] isEqualToString:@"Suggestions"])
            containerView.hidden = NO;
        else
            containerView.hidden = YES;
#endif
    }completion:nil];
    
    [self hideView:sender completion:nil];
    
}

- (void)hideView:(id)sender completion:(void (^)(void))completion {
    
    viewToShowBackgroundAsTransparent.alpha = 0;
    viewAfterTap.hidden = YES;
    viewToShowBackgroundAsTransparent.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)hideGroupOrIndividualView {
    [self hideGroupOrIndividualViewCompletion:nil];
}

- (void)hideGroupOrIndividualViewCompletion:(void (^)(void))completion {
    if ([[currentChatUserInfo valueForKey:@"CONVERSATION_TYPE"] isEqualToString:@"g"]) {
        [self hideViewGroupChat:self completion:completion];
    } else {
        [self hideView:self completion:completion];
    }
}

- (void)audioModeTapped:(id)sender {
    
    if(!recordingView.hidden) {
        return;
    }
    
    if( [Audio isHeadsetPluggedIn]) {
        EnLogd(@"Headset plugged-in. No mode change.");
        KLog(@"Headset plugged-in. No mode change.");
        return;
    }
    
    if(_speakerMode) {
        // turn the speaker off
        EnLogd(@"Speaker Off");
        
        [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-closed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
        [self.enableSpeakerButton setTintColor:[IVColors grayOutlineColor]];
        
        _speakerMode = false;
        [appDelegate.confgReader setVolumeMode:CALLER_MODE];
        [self.audioObj setVolume:[appDelegate.confgReader getVolumeMode]];
    }
    else {
        //turn the speacker on
        EnLogd(@"Speaker On");
        [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-closed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
        [self.enableSpeakerButton setImage:[[UIImage imageNamed:@"speaker-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.enableSpeakerButton setTintColor:[IVColors redColor]];
        
        _speakerMode = true;
        [appDelegate.confgReader setVolumeMode:SPEAKER_MODE];
        [self.audioObj setVolume:[appDelegate.confgReader getVolumeMode]];
    }
}

- (void)editOrLeave:(id)sender
{
#ifndef REACHME_APP
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [self hideViewGroupChat:nil];
        return;
    }
    
    NSString* buttonTitle = [sender title];
    if ([buttonTitle isEqualToString:@"Edit"]) {
        [self hideViewGroupChat:nil];
        [self initNewGroupCreationForChat];
        addOrDeleteMemeber = YES;
    }
    else if([buttonTitle isEqualToString:@"Leave"]) {
        
        NSString *alertTitle = NSLocalizedString(@"Leave group?", nil);
        NSString *alertMessage = NSLocalizedString(@"You will not be able to send or receive any messages in this group", nil);
        
        UIAlertController *leaveGroup = [UIAlertController
                                         alertControllerWithTitle:alertTitle
                                         message:alertMessage
                                         preferredStyle:UIAlertControllerStyleAlert];
        leaveGroup.view.tag = groupInfoAlertViewTag;
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                                 {
                                     [leaveGroup dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [leaveGroup addAction:cancel];
        
        UIAlertAction *leave = [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    viewForGroupChatMembers.editLeaveButton.enabled = NO;
                                    viewForGroupChatMembers.editLeaveButtonClicked = YES;
                                    [self leaveGroup];
                                    [self hideViewGroupChat:nil];
                                    
                                }];
        
        [leaveGroup addAction:leave];
        
        [self presentViewController:leaveGroup animated:YES completion:nil];
        [leaveGroup.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        
    }
#endif
    
}

-(void)initNewGroupCreationForChat
{
#ifndef REACHME_APP
    CreateNewGroupViewController *vController = [[CreateNewGroupViewController alloc]initWithNibName:@"CreateNewGroupViewController" bundle:nil andGroupDetails:currentChatUserInfo];
    vController.delegate = self;

    [[UIStateMachine sharedStateMachineObj] setCurrentPresentedUI:vController];

    [self hideGroupOrIndividualViewCompletion:^{
        UINavigationController *navControllerForEditGroupController = [[UINavigationController alloc] initWithRootViewController:vController];
        [self presentViewController:navControllerForEditGroupController animated:YES completion:nil];
    }];
#endif
    
}

-(void)leaveGroup
{
    NSMutableDictionary* groupDic = [[NSMutableDictionary alloc]init];
    
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [requestDic setValue:[currentChatUserInfo valueForKey:FROM_USER_ID] forKey:@"group_id"];
    [requestDic setValue:@"u" forKey:@"group_operation"];
    [requestDic setValue:[NSNumber numberWithInt:1] forKey:@"group_type"];
    NSMutableArray* memberList = [[NSMutableArray alloc]init];
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setValue:[NSString stringWithFormat:@"%ld",[[ConfigurationReader sharedConfgReaderObj]getIVUserId]] forKey:@"contact"];
    [dic setValue:IV_TYPE forKey:@"type"];
    [dic setValue:@"l" forKey:@"operation"];
    [memberList addObject:dic];
    
    [requestDic setValue:memberList forKey:@"member_updates"];
    [groupDic setValue:requestDic forKey:@"group_server_request"];
    
    
    /*
      TODO: Why server needs two different API calls to leave from a group?
      This makes client's logic more complicated.
    */
#ifndef REACHME_APP
    GroupUtility* util = [[GroupUtility alloc]initWithData:0];
    [util sendLeaveGroupMessage];
#endif
    
}


- (void)hideViewGroupChat:(id)sender {
    
    [self hideViewGroupChat:sender completion:nil];
}

- (void)hideViewGroupChat:(id)sender completion:(void (^)(void))completion {
    
#ifndef REACHME_APP
    [UIView animateWithDuration:.25 animations:^{
        viewToShowBackgroundAsTransparent.alpha = 0;
        viewForGroupChatMembers.frame = CGRectMake(self.navigationController.view.frame.size.width, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
    } completion:^(BOOL finished) {
        viewForGroupChatMembers.hidden = YES;
        viewToShowBackgroundAsTransparent.hidden = YES;
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        containerView.hidden = NO;
        if (completion) {completion();}
    }];
#endif
    
}

-(void)dismissedTheViewController:(id)sender withIdentity:(NSString *)str
{
    [self hideView:nil];
    if ([str isEqualToString:@"Chat"]) {
        EnLogd("Chat - user with multiple contacts");
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:self.msgType forKey:MSG_TYPE];
        NSString *textMsg = text1.text;
        if(textMsg != nil && [textMsg length]>0)
        {
            [dic setValue:textMsg forKey:MSG_CONTENT];
            [dic setValue:TEXT_TYPE forKey:MSG_CONTENT_TYPE];
            [appDelegate.engObj setLastMsgInfo:dic];
        }
        saveLastMsg = NO;
        //
        
        NSMutableDictionary *newDic = sender;
        if(newDic == nil && [newDic count] == 0)
        {
#ifndef REACHME_APP
            viewForGroupChatMembers.hidden = YES;
#endif
            [self.navigationController popViewControllerAnimated:NO];
            [appDelegate.tabBarController setSelectedIndex:4];//Notes tab
        }
        else
        {
            [appDelegate.dataMgt setCurrentChatUser:newDic];
            BaseUI* newVC = [[InsideConversationScreen alloc] initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
            UINavigationController *navController = self.navigationController;
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:navController.viewControllers];
            if([viewControllers count]) {
                [viewControllers removeLastObject];
                [viewControllers addObject:newVC];
                [[self navigationController] setViewControllers:viewControllers animated:YES];
            }
        }
    }
    else if([str isEqualToString:@"Invite"])
    {
        NSString *newDic = sender;
        [self addToInstavoiceTapped:newDic];
    }
}

-(void)dismissedTheViewControllerGroupChat:(id)sender withIdentity:(NSString *)str
{
    [self hideViewGroupChat:nil];
    if([str isEqualToString:@"Invite"])
    {
        NSString *newDic = sender;
        [self addToInstavoiceTapped:newDic];
    }
}


- (IBAction)addToInstavoiceTapped:(id)sender {
    NSString *str = (NSString*)sender;
    self.currentMobileNumber = str;
    [text1 resignFirstResponder];
    NSArray* contactDetailList = [[Contacts sharedContact]getContactForPhoneNumber:self.currentMobileNumber];
    ContactDetailData* detailDataContact = nil;
    if([contactDetailList count] > 0)
    {
        ContactDetailData* detail = [contactDetailList objectAtIndex:0];
        ContactData* data = detail.contactIdParentRelation;
        NSSet* all = data.contactIdDetailRelation;
        for(ContactDetailData* obj in all)
        {
            NSString* dataValue =  obj.contactDataValue;
            if(dataValue && [dataValue isEqualToString:self.currentMobileNumber]) {
                detailDataContact = obj;
                break;
            }
        }
        _invitedContact = detailDataContact.contactIdParentRelation;
    }
    else
    {
        contactDetailList = [[Contacts sharedContact]getCustomContactForNewPhoneNumber:self.currentMobileNumber];
        
        ContactDetailData* detailDataContact = nil;
        if([contactDetailList count] > 0)
        {
            ContactDetailData* detail = [contactDetailList objectAtIndex:0];
            ContactData* data = detail.contactIdParentRelation;
            NSSet* all = data.contactIdDetailRelation;
            for(ContactDetailData* obj in all)
            {
                NSString* dataValue =  obj.contactDataValue;
                if(dataValue && [dataValue isEqualToString:self.currentMobileNumber]) {
                    detailDataContact = obj;
                    break;
                }
            }
            _invitedContact = detailDataContact.contactIdParentRelation;
        }
    }
    containerView.hidden = YES;
    popUp = [[CustomIOS7AlertView alloc]init];
    [ContactInvitePopUPAction setParentView:self];
    [ContactInvitePopUPAction createContactAlert:_invitedContact alertType:INVITE_ALERT deviceHeight:appDelegate.deviceHeight alertView:popUp];
    
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    [alertView close];
    containerView.hidden = NO;
#ifdef REACHME_APP
    if ([currentChatUserInfo valueForKey:@"HELP_TEXT"])
        containerView.hidden = NO;
    else
        containerView.hidden = YES;
#endif
}

-(void)byDefaultSelected:(ContactDetailData *)detailDic tag:(int)tag
{
    if(detailDic != nil)
    {
        NSMutableDictionary *dic = [[ NSMutableDictionary alloc]init];
        [dic setValue:detailDic.contactDataType  forKey:CONTACT_DATA_TYPE];
        [dic setValue:detailDic.contactDataValue forKey:CONTACT_DATA_VALUE];
        [dic setValue:detailDic.contactId forKey:CONTACT_ID];
        [dic setValue:[NSString stringWithFormat:@"%d",tag] forKey:INDEX];
        [inviteList addObject:dic];
    }
}

-(void)selectBtnInviteAction:(id)sender
{
    long tag = [[sender superview] tag];
    if([sender tag] == 0)
    {
        [sender setTag:1];
        [sender setImage:[UIImage imageNamed:IMG_IC_TICK_GRN_M] forState:UIControlStateNormal];
        
        ContactData* data = _invitedContact;
        NSArray *detailArray = [data.contactIdDetailRelation allObjects];
        
        ContactDetailData* detail = Nil;
        
        if([detailArray count] > tag)
        {
            detail = [detailArray objectAtIndex:tag];
        }
        
        if(detail != nil)
        {
            NSMutableDictionary *dic = [[ NSMutableDictionary alloc]init];
            [dic setValue:detail.contactDataType  forKey:CONTACT_DATA_TYPE];
            [dic setValue:detail.contactDataValue  forKey:CONTACT_DATA_VALUE];
            [dic setValue:detail.contactId forKey:CONTACT_ID];
            [dic setValue:[NSString stringWithFormat:@"%ld",tag] forKey:INDEX];
            [inviteList addObject:dic];
        }
    }
    else
    {
        [sender setTag:0];
        [sender setImage:[UIImage imageNamed:IMG_IC_TICK_GREY_M] forState:UIControlStateNormal];
        NSMutableDictionary *tempDic = nil;
        for(NSMutableDictionary *dic in inviteList)
        {
            NSString *value = [dic valueForKey:INDEX];
            if([value isEqualToString:[NSString stringWithFormat:@"%ld",tag]])
            {
                tempDic = [[NSMutableDictionary alloc]initWithDictionary:dic];
                break;
            }
        }
        if(tempDic != nil)
        {
            [inviteList removeObject:tempDic];
        }
    }
}

-(void)cancelBtnInviteAction
{
    if(inviteList != nil && [inviteList count] > 0)
    {
        [inviteList removeAllObjects];
    }
    
    popUp.tag = 0;
    popUp = nil;
    containerView.hidden = NO;
#ifdef REACHME_APP
    if ([currentChatUserInfo valueForKey:@"HELP_TEXT"])
        containerView.hidden = NO;
    else
        containerView.hidden = YES;
#endif
}

-(void)sendBtnInviteAction
{
    popUp.tag = 0;
    popUp = nil;
    
    if(inviteList == nil || [inviteList count] == 0)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"SELECT_CONTACT", nil)];
        return;
    }
    if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    BOOL isPhone = FALSE;
    if( inviteList != nil && [inviteList count] > 0)
    {
        NSMutableArray* smsInvitationList = [[NSMutableArray alloc] init];
        NSMutableArray *emailInviteList = [[NSMutableArray alloc] init];
        for(NSMutableDictionary *dic in inviteList )
        {
            NSString *contactType = [dic valueForKey:CONTACT_DATA_TYPE];
            if([contactType isEqualToString:PHONE_MODE])
            {
                [smsInvitationList addObject:[dic valueForKey:CONTACT_DATA_VALUE]];
                isPhone = TRUE;
            }
            else
            {
                [emailInviteList addObject:dic];
            }
        }
        
        if([smsInvitationList count] > 0)
        {
            NSMutableDictionary *dic = [Common getSIMInfo];
            if(dic != nil && [dic count] >0)
            {
                [self sendSMSInvitation:smsInvitationList];
            }
            else
            {
                [ScreenUtility showAlert:NSLocalizedString(@"SIM_NOT_AVAILABLE", nil)];
            }
        }
    }
    if(!isPhone )
    {
        popUp = nil;
    }
    
    containerView.hidden = NO;
#ifdef REACHME_APP
    if ([currentChatUserInfo valueForKey:@"HELP_TEXT"])
        containerView.hidden = NO;
    else
        containerView.hidden = YES;
#endif
}

-(BOOL) sendSMSInvitation:(NSMutableArray*)smsInvitationList
{
    if(![MFMessageComposeViewController canSendText])
    {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"SMS_NOT_SUPPORTED", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [warningAlert show];
        return NO;
    }
    
    NSArray *recipents = [NSArray arrayWithArray:smsInvitationList];
    NSString *message = NSLocalizedString(@"SMS_MESSAGE_PHONE", nil);
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    [self presentViewController:messageController animated:YES completion:nil];
    
    return YES;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
        {
            EnLoge(@"Cancelled");
        }
            break;
        case MessageComposeResultFailed:
        {
            [ScreenUtility showAlert:NSLocalizedString(@"INVITATION_FAIL", nil)];
        }
            break;
        case MessageComposeResultSent:
        {
            [ScreenUtility showAlert:NSLocalizedString(@"INVITATION_SENT", nil)];
            NSMutableArray* smsInviteList = [[NSMutableArray alloc]init];
            for(NSMutableDictionary *dic in inviteList )
            {
                if([[dic valueForKey:CONTACT_DATA_TYPE] isEqualToString:PHONE_MODE])
                {
                    [smsInviteList addObject:dic];
                }
            }
            [inviteList removeAllObjects];
            [self updateInviteStatusInDB:smsInviteList];
        }
            break;
        default:
            break;
    }
    popUp = nil;
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateInviteStatusInDB:(NSMutableArray*)contactList
{
    _invitedContact.isInvited = [NSNumber numberWithBool:YES];
    NSError* error = Nil;
    self.managedObjectContext = [AppDelegate sharedMainQueueContext];
    
    if (![_managedObjectContext save:&error]) {
        KLog(@"CoreData: Failed to invite %@", contactList);
    }
}

-(void)markReadMessagesFromThisList:(NSArray *)list
{
    //Do not send Read-recipt when app is in background with the chat screen vc at top.
    if([[UIApplication sharedApplication]applicationState] != UIApplicationStateBackground) {
        //Jan 20, 2017
        KLog(@"markReadMessagesFromThisList: START");
        NSArray* allDateKeys = [dicSections allKeys];
        for(NSDate* dtDate in allDateKeys) {
            NSArray* msgList = [dicSections objectForKey:dtDate];
            [self markReadMessagesFromThisList:msgList withMsgReadStatus:MessageReadStatusRead];
            [self markReadMessagesFromThisList:msgList withMsgReadStatus:MessageReadStatusSeen];
        }
        KLog(@"markReadMessagesFromThisList: END");
        //
    }
}

-(void)markReadMessagesFromThisList:(NSArray *)list withMsgReadStatus:(MessageReadStatus)readStatus
{
    //KLog(@"markReadMessagesFromThisList = %@",list);
    NSArray *unreadMessages = nil;
    NSPredicate *predicate = nil;
    ChatActivityType activityType = ChatActivityTypeReadMessage;
    if(MessageReadStatusRead==readStatus) {
        predicate = [NSPredicate predicateWithFormat:@"!(MSG_CONTENT_TYPE LIKE %@) && (MSG_FLOW LIKE %@) && (MSG_READ_CNT <= 0)",@"a",@"r"];
    } else {//MessageReadStatusSeen
        predicate = [NSPredicate predicateWithFormat:@"(MSG_CONTENT_TYPE LIKE %@) && (MSG_FLOW LIKE %@) && (MSG_READ_CNT == 0)",@"a",@"r"];
        activityType = ChatActivityTypeSeenMessage;
    }
    
    unreadMessages = [list filteredArrayUsingPredicate:predicate];
    
    NSMutableArray* list1=[[NSMutableArray alloc]init];
    NSArray* unreadMessages1=nil;
    for(NSDictionary* dic in list) {
        NSArray* msgList =  [dic valueForKey:MSG_LIST];
        if([msgList count]) {
            [list1 addObjectsFromArray:msgList];
        }
    }
    if([list1 count]) {
        unreadMessages1 = [list1 filteredArrayUsingPredicate:predicate];
    }
    
    NSMutableArray* unreadMessageList = [[NSMutableArray alloc]init]; //May contain duplicates
    if([unreadMessages count])
        [unreadMessageList addObjectsFromArray:unreadMessages];
    
    if([unreadMessages1 count])
        [unreadMessageList addObjectsFromArray:unreadMessages1];
    
    
    NSMutableArray *msgIdsOfUnreadMsgs = [[NSMutableArray alloc]init];
    NSMutableArray *msgIdsOfUnreadMsgsForCeleb = [[NSMutableArray alloc]init];
    for (NSDictionary *temp in unreadMessageList) {
        //[temp setValue:[NSNumber numberWithInt:readStatus] forKey:MSG_READ_CNT];
        
        if([[temp valueForKey:MSG_TYPE]isEqualToString:CELEBRITY_TYPE])
        {
            [msgIdsOfUnreadMsgsForCeleb addObject:[temp valueForKey:MSG_ID]];
        }
        else
        {
            [msgIdsOfUnreadMsgs addObject:[temp valueForKey:MSG_ID]];
            
        }
    }
    
    if(msgIdsOfUnreadMsgs.count>0)
    {
        KLog(@"Read messages: %@",msgIdsOfUnreadMsgs);
        EnLogd(@"Read messages: %@",msgIdsOfUnreadMsgs);
        
        NSArray* uniqueMsgIdsOfUnreadMsgs = [[NSSet setWithArray: msgIdsOfUnreadMsgs] allObjects];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setValue:IV_TYPE forKey:MSG_TYPE];
        [dic setValue:uniqueMsgIdsOfUnreadMsgs forKey:API_MSG_IDS];
        
        [[ChatActivity sharedChatActivity]addActivityOfType:activityType withData:dic];
    }
    if(msgIdsOfUnreadMsgsForCeleb.count>0)
    {
        KLog(@"Read messages: %@",msgIdsOfUnreadMsgsForCeleb);
        EnLogd(@"Read messages: %@",msgIdsOfUnreadMsgsForCeleb);
        
        NSArray* uniqueMsgIdsOfUnreadMsgsForCeleb = [[NSSet setWithArray: msgIdsOfUnreadMsgsForCeleb] allObjects];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setValue:CELEBRITY_TYPE forKey:MSG_TYPE];
        [dic setValue:uniqueMsgIdsOfUnreadMsgsForCeleb forKey:API_MSG_IDS];
        
        [[ChatActivity sharedChatActivity]addActivityOfType:activityType withData:dic];
    }
}

#pragma mark - IVMediaLoaderDelegate
-(void)ivMediaLoaderDidFinishDownloadingImageData:(IVImageData *)imageData
{
    //APR, 2017 [self.chatView reloadData];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self.chatView reloadData];
    }];
    [self markReadMessagesFromThisList:nil];
}

-(void)removeOverlayViewsIfAnyOnPushNotification
{
    [super removeOverlayViewsIfAnyOnPushNotification];
    if (!viewAfterTap.hidden)
    {
        [self hideView:nil];
    }
    
    if(acWithdraw) {
        [acWithdraw dismissViewControllerAnimated:YES completion:nil];
        acWithdraw = nil;
    }
    
    if(self.actionSheet) {
        [self.actionSheet dismissViewControllerAnimated:YES completion:nil];
    }

    [self.chatView reloadData];
    
#ifndef REACHME_APP
    if (!viewForGroupChatMembers.hidden)
    {
        [self hideViewGroupChat:nil];
    }
#endif
    
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(void)cancel
{
    [self removeOverlayViewsIfAnyOnPushNotification];
    [self.navigationController popViewControllerAnimated:NO];
    [appDelegate setChatScreenPushed:FALSE];
}

#pragma mark VOIP related
#ifdef REACHME_APP
- (void)onPresenceChanged:(NSNotification *)k {
    
    KLog(@"Notification = %@",k);
    LinphoneFriend *f = [[k.userInfo valueForKey:@"friend"] pointerValue];
    //linphone_presence_model_get_basic_status(linphone_friend_get_presence_model(_contact.friend) == LinphonePresenceBasicStatusOpen
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

-(void)dismissAlert {
    
    if(uiAlertView) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        uiAlertView = nil;
    }
}
#endif

@end
