//
//  StatePopOverView.m
//  Kirusa
//
//  Created by Vinoth on 24/08/13.
//  Copyright (c) 2013 TCS. All rights reserved.
//

#import "IVDropDownView.h"
#define tableHeight 40
@implementation IVDropDownView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withParameters:(NSDictionary*)dict
{
    self = [super initWithFrame:frame];
    if (self) {
        self.uniqueIdentifier = [dict objectForKey:@"uniqueIdentifier"];
        NSString *currentlySelected;
        if([self.uniqueIdentifier isEqualToString:@"friendsScreen_titleTapped"])
        {
            currentlySelected = [dict objectForKey:@"currentlySelected"];
        }
        int tableWidth = [[dict objectForKey:@"tableWidth"] intValue];
        tableWidth = tableWidth - 5 ;
        NSArray *rowTitles = [dict objectForKey:@"rowTitles"];
        int rowCount = [rowTitles count];
        [self setFrame:CGRectMake(0, 5, tableWidth, tableHeight * rowCount)];

        for (int i = 0; i< rowCount; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            button.frame = CGRectMake(0, (i*tableHeight), tableWidth, tableHeight-1);
            [button setTitle:rowTitles[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame), tableWidth, 1)];
            [lineView setBackgroundColor:[UIColor colorWithRed:.86 green:.86 blue:.86 alpha:1]];
            [self addSubview:lineView];
            [self addSubview:button];
        }
        
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

-(void)buttonTapped:(id)sender
{
    //TODO [self.delegate buttonTappedRespond:sender withUniqueIdentifier:self.uniqueIdentifier];
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
