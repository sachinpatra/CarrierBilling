//
//  IVMediaZoomDisplayViewController.h
//  InstaVoice
//
//  Created by kirusa on 12/2/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVMediaZoomDisplayViewController : UIPageViewController<UIPageViewControllerDataSource>
{
    UIView *annotationView;
    UIView  *topView;               //Navigation bar view
    UILabel *title;
    UIButton *backButton;
    UITextView *annotation;
    UIImageView *labelImageView;
}

@property(nonatomic,strong)NSArray *mediaList;
@property(nonatomic)NSInteger currentIndex;
@property(nonatomic,strong)NSDictionary* currentMedia;
@property(nonatomic)BOOL isCeleb;

-(void)cancel;

@end
