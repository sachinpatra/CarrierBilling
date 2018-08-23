//
//  IVVoiceMailStepsToActivateTableViewCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 24/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVVoiceMailStepsToActivateTableViewCell.h"

@implementation IVVoiceMailStepsToActivateTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
}

- (IBAction)copyButtonTapped:(id)sender {
    if (self.stepsToActicateTableViewCellDelegate && [self.stepsToActicateTableViewCellDelegate respondsToSelector:@selector(didTapOnCopyButton)]) {
        [self.stepsToActicateTableViewCellDelegate didTapOnCopyButton];
    }
}
- (void)dealloc
{
    //NSLog(@"IVVoiceMailStepsToActivateTableViewCell dealloc");
    self.stepsToActicateTableViewCellDelegate = nil; 
}
@end
