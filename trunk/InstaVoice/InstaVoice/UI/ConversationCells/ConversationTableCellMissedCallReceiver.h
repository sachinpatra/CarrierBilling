//
//  ConversationTableCellMissedCallReceiver.h
//  InstaVoice
//
//  Created by Jatin Mitruka on 5/13/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//
#import "ConversationTableCell.h"

@interface ConversationTableCellMissedCallReceiver : ConversationTableCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callArrowLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *toLabel;

@property (weak, nonatomic) IBOutlet UIView *missedCallView;
@property (weak, nonatomic) IBOutlet UIImageView *mcImageView;
@property (weak, nonatomic) IBOutlet UITextView *mcTextview;
@property (weak, nonatomic) IBOutlet UIButton *expandButtonOutlet;
@property (weak, nonatomic) IBOutlet UILabel *timeAndLocationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *missedCallViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *fromUserNumberButtonOutlet;
@property (weak, nonatomic) IBOutlet UILabel *missedCallTitleLabelOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mcTextViewHeightConstraint;

- (IBAction)callIconButtonAction:(id)sender;
- (IBAction)expandButtonAction:(id)sender;
- (IBAction)fromUserNumberButtonAction:(id)sender;

@end

