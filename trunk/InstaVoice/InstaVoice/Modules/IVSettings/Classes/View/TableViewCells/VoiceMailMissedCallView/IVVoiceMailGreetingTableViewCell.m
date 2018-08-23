//
//  IVVoiceMailGreetingTableViewCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 24/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVVoiceMailGreetingTableViewCell.h"

@implementation IVVoiceMailGreetingTableViewCell

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
}

- (IBAction)editButtonTapped:(id)sender {
    if (self.voiceMailGreetingCellDelegate && [self.voiceMailGreetingCellDelegate respondsToSelector:@selector(didTapOnEditMailButton)])
        [self.voiceMailGreetingCellDelegate didTapOnEditMailButton];
}

- (IBAction)infoButtonTapped:(id)sender {
    if (self.voiceMailGreetingCellDelegate && [self.voiceMailGreetingCellDelegate respondsToSelector:@selector(didTapOnInfoButton)])
        [self.voiceMailGreetingCellDelegate didTapOnInfoButton];
}
@end
