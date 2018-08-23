//
//  IVAccountSettingsManageAccountTableViewCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 02/05/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVAccountSettingsManageAccountTableViewCell.h"

@implementation IVAccountSettingsManageAccountTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.processDataButton.layer.cornerRadius = 4.0;
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)infoButtonTapped:(id)sender {

    if (self.accountSettingsDelegate && [self.accountSettingsDelegate respondsToSelector:@selector(didTapOnInfoButton)]) {
        [self.accountSettingsDelegate didTapOnInfoButton];
        
    }

}

- (IBAction)processDataButtonTapped:(id)sender {
    if (self.accountSettingsDelegate && [self.accountSettingsDelegate respondsToSelector:@selector(didTapOnProcessDataButtonWithTag:)]) {
        [self.accountSettingsDelegate didTapOnProcessDataButtonWithTag:[sender tag]];
        
    }
}
@end
