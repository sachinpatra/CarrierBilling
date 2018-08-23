//
//  IVVoiceMailActivateViewController.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 11/07/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "IVVoiceMailActivateViewController.h"
#import "MyProfileApi.h"
#import "UserProfileModel.h"
#import "InsideConversationScreen.h"
#import "IVFileLocator.h"
#import "IVVoiceMailActivateTableViewCell.h"

#define kNumberSectionsInActivate 2
#define kNumberOfRowsInActivate 1
#define kHeightForSections 100.0
#define kInfoAlertTag 891
#define kVoiceMailDeActivateCellIdentifier @"VoiceMailActivateCell"

@interface IVVoiceMailActivateViewController ()
@property (nonatomic, strong) NSString *helpText;
@property (nonatomic, strong) NSMutableArray *helpTextArray;
@property (nonatomic, strong) NSMutableArray *supportContactList;
@property (nonatomic, strong) NSString *deactivateDialNumber;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@end

@implementation IVVoiceMailActivateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Activate InstaVoice", nil);
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpAction)];
    self.navigationItem.rightBarButtonItem = helpButton;
    IVSettingsCountryCarrierInfo *supportedCarrierInfo =
    [[Setting sharedSetting]supportedCarrierInfoFromCustomSettingsForPhoneNumber:@""];
    self.deactivateDialNumber = supportedCarrierInfo.ussdInfo.deactiAll;
    [self configureHelpAndSuggestion];
    
    NSString *infoString = @"Note: In case you don't get any notification, please contact support.";
    self.noteTextView.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;
    NSURL *URL = [NSURL URLWithString: @""];
    NSMutableAttributedString * linkStr = [[NSMutableAttributedString alloc] initWithString:infoString];
    [linkStr addAttribute: NSLinkAttributeName value:URL range: NSMakeRange(infoString.length - 16, 16)];
    [linkStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, infoString.length)];
    [linkStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0] range:NSMakeRange(0, infoString.length)];
    [linkStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.noteTextView.font.pointSize] range:NSMakeRange(0, 4)];
    [linkStr addAttribute:NSFontAttributeName value:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1] range:NSMakeRange(4, infoString.length - 4)];
    self.noteTextView.attributedText = linkStr;
    self.noteTextView.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
    self.noteTextView.textContainerInset = UIEdgeInsetsMake(0.0, 10.0, 10.0, 10.0);
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    [self helpAction];
    return YES;
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
    return  kNumberSectionsInActivate;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSArray *dialCodeArray = [self.activationCode componentsSeparatedByString:@";"];
        if(dialCodeArray.count)
            return dialCodeArray.count;
        else
            return kNumberOfRowsInActivate;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    NSString *numberStep1 = [NSString stringWithFormat:@"Step 1: Dial a code\nYou can copy & paste the codes on your dialer or you can dial it from the device containing the SIM associated with %@.",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
    
    NSString *numberStep2 = [NSString stringWithFormat:@"Step 2: Verify activation\nYou can test the service by putting your phone on flight mode and dialing %@ from any other phone. When you reach your voicemail, disconnect the call after a beep.\n\nYou will receive a missed call notification in the home tab.",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
    
    NSArray *headerTitle = @[numberStep1,numberStep2];
    
    UITextView *label = [[UITextView alloc] init];
    label.text = NSLocalizedString([headerTitle objectAtIndex:section], nil);
    label.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    [label sizeToFit];
    
    if (section == 0) {
        
        NSString *stringRange = [NSString stringWithFormat:@"You can copy & paste the codes on your dialer or you can dial it from the device containing the SIM associated with %@.",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        
        NSRange range1 = [label.text rangeOfString:@"Step 1: Dial the following code(s)\n"];
        NSRange range2 = [label.text rangeOfString:stringRange];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:label.text];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:label.font.pointSize]}
                                range:range1];
        [attributedText setAttributes:@{NSFontAttributeName:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1]}
                                range:range2];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, [attributedText length])];
        
        label.attributedText = attributedText;
        
    }else{
        
        NSString *stringRange = [NSString stringWithFormat:@"You can test the service by putting your phone on flight mode and dialing %@ from any other phone. When you reach your voicemail, disconnect the call after a beep.\n\nYou will receive a missed call notification in the home tab.",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        NSRange range1 = [label.text rangeOfString:@"Step 2: Verify activation"];
        NSRange range2 = [label.text rangeOfString:stringRange];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:label.text];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:label.font.pointSize]}
                                range:range1];
        [attributedText setAttributes:@{NSFontAttributeName:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1]}
                                range:range2];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, [attributedText length])];
        
        label.attributedText = attributedText;
    }
    
    UITextView *msgLabel = [[UITextView alloc] init];
    msgLabel.text = label.text;
    msgLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    [msgLabel sizeToFit];
    
    CGSize stringSize;
    CGSize lableWidth = CGSizeMake(DEVICE_WIDTH - 20.0, CGFLOAT_MAX);
    CGSize neededSize = [msgLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
    
    stringSize = neededSize;
    stringSize.height += section == 0?30.0:10.0;
    return stringSize.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *numberStep1 = [NSString stringWithFormat:@"Step 1: Dial the following code(s)\nYou can copy & paste the codes on your dialer or you can dial it from the device containing the SIM associated with %@.",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
    
    NSString *numberStep2 = [NSString stringWithFormat:@"Step 2: Verify activation\nYou can test the service by putting your phone on flight mode and dialing %@ from any other phone. When you reach your voicemail, disconnect the call after a beep.\n\nYou will receive a missed call notification in the home tab.",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
    
    NSArray *headerTitle = @[numberStep1,numberStep2];
    
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UITextView *label = [[UITextView alloc] initWithFrame:CGRectMake(10.0, section == 0?15.0:25.0, DEVICE_WIDTH - 32.0, 40.0)];
    label.text = NSLocalizedString([headerTitle objectAtIndex:section], nil);
    label.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    label.editable = NO;
    label.scrollEnabled = NO;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    [label sizeToFit];
    
    if (section == 0) {
        
        NSString *stringRange = [NSString stringWithFormat:@"You can copy & paste the codes on your dialer or you can dial it from the device containing the SIM associated with %@.",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        
        NSRange range1 = [label.text rangeOfString:@"Step 1: Dial the following code(s)\n"];
        NSRange range2 = [label.text rangeOfString:stringRange];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:label.text];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:label.font.pointSize]}
                                range:range1];
        [attributedText setAttributes:@{NSFontAttributeName:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1]}
                                range:range2];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, [attributedText length])];
        
        label.attributedText = attributedText;
    }else{
        
        NSString *stringRange = [NSString stringWithFormat:@"You can test the service by putting your phone on flight mode and dialing %@ from any other phone. When you reach your voicemail, disconnect the call after a beep.\n\nYou will receive a missed call notification in the home tab.",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        NSRange range1 = [label.text rangeOfString:@"Step 2: Verify activation"];
        NSRange range2 = [label.text rangeOfString:stringRange];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:label.text];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:label.font.pointSize]}
                                range:range1];
        [attributedText setAttributes:@{NSFontAttributeName:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1]}
                                range:range2];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, [attributedText length])];
        
        label.attributedText = attributedText;
        label.dataDetectorTypes = UIDataDetectorTypeAll;
    }
    label.tintColor = [UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f];
    [tableHeaderView addSubview:label];
    return tableHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kVoiceMailDeActivateCellIdentifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[IVVoiceMailActivateTableViewCell class]]) {
        IVVoiceMailActivateTableViewCell *activateVoiceCell = (IVVoiceMailActivateTableViewCell *)cell;
        NSArray *dialCodeArray = [self.activationCode componentsSeparatedByString:@";"];
        if(dialCodeArray.count)
            activateVoiceCell.dialerCodeLabel.text = [dialCodeArray objectAtIndex:indexPath.row];
        else
            activateVoiceCell.dialerCodeLabel.text = self.activationCode;
        
        activateVoiceCell.dialerCodeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        activateVoiceCell.dialerCodeButton.tintColor = [UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f];
        activateVoiceCell.dialerCodeButton.tag = indexPath.row;
        [activateVoiceCell.dialerCodeButton addTarget:self action:@selector(activateCodeCopy:) forControlEvents:UIControlEventTouchUpInside];
        
    }
//    self.activateTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 90.0, 0.0);
//    self.activateTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 90.0, 0.0);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell layoutIfNeeded];
    [cell layoutSubviews];
    [cell setNeedsLayout];
    return cell;
}

- (IBAction)activateCodeCopy:(id)sender
{
    NSArray *dialCodeArray = [self.activationCode componentsSeparatedByString:@";"];
    NSString *dialCode = @"";
    if(dialCodeArray.count)
        dialCode = [dialCodeArray objectAtIndex:[sender tag]];
    else
        dialCode = self.activationCode;
        
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
