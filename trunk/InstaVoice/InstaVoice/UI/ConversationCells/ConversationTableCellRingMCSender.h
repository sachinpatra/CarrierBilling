//
//  NSObject_ConversationTableCellRingMCSender.h
//  InstaVoice
//
//  Created by Pandian on 27/03/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConversationTableCell.h"

@interface ConversationTableCellRingMCSender : ConversationTableCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mcTitleTopConstraint;

@property (weak, nonatomic) IBOutlet UIView *missedCallView;
@property (weak, nonatomic) IBOutlet UILabel *mcTitleLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *fromUser;
@property (weak, nonatomic) IBOutlet UIButton *toUserNumberButtonOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mcViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mcTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toUserNumberButtonWidth;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UILabel *toUserAndLocation;


- (IBAction)callIconButtonAction:(id)sender;
@end
