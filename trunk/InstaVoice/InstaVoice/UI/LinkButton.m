//
//  LinkButton.m
//  InstaVoice
//
//  Created by Eninov User on 18/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "LinkButton.h"



@implementation LinkButton

- (id)initWithFrame:(CGRect)frame red:(double)red green:(double)green blue:(double)blue alpha:(double)alpha
{
    self = [super initWithFrame:frame];
    if (self)
    {
        redColor = red;
        greenColor = green;
        blueColor = blue;
        alphaColor = alpha;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(redColor>=0.0 && blueColor>=0.0 && greenColor>=0.0 && alphaColor>=0.0)
    {
        CGContextSetRGBStrokeColor(context, redColor, greenColor, blueColor, alphaColor);
    }
    else
    {
        CGContextSetRGBStrokeColor(context, 255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0);
    }
    
    // Draw them with a 1.0 stroke width.
    CGContextSetLineWidth(context, 1.0);
    
    // Draw a single line from left to right
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextStrokePath(context);
    

}


@end
