//
//  ScreenUtility.m
//  InstaVoice
//
//  Created by Vivek Mudgil on 21/01/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "ScreenUtility.h"
#import "IVFileLocator.h"
#import "IVImageUtility.h"
#define INT_1000                1000
#define INT_60                  60
#define INT_9                   9
#define MIN_WIDTH               111  // in pixel
#define MAX_WIDTH               [UIScreen mainScreen].bounds.size.width //Km
#define SIZE_3_5                3.5
#define SIZE_1_6                1.6


static CustomIOS7AlertView *alertPopup = nil;
static UIAlertView *alertOnTimer;
@implementation ScreenUtility

#pragma mark dateConverter

//Function:Convert dateTime to the string from milisecond
+(NSString *)dateConverter:(NSNumber *)dateTime dateFormateString:(NSString *)dateFormat
{
    double val = ([dateTime doubleValue])/INT_1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:val];
    NSTimeInterval timeSinceDate = [[NSDate date] timeIntervalSinceDate:date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *convertedString = nil;
    if([dateFormat isEqualToString:NSLocalizedString(@"DATE_FORMATE_CONVERSATION",nil)])
    {
        if(timeSinceDate < SIZE_86400)
        {
            if([[NSCalendar currentCalendar] isDateInToday:date])
                [formatter setDateFormat:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
            else
                [formatter setDateFormat:NSLocalizedString(@"DATE_FORMATE_CONVERSATION",nil)];
        }
        else
        {
            [formatter setDateFormat:NSLocalizedString(@"DATE_FORMATE_CONVERSATION",nil)];
        }
        convertedString = [formatter stringFromDate:date];
    }
    else if([dateFormat isEqualToString:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)]) {
        [formatter setDateFormat:NSLocalizedString(@"DATE_FORMATE_IN_HOUR",nil)];
        convertedString = [formatter stringFromDate:date];
    }
    else if([dateFormat isEqualToString:NSLocalizedString(@"DATE_FORMATE_CONVERSATION_MISSCALL",nil)])
    {
        [formatter setDateFormat:NSLocalizedString(@"DATE_FORMATE_CHATGRID",nil)];
        if(timeSinceDate < SIZE_86400)
        {
            NSUInteger daysSinceDate = (NSUInteger)(timeSinceDate / (SIZE_3600));
            switch(daysSinceDate)
            {
                case 1:
                {
                    convertedString  = NSLocalizedString(@"ONE_HOUR_STRING",nil);
                }
                    break;
                case 0:
                {
                    NSUInteger minutesSinceDate = (NSUInteger)(timeSinceDate / SIZE_60);
                    convertedString     =   [[[NSString alloc]initWithFormat:@"%lu",(unsigned long)minutesSinceDate] stringByAppendingString:NSLocalizedString(@"MIN_AGO_STRING",nil)];
                }
                    break;
                default:
                    convertedString = [NSString stringWithFormat:NSLocalizedString(@"N_HOURS_STRING",nil), daysSinceDate];
            }
        }
        else
        {
            NSUInteger minutesSinceDate = (NSUInteger)(timeSinceDate / SIZE_86400);
            if(minutesSinceDate == 1)
                convertedString     =   [[[NSString alloc]initWithFormat:@"%lu",(unsigned long)minutesSinceDate] stringByAppendingString:NSLocalizedString(@"DAY_AGO_STRING",nil)];
            else if(minutesSinceDate  > 0 )
                convertedString     =   [[[NSString alloc]initWithFormat:@"%lu",(unsigned long)minutesSinceDate] stringByAppendingString:NSLocalizedString(@"DAYS_AGO_STRING",nil)];
        }
    }
    else
    {
        [formatter setDateFormat:NSLocalizedString(@"DATE_FORMATE_CHATGRID",nil)];
        if(timeSinceDate < SIZE_86400) {
            NSDateFormatter *shortFormatter = [NSDateFormatter new];
            [shortFormatter setDateStyle:NSDateFormatterShortStyle];
            [shortFormatter setDateFormat:@"hh:mm a"];
            convertedString = [shortFormatter stringFromDate:date];
            // if the first character is a 0, get rid of it, so it doesn't say something like 07:33
            if ([convertedString characterAtIndex:0] == '0') {
                convertedString = [convertedString substringFromIndex:1];
            }
        }
        else
        {
            NSUInteger minutesSinceDate = (NSUInteger)(timeSinceDate / SIZE_86400);
            if (minutesSinceDate <= 7) {
                NSDateFormatter *shortFormatter = [NSDateFormatter new];
                [shortFormatter setDateFormat:@"EEEE"];
                convertedString = [shortFormatter stringFromDate:date];
            } else {
                NSDateFormatter *shortFormatter = [NSDateFormatter new];
                [shortFormatter setDateStyle:NSDateFormatterShortStyle];
                convertedString =[shortFormatter stringFromDate:date];
            }
        }
    }
    return convertedString;
}

#pragma mark Alert Message View
//Function: For Alert Message On screen
+(void)showAlertMessage:(NSString *)alertMsg
{
    if(alertMsg.length > 0){
        if(alertPopup != nil)
        {
            [alertPopup close];
        }
        alertPopup = [[CustomIOS7AlertView  alloc] init];
        [alertPopup setButtonTitles:NULL];
        
        UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(SIZE_0,SIZE_15,DEVICE_WIDTH-50.0/*SIZE_250*/,SIZE_22)];
        lblText.text = alertMsg;
        lblText.font = [UIFont systemFontOfSize:SIZE_13];
        lblText.numberOfLines = SIZE_0;
        CGRect currentFrame = lblText.frame;
        CGSize max = CGSizeMake(lblText.frame.size.width,SIZE_250);
        
        // DC MAY 26 2016
        NSAttributedString *textAttributedString ;
        if (textAttributedString.length) {
            textAttributedString = [[NSAttributedString alloc]initWithString:alertMsg attributes:@{NSFontAttributeName:lblText.font}];
        }
        else
            textAttributedString = [[NSAttributedString alloc]initWithString:@"" attributes:@{}];
        
        CGRect textStringRect = [textAttributedString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        CGSize expected = textStringRect.size;
        //CGSize expected = [alertMsg sizeWithFont:lblText.font constrainedToSize:max lineBreakMode:lblText.lineBreakMode];
        currentFrame.size.height = expected.height;
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(SIZE_0,SIZE_0,DEVICE_WIDTH-50.0/*SIZE_250*/,expected.height+SIZE_40)];
        lblText.frame = currentFrame;
        lblText.backgroundColor = [UIColor clearColor];
        lblText.textColor = [UIColor blackColor];
        lblText.textAlignment = NSTextAlignmentCenter;
        [container addSubview:lblText];
        [alertPopup setContainerView:container];
        [alertPopup setUseMotionEffects:YES];
        [alertPopup show];
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(closeAlert) userInfo:nil repeats:NO];
    }
}

//Function:To Stop Alert Message
+(void)closeAlert
{
    [alertPopup close];
    alertPopup = nil;
}

/*
 * Convert the image's fill color to the passed in color
 */
+(UIImage*) imageFilledWith:(UIColor*)color using:(UIImage*)startImage
{
    // Create the proper sized rect
    CGRect imageRect = CGRectMake(SIZE_0, SIZE_0, CGImageGetWidth(startImage.CGImage), CGImageGetHeight(startImage.CGImage));
    
    // Create a new bitmap context
    CGContextRef context = CGBitmapContextCreate(NULL, imageRect.size.width, imageRect.size.height, SIZE_8, SIZE_0, CGImageGetColorSpace(startImage.CGImage), kCGImageAlphaPremultipliedLast);
    
    // Use the passed in image as a clipping mask
    CGContextClipToMask(context, imageRect, startImage.CGImage);
    // Set the fill color
    CGContextSetFillColorWithColor(context, color.CGColor);
    // Fill with color
    CGContextFillRect(context, imageRect);
    
    // Generate a new image
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage* newImage = [UIImage imageWithCGImage:newCGImage scale:startImage.scale orientation:startImage.imageOrientation];
    
    // Cleanup
    CGContextRelease(context);
    CGImageRelease(newCGImage);
    return newImage;
}

//Function: for convert the recording duration into string
+(NSString *)durationIntoString:(int)duration
{
    NSString *str   = nil;
    if(duration >=0 && duration < INT_60)
    {
        str = [NSString stringWithFormat:@"0:%02d",duration];
    }
    else if(duration >= INT_60)
    {
        int min = duration/INT_60;
        int sec = duration%INT_60;
        str = [NSString stringWithFormat:@"%d:%02d",min,sec];
        /*
        if(sec <= INT_9)
            str = [NSString stringWithFormat:@"0%d:0%d",min,sec];
        else
            str = [NSString stringWithFormat:@"0%d:%d",min,sec];
        */
    }
    return str;
}

#pragma mark Setting voiceView width

//Function:Get the VoiceView Width according to duration time
+(float) voiceViewWidth:(int)msgDuration
{
    float width = 0.0;
    int maxWidth = [UIScreen mainScreen].bounds.size.width - 120; //in pixels
    int minWidth = 85;
    //int minWidth = 131;
    int diff = maxWidth - minWidth;
    double div = (double)diff/120;
    double dur = (double)msgDuration*div;
    width = minWidth+dur;
    return MIN(width, maxWidth);
}


#pragma mark get the Image from the path
+(UIImage *)getPicImage:(NSString *)imgPath
{
    UIImage *remoteUserImg = nil;
    if(imgPath != nil && ![imgPath isEqual:@""])
    {
        remoteUserImg = [IVImageUtility getUIImageFromFilePath:imgPath];
    }
    return remoteUserImg;
}


+(void)showAlert:(NSString *)alertMsg
{
    if(alertMsg.length > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}



/* OCT 22
+(CGSize)sizeOfString:(NSString *)string withFont:(UIFont *)font
{
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
//    NSAttributedString *arr = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    CGSize max = CGSizeMake(SIZE_240,SIZE_12000);
    
//    CGRect rect = [arr boundingRectWithSize:max options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    CGRect rect;
    
    rect = [string boundingRectWithSize:max options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:font} context:nil];

    rect.size.height = ceil(rect.size.height);
    
    return rect.size;
}*/


+(CGSize)sizeOfString:(NSString *)string withFont:(UIFont *)font
{
    CGSize max = CGSizeMake(DEVICE_WIDTH - 80,CGFLOAT_MAX);
    CGRect rect;
    
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        rect =
        [string boundingRectWithSize:max
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     attributes:@{NSFontAttributeName:font}
                                     context:nil];
    }
    else {
        // DC MAY 26 2016
        NSAttributedString *textAttributedString;
        if (string.length) {
            textAttributedString = [[NSAttributedString alloc]initWithString:string attributes:@{NSFontAttributeName:font}];
        }
        else
            textAttributedString = [[NSAttributedString alloc]initWithString:@"" attributes:@{}];
        CGRect textStringRect = [textAttributedString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        rect.size = textStringRect.size;
        //rect.size =  [string sizeWithFont:font constrainedToSize:max lineBreakMode:NSLineBreakByWordWrapping];
        rect.size.width = rect.size.width;
    }
    
    return rect.size;
}

@end
