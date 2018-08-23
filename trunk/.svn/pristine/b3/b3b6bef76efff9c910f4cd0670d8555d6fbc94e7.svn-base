
//  ShareFriendsListViewController.m
//  InstaVoice
//
//  Created by kirusa on 11/13/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ShareFriendsListViewController.h"
#import "ScreenUtility.h"
#import "Contacts.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "CoreDataSetup.h"
#import "ConversationApi.h"
#import "IVFileLocator.h"
#import "ContactSyncUtility.h"
//#import "ContactTableViewInviteCell.h"
#import "ShareFriendsListCell.h"
#import "ShareFriendsListCellIv.h"
#import "ShareFriendsListCellNonIv.h"
@interface ShareFriendsListViewController () <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *friendTable;
@property (weak, nonatomic) IBOutlet UILabel *noContactLbl;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *sharedPSC;
@property (nonatomic, strong) NSFetchRequest* fetchRequest;
@property (nonatomic, strong) NSString* sectionNameKeyPath;
@property (nonatomic, strong) NSFetchedResultsController *fetchedPBResultController;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, assign) BOOL loadAllPBContact;
@property (weak, nonatomic) IBOutlet UISearchBar *shareFriendsSearchBar;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) NSArray *friendsList;
@property (nonatomic, strong) NSMutableDictionary *sortedFriendsData;
@property (nonatomic, strong) NSArray *sortedFriendsKeys;
@property (nonatomic, strong) NSArray *sectionIndexTitleList;
@end

@implementation ShareFriendsListViewController

BOOL displayProgressBar;

//TODO this method is not used.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.isSearching        = FALSE;
        
        self.navigationItem.hidesBackButton = YES;
        
        [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
        
        /* CMP MAR 04,16
        self.sharedPSC = [[CoreDataSetup sharedCoredDataSetup] persistentStoreCoordinator];
        self.managedObjectContext = [[CoreDataSetup sharedCoredDataSetup]managedObjectContext];
         */
        //id delegate = [[UIApplication sharedApplication]delegate];
        self.managedObjectContext = [AppDelegate sharedMainQueueContext];
        displayProgressBar = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    KLog(@"viewDidLoad - START");
    
    [super viewDidLoad];

    _inviteList = [[NSMutableArray alloc]init];
    
    self.title = NSLocalizedString(@"Select Friends", nil);

    //For non-iv cells
    UINib* nib = [UINib nibWithNibName:@"ShareFriendsListCellNonIv" bundle:nil];
    [self.friendTable registerNib:nib forCellReuseIdentifier:@"ShareFriendsListCellNonIv"];
    
    //For iv cells
    UINib* nib1 = [UINib nibWithNibName:@"ShareFriendsListCellIv" bundle:nil];
    [self.friendTable registerNib:nib1 forCellReuseIdentifier:@"ShareFriendsListCellIv"];
    

    self.friendTable.estimatedRowHeight = 90.0;
    self.friendTable.rowHeight = UITableViewAutomaticDimension;

    self.noContactLbl.hidden = YES;
    self.friendTable.hidden = YES;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(popController:)];
    [self.navigationItem setLeftBarButtonItem:backButton animated:NO];
  
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonTapped:)];
    [rightBarButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont systemFontOfSize:[UIFont labelFontSize]],
      NSFontAttributeName,
      nil] forState:UIControlStateNormal];

    [self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
    
    self.isSearching = NO;
    //id delegate = [[UIApplication sharedApplication]delegate];
    self.managedObjectContext = [AppDelegate sharedMainQueueContext];
    KLog(@"viewDidLoad - END");
}

-(void)viewWillAppear:(BOOL)animated
{
    KLog(@"viewWillAppear - START");
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    self.isSearching = NO;
    displayProgressBar = YES;
    [appDelegate.stateMachineObj setCurrentPresentedUI:self];
    self.friendTable.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self performSelectorOnMainThread:@selector(pbBtnAction) withObject:nil waitUntilDone:NO];
    KLog(@"viewWillAppear - END");
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    [appDelegate.stateMachineObj setCurrentPresentedUI:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)unloadData:(BOOL)event
{
    self.friendTable.hidden = YES;
    self.noContactLbl.hidden = NO;
    if(!self.isSearching)
        self.noContactLbl.text = NSLocalizedString(@"NO_CONTACTS", nil);
    else
        self.noContactLbl.text = NSLocalizedString(@"NO_RESULT", nil);
    
    self.noContactLbl.backgroundColor = [UIColor clearColor];
}

#pragma mark - create different views

- (IBAction)segmentSelectionChanged:(id)sender {
    
    [self killScroll];
    [self pbBtnAction];
}

- (void)killScroll {
    
    [self.friendTable setContentOffset:self.friendTable.contentOffset animated:NO];
}


- (void)pbBtnAction {
    
    self.noContactLbl.hidden = YES;
    self.friendTable.hidden  = NO;
    
    self.friendsList = [self currentActiveResultController].fetchedObjects;
    
    if (self.friendsList && [self.friendsList count] > 0) {
        if (!self.isSearching) {
            if(displayProgressBar)
                [self showProgressBar];
            [self performSelectorInBackground:@selector(processFriendsList:) withObject:self.friendsList];
        }
        else {
            self.sortedFriendsData = nil;
            self.sortedFriendsKeys = nil;
            self.sectionIndexTitleList = nil;
        }
        [self.friendTable reloadData];
    }
    else
        [self unloadData:YES];
    
}

#pragma mark - table view delegate's implementation
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return [[[self currentActiveResultController] sections] count];
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections;
    numberOfSections = [self.sortedFriendsKeys count]? [self.sortedFriendsKeys count]:1;
    return numberOfSections;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    if (self.sortedFriendsKeys && [self.sortedFriendsKeys count]) {
        KLog(@"section = %ld, sortedFriendsKeys = %ld",section,[self.sortedFriendsKeys count]);
        NSString *key = [self.sortedFriendsKeys objectAtIndex:section];
        numberOfRows = [self.sortedFriendsData[key]count];

    }
    else
    {
        if ([[[self currentActiveResultController] sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[[self currentActiveResultController] sections] objectAtIndex:section];
            numberOfRows = [sectionInfo numberOfObjects];
        }

    }
    
    KLog(@"numberOfRowsInSection: %ld",(long)numberOfRows);
    return numberOfRows;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [Common preferredFontForTextStyleInApp:@"SectionHeaderBoldFont"];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.contentView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
    
    header.frame = headerFrame;
    
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return UITableViewAutomaticDimension;
    return 64.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return ([self.sortedFriendsKeys objectAtIndex:section]);
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionIndexTitleList;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger section = [self.sortedFriendsKeys indexOfObject:title];
    if (section == NSNotFound) {
        if (index > [self.sortedFriendsKeys count])
            section = [self.sortedFriendsKeys count]-1;
        else
            section = index - 1;
    }
    return section;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *friendsList;
    ContactDetailData* detailData;
    if (self.sortedFriendsKeys && [self.sortedFriendsKeys count]) {
        NSString *key = [self.sortedFriendsKeys objectAtIndex:indexPath.section];
       friendsList = self.sortedFriendsData[key];
        
        if([friendsList count] > indexPath.row) {
            detailData = [friendsList objectAtIndex:indexPath.row];
        } else {
            /* TODO -- refactor the code. MAR 30, 2017
             This is due to calling reloadData on table before completion of datasource at processFriendsList
             Also check the code at viewWillAppear */
            KLog(@"Debug");
        }
    }
    else {
        detailData = [[self currentActiveResultController] objectAtIndexPath:indexPath];
    }
   
    ShareFriendsListCell* cell = nil;
    if([detailData.ivUserId longLongValue]>0)
        cell = (ShareFriendsListCellIv*)[tableView dequeueReusableCellWithIdentifier:@"ShareFriendsListCellIv"];
    else
       cell = (ShareFriendsListCellNonIv*)[tableView dequeueReusableCellWithIdentifier:@"ShareFriendsListCellNonIv"];
    
    
    
    //cell.selectedRowIndex = indexPath;
    [cell configureShareMessageCellWithData:detailData];
    if ([_inviteList containsObject:detailData])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactDetailData* detail;
    if (self.isSearching && [self.searchString length])
        detail = [[self currentActiveResultController] objectAtIndexPath:indexPath];
    else
    {
        NSString *key = [self.sortedFriendsKeys objectAtIndex:indexPath.section];
        NSArray *friendsList = self.sortedFriendsData[key];
        if (friendsList && [friendsList count]) {
            detail = [friendsList objectAtIndex:indexPath.row];
        }
    }
 
    UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
    if (c.accessoryType == UITableViewCellAccessoryCheckmark) {
        [c setAccessoryType:UITableViewCellAccessoryNone];
        if (detail) {
            [_inviteList removeObject:detail];
        }
    }
    else
    {
        if (detail) {
            [_inviteList addObject:detail];
         }
        [c setAccessoryType:UITableViewCellAccessoryCheckmark];
    }

    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_inviteList && [_inviteList count]) {
            NSString *titleString = [NSString stringWithFormat:@"Selected Friends(%lu)",(unsigned long)_inviteList.count];
            self.title = NSLocalizedString(titleString, nil);
        }
        else
            self.title = NSLocalizedString(@"Select Friends", nil);

        UIBarButtonItem *rightBarButton = self.navigationItem.rightBarButtonItem;
        if (_inviteList && _inviteList.count) {
            [rightBarButton setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [UIFont boldSystemFontOfSize:[UIFont labelFontSize]],
              NSFontAttributeName,
              nil] forState:UIControlStateNormal];
        }
        else {
            [rightBarButton setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [UIFont systemFontOfSize:[UIFont labelFontSize]],
              NSFontAttributeName,
              nil] forState:UIControlStateNormal];

        }
    });
}

- (void)tableView:(UITableView *)tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactDetailData* detail = [[self currentActiveResultController] objectAtIndexPath:indexPath];
    UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
    if (c.accessoryType == UITableViewCellAccessoryCheckmark) {
        [c setAccessoryType:UITableViewCellAccessoryNone];
        [_inviteList removeObject:detail];
    }
    else
    {
        [_inviteList addObject:detail];
        [c setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
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
            if(!self.loadAllPBContact)
            {
                _loadAllPBContact = YES;
                _fetchedPBResultController = Nil;
                [self segmentSelectionChanged:Nil];
                KLog(@"load more rows");
            }
        }
    }
}

#pragma mark -- NSFetchedResultsController
-(NSFetchedResultsController*)fetchedResultsController
{
    if(_fetchedResultsController != Nil)
        return _fetchedResultsController;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath cacheName:Nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    
    KLog(@"fetchedResultsController -- START");
    
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
    
    KLog(@"fetchedResultsController -- END");
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
    
    KLog(@"fetchedPBResultController -- START");
    if (![_fetchedPBResultController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        KLog(@"Unresolved error %@, %@", error, [error userInfo]);
        EnLogd(@"FIXME: Error: %@, Do a graceful exit",error);
        //June, 2017 abort();
        return nil;
    }
    
    KLog(@"fetchedPBResultController -- END");
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
    
    _sectionNameKeyPath = Nil;
    if(self.isSearching && searchString != Nil && [searchString length] > 0)
    {
        /* MAR 22, 2017
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"(contactIdParentRelation.isIV = 1 AND contactDataType = %@ AND contactIdParentRelation.contactType != %d AND ((contactIdParentRelation.contactName contains[cd] %@) OR (contactIdParentRelation.lastName contains[cd] %@) OR (contactDataValue CONTAINS[cd] %@)))",contactDataType,ContactTypeCelebrity,searchString,searchString,searchString];
         */
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"(contactDataType = %@ AND contactIdParentRelation.contactType != %d AND ((contactIdParentRelation.contactName contains[cd] %@) OR (contactIdParentRelation.lastName contains[cd] %@) OR (contactDataValue CONTAINS[cd] %@)))",contactDataType,ContactTypeCelebrity,searchString,searchString,searchString];
        [_fetchRequest setPredicate:condition];
    }
    else
    {
        /* MAR 22, 2017
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"(contactIdParentRelation.isIV = 1 AND contactDataType = %@ AND contactIdParentRelation.contactType != %d)",contactDataType,ContactTypeCelebrity];
         */
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"(contactDataType = %@ AND contactIdParentRelation.contactType != %d)",contactDataType,ContactTypeCelebrity];
        [_fetchRequest setPredicate:condition];
    }
    
    [_fetchRequest setSortDescriptors:@[sortName]];
}

-(NSFetchedResultsController*)currentActiveResultController
{
    if(self.isSearching)
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

#pragma mark - 

- (void)shareButtonTapped:(id)sender {
    
    self.searchString = nil;
    self.isSearching = NO;
    [self.shareFriendsSearchBar setText:@""];
    [self.shareFriendsSearchBar setShowsCancelButton:NO animated:YES];
    [self.shareFriendsSearchBar resignFirstResponder];
    if(_inviteList.count<1)
    {
        //[ScreenUtility showAlert:@"Please select a contact before sharing the message"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please select a contact before sharing the message" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
        [self presentViewController:alert animated:YES completion:nil];
        
        [self killScroll];
        _fetchedResultsController = Nil;
        [self setFetchRequestForSearchString:self.searchString];
        [self pbBtnAction];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^{
            if([_inviteList count] > 0) {
                
                if (self.shareMessageDelegate &&
                    [self.shareMessageDelegate respondsToSelector:@selector(shareFriendListDidFinishSelectingList:forMessage:)]) {
                    [self.shareMessageDelegate shareFriendListDidFinishSelectingList:_inviteList forMessage:self.messageDictionary];
                    
                }
            }
        }];
    }
}

- (void)popController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UISearchBar Delegate Methods -
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText && [searchText length] > 0 && ![searchText isEqualToString:@""]) {
        self.isSearching = YES;
        self.searchString = searchText;
    }
    else {
        self.searchString = nil;
        self.isSearching = NO;

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
    self.isSearching = NO;
    [self.shareFriendsSearchBar setText:@""];
    [self.shareFriendsSearchBar setShowsCancelButton:NO animated:YES];
    [self.shareFriendsSearchBar resignFirstResponder];
    [self killScroll];
    _fetchedResultsController = Nil;
    [self setFetchRequestForSearchString:self.searchString];
    [self pbBtnAction];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
}

#pragma mark - Font Size Related Changes - 
- (void)preferredContentSizeChanged: (NSNotification *)withNotification {
    self.noContactLbl.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    [self.friendTable reloadData];
}


#pragma mark - Private Methods - 

/* TODO
  This method takes too much time in preparing the indexing for the array content.
  Change the implementation logic.
 */
- (void)processFriendsList:(NSArray *)friendsList {
    
    if (friendsList && [friendsList count]) {
        NSMutableArray *sortedArray =[[NSMutableArray alloc]init];
        self.sortedFriendsData = [self createDictionaryForSectionIndex:friendsList];
                //It means we have other elements which are not belongs to alphabets
        self.sortedFriendsKeys = [[self.sortedFriendsData allKeys]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        for (NSInteger i=0; i< [self.sortedFriendsKeys count]; i++) {
            NSString *key = [self.sortedFriendsKeys objectAtIndex:i];
            NSArray *carrierList = self.sortedFriendsData[key];
            [sortedArray addObjectsFromArray:carrierList];
        }
        
        if ([friendsList count] > [sortedArray count]) {
            NSMutableArray *friendsListWithoutAlphabets = [[NSMutableArray alloc]init];
            NSMutableArray *keysArray = [[NSMutableArray alloc]init];
            for (NSInteger i=0; i< [friendsList count]; i++) {
                if (![sortedArray containsObject:[friendsList objectAtIndex:i]]) {
                    [friendsListWithoutAlphabets addObject:[friendsList objectAtIndex:i]];
                }
            }
            [self.sortedFriendsData setObject:friendsListWithoutAlphabets forKey:@"#"];
             [keysArray addObjectsFromArray:self.sortedFriendsKeys];
             [keysArray addObject:@"#"];
            self.sortedFriendsKeys = keysArray;
            self.sectionIndexTitleList = @[@"A", @"B", @"C", @"D", @"E",@"F",@"G",@"H", @"I", @"J",@"K", @"L",@"M", @"N", @"O", @"P",@"Q",@"R", @"S",@"T", @"U", @"V", @"W",@"X",@"Y",@"Z", @"#"];
            
        }
        else {
            self.sectionIndexTitleList = @[@"A", @"B", @"C", @"D", @"E",@"F",@"G",@"H", @"I", @"J",@"K", @"L",@"M", @"N", @"O", @"P",@"Q",@"R", @"S",@"T", @"U", @"V", @"W",@"X",@"Y",@"Z"];

        }
    }
    
    [self performSelectorOnMainThread:@selector(finishedIndexingTheList) withObject:nil waitUntilDone:NO];
}

-(void)finishedIndexingTheList {
    
    [self hideProgressBar];
    displayProgressBar = NO;
    [self.friendTable reloadData];
}

- (NSMutableDictionary *)createDictionaryForSectionIndex:(NSArray *)friendsListArray {
    
    NSMutableDictionary *friendsInfoDictionary = [[NSMutableDictionary alloc]init];
    
    for (char firstChar = 'a' ; firstChar <= 'z'; firstChar++) {
                
        NSString *firstCharacter = [NSString stringWithFormat:@"%c", firstChar];
        NSArray *content = [friendsListArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contactIdParentRelation.contactName beginswith[cd] %@", firstCharacter]];
        NSMutableArray *mutableContent = [NSMutableArray arrayWithArray:content];
        
        if ([mutableContent count] > 0)
        {
            NSString *key = [firstCharacter uppercaseString];
            [friendsInfoDictionary setObject:mutableContent forKey:key];
        }
    }
    
    return friendsInfoDictionary;
}

#pragma mark - Memory CleanUp Methods -
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
