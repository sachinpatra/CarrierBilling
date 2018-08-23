//
//  DrawCircle.m
//  InstaVoice
//
//  Created by EninovUser on 21/11/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "DrawCircle.h"
#import "BaseUI.h"
#import "IVFileLocator.h"
#import "IVImageUtility.h"

@implementation DrawCircle

- (id)initWithFrame:(CGRect)frame color:(NSString *)colorId radius :(float) circleRadius
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        receiverId = colorId;
        radius = circleRadius;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIColor *color = [IVImageUtility setColorDefaultImage:receiverId];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    UIBezierPath *blueHalf = [UIBezierPath bezierPath];
    [blueHalf addArcWithCenter:CGPointMake(center.x, center.y) radius:radius startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES];
    [blueHalf setLineWidth:2.0];
    [blueHalf stroke];
    
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    
    UIBezierPath *redHalf = [UIBezierPath bezierPath];
    [redHalf addArcWithCenter:CGPointMake(center.x, center.y) radius:radius startAngle:M_PI_2 endAngle:3.0 * M_PI_2 clockwise:YES];
    [redHalf setLineWidth:2.0];
    [redHalf stroke];
}


@end
