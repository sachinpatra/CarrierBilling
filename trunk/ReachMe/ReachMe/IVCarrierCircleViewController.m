//
//  IVCarrierCircleViewController.m
//  ReachMe
//
//  Created by Bhaskar Munireddy on 29/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "IVCarrierCircleViewController.h"
#import "UserProfileModel.h"
#import "Profile.h"
#import "IVFileLocator.h"
#import "IVCarrierSearchViewController.h"
#import "FetchCarriersListAPI.h"
#import "IVSettingsCountryCarrierInfo.h"
#import "IVSelectCarrierViewController.h"
#import "EditNumberDetailsViewController.h"
#import "ActivateReachMeViewController.h"

#define kErrorCodeForCarrierListNotFound 20

@interface IVCarrierCircleViewController ()<UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate,IVCarrierSearchDelegate>{
    UIActivityIndicatorView *indicator;
    BOOL isSearching;
    UISearchBar *searchBar;
}
@property (strong, nonatomic) NSMutableArray *carrierName, *filteredCarriers;
@property (weak, nonatomic) IBOutlet UITableView *circleTableView;
@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, assign) BOOL isCarrierSelected;

@property (nonatomic, strong) IVCarrierSearchViewController *carrierSearchViewController;

@end

@implementation IVCarrierCircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.carrierName = [[NSMutableArray alloc] init];
    self.filteredCarriers = [[NSMutableArray alloc] init];
    isSearching = NO;
    self.isCarrierSelected = NO;
    appDelegate.tabBarController.tabBar.hidden = YES;
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    indicator.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    self.circleTableView.hidden = YES;
    self.carrierList = nil;
    [self fetchCarriers];
    
    self.title = @"Select Carrier";
    if (@available(iOS 11.0, *)) {
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchResultsUpdater = self;
        self.searchController.delegate = self;
        self.searchController.searchBar.delegate = self;
        self.searchController.obscuresBackgroundDuringPresentation = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.navigationItem.searchController = self.searchController;
    } else {
        searchBar = [[UISearchBar alloc] init];
        searchBar.placeholder = @"Search";
        searchBar.delegate = self;
        searchBar.frame = CGRectMake(0.0, 0.0, self.navigationController.view.bounds.size.width, 44.0);
        searchBar.barStyle = UIBarStyleDefault;
        searchBar.searchBarStyle = UISearchBarStyleDefault;
        searchBar.tintColor = [UIColor redColor];
        [self.view addSubview:searchBar];
        self.tableTopConstraint.constant = 44.0;
    }
    self.navigationController.navigationBarHidden = NO;
    if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus] || [[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP]){
        if(!self.isEdit)
            self.navigationItem.hidesBackButton = YES;
        else
            self.navigationItem.hidesBackButton = NO;
    }else
        self.navigationItem.hidesBackButton = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void)fetchCarriers
{
    
    if (self.carrierList && [self.carrierList count]) {
        for (NSUInteger i=0; i<[self.carrierList count]; i++) {
            IVSettingsCountryCarrierInfo *settingsCountryCarrierInfo = [self.carrierList objectAtIndex:i];
            if (settingsCountryCarrierInfo.carrierName) {
                [self.carrierName addObject:settingsCountryCarrierInfo.carrierName];
            }
        }
        
        NSMutableArray *unique = [NSMutableArray array];
        for (id obj in self.carrierName) {
            if (![unique containsObject:obj] && ![obj isEqualToString:@""]) {
                [unique addObject:obj];
            }
        }
        self.carrierName = unique;
        
        self.circleTableView.hidden = NO;
    }else{
        NSMutableDictionary *requestData = [[NSMutableDictionary alloc]init];
        [requestData setObject:@"091" forKey:@"country_code"];
        [requestData setValue:[NSNumber numberWithBool:1] forKey:@"fetch_voicemails_info"]; //NOV 16, 2016
        FetchCarriersListAPI* fetchCarrierListRequest = [[FetchCarriersListAPI alloc]initWithRequest:requestData];
        [indicator startAnimating];
        [fetchCarrierListRequest callNetworkRequest:requestData withSuccess:^(FetchCarriersListAPI *req, NSMutableDictionary *responseObject) {
            NSArray *carrierDetailsInfo = responseObject[@"country_list"];
            self.carrierList = carrierDetailsInfo;
            if (carrierDetailsInfo && [carrierDetailsInfo count]) {
                
                for (NSUInteger i=0; i<[carrierDetailsInfo count]; i++) {
                    IVSettingsCountryCarrierInfo *settingsCountryCarrierInfo = [carrierDetailsInfo objectAtIndex:i];
                    if (settingsCountryCarrierInfo.carrierName) {
                        [self.carrierName addObject:settingsCountryCarrierInfo.carrierName];
                    }
                }
                
                NSMutableArray *unique = [NSMutableArray array];
                for (id obj in self.carrierName) {
                    if (![unique containsObject:obj] && ![obj isEqualToString:@""]) {
                        [unique addObject:obj];
                    }
                }
                self.carrierName = unique;
                
                self.circleTableView.hidden = NO;
                [self.circleTableView reloadData];
                [indicator stopAnimating];
                
            }
        } failure:^(FetchCarriersListAPI *req, NSError *error) {
            KLog(@"Failure in fetching carrier list");
            
            NSInteger errorCode = 0;
            NSString *errorReason;
            if (error.userInfo) {
                errorCode = [error.userInfo[@"error_code"]integerValue];
                errorReason = error.userInfo[@"error_reason"];
            }
            if (kErrorCodeForCarrierListNotFound == errorCode)
                [ScreenUtility showAlert:errorReason];
            
            [indicator startAnimating];
        }];
        
    }
}

#pragma mark TableView DataSourse & Delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isSearching) {
        if (self.carrierName) {
            return self.carrierName.count;
        }
    }else if(self.filteredCarriers){
        return self.filteredCarriers.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectCarrierCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectCarrierCell"];
    }
    if (!isSearching) {
        if (self.carrierName) {
            cell.textLabel.text = [self.carrierName objectAtIndex:indexPath.row];
        }
    }else if (self.filteredCarriers) {
        cell.textLabel.text = [self.filteredCarriers objectAtIndex:indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *filteredCarrierArray = [[NSMutableArray alloc] init];
    NSPredicate *resultPredicate;
    if (isSearching) {
        resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", [self.filteredCarriers objectAtIndex:indexPath.row]];
    }else{
        resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", [self.carrierName objectAtIndex:indexPath.row]];
    }
    
    NSMutableArray *networkNameArray = [NSMutableArray array];
    for (NSUInteger i=0; i<[self.carrierList count]; i++) {
        IVSettingsCountryCarrierInfo *settingsCountryCarrierInfo = [self.carrierList objectAtIndex:i];
        if (settingsCountryCarrierInfo.carrierName) {
            [networkNameArray addObject:settingsCountryCarrierInfo.networkName];
        }
    }
    
    filteredCarrierArray = [NSMutableArray arrayWithArray:[networkNameArray filteredArrayUsingPredicate:resultPredicate]];
    IVSelectCarrierViewController *carrierViewController = [[IVSelectCarrierViewController alloc] initWithNibName:@"IVSelectCarrierViewController" bundle:nil];
    carrierViewController.networkName = filteredCarrierArray;
    carrierViewController.carrierList = self.carrierList;
    carrierViewController.isEdit = self.isEdit;
    [self.navigationController pushViewController:carrierViewController animated:YES];
    
    [self.searchController setActive:NO];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchText = searchController.searchBar.text;
    if (searchText && searchText.length) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
        self.filteredCarriers = [NSMutableArray arrayWithArray:[self.carrierName filteredArrayUsingPredicate:resultPredicate]];
        isSearching = YES;
        [self.circleTableView reloadData];
    }else{
        isSearching = NO;
        [self.circleTableView reloadData];
    }
}

#pragma mark - Search Bar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText && searchText.length) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
        self.filteredCarriers = [NSMutableArray arrayWithArray:[self.carrierName filteredArrayUsingPredicate:resultPredicate]];
        isSearching = YES;
        [self.circleTableView reloadData];
    }else{
        isSearching = NO;
        [self.circleTableView reloadData];
    }
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar
{
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar*)searchBar
{
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setText:@""];
    [searchBar.delegate searchBar:searchBar textDidChange:@""];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [searchBar resignFirstResponder];
}
- (IBAction)carrierNotListed:(id)sender {
    
    self.isCarrierSelected = YES;
    if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus]) {
        [self showProgressBar];
        //Carrier Info Update
        CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
        currentCarrierInfo.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
        currentCarrierInfo.countryCode = [NSString stringWithFormat:@"%d", -1];
        currentCarrierInfo.networkId = [NSString stringWithFormat:@"%d", -1];
        currentCarrierInfo.vSMSId = [NSNumber numberWithInteger:-1];
        currentCarrierInfo.isReachMeIntlActive = NO;
        currentCarrierInfo.isReachMeHomeActive = NO;
        currentCarrierInfo.isReachMeVMActive = NO;
        [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
        return;
    }else if ([[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP]) {
        [self showProgressBar];
        //Carrier Info Update
        CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
        currentCarrierInfo.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getVerifiedOTPNumber];
        currentCarrierInfo.countryCode = [NSString stringWithFormat:@"%d", -1];
        currentCarrierInfo.networkId = [NSString stringWithFormat:@"%d", -1];
        currentCarrierInfo.vSMSId = [NSNumber numberWithInteger:-1];
        currentCarrierInfo.isReachMeIntlActive = NO;
        currentCarrierInfo.isReachMeHomeActive = NO;
        currentCarrierInfo.isReachMeVMActive = NO;
        [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
        return;
    }
    
    IVSettingsCountryCarrierInfo *settingsCountryCarrierInfo = [[IVSettingsCountryCarrierInfo alloc] init];
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[EditNumberDetailsViewController class]]) {
            NSDictionary* userInfo = @{@"carrier_info": settingsCountryCarrierInfo};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Carrier_Selected"
                                                                object:self
                                                              userInfo:userInfo];
            [self.navigationController popToViewController:aViewController animated:YES];
        }
    }
    
}

- (void)updateSettingCompletedWith:(SettingModel*)modelData withUpdateStatus:(BOOL)withUpdateStatus {
    if(withUpdateStatus) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@NO forKey:kUserSettingsFetched];
        [userDefaults synchronize];
        [[Setting sharedSetting]getUserSettingFromServer];
    } else {
        [self hideProgressBar];
    }
}

- (void)fetchSettingCompletedWith:(SettingModel*)modelData withFetchStatus:(BOOL)withFetchStatus {
    if (withFetchStatus) {
        if (self.isCarrierSelected) {
            [self hideProgressBar];
            if ([[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP]) {
                ActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ActivateReachMe"];
                activateReachMe.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getVerifiedOTPNumber];
                activateReachMe.isPrimaryNumber = NO;
                [self.navigationController pushViewController:activateReachMe animated:YES];
            }else{
                ActivateReachMeViewController *activateReachMe = [[UIStoryboard storyboardWithName:@"IVVoicemailMissedCallSettings_rm" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ActivateReachMe"];
                activateReachMe.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
                activateReachMe.isPrimaryNumber = YES;
                [self.navigationController pushViewController:activateReachMe animated:YES];
            }
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
