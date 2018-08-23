//
//  ConversationTableCellMissedCallSender.m
//  InstaVoice
//
//  Created by Jatin Mitruka on 5/14/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "ConversationTableCellMissedCallSender.h"
#import "IVColors.h"

@interface ConversationTableCellMissedCallSender (){
     BOOL isCallListExpanded;
}
@property (weak, nonatomic) IBOutlet UIImageView *readReceipt;
@property (weak, nonatomic) IBOutlet UIImageView *missedCallIconView;
@property (weak, nonatomic) IBOutlet UIButton *callBackButton;

@end

@implementation ConversationTableCellMissedCallSender
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
    NSInteger count = [[self.dic valueForKey:MISSED_CALL_COUNT] integerValue];
    if(count > 1) {
        _mcTitleLabelOutlet.text = [NSString stringWithFormat:@"Missed your %lu calls", (unsigned long)count];
    } else {
        _mcTitleLabelOutlet.text =  @"Missed your call";
    }
    
    CGRect currentFrame         =   _mcTextView.frame;
    CGSize expected = [ScreenUtility sizeOfString:_mcTextView.text withFont:_mcTextView.font];
    currentFrame.size.height    =   expected.height;
    currentFrame.size.width     =   expected.width;
    // _mcTextview.frame              =   CGRectMake(SIZE_48, SIZE_3, currentFrame.size.width,  currentFrame.size.height+SIZE_5);
    [self.expandButtonOutlet setImage:[[UIImage imageNamed:@"newPlusIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.expandButtonOutlet setTintColor:[IVColors redOutlineColor]];

    self.mcImageView.backgroundColor = [IVColors redFillColor];
    self.mcImageView.layer.borderColor = [IVColors redOutlineColor].CGColor;
    self.mcImageView.layer.borderWidth = 1;
    self.mcImageView.image = nil;
    self.mcImageView.layer.cornerRadius = 4;

    
    //To set readReceipt image
    NSString* msgStatus =[self.dic valueForKey:MSG_STATE];
    if (!self.readReceipt) {
        
        self.readReceipt.hidden = YES;
        self.readReceipt.tintColor = [IVColors lightGreyColor];
        //self.readReceiptView.tag = 11929;
    }
    NSString* tickImageName = @"";
    
    if ([[self.dic valueForKey:MSG_READ_CNT] intValue] > 0) {
        //self.readReceipt.hidden = NO;
        if ([[self.dic valueForKey:CONVERSATION_TYPE] isEqualToString:GROUP_TYPE])
            tickImageName = @"single_tick";
        else
            tickImageName = @"double_tick";
    }
    else if([msgStatus isEqualToString:API_DELIVERED]) {
        //self.readReceipt.hidden = NO;
        tickImageName = @"single_tick";
    }
    else {
        self.readReceipt.hidden = YES;
    }
    
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
    NSString *theTimeLocationString  =   [ScreenUtility dateConverter:theDate dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];

    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    if(![msgStatus isEqualToString:API_WITHDRAWN]) {
        attachment.image = [UIImage imageNamed:tickImageName];
    }
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *timeAttrString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",theTimeLocationString]];
    [timeAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11]range:NSMakeRange(0, theTimeLocationString.length)];
    [timeAttrString insertAttributedString:attachmentString atIndex:0];
    
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
    
    self.timeAndLocationLabelOutlet.attributedText = attributedString;
    
    if (!isCallListExpanded) {
        
//        if(!(count > 1)) {
//            _callArrowLeadingConstraint.constant = _missedCallIconView.frame.origin.x - 17.0;
//        }
        
        isCallListExpanded = YES;
        self.fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabelOutlet.frame.size.height, self.missedCallView.frame.size.width/2 + 35.0, 20.0)];
        self.locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.fromLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 35.0, self.missedCallView.frame.size.height + self.timeAndLocationLabelOutlet.frame.size.height, self.missedCallView.frame.size.width/2 - 30.0, 20.0)];
    }
    
    self.fromLabel.textColor = UIColorFromRGB(LOCATION_TEXT);
    self.fromLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    [self.contentView addSubview:self.fromLabel];
    self.fromLabel.text = [NSString stringWithFormat:@"From: %@",theFromPhoneNumber];
    
    self.locationLabel.textColor = UIColorFromRGB(LOCATION_TEXT);
    self.locationLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    [self.contentView addSubview:self.locationLabel];
    self.locationLabel.text = @"";

    [_mcTextView setText:nil];
    
    if([[self.dic valueForKey:MISSED_CALL_COUNT]integerValue] <= 1)
    {
        [_expandButtonOutlet setHidden:YES];
    }
    else
    {
        [_expandButtonOutlet setEnabled:YES];
        [_expandButtonOutlet setHidden:NO];
        
        NSMutableArray *msgList = [self.dic valueForKey:MSG_LIST];
        long count = [msgList count];
        for (int i=0; i<count; i++) {
            NSNumber *date = [[msgList objectAtIndex:i] valueForKey:MSG_DATE];
            NSString *timeLocationString  = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_CONVERSATION",nil)];
            NSArray* timeAndDay = [timeLocationString componentsSeparatedByString: @","];
            if ([timeAndDay count] > 1) {
                _mcTextView.text = [_mcTextView.text stringByAppendingString:[NSString stringWithFormat:@"Sent on %@ at%@\n",[timeAndDay objectAtIndex:0],[timeAndDay objectAtIndex:1]]];
            }else{
                _mcTextView.text = [_mcTextView.text stringByAppendingString:[NSString stringWithFormat:@"Sent at %@ \n",timeLocationString]];
            }
        }
        
        NSNumber *date = [self.dic valueForKey:MSG_DATE];
        NSString *timeLocationString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_CONVERSATION",nil)];
        NSArray* timeAndDay = [timeLocationString componentsSeparatedByString: @","];
        if ([timeAndDay count] > 1) {
            _mcTextView.text = [_mcTextView.text stringByAppendingString:[NSString stringWithFormat:@"Sent on %@ at%@\n",[timeAndDay objectAtIndex:0],[timeAndDay objectAtIndex:1]]];
        }else{
            _mcTextView.text = [_mcTextView.text stringByAppendingString:[NSString stringWithFormat:@"Sent at %@ \n",timeLocationString]];
        }
        
        [_mcTextView setContentOffset:CGPointZero animated:NO];
    }
    
    NSNumber *date = [self.dic valueForKey:MSG_DATE];
    NSString *locationString = [self.dic valueForKey:LOCATION_NAME];
    if(!locationString)
        locationString = @"";
    
    NSString *timeLocationString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_CONVERSATION",nil)];
    
    BOOL isExpanded = [[self.dic valueForKey:IS_EXPANDED]boolValue];
    if([[self.dic valueForKey:MISSED_CALL_COUNT]integerValue]>1)
    {
        if (isExpanded == false) {
            _mcTextViewHeightConstraint.constant = SIZE_1;
            [_expandButtonOutlet setImage:[[UIImage imageNamed:@"newPlusIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            
            self.fromLabel.frame = CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabelOutlet.frame.size.height, self.missedCallView.frame.size.width/2 + 35.0, 20.0);
            
            self.locationLabel.frame = CGRectMake(self.fromLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 35.0, self.missedCallView.frame.size.height + self.timeAndLocationLabelOutlet.frame.size.height, self.missedCallView.frame.size.width/2 - 30.0, 20.0);
            
        }else{
            [_expandButtonOutlet setImage:[[UIImage imageNamed:@"newMinusIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            _mcTextViewHeightConstraint.constant = [ScreenUtility sizeOfString:_mcTextView.text withFont:_mcTextView.font].height;
            _mcTextView.layer.borderColor = self.mcImageView.layer.borderColor;
            _mcTextView.layer.borderWidth = 1.0;
            _mcTextView.layer.cornerRadius = 4.0;
            [_mcTextView setContentOffset:CGPointMake(0, 0)];
            
            self.fromLabel.frame = CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabelOutlet.frame.size.height + _mcTextViewHeightConstraint.constant - 5.0, self.missedCallView.frame.size.width/2 + 35.0, 20.0);
            
            self.locationLabel.frame = CGRectMake(self.fromLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 35.0, self.missedCallView.frame.size.height + self.timeAndLocationLabelOutlet.frame.size.height + _mcTextViewHeightConstraint.constant - 5.0, self.missedCallView.frame.size.width/2 - 30.0, 20.0);
            
        }
    }else{
        _mcTextViewHeightConstraint.constant = SIZE_1;
        self.fromLabel.frame = CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabelOutlet.frame.size.height, self.missedCallView.frame.size.width/2 + 35.0, 20.0);
        
        self.locationLabel.frame = CGRectMake(self.fromLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 35.0, self.missedCallView.frame.size.height + self.timeAndLocationLabelOutlet.frame.size.height, self.missedCallView.frame.size.width/2 - 30.0, 20.0);
    }
    
//    _mcViewHeightConstraint.constant = _mcTextViewHeightConstraint.constant+SIZE_30;

    if(locationString  != nil)
    {
        locationString = [@" " stringByAppendingString:locationString];
        timeLocationString = [timeLocationString stringByAppendingString:locationString];
        
    }
    
    timeLocationString = [@"From   " stringByAppendingString:[NSString stringWithFormat:@"%@   %@",[Common getFormattedNumber:[self.dic valueForKey:NATIVE_CONTACT_ID] withCountryIsdCode:nil withGivenNumberisCannonical:YES],timeLocationString]];
    
//    _timeAndLocationLabelOutlet.text = timeLocationString;

    // create the tick view
    int tickViewHeight = 18;
    int topOffset = 0;
    int rightOffset = 8;
    //UIView *tickView = [self viewWithTag:0x71c];
    //if (!tickView) {
        UIView* tickView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 28, self.missedCallView.frame.origin.y - topOffset, tickViewHeight, tickViewHeight)];
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

    //APR, 2017
    self.locationLabel.tag = LOCATION_LBL_TAG;
    self.fromLabel.tag = FROMTO_LBL_TAG;
    //
    [_expandButtonOutlet setTag:self.cellIndex];

    NSString *formattedFromUserNumber = [Common getFormattedNumber:[self.dic valueForKey:@"FROM_USER_ID"] withCountryIsdCode:nil withGivenNumberisCannonical:YES];

    CGSize stringsize = [formattedFromUserNumber sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}];
    _toUserNumberButtonWidth.constant = stringsize.width;
    [_toUserNumberButtonOutlet setTitle:formattedFromUserNumber forState:UIControlStateNormal];
    //DC MAY 23 2016
    self.timeAndLocationLabelOutlet.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    self.fromLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    [_mcTextView setFont:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]];
    [_mcTitleLabelOutlet setFont:[Common preferredFontForTextStyleInApp:UIFontTextStyleBody]];

    
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

- (IBAction)expandButtonAction:(id)sender
{
    BOOL isExpanded = [[self.dic valueForKey:IS_EXPANDED]boolValue];
    if(isExpanded)
    {
        [self.dic setValue:[NSNumber numberWithBool:NO] forKey:IS_EXPANDED];
        [_expandButtonOutlet setImage:[[UIImage imageNamed:@"newPlusIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _mcTextViewHeightConstraint.constant = SIZE_1;
        
        self.fromLabel.frame = CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabelOutlet.frame.size.height, self.missedCallView.frame.size.width/2 + 35.0, 20.0);
        
        self.locationLabel.frame = CGRectMake(self.fromLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 35.0, self.missedCallView.frame.size.height + self.timeAndLocationLabelOutlet.frame.size.height, self.missedCallView.frame.size.width/2 - 30.0, 20.0);

    } else {
        isCallListExpanded = YES;
        [self.dic setValue:[NSNumber numberWithBool:YES] forKey:IS_EXPANDED];
        [_expandButtonOutlet setImage:[[UIImage imageNamed:@"newMinusIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _mcTextViewHeightConstraint.constant = [ScreenUtility sizeOfString:_mcTextView.text withFont:_mcTextView.font].height;
        _mcTextView.layer.borderColor = self.mcImageView.layer.borderColor;
        _mcTextView.layer.borderWidth = 1.0;
        _mcTextView.layer.cornerRadius = 4.0;
        
        self.fromLabel.frame = CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabelOutlet.frame.size.height + _mcTextViewHeightConstraint.constant - 5.0, self.missedCallView.frame.size.width/2 + 35.0, 20.0);
        
        self.locationLabel.frame = CGRectMake(self.fromLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 35.0, self.missedCallView.frame.size.height + self.timeAndLocationLabelOutlet.frame.size.height + _mcTextViewHeightConstraint.constant - 5.0, self.missedCallView.frame.size.width/2 - 30.0, 20.0);

    }
    
    [self.delegate missedCallExpandedViewAtIndex:self.cellIndex];//TEST Jan 19, 2017
}

- (IBAction)toUserNumberButtonAction:(id)sender
{
    if([self.delegate isAudioRecording])
        return;
    
    [self.delegate resignTextResponder];
    [Common callWithNumber:[self.dic valueForKey:@"FROM_USER_ID"]];
}

@end
