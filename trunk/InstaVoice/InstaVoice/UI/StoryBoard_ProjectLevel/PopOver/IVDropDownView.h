//
//  StatePopOverView.h
//  Kirusa
//
//  Created by Vinoth on 24/08/13.
//  Copyright (c) 2013 TCS. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef REACHME_APP
    #import "ChatGridViewController.h"
#endif


@interface IVDropDownView : UIView
@property (weak, nonatomic) IBOutlet UIView *popOverView;
@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NSString* uniqueIdentifier;

- (id)initWithFrame:(CGRect)frame withParameters:(NSDictionary*)dict;

@end









