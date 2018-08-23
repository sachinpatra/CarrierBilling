//
//  IVVoiceMailVerifyInstaVoiceViewController.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 07/07/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "IVVoiceMailVerifyInstaVoiceViewController.h"
#import "MyProfileApi.h"
#import "UserProfileModel.h"
#import "InsideConversationScreen.h"
#import "IVFileLocator.h"
#import "IVVoiceMailVerifyInstaVoiceTableViewCell.h"

#define kNumberSectionsInVerifyInstaVoice 1
#define kNumberOfRowsInVerifyInstaVoice 1
#define kHeightForSections 20.0
#define kHeightForRows 350.0
#define kInfoAlertTag 891

#define kVoiceMailVerifyInstaVoiceCellIdentifier @"VoiceMailVerifyInstaVoiceCell"

@interface IVVoiceMailVerifyInstaVoiceViewController ()
@property (nonatomic, strong) NSString *helpText;
@property (nonatomic, strong) NSMutableArray *helpTextArray;
@property (nonatomic, strong) NSMutableArray *supportContactList;
@end

@implementation IVVoiceMailVerifyInstaVoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Verify InstaVoice is working", nil);
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpAction)];
    self.navigationItem.rightBarButtonItem = helpButton;
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
    return  kNumberSectionsInVerifyInstaVoice;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRowsInVerifyInstaVoice;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeightForSections;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeightForRows;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *tableHeaderView = [[UIView alloc]init];
    tableHeaderView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return tableHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kVoiceMailVerifyInstaVoiceCellIdentifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[IVVoiceMailVerifyInstaVoiceTableViewCell class]]) {
        IVVoiceMailVerifyInstaVoiceTableViewCell *verifyInstaVoiceCell = (IVVoiceMailVerifyInstaVoiceTableViewCell *)cell;
        
        NSString *number = [NSString stringWithFormat:@"Verify with self call\n\nCall your own number: %@ from the device with the same SIM to trigger a busy call. Please disconnect the call after the beep.\n\nOnce verified, you will receive a notification that InstaVoice is active on this number.\n\n\nNote: In case you don’t get any notification, please check the selected carrier and activate again.",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        
        verifyInstaVoiceCell.numberContentView.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
        
        verifyInstaVoiceCell.numberContentView.text = number;
        
        NSRange range1 = [verifyInstaVoiceCell.numberContentView.text rangeOfString:@"Verify with self call"];
        NSRange range2 = [verifyInstaVoiceCell.numberContentView.text rangeOfString:@"Note:"];
        NSString *stringRange = [NSString stringWithFormat:@"\n\nCall your own number: %@ from the device with the same SIM to trigger a busy call. Please disconnect the call after the beep.\n\nOnce verified, you will receive a notification that InstaVoice is active on this number.\n\n\n",[Common getFormattedNumber:self.phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
        NSRange range3 = [verifyInstaVoiceCell.numberContentView.text rangeOfString:stringRange];
        NSRange range4 = [verifyInstaVoiceCell.numberContentView.text rangeOfString:@" In case you don’t get any notification, please check the selected carrier and activate again."];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:verifyInstaVoiceCell.numberContentView.text];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:verifyInstaVoiceCell.numberContentView.font.pointSize]}
                                range:range1];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:verifyInstaVoiceCell.numberContentView.font.pointSize]}
                                range:range2];
        [attributedText setAttributes:@{NSFontAttributeName:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1]}
                                range:range3];
        [attributedText setAttributes:@{NSFontAttributeName:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1]}
                                range:range4];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, [attributedText length])];
        
        verifyInstaVoiceCell.numberContentView.attributedText = attributedText;
        verifyInstaVoiceCell.numberContentView.tintColor = [UIColor colorWithRed:(0.0/255.0) green:(122.0/255.0) blue:(255.0/255.0) alpha:1.0f];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell layoutIfNeeded];
    [cell layoutSubviews];
    [cell setNeedsLayout];
    return cell;
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