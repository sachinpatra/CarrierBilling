//
//  CallingRatesTableViewCell.h
//  ReachMe
//
//  Created by Bhaskar Munireddy on 29/06/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallingRatesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *callingRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryCode;
@property (weak, nonatomic) IBOutlet UILabel *countryName;
-(void)configureCountryCell:(NSMutableDictionary*)country;
@end
