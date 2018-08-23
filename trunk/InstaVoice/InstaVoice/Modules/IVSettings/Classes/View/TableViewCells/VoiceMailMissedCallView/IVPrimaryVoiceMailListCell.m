//
//  IVPrimaryVoiceMailListCell.m
//  InstaVoice
//
//  Created by Pandian on 18/11/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IVPrimaryVoiceMailListCell.h"

@implementation IVPrimaryVoiceMailListCell

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
    self.phoneNumberLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.phoneNumberLabel.frame);
}

@end
