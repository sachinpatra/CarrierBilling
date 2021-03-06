//
//  IVVoiceMailListViewController.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 18/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVVoiceMailListViewController.h"
//IVVoiceMailListCell
#import "IVVoiceMailListCell.h"
#import "IVPrimaryVoiceMailListCell.h"

#import "IVSettingsCountryCarrierInfo.h"
#import "Common.h"

#import "ChangePrimaryNumberViewController.h"
#import "MZFormSheetController.h"
#import "ManageUserContactAPI.h"
#import "NBPhoneNumberUtil.h"
#import "ContactDetailData.h"
#import "InsideConversationScreen.h"
#import "VerifyUserAPI.h"
#import "VerificationOTPViewController.h"
#import "LinkAdditionalMobileNumberViewController.h"
#import "IVFileLocator.h"
#import "IVLinkedNumberVoiceMailViewController.h"
#import "IVPrimaryNumberVoiceMailViewController.h"

//Settings
#import "Setting.h"

#import "Profile.h"

#import "RegistrationApi.h"
#import "FetchUserContactAPI.h"

#define kNumberOfSections 2
#define kPrimaryNumberSectionRowCount 1
#define kCellLabelTag 99
#define kSectionHeaderLabelTag 199
#define kPrimaryNumberSectionTab 2099
#define kCellIdentifier @"IVNumbersCell"
#define kPrimaryNumCellIdentifier @"PrimaryVoiceMailListCell"
#define kContactIdKey @"contact_id"
#define kCountryCodeKey @"country_code"

#define kPrimaryNumberCanNotDeleteErrorCode 88

//Enums
typedef NS_ENUM(NSUInteger,Sections){
    ePrimaryNumberSection = 0,
    eAdditionalNumberSection,
};

typedef NS_ENUM(NSUInteger, ContactUpdateType) {
    eContactUpdateType = 0,
    eContactAddType,
    eContactDeleteType
};

@interface IVVoiceMailListViewController () <SettingProtocol,VerificationOTPViewControllerDelegate>{
    NSArray *iconArray;
}
@property (weak, nonatomic) IBOutlet UIView *sectionHeaderView;
@property (weak, nonatomic) IBOutlet UITableView *voiceMailListTableView;
@property (nonatomic, strong) IVVoiceMailListCell *listCell;
@property (nonatomic, strong) IVPrimaryVoiceMailListCell* primaryNumCell;
@property (nonatomic, strong) SettingModel *currentSettingsModel;
@property (nonatomic, strong) UserProfileModel *currentUserProfileDetails;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) NSMutableArray *additionalLinkedVerifiedNumbers, *additionalLinkedNonVerifiedNumbers, *linkedMobileNumbers;
@property (nonatomic, strong) NSMutableArray *verifiedSecondaryNumbers;
@property (nonatomic, strong) NSMutableArray *verifiedNumbers;

@property (nonatomic, strong) NSString *currentNetworkName;
@property (nonatomic, strong) NSString *helpText;
@property (nonatomic, strong) NSString *activationDialNumber;
@property (nonatomic, strong) NSMutableArray *helpTextArray;
@property (nonatomic, strong) NSMutableArray *supportContactList;
@property (nonatomic, strong) NSArray *customImageName;

//NOV 24, 2016 @property (nonatomic, strong) NSMutableArray *additionalNumbersVoiceMailInfo;
@property (weak, nonatomic) IBOutlet UIView *sectionPrimaryNumber;

@property (nonatomic, assign) BOOL isEditingCell;

@property (nonatomic, strong) NSString *randomImageName;

@end

@implementation IVVoiceMailListViewController

#pragma mark - View Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Numbers", nil);
    self.isEditingCell = NO;
    self.additionalLinkedVerifiedNumbers = [[NSMutableArray alloc]init];
    self.additionalLinkedNonVerifiedNumbers = [[NSMutableArray alloc]init];
    self.linkedMobileNumbers = [[NSMutableArray alloc]init];
    [self.voiceMailListTableView setContentOffset:CGPointZero animated:YES];
    [self.voiceMailListTableView setEditing:YES animated:YES];
    self.voiceMailListTableView.allowsSelectionDuringEditing = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    iconArray = @[@"mobile_red_icon",@"iphone_icon",@"mobile_purple_icon",@"mobile_green_icon",@"mobile_red_icon",@"iphone_icon",@"mobile_purple_icon",@"mobile_green_icon",@"mobile_red_icon",@"iphone_icon",@"mobile_red_icon",@"iphone_icon",@"mobile_purple_icon",@"mobile_green_icon",@"mobile_red_icon",@"iphone_icon",@"mobile_purple_icon",@"mobile_green_icon",@"mobile_red_icon",@"iphone_icon",@"mobile_red_icon",@"iphone_icon",@"mobile_purple_icon",@"mobile_green_icon",@"mobile_red_icon",@"iphone_icon",@"mobile_purple_icon",@"mobile_green_icon",@"mobile_red_icon",@"iphone_icon"];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = NO;
    appDelegate.tabBarController.tabBar.hidden = YES;
    [self configureHelpAndSuggestion];
    [self processLinkedNumbersFromProfileData];
    
    [self loadLatestDataFromServer];
    
    //If we do not have additional numbers then only fetch user settings!
    if (!(self.additionalNumbers && [self.additionalNumbers count])) {
        [self showLoadingIndicator];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@NO forKey:kUserSettingsFetched];
        [userDefaults synchronize];
        [Setting sharedSetting].delegate = self;
        [[Setting sharedSetting]getUserSettingFromServer];
    }
    
    self.uiType = VOICEMAIL_LIST_VIEWCONTROLLER;
    [appDelegate.stateMachineObj setCurrentUI:self];
    //- Set the empty space at top and bottome with the specified color
    UIView *bgView = [UIView new];
    bgView.frame = self.view.frame;
    bgView.layer.borderWidth = .1;
    bgView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:244.0/255.0];
    [self.voiceMailListTableView setBackgroundView:bgView];
    
    UIView *bgFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.voiceMailListTableView.frame.size.width,1)];
    bgFooterView.layer.borderWidth = .1;
    bgFooterView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:244.0/255.0];
    [self.voiceMailListTableView setTableFooterView:bgFooterView];
    //
    //Settings - TextFlow related changes notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    if ([[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP]) {
        
        IVLinkedNumberVoiceMailViewController *linkedNumberVoiceMailView = [[UIStoryboard storyboardWithName:@"IVVoiceMailMissedCallSettingsStoryBoard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"IVLinkedNumberVoiceMail"];
        linkedNumberVoiceMailView.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getVerifiedOTPNumber];
        linkedNumberVoiceMailView.imageName = self.randomImageName;
        [self.navigationController pushViewController:linkedNumberVoiceMailView animated:YES];
        
    }
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //Remove ContentSizeCategoryDidChangeNotification
    self.isEditingCell = NO;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Datasource Methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    switch (section) {
        case ePrimaryNumberSection:
            numberOfRows = kPrimaryNumberSectionRowCount;
            break;
        case eAdditionalNumberSection:
            numberOfRows = [self.linkedMobileNumbers count];
            break;
        default:
            break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    static NSString *cellIdentifier = @"";
    cellIdentifier = kCellIdentifier;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    switch (indexPath.section) {
        case ePrimaryNumberSection: {
            
            IVVoiceMailListCell* primaryNumberCell = (IVVoiceMailListCell*)cell;
            NSString *networkName = @"";
            IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.primaryNumber];
            
            if (carrierInfo) {
                networkName = carrierInfo.networkName;
            }else{
                CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
                
                if (carrierDetails) {
                    
                    if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
                        networkName = @"Not Listed";
                    }else{
                        networkName = @"";
                    }
                }else{
                    networkName = @"";
                }
            }
            
            VoiceMailInfo *primaryNumberVoiceMailInfo;
            self.currentSettingsModel = [Setting sharedSetting].data;
            if (self.currentSettingsModel) {
                if (self.currentSettingsModel.voiceMailInfo && [self.currentSettingsModel.voiceMailInfo count]) {
                    for (VoiceMailInfo *voiceMailInfo in self.currentSettingsModel.voiceMailInfo) {
                        if([voiceMailInfo.phoneNumber isEqualToString:self.primaryNumber]) {
                            primaryNumberVoiceMailInfo = voiceMailInfo;
                        }
                    }
                    
                }
            }
            
            if (!primaryNumberVoiceMailInfo || !primaryNumberVoiceMailInfo.countryVoicemailSupport) {
                networkName = @"Not supported";
            }
            
            CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
            
            NumberInfo *numberDetails = [[Setting sharedSetting]customNumberInfoForPhoneNumber:self.primaryNumber];
            
            NSString* titleName = @"";
            NSString* imageName = @"";
            NSString* contactNumber = [Common getFormattedNumber:self.primaryNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
            NSString *combinedString = @"";
            
            if (numberDetails.titleName.length > 0) {
                titleName = numberDetails.titleName;
                combinedString = [NSString stringWithFormat:@"%@ . %@",contactNumber,networkName];
            }else{
                titleName = contactNumber;
                combinedString = networkName;
            }
            
            if (numberDetails.imgName.length > 0) {
                imageName = numberDetails.imgName;
                imageName = [imageName stringByAppendingString:@"_icon"];
            }else{
                imageName = @"work_icon";
            }
            
            primaryNumberCell.titleLabel.text = NSLocalizedString(titleName, nil);
            primaryNumberCell.numberInfoLabel.text = combinedString;
            primaryNumberCell.verifyNumberButton.hidden = YES;
            [primaryNumberCell.infoIconButton addTarget:self action:@selector(primaryNumberInfo:) forControlEvents:UIControlEventTouchUpInside];
            primaryNumberCell.iconImageView.image = [UIImage imageNamed:imageName];
            
            primaryNumberCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
            primaryNumberCell.numberInfoLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
            
            if ([self primaryNumberIsActive] && carrierDetails)
                primaryNumberCell.activeStatus.image = [UIImage imageNamed:@"voicemail_active"];
            else
                primaryNumberCell.activeStatus.image = [UIImage imageNamed:@"voicemail_not_active"];
            
            break;
        }
        case eAdditionalNumberSection: {
            IVVoiceMailListCell* additionaNumbersCell = (IVVoiceMailListCell*)cell;
            self.customImageName = iconArray;
            
            additionaNumbersCell.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
            additionaNumbersCell.verifyNumberButton.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
            additionaNumbersCell.numberInfoLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
            
            if([self.linkedMobileNumbers count]) {
                additionaNumbersCell.titleLabel.text =
                        [Common getFormattedNumber:[self.linkedMobileNumbers objectAtIndex:indexPath.row] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
            }
            NSString* contactNumber = [Common getFormattedNumber:[self.linkedMobileNumbers objectAtIndex:indexPath.row] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        
            NSString *networkName = @"";
            IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:[self.linkedMobileNumbers objectAtIndex:indexPath.row]];
            CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:[self.linkedMobileNumbers objectAtIndex:indexPath.row]];
            
            NumberInfo *numberDetails = [[Setting sharedSetting]customNumberInfoForPhoneNumber:[self.linkedMobileNumbers objectAtIndex:indexPath.row]];
            
            if (carrierInfo) {
                networkName = carrierInfo.networkName;
            }else{
                
                if (carrierDetails) {
                    
                    if ([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1) {
                        networkName = @"Not Listed";
                    }else{
                        networkName = @"";
                    }
                }else{
                    networkName = @"";
                }
            }
            
            VoiceMailInfo *linkedNumberVoiceMailInfo;
            self.currentSettingsModel = [Setting sharedSetting].data;
            if (self.currentSettingsModel) {
                if (self.currentSettingsModel.voiceMailInfo && [self.currentSettingsModel.voiceMailInfo count]) {
                    for (VoiceMailInfo *voiceMailInfo in self.currentSettingsModel.voiceMailInfo) {
                        if([voiceMailInfo.phoneNumber isEqualToString:[self.linkedMobileNumbers objectAtIndex:indexPath.row]]) {
                            linkedNumberVoiceMailInfo = voiceMailInfo;
                        }
                    }
                    
                }
            }
            
            if (!linkedNumberVoiceMailInfo || !linkedNumberVoiceMailInfo.countryVoicemailSupport) {
                networkName = @"Not supported";
            }
            
            if(![[self.additionalLinkedVerifiedNumbers valueForKey:kContactIdKey] containsObject:[self.linkedMobileNumbers objectAtIndex:indexPath.row]])
                networkName = @"";
            
            NSString* titleName = @"";
            NSString* imageName = @"";
            NSString *combinedString = @"";
            
            if (numberDetails.titleName.length > 0) {
                titleName = numberDetails.titleName;
                combinedString = [NSString stringWithFormat:@"%@ . %@",contactNumber,networkName];
            }else{
                titleName = contactNumber;
                combinedString = networkName;
            }
            
            if (numberDetails.imgName.length > 0) {
                imageName = numberDetails.imgName;
                imageName = [imageName stringByAppendingString:@"_icon"];
            }else{
                imageName = [iconArray objectAtIndex:indexPath.row];//TODO: later
                self.randomImageName = imageName;
            }
            
            additionaNumbersCell.titleLabel.text = titleName;
            additionaNumbersCell.numberInfoLabel.text = combinedString;
            additionaNumbersCell.verifyNumberButton.hidden = [[self.additionalLinkedVerifiedNumbers valueForKey:kContactIdKey] containsObject:[self.linkedMobileNumbers objectAtIndex:indexPath.row]]? YES: NO;
            additionaNumbersCell.infoIconButton.hidden = YES;
            additionaNumbersCell.iconImageView.image = [UIImage imageNamed:imageName];
            
            [additionaNumbersCell.verifyNumberButton addTarget:self action:@selector(verifyLinkedNumber:) forControlEvents:UIControlEventTouchUpInside];
            [additionaNumbersCell.verifyNumberButton setTitleColor:[UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f] forState:UIControlStateNormal];
            additionaNumbersCell.verifyNumberButton.tag = indexPath.row;
            
            if (![[self.additionalLinkedVerifiedNumbers valueForKey:kContactIdKey] containsObject:[self.linkedMobileNumbers objectAtIndex:indexPath.row]]) {
                additionaNumbersCell.activeStatus.image = [UIImage imageNamed:@"voicemail_not_active"];
            }else{
                if ([self linkedNumberIsActive:[self.linkedMobileNumbers objectAtIndex:indexPath.row] withVoiceMailInfo:linkedNumberVoiceMailInfo] && carrierDetails) {
                    additionaNumbersCell.activeStatus.image = [UIImage imageNamed:@"voicemail_active"];
                }else{
                    additionaNumbersCell.activeStatus.image = [UIImage imageNamed:@"voicemail_not_active"];
                }
            }
            //
            break;
        }
        default:
            break;
    }
    [cell layoutIfNeeded];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *headerTitle = @[@"PRIMARY NUMBER",@"LINKED NUMBERS"];
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 20.0, 250.0, 40.0)];
    label.text = NSLocalizedString([headerTitle objectAtIndex:section], nil);
    label.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    
    CGFloat buttonWidth;
    if(section == 0)
        buttonWidth = 150.0;
    else
        buttonWidth = 135.0;
    
    UIButton *changePrimaryNumber = [UIButton buttonWithType:UIButtonTypeSystem];
    changePrimaryNumber.frame = CGRectMake(DEVICE_WIDTH - 150.0, 20.0, buttonWidth, 40.0);
    [changePrimaryNumber setTitleColor:[UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f] forState:UIControlStateNormal];
    changePrimaryNumber.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    changePrimaryNumber.hidden = YES;
    
    if (section == 0) {
        [changePrimaryNumber setTitle:@"Change Primary" forState:UIControlStateNormal];
        [changePrimaryNumber addTarget:self action:@selector(changePrimaryNumber:) forControlEvents:UIControlEventTouchUpInside];
        if(self.verifiedSecondaryNumbers.count > 0)
            changePrimaryNumber.hidden = NO;
    }else if (section == 1){
        [changePrimaryNumber setTitle:self.isEditingCell?@"Done":@"Edit" forState:UIControlStateNormal];
        changePrimaryNumber.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        changePrimaryNumber.hidden = NO;
        [changePrimaryNumber addTarget:self action:@selector(editLinkedNumbers:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [tableHeaderView addSubview:label];
    [tableHeaderView addSubview:changePrimaryNumber];
    return tableHeaderView;
}

//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    
//    if(ePrimaryNumberSection == section) {
//        return @"SELECT NUMBER TO CONTINUE";
//    }
//    else {
//        if([self.additionalNumbers count]>1)
//            return @"LINKED MOBILE NUMBERS";
//        else if([self.additionalNumbers count])
//            return @"LINKED MOBILE NUMBER";
//    }
//    
//    return nil;
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    CGRect headerFrame = header.frame;
//    headerFrame.size.height = 54;
//    header.frame = headerFrame;
//    
//    header.textLabel.textColor = [UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1.0];
//    header.textLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
//    [header.textLabel sizeToFit];
//    header.textLabel.contentMode = UIViewContentModeBottom;
//    
//    header.contentMode = UIViewContentModeBottom;
//    header.textLabel.textAlignment =  NSTextAlignmentNatural;
//    header.backgroundView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:244.0/255.0 alpha:1.0];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    /*
    NSString *titleString = [self tableView:tableView titleForHeaderInSection:section];
    CGSize textSize = CGSizeZero;
    textSize = [Common sizeOfViewWithText:titleString withFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    CGFloat sectionHeaderHeight =  textSize.height + kHeaderHeightOffset;
    return sectionHeaderHeight;
     */
    return 54.0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}


#pragma mark - TableView Deleagte Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    VoiceMailInfo *voiceMailInfo;
    NSString *phoneNumber;
    switch (indexPath.section) {
        case ePrimaryNumberSection: {
            voiceMailInfo = self.primaryNumberVoiceMailInfo;
            phoneNumber = self.primaryNumber;
            
            IVPrimaryNumberVoiceMailViewController *primaryNumberVoiceMailView = [[UIStoryboard storyboardWithName:@"IVVoiceMailMissedCallSettingsStoryBoard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"IVPrimaryNumberVoiceMail"];
            [self.navigationController pushViewController:primaryNumberVoiceMailView animated:YES];
            
            break;
        }
        case eAdditionalNumberSection: {
            if (![[self.additionalLinkedVerifiedNumbers valueForKey:kContactIdKey] containsObject:[self.linkedMobileNumbers objectAtIndex:indexPath.row]]) {
                return;
            }
            
            if (self.additionalNumbersVoiceMailInfo && [self.additionalNumbersVoiceMailInfo count]) {
                voiceMailInfo = [self.additionalNumbersVoiceMailInfo objectAtIndex:indexPath.row];
            }
            if (self.linkedMobileNumbers && [self.linkedMobileNumbers count]) {
                phoneNumber = [self.linkedMobileNumbers objectAtIndex:indexPath.row];
            }
            
            if (!self.isEditingCell){
                IVLinkedNumberVoiceMailViewController *linkedNumberVoiceMailView = [[UIStoryboard storyboardWithName:@"IVVoiceMailMissedCallSettingsStoryBoard" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"IVLinkedNumberVoiceMail"];
                linkedNumberVoiceMailView.phoneNumber = phoneNumber;
                linkedNumberVoiceMailView.imageName = [self.customImageName objectAtIndex:indexPath.row];
                linkedNumberVoiceMailView.voiceMailInfo = voiceMailInfo;
                [self.navigationController pushViewController:linkedNumberVoiceMailView animated:YES];
            }
            
            break;
        }
        default:
            break;
    }
    return;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1){
        if(indexPath.row < self.linkedMobileNumbers.count)
            if (self.isEditingCell)
                return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1){
        if(indexPath.row < self.linkedMobileNumbers.count)
            if (self.isEditingCell)
                return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
            NSString *title = [NSString stringWithFormat:@"Confirm Delete\n %@",[Common getFormattedNumber:[@"+" stringByAppendingString:[self.linkedMobileNumbers objectAtIndex:indexPath.row]] withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
            
            
            UIAlertController *alertController =   [UIAlertController
                                                    alertControllerWithTitle:NSLocalizedString(title,nil)
                                                    message:NSLocalizedString(@"You are about to delete this number from your account, are you sure?", nil)
                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alertController dismissViewControllerAnimated:YES completion:nil];
                                     }];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self deleteNumber:[self.linkedMobileNumbers objectAtIndex:indexPath.row]];
                                     [alertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            [alertController addAction:cancel];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        }else{
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        }
    }
}

- (void)deleteNumber:(NSString *)phoneNumber
{
    [self showProgressBar];
    NSMutableArray *verifiedNumberDetails;
    NSMutableArray *verifiedNumbers;
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    
    verifiedNumberDetails = currentUserProfileDetails.additionalVerifiedNumbers;
    self.additionalLinkedNonVerifiedNumbers = currentUserProfileDetails.additionalNonVerifiedNumbers;
    verifiedNumbers = [[NSMutableArray alloc]initWithArray:[verifiedNumberDetails valueForKeyPath:kContactIdKey]];
    
    BOOL __block isNumberDeleted = NO;
    //We are very sure that this button belongs to the LinkedNumber Row.
    //Check the number is verified or non verified. If number is non verified remove from the - nonverified details and update the profile data.
    
    NSString *phoneNumberToBeDeleted = phoneNumber;//TODO Check bounds
    NSArray *nonVerifiedNumberList = [self.additionalLinkedNonVerifiedNumbers valueForKeyPath:kContactIdKey];
    
    if ([nonVerifiedNumberList containsObject:phoneNumberToBeDeleted]) {
        //Check nonVerified List contains phoneNumberToBeDeleted.
        for (phoneNumberToBeDeleted in nonVerifiedNumberList) {
            //Yes, Its belonging to non verified number - remove from the local list and update the profile data - nonverified number list.
            for (NSDictionary *numberInfo in self.additionalLinkedNonVerifiedNumbers) {
                if ([[numberInfo valueForKey:kContactIdKey] isEqualToString:phoneNumberToBeDeleted]) {
                    [self.additionalLinkedNonVerifiedNumbers removeObject:numberInfo];
                    isNumberDeleted = YES;
                    break;
                }
            }
            if (isNumberDeleted) {
                [self hideProgressBar];
                break;
            }
        }
    }
    else {
        //Number should be verified number.
        NSMutableDictionary *dataDictionary = [self dataForUpdatationOfContactToServer:eContactDeleteType withPrimaryPhoneNumberStatus:NO withContactNumber:phoneNumberToBeDeleted withCountryCode:nil];
        
        ManageUserContactAPI* api = [[ManageUserContactAPI alloc]initWithRequest:dataDictionary];
        [self showProgressBar];
        
        [api callNetworkRequest:api.request withSuccess:^(ManageUserContactAPI *req, NSMutableDictionary *responseObject) {
            
            if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
                [self hideProgressBar];
                EnLogd(@"Error calling manage_user_contact %@ and api request %@",dataDictionary,api.request);
            } else {
                [self hideProgressBar];
                if ([self.verifiedNumbers containsObject:phoneNumberToBeDeleted]) {
                    [self.verifiedNumbers removeObject:phoneNumberToBeDeleted];
                    
                    for (NSDictionary *numberInfo in verifiedNumberDetails) {
                        if ([[numberInfo valueForKey:kContactIdKey] isEqualToString:phoneNumberToBeDeleted]) {
                            [verifiedNumberDetails removeObject:numberInfo];
                            isNumberDeleted = YES;
                            break;
                        }
                    }
                }
                [ScreenUtility showAlert:@"Number has been deleted successfully"];
                currentUserProfileDetails.additionalVerifiedNumbers = verifiedNumberDetails;
                currentUserProfileDetails.additionalNonVerifiedNumbers = self.additionalLinkedNonVerifiedNumbers;
                [[Profile sharedUserProfile]writeProfileDataInFile];
                
                //Remove Carrier information of the secondary number if any in settings.
                [[Setting sharedSetting]updateCarrierSettingsInfoForDeletedSecondaryNumber:phoneNumberToBeDeleted];
                
                //Remove Number information of the secondary number if any in settings.
                [[Setting sharedSetting]updateNumberSettingsInfoForDeletedSecondaryNumber:phoneNumberToBeDeleted];
                
                isNumberDeleted = YES;
                //Update the linked Numbers array.
                [self processLinkedNumbersFromProfileData];
            }
            
        } failure:^(ManageUserContactAPI *req, NSError *error) {
            
            isNumberDeleted = NO;
            [self hideProgressBar];
            EnLogd(@"Error calling manage_user_contact api: %@, Error",dataDictionary,[error description]);
            NSInteger errorCode = error.code;
            NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
            if(error.code == kPrimaryNumberCanNotDeleteErrorCode){
                [self fetchUserContacts];
                errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
            }
            if([errorMsg length]) {
                //OCT 13, 2016 [ScreenUtility showAlertMessage: errorMsg];
                [ScreenUtility showAlert: errorMsg];
            }
            
        }];
    }
    
    if (isNumberDeleted) {
        //Update the linked Numbers array.
        [self processLinkedNumbersFromProfileData];
    }
}

#pragma mark - Private Methods -
- (void)fetchUserContacts {
    if( [Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        //OCT 13, 2016 [ScreenUtility showAlert:@"Network is not connected."];
        //[ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    NSMutableDictionary *userList = [[NSMutableDictionary alloc]init];
    long ivUserId = [[ConfigurationReader sharedConfgReaderObj] getIVUserId];
    NSNumber *num = [NSNumber numberWithLong:ivUserId];
    
    [userList setValue:[appDelegate.confgReader getDeviceUUID] forKey:API_DEVICE_ID];
    [userList setValue:num forKey:IV_USER_ID];
    [userList setValue:[appDelegate.confgReader getUserSecureKey] forKey:API_USER_SECURE_KEY];
    
    FetchUserContactAPI* api = [[FetchUserContactAPI alloc]initWithRequest:userList];
    [api callNetworkRequest:userList withSuccess:^(FetchUserContactAPI *req, NSMutableDictionary *responseObject) {
        if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
            EnLogd(@"Error fetching the user userlist %@ and api request %@",userList,api.request);
        } else {
            [self.linkedMobileNumbers removeAllObjects];
            NSArray *userContacts = [responseObject valueForKey:@"user_contacts"];
            UserProfileModel *model = [[Profile sharedUserProfile]profileData];
            NSMutableArray *additionalNonVerifiedNumbers = [model.additionalNonVerifiedNumbers mutableCopy];
            NSMutableArray *additionalVerifiedNumbers = [model.additionalVerifiedNumbers mutableCopy];
            
            [additionalVerifiedNumbers removeAllObjects];
            
            for (int i=0; i<[userContacts count]; i++) {
                NSDictionary *userContact = [userContacts objectAtIndex:i];
                
                if([[userContact valueForKey:@"contact_type"] isEqualToString:@"p"]){
                    int isPrimary = [[userContact valueForKey:@"is_primary"] intValue];
                    NSArray *filteredNonVerifiedNumbers = [additionalNonVerifiedNumbers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_id = %@",[userContact valueForKey:@"contact_id"]]];
                    
                    NSDictionary *verifiedNumber = @{ @"contact_id" : [userContact valueForKey:@"contact_id"],
                                                      @"country_code" : [userContact valueForKey:@"country_code"],
                                                      @"is_primary" : [userContact valueForKey:@"is_primary"],
                                                      @"is_virtual" : [userContact valueForKey:@"is_virtual"]
                                                      };
                    
                    if(isPrimary == 1){
                        //Its primary number - update the login id
                        //MAR 9, 2017
                        NSString* curPrimNum = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
                        NSString* newPrimNum = verifiedNumber[@"contact_id"];
                        if(![curPrimNum isEqualToString:newPrimNum]) {
                            [[Engine sharedEngineObj]updateUserIdFrom:curPrimNum toNew:[@"+" stringByAppendingString:newPrimNum]];
                        }
                        //
                        [[ConfigurationReader sharedConfgReaderObj]setLoginId:verifiedNumber[@"contact_id"]];
                        [additionalVerifiedNumbers insertObject:verifiedNumber  atIndex:0];
                        
                    }
                    else{
                        [additionalVerifiedNumbers addObject:verifiedNumber];
                    }
                    if(([additionalVerifiedNumbers containsObject:[userContact valueForKey:@"contact_id"]]) && ([filteredNonVerifiedNumbers count] != 0)){
                        [additionalNonVerifiedNumbers removeObjectsInArray:filteredNonVerifiedNumbers];
                    }
                }
            }
            
            model.additionalVerifiedNumbers = additionalVerifiedNumbers;
            model.additionalNonVerifiedNumbers = additionalNonVerifiedNumbers;
            
            [[Profile sharedUserProfile]writeProfileDataInFile];
            
            [self processLinkedNumbersFromProfileData];
            
            [[Setting sharedSetting]fetchCarrierList];
        }
    }failure:^(FetchUserContactAPI *req, NSError *error) {
        EnLogd(@"*** Error fetching the user: %@, %@",userList,[error description]);
        KLog(@"*** Error fetching the user: %@, %@",userList,[error description]);
        
        /* SEP 28, 2016
         NSInteger errorCode = error.code;
         NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
         if([errorMsg length])
         [ScreenUtility showAlertMessage: errorMsg];
         */
    }];
}

- (BOOL)primaryNumberIsActive
{
    CarrierInfo *currentSelectedNumberCarrierInfo = [[Setting sharedSetting] customCarrierInfoForPhoneNumber:self.primaryNumber];
    //check do we have carrier list for the country.
    NSArray *carrierList = [[Setting sharedSetting]carrierListForCountry:self.primaryNumberVoiceMailInfo.carrierCountryCode];
    if (currentSelectedNumberCarrierInfo) {
        if ([currentSelectedNumberCarrierInfo.networkId isEqualToString:@"-1"] && [currentSelectedNumberCarrierInfo.countryCode isEqualToString:@"-1" ] && [currentSelectedNumberCarrierInfo.vSMSId integerValue] == -1) {
            //We do not have USSD Info - Redirect screen to Carrier Selection page.
            return NO;
        }
        
        if (self.primaryNumberVoiceMailInfo) {
            //We have voicemail info
            //Check for voicemail enabled ore not.
            if (self.primaryNumberVoiceMailInfo.isVoiceMailEnabled && self.primaryNumberVoiceMailInfo.countryVoicemailSupport) {
                if (carrierList && [carrierList count]) {
                    //We have custom settings - carrier info - which takes a highest priority in deciding the voicemail and settings page.
                    //Check we have supported carrierInfo in the carrier list.
                    if ([[Setting sharedSetting]hasSupportedCustomCarrierInfo:self.primaryNumber]) {
                        
                        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.primaryNumber];
                        
                        //Yes, we have valid carrier info in the carrier list
                        //Check for valid USSD Info required - actilAll and deactiAll.
                        if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                            //Yes, We have valid USSD Info.
                            return YES;
                        }
                        else {
                            //We do not have USSD info.
                            return NO;
                        }
                    }
                    else {
                        return NO;
                    }
                }
                else {
                    //Fetch carrier list for country.
                    [[Setting sharedSetting]fetchListOfCarriersForCountry:self.primaryNumberVoiceMailInfo.carrierCountryCode];
                    return YES;
                }
            }
            else { //voicemail is not enabled - show the default screen
                return NO;
            }
        }
        else {
            return NO;
        }
    }
    //Check for Sim - MCCMNC and countryCode.
    else if ([[Setting sharedSetting]hasValidSimInfoForPhoneNumber:self.primaryNumber]) {
        //Yes, we have valid sim info.
        //Check for voicemail info
        if (self.primaryNumberVoiceMailInfo) {
            //Yes, we have voicemail info
            if (self.primaryNumberVoiceMailInfo.isVoiceMailEnabled) {
                if (carrierList && [carrierList count]) {
                    //Yes, we have carrier list.
                    //Check for the supported carrier info.
                    if ([[Setting sharedSetting]hasSupportedSimCarrierInfo:self.primaryNumber]) {
                        //Yes, we have supported carrier info.
                        //Check for the valid USSD info for the carrier.
                        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromSimInfoForPhoneNumber:self.primaryNumber];
                        if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                            return YES;
                        }
                        else {
                            return NO;
                        }
                    }
                    else {
                        //We do not have supported carrier info - so redirect it to select your carrier info page.
                        return NO;
                    }
                }
                else {
                    
                    //Fetch carrier list for country.
                    [[Setting sharedSetting]fetchListOfCarriersForCountry:self.primaryNumberVoiceMailInfo.carrierCountryCode];
                    return YES;
                }
                
            }
            else {
                //Voicemail Info not enabled.
                return NO;
            }
        }
        else {
            //No, we do not have voicemail info. Redirect user to the carrier selection page.
            return NO;
            
        }
    }
    else {
        //We do not have supporting sim info - check for the voice mail info
        if (self.primaryNumberVoiceMailInfo) {
            //Yes, we have voicemail info
            //Check for voice mail enabled or not.
            if (self.primaryNumberVoiceMailInfo.isVoiceMailEnabled) {
                if (carrierList && [carrierList count]) {
                    
                    if ([[Setting sharedSetting]hasSupportedVoiceMailInfo:self.primaryNumber]) {
                        //We have supported carrier
                        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromVoiceMailInfoForPhoneNumber:self.primaryNumber];
                        //Check for USSD info
                        if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                            
                            return YES;
                        }
                        else {
                            
                            return NO;
                        }
                    }
                    else {
                        //We do not have supported carrier
                        //Voice mail has not enabled - so redirect it to carrier selection page.
                        
                        return NO;
                    }
                }
                else {
                    //Fetch carrier list for country.
                    [[Setting sharedSetting]fetchListOfCarriersForCountry:self.primaryNumberVoiceMailInfo.carrierCountryCode];
                    return YES;
                }
            }
            else {
                //Voice mail has not enabled - so redirect it to carrier selection page.
                return NO;
            }
        }
        else {
            //We do not have voice mail info - so redirect it to carrier selection page.
            return NO;
        }
    }
    return NO;
}

- (BOOL)linkedNumberIsActive:(NSString *)phoneNumber withVoiceMailInfo:(VoiceMailInfo *)withVoiceMailInfo
{
    self.currentSettingsModel = [Setting sharedSetting].data;
    
    //check do we have carrier list for the country.
    NSArray *carrierList = [[Setting sharedSetting]carrierListForCountry:withVoiceMailInfo.carrierCountryCode];
    
    //We have only primary number - based on the voicemail info - decide the next screen.
    //Check whether - voicemail has been already activated? If activated - redirect user to the successfully activated screen.
    //Get the carrier information for the number.
    CarrierInfo *currentSelectedNumberCarrierInfo = [[Setting sharedSetting] customCarrierInfoForPhoneNumber:phoneNumber];
    if (currentSelectedNumberCarrierInfo) {
        if ([currentSelectedNumberCarrierInfo.networkId isEqualToString:@"-1"] && [currentSelectedNumberCarrierInfo.countryCode isEqualToString:@"-1" ] && [currentSelectedNumberCarrierInfo.vSMSId integerValue] == -1) {
            //We do not have USSD Info - Redirect screen to Carrier Selection page.
            return NO;
        }
        //We have custom settings carrier info
        //Check for the voice mail info
        if (withVoiceMailInfo) {
            //Yes, we have voicemail info
            //check for the voicemail info enabled.
            if (withVoiceMailInfo.isVoiceMailEnabled) {
                
                if (carrierList && [carrierList count]) {
                    //Yes, we have carrier list. Check for the valid carrier in the carrier list.
                    if ([[Setting sharedSetting]hasSupportedCustomCarrierInfo:phoneNumber]) {
                        //Yes, we have valid carrier info
                        
                        IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:phoneNumber];
                        if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                            return YES;
                        }
                        else {
                            
                            return NO;
                        }
                        
                    }
                    else {
                        
                        return NO;
                    }
                    
                }
                else {
                    //Fetch carrier list for country.
                    [[Setting sharedSetting]fetchListOfCarriersForCountry:withVoiceMailInfo.carrierCountryCode];
                    
                    return YES;
                }
            }
            else {
                
                return NO;
            }
        }
        else {
            
            return NO;
        }
    }
    
    //We do not have custom settings information. - check for sim information for primary phone only
    else {
        BOOL checkForVoiceMailInfo = YES;
        
        //Its not primary phone number - so check for voice mail info
        if (checkForVoiceMailInfo) {
            if (withVoiceMailInfo) {
                
                if (withVoiceMailInfo.isVoiceMailEnabled && withVoiceMailInfo.countryVoicemailSupport) {
                    
                    if (carrierList && [carrierList count]) {
                        
                        if ([[Setting sharedSetting]hasSupportedVoiceMailInfo:phoneNumber]) {
                            
                            IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromVoiceMailInfoForPhoneNumber:phoneNumber];
                            if ([[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                                
                                return YES;
                            }
                            else {
                                
                                return NO;
                                
                            }
                        }
                        else {
                            
                            return NO;
                            
                        }
                        
                    }
                    else {
                        //Fetch carrier list for country.
                        [[Setting sharedSetting]fetchListOfCarriersForCountry:withVoiceMailInfo.carrierCountryCode];
                        
                        return YES;
                    }
                }
                else {
                    
                    
                    return NO;
                    
                }
                
            }
            else {
                
                return NO;
                
            }
        }
    }
    return NO;
}

- (void)processLinkedNumbersFromProfileData {
    
    //Get the primary number information.
    self.primaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
    
    //TODO : reverify the logic of this method - we can optimise!!!
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    //Profile - additionalVerifiedNumbers and additionalNonVerifiedNumbers
    
    NSMutableArray *profileVerifiedNumbers = currentUserProfileDetails.additionalVerifiedNumbers;
    NSMutableArray *profileNonVerifiedNumbers = currentUserProfileDetails.additionalNonVerifiedNumbers;
    
    self.additionalLinkedVerifiedNumbers = profileVerifiedNumbers;
    
    self.additionalLinkedNonVerifiedNumbers = profileNonVerifiedNumbers;
    
    
    if (!(self.additionalLinkedVerifiedNumbers && [self.additionalLinkedVerifiedNumbers count])) {
        self.additionalLinkedVerifiedNumbers = [[NSMutableArray alloc]init];
        //Add primary number as verified numbers - in the first index
        NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
        NSNumber *countryIsdCode = [phoneUtil extractCountryCode:self.primaryNumber nationalNumber:nil];
        NSDictionary *verifiedNumber = @{kContactIdKey : self.primaryNumber,
                                         kCountryCodeKey : countryIsdCode,
                                         };
        [self.additionalLinkedVerifiedNumbers insertObject:verifiedNumber atIndex:0];
    }
    
    //Update profile data with verified and non verified numbers.
    currentUserProfileDetails.additionalVerifiedNumbers = _additionalLinkedVerifiedNumbers;
    currentUserProfileDetails.additionalNonVerifiedNumbers = _additionalLinkedNonVerifiedNumbers;
    [[Profile sharedUserProfile]writeProfileDataInFile];
    
    //Update the carrier list information in the settings
    [[Setting sharedSetting]fetchCarrierList];
    
    //Reconstruct the linkedNumbers Array
    if (self.linkedMobileNumbers && [self.linkedMobileNumbers count]) {
        [self.linkedMobileNumbers removeAllObjects];
        self.linkedMobileNumbers = nil;
    }
    
    self.linkedMobileNumbers = [[NSMutableArray alloc]init];
    [self.linkedMobileNumbers addObjectsFromArray:[self.additionalLinkedVerifiedNumbers valueForKeyPath:kContactIdKey]];
    [self.linkedMobileNumbers addObjectsFromArray:[self.additionalLinkedNonVerifiedNumbers valueForKeyPath:kContactIdKey]];
    [self.linkedMobileNumbers removeObject:self.primaryNumber];
    
    if(self.linkedMobileNumbers.count)
    {
        self.linkedMobileNumbers = [NSMutableArray arrayWithArray:[self.linkedMobileNumbers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    
    self.verifiedNumbers = [[NSMutableArray alloc]initWithArray:[self.additionalLinkedVerifiedNumbers valueForKeyPath:kContactIdKey]];
    self.verifiedSecondaryNumbers =  [[NSMutableArray alloc]initWithArray:self.verifiedNumbers];
    [self.verifiedSecondaryNumbers removeObject:self.primaryNumber];
    
    dispatch_async(dispatch_get_main_queue()
                   , ^{
                       
                       //Reload TableView.
                       [self.voiceMailListTableView reloadData];
                       
                   });
    
    if (self.linkedMobileNumbers.count < 4) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    [self.voiceMailListTableView reloadData];
}

#pragma mark - Settings Protocol Methods -
- (void)fetchSettingCompletedWith:(SettingModel*)modelData withFetchStatus:(BOOL)withFetchStatus {
    
    KLog(@"fetchSettingCompletedWith. withFetchStatus = %d",withFetchStatus);
    
    [self hideLoadingIndicator];
    
    if(withFetchStatus)
        [self loadLatestDataFromServer];
}

- (void)helpAction
{
    IVSettingsCountryCarrierInfo *carrierInfo = [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber: self.primaryNumber];
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:self.primaryNumber];
    
    if (self.primaryNumberVoiceMailInfo.countryVoicemailSupport && !self.primaryNumberVoiceMailInfo.isVoiceMailEnabled && [[Setting sharedSetting]hasCarrierContainsValidUSSDInfo:carrierInfo]) {
        self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", carrierInfo.networkName, carrierInfo.ussdInfo.actiAll];
    }else if (([carrierDetails.networkId isEqualToString:@"-1"] && [carrierDetails.countryCode isEqualToString:@"-1" ] && [carrierDetails.vSMSId integerValue] == -1)|| !self.primaryNumberVoiceMailInfo.countryVoicemailSupport || !carrierInfo.networkName.length) {
        self.helpText = [NSString stringWithFormat:@"Hi, I'm interested in InstaVoice Voicemail/Missed Call alerts. Please inform me when it's made available for my Carrier:"];
    }else if (self.primaryNumberVoiceMailInfo.isVoiceMailEnabled) {
        self.helpText = @"";
    }else{
        self.helpText = [NSString stringWithFormat:@"Hi, I'm interested in InstaVoice Voicemail/Missed Call alerts. Please inform me when it's made available for my Carrier: %@",carrierInfo.networkName];
    }
    
    [self showHelpMessage];
}

- (void)configureHelpAndSuggestion
{
    self.helpTextArray = [[NSMutableArray alloc]init];
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
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE",nil)];
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
    [newDic setValue:self.helpText forKey:@"HELP_TEXT"];
    
    
    //- get the pic
    NSNumber* ivID = [NSNumber numberWithLong:[ivUserId longLongValue]];
    NSArray* arr = [[Contacts sharedContact]getContactForIVUserId:ivID usingMainContext:YES];
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

- (NSMutableDictionary *)dataForUpdatationOfContactToServer:(NSInteger)withUpdationType withPrimaryPhoneNumberStatus:(BOOL)withPhoneNumberStatus withContactNumber:(NSString *)withContactNumber withCountryCode:(NSString *)withCountryCode{
    
    NSString *operation;
    NSNumber *isPrimaryStatus = [NSNumber numberWithBool:withPhoneNumberStatus];
    NSMutableDictionary *dataInfo = [[NSMutableDictionary alloc]init];
    
    switch (withUpdationType) {
        case eContactAddType: {
            operation = @"a";
            [dataInfo setValue:withCountryCode forKey:@"country_code"];
            break;
        }
        case eContactDeleteType:
            operation = @"d";
            break;
        case eContactUpdateType:
            operation = @"u";
            break;
        default:
            break;
    }
    NSString *phoneNumber = [withContactNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [dataInfo setValue:phoneNumber forKey:@"contact"];
    [dataInfo setValue:@"p" forKey:@"contact_type"];
    [dataInfo setValue:operation forKey:@"operation"];
    [dataInfo setValue:isPrimaryStatus forKey:@"set_as_primary"];
    return dataInfo;
}

#pragma mark - VerificationOTP Delegate Methods -

- (void)updateAdditionalNumbers {
    
    [self processLinkedNumbersFromProfileData];
    
}

- (void)addingNonVerifiedNumber:(NSString *)nonVerifiedNumber withcountrycode:(NSString *)countryCode {
    // NSLog(@"Additional non verified numbers =%@ and Country Code =%@", nonVerifiedNumber, countryCode);
    
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    
    //Check for the existance of the non verified numbers array - if not create one.
    if (!(self.additionalLinkedNonVerifiedNumbers && [self.additionalLinkedNonVerifiedNumbers count])) {
        self.additionalLinkedNonVerifiedNumbers  = [[NSMutableArray alloc]init];
    }
    //Add non verified number details into the list.
    //Create a dictionary with the "contryCode" and "contactNumber" and add it to the array.
    NSDictionary *nonVerifiedNumberInfo = @{
                                            kContactIdKey : nonVerifiedNumber,
                                            kCountryCodeKey : countryCode,
                                            };
    
    //Check - NonVerified Number already has the number.
    if (![self.additionalLinkedNonVerifiedNumbers containsObject:nonVerifiedNumberInfo]) {
        [self.additionalLinkedNonVerifiedNumbers addObject:nonVerifiedNumberInfo];
        currentUserProfileDetails.additionalVerifiedNumbers = self.additionalLinkedVerifiedNumbers;
        currentUserProfileDetails.additionalNonVerifiedNumbers = self.additionalLinkedNonVerifiedNumbers;
        [[Profile sharedUserProfile]writeProfileDataInFile];
        
    }
    
}

- (IBAction)verifyLinkedNumber:(id)sender{
    //First verify - the number you are verify cross the limit of secondary numbers.
    if ([self.verifiedSecondaryNumbers count] == 10 ) {
        [ScreenUtility showAlert:@"Limit Exceeded! Only 10 verified numbers can be linked to account"];
        return;
    }
    
    if ([self.verifiedSecondaryNumbers count] < 10) {
        //get the phone number to be verified.
        NSString *numberToBeVerified = [self.linkedMobileNumbers objectAtIndex:[sender tag]];
        
        //Nonverified number info
        NSDictionary *nonVerifiedNumberInfo;
        
        for (NSDictionary *numberInfo in self.additionalLinkedNonVerifiedNumbers) {
            // NSLog(@"Number is =%@", [numberInfo valueForKey:kContactIdKey]);
            if ([[numberInfo valueForKey:kContactIdKey] isEqualToString:numberToBeVerified]) {
                nonVerifiedNumberInfo = numberInfo;
                break;
            }
        }
        
        //Verify the number.
        VerificationOTPViewController *verify = (VerificationOTPViewController *)[[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"VerifyOTP"];
        verify.userID = numberToBeVerified;
        verify.fromSignUp = false;
        verify.verificationType = MANAGE_USER_CONTACT_TYPE;
        verify.countryCode = [nonVerifiedNumberInfo valueForKey:kCountryCodeKey];
        verify.delegate = self;
        NSDate* now = [NSDate date];
        NSNumber* currentTime = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
        [appDelegate.confgReader setValidationTimer:currentTime];
        [self.navigationController pushViewController:verify animated:YES];
    }
    else {
        [ScreenUtility showAlert:@"Limit Exceeded! Only 10 verified numbers can be linked to account"];
    }
}

- (IBAction)editLinkedNumbers:(id)sender
{
    if (self.isEditingCell)
        self.isEditingCell = NO;
    else
        self.isEditingCell = YES;
    
    [self.voiceMailListTableView reloadData];
}

- (IBAction)changePrimaryNumber:(id)sender
{
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    
    ChangePrimaryNumberViewController *changePrimaryNumberViewController = [[ChangePrimaryNumberViewController alloc]initWithNibName:@"ChangePrimaryNumberViewController" bundle:[NSBundle mainBundle]];
    
    changePrimaryNumberViewController.currentPrimaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
    changePrimaryNumberViewController.verifiedMobileNumberList = self.verifiedNumbers;
    
    changePrimaryNumberViewController.view.frame = CGRectMake(0, 0, 260, CGRectGetHeight([UIScreen mainScreen].applicationFrame)-140);
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:changePrimaryNumberViewController];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.cornerRadius = 8.0;
    formSheet.presentedFormSheetSize = CGSizeMake(260, CGRectGetHeight([UIScreen mainScreen].applicationFrame)-140);
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    
    formSheet.willDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
        
        if(changePrimaryNumberViewController.isSelected) {
            NSMutableDictionary *dataDictionary = [self dataForUpdatationOfContactToServer:eContactUpdateType withPrimaryPhoneNumberStatus:YES withContactNumber:changePrimaryNumberViewController.currentPrimaryNumber withCountryCode:nil];
            ManageUserContactAPI* api = [[ManageUserContactAPI alloc]initWithRequest:dataDictionary];
            [self showProgressBar];
            
            [api callNetworkRequest:api.request withSuccess:^(ManageUserContactAPI *req, NSMutableDictionary *responseObject) {
                
                if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
                    [self hideProgressBar];
                    EnLogd(@"Error blocking the user userlist %@ and api request %@",dataDictionary,api.request);
                } else {
                    [self hideProgressBar];
                    
                    //Update the User Secure Key - As per the mail conversation on date 14th June.
                    if ([responseObject valueForKey:API_USER_SECURE_KEY] && ![[responseObject valueForKey:API_USER_SECURE_KEY] isEqualToString:@""]) {
                        [appDelegate.confgReader setUserSecureKey:[responseObject valueForKey:API_USER_SECURE_KEY]];
                    }
                    
                    
                    [appDelegate.engObj deleteAllChats:self.verifiedSecondaryNumbers];
                    
                    [[Engine sharedEngineObj]updateUserIdFrom:self.primaryNumber toNew:[@"+" stringByAppendingString:changePrimaryNumberViewController.currentPrimaryNumber]];
                    
                    NSArray *serverResponse = responseObject[@"user_contacts"];
                    
                    if (serverResponse && [serverResponse count]) {
                        if (self.additionalLinkedVerifiedNumbers && [self.additionalLinkedVerifiedNumbers count]) {
                            self.additionalLinkedVerifiedNumbers = nil;
                            
                        }
                        self.additionalLinkedVerifiedNumbers = [[NSMutableArray alloc]init];
                        for (int i=0; i<[serverResponse count]; i++) {
                            NSDictionary *userContact = [serverResponse objectAtIndex:i];
                            
                            if([[userContact valueForKey:@"contact_type"] isEqualToString:@"p"]){
                                int isPrimary = [[userContact valueForKey:@"is_primary"] intValue];
                                
                                NSDictionary *verifiedNumber = @{ @"contact_id" : [userContact valueForKey:@"contact_id"],
                                                                  @"country_code" : [userContact valueForKey:@"country_code"],
                                                                  @"is_primary" : [userContact valueForKey:@"is_primary"]
                                                                  };
                                
                                if(isPrimary == 1){
                                    [self.additionalLinkedVerifiedNumbers insertObject:verifiedNumber  atIndex:0];
                                }
                                else{
                                    [self.additionalLinkedVerifiedNumbers addObject:verifiedNumber];
                                }
                                
                            }
                        }
                        
                    }
                    
                    //Delete the carrier logo - once primary number has been changed.
                    NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
                    NSString* localFileName = [NSString stringWithFormat:@"CarrierLogo_%@.png",loginId];
                    [IVFileLocator deleteFileAtPath:[IVFileLocator getCarrierLogoPath:localFileName]];
                    
                    [[ConfigurationReader sharedConfgReaderObj]setLoginId:changePrimaryNumberViewController.currentPrimaryNumber];
                    
                    //TODO : Change the logic here!!!
                    //Get the primary number information.
                    self.primaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
                    
                    [self.verifiedNumbers exchangeObjectAtIndex:0 withObjectAtIndex:[self.verifiedNumbers indexOfObject:changePrimaryNumberViewController.currentPrimaryNumber]];
                    
                    currentUserProfileDetails.additionalVerifiedNumbers = self.additionalLinkedVerifiedNumbers;
                    [[Profile sharedUserProfile]writeProfileDataInFile];
                    [self loadLatestDataFromServer];
                    [self processLinkedNumbersFromProfileData];
                    
                    [ScreenUtility showAlertMessage:@"Setting Saved"];
                }
                
            } failure:^(ManageUserContactAPI *req, NSError *error) {
                [self hideProgressBar];
                EnLogd(@"Error blocking the user: %@, Error",dataDictionary,[error description]);
                NSInteger errorCode = error.code;
                NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
                if([errorMsg length])
                    [ScreenUtility showAlert: errorMsg];
            }];
        }
    };
    
    [formSheet presentAnimated:YES completionHandler:nil];
}

- (IBAction)primaryNumberInfo:(id)sender
{
    UIAlertController *alertController =   [UIAlertController
                                            alertControllerWithTitle:nil
                                            message:NSLocalizedString(@"Primary number is the login number of your InstaVoice account.\n\nInstaVoice message (text, audio & image) sent to the contacts not on the InstaVoice App will receive the message as an SMS from the primary number.\n\nYou can set any of the linked numbers as your primary number by clicking on Change primary number in the linked number list.", nil)
                                            preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *alertMessage = [[NSMutableAttributedString alloc] initWithString:@"Primary number is the login number of your InstaVoice account.\n\nInstaVoice message (text, audio & image) sent to the contacts not on the InstaVoice App will receive the message as an SMS from the primary number.\n\nYou can set any of the linked numbers as your primary number by clicking on Change primary number in the linked number list."];
    [alertMessage addAttribute:NSFontAttributeName
                         value:[UIFont systemFontOfSize:13.0]
                         range:NSMakeRange(0, alertMessage.length)];
    [alertController setValue:alertMessage forKey:@"attributedMessage"];
    
    UIAlertAction *gotIt = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"Got It", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [alertController dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    UIAlertAction *liveHelp = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Get Live Help", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [self helpAction];
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alertController addAction:liveHelp];
    [alertController addAction:gotIt];
    [self presentViewController:alertController animated:YES completion:nil];
    [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
}

#pragma mark - Private Methdos -

- (void)loadLatestDataFromServer {
    
    KLog(@"loadLatestDataFromServer");
    
    self.currentSettingsModel = [Setting sharedSetting].data;
    if (self.currentSettingsModel) {
        
        self.additionalNumbersVoiceMailInfo = [[NSMutableArray alloc]init];
        if (self.currentSettingsModel.voiceMailInfo && [self.currentSettingsModel.voiceMailInfo count]) {
            NSMutableArray *additionalNumberList = [[NSMutableArray alloc]init];
            for (VoiceMailInfo *voiceMailInfo in self.currentSettingsModel.voiceMailInfo) {
                if(![voiceMailInfo.phoneNumber isEqualToString:self.primaryNumber]) {
                    [self.additionalNumbersVoiceMailInfo addObject:voiceMailInfo];
                    [additionalNumberList addObject:voiceMailInfo.phoneNumber];
                }
                else
                    self.primaryNumberVoiceMailInfo = voiceMailInfo;
            }
            self.additionalNumbers = additionalNumberList;
            
            for (int i = 0; i<[self.linkedMobileNumbers count]; i++) {
                if (![[self.additionalLinkedVerifiedNumbers valueForKey:kContactIdKey] containsObject:[self.linkedMobileNumbers objectAtIndex:i]]) {
                    [self.additionalNumbersVoiceMailInfo insertObject:@"" atIndex:i];
                }
            }
        }
        
        [self.voiceMailListTableView reloadData];
    }
}

- (void)showLoadingIndicator {
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
}

- (void)hideLoadingIndicator {
    [self.loadingIndicator stopAnimating];
    self.loadingIndicator.hidden = YES;
}

- (IVVoiceMailListCell*)listCell {
    if (!_listCell)
        _listCell = [self.voiceMailListTableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    return _listCell;
}

- (IVPrimaryVoiceMailListCell*)primaryNumCell {
    if (!_primaryNumCell)
        _primaryNumCell = [self.voiceMailListTableView dequeueReusableCellWithIdentifier:kPrimaryNumCellIdentifier];
    return _primaryNumCell;
}

#pragma mark - BaseUI Method Implementation -
- (void)removeOverlayViewsIfAnyOnPushNotification {
    
    KLog(@"Remove PopOver if any open");
    [ScreenUtility closeAlert];
    [self dismissViewControllerAnimated:YES completion:nil];
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0)
            if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]])
                [(UIAlertView *)[subviews objectAtIndex:0] dismissWithClickedButtonIndex:[(UIAlertView *)[subviews objectAtIndex:0] cancelButtonIndex] animated:NO];
    }
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
    [super removeOverlayViewsIfAnyOnPushNotification];
    
}

#pragma mark - Memory CleanUp Methods -
- (void)dealloc {
    
    //NSLog(@"Dealloc of voicemail carrier list controller has been called");
    
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.primaryNumberVoiceMailInfo = nil;
    //NOV 24, 2016 self.additionalNumberVoiceMailInfo = nil;
    self.primaryNumber = nil;
    self.additionalNumbers = nil;
    
    self.voiceMailListTableView = nil;
    self.listCell = nil;
    self.primaryNumCell = nil;
    self.currentSettingsModel = nil;
    self.currentUserProfileDetails = nil;
    self.loadingIndicator = nil;
    self.additionalNumbersVoiceMailInfo = nil;
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
