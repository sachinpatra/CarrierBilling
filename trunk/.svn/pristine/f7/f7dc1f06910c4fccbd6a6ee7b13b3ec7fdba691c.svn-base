//
//  CustomProgressView.m
//  InstaVoice
//
//  Created by Vivek Mudgil on 22/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "CircleProgressView.h"
#import "SizeMacro.h"

#define RADIUS_NON_RETINA 52.5
#define RADIUS_RETINA     55.0

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


@implementation CircleProgressView
@synthesize duration;
@synthesize startAngle;
@synthesize endAngle;
@synthesize state;
@synthesize sendButton;
@synthesize maxDurationTime;
@synthesize selectColor;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        sendButton= [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.frame =CGRectMake(SIZE_35,SIZE_35,SIZE_45,SIZE_45);
        [sendButton setTintColor:[UIColor redColor]];//KM
        [sendButton setTitle:@"" forState:UIControlStateNormal];
        [self addSubview:sendButton];
        sendButton.hidden = TRUE;
        state = 0;
        selectColor = 0;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    context     = UIGraphicsGetCurrentContext();
    [self drawCircle];
}


-(void)drawCircle 
{
    CGFloat radius;
    
    if([UIScreen mainScreen].scale > 1.0)
	{
        radius = RADIUS_RETINA;
    }
	else
	{
        radius = RADIUS_NON_RETINA;
    }

    if(duration <= maxDurationTime)
	{
        if(state == 1)
		{
            state = 2;
        }
    }
    if(duration != 0)
	{
		//KM
        CGContextSetLineWidth(context, 1.5);
        if (selectColor == 0) {
            CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:1 alpha:.9] CGColor]);
        } else if (selectColor == 1) {
            CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:1 alpha:.9] CGColor]);
		//KM
        }
        CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextStrokePath(context);
    }
}
@end
