//
//  ProfileFieldSelectionTableViewController.h
//  InstaVoice
//
//  Created by adwivedi on 24/08/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileFieldSelectionTableViewController;

@protocol ProfileFieldSelectionDelegate <NSObject>
@optional
-(void)profileFieldSelectionViewController:(ProfileFieldSelectionTableViewController*)profileViewController didSelectGender:(NSString*)gender;
-(void)profileFieldSelectionViewController:(ProfileFieldSelectionTableViewController*)profileViewController didSelectCountry:(NSMutableDictionary*)country;
-(void)profileFieldSelectionViewController:(ProfileFieldSelectionTableViewController*)profileViewController didSelectState:(NSMutableDictionary*)state;
@end

typedef enum : NSInteger {
    ProfileFieldTypeGender,
    ProfileFieldTypeState,
    ProfileFieldTypeCountry
} ProfileFieldType;

@interface ProfileFieldSelectionTableViewController : UITableViewController
@property ProfileFieldType profileFieldType;
@property NSMutableArray* profileFieldData;
@property NSMutableArray* topFiveCountryList;
@property NSString* profileFieldTitle;
@property id<ProfileFieldSelectionDelegate> profileFieldSelectionDelegate;
@end
