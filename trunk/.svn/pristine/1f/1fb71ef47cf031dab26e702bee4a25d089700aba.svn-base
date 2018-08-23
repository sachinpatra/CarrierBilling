//
//  ConversationTableCellReachMeCallSender.m
//  ReachMe
//
//  Created by Pandian on 30/05/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConversationTableCellReachMeCallSender.h"
#import "IVColors.h"

@interface ConversationTableCellReachMeCallSender (){
    BOOL isCallListExpanded;
}
@property (weak, nonatomic) IBOutlet UIImageView *readReceipt;
@property (weak, nonatomic) IBOutlet UIImageView *missedCallIconView;
@property (weak, nonatomic) IBOutlet UIButton *callBackButton;

@end

@implementation ConversationTableCellReachMeCallSender
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
#pragma mark ChatView Sender/Receiver cell

//Setting for Left(Receiver) side conversation of chatView
-(void)configureCell
{
    int duration =  [[self.dic valueForKey:DURATION]intValue];
    NSString* status = [self.dic valueForKey:MSG_CONTENT];
    int min=0,seconds=0;
    if(duration>0) {
        min = duration/60;
        seconds = duration - min*60;
    }
    
    NSString* sDuration = [NSString stringWithFormat:@"%dm %ds",min,seconds];
    if([status isEqualToString:VOIP_CALL_CANCELED])
        sDuration = VOIP_CALL_CANCELED;
    self.labelDuration.text = sDuration;
    self.labelDuration.textColor = UIColorFromRGB(MSG_TIME_TEXT);
    self.labelDuration.font = [UIFont systemFontOfSize:12.0];
    
    /* REMOVE
    NSString* msgSubType = [self.dic valueForKey:MSG_SUB_TYPE];
    if([msgSubType isEqualToString:VOIP_TYPE])
        self.labelReachMe.text = @"Free";
    else
        self.labelReachMe.text = @"Paid";
    
    self.labelReachMe.layer.borderWidth = 1;
    self.labelReachMe.layer.masksToBounds = YES;
    self.labelReachMe.layer.cornerRadius = 12;
    self.labelReachMe.layer.borderColor = [UIColor darkGrayColor].CGColor;
    */
    
    [_missedCallTitleLabelOutlet setFont:[Common preferredFontForTextStyleInApp:UIFontTextStyleBody]];
    _missedCallTitleLabelOutlet.text = @"Outgoing";
    
    self.mcImageView.backgroundColor = [IVColors blueFillColor];
    self.mcImageView.layer.borderColor = [IVColors blueOutlineColor].CGColor;
    self.mcImageView.layer.borderWidth = 1;
    self.mcImageView.image = nil;
    self.mcImageView.layer.cornerRadius = 4;
    
    
    //Get To and From user name
    NSString *fromNumber = [self.dic valueForKey:NATIVE_CONTACT_ID];
    NSString *theFromPhoneNumber = [Common getFormattedNumber:fromNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    NSString *toNumber = [self.dic valueForKey:@"FROM_USER_ID"];
    NSString *theToPhoneNumber = [Common getFormattedNumber:toNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    
    if(!theToPhoneNumber) {
        if(toNumber.length)
            theToPhoneNumber = toNumber;
        else
            theToPhoneNumber = @"";
    }
    
    if(!theFromPhoneNumber) {
        if(fromNumber.length)
            theFromPhoneNumber = fromNumber;
        else
            theFromPhoneNumber = @"";
    }
    
    
    NSNumber *theDate = [self.dic valueForKey:MSG_DATE];
    NSString *theTimeLocationString  =  [ScreenUtility dateConverter:theDate dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
    
    NSMutableAttributedString *timeAttrString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",theTimeLocationString]];
    [timeAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11]range:NSMakeRange(0, theTimeLocationString.length)];
    
    self.timeLabel.attributedText = timeAttrString;
    self.timeLabel.textColor = UIColorFromRGB(MSG_TIME_TEXT);
    self.timeLabel.font = [UIFont systemFontOfSize:11.0];
    
    NSString *toUser = [NSString stringWithFormat:@"To: %@",theToPhoneNumber];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:toUser];
    NSRange toPhoneRange = [toUser rangeOfString:theToPhoneNumber];
    
    
    NSDictionary *attributesForPhoneNumbers = @{NSForegroundColorAttributeName: UIColorFromRGB(TO_USER_TEXT_COLOR),
                                                NSFontAttributeName:
                                                    [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]};
    
    [attributedString addAttributes:attributesForPhoneNumbers range:toPhoneRange];
    
    self.timeAndLocationLabel.attributedText = attributedString;
    
    self.fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height, self.missedCallView.frame.size.width/2 + 35.0, 20.0)];
    
    self.fromLabel.textColor = UIColorFromRGB(LOCATION_TEXT);
    self.fromLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    [self.contentView addSubview:self.fromLabel];
    self.fromLabel.text = [NSString stringWithFormat:@"From: %@",theFromPhoneNumber];
    
    // create the tick view
    int tickViewHeight = 18;
    int topOffset = 0;
    int rightOffset = 8;
    UIView *tickView = [self viewWithTag:0x71c];
    if (!tickView) {
        tickView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 28, self.missedCallView.frame.origin.y - 3, tickViewHeight, tickViewHeight)];
    }
    [tickView setTag:TICK_VIEW_ID];
    tickView.backgroundColor = [UIColor clearColor];
    tickView.tag = 0x71c;
    
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
    tickShapeNotClosedLayer.strokeColor = self.mcImageView.layer.borderColor;
    tickShapeNotClosedLayer.fillColor = self.mcImageView.backgroundColor.CGColor;
    [tickView.layer addSublayer:tickShapeNotClosedLayer];
    
    [self.contentView addSubview:tickView];
    // }
    
   // self.locationLabel.tag = LOCATION_LBL_TAG;
    self.fromLabel.tag = FROMTO_LBL_TAG;
    //
    
    NSString *formattedFromUserNumber = [Common getFormattedNumber:[self.dic valueForKey:@"FROM_USER_ID"] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    /*
    CGSize stringsize = [formattedFromUserNumber sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}];
    _toUserNumberButtonWidth.constant = stringsize.width;
    [_toUserNumberButtonOutlet setTitle:formattedFromUserNumber forState:UIControlStateNormal];
    */
    
    self.timeAndLocationLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    self.fromLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    //[_mcTextView setFont:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]];
    //[_mcTitleLabel setFont:[Common preferredFontForTextStyleInApp:UIFontTextStyleBody]];
    
}

- (IBAction)callIconButtonAction:(id)sender
{
    if([self.delegate isAudioRecording])
        return;
    
    [self.delegate resignTextResponder];
    NSString* phoneNum = [self.dic valueForKey:@"FROM_USER_ID"];
    NSString* remoteUserType = [self.dic valueForKey:REMOTE_USER_TYPE];
    NSString* fromNumber = [self.dic valueForKey:NATIVE_CONTACT_ID];
    [Common callNumber:phoneNum FromNumber:fromNumber UserType:remoteUserType];
}

@end
