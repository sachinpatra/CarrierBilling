//
//  IVVoiceMailGreetingsRecordTableViewCell.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 10/03/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVVoiceMailGreetingsRecordTableViewCell.h"

@implementation IVVoiceMailGreetingsRecordTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.recordDetailsLabel sizeToFit];
    [self.recordingLabel sizeToFit];
    [self.titleLabel sizeToFit];
    [self layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.recordDetailsLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.recordDetailsLabel.frame);
    

}

- (IBAction)cancelRecordButtonTapped:(id)sender {
    if (self.greetingsRecordTableViewCellDelegate && [self.greetingsRecordTableViewCellDelegate respondsToSelector:@selector(didTapOnCancelRecordButtonWithTag:)]) {
        [self.greetingsRecordTableViewCellDelegate didTapOnCancelRecordButtonWithTag:[sender tag]];
    }
}

- (IBAction)recordButtonTapped:(id)sender {
    if (self.greetingsRecordTableViewCellDelegate && [self.greetingsRecordTableViewCellDelegate respondsToSelector:@selector(didTapOnRecordButtonWithTag:)]) {
        [self.greetingsRecordTableViewCellDelegate didTapOnRecordButtonWithTag:[sender tag]];
    }
}

- (IBAction)playRecordingButtonTapped:(id)sender {
    
    if (self.greetingsRecordTableViewCellDelegate && [self.greetingsRecordTableViewCellDelegate respondsToSelector:@selector(didTapOnPlayRecordingButton:)]) {
        [self.greetingsRecordTableViewCellDelegate didTapOnPlayRecordingButton:sender];
    }

}

- (IBAction)valueChanged:(id)sender {
    if (self.greetingsRecordTableViewCellDelegate && [self.greetingsRecordTableViewCellDelegate respondsToSelector:@selector(changedSliderPosition:)]) {
        [self.greetingsRecordTableViewCellDelegate changedSliderPosition:sender];
    }
}

- (IBAction)touchOutSide:(id)sender {
    if (self.greetingsRecordTableViewCellDelegate && [self.greetingsRecordTableViewCellDelegate respondsToSelector:@selector(touchUpOutside:)]) {
        [self.greetingsRecordTableViewCellDelegate touchUpOutside:sender];
    }
}

- (IBAction)touchInSide:(id)sender {
    if (self.greetingsRecordTableViewCellDelegate && [self.greetingsRecordTableViewCellDelegate respondsToSelector:@selector(touchUpInside:)]) {
        [self.greetingsRecordTableViewCellDelegate touchUpInside:sender];
    }
}

- (IBAction)dragOutSide:(id)sender {
    if (self.greetingsRecordTableViewCellDelegate && [self.greetingsRecordTableViewCellDelegate respondsToSelector:@selector(sliderDragOutside:)]) {
        [self.greetingsRecordTableViewCellDelegate sliderDragOutside:sender];
    }
}

- (IBAction)dragInside:(id)sender {
    if (self.greetingsRecordTableViewCellDelegate && [self.greetingsRecordTableViewCellDelegate respondsToSelector:@selector(sliderDragInside:)]) {
        [self.greetingsRecordTableViewCellDelegate sliderDragInside:sender];
    }
}

- (IBAction)touchCancel:(id)sender {
    if (self.greetingsRecordTableViewCellDelegate && [self.greetingsRecordTableViewCellDelegate respondsToSelector:@selector(touchCancel:)]) {
        [self.greetingsRecordTableViewCellDelegate touchCancel:sender];
    }
}

- (void)dealloc {
    // NSLog(@"IVVoiceMailGreetingsRecordTableViewCell dealloc");
    self.greetingsRecordTableViewCellDelegate = nil;
}

@end
