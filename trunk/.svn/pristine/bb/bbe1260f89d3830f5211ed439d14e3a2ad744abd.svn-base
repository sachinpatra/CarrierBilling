//
//  IVVoiceMailEmailNotificationTableViewCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 24/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVVoiceMailEmailNotificationTableViewCell.h"

@implementation IVVoiceMailEmailNotificationTableViewCell
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);

}

- (IBAction)notificationSwitchValueHasChanged:(id)sender {
    
    UISwitch *notificationSwitch = (UISwitch *)sender;
    if (self.emailNotificationTableViewCellDelegate && [self.emailNotificationTableViewCellDelegate respondsToSelector:@selector(didChangedNotificationSwitchValue:withSwitchTag:)]) {
        [self.emailNotificationTableViewCellDelegate didChangedNotificationSwitchValue:notificationSwitch.on  withSwitchTag:notificationSwitch.tag];
    }
}

- (IBAction)editOrAddEmailAction:(id)sender {
    
    if (self.emailNotificationTableViewCellDelegate && [self.emailNotificationTableViewCellDelegate respondsToSelector:@selector(didTapOnEditMailButton)])
        [self.emailNotificationTableViewCellDelegate didTapOnEditMailButton];
    
}

- (void)dealloc {
    //NSLog(@"IVVoiceMailEmailNotificationTableViewCell dealloc");
    self.emailNotificationTableViewCellDelegate = nil; 
}
@end
