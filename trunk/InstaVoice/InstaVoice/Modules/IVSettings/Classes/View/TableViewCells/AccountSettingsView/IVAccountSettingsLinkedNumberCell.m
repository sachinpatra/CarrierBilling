//
//  IVAccountSettingsLinkedNumberCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 02/05/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVAccountSettingsLinkedNumberCell.h"

@implementation IVAccountSettingsLinkedNumberCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)verifyButtonTapped:(id)sender {
    
    if (self.ivAccountSettingsDelegate && [self.ivAccountSettingsDelegate respondsToSelector:@selector(didTapOnVerifyLinkedNumberButtonInRow:)]) {
        [self.ivAccountSettingsDelegate didTapOnVerifyLinkedNumberButtonInRow:[sender tag]];
    }
}

- (IBAction)deleteLinkedNumberButtonTapped:(id)sender {
    if (self.ivAccountSettingsDelegate && [self.ivAccountSettingsDelegate respondsToSelector:@selector(didTapOnDeleteLinkedNumberButtonInRow:)]) {
        [self.ivAccountSettingsDelegate didTapOnDeleteLinkedNumberButtonInRow:[sender tag]];
    }
}
- (IBAction)addLinkedNumberButtonTapped:(id)sender {
    if (self.ivAccountSettingsDelegate && [self.ivAccountSettingsDelegate respondsToSelector:@selector(didTapOnAddLinkedNumberButton)]) {
        [self.ivAccountSettingsDelegate didTapOnAddLinkedNumberButton];
    }

}
@end
