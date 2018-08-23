//
//  ConversationTableCellTextReceiver.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 5/20/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "ConversationTableCellTextReceiver.h"
#import "SharedMenuLabel.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"
#import "IVColors.h"
#import "ScreenUtility.h"

@interface ConversationTableCellTextReceiver ()
@end

@implementation ConversationTableCellTextReceiver

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
    UIButton      *showMore             = nil;
    UITextView    *msgLabel             = nil;
    UILabel       *fromUserLabel        = nil;
    //UIImageView   *likeImage            = nil;
    NSString      *locationString       = nil;
    NSString      *timeLocationString   = nil;
    SharedMenuLabel *sharedLabel = nil;

    NSString *msgContentType = [[self.dic valueForKey:MSG_CONTENT_TYPE]lowercaseString];
    NSString *msgContent = [self.dic valueForKey:MSG_CONTENT];
    NSString *linkedOPR = [self.dic valueForKey:LINKED_OPR];
    NSString* msgState = [self.dic valueForKey:MSG_STATE];
    BOOL isMsgWithdrawn = [msgState isEqualToString:API_WITHDRAWN];
    
    BOOL likeBool = [[self.dic valueForKey:MSG_LIKED] boolValue];
    BOOL twBool = [[self.dic valueForKey:MSG_TW_POST] boolValue];
    BOOL fbBool = [[self.dic valueForKey:MSG_FB_POST] boolValue];
    BOOL vbBool = [[self.dic valueForKey:MSG_VB_POST] boolValue];
    BOOL ivBool = [[self.dic valueForKey:MSG_FORWARD] boolValue];
    BOOL fwdBool = [linkedOPR isEqualToString:IS_FORWORD_MSG];
    
    UIImageView *msgView = nil;
    if([msgContentType isEqualToString:TEXT_TYPE])
    {
        showMore = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        showMore.frame = CGRectZero;
        
        msgLabel = [[UITextView alloc] init];
        msgLabel.delegate = self.baseConversationObj;
        msgLabel.backgroundColor = [UIColor clearColor];
        msgLabel.userInteractionEnabled = YES;
        msgLabel.selectable = YES;
        msgLabel.scrollEnabled = NO;
        msgLabel.editable = NO;
        msgLabel.textAlignment = NSTextAlignmentLeft;
        msgLabel.dataDetectorTypes = UIDataDetectorTypeAll;
        
        if(!isMsgWithdrawn)
        {
            NSNumber *value = [self.dic valueForKey:@"toShowMore"];
            if(msgContent.length > SHOW_MORE_LEN && (value == nil || [value intValue] == 1)) {
                NSRange stringRange = {0, MIN([msgContent length], SHOW_MORE_LEN)};
                msgContent = [msgContent substringWithRange:stringRange];
                [self.dic setValue:[NSNumber numberWithInt:1] forKey:@"toShowMore"];
                [self.contentView addSubview:showMore];
                
                msgLabel.text = [NSString stringWithFormat:@"%@....", msgContent];
            }
            else {
                if(value == nil ) {
                    [self.dic setValue:[NSNumber numberWithInt:2] forKey:@"toShowMore"];
                }
                msgLabel.text = msgContent;
            }
        }
        else
        {
            msgLabel.text = msgContent;
            msgLabel.selectable = YES;
        }
        
        [msgLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [arrayDictionary replaceObjectAtIndex:self.cellIndex.row withObject:self.dic];//TEST Jan 19, 2017
        //Height calculations R&D Bhaskar Feb 7
        CGSize lableWidth = CGSizeMake(DEVICE_WIDTH - 80, CGFLOAT_MAX);
        CGSize neededSize = [msgLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
        CGFloat msgLblX = SIZE_20;//DEVICE_WIDTH - (expected.width+30);
        CGFloat msgLblY = 12;
        CGFloat msgLblW = neededSize.width+10;
        CGFloat msgLblH = neededSize.height + 10;
        
        CGFloat newWidth = msgLblW + 70;
        //CGFloat newHeight = msgLblH;
        if(msgContent.length < SHOW_MORE_LEN) {
            if(newWidth >= (DEVICE_WIDTH-50)) {
                newWidth -= 50;
                msgLblH += 3;
            }
            msgLabel.frame = CGRectMake(msgLblX, msgLblY, newWidth - 10, msgLblH);
        }
        else {
            msgLabel.frame = CGRectMake(msgLblX, msgLblY, msgLblW - 10, msgLblH);
        }
        
        if ([msgLabel respondsToSelector:@selector(linkTextAttributes)] && !isMsgWithdrawn) {
            //FEB 8
            UIColor *linkColor = [UIColor blackColor];
            if ([[UIDevice currentDevice].systemVersion floatValue] < 9) {
                UIFont* font =  [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:msgLabel.text];
                [string addAttribute:NSForegroundColorAttributeName value:linkColor range:NSMakeRange(0,msgLabel.text.length)];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
                
                [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, msgLabel.text.length)];
                [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, msgLabel.text.length)];
                msgLabel.attributedText = string;
                msgLabel.dataDetectorTypes = UIDataDetectorTypeAll;
            }else {
                
                NSDictionary *attributes = @{
                                             NSForegroundColorAttributeName: linkColor,
                                             NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                             };
                msgLabel.linkTextAttributes = attributes;
            }
            //
        }
        
        if([[self.dic valueForKey:MSG_TYPE] isEqualToString:VSMS_TYPE]) {
            msgView = [[UIImageView alloc] initWithImage:[UIImage new]];
            msgView.backgroundColor = [IVColors grayFillColor];
            msgView.layer.borderColor = [IVColors grayOutlineColor].CGColor;
            msgView.layer.borderWidth = 1;
            msgView.layer.cornerRadius = 4;
        }
        else if([[self.dic valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE]) {
            msgView = [[UIImageView alloc] initWithImage:[UIImage new]];
            msgView.backgroundColor = [IVColors orangeFillColor];
            msgView.layer.borderColor = [IVColors orangeOutlineColor].CGColor;
            msgView.layer.borderWidth = 1;
            msgView.layer.cornerRadius = 4;
        }
        else {
            msgView = [[UIImageView alloc] initWithImage:[UIImage new]];
            msgView.backgroundColor = [IVColors blueFillColor];
            msgView.layer.borderColor = [IVColors blueOutlineColor].CGColor;
            msgView.layer.borderWidth = 1;
            msgView.layer.cornerRadius = 4;
            self.tintColor = [IVColors blueOutlineColor];
        }
        
        if(isMsgWithdrawn) {
            [msgLabel setFont:[UIFont italicSystemFontOfSize:msgLabel.font.pointSize]];
            msgLabel.textColor = [UIColor grayColor];
        }
        
        if(msgContent.length < SHOW_MORE_LEN) {
            if(newWidth > (DEVICE_WIDTH-50)) {
                newWidth -= 50;
            }
            msgView.frame = CGRectMake(msgLblX,msgLblY+3,newWidth,msgLblH);
        } else {
            msgView.frame = CGRectMake(msgLblX,msgLblY+3,msgLblW+50,msgLblH);
        }
        
        
        if ((msgView.frame.size.width > (DEVICE_WIDTH - 80)) || (msgLabel.frame.size.width > (DEVICE_WIDTH - 80))) {
            msgView.frame = CGRectMake(20,msgLblY+3,DEVICE_WIDTH - 80,msgLblH);
            msgLabel.frame = CGRectMake(20, msgLblY+4, DEVICE_WIDTH - 80, msgLblH);
        } else {
            //KLog(@"Debug");
        }
        
        //debug blank text bubble
         NSNumber *valueToGet = [self.dic valueForKey:@"toShowMore"];//written by rakesh
        if(fbBool || vbBool || twBool || ivBool || fwdBool ||  (valueToGet && [valueToGet intValue]!=2) )
        {
            if([valueToGet intValue]!=2)
            {
                showMore.frame = CGRectMake(msgLabel.frame.origin.x + 13,
                                            msgLabel.frame.size.height,
                                            SIZE_120,SIZE_40);
                
                showMore.titleLabel.textAlignment = NSTextAlignmentLeft;
                //showMore.layer.borderWidth = 1;//DEBUG
                [showMore setTitleEdgeInsets:UIEdgeInsetsMake(-10.0f, -15.0f, 0.0f, 0.0f)];
                [showMore setTitleEdgeInsets:UIEdgeInsetsMake(10.0, 0.0, 10.0, 0.0)];
                if([valueToGet intValue]==1) {
                    [showMore setTitle:@"+ Show More" forState:UIControlStateNormal];
                } else {
                    [showMore setTitle:@"- Show Less" forState:UIControlStateNormal];
                }
                
                showMore.titleLabel.font  = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
                [showMore setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [showMore addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    
        // create the tick view
        int tickViewHeight = 16;
        int topOffset = 0;
        int rightOffset = tickViewHeight - 6;
        UIView *tickView = [[UIView alloc] initWithFrame:CGRectMake(msgView.frame.origin.x - rightOffset, msgView.frame.origin.y - topOffset, tickViewHeight, tickViewHeight)];
        tickView.backgroundColor = [UIColor clearColor];

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
        tickShapeNotClosedLayer.strokeColor = msgView.layer.borderColor;
        tickShapeNotClosedLayer.fillColor = msgView.backgroundColor.CGColor;
        [tickView.layer addSublayer:tickShapeNotClosedLayer];
        
        //FEB 8
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
        //

        msgView.userInteractionEnabled = NO;
        msgLabel.userInteractionEnabled = NO;
        
        [self.contentView addSubview:msgView];
        [self.contentView addSubview:tickView];
        [self.contentView addSubview:msgLabel];
        if(!isMsgWithdrawn)
            [self.contentView addSubview:showMore];

        if(valueToGet && valueToGet != nil) {
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMore)];
            [tap setNumberOfTapsRequired:1];
            [self.contentView addGestureRecognizer:tap];
        }
        
        if(isMsgWithdrawn) {
            fwdBool = ivBool = fbBool = vbBool = twBool = likeBool = FALSE;
        }
        
        ivBool = 0;
        likeBool = 0;
        twBool = 0;
        fbBool = 0;
        fwdBool = 0;
        
        int shareCountVal = 0;
        int deltaWidth = 8;
        
        if(likeBool) {
            UIImageView* likeImage = [[UIImageView alloc]initWithFrame:CGRectMake(msgLabel.frame.origin.x+deltaWidth,
                                                                                  msgLabel.frame.size.height+SIZE_1,
                                                                                  SIZE_15,SIZE_12)];
            UIImage* img = [[UIImage imageNamed:@"share-icon-like"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            likeImage.tintColor = [IVColors redColor];
            likeImage.contentMode = UIViewContentModeScaleAspectFit;
            [self setShareImg:img atView:likeImage];
            deltaWidth=30;
            shareCountVal++;
        }
        
        if(ivBool)
        {
            UIImageView* shareImg1 = [[UIImageView alloc]initWithFrame:CGRectMake(msgLabel.frame.origin.x+deltaWidth,
                                                                     msgLabel.frame.size.height+SIZE_5,
                                                                     SIZE_15,SIZE_12)];
            shareImg1.tintColor = [UIColor colorWithCGColor:msgView.layer.borderColor];
            shareImg1.contentMode = UIViewContentModeScaleAspectFit;
            [self setShareImg:instaGreyIcon atView:shareImg1];
            deltaWidth+=20;
            shareCountVal++;
        }
        
        if(fbBool)
        {
            UIImageView* shareImg2 = [[UIImageView alloc]initWithFrame:CGRectMake(msgLabel.frame.origin.x+deltaWidth,
                                                                     msgLabel.frame.size.height+SIZE_1,
                                                                     SIZE_12,SIZE_12)];
            shareImg2.tintColor = [UIColor colorWithCGColor:msgView.layer.borderColor];
            shareImg2.contentMode = UIViewContentModeScaleAspectFit;
            [self setShareImg:fbGreyIcon atView:shareImg2];
            deltaWidth += 20;
            shareCountVal++;
        }
        /* DEC 26, 2016
        if(vbBool)
        {
            UIImageView* shareImg3 = [[UIImageView alloc]initWithFrame:CGRectMake(theTim-deltaWidth,
                                                                     msgLabel.frame.size.height+SIZE_1,
                                                                     SIZE_12,SIZE_12)];
            shareImg3.contentMode = UIViewContentModeScaleAspectFit;
            [self setShareImg:vbGreyIcon atView:shareImg3];
            deltaWidth += 20;
            shareCountVal++;
        }*/
        
        if(twBool)
        {
            UIImageView* shareImg4 = [[UIImageView alloc]initWithFrame:CGRectMake(msgLabel.frame.origin.x+deltaWidth,
                                                                     msgLabel.frame.size.height+SIZE_1,
                                                                     SIZE_12,SIZE_12)];
            shareImg4.tintColor = [UIColor colorWithCGColor:msgView.layer.borderColor];
            shareImg4.contentMode = UIViewContentModeScaleAspectFit;
            [self setShareImg:twitterGreyIcon atView:shareImg4];
            deltaWidth += 20;
            shareCountVal++;
        }
        
        if(fwdBool)
        {
            UIImageView* shareImg5 = [[UIImageView alloc]initWithFrame:CGRectMake(msgLabel.frame.origin.x+deltaWidth,
                                                                     msgLabel.frame.size.height+SIZE_1,
                                                                     SIZE_12,SIZE_12)];
            shareImg5.tintColor = [UIColor colorWithCGColor:msgView.layer.borderColor];
            shareImg5.contentMode = UIViewContentModeScaleAspectFit;
            [self setShareImg:fwdGreyIcon atView:shareImg5];
            shareCountVal++;
        }
        
        int shareFrameWidth = (shareCountVal) * SIZE_20;
        int shareFrameHeight = 0;
        
        if(shareCountVal>0 || (valueToGet && [valueToGet intValue]!=2))
        {
            shareFrameHeight = SIZE_12;
            if(msgView.frame.size.width < shareFrameWidth + 10)
            {
                msgView.frame = CGRectMake(
                                    SIZE_20,
                                    msgView.frame.origin.y,
                                    MAX(msgView.frame.size.width, shareFrameWidth + SIZE_20) + 5,
                                    msgLabel.frame.size.height + shareFrameHeight);
            }
            else
            {
                msgView.frame = CGRectMake(
                                           SIZE_20,
                                           msgView.frame.origin.y,
                                           msgView.frame.size.width,
                                           msgLabel.frame.size.height + shareFrameHeight);
            }
            
            
            
        }
        
        if(!isMsgWithdrawn) {
            sharedLabel = [[SharedMenuLabel alloc]init];
            [sharedLabel setTag:self.cellIndex];
            sharedLabel.stringText = msgLabel;
            sharedLabel.stringToCopy = msgContent;
            sharedLabel.userInteractionEnabled = YES;
            sharedLabel.stringText.editable = NO;
            sharedLabel.stringText.dataDetectorTypes = UIDataDetectorTypeAll;
            [sharedLabel setFrame:msgLabel.frame];
            [sharedLabel setBackgroundColor:[UIColor clearColor]];
            SEL selectorAction = @selector(tapOnLink:);
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                         action:selectorAction];
            [sharedLabel addGestureRecognizer:tapGesture];
            [self.contentView addSubview:sharedLabel];
        }
        
        //OCT 6, 2016
        if(isMsgWithdrawn) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
            CGRect frame = button.frame;
            frame.origin.y += 2;
            frame.size.width -= 4;
            frame.size.height = frame.size.width;
            button.frame = frame;
            
            [button addTarget:self action:@selector(popupInfo) forControlEvents:UIControlEventTouchUpInside];
            button.userInteractionEnabled = YES;
            msgView.userInteractionEnabled = YES;
            msgView.frame = CGRectMake(msgView.frame.origin.x,
                                       msgView.frame.origin.y,
                                       msgView.frame.size.width+button.frame.size.width + 18.0,
                                       msgView.frame.size.height);
            
            msgLabel.frame = CGRectMake(msgLabel.frame.origin.x+button.frame.size.width,
                                        msgLabel.frame.origin.y,
                                        msgLabel.frame.size.width+button.frame.size.width,
                                        msgLabel.frame.size.height);
            
            CGRect buttonFrame = button.frame;
            buttonFrame.origin.x += 3;
            buttonFrame.origin.y += 8;
            button.tintColor = [IVColors colorWithHexString:@"ff6600"];
            [button setFrame:buttonFrame];
            [msgView addSubview:button];
        }
        //
    }
    
    
    //DEC 26, 2016
    //////////DEC 20
    //- Set up time with tick image or hour glass
    NSNumber *date  = [self.dic valueForKey:MSG_DATE];
    NSString* timeString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
    UILabel* theTimeLabel = nil;
    if(msgContent.length < SHOW_MORE_LEN) {
        theTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(
                                                                msgView.frame.size.width - 44,
                                                                msgView.frame.size.height - 5,
                                                                52, 20)];
    } else {
        theTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(
                                                                msgView.frame.size.width - 44,
                                                                msgLabel.frame.size.height,
                                                                52, 30)];
    }
    theTimeLabel.textAlignment = NSTextAlignmentRight;
    theTimeLabel.text = timeString;
    theTimeLabel.textColor = UIColorFromRGB(MSG_TIME_TEXT);
    theTimeLabel.font = [UIFont systemFontOfSize:11.0];
    [self.contentView addSubview:theTimeLabel];
    
    UIButton *msgWithdrawDelete = nil;
    if(isMsgWithdrawn) {
        CGSize lableWidth = CGSizeMake(theTimeLabel.frame.size.width, CGFLOAT_MAX);
        CGSize neededSize = [theTimeLabel sizeThatFits:CGSizeMake(lableWidth.width, CGFLOAT_MAX)];
        msgWithdrawDelete = [[UIButton alloc]initWithFrame:CGRectMake(msgView.frame.size.width - neededSize.width - 12, msgView.frame.size.height - 10, 24, 31)];
        [msgWithdrawDelete setImage:[UIImage imageNamed:@"dellWithdrawn"] forState:UIControlStateNormal];
        [msgWithdrawDelete addTarget:self action:@selector(deleteStaticMessageWithdrawReciever:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:msgWithdrawDelete];
        
    }
    
    ////////////
    
    if(vbBool)
    {
        UIImageView* shareImg3 = [[UIImageView alloc]initWithFrame:CGRectMake(theTimeLabel.frame.origin.x-10,theTimeLabel.frame.origin.y + 4, SIZE_12,SIZE_12)];
        shareImg3.contentMode = UIViewContentModeScaleAspectFit;
        [self setShareImg:vbGreyIcon atView:shareImg3];
    }
    
    
    
    UILabel* locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(msgView.frame.origin.x, msgView.frame.size.height+15, DEVICE_WIDTH - 140, [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2].lineHeight + 3)];
    
    locationLabel.textAlignment = NSTextAlignmentLeft;
    locationLabel.backgroundColor = [UIColor clearColor];
    locationLabel.textColor = UIColorFromRGB(LOCATION_TEXT);
    locationLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    
    
    /////////////////////
    
    timeLocationString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
    locationString = [self.dic valueForKey:LOCATION_NAME];
    if([locationString length])
    {
        locationLabel.text = locationString;
        [self.contentView addSubview:locationLabel];
    }

    UIButton *callBackButton = (UIButton *)[self.contentView viewWithTag:8770];
    if (!callBackButton) {
        callBackButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 50, msgView.center.y - 22, 44, 44)];
        callBackButton.tag = 8770;
        [callBackButton setImage:[[UIImage imageNamed:@"return-call"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [callBackButton setImage:[[UIImage imageNamed:@"return-call-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]  forState:UIControlStateHighlighted];
        [self.contentView addSubview:callBackButton];
    }
    callBackButton.hidden = YES;
    [callBackButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    
    fromUserLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, -2,
                                                DEVICE_WIDTH - 20,
                                                [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2].pointSize+3)];
	
    fromUserLabel.textColor = UIColorFromRGB(FROM_USER_TEXT);
    fromUserLabel.backgroundColor = [UIColor clearColor];
    [fromUserLabel setFont:[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2]];
    
    if([[self.dic valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE]) {
        fromUserLabel.hidden = NO;
        fromUserLabel.frame = CGRectMake(locationLabel.frame.origin.x, -2,DEVICE_WIDTH - 20,[Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2].pointSize+3);
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithDictionary:self.dic]; //TODO CHECK
        fromUserLabel.text = [self getGroupMemberNameFromDic:dic];
    }
    else {
        fromUserLabel.hidden = YES;
    }
    
    fromUserLabel.numberOfLines = 0;
    [self.contentView addSubview:fromUserLabel];
}

-(void)setShareImg:(UIImage *)name atView:(UIImageView*)imgView
{
    name = [name imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [imgView setImage:name];
    imgView.hidden = NO;
    [self.contentView addSubview:imgView];
}


-(void)popupInfo
{
    if([self.delegate isAudioRecording])
        return;
#ifdef REACHME_APP
    [ScreenUtility showAlert:@"With ReachMe, sent messages can be withdrawn. Long press on any sent message for the withdraw option"];
#else
    [ScreenUtility showAlert:@"With InstaVoice, sent messages can be withdrawn. Long press on any sent message for the withdraw option"];
#endif
}

- (IBAction)tappedOnCell:(id)sender
{
    /* TODO OCT 6
    // when the cell is tapped on, show the cell's location
    if (self.locationString && !self.locationCurrentlyShown) {

        // if we are in a group chat, we need to keep the attributed string, otherwise we can just do normal appending.
        if ([[self.dic valueForKey:CONVERSATION_TYPE] isEqualToString:GROUP_TYPE]) {
            NSMutableAttributedString *currentString = [self.timeLabel.attributedText mutableCopy];

            NSDictionary *attributesForNewString = @{NSForegroundColorAttributeName: [IVColors lightGreyColor],
                                                     NSFontAttributeName: TimeStampFont};
            NSAttributedString *stringToAppend = [[NSAttributedString alloc] initWithString:self.locationString attributes:attributesForNewString];

            [currentString appendAttributedString:stringToAppend];
            self.timeLabel.attributedText = currentString;
        } else {
            if([self.locationString length]>1) {
                self.timeLabel.text = [self.timeLabel.text stringByAppendingString:self.locationString];
                self.locationCurrentlyShown = YES;
            }
        }
    }
    else if (_timeString && self.locationCurrentlyShown) {
        if([_timeString length] > 1) {
            self.timeLabel.text = _timeString;
            self.locationCurrentlyShown = NO;
        }
    }
     */
}

-(IBAction)deleteStaticMessageWithdrawReciever:(id)sender
{
    if([self.delegate isAudioRecording])
        return;
    
    //NSLog(@"Delete Receiver Msg Withdrawn");
    [self.delegate deleteWithdrawn:(NSMutableDictionary*)self.dic withIndexPath:self.cellIndex];
}


-(IBAction) showMore
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

-(void)dealloc {
    KLog(@"Dealloc");
}

@end
