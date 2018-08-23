//
//  DatePickerView.m
//  InstaVoice
//
//  Created by kirusa on 4/4/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "DatePickerView.h"

@implementation DatePickerView
@synthesize datePicker,cancelButton,setButton;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, 320, 216)];
        datePicker.datePickerMode = UIDatePickerModeDate;
        [datePicker setBackgroundColor:[UIColor whiteColor]];
        [datePicker setDate:[NSDate date]];
        cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 216, 160, 50)];
        cancelButton.backgroundColor = [UIColor grayColor];
        
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        setButton = [[UIButton alloc]initWithFrame:CGRectMake(160, 216, 160, 50)];
        setButton.backgroundColor = [UIColor colorWithRed:0.0 green:122/255 blue:1.0 alpha:1];
        [setButton setTitle:@"Ok" forState:UIControlStateNormal];
        
        [self addSubview:datePicker];
        [self addSubview:cancelButton];
        [self addSubview:setButton];
        [setButton addTarget:self action:@selector(labelChange:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


- (void)labelChange:(id)sender{
    
    
    self.hidden = YES;
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MMM-yyyy"];
    df.dateStyle = NSDateFormatterMediumStyle;
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]components:NSCalendarUnitYear fromDate:[datePicker date] toDate:now options:0];
    NSInteger age = [ageComponents year];
    if(age < 13)
    {
//        [self showAlertMessage:NSLocalizedString(@"DOB_NOT_VALID", nil)];
        [self.delegate datePickerController:self withDateString:[NSString stringWithFormat:@"%@",
                                                                 [df stringFromDate:datePicker.date]] withDate:[datePicker date] withError:YES];
    }
    else
    {
         
        [self.delegate datePickerController:self withDateString:[NSString stringWithFormat:@"%@",
                                                                 [df stringFromDate:datePicker.date]] withDate:[datePicker date]withError:NO];
    }
}


- (void)cancelAction:(id)sender {
    self.hidden = YES;
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
