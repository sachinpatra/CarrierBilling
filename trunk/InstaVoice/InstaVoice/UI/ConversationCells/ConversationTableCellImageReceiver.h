//
//  ConversationTableCellImageReceiver.h
//  InstaVoice
//
//  Created by adwivedi on 22/07/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ConversationTableCell.h"

@interface ConversationTableCellImageReceiver : ConversationTableCell
@property (weak, nonatomic) IBOutlet UIView *dataView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIImageView *shareImg1;
@property (weak, nonatomic) IBOutlet UIImageView *shareImg2;
@property (weak, nonatomic) IBOutlet UIImageView *shareImg3;
@property (weak, nonatomic) IBOutlet UIImageView *shareImg4;
@property (weak, nonatomic) IBOutlet UIImageView *shareImg5;
@property (weak, nonatomic) IBOutlet UITextView *annotation;
@property (weak, nonatomic) IBOutlet UIButton *buttonOverMainImage;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *graySpinner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareIconViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *fromName;

@end
