//
//  IVMediaZoomDisplayViewController.m
//  InstaVoice
//
//  Created by kirusa on 12/2/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "IVMediaZoomDisplayViewController.h"
#import "PhotoViewController.h"
#import "TableColumns.h"
#import "ImgMacro.h"
#import "Macro.h"
#import "Logger.h"

@interface IVMediaZoomDisplayViewController ()

@end

@implementation IVMediaZoomDisplayViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _currentIndex = 0;
    if(!self.isCeleb) {
        NSString* curMsgGuid = [self.currentMedia valueForKey:MSG_GUID];
        for(int i =0;i<[self.mediaList count];i++)
        {
            NSString* msgGuid = [[self.mediaList objectAtIndex:i]valueForKey:MSG_GUID];
            if([curMsgGuid isEqualToString:msgGuid]) {
                _currentIndex = i;
                break;
            }
        }
    }
    else {
        long currentMsgId = 0;
        if([self.currentMedia valueForKey:MSG_ID]) {
            currentMsgId =  [[self.currentMedia valueForKey:MSG_ID] longValue];
        }
        
        if(currentMsgId) {
            for(int i =0;i<[self.mediaList count];i++)
            {
                long msgId = [[[self.mediaList objectAtIndex:i]valueForKey:MSG_ID]longValue];
                if(currentMsgId == msgId)
                {
                    _currentIndex = i;
                    break;
                }
            }
        }
    }
    
    PhotoViewController *startingPage = [PhotoViewController photoViewControllerForPageIndex:_currentIndex witharray:_mediaList];
    if (startingPage != nil)
    {
        self.dataSource = self;
        self.view.gestureRecognizers = self.gestureRecognizers;
        
        // Find the tap gesture recognizer so we can remove it!
        UIGestureRecognizer* tapRecognizer = nil;
        for (UIGestureRecognizer* recognizer in self.gestureRecognizers) {
            if ( [recognizer isKindOfClass:[UITapGestureRecognizer class]] ) {
                tapRecognizer = recognizer;
                break;
            }
        }
        
        if ( tapRecognizer ) {
            [self.view removeGestureRecognizer:tapRecognizer];
            [self.view removeGestureRecognizer:tapRecognizer];
        }
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        [singleTap setDelegate:self];
        singleTap.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
        [doubleTap setDelegate:self];
        doubleTap.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [self setViewControllers:@[startingPage]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
        
        [self createTopView];
        topView.hidden = NO;
        annotationView.hidden = NO;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    //CMP [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self prefersStatusBarHidden];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view addSubview:topView];
    //CMP [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self prefersStatusBarHidden];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [topView removeFromSuperview];
}

-(void)setAnnotationwithIndex:(NSInteger)index {
    
    NSDictionary *mediaDic = [[NSDictionary alloc]initWithDictionary:[_mediaList objectAtIndex:index]];
    NSString* annotationText = [mediaDic valueForKey:ANNOTATION];
    if(annotationText && annotationText.length > 0)
    {
        annotation.hidden = NO;
        annotation.editable=YES;
        annotation.clearsOnInsertion=YES;
        annotation.text = annotationText;
        annotation.editable=NO;
        //annotation.font = [UIFont fontWithName:HELVETICANEUE_MEDIUM size:15.0f];
        annotation.textColor = [UIColor whiteColor];
        
        if ([annotation respondsToSelector:@selector(linkTextAttributes)]) {
            /* FEB 8 TODO
            UIColor *linkColor = [UIColor whiteColor];
            NSDictionary *attributes = @{NSForegroundColorAttributeName:linkColor, NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
            annotation.linkTextAttributes = attributes;
            */
            
            //FEB 8
            UIColor *linkColor = [UIColor blackColor];
            if ([[UIDevice currentDevice].systemVersion floatValue] < 9) {
                UIFont* font =  [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
                NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:annotation.text];
                [string addAttribute:NSForegroundColorAttributeName value:linkColor range:NSMakeRange(0,annotation.text.length)];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
                
                [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, annotation.text.length)];
                [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, annotation.text.length)];
                annotation.attributedText = string;
                annotation.dataDetectorTypes = UIDataDetectorTypeAll;
            } else {
                
                NSDictionary *attributes = @{
                                             NSForegroundColorAttributeName: linkColor,
                                             NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                             };
                annotation.linkTextAttributes = attributes;
            }
            //
        }
        labelImageView.hidden = NO;
    }
    else
    {
        annotation.hidden = YES;
        annotation.text = @"";
        labelImageView.hidden = YES;
    }
}

-(void)prepareToReuse {
    annotation.editable = YES;
    annotation.editable = NO;
    annotation.selectable = NO;
    annotation.selectable = YES;
}

-(void)createTopView {
    if(UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])){
        topView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0,SIZE_0,self.view.frame.size.height, SIZE_40)];
        backButton = [[UIButton alloc] initWithFrame:CGRectMake(SIZE_8,SIZE_0, SIZE_50, SIZE_40)];
        title = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.height - SIZE_201)/2,SIZE_0,SIZE_201, SIZE_35)];
        
        //CMP [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
        [self prefersStatusBarHidden];
    }else{
        if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            topView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0,SIZE_0,DEVICE_WIDTH, SIZE_44)];
            backButton = [[UIButton alloc] initWithFrame:CGRectMake(SIZE_8,SIZE_0, SIZE_50, SIZE_44)];
            title = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_59,SIZE_8,SIZE_201, SIZE_30)];
        } else {
            topView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0, SIZE_0,DEVICE_WIDTH, SIZE_60)];
            backButton = [[UIButton alloc] initWithFrame:CGRectMake(SIZE_8,SIZE_25, SIZE_50, SIZE_44)];
            title = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_0,SIZE_33, DEVICE_WIDTH,SIZE_30)];
        }
        //CMP [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        [self prefersStatusBarHidden];
    }
    title.textAlignment = NSTextAlignmentCenter;
    title.text = [NSString stringWithFormat:@"%ld of %lu",_currentIndex+1,(unsigned long)[_mediaList count]];
    title.backgroundColor = [UIColor clearColor];
    
    [backButton setImage:[UIImage imageNamed:IMG_BACK] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    topView.backgroundColor = [UIColor whiteColor];
    
    [topView addSubview:backButton];
    [topView addSubview:title];
}

-(void)createAnnotationView
{
    if(UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])){
        annotationView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0,DEVICE_WIDTH - SIZE_30,self.view.frame.size.height, SIZE_30)];
        annotation = [[UITextView alloc]initWithFrame:CGRectMake(SIZE_0,SIZE_0,self.view.frame.size.height, SIZE_30)];
        labelImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SIZE_0,SIZE_0,self.view.frame.size.height, SIZE_30)];
    } else {
        annotationView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0,self.view.frame.size.height - SIZE_40,DEVICE_WIDTH, SIZE_40)];
        annotation = [[UITextView alloc]initWithFrame:CGRectMake(SIZE_0,SIZE_0,DEVICE_WIDTH, SIZE_40)];
        labelImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SIZE_0,SIZE_0,DEVICE_WIDTH, SIZE_40)];
    }
    
    annotation.scrollEnabled = NO;
    annotation.editable = NO;
    annotation.selectable = YES;
    annotation.dataDetectorTypes = UIDataDetectorTypeAll;
    
    [labelImageView setImage:[UIImage imageNamed:IMG_TRANSPARENT_STRIPE_READ]];

    annotation.textAlignment = NSTextAlignmentCenter;
    annotation.font = [UIFont fontWithName:HELVETICANEUE_MEDIUM size:15.0f];
    annotation.textColor = [UIColor whiteColor];
    
    labelImageView.userInteractionEnabled = YES;

    annotation.opaque = NO;
    annotation.backgroundColor = [UIColor clearColor];
    annotation.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    annotation.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [annotationView addSubview:annotation];
    [annotationView insertSubview:labelImageView belowSubview:annotation];
}

-(void)backBtnAction
{
   // [self.view.superview addSubview:self.view];
    
    // Transformation start scale
    self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    
    //    // Store original centre point of the destination view
    //    CGPoint originalCenter = vController.view.center;
    //
    //    CGPoint originatingPoint = CGRectMake(, <#CGFloat y#>, 0, 0);
    
    // Set center to start point of the button
    //    vController.view.center = originatingPoint;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Grow!
                         self.view.transform = CGAffineTransformMakeScale(0.001, 0.001);
                         //                       vController.view.center = originalCenter;
                         [self dismissViewControllerAnimated:YES completion:nil];
                     }
                     completion:^(BOOL finished){
                       //  [self.view removeFromSuperview]; // remove from temp super view
                        // [self dismissViewControllerAnimated:YES completion:nil]; // present VC
                     }];
    
    //CMP [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self prefersStatusBarHidden];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UIDeviceOrientationIsLandscape(toInterfaceOrientation)) {
        topView.frame = CGRectMake(SIZE_0, SIZE_0,self.view.frame.size.height,SIZE_40);
        title.frame = CGRectMake((self.view.frame.size.height - SIZE_201)/2, SIZE_0, SIZE_201, SIZE_35);
        backButton.frame = CGRectMake(SIZE_8, SIZE_0, SIZE_50, SIZE_40);
        annotationView.frame = CGRectMake(SIZE_0,DEVICE_WIDTH - SIZE_30,self.view.frame.size.height, SIZE_30);
        annotation.frame = CGRectMake(SIZE_0,SIZE_0,self.view.frame.size.height, SIZE_30);
        labelImageView.frame = CGRectMake(SIZE_0,SIZE_0,self.view.frame.size.height, SIZE_30);
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    }
    else if(UIDeviceOrientationIsPortrait(toInterfaceOrientation)) {
        if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            topView.frame = CGRectMake(SIZE_0,SIZE_0,DEVICE_WIDTH, SIZE_44);
            backButton.frame = CGRectMake(SIZE_8,SIZE_0, SIZE_50, SIZE_44);
            title.frame = CGRectMake(SIZE_59,SIZE_8,SIZE_201, SIZE_30);
        } else {
            topView.frame = CGRectMake(SIZE_0, SIZE_0,DEVICE_WIDTH, SIZE_60);
            backButton.frame = CGRectMake(SIZE_8,SIZE_15, SIZE_50, SIZE_44);
            title.frame = CGRectMake(SIZE_59,SIZE_23, SIZE_201,SIZE_30);
        }
        annotationView.frame = CGRectMake(SIZE_0,self.view.frame.size.width - SIZE_40,self.view.frame.size.height, SIZE_40);
        annotation.frame = CGRectMake(SIZE_0,SIZE_0,self.view.frame.size.height, SIZE_40);
        labelImageView.frame = CGRectMake(SIZE_0,SIZE_0,self.view.frame.size.height, SIZE_40);
        [annotation sizeToFit];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    }
}

#pragma mark - UIPageViewControllerDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    KLog1(@"pageViewController(Before) index = %lu",(unsigned long)index);
    if(index > 0) {
        title.text = [NSString stringWithFormat:@"%lu of %lu",index+1,(unsigned long)[_mediaList count]];
      //  [self setAnnotationwithIndex:index];
        return [PhotoViewController photoViewControllerForPageIndex:(index - 1) witharray:_mediaList];
        
    } else if(index == 0){
        title.text = [NSString stringWithFormat:@"%d of %lu",1,(unsigned long)[_mediaList count]];
      //  [self setAnnotationwithIndex:0];
        return nil;
    }
    else
        return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(PhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    
    KLog(@"pageViewController(After) index = %lu",(unsigned long)index);
    
    if (index < [_mediaList count]) {
        title.text = [NSString stringWithFormat:@"%lu of %lu",index+1,(unsigned long)[_mediaList count]];
        return [PhotoViewController photoViewControllerForPageIndex:(index + 1) witharray:_mediaList];
    } else {
        return nil;
    }
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    if(topView.hidden){
        topView.hidden = NO;
        annotationView.hidden = NO;
        self.view.backgroundColor = [UIColor whiteColor];
       //CMP  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
        [self prefersStatusBarHidden];
        if(!(UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])))
            [self prefersStatusBarHidden];
            //CMP [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    }else{
        topView.hidden = YES;
        annotationView.hidden = YES;
        self.view.backgroundColor = [UIColor blackColor];
        //CMP [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
        [self prefersStatusBarHidden];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel
{
    [self dismissViewControllerAnimated:NO completion:nil];
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
