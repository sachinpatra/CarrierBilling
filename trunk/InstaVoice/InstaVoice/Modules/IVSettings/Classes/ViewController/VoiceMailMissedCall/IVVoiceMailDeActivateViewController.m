//
//  IVVoiceMailDeActivateViewController.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 07/07/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "IVVoiceMailDeActivateViewController.h"
#import "MyProfileApi.h"
#import "UserProfileModel.h"
#import "InsideConversationScreen.h"
#import "IVFileLocator.h"
#import "IVVoiceMailDeActivateTableViewCell.h"

#define kNumberSectionsInDeActivate 2
#define kNumberOfRowsInDeActivate 1
#define kHeightForSections 100.0
#define kInfoAlertTag 891

#define kVoiceMailDeActivateCellIdentifier @"VoiceMailDeActivateCell"

@interface IVVoiceMailDeActivateViewController ()
@property (nonatomic, strong) NSString *helpText;
@property (nonatomic, strong) NSMutableArray *helpTextArray;
@property (nonatomic, strong) NSMutableArray *supportContactList;
@property (nonatomic, strong) NSString *deactivateDialNumber;
@end

@implementation IVVoiceMailDeActivateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"How to deactivate InstaVoice?", nil);
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpAction)];
    self.navigationItem.rightBarButtonItem = helpButton;
    IVSettingsCountryCarrierInfo *supportedCarrierInfo =
    [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:@""];
    self.deactivateDialNumber = supportedCarrierInfo.ussdInfo.deactiAll;
    [self configureHelpAndSuggestion];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)helpAction
{
    //self.helpText = [NSString stringWithFormat:@"I'm having problems in activating InstaVoice Voicemail & Missed Call Service. My carrier is %@ and the activation number is %@", self.currentNetworkName, self.activationDialNumber];
    [self showHelpMessage];
}

- (void)configureHelpAndSuggestion
{
    self.helpTextArray       = [[NSMutableArray alloc]init];
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
    [newDic setValue:@"" forKey:@"HELP_TEXT"];
    
    
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
    
    //    [appDelegate.stateMachineObj setNavigationController:appDelegate.tabBarController.viewControllers[0]];
    //    [appDelegate.tabBarController setSelectedIndex:0];
    //    [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[0]];
    
    BaseUI* uiObj = [[InsideConversationScreen alloc]initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    uiObj.isAnyChangesSpecificSubClass = YES;
    [self.navigationController pushViewController:uiObj animated:YES];
    //[appDelegate.getNavController pushViewController:uiObj animated:YES];
    
}

#pragma mark - BaseUI Method Implementation -
- (void)removeOverlayViewsIfAnyOnPushNotification {
    
    KLog(@"Remove PopOver if any open");
    [ScreenUtility closeAlert];
    
    NSArray *subViews = self.view.subviews;
    
    for (UIView *subView in subViews) {
        if (subView.tag == kInfoAlertTag) {
            UIAlertView *alertView = (UIAlertView *)subView;
            [alertView dismissWithClickedButtonIndex:1 animated:YES];
        }
    }
    
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
    [super removeOverlayViewsIfAnyOnPushNotification];
    
}

#pragma mark - UITableView Datasource Methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  kNumberSectionsInDeActivate;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSArray *dialCodeArray = [self.deActivationCode componentsSeparatedByString:@";"];
        if(dialCodeArray.count)
            return dialCodeArray.count;
        else
            return kNumberOfRowsInDeActivate;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeightForSections;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *number = [NSString stringWithFormat:@"To deactivate, dial below code(s) on device containing the SIM associated with %@.",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
    NSString *noteString = [NSString stringWithFormat:@"Note: If you face any issues, contact network operator for deactivating call forwarding."];
    NSArray *headerTitle = @[number,noteString];
    
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, section == 0?30.0:16.0, DEVICE_WIDTH - 30.0, 40.0)];
    label.text = NSLocalizedString([headerTitle objectAtIndex:section], nil);
    label.numberOfLines = 0;
    label.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    label.textColor = [UIColor darkGrayColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [label sizeToFit];
    if (section == 1) {
        NSRange range1 = [label.text rangeOfString:@"Note:"];
        NSRange range2 = [label.text rangeOfString:@" If you face any issues, contact network operator for deactivating call forwarding."];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:label.text];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:label.font.pointSize]}
                                range:range1];
        [attributedText setAttributes:@{NSFontAttributeName:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1]}
                                range:range2];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, [attributedText length])];
        label.attributedText = attributedText;
    }
    
    [tableHeaderView addSubview:label];
    return tableHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kVoiceMailDeActivateCellIdentifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[IVVoiceMailDeActivateTableViewCell class]]) {
        IVVoiceMailDeActivateTableViewCell *deActivateVoiceCell = (IVVoiceMailDeActivateTableViewCell *)cell;
        
        NSArray *dialCodeArray = [self.deActivationCode componentsSeparatedByString:@";"];
        if(dialCodeArray.count)
            deActivateVoiceCell.dialerCodeLabel.text = [dialCodeArray objectAtIndex:indexPath.row];
        else
            deActivateVoiceCell.dialerCodeLabel.text = self.deActivationCode;
        
        deActivateVoiceCell.dialerCodeButton.tag = indexPath.row;
        deActivateVoiceCell.dialerCodeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        deActivateVoiceCell.dialerCodeButton.tintColor = [UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f];
        [deActivateVoiceCell.dialerCodeButton addTarget:self action:@selector(deActivateCodeCopy:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell layoutIfNeeded];
    [cell layoutSubviews];
    [cell setNeedsLayout];
    return cell;
}

- (IBAction)deActivateCodeCopy:(id)sender
{
    NSArray *dialCodeArray = [self.deActivationCode componentsSeparatedByString:@";"];
    NSString *dialCode = @"";
    if(dialCodeArray.count)
        dialCode = [dialCodeArray objectAtIndex:[sender tag]];
    else
        dialCode = self.deActivationCode;
    
    [[UIPasteboard generalPasteboard] setString:dialCode>0 ? dialCode : @""];
    [ScreenUtility showAlertMessage:@"Dialer code copied"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
