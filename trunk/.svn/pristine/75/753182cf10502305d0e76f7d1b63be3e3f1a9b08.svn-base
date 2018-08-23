//
//  DateOfBirthView.h
//  InstaVoice
//
//  Created by kirusa on 4/4/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  DateOfBirthView;
@protocol DateOfBirthViewDelegate <NSObject>
-(void) dateOfBirth:(DateOfBirthView*)view;
@end
@interface DateOfBirthView : UIView {
    UIImageView *BackImage;
}
@property (nonatomic,strong)UIButton *calenderButton;
@property (nonatomic,strong)UILabel *dateShowLabel;
@property (nonatomic,weak)id<DateOfBirthViewDelegate> delegate;

@end
