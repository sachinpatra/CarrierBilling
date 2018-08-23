
//
//  SharingSettingsViewController.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 4/16/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "SettingsSharingMenuViewController.h"
#import "Setting.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
    #import "MyVoboloScreen.h"
    #import "MyNotesScreen.h"
    #import "ChatGridViewController.h"
#endif

#import "FriendsScreen.h"
#import "IVSettingsListViewController.h"


#define FB_ALERT        @"FB_ALERT"
#define TW_ALERT        @"TW_ALERT"


typedef NS_ENUM(NSUInteger,Sections){
    eScoialNetworksSection = 0,
    eInstaVoiceBlogsSection,
};


typedef NS_ENUM(NSUInteger,SocialNetworkSectionCells){
    eFacebookConnetCell = 0,
    eTwitterConnectCell,
};

typedef NS_ENUM(NSUInteger,InstaVoiceBlogsCells){
    eAutomaticallyPostBlogsToFacebookCell = 0,
    eAutomaticallyPostBlogsToTwitterCell
};


@interface SettingsSharingMenuViewController ()<SettingProtocol, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *sectionsArray;
@end

@implementation SettingsSharingMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _fetchSettingFromServer = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [Setting sharedSetting].delegate = self;

    //Set the sections array.
    self.sectionsArray = @[@"Social Networks",@"InstaVoice Blogs"];

    //[self updateViewConstraintsForStoryBoard];
    [self createTopViewStoryBoardWithTitle:@"Sharing Settings"];

    self.title = @"Social Sharing";

    SettingModel* model = [Setting sharedSetting].data;
    if (!model.vbEnabled) {
        [self enblVBBtnAction];
    }
    
    [self loadTableViewWithData];
    self.shareSettingsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];

    self.hidesBottomBarWhenPushed = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    appDelegate.stateMachineObj.pnClicked=0;//TODO
    if(_fetchSettingFromServer)
    {
        Setting* setting = [Setting sharedSetting];
        setting.delegate = self;
        [setting getUserSettingFromServer];
        _fetchSettingFromServer = NO;
    }
    [super viewWillAppear:animated];
    self.uiType = SHARE_SETTING;
    [appDelegate.stateMachineObj setCurrentUI:self];
    [self setEnableButton];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self closeBannerView:nil];
    [Setting sharedSetting].delegate = Nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(_btnClicked) {
        _btnClicked = FALSE;
        return;
    }
    [self UpdateTabBarController];
}

 -(void)UpdateTabBarController
 {
     
#ifndef REACHME_APP
     NSInteger pnClicked = appDelegate.stateMachineObj.pnClicked;
     if(pnClicked) {
         appDelegate.stateMachineObj.pnClicked = 0;
         return;
     }
     
     BOOL vbflag = [[Setting sharedSetting] data].vbEnabled;
     NSMutableArray* newArray = [NSMutableArray arrayWithArray:appDelegate.tabBarController.viewControllers];
     if (vbflag) {
         if(9==[newArray count]) {
             MyVoboloScreen *myVoboloScreen = [[MyVoboloScreen alloc] initWithNibName:@"BaseConversationScreen_4.0_ios7Master"
                                                                               bundle:nil];
             UINavigationController *vbNavController = [[UINavigationController alloc] initWithRootViewController:myVoboloScreen];
             [newArray insertObject: vbNavController atIndex:5];
             [appDelegate.tabBarController setViewControllers:newArray animated:NO];
             appDelegate.tabBarController.customizableViewControllers = @[];
         }
     }
     else {
         if(10==[newArray count]) {
            [newArray removeObjectAtIndex:5];
            [appDelegate.tabBarController setViewControllers:newArray animated:YES];
            [((UITabBarController *)appDelegate.window.rootViewController) setSelectedIndex:4];
         }
     }
     
     appDelegate.stateMachineObj.pnClicked=0;
#endif
     
     
 }


-(void)loadTableViewWithData
{
    objFetchSharingSettings = [[FetchSettingsSharingMenu alloc]init];
    [objFetchSharingSettings setDelegateFetchService:self];
    [objFetchSharingSettings fetchData:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)callBackFetchedData:(id)fetchedData
{
    if (fetchedData!=nil) {
        KLog(@"Fetched Data %@",fetchedData);

        self.fetchServiceResultArray = fetchedData;
    }
    [self.shareSettingsTableView reloadData];
    //reload table;
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:shouldAnimatePushPop];
}

- (NSString *)findCellIdentifierForRowAtSection:(NSIndexPath *)indexPath
{
    NSString *identifierForCell;
    switch (indexPath.section) {
        case eScoialNetworksSection:
            identifierForCell = @"sharingSettingsFBTW";
            break;
        case eInstaVoiceBlogsSection:
            identifierForCell = @"sharingSettingsVobolo";
            break;
        default:
            break;
    }
    return identifierForCell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    NSString *title;
    title = (self.sectionsArray && [self.sectionsArray count])?[self.sectionsArray objectAtIndex:section]:@"";

    return title;


}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.frame = headerFrame;

}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 3:
        case 4:
            return 1;
        default:
            return 0;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.sectionsArray && [self.sectionsArray count])?[self.sectionsArray count]:1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self findCellIdentifierForRowAtSection:indexPath]];

    switch (indexPath.section) {
        case eScoialNetworksSection: {
            ModelSettings *objSettings = [self.fetchServiceResultArray objectAtIndex:indexPath.row];
            [cell configureWithModel:objSettings];
            switch (indexPath.row) {
                case eFacebookConnetCell:
                    [cell.settingsRHSButton setButtonConnected:fbflag];
                    if (fbflag) {
                        [cell.settingsRHSButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                        [cell.settingsRHSButton setContentEdgeInsets:UIEdgeInsetsZero];
                    }
                    else {
                        [cell.settingsRHSButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
                        [cell.settingsRHSButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
                    }
                    cell.settingsRHSButton.tag = objSettings.basicTableLocalizedNumberKey;
                    [cell.settingsRHSButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case eTwitterConnectCell:
                    [cell.settingsRHSButton setButtonConnected:twflag];
                    if (twflag) {
                        [cell.settingsRHSButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                        [cell.settingsRHSButton setContentEdgeInsets:UIEdgeInsetsZero];
                    }
                    else{
                        [cell.settingsRHSButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
                        [cell.settingsRHSButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
                    }
                    cell.settingsRHSButton.tag = objSettings.basicTableLocalizedNumberKey;
                    [cell.settingsRHSButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    break;

                default:
                    break;
            }
            return cell;
        }

        case eInstaVoiceBlogsSection: {
            ModelSettings *objSettings = [self.fetchServiceResultArray objectAtIndex:indexPath.row + [tableView.dataSource tableView:tableView numberOfRowsInSection:0]];
            [cell configureWithModel:objSettings];
            switch (indexPath.row) {
                case eAutomaticallyPostBlogsToFacebookCell:
                    [cell.settingsRHSSwitch setOn:fbflag&&fbPostFlag animated:NO];
                    cell.settingsRHSSwitch.tag = objSettings.basicTableLocalizedNumberKey;
                    [cell.settingsRHSSwitch addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventValueChanged];            break;
                case eAutomaticallyPostBlogsToTwitterCell:
                    [cell.settingsRHSSwitch setOn:twflag&&twPostFlag animated:NO];
                    cell.settingsRHSSwitch.tag = objSettings.basicTableLocalizedNumberKey;
                    [cell.settingsRHSSwitch addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventValueChanged];            break;
            }
            return cell;
        }
        default:
            break;
    }

    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Start: Nivedita- Date 14th Jan - Dynamic calculation of height of a row.
    CGFloat rowHeight = 0.0;
    switch (indexPath.section) {
        case eScoialNetworksSection: {
            NSUInteger cellPadding = 15;
            ModelSettings *objSettings = [self.fetchServiceResultArray objectAtIndex:indexPath.row + [tableView.dataSource tableView:tableView numberOfRowsInSection:0]];
            CGSize textSize = CGSizeZero;
            CGSize detailsTextSize = CGSizeZero;

            textSize = [Common sizeOfViewWithText:objSettings.basicTableMainTitle withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
            detailsTextSize = [Common sizeOfViewWithText:objSettings.basicTableSubTitle withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
            rowHeight =  textSize.height + detailsTextSize.height + cellPadding + cellPadding;
            return rowHeight;
        }
        case eInstaVoiceBlogsSection:{

            switch (indexPath.row) {
                case eAutomaticallyPostBlogsToFacebookCell:
                case eAutomaticallyPostBlogsToTwitterCell:
                {
                    ModelSettings *objSettings = [self.fetchServiceResultArray objectAtIndex:indexPath.row + [tableView.dataSource tableView:tableView numberOfRowsInSection:0]];
                    CGSize textSize = CGSizeZero;
                    CGSize detailsTextSize = CGSizeZero;
                    KLog(@"main title and subtitle =%@ and %@ and %@ eInstaVoiceBlogsSection", objSettings.basicTableMainTitle, objSettings.basicTableSubTitle, objSettings.basicTableLocalizedString);

                    textSize = [Common sizeOfViewWithText:objSettings.basicTableMainTitle withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
                    detailsTextSize = [Common sizeOfViewWithText:objSettings.basicTableSubTitle withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
                    rowHeight =  textSize.height + detailsTextSize.height + 20 + 20;
                    return rowHeight;
                }
                default:
                {
                    ModelSettings *objSettings = [self.fetchServiceResultArray objectAtIndex:indexPath.row + [tableView.dataSource tableView:tableView numberOfRowsInSection:0]];
                    CGSize textSize = CGSizeZero;
                    CGSize detailsTextSize = CGSizeZero;
                    KLog(@"main title and subtitle =%@ and %@ and %@ eInstaVoiceBlogsSection", objSettings.basicTableMainTitle, objSettings.basicTableSubTitle, objSettings.basicTableLocalizedString);

                    textSize = [Common sizeOfViewWithText:objSettings.basicTableMainTitle withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
                    detailsTextSize = [Common sizeOfViewWithText:objSettings.basicTableSubTitle withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
                    rowHeight =  textSize.height + detailsTextSize.height + 15 + 15;
                    return rowHeight;

                }
            }

            break;
        }

        default:
            break;
    }


    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 54.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return NO;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

- (void)setEnableButtonReloadTableViewNoReload
{
    SettingModel* model = [Setting sharedSetting].data;
    flag = model.vbEnabled;
    fbflag = model.fbConnected;
    twflag = model.twConnected;
    twPostFlag = model.twPostEnabled;
    fbPostFlag = model.fbPostEnabled;
}

-(void)setEnableButton
{
    [self setEnableButtonReloadTableViewNoReload];
    [self.shareSettingsTableView reloadData];
}

-(void)buttonClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 50201:
            [self fbConnBtnAction];
            break;
        case 50202:
            [self twConnBtnAction];
            break;
        case 50203:
            [self autoFBPostBtnAction];
            break;
        case 50204:
            [self autoTWPostBtnAction];
            break;
        default:
            break;
    }
}

-(void)fbConnBtnAction
{
    int isNetAvailable = [Common isNetworkAvailable];
    if(isNetAvailable == NETWORK_AVAILABLE)
    {
        if(!fbflag)
        {
            _btnClicked = TRUE;
            _alertType = FB_ALERT;
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FACEBOOK_CONFIRMATION",nil) message:NSLocalizedString(@"FACEBOOK_CONFIRMATION_DES",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"DIALOG_NEGATIVE_BUTTON",nil) otherButtonTitles:NSLocalizedString(@"DIALOG_POSITIVE_BUTTON",nil), nil];
            [message show];
        }
        else
        {
            [[Setting sharedSetting]disconnectFBTwitter:@"FB"];
            fbflag = NO;
            [Setting sharedSetting].data.fbConnected = NO;
            [self setEnableButton];
        }
    }
    else
    {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}


-(void)twConnBtnAction
{
    int isNetAvailable = [Common isNetworkAvailable];
    if(isNetAvailable == NETWORK_AVAILABLE)
    {
        if(!twflag)
        {
            _btnClicked = TRUE;
            _alertType = TW_ALERT;
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TWITTER_CONFIRMATION",nil) message:NSLocalizedString(@"TWITTER_CONFIRMATION_DES",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"DIALOG_NEGATIVE_BUTTON",nil) otherButtonTitles:NSLocalizedString(@"DIALOG_POSITIVE_BUTTON",nil), nil];
            [message show];
        }
        else
        {
            [[Setting sharedSetting]disconnectFBTwitter:@"TW"];
            twflag = NO;
            [Setting sharedSetting].data.twConnected = NO;
            [self setEnableButton];
        }
    }
    else
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];

}


-(void)enblVBBtnAction
{
    //Added network check - to fix the issue - 9490- Nivedita Date: 28th Apr
    int isNetAvailable = [Common isNetworkAvailable];
    if(isNetAvailable == NETWORK_AVAILABLE) {
        flag = YES;
        [[Setting sharedSetting] updateUserSettingType:SettingTypeVoboloEnable andValue:flag];
        [self setEnableButtonReloadTableViewNoReload];
        [self.shareSettingsTableView reloadData];
    }
    else {
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        
        [self.shareSettingsTableView reloadData];

    }
}

-(void)autoFBPostBtnAction
{
    if (!fbflag) {
        [ScreenUtility showAlertMessage:NSLocalizedString(@"PLS_CONN_FB", nil)];
        //Start: Nivedita - Added following lines of code to fix the issue - 8666 - Date: Feb 4th 2016
        [self setEnableButton];
        [self.shareSettingsTableView reloadData];
        //End: Nivedita
        return;
    }

    int isNetAvailable = [Common isNetworkAvailable];
    if(isNetAvailable == NETWORK_AVAILABLE) {
        if(!fbPostFlag)
            fbPostFlag = YES;
        else
            fbPostFlag = NO;
        if(fbflag)
            [[Setting sharedSetting]updateUserSettingType:SettingTypeVoboloFBAutoPostEnable andValue:fbPostFlag];

    }
    else {
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    
    [self.shareSettingsTableView reloadData];
}

-(void)autoTWPostBtnAction
{
    if (!twflag) {
        [ScreenUtility showAlertMessage:NSLocalizedString(@"PLS_CONN_TW", nil)];
        [self setEnableButton];
        [self.shareSettingsTableView reloadData];
        return;
    }

    int isNetAvailable = [Common isNetworkAvailable];
    if (isNetAvailable == NETWORK_AVAILABLE) {
        if(!twPostFlag)
            twPostFlag = YES;
        else
            twPostFlag = NO;

        if(twflag)
            [[Setting sharedSetting]updateUserSettingType:SettingTypeVoboloTWAutoPostEnable andValue:twPostFlag];
        //[ScreenUtility showAlertMessage:@"Setting saved"];
    }
    else {
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    
    [self.shareSettingsTableView reloadData];
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
    
    self.channelsBannerView.hidden = YES;
    self.bannerBackGroundView.hidden = YES;
    statusBarView.hidden = YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([_alertType isEqualToString:FB_ALERT]){
        if (buttonIndex == 1)
        {
            _fetchSettingFromServer = YES;
            
            //We need fetch the data from the server freshly, server is maintaining the status of FB/TW connected status for a user.
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@NO forKey:kUserSettingsFetched];
            [userDefaults synchronize];
            
            FacebookWebViewScreen *fbScreen = [[FacebookWebViewScreen alloc]initWithNibName:@"BaseWebViewScreen"
                                                                                     bundle:nil andFB:YES];
            [self.navigationController pushViewController:fbScreen animated:shouldAnimatePushPop];
        }
    }else if([_alertType isEqualToString:TW_ALERT]){
        if (buttonIndex == 1) {
            _fetchSettingFromServer = YES;
            
            //We need fetch the data from the server freshly, server is maintaining the status of FB/TW connected status for a user.
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@NO forKey:kUserSettingsFetched];
            [userDefaults synchronize];
            
            FacebookWebViewScreen *fbScreen = [[FacebookWebViewScreen alloc]initWithNibName:@"BaseWebViewScreen"
                                                                                     bundle:nil andFB:NO];
            [self.navigationController pushViewController:fbScreen animated:shouldAnimatePushPop];
        }
    }
}


- (void)fetchSettingCompletedWith:(SettingModel *)modelData withFetchStatus:(BOOL)withFetchStatus {
    KLog(@"Model Data %@",modelData);
    //Either it may be pass or fail case update the UI.
    [self setEnableButton];
}

- (void)updateSettingCompletedWith:(SettingModel *)modelData withUpdateStatus:(BOOL)withUpdateStatus {
    KLog(@"Model Data %@",modelData);

    if (withUpdateStatus) {
        //[ScreenUtility showAlertMessage:@"Setting saved"];
        //Fetch again the fresh data..!!
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@NO forKey:kUserSettingsFetched];
        [userDefaults synchronize];
        [Setting sharedSetting].delegate = self;
        [[Setting sharedSetting]getUserSettingFromServer];

    }
    else {
        [ScreenUtility showAlertMessage:@"Please try again later"];
        [self setEnableButton];

    }
}


#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {

    [self.shareSettingsTableView reloadData];
}


//Clean Up Methods
- (void)dealloc {

    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];

}



@end










