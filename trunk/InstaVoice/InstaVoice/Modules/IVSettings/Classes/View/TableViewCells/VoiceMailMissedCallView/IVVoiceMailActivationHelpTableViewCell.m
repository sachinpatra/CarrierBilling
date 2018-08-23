//
//  IVVoiceMailActivationHelpTableViewCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 24/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVVoiceMailActivationHelpTableViewCell.h"

@implementation IVVoiceMailActivationHelpTableViewCell

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
    self.cellTitleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.cellTitleLabel.frame);
    self.cellSubTitleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.cellSubTitleLabel.frame);
}



- (IBAction)copyButtonTapped:(id)sender {
    if (self.activationHelpTableViewCellDelegate && [self.activationHelpTableViewCellDelegate respondsToSelector:@selector(didTapOnCopyButton)]) {
        [self.activationHelpTableViewCellDelegate didTapOnCopyButton];
    }
}

- (IBAction)getHelpButtonTapped:(id)sender {
    if (self.activationHelpTableViewCellDelegate && [self.activationHelpTableViewCellDelegate respondsToSelector:@selector(didTapOnGetHelpButton)]) {
        [self.activationHelpTableViewCellDelegate didTapOnGetHelpButton];
    }
}

- (IBAction)howToDeactivateButtonTapped:(id)sender {
    if (self.activationHelpTableViewCellDelegate && [self.activationHelpTableViewCellDelegate respondsToSelector:@selector(didTapOnHowToDeactiveButton)]) {
        [self.activationHelpTableViewCellDelegate didTapOnHowToDeactiveButton];
    }

}
- (void)dealloc {
   // NSLog(@"Dealloc of IVVoiceMailActivationHelpTableViewCell");
    self.activationHelpTableViewCellDelegate = nil;
}

@end
