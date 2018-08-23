//
//  IVAccountSettingsInfoCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 19/04/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVAccountSettingsInfoCell.h"

@implementation IVAccountSettingsInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)changePrimaryNumberButtonTapped:(id)sender {
    if (self.accountSettingsDelegate && [self.accountSettingsDelegate respondsToSelector:@selector(didTapOnChangePrimaryNumberButton)]) {
        [self.accountSettingsDelegate didTapOnChangePrimaryNumberButton];
    }
}
@end
