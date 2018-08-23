//
//  ConversationTabelCellReachMeCallReceiver.m
//  InstaVoice
//
//  Created by Pandian on 8/7/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConversationTableCellReachMeCallReceiver.h"
#import "IVColors.h"


@interface ConversationTableCellReachMeCallReceiver ()

@property (weak, nonatomic) IBOutlet UIImageView *missedCallIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *callBackButton;

@end

@implementation ConversationTableCellReachMeCallReceiver

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
    int min=0,seconds=0;
    if(duration>0) {
        min = duration/60;
        seconds = duration - min*60;
    }
    
    NSString* sDuration = [NSString stringWithFormat:@"%dm %ds",min,seconds];
    self.labelDuration.text = sDuration;
    self.labelDuration.textColor = UIColorFromRGB(MSG_TIME_TEXT);
    self.labelDuration.font = [UIFont systemFontOfSize:12.0];
    
    /* REMOVE
    self.labelReachMe.hidden = YES;
    self.labelReachMe.layer.borderWidth = 1;
    self.labelReachMe.layer.masksToBounds = YES;
    self.labelReachMe.layer.cornerRadius = 12;
    self.labelReachMe.layer.borderColor = [UIColor darkGrayColor].CGColor;
    */
    
    [_missedCallTitleLabelOutlet setFont:[Common preferredFontForTextStyleInApp:UIFontTextStyleBody]];
    _missedCallTitleLabelOutlet.text = @"Answered";
    
    self.mcImageView.backgroundColor = [IVColors blueFillColor];
    self.mcImageView.layer.borderColor = [IVColors blueOutlineColor].CGColor;
    self.mcImageView.layer.borderWidth = 1;
    self.mcImageView.image = nil;
    self.mcImageView.layer.cornerRadius = 4;
    
    //Get To and From user name
    NSString* fromPhoneNumber = [self.dic valueForKey:@"FROM_USER_ID"];
    NSString *theFromPhoneNumber = [Common getFormattedNumber:fromPhoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    NSString *toPhoneNumber = [self.dic valueForKey:NATIVE_CONTACT_ID];
    NSString *theToPhoneNumber = [Common getFormattedNumber:toPhoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    
    if(!theFromPhoneNumber) {
        if(fromPhoneNumber.length)
            theFromPhoneNumber = fromPhoneNumber;
        else
            theFromPhoneNumber = @"";
    }
    
    if(!theToPhoneNumber) {
        if(toPhoneNumber.length)
            theToPhoneNumber = toPhoneNumber;
        else
            theToPhoneNumber = @"";
    }
    
    // the date/time
    NSNumber *theDate = [self.dic valueForKey:MSG_DATE];
    NSString *theTimeLocationString = [ScreenUtility dateConverter:theDate dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
    
    self.timeLabel.text = theTimeLocationString;
    self.timeLabel.textColor = UIColorFromRGB(MSG_TIME_TEXT);
    self.timeLabel.font = [UIFont systemFontOfSize:11.0];
    
    NSString *fromUser = [NSString stringWithFormat:@"From: %@",theFromPhoneNumber];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fromUser];
    NSRange fromPhoneRange = [fromUser rangeOfString:theFromPhoneNumber];
    
    
    NSDictionary *attributesForPhoneNumbers = @{NSForegroundColorAttributeName: UIColorFromRGB(TO_USER_TEXT_COLOR),
                                                NSFontAttributeName:
                                                    [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]};
    
    [attributedString addAttributes:attributesForPhoneNumbers range:fromPhoneRange];
    
    self.timeAndLocationLabel.attributedText = attributedString;
    self.timeAndLocationLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    
    self.toLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height, self.missedCallView.frame.size.width/2 + 25, 20.0)];
    self.locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.toLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 25, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height, self.missedCallView.frame.size.width/2 - 20, 20.0)];
    
    self.toLabel.textColor = UIColorFromRGB(LOCATION_TEXT);
    self.toLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    [self.contentView addSubview:self.toLabel];
    self.toLabel.text = [NSString stringWithFormat:@"To: %@", theToPhoneNumber];
    
    self.locationLabel.textColor = UIColorFromRGB(LOCATION_TEXT);
    self.locationLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    [self.contentView addSubview:self.locationLabel];
    self.locationLabel.text = @"";
    
    int tickViewHeight = 16;
    int topOffset = 0;
    int rightOffset = tickViewHeight - 6;
    
    //JUNE 1, 2016 UIView *tickView = [self.contentView viewWithTag:TICK_VIEW_ID];
    //if (!tickView) {
    UIView* tickView = [[UIView alloc] initWithFrame:CGRectMake(self.mcImageView.frame.origin.x - rightOffset, self.mcImageView.frame.origin.y - topOffset, tickViewHeight, tickViewHeight)];
    tickView.tag = TICK_VIEW_ID;
    
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
    
    tickShapeNotClosedLayer.strokeColor = [IVColors blueOutlineColor].CGColor;
    tickShapeNotClosedLayer.fillColor = [IVColors blueFillColor].CGColor;
    
    [tickView.layer addSublayer:tickShapeNotClosedLayer];
    //}
    tickView.backgroundColor = [UIColor clearColor];
    
    
    self.missedCallIconImageView.tintColor = [IVColors blueOutlineColor];
    [self.mcImageView.layer setBorderWidth:1];
    [self.mcImageView setClipsToBounds:YES];
    
    self.mcImageView.layer.cornerRadius = 4;
    
    self.missedCallView.clipsToBounds = NO;
    [self.missedCallView addSubview:tickView];
    [self.missedCallView bringSubviewToFront:tickView];
    
    
    /* MAR 30, 2018
    NSNumber *date = [self.dic valueForKey:MSG_DATE];
    NSString *locationString = [self.dic valueForKey:LOCATION_NAME];
    if(!locationString)
        locationString = @"";
    
    NSString *timeLocationString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_CONVERSATION",nil)];
    
    if(locationString  != nil)
    {
        locationString = [@" " stringByAppendingString:locationString];
        timeLocationString = [timeLocationString stringByAppendingString:locationString];
        
    }
    
    timeLocationString = [@"To  " stringByAppendingString:[NSString stringWithFormat:@"%@   %@",[Common getFormattedNumber:[self.dic valueForKey:NATIVE_CONTACT_ID] withCountryIsdCode:nil withGivenNumberisCannonical:YES],timeLocationString]];
    */
    
    self.locationLabel.tag = LOCATION_LBL_TAG;
    self.toLabel.tag = FROMTO_LBL_TAG;
    
    NSString *formattedFromUserNumber = [Common getFormattedNumber:[self.dic valueForKey:@"FROM_USER_ID"] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    [_fromUserNumberButtonOutlet setTitle:formattedFromUserNumber forState:UIControlStateNormal];
}

- (IBAction)callIconButtonAction:(id)sender
{
    if([self.delegate isAudioRecording])
        return;
    
    [self.delegate resignTextResponder];
    NSString* phoneNum = [self.dic valueForKey:@"FROM_USER_ID"];
#ifdef REACHME_APP
    NSString* remoteUserType = [self.dic valueForKey:REMOTE_USER_TYPE];
    NSString* fromNumber = [self.dic valueForKey:NATIVE_CONTACT_ID];
    [Common callNumber:phoneNum FromNumber:fromNumber UserType:remoteUserType];
#else
    [Common callWithNumber:phoneNum];
#endif
}

- (IBAction)fromUserNumberButtonAction:(id)sender
{
    [Common callWithNumber:[self.dic valueForKey:FROM_USER_ID]];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
