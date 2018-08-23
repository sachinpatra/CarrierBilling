//
//  CreateNewGroupViewController.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 9/1/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "CreateNewGroupViewController.h"
#import "CreateNewGroupMembersCell.h"
#import "CreateGroupAPI.h"
#import "FetchGroupInfoAPI.h"
#import "UpdateGroupAPI.h"
#import "TableColumns.h"
#import "Macro.h"
#import "Engine.h"
#import "ConversationApi.h"
#import "IVColors.h"
#import "GroupUtility.h"
#import "Contacts.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "GroupMemberData.h"
#import "CoreDataSetup.h"
#import "ContactSyncUtility.h"
#import "NBPhoneNumberUtil.h"
#import "NBAsYouTypeFormatter.h"
#import "IVImageUtility.h"
#import "Profile.h"
#import "IVFileLocator.h"
#import "ContactTableViewCell.h"
#import "Common.h"
#import "InsideConversationScreen.h"

#define GROUP_NAME_LIMIT_WARN   @"Sorry, group name cannot exceed 30 characters"
#define GROUP_NAME_LENGTH_LIMIT 30
#define GROUP_MEMBER_COUNT_MAX  200

#define kCreateNewGroupMembersCellIdentifier @"CreateNewGroupMembersCellIdentifier"

@interface CreateNewGroupViewController () <UISearchBarDelegate, UIToolbarDelegate>

@property (strong, nonatomic) UISegmentedControl *navSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *peopleInGroupLabel; // a label that will display who is "ticked off" as in the group.
@property (strong, nonatomic) IBOutlet UIView *peopleInGroupBackgroundView; // the view behind the peopleInGroupLabel

@property (strong, nonatomic) IBOutlet UIToolbar *instructionsToolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *instructionsToolbarToTopOfScreenConstraint;
@property (strong,nonatomic) __block NSMutableDictionary* groupInfo;
@end

@implementation CreateNewGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGroupDetails:(NSDictionary*)groupDetails
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.groupName = [groupDetails valueForKey:REMOTE_USER_NAME];
        self.groupID = [groupDetails valueForKey:FROM_USER_ID];
        self.groupProfilePicPath = [groupDetails valueForKey:REMOTE_USER_PIC];
        //_managedObjectContext = [AppDelegate sharedMainQueueContext];
        alertView = nil;
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -- View appearance methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.groupMemberTableView.estimatedRowHeight = 90.0;
    self.groupMemberTableView.rowHeight = UITableViewAutomaticDimension;

    UINib* nibRec = [UINib nibWithNibName:@"CreateNewGroupMembersCell" bundle:nil];
    [self.groupMemberTableView registerNib:nibRec forCellReuseIdentifier:kCreateNewGroupMembersCellIdentifier];

    //Image Work
    imagePickerViewController = [[UIImagePickerController alloc] init];
    imagePickerViewController.delegate = (id)self;
    imagePickerViewController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerViewController.allowsEditing = YES;
    _picChanged = NO;
    self.shouldUpdateScreen = YES;
    _memberSearchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    self.navigationController.navigationBar.barTintColor = [IVColors redColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    // set up what the navigation controllers should contain in each one of the screens.
    UISegmentedControl *selectWhichTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"chat-icon-seg"], [UIImage imageNamed:@"new-group-chat"], [UIImage imageNamed:@"new-mobile-chat"]]];
    for (int i = 0; i < selectWhichTypeSegmentedControl.numberOfSegments; i++) {
        [selectWhichTypeSegmentedControl setWidth:70 forSegmentAtIndex:i];
    }
    self.navSegmentedControl = selectWhichTypeSegmentedControl;

    [selectWhichTypeSegmentedControl sendActionsForControlEvents:UIControlEventTouchUpInside];
    [selectWhichTypeSegmentedControl addTarget:self action:@selector(segmentedControlTapped:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = selectWhichTypeSegmentedControl;

    // set up the "Cancel" Button
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel-circle"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    // set up the "Create" button
    UIBarButtonItem * createButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"create-ok"] style:UIBarButtonItemStylePlain target:self action:@selector(createNewGroup:)];
    createButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = createButton;

    self.hidesBottomBarWhenPushed = YES;
    self.tabBarController.tabBar.hidden = YES;//JAN 8, 16

    // set up the add group chat image to have a specfic color
   // self.groupChatImage.image = [[UIImage imageNamed:@"addImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.groupChatImage.image = [[UIImage imageNamed:@"camera_icn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.groupChatImage.tintColor = [IVColors redColor];

    // set the people in group label to be translucent when there is no one in the group
    self.peopleInGroupLabel.alpha = .25;
    
    // create a red line to put as a separator between the people in group view nad the actual table
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [aPath moveToPoint:CGPointMake(0, self.peopleInGroupBackgroundView.frame.size.height)];
    [aPath addLineToPoint:CGPointMake([UIScreen mainScreen].bounds.size.width, self.peopleInGroupBackgroundView.frame.size.height)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = aPath.CGPath;
    shapeLayer.strokeColor = [UIColor colorWithRed:233.f/255 green:88.f/255 blue:75.f/255 alpha:.3].CGColor;
    [self.peopleInGroupBackgroundView.layer addSublayer:shapeLayer];
    //
    
    // set up the label for the instructions
    UILabel *instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    instructionsLabel.text = @"New Group";
    instructionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    instructionsLabel.textAlignment = NSTextAlignmentCenter;
    [self.instructionsToolbar addSubview:instructionsLabel];
    
    //Settings - TextFlow related changes notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    [self updateNavigationBarTintColor];


}

//- updateScreenUI should not be called from main thread
-(void)updateScreenUI
{
    [self updateViewConstraintsForStoryBoard];
    GroupUtility* util = [[GroupUtility alloc]initWithData:0];
    self.groupMembersOriginal = [util getCreateGroupMemberDataList:self.groupID];
    
    if (self.groupName.length>0) {
        self.groupNameTextField.text = self.groupName;
        [self.createOrUpdateButton setTitle:@"Update" forState:UIControlStateNormal];
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.memberSelected = YES"];
        self.groupMembersInitiallySelected =  [[self.groupMembersOriginal filteredArrayUsingPredicate:resultPredicate] copy];
    }
    
    if (self.groupMembersInitiallySelected.count > 0) {
        self.navigationItem.titleView = nil;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        self.title = @"Edit Group";

        NSMutableString *currentlySelectedPeopleNames = [NSMutableString new];
        for (CreateGroupMemberData *selectedPerson in self.groupMembersInitiallySelected) {
            if(selectedPerson.memberName.length>0) {
                [currentlySelectedPeopleNames appendString:[[selectedPerson.memberName componentsSeparatedByString:@" "] objectAtIndex:0]];
                [currentlySelectedPeopleNames appendString:@", "];
            }
        }
        self.peopleInGroupLabel.text = [currentlySelectedPeopleNames copy];
        self.peopleInGroupLabel.alpha = 1;

        // hide the initial "New Group" bar.
        self.instructionsToolbar.hidden = YES;
        self.instructionsToolbarToTopOfScreenConstraint.constant = 0;
    }
    //NOV 2, 2016
    else if(self.groupID.length && self.groupName.length) {
        self.navigationItem.titleView = nil;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        self.title = @"Edit Group";
        // hide the initial "New Group" bar.
        self.instructionsToolbar.hidden = YES;
        self.instructionsToolbarToTopOfScreenConstraint.constant = 0;
    }
    //
    
    self.isImageSelected = NO;
    if (self.groupProfilePicPath.length>0) {
        self.groupChatImage.image = [UIImage imageWithContentsOfFile:self.groupProfilePicPath];
        self.isImageSelected = YES;
        self.groupChatImage.layer.cornerRadius = self.groupChatImage.frame.size.width / 2;
        self.groupChatImage.layer.masksToBounds = YES;
        self.groupChatImage.contentMode = UIViewContentModeScaleAspectFill;
    }
   
    //dp 7 MAR - on Edit edit image icon missing
    
    
    if (!self.groupChatImage.image) {
       // self.groupChatImage.image = [UIImage imageNamed:@"addImage"];
        self.groupChatImage.image = [UIImage imageNamed:@"camera_icn"];
        //To fix the bug: 10335
        self.groupChatImage.layer.cornerRadius = 1.0;
        self.groupChatImage.contentMode = UIViewContentModeCenter;
    }
    //dp///////////////////////////////
 
    self.groupMembersSearch = [self.groupMembersOriginal mutableCopy];
    self.groupMembersCurrentlySelected = [[NSMutableArray alloc]init];
    [self.groupNameTextField becomeFirstResponder];
    
    [self.groupMemberTableView reloadData];
    [self hideProgressBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.uiType = GROUP_SCREEN;
    [[UIStateMachine sharedStateMachineObj]setCurrentPresentedUI:self];
    
    if (self.shouldUpdateScreen) {
        [self showProgressBar];
        [self performSelectorOnMainThread:@selector(updateScreenUI) withObject:nil waitUntilDone:NO];
        self.shouldUpdateScreen = NO;
    }
    
    [self.navSegmentedControl setSelectedSegmentIndex:1];
    
    if (self.groupProfilePicPath && [self.groupProfilePicPath length]) {
        self.groupChatImage.layer.cornerRadius = self.groupChatImage.frame.size.width / 2;
        self.groupChatImage.layer.masksToBounds = YES;
        self.groupChatImage.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    if (!self.groupChatImage.image) {
        self.groupChatImage.image = [UIImage imageNamed:@"camera_icn"];
        self.groupChatImage.contentMode = UIViewContentModeCenter;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dismissThisViewController
{
    if(nil != alertView) {
        [alertView dismissWithClickedButtonIndex:-1 animated:NO];
    }
    alertView = nil;
    
    [self cancelGroupCreation:nil];
}

- (IBAction)cancelGroupCreation:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)updateViewConstraintsForStoryBoard
{
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        [self.verticalConstant setConstant:-15];
    }
    else
    {
        [self.verticalConstant setConstant:0];
    }
}


- (NSArray *)getCurrentlySelectedMembers
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.memberSelected = YES"];
    return [[self.groupMembersOriginal filteredArrayUsingPredicate:resultPredicate] mutableCopy];
}

- (IBAction)createNewGroup:(id)sender {

    // disable the top right button so it cant be clicked again
    self.navigationItem.rightBarButtonItem.enabled = NO;

    // get the navigation controller at the zero-th index of the tab bar controller
    UINavigationController *chatsNavigationController = (UINavigationController *)[[self.callingTabBarController viewControllers] objectAtIndex:0];

    // set that as the current navigation controller - this sets that navigation stack to be the stack that gets pushed onto
    self.callingTabBarController.selectedIndex = 0;
    [self.callingTabBarController setSelectedViewController:chatsNavigationController];
    //DEC 28, 2017 [appDelegate.stateMachineObj setNavigationController:chatsNavigationController];

    // do the work for creating the group
	//
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.memberSelected = YES"];
    self.groupMembersCurrentlySelected =  [[self.groupMembersOriginal filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    self.groupMembersDifferenceSelected = [self getModifiedDifferenceUpdateGroup];
    
    // KLog(@"Group Initially Selected %@",self.groupMembersInitiallySelected);
    // KLog(@"Group currently Selected %@",self.groupMembersCurrentlySelected);
    // KLog(@"Group difference Selected %@",self.groupMembersDifferenceSelected);
    
    if ([self isReadyGroupCreation]) {
        self.groupNameTextField.text = [self.groupNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
        NSString *timestamp=[NSString stringWithFormat:@"%ld",unixTime];
        NSString* fileName  = [[NSString alloc] initWithFormat:@"%@_%@.%@",self.groupNameTextField.text,timestamp,@"jpg"];
        
        if (self.isImageSelected) {
            NSData *imageData = UIImageJPEGRepresentation(self.groupChatImage.image,1.0);
            self.groupProfilePicPath = [IVFileLocator getNativeContactPicPath:fileName];
            [imageData writeToFile:self.groupProfilePicPath atomically:YES];
        }
        else
        {
            self.groupProfilePicPath = nil;
        }
        
        // KLog(@"Group Profile picture path %@",self.groupProfilePicPath);
        // KLog(@"Group Members selected %@",self.groupMembersCurrentlySelected);
        [self showProgressBar];
        if( self.groupID.length>0 ) {
            [self updateGroupWithGroupId:self.groupID groupName:self.groupNameTextField.text picPath:self.groupProfilePicPath memberList:self.groupMembersDifferenceSelected];
        }
        else {
            if( NETWORK_AVAILABLE != [Common isNetworkAvailable] ) {
                self.navigationItem.rightBarButtonItem.enabled = YES;
                [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
                [self hideProgressBar];
            }
            else {
                [self createGroupWithGroupName:self.groupNameTextField.text
                                       picPath:self.groupProfilePicPath
                                    memberList:self.groupMembersCurrentlySelected];
            }
        }
    }
}

- (BOOL)isMinimumUsersInGroup
{
    BOOL isMinimum = YES;
    switch (self.groupMembersCurrentlySelected.count) {
        case 0:
            //No member added in group
            if(self.groupID && self.groupID.length > 0)
                [self createAlertWithSubject:@"Error" andDescription:@"Group should contain atleast two members other than you"];
            else
                [self createAlertWithSubject:@"Error" andDescription:@"Select friends to create group"];
            isMinimum = NO;
            break;
        case 1:
            //Only one member added in group, no fine
            [self createAlertWithSubject:@"Error" andDescription:@"Group should contain atleast two members other than you"];
            isMinimum = NO;
            break;
        default:
            break;
    }
    return isMinimum;
}

-(BOOL)isReadyGroupCreation
{
    //Checking whether group name entered
    if ([self.groupNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <= 0) {
        [self createAlertWithSubject:@"Error" andDescription:@"Please enter group name"];
        return NO;
    }
    if (self.groupNameTextField.text.length > GROUP_NAME_LENGTH_LIMIT) {
        [ScreenUtility showAlert:GROUP_NAME_LIMIT_WARN];
        return NO;
    }
    if (![self isMinimumUsersInGroup]) {
        return NO;
    }
    
    if (self.groupMembersCurrentlySelected.count > GROUP_MEMBER_COUNT_MAX) {
        [self createAlertWithSubject:@"Error" andDescription:@"Group should not contain more than 200 members"];
        return NO;
    }
    
    return YES;
}

-(void)createAlertWithSubject:(NSString*)subject andDescription:(NSString*)description
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:subject message:description preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    alert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
    [self presentViewController:alert animated:YES completion:nil];
    
//    alertView = [[UIAlertView alloc] initWithTitle:subject message:description delegate:nil cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alertView show];
    
}

-(NSMutableArray*)getModifiedDifferenceUpdateGroup
{
    NSMutableArray *tempArray01 = [self.groupMembersInitiallySelected mutableCopy];
    NSMutableArray *tempArray02 = [self.groupMembersCurrentlySelected mutableCopy];
    [tempArray01 removeObjectsInArray:self.groupMembersCurrentlySelected];
    [tempArray02 removeObjectsInArray:self.groupMembersInitiallySelected];
    for(CreateGroupMemberData *obj in tempArray01)
    {
        obj.operationType = @"d";
    }
    for(CreateGroupMemberData *obj in tempArray02)
    {
        obj.operationType = @"a";
    }
    [tempArray01 addObjectsFromArray:tempArray02];
    return tempArray01;
}

#pragma mark -- Group Pic selection
- (IBAction)selectGroupPicture:(id)sender
{
    int isNetAvailable = [Common isNetworkAvailable];
    if(isNetAvailable == NETWORK_AVAILABLE)
    {
        [self presentViewController:imagePickerViewController animated:YES completion:nil];
    }
    else
    {
        ;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    BOOL processImage = [IVImageUtility isImageValidForServerUpload:info];
    NSURL *assetURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    NSString *extension = [assetURL pathExtension];
    if(!processImage)
    {
        [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];//KM
        [ScreenUtility showAlertMessage:[NSString stringWithFormat:@"Unsupported image type: %@",extension]];
    }
    else
    {
        [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];//KM
        int isNetAvailable = [Common isNetworkAvailable];
        if(isNetAvailable == NETWORK_AVAILABLE)
        {
            UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
            [self.groupChatImage setImage:image];
            [NSTimer scheduledTimerWithTimeInterval: 0.0f
                                             target: self
                                           selector: @selector(picChanged:)
                                           userInfo: image
                                            repeats: NO];
        }
        else
        {
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        }
    }
}

-(void)picChanged:(NSTimer*)timer
{
    UIImage *image = [timer userInfo];
    if(image != nil)
    {
        [self.groupChatImage setImage:image];
        self.isImageSelected = YES;
        if (self.isImageSelected) {
            self.groupChatImage.contentMode = UIViewContentModeScaleAspectFill;
            self.groupChatImage.layer.cornerRadius = self.groupChatImage.frame.size.width / 2;
            self.groupChatImage.layer.masksToBounds = YES;
        } else {
            self.groupChatImage.contentMode = UIViewContentModeCenter;
            self.groupChatImage.layer.cornerRadius = 0;
            self.groupChatImage.layer.masksToBounds = NO;
        }
        _picChanged = YES;
    }

    if (![self.groupNameTextField.text isEqualToString:@""] && ![self.peopleInGroupLabel.text isEqualToString:@"Select People Below to Add to Group"]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePickerViewController dismissViewControllerAnimated:NO completion:nil];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.groupNameTextField resignFirstResponder];
    [self.memberSearchTextField resignFirstResponder];
}

-(void)cancel
{
    [imagePickerViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -- TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.groupNameTextField) {
        NSString *text = [NSString stringWithString:self.groupNameTextField.text];
        text = [text stringByReplacingCharactersInRange:range withString:string];
        if(text.length > GROUP_NAME_LENGTH_LIMIT)
        {
            [ScreenUtility showAlert:GROUP_NAME_LIMIT_WARN];
        }
        if(text.length == 0)
        {
            self.groupNameTextField.text = @"";
        }
    }
    [self enableRightBarButtonItem];
    return YES;
}


#pragma mark - Search Bar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *text = [NSString stringWithString:searchText];
    text = [NSString stringWithString:text];
    if(text.length == 0)
    {
        isSearching = NO;
        self.groupMembersSearch =  [self.groupMembersOriginal copy];
        [self.groupMemberTableView reloadData];
    }
    else
    {
        isSearching = YES;
        if(isSearching && text != Nil && [text length] > 0)
        {
            NSPredicate *resultPredicateName = [NSPredicate predicateWithFormat:@"SELF.memberName CONTAINS[c] %@ OR SELF.memberPhoneNumber CONTAINS[c] %@", text,text];
          
            self.groupMembersSearch =  [[self.groupMembersOriginal filteredArrayUsingPredicate:resultPredicateName] mutableCopy];
         
            [self.groupMemberTableView reloadData];
        }
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)killScroll {
    [_groupMemberTableView setContentOffset:_groupMemberTableView.contentOffset animated:NO];
}

#pragma mark -- TableView Delegate and Datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kCreateNewGroupMembersCellIdentifier;
    CreateNewGroupMembersCell *cell = (CreateNewGroupMembersCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    CreateGroupMemberData *groupMemberData = [self.groupMembersSearch objectAtIndex:indexPath.row];
    [cell configureCellWithGroupMemberData:groupMemberData];
    cell.accessoryType = groupMemberData.memberSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    [cell layoutIfNeeded];
    [cell layoutSubviews];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groupMembersSearch count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Boolean isNowChecked = NO;
    if([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark)
    {
        isNowChecked = YES;
    }
    if(isNowChecked)
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        CreateGroupMemberData *dic = [self.groupMembersSearch objectAtIndex:indexPath.row];
        dic.memberSelected = NO;
        dic.operationType = @"d";
    }
    else
    {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        CreateGroupMemberData *dic = [self.groupMembersSearch objectAtIndex:indexPath.row];
        dic.operationType = @"a";
        dic.memberSelected = YES;
    }

    NSArray *currentlySelectedPeople = [self getCurrentlySelectedMembers];

    NSMutableString *currentlySelectedPeopleNames = [NSMutableString new];
    for (CreateGroupMemberData *selectedPerson in currentlySelectedPeople) {
        NSString* name = selectedPerson.memberName;
        if(!name.length)
            name = selectedPerson.memberPhoneNumber;
        [currentlySelectedPeopleNames appendString:[[name componentsSeparatedByString:@" "] objectAtIndex:0]];
        [currentlySelectedPeopleNames appendString:@", "];
    }
    NSString *selectedPeopleString = @"";
    if (currentlySelectedPeopleNames.length >= 2) {
        selectedPeopleString = [currentlySelectedPeopleNames substringToIndex:currentlySelectedPeopleNames.length - 2];
        [UIView animateWithDuration:.25 animations:^{self.peopleInGroupLabel.alpha = 1;}];
    } else {
        selectedPeopleString = @"Select People Below to Add to Group";
        [UIView animateWithDuration:.25 animations:^{self.peopleInGroupLabel.alpha = .25;}];
    }
    self.peopleInGroupLabel.text = [NSString stringWithFormat:@"%@", selectedPeopleString];

    [self enableRightBarButtonItem];
}


#pragma mark -- Create and Update action
-(void)createGroupWithGroupName:(NSString*)name picPath:(NSString*)path memberList:(NSMutableArray*)members
{
    NSMutableDictionary* groupDic = [[NSMutableDictionary alloc]init];
    [groupDic setValue:name forKey:@"group_pic_name"];
    [groupDic setValue:path forKey:@"group_pic_path"];
    
    
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [requestDic setValue:name forKey:@"group_desc"];
    [requestDic setValue:name forKey:@"group_about"];
    [requestDic setValue:@"jpg" forKey:@"group_pic_file_type"];
    [requestDic setValue:[NSNumber numberWithInt:1] forKey:@"group_type"];
    [requestDic setValue:name forKey:@"file_name"];
    [requestDic setValue:@"jpg" forKey:@"file_type"];
    NSMutableArray* memberList = [[NSMutableArray alloc]init];
    for(CreateGroupMemberData* data in members)
    {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        if([data.memberIvId isEqual:@"0"])
        {
            [dic setValue:data.memberPhoneNumber forKey:@"contact"];
            [dic setValue:@"tel" forKey:@"type"];
        }
        else
        {
            [dic setValue:data.memberIvId forKey:@"contact"];
            [dic setValue:data.memberType forKey:@"type"];
        }
        
        [memberList addObject:dic];
    }
    [requestDic setValue:memberList forKey:@"member_contacts"];
    
    [groupDic setValue:requestDic forKey:@"group_server_request"];
    self.groupInfo = nil;
    CreateGroupAPI* api = [[CreateGroupAPI alloc]initWithRequest:groupDic];
    [api callNetworkRequest:groupDic withSuccess:^(CreateGroupAPI *req, NSMutableDictionary *responseObject) {
        
        NSString* groupId = [responseObject valueForKey:@"group_id"];
        //move profile pic with correct name
        NSString* newName = [IVFileLocator getNativeContactPicPath:[NSString stringWithFormat:@"%@.jpg",groupId]];
        NSString* oldName = [req.request valueForKey:@"group_pic_path"];
        
        if(oldName != nil)
        {
            NSError * err = NULL;
            NSFileManager * fm = [[NSFileManager alloc] init];
            BOOL result = [fm moveItemAtPath:oldName toPath:newName error:&err];
            if(!result)
                KLog(@"Error: %@", err);
        }
        
        NSMutableDictionary* gInfo = [self createGroupMessageForGroupName:name groupId:groupId picPath:newName memberList: members isNewGroup:YES];
        
        self.groupInfo = [[NSMutableDictionary alloc]initWithDictionary:gInfo];
    
        NSString *groupIDStr = [[NSMutableString alloc]init];
        groupIDStr=groupId;
        
        NSManagedObjectContext* moc = [AppDelegate sharedPrivateQueueContext];
        GroupUtility* util = [[GroupUtility alloc]initWithData:0];
        if( [util checkIfGroupAlreadyExist:groupIDStr] )
        {
            
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:moc];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSPredicate* condition = [NSPredicate predicateWithFormat:@"groupId = %@",groupIDStr];
            [request setPredicate:condition];
            
            NSError *error;
            NSArray *array = [moc executeFetchRequest:request error:&error];
            if(array != Nil && [array count]>0)
            {
                for(ContactData* data in array)
                {
                    data.contactName = name;
                    NSString* picUri = path;
                    data.contactPicURI = picUri;
                    NSString *imgName =[data.groupId stringByAppendingPathExtension:@"jpg"];
                    data.contactPic = imgName;
                }
            }
            if (![moc save:&error]) {
                KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
            }
            [self hideProgressBar];
            [self cancelGroupCreation:nil];
        }
        else
        {
            //group created first time- creating header
            ContactData* data = [NSEntityDescription insertNewObjectForEntityForName:@"ContactData" inManagedObjectContext:moc];
            ContactDetailData* detailData = [NSEntityDescription insertNewObjectForEntityForName:@"ContactDetailData" inManagedObjectContext:moc];
            data.contactName = name;
            
            data.contactId = [NSNumber numberWithLongLong:(LONG_MAX - [[responseObject valueForKey:@"group_id"]longLongValue])];
            data.contactType = [NSNumber numberWithInteger:ContactTypeIVGroup];
            data.isIV = [NSNumber numberWithBool:YES];
            
            data.groupId = groupIDStr;
            // data.localSyncTime = [groupHeader valueForKey:@"creation_date_long"];
            data.firstName = data.contactName;
            
            detailData.contactId = data.contactId;
            detailData.ivUserId = [NSNumber numberWithInt:1];//[groupHeader valueForKey:@"group_creator_userid"];
            detailData.contactDataValue = data.groupId;
            detailData.contactDataType = PHONE_MODE;
            detailData.localSync = [NSNumber numberWithBool:YES];
            detailData.serverSync = [NSNumber numberWithBool:YES];
            
            NSString* picUri = path;
            data.contactPicURI = picUri;
            NSString *imgName =[data.groupId stringByAppendingPathExtension:@"jpg"];
            data.contactPic = imgName;

            [data addContactIdDetailRelationObject:detailData];
            [moc insertObject:data];
            
            NSError* error = Nil;
            if (![moc save:&error]) {
                KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
            }
            ///group member info save/////
            {
            GroupMemberData* data = [NSEntityDescription insertNewObjectForEntityForName:@"GroupMemberData" inManagedObjectContext:moc];
            data.groupId = groupIDStr;
            //TODO Discuss with Divya NSString *number=[appDelegate.confgReader getFormattedUserName];
            NSString *number=[appDelegate.confgReader getLoginId];
            NSString *ivID=[NSString stringWithFormat:@"%ld",[appDelegate.confgReader getIVUserId]];
            NSString *displayName=[appDelegate.confgReader getLoginId];
            UserProfileModel *profileData = [Profile sharedUserProfile].profileData;
            displayName=profileData.screenName;
            data.memberContactDataValue = [Common setPlusPrefixChatWithMobile:number];
            data.isAdmin = [NSNumber numberWithInt:0];//[member valueForKey:@"is_admin"];
            data.isOwner = [NSNumber numberWithInt:1];//[member valueForKey:@"is_owner"];
            data.isAgent = [NSNumber numberWithInt:0];//[member valueForKey:@"is_agent"];
            data.isMember = [NSNumber numberWithInt:1];//[member valueForKey:@"is_member"];
            data.memberId = ivID;
            data.memberType = IV_TYPE;
            data.memberDisplayName =displayName;
            data.status = [NSNumber numberWithInteger:GroupMemberStatusActive];
            [moc insertObject:data];
            ////owner////
            }
            for(CreateGroupMemberData* member in members)
            {
                GroupMemberData* data = [NSEntityDescription insertNewObjectForEntityForName:@"GroupMemberData" inManagedObjectContext:moc];
                data.groupId = groupIDStr;
                data.memberContactDataValue = [Common setPlusPrefixChatWithMobile:member.memberPhoneNumber];
                data.isAdmin = [NSNumber numberWithInt:0];//[member valueForKey:@"is_admin"];
                data.isOwner = [NSNumber numberWithInt:0];//[member valueForKey:@"is_owner"];
                data.isAgent = [NSNumber numberWithInt:0];//[member valueForKey:@"is_agent"];
                data.isMember = [NSNumber numberWithInt:1];//[member valueForKey:@"is_member"];
                data.memberId = member.memberIvId;
                if([member.memberType isEqualToString:@"tel"])
                    data.memberType=@"tel";
                else
                    data.memberType = IV_TYPE;
                data.memberDisplayName = member.memberName;
                if([member valueForKey:@"memberIvId"])
                    KLog(@"key exist");
                //         if([member valueForKey:@"profile_pic_path"])
                //            {
                //    data.picLocalPath = [NSString stringWithFormat:@"%@.png",data.memberId];
                //     data.picRemoteUri =[NSString stringWithFormat:@"%@%@",SERVER_PIC_URL,[member valueForKey:@"profile_pic_path"]];
                //           }
                if([member.memberType isEqualToString:@"tel"])
                    data.memberId=member.memberPhoneNumber;
                else
                    data.memberId = member.memberIvId;
                NSString* status = member.operationType;
                if([status isEqualToString:@"a"])
                    data.status = [NSNumber numberWithInteger:GroupMemberStatusActive];
                else if([status isEqualToString:@"d"])
                    data.status = [NSNumber numberWithInteger:GroupMemberStatusDeleted];
                else
                    data.status = [NSNumber numberWithInteger:GroupMemberStatusLeft];
                [moc insertObject:data];
            }
            NSError* errorCreatingMembersInfo = Nil;
            if (![moc save:&errorCreatingMembersInfo]) {
                KLog(@"CoreData: Whoops, couldn't save: %@", [errorCreatingMembersInfo localizedDescription]);
            }
            
             [self hideProgressBar];
             [self cancelGroupCreation:nil];
        }//else ends
        
        [self hideProgressBar];
        if(gInfo) {
            [self performSelectorOnMainThread:@selector(gotoGroupChat) withObject:nil waitUntilDone:NO];
        }
        
    } failure:^(CreateGroupAPI *req, NSError *error) {
        KLog(@"unable to create group");
        [self createAlertWithSubject:@"Error" andDescription:@"Unable to create group"];
        [self hideProgressBar];
        //error alert message
    }];
}

-(void)gotoGroupChat {
    KLog(@"gotoGroupChat");
    [[UIDataMgt sharedDataMgtObj] setCurrentChatUser:self.groupInfo];
    BaseUI* uiObj = [[InsideConversationScreen alloc]
                     initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];

    [appDelegate.tabBarController setSelectedIndex:2];
    //[appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[0]];
    [appDelegate.getNavController pushViewController:uiObj animated:YES];
}

-(void)updateGroupWithGroupId:(NSString*)groupId groupName:(NSString*)name picPath:(NSString*)path memberList:(NSMutableArray*)members
{
    if(!_picChanged)
        path = Nil;
    NSMutableDictionary* groupDic = [[NSMutableDictionary alloc]init];
    [groupDic setValue:name forKey:@"group_pic_name"];
    [groupDic setValue:path forKey:@"group_pic_path"];
    
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [requestDic setValue:groupId forKey:@"group_id"];
    [requestDic setValue:@"u" forKey:@"group_operation"];
    [requestDic setValue:name forKey:@"group_desc"];
    [requestDic setValue:name forKey:@"group_about"];
    [requestDic setValue:@"jpg" forKey:@"group_pic_file_type"];
    [requestDic setValue:groupId forKey:@"file_name"];
    [requestDic setValue:@"jpg" forKey:@"file_type"];
    [requestDic setValue:[NSNumber numberWithInt:1] forKey:@"group_type"];
    NSMutableArray* memberList = [[NSMutableArray alloc]init];
    
    for(CreateGroupMemberData* data in members)
    {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        NSString *ivIDWithPlus=[@"+" stringByAppendingString:data.memberIvId];
        if([ivIDWithPlus isEqual:data.memberPhoneNumber])
        {
            [dic setValue:data.memberIvId forKey:@"contact"];
            [dic setValue:@"tel" forKey:@"type"];
        }
        else if([data.memberIvId isEqual:data.memberPhoneNumber])
        {
            [dic setValue:data.memberPhoneNumber forKey:@"contact"];
            [dic setValue:@"tel" forKey:@"type"];
        }
        else if([data.memberIvId isEqual:@"0"])
        {
            NSString *firstCharCheckIfPlus =[data.memberPhoneNumber substringToIndex:1];
            // for deleting non iv number
            if([firstCharCheckIfPlus isEqualToString:@"+"])
            {
                NSString *numberWithoutPlus = [data.memberPhoneNumber substringFromIndex:1];
                [dic setValue:numberWithoutPlus forKey:@"contact"];
                [dic setValue:@"tel" forKey:@"type"];
            }
            else
            {
                //for adding non iv number
                [dic setValue:data.memberPhoneNumber forKey:@"contact"];
                [dic setValue:@"tel" forKey:@"type"];
            }
        }
        else
        {
            [dic setValue:data.memberIvId forKey:@"contact"];
            [dic setValue:data.memberType forKey:@"type"];
        }
        
        [dic setValue:data.operationType forKey:@"operation"];
        [memberList addObject:dic];
    }
    
    [requestDic setValue:memberList forKey:@"member_updates"];
    [groupDic setValue:requestDic forKey:@"group_server_request"];
    
    UpdateGroupAPI* api = [[UpdateGroupAPI alloc] initWithRequest:groupDic];
    [api callNetworkRequest:groupDic withSuccess:^(UpdateGroupAPI *req, NSMutableDictionary *responseObject) {
        NSString* groupId = [responseObject valueForKey:@"group_id"];
        //move profile pic with correct name
        NSString* newName = [IVFileLocator getNativeContactPicPath:[NSString stringWithFormat:@"%@.jpg",groupId]];
        NSString* oldName = [req.request valueForKey:@"group_pic_path"];
        
        if(oldName != nil)
        {
            NSError * err = NULL;
            NSFileManager * fm = [[NSFileManager alloc] init];
            //remove existing file
            BOOL result = [IVFileLocator deleteFileAtPath:newName];
            result = [fm moveItemAtPath:oldName toPath:newName error:&err];
            if(!result)
                KLog(@"Error: %@", err);
        }
        self.groupName = self.groupNameTextField.text;
        [self createGroupMessageForGroupName:name groupId:groupId picPath:newName memberList:members isNewGroup:NO];
        NSManagedObjectContext* moc = [AppDelegate sharedPrivateQueueContext];
        GroupUtility* util = [[GroupUtility alloc]initWithData:0];
        if([util checkIfGroupAlreadyExist:groupId])
        {
            
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:moc];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSPredicate* condition = [NSPredicate predicateWithFormat:@"groupId = %@",groupId];
            [request setPredicate:condition];
            
            NSError *error;
            NSArray *array = [moc executeFetchRequest:request error:&error];
            if(array != Nil && [array count]>0)
            {
                for(ContactData* data in array)
                {
                    data.contactName = name;
                    //NSString* existingPicUri = data.contactPicURI;
                    NSString* picUri = path;
                    data.contactPicURI = picUri;
                    NSString *imgName =[data.groupId stringByAppendingPathExtension:@"jpg"];
                    data.contactPic = imgName;
                }
            }
            if (![moc save:&error]) {
                KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
        
        [self updateGroupMembers:groupId memberList:members];
        [self hideProgressBar];
        [self cancelGroupCreation:nil];
        [self updateScreenUI];
    } failure:^(UpdateGroupAPI *req, NSError *error) {
        KLog(@"unable to update group");
        [self createAlertWithSubject:@"Error" andDescription:[NSString stringWithFormat:@"Unable to update group. %@", error.localizedDescription]];
        [self hideProgressBar];
        //error
    }];
}

//- updateGroupMembers should not be called from main thread
-(void)updateGroupMembers:(NSString*)groupId memberList:(NSMutableArray*)memberList
{
    NSManagedObjectContext* moc = [AppDelegate sharedPrivateQueueContext];
    
    for(CreateGroupMemberData* member in memberList)
    {
        if([self checkIfMember:member.memberIvId existInGroup:groupId])
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GroupMemberData" inManagedObjectContext:moc];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSPredicate* condition = [NSPredicate predicateWithFormat:@"groupId = %@ AND memberId = %@",groupId,member.memberIvId];
            [request setPredicate:condition];
            
            NSError *error;
            NSArray *array = [moc executeFetchRequest:request error:&error];
            
            if(array != Nil && [array count]>0)
                {
                    for(GroupMemberData* data in array)
                    {   data.groupId = groupId;
                        data.memberContactDataValue = [Common setPlusPrefixChatWithMobile:member.memberPhoneNumber];
                        data.isAdmin = [NSNumber numberWithInt:0];//[member valueForKey:@"is_admin"];
                        data.isOwner = [NSNumber numberWithInt:0];//[member valueForKey:@"is_owner"];
                        data.isAgent = [NSNumber numberWithInt:0];//[member valueForKey:@"is_agent"];
                       // if([member.operationType isEqualToString:@"d"])
                        data.isMember = [NSNumber numberWithInt:1];//[member valueForKey:@"is_member"];
                        if([member.memberType isEqualToString:@"tel"])
                            data.memberType=@"tel";
                        else
                            data.memberType = IV_TYPE;
                        data.memberDisplayName = member.memberName;
                        if([member valueForKey:@"memberIvId"])
                            KLog(@"key exist");
                        if([member.memberType isEqualToString:@"tel"])
                            data.memberId=member.memberPhoneNumber;
                        else
                            data.memberId = member.memberIvId;
                        NSString* status = member.operationType;
                        if([status isEqualToString:@"a"])
                            data.status = [NSNumber numberWithInteger:GroupMemberStatusActive];
                        else if([status isEqualToString:@"d"])
                            data.status = [NSNumber numberWithInteger:GroupMemberStatusDeleted];
                        else
                            data.status = [NSNumber numberWithInteger:GroupMemberStatusLeft];
                    }
                    if (![moc save:&error]) {
                        KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
                    }
            }//if array count!= nil
        }//if member already exist
        else //new member
        {
            if([member.operationType isEqualToString:@"a"])
            {
                GroupMemberData* data = [NSEntityDescription insertNewObjectForEntityForName:@"GroupMemberData" inManagedObjectContext:moc];
                data.groupId = groupId;
                data.memberContactDataValue = [Common setPlusPrefixChatWithMobile:member.memberPhoneNumber];
                data.isAdmin = [NSNumber numberWithInt:0];;//[member valueForKey:@"is_admin"];
                data.isOwner = [NSNumber numberWithInt:0];;//[member valueForKey:@"is_owner"];
                data.isAgent = [NSNumber numberWithInt:0];//[member valueForKey:@"is_agent"];
                data.isMember = [NSNumber numberWithInt:1];//[member valueForKey:@"is_member"];
                data.memberId = member.memberIvId;
                if([member.memberType isEqualToString:@"tel"])
                    data.memberType=@"tel";
                else
                    data.memberType = IV_TYPE;
                data.memberDisplayName = member.memberName;
                if([member valueForKey:@"memberIvId"])
                    KLog(@"key exist");
            
                if([member.memberType isEqualToString:@"tel"])
                    data.memberId=member.memberPhoneNumber;
                else
                    data.memberId = member.memberIvId;
                NSString* status = member.operationType;
                if([status isEqualToString:@"a"])
                    data.status = [NSNumber numberWithInteger:GroupMemberStatusActive];
                else if([status isEqualToString:@"d"])
                    data.status = [NSNumber numberWithInteger:GroupMemberStatusDeleted];
                else
                    data.status = [NSNumber numberWithInteger:GroupMemberStatusLeft];
                ////
                [moc insertObject:data];
                NSError* errorCreatingMembersInfo = Nil;
                if (![moc save:&errorCreatingMembersInfo]) {
                    KLog(@"CoreData: Whoops, couldn't save: %@", [errorCreatingMembersInfo localizedDescription]);
                }
                
            }//if ends:operation type "a"
            
        }//else of new member
        
    }//for loop
}

//- checkIfMember should not be called from main thread
-(BOOL)checkIfMember:(NSString*)memberId existInGroup:(NSString*)groupIdStr
{
    NSManagedObjectContext* moc = [AppDelegate sharedPrivateQueueContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GroupMemberData" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"groupId = %@ AND memberId = %@",groupIdStr,memberId];
    [request setPredicate:condition];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil || [array count] <= 0)
    {
        return false;
    }
    
    return true;
}

#pragma mark --create message for group
//- createGroupMessageForGroupName should not be called from main thread
-(NSMutableDictionary*)createGroupMessageForGroupName:(NSString*)name groupId:(NSString*)groupId
                                              picPath:(NSString*)picPath memberList:(NSMutableArray*)memberList
                                           isNewGroup:(BOOL)isNewGroup
{
    GroupUtility* util = [[GroupUtility alloc]initWithData:0];
    NSMutableDictionary* groupInfo =  [util createGroupMessageForGroupName:name
                                                                  groupId:groupId
                                                                  picPath:picPath
                                                               memberList:memberList
                                                               isNewGroup:isNewGroup];
    
    return groupInfo;
}

-(void)fetchGroupInfo:(NSString*)groupId
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setValue:groupId forKey:@"group_id"];
    [dic setValue:[NSNumber numberWithBool:YES] forKey:@"fetch_members"];
    FetchGroupInfoAPI* api = [[FetchGroupInfoAPI alloc]initWithRequest:dic];
    [api callNetworkRequest:dic withSuccess:^(FetchGroupInfoAPI *req, NSMutableDictionary *responseObject) {
        GroupUtility* util = [[GroupUtility alloc]initWithData:0];
        [util updateGroupMemberInfoFromServerResponse:responseObject syncMember:YES];
        [self hideProgressBar];
        [self cancelGroupCreation:nil];
    } failure:^(FetchGroupInfoAPI *req, NSError *error) {
        [self hideProgressBar];
        [self cancelGroupCreation:nil];
    }];
}

- (IBAction)segmentedControlTapped:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    [self.tabBarController setSelectedViewController:[self.tabBarController.viewControllers objectAtIndex:segmentedControl.selectedSegmentIndex]];
}

#pragma mark - Toolbar Delegate
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTop;
}

- (void)enableRightBarButtonItem
{
    if (self.groupNameTextField.text.length >= 0 && [self getCurrentlySelectedMembers].count > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    [self.groupMemberTableView reloadData];
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

@end
