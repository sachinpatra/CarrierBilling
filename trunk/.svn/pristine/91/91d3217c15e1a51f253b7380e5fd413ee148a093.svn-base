//
//  IVVoiceMailGreetingTableViewCell.h
//  InstaVoice
//
//  Created by Nivedita Angadi on 24/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVVoiceMailCarrierSelectionProtocol.h"
@interface IVVoiceMailGreetingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailIdCopyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *emailVerificationStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *unverifiedLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailIdCopyWidthConstraints;

@property (nonatomic, weak) id<IVVoiceMailCarrierSelectionProtocol> voiceMailGreetingCellDelegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unverifiedLabelWidthConstraints;

- (IBAction)editButtonTapped:(id)sender;
- (IBAction)infoButtonTapped:(id)sender;

@end
