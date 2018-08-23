//
//  IVVoiceMailStepsToActivateTableViewCell.h
//  InstaVoice
//
//  Created by Nivedita Angadi on 24/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVVoiceMailCarrierSelectionProtocol.h"

@interface IVVoiceMailStepsToActivateTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *activationNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *numberCopyButton;
@property (weak, nonatomic) id<IVVoiceMailCarrierSelectionProtocol> stepsToActicateTableViewCellDelegate;

- (IBAction)copyButtonTapped:(id)sender;

@end
