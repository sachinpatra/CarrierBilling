//
//  InviteCodeSuccessViewController.m
//  ReachMe
//
//  Created by Bhaskar Munireddy on 30/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "InviteCodeSuccessViewController.h"
#import "UserProfileModel.h"
#import "Profile.h"
#import "IVFileLocator.h"
#import "ContactDetailData.h"
#import "Contacts.h"
#import "InsideConversationScreen.h"
//OnBoarding
#import "InviteCodeViewController.h"
#import "IVCarrierSearchViewController.h"
#import "IVCarrierCircleViewController.h"
#import "FetchCarriersListAPI.h"
#import "ActivateReachMeViewController.h"
#import "IVSettingsListViewController.h"

#define kErrorCodeForCarrierListNotFound 20

@interface InviteCodeSuccessViewController ()<SettingProtocol>
@property (nonatomic, strong) NSString *helpText;
@property (nonatomic, strong) NSMutableArray *helpTextArray, *supportContactList;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *continueNext;
@property (nonatomic, strong) NSArray *currentCarrierList;
@property (nonatomic, strong) IVCarrierSearchViewController *carrierSearchViewController;
@property (nonatomic, strong) IVSettingsCountryCarrierInfo *selectedCountryCarrierInfo;
@property (nonatomic, strong) VoiceMailInfo *voiceMailInfo;
@property (nonatomic, strong) SettingModel *currentSettingsModel;

@end

@implementation InviteCodeSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    self.title = NSLocalizedString(@"Redeem Code", nil);
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpAction)];
    self.navigationItem.rightBarButtonItem = helpButton;
    UIBarButtonItem *skipButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(skipAction)];
    self.navigationItem.leftBarButtonItem = skipButton;
    self.navigationController.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:(218.0/255.0) green:(67.0/255.0) blue:(54.0/255.0) alpha:1.0];
    [Setting sharedSetting].delegate = self;
    
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    [self.webView setScalesPageToFit:YES];
    
    self.continueNext.layer.cornerRadius = 22.0;
    self.continueNext.layer.borderWidth = 2.0;
    self.continueNext.layer.borderColor = [[UIColor clearColor] CGColor];
    self.continueNext.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.continueNext.layer.shadowOpacity = 1.0f;
    self.continueNext.layer.shadowRadius = 1.0f;
    self.continueNext.layer.shadowOffset = CGSizeMake(0, 1);
    
    [self configureHelpAndSuggestion];
    // Do any additional setup after loading the view from its nib.
}

- (void)skipAction
{
    
}

- (void)helpAction
{
    self.helpText = @"";
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


-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showProgressBar];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideProgressBar];
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideProgressBar];
    int erroeCode = (int)[error code];
    NSString *errorStr = nil;
    switch (erroeCode)
    {
        case NSURLErrorTimedOut:
            errorStr = NSLocalizedString(@"NET_TIME_OUT", nil);
            break;
        case NSURLErrorCannotFindHost:
            errorStr = NSLocalizedString(@"SERVER_NOT_FOUND", nil);
            break;
        case NSURLErrorCannotConnectToHost:
            errorStr = NSLocalizedString(@"SERVER_NOT_RECHABLE", nil);
            break;
        case NSURLErrorNetworkConnectionLost:
            errorStr = NSLocalizedString(@"NET_NOT_AVAILABLE", nil);
            break;
        default:
            break;
    }
    
    if(errorStr != nil && [errorStr length]>0)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:errorStr preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [alert addAction:ok];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)continueToNext:(id)sender
{
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[IVSettingsListViewController class]]) {
            [self.navigationController popToViewController:aViewController animated:YES];
        }
    }
    
//    [[ConfigurationReader sharedConfgReaderObj] setOnBoardingStatus:YES];
//    [self loadLatestDataFromServer];
//
//    NSString *simMCCMNC =[Common simMCCMNCCode];
//    //simMCCMNC = @"40492";
//    NSString *simCountry = [Common simCountryCode];
//    //simCountry = @"091";
//    //We have carrier info - check in the carrier list we have corresponding supported carrier info in the carrier list.
//    NSString *countryCode = self.voiceMailInfo.carrierCountryCode;
//    NSMutableArray *mccMNCCarrierList = [[NSMutableArray alloc] init];
//    NSArray *carrierList = [self carrierListForCountry:countryCode];
//    if (carrierList && [carrierList count]) {
//        for (NSInteger i=0; i<[carrierList count]; i++) {
//            IVSettingsCountryCarrierInfo *carrierInfoInList = [carrierList objectAtIndex:i];
//            //check mccmnc list in the carrier info
//            if (carrierInfoInList.mccmncList && [carrierInfoInList.mccmncList count]) {
//                //We have MCCMNC List, check whether mccmnc sim is in the list.
//                BOOL isMCCMNCListInCarrierList = [carrierInfoInList.mccmncList containsObject:simMCCMNC];
//                if (isMCCMNCListInCarrierList && [simCountry isEqualToString:carrierInfoInList.countryCode]) {
//                    [mccMNCCarrierList addObject:[carrierList objectAtIndex:i]];
//                }
//            }
//
//        }
//
//    }
//
//    if (mccMNCCarrierList.count == 1) {
//        ActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ActivateReachMe"];
//        activateReachMe.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
//        activateReachMe.isPrimaryNumber = YES;
//        activateReachMe.voiceMailInfo = self.voiceMailInfo;
//        [self.navigationController pushViewController:activateReachMe animated:YES];
//        return;
//    }
//
//    if (!self.voiceMailInfo || !self.voiceMailInfo.countryVoicemailSupport) {
//        //ActivateReachMe
//        ActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ActivateReachMe"];
//        activateReachMe.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
//        activateReachMe.isPrimaryNumber = YES;
//        activateReachMe.voiceMailInfo = self.voiceMailInfo;
//        [self.navigationController pushViewController:activateReachMe animated:YES];
//        return;
//    }
//    NSArray *listOfCarriers = [[Setting sharedSetting]carrierListForCountry:self.voiceMailInfo.carrierCountryCode];
//    if (listOfCarriers && [listOfCarriers count]) {
//        //We have list of carriers.
//        self.currentCarrierList = listOfCarriers;
//        [self selectCarrier];
//    }
//    else {
//        self.currentCarrierList = nil;
//        //We do not have list of carriers - so start fetching list of carriers for the country.
//        [[Setting sharedSetting]fetchListOfCarriersForCountry:self.voiceMailInfo.carrierCountryCode];
//    }
}

- (NSArray *)carrierListForCountry:(NSString *)withCountryCode {
    
    NSArray *carrierList;
    
    if (withCountryCode) {
        //Get the current country carrier list.
        if ([[Setting sharedSetting].data.listOfCarriers count]) {
            
            NSDictionary *carrierDetails;
            BOOL statusOfExistanceOfCarrierList = NO;
            for (carrierDetails in [Setting sharedSetting].data.listOfCarriers) {
                
                NSString *countryCode = [[carrierDetails allKeys]objectAtIndex:0];
                if([countryCode isKindOfClass:[NSNumber class]]) {
                    countryCode = [NSString stringWithFormat:@"%@",countryCode];
                }
                
                @try {
                    if ([countryCode isEqualToString:withCountryCode]) {
                        statusOfExistanceOfCarrierList = YES;
                        break;
                    }
                    else {
                        statusOfExistanceOfCarrierList = NO;
                    }
                }
                @catch (NSException *exception) {
                    EnLogd(@"FIXME");
                    if([withCountryCode isKindOfClass:[NSNumber class]]) {
                        EnLogd(@"Why withCountryCode is of NSNumber type?");
                    }
                }
            }
            
            if (statusOfExistanceOfCarrierList) {
                carrierList = [carrierDetails objectForKey:withCountryCode];
            }
        }
        else {
            carrierList = nil;
        }
    }
    return carrierList;
}

- (void)fetchListOfCarriersForCountry:(SettingModel *)modelData withFetchStatus:(BOOL)withFetchStatus {
    
    //hide loading Indicator
    [self hideProgressBar];
    
    //NOV 24, 2016
    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    //
    
    if (withFetchStatus) {
        NSArray *listOfCarriers = [[Setting sharedSetting]carrierListForCountry:self.voiceMailInfo.carrierCountryCode];
        self.currentCarrierList = listOfCarriers;
        [self selectCarrier];
    }
}

- (void)loadLatestDataFromServer {
    
    KLog(@"loadLatestDataFromServer");
    
    self.currentSettingsModel = [Setting sharedSetting].data;
    if (self.currentSettingsModel) {
        if (self.currentSettingsModel.voiceMailInfo && [self.currentSettingsModel.voiceMailInfo count]) {
            for (VoiceMailInfo *voiceMailInfo in self.currentSettingsModel.voiceMailInfo) {
                if([voiceMailInfo.phoneNumber isEqualToString:[[ConfigurationReader sharedConfgReaderObj] getLoginId]]) {
                    self.voiceMailInfo = voiceMailInfo;
                }
            }
            
        }
    }
}

- (void)selectCarrier
{
    if ([self.voiceMailInfo.carrierCountryCode isEqualToString:@"091"]) {
        IVCarrierCircleViewController *selectCircle = [[IVCarrierCircleViewController alloc]initWithNibName:@"IVCarrierCircleViewController" bundle:nil];
        selectCircle.carrierList = self.currentCarrierList;
        selectCircle.isEdit = NO;
        [self.navigationController pushViewController:selectCircle animated:YES];
        return;
    }
    
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        if(self.currentCarrierList && self.currentCarrierList.count) {
            if (!self.carrierSearchViewController) {
                self.carrierSearchViewController = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"IVCarrierSearchView"];
            }
            
            if (![self.navigationController.topViewController isKindOfClass:[IVCarrierSearchViewController class]]) {
                self.carrierSearchViewController.carrierList = self.currentCarrierList;
                self.carrierSearchViewController.voiceMailInfo = self.voiceMailInfo;
                self.carrierSearchViewController.isEdit = NO;
                self.carrierSearchViewController.selectedCountryCarrierInfo = self.selectedCountryCarrierInfo;
                [self.navigationController pushViewController:self.carrierSearchViewController animated:YES];
                return;
            }
        }
        else
            //Fetch the carrier list.
            [self retrieveCarrierDetails];
    }else{
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

- (void)retrieveCarrierDetails {
    
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    if (self.voiceMailInfo) {
        
        NSMutableDictionary *requestData = [[NSMutableDictionary alloc]init];
        if(self.voiceMailInfo.carrierCountryCode) {
            //[self showLoadingIndicator];
            [requestData setObject:self.voiceMailInfo.carrierCountryCode forKey:@"country_code"];
            [requestData setValue:[NSNumber numberWithBool:1] forKey:@"fetch_voicemails_info"]; //NOV 16, 2016
            FetchCarriersListAPI* fetchCarrierListRequest = [[FetchCarriersListAPI alloc]initWithRequest:requestData];
            
            [fetchCarrierListRequest callNetworkRequest:requestData withSuccess:^(FetchCarriersListAPI *req, NSMutableDictionary *responseObject) {
                
                //Hide the loading indicator
                //[self hideLoadingIndicator];
                self.currentCarrierList = responseObject[@"country_list"];
                
                //Reload Data - Current Network Name and reload the tableView.
                //[self reloadData];
                //[self redirectToAppropriateVoiceMailSettingsView];
                
            } failure:^(FetchCarriersListAPI *req, NSError *error) {
                KLog(@"Failure in fetching carrier list");
                //Hide the loading indicator
                //[self hideLoadingIndicator];
                
                NSInteger errorCode = 0;
                NSString *errorReason;
                if (error.userInfo) {
                    errorCode = [error.userInfo[@"error_code"]integerValue];
                    errorReason = error.userInfo[@"error_reason"];
                }
                if (kErrorCodeForCarrierListNotFound == errorCode)
                    [ScreenUtility showAlert:errorReason];
            }];
        }
    }
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
