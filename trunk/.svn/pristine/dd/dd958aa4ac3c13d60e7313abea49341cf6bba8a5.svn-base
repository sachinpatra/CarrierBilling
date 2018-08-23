//
//  DateOfBirthView.m
//  InstaVoice
//
//  Created by kirusa on 4/4/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "DateOfBirthView.h"

@implementation DateOfBirthView
@synthesize dateShowLabel,calenderButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        BackImage = [[UIImageView alloc]initWithFrame:CGRectMake(3, 43, 275, 35)];
        [BackImage setImage:[UIImage imageNamed:@"reg_textRow1"]];
        dateShowLabel = [[UILabel alloc]initWithFrame:CGRectMake(48, 43, 230, 35)];
        dateShowLabel.backgroundColor = [UIColor clearColor];
        dateShowLabel.textAlignment = NSTextAlignmentCenter;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = dateShowLabel.frame;
        [btn addTarget:self action:@selector(buttonsInAnimationView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        calenderButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 44, 32, 32)];
        calenderButton.tag = 3;
        calenderButton.backgroundColor = [UIColor clearColor];
        [calenderButton setBackgroundImage:[UIImage imageNamed:@"date"] forState:UIControlStateNormal];
        [self addSubview:BackImage];
        [self addSubview:dateShowLabel];
        [self addSubview:calenderButton];
        [calenderButton addTarget:self action:@selector(buttonsInAnimationView:) forControlEvents:UIControlEventTouchUpInside];
        self.dateShowLabel.text = @"Select your birthday";
    }
    return self;
}

-(void)buttonsInAnimationView:(id)sender {
    [self.delegate dateOfBirth:self];
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
