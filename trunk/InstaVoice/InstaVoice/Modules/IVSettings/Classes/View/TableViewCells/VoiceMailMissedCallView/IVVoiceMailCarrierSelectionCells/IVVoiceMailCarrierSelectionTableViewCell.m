//
//  IVVoiceMailCarrierSelectionTableViewCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 19/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVVoiceMailCarrierSelectionTableViewCell.h"

@implementation IVVoiceMailCarrierSelectionTableViewCell

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
    self.carrierLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.carrierLabel.frame);
}

- (IBAction)selectYourCarrierButtonTapped:(id)sender {
    if (self.voiceMailCarrierSelectionDelegate && [self.voiceMailCarrierSelectionDelegate respondsToSelector:@selector(didTapOnSelectYourCarrierButton)])
       [self.voiceMailCarrierSelectionDelegate didTapOnSelectYourCarrierButton];
}

- (void)dealloc
{
   // NSLog(@"IVVoiceMailCarrierSelectionTableViewCell dealloc");
    self.voiceMailCarrierSelectionDelegate = nil;
    
}
@end
