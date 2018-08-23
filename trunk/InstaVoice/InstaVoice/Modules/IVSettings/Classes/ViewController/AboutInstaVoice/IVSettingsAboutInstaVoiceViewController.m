//
//  IVSettingsAboutInstaVoiceViewController.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 16/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVSettingsAboutInstaVoiceViewController.h"
#import "Common.h"
#import "Setting.h"
#import "IVSettingsWebViewController.h"
#import "TableColumns.h"
#import "Contacts.h"
#import "BaseUI.h"
#import "InsideConversationScreen.h"
#import "IVFileLocator.h"
//Constants
#define  kAboutInstaVoiceCellIdentifier @"InstaVoiceAboutCell"
#define  kCellTitleLabelTag 99

#ifdef REACHME_APP
    #define  kViewTitle @"About ReachMe"
#else
    #define  kViewTitle @"About & Help"
#endif

//Segue
#define kShowSettingsWebView @"ShowSettingsWebView"

//Enums
#ifdef REACHME_APP
typedef NS_ENUM(NSUInteger,AboutInstaVoiceCells){
    eFrequentlyAskedQuestions = 0,
    eSuggestionsCell,
    eTermsAndConditionsCell,
    ePrivacyPolicyCell
};
#else
typedef NS_ENUM(NSUInteger,AboutInstaVoiceCells){
    eFrequentlyAskedQuestions = 0,
    eHelpCell,
    eSuggestionsCell,
    eTermsAndConditionsCell,
    ePrivacyPolicyCell
};
#endif


@interface IVSettingsAboutInstaVoiceViewController ()
@property (weak, nonatomic) IBOutlet UITableView *settingsAboutInstaVoiceListTableView;
@property (nonatomic, strong) NSArray *cellTitleArray;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, strong) NSMutableArray *helpDetails;
@property (nonatomic, strong) NSMutableArray *supportDetails;
@property (nonatomic, strong) NSArray *supportContatctList;
@end

@implementation IVSettingsAboutInstaVoiceViewController

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //Setup the title
        self.title = NSLocalizedString(kViewTitle, nil);
        
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(kViewTitle, nil)
                                                          image:[UIImage imageNamed:@"about_help"] selectedImage:[UIImage imageNamed:@"about_help_selected"]]];
    }
    
    return self;
}

#pragma mark - View Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(kViewTitle, nil);
#ifdef REACHME_APP
    self.cellTitleArray = @[@"Frequently Asked Questions", @"Suggestions", @"Terms & Conditions", @"Privacy Policy"];
#else
    self.cellTitleArray = @[@"Frequently Asked Questions", @"Live Support", @"Suggestions", @"Terms & Conditions", @"Privacy Policy"];
#endif
    
    //Settings - TextFlow related changes notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    [self retrieveHelpAndSupportInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView DataSource Methods -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cellTitleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    static NSString *cellIdentifier = kAboutInstaVoiceCellIdentifier;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UILabel *titleLable = (UILabel *)[cell viewWithTag:kCellTitleLabelTag];
    titleLable.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    titleLable.text = NSLocalizedString([self.cellTitleArray objectAtIndex:indexPath.row], nil);
    
    [cell layoutIfNeeded];
    [cell layoutSubviews];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark - TableView Delegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.settingsAboutInstaVoiceListTableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedRow = indexPath.row;
    switch (indexPath.row) {
        case eTermsAndConditionsCell:
        case ePrivacyPolicyCell:
        case eFrequentlyAskedQuestions: {
            [self performSegueWithIdentifier:kShowSettingsWebView sender:self];
            break;
        }
            
#ifndef REACHME_APP
        case eHelpCell: {
            [self showHelpView];
            break;
        }
#endif
            
        case eSuggestionsCell: {
            [self showSuggestionsView];
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - StoryBoard Segue Methods -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:kShowSettingsWebView]) {
        //if you need to pass data to the next controller do it here
        IVSettingsWebViewController *settingsWebViewController = segue.destinationViewController;
        settingsWebViewController.selectedSettingOptions = self.selectedRow;
        
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:kShowSettingsWebView])
        //Check for Network and Load the Web View
        return [self canLoadWebView];
    else
        return NO;
}


#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.settingsAboutInstaVoiceListTableView reloadData];
    });
    
}

#pragma mark - Private Methods -
- (BOOL)canLoadWebView {
    BOOL canLoadWebView = YES;
    
    int isNetAvailable = [Common isNetworkAvailable];
    if(isNetAvailable != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        canLoadWebView = NO;
    }
    return canLoadWebView;
}

- (void)retrieveHelpAndSupportInfo {
    
    self.supportContatctList = [Setting sharedSetting].supportContactList;
    if(self.supportContatctList && [self.supportContatctList count]) {
        
        self.supportDetails = [[NSMutableArray alloc]init];
        self.helpDetails = [[NSMutableArray alloc]init];
        for (NSUInteger i=0; i<[self.supportContatctList count]; i++) {
            
            NSMutableDictionary *supportContactsDictionary = [self.supportContatctList objectAtIndex:i];
            NSString *supportName = [supportContactsDictionary valueForKey:SUPPORT_NAME];
            if([supportName isEqualToString:MENU_FEEDBACK])
                [self.supportDetails addObject:supportContactsDictionary];
            else
                [self.helpDetails addObject:supportContactsDictionary];
        }
    }
}

- (void)showHelpView {
    
    if(NETWORK_AVAILABLE == [Common isNetworkAvailable]) {
        
        if(self.helpDetails && [self.helpDetails count]) {
            for (NSUInteger i=0; i<[self.helpDetails count]; i++) {
                NSDictionary *helpDetailsData = [self.helpDetails objectAtIndex:i];
                [self updateAndShowInfoForShowInConversationView:helpDetailsData];
            }
        }
        else
            [ScreenUtility showAlertMessage:NSLocalizedString(@"NO_SUPPORT_LIST", nil)];
    }
    else {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

- (void)showSuggestionsView {
    
    if(NETWORK_AVAILABLE == [Common isNetworkAvailable]) {
        
        if(self.supportDetails && [self.supportDetails count]) {
            for (NSUInteger i=0; i<[self.supportDetails count]; i++) {
                NSDictionary *supportDetailsData = [self.supportDetails objectAtIndex:i];
                [self updateAndShowInfoForShowInConversationView:supportDetailsData];
            }
        }
        else
            [ScreenUtility showAlertMessage:NSLocalizedString(@"NO_SUPPORT_LIST", nil)];
    }
    else {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    
}
- (void)updateAndShowInfoForShowInConversationView:(NSDictionary *)details {
    
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
    NSString *ivUserId = [details valueForKey:SUPPORT_IV_ID];
    NSNumber* ivID = [NSNumber numberWithLong:[ivUserId longLongValue]];
    NSArray* arr = [[Contacts sharedContact]getContactForIVUserId:ivID usingMainContext:YES];
    ContactDetailData* detailData = Nil;
    if([arr count]>0)
        detailData = [arr objectAtIndex:0];
    
    [newDic setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
    [newDic setValue:ivUserId forKey:REMOTE_USER_IV_ID];
    [newDic setValue:[details valueForKey:SUPPORT_DATA_VALUE] forKey:FROM_USER_ID];
    [newDic setValue:[details valueForKey:SUPPORT_NAME] forKey:REMOTE_USER_NAME];
    if(detailData)
        [newDic setValue:[IVFileLocator getNativeContactPicPath:detailData.contactIdParentRelation.contactPic] forKey:REMOTE_USER_PIC];
    
    [appDelegate.dataMgt setCurrentChatUser:newDic];
    
    BaseUI* uiObj = [[InsideConversationScreen alloc]
                     initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    
    [self.navigationController pushViewController:uiObj animated:YES];
}

#pragma mark - Memory CleanUp Methods -
- (void)dealloc {
    
    // NSLog(@"Dealloc of About Page");
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    self.settingsAboutInstaVoiceListTableView = nil;
    self.cellTitleArray = nil;
    self.selectedRow = 0;
    self.helpDetails = nil;
    self.supportDetails = nil;
    self.supportContatctList = nil;
    
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

