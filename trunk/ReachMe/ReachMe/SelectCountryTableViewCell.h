//
//  SelectCountryTableViewCell.h
//  ReachMe
//
//  Created by Bhaskar Munireddy on 19/07/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectCountryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *countryCode;
@property (weak, nonatomic) IBOutlet UILabel *countryName;
-(void)configureCountryCell:(NSMutableDictionary*)country;
@end
