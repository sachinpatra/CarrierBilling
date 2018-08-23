//
//  IVVoiceMailInstructionTableViewCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 19/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVVoiceMailInstructionTableViewCell.h"

@implementation IVVoiceMailInstructionTableViewCell

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
    self.enabledStatusLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.enabledStatusLabel.frame);
    self.detailsTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.detailsTextLabel.frame);  //[self.detailsTextLabel sizeToFit];
}


- (IBAction)getInTouchButtonTapped:(id)sender {
    
    if(self.voiceMailCarrierSelectionDelegate && [self.voiceMailCarrierSelectionDelegate respondsToSelector:@selector(didTapOnGetInTouchButton)])
       [self.voiceMailCarrierSelectionDelegate didTapOnGetInTouchButton];
    
}
- (void)dealloc
{
    //NSLog(@"IVVoiceMailInstructionTableViewCell dealloc");
    self.voiceMailCarrierSelectionDelegate = nil; 
}
@end
