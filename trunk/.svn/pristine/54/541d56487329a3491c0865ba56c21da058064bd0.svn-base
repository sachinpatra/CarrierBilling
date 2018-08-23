//
//  IVInstaVoiceInfoTableViewCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 16/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVInstaVoiceInfoTableViewCell.h"

@interface IVInstaVoiceInfoTableViewCell()

@end

@implementation IVInstaVoiceInfoTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)updateButtonAction:(id)sender {
    NSString *iTunesLink = @"";
#ifdef REACHME_APP
    iTunesLink = @"https://itunes.apple.com/us/app/instavoice-reachme/id1345352747?mt=8";
#else
    iTunesLink = @"https://itunes.apple.com/us/app/instavoice-visual-voicemail-missed-call-alerts/id821541731?mt=8";
#endif
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

/*
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.versionNumberLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.versionNumberLabel.frame);
}
*/
@end
