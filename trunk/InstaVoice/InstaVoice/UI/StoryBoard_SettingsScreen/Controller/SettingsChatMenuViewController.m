//
//  MaxRecordTimeScreen.m
//  InstaVoice
//
//  Created by EninovUser on 08/11/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "SettingsChatMenuViewController.h"
#import "Setting.h"

@interface SettingsChatMenuViewController () <UITableViewDataSource, UITableViewDelegate, SettingProtocol>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISegmentedControl *lengthSegmentedControl;

@end

typedef NS_ENUM(NSUInteger,RecordingLength){
    eRecoridngLength30Secs = 0,
    eRecoridngLength60Secs,
    eRecoridngLength120Secs,
    
};


@implementation SettingsChatMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    _model = [Setting sharedSetting].data;
    [Setting sharedSetting].delegate = self;
    [super viewDidLoad];
    //[self updateViewConstraintsForStoryBoard];
    [self createTopViewStoryBoardWithTitle:@"Chat Settings"];
    [self.recordTimeSlider setThumbImage: [UIImage imageNamed:@"slider_recording_limit.png"] forState:UIControlStateNormal];
    [self.recordTimeSlider setThumbImage: [UIImage imageNamed:@"slider_recording_limit.png"] forState:UIControlStateHighlighted];
    [self updateSettingScreen];
    //KM
    self.title = @"Chat Settings";
    
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.lengthSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"30 sec", @"1 min", @"2 min"]];
    [self.lengthSegmentedControl addTarget:self action:@selector(timeValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.switchLocationDisplay = [UISwitch new];
    [self.switchLocationDisplay addTarget:self action:@selector(displayLocBtnAction) forControlEvents:UIControlEventValueChanged];
    
    self.hidesBottomBarWhenPushed = YES;
    
    //Start: Nivedita,Date 14th Jan -Set the font
    self.recordTimeLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    
   /* SEP 19, 2016
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    */
    
    
}

-(void)viewWillAppear:(BOOL)animated

{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    self.uiType = MAX_RECORD_TIME_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    _model = [Setting sharedSetting].data;
    [Setting sharedSetting].delegate = self;//SEP 19, 2016
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    
}

//KM
- (IBAction) timeValueChanged:(UISlider *)sender {
    
    //Nivedita - Added check of network - to fix the bug - 8696, Date 13th Apr.
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        
        switch (self.lengthSegmentedControl.selectedSegmentIndex) {
            case eRecoridngLength30Secs:
                [[Setting sharedSetting] updateUserSettingType:SettingTypeMaxRecordTime andValue:30];
                //Till we recieve we can not show the end user the status - so commenting it.
                //  [ScreenUtility showAlertMessage:@"Setting Saved"];
                break;
            case eRecoridngLength60Secs:
                [[Setting sharedSetting] updateUserSettingType:SettingTypeMaxRecordTime andValue:60];
                //   [ScreenUtility showAlertMessage:@"Setting Saved"];
                break;
            case eRecoridngLength120Secs:
                [[Setting sharedSetting] updateUserSettingType:SettingTypeMaxRecordTime andValue:120];
                //  [ScreenUtility showAlertMessage:@"Setting Saved"];
                break;
            default:
                break;
        }
    }
    else {
        [self updateSettingScreen];
        [self.tableView reloadData];
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE",nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE",nil)];
        
    }
}

-(int)roundSliderValue:(float)x {
    if (x < 25) {
        return 0;
    } else if (x < 75) {
        return 50;
    } else  {
        return 100;
    }
}


-(void)updateSettingScreen
{
    NSInteger time = _model.maxRecordTime;//[recordTm integerValue];
    int value;
    NSString *timeStr = nil;
    if(time == 120) {
        timeStr = @"2 Min";
        value = 100;
    }
    else if(time == 60) {
        timeStr = @"1 Min";
        value = 50;
        
    } else {
        timeStr = @"30 Sec";
        value = 0;
    }
    self.recordTimeLabel.text = timeStr;
    [self.recordTimeSlider setValue:value animated:NO];
    
    BOOL disLocFlag = _model.displayLocation;//[disLoc boolValue];
    if(disLocFlag)
        [self.switchLocationDisplay setOn:YES animated:NO];
    else
        [self.switchLocationDisplay setOn:NO animated:NO];
}

- (IBAction)displayLocBtnAction
{
    //Nivedita - Added check of network - to fix the bug - 8696, Date 13th Apr.
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        
        BOOL updateFlag =NO;
        if(self.switchLocationDisplay.isOn) {
            [self.switchLocationDisplay setOn:YES animated:NO];
            updateFlag = YES;
            [appDelegate.confgReader setUserLocationAccess:YES];
        }
        else {
            [self.switchLocationDisplay setOn:NO animated:NO];
            [appDelegate.confgReader setUserLocationAccess:NO];
            
        }
        
        NSString *locationUpdateStatus = [NSString stringWithFormat:@"%d", updateFlag];
        //Update the status in the userdefaults.
        NSUserDefaults *standarDefaults = [NSUserDefaults standardUserDefaults];
        [standarDefaults setValue:locationUpdateStatus forKey:kShareLocationSettingsValue];
        [standarDefaults synchronize];
        
        [[Setting sharedSetting]updateUserSettingType:SettingTypeDisplayLocation andValue:updateFlag];
        
        BOOL  flag = [CLLocationManager locationServicesEnabled];
        if (flag)
        {
            KLog(@"Location Services Enabled");
            if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
                [self getLocationPermission];
                return;
            }
            else {
                if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
                    UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOCATION_PERMISSION_DENIED", nil) message:NSLocalizedString(@"LOCATION_PERMISSION_MSG",nil) delegate:nil
                                                           cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                                           otherButtonTitles:nil];
                    [alert show];
                    [self.switchLocationDisplay setOn:NO animated:NO];
                    return;
                }
            }
            
        }
        else {
            
            UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"LOCATION_SERVICE_OFF", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
            [alert show];
            return;
        }
        // [ScreenUtility showAlertMessage:@"Setting saved"];
    }
    else {
        [self updateSettingScreen];
        [self.tableView reloadData];
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE",nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE",nil)];
    }
}


#pragma mark - Get The Current Loction & Address
- (void)getLocationPermission {
    /*---- For get location and address of the user -----*/
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [locationManager requestWhenInUseAuthorization];
    
    [self getCurrentLocation];
}


-(void)getCurrentLocation {
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
}


- (void)stopUpdatingLocation {
    [locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self stopUpdatingLocation];
    [appDelegate.confgReader setUserLocationAccess:NO];
    //Before updating it to server update it in the userdefaults.
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setValue:@NO forKey:kShareLocationSettingsValue];
    [standardDefaults synchronize];
    
    [[Setting sharedSetting]updateUserSettingType:SettingTypeDisplayLocation andValue:NO];
    if([error code] == kCLErrorDenied)
        [self.switchLocationDisplay setOn:NO animated:NO];
    
    else
        [ScreenUtility showAlertMessage:NSLocalizedString(@"LOCATION_NOT_ACCESSIBLE", nil)];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self stopUpdatingLocation];
    [appDelegate.confgReader setUserLocationAccess:YES];
    
    //Before updating it to server update it in the userdefaults.
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setValue:@YES forKey:kShareLocationSettingsValue];
    [standardDefaults synchronize];
    
    [[Setting sharedSetting]updateUserSettingType:SettingTypeDisplayLocation andValue:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:shouldAnimatePushPop];
}

//KM
#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 54.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Recording Settings";
            break;
        case 1:
            return @"Location Settings";
        default:
            break;
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.frame = headerFrame;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            UILabel *cellTextLabel;
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"changeTimeRecordingLengthCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"changeTimeRecordingLengthCell"];
                
                int xWidth = appDelegate.deviceHeight.width <= 340 ? 5:0;
                int xX =  appDelegate.deviceHeight.width <= 340 ? 1:8;
                
                self.lengthSegmentedControl.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - self.lengthSegmentedControl.frame.size.width - xX, ([tableView.delegate tableView:tableView heightForRowAtIndexPath:indexPath] / 2) - (self.lengthSegmentedControl.frame.size.height / 2), self.lengthSegmentedControl.frame.size.width - xWidth, self.lengthSegmentedControl.frame.size.height);
                
                [cell addSubview:self.lengthSegmentedControl];
            }
            
            for(UIView *subViewCell in cell.contentView.subviews) {
                if(subViewCell.tag == 99)
                    [subViewCell removeFromSuperview];
            }
            
            CGFloat xOffSet = 15.0; //TODO : Hardcoded, as per design we need to determine the proper xOffSet.
            CGFloat widthOffSet = 20.0;
            
            cellTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(xOffSet, self.lengthSegmentedControl.frame.origin.y, tableView.frame.size.width - self.lengthSegmentedControl.frame.size.width - widthOffSet, self.lengthSegmentedControl.frame.size.height)];
            cellTextLabel.tag = 99;
            [cell.contentView addSubview:cellTextLabel];
            
            cellTextLabel.textAlignment = NSTextAlignmentLeft;
            cellTextLabel.text = @"Recording Length";
            
            [cellTextLabel setFont:[Common preferredFontForTextStyleInApp:UIFontTextStyleBody]];
            cellTextLabel.adjustsFontSizeToFitWidth = YES;
            cellTextLabel.numberOfLines = 1;
            
            int time = (int)_model.maxRecordTime;
            switch (time) {
                case 30:
                    self.lengthSegmentedControl.selectedSegmentIndex = 0;
                    break;
                case 60:
                    self.lengthSegmentedControl.selectedSegmentIndex = 1;
                    break;
                case 120:
                    self.lengthSegmentedControl.selectedSegmentIndex = 2;
                    break;
                default:
                    self.lengthSegmentedControl.selectedSegmentIndex = 0;
                    break;
            }
            
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        case 1: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shareLocationInChatsCell"];
            
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"shareLocationInChatCell"];
                
                self.switchLocationDisplay.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - self.switchLocationDisplay.frame.size.width - 8, ([tableView.delegate tableView:tableView heightForRowAtIndexPath:indexPath] / 2) - (self.switchLocationDisplay.frame.size.height / 2), self.switchLocationDisplay.frame.size.width, self.switchLocationDisplay.frame.size.height);
                [cell addSubview:self.switchLocationDisplay];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Share Location In Chats";
            cell.textLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
            
            self.switchLocationDisplay.on = _model.displayLocation;
            
            return cell;
        }
        default:
            break;
    }
    return [UITableViewCell new];
}

#pragma mark - Settings Protocol Methods -
- (void)updateSettingCompletedWith:(SettingModel *)modelData withUpdateStatus:(BOOL)withUpdateStatus {
    
    //If update successful only fetch settings again, else upate settings is failed.
    
    //Bhaskar --> Removed Toast messages
    
    if(withUpdateStatus){
        //[ScreenUtility showAlertMessage:@"Setting Saved"];
    }else {
        _model = [Setting sharedSetting].data;
        //[ScreenUtility showAlertMessage:@"Please try again later"];
        [self updateSettingScreen];
        [self.tableView reloadData];
    }
}

- (void)fetchSettingCompletedWith:(SettingModel *)modelData withFetchStatus:(BOOL)withFetchStatus {
    
    //Update the UI
    if (withFetchStatus) {
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        BOOL updateStatus = [[standardDefaults valueForKey:kUserSettingsUpdated]boolValue];
        if (updateStatus) {
            //Reassign the value and reload the UI.
            _model = [Setting sharedSetting].data;
            //Update the UI in this case.
            [self updateSettingScreen];
            [self.tableView reloadData];
        }
        //In else case no need to update the status, since - already in UI button we have chanegd the recording time length.
    }
    
}

#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    
    [self.tableView reloadData];
}


//Clean Up Methods
- (void)dealloc {
    
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    
}

//
@end
