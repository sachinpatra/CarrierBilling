//
//  IVAdditionalActivationInfoCell.m
//  InstaVoice
//
//  Created by Pandian on 27/10/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVAdditionalActivationInfoCell.h"

@implementation IVAdditionalActivationInfoCell

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
    //self.additionalActiInfo.preferredMaxLayoutWidth = CGRectGetWidth(self.additionalActiInfo.frame);
}

- (void)dealloc
{
    
}
@end
