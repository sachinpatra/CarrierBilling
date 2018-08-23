//
//  LinkButton.h
//  InstaVoice
//
//  Created by Eninov User on 18/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinkButton : UIButton
{
    double redColor;
    double greenColor;
    double blueColor;
    double alphaColor;
}

- (id)initWithFrame:(CGRect)frame red:(double)red green:(double)green blue:(double)blue alpha:(double)alpha;
@end

