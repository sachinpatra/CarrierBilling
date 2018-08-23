//
//  IVVoiceMailInstructionTableViewCell.h
//  InstaVoice
//
//  Created by Nivedita Angadi on 19/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVVoiceMailCarrierSelectionProtocol.h"
@interface IVVoiceMailInstructionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ivIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *enabledStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *getInTouchButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacePhLabelAndGetInTouchButton;

@property (nonatomic, weak) id<IVVoiceMailCarrierSelectionProtocol> voiceMailCarrierSelectionDelegate;

- (IBAction)getInTouchButtonTapped:(id)sender;

@end
