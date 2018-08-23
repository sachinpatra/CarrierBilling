//
//  ConversationTableRingMCSender.m
//  InstaVoice
//
//  Created by Pandian on 27/03/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConversationTableCellRingMCSender.h"
#import "IVColors.h"

@interface ConversationTableCellRingMCSender ()

@property (weak, nonatomic) IBOutlet UIImageView *readReceiptView;
@property (weak, nonatomic) IBOutlet UIImageView *missedCallIconView;
@property (weak, nonatomic) IBOutlet UIButton *callBackButton;

@end

@implementation ConversationTableCellRingMCSender
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    /*
    _mcTitleLabelOutlet.lineBreakMode = NSLineBreakByWordWrapping;
    [_mcTitleLabelOutlet setPreferredMaxLayoutWidth:195];
    
    //DC JUNE 7 2016
    if ([[UIDevice currentDevice]systemVersion].floatValue >= 8.2) {
        //self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, UIEdgeInsetsMake(5, 0, 30, 0));
        //Added by Nivedita - for selected color
        self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, UIEdgeInsetsMake(0, 0, 0, 0));
    }*/
}

-(void)configureCell
{
    self.mcTitleLabelOutlet.text =  [self.dic valueForKey:MSG_CONTENT];
    self.missedCallView.backgroundColor = [IVColors redFillColor];
    self.missedCallView.layer.borderColor = [IVColors redOutlineColor].CGColor;
    self.missedCallView.layer.borderWidth = 1;
    self.missedCallView.layer.cornerRadius = 4;
    
    NSString* msgStatus = [self.dic valueForKey:MSG_STATE];
    NSString *locationString = [self.dic valueForKey:LOCATION_NAME];
    if(!locationString)
        locationString = @"";
    
    NSNumber *theDate = [self.dic valueForKey:MSG_DATE];
    
    // create the tick view
    int tickViewHeight = 18;
    int topOffset = 0;
    int rightOffset = 8;
    UIView* tickView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 28, self.missedCallView.frame.origin.y - topOffset, tickViewHeight, tickViewHeight)];
        tickView.backgroundColor = [UIColor clearColor];
    [tickView setTag:TICK_VIEW_ID];
        
    // create the masking layer for the tick view and apply it
    UIBezierPath *tickShape = [UIBezierPath bezierPath];
    [tickShape moveToPoint:CGPointMake(0, topOffset)];
    [tickShape addLineToPoint:CGPointMake(tickViewHeight, 0)];
    [tickShape addLineToPoint:CGPointMake(rightOffset, tickViewHeight - 4)];
    [tickShape addLineToPoint:CGPointMake(rightOffset , tickViewHeight)];
    [tickShape addLineToPoint:CGPointMake(0, tickViewHeight)];
    [tickShape closePath];
    CAShapeLayer *tickShapeLayer = [CAShapeLayer layer];
    tickShapeLayer.path = tickShape.CGPath;
    tickView.layer.mask = tickShapeLayer;
    
    // create a layer stroked with the actual color we want
    UIBezierPath *tickShapeNotClosed = [UIBezierPath bezierPath];
    [tickShapeNotClosed moveToPoint:CGPointMake(0, topOffset)];
    [tickShapeNotClosed addLineToPoint:CGPointMake(tickViewHeight, 0)];
    [tickShapeNotClosed addLineToPoint:CGPointMake(rightOffset, tickViewHeight - 4)];
    [tickShapeNotClosed addLineToPoint:CGPointMake(rightOffset, tickViewHeight)];
    CAShapeLayer *tickShapeNotClosedLayer = [CAShapeLayer layer];
    tickShapeNotClosedLayer.path = tickShapeNotClosed.CGPath;
    tickShapeNotClosedLayer.lineWidth = 2;
    tickShapeNotClosedLayer.strokeColor = self.missedCallView.layer.borderColor;
    tickShapeNotClosedLayer.fillColor = self.missedCallView.backgroundColor.CGColor;
    [tickView.layer addSublayer:tickShapeNotClosedLayer];
    
    [self.contentView addSubview:tickView];
    
    if([msgStatus isEqualToString:API_NETUNAVAILABLE])
    {
        self.mcTitleLabelOutlet.text = RING_MC_TEXT;
    }
    
    //DEBUG
     //self.mcTitleLabelOutlet.text = RING_MC_ACK_FAILED;
     //self.mcTitleLabelOutlet.text = RING_MC_REQUESTED;
     //self.mcTitleLabelOutlet.text = RING_MC_FAILED;
    //
    
    self.mcTitleLabelOutlet.font = [UIFont systemFontOfSize:17.0];
    //
    
    NSString *theFromPhoneNumber = [Common getFormattedNumber:[self.dic valueForKey:NATIVE_CONTACT_ID] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    NSString *theToPhoneNumber = [Common getFormattedNumber:[self.dic valueForKey:@"FROM_USER_ID"] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    
    //Why from/to will be null. FIXME.
    if(!theToPhoneNumber)
        theToPhoneNumber = @"";
    
    if(!theFromPhoneNumber)
        theFromPhoneNumber = @"";
    
    
    //- set the from user name/number
    self.fromUser.backgroundColor = [UIColor clearColor];
    self.fromUser.textColor = UIColorFromRGB(LOCATION_TEXT);
    if(theFromPhoneNumber.length) {
        NSString *fromUser = [NSString stringWithFormat:@"From: %@                   %@", theFromPhoneNumber,locationString];
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:fromUser];
        
        NSDictionary* theAttributes = @{NSForegroundColorAttributeName: UIColorFromRGB(LOCATION_TEXT),
                                        NSFontAttributeName: [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]};
        [attributedString setAttributes:theAttributes range:[fromUser rangeOfString:theFromPhoneNumber]];
        self.fromUser.attributedText = attributedString;
        self.fromUser.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    }
    
    //- set the to user name/number and location
    if (!locationString.length) {
        locationString = @"";
    }
    self.toUserAndLocation.backgroundColor = [UIColor clearColor];
    self.toUserAndLocation.textColor = UIColorFromRGB(LOCATION_TEXT);
    if(theToPhoneNumber.length) {
        NSString *toUser = [NSString stringWithFormat:@"To: %@", theToPhoneNumber];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:toUser];
        
        NSDictionary *theAttributes = @{NSForegroundColorAttributeName: UIColorFromRGB(TO_USER_TEXT_COLOR),
                                        NSFontAttributeName: [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]};
        [attributedString setAttributes:theAttributes range:[toUser rangeOfString:theToPhoneNumber]];
        self.toUserAndLocation.attributedText = attributedString;
        self.toUserAndLocation.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
        
    }

    //- set up read receipts
    NSString* tickImage = @"";
    
    if ([[self.dic valueForKey:MSG_READ_CNT] intValue] > 0) {
        tickImage = @"double_tick";
    }
    else if([msgStatus isEqualToString:API_DELIVERED]) {
        tickImage = @"single_tick";
    }
    else if([msgStatus isEqualToString:API_NETUNAVAILABLE] || [msgStatus isEqualToString:API_UNSENT]) {
        tickImage = @"failed-msg";
    }
    else {
        tickImage = @"hour-glass";
    }
    
    
    /* TODO DEBUG
    if([msgStatus isEqualToString:API_INPROGRESS] || [msgStatus isEqualToString:API_MSG_REQ_SENT]) {
    }
    else if([msgStatus isEqualToString:API_NETUNAVAILABLE]) {
    }
    else if([msgStatus isEqualToString:API_UNSENT]) {
    }
    else {
    }*/
    
    //- Combine tick mark and time
    NSString* theTimeString = [ScreenUtility dateConverter:theDate dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
    self.timeStamp.textColor = UIColorFromRGB(MSG_TIME_TEXT);
    self.timeStamp.font = [UIFont systemFontOfSize:11.0];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:tickImage];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",theTimeString]];
    [myString insertAttributedString:attachmentString atIndex:0];
    self.timeStamp.attributedText = myString;
    
}

- (IBAction)callIconButtonAction:(id)sender
{
    if([self.delegate isAudioRecording])
        return;
    
    [self.delegate resignTextResponder];
    [Common callWithNumberWithoutPrompt:[self.dic valueForKey:@"FROM_USER_ID"]];
}

@end
