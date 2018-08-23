//
//  IVVoiceMailGetHelpTableViewCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 24/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVVoiceMailGetHelpTableViewCell.h"
@implementation IVVoiceMailGetHelpTableViewCell

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
    self.cellTitleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.cellTitleLabel.frame);  //[self.detailsTextLabel sizeToFit];
}


- (IBAction)getHelpButtonTapped:(id)sender {

    if (self.getHelpTableViewCellDelegate && [self.getHelpTableViewCellDelegate respondsToSelector:@selector(didTapOnGetHelpButton)]) {
        [self.getHelpTableViewCellDelegate didTapOnGetHelpButton];
        
    }
    
}

- (IBAction)howToDeactiveButtonTapped:(id)sender {

    if (self.getHelpTableViewCellDelegate && [self.getHelpTableViewCellDelegate respondsToSelector:@selector(didTapOnHowToDeactiveButton)]) {
        [self.getHelpTableViewCellDelegate didTapOnHowToDeactiveButton];
        
    }
}
- (void)dealloc {
   // NSLog(@"IVVoicemailGetHelpTableViewCell dealloc");
    self.getHelpTableViewCellDelegate = nil; 
}
@end
