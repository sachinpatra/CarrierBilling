//
//  ConversationTableCellTextSender.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 5/20/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "ConversationTableCellTextSender.h"
#import "SharedMenuLabel.h"
#import "IVColors.h"

@interface ConversationTableCellTextSender ()
@end

@implementation ConversationTableCellTextSender

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark ChatView Sender cell

-(void)configureCell
{
    UIButton      *showMore         = nil;
    UITextView    *msgLabel         = nil;
    NSString      *msgStatus        = @"";
    NSString      *locationString   = nil;
    SharedMenuLabel *sharedLabel = nil;

    UIImageView   *likeImage        = nil;
    NSString *linkedOPR = [self.dic valueForKey:LINKED_OPR];
    
    BOOL likeBool =   [[self.dic valueForKey:MSG_LIKED] boolValue];
    BOOL twBool   =   [[self.dic valueForKey:MSG_TW_POST] boolValue];
    BOOL fbBool   =   [[self.dic valueForKey:MSG_FB_POST] boolValue];
    BOOL vbBool   =   [[self.dic valueForKey:MSG_VB_POST] boolValue];
    BOOL ivBool   =   [[self.dic valueForKey:MSG_FORWARD] boolValue];
    BOOL fwdBool  =   [linkedOPR isEqualToString:IS_FORWORD_MSG];
    
    msgStatus = [self.dic valueForKey:MSG_STATE];
    BOOL isMsgWithdrawn = [msgStatus isEqualToString:API_WITHDRAWN];
    self.tintColor = [IVColors greenOutlineColor];
    
    UIImageView *msgView = nil;
    msgLabel = [[UITextView alloc] init];
    msgLabel.delegate = self.baseConversationObj;
    msgLabel.backgroundColor = [UIColor clearColor];
    msgLabel.userInteractionEnabled = YES;
    msgLabel.selectable = YES;
    msgLabel.scrollEnabled = NO;
    msgLabel.editable = NO;
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.dataDetectorTypes = UIDataDetectorTypeAll;
    
    int msgReadCount = [[self.dic valueForKey:MSG_READ_CNT]intValue];
    if(msgReadCount > 1)
        msgReadCount = 1;
    
    NSString *msgContent = [self.dic valueForKey:MSG_CONTENT];
    msgLabel.text = msgContent;
    
    if(!isMsgWithdrawn) {
        NSNumber *value = [self.dic valueForKey:@"toShowMore"];
        showMore = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        showMore.frame = CGRectZero;
        
        if(msgContent.length > SHOW_MORE_LEN && (value == nil || [value intValue] == 1)) {
            NSRange stringRange = {0, MIN([msgContent length], SHOW_MORE_LEN)};
            msgContent = [msgContent substringWithRange:stringRange];
            [self.dic setValue:[NSNumber numberWithInt:1] forKey:@"toShowMore"];
            msgLabel.text = [NSString stringWithFormat:@"%@....", msgContent];
            [self.contentView addSubview:showMore];
        }
        else {
            if(value == nil )
                [self.dic setValue:[NSNumber numberWithInt:2] forKey:@"toShowMore"];
            
            msgLabel.text = msgContent;
        }
    } else {
        msgLabel.selectable = NO;
    }
    
    /*
    if(isMsgWithdrawn)
        [msgLabel setFont:[UIFont italicSystemFontOfSize:[UIFont systemFontSize]]];
    else*/
        [msgLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    
    [arrayDictionary replaceObjectAtIndex:self.cellIndex.row withObject:self.dic];//TEST Jan 19, 2017
    //Height calculations R&D Bhaskar Feb 7
    CGSize lableWidth = CGSizeMake(DEVICE_WIDTH - 80, CGFLOAT_MAX);
    CGSize neededSize = [msgLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
    CGFloat msgLblX = DEVICE_WIDTH - (neededSize.width+30);
    CGFloat msgLblY = 12;
    CGFloat msgLblW = neededSize.width+10;
    CGFloat msgLblH = neededSize.height+10;
    
    CGFloat newX = msgLblX - 70;
    
    if(msgContent.length < SHOW_MORE_LEN) {
        if(newX < 0) {
            msgLabel.frame = CGRectMake(msgLblX, msgLblY+4, msgLblW, msgLblH);
        }
        else {
            msgLabel.frame = CGRectMake(newX + 10, msgLblY, msgLblW + 60, msgLblH);
        }
    }
    else {
        msgLabel.frame = CGRectMake(msgLblX, msgLblY+4, msgLblW, msgLblH);
    }
    
    if ([msgLabel respondsToSelector:@selector(linkTextAttributes)] && !isMsgWithdrawn)
    {
        UIColor *linkColor;
        if (msgReadCount > 0) {
            linkColor = [UIColor blackColor];
        }
        else
        {
            linkColor = [UIColor whiteColor];
        }
        
        if ([[UIDevice currentDevice].systemVersion floatValue] < 9) {
            UIFont* font =  [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
            NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:msgLabel.text];
            [string addAttribute:NSForegroundColorAttributeName value:linkColor range:NSMakeRange(0,msgLabel.text.length)];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            
            [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, msgLabel.text.length)];
            [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, msgLabel.text.length)];
            msgLabel.attributedText = string;
            msgLabel.dataDetectorTypes = UIDataDetectorTypeAll;
        }else{
            
            NSDictionary *attributes = @{
                                         NSForegroundColorAttributeName: linkColor,
                                         NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                         };
            msgLabel.linkTextAttributes = attributes;
        }
    }
    
    if([[self.dic valueForKey:MSG_TYPE] isEqualToString:VB_TYPE])
    {
        msgView = [[UIImageView alloc] initWithImage:[UIImage new]];
        msgView.backgroundColor = [IVColors orangeFillColor];
        msgView.layer.borderColor = [IVColors orangeOutlineColor].CGColor;
        msgView.layer.borderWidth = 1;
        msgLabel.textColor = [UIColor blackColor];
        vbBool = NO;
    }
    else if([[self.dic valueForKey:MSG_TYPE] isEqualToString:VSMS_TYPE])
    {
        if (msgReadCount > 0) {
            msgView = [[UIImageView alloc] initWithImage:[UIImage new]];
            msgView.backgroundColor = [IVColors grayFillColor];
            msgView.layer.borderColor = [IVColors grayOutlineColor].CGColor;
            msgView.layer.borderWidth = 1;
            msgLabel.textColor = [UIColor blackColor];
        }
        else
        {
            msgView = [[UIImageView alloc] initWithImage:[UIImage new]];
            msgView.backgroundColor = [IVColors grayFillColor];
            msgView.layer.borderColor = [IVColors grayOutlineColor].CGColor;
            msgView.layer.borderWidth = 1;
            msgLabel.textColor = [UIColor blackColor];
        }
    }
    else if([[self.dic valueForKey:MSG_TYPE] isEqualToString:NOTES_TYPE])
    {
        msgView = [[UIImageView alloc] initWithImage:[UIImage new]];
        msgView.backgroundColor = [IVColors greenFillColor];
        msgView.layer.borderColor = [IVColors greenOutlineColor].CGColor;
        msgView.layer.borderWidth = 1;
        msgLabel.textColor = [UIColor blackColor];
    }
    else
    {
        if (msgReadCount > 0) {
            msgView = [[UIImageView alloc] initWithImage:[UIImage new]];
            msgView.backgroundColor = [IVColors greenFillColor];
            msgView.layer.borderColor = [IVColors greenOutlineColor].CGColor;
            msgView.layer.borderWidth = 1;
            msgLabel.textColor = [UIColor blackColor];
        }
        else
        {
            msgView = [[UIImageView alloc] initWithImage:[UIImage new]];
            msgView.backgroundColor = [IVColors greenFillColor];
            msgView.layer.borderColor = [IVColors greenOutlineColor].CGColor;
            msgView.layer.borderWidth = 1;
            msgLabel.textColor = [UIColor blackColor];
        }
    }
    
    if(isMsgWithdrawn) {
        [msgLabel setFont:[UIFont italicSystemFontOfSize:msgLabel.font.pointSize]];
        msgLabel.textColor = [UIColor grayColor];
    }
    
    if(msgContent.length < SHOW_MORE_LEN) {
        if(newX < 0) {
            msgView.frame = CGRectMake(msgLblX,msgLblY+3,msgLblW,msgLblH);
        }
        else {
            msgView.frame = CGRectMake(newX + 10,msgLblY+3,msgLblW + 60,msgLblH);
        }
    }
    else {
        msgView.frame = CGRectMake(msgLblX,msgLblY+3,msgLblW,msgLblH+20);
    }
    
    msgView.userInteractionEnabled = NO;
    msgView.layer.cornerRadius = 4;
    [msgView setTag:TEXT_VIEW_ID];
    
    
    if ((msgView.frame.size.width > (DEVICE_WIDTH - 80)) || (msgLabel.frame.size.width > (DEVICE_WIDTH - 80))) {
        msgView.frame = CGRectMake(60,msgLblY+3,DEVICE_WIDTH - 80,msgContent.length < SHOW_MORE_LEN?msgLblH + 5:msgLblH+20);
        msgLabel.frame = CGRectMake(60, msgLblY+4, DEVICE_WIDTH - 80, msgLblH + 5);
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 9) {
        UIFont* font =  [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:msgLabel.text];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,msgLabel.text.length)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        
        [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, msgLabel.text.length)];
        [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, msgLabel.text.length)];
        msgLabel.attributedText = string;
        msgLabel.dataDetectorTypes = UIDataDetectorTypeAll;
    } else {
        
        NSDictionary *attributes = @{
                                     NSForegroundColorAttributeName: [UIColor colorWithCGColor:msgView.layer.borderColor],
                                     NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                     };
        msgLabel.linkTextAttributes = attributes;
    }
    
    NSNumber *valueToGet = [self.dic valueForKey:@"toShowMore"];
    if(fbBool || vbBool || twBool || ivBool || fwdBool || (valueToGet && [valueToGet intValue]!=2) )
    {
        int size = 0;
        if([valueToGet intValue]!=2) {
            showMore.frame = CGRectMake(msgLabel.frame.origin.x + 3,
                                        msgLabel.frame.size.height + 4,
                                        SIZE_120,SIZE_40);
            showMore.titleLabel.textAlignment = NSTextAlignmentLeft;
            [showMore setTitleEdgeInsets:UIEdgeInsetsMake(-10.0f, -20.0f, 0.0f, 0.0f)];
            if([valueToGet intValue]==1) {
                [showMore setTitle:@"+ Show More" forState:UIControlStateNormal];
            } else {
                [showMore setTitle:@"- Show Less" forState:UIControlStateNormal];
            }
            showMore.titleLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
            [showMore setTitleColor:[UIColor colorWithCGColor:self.layer.borderColor] forState:UIControlStateNormal];
            [showMore addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchUpInside];
            size = SIZE_12;
        }
    }
    
    if(!isMsgWithdrawn) {
        sharedLabel = [[SharedMenuLabel alloc]init];
        [sharedLabel setTag:self.cellIndex];
        sharedLabel.stringText = msgLabel;
        sharedLabel.stringToCopy = [self.dic valueForKey:MSG_CONTENT];
        sharedLabel.userInteractionEnabled = YES;
        sharedLabel.stringText.selectable = YES;
        sharedLabel.stringText.editable = NO;
        sharedLabel.stringText.dataDetectorTypes = UIDataDetectorTypeAll;
        [sharedLabel setFrame:msgView.frame];
        [sharedLabel setBackgroundColor:[UIColor clearColor]];
        
        SEL selectorAction = @selector(tapOnLink:);
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:selectorAction];
        [sharedLabel addGestureRecognizer:tapGesture];
    }
    
    // create the tick view
    int tickViewHeight = 20;
    int topOffset = 0;
    int rightOffset = 8;
    UIView *tickView = [[UIView alloc] initWithFrame:CGRectMake(msgView.frame.origin.x + msgView.frame.size.width - rightOffset, msgView.frame.origin.y - topOffset, tickViewHeight, tickViewHeight)];
    tickView.backgroundColor = [UIColor clearColor];


    // create the masking layer for the tick view and apply it
    UIBezierPath *tickShape = [UIBezierPath bezierPath];
    [tickShape moveToPoint:CGPointMake(0, topOffset)];
    [tickShape addLineToPoint:CGPointMake(tickViewHeight, 0)];
    [tickShape addLineToPoint:CGPointMake(rightOffset + 2, tickViewHeight - 4)];
    [tickShape addLineToPoint:CGPointMake(rightOffset + 2, tickViewHeight)];
    [tickShape addLineToPoint:CGPointMake(0, tickViewHeight)];
    [tickShape closePath];
    CAShapeLayer *tickShapeLayer = [CAShapeLayer layer];
    tickShapeLayer.path = tickShape.CGPath;
    tickView.layer.mask = tickShapeLayer;
    
    // create a layer stroked with the actual color we want
    UIBezierPath *tickShapeNotClosed = [UIBezierPath bezierPath];
    [tickShapeNotClosed moveToPoint:CGPointMake(0, topOffset)];
    [tickShapeNotClosed addLineToPoint:CGPointMake(tickViewHeight, 0)];
    [tickShapeNotClosed addLineToPoint:CGPointMake(rightOffset + 2, tickViewHeight - 4)];
    [tickShapeNotClosed addLineToPoint:CGPointMake(rightOffset + 2, tickViewHeight)];
    CAShapeLayer *tickShapeNotClosedLayer = [CAShapeLayer layer];
    tickShapeNotClosedLayer.path = tickShapeNotClosed.CGPath;
    tickShapeNotClosedLayer.lineWidth = 2;
    tickShapeNotClosedLayer.strokeColor = msgView.layer.borderColor;
    tickShapeNotClosedLayer.fillColor = msgView.backgroundColor.CGColor;
    [tickView.layer addSublayer:tickShapeNotClosedLayer];
    
    [self.contentView addSubview:msgView];
    [self.contentView addSubview:tickView];
    [self.contentView addSubview:msgLabel];
    if(!isMsgWithdrawn) {
        [self.contentView addSubview:showMore];
        [self.contentView addSubview:sharedLabel];
    }
    
    if(valueToGet && valueToGet != nil) {
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMore)];
        [tap setNumberOfTapsRequired:1];
        [self.contentView addGestureRecognizer:tap];
    }
    
    if(isMsgWithdrawn) {
        fwdBool = ivBool = fbBool = vbBool = twBool = likeBool = FALSE;
    }
    
    //- Set up time with tick image or hour glass
    NSNumber *date  = [self.dic valueForKey:MSG_DATE];
    NSString* timeString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
    timeString = [@" " stringByAppendingString:timeString];
    NSString* msgState = [self.dic valueForKey:MSG_STATE];
    NSString* tickImageName = @"";
    if (MessageReadStatusRead == msgReadCount) {
        if ([[self.dic valueForKey:CONVERSATION_TYPE] isEqualToString:GROUP_TYPE]) {
            if([[self.dic valueForKey:MSG_SUB_TYPE] isEqualToString:GROUP_MSG_EVENT_TYPE])
                tickImageName = @"";
            else
                tickImageName = @"single_tick";
        } else {
            tickImageName = @"double_tick";
        }
    }
    else if([msgStatus isEqualToString:API_DELIVERED] ||
            [msgStatus isEqualToString:API_DOWNLOADED] ) {
        tickImageName = @"single_tick";
    }
    else if([msgStatus isEqualToString:API_NETUNAVAILABLE] || [msgStatus isEqualToString:API_UNSENT]) {
        tickImageName = @"failed-msg";
    }
    else {
        tickImageName = @"hour-glass";
    }
    
    //combine image and label
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    if(![msgState isEqualToString:API_WITHDRAWN]) {
        attachment.image = [UIImage imageNamed:tickImageName];
    }
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *timeAttrString= [[NSMutableAttributedString alloc] initWithString:timeString];
    [timeAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11]range:NSMakeRange(0, timeString.length)];
    [timeAttrString insertAttributedString:attachmentString atIndex:0];

    int shareCountVal = 0;
    int deltaWidth = 0;
    //
    
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    BOOL is24Hour = ([format rangeOfString:@"a"].location == NSNotFound);
    
    UILabel* theTimeLabel = nil;
    UIButton *msgWithdrawDelete = nil;
    if(msgContent.length < SHOW_MORE_LEN) {
        theTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(is24Hour?msgLabel.frame.origin.x+msgLabel.frame.size.width-SIZE_50:msgLabel.frame.origin.x+msgLabel.frame.size.width-SIZE_70, msgLblH - 3, 70, 20)];
    } else {
        theTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(is24Hour?msgLabel.frame.origin.x+msgLabel.frame.size.width-SIZE_50:msgLabel.frame.origin.x+msgLabel.frame.size.width-SIZE_70, msgLabel.frame.size.height+10, 70, 20)];
    }
    
    if(isMsgWithdrawn) {
        theTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(is24Hour?msgLabel.frame.origin.x+msgLabel.frame.size.width-SIZE_50:msgLabel.frame.origin.x+msgLabel.frame.size.width-SIZE_60, msgLabel.frame.size.height-7, 70, 20)];
        
        msgWithdrawDelete = [[UIButton alloc]initWithFrame:CGRectMake(theTimeLabel.frame.origin.x - 17, msgLabel.frame.size.height-12, 24, 31)];
        [msgWithdrawDelete setImage:[UIImage imageNamed:@"dellWithdrawn"] forState:UIControlStateNormal];
        [msgWithdrawDelete addTarget:self action:@selector(deleteStaticMessageWithdraw:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:msgWithdrawDelete];
        
    }
    
    theTimeLabel.attributedText = timeAttrString;
    theTimeLabel.textColor = UIColorFromRGB(MSG_TIME_TEXT);
    [self.contentView addSubview:theTimeLabel];
    deltaWidth = 90;

    likeBool = 0;
    fwdBool = 0;
    ivBool = 0;
    fbBool = 0;
    twBool = 0;
    //vbBool = 0;
    //DEC 21, 2016
    if(likeBool)
    {
        likeImage = [[UIImageView alloc] initWithFrame:CGRectMake(
                                                            msgLabel.frame.origin.x+msgLabel.frame.size.width - deltaWidth,
                                                            msgLabel.frame.size.height+SIZE_10,
                                                            SIZE_12,SIZE_12)];
        UIImage* img = [[UIImage imageNamed:@"share-icon-like"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        likeImage.tintColor = [IVColors redColor];
        likeImage.contentMode = UIViewContentModeScaleAspectFit;
        [self setShareImg:img atView:likeImage];
        deltaWidth = deltaWidth + 20;
        shareCountVal++;
    }
    //
    
    if(ivBool)
    {
        UIImageView* shareImg1 = [[UIImageView alloc]initWithFrame:CGRectMake(
                                                                msgLabel.frame.origin.x+msgLabel.frame.size.width - deltaWidth,
                                                                msgLabel.frame.size.height+SIZE_10,
                                                                SIZE_12, SIZE_12)];
        shareImg1.tintColor = [UIColor colorWithCGColor:msgView.layer.borderColor];
        shareImg1.contentMode = UIViewContentModeScaleAspectFit;
        [self setShareImg:msgReadCount>0?instaGreyIcon:fwdWhiteIcon atView:shareImg1];
        deltaWidth += 20;
        shareCountVal++;
    }
    
    if(fbBool)
    {
        UIImageView* shareImg2 = [[UIImageView alloc]initWithFrame:CGRectMake(
                                                                msgLabel.frame.origin.x+msgLabel.frame.size.width - deltaWidth,
                                                                msgLabel.frame.size.height+SIZE_10,
                                                                SIZE_12,SIZE_12)];
        shareImg2.tintColor = [UIColor colorWithCGColor:msgView.layer.borderColor];
        shareImg2.contentMode = UIViewContentModeScaleAspectFit;
        [self setShareImg:msgReadCount>0?fbGreyIcon:fbIcon atView:shareImg2];
        deltaWidth += 20;
        shareCountVal++;
    }
    
    if(vbBool)
    {
        if(msgContent.length < SHOW_MORE_LEN) {
            if(newX < 0) {
                msgLabel.frame = CGRectMake(msgLblX, msgLblY+4, msgLblW, msgLblH);
                msgView.frame = CGRectMake(msgLblX,msgLblY+3,msgLblW,msgLblH);
            }
            else {
                msgLabel.frame = CGRectMake(newX + (msgContent.length>10?10:-20), msgLblY, msgLblW + (msgContent.length>10?50:90), msgLblH);
                msgView.frame = CGRectMake(newX + (msgContent.length>10?10:-20),msgLblY+3,msgLblW + (msgContent.length>10?50:90),msgLblH);
            }
        }
        else {
            msgLabel.frame = CGRectMake(msgLblX, msgLblY+4, msgLblW, msgLblH);
            msgView.frame = CGRectMake(msgLblX,msgLblY+3,msgLblW,msgLblH+20);
        }
        
        if ((msgView.frame.size.width > (DEVICE_WIDTH - 80)) || (msgLabel.frame.size.width > (DEVICE_WIDTH - 80))) {
            msgView.frame = CGRectMake(60,msgLblY+3,DEVICE_WIDTH - 80,msgContent.length < SHOW_MORE_LEN?msgLblH + 5:msgLblH+20);
            msgLabel.frame = CGRectMake(60, msgLblY+4, DEVICE_WIDTH - 80, msgLblH + 5);
        }
        
        UIImageView* shareImg3 = nil;
        if(msgContent.length < SHOW_MORE_LEN) {
                shareImg3 = [[UIImageView alloc]initWithFrame:CGRectMake(
                                                                msgLabel.frame.origin.x+msgLabel.frame.size.width - deltaWidth,
                                                                msgLblH,
                                                                SIZE_12,SIZE_12)];
        } else {
            shareImg3 = [[UIImageView alloc]initWithFrame:CGRectMake(
                                                                     msgLabel.frame.origin.x+msgLabel.frame.size.width - deltaWidth,
                                                                     msgLabel.frame.size.height+14,
                                                                     SIZE_12,SIZE_12)];
        }
        shareImg3.tintColor = [UIColor colorWithCGColor:msgView.layer.borderColor];
        shareImg3.contentMode = UIViewContentModeScaleAspectFit;
        [self setShareImg:msgReadCount>0?vbGreyIcon:vbIcon atView:shareImg3];
        deltaWidth += 20;
        shareCountVal++;
    }
    
    if(twBool)
    {
        UIImageView* shareImg4 = [[UIImageView alloc]initWithFrame:CGRectMake(
                                                                msgLabel.frame.origin.x+msgLabel.frame.size.width - deltaWidth,
                                                                msgLabel.frame.size.height+SIZE_10,
                                                                SIZE_12,SIZE_12)];
        shareImg4.tintColor = [UIColor colorWithCGColor:msgView.layer.borderColor];
        shareImg4.contentMode = UIViewContentModeScaleAspectFit;
        [self setShareImg:msgReadCount>0?twitterGreyIcon:twitterIcon atView:shareImg4];
        deltaWidth += 20;
        shareCountVal++;
    }
    
    if(fwdBool)
    {
        UIImageView* shareImg5 = [[UIImageView alloc]initWithFrame:CGRectMake(
                                                                msgLabel.frame.origin.x+msgLabel.frame.size.width - deltaWidth,
                                                                msgLabel.frame.size.height+SIZE_10,
                                                                SIZE_12,SIZE_12)];
        shareImg5.tintColor = [UIColor colorWithCGColor:msgView.layer.borderColor];
        shareImg5.contentMode = UIViewContentModeScaleAspectFit;
        [self setShareImg:msgReadCount>0?fwdGreyIcon:fwdWhiteMsgIcon atView:shareImg5];
        shareCountVal++;
    }
    
    /*
    int shareFrameWidth = (shareCountVal) * SIZE_20;
    int shareFrameHeight = 0;
    */
    
    tickView.frame = CGRectMake(msgView.frame.origin.x + msgView.frame.size.width - rightOffset - 2, msgView.frame.origin.y - topOffset, tickViewHeight, tickViewHeight);
    
    
    UILabel* locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,
                                                msgView.frame.size.height+15,
                                                DEVICE_WIDTH - 20 - 8,
                                                [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2].lineHeight + 3)];
    
    locationLabel.textAlignment = NSTextAlignmentRight;
    locationLabel.backgroundColor = [UIColor clearColor];
    locationLabel.textColor = UIColorFromRGB(LOCATION_TEXT);
    locationLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    
    if([msgStatus isEqualToString:API_INPROGRESS] || [msgStatus isEqualToString:API_MSG_REQ_SENT])
    {
        KLog(@"Sending...");
    }
    else if([msgStatus isEqualToString:API_NETUNAVAILABLE])
    {
        KLog(@"*** Failed to send. Data connection error");
    }
    else if([msgStatus isEqualToString:API_UNSENT])
    {
        KLog(@"*** Failed to send.");
    }
    else
    {
        locationString = [self.dic valueForKey:LOCATION_NAME];
        if(locationString != nil)
        {
            locationLabel.text = locationString;
            [self.contentView addSubview:locationLabel];
        }
    }
}


- (IBAction)tappedOnCell:(id)sender
{
    /* TODO OCT 6
    // when the cell is tapped on, show the cell's location
    if (self.locationString && !self.locationCurrentlyShown) {
        self.timeLabel.text = [self.locationString stringByAppendingString:self.timeLabel.text];
        self.locationCurrentlyShown = YES;
    }
    else if(_timeString && self.locationCurrentlyShown) {
        self.timeLabel.text = _timeString;
        self.locationCurrentlyShown = NO;
    }*/
}

/*
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.contentViewstringText.editable) {
        return [super hitTest:point withEvent:event];
    }
    if (self.stringText.attributedText.length > 0 && CGRectContainsPoint(self.stringText.bounds, point)) {
        UITextPosition *position = [self.stringText closestPositionToPoint:point];
        
        UITextPosition *Pos1 = [self.stringText positionFromPosition:position offset:-1];
        UITextPosition *Pos2 = [self.stringText positionFromPosition:position offset:1];
        
        UITextRange *range = [self.stringText textRangeFromPosition:Pos1 toPosition:Pos2];
        
        NSInteger startOffset = [self.stringText offsetFromPosition:self.stringText.beginningOfDocument toPosition:range.start];
        NSInteger endOffset = [self.stringText offsetFromPosition:self.stringText.beginningOfDocument toPosition:range.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        NSURL *url = nil;
        if (offsetRange.location == NSNotFound) {
            return self.stringText.superview;
        }
        if (offsetRange.location +offsetRange.length > self.stringText.attributedText.length) {
            return self.stringText.superview;
        }
        @try {
            NSAttributedString *substring = [self.stringText.attributedText attributedSubstringFromRange:offsetRange];
            if ([substring length] > 0) {
                url = [substring attribute:NSLinkAttributeName atIndex:0 effectiveRange:Nil];
            }
        }
        @catch (NSException * e) {
            
        }
        if ([super hitTest:point withEvent:event] == self.stringText) {
            
            if (url) {
                return [super hitTest:point withEvent:event];
            } else {
                return self.stringText.superview;
            }
        } else {
            return[super hitTest:point withEvent:event];
        }
    } else {
        return [super hitTest:point withEvent:event];
    }
}*/

-(IBAction)deleteStaticMessageWithdraw:(id)sender
{
    if([self.delegate isAudioRecording])
        return;
    
    //NSLog(@"Delete Msg Withdrawn");
    [self.delegate deleteWithdrawn:(NSMutableDictionary*)self.dic withIndexPath:self.cellIndex];
}

-(void)setShareImg:(UIImage *)name atView:(UIImageView*)imgView
{
    name = [name imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [imgView setImage:name];
    imgView.hidden = NO;
    [self.contentView addSubview:imgView];
}

-(void) showMore
{
    if([self.delegate isAudioRecording])
        return;
    
    [self.delegate showMore:(NSMutableDictionary*)self.dic withIndexPath:self.cellIndex];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
