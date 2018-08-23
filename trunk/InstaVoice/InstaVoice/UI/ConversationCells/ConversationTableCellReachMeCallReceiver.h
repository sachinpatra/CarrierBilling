//
//  ConversationTableCellReachMeCallReceiver.h
//  InstaVoice
//
//  Created by Pandian on 8/7/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "ConversationTableCell.h"

@interface ConversationTableCellReachMeCallReceiver : ConversationTableCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callArrowLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *toLabel;

@property (weak, nonatomic) IBOutlet UIView *missedCallView;
@property (weak, nonatomic) IBOutlet UIImageView *mcImageView;
//CMP @property (weak, nonatomic) IBOutlet UITextView *mcTextview;
//@property (weak, nonatomic) IBOutlet UIButton *expandButtonOutlet;
@property (weak, nonatomic) IBOutlet UILabel *timeAndLocationLabel;
//CMP @property (weak, nonatomic) IBOutlet NSLayoutConstraint *missedCallViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *fromUserNumberButtonOutlet;
@property (weak, nonatomic) IBOutlet UILabel *missedCallTitleLabelOutlet;
//CMP @property (weak, nonatomic) IBOutlet NSLayoutConstraint *mcTextViewHeightConstraint;
//@property (weak, nonatomic) IBOutlet UILabel *labelReachMe;
@property (weak, nonatomic) IBOutlet UILabel *labelDuration;

- (IBAction)callIconButtonAction:(id)sender;
- (IBAction)fromUserNumberButtonAction:(id)sender;

@end
