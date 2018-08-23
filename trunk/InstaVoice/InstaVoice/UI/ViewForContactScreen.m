//
//  ViewForContactScreen.m
//  InstaVoice
//
//  Created by kirusa on 7/7/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "ViewForContactScreen.h"
#import "CustomCellForViewTableViewCell.h"
#import "IVFileLocator.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "Contacts.h"
#import "Common.h"
#import "ImgMacro.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"
#import "Setting.h"
#import "TableColumns.h"
#import "IVImageUtility.h"
#import "GroupMemberData.h"
#import "ScreenUtility.h"

@interface ViewForContactScreen ()

@property (strong, nonatomic) UIView *coloredViewOnTop;

@end

@implementation ViewForContactScreen
@synthesize nameLabel,cancelButton,speakerButton;


#define kCellIdentifier @"CellIdentifier"

- (id)initWithFrame:(CGRect)frame withPhoneNumber:(NSString*)phoneNumber
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (AppDelegate *)APP_DELEGATE;
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        _contactNumber = phoneNumber;
        bShowContacts = FALSE;
        speakerButton = nil;
        [self initializeVariable];
    }
    return self;
}

- (void)initializeVariable {
    if([_contactNumber isEqualToString:CELEBRITY_TYPE]) {
        nameArray = 0;
    }
    else {
        nameArray = [self getCurrentChatUserContacts];
        bShowContacts = TRUE;
    }

    // create the toolbar for the top of the screen
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height + 44)];
    toolbar.delegate = self;
    [toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [toolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
    [self addSubview:toolbar];

    // create close button for the top right of the screen
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:nil action:nil];
    [cancelButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:17],
                                          NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    toolbar.items = @[cancelButton];
    toolbar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];

    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 22, 200, 40)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor whiteColor];

    [nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SIZE_18]];
    [self addSubview:nameLabel];


    int yVal = 75;
    int xDeltaVal = 17;
    if(bShowContacts) {
        yVal = 205;
        xDeltaVal = 0;
        tableToSeeTheUserPhoneNo = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        tableToSeeTheUserPhoneNo.dataSource = self;
        tableToSeeTheUserPhoneNo.delegate = self;
        tableToSeeTheUserPhoneNo.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero] ;
        tableToSeeTheUserPhoneNo.allowsSelection = NO;
        [self addSubview:tableToSeeTheUserPhoneNo];
        [self insertSubview:tableToSeeTheUserPhoneNo belowSubview:toolbar];
        UINib *myNib = [UINib nibWithNibName:@"CustomCellForViewTableViewCell" bundle:nil];
        [tableToSeeTheUserPhoneNo registerNib:myNib forCellReuseIdentifier:kCellIdentifier];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return [nameArray count];
        default:
            return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return self.frame.size.width;
        case 1:
            return 50;
        default:
            return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellId = @"pictureOnTopCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] init];
        }

        if (self.profilePicture) {
            UIImageView *backgroundView = (UIImageView *)[cell viewWithTag:8189];
            if (!backgroundView) {
                backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
                backgroundView.tag = 8189;
            }

            backgroundView.image = self.profilePicture;
            self.coloredViewOnTop = backgroundView;
            [cell addSubview:backgroundView];
        } else {
            UIImageView *backgroundView = (UIImageView *)[cell viewWithTag:8189];
            if (!backgroundView) {
                backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.width)];
                backgroundView.tag = 8189;
            }
            
            backgroundView.image = [UIImage imageNamed:@"default_profile_img_user"];
            self.coloredViewOnTop = backgroundView;
            [cell addSubview:backgroundView];
        }

        return cell;

    } else if (indexPath.section == 1) {
        static NSString *CellIdentifier = kCellIdentifier;
        
        CustomCellForViewTableViewCell *cell = (CustomCellForViewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSMutableDictionary *dic = [nameArray objectAtIndex:indexPath.row];
        KLog(@"Contact Data Value : %@",[dic objectForKey:CONTACT_DATA_VALUE]);
        NSString* contactMode = [dic objectForKey:@"CONTACT_MODE"];
        NSString* contactDataValue = [dic objectForKey:CONTACT_DATA_VALUE];
//        contactDataValue = @"234 998 605 8974";
        if([contactMode isEqualToString:PHONE_MODE]){
            NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
            
            NSNumber *countryIsdCode = [phoneUtil extractCountryCode:([Common addPlus:contactDataValue]) nationalNumber:nil];
            //NSNumber *countryIsdCode = [NSNumber numberWithInt:[[[ConfigurationReader sharedConfgReaderObj]getCountryISD]intValue]];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSString *countryIsdCodeString = [formatter stringFromNumber:countryIsdCode];
            
            NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCodeString];
            NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:countrySimIso];

            cell.phoneLabel.text = [f inputString:[Common addPlus:contactDataValue]];
        } else {
            cell.phoneLabel.text = contactDataValue;
        }
        
        cell.callButton.hidden = NO;
#ifndef REACHME_APP
        cell.chatButton.hidden = NO;
#else
        cell.chatButton.hidden = YES;
#endif
        cell.inviteButton.hidden = NO;
        //cell.addToPhoneBookButton.hidden = NO;

        cell.callButton.tag = indexPath.row;
#ifndef REACHME_APP
        cell.chatButton.tag = indexPath.row;
#endif
        //cell.addToPhoneBookButton.tag = indexPath.row;
        cell.inviteButton.tag = indexPath.row;
        [cell.callButton addTarget:self action:@selector(callToMake:) forControlEvents:UIControlEventTouchUpInside];
#ifndef REACHME_APP
        [cell.chatButton addTarget:self action:@selector(chatToMake:) forControlEvents:UIControlEventTouchUpInside];
#endif
        //[cell.addToPhoneBookButton addTarget:self action:@selector(addToPhoneBook:) forControlEvents:UIControlEventTouchUpInside];
        [cell.inviteButton addTarget:self action:@selector(inviteToMake:) forControlEvents:UIControlEventTouchUpInside];
        //[cell.addToPhoneBookButton setHidden:YES];

        // if we are in the current chat, we shouldn't give the user the option to chat with the person
#ifndef REACHME_APP
        if([[dic valueForKey:@"IS_CURRENT_CHAT"] boolValue]) {cell.chatButton.hidden = YES;}
#endif

        // if we can't add to the phonebook, don't give the user the option to
        //if(![[dic valueForKey:@"ADDTOPHONEBOOK"] boolValue]) {cell.addToPhoneBookButton.hidden = YES;}

        // if we're in an instavoice chat, hide the invite button. otherwise hide the instavoice icon.
#ifndef REACHME_APP
        if([[dic valueForKey:@"IS_IV"] boolValue]) {
            if(NO == cell.chatButton.hidden) {
                cell.instavoiceImage.hidden = YES;
            }
            cell.inviteButton.hidden = YES;
        }
        else {
            UIImage *imageView =  [UIImage imageNamed:@"ChatGrey"];
            [cell.chatButton setImage: imageView forState:UIControlStateNormal];
            cell.instavoiceImage.hidden = YES;
        }
#else
        if([[dic valueForKey:@"IS_IV"] boolValue]) {
            cell.inviteButton.hidden = YES;
        }
        else {
            cell.inviteButton.hidden = NO;
        }
#endif
        // there should always be an call-this-person button
        [cell.callButton setImage:[[UIImage imageNamed:@"return-call"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [cell.callButton setImage:[[UIImage imageNamed:@"return-call-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];

        // set the images for the invite to instavoice cell
        [cell.inviteButton setImage:[[UIImage imageNamed:@"invite-to-iv"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [cell.inviteButton setImage:[[UIImage imageNamed:@"invite-to-iv-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];

        // if the label is for a celeb, there should be no way to contact that celeb back
        if([cell.phoneLabel.text rangeOfString:@"@"].location != NSNotFound) {
            cell.callButton.hidden = YES;
#ifndef REACHME_APP
            cell.chatButton.hidden = YES;
#endif
            cell.inviteButton.hidden = YES;
            //cell.addToPhoneBookButton.hidden = YES;
        }
        return  cell;
    }
    return [[UITableViewCell alloc] init];
}
//

- (void)forReloadingOfTable {
    [tableToSeeTheUserPhoneNo reloadData];
}

- (IBAction)callToMake:(id)sender {
    
    UIButton *callButton = (UIButton *)sender;
    NSMutableDictionary *dic = [nameArray objectAtIndex:callButton.tag];
    NSString* contact = [dic objectForKey:CONTACT_DATA_VALUE];
#ifdef REACHME_APP
    BOOL isIV = [[dic valueForKey:@"IS_IV"]boolValue];
    NSString* userType = @"tel";
    if(isIV)
        userType = IV_TYPE;
    [Common callNumber:contact FromNumber:nil UserType:userType];
#else
    [Common callWithNumber:contact];
#endif
}

- (IBAction)chatToMake:(id)sender {
    UIButton *chatButton = (UIButton *)sender;
    NSMutableDictionary *dic = [nameArray objectAtIndex:chatButton.tag];
    [self setCurrentlyTapped:@"Chat"];
    [self sendMessageTapped:dic];
}

- (IBAction)inviteToMake:(id)sender {
    UIButton *inviteButton = (UIButton *)sender;
    NSMutableDictionary *dic = [nameArray objectAtIndex:inviteButton.tag];
    [self setCurrentlyTapped:@"Invite"];
    [self.delegate dismissedTheViewController:[dic objectForKey:CONTACT_DATA_VALUE] withIdentity:self.currentlyTapped];
}

- (IBAction)addToPhoneBook:(id)sender {
    KLog(@"ADD to PB");

}

-(void)setSpeakerMode {

    if(speakerButton) {
        int audioMode = [appDelegate.confgReader getVolumeMode];
        if(SPEAKER_MODE == audioMode) {
            [speakerButton setSelectedSegmentIndex:0];
        
        } else {
            [speakerButton setEnabled:NO forSegmentAtIndex:1];
            [speakerButton setEnabled:YES forSegmentAtIndex:1];
        }
    }
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

-(NSArray*) getCurrentChatUserContacts
{
    NSString* sCurPhoneNumber = _contactNumber;
    if(!sCurPhoneNumber.length) {
        EnLogd(@"_contactNumber:%@",_contactNumber);
        return nil;
    }
    
    NSArray* contactDetailList = [[Contacts sharedContact]getContactForPhoneNumber:sCurPhoneNumber];
    EnLogd(@"ViewForContactScreen:Number selected: %@",sCurPhoneNumber);
    
    NSArray* memberData = nil;
    if(!contactDetailList || ![contactDetailList count]) {
        memberData = [[Contacts sharedContact]getGroupMemberDataForPhoneNumber:sCurPhoneNumber];
    }
    
    if(memberData && [memberData count]) {
        /* Debug
        for(GroupMemberData* grpMemData in memberData) {
            NSLog(@"memberDisplayName = %@",grpMemData.memberDisplayName);
            NSLog(@"contactDataValue = %@", grpMemData.memberContactDataValue);
            NSLog(@"memberType = %@", grpMemData.memberType);
            NSLog(@"memberId = %@",grpMemData.memberId);
            NSLog(@"memberIvUserId = %@", grpMemData.memberIvUserId);
            NSLog(@"groupId = %@", grpMemData.groupId);
            NSLog(@"isAdmin = %@", grpMemData.isAdmin);
        }*/
        
        NSMutableArray* arrContacts = [[NSMutableArray alloc]init];
        GroupMemberData* grpMemData = [memberData objectAtIndex:0];
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        if(grpMemData.memberContactDataValue) {
            [dic setObject:grpMemData.memberContactDataValue forKey:CONTACT_DATA_VALUE];
            [dic setObject:@"tel" forKey:@"CONTACT_MODE"];
            [dic setValue:[NSNumber numberWithBool:YES] forKey:@"IS_CURRENT_CHAT"];
        }
        
        if([grpMemData.memberType isEqualToString:IV_TYPE]) {
            [dic setValue:[NSNumber numberWithBool:YES] forKey:IS_IV];
        } else {
            [dic setValue:[NSNumber numberWithBool:NO] forKey:IS_IV];
        }
        
        [dic setValue:[NSNumber numberWithBool:YES] forKey:@"ADDTOPHONEBOOK"];
        [arrContacts addObject:dic];
        return arrContacts;
    }
    else if(contactDetailList && [contactDetailList count]) {
        EnLogd(@"ViewForContactScreen:Contact Detail Array: %@",contactDetailList);
        ContactDetailData* detail = [contactDetailList objectAtIndex:0];
        
        NSMutableArray* uniqueMemberId = [[NSMutableArray alloc]init];
        
        NSMutableArray* arrContacts = [[NSMutableArray alloc]init];
        ContactData* data = detail.contactIdParentRelation;
        NSSet* all = data.contactIdDetailRelation;
        bool bIsCurChat = false;
        for(ContactDetailData* obj in all)
        {
            NSString* contactDataValue =  obj.contactDataValue;
            NSString* type = obj.contactDataType; //Phone mode or email-mode
            NSString* subtype = obj.contactDataSubType; //home,work,other..
            NSNumber* IVUserID = obj.ivUserId;

            if([type isEqualToString:EMAIL_MODE])
                continue;
            if(contactDataValue) {
                //SEPT 28, 2016
                //To remove the duplicates
                if([uniqueMemberId containsObject:contactDataValue]) {
                    continue;
                } else {
                    [uniqueMemberId addObject:contactDataValue];
                }
                //
                
                NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
                [dic setObject:contactDataValue forKey:CONTACT_DATA_VALUE];
                [dic setObject:type forKey:@"CONTACT_MODE"];
                
                if([contactDataValue isEqualToString:sCurPhoneNumber]) {
                    [dic setValue:[NSNumber numberWithBool:YES] forKey:@"IS_CURRENT_CHAT"];
                    bIsCurChat=true;
                } else {
                    [dic setValue:[NSNumber numberWithBool:NO] forKey:@"IS_CURRENT_CHAT"];
                }
                
                if( 0==[IVUserID intValue] ) {
                    [dic setValue:[NSNumber numberWithBool:NO] forKey:IS_IV];
                } else {
                    [dic setValue:[NSNumber numberWithBool:YES] forKey:IS_IV];
                }
                
                if( subtype && [subtype length] ) {
                    [dic setObject:subtype forKey:CONTACT_TYPE];
                }
                
                if(bIsCurChat) {
                    [arrContacts insertObject:dic atIndex:0];
                    bIsCurChat=false;
                }else {
                    [arrContacts addObject:dic];
                }
            }
        }
        
        if(arrContacts && [arrContacts count]) {
            return arrContacts;
        }
    }
    else
    {
        NSMutableArray* arrContacts = [[NSMutableArray alloc]init];
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        [dic setObject:@"tel" forKey:@"CONTACT_MODE"]; //Phone mode is assumed. TODO
        /* Crashlytics #1429 @ 416. 
           setObject with nil obj param causes a crash. See the check at the start of this method.
        */
        [dic setObject:sCurPhoneNumber forKey:CONTACT_DATA_VALUE];
        [dic setValue:[NSNumber numberWithBool:YES] forKey:@"IS_CURRENT_CHAT"];
        [dic setValue:[NSNumber numberWithBool:NO] forKey:IS_IV];
        [dic setValue:[NSNumber numberWithBool:YES] forKey:@"ADDTOPHONEBOOK"];
        [arrContacts addObject:dic];
        return arrContacts;
    }
    
    return nil;
}

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
    [self.delegate dismissedTheViewController:newDic withIdentity:self.currentlyTapped];
}


-(NSMutableDictionary *)setUserInfoForConversation:(ContactDetailData *)detailData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    if (detailData != nil) {
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
    else if([loginID isEqualToString:self.currentMobileNumber])
    {
        result = YES;
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

//KM
#pragma mark Toolbar Delegate
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTop;
}

#pragma mark Scrollbar Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == tableToSeeTheUserPhoneNo) {
        if (scrollView.contentOffset.y < 0) {
            self.coloredViewOnTop.frame = CGRectMake(self.coloredViewOnTop.frame.origin.x, scrollView.contentOffset.y, self.coloredViewOnTop.frame.size.width, self.coloredViewOnTop.frame.size.height);
        } else {
            self.coloredViewOnTop.frame = CGRectMake(0, 0, self.coloredViewOnTop.frame.size.width, self.coloredViewOnTop.frame.size.height);
        }
    }
}

#pragma mark Setters
- (void)setProfilePicture:(UIImage *)profilePicture
{
    _profilePicture = profilePicture;
    KLog(@"%@", profilePicture);
    [tableToSeeTheUserPhoneNo reloadData];
}
//

@end
