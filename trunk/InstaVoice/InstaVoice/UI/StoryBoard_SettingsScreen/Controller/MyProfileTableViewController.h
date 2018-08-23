//
//  MyProfileViewController.h
//  InstaVoice
//
//  Created by adwivedi on 09/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
#import "UserProfileModel.h"

#define COUNTRY_FLAG    @"flag"
#define FILETYPE        @"png"
#define DATE_FORMATE    @"dd-MMM-yyyy"
#pragma mark COLOR CODE

#define COLORE53_255 53/255.0
#define COLOR100_255 100/255.0
#define COLOR105_255 105/255.0
#define COLOR141_255 141/255.0
#define COLOR185_255 185/255.0
#define COLOR186_255 186/255.0
#define COLOR220_255 220/255.0
#define COLOR230_255 230/255.0
#define COLOR231_255 231/255.0

@interface MyProfileTableViewController : UITableViewController
{
    UIImagePickerController *imagePickerViewController;
    UIDatePicker *datePicker;
    BOOL _fetchSettingFromServer;
    UserProfileModel* _editedProfileData;
    MBProgressHUD *progressBar;
    
    UIView* _datePickerView;
    BOOL _datePickerVisible;
    
    NSString* _editedPicPath;
    NSString* _editedName;
    NSString* _editedEmail;
    NSString* _editedGender;
    NSDate* _editedDate;
    NSString* _editedDateString;
    NSString* _editedCountry;
    NSString* _editedState;
    NSString* _editedCity;
    NSString* _editedCountryCode;
}

@end
