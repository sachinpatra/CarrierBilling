//
//  genderView.m
//  InstaVoice
//
//  Created by kirusa on 4/4/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "GenderView.h"

@implementation GenderView
@synthesize maleButton,femaleButton,otherButton;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
       
        self.backgroundColor = [UIColor clearColor];
        maleLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 13, 72, 21)];
        maleLabel.text = @"Male";
        maleLabel.textAlignment = NSTextAlignmentCenter;
        maleLabel.backgroundColor = [UIColor clearColor];
        maleLabel.textColor = [UIColor grayColor];
        femaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(111, 13, 72, 21)];
        femaleLabel.text = @"Female";
        femaleLabel.textAlignment = NSTextAlignmentCenter;
        femaleLabel.backgroundColor = [UIColor clearColor];
         femaleLabel.textColor = [UIColor grayColor];
        otherLabel = [[UILabel alloc]initWithFrame:CGRectMake(199, 13, 72, 21)];
        otherLabel.text = @"Other";
        otherLabel.textAlignment = NSTextAlignmentCenter;
        otherLabel.backgroundColor = [UIColor clearColor];
         otherLabel.textColor = [UIColor grayColor];
        maleButton = [[UIButton alloc]initWithFrame:CGRectMake(14, 42, 72, 72)];
        maleButton.tag = 0;
        [maleButton setImage:[UIImage imageNamed:@"reg_male"] forState:UIControlStateNormal];
        
        femaleButton = [[UIButton alloc]initWithFrame:CGRectMake(111, 42, 72, 72)];
         femaleButton.tag = 1;
        [femaleButton setImage:[UIImage imageNamed:@"reg_female"] forState:UIControlStateNormal];
        otherButton = [[UIButton alloc]initWithFrame:CGRectMake(199, 42, 72, 72)];
         otherButton.tag = 2;
        [otherButton setImage:[UIImage imageNamed:@"reg_other"] forState:UIControlStateNormal];
        [self addSubview:maleLabel];
        [self addSubview:femaleLabel];
        [self addSubview:otherLabel];
        [self addSubview:maleButton];
        [self addSubview:femaleButton];
        [self addSubview:otherButton];
         [maleButton addTarget:self action:@selector(buttonsInAnimationView:) forControlEvents:UIControlEventTouchUpInside];
         [femaleButton addTarget:self action:@selector(buttonsInAnimationView:) forControlEvents:UIControlEventTouchUpInside];
         [otherButton addTarget:self action:@selector(buttonsInAnimationView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)buttonsInAnimationView:(id)sender {
    NSString *gender;
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 0:
           gender = @"m";
            [maleButton setImage:[UIImage imageNamed:@"reg_male_selected"] forState:UIControlStateNormal];
            [femaleButton setImage:[UIImage imageNamed:@"reg_female"] forState:UIControlStateNormal];
            [otherButton setImage:[UIImage imageNamed:@"reg_other"] forState:UIControlStateNormal];
            

            break;
        case 1:
           gender = @"f";
            [maleButton setImage:[UIImage imageNamed:@"reg_male"] forState:UIControlStateNormal];
            [femaleButton setImage:[UIImage imageNamed:@"reg_female_selected"] forState:UIControlStateNormal];
            [otherButton setImage:[UIImage imageNamed:@"reg_other"] forState:UIControlStateNormal];
            

            break;
        case 2:
            gender = @"o";
            
            [maleButton setImage:[UIImage imageNamed:@"reg_male"] forState:UIControlStateNormal];
            [femaleButton setImage:[UIImage imageNamed:@"reg_female"] forState:UIControlStateNormal];
            [otherButton setImage:[UIImage imageNamed:@"reg_other_selected"] forState:UIControlStateNormal];
            

            break;

        default:
            break;
    }
    
    [self.delegate genderView:self didSelectGender:gender];
    
    
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
