//
//  IVVoiceMailActivationHelpTableViewCell.h
//  InstaVoice
//
//  Created by Nivedita Angadi on 24/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVVoiceMailCarrierSelectionProtocol.h"

@interface IVVoiceMailActivationHelpTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellSubTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *howToDeactiveButton;
@property (weak, nonatomic) IBOutlet UIButton *getHelpButton;
@property (weak, nonatomic) IBOutlet UIButton *activationCodeCopyButton;

@property (nonatomic, weak) id<IVVoiceMailCarrierSelectionProtocol> activationHelpTableViewCellDelegate;
- (IBAction)copyButtonTapped:(id)sender;
- (IBAction)getHelpButtonTapped:(id)sender;
- (IBAction)howToDeactivateButtonTapped:(id)sender;

@end
