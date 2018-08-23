//
//  ConversationTableCellRingMCReceiver.h
//  InstaVoice
//
//  Created by Pandian on 28/03/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "ConversationTableCell.h"

@interface ConversationTableCellRingMCReceiver : ConversationTableCell

@property (weak, nonatomic) IBOutlet UIView *missedCallView;
@property (weak, nonatomic) IBOutlet UILabel *missedCallTitleLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UILabel *fromUser;
@property (weak, nonatomic) IBOutlet UILabel *toUserAndLocation;

- (IBAction)callIconButtonAction:(id)sender;

@end
