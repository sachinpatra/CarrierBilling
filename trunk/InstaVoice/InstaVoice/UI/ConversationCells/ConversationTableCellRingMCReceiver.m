//
//  ConversationTableCellRingMCReceiver.m
//  InstaVoice
//
//  Created by Pandian on 28/03/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConversationTableCellRingMCReceiver.h"
#import "IVColors.h"

@interface ConversationTableCellRingMCReceiver ()

@property (weak, nonatomic) IBOutlet UIImageView *missedCallIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *callBackButton;

@end

@implementation ConversationTableCellRingMCReceiver

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
//DC JUNE 13 2016
-(void)layoutSubviews
{
    [super layoutSubviews];
    //DC JUNE 7 2016
    /*
    if ([[UIDevice currentDevice]systemVersion].floatValue >= 8.2) {
        self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, UIEdgeInsetsMake(0, 0, 20, 0));
        Added by Nivedita - for selected color
        self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, UIEdgeInsetsMake(0, 0, 0, 0));
    }*/
}

#pragma mark Receiver cell

-(void)configureCell
{
    NSString* msgContent = [self.dic valueForKey:MSG_CONTENT];
    if(msgContent && [msgContent length])
        self.missedCallTitleLabelOutlet.text = msgContent;
    else
        self.missedCallTitleLabelOutlet.text = RING_MC_TEXT;
    
    self.missedCallTitleLabelOutlet.font = [UIFont systemFontOfSize:17.0];
    
    self.missedCallView.backgroundColor = [IVColors redFillColor];
    self.missedCallView.layer.borderColor = [IVColors redOutlineColor].CGColor;
    self.missedCallView.layer.borderWidth = 1;
    self.missedCallView.layer.cornerRadius = 4;
    
    // the from phone number
    NSString *theFromPhoneNumber = [Common getFormattedNumber:[self.dic valueForKey:@"FROM_USER_ID"] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    // the to phone number
    NSString *theToPhoneNumber = [Common getFormattedNumber:[self.dic valueForKey:NATIVE_CONTACT_ID] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    
    //Why to/from will be null. FIXME.
    if(!theFromPhoneNumber)
        theFromPhoneNumber = @"";
    if(!theToPhoneNumber)
        theToPhoneNumber = @"";
    
    //Set the date/time
    NSNumber *theDate = [self.dic valueForKey:MSG_DATE];
    NSString *theTime = [ScreenUtility dateConverter:theDate dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
    self.timeStamp.text = theTime;
    self.timeStamp.textColor = UIColorFromRGB(MSG_TIME_TEXT);
    self.timeStamp.font = [UIFont systemFontOfSize:11.0];
    
    //Set the from user name/phone number
    self.fromUser.backgroundColor = [UIColor clearColor];
    self.fromUser.textColor = UIColorFromRGB(LOCATION_TEXT);
    NSString* fromUser = [NSString stringWithFormat:@"From: %@", theFromPhoneNumber];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fromUser];
    NSRange fromPhoneRange = [fromUser rangeOfString:theFromPhoneNumber];
    NSDictionary *attributesForPhoneNumbers = @{NSForegroundColorAttributeName: UIColorFromRGB(FROM_USER_TEXT_COLOR),
                                                NSFontAttributeName:
                                                    [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]};
    [attributedString addAttributes:attributesForPhoneNumbers range:fromPhoneRange];
    
    self.fromUser.attributedText = attributedString;
    self.fromUser.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    //DEBUG self.fromUser.layer.borderWidth = 1;
    
    // set the toUser label and location
    self.toUserAndLocation.textColor =  UIColorFromRGB(LOCATION_TEXT);
    self.toUserAndLocation.backgroundColor =  [UIColor clearColor];
    NSString *locationString = [self.dic valueForKey:LOCATION_NAME];
    if(!locationString)
        locationString = @"";
    
    NSString *toUser = [NSString stringWithFormat:@"To: %@  %@", theToPhoneNumber, locationString];
    attributedString = [[NSMutableAttributedString alloc] initWithString:toUser];
    NSRange toPhoneRange = [toUser rangeOfString:theToPhoneNumber];
    
    
    attributesForPhoneNumbers = @{NSForegroundColorAttributeName: UIColorFromRGB(LOCATION_TEXT),
                                                NSFontAttributeName:
                                                [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]};
    
    [attributedString addAttributes:attributesForPhoneNumbers range:toPhoneRange];
    
    self.toUserAndLocation.attributedText = attributedString;
    self.toUserAndLocation.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    
    //DEBUG self.toUser.layer.borderWidth = 1;
    
    
    int tickViewHeight = 16;
    int topOffset = 0;
    int rightOffset = tickViewHeight - 6;
    
    UIView* tickView = [[UIView alloc] initWithFrame:CGRectMake(self.missedCallView.frame.origin.x - rightOffset, self.missedCallView.frame.origin.y - topOffset, tickViewHeight, tickViewHeight)];
    [tickView setTag:TICK_VIEW_ID];
    
    // create the masking layer for the tick view and apply it
    UIBezierPath *tickShape = [UIBezierPath bezierPath];
    [tickShape moveToPoint:CGPointMake(tickViewHeight, topOffset)];
    [tickShape addLineToPoint:CGPointMake(topOffset, 0)];
    [tickShape addLineToPoint:CGPointMake(rightOffset, tickViewHeight - 4)];
    [tickShape addLineToPoint:CGPointMake(rightOffset, tickViewHeight)];
    
    [tickShape closePath];
    CAShapeLayer *tickShapeLayer = [CAShapeLayer layer];
    tickShapeLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
    tickShapeLayer.path = tickShape.CGPath;
    tickView.layer.mask = tickShapeLayer;
    
    // create a layer stroked with the actual color we want
    UIBezierPath *tickShapeNotClosed = [UIBezierPath bezierPath];
    [tickShapeNotClosed moveToPoint:CGPointMake(tickViewHeight, topOffset)];
    [tickShapeNotClosed addLineToPoint:CGPointMake(topOffset, 0)];
    [tickShapeNotClosed addLineToPoint:CGPointMake(rightOffset, tickViewHeight - 4)];
    [tickShapeNotClosed addLineToPoint:CGPointMake(rightOffset, tickViewHeight)];
    CAShapeLayer *tickShapeNotClosedLayer = [CAShapeLayer layer];
    tickShapeNotClosedLayer.path = tickShapeNotClosed.CGPath;
    tickShapeNotClosedLayer.lineWidth = 2;
    
    tickShapeNotClosedLayer.strokeColor = [IVColors redOutlineColor].CGColor;
    tickShapeNotClosedLayer.fillColor = [IVColors redFillColor].CGColor;
    
    [tickView.layer addSublayer:tickShapeNotClosedLayer];
    tickView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:tickView];
}

- (IBAction)callIconButtonAction:(id)sender
{
    if([self.delegate isAudioRecording])
        return;
    
    [self.delegate resignTextResponder];
    [Common callWithNumber:[self.dic valueForKey:@"FROM_USER_ID"]];
}

@end
