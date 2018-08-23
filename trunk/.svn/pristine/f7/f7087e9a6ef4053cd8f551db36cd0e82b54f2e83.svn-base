//
//  SettingsMissedCallCarrierViewController.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 9/15/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "SettingsMissedCallCarrierViewController.h"
#import "MZFormSheetController.h"
#import "MZCustomTransition.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"

#import "SettingModel.h"

//IVSettingsCountryCarrierInfo
#import "IVSettingsCountryCarrierInfo.h"

@interface SettingsMissedCallCarrierViewController ()
//Added by Nivedita, to hold the currently selected carrier information.
//@property (nonatomic, strong) NSDictionary *currentCarrierDetails;
@property (nonatomic, strong) IVSettingsCountryCarrierInfo *currentCarrierDetails;
@end

@implementation SettingsMissedCallCarrierViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithMobileString:(NSString*)mobNumber andCarrier:(NSString*)defaultCarrier andDataArray:(NSArray*)array
{
    self = [super init];
    if (self) {
        _mobileNumberString = mobNumber;
        _mobileCarrierArray = array;
        _defaultNetworkCarrier = defaultCarrier;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedRow = -1;
    for (int i=0; i<[self.mobileCarrierArray count]; i++) {
        
        //Get the IVSettingsCountryCarrierInfo
        IVSettingsCountryCarrierInfo *currentCountryCarrierInfo = [self.mobileCarrierArray objectAtIndex:i];
        
        //NSDictionary *dict = [self.mobileCarrierArray objectAtIndex:i];
        
        
        if ([self.defaultNetworkCarrier isEqualToString:currentCountryCarrierInfo.networkName]) {
            self.selectedRow = i;
        }
    }
    
    self.mobileNumberLabel.text = [Common getFormattedNumber:self.mobileNumberString withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    self.hidesBottomBarWhenPushed = YES;//KM

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return [self.mobileCarrierArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    //NSDictionary *dict = [self.mobileCarrierArray objectAtIndex:indexPath.row];
    IVSettingsCountryCarrierInfo *carrierInfo = [self.mobileCarrierArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    cell.textLabel.text = carrierInfo.networkName; //[dict objectForKey:@"network_name"];
    if (self.selectedRow == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRow = indexPath.row;
   // NSDictionary *dict = [self.mobileCarrierArray objectAtIndex:indexPath.row];
    IVSettingsCountryCarrierInfo *carrierInfo = [self.mobileCarrierArray objectAtIndex:indexPath.row];

    self.currentCarrierDetails = carrierInfo;
    self.defaultNetworkCarrier = carrierInfo.networkName;//[dict objectForKey:@"network_name"];
    [tableView reloadData];
    
    //As per requirement changes - updated by Nivedita - Date Apr6th 2016
    [self selectTapped:nil];
}

-(IBAction)selectTapped:(id)sender
{
    self.isOkTapped = YES;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {

    }];
    
}
-(IBAction)cancelTapped:(id)sender
{
    self.isOkTapped = NO;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
    
}


#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    
    [self.carrierTableView reloadData];
}

//Clean Up Methods
- (void)dealloc {
    
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    
}




@end
