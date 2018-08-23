//
//  ReachMeStatusTableViewCell.h
//  ReachMe
//
//  Created by Bhaskar Munireddy on 11/07/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReachMeStatusTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *reachMeIcon;
@property (weak, nonatomic) IBOutlet UIImageView *homeIcon;
@property (weak, nonatomic) IBOutlet UIImageView *internationalIcon;
@property (weak, nonatomic) IBOutlet UIImageView *callIcon;
@property (weak, nonatomic) IBOutlet UILabel *primaryNumber;
@property (weak, nonatomic) IBOutlet UILabel *carrierName;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *tagName;
@property (weak, nonatomic) IBOutlet UIImageView *countryFlag;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end
