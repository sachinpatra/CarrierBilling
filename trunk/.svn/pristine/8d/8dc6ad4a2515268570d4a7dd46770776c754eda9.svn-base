//
//  ConversationTableCellImageReceiver.m
//  InstaVoice
//
//  Created by adwivedi on 22/07/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ConversationTableCellImageReceiver.h"
#import "IVFileLocator.h"
#import "IVMediaLoader.h"
#import "IVColors.h"

@interface ConversationTableCellImageReceiver ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainImageTopSpacingConstraint;
@end

@implementation ConversationTableCellImageReceiver


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
//Setting for Left(Receiver) side conversation of chatView
-(void)configureCell
{
    NSString* msgType = [self.dic valueForKey:MSG_TYPE];

    if( [[self.dic valueForKey:REMOTE_USER_TYPE] isEqualToString:CELEBRITY_TYPE]) {
         msgType = CELEBRITY_TYPE;
    }
    
    // create the tick view
    int tickViewHeight = 16;
    int topOffset = 0;
    int rightOffset = tickViewHeight - 6;

    UIView* tickView = [[UIView alloc] initWithFrame:CGRectMake(self.dataView.frame.origin.x - rightOffset,
                                                                self.dataView.frame.origin.y - topOffset,
                                                                tickViewHeight, tickViewHeight)];
    [tickView setTag:TICK_VIEW_ID];
    
    tickView.backgroundColor = [UIColor clearColor];
    for (CALayer *layer in [tickView.layer sublayers]) {
        [layer removeFromSuperlayer];
    }

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

    if ([[self.dic valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE]) {
        tickShapeNotClosedLayer.fillColor = [IVColors orangeFillColor].CGColor;
        tickShapeNotClosedLayer.strokeColor = [IVColors orangeOutlineColor].CGColor;
    }

    [tickView.layer addSublayer:tickShapeNotClosedLayer];
    if ([msgType isEqualToString:CELEBRITY_TYPE] || [[self.dic valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE]) {
        [self.dataView setBackgroundColor:[IVColors orangeFillColor]];
        [self.dataView.layer setBorderColor:[IVColors orangeOutlineColor].CGColor];
        [self.dataView.layer setBorderWidth:1];
        self.annotation.backgroundColor = [IVColors orangeFillColor];
        [self.dataView setClipsToBounds:YES];
        tickShapeNotClosedLayer.strokeColor = [IVColors orangeOutlineColor].CGColor;
        tickShapeNotClosedLayer.fillColor = [IVColors orangeFillColor].CGColor;
        self.dataView.layer.cornerRadius = 4;
    } else {
        [self.dataView setBackgroundColor:[IVColors blueFillColor]];
        [self.dataView.layer setBorderColor:[IVColors blueOutlineColor].CGColor];
        [self.dataView.layer setBorderWidth:1];
        self.annotation.backgroundColor = [IVColors blueFillColor];
        [self.dataView setClipsToBounds:YES];
        tickShapeNotClosedLayer.strokeColor = [IVColors blueOutlineColor].CGColor;
        tickShapeNotClosedLayer.fillColor = [IVColors blueFillColor].CGColor;
        self.dataView.layer.cornerRadius = 4;
    }

    tickShapeNotClosedLayer.strokeColor = self.dataView.layer.borderColor;
    tickShapeNotClosedLayer.fillColor = self.dataView.backgroundColor.CGColor;
	//
    //annotation setting
    NSString* annotation = [[self.dic valueForKey:ANNOTATION]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(annotation && annotation.length > 0)
    {
        self.annotation.hidden = NO;
        self.annotation.text = annotation;
        self.annotation.textColor = [UIColor blackColor];
        self.annotation.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        self.annotation.scrollEnabled = NO;
        self.annotation.selectable = YES;
        self.annotation.editable = NO;
        self.annotation.dataDetectorTypes = UIDataDetectorTypeAll;
        //KLog(@"Text length for caption \"%@\":  %lu", self.annotation.text, (unsigned long)self.annotation.text.length);
        if (self.annotation.text.length >= 45) {
            self.annotation.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } else {
            self.annotation.textContainerInset = [UITextView new].textContainerInset;
        }

        self.dataView.layer.cornerRadius = 4;
        self.dataView.clipsToBounds = YES;
    
        if ([self.annotation respondsToSelector:@selector(linkTextAttributes)]) {
            UIColor *linkColor = [UIColor blackColor];
            if ([[UIDevice currentDevice].systemVersion floatValue] < 9) {
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
        
        if (self.dataView.frame.size.height > tickView.frame.size.height) {
            self.dataView.frame = CGRectMake(self.dataView.frame.origin.x, self.dataView.frame.origin.y, self.dataView.frame.size.width, tickView.frame.size.height);
        }

        [self.contentView addSubview:tickView];
    }
    else {
        self.annotation.hidden = YES;
        self.mainImageTopSpacingConstraint.constant = -30;
        [self.contentView insertSubview:tickView belowSubview:self.dataView];
    }
    
    //main image setting
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
            msgLocalPath = [[self.dic valueForKey:MSG_ID] stringValue];
        }
        UIImage* imgThumbnail = [[IVMediaLoader sharedIVMediaLoader]getThumbnailImageForLocalPath:msgLocalPath serverPath:thumbnailURL base64String:base64String];
        
        UIImage* imgMain = [[IVMediaLoader sharedIVMediaLoader]getImageForLocalPath:msgLocalPath serverPath:imageUrl];
        
        if (imgMain)
		{
            self.mainImage.image = imgMain;
            self.loadingView.hidden = YES;
            [self.graySpinner stopAnimating];
        }
		else if (imgThumbnail)
		{
			self.mainImage.image = imgThumbnail;
            self.loadingView.hidden = YES;
            [self.graySpinner stopAnimating];
        }
		else
		{
            self.mainImage.image = nil;
            self.loadingView.hidden = NO;
            [self.graySpinner startAnimating];
        }
    }
    
    //button setting
    [self.buttonOverMainImage setTag:self.cellIndex.row];
    [self.buttonOverMainImage addTarget:self
                                 action:@selector(imgTappedMsgAction)
                       forControlEvents:UIControlEventTouchUpInside];
    
    
    //- Location and time setting
    self.location.textAlignment = NSTextAlignmentRight;
    self.location.backgroundColor = [UIColor clearColor];
    self.location.textColor = UIColorFromRGB(LOCATION_TEXT);
    self.location.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    
    self.timeStamp.backgroundColor = [UIColor clearColor];
    self.timeStamp.textColor = UIColorFromRGB(MSG_TIME_TEXT);
    self.timeStamp.textAlignment = NSTextAlignmentRight;
    self.timeStamp.font = [UIFont systemFontOfSize:11.0];
    
    self.annotation.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.fromName.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption2];
    
    NSString* locationString = [self.dic valueForKey:LOCATION_NAME];
    if(nil != locationString) {
        self.location.hidden = NO;
        self.location.text = locationString;
    } else {
        self.location.text = @"";
        self.location.hidden = YES;
    }
    
    NSNumber* date = [self.dic valueForKey:MSG_DATE];
    NSString* timeString = [ScreenUtility dateConverter:date dateFormateString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
    if(nil!=timeString) {
        self.timeStamp.text = timeString;
    }
    
    if([[self.dic valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE]) {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithDictionary:self.dic];//TODO check
        self.fromName.text = [self getGroupMemberNameFromDic:dic];
        self.fromName.hidden = NO;
    }
    else
    {
        self.fromName.hidden = YES;
    }
    
#ifndef REACHME_APP
    NSString *linkedOPR =   [self.dic valueForKey:LINKED_OPR];

    BOOL likeBool = [[self.dic valueForKey:MSG_LIKED] boolValue];
    BOOL twBool   =  [[self.dic valueForKey:MSG_TW_POST] boolValue];
    BOOL fbBool   =  [[self.dic valueForKey:MSG_FB_POST] boolValue];
    BOOL vbBool   =  [[self.dic valueForKey:MSG_VB_POST] boolValue];
    BOOL ivBool   =  [[self.dic valueForKey:MSG_FORWARD] boolValue];
    BOOL fwdBool  =  [linkedOPR isEqualToString:IS_FORWORD_MSG];
    
    self.shareIconViewHeight.constant = 20;
    self.shareImg1.hidden = YES;
    self.shareImg2.hidden = YES;
    self.shareImg3.hidden = YES;
    self.shareImg4.hidden = YES;
    self.shareImg5.hidden = YES;
    
    likeBool = NO;
    ivBool = NO;
    fbBool = NO;
    fwdBool = NO;
    twBool = NO;
    
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
    if(vbBool)
    {
        [self setShareImg:@"share-icon-vb" atPosition:shareCountVal];
        shareCountVal++;
    }
    if(fwdBool)
    {
        [self setShareImg:@"share-icon-fwd" atPosition:shareCountVal];
        shareCountVal++;
    }
    
   //DEBUG  self.timeStamp.layer.borderWidth = 1;
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

/*
-(NSInteger)setShareImg:(NSString *)name atPosition:(NSInteger)shareCountValue{
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
}
*/

/*
- (void)showLocation
{
    if (self.locationString) {
        
        // if we are in a group chat, we need to keep the attributed string, otherwise we can just do normal appending.
        if ([[self.dic valueForKey:CONVERSATION_TYPE] isEqualToString:GROUP_TYPE]) {
            NSMutableAttributedString *currentString = [self.timeAndLocation.attributedText mutableCopy];
            
            NSDictionary *attributesForNewString = @{NSForegroundColorAttributeName: [IVColors lightGreyColor],
                                                     NSFontAttributeName: TimeStampFont};
            NSAttributedString *stringToAppend = [[NSAttributedString alloc] initWithString:self.locationString attributes:attributesForNewString];
            
            [currentString appendAttributedString:stringToAppend];
            self.timeAndLocation.attributedText = currentString;
        } else {
            self.timeAndLocation.text = [self.timeAndLocation.text stringByAppendingString:self.locationString];
        }
    }
}*/

- (IBAction)tappedOnCell:(id)sender
{
    /* TODO OCT 6
    // when the cell is tapped on, show the cell's location
    if (self.locationString && !self.locationCurrentlyShown) {

        // if we are in a group chat, we need to keep the attributed string, otherwise we can just do normal appending.
        if ([[self.dic valueForKey:CONVERSATION_TYPE] isEqualToString:GROUP_TYPE]) {
            NSMutableAttributedString *currentString = [self.timeAndLocation.attributedText mutableCopy];

            NSDictionary *attributesForNewString = @{NSForegroundColorAttributeName: [IVColors lightGreyColor],
                                                     NSFontAttributeName: TimeStampFont};
            NSAttributedString *stringToAppend = [[NSAttributedString alloc] initWithString:self.locationString attributes:attributesForNewString];

            [currentString appendAttributedString:stringToAppend];
            self.timeAndLocation.attributedText = currentString;
        } else {
            self.timeAndLocation.text = [self.timeAndLocation.text stringByAppendingString:self.locationString];
            self.locationCurrentlyShown = YES;
        }
    }
    else if(_timeString && self.locationCurrentlyShown) {
        self.timeAndLocation.text = _timeString;
        self.locationCurrentlyShown = NO;
    }*/
}
//

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
