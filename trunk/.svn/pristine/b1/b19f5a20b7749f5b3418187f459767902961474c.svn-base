//
//  ProfileFieldSelectionTableViewController.m
//  InstaVoice
//
//  Created by adwivedi on 24/08/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "ProfileFieldSelectionTableViewController.h"
#import "ProfileFieldSelectionTableViewCell.h"

#import "Common.h"

@interface ProfileFieldSelectionTableViewController ()

@end

@implementation ProfileFieldSelectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    switch (self.profileFieldType) {
        case ProfileFieldTypeGender:
            [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"genderCell"];
            break;
        case ProfileFieldTypeCountry:
            [self.tableView registerNib:[UINib nibWithNibName:@"ProfileFieldSelectionTableViewCell" bundle:nil] forCellReuseIdentifier:@"countryCell"];
            break;
        case ProfileFieldTypeState:
            [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"stateCell"];
            break;
        default:
            break;
    }
    
    
    self.title = self.profileFieldTitle;
    
    //Settings - TextFlow related changes notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    NSInteger numberOfSection = 0;
    // Return the number of sections.
    if(self.profileFieldType == ProfileFieldTypeCountry)
         numberOfSection = 2;
    else
         numberOfSection = 1;
    
    return numberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger numberOfRows = 0;
    // Return the number of rows in the section.
    if(self.profileFieldType == ProfileFieldTypeCountry)
    {
        if(section == 0)
            numberOfRows = 5;
        else
            numberOfRows = self.profileFieldData.count;
    }
    else
    {
         numberOfRows = self.profileFieldData.count;
    }
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.profileFieldType == ProfileFieldTypeCountry)
    {
        NSString *sectionName;
        switch (section)
        {
            case 0:
                sectionName = @"  ";
                break;
            case 1:
                sectionName = @"  ";
                break;
                // ...
            default:
                sectionName = @"";
                break;
        }
        return sectionName;
    }
    else
        return @"";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* vw = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 2)];
    if(section == 0)
        vw.backgroundColor = [UIColor clearColor];
    else
        vw.backgroundColor = [UIColor grayColor];
    return vw;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    switch (self.profileFieldType) {
        case ProfileFieldTypeGender:
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"genderCell" forIndexPath:indexPath];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"genderCell"];
            }
            return [self configureGenderCell:cell forIndexPath:indexPath];
        }
            break;
        case ProfileFieldTypeCountry:
        {
            ProfileFieldSelectionTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"countryCell" forIndexPath:indexPath];
            if(cell == nil)
            {
                cell = [[ProfileFieldSelectionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"countryCell"];
            }
            [cell configureCountryCell:[self getCountryAtIndexPath:indexPath]];
            return cell;
        }
            break;
        case ProfileFieldTypeState:
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"stateCell" forIndexPath:indexPath];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"stateCell"];
            }
            return [self configureStateCell:cell forIndexPath:indexPath];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(UITableViewCell*)configureGenderCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath
{
    NSString* gender = [self.profileFieldData objectAtIndex:indexPath.row];
    cell.textLabel.text = gender;
    return cell;
}

-(UITableViewCell*)configureStateCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary* state = [self.profileFieldData objectAtIndex:indexPath.row];
    cell.textLabel.text = [state valueForKey:@"STATE_NAME"];
    //For Text Reflow. - Nivedita - Date May 23rd.
    cell.textLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    return cell;
}

-(NSMutableDictionary*)getCountryAtIndexPath:(NSIndexPath*)indexPath
{
    NSMutableDictionary* country;
    if(indexPath.section == 0)
    {
        country = [self.topFiveCountryList objectAtIndex:indexPath.row];
    }
    else
    {
        country = [self.profileFieldData objectAtIndex:indexPath.row];
    }
    return country;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.profileFieldType) {
        case ProfileFieldTypeGender:
        {
            [self.profileFieldSelectionDelegate profileFieldSelectionViewController:self didSelectGender:[self.profileFieldData objectAtIndex:indexPath.row]];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case ProfileFieldTypeState:
        {
            [self.profileFieldSelectionDelegate profileFieldSelectionViewController:self didSelectState:[self.profileFieldData objectAtIndex:indexPath.row]];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case ProfileFieldTypeCountry:
        {
            NSMutableDictionary* selectedCountry = [self getCountryAtIndexPath:indexPath];
            [self.profileFieldSelectionDelegate profileFieldSelectionViewController:self didSelectCountry:selectedCountry];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    [self.tableView reloadData];
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
