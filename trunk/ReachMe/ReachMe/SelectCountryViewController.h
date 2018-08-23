//
//  SelectCountryViewController.h
//  ReachMe
//
//  Created by Bhaskar Munireddy on 19/07/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectCountryViewController;

@protocol SelectCountryViewControllerDelegate <NSObject>
@optional
-(void)countrySelection:(SelectCountryViewController*)countrySelected didSelectCountry:(NSMutableDictionary*)country;
@end

@interface SelectCountryViewController : UIViewController
@property NSMutableArray* profileFieldData;
@property NSMutableArray* topFiveCountryList;
@property id<SelectCountryViewControllerDelegate> countrySelectionDelegate;
@end
