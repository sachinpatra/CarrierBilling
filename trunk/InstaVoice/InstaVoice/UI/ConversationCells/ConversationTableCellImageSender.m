//
//  ConversationTableCellImageSender.m
//  InstaVoice
//
//  Created by adwivedi on 22/07/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ConversationTableCellImageSender.h"
#import "IVFileLocator.h"
#import "IVMediaLoader.h"
#import "IVColors.h"

#define CORNER_RADIUS 4

@interface ConversationTableCellImageSender ()

//@property (weak, nonatomic) IBOutlet UIView *tickView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintForDistanceOfCheckView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainImageTopSpacingConstraint;
@end

@implementation ConversationTableCellImageSender

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    //self.mainImage.frame = CGRectMake(0,0,206,172);
    //DC JUNE 7 2016

    if ([[UIDevice currentDevice]systemVersion].floatValue >= 8.2) {
        self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, UIEdgeInsetsMake(0, 0, 0, 0));
    }
}


#pragma mark ChatView Sender/Receiver cell
//Setting for sender side conversation of chatView
-(void)configureCell
{
    NSString* msgType = [self.dic valueForKey:MSG_TYPE];
    
    //-  create the tick view
    int tickViewHeight = 20;
    int topOffset = 0;
    int rightOffset = 8;

    UIView *tickView = [self.contentView viewWithTag:1123];
    if (!tickView) {
        UIView* tickView = [[UIView alloc] initWithFrame:CGRectMake(self.dataView.frame.origin.x + self.dataView.frame.size.width - rightOffset, self.dataView.frame.origin.y - topOffset, tickViewHeight, tickViewHeight)];
        tickView.tag = 1123;
    }
    
    tickView.backgroundColor = [UIColor clearColor];
    for (CALayer *layer in [tickView.layer sublayers]) {
        [layer removeFromSuperlayer];
    }

    // create the masking layer for the tick view and apply it
    UIBezierPath *tickShape = [UIBezierPath bezierPath];
    [tickShape moveToPoint:CGPointMake(0, topOffset)];
    [tickShape addLineToPoint:CGPointMake(tickViewHeight, 0)];
    [tickShape addLineToPoint:CGPointMake(rightOffset + 2, tickViewHeight - 8)];
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
    [tickShapeNotClosed addLineToPoint:CGPointMake(rightOffset + 2, tickViewHeight - 8)];
    [tickShapeNotClosed addLineToPoint:CGPointMake(rightOffset + 2, tickViewHeight)];
    CAShapeLayer *tickShapeNotClosedLayer = [CAShapeLayer layer];
    tickShapeNotClosedLayer.path = tickShapeNotClosed.CGPath;
    tickShapeNotClosedLayer.lineWidth = 2;
    tickShapeNotClosedLayer.strokeColor = [IVColors greenOutlineColor].CGColor;
    tickShapeNotClosedLayer.fillColor = [IVColors greenFillColor].CGColor;
    [tickView.layer addSublayer:tickShapeNotClosedLayer];
    tickView.backgroundColor = [UIColor clearColor];
    
    //background setting
    int msgReadCount = [[self.dic valueForKey:MSG_READ_CNT]intValue];
    if(msgReadCount > 1)
        msgReadCount = 1;
    
    if([msgType isEqualToString:VB_TYPE]) {
        [self.dataView setBackgroundColor:[IVColors orangeFillColor]];
        self.annotation.backgroundColor = [IVColors orangeFillColor];
        [self.dataView.layer setBorderColor:[IVColors orangeOutlineColor].CGColor];
        [self.dataView.layer setBorderWidth:1];
        [self.dataView.layer setCornerRadius:CORNER_RADIUS];
        tickShapeNotClosedLayer.fillColor = [IVColors orangeFillColor].CGColor;
        tickShapeNotClosedLayer.strokeColor = [IVColors orangeOutlineColor].CGColor;
        [self.dataView setClipsToBounds:YES];
    } else if (([msgType isEqualToString:VSMS_TYPE])) {
        [self.dataView setBackgroundColor:[IVColors grayFillColor]];
        self.annotation.backgroundColor = [IVColors grayFillColor];
        [self.dataView.layer setBorderColor:[IVColors grayOutlineColor].CGColor];
        [self.dataView.layer setBorderWidth:1];
        [self.dataView.layer setCornerRadius:CORNER_RADIUS];
        tickShapeNotClosedLayer.fillColor = [IVColors grayFillColor].CGColor;
        tickShapeNotClosedLayer.strokeColor = [IVColors grayOutlineColor].CGColor;
        [self.dataView setClipsToBounds:YES];
    } else {
        [self.dataView setBackgroundColor:[IVColors greenFillColor]];
        self.annotation.backgroundColor = [IVColors greenFillColor];
        [self.dataView.layer setBorderColor:[IVColors greenOutlineColor].CGColor];
        [self.dataView.layer setBorderWidth:1];
        [self.dataView.layer setCornerRadius:CORNER_RADIUS];
        tickShapeNotClosedLayer.fillColor = [IVColors greenFillColor].CGColor;
        tickShapeNotClosedLayer.strokeColor = [IVColors greenOutlineColor].CGColor;
        [self.dataView setClipsToBounds:YES];
    }

    //- annotation setting
    NSString* annotation = [[self.dic valueForKey:ANNOTATION]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(annotation && annotation.length > 0)
    {
        //self.mainImageTopSpacingConstraint.constant = 30;
        self.annotation.hidden = NO;
        self.annotation.text = annotation;
        self.annotation.textColor = [UIColor blackColor];
        self.annotation.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        if (self.annotation.text.length >= 45) {
            self.annotation.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } else {
            self.annotation.textContainerInset = [UITextView new].textContainerInset;
        }

        if ([self.annotation respondsToSelector:@selector(linkTextAttributes)]) {
            
            UIColor *linkColor = [UIColor blackColor];
            
            if ([[UIDevice currentDevice].systemVersion floatValue] < 9) {
                //BUG8951
                UIFont* font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:self.annotation.text];
                [string addAttribute:NSForegroundColorAttributeName value:linkColor range:NSMakeRange(0,self.annotation.text.length)];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
                
                [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.annotation.text.length)];
                [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.annotation.text.length)];
                self.annotation.attributedText = string;
                self.annotation.dataDetectorTypes = UIDataDetectorTypeAll;
            }else{
                
                NSDictionary *attributes = @{
                                             NSForegroundColorAttributeName: linkColor,
                                             NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                             };
                self.annotation.linkTextAttributes = attributes;
            }
        }
    }
    else {
        self.annotation.hidden = YES;
        self.annotation.text = nil;
        self.mainImageTopSpacingConstraint.constant = -30;
        //[self.contentView insertSubview:tickView belowSubview:self.dataView];
        [self.contentView sendSubviewToBack:tickView];
    }
    [self.annotation setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    //image setting
    //in senders case we will have image data already present
    NSString* msgLocalPath = [self.dic valueForKey:MSG_LOCAL_PATH];
    UIImage *image = nil;
    if(msgLocalPath && msgLocalPath.length > 1)
    {
        NSString* localPath = [[IVFileLocator getMediaImagePath:msgLocalPath]stringByAppendingPathExtension:@"jpg"];
        if(localPath != nil)
        {
            image = [UIImage imageWithContentsOfFile:localPath];
            if(image)
			{
                self.mainImage.image = image;
                self.loadingView.hidden = YES;
                self.graySpinner.hidden = YES;
                [self.graySpinner stopAnimating];
            } /*else {
                NSLog(@"Debug");
            }*/
        }
    }
    if(image == Nil)
    {
        NSString *msgContent = [self.dic valueForKey:MSG_CONTENT];
        NSData *data = [msgContent dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSMutableDictionary *imageData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSMutableArray* imageArr = [imageData valueForKey:@"img"];
        for(NSMutableDictionary* imageDic in imageArr)
        {
            NSString* thumbnailURL = [imageDic valueForKey:@"thumb_url"];
            NSString* imageUrl = [imageDic valueForKey:@"url"];
            NSString* base64String = [imageDic valueForKey:@"thumb_base64"];
            
            NSString* msgLocalPath = [self.dic valueForKey:MSG_LOCAL_PATH];
            if(!msgLocalPath || msgLocalPath.length == 0)
            {
                msgLocalPath = [[self.dic valueForKey:MSG_ID]stringValue];
            }
            UIImage* imgThumbnail = [[IVMediaLoader sharedIVMediaLoader]getThumbnailImageForLocalPath:msgLocalPath serverPath:thumbnailURL base64String:base64String];
            
            UIImage* imgMain = [[IVMediaLoader sharedIVMediaLoader]getImageForLocalPath:msgLocalPath serverPath:imageUrl];
            
            if(imgMain)
            {
                self.mainImage.image = imgMain;
                self.loadingView.hidden = YES;
                self.graySpinner.hidden = YES;
                [self.graySpinner stopAnimating];
            }
            else if(imgThumbnail)
            {
                self.mainImage.image = imgThumbnail;
                self.loadingView.hidden = YES;
                self.graySpinner.hidden = YES;
                [self.graySpinner stopAnimating];
            }
            else
            {
                self.mainImage.image = nil;
                self.loadingView.hidden = NO;
                self.loadingView.hidden = YES;
                [self.graySpinner startAnimating];
            }
        }
    }


    //button setting
    [self.buttonOverMainImage setTag:self.cellIndex.row];
    [self.buttonOverMainImage addTarget:self
                                 action:@selector(imgTappedMsgAction)
                       forControlEvents:UIControlEventTouchUpInside];
    
    //time and location setting
    NSString* msgStatus = [self.dic valueForKey:MSG_STATE];
    NSString* locationString = @"";
    /*
    if([msgStatus isEqualToString:API_INPROGRESS] || [msgStatus isEqualToString:API_MSG_REQ_SENT])
    {
        KLog(@"Sending...");
    }
    else if([msgStatus isEqualToString:API_NETUNAVAILABLE])
    {
        KLog(@"*** Failed to send. Data connection error.");
    }
    else if([msgStatus isEqualToString:API_UNSENT])
    {
        KLog(@"*** Failed to send.");
    }
    else*/
    {
        
        NSNumber *date = [self.dic valueForKey:MSG_DATE];
        NSString* timeString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
        self.timeStamp.text = timeString;
        locationString = [self.dic valueForKey:LOCATION_NAME];
        if(locationString != nil)
        {   self.location.text = locationString;
        }else{
            self.location.text = @"";
        }
    }

    self.location.textAlignment = NSTextAlignmentRight;
    self.location.backgroundColor = [UIColor clearColor];
    self.location.textColor = UIColorFromRGB(LOCATION_TEXT);
    self.location.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    
    //self.timeStamp.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    self.timeStamp.backgroundColor = [UIColor clearColor];
    self.timeStamp.textColor = UIColorFromRGB(MSG_TIME_TEXT);
    self.timeStamp.textAlignment = NSTextAlignmentRight;
    [self.timeStamp setFont:[UIFont systemFontOfSize:11.0]];
    
    //- set up tick image or hour glass
    NSString* msgState = [self.dic valueForKey:MSG_STATE];
    NSString* tickImageName = @"";
    if (MessageReadStatusRead == msgReadCount) {
        if ([[self.dic valueForKey:CONVERSATION_TYPE] isEqualToString:GROUP_TYPE])
            tickImageName = @"single_tick";
        else
            tickImageName = @"double_tick";
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
    
    NSMutableString* dateString = [[NSMutableString alloc]initWithString:@" "];
    [dateString appendString:self.timeStamp.text];
    
    //combine image and label
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    if(![msgState isEqualToString:API_WITHDRAWN]) {
        attachment.image = [UIImage imageNamed:tickImageName];
    }
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:dateString];
    [myString insertAttributedString:attachmentString atIndex:0];
    self.timeStamp.attributedText = myString;
    //

#ifndef REACHME_APP
    NSString *linkedOPR = [self.dic valueForKey:LINKED_OPR];
    BOOL likeBool =   [[self.dic valueForKey:MSG_LIKED] boolValue];
    BOOL twBool   =   [[self.dic valueForKey:MSG_TW_POST] boolValue];
    BOOL fbBool   =   [[self.dic valueForKey:MSG_FB_POST] boolValue];
    BOOL vbBool   =   [[self.dic valueForKey:MSG_VB_POST] boolValue];
    BOOL ivBool   =   [[self.dic valueForKey:MSG_FORWARD] boolValue];
    BOOL fwdBool  =   [linkedOPR isEqualToString:IS_FORWORD_MSG];
    
    likeBool = NO;
    twBool = NO;
    fbBool = NO;
    ivBool = NO;
    fwdBool = NO;
    
    self.shareIconViewHeight.constant = 20;
    self.shareImg1.hidden = YES;
    self.shareImg2.hidden = YES;
    self.shareImg3.hidden = YES;
    self.shareImg4.hidden = YES;
    self.shareImg5.hidden = YES;
    
    int shareCountVal = 1;
    if(likeBool) {
        [self setShareImg:@"share-icon-like" atPosition:shareCountVal];
        shareCountVal++;
    }
    if(ivBool)
    {
        [self setShareImg:@"share-icon-iv" atPosition:shareCountVal];
        shareCountVal++;
    }
    if(fbBool)
    {
        [self setShareImg:@"share-icon-fb" atPosition:shareCountVal];
        shareCountVal++;
    }
    if(twBool)
    {
        [self setShareImg:@"share-icon-tw" atPosition:shareCountVal];
        shareCountVal++;
    }
    if(vbBool && ![msgType isEqualToString:VB_TYPE])
    {
        [self setShareImg:@"share-icon-vb" atPosition:shareCountVal];
        shareCountVal++;
    }
    if(fwdBool)
    {
        [self setShareImg:@"share-icon-fwd" atPosition:shareCountVal];
        shareCountVal++;
    }
    
    //DEBUG self.timeStamp.layer.borderWidth = 1;
#endif
    
}


-(void)setShareImg:(NSString *)name atPosition:(NSInteger)shareCountValue
{
    UIImageView* imageView = nil;
    switch(shareCountValue) {
        case 1:
            imageView = self.shareImg1;
            break;
        case 2:
            imageView = self.shareImg2;
            break;
        case 3:
            imageView = self.shareImg3;
            break;
        case 4:
            imageView = self.shareImg4;
            break;
        case 5:
            imageView = self.shareImg5;
            break;
    }
    
    if(nil != imageView) {
        if([name length]) {
            UIImage* img = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [imageView setImage:img];
            imageView.hidden = NO;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
}

/* DEC 24, 2016
-(NSInteger)setShareImg:(NSString *)name atPosition:(NSInteger)shareCountValue
{
    self.shareIconViewHeight.constant = 20;
    switch (shareCountValue) {
        case 0:
        {
            [self.shareImg1 setImage:[[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            self.shareImg1.hidden = NO;
        }
            break;
        case 1:
        {
            [self.shareImg2 setImage:[[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            self.shareImg2.hidden = NO;
        }
            break;
        case 2:
        {
            [self.shareImg3 setImage:[[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            self.shareImg3.hidden = NO;
        }
            break;
        case 3:
        {
            [self.shareImg4 setImage:[[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            self.shareImg4.hidden = NO;
        }
            break;
        case 4:
        {
            [self.shareImg5 setImage:[[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            self.shareImg5.hidden = NO;
            
        }
            break;
        default:
            self.shareIconViewHeight.constant = 0;
            break;
    }
    shareCountValue = shareCountValue +1;
    return shareCountValue;
}*/


- (IBAction)tappedOnCell:(id)sender
{
    /* TODO OCT 6
    // when the cell is tapped on, show the cell's location
    if (self.locationString && !self.locationCurrentlyShown) {
        self.location.text = [self.locationString stringByAppendingString:self.location.text];
        self.locationCurrentlyShown = YES;
    }
    else if(_timeString && self.locationCurrentlyShown) {
        self.location.text = _timeString;
        self.locationCurrentlyShown = NO;
    }*/
}

//Jan 19, 2017
-(void)imgTappedMsgAction {
    [self.delegate imageTappedAtIndex:self.cellIndex];
}

//

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
