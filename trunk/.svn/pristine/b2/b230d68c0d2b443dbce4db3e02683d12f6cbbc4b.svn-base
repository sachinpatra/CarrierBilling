//
//  IVCarrierSearchViewController.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 21/06/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVCarrierSearchViewController.h"

#import "IVSettingsCountryCarrierInfo.h"
#ifdef REACHME_APP
#import "ActivateReachMeViewController.h"
#endif

#define kCellIdentifier @"CarrierNameCell"
#define kCarrierNameLabelTag 978

@interface IVCarrierSearchViewController () <SettingProtocol>{
    UIActivityIndicatorView *indicator;
}
@property (weak, nonatomic) IBOutlet UITableView *carrierListTableView;
@property (nonatomic, strong) NSIndexPath *selectedCarrierIndex;
@property (weak, nonatomic) IBOutlet UISearchBar *carrierListSearchBar;
@property (nonatomic, strong) NSMutableDictionary *sortedCarrierData;
@property (nonatomic, strong) NSArray *sortedCarrierKeys;
@property (nonatomic, strong) NSArray *sectionIndexTitleList;
@property (weak, nonatomic) IBOutlet UIButton *carrierNotInListButton;
@property (nonatomic, assign) BOOL searchStatus;
@property (nonatomic, strong) NSString *searchString;
@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;
#ifdef REACHME_APP
@property (nonatomic, strong) SettingModel *currentSettingsModel;
@property (nonatomic, assign) BOOL isCarrierSelected;
#endif
@end

@implementation IVCarrierSearchViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Select your Carrier", nil);
    self.selectedCarrierIndex = nil; //Initial value - if its -1 no row is seletced.
    self.noResultsLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    self.carrierNotInListButton.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    
#ifdef REACHME_APP
    if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus] || [[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP])
        if(!self.isEdit)
            self.navigationItem.hidesBackButton = YES;
        else
            self.navigationItem.hidesBackButton = NO;
    else
        self.navigationItem.hidesBackButton = NO;
#endif
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Setting sharedSetting].delegate = self;
    //Settings - TextFlow related changes notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    indicator.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [indicator startAnimating];
    self.carrierList = nil;
    
    //CMP NOV 21, 2016
    if (self.carrierList.count > 0) {
        [indicator stopAnimating];
        [self processCarrierList:self.carrierList];
    }else{
        self.carrierListTableView.hidden = YES;
        self.noResultsLabel.hidden = YES;
        [[Setting sharedSetting]fetchListOfCarriersForCountry:self.voiceMailInfo.carrierCountryCode];
        [self processCarrierList:self.carrierList];
    }
    //
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.searchStatus = NO;
    self.searchString = nil;
    [self.carrierListSearchBar setText:@""];
    [self.carrierListSearchBar resignFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.searchStatus = NO;
    self.searchString = nil;
    [self.carrierListSearchBar setText:@""];
    [self.carrierListSearchBar resignFirstResponder];
    [indicator removeFromSuperview];
}

#pragma mark - UITableView DataSource Methods - 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections;
    numberOfSections = [self.sortedCarrierKeys count]? [self.sortedCarrierKeys count]:1;
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    NSString *key = [self.sortedCarrierKeys objectAtIndex:section];
    numberOfRows = [self.sortedCarrierData[key]count];
    
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.sortedCarrierKeys.count>0)
        return ([self.sortedCarrierKeys objectAtIndex:section]);
    return @"";
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionIndexTitleList;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger section = [self.sortedCarrierKeys indexOfObject:title];
    if (section == NSNotFound) {
        if (index > [self.sortedCarrierKeys count])
            section = [self.sortedCarrierKeys count]-1;
        else
            section = index - 1;
    }
    return section;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    static NSString *cellIdentifier = kCellIdentifier;
      cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    UILabel *carrierNameLabel = (UILabel *)[cell viewWithTag:kCarrierNameLabelTag];
    
    NSString *key = [self.sortedCarrierKeys objectAtIndex:indexPath.section];
    NSArray *carrierList = self.sortedCarrierData[key];
    IVSettingsCountryCarrierInfo *settingsCountryCarrierInfo = [carrierList objectAtIndex:indexPath.row];
    carrierNameLabel.text = settingsCountryCarrierInfo.networkName;
    carrierNameLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    
    if ([self.selectedCountryCarrierInfo.networkName isEqualToString:settingsCountryCarrierInfo.networkName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
//    if (self.selectedCarrierIndex) {
//        if (self.selectedCarrierIndex.section == indexPath.section) {
//            if (self.selectedCarrierIndex.row == indexPath.row)
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            else
//                cell.accessoryType = UITableViewCellAccessoryNone;
//        }
//    }
//    else
//        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [Common preferredFontForTextStyleInApp:@"SectionHeaderBoldFont"];
    header.contentView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];

    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.frame = headerFrame;
    
}

#pragma mark - UITableView Delegate Methods - 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    self.selectedCarrierIndex = indexPath;
    [self.carrierListTableView reloadData];
#ifdef REACHME_APP
    self.isCarrierSelected = YES;
    if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus] && !self.isEdit) {
        [self showProgressBar];
        self.selectedCountryCarrierInfo = [self carrierInfo:indexPath.section inRow:indexPath.row];
        //Carrier Info Update
        CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
        currentCarrierInfo.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
        if(self.selectedCountryCarrierInfo) {
            currentCarrierInfo.countryCode = self.selectedCountryCarrierInfo.countryCode;
            currentCarrierInfo.networkId = self.selectedCountryCarrierInfo.networkId;
            currentCarrierInfo.vSMSId = self.selectedCountryCarrierInfo.vsmsNodeId;
            currentCarrierInfo.isVoipEnabled = self.voiceMailInfo.isVoipEnabled;
            currentCarrierInfo.isVoipStatusEnabled = YES;
        }else{
            currentCarrierInfo.countryCode = [NSString stringWithFormat:@"%d", -1];
            currentCarrierInfo.networkId = [NSString stringWithFormat:@"%d", -1];
            currentCarrierInfo.vSMSId = [NSNumber numberWithInteger:-1];
#ifndef REACHME_APP
            currentCarrierInfo.isVoipEnabled = self.voiceMailInfo.isVoipEnabled;
            currentCarrierInfo.isVoipStatusEnabled = NO;
#else
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = NO;
#endif
            
        }
        [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
        return;
    }else if ([[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP] && !self.isEdit) {
        [self showProgressBar];
        self.selectedCountryCarrierInfo = [self carrierInfo:indexPath.section inRow:indexPath.row];
        //Carrier Info Update
        CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
        currentCarrierInfo.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getVerifiedOTPNumber];
        if(self.selectedCountryCarrierInfo) {
            currentCarrierInfo.countryCode = self.selectedCountryCarrierInfo.countryCode;
            currentCarrierInfo.networkId = self.selectedCountryCarrierInfo.networkId;
            currentCarrierInfo.vSMSId = self.selectedCountryCarrierInfo.vsmsNodeId;
#ifndef REACHME_APP
            currentCarrierInfo.isVoipEnabled = self.voiceMailInfo.isVoipEnabled;
            currentCarrierInfo.isVoipStatusEnabled = NO;
#else
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = NO;
#endif
        }else{
            currentCarrierInfo.countryCode = [NSString stringWithFormat:@"%d", -1];
            currentCarrierInfo.networkId = [NSString stringWithFormat:@"%d", -1];
            currentCarrierInfo.vSMSId = [NSNumber numberWithInteger:-1];
#ifndef REACHME_APP
            currentCarrierInfo.isVoipEnabled = self.voiceMailInfo.isVoipEnabled;
            currentCarrierInfo.isVoipStatusEnabled = NO;
#else
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = NO;
#endif
        }
        [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
        return;
    }
#endif
    
    if ([self.carrierSearchDelegate respondsToSelector:@selector(didSelectCarrier:)]) {
        self.selectedCountryCarrierInfo = [self carrierInfo:indexPath.section inRow:indexPath.row];
        [self.carrierSearchDelegate didSelectCarrier:[self carrierInfo:indexPath.section inRow:indexPath.row]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#ifdef REACHME_APP
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
#endif

#pragma mark - UISearchBar Delegate Methods - 
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText && [searchText length] > 0 && ![searchText isEqualToString:@""]) {
        self.searchStatus = YES;
        self.searchString = searchText;
    }
    else {
        self.searchString = nil;
        self.searchStatus = NO;
    }
    [self processCarrierList:self.carrierList];

}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    return YES;
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchString = nil;
    self.searchStatus = NO;
    [self.carrierListSearchBar setText:@""];
    [self.carrierListSearchBar setShowsCancelButton:NO animated:YES];
    [self.carrierListSearchBar resignFirstResponder];
    [self processCarrierList:self.carrierList];
    
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];

}

#pragma mark - Settings Protocol - 
- (void)fetchListOfCarriersForCountry:(SettingModel *)modelData withFetchStatus:(BOOL)withFetchStatus {
    NSArray *listOfCarriers = [[Setting sharedSetting]carrierListForCountry:self.voiceMailInfo.carrierCountryCode];
    if(!listOfCarriers || !listOfCarriers.count) {
        KLog(@"Debug");
    }
    self.carrierList = listOfCarriers;
    [self processCarrierList:self.carrierList];
    self.carrierListTableView.hidden = NO;
    [self.carrierListTableView reloadData];
    [indicator stopAnimating];
    [indicator removeFromSuperview];
}

#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    self.noResultsLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    self.carrierNotInListButton.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleHeadline];
    [self.carrierListTableView reloadData];
}

#pragma mark - IBAction -
- (IBAction)carrierNotInListButtonTapped:(id)sender {
    
    self.selectedCarrierIndex = nil;
    self.selectedCountryCarrierInfo = nil; 
    [self.carrierListTableView reloadData];
    
#ifdef REACHME_APP
    self.isCarrierSelected = YES;
    self.selectedCountryCarrierInfo = nil;
    if ([[ConfigurationReader sharedConfgReaderObj] getOnBoardingStatus] && !self.isEdit) {
        [self showProgressBar];
        //Carrier Info Update
        CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
        currentCarrierInfo.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
        if(self.selectedCountryCarrierInfo) {
            currentCarrierInfo.countryCode = self.selectedCountryCarrierInfo.countryCode;
            currentCarrierInfo.networkId = self.selectedCountryCarrierInfo.networkId;
            currentCarrierInfo.vSMSId = self.selectedCountryCarrierInfo.vsmsNodeId;
#ifndef REACHME_APP
            currentCarrierInfo.isVoipEnabled = self.voiceMailInfo.isVoipEnabled;
            currentCarrierInfo.isVoipStatusEnabled = NO;
#else
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = NO;
#endif
        }else{
            currentCarrierInfo.countryCode = [NSString stringWithFormat:@"%d", -1];
            currentCarrierInfo.networkId = [NSString stringWithFormat:@"%d", -1];
            currentCarrierInfo.vSMSId = [NSNumber numberWithInteger:-1];
#ifndef REACHME_APP
            currentCarrierInfo.isVoipEnabled = self.voiceMailInfo.isVoipEnabled;
            currentCarrierInfo.isVoipStatusEnabled = NO;
#else
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = NO;
#endif
        }
        [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
        return;
    }else if ([[ConfigurationReader sharedConfgReaderObj] getVerifiedOTP] && !self.isEdit) {
        [self showProgressBar];
        //Carrier Info Update
        CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
        currentCarrierInfo.phoneNumber = [[ConfigurationReader sharedConfgReaderObj] getVerifiedOTPNumber];
        if(self.selectedCountryCarrierInfo) {
            currentCarrierInfo.countryCode = self.selectedCountryCarrierInfo.countryCode;
            currentCarrierInfo.networkId = self.selectedCountryCarrierInfo.networkId;
            currentCarrierInfo.vSMSId = self.selectedCountryCarrierInfo.vsmsNodeId;
#ifndef REACHME_APP
            currentCarrierInfo.isVoipEnabled = self.voiceMailInfo.isVoipEnabled;
            currentCarrierInfo.isVoipStatusEnabled = NO;
#else
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = NO;
#endif
        }else{
            currentCarrierInfo.countryCode = [NSString stringWithFormat:@"%d", -1];
            currentCarrierInfo.networkId = [NSString stringWithFormat:@"%d", -1];
            currentCarrierInfo.vSMSId = [NSNumber numberWithInteger:-1];
#ifndef REACHME_APP
            currentCarrierInfo.isVoipEnabled = self.voiceMailInfo.isVoipEnabled;
            currentCarrierInfo.isVoipStatusEnabled = NO;
#else
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = NO;
#endif
        }
        [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
        return;
    }
#endif
    
    if ([self.carrierSearchDelegate respondsToSelector:@selector(didSelectCarrier:)]) {
        [self.carrierSearchDelegate didSelectCarrier:nil];
    }
    [self.navigationController popViewControllerAnimated:NO];

}
#pragma mark - PrivateMethods -
- (IVSettingsCountryCarrierInfo *)carrierInfo:(NSInteger)inSection inRow:(NSInteger)inRow {
    IVSettingsCountryCarrierInfo *selectedContryInfo;
    NSString *key = [self.sortedCarrierKeys objectAtIndex:inSection];
    NSArray *carrierListFromDictionary = self.sortedCarrierData[key];
    selectedContryInfo = [carrierListFromDictionary objectAtIndex:inRow];
    return selectedContryInfo;
}

- (void)processCarrierList:(NSArray *)carrierList{
    
    if (carrierList && [carrierList count]) {

        if (self.searchStatus && self.searchString && [self.searchString length]) {
            //Modify the carrier list
            NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"networkName contains[cd] %@", self.searchString];
            carrierList = [NSArray arrayWithArray:[carrierList filteredArrayUsingPredicate:resultPredicate]];
            self.sectionIndexTitleList = nil;
            if ([carrierList count] == 0) {
                self.sortedCarrierData = nil;
                self.sortedCarrierKeys = nil;
                self.noResultsLabel.hidden = NO;
                self.noResultsLabel.text = @"No Carriers Found";
                [self.carrierListTableView reloadData];
                return;
            }
            else
                self.noResultsLabel.hidden = YES;
        }
        else {
            
            NSInteger visibleCellsCount = [self.carrierListTableView.visibleCells count];
            
            NSInteger sections = self.carrierListTableView.numberOfSections;
            
            NSInteger rowCount = 0;
            for (NSInteger i=0; i< sections; i++) {
                rowCount += [self.carrierListTableView numberOfRowsInSection:i];
            }
            
            if (visibleCellsCount < rowCount ) {
                self.sectionIndexTitleList = @[@"A", @"B", @"C", @"D", @"E",@"F",@"G",@"H", @"I", @"J",@"K", @"L",@"M", @"N", @"O", @"P",@"Q",@"R", @"S",@"T", @"U", @"V", @"W",@"X",@"Y",@"Z"];
            }
            

        }

        if (carrierList && [carrierList count]) {
            self.noResultsLabel.hidden = YES;
            self.sortedCarrierData = [self createDictionaryForSectionIndex:carrierList];
            if(!self.sortedCarrierData.count) {
                //Return. Check the createDictionaryForSectionIndex
                EnLogd(@"Something wrong in carrieList. Check");
                return;
            }
            self.sortedCarrierKeys = [[self.sortedCarrierData allKeys]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            
            if (self.selectedCountryCarrierInfo) {
                
                NSString *key = [self.selectedCountryCarrierInfo.networkName substringToIndex:1];
                
                NSArray *carrierListInDictionary = self.sortedCarrierData[key];
                
                if (carrierListInDictionary && [carrierListInDictionary count]) {
                    if ([carrierListInDictionary containsObject:self.selectedCountryCarrierInfo]) {
                        NSInteger section = -1;
                        NSInteger row = -1;
                        for (NSInteger i=0; i<[self.sortedCarrierKeys count]; i++) {
                            if ([key isEqualToString:[self.sortedCarrierKeys objectAtIndex:i]]) {
                                section = i;
                                break;
                            }
                        }
                        for (NSInteger i=0; i< [carrierListInDictionary count]; i++) {
                            IVSettingsCountryCarrierInfo *carrierInfo = [carrierListInDictionary objectAtIndex:i];
                            if ([self.selectedCountryCarrierInfo isEqual:carrierInfo]) {
                                row = i;
                                break;
                            }
                        }
                        
                        if (section > -1 && row > -1) {
                            self.selectedCarrierIndex = [NSIndexPath indexPathForRow:row inSection:section];
                        }
                        else
                            self.selectedCarrierIndex = nil;
                        
                    }
                    else {
                        //NOV 29, 2016
                        NSInteger section = 0;
                        NSInteger row = -1;
                        carrierListInDictionary = self.sortedCarrierData[@" "];
                        for (NSInteger i=0; i< [carrierListInDictionary count]; i++) {
                            IVSettingsCountryCarrierInfo *carrierInfo = [carrierListInDictionary objectAtIndex:i];
                            if ([self.selectedCountryCarrierInfo isEqual:carrierInfo]) {
                                row = i;
                                break;
                            }
                        }
                        
                        if (section > -1 && row > -1) {
                            self.selectedCarrierIndex = [NSIndexPath indexPathForRow:row inSection:section];
                        }
                        else
                            self.selectedCarrierIndex = nil;
                        //
                        //NOV 29, 2016 self.selectedCarrierIndex = nil;
                    }
                }
                else
                    self.selectedCarrierIndex = nil;
            }
            else
                self.selectedCarrierIndex = nil;
            
            
            [self.carrierListTableView reloadData];
            
            if (!_searchStatus) {
                NSInteger visibleCellsCount = [self.carrierListTableView.visibleCells count];
                
                NSInteger sections = self.carrierListTableView.numberOfSections;
                
                NSInteger rowCount = 0;
                for (NSInteger i=0; i< sections; i++) {
                    rowCount += [self.carrierListTableView numberOfRowsInSection:i];
                }
                
                if (visibleCellsCount < rowCount ) {
                    self.sectionIndexTitleList = @[@"A", @"B", @"C", @"D", @"E",@"F",@"G",@"H", @"I", @"J",@"K", @"L",@"M", @"N", @"O", @"P",@"Q",@"R", @"S",@"T", @"U", @"V", @"W",@"X",@"Y",@"Z"];
                    [self.carrierListTableView reloadData];

                }

            }

        }
    }
}


- (NSMutableDictionary *)createDictionaryForSectionIndex:(NSArray *)carrierListArray {
    
    /* Debug
    KLog(@"All items ---");
    for(IVSettingsCountryCarrierInfo* ci in carrierListArray) {
        KLog(@"network:  %@, %@", ci.networkName, ci.displayOrder);
    }*/
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"!(displayOrder='999')"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"networkName" ascending:YES];
    NSArray *prorityCarriers = [carrierListArray filteredArrayUsingPredicate:predicate];
    //NSArray *results = [prorityCarriers sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    /* Debug
    KLog(@"Priority-items ---");
    for(IVSettingsCountryCarrierInfo* ci in prorityCarriers) {
        KLog(@"network:  %@, %@", ci.networkName, ci.displayOrder);
    }
    */
    
    predicate = [NSPredicate predicateWithFormat:@"displayOrder='999'"];
    NSArray *allOtherCarriers = [carrierListArray filteredArrayUsingPredicate:predicate];
    NSArray *allOtherCarriersSorted = [allOtherCarriers sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    NSMutableDictionary *carrierInfoDictionary = [[NSMutableDictionary alloc]init];
    if([prorityCarriers count]) {
        NSMutableArray *mutableResults = [NSMutableArray arrayWithArray:prorityCarriers];
        [carrierInfoDictionary setObject:mutableResults forKey:@" "];
    }
    
    for (char firstChar = 'a' ; firstChar <= 'z'; firstChar++) {
        NSString *firstCharacter = [NSString stringWithFormat:@"%c", firstChar];
        NSArray *content = [allOtherCarriersSorted filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"networkName beginswith[cd] %@", firstCharacter]];
        NSArray* contentSorted = [content sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        NSMutableArray *mutableContent = [NSMutableArray arrayWithArray:contentSorted];
        
        if ([mutableContent count] > 0)
        {
            NSString *key = [firstCharacter uppercaseString];
            [carrierInfoDictionary setObject:mutableContent forKey:key];
        }
    }
    
    for (char firstChar = '0' ; firstChar <= '9'; firstChar++) {
        NSString *firstCharacter = [NSString stringWithFormat:@"%c", firstChar];
        NSArray *content = [allOtherCarriersSorted filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"networkName beginswith[cd] %@", firstCharacter]];
        NSArray* contentSorted = [content sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        NSMutableArray *mutableContent = [NSMutableArray arrayWithArray:contentSorted];
        
        if ([mutableContent count] > 0)
        {
            NSString *key = [firstCharacter uppercaseString];
            [carrierInfoDictionary setObject:mutableContent forKey:key];
        }
    }
    
    return carrierInfoDictionary;
}


#pragma mark - Memory CleanUp Methods - 
-  (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



@end
