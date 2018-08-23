//
//  IVVoiceMailSuccessfullyActivatedTableViewCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 24/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVVoiceMailSuccessfullyActivatedTableViewCell.h"

@implementation IVVoiceMailSuccessfullyActivatedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
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
    self.missedAndVoiceMailCountLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.missedAndVoiceMailCountLabel.frame);
}

@end
