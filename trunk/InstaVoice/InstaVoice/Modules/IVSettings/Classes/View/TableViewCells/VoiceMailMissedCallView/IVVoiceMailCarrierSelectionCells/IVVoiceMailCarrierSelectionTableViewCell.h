//
//  IVVoiceMailCarrierSelectionTableViewCell.h
//  InstaVoice
//
//  Created by Nivedita Angadi on 19/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVVoiceMailCarrierSelectionProtocol.h"

@interface IVVoiceMailCarrierSelectionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *carrierSelectionButton;
@property (weak, nonatomic) IBOutlet UILabel *carrierLabel;
@property (weak, nonatomic) IBOutlet UILabel *additionalInfo;
@property (nonatomic, weak) id<IVVoiceMailCarrierSelectionProtocol> voiceMailCarrierSelectionDelegate; 
@end
