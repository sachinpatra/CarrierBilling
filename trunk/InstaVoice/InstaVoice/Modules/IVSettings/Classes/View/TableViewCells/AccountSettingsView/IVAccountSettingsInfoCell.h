//
//  IVAccountSettingsInfoCell.h
//  InstaVoice
//
//  Created by Nivedita Angadi on 19/04/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVAccountSettingsProtocol.h"
@interface IVAccountSettingsInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *primaryPhoneNumberLabel;
@property (nonatomic, weak) id<IVAccountSettingsDelegate> accountSettingsDelegate;
@property (weak, nonatomic) IBOutlet UILabel *primaryNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *changePrimaryNumberButton;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIconImageView;
- (IBAction)changePrimaryNumberButtonTapped:(id)sender;


@end
