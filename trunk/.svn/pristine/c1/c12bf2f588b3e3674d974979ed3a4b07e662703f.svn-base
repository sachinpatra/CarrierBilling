//
//  GenderView.h
//  InstaVoice
//
//  Created by kirusa on 4/4/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GenderView;

@protocol GenderViewDelegate <NSObject>
-(void) genderView:(GenderView*)view didSelectGender:(NSString*) gender;
@end

@interface GenderView : UIView {

    UILabel *maleLabel;
    UILabel *femaleLabel;
    UILabel *otherLabel;
    UIButton *nextOrSkipButton;
}

@property(nonatomic,strong)UIButton *maleButton;
@property(nonatomic,strong)UIButton *femaleButton;
@property(nonatomic,strong)UIButton *otherButton;

@property (nonatomic,weak)id<GenderViewDelegate> delegate;

@end
