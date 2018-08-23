//
//  ChatMobileNumberViewController.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 7/7/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "ChatMobileNumberViewController.h"
#import "IVFileLocator.h"
#define COUNTRY_FLAG @"flag"
#define SEPARATOR  @"SEP"
#import <QuartzCore/QuartzCore.h>
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"
#import "IVColors.h"
#import "ChatGridViewController.h"
#import "Profile.h"
#import "InsideConversationScreen.h"
#import "ProfileFieldSelectionTableViewController.h"

#define PLACEHOLDERTEXT @"_placeholderLabel.textColor"
#define CELL_HEIGHT 40
#define SELECT_COUNTRY @"Select Country"
#define PWD_MIN 6
#define PWD_MAX 25

#define kContactIdKey @"contact_id"


@interface ChatMobileNumberViewController ()<ProfileFieldSelectionDelegate>

@property (strong, nonatomic) UISegmentedControl *navSegmentedControl;

@end

@implementation ChatMobileNumberViewController
BOOL editUserID;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        countryList =  nil;
        newCountryList = nil;
        countryIsdCode = @"";
        countryName = @"";
        maxPhoneLen = 0;
        minPhoneLen = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDefaultFlag];
    
    downArrow.center = CGPointMake(100.0, 100.0);
    downArrow.transform = CGAffineTransformMakeRotation(- M_PI_2);
    
    UITapGestureRecognizer *selectCountry = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectCountryBtnAction:)];
    [downArrow addGestureRecognizer:selectCountry];
    
    UITapGestureRecognizer *selectCountryLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectCountryBtnAction:)];
    [countryNameLbl addGestureRecognizer:selectCountryLabel];
    
    userID.keyboardType = UIKeyboardTypeNumberPad;
    self.uiType = NEW_CHAT_SCREEN;
    //DEC 14 [appDelegate.stateMachineObj setCurrentUI:self];
    CGRect rect = CGRectMake(SIZE_0, SIZE_0, SIZE_5, SIZE_34);
    worldIconImg = [UIImage imageNamed:IMG_WORLD_ICON];
    UIView *ped = [[UIView alloc] initWithFrame:rect];
    userID.leftView = ped;
    userID.leftViewMode = UITextFieldViewModeAlways;
    [userID becomeFirstResponder];
    NSString *simISD = [appDelegate.confgReader getSIMIsdCode];
    [self setSelectCountry:simISD];
    
    indexArray = [Common loadIndexArray];
    countryIndexData = [Common loadDataAtIndexArray:newCountryList key:COUNTRY_NAME indexArray:indexArray];
    [countryView.layer setCornerRadius:SIZE_10];
    countryView.layer.masksToBounds = YES;
    
    //Start
    //As per the latest requirement - Conversation: String update: "Chat with mobile"  update to "Chat with Any Number" - Date - 23rd May 2016, Nivedita
   // [self createTopViewStoryBoardWithTitle:@"Chat with a mobile number"];
     [self createTopViewStoryBoardWithTitle:@"Chat with Any Number"];
    //End
    inviteList = [[NSMutableArray alloc]init];
    numberWithoutFormat = @"";
    numberE164format = @"";
	isPossible = false;
    self.navigationController.navigationBar.barTintColor = [IVColors redColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    // set up what the navigation controllers should contain in each one of the screens.
    UISegmentedControl *selectWhichTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"chat-icon-seg"], [UIImage imageNamed:@"new-group-chat"], [UIImage imageNamed:@"new-mobile-chat"]]];
    for (int i = 0; i < selectWhichTypeSegmentedControl.numberOfSegments; i++) {
        [selectWhichTypeSegmentedControl setWidth:70 forSegmentAtIndex:i];
    }
    self.navSegmentedControl = selectWhichTypeSegmentedControl;

    [selectWhichTypeSegmentedControl sendActionsForControlEvents:UIControlEventTouchUpInside];
    [selectWhichTypeSegmentedControl addTarget:self action:@selector(segmentedControlTapped:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = selectWhichTypeSegmentedControl;

    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel-circle"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    self.hidesBottomBarWhenPushed = YES;
    self.tabBarController.tabBar.hidden = YES;
    [self updateNavigationBarTintColor];
}

-(void)createTopViewStoryBoardWithTitle:(NSString*)nonLocalizedString
{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0, SIZE_0, SIZE_320, SIZE_54)];
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_0, SIZE_22, DEVICE_WIDTH, SIZE_30)];
    UIView *borderView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0, SIZE_53, appDelegate.deviceHeight.width, SIZE_1)];

    [borderView setBackgroundColor:[UIColor colorWithRed:(230/255.f) green:(230/255.f) blue:(230/255.f) alpha:1.0f]];
    
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont fontWithName:HELVETICANEUE_MEDIUM size:SIZE_18]];
    [title setTextColor:[UIColor blackColor]];
    title.backgroundColor = [UIColor clearColor];
    title.text = NSLocalizedString(nonLocalizedString, nil);
    //    [topView setBackgroundColor:[UIColor colorWithWhite:.88 alpha:1.0]];
    //KM [topView addSubview:backButton];
    [topView addSubview:title];
    [topView addSubview:borderView];
    [self.view addSubview:topView];
    userID.delegate = self;
}

#pragma mark delegates for the TextField(userID)
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return editUserID;
}

// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [userID resignFirstResponder];
    return YES;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIStateMachine sharedStateMachineObj]setCurrentPresentedUI:self];
    [self setPlaceHolderForTextField];
    int netAvailable = [Common isNetworkAvailable];
    if(netAvailable == NETWORK_NOT_AVAILABLE)
    {
        //OCT 4, 2016 [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }

    [self.navSegmentedControl setSelectedSegmentIndex:2];
    
    editUserID = YES;
    [userID becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //OCT 5, 2016 [[UIStateMachine sharedStateMachineObj]setCurrentPresentedUI:nil];
    //DC
    [userID resignFirstResponder];
    [super viewWillDisappear:animated];
}

-(void)dismissThisViewController
{
    if(nil != alertAddToIVValidation) {
        [alertAddToIVValidation dismissWithClickedButtonIndex:-1 animated:NO];
    }
    
    if(nil != alertNumberValidation) {
        [alertNumberValidation dismissWithClickedButtonIndex:-1 animated:NO];
    }
    
    if(nil != alertWarning) {
        [alertWarning dismissWithClickedButtonIndex:-1 animated:NO];
    }
    
    [ScreenUtility closeAlert];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(nil != popUp)
    {
        [popUp close];
        
        if(inviteList != nil && [inviteList count] > 0) {
            [inviteList removeAllObjects];
        }
        
        popUp.tag = 0;
        popUp = nil;
        editUserID = YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(countryIsdCode == nil || [countryIsdCode length]==0)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"ALERT_COUTRY_CODE", nil)];
        return NO;
    }
    
    if(userID == textField) {
        if (textField.keyboardType == UIKeyboardTypeNumberPad)
        {
            if ([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound && ![string isEqualToString:@""])
            {
                return NO;
            }
        }
    }

    return YES;
}

#pragma mark - UITableView's Delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{
    return [countryList count];
}


-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dic;
    UITableViewCell *cell = nil;
    static NSString *someCell = @"cellIdentifier";
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:someCell];
    }
    
    dic = [countryList objectAtIndex:indexPath.row];
    [self setFlag:dic];
    
    NSNumber *num = [dic valueForKey:SEPARATOR];
    UIView *lineView = nil;
    if(num != nil && [num boolValue])
    {
        lineView = [[UIView alloc] initWithFrame:CGRectMake(SIZE_0, SIZE_37, cell.contentView.frame.size.width, 3)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:lineView];
    }
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SIZE_10, SIZE_8, SIZE_24, SIZE_24)];
    NSString *countryFlag = [dic valueForKey:COUNTRY_FLAG];
    UIImage *flagImg = [UIImage imageNamed:countryFlag];
    
    if(flagImg == nil)
    {
        flagImg = worldIconImg;
    }
    [imageView setImage:flagImg];
    
    
    UILabel *lblCountry_isd_Code = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_43, SIZE_4, SIZE_50, SIZE_30)];
    lblCountry_isd_Code.textColor = [UIColor blackColor];
    lblCountry_isd_Code.backgroundColor= [UIColor clearColor];
    NSString *isd =@"+";
    isd = [isd stringByAppendingString:[dic valueForKey:COUNTRY_ISD_CODE]];
    lblCountry_isd_Code.text =isd;
    [lblCountry_isd_Code setFont:[UIFont systemFontOfSize:SIZE_14]];
    
    UILabel *lblCountryName = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_88, SIZE_4, SIZE_170, SIZE_30)];
    lblCountryName.textColor = [UIColor blackColor];
    lblCountryName.backgroundColor= [UIColor clearColor];
    NSString *name = [dic valueForKey:COUNTRY_NAME];
    lblCountryName.text = name;
    [lblCountryName setFont:[UIFont systemFontOfSize:SIZE_14]];
    [lblCountryName setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [cell addSubview:imageView];
    [cell addSubview:lblCountry_isd_Code];
    [cell addSubview:lblCountryName];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*NSMutableDictionary *tempDic = [countryList objectAtIndex:indexPath.row];
    
    NSString *countryFlag = [tempDic valueForKey:COUNTRY_FLAG];
    
    countryName =  [tempDic valueForKey:COUNTRY_NAME];
    maxPhoneLen = [[tempDic valueForKey:COUNTRY_MAX_PHONE_LENGTH] integerValue];
    minPhoneLen = [[tempDic valueForKey:COUNTRY_MIN_PHONE_LENGTH] integerValue];
    
    NSString *isd = countryIsdCode;
    countryIsdCode = [tempDic valueForKey:COUNTRY_ISD_CODE];
    
    if(countryIsdCode != nil && [countryIsdCode length] > 0)
    {
        NSString *tempStr = [[NSString alloc] initWithFormat:@"+%@",countryIsdCode];
        plusField.text = tempStr;
    }
    
    UIImage *flagImg = [UIImage imageNamed:countryFlag];
    if(flagImg == nil)
    {
        flagImg = worldIconImg;
    }
    [countryNameLbl setText:countryName];
    [flagview setImage:flagImg];
    [countryTable reloadData];
    
    countryView.hidden = YES;
    if(![isd isEqualToString:countryIsdCode])
    {
        userID.text = @"";
    }
    userID.text = @"";
    numberWithoutFormat = @"";
    [userID becomeFirstResponder];
     */
}


#pragma mark - Action associated with buttons

-(IBAction)cancelBtnAction:(id)sender
{
    if(!countryView.hidden)
    {
        countryView.hidden = YES;
        [userID becomeFirstResponder];
    }
}

-(void)profileFieldSelectionViewController:(ProfileFieldSelectionTableViewController *)profileViewController didSelectCountry:(NSMutableDictionary *)country
{
    NSString *countryFlag = [country valueForKey:@"COUNTRY_FLAG"];
    
    countryName =  [country valueForKey:COUNTRY_NAME];
    maxPhoneLen = [[country valueForKey:COUNTRY_MAX_PHONE_LENGTH] integerValue];
    minPhoneLen = [[country valueForKey:COUNTRY_MIN_PHONE_LENGTH] integerValue];
    
    NSString *isd = countryIsdCode;
    countryIsdCode = [country valueForKey:COUNTRY_ISD_CODE];
    
    if(countryIsdCode != nil && [countryIsdCode length] > 0)
    {
        NSString *tempStr = [[NSString alloc] initWithFormat:@"+%@",countryIsdCode];
        plusField.text = tempStr;
    }
    
    UIImage *flagImg = [UIImage imageNamed:countryFlag];
    if(flagImg == nil)
    {
        flagImg = worldIconImg;
    }
    [countryNameLbl setText:countryName];
    [flagview setImage:flagImg];
    [countryTable reloadData];
    
    countryView.hidden = YES;
    if(![isd isEqualToString:countryIsdCode])
    {
        userID.text = @"";
    }
    userID.text = @"";
    numberWithoutFormat = @"";
    [userID becomeFirstResponder];
    
}

-(IBAction)selectCountryBtnAction:(id)sender;
{
    ProfileFieldSelectionTableViewController* svc = [[ProfileFieldSelectionTableViewController alloc]initWithNibName:@"ProfileFieldSelectionTableViewController" bundle:Nil];
    svc.profileFieldTitle = @"Select Country";
    svc.profileFieldType = ProfileFieldTypeCountry;
    svc.profileFieldData = [[Setting sharedSetting]getCountryList];
    svc.topFiveCountryList = [Common topFiveCountryList];
    svc.profileFieldSelectionDelegate = self;
    [self.navigationController pushViewController:svc animated:YES];
    
}

#pragma mark-emptyField validation

-(BOOL)emptyFieldValidation
{
    BOOL result = YES;
    
    int netAvailable = [Common isNetworkAvailable];
    if(netAvailable == NETWORK_NOT_AVAILABLE)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return NO;
    }
    
    if(countryIsdCode == nil || [countryIsdCode length]==0)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"ALERT_COUTRY_CODE", nil)];
        return NO;
    }
    
    numberWithoutFormat = userID.text;
    
    if(!numberWithoutFormat.length)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"ENTER_PHONE_NUMBER", nil)];
        [userID becomeFirstResponder];
        return NO;
    }
    else
    {
        numberE164format = [Common getE164FormatNumber:numberWithoutFormat withCountryIsdCode:countryIsdCode];
        
        if([Common isValidNumber:numberWithoutFormat withContryISDCode:countryIsdCode]) {
            KLog(@"valid number");
        }
        else if ([Common isPossibleNumber:numberWithoutFormat withContryISDCode:countryIsdCode showAlert:YES])
        {
            isPossible = true;
        }
        else
        {
            [ScreenUtility showAlert:NSLocalizedString(@"ENTER_CORRECT_NUMBER", nil)];
            [userID becomeFirstResponder];
            return NO;
        }
    }
    
    return result;
}

#pragma mark alertview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == alertNumberValidation){
        if(buttonIndex == 0){
            [userID becomeFirstResponder];
        }
        else
        {
            [self sendMessageTappedAction];
        }
    }
    else if (alertView == alertAddToIVValidation){
        if(buttonIndex == 0) {
            [userID becomeFirstResponder];
        }
        else
        {
            [self addToInstavoiceTappedAction];
             editUserID = NO;
        }
    }
}

#pragma mark - UITableView's DataSource

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return indexArray;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    NSMutableArray *dataAtIndex = nil;
    int i = 0;
    
    dataAtIndex =  countryIndexData;
    if([dataAtIndex count] > index)
    {
        NSMutableDictionary *dataDic = [dataAtIndex objectAtIndex:index];
        
        i = [[dataDic valueForKey:TABLE_VALUE] intValue];
        if(i == 0)
        {
            if(index > 0)
            {
                dataDic = [dataAtIndex objectAtIndex:index-1];
                i = [[dataDic valueForKey:TABLE_VALUE] intValue];
            }
        }
    }
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i+(sepCount+1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return i;
    
}
-(NSMutableDictionary *) setFlag : (NSMutableDictionary *)flagDic
{
    NSString *country_flag = [flagDic valueForKey:COUNTRY_NAME];
    //country_flag = [country_flag stringByAppendingString:@".png"];
    
    for(int i=0;i<[country_flag length];i++)
    {
        if([country_flag characterAtIndex:i]==' ')
        {
            country_flag = [country_flag stringByReplacingOccurrencesOfString:@" "
                                                                   withString:@"-"];
        }
    }
    [flagDic setValue: country_flag forKey:COUNTRY_FLAG];
    return flagDic;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


-(void)setDefaultFlag
{
    NSString *countryISD = [appDelegate.confgReader getCountryISD];
    NSString *countryFlag = [appDelegate.confgReader getCountryName];
    
    if(countryISD != nil && [countryISD length]>0 && countryFlag != nil && [countryFlag length]>0)
    {
        maxPhoneLen = [appDelegate.confgReader getMaxPhoneLen];
        minPhoneLen = [appDelegate.confgReader getMinPhoneLen];
        countryNameLbl.text = countryFlag;
        countryName = countryFlag;
        //countryFlag = [countryFlag stringByAppendingString:@".png"];
        countryFlag = [countryFlag stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        [flagview setImage:[UIImage imageNamed:countryFlag]];
        [plusField setText:[[NSString alloc] initWithFormat:@"+%@",countryISD]];
        if(countryIsdCode == nil)
        {
            countryIsdCode = @"";
        }
        countryIsdCode= countryISD;
    }
    else
    {
        [flagview setImage:worldIconImg];
        [countryNameLbl setText:NSLocalizedString(@"SELECT_COUNTRY", nil)];
        plusField.text = @"+";
        userID.text= @"";
    }
}

-(void)setSelectCountry:(NSString*)countryISD
{
    NSMutableArray *fiveCountryList = [Common topFiveCountryList];
    if(countryISD != nil && [countryISD length]>0)
    {
        int count = (int)[fiveCountryList count];
        int index = -1;
        for (int i =0; i<count; i++)
        {
            NSMutableDictionary *dic = [fiveCountryList objectAtIndex:i];
            NSString *isd = [dic valueForKey:COUNTRY_ISD_CODE];
            if([isd isEqualToString:countryISD])
            {
                index = i;
                break;
            }
        }
        if(index >= 0)
        {
            NSMutableDictionary *dic = [fiveCountryList objectAtIndex:index];
            [fiveCountryList removeObjectAtIndex:index];
            [fiveCountryList insertObject:dic atIndex:0];
        }
        
    }
    newCountryList = [[Setting sharedSetting]getCountryList];
    countryList = newCountryList;
    sepCount = 4;
    [fiveCountryList addObjectsFromArray:countryList];
    countryList = fiveCountryList;
    if(sepCount>0)
    {
        NSMutableDictionary *dic = [countryList objectAtIndex:sepCount];
        [dic setValue:[NSNumber numberWithBool:YES] forKey:SEPARATOR];
    }
}

-(void)setPlaceHolderForTextField
{
    [userID setValue:[UIColor lightGrayColor] forKeyPath:PLACEHOLDERTEXT];
    userID.keyboardType = UIKeyboardTypeNumberPad;
}

-(IBAction)backAction
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)sendMessageTapped:(id)sender {

    if (![self emptyFieldValidation]) {
        return;
    }
    else {
        if(isPossible) {
            NSString *msg = @"\nThis number appears to be invalid. Do you want to continue?";
            NSString *title = [@"Confirm mobile number\n" stringByAppendingString:[Common getFormattedNumber:numberWithoutFormat withCountryIsdCode:countryIsdCode withGivenNumberisCannonical:NO]];
            alertNumberValidation = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Change" otherButtonTitles:@"Continue", nil];
            [alertNumberValidation show];
        }
        else {
            [self sendMessageTappedAction];
        }
        
        isPossible = false;
    }
}

-(void)sendMessageTappedAction
{
    UINavigationController *chatsNavigationController = (UINavigationController *)[[self.callingTabBarController viewControllers] objectAtIndex:0];
    ChatGridViewController<ChatMobileNumberProtocol> *chatGridScreenToGoBackTo = (ChatGridViewController<ChatMobileNumberProtocol> *)chatsNavigationController.viewControllers[0];

    // set that as the current navigation controller - this sets that navigation stack to be the stack that gets pushed onto
    self.callingTabBarController.selectedIndex = 0;

    self.currentMobileNumber = [Common removePlus:numberE164format];
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
    else
    {
        contactDetailList = [[Contacts sharedContact]getCustomContactForNewPhoneNumber:self.currentMobileNumber];
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
    
    
    //check for going to notes
    NSMutableDictionary *newDic = [self setUserInfoForConversation:detailDataContact];
    [self dismissViewControllerAnimated:NO completion:^{
        [chatGridScreenToGoBackTo dismissedChatMobileNumberViewController:newDic];
    }];
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
        NSMutableArray* secondaryNumbers = [[[Profile sharedUserProfile]profileData]additionalVerifiedNumbers];
        
        for(NSDictionary* numberInfo in secondaryNumbers)
        {
            if([value isEqualToString:numberInfo[kContactIdKey]])
            {
                result = YES;
            }
        }
    }
    return result;
}

- (IBAction)addToInstavoiceTapped:(id)sender {
    
    if (![self emptyFieldValidation])
    {
        return;
    }
    else
    {
        if(isPossible)
        {
            NSString *msg = @"\nThis number appears to be invalid. Do you want to continue?";
            NSString *title = [@"Confirm mobile number\n" stringByAppendingString:[Common getFormattedNumber:numberWithoutFormat withCountryIsdCode:countryIsdCode withGivenNumberisCannonical:NO]];
            alertAddToIVValidation = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Change" otherButtonTitles:@"Continue", nil];
            [alertAddToIVValidation show];
        }
        else
        {
            [self addToInstavoiceTappedAction];
        }
        isPossible = false;
    }
}

-(void)addToInstavoiceTappedAction
{
    [userID resignFirstResponder];
    self.currentMobileNumber = [Common removePlus:numberE164format];
    NSArray* contactDetailList = [[Contacts sharedContact]getContactForPhoneNumber:self.currentMobileNumber];
    ContactDetailData* detailDataContact = nil;
    if([contactDetailList count] > 0)
    {
        ContactDetailData* detail = [contactDetailList objectAtIndex:0];
        ContactData* data = detail.contactIdParentRelation;
        NSSet* all = data.contactIdDetailRelation;
        
        if([data.isIV intValue] == 1)
        {
            [ScreenUtility showAlert:@"Contact already exist in your Friend list"];
            return;
        }
        
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
    popUp = [[CustomIOS7AlertView alloc]init];
    [ContactInvitePopUPAction setParentView:self];
    [ContactInvitePopUPAction createContactAlert:_invitedContact alertType:INVITE_ALERT deviceHeight:appDelegate.deviceHeight alertView:popUp];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    [alertView close];
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
    editUserID = YES;
    [userID becomeFirstResponder];
}

-(void)sendBtnInviteAction
{
    popUp.tag = 0;
    popUp = nil;
    editUserID = YES;
    
    if(inviteList == nil || [inviteList count] == 0)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"SELECT_CONTACT", nil)];
        return;
    }
    if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE)
    {
        [ScreenUtility showAlert:NSLocalizedString(@"NETWORK_NOT_AVAILABLE", nil)];
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
    [userID becomeFirstResponder];
    
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
    if(![_managedObjectContext save:&error])
    {
        KLog(@"CoreData: updateInviteStatusInDB: Error Inviting %@",contactList);
    }
}
//KM
#pragma mark - Selectors
- (IBAction)segmentedControlTapped:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    [self.tabBarController setSelectedViewController:[self.tabBarController.viewControllers objectAtIndex:segmentedControl.selectedSegmentIndex]];
}


//

- (void)updateNavigationBarTintColor {
#if DEFAULT_THEMECOLOR_ENABLED
     self.navigationController.navigationBar.barTintColor = [IVColors redColor];
    
#else
    {
        //NSString *primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
        NSString *carrierThemeColor = [[ConfigurationReader sharedConfgReaderObj]getLatestCarrierThemeColor];

        //NSString *carrierThemeColor = [[Setting sharedSetting]getCarrierThemeColorForNumber:primaryNumber];
        if (carrierThemeColor && [carrierThemeColor length])
             self.navigationController.navigationBar.barTintColor = [IVColors convertHexValueToUIColor:carrierThemeColor];
        else
            self.navigationController.navigationBar.barTintColor = [IVColors redColor];
        
    }
    
#endif
    
}
@end
