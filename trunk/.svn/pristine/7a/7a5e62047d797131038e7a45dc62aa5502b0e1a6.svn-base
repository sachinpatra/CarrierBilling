//
//  IVVoiceMailEmailNotificationTableViewCell.h
//  InstaVoice
//
//  Created by Nivedita Angadi on 24/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVVoiceMailCarrierSelectionProtocol.h"

@interface IVVoiceMailEmailNotificationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UIButton *addEmailAddress;
@property (weak, nonatomic) IBOutlet UILabel *emailTimeZone;

@property (nonatomic, weak) id<IVVoiceMailCarrierSelectionProtocol> emailNotificationTableViewCellDelegate;
- (IBAction)notificationSwitchValueHasChanged:(id)sender;
- (IBAction)editOrAddEmailAction:(id)sender;

@end
