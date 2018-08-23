//
//  FriendsInviteViewController.m
//  InstaVoice
//
//  Created by kirusa on 10/21/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ContactTableViewInviteCell.h"
#import "CountryTableViewController.h"
#import "FriendsInviteViewController.h"
#import "MZFormSheetController.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"
#import "Setting.h"
#import "ScreenUtility.h"

#ifdef REACHME_APP
#import "Profile.h"
#import "SendFriendInviteAPI.h"
#import "ConversationApi.h"
#endif

#define INVITE_TEXT     @"Please select a friend to invite"

@interface FriendsInviteViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *sharedPSC;
@property (nonatomic, strong) NSFetchRequest* fetchRequest;
@property (nonatomic, strong) NSString* sectionNameKeyPath;
@property (nonatomic, strong) NSFetchedResultsController *fetchedPBResultController;
@property (weak, nonatomic) IBOutlet UITableView *friendsInviteTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *friendsInviteSearchBar;
@property (nonatomic, strong) NSString *searchString;
@property (weak, nonatomic) IBOutlet UILabel *noResultLabel;

@end

@implementation FriendsInviteViewController

//TODO unused method
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        numberE164format = @"";
        numberWithoutFormat = @"";
        countryIsdCode = @"";
        isSearching = FALSE;
    
        //id delegate = [[UIApplication sharedApplication]delegate];
        self.managedObjectContext = [AppDelegate sharedMainQueueContext];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _inviteList = [[NSMutableArray alloc]init];

    self.noResultLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];

    //id delegate = [[UIApplication sharedApplication]delegate];
    self.managedObjectContext = [AppDelegate sharedMainQueueContext];

    if(self.inviteBySms)
        _loadAllPBContact = NO;
    else
        _loadAllPBContact = YES;
    
    UINib* nib = [UINib nibWithNibName:@"ContactTableViewInviteCell" bundle:nil];
    [self.friendsInviteTableView registerNib:nib forCellReuseIdentifier:@"ContactTableViewInviteCell"];
    
    self.friendsInviteTableView.estimatedRowHeight = 90.0;
    self.friendsInviteTableView.rowHeight = UITableViewAutomaticDimension;

    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(popController:)];
    [self.navigationItem setLeftBarButtonItem:backButton animated:NO];

    UIImage *buttonImage = [[UIImage imageNamed:@"send_icn"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *buttonSelectedImage = [[UIImage imageNamed:@"send_icn_hvr"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height)];
    [rightButton setImage:buttonImage forState:UIControlStateNormal];
    [rightButton setImage:buttonSelectedImage forState:UIControlStateSelected];
    [rightButton setShowsTouchWhenHighlighted:YES];
    [rightButton setSelected:NO];
    [rightButton addTarget:self action:@selector(inviteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    self.title = NSLocalizedString(@"Select Friends", nil);
    self.uiType = FRIENDS_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    self.noResultLabel.hidden = YES;
    [self pbBtnAction];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    isSearching = NO;
    if(self.inviteBySms)
        self.friendsInviteSearchBar.placeholder = NSLocalizedString(@"Name or phone number", nil);
    else
        self.friendsInviteSearchBar.placeholder = NSLocalizedString(@"Name or email address", nil);
    
    self.friendsInviteTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    appDelegate.tabBarController.tabBar.hidden = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIBarButton Action -

- (void)popController:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
    /*
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];*/
}

- (void)inviteButtonTapped:(id)sender {
    
    ContactInviteType inviteType = ContactInviteTypeSMS;
    if(_inviteList.count<1)
    {
        [ScreenUtility showAlertMessage:INVITE_TEXT];
    }
    else
    {
        if(!self.inviteBySms)
            inviteType = ContactInviteTypeEmail;
        
            if([_inviteList count] > 0) {
#ifndef REACHME_APP
                if (self.delegate && [self.delegate respondsToSelector:@selector(listSelected:forInviteType:)]) {
                    [self.delegate listSelected:_inviteList forInviteType:inviteType];
                }
#else
                [self listSelected:_inviteList forInviteType:inviteType];
                [self.delegate listSelected:_inviteList forInviteType:inviteType];
#endif
            }
        
        self.searchString = nil;
        isSearching = NO;
        [self.friendsInviteSearchBar setText:@""];
        [self.friendsInviteSearchBar setShowsCancelButton:NO animated:YES];
        [self.friendsInviteSearchBar resignFirstResponder];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
- (void)pbBtnAction
{
    if([[self currentActiveResultController].fetchedObjects count] > 0)
    {
        self.noResultLabel.hidden = YES;
        [self.friendsInviteTableView reloadData];

    }
    else {
        [self.friendsInviteTableView reloadData];
        self.noResultLabel.hidden = NO;
        if(!isSearching)
        {
            self.noResultLabel.text = NSLocalizedString(@"NO_CONTACTS", nil);
        }
        else
        {
            self.noResultLabel.text = NSLocalizedString(@"NO_RESULT", nil);
        }
    }
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


-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return UITableViewAutomaticDimension;
    return 64.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactDetailData* detailData = [[self currentActiveResultController] objectAtIndexPath:indexPath];
    
    ContactTableViewInviteCell* cell = (ContactTableViewInviteCell*)[tableView dequeueReusableCellWithIdentifier:@"ContactTableViewInviteCell" forIndexPath:indexPath];
 
    cell.selectedRowIndex = indexPath;
    [cell configureSMSInviteCellWithData:detailData withFlag:self.inviteBySms];
    
    if(self.inviteBySms){
        if([_inviteList containsObject:[@"+" stringByAppendingString:[detailData contactDataValue]]])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        if([_inviteList containsObject:[detailData contactDataValue]])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactDetailData* detail = [[self currentActiveResultController] objectAtIndexPath:indexPath];
    UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
    
    if(self.inviteBySms){
        if (c.accessoryType == UITableViewCellAccessoryCheckmark) {
            [c setAccessoryType:UITableViewCellAccessoryNone];
            [_inviteList removeObject:[@"+" stringByAppendingString:[detail contactDataValue]]];
        }
        else
        {
            [_inviteList addObject:[@"+" stringByAppendingString:[detail contactDataValue]]];
            [c setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }else{
        if (c.accessoryType == UITableViewCellAccessoryCheckmark) {
            [c setAccessoryType:UITableViewCellAccessoryNone];
            [_inviteList removeObject:[detail contactDataValue]];
        }
        else
        {
            [_inviteList addObject:[detail contactDataValue]];
            [c setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_inviteList && [_inviteList count]) {
            NSString *titleString = [NSString stringWithFormat:@"Selected Friends(%lu)",(unsigned long)_inviteList.count];
            self.title = NSLocalizedString(titleString, nil);
        }
        else
            self.title = NSLocalizedString(@"Select Friends", nil);

        UIBarButtonItem *rightBarButton = self.navigationItem.rightBarButtonItem;
        UIButton *button = (UIButton *)rightBarButton.customView;
        button.selected = (_inviteList && _inviteList.count) ? YES: NO;
    });
}


- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    /* CMP
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
    }*/
}

- (IBAction)segmentSelectionChanged:(id)sender {
    [self killScroll];
    [self pbBtnAction];
}

- (void)killScroll {
    [self.friendsInviteTableView setContentOffset:self.friendsInviteTableView.contentOffset animated:NO];
}

#pragma mark -- NSFetchedResultsController
-(NSFetchedResultsController*)fetchedResultsController
{
    if(_fetchedResultsController != Nil)
        return _fetchedResultsController;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath cacheName:Nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    
    if (![_fetchedResultsController performFetch:&error]) {
        KLog(@"Unresolved error %@, %@", error, [error userInfo]);
        EnLogd(@"FIXME: Error: %@, Do a graceful exit",error);
        //JUNE 2017 abort();
        return nil;
    }
    
    return _fetchedResultsController;
}

-(NSFetchedResultsController*)fetchedPBResultController
{
    if(_fetchedPBResultController != Nil)
        return _fetchedPBResultController;
    
    [self setFetchRequestForSearchString:Nil];
    
    _fetchedPBResultController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath cacheName:Nil];
    _fetchedPBResultController.delegate = self;
    
    NSError *error = nil;
    
    if (![_fetchedPBResultController performFetch:&error]) {
        KLog(@"Unresolved error %@, %@", error, [error userInfo]);
        EnLogd(@"FIXME: Error: %@, Do a graceful exit",error);
        //JUNE 2017 abort();
        return nil;
    }
    
    return _fetchedPBResultController;
}


-(void)setFetchRequestForSearchString:(NSString*)searchString
{
    _fetchRequest = [[NSFetchRequest alloc] init];
    _fetchRequest.fetchBatchSize = 20;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
    [_fetchRequest setEntity:entityDescription];
    
    NSSortDescriptor *sortName = [[NSSortDescriptor alloc]initWithKey:@"contactIdParentRelation.contactName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSString* contactDataType = PHONE_MODE;
    if(!self.inviteBySms)
        contactDataType = EMAIL_MODE;
    _sectionNameKeyPath = Nil;
    if(isSearching && searchString != Nil && [searchString length] > 0)
    {
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"(contactDataType = %@ AND contactIdParentRelation.contactType = %@ AND contactIdParentRelation.isIV = 0 AND ((contactIdParentRelation.contactName CONTAINS[cd] %@) OR (contactIdParentRelation.lastName CONTAINS[cd] %@) OR (contactDataValue CONTAINS[cd] %@)))",contactDataType,[NSNumber numberWithInteger:ContactTypeNativeContact],searchString,searchString,searchString];
        [_fetchRequest setPredicate:condition];
    }
    else if([[appDelegate.confgReader getTotalContact]intValue] > kMaxContactLimitHack && !_loadAllPBContact)
    {
        NSString* a = @"a";
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"(contactDataType = %@ AND contactIdParentRelation.contactType = %@ AND contactIdParentRelation.isIV = 0 AND ((contactIdParentRelation.contactName CONTAINS[cd] %@) OR (contactIdParentRelation.lastName CONTAINS[cd] %@)))",contactDataType,[NSNumber numberWithInteger:ContactTypeNativeContact],a,a];
        [_fetchRequest setPredicate:condition];
    }
    else
    {
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"(contactDataType = %@ AND contactIdParentRelation.contactType = %@ AND contactIdParentRelation.isIV = 0)",contactDataType,[NSNumber numberWithInteger:ContactTypeNativeContact]];
        [_fetchRequest setPredicate:condition];
    }
    
    [_fetchRequest setSortDescriptors:@[sortName]];
    
}

-(NSFetchedResultsController*)currentActiveResultController
{
    if(isSearching)
        return self.fetchedResultsController;
    
    return self.fetchedPBResultController;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //[self segmentSelectionChanged:Nil];
}


-(void)removeOverlayViewsIfAnyOnPushNotification
{
    [self dismissViewController];
    [super removeOverlayViewsIfAnyOnPushNotification];
}

#pragma mark - UISearchBar Delegate Methods -
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText && [searchText length] > 0 && ![searchText isEqualToString:@""]) {
        isSearching = YES;
        self.searchString = searchText;
        
    }
    else {
        self.searchString = nil;
        isSearching = NO;
    }
    
    [self killScroll];
    _fetchedResultsController = Nil;
    [self setFetchRequestForSearchString:self.searchString];
    [self pbBtnAction];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchString = nil;
    isSearching = NO;
    [self.friendsInviteSearchBar setText:@""];
    [self.friendsInviteSearchBar setShowsCancelButton:NO animated:YES];
    [self.friendsInviteSearchBar resignFirstResponder];
    [self killScroll];
    _fetchedResultsController = Nil;
    [self setFetchRequestForSearchString:self.searchString];
    [self pbBtnAction];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

#pragma mark - Font Size Related Changes - 
- (void)preferredContentSizeChanged: (NSNotification *)withNotification {
    self.noResultLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    [self.friendsInviteTableView reloadData];
}

#pragma mark - Memory CleanUp Methods - 
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#ifdef REACHME_APP
-(void)listSelected:(NSMutableArray *)selectedInviteList forInviteType:(ContactInviteType)inviteType
{
    switch (inviteType)
    {
        case ContactInviteTypeSMS:
        {
            NSMutableDictionary *dic = [Common getSIMInfo];
            if(dic != nil && [dic count] >0)
            {
                //[self sendSMSInvitation:selectedInviteList];
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

-(void)sendEmailInvitation:(NSMutableArray*)emailInviteList
{
    NSMutableArray* emailList = [[NSMutableArray alloc]init];
    for(NSMutableDictionary* cntDic in emailInviteList)
    {
        [emailList addObject:[cntDic valueForKey:CONTACT_DATA_VALUE]];
    }
    
    [self sendEmailInvitationToEmailList:emailList];
    //[self updateInviteStatusInDB:emailInviteList];
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

#endif

@end
