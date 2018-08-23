//
//  IVVoiceMailUnsupportedInstructionCell.h
//  InstaVoice
//
//  Created by Pandian on 17/11/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IVVoiceMailCarrierSelectionProtocol.h"
@interface IVVoiceMailUnsupportedInstructionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ivIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *enabledStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *getInTouchButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacePhLabelAndGetInTouchButton;
@property (weak, nonatomic) IBOutlet UIView *alertView;

@property (nonatomic, weak) id<IVVoiceMailCarrierSelectionProtocol> voiceMailCarrierSelectionDelegate;

- (IBAction)getInTouchButtonTapped:(id)sender;

@end