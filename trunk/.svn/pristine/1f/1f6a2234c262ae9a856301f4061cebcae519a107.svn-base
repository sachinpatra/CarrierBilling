//
//  SelectCountryViewController.m
//  ReachMe
//
//  Created by Bhaskar Munireddy on 19/07/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "SelectCountryViewController.h"
#import "SelectCountryTableViewCell.h"
#import "DebitRates.h"
#import "AppDelegate_rm.h"

#define kCallingRatesCellIdentifier @"CountrySelctionCell"

@interface SelectCountryViewController ()<UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate>{
    BOOL isSearching;
    UISearchBar *searchBar;
    BOOL hasPrefixValues;
}
@property (weak, nonatomic) IBOutlet UITableView *countryTableView;
@property (strong, nonatomic) NSMutableArray *filteredCountries;
@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;

@end

@implementation SelectCountryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Select Country";
    self.filteredCountries = [[NSMutableArray alloc] init];
    isSearching = NO;
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
        searchBar.placeholder = @"Search Country";
        searchBar.delegate = self;
        searchBar.frame = CGRectMake(0.0, 0.0, self.navigationController.view.bounds.size.width, 44.0);
        searchBar.barStyle = UIBarStyleDefault;
        searchBar.searchBarStyle = UISearchBarStyleDefault;
        searchBar.tintColor = [UIColor redColor];
        [self.view addSubview:searchBar];
        self.tableTopConstraint.constant = 44.0;
    }
    // Do any additional setup after loading the view.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    
    if (!isSearching) {
        if(section == 0)
            numberOfRows = 5;
        else
            numberOfRows = self.profileFieldData.count;
    }else if(self.filteredCountries){
        if(section == 0)
            return 0;
        else
            return self.filteredCountries.count;
    }
    
    return numberOfRows;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    static NSString *cellIdentifier = kCallingRatesCellIdentifier;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[SelectCountryTableViewCell class]]) {
        SelectCountryTableViewCell *countrySelectTableViewCell = (SelectCountryTableViewCell *)cell;
        [countrySelectTableViewCell configureCountryCell:[self getCountryAtIndexPath:indexPath]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSMutableDictionary*)getCountryAtIndexPath:(NSIndexPath*)indexPath
{
    hasPrefixValues = NO;
    NSMutableDictionary* country;
    if (!isSearching) {
        if(indexPath.section == 0)
        {
            country = [self.topFiveCountryList objectAtIndex:indexPath.row];
        }
        else
        {
            country = [self.profileFieldData objectAtIndex:indexPath.row];
        }
    }else if (self.filteredCountries) {
        country = [self.filteredCountries objectAtIndex:indexPath.row];
    }
    
    return country;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary* selectedCountry = [self getCountryAtIndexPath:indexPath];
    [self.searchController setActive:NO];
    [self.countrySelectionDelegate countrySelection:self didSelectCountry:selectedCountry];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchText = searchController.searchBar.text;
    if (searchText && searchText.length) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"COUNTRY_NAME contains[c] %@", searchText];
        self.filteredCountries = [NSMutableArray arrayWithArray:[self.profileFieldData filteredArrayUsingPredicate:resultPredicate]];
        
        isSearching = YES;
        [self.countryTableView reloadData];
    }else{
        isSearching = NO;
        [self.countryTableView reloadData];
    }
}

#pragma mark - Search Bar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText && searchText.length) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"COUNTRY_NAME contains[c] %@", searchText];
        self.filteredCountries = [NSMutableArray arrayWithArray:[self.profileFieldData filteredArrayUsingPredicate:resultPredicate]];
        isSearching = YES;
        [self.countryTableView reloadData];
    }else{
        isSearching = NO;
        [self.countryTableView reloadData];
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

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
