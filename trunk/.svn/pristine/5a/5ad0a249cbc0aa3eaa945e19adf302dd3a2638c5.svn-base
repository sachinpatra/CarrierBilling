//
//  DatePickerView.h
//  InstaVoice
//
//  Created by kirusa on 4/4/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DatePickerView;
@protocol DatePickerViewDelegate <NSObject>
-(void) datePickerController:(DatePickerView*)view withDateString:(NSString *)dateString withDate:(NSDate *)dateValue withError:(bool)error;

@end

@interface DatePickerView : UIView
@property (nonatomic,strong)UIDatePicker *datePicker;
@property (nonatomic,strong)UIButton *cancelButton;
@property (nonatomic,strong)UIButton *setButton;
@property (nonatomic,weak)id<DatePickerViewDelegate> delegate;

@end
