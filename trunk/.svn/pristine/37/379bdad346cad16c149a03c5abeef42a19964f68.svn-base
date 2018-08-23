//
//  IVSelectCarrierViewController.m
//  ReachMe
//
//  Created by Bhaskar Munireddy on 29/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "IVSelectCarrierViewController.h"
#import "EditNumberDetailsViewController.h"
#import "ActivateReachMeViewController.h"

@interface IVSelectCarrierViewController ()<UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate,SettingProtocol>{
    BOOL isSearching;
    UISearchBar *searchBar;
}
@property (strong, nonatomic) NSMutableArray *filteredCarriers;
@property (weak, nonatomic) IBOutlet UITableView *carrierTableView;
@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic, strong) VoiceMailInfo *voiceMailInfo;
@property (nonatomic, strong) SettingModel *currentSettingsModel;
@property (nonatomic, assign) BOOL isCarrierSelected;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;

@end

@implementation IVSelectCarrierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.filteredCarriers = [[NSMutableArray alloc] init];
    isSearching = NO;
    self.isCarrierSelected = NO;
    self.title = @"Select Circle";
    
    if (@available(iOS 11.0, *)) {
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchResultsUpdater = self;
        self.searchController.delegate = self;
        self.searchController.searchBar.delegate = self;
        self.searchController.obscuresBackgroundDuringPresentation = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
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
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Setting sharedSetting].delegate = self;
}

#pragma mark TableView DataSourse & Delegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.networkName && !isSearching) {
        return self.networkName.count;
    }else if(self.filteredCarriers){
        return self.filteredCarriers.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectCarrierCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectCarrierCell"];
    }
    if (self.networkName && !isSearching) {
        cell.textLabel.text = [self.networkName objectAtIndex:indexPath.row];
    }else if (self.filteredCarriers) {
        cell.textLabel.text = [self.filteredCarriers objectAtIndex:indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.searchController setActive:NO];
    NSString *selectedNetwokName;
    if (isSearching) {
        selectedNetwokName = [self.filteredCarriers objectAtIndex:indexPath.row];
    }else{
        selectedNetwokName = [self.networkName objectAtIndex:indexPath.row];
    }
    self.isCarrierSelected = YES;
    for (NSUInteger i=0; i<[self.carrierList count]; i++) {
        IVSettingsCountryCarrierInfo *settingsCountryCarrierInfo = [self.carrierList objectAtIndex:i];
        if ([settingsCountryCarrierInfo.networkName isEqualToString:selectedNetwokName]) {
            if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus] && !self.isEdit) {
                [self showProgressBar];
                //Carrier Info Update
                CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
                currentCarrierInfo.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
                if(settingsCountryCarrierInfo) {
                    currentCarrierInfo.countryCode = settingsCountryCarrierInfo.countryCode;
                    currentCarrierInfo.networkId = settingsCountryCarrierInfo.networkId;
                    currentCarrierInfo.vSMSId = settingsCountryCarrierInfo.vsmsNodeId;
                    currentCarrierInfo.isReachMeIntlActive = NO;
                    currentCarrierInfo.isReachMeHomeActive = NO;
                    currentCarrierInfo.isReachMeVMActive = NO;
                }else{
                    currentCarrierInfo.countryCode = [NSString stringWithFormat:@"%d", -1];
                    currentCarrierInfo.networkId = [NSString stringWithFormat:@"%d", -1];
                    currentCarrierInfo.vSMSId = [NSNumber numberWithInteger:-1];
                    currentCarrierInfo.isReachMeIntlActive = NO;
                    currentCarrierInfo.isReachMeHomeActive = NO;
                    currentCarrierInfo.isReachMeVMActive = NO;
                }
                [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
                return;
            }else if ([[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP] && !self.isEdit) {
                [self showProgressBar];
                //Carrier Info Update
                CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
                currentCarrierInfo.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getVerifiedOTPNumber];
                if(settingsCountryCarrierInfo) {
                    currentCarrierInfo.countryCode = settingsCountryCarrierInfo.countryCode;
                    currentCarrierInfo.networkId = settingsCountryCarrierInfo.networkId;
                    currentCarrierInfo.vSMSId = settingsCountryCarrierInfo.vsmsNodeId;
                    currentCarrierInfo.isReachMeIntlActive = NO;
                    currentCarrierInfo.isReachMeHomeActive = NO;
                    currentCarrierInfo.isReachMeVMActive = NO;
                }else{
                    currentCarrierInfo.countryCode = [NSString stringWithFormat:@"%d", -1];
                    currentCarrierInfo.networkId = [NSString stringWithFormat:@"%d", -1];
                    currentCarrierInfo.vSMSId = [NSNumber numberWithInteger:-1];
                    currentCarrierInfo.isReachMeIntlActive = NO;
                    currentCarrierInfo.isReachMeHomeActive = NO;
                    currentCarrierInfo.isReachMeVMActive = NO;
                }
                [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
                return;
            }
            
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
    }
}

- (void)loadLatestDataFromServer {
    
    KLog(@"loadLatestDataFromServer");
    
    self.currentSettingsModel = [Setting sharedSetting].data;
    if (self.currentSettingsModel) {
        if (self.currentSettingsModel.voiceMailInfo && [self.currentSettingsModel.voiceMailInfo count]) {
            for (VoiceMailInfo *voiceMailInfo in self.currentSettingsModel.voiceMailInfo) {
                if ([[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP]) {
                    if([voiceMailInfo.phoneNumber isEqualToString:[[ConfigurationReader sharedConfgReaderObj] getVerifiedOTPNumber]])
                        self.voiceMailInfo = voiceMailInfo;
                }else{
                    if([voiceMailInfo.phoneNumber isEqualToString:[[ConfigurationReader sharedConfgReaderObj] getLoginId]])
                        self.voiceMailInfo = voiceMailInfo;
                }
            }
            
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
            [self loadLatestDataFromServer];
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

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchText = searchController.searchBar.text;
    if (searchText && searchText.length) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
        self.filteredCarriers = [NSMutableArray arrayWithArray:[self.networkName filteredArrayUsingPredicate:resultPredicate]];
        isSearching = YES;
        [self.carrierTableView reloadData];
    }else{
        isSearching = NO;
        [self.carrierTableView reloadData];
    }
}

#pragma mark - Search Bar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText && searchText.length) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
        self.filteredCarriers = [NSMutableArray arrayWithArray:[self.networkName filteredArrayUsingPredicate:resultPredicate]];
        isSearching = YES;
        [self.carrierTableView reloadData];
    }else{
        isSearching = NO;
        [self.carrierTableView reloadData];
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
- (IBAction)carrierNotListed:(id)sender {
    
    self.isCarrierSelected = YES;
    
    if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus] && !self.isEdit) {
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
    }else if ([[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP] && !self.isEdit) {
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
