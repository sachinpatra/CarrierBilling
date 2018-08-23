//
//  ProfileFieldSelectionTableViewCell.h
//  InstaVoice
//
//  Created by adwivedi on 24/08/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileFieldSelectionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *countryCode;
@property (weak, nonatomic) IBOutlet UILabel *countryName;

-(void)configureCountryCell:(NSMutableDictionary*)country;
@end
