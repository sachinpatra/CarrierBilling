//
//  ConversationTableCellMissedCallReceiver.m
//  InstaVoice
//
//  Created by Jatin Mitruka on 5/13/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "ConversationTableCellMissedCallReceiver.h"
#import "IVColors.h"


@interface ConversationTableCellMissedCallReceiver ()
{
    //DC
    BOOL isCallListExpanded;
    float mcTextViewRowsCount;
}
@property (weak, nonatomic) IBOutlet UIImageView *missedCallIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *callBackButton;

@end

@implementation ConversationTableCellMissedCallReceiver

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
    //DC MAY 20 2016
    [_missedCallTitleLabelOutlet setFont:[Common preferredFontForTextStyleInApp:UIFontTextStyleBody]];
    //DC
    mcTextViewRowsCount = (_mcTextview.contentSize.height - _mcTextview.textContainerInset.top - _mcTextview.textContainerInset.bottom) / _mcTextview.font.lineHeight;

    long count = [[self.dic valueForKey:MISSED_CALL_COUNT] integerValue];
    if(count > 1 ){
        _missedCallTitleLabelOutlet.text = [NSString stringWithFormat:@"%ld Missed Calls", count];
    } else {
        _missedCallTitleLabelOutlet.text = @"Missed Call";
    }

    [self.expandButtonOutlet setImage:[[UIImage imageNamed:@"newPlusIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.expandButtonOutlet setTintColor:[IVColors redOutlineColor]];

    self.mcImageView.backgroundColor = [IVColors redFillColor];
    self.mcImageView.layer.borderColor = [IVColors redOutlineColor].CGColor;
    self.mcImageView.layer.borderWidth = 1;
    self.mcImageView.image = nil;
    self.mcImageView.layer.cornerRadius = 4;

    //Get To and From user name
    NSString *fromNumber = [self.dic valueForKey:@"FROM_USER_ID"];
    NSString *theFromPhoneNumber = [Common getFormattedNumber:fromNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    NSString *toNumber = [self.dic valueForKey:NATIVE_CONTACT_ID];
    NSString *theToPhoneNumber = [Common getFormattedNumber:toNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];

    if(!theFromPhoneNumber) {
        if(fromNumber.length)
            theFromPhoneNumber = fromNumber;
        else
            theFromPhoneNumber = @"";
    }
    
    if(!theToPhoneNumber) {
        if(toNumber.length)
            theToPhoneNumber = toNumber;
        else
            theToPhoneNumber = @"";
    }
    
    // the date/time
    NSNumber *theDate = [self.dic valueForKey:MSG_DATE];
    NSString *theTimeLocationString  =   [ScreenUtility dateConverter:theDate dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
    
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
    if (!isCallListExpanded) {
        isCallListExpanded = YES;
        self.toLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height, self.missedCallView.frame.size.width/2 + 25, 20.0)];
        self.locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.toLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 25, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height, self.missedCallView.frame.size.width/2 - 20, 20.0)];
    }
    
    self.toLabel.textColor = UIColorFromRGB(LOCATION_TEXT);
    self.toLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    [self.contentView addSubview:self.toLabel];
    self.toLabel.text = [NSString stringWithFormat:@"To: %@",theToPhoneNumber];
    
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

        tickShapeNotClosedLayer.strokeColor = [IVColors redOutlineColor].CGColor;
        tickShapeNotClosedLayer.fillColor = [IVColors redFillColor].CGColor;

        [tickView.layer addSublayer:tickShapeNotClosedLayer];
    //}
    tickView.backgroundColor = [UIColor clearColor];


    self.missedCallIconImageView.tintColor = [IVColors redOutlineColor];
    [self.mcImageView.layer setBorderWidth:1];
    [self.mcImageView setClipsToBounds:YES];

    self.mcImageView.layer.cornerRadius = 4;

    self.missedCallView.clipsToBounds = NO;
    [self.missedCallView addSubview:tickView];
    [self.missedCallView bringSubviewToFront:tickView];
    
    CGRect currentFrame = _mcTextview.frame;
    CGSize expected = [ScreenUtility sizeOfString:_mcTextview.text withFont:_mcTextview.font];
    currentFrame.size.height = expected.height;
    currentFrame.size.width = expected.width;
    
    _missedCallViewHeightConstraint.constant = _mcTextViewHeightConstraint.constant+SIZE_30;
    
    [_mcTextview setText:nil];
    
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
            NSString *timeLocationString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_CONVERSATION",nil)];
            NSArray* timeAndDay = [timeLocationString componentsSeparatedByString: @","];
            if ([timeAndDay count] > 1) {
                _mcTextview.text = [_mcTextview.text stringByAppendingString:[NSString stringWithFormat:@"Received on %@ at%@\n",[timeAndDay objectAtIndex:0],[timeAndDay objectAtIndex:1]]];
            }else{
                _mcTextview.text = [_mcTextview.text stringByAppendingString:[NSString stringWithFormat:@"Received at %@ \n",timeLocationString]];
            }
        }
       
        NSNumber *date = [self.dic  valueForKey:MSG_DATE];
        NSString *timeLocationString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_CONVERSATION",nil)];
        NSArray* timeAndDay = [timeLocationString componentsSeparatedByString: @","];
        if ([timeAndDay count] > 1) {
            _mcTextview.text = [_mcTextview.text stringByAppendingString:[NSString stringWithFormat:@"Received on %@ at%@\n",[timeAndDay objectAtIndex:0],[timeAndDay objectAtIndex:1]]];
        }else{
            _mcTextview.text = [_mcTextview.text stringByAppendingString:[NSString stringWithFormat:@"Received at %@ \n",timeLocationString]];
        }
        
        //DC MAY18 2016
        [_mcTextview setFont:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]];
        [_mcTextview setContentOffset:CGPointZero animated:NO];
    }
    
    NSNumber *date = [self.dic valueForKey:MSG_DATE];
    NSString *locationString = [self.dic valueForKey:LOCATION_NAME];
    if(!locationString)
        locationString = @"";
    
    NSString *timeLocationString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_CONVERSATION",nil)];
    
    BOOL isExapanded = [[self.dic valueForKey:IS_EXPANDED]boolValue];
    if([[self.dic valueForKey:MISSED_CALL_COUNT]integerValue]>1)
    {
        if (!isExapanded) {
            _mcTextViewHeightConstraint.constant = SIZE_1;
            [_expandButtonOutlet setImage:[[UIImage imageNamed:@"newPlusIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            
            self.toLabel.frame = CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height, self.missedCallView.frame.size.width/2 + 25, 20.0);
            
            self.locationLabel.frame = CGRectMake(self.toLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 25, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height, self.missedCallView.frame.size.width/2 - 20, 20.0);
        } else {
            [_expandButtonOutlet setImage:[[UIImage imageNamed:@"newMinusIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            _mcTextViewHeightConstraint.constant = [ScreenUtility sizeOfString:_mcTextview.text withFont:_mcTextview.font].height;
            
            _mcTextview.layer.borderColor = self.mcImageView.layer.borderColor;
            _mcTextview.layer.borderWidth = 1.0;
            _mcTextview.layer.cornerRadius = 4.0;
            [_mcTextview setContentOffset:CGPointMake(0, 0)];
            
            self.toLabel.frame = CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height + _mcTextViewHeightConstraint.constant - 5.0, self.missedCallView.frame.size.width/2 + 25, 20.0);
            
            self.locationLabel.frame = CGRectMake(self.toLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 25, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height + _mcTextViewHeightConstraint.constant - 5.0, self.missedCallView.frame.size.width/2 - 20, 20.0);
            
        }
    } else {
        _mcTextViewHeightConstraint.constant = SIZE_1;
        self.toLabel.frame = CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height, self.missedCallView.frame.size.width/2 + 25, 20.0);
        
        self.locationLabel.frame = CGRectMake(self.toLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 25, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height, self.missedCallView.frame.size.width/2 - 20, 20.0);
    }
    
    _missedCallViewHeightConstraint.constant = _mcTextViewHeightConstraint.constant + mcTextViewRowsCount*[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2].lineHeight + [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2].lineHeight + [Common preferredFontForTextStyleInApp:UIFontTextStyleBody].lineHeight;//+SIZE_30;
    
    if(locationString  != nil)
    {
        locationString = [@" " stringByAppendingString:locationString];
        timeLocationString = [timeLocationString stringByAppendingString:locationString];
        
    }
    
    timeLocationString = [@"To  " stringByAppendingString:[NSString stringWithFormat:@"%@   %@",[Common getFormattedNumber:[self.dic valueForKey:NATIVE_CONTACT_ID] withCountryIsdCode:nil withGivenNumberisCannonical:YES],timeLocationString]];
    
//    _timeAndLocationLabel.text = timeLocationString;

    //APR, 2017
    self.locationLabel.tag = LOCATION_LBL_TAG;
    self.toLabel.tag = FROMTO_LBL_TAG;
    //
    
    [_expandButtonOutlet setTag:self.cellIndex];
    
    NSString *formattedFromUserNumber = [Common getFormattedNumber:[self.dic valueForKey:@"FROM_USER_ID"] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    [_fromUserNumberButtonOutlet setTitle:formattedFromUserNumber forState:UIControlStateNormal];
}

- (IBAction)callIconButtonAction:(id)sender
{
    if([self.delegate isAudioRecording])
        return;
    
    [self.delegate resignTextResponder];
    //[Common callWithNumber:[self.dic valueForKey:@"FROM_USER_ID"]];
    NSString* phoneNum = [self.dic valueForKey:@"FROM_USER_ID"];
#ifdef REACHME_APP
    NSString* remoteUserType = [self.dic valueForKey:REMOTE_USER_TYPE];
    NSString* fromNumber = [self.dic valueForKey:NATIVE_CONTACT_ID];
    [Common callNumber:phoneNum FromNumber:fromNumber UserType:remoteUserType];
#else
    [Common callWithNumber:phoneNum];
#endif
}

- (IBAction)expandButtonAction:(id)sender {
    
    BOOL isExpanded = [[self.dic valueForKey:IS_EXPANDED]boolValue];
    if(isExpanded)
    {
        [self.dic setValue:[NSNumber numberWithBool:NO] forKey:IS_EXPANDED];
        [_expandButtonOutlet setImage:[[UIImage imageNamed:@"newPlusIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _mcTextViewHeightConstraint.constant = SIZE_1;
        _missedCallViewHeightConstraint.constant = self.mcTextViewHeightConstraint.constant + mcTextViewRowsCount*[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2].lineHeight;//SIZE_30;
    
        self.toLabel.frame = CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height, self.missedCallView.frame.size.width/2 + 25, 20.0);
        
        self.locationLabel.frame = CGRectMake(self.toLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 25, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height, self.missedCallView.frame.size.width/2 - 20, 20.0);
        
    } else {
        isCallListExpanded = YES;
        [self.dic setValue:[NSNumber numberWithBool:YES] forKey:IS_EXPANDED];
        
        [_expandButtonOutlet setImage:[[UIImage imageNamed:@"newMinusIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _mcTextViewHeightConstraint.constant = [ScreenUtility sizeOfString:_mcTextview.text withFont:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]].height;
    
        _missedCallViewHeightConstraint.constant = _mcTextViewHeightConstraint.constant +
        [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2].lineHeight + [Common preferredFontForTextStyleInApp:UIFontTextStyleBody].lineHeight;
        
        _mcTextview.layer.borderColor = self.mcImageView.layer.borderColor;
        _mcTextview.layer.borderWidth = 1.0;
        _mcTextview.layer.cornerRadius = 4.0;
        
        self.toLabel.frame = CGRectMake(self.missedCallView.frame.origin.x, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height + _mcTextViewHeightConstraint.constant - 5.0, self.missedCallView.frame.size.width/2 + 25, 20.0);
        
        self.locationLabel.frame = CGRectMake(self.toLabel.frame.origin.x + self.missedCallView.frame.size.width/2 + 25, self.missedCallView.frame.size.height + self.timeAndLocationLabel.frame.size.height + _mcTextViewHeightConstraint.constant - 5.0, self.missedCallView.frame.size.width/2 - 20, 20.0);
    }
    
    [self.delegate missedCallExpandedViewAtIndex:self.cellIndex];//TODO TEST Jan 19, 2017
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
