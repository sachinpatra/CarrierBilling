//
//  TopLeftUILabel.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 5/28/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "TopLeftUILabel.h"

@implementation TopLeftUILabel
@synthesize verticalAlignment;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawTextInRect:(CGRect)rect
{
	if(verticalAlignment == UIControlContentVerticalAlignmentTop ||
	   verticalAlignment == UIControlContentVerticalAlignmentBottom)
	{
		//	If one line, we can just use the lineHeight, faster than querying sizeThatFits
		const CGFloat height = ((self.numberOfLines == 1) ? ceilf(self.font.lineHeight) : [self sizeThatFits:self.frame.size].height);
		
		rect.origin.y = ((self.frame.size.height - height) / 2.0f) * ((verticalAlignment == UIControlContentVerticalAlignmentTop) ? -1.0f : 1.0f);
	}
	
	[super drawTextInRect:rect];
}

- (void) setVerticalAlignment:(UIControlContentVerticalAlignment)_verticalAlignment
{
	verticalAlignment = _verticalAlignment;
	
	[self setNeedsDisplay];
}


@end
