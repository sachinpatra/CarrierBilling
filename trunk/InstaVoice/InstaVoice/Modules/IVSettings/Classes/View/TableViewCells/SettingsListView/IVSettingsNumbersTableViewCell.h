//
//  IVSettingsNumbersTableViewCell.h
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 25/07/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVSettingsNumbersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *viewAllNumbers;
@property (weak, nonatomic) IBOutlet UIButton *addNumberButton;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *verifyNumberButton;
@property (weak, nonatomic) IBOutlet UIButton *infoIconButton;
@property (weak, nonatomic) IBOutlet UIImageView *activeStatus;

#ifdef REACHME_APP
@property (weak, nonatomic) IBOutlet UIButton *changePrimaryNumber;
@property (weak, nonatomic) IBOutlet UIView *flagView;
@property (weak, nonatomic) IBOutlet UILabel *linkedNumberCount;
@property (weak, nonatomic) IBOutlet UILabel *linkedNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *expandColapseImage;
#endif

- (IBAction)verifyNumber:(id)sender;
- (IBAction)infoButton:(id)sender;

@end
