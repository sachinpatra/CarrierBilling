//
//  RHSTableViewCellButton.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 5/16/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "RHSTableViewCellButton.h"

@implementation RHSTableViewCellButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setButtonConnected:(BOOL)selected
{
    if (selected) {
        [self setBackgroundImage:[UIImage imageNamed:self.enabledImage] forState:UIControlStateNormal];
        [self setTitle:self.enabledText forState:UIControlStateNormal];
    }
    else
    {
        [self setBackgroundImage:[UIImage imageNamed:self.defaultImage] forState:UIControlStateNormal];
        [self setTitle:self.defaultText forState:UIControlStateNormal];
        
    }
}

@end
