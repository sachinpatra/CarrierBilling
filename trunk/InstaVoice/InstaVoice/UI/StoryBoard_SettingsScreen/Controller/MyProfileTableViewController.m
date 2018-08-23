//
//  MyProfileViewController.m
//  InstaVoice
//
//  Created by adwivedi on 09/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "MyProfileTableViewController.h"
#import "Setting.h"
#import "FacebookWebViewScreen.h"
#import "Profile.h"
#import "IVFileLocator.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"
#import "IVColors.h"
#import "ProfileFieldSelectionTableViewController.h"
#import "FetchStatesAPI.h"
#import "AddressEntryTableViewCell.h"
#import "ScreenUtility.h"
#import "EditableTextTableViewCell.h"
#import "IVImageUtility.h"
#import "FetchUserProfileAPI.h"
#import "IVInAppPromoViewController.h"

typedef NS_ENUM (NSUInteger, ProfileCells){
    eProfileImageCell = 0,
    eUserNameCell = 1,
    eEmailIdCell = 2,
    eGenderSelectionCell = 3,
    eBirthdaySelectionCell = 4,
    eCountrySelectionCell = 5,
    eStateSelectionCell = 6,
    eCitySelectionCell = 7,
    eAddressSelectionCell = 8,
};

#define  kNumberOfRowsInSection 8
#define  kNumberOfSections 1
#define  kProfileImageCellHeight 250.0
#define  kCellHeight 44.0
#define  kProfilePictureViewTag 15

@interface MyProfileTableViewController ()<SettingProtocol,ProfileProtocol, UITableViewDataSource, UITableViewDelegate,ProfileFieldSelectionDelegate,EditableTextTableViewCellDelegate,UITextFieldDelegate>
@property (strong, nonatomic) UIImageView *profilePictureImageView;
@property BOOL editing;
@end

@implementation MyProfileTableViewController

#pragma mark - Init Methods -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //KM
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.hidesBottomBarWhenPushed = YES;
        //
    }
    return self;
}

#pragma mark - View Life Cycle Methods -
//KM
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add the edit button to the top right of the screen.
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editClicked:)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    // set the title of this screen
    self.title = @"My Profile";
    
    UINib* editableFieldNib = [UINib nibWithNibName:@"EditableTextTableViewCell" bundle:nil];
    [self.tableView registerNib:editableFieldNib forCellReuseIdentifier:@"editableField"];
    
    _datePickerVisible = NO;
    //Image Work
    imagePickerViewController = [[UIImagePickerController alloc] init];
    imagePickerViewController.delegate = (id)self;
    imagePickerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerViewController.allowsEditing = YES;
    
    [self setEditedData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;//KM
    UserProfileModel* model = [[Profile sharedUserProfile]getUserProfile];;
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
         [[Profile sharedUserProfile]updateUserProfile:model];
    }
    
    if(_fetchSettingFromServer) {
        [Setting sharedSetting].delegate = self;
        [[Setting sharedSetting]getUserSettingFromServer];
        _fetchSettingFromServer = NO;
    }
    
    [self.tableView reloadData];
    [Profile sharedUserProfile].delegate = self;
    
//    if (!self.editing) {
//        [[Profile sharedUserProfile]getProfileDataFromServer];//DEC 8, 2016
//    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [Setting sharedSetting].delegate = Nil;
    [super viewWillDisappear:animated];
    [Profile sharedUserProfile].delegate = nil;
    _datePickerVisible = NO;
    [_datePickerView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfRowsInSection;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfSections;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: return kProfileImageCellHeight;
            //case 4: return 100;
        default: return kCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case eProfileImageCell: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfilePictureCell"];
            
            // set up the cell if has not already been initialized.
            if (!cell) {
                // initialize the cell
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProfilePictureCell"];
                
                // set up the view in the cell
                UIImageView *profilePictureView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [tableView.delegate tableView:tableView heightForRowAtIndexPath:indexPath])];
                profilePictureView.tag = kProfilePictureViewTag;
                profilePictureView.backgroundColor = [UIColor clearColor];
                profilePictureView.contentMode = UIViewContentModeScaleAspectFill;
                profilePictureView.clipsToBounds = NO;
                
                self.profilePictureImageView = profilePictureView;
                [cell.contentView addSubview:profilePictureView];
                cell.layer.zPosition = 0;
            }
            
            // get the image view in the cell
            UIImageView *profilePictureView = (UIImageView *)[cell viewWithTag:15];
            
            if(self.editing) {
                for(UIView* vw in [profilePictureView subviews])
                {
                    [vw removeFromSuperview];
                }
                
                CGRect ppView = profilePictureView.frame;
                CGRect editCameraFrame = CGRectMake((ppView.size.width/2)-20, (ppView.size.height/2)-20, 40, 40);
                UIImageView* editCamera = [[UIImageView alloc]initWithFrame:editCameraFrame];
                editCamera.image = [UIImage imageNamed:@"editProfileCamera"];
                [profilePictureView addSubview:editCamera];
            }
            else
            {
                for(UIView* vw in [profilePictureView subviews])
                {
                    [vw removeFromSuperview];
                }
            }
            
            // get ther user's profile picture and user name
            UserProfileModel *profileData = [Profile sharedUserProfile].profileData;
            if (profileData) {
                NSString *pathToPicture = [IVFileLocator getMyProfilePicPath:profileData.localPicPath];
                if (pathToPicture && pathToPicture.length > 0) {
                    profilePictureView.image = [UIImage imageWithContentsOfFile:pathToPicture];
                }else{
                    profilePictureView.image = [UIImage imageNamed:@"default_profile_img"];
                }
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            
            // the username cell
        case eUserNameCell: {
            EditableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editableField"];
            
            // set up the cell if it hasn't been initialized yet
            if (!cell) {
                cell = [[EditableTextTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"editableField"];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.zPosition = 1;
            if(self.editing)
            {
                
                
                cell.delegate = self;
                cell.fieldType.text = @"Name";
                cell.editableFieldType = EditableFieldTypeName;
                cell.fieldValue.userInteractionEnabled = YES;
                cell.fieldValue.textAlignment = NSTextAlignmentRight;
                [cell.fieldValue setBorderStyle:UITextBorderStyleRoundedRect];
                [cell.fieldValue setNeedsDisplay];
                // get the user's username
                [cell.fieldValue setTextColor:[UIColor blackColor]];
                cell.fieldValue.text = _editedName;
//                if(_editedName.length == 0)
//                {   UserProfileModel* profileData = [[Profile sharedUserProfile]profileData];
//                    cell.fieldValue.text=profileData.screenName;
//                    _editedName=profileData.screenName;
//                }
                
                cell.fieldValue.delegate =self;
                cell.fieldValue.tag = eUserNameCell;
                
                // set up the icon for this image
                cell.cellImage.image = [[UIImage imageNamed:@"profile-pic-set"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.cellImage.tintColor = [IVColors blueOutlineColor];
                
                
                cell.clipsToBounds = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                
                //Start: Nivedita - Date 14th Jan - Set the font
                cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                //End: Nivedita
                
                return cell;
            }
            else
            {
                cell.delegate = self;
                cell.fieldType.text = @"Name";
                cell.editableFieldType = EditableFieldTypeName;
                cell.fieldValue.userInteractionEnabled = NO;
                cell.fieldValue.textAlignment = NSTextAlignmentRight;
                [cell.fieldValue setBorderStyle:UITextBorderStyleNone];
                [cell.fieldValue setNeedsDisplay];
                // get the user's username
                [cell.fieldValue setTextColor:[UIColor darkGrayColor]];
                cell.fieldValue.text = _editedName;
//                if(_editedName.length == 0)
//                {   UserProfileModel* profileData = [[Profile sharedUserProfile]profileData];
//                    NSString *trimmedString = [profileData.screenName stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
//                    NSString *name;
//                    if(![trimmedString length])
//                    {
//                        name = [Common setPlusPrefix:profileData.screenName];
//                        name = [Common getFormattedNumber:name withCountryIsdCode:nil withGivenNumberisCannonical:YES];
//                    }else{
//                        name = profileData.screenName;
//                    }
//                    cell.fieldValue.text=name;
//                }
                
                cell.fieldValue.delegate =self;
                
                // set up the icon for this image
                cell.cellImage.image = [[UIImage imageNamed:@"profile-pic-set"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.cellImage.tintColor = [IVColors blueOutlineColor];
                
                cell.clipsToBounds = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                
                //Start: Nivedita - Date 14th Jan - Set the font
                cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                //End: Nivedita
                
                return cell;
                
            }
        }
            
        case eGenderSelectionCell:{
            
            EditableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editableField"];
            
            // set up the cell if it hasn't been initialized yet
            if (!cell) {
                cell = [[EditableTextTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"editableField"];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.zPosition = 1;
            if(self.editing)
            {
                cell.delegate = self;
                cell.fieldType.text = @"Gender";
                cell.editableFieldType = EditableFieldTypeName;
                cell.fieldValue.userInteractionEnabled = NO;
                cell.fieldValue.textAlignment = NSTextAlignmentRight;
                [cell.fieldValue setBorderStyle:UITextBorderStyleNone];
                [cell.fieldValue setNeedsDisplay];
                
                cell.fieldValue.text = _editedGender;
                cell.fieldValue.delegate =self;
                
                // set up the icon for this image
                cell.cellImage.image = [[UIImage imageNamed:@"gender-ico"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.cellImage.tintColor = [IVColors blueOutlineColor];
                cell.clipsToBounds = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                
                //Start: Nivedita - Date 14th Jan - Set the font
                cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                //End: Nivedita
                
                return cell;
            }
            else
            {
                cell.delegate = self;
                cell.fieldType.text = @"Gender";
                cell.editableFieldType = EditableFieldTypeName;
                cell.fieldValue.userInteractionEnabled = NO;
                cell.fieldValue.textAlignment = NSTextAlignmentRight;
                [cell.fieldValue setBorderStyle:UITextBorderStyleNone];
                [cell.fieldValue setNeedsDisplay];
                // get the user's username
                [cell.fieldValue setTextColor:[UIColor darkGrayColor]];
                cell.fieldValue.text = _editedGender;
                cell.fieldValue.delegate =self;
                
                // set up the icon for this image
                cell.cellImage.image = [[UIImage imageNamed:@"gender-ico"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.cellImage.tintColor = [IVColors blueOutlineColor];
                cell.clipsToBounds = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                //Start: Nivedita - Date 14th Jan - Set the font
                cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                //End: Nivedita
                
                return cell;
                
            }
        }
            // birthday cell
        case eBirthdaySelectionCell: {
            EditableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editableField"];
            
            // set up the cell if it hasn't been initialized yet
            if (!cell) {
                cell = [[EditableTextTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"editableField"];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.zPosition = 1;
            cell.delegate = self;
            cell.fieldType.text = @"Birthday";
            cell.editableFieldType = EditableFieldTypeName;
            cell.fieldValue.userInteractionEnabled = NO;
            cell.fieldValue.textAlignment = NSTextAlignmentRight;
            [cell.fieldValue setBorderStyle:UITextBorderStyleNone];
            [cell.fieldValue setNeedsDisplay];
            [cell.fieldValue setTextColor:[UIColor darkGrayColor]];
            cell.fieldValue.text = _editedDateString;
            cell.cellImage.image = [[UIImage imageNamed:@"birthday-cake"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.cellImage.tintColor = [IVColors redColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //Start: Nivedita - Date 14th Jan - Set the font
            cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
            cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
            //End: Nivedita
            return cell;
        }
            
            // address cell
        case eAddressSelectionCell: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileInfoCell"];
            
            // set up the cell if it hasn't been initialized yet
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ProfileInfoCell"];
                cell.backgroundColor = [UIColor whiteColor];
                cell.layer.zPosition = 1;
            }
            
            cell.textLabel.text = @"Address";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //Start: Nivedita - Date 14th Jan - Set the font
            cell.textLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
            cell.detailTextLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
            //End: Nivedita
            
            return cell;
            
        }
        case eCountrySelectionCell: {
            EditableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editableField"];
            
            // set up the cell if it hasn't been initialized yet
            if (!cell) {
                cell = [[EditableTextTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"editableField"];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.zPosition = 1;
            if(self.editing)
            {
                cell.delegate = self;
                cell.fieldType.text = @"Country";
                cell.editableFieldType = EditableFieldTypeName;
                cell.fieldValue.userInteractionEnabled = NO;
                cell.fieldValue.textAlignment = NSTextAlignmentRight;
                [cell.fieldValue setBorderStyle:UITextBorderStyleNone];
                [cell.fieldValue setNeedsDisplay];
                [cell.fieldValue setTextColor:[UIColor darkGrayColor]];
                cell.fieldValue.text = _editedCountry;
                cell.fieldValue.delegate =self;
                cell.clipsToBounds = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                
                //Start: Nivedita - Date 14th Jan - Set the font
                cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                //End: Nivedita
                
                return cell;
            }
            else
            {
                cell.delegate = self;
                cell.fieldType.text = @"Country";
                cell.editableFieldType = EditableFieldTypeName;
                cell.fieldValue.userInteractionEnabled = NO;
                cell.fieldValue.textAlignment = NSTextAlignmentRight;
                [cell.fieldValue setBorderStyle:UITextBorderStyleNone];
                [cell.fieldValue setNeedsDisplay];
                // get the user's username
                [cell.fieldValue setTextColor:[UIColor darkGrayColor]];
                cell.fieldValue.text = _editedCountry;
                cell.fieldValue.delegate =self;
                cell.clipsToBounds = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                //Start: Nivedita - Date 14th Jan - Set the font
                cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                //End: Nivedita
                
                return cell;
                
            }
        }
        case eStateSelectionCell: {
            EditableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editableField"];
            
            // set up the cell if it hasn't been initialized yet
            if (!cell) {
                cell = [[EditableTextTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"editableField"];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.zPosition = 1;
            if(self.editing)
            {
                cell.delegate = self;
                cell.fieldType.text = @"State";
                cell.editableFieldType = EditableFieldTypeName;
                cell.fieldValue.userInteractionEnabled = NO;
                cell.fieldValue.textAlignment = NSTextAlignmentRight;
                [cell.fieldValue setBorderStyle:UITextBorderStyleNone];
                [cell.fieldValue setNeedsDisplay];
                [cell.fieldValue setTextColor:[UIColor darkGrayColor]];
                cell.fieldValue.text = _editedState;
                if(_editedState.length == 0)
                    cell.fieldValue.placeholder = @"Select State";
                cell.fieldValue.delegate =self;
                cell.clipsToBounds = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                
                //Start: Nivedita - Date 14th Jan - Set the font
                cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                //End: Nivedita
                
                return cell;
            }
            else
            {
                cell.delegate = self;
                cell.fieldType.text = @"State";
                cell.editableFieldType = EditableFieldTypeName;
                cell.fieldValue.userInteractionEnabled = NO;
                cell.fieldValue.textAlignment = NSTextAlignmentRight;
                [cell.fieldValue setBorderStyle:UITextBorderStyleNone];
                [cell.fieldValue setNeedsDisplay];
                // get the user's username
                [cell.fieldValue setTextColor:[UIColor darkGrayColor]];
                cell.fieldValue.text = _editedState;
                if(_editedState.length == 0)
                    cell.fieldValue.placeholder = @"";
                cell.fieldValue.delegate =self;
                
                
                cell.clipsToBounds = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                //Start: Nivedita - Date 14th Jan - Set the font
                cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                //End: Nivedita
                
                
                return cell;
            }
            
        }
        case eCitySelectionCell: {
            if(self.editing)
            {
                EditableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editableField"];
                
                // set up the cell if it hasn't been initialized yet
                if (!cell) {
                    cell = [[EditableTextTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"editableField"];
                    cell.backgroundColor = [UIColor whiteColor];
                    // cell.layer.zPosition = 1;
                }
                
                cell.delegate = self;
                cell.fieldType.text = @"City";
                cell.editableFieldType = EditableFieldTypeCity;
                cell.fieldValue.userInteractionEnabled = YES;
                cell.fieldValue.textAlignment = NSTextAlignmentRight;
                [cell.fieldValue setBorderStyle:UITextBorderStyleRoundedRect];
                [cell.fieldValue setNeedsDisplay];
                // get the user's username
                [cell.fieldValue setTextColor:[UIColor blackColor]];
                cell.fieldValue.text = _editedCity;
                cell.fieldValue.delegate =self;
                cell.fieldValue.placeholder = @"Enter City";
                cell.fieldValue.tag = eCitySelectionCell;
                
                // set up the icon for this image
                cell.cellImage.image = [[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.cellImage.tintColor = [IVColors orangeOutlineColor];
                cell.cellImage.alpha = .01;
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                //Start: Nivedita - Date 14th Jan - Set the font
                cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                //End: Nivedita
                
                return cell;
            }
            else
            {
                EditableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editableField"];
                
                // set up the cell if it hasn't been initialized yet
                if (!cell) {
                    cell = [[EditableTextTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"editableField"];
                    cell.backgroundColor = [UIColor whiteColor];
                }
                
                cell.delegate=self;
                cell.fieldType.text = @"City";
                cell.fieldValue.text = _editedCity;
                cell.fieldValue.placeholder = @"Enter City";
                cell.editableFieldType = EditableFieldTypeCity;
                cell.fieldValue.userInteractionEnabled = NO;
                cell.fieldValue.textAlignment = NSTextAlignmentRight;
                [cell.fieldValue setBorderStyle:UITextBorderStyleNone];
                [cell.fieldValue setNeedsDisplay];
                cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                [cell.fieldValue setTextColor:[UIColor darkGrayColor]];
                
                cell.cellImage.image = [[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.cellImage.tintColor = [IVColors orangeOutlineColor];
                cell.cellImage.alpha = .01;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
            }
            //
        }
        case eEmailIdCell: {
            EditableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editableField"];
            
            // set up the cell if it hasn't been initialized yet
            if (!cell) {
                cell = [[EditableTextTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"editableField"];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.zPosition = 1;
            if(self.editing)
            {
                
                
                cell.delegate = self;
                cell.fieldType.text = @"Email";
                cell.editableFieldType = EditableFieldTypeEmail;
                cell.fieldValue.userInteractionEnabled = YES;
                cell.fieldValue.textAlignment = NSTextAlignmentRight;
                [cell.fieldValue setBorderStyle:UITextBorderStyleRoundedRect];
                [cell.fieldValue setNeedsDisplay];
                // get the user's username
                [cell.fieldValue setTextColor:[UIColor blackColor]];
                cell.fieldValue.text = _editedEmail;
//                if(_editedEmail.length == 0)
//                {   UserProfileModel* profileData = [[Profile sharedUserProfile]profileData];
//                    cell.fieldValue.text=profileData.profileEmailId;
//                    _editedEmail=profileData.profileEmailId;
//                }
                cell.fieldValue.placeholder = @"Email Address";
                cell.fieldValue.keyboardType = UIKeyboardTypeEmailAddress;
                cell.fieldValue.delegate =self;
                
                // set up the icon for this image
                cell.cellImage.image = [[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.cellImage.tintColor = [IVColors blueOutlineColor];
                
                cell.clipsToBounds = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                
                return cell;
            }
            else
            {
                cell.delegate = self;
                cell.fieldType.text = @"Email";
                cell.editableFieldType = EditableFieldTypeEmail;
                cell.fieldValue.userInteractionEnabled = NO;
                cell.fieldValue.textAlignment = NSTextAlignmentRight;
                [cell.fieldValue setBorderStyle:UITextBorderStyleNone];
                [cell.fieldValue setNeedsDisplay];
                // get the user's username
                [cell.fieldValue setTextColor:[UIColor darkGrayColor]];
                cell.fieldValue.text = _editedEmail;
//                if(_editedEmail.length == 0)
//                {   UserProfileModel* profileData = [[Profile sharedUserProfile]profileData];
//                    cell.fieldValue.text=profileData.profileEmailId;
//                    if (profileData.profileEmailId.length == 0) {
//                        cell.fieldValue.placeholder = @"Email Address";
//                    }
//                }
                
                cell.fieldValue.delegate =self;
                
                cell.cellImage.image = [[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.cellImage.tintColor = [IVColors blueOutlineColor];
                
                cell.clipsToBounds = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                cell.fieldType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                cell.fieldValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
                
                return cell;
                
            }
        }
        default:
            break;
    }
    return nil;
}

#pragma mark - Table View Delegate Methods -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.editing)
    {
        if(_datePickerVisible)
            [self cancelDateValue:nil];
        [self checkAndRemoveKeyboard];
        
        if(indexPath.row == eProfileImageCell)
            [self selectPicFromGallery];
        if(indexPath.row == eGenderSelectionCell) {
            ProfileFieldSelectionTableViewController* svc = [[ProfileFieldSelectionTableViewController alloc]initWithNibName:@"ProfileFieldSelectionTableViewController" bundle:Nil];
            svc.profileFieldTitle = @"Select Gender";
            svc.profileFieldType = ProfileFieldTypeGender;
            svc.profileFieldData = [NSMutableArray arrayWithObjects:@"Male",@"Female",@"Other", nil];
            svc.profileFieldSelectionDelegate = self;
            [self.navigationController pushViewController:svc animated:YES];
        }
        else if(indexPath.row == eBirthdaySelectionCell)
            [self datePickerBtnAction:nil];
        
        else if(indexPath.row == eCountrySelectionCell)
            [self countryBtnAction];
        
        else if(indexPath.row == eStateSelectionCell)
            [self stateBtnAction];
        
    }
}

#pragma mark - Private Methods -

- (CGSize)getCropSize {
    CGSize size;
    
    size = CGSizeMake(DEVICE_WIDTH, 230);
    
    return size;
}

- (BOOL)isNumeric:(NSString *)name {
    
    BOOL result = FALSE;
    if(name != nil && name.length >0) {
        BOOL valid = [Common validateNumeric:name];
        if (valid)
            result = TRUE;
    }
    return result;
}


- (void)selectPicFromGallery {
    int isNetAvailable = [Common isNetworkAvailable];
    if(isNetAvailable == NETWORK_AVAILABLE)
        [self presentViewController:imagePickerViewController animated:YES completion:nil];
    else {
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

-(BOOL)isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)editClicked:(id)sender {
    int isNetAvailable = [Common isNetworkAvailable];
    if(isNetAvailable == NETWORK_AVAILABLE) {
        UIBarButtonItem* edit;
        if(self.editing) {
            edit= [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editClicked:)];
            _datePickerView.hidden=true;
            if(_editedName.length==0){
                [ScreenUtility showAlertMessage:@"Empty Profile name is not allowed"];
                return;
            }
            else if (![self isValidEmail:_editedEmail] && _editedEmail.length != 0){
                [ScreenUtility showAlertMessage:@"Enter Valid Email Address"];
                return;
            }
            else{
                _editedName = [_editedName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *name = _editedName;
                name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
                name = [name stringByReplacingOccurrencesOfString:@"+" withString:@""];
                NSString *trimmedString = [name stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
                if(![trimmedString length])
                {
                    [ScreenUtility showAlertMessage:@"Name should not be a number"];
                    return;
                }
                [self saveNewData];
                self.editing = NO;
                [self.tableView reloadData];
                [ScreenUtility showAlertMessage:@"Profile saved successfully"];
                self.navigationItem.rightBarButtonItem = edit;
                
                
            }
            
            
        }
        else {
            edit = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editClicked:)];
            self.editing = YES;
        }
        self.navigationItem.rightBarButtonItem = edit;
        [self.tableView reloadData];
    }
    else {
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

- (void)saveNewData
{
    UserProfileModel* model = [[Profile sharedUserProfile]getUserProfile];;
    [self updateProfileData:model];
    [[Profile sharedUserProfile]updateUserProfile:model];
}

- (void)setEditedData
{
    UserProfileModel* profileData = [[Profile sharedUserProfile]profileData];
    _editedPicPath = [IVFileLocator getMyProfilePicPath:profileData.localPicPath];
    if(profileData.screenName != nil) {
        _editedName = profileData.screenName;
        NSString *trimmedString = [_editedName stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        NSString *name;
        if(![trimmedString length])
        {
            name = [Common setPlusPrefix:_editedName];
            name = [Common getFormattedNumber:name withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        }else{
            name = _editedName;
        }
        _editedName = name;
    }
    else {
        _editedName = @"";
    }
    
    if(profileData.profileEmailId != nil) {
        _editedEmail = profileData.profileEmailId;
    }
    else {
        _editedEmail = @"";
    }
    
    NSString *gender = profileData.gender;
    if (gender && gender.length > 0) {
        if ([gender caseInsensitiveCompare:FEMALE_TYPE] == NSOrderedSame)
            _editedGender = NSLocalizedString(@"FEMALE", nil);
        else if ([gender caseInsensitiveCompare:MALE_TYPE] == NSOrderedSame)
            _editedGender = NSLocalizedString(@"MALE", nil);
        else
            _editedGender = NSLocalizedString(@"OTHERS", nil);
    } else
        _editedGender = @"N/A";
    
    NSNumber *dateOfBirth = profileData.dob;
    if ([dateOfBirth longLongValue] > 0) {
        NSDate *date = [NSDate dateWithTimeInterval:[dateOfBirth doubleValue] sinceDate:IVDOBreferenceDate];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        _editedDateString = [dateFormatter stringFromDate:date];
        _editedDate = date;
    }
    else {
        _editedDateString=@"N/A";
    }
    
    _editedCountry = profileData.countryName;
    if(_editedCountry == nil)
        _editedCountry = @"";
    
    _editedCountryCode = profileData.countryCode;
    if(_editedCountryCode == nil)
        _editedCountryCode = @"";
    
    _editedCity = profileData.cityName;
    if(_editedCity == nil)
        _editedCity = @"";
    
    _editedState = profileData.stateName;
    if(_editedState == nil)
        _editedState = @"";
}


-(void)checkAndRemoveKeyboard
{
    NSArray* visibleCells = [self.tableView visibleCells];
    for (UITableViewCell* cell in visibleCells){
        if([cell.reuseIdentifier isEqualToString:@"editableField"])
        {
            UITextField* field = [((EditableTextTableViewCell*)cell) fieldValue];
            if([field isFirstResponder])
                [field resignFirstResponder];
        }
    }
}

/** Method to get the country list
 @return Returns the array of country list*/
- (NSMutableArray*)getCountryList
{
    NSMutableArray *fiveCountryList = [Common topFiveCountryList];
    NSMutableDictionary* fifthCountry = [fiveCountryList objectAtIndex:fiveCountryList.count - 1];
    [fifthCountry setValue:[NSNumber numberWithBool:YES] forKey:@"SEPARATOR"];
    NSMutableArray* countryList = [[Setting sharedSetting]getCountryList];
    [fiveCountryList addObjectsFromArray:countryList];
    return fiveCountryList;
}

#pragma mark - Scroll View Delegate Methods -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        // make the profile picture stick to the top of the screen when you pull down further than the scroll view goes
        if (scrollView.contentOffset.y < 0) {
            self.profilePictureImageView.frame = CGRectMake(self.profilePictureImageView.frame.origin.x, scrollView.contentOffset.y / 2, self.profilePictureImageView.frame.size.width, self.profilePictureImageView.frame.size.height);
        } else {
            self.profilePictureImageView.frame = CGRectMake(self.profilePictureImageView.frame.origin.x, scrollView.contentOffset.y / 2, self.profilePictureImageView.frame.size.width, self.profilePictureImageView.frame.size.height);
        }
    }
}

#pragma mark - Action Methods -
-(void)stateBtnAction
{
    NSString* countryCode = _editedCountryCode;
    if(countryCode != nil && [countryCode length]>0)
    {
        [self showProgressBar];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:countryCode forKey:COUNTRY_CODE];
        FetchStatesAPI* api = [[FetchStatesAPI alloc]initWithRequest:nil];
        [api callNetworkRequest:dic withSuccess:^(FetchStatesAPI *req, NSMutableArray *responseObject) {
            [self hideProgressBar];
            if(responseObject != nil && [responseObject count]>0)
            {
                ProfileFieldSelectionTableViewController* svc = [[ProfileFieldSelectionTableViewController alloc]initWithNibName:@"ProfileFieldSelectionTableViewController" bundle:Nil];
                svc.profileFieldTitle = @"Select State";
                svc.profileFieldType = ProfileFieldTypeState;
                svc.profileFieldData = responseObject;
                svc.profileFieldSelectionDelegate = self;
                [self.navigationController pushViewController:svc animated:YES];
            }
            else
            {
                [ScreenUtility showAlertMessage:NSLocalizedString(@"LIST_NOT_FOUND", nil)];
            }
        } failure:^(FetchStatesAPI *req, NSError *error) {
            [self hideProgressBar];
            [ScreenUtility showAlertMessage:NSLocalizedString(@"LIST_NOT_FOUND", nil)];
        }];
        
    }
    else
        [ScreenUtility showAlertMessage:NSLocalizedString(@"ALERT_COUTRY_CODE", nil)];
}

-(void)countryBtnAction
{
    ProfileFieldSelectionTableViewController* svc = [[ProfileFieldSelectionTableViewController alloc]initWithNibName:@"ProfileFieldSelectionTableViewController" bundle:Nil];
    svc.profileFieldTitle = @"Select Country";
    svc.profileFieldType = ProfileFieldTypeCountry;
    svc.profileFieldData = [[Setting sharedSetting]getCountryList];
    svc.topFiveCountryList = [Common topFiveCountryList];
    svc.profileFieldSelectionDelegate = self;
    [self.navigationController pushViewController:svc animated:YES];
    
    //countryIndexData = [Common loadDataAtIndexArray:newCountryList key:COUNTRY_NAME indexArray:indexArray];
}



#pragma mark - ProfileFieldSelectionDelegate -
-(void)profileFieldSelectionViewController:(ProfileFieldSelectionTableViewController *)profileViewController didSelectGender:(NSString *)gender
{
    KLog(@"Gender Selected %@",gender);
    _editedGender = gender;
    [self.tableView reloadData];
}

-(void)profileFieldSelectionViewController:(ProfileFieldSelectionTableViewController *)profileViewController didSelectState:(NSMutableDictionary *)state
{
    KLog(@"State Selected %@",[state valueForKey:@"STATE_NAME"]);
    _editedState = [state valueForKey:@"STATE_NAME"];
    [self.tableView reloadData];
}

-(void)profileFieldSelectionViewController:(ProfileFieldSelectionTableViewController *)profileViewController didSelectCountry:(NSMutableDictionary *)country
{
    KLog(@"State Selected %@",[country valueForKey:@"COUNTRY_NAME"]);
    
    //Start: Nivedita Angadi: Following logic to fix the bug 7951
    if(_editedCountry) {
        if(![_editedCountry isEqualToString: country[@"COUNTRY_NAME"]]) {
            _editedState = @"";
            _editedCity =@"";
        }
    }
    //End
    _editedCountry = [country valueForKey:@"COUNTRY_NAME"];
    _editedCountryCode = [country valueForKey:@"COUNTRY_CODE"];
    [self stateBtnAction];
    [self.tableView reloadData];
}

-(void)editableFieldOfType:(EditableFieldType)type textEntered:(NSString *)text
{
    if(type == EditableFieldTypeName) {
        KLog(@"Name Entered %@",text);
        _editedName = text;
    }
    else if(type == EditableFieldTypeCity) {
        KLog(@"City Entered %@",text);
        _editedCity = text;
    }else if(type == EditableFieldTypeEmail) {
        KLog(@"City Entered %@",text);
        _editedEmail = text;
    }
}


#pragma mark - Imagepicker related Methods -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    BOOL processImage = [IVImageUtility isImageValidForServerUpload:info];
    NSURL *assetURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    NSString *extension = [assetURL pathExtension];
    if(!processImage)
    {
        [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
        [ScreenUtility showAlertMessage:[NSString stringWithFormat:@"Unsupported image type: %@",extension]];
    }
    else
    {
        [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
        int isNetAvailable = [Common isNetworkAvailable];
        if(isNetAvailable == NETWORK_AVAILABLE)
        {
            UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
            //[userPic setImage:image];
            [NSTimer scheduledTimerWithTimeInterval: 0.0f
                                             target: self
                                           selector: @selector(picChanged:)
                                           userInfo: image
                                            repeats: NO];
        }
        else
        {
            //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        }
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Timer Method -
-(void)picChanged:(NSTimer*)timer
{
    UIImage *image = [timer userInfo];
    if(image != nil)
    {
        image = [IVImageUtility fixrotation:image];
        //JAN 27
        NSString* fileName=nil;
        NSString* loginID=nil;
        
        @autoreleasepool { //JAN 27 CMP
            NSData *imageData = UIImagePNGRepresentation(image);
            //AVN_TO_DO
            loginID = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            fileName = [[NSString alloc] initWithFormat:@"%@.%@",loginID,FILETYPE];
            [imageData writeToFile:[IVFileLocator getMyProfilePicPath:fileName] atomically:YES];
        }
        
        [Profile sharedUserProfile].profileData.localPicPath = fileName;
        
        UIImage *cropImg = [IVImageUtility cropImage:image targetSize:[self getCropSize]];
        if(cropImg != nil)
        {
            @autoreleasepool { //JAN 27 CMP
                NSData *cropData = UIImagePNGRepresentation(cropImg);
                NSString* cropFileName = [[NSString alloc] initWithFormat:@"crop%@.%@",loginID,FILETYPE];
                //NSString *cropPath = [IVFileLocator createImageDirectory];
                //cropPath = [cropPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"crop%@.%@",loginID,FILETYPE]];
                [cropData writeToFile:[IVFileLocator getMyProfilePicPath:cropFileName] atomically:YES];
                //[dic setValue:cropPath forKey:CROP_PROFILE_PIC_PATH];
                [Profile sharedUserProfile].profileData.cropProfilePicPath = cropFileName;
            }
        }
        [[Profile sharedUserProfile]writeProfileDataInFile];
        [[Profile sharedUserProfile]uploadProfilePicWithPath:[IVFileLocator getMyProfilePicPath:fileName] fileName:@""];
    }
    [self.tableView reloadData];
}






#pragma mark - DOB work -
-(IBAction)datePickerBtnAction:(id)sender
{
    CGFloat bottomPadding;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        bottomPadding = window.safeAreaInsets.bottom;
    }else{
        bottomPadding = 0.0f;
    }
    _datePickerVisible = YES;
    CGFloat deviceHeight = DEVICE_HEIGHT;
    CGFloat deviceWidth = DEVICE_WIDTH;
    CGFloat pickerViewHeight = 250;
    CGFloat buttonHeight = 34;
    _datePickerView = [[UIView alloc]initWithFrame:CGRectMake(0, deviceHeight - pickerViewHeight - bottomPadding, deviceWidth, pickerViewHeight)];
    _datePickerView.backgroundColor = [UIColor whiteColor];
    
    
    UIButton* setDateButton = [[UIButton alloc]initWithFrame:CGRectMake(0, pickerViewHeight-buttonHeight, deviceWidth/2, buttonHeight)];
    [setDateButton setTitle:@"Set" forState:UIControlStateNormal];
    [setDateButton addTarget:self action:@selector(setDateValue:) forControlEvents:UIControlEventTouchUpInside];
    setDateButton.backgroundColor = [UIColor whiteColor];
    [setDateButton setTitleColor:[IVColors redColor] forState:UIControlStateNormal];
    
    UIButton* cancelDateButton = [[UIButton alloc]initWithFrame:CGRectMake(deviceWidth/2, pickerViewHeight-buttonHeight, deviceWidth/2, buttonHeight)];
    [cancelDateButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelDateButton addTarget:self action:@selector(cancelDateValue:) forControlEvents:UIControlEventTouchUpInside];
    cancelDateButton.backgroundColor = [UIColor whiteColor];
    [cancelDateButton setTitleColor:[IVColors redColor] forState:UIControlStateNormal];
    
    [_datePickerView addSubview:setDateButton];
    [_datePickerView addSubview:cancelDateButton];
    
    datePicker =[[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0,deviceWidth, pickerViewHeight-buttonHeight)];
    datePicker.datePickerMode=UIDatePickerModeDate;
    if(_editedDate)
        datePicker.date = _editedDate;
    else
        datePicker.date=[NSDate date];
    [datePicker setMaximumDate:[NSDate date]];
    //[datePicker addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventValueChanged];
    
    [_datePickerView addSubview:datePicker];
    [self.navigationController.view addSubview:_datePickerView];
}

-(void)setDateValue:(id)sender
{
    NSDate *date = [datePicker date];
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]components:NSCalendarUnitYear fromDate:date toDate:now options:0];
    NSInteger age = [ageComponents year];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger year = [components year];
    NSInteger month=[components month];
    NSInteger refernceYear=1900;
    if(age < 13)
    {
        UIAlertController *alertController =   [UIAlertController
                                                alertControllerWithTitle:nil
                                                message:NSLocalizedString(@"DOB_NOT_VALID", nil)
                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"OK", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];

        
        
        // To fix: 9937
        //[ScreenUtility showAlertMessage:NSLocalizedString(@"DOB_NOT_VALID", nil)];
    }
    else if((year<refernceYear)||((year==refernceYear)&(month<1)))
    {
        
        [ScreenUtility showAlertMessage:@"Birthdate cannot be older than Jan 1900"];
        
    }
    else
    {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        _editedDate = date;
        _editedDateString = [dateFormatter stringFromDate:date];
        
    }
    [self.tableView reloadData];
    _datePickerVisible = NO;
    [_datePickerView removeFromSuperview];
}

-(void)cancelDateValue:(id)sender
{
    _datePickerVisible = NO;
    [_datePickerView removeFromSuperview];
}

-(void)updateProfileData:(UserProfileModel*)model
{
    if([_editedName length] > 0)
    {
        model.screenName = _editedName;
    }
    else
    {
        model.screenName =@"";
    }
    
    if([_editedEmail length] > 0)
    {
        model.profileEmailId = _editedEmail;
    }
    else
    {
        model.profileEmailId =@"";
    }
    
    if([_editedGender isEqualToString:@"Male"])
    {
        model.gender = @"m";
    }
    else if([_editedGender isEqualToString:@"Female"])
    {
        model.gender = @"f";
    }else if([_editedGender isEqualToString:@"Other"])
    {
        model.gender = @"o";
    }
    
    if(_editedDate)
    {
        NSNumber* dobValue = [NSNumber numberWithDouble:[_editedDate timeIntervalSinceDate:IVDOBreferenceDate]];
        model.dob = dobValue;
    }
    
    if(_editedCountry.length)
    {
        model.countryCode = _editedCountryCode;
        model.countryName = _editedCountry;
    }
    else
    {
        model.countryCode = @"";
        model.countryName = @"";
    }
    
    if(_editedState.length)
    {
        model.stateName = _editedState;
    }
    else
    {
        model.stateName = @"";
    }
    
    if(_editedCity != nil && [_editedCity length]>0)
    {
        NSCharacterSet *symbolChars = [NSCharacterSet symbolCharacterSet];
        NSCharacterSet *decimalChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        
        if ([_editedCity rangeOfCharacterFromSet:symbolChars].location == NSNotFound &&
            [_editedCity rangeOfCharacterFromSet:decimalChars].location == NSNotFound ) {
            model.cityName = _editedCity;
        } else {
            [ScreenUtility showAlert:NSLocalizedString(@"SCREENID_LETTERS", nil)];
            _editedCity = model.cityName;
        }
    }
    else
    {
        model.cityName = @"";
    }
}



-(void)fetchProfileCompletedWith:(UserProfileModel*)modelData
{
    [self setEditedData];
    [self.tableView reloadData];
}
-(void)updateProfileCompletedWith:(UserProfileModel*)modelData
{
    if (!self.editing) {
        [[Profile sharedUserProfile]getProfileDataFromServer];//DEC 8, 2016
    }
}

-(void)uploadPicCompletedWithPath:(NSString*)path
{
    [self.tableView reloadData];
}
-(void)downloadPicCompletedWithPath:(NSString*)path
{
    [self.tableView reloadData];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* currentText = textField.text;
    if(currentText.length == 0) {
        //first character can not be space or numeric
        if([string isEqualToString:@" "] || [self isNumeric:string])
            return NO;
    }
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag == eUserNameCell) {
        if (newString.length > 50) {
            [self limitExceedForUsernameAndCity:@"Name should not exceed 50 characters"];
            //[ScreenUtility showAlert:@"Username should not exceed 20 characters"];
            return NO;
        }
        
    }else if (textField.tag == eCitySelectionCell){
        if (newString.length > 32) {
            [self limitExceedForUsernameAndCity:@"City name should not exceed 32 characters"];
            //[ScreenUtility showAlert:@"City name should not exceed 32 characters"];
            return NO;
        }
        
    }
    
    if (range.location == textField.text.length && [string isEqualToString:@" "]) {
        textField.text = [textField.text stringByAppendingString:@"\u00a0"];
        return NO;
    }
    
    return YES;
}

- (void)limitExceedForUsernameAndCity:(NSString *)message
{
    UIAlertController *alertController =   [UIAlertController
                                            alertControllerWithTitle:nil
                                            message:message
                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"OK", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
    [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
}

#pragma mark - ProgressBar
-(void)showProgressBar
{
    if(progressBar == nil) {
        progressBar = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:progressBar];
        [progressBar show:YES];
    }
}

-(void)hideProgressBar
{
    [progressBar hide:YES];
    [progressBar removeFromSuperview];
    progressBar = nil;
}

#pragma mark - Settings Protocol Methods -

-(void)fetchSettingCompletedWith:(SettingModel*)modelData withFetchStatus:(BOOL)withFetchStatus{
    
    
    
}
-(void)updateSettingCompletedWith:(SettingModel*)modelData withUpdateStatus:(BOOL)withUpdateStatus {
    
}

#ifndef REACHME_APP
- (void)fetchPromoImageCompletedWithStatus: (BOOL)withFetchStatus {
    
    if (withFetchStatus) {
        if ([[Setting sharedSetting]shouldShowInAppPromoImage]) {
            [self showInAppPromoImage];
        }
    }
}

- (void)showInAppPromoImage {
    UIStoryboard *friendsStoryBoard = [UIStoryboard storyboardWithName:@"IVFriendsStoryboard" bundle:[NSBundle mainBundle]];
    IVInAppPromoViewController *inAppPromoViewController = [friendsStoryBoard instantiateViewControllerWithIdentifier:@"IVInAppPromoView"];
    inAppPromoViewController.view.frame = [UIScreen mainScreen].bounds;
    inAppPromoViewController.view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [inAppPromoViewController setModalPresentationStyle:UIModalPresentationOverFullScreen];
    [self setModalPresentationStyle:UIModalPresentationOverFullScreen];
    [self.parentViewController presentViewController:inAppPromoViewController animated:NO completion:nil];
}
#endif


@end

