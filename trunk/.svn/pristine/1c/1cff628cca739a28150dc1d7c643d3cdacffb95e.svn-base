//
//  FriendsScreen.m
//  InstaVoice
//
//  Created by EninovUser on 19/11/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "ScreenUtility.h"
#import "FriendsScreen.h"
#import "DrawCircle.h"
#import "SizeMacro.h"
#import <AddressBookUI/AddressBookUI.h>
#import "DBTables.h"
#import "ContactTableViewCell.h"
#import "ContactInvitePopUPAction.h"
#import "Contacts.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "CoreDataSetup.h"
#import "ConversationApi.h"
#import "SendFriendInviteAPI.h"
#import "IVFileLocator.h"
#import "ContactSyncUtility.h"
#import "IVDropDownView.h"
#import "FriendsInviteViewController.h"
#import "BrandingScreenViewController.h"
#import "InsideConversationScreen.h"
#import "MyNotesScreen.h"
#import "Profile.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"
#import "CreateNewSingleChatViewController.h"
#import "IVColors.h"

#import "IVInAppPromoViewController.h"
#import "ContactsApi.h"
#import "BlockedChatsViewController.h"
#import "ChatGridViewController.h"

#define TITLE_FRIENDS_SCREEN  @"Contacts"

#define PERMISSION_ALERT        0
#define CNT_ACCESS_WARNING      2

NSString *const kGroupDataUpdated = @"GroupDataUpdated";

#ifdef REACHME_APP
extern NSString* kVOIPCallReceived;
#endif

static UIAlertController *myAlertController=nil;

typedef enum:NSInteger
{
    ActionSheetTypeInvite = 1,
    ActionSheetTypeSelectContact = 2
}ActionSheetType;

@interface FriendsScreen () <MFMessageComposeViewControllerDelegate,ContactTableViewCellDelegate,NSFetchedResultsControllerDelegate,FriendInviteListProtocol,UIActionSheetDelegate, SettingProtocol>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *sharedPSC;
@property (nonatomic, strong) NSFetchRequest* fetchRequest;
@property (nonatomic, strong) NSString* sectionNameKeyPath;

@property (nonatomic, strong) NSFetchedResultsController *fetchedPBResultController;
@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation FriendsScreen

@synthesize _friendTable = friendTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        listIndex          = [NSIndexPath indexPathForItem:0 inSection:0];
        progressView.tag   = 0;
        alertType          = PERMISSION_ALERT;
        
        isSearching        = FALSE;
        inviteList         = nil;
        searchTopView      = nil;
        topView            = nil;
        txfSearchField     = nil;
        
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.uiType = FRIENDS_SCREEN;
        [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    
        self.managedObjectContext = [AppDelegate sharedMainQueueContext];
        
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:TITLE_FRIENDS_SCREEN image:[UIImage imageNamed:@"contacts"] selectedImage:[UIImage imageNamed:@"contacts-selected"]]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.uiType = FRIENDS_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    self.title = TITLE_FRIENDS_SCREEN;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addressBookEntryChanged)
                                                 name:kNewABRecordNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recievedAppBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    UINib* nib = [UINib nibWithNibName:@"ContactTableViewCellIv" bundle:nil];
    [friendTable registerNib:nib forCellReuseIdentifier:@"ContactTableViewCellIv"];
    
    UINib* nib1 = [UINib nibWithNibName:@"ContactTableViewCellNonIv" bundle:nil];
    [friendTable registerNib:nib1 forCellReuseIdentifier:@"ContactTableViewCellNonIv"];
    
    //Adding Bar Button item for invite.
    
    UIBarButtonItem* inviteButton = [[UIBarButtonItem alloc]initWithTitle:@"Invite" style:UIBarButtonItemStylePlain target:self action:@selector(stateSelected:)];
    self.navigationItem.rightBarButtonItem = inviteButton;
    
   //MAR 16, 2017 [self createSearchView];
    progressView.hidden = YES;
    
    inviteList = [[NSMutableArray alloc]init];
    
    noContactLbl.hidden = YES;
    noContactLblBackgroundView.hidden = YES;
    friendTable.hidden = YES;
    
    self.uiType = FRIENDS_SCREEN;
    // Contact Aceess Permission
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
            [self showPermissionDialog];
        }
        else
        {
            alertType = CNT_ACCESS_WARNING;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PERMISSION_DIALOG", nil) message:NSLocalizedString(@"CONTACT_ACCESS_WARNING", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
            
            [appDelegate.confgReader setContactSyncPermissionFlag:FALSE];
            [appDelegate.confgReader setContactLocalSyncFlag:TRUE];
            [appDelegate.confgReader setContactServerSyncFlag:TRUE];
            [appDelegate.confgReader setContactPermissionAlertFlag:TRUE];
            
            _fetchedResultsController = Nil;
            _fetchedPBResultController = Nil;
            
            NSError* error;
            if (![self.managedObjectContext save:&error]) {
                KLog(@"CoreData: Error %@",[error localizedDescription]);
            }
            
            NSArray* supportContact = [Setting sharedSetting].supportContactList;
            if(supportContact && [supportContact count] > 0)
                [[Contacts sharedContact]saveIVSupportContact:supportContact];
            
            KLog(@"Calling fetchMsgRequest...");
            [appDelegate.engObj fetchMsgRequest:nil];
            friendTable.scrollEnabled = YES;
            self.tabBarController.view.userInteractionEnabled = YES;
        }
    }
    else
    {
        if(![appDelegate.confgReader getContactLocalSyncFlag])
        {
            [self yesBtnAction];
        }
    }
    
    [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:TITLE_FRIENDS_SCREEN image:[UIImage imageNamed:@"contacts"] selectedImage:[UIImage imageNamed:@"contacts-selected"]]];
    
    [Setting sharedSetting].delegate = self;
    
    friendTable.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
}

-(void)recievedAppBackgroundNotification {
    //TODO
    self.fetchedResultsController = nil;
    self.fetchedPBResultController = nil;
    KLog(@"AppBackgroundNotification");
}

-(void)viewWillAppear:(BOOL)animated
{

    if(![[ConfigurationReader sharedConfgReaderObj]getContactServerSyncFlag]) {
        self.tabBarController.view.userInteractionEnabled = NO;
    }
    
    _loadAllPBContact = NO;
    self.uiType = FRIENDS_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    [super viewWillAppear:animated];
    topView.hidden = NO;
    [self.view addSubview:topView];
    txfSearchField.text = @"";
    
    if([_searchString length]) {
        isSearching = YES;
        txfSearchField.text = _searchString;
        self.searchBar.text = _searchString;
        [txfSearchField becomeFirstResponder];
        [self searchAction];
        [friendTable reloadData];
    }
    
    [self pbBtnAction];
    
    friendTable.separatorColor = [UIColor colorWithWhite:204./255 alpha:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(updateGroupData)
                                               name:kGroupDataUpdated
                                             object:nil];
#ifdef REACHME_APP
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(voipCallReceived)
                                               name:kVOIPCallReceived
                                             object:nil];
#endif
    
    self.homeTab = NO;
}

-(void)voipCallReceived {
    [self killScroll];
}

-(void)addressBookEntryChanged
{
    KLog(@"AB -- addressBookEntryChanged. reloading friend Table");
    _fetchedPBResultController = nil;
    _searchString = @"";
    isSearching = NO;
    self.searchBar.text = nil;
    
    [friendTable reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [topView removeFromSuperview];
    [searchTopView removeFromSuperview];
    [self closeActionSheet];
    if(popUp != nil) {
        [popUp close];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kGroupDataUpdated
                                                  object:nil];
#ifdef REACHME_APP
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kVOIPCallReceived
                                                  object:nil];
#endif
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:kNewABRecordNotification
                                                      object:nil];
    } @catch (NSException *exception) {
        KLog(@"Exception occurred: %@",exception);
    } @finally {
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    EnLogd(@"didReceiveMemoryWarning of conatct screen");
    // Dispose of any resources that can be recreated.
}

-(void)showProgressView:(NSInteger)tab
{
    NSInteger syncContact = [[Contacts sharedContact]syncedPBContact];
    [self showProgress:syncContact];
}


/**
 *This function shows the alert which asks permission to get the instavoice contact from the server or not.
 */

-(void)showPermissionDialog
{
    if([[ConfigurationReader sharedConfgReaderObj]getShowContactUploadDlg]) {
        KLog(@"showPermissionDialog");
        friendTable.hidden = YES;
        noContactLbl.hidden = YES;
        noContactLblBackgroundView.hidden = YES;
        alertType = PERMISSION_ALERT;
       
         //APR, 2017 if ([[UIDevice currentDevice].systemVersion floatValue] >= 9)
         {
             
             myAlertController = [UIAlertController
                                                     alertControllerWithTitle:NSLocalizedString(@"DIALOG_TITLE", nil)
                                                     message:NSLocalizedString(@"DIALOG_MESSAGE", nil)
                                                     preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction* cancelBtn = [UIAlertAction
                                         actionWithTitle:NSLocalizedString(@"DIALOG_NEGATIVE_BUTTON",nil)
                                         style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction * action)
                                         {
                                             [self noBtnAction];
                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
             
             UIAlertAction* okBtn = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"DIALOG_POSITIVE_BUTTON",nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [self yesBtnAction];
                                         [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                     }];
             
             [myAlertController addAction: cancelBtn];
             [myAlertController addAction: okBtn];
             UIViewController *rootViewController=[UIApplication sharedApplication].delegate.window.rootViewController;
             [rootViewController presentViewController:myAlertController animated:NO completion:nil];
             myAlertController.view.tintColor = [UIColor blueColor];
         }/* APR, 2017
         else {
             myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DIALOG_TITLE", nil) message:NSLocalizedString(@"DIALOG_MESSAGE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"DIALOG_NEGATIVE_BUTTON",nil) otherButtonTitles:NSLocalizedString(@"DIALOG_POSITIVE_BUTTON",nil), nil];
             [myAlertView show];
         }*/
        
        [[ConfigurationReader sharedConfgReaderObj]setShowContactUploadDlg:NO];
    }
    else {
        EnLoge(@"ShowPermissionDlg: 2nd time. Check.");
        KLog(@"ShowPermissionDlg: 2nd time. Check.");
        //APR, 2017 if ([[UIDevice currentDevice].systemVersion floatValue] >= 9)
        {
            if(myAlertController) {
               UIViewController *rootViewController=[UIApplication sharedApplication].delegate.window.rootViewController;
               [rootViewController presentViewController:myAlertController animated:NO completion:nil];
                myAlertController.view.tintColor = [UIColor blueColor];
            }
        }
        /* APR, 2016
        else {
            //[self.view bringSubviewToFront:myAlertView];
            [myAlertView show];
        }*/
    }
}

-(void)unloadData:(BOOL)event
{
    friendTable.hidden = NO;
    noContactLbl.hidden = NO;
    noContactLblBackgroundView.hidden = NO;
    noContactLbl.layer.zPosition = 2;
    
    if(!isSearching)
    {
        noContactLbl.text = NSLocalizedString(@"NO_CONTACTS", nil);
    }
    else
    {
        noContactLbl.text = NSLocalizedString(@"NO_RESULT", nil);
    }
    noContactLbl.backgroundColor = [UIColor clearColor];
}

#pragma mark - event handler


/**
 * This function is used to perform the action when click on YES button of the AlertView.
 */
-(void)yesBtnAction
{
    KLog(@"Yes button clicked");
    
    [appDelegate.confgReader setContactPermissionAlertFlag:YES];
    [appDelegate.confgReader setContactSyncPermissionFlag:TRUE];
    [appDelegate.confgReader setABChangeSynced:YES];
    
    NSError* error;
    if (![self.managedObjectContext save:&error]) {
        KLog(@"CoreData: Error %@",[error localizedDescription]);
    }
    
    NSArray* supportContact = [Setting sharedSetting].supportContactList;
    if(supportContact && [supportContact count] > 0)
        [[Contacts sharedContact]saveIVSupportContact:supportContact];
    [[Contacts sharedContact]syncContactFromNativeContact];
    friendTable.scrollEnabled = NO;
    self.tabBarController.view.userInteractionEnabled = friendTable.scrollEnabled;
}


-(void)clearThePage {
    [progressBar show:YES];
    [NSFetchedResultsController deleteCacheWithName:nil];
    self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithValue:NO];
    [self.fetchedResultsController performFetch:nil];
    self.fetchedPBResultController.fetchRequest.predicate = [NSPredicate predicateWithValue:NO];
    [self.fetchedPBResultController performFetch:nil];
    [friendTable reloadData];
    [progressBar hide:YES];
    [self unloadData:NO];
}
/**
 *This function is used to perform the action when click on NO button of AlertView.
 */

-(void)noBtnAction
{
    [appDelegate.confgReader setContactSyncPermissionFlag:FALSE];
    [appDelegate.confgReader setContactPermissionAlertFlag:TRUE];
    
    _fetchedResultsController = Nil;
    _fetchedPBResultController = Nil;
    
    NSError* error;
    if (![self.managedObjectContext save:&error]) {
        KLog(@"CoreData: Error %@",[error localizedDescription]);
    }
    
    NSArray* supportContact = [Setting sharedSetting].supportContactList;
    if(supportContact && [supportContact count] > 0)
        [[Contacts sharedContact]saveIVSupportContact:supportContact];
    
    [[Contacts sharedContact]syncContactFromNativeContact];
    
}


#pragma mark - UIAlertView's delegate

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    [alertView close];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertType == CNT_ACCESS_WARNING)
    {
        KLog(@"Calling fetchMsgRequest...");
        [appDelegate.engObj fetchMsgRequest:nil]; // to get msg when there is no permission to access contact
    }
    else
    {
        if (buttonIndex == 0)
        {
            [self noBtnAction];
        }
        else if (buttonIndex == 1)
        {
            [self yesBtnAction];
        }
    }
}

-(void)showProgress :(NSInteger)synched
{
    [self.view bringSubviewToFront:progressView];
    progressView.hidden = NO;
    progressView.tag = 1;
    NSInteger frndzCount = 0;
    BOOL localContactSync = [appDelegate.confgReader getContactLocalSyncFlag];
    if(!localContactSync) {
        frndzCount = [[appDelegate.confgReader getTotalContact]integerValue];
    } else {
        frndzCount = [[appDelegate.confgReader getTotalContactValues]integerValue];
    }
    
    KLog(@"Total = %ld, Synced = %ld", frndzCount, synched);
    
    float progress = 0.0f;
    if(frndzCount == 0)
    {
        frndzCount = synched + 1;
    }
    progress = (float)synched/ (float)frndzCount;
    progressbar.progress = progress;
    
    NSString *str=nil;
    if(frndzCount && !localContactSync) {
        str = [NSString stringWithFormat:@"Reading %ld of %ld Contacts",(long)synched,(long)frndzCount];
    }
    else {
        str = [NSString stringWithFormat:@"Syncing %ld of %ld Contacts",(long)synched,(long)frndzCount];
    }
    progressBarLbl.text = [NSString stringWithString:str];
    progressView.hidden = NO;
}

-(void)dismissProgressBar
{
    progressView.tag = 0;
    progressView.hidden = YES;
    KLog(@"dismissProgressBar");
}


#pragma mark - Search Bar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self killScroll];
    _fetchedResultsController = Nil;
    NSString *text = [NSString stringWithString:searchBar.text];
    if(text.length == 0) {
        _searchString = @"";
        isSearching = NO;
        [self setFetchRequestForSearch:Nil];
    } else {
        isSearching = YES;
        if([text hasPrefix:@"+"])
        {
            if([text length] > 1)
                text = [text substringFromIndex:1];
        }
        [self setFetchRequestForSearch:text];
        _searchString = text;
    }
    
    if([[self currentActiveResultController].fetchedObjects count]>0) {
        noContactLbl.hidden = YES;
        noContactLblBackgroundView.hidden = YES;
        friendTable.hidden = NO;
        [friendTable reloadData];
    } else {
        [self unloadData:YES];
    }
    
    [friendTable reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar
{
    KLog(@"searchBarShouldBeginEditing");
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar*)searchBar
{
    KLog(@"searchBarShouldEndEditing");
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    _searchString = @"";
    [searchBar.delegate searchBar:searchBar textDidChange:@""];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - UITextField's delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self killScroll];
    [txfSearchField resignFirstResponder];
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self killScroll];
    _fetchedResultsController = Nil;
    NSString *text = [NSString stringWithString:textField.text];
    text = [text stringByReplacingCharactersInRange:range withString:string];
    if(text.length == 0)
    {
        isSearching = NO;
        _searchString = @"";
        [self setFetchRequestForSearch:Nil];
    }
    else
    {
        isSearching = YES;
        if([text hasPrefix:@"+"])
        {
            if([text length] > 1)
                text = [text substringFromIndex:1];
        }
        [self setFetchRequestForSearch:text];
    }
    
    if([[self currentActiveResultController].fetchedObjects count]>0)
    {
        noContactLbl.hidden = YES;
        noContactLblBackgroundView.hidden = YES;
        friendTable.hidden = NO;
        [friendTable reloadData];
    }
    else
    {
        [self unloadData:YES];
    }
    
    return YES;
}

#pragma mark - table view delegate's implementation
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[[self currentActiveResultController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    
    if ([[[self currentActiveResultController] sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self currentActiveResultController] sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id dic = nil;
    NSInteger fetchedObjectsCount = [[self currentActiveResultController].fetchedObjects count];
    
    if(indexPath.row < fetchedObjectsCount) {
        dic = [[self currentActiveResultController] objectAtIndexPath:indexPath];
    } else {
        KLog(@"Debug");
    }
    
    ContactTableViewCell* cell = nil;
    ContactDetailData* contactDetailData = dic;
    if([contactDetailData.ivUserId boolValue]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCellIv" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContactTableViewCellNonIv" forIndexPath:indexPath];
    }
    
    if(cell == nil)
    {
        EnLogd(@"*** cell alloc failed ***");
        cell = [[ContactTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactTableViewCellIv"];
    }
    
    cell.delegate = self;
    cell.selectedRowIndex = indexPath;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if(nil != dic) {
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
    
    if([appDelegate.confgReader getContactLocalSyncFlag])
    {
        friendTable.scrollEnabled = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL localSyncFlag = [appDelegate.confgReader getContactLocalSyncFlag];
    if(!localSyncFlag)
    {
        [self showProgressView:0];
    }
    else
    {
        if( searchTopView.tag == 1)
        {
            [txfSearchField resignFirstResponder];
        }
        
        ContactDetailData* contactDetailData = nil;
        ContactData* selectedContact = nil;
        contactDetailData = [[self currentActiveResultController] objectAtIndexPath:indexPath];
        selectedContact = contactDetailData.contactIdParentRelation;

        if([selectedContact.contactType integerValue] == ContactTypeIVGroup)
        {
            [self moveToGroupChatScreen:selectedContact];
        }
        else
        {
            
            NSArray* arrBlockedListFromSettings = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"BLOCKED_TILES"];
            
            NSString *contactNumberID = [NSString stringWithFormat:@"%@",selectedContact.contactId];
            
            NSString *contactNumberIVUserID = [NSString stringWithFormat:@"%@",contactDetailData.ivUserId];
            
            NSString *contactNumberUserID = [NSString stringWithFormat:@"%@",contactDetailData.contactDataValue];
            
            for (NSString *contactID in arrBlockedListFromSettings) {
                if ([contactID isEqualToString:contactNumberID] || [contactID isEqualToString:contactNumberIVUserID] || [contactID isEqualToString:contactNumberUserID]) {
                    UIAlertController *blockedInfo = [UIAlertController alertControllerWithTitle:@"User blocked" message:@"Please unblock the user in Settings -> Account -> Blocked contacts." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        
                    }];
                    
                    [blockedInfo addAction:ok];
                    
                    [self presentViewController:blockedInfo animated:YES completion:nil];
                    [blockedInfo.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
                    
                    return;
                }
            }
            
            [self updateNewJoineeInfo:selectedContact];
            [self moveToConversationScreen:contactDetailData];
        }
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return Nil;
}

-(void)updateNewJoineeInfo:(ContactData*)contact
{
    if([contact.isNewJoinee boolValue])
    {
        contact.isNewJoinee = [NSNumber numberWithBool:NO];
        NSError* error = Nil;
        if(![_managedObjectContext save:&error])
        {
            KLog(@"CoreData: Save Failed");
        }
    }
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
    
    _multipleContact = [NSMutableArray arrayWithArray:sortedArray];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.contactDataType != %@",EMAIL_MODE];
    [_multipleContact filterUsingPredicate:predicate];
    
    actionSheetContactSelect = [[UIActionSheet alloc]initWithTitle:@"Select a phone number to send an InstaVoice to."
                                                          delegate:self
                                                 cancelButtonTitle:nil destructiveButtonTitle:Nil otherButtonTitles:nil];
    
    int buttonIndex = 0;
    for (ContactDetailData* detail in _multipleContact)
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
    
    [self.searchBar resignFirstResponder];
    actionSheetContactSelect.cancelButtonIndex = [actionSheetContactSelect addButtonWithTitle:@"Cancel"];
    actionSheetContactSelect.tag = ActionSheetTypeSelectContact;
    [actionSheetContactSelect showInView:self.view];
}

-(NSString*)formatPhoneNumberString:(NSString *)strNumber
{
    NSString* strResult = nil;
    NSCharacterSet *alphaSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    NSRange r = [strNumber rangeOfCharacterFromSet:alphaSet];
    if(r.location == NSNotFound) {
        
        NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
        NSNumber *countryIsdCode = [phoneUtil extractCountryCode:([Common addPlus:strNumber]) nationalNumber:nil];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSString *countryIsdCodeString = [formatter stringFromNumber:countryIsdCode];
        
        NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCodeString];
        NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:countrySimIso];
        
        strResult = [f inputString:[Common addPlus:strNumber]];
    }
    return strResult;
}

-(void)conversationBtnAction:(id) sender
{
    [popUp close];
    popUp = nil;
    ContactData* data = [[self currentActiveResultController]objectAtIndexPath:listIndex];
    
    ContactDetailData* selectedContactDetail = nil;
    if([[data.contactIdDetailRelation allObjects] count])
        selectedContactDetail = [[data.contactIdDetailRelation allObjects]objectAtIndex:0];
    
    NSInteger contactDataId = [sender tag];
    for(ContactDetailData* contactDetail in [data.contactIdDetailRelation allObjects])
    {
        if([contactDetail.contactDataType isEqualToString:PHONE_MODE] && [contactDetail.contactDataId integerValue] == contactDataId)
        {
            selectedContactDetail = contactDetail;
            break;
        }
    }
    
    [self moveToConversationScreen:selectedContactDetail];
}

-(void)moveToConversationScreen:(ContactDetailData*)contactDetail
{
    if(!contactDetail) {
        KLog(@"***ERR: contactDetial is nil");
        return;
    }
    
    NSMutableDictionary *newDic = [self setUserInfoForConversation:contactDetail];
    
    if(newDic == nil && [newDic count] == 0)
    {
        [appDelegate.tabBarController setSelectedIndex:4];
        [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[4]];
    }
    else
    {
        [appDelegate.dataMgt setCurrentChatUser:newDic];
        BaseUI* uiObj = [[InsideConversationScreen alloc] initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
        
        // set "Chats" as parent
        if(self.homeTab) {
            [appDelegate.tabBarController setSelectedIndex:2];
            [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[2]];
            [appDelegate.getNavController pushViewController:uiObj animated:YES];
        } else {
            [self.navigationController pushViewController:uiObj animated:YES];
        }
    }
    [self dismissViewControllerAnimated:NO completion:nil];
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
    
    [appDelegate.dataMgt setCurrentChatUser:dic];
    BaseUI* uiObj = [[InsideConversationScreen alloc]
                   initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    
    if(self.homeTab) {
        [appDelegate.tabBarController setSelectedIndex:2];
        [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[2]];
        [appDelegate.getNavController pushViewController:uiObj animated:YES];
    } else {
        [self.navigationController pushViewController:uiObj animated:YES];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

/**
 * Move to Notes Screen if user is current logged in user.
 */
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

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if ([[[ConfigurationReader sharedConfgReaderObj]getTotalContact]intValue] > kMaxContactLimitHack)
    {
        CGPoint offset = aScrollView.contentOffset;
        CGRect bounds = aScrollView.bounds;
        CGSize size = aScrollView.contentSize;
        UIEdgeInsets inset = aScrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        
        float reload_distance = 10;
        if(y > h + reload_distance) {
            if(!_loadAllPBContact)
            {
                _loadAllPBContact = YES;
                _fetchedPBResultController = Nil;
                [self segmentSelectionChanged:Nil];
                KLog(@"load more rows");
            }
        }
    }
}

#pragma  mark - actions associated with different button


- (IBAction)segmentSelectionChanged:(id)sender {
    [self killScroll];
    [self pbBtnAction];
}

- (void)killScroll {
    [friendTable setContentOffset:friendTable.contentOffset animated:NO];
}

-(void)pbBtnAction
{
    /* MAR 16, 2017
    if(searchTopView.tag == 1)
        [self crossBtnAction];
     */
    
    noContactLbl.hidden = YES;
    noContactLblBackgroundView.hidden = YES;
    friendTable.hidden  = NO;
    
    if(progressView.tag == 1)
    {
        [self dismissProgressBar];
    }
    if([[self currentActiveResultController].fetchedObjects count] > 0)
    {
        [friendTable reloadData];
    }
    else
    {
        [self unloadData:YES];
    }
}

/**
 *This function performs the back button action of the top view which moves to the previous screen.
 */

-(void)backAction
{
    if([appDelegate.confgReader getContactLocalSyncFlag])
    {
        [topView removeFromSuperview];
        [searchTopView removeFromSuperview];
        
        BaseUI* uiObj = [[InsideConversationScreen alloc]
                         initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
        [self.navigationController pushViewController:uiObj animated:YES];
        
    }
}

/**
 * This fucntion is used to search a contact from the contact list.
 */
-(void)searchAction
{
    [self killScroll];

    topView.hidden = YES;
    searchTopView.tag = 1;
    searchTopView.hidden = NO;
    [topView removeFromSuperview];
    [self.view addSubview:searchTopView];
    [txfSearchField becomeFirstResponder];
    [friendTable reloadData];
}


/**
 * This function is used to cancel the search.
 */
/* MAR 16, 2017
-(void)crossBtnAction
{
    [self setFetchRequestForSearch:_searchString];
    noContactLbl.hidden = YES;
    noContactLblBackgroundView.hidden = YES;
    searchTopView.tag = 0;
    searchTopView.hidden = YES;
    topView.hidden = NO;
    [searchTopView removeFromSuperview];
    [self.view addSubview:topView];
    [friendTable reloadData];
    friendTable.hidden = NO;
}*/

-(NSFetchedResultsController*)fetchedResultsController
{
    if(_fetchedResultsController != Nil && [[_fetchedResultsController fetchedObjects]count])
        return _fetchedResultsController;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath cacheName:Nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    
    @try {
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
    } @catch(NSException* ex) {
        EnLogd(@"Exception occurred:%@",ex);
    }
    
    return _fetchedResultsController;
}

-(NSFetchedResultsController*)fetchedPBResultController
{
    if(_fetchedPBResultController != Nil && [[_fetchedPBResultController fetchedObjects]count])
        return _fetchedPBResultController;
     
    [self setFetchRequestForSearch:Nil];
    
    _fetchedPBResultController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath cacheName:Nil];
    _fetchedPBResultController.delegate = self;
    
    NSError *error = nil;
    
    @try {
        if (![_fetchedPBResultController performFetch:&error]) {
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
    } @catch(NSException* ex) {
        EnLogd(@"*** Exception occurred: %@",ex);
    }
    
    return _fetchedPBResultController;
}


-(void)setFetchRequestForSearch:(NSString*)searchString
{
    _fetchRequest = [[NSFetchRequest alloc] init];
    _fetchRequest.fetchBatchSize = 0;
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
    [_fetchRequest setEntity:entityDescription];
    
    NSSortDescriptor *sortName = [[NSSortDescriptor alloc]initWithKey:@"contactIdParentRelation.contactName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSString* contactDataType = PHONE_MODE;
    _sectionNameKeyPath = Nil;
    if(isSearching && searchString != Nil && [searchString length] > 0)
    {
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"(contactDataType = %@ AND contactIdParentRelation.contactType != %@ AND ((contactIdParentRelation.contactName CONTAINS[cd] %@) OR (contactIdParentRelation.lastName CONTAINS[cd] %@) OR (contactDataValue CONTAINS[cd] %@)))",contactDataType,[NSNumber numberWithInteger:ContactTypeCelebrity],searchString,searchString,searchString];
        [_fetchRequest setPredicate:condition];
    }
    else if([[appDelegate.confgReader getTotalContact]intValue] > kMaxContactLimitHack && !_loadAllPBContact)
    {
        NSString* a = @"a";
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"(contactDataType = %@ AND contactIdParentRelation.contactType != %@ AND ((contactIdParentRelation.contactName CONTAINS[cd] %@) OR (contactIdParentRelation.lastName CONTAINS[cd] %@)))",contactDataType,[NSNumber numberWithInteger:ContactTypeCelebrity],a,a];
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
    else
        return self.fetchedPBResultController;
}

// this is called via observing "NSManagedObjectContextDidSaveNotification" from our APLParseOperation
- (void)mergeChanges:(NSNotification *)notification {
    if (notification.object != _managedObjectContext) {
        [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
    }
}

// merge changes to main context,fetchedRequestController will automatically monitor the changes and update tableview.
- (void)updateMainContext:(NSNotification *)notification {
    
    assert([NSThread isMainThread]);
    
    KLog(@"updateMainContext");
    
    if(![[ConfigurationReader sharedConfgReaderObj]getABChangeSynced]) {
        KLog(@"*** AB change has not been synced. returns.");
        return;
    }
    
    BOOL localSyncFlag = [appDelegate.confgReader getContactLocalSyncFlag];
    if(localSyncFlag)
    {
        if([appDelegate.confgReader getContactServerSyncFlag])
        {
            _fetchedPBResultController = Nil;
        }
        _fetchedResultsController = Nil;
    }
    else
    {
        if([[appDelegate.confgReader getTotalContact]intValue] > kMaxContactLimitHack && [[_fetchedPBResultController fetchedObjects] count] < 10)
        {
            _fetchedPBResultController = Nil;
        }
        [appDelegate.tabBarController.view setUserInteractionEnabled:NO];
    }
    
    friendTable.scrollEnabled = NO;
    self.tabBarController.view.userInteractionEnabled = NO;

    [self dismissProgressBar];
    [self segmentSelectionChanged:Nil];
    [self showProgressView:0];
    BOOL serverSyncFlag = [appDelegate.confgReader getContactServerSyncFlag];
    if(localSyncFlag && serverSyncFlag) {
        KLog(@"Local and Server sync are done");
        [self dismissProgressBar];
        friendTable.scrollEnabled = YES;
        self.tabBarController.view.userInteractionEnabled = YES;
        
        if ([[Setting sharedSetting]shouldShowInAppPromoImage]) {
            [self showInAppPromoImage];
        }

        @try {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:NSManagedObjectContextDidSaveNotification
                                                          object:nil];
        } @catch (NSException *exception) {
            KLog(@"Exception occurred:%@",exception);
            
            if ([[Setting sharedSetting]shouldShowInAppPromoImage]) {
                [self showInAppPromoImage];
            }
        }
    }
}

-(void)updateGroupData {
    
    KLog(@"updateGroupData");
    
    BOOL localSyncFlag = [appDelegate.confgReader getContactLocalSyncFlag];
    if(localSyncFlag)
    {
        if([appDelegate.confgReader getContactServerSyncFlag])
        {
            _fetchedPBResultController = Nil;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //[self segmentSelectionChanged:Nil];
}

-(void)removeOverlayViewsIfAnyOnPushNotification
{
    [super removeOverlayViewsIfAnyOnPushNotification];
    [self buttonTappedRespond:nil withUniqueIdentifier:nil];
}


#pragma mark Invite button clicked
- (IBAction)stateSelected:(id)sender
{
    [inviteSearchBar resignFirstResponder];
    actionSheetInvite = [[UIActionSheet alloc]initWithTitle:@"Invite Friends" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Invite Friends via SMS",@"Invite Friends via Email", nil];
    actionSheetInvite.tag = ActionSheetTypeInvite;
    [actionSheetInvite showFromBarButtonItem:sender animated:YES];
}

#pragma mark -- IVDropDownDelegate User selection handling
-(void)buttonTappedRespond:(id)sender withUniqueIdentifier:(NSString*)uniqueIdentifier
{
    [pv dismiss:YES];
    pv = nil;
    UIButton *btn = (UIButton*)sender;
    if ([uniqueIdentifier isEqualToString:@"inviteBy_plusTapped"]) {
        if ([btn tag] == 0) {
            [self inviteBySMS];
        }
        else if ([btn tag] == 1){
            [self inviteByEmail];
        }
    }
    else if([uniqueIdentifier isEqualToString:@"friendsScreen_titleTapped"])
    {
        title.text = [NSString stringWithFormat:@"%@%@",[btn titleForState:UIControlStateNormal],@" ▾"];
        if ([btn tag] == 0) {
#pragma mark TODO Vinoth
            //All Chats
        }
        else if ([btn tag] == 1){
            //Unread Chats
        }
        else if ([btn tag] == 2){
            //Group Chats
        }
    }
}

-(void)inviteBySMS
{
    UIStoryboard *voiceMailSettingsStorybaord = [UIStoryboard storyboardWithName:@"IVFriendsStoryboard" bundle:[NSBundle mainBundle]];
    FriendsInviteViewController *friendsInviteViewController = [voiceMailSettingsStorybaord instantiateViewControllerWithIdentifier:@"FriendsInviteView"];
    
    friendsInviteViewController.inviteBySms = YES;
    friendsInviteViewController.delegate = self;

    //UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:friendsInviteViewController];
    [self.navigationController pushViewController:friendsInviteViewController animated:YES];
    
    /*
    [self.navigationController presentViewController:navController animated:YES completion:^{
    }];*/
}

-(void)inviteByEmail
{
    UIStoryboard *voiceMailSettingsStorybaord = [UIStoryboard storyboardWithName:@"IVFriendsStoryboard" bundle:[NSBundle mainBundle]];
    FriendsInviteViewController *friendsInviteViewController = [voiceMailSettingsStorybaord instantiateViewControllerWithIdentifier:@"FriendsInviteView"];
    friendsInviteViewController.inviteBySms = NO;
    friendsInviteViewController.delegate = self;
    //UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:friendsInviteViewController];
    [self.navigationController pushViewController:friendsInviteViewController animated:YES];
    
    /*
    [self.navigationController presentViewController:navController animated:YES completion:^{
    }];*/
}

#pragma mark -- FriendInviteListProtocol
-(void)listSelected:(NSMutableArray *)selectedInviteList forInviteType:(ContactInviteType)inviteType
{
    switch (inviteType)
    {
        case ContactInviteTypeSMS:
        {
            NSMutableDictionary *dic = [Common getSIMInfo];
            if(dic != nil && [dic count] >0)
            {
                [self sendSMSInvitation:selectedInviteList];
                [self sendInviteData:selectedInviteList forInviteType:inviteType];
            }
            else
            {
                [ScreenUtility showAlertMessage:NSLocalizedString(@"SIM_NOT_AVAILABLE", nil)];
            }
        }
            break;
        case ContactInviteTypeEmail:
        {
            [self sendInviteData:selectedInviteList forInviteType:inviteType];
        }
            break;
        case ContactInviteTypeFacebook:
        {
            [self sendInviteData:selectedInviteList forInviteType:inviteType];
        }
            break;
            
        default:
            break;
    }
}

-(void)sendInviteData:(NSMutableArray*)inviteDataList forInviteType:(ContactInviteType)inviteType
{
    NSMutableDictionary* sendMsgDic = [[NSMutableDictionary alloc]init];
    if(inviteType == ContactInviteTypeFacebook)
    {
        NSString *fbListString = [inviteDataList componentsJoinedByString:@","];
        [sendMsgDic setValue:fbListString forKey:API_FRIEND_FB_USER_IDS];
        [sendMsgDic setValue:[NSArray array] forKey:API_CONTACT_IDS];
    }
    else
    {
        NSMutableArray *contactIds = [[NSMutableArray alloc] init];
        NSString* inviteMode = PHONE_MODE;
        if(inviteType == ContactInviteTypeEmail)
            inviteMode = EMAIL_MODE;
        for(NSString* email in inviteDataList)
        {
            NSMutableDictionary *contactDic = [[NSMutableDictionary alloc] init];
            [contactDic setValue:inviteMode forKey:API_TYPE];
            [contactDic setValue:email forKey:API_CONTACT];
            [contactIds addObject:contactDic];
        }
        [sendMsgDic setValue:contactIds forKey:API_CONTACT_IDS];
    }
    
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    SendFriendInviteAPI* api = [[SendFriendInviteAPI alloc]initWithRequest:sendMsgDic];
    [api callNetworkRequest:sendMsgDic withSuccess:^(SendFriendInviteAPI *req, NSMutableDictionary *responseObject) {
        KLog(@"Response %@",responseObject);
        if(inviteType != ContactInviteTypeSMS)
        {
            [ScreenUtility showAlertMessage:NSLocalizedString(@"INVITATION_SENT", nil)];
        }
    } failure:^(SendFriendInviteAPI *req, NSError *error) {
        //dp bug:7987
        if(inviteType!=ContactInviteTypeSMS)
            [ScreenUtility showAlert:NSLocalizedString(@"INVITATION_FAIL", nil)];
    }];
}


#pragma mark - Send SMS and Email Invitation Old
-(void)inviteButtonClickedForCellAtRow:(NSIndexPath*)indexPath
{
    listIndex = indexPath;
    [inviteList removeAllObjects];
    
    if( searchTopView.tag == 1)
    {
        [txfSearchField resignFirstResponder];
    }
    
    _invitedContact = [[self currentActiveResultController]objectAtIndexPath:indexPath];
    
    popUp = [[CustomIOS7AlertView alloc]init];
    [ContactInvitePopUPAction setParentView:self];
    [ContactInvitePopUPAction createContactAlert:_invitedContact alertType:INVITE_ALERT deviceHeight:appDelegate.deviceHeight alertView:popUp];
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
        
        ContactData* data = [[self currentActiveResultController]objectAtIndexPath:listIndex];
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
}

-(void)sendBtnInviteAction
{
    popUp.tag = 0;
    popUp = nil;
    /* MAR 16, 2017
    if(searchTopView.tag == 1)
    {
        [self crossBtnAction];
    }*/
    
    if(inviteList == nil || [inviteList count] == 0)
    {
        [ScreenUtility showAlertMessage:NSLocalizedString(@"SELECT_CONTACT", nil)];
        return;
    }
    if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE)
    {
        [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
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
                [ScreenUtility showAlertMessage:NSLocalizedString(@"SIM_NOT_AVAILABLE", nil)];
            }
        }
        if([emailInviteList count] > 0)
        {
            [self sendEmailInvitation:emailInviteList];
        }
    }
    if(!isPhone )
    {
        popUp = nil;
        [friendTable reloadData];
    }
}

-(void)sendEmailInvitation:(NSMutableArray*)emailInviteList
{
    NSMutableArray* emailList = [[NSMutableArray alloc]init];
    for(NSMutableDictionary* cntDic in emailInviteList)
    {
        [emailList addObject:[cntDic valueForKey:CONTACT_DATA_VALUE]];
    }
    
    [self sendEmailInvitationToEmailList:emailList];
    [self updateInviteStatusInDB:emailInviteList];
}

-(void)sendEmailInvitationToEmailList:(NSMutableArray*)emailList
{
    NSMutableDictionary* sendMsgDic = [[NSMutableDictionary alloc]init];
    NSMutableArray *contactIds = [[NSMutableArray alloc] init];
    for(NSString* email in emailList)
    {
        NSMutableDictionary *contactDic = [[NSMutableDictionary alloc] init];
        [contactDic setValue:EMAIL_MODE forKey:API_TYPE];
        [contactDic setValue:email forKey:API_CONTACT];
        [contactIds addObject:contactDic];
    }
    [sendMsgDic setValue:contactIds forKey:API_CONTACT_IDS];
    SendFriendInviteAPI* api = [[SendFriendInviteAPI alloc]initWithRequest:sendMsgDic];
    [api callNetworkRequest:sendMsgDic withSuccess:^(SendFriendInviteAPI *req, NSMutableDictionary *responseObject) {
        KLog(@"Response %@",responseObject);
    } failure:^(SendFriendInviteAPI *req, NSError *error) {
    }];
}

-(BOOL) sendSMSInvitation:(NSMutableArray*)smsInvitationList
{
    if(![MFMessageComposeViewController canSendText])
    {
        alertWarning = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"SMS_NOT_SUPPORTED", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertWarning show];
        return NO;
    }
    
    NSArray *recipents = [NSArray arrayWithArray:smsInvitationList];
    NSString* smsText = [[[Profile sharedUserProfile]profileData]inviteSmsText];
    NSString *message = NSLocalizedString(@"SMS_MESSAGE_PHONE", nil);
    if(smsText && smsText.length > 0)
    {
        message = smsText;
    }
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
            [ScreenUtility showAlertMessage:NSLocalizedString(@"INVITATION_FAIL", nil)];
        }
            break;
        case MessageComposeResultSent:
        {
            [ScreenUtility showAlertMessage:NSLocalizedString(@"INVITATION_SENT", nil)];
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
    isSearching = NO;
}

-(void)updateInviteStatusInDB:(NSMutableArray*)contactList
{
    /*
     _invitedContact.isInvited = [NSNumber numberWithBool:YES];
     NSError* error = Nil;
     [self.managedObjectContext save:&error];
     _fetchedPBResultController = Nil;
     [self segmentSelectionChanged:Nil];
     */
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -- UIActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == ActionSheetTypeInvite)
    {
        if(buttonIndex == 0)
        {
            [self inviteBySMS];
        }
        else if(buttonIndex == 1)
        {
            [self inviteByEmail];
        }else{
           //MAR 30, 2017 [inviteSearchBar becomeFirstResponder];
        }
    }
    
    if(actionSheet.tag == ActionSheetTypeSelectContact)
    {
        if(buttonIndex < _multipleContact.count)
        {
            ContactDetailData* selectedDetail = [_multipleContact objectAtIndex:buttonIndex];
            KLog(@"Selected contact %@ at index %ld",selectedDetail.contactDataValue,(long)buttonIndex);
            [self moveToConversationScreen:selectedDetail];
        }
    }
}

-(void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
}

-(void)closeActionSheet
{
    if(nil != actionSheetContactSelect) {
        [actionSheetContactSelect dismissWithClickedButtonIndex:-1 animated:NO];
        actionSheetContactSelect = nil;
    }
    
    if(nil != actionSheetInvite) {
        [actionSheetInvite dismissWithClickedButtonIndex:-1 animated:NO];
        actionSheetInvite = nil;
    }
}

-(void)dismissThisViewController
{
    if(nil != alertWarning) {
        [alertWarning dismissWithClickedButtonIndex:-1 animated:NO];
        alertWarning = nil;
    }
    
    [self closeActionSheet];
    [ScreenUtility closeAlert];
    [self dismissViewController];
}


- (void)updateNavigationBarTintColor {
    
#if DEFAULT_THEMECOLOR_ENABLED
     self.navigationController.navigationBar.barTintColor = [IVColors redColor];
    
#else
    {
        NSString *carrierThemeColor = [[ConfigurationReader sharedConfgReaderObj]getLatestCarrierThemeColor];

        if (carrierThemeColor && [carrierThemeColor length])
             self.navigationController.navigationBar.barTintColor = [IVColors convertHexValueToUIColor:carrierThemeColor];
        else
             self.navigationController.navigationBar.barTintColor = [IVColors redColor];
    }
    
#endif

}

#pragma mark - Setting Delegate Methods
- (void)fetchPromoImageCompletedWithStatus:(BOOL)withFetchStatus {
    if (withFetchStatus) {
        if ([[Setting sharedSetting]shouldShowInAppPromoImage]) {
            //Show the In App PromoImage.
            [self showInAppPromoImage];
        }
    }
}
@end
