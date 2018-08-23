//
//  ViewForGroupChatContactScreen.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 8/14/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ViewForGroupChatContactScreen.h"
#import "GroupChatMembersTableViewCell.h"
#import "IVFileLocator.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "Contacts.h"
#import "GroupMemberData.h"
#import "FetchGroupInfoAPI.h"
#import "GroupUtility.h"
#import "ContactSyncUtility.h"
#import "Common.h"
#import "ScreenUtility.h"
#import "ImgMacro.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"
#import "Setting.h"
#import "TableColumns.h"
#import "IVImageUtility.h"
#import "ConfigurationReader.h"
#import "InsideConversationScreen.h"

#define TAG_GRP_OWNER   0x234321

@interface ViewForGroupChatContactScreen ()  <UIToolbarDelegate>

//@property (nonatomic) BOOL validatedNumberOfPeopleInGroup;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIImageView *nonBlurredImageView;
@property (nonatomic, strong) UIView *upperColorView;
@property (nonatomic, strong) UIToolbar *toolbarOnTopOfScreen;
@property (nonatomic, strong) UIBarButtonItem *space, *space2;
@property (nonatomic, strong) UIView *groupImageView;

@end

@implementation ViewForGroupChatContactScreen
@synthesize groupImage;

#define kCellIdentifier @"CellIdentifierGroupChat"

- (id)initWithFrame:(CGRect)frame withPhoneNumber:(NSString*)phoneNumber
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (AppDelegate *)APP_DELEGATE;
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        _groupIDString = phoneNumber;
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont systemFontOfSize:17]];
    }
    return self;
}

-(void)fetchGroupInfo:(NSString*)groupId
{
    KLog(@"fetchGroupInfo");
    [self hideProgressBar];
    BOOL fetchFromServer = [[ConfigurationReader sharedConfgReaderObj]getFetchGroupInfoFromServer];
    grpMemberList = [self getListOfGroupMembers];
    int netStatus = [Common isNetworkAvailable];
    if( [grpMemberList count] && fetchFromServer &&  netStatus != NETWORK_AVAILABLE) {
        //TODO No internet connection to get the latest group info
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }else if (netStatus != NETWORK_AVAILABLE) {
         //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    
    if([grpMemberList count] < 2) {
        //- group members count should be atleast 2 excluding owner
        //TODO -- what to do?
        grpMemberList = nil;
    }
    
    if([grpOwner count] <= 0) {
        grpMemberList = nil;
    }
    
    if( (![grpMemberList count] || fetchFromServer ) && [Common isNetworkAvailable] == NETWORK_AVAILABLE)
    {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        [dic setValue:groupId forKey:@"group_id"];
        [dic setValue:[NSNumber numberWithBool:YES] forKey:@"fetch_members"];
        grpMemberList = nil;//FEB 20, 2017
        if(!grpMemberList || ![grpMemberList count]) {
            [self showProgressBar];
            [dic setValue:[NSNumber numberWithBool:NO] forKey:@"all_groups"];
            KLog(@"### FetchGroupInfoAPI");
            FetchGroupInfoAPI* api = [[FetchGroupInfoAPI alloc]initWithRequest:dic];
            [api callNetworkRequest:dic withSuccess:^(FetchGroupInfoAPI *req, NSMutableDictionary *responseObject) {
                //NSLog(@"FetchGroupAPI resp = %@", responseObject);
                [self hideProgressBar];
                GroupUtility* utility = [[GroupUtility alloc]initWithData:0];
                [utility updateGroupMemberInfoFromServerResponse:responseObject syncMember:YES];
                grpMemberList = [self getListOfGroupMembers];
                if (grpMemberList) {
                    //May 2017 Bhaskar --> only once need to fetch group info from server
                    [[ConfigurationReader sharedConfgReaderObj]setFetchGroupInfoFromServer:FALSE];
                }
                [tableToSeeTheUserPhoneNo reloadData];
                if ([self checkIfLoggedUserIsOwnerOfGroup:nil]) {
                    self.editLeaveButton.title = @"Edit";
                }
                [self checkAndHideLeaveOption:grpMemberList];
                [self hideProgressBar];
            } failure:^(FetchGroupInfoAPI *req, NSError *error) {
                [self hideProgressBar];
                NSString* errorString = [error.userInfo valueForKey:@"error_reason"];
                if(error.code < 0) {
                    [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
                }
                else {
                    [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
                }
                grpMemberList = [self getListOfGroupMembers];
            }];
        }
    }
    
    self.editLeaveButtonClicked = NO;
    if([grpMemberList count]) {
        [tableToSeeTheUserPhoneNo reloadData];
        if ([self checkIfLoggedUserIsOwnerOfGroup:nil]) {
            self.editLeaveButton.title = @"Edit";
        }
        [self checkAndHideLeaveOption:grpMemberList];
    }
}

- (void)initializeVariable
{
    // create the toolbar for the top view
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height + 44)];
    [toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [toolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
    toolbar.tintColor = [UIColor whiteColor];
    toolbar.delegate = self;
    self.toolbarOnTopOfScreen = toolbar;

    // create close button for the top right of the screen
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:nil action:nil];
    [closeButton setTitleTextAttributes:@{NSFontAttributeName: //[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]
                                          //DC MAY 19 2016
                                          [UIFont systemFontOfSize:17.0],
                                        NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    self.cancelButton = closeButton;

    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.space = space;

    UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.space2 = space2;

    UIBarButtonItem *titleView = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonSystemItemDone target:nil action:nil];
    self.nameLabel = titleView;
    
    [titleView setTitleTextAttributes:@{NSFontAttributeName: //[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]
                                        //DC MAY 19 2016
                                        [UIFont systemFontOfSize:17.0],
                                        NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];

    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonSystemItemEdit target:nil action:nil];
    self.editLeaveButton = editButton;

    toolbar.items = @[closeButton, space, editButton];
 

    nameLabelCreatedTime = [[UILabel alloc] initWithFrame:CGRectMake(60, 36, 200, 30)];
    nameLabelCreatedTime.textAlignment = NSTextAlignmentLeft;
    nameLabelCreatedTime.backgroundColor = [UIColor clearColor];
    nameLabelCreatedTime.textColor = [UIColor blackColor];
    [nameLabelCreatedTime setFont:[UIFont fontWithName:HELVETICANEUE size:SIZE_12]];
    
    ContactData* data = [[Contacts sharedContact]getGroupHeaderForGroupId:_groupIDString usingMainQueue:YES];
    if(data)
    {
        NSString *dateString = [ScreenUtility dateConverter:data.localSyncTime dateFormateString:NSLocalizedString(@"DATE_FORMATE_CHATGRID",nil)];
        if (dateString.length > 0) {
            nameLabelCreatedTime.text = [dateString hasSuffix:@"ago"]?[NSString stringWithFormat:@"Created %@",dateString]:[NSString stringWithFormat:@"Created on %@",dateString];
            [self addSubview:nameLabelCreatedTime];
        }
    }

    tableToSeeTheUserPhoneNo = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    tableToSeeTheUserPhoneNo.dataSource = self;
    tableToSeeTheUserPhoneNo.delegate = self;
    tableToSeeTheUserPhoneNo.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableToSeeTheUserPhoneNo.allowsSelection = YES;
    tableToSeeTheUserPhoneNo.allowsMultipleSelection = NO;

    [self addSubview:tableToSeeTheUserPhoneNo];
    UINib *myNib = [UINib nibWithNibName:@"GroupChatMembersTableViewCell" bundle:nil];
    [tableToSeeTheUserPhoneNo registerNib:myNib forCellReuseIdentifier:kCellIdentifier];
    
    if ([self checkIfLoggedUserIsOwnerOfGroup:nil]) {
        self.editLeaveButton.title = @"Edit";
    } else {
        self.editLeaveButton.title = @"Leave";
        self.editLeaveButton.tag = 1;
    }
    
    self.editLeaveButton.enabled = NO;

    // set up the blurred image view
    UIImageView *blurredImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, toolbar.frame.size.height -[tableToSeeTheUserPhoneNo.delegate tableView:tableToSeeTheUserPhoneNo heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], self.frame.size.width, [tableToSeeTheUserPhoneNo.delegate tableView:tableToSeeTheUserPhoneNo heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]])];
    self.blurredImageView = blurredImageView;

    self.nonBlurredImageView = [[UIImageView alloc] initWithFrame:blurredImageView.frame];
    self.upperColorView = [[UIView alloc] initWithFrame:blurredImageView.frame];
    self.nonBlurredImageView.clipsToBounds = YES;
    self.blurredImageView.clipsToBounds = YES;

    [self addSubview:self.nonBlurredImageView];
    [self addSubview:blurredImageView];
    [self addSubview: self.upperColorView];
    self.blurredImageView.hidden = YES;
    self.nonBlurredImageView.hidden = YES;
    self.upperColorView.hidden = YES;
    [self fetchGroupInfo:_groupIDString];//TODO
    toolbar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
    [self addSubview:toolbar];
    
    self.editLeaveButtonClicked = NO;
}

-(void)checkAndHideLeaveOption:(NSArray*)groupMembers
{
    KLog(@"checkAndHideLeaveOption");
    
    NSString* ivID = [NSString stringWithFormat:@"%ld",[appDelegate.confgReader getIVUserId]];
    NSString* loggedInNumber = [appDelegate.confgReader getLoginId];
    NSArray *filtered = [groupMembers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(memberId == %@ OR memberId == %@)", ivID,loggedInNumber]];
    
    if(!filtered.count && grpOwner.count) {
        filtered = [grpOwner filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(memberId == %@ OR memberId == %@)", ivID,loggedInNumber]];
    }
    
    if(self.editLeaveButtonClicked)
        return;
    
    if(filtered.count > 0)
	{
        GroupMemberData* data = [filtered objectAtIndex:0];
        if([data.status integerValue] != GroupMemberStatusActive) {
            if(self.editLeaveButton.tag == 1) {
                self.editLeaveButton.enabled = NO;
            }
        } else {
            self.editLeaveButton.enabled = YES;
        }
    }
    else {
        if(self.editLeaveButton.tag == 1) {
            self.editLeaveButton.enabled = NO;
        }
    }
}


-(BOOL)checkIfLoggedUserIsOwnerOfGroup:(NSString*)sender
{
    NSString* ivID = [NSString stringWithFormat:@"%ld",[appDelegate.confgReader getIVUserId]];
    for(GroupMemberData* dic in grpOwner)
    {
        if([dic.isOwner boolValue] && [dic.memberId isEqualToString:ivID])
            return YES;
    }
    return NO;
}

#pragma mark - ProgressBar
-(void)showProgressBar
{
    if(progressBar == nil)
    {
        progressBar = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:progressBar];
        progressBar.delegate = self;
        [progressBar show:YES];
    }
}

-(void)hideProgressBar
{
    [progressBar hide:YES];
    [progressBar removeFromSuperview];
    progressBar = nil;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case GroupInfoSectionImage:
            return 1;
        case GroupInfoSectionTitle:
            return 1;
        case GroupInfoSectionOwner:
            return [grpOwner count];
        case GroupInfoSectionMember:
            return [grpMemberList count];
        default:
            break;
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case GroupInfoSectionImage: return self.frame.size.width;
        case GroupInfoSectionTitle: return 44;
        default: return 60;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch(indexPath.section)
    {
        case GroupInfoSectionImage:
        {
            static NSString *cellIdentifier = @"groupImageCell";
            UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            if (self.groupImage) {
                UIImageView *groupImageView = (UIImageView *)[cell viewWithTag:27];
                if (!groupImageView) {
                    groupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [tableView.delegate tableView:tableView heightForRowAtIndexPath:indexPath])];
                    groupImageView.tag = 27;
                }
                groupImageView.backgroundColor = [UIColor lightGrayColor];
                groupImageView.contentMode = UIViewContentModeScaleAspectFill;
                groupImageView.image = self.groupImage;
                groupImageView.clipsToBounds = NO;
                self.groupImageView = groupImageView;
                [cell addSubview:groupImageView];
            } else {
                UIImageView *groupImageView = (UIImageView *)[cell viewWithTag:27];
                if (!groupImageView) {
                    groupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width, [tableView.delegate tableView:tableView heightForRowAtIndexPath:indexPath])];
                    groupImageView.tag = 27;
                }
                groupImageView.backgroundColor = [UIColor lightGrayColor];
                groupImageView.image = [UIImage imageNamed:@"default_profile_img_group"];
                self.groupImageView = groupImageView;
                [cell addSubview:groupImageView];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            return cell;
        }
            
        case GroupInfoSectionTitle:
        {
            static NSString *cellIdentifier = @"titleCell";
            UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            self.titleLabel = (UILabel *)[cell viewWithTag:872];
            if (!self.titleLabel) {
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [tableView.delegate tableView:tableView heightForRowAtIndexPath:indexPath])];
                self.titleLabel.tag = 872;
            }
            
            self.titleLabel.textColor = [UIColor blackColor];
            self.titleLabel.text = self.titleLabelText;
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.font = [UIFont systemFontOfSize:17.0];
            
            [cell addSubview:self.titleLabel];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            
        case GroupInfoSectionOwner:
        {
            static NSString *CellIdentifier = kCellIdentifier;
            
            GroupChatMembersTableViewCell *cell = (GroupChatMembersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            GroupMemberData *dic = [grpOwner objectAtIndex:indexPath.row];
            
            if ([dic.isOwner boolValue]) {
                
                NSString *name = [Common setPlusPrefixChatWithMobile:dic.memberDisplayName];
                NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
                
                if(name != nil){
                    NSNumber *countryIsdCode = [phoneUtil extractCountryCode:(name) nationalNumber:nil];
                    NSString *countryIsdCodeString = [formatter stringFromNumber:countryIsdCode];
                    
                    NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCodeString];
                    NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:countrySimIso];
                    cell.memberName.text = [f inputString:name];
                    cell.memberPhoneNumber.text = [f inputString:name];
                }
                else {
                    cell.memberName.text = dic.memberDisplayName;
                    if(dic.memberContactDataValue != nil) {
                        NSNumber *countryIsdCode = [phoneUtil extractCountryCode:([Common addPlus:dic.memberContactDataValue]) nationalNumber:nil];
                        NSString *countryIsdCodeString = [formatter stringFromNumber:countryIsdCode];
                        NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCodeString];
                        NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:countrySimIso];
                        cell.memberPhoneNumber.text = [f inputString:[Common addPlus:dic.memberContactDataValue]];
                        if ([dic.memberType  isEqual: IV_TYPE]) {
                            cell.memberPhoneNumber.text = [NSString stringWithFormat:@"      %@",cell.memberPhoneNumber.text];
                        }
                        
                    } else {
                        cell.memberPhoneNumber.text = @"";
                    }
                }
                
                cell.callButton.tag = TAG_GRP_OWNER;
                [cell.callButton addTarget:self action:@selector(callToMake:) forControlEvents:UIControlEventTouchUpInside];
                [cell configureGroupMemberCellWithData:dic];
                cell.memberName.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleSubheadline];
                cell.memberPhoneNumber.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleSubheadline];
                
                if([cell.memberName.text isEqualToString:cell.memberPhoneNumber.text]) {
                    cell.memberPhoneNumber.hidden = YES;
                } else {
                    cell.memberPhoneNumber.hidden = NO;
                }
                
                if([cell.memberName.text isEqualToString:cell.memberPhoneNumber.text]) {
                    cell.memberPhoneNumber.hidden = YES;
                } else {
                    cell.memberPhoneNumber.hidden = NO;
                }
            }
            
            if ([dic.memberType  isEqual: IV_TYPE]) {
                [[cell viewWithTag:9009] setHidden:NO];
            }else{
                [[cell viewWithTag:9009] setHidden:YES];
            }
            
            return cell;
        }
            
        case GroupInfoSectionMember:
        {
            static NSString *CellIdentifier = kCellIdentifier;
            NSString *memberName;
            GroupChatMembersTableViewCell *cell = (GroupChatMembersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            GroupMemberData *dic = [grpMemberList objectAtIndex: indexPath.row];
            
            NSString *name = [Common setPlusPrefixChatWithMobile:dic.memberDisplayName];
            NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            
            if(name != nil){
                NSNumber *countryIsdCode = [phoneUtil extractCountryCode:(name) nationalNumber:nil];
                NSString *countryIsdCodeString = [formatter stringFromNumber:countryIsdCode];
                
                NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCodeString];
                NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:countrySimIso];
                cell.memberName.text = [f inputString:name];
                cell.memberPhoneNumber.text = [f inputString:name];
            }
            else {
                cell.memberName.text = dic.memberDisplayName;
                if(dic.memberContactDataValue != nil) {
                    NSNumber *countryIsdCode = [phoneUtil extractCountryCode:([Common addPlus:dic.memberContactDataValue]) nationalNumber:nil];
                    NSString *countryIsdCodeString = [formatter stringFromNumber:countryIsdCode];
                    NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCodeString];
                    NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:countrySimIso];
                    cell.memberPhoneNumber.text = [f inputString:[Common addPlus:dic.memberContactDataValue]];
                    memberName = cell.memberPhoneNumber.text;
                    if ([dic.memberType  isEqual: IV_TYPE]) {
                        cell.memberPhoneNumber.text = [NSString stringWithFormat:@"      %@",cell.memberPhoneNumber.text];
                    }
                } else {
                    cell.memberPhoneNumber.text = @"";
                }
            }
            
            if ([dic.memberType  isEqual: IV_TYPE]) {
                [[cell viewWithTag:9009] setHidden:NO];
            }else{
                [[cell viewWithTag:9009] setHidden:YES];
            }
            
            cell.callButton.tag = indexPath.row;
            
            [cell.callButton addTarget:self action:@selector(callToMake:) forControlEvents:UIControlEventTouchUpInside];
            [cell configureGroupMemberCellWithData:dic];
            cell.memberName.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleSubheadline];
            cell.memberPhoneNumber.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleSubheadline];
            
            if([cell.memberName.text isEqualToString:cell.memberPhoneNumber.text]) {
                cell.memberPhoneNumber.hidden = YES;
            }else if (!dic.memberDisplayName.length){
                cell.memberName.text = memberName;
                cell.memberPhoneNumber.hidden = YES;
            }else {
                cell.memberPhoneNumber.hidden = NO;
            }
            
            return  cell;
        }
    }
    
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 2: return @"Owner";
        case 3: return @"Members";
        default: return @"";
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GroupMemberData *dic = 0;
    switch(indexPath.section)
    {
        case GroupInfoSectionOwner:
            KLog(@"Selected the owner cell");
            dic = [grpOwner objectAtIndex:indexPath.row];
            break;
        case GroupInfoSectionMember:
            KLog(@"Selected the member cell");
            dic = [grpMemberList objectAtIndex:indexPath.row];
            break;
    }
    
    if(nil != dic) {
        KLog(@"Selected user");
        self.currentMobileNumber = [Common removePlus:dic.memberContactDataValue];
        NSMutableDictionary *newDic = [self setUserInfoForConversation:dic];
        [self.delegate dismissedTheViewController:newDic withIdentity:@"Chat"];
    }
}


- (void)forReloadingOfTable {
    [tableToSeeTheUserPhoneNo reloadData];
}

- (IBAction)callToMake:(id)sender
{
    UIButton *callButton = (UIButton *)sender;
    GroupMemberData *dic=nil;
    if(TAG_GRP_OWNER == callButton.tag) {
        if([grpOwner count])
            dic = [grpOwner objectAtIndex:0];
    }
    else {
        if([grpMemberList count])
            dic = [grpMemberList objectAtIndex:callButton.tag];
    }
    
    NSString* phoneNum = [dic memberContactDataValue];
    if([phoneNum length])
        [Common callWithNumber:[dic memberContactDataValue]];
}

/*
 Query Contact and Contact Detail tables to get the phone number of the selected chat user.
 Make the Array of dictionary object with the keys PHONE and IS_IV
 Example:
 {
 "IS_IV" = 0; //or 1
 "CONTACT_DATA_VALUE" = "918892724917"
 "CONTACT_TYPE" = "Work"
 "CONTACT_MODE = "tel"; //PHONE_MODE
 
 },
 {
 "IS_IV" = 1;
 "CONTACT_DATA_VALUE" = "apps@kirusa.com";
 "CONTACT_TYPE" = "work"
 "CONTACT_MODE = "e"; //EMAIL_MODE
 }
 */

-(NSArray*) getListOfGroupMembers
{
    KLog(@"getListOfGroupMembers - START");
    
    NSString* groupID = _groupIDString;
    NSArray* groupMemberLists = [[Contacts sharedContact]getGroupMemberInfoForGroupId:groupID];
    EnLogd(@"ViewForGroupChatContactScreen: group selectd: %@",groupID);
    
    NSMutableArray *uniqueMemberId = [[NSMutableArray alloc]init];
    NSMutableArray *uniqueMembers = [[NSMutableArray alloc]init];
    
    for(GroupMemberData *gmd in groupMemberLists)
    {
        /*
        NSLog(@"=====");
        NSLog(@"groupId: %@", gmd.groupId);
        NSLog(@"isAdmin: %d",[gmd.isAdmin intValue]);
        NSLog(@"isMember:%d",[gmd.isMember intValue]);
        NSLog(@"isOwner:%d",[gmd.isOwner intValue]);
        NSLog(@"joiningDate:%lld",[gmd.joiningDate longLongValue]);
        NSLog(@"memberContactValue:%@",gmd.memberContactDataValue);
        NSLog(@"memberDisplayName:%@",gmd.memberDisplayName);
        NSLog(@"memberId:%@",gmd.memberId);
        NSLog(@"memberIvUserId:%lld",[gmd.memberIvUserId longLongValue]);
        NSLog(@"memberType:%@",gmd.memberType);
        NSLog(@"picLocalPath:%@",gmd.picLocalPath);
        NSLog(@"picRemoteUri:%@",gmd.picRemoteUri);
        NSLog(@"status:%d",[gmd.status intValue]);
        NSLog(@"isAgent:%d",[gmd.isAgent intValue]);
        NSLog(@"=====");
        */
        
        if([uniqueMemberId containsObject:gmd.memberId]) {
            continue;
        }
        else {
            if([gmd.memberContactDataValue length]) {
                [uniqueMemberId addObject:gmd.memberId];
                [uniqueMembers addObject:gmd];
            }
        }
        
        if(!gmd.memberContactDataValue || ![gmd.memberContactDataValue length]) {
            continue;
        }
    }
    
    NSMutableArray *phoneList = [[NSMutableArray alloc]init];
    NSMutableDictionary* activeConversationDictionary=nil;
    NSString* loginID = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
    
    GroupMemberData* you = nil;
    GroupMemberData* owner = nil;
    
    long curUserIvId = [appDelegate.confgReader getIVUserId];
    //- Get the list of members' phone numbers without + sign
    for(GroupMemberData *gmd in uniqueMembers) {
        
        if(!gmd.memberContactDataValue) {
            continue;
        }
        
        NSMutableString* tmpContactNumber = [[NSMutableString alloc]initWithString: gmd.memberContactDataValue];
        
        if(nil != tmpContactNumber && [tmpContactNumber length]) {
            NSString* contactNumber = [Common removePlus:tmpContactNumber];
            [phoneList addObject:contactNumber];
            if([contactNumber isEqualToString:loginID] || ([gmd.memberId longLongValue] == curUserIvId)) {
                you = gmd;
            }
            if([gmd.isOwner intValue]) {
                owner = gmd;
            }
        }
    }
    //
    
    //- Get the list of dic object for the prepared phone numbers
    activeConversationDictionary = [[Contacts sharedContact]getContactDictionaryForChatGridScreen:phoneList];
    if([activeConversationDictionary count]) {
        for(GroupMemberData *gmd in uniqueMembers) {
            
            if(!gmd.memberContactDataValue) {
                continue;
            }
            NSMutableString* tmpContactNumber = [[NSMutableString alloc]initWithString: gmd.memberContactDataValue];
            NSString* contactNumber = [Common removePlus:tmpContactNumber];
            ContactDetailData* detail = [activeConversationDictionary valueForKey:contactNumber];
            if(nil != detail) {
                NSString* contactName = detail.contactIdParentRelation.contactName;
                //NSLog(@"ContactName = %@",contactName);
                gmd.memberDisplayName = contactName;
            }
        }
    }
    
    
    /* Debug
    KLog(@"Original list");
    for(GroupMemberData* m in uniqueMembers) {
        KLog(@"Name = %@",m.memberDisplayName);
    }
    KLog(@"=======");
    */
    
    [uniqueMembers removeObject:owner];
    [uniqueMembers removeObject:you];
    
    NSPredicate *predicte1 = [NSPredicate predicateWithFormat: @"memberType == %@", IV_TYPE];
    NSArray *filteredArrayIvUsers = [uniqueMembers filteredArrayUsingPredicate:predicte1];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"memberDisplayName" ascending:YES];
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"memberContactDataValue" ascending:YES];
    NSArray* sortedArrayIvUsers=[filteredArrayIvUsers sortedArrayUsingDescriptors:@[sort,sort2]];
    
    NSPredicate *predicte2 = [NSPredicate predicateWithFormat: @"memberType == %@", @"tel"];
    NSArray *filteredArrayNonIvUsers = [uniqueMembers filteredArrayUsingPredicate:predicte2];
    
    NSArray* sortedArrayNonIvUsers=[filteredArrayNonIvUsers sortedArrayUsingDescriptors:@[sort,sort2]];
    
    /* Debug
    KLog(@"Sorted list of IV users");
    for(GroupMemberData* m in sortedArrayIvUsers) {
        KLog(@"Name = %@",m.memberDisplayName);
    }
    KLog(@"=======");
    
    KLog(@"Sorted list of non IV users");
    for(GroupMemberData* m in sortedArrayNonIvUsers) {
        KLog(@"Name = %@",m.memberDisplayName);
    }
    KLog(@"=======");
    */
    
    [uniqueMembers removeAllObjects];
    [grpOwner removeAllObjects];
    
    grpOwner = [[NSMutableArray alloc]init];
    
    if(nil!=owner) {
        if([owner.memberContactDataValue containsString:loginID])
            owner.memberDisplayName = @"You";
        [grpOwner addObject:owner];
    }
    
    if(nil!=you) {
        if([you.memberContactDataValue containsString:loginID] || ([you.memberId longLongValue] == curUserIvId))
            you.memberDisplayName = @"You";
        
        if(![owner.memberContactDataValue isEqualToString:you.memberContactDataValue])
            [uniqueMembers addObject:you];
    }

    if([sortedArrayIvUsers count])
        [uniqueMembers addObjectsFromArray:sortedArrayIvUsers];
        
    
    if([sortedArrayNonIvUsers count])
        [uniqueMembers addObjectsFromArray:sortedArrayNonIvUsers];
    
    KLog(@"getListOfGroupMembers - END");
    
    //DEBUG
    /*
     grpOwner = nil;
     [uniqueMembers removeObjectAtIndex:0];
     [uniqueMembers removeObjectAtIndex:0];
    */
    
    if(uniqueMembers && [uniqueMembers count]) {
        return uniqueMembers;
    }
    else {
        return nil;
    }
}

/* SEP 24, 2016
- (IBAction)sendMessageTapped:(id)sender {
    NSDictionary *dict = (NSDictionary*)sender;
    self.currentMobileNumber = [dict objectForKey:CONTACT_DATA_VALUE];
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
    }
    NSMutableDictionary *newDic = [self setUserInfoForConversation:detailDataContact];
    [self.delegate dismissedTheViewControllerGroupChat:newDic withIdentity:self.currentlyTapped];
}
*/

-(NSMutableDictionary *)setUserInfoForConversation:(GroupMemberData *)detailData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    if (detailData != nil)
    {
        if([self moveToNotesScreen:detailData])
        {
            dic = nil;
        }
        else
        {
            [dic setValue:detailData.memberType forKey:REMOTE_USER_TYPE];
            if([detailData.memberId length])
            {
                if([detailData.memberType isEqualToString:IV_TYPE]) {
                    [dic setValue:detailData.memberId forKey:REMOTE_USER_IV_ID];
                    //[dic setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
                } else {
                    [dic setValue:@"0" forKey:REMOTE_USER_IV_ID];
                }
            }
            else
            {
                [dic setValue:@"0" forKey:REMOTE_USER_IV_ID];
            }
            
            [dic setValue:self.currentMobileNumber forKey:FROM_USER_ID];
            [dic setValue:detailData.memberDisplayName forKey:REMOTE_USER_NAME];
            [dic setValue:[IVFileLocator getNativeContactPicPath:detailData.picLocalPath] forKey:REMOTE_USER_PIC];
        }
    }
    else
    {
        if ([[appDelegate.confgReader getLoginId] isEqualToString:self.currentMobileNumber]) {
            dic = nil;
        }
        else
        {
            [dic setValue:@"tel" forKey:REMOTE_USER_TYPE];
            [dic setValue:@"0" forKey:REMOTE_USER_IV_ID];
            [dic setValue:self.currentMobileNumber forKey:FROM_USER_ID];
            [dic setValue:self.currentMobileNumber forKey:REMOTE_USER_NAME];
        }
    }
    return dic;
}

-(BOOL)moveToNotesScreen:(GroupMemberData*)userDic
{
    BOOL result = NO;
    NSString *loginID = [appDelegate.confgReader getLoginId];
    NSString *selected = [Common removePlus:self.currentMobileNumber];
    long getCurIvUserId = [appDelegate.confgReader getIVUserId];//logged-in user IV User ID
    long memberId = [userDic.memberId longLongValue];
    if([loginID isEqualToString:selected] || (getCurIvUserId == memberId)) {
        result = YES;
    } else if( [loginID isEqualToString:userDic.memberContactDataValue]) {
        result = YES;
    }
    
    return result;
}

#pragma mark Toolbar Delegate
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTop; //or UIBarPositionTopAttached
}

#pragma mark overridden setters
//SEP 24, 2016
//- (void)setGroupImage:(UIImage *)newGroupImage;
//{
//    self.groupImage = newGroupImage;
//    /*
//    CMP: Imagage filtering is taking too much (6 seconds). so commented out.
//    KLog(@"img filter starts");
//    if (groupImage) {
//        GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
//        blurFilter.blurRadiusAsFractionOfImageWidth = .05;
//        self.nonBlurredImageView.contentMode = UIViewContentModeScaleAspectFill;
//        self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
//        self.nonBlurredImageView.image = newGroupImage;
//        self.blurredImageView.image = [blurFilter imageByFilteringImage:newGroupImage];
//    }
//    KLog(@"img filer ends");
//    */
//}

#pragma mark ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == tableToSeeTheUserPhoneNo) {
        // the offset for which the nav bar should begin its blurring
        double startBlurringNumber = self.frame.size.width - self.toolbarOnTopOfScreen.frame.size.height;

        // the offset for which the nav bar should stop adding additional blurring
        double endBlurringNumber = startBlurringNumber + 44;

        // if the scrollview is high enough, show the sticky navbar on the top of the screen, and adjust the
        // alpha value of the blur view appropriately.
        if (scrollView.contentOffset.y > startBlurringNumber) {
            [self.toolbarOnTopOfScreen setShadowImage:[[[UINavigationController new] navigationBar] shadowImage] forToolbarPosition:UIBarPositionTop];
            self.blurredImageView.hidden = NO;
            self.nonBlurredImageView.hidden = NO;
            self.upperColorView.hidden = NO;
            double alpha = (scrollView.contentOffset.y - startBlurringNumber) / (endBlurringNumber - startBlurringNumber);
            self.blurredImageView.alpha = alpha;
        } else {
            [self.toolbarOnTopOfScreen setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionTop];
            self.nonBlurredImageView.hidden = YES;
            self.blurredImageView.hidden = YES;
            self.upperColorView.hidden = YES;
        }

        // if we're above showing the nav bar, add the title of the group to the nav bar.
        if (scrollView.contentOffset.y > endBlurringNumber) {
            self.toolbarOnTopOfScreen.items = @[self.cancelButton, self.space, self.nameLabel, self.space2, self.editLeaveButton];
        } else {
            self.toolbarOnTopOfScreen.items = @[self.cancelButton, self.space, self.editLeaveButton];
        }

        // adjust the image view such that if the content offset of the view is negative, we set it back to 0.
        self.groupImageView.frame = CGRectMake(self.groupImageView.frame.origin.x, MIN(scrollView.contentOffset.y, 0), self.groupImageView.frame.size.width, self.groupImageView.frame.size.width);
    }
}
@end
