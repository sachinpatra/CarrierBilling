//
//  ConversationTableCellImageSender.h
//  InstaVoice
//
//  Created by adwivedi on 22/07/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ConversationTableCell.h"

@interface ConversationTableCellImageSender : ConversationTableCell

@property (strong, nonatomic) IBOutlet UILabel *location;
@property (strong, nonatomic) IBOutlet UIImageView *likeImage;
@property (strong, nonatomic) IBOutlet UIView *dataView;
@property (strong, nonatomic) IBOutlet UIImageView *mainImage;
@property (strong, nonatomic) IBOutlet UIImageView *shareImg1;
@property (strong, nonatomic) IBOutlet UIImageView *shareImg2;
@property (strong, nonatomic) IBOutlet UIImageView *shareImg3;
@property (strong, nonatomic) IBOutlet UIImageView *shareImg4;
@property (strong, nonatomic) IBOutlet UIImageView *shareImg5;
@property (weak, nonatomic) IBOutlet UIImageView *shareImg6;
@property (strong, nonatomic) IBOutlet UITextView *annotation;
@property (strong, nonatomic) IBOutlet UIButton *buttonOverMainImage;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *graySpinner;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *shareIconViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;

@end
