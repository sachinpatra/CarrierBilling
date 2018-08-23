//
//  PhotoViewController.m
//  InstaVoice
//
//  Created by kirusa on 11/28/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "PhotoViewController.h"
#import "ImageScrollView.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

+ (PhotoViewController *)photoViewControllerForPageIndex:(NSUInteger)pageIndex witharray:(NSArray *)array
{
    if (pageIndex < [array count])
    {
        return [[self alloc] initWithPageIndex:pageIndex witharray:array];
    }
    return nil;
}

- (id)initWithPageIndex:(NSInteger)pageIndex witharray:(NSArray *)array
{
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil)
    {
        _mediaList = array;
        _pageIndex = pageIndex;
    }
    [self loadView];
    return self;
}

- (void)loadView
{
    // replace our view property with our custom image scroll view
    //ImageScrollView *scrollView = [ImageScrollView imageCountwitharray:_mediaList];
    
     ImageScrollView *scrollView = [[ImageScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) witharray:_mediaList];
    scrollView.index = _pageIndex;
    scrollView.mediaList = _mediaList;
    self.view = scrollView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
