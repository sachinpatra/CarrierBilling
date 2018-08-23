//
//  ReachMeIntroViewController.m
//  ReachMe
//
//  Created by Bhaskar Munireddy on 25/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "ReachMeIntroViewController.h"
#import "UIStateMachine.h"
#import "AppDelegate_rm.h"

@interface ReachMeIntroViewController ()<UIScrollViewDelegate>{
    
    UIScrollView *scroll;
    UIPageControl *pageControl;
    UIView *backGroundView;
    UIButton *nextOrEnterButton, *skipButton;
}

@end

@implementation ReachMeIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat bottomPadding, topPadding;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        bottomPadding = window.safeAreaInsets.bottom;
        topPadding = window.safeAreaInsets.top;
    }else{
        bottomPadding = 0.0f;
        topPadding = 0.0f;
    }
    
    // Scroll View
    scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    scroll.backgroundColor = [UIColor colorWithRed:(200.0/255.0) green:(15.0/255.0) blue:(22.0/255.0) alpha:1.0f];
    scroll.delegate=self;
    scroll.pagingEnabled=YES;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    [scroll setContentSize:CGSizeMake(scroll.frame.size.width*4, 0)];
    
    // page control
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0.0, scroll.frame.size.height - 45.0 - bottomPadding, 600.0, 38.0)];
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.numberOfPages = 4;
    pageControl.userInteractionEnabled = NO;
    //[pageControl addTarget:self action:@selector(pageChanged) forControlEvents:UIControlEventValueChanged];
    
    //- iconArray, mainTextArray, subTextArray - all 3 arrays should have same number of elements.
    NSArray *iconArray = @[@"im_international roaming",
                           @"im_unreachable",
                           @"im_SIMless",
                           @"im_reachme"];
    
    NSArray *mainTextArray = @[@"Save high roaming costs",
                               @"Never be unreachable",
                               @"Link multiple numbers",
                               @"Get calls in any device"];
    NSArray *subTextArray =
                @[@"Receive all incoming calls in the app, when traveling abroad, as long as you're connected to data. Say goodbye to expensive roaming packages.",
                  @"Get calls over WiFi, when your phone is out of coverage, unreachable, or in flight mode.",
                  @"Link up to 10 numbers in the app and receive calls and voicemails for all. No hassles of carrying extra phones.",
                  @"Install the app on any device, and start receiving incoming calls even if your SIM card is not present."];
    
    CGFloat x=0;
    for(int i=0;i<4;i++)
    {
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(x+0.0, 85.0, scroll.frame.size.width, scroll.frame.size.width - 80.0)];
        [image setImage:[UIImage imageNamed:[iconArray objectAtIndex:i]]];
        
        UILabel *mainText = [[UILabel alloc] initWithFrame:CGRectMake(x+0.0, scroll.frame.size.height - 170.0 - bottomPadding - topPadding, scroll.frame.size.width, 24.0)];
        mainText.textAlignment = NSTextAlignmentCenter;
        mainText.font = [UIFont boldSystemFontOfSize:19.0];
        mainText.textColor = [UIColor whiteColor];
        mainText.text = [mainTextArray objectAtIndex:i];
        mainText.numberOfLines = 2;
        
        UILabel *subText = [[UILabel alloc] initWithFrame:CGRectMake(x+25.0, scroll.frame.size.height - 135.0 - bottomPadding - topPadding, scroll.frame.size.width - 50.0, 75.0)];
        subText.textAlignment = NSTextAlignmentCenter;
        subText.font = [UIFont systemFontOfSize:15.0];
        subText.textColor = [UIColor whiteColor];
        subText.text = [subTextArray objectAtIndex:i];
        subText.numberOfLines = 10;
        
        [scroll addSubview:image];
        [scroll addSubview:mainText];
        [scroll addSubview:subText];
        x+=scroll.frame.size.width;
    }
    
    [self.view addSubview:scroll];
    [self.view addSubview:pageControl];
    
    UIImageView *reachMeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(26.0, 25.0 + topPadding, 164.0, 36.0)];
    reachMeLogo.image = [UIImage imageNamed:@"im_reachme_logo"];
    [self.view addSubview:reachMeLogo];
    
    skipButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0, DEVICE_HEIGHT - 45.0 - bottomPadding, 50.0, 38.0)];
    [skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    skipButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [skipButton addTarget:self action:@selector(skipTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
    
    nextOrEnterButton = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH - 70.0, DEVICE_HEIGHT - 45.0 - bottomPadding, 66.0, 38.0)];
    [nextOrEnterButton setTitle:@"" forState:UIControlStateNormal];
    [nextOrEnterButton setImage:[UIImage imageNamed:@"ic_arrow_left"] forState:UIControlStateNormal];
    nextOrEnterButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [nextOrEnterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextOrEnterButton addTarget:self action:@selector(enterTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextOrEnterButton];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSArray *colorArray = @[[UIColor colorWithRed:(200.0/255.0) green:(15.0/255.0) blue:(22.0/255.0) alpha:1.0f],[UIColor colorWithRed:(108.0/255.0) green:(200.0/255.0) blue:(53.0/255.0) alpha:1.0f],[UIColor colorWithRed:(224.0/255.0) green:(192.0/255.0) blue:(13.0/255.0) alpha:1.0f],[UIColor colorWithRed:(0.0/255.0) green:(141.0/255.0) blue:(232.0/255.0) alpha:1.0f]];
    CGFloat viewWidth = scrollView.frame.size.width;
    int pageNumber = floor((scrollView.contentOffset.x - viewWidth/50) / viewWidth) +1;
    pageControl.currentPage=pageNumber;
    
    CGFloat maximumHorizontalOffset = scrollView.contentSize.width - CGRectGetWidth(scrollView.frame);
    CGFloat currentHorizontalOffset = scrollView.contentOffset.x;
    
    // percentages
    CGFloat percentageHorizontalOffset = currentHorizontalOffset / maximumHorizontalOffset;
    if (scrollView.contentOffset.x > 0 && scrollView.contentOffset.x < viewWidth) {
        scroll.backgroundColor = [self fadeFromColor:colorArray[0] toColor:colorArray[1] withPercentage:percentageHorizontalOffset*3];
    }else if (scrollView.contentOffset.x > viewWidth && scrollView.contentOffset.x < viewWidth * 2){
        scroll.backgroundColor = [self fadeFromColor:colorArray[1] toColor:colorArray[2] withPercentage:(percentageHorizontalOffset-0.333333)*3];
    }else if (scrollView.contentOffset.x > viewWidth * 2 && scrollView.contentOffset.x < viewWidth * 3){
        scroll.backgroundColor = [self fadeFromColor:colorArray[2] toColor:colorArray[3] withPercentage:(percentageHorizontalOffset-0.666667)*3];
    }
    if (pageNumber == 3) {
        [skipButton setTitle:@"" forState:UIControlStateNormal];
        skipButton.enabled = NO;
        [nextOrEnterButton setTitle:@"Enter" forState:UIControlStateNormal];
        [nextOrEnterButton setImage:nil forState:UIControlStateNormal];
    }else if (pageNumber < 3){
        [skipButton setTitle:@"Skip" forState:UIControlStateNormal];
        skipButton.enabled = YES;
        [nextOrEnterButton setTitle:@"" forState:UIControlStateNormal];
        [nextOrEnterButton setImage:[UIImage imageNamed:@"ic_arrow_left"] forState:UIControlStateNormal];
    }
}

- (UIColor *)fadeFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor withPercentage:(CGFloat)percentage
{
    // get the RGBA values from the colours
    CGFloat fromRed, fromGreen, fromBlue, fromAlpha;
    [fromColor getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed, toGreen, toBlue, toAlpha;
    [toColor getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    //calculate the actual RGBA values of the fade colour
    CGFloat red = (toRed - fromRed) * percentage + fromRed;
    CGFloat green = (toGreen - fromGreen) * percentage + fromGreen;
    CGFloat blue = (toBlue - fromBlue) * percentage + fromBlue;
    CGFloat alpha = (toAlpha - fromAlpha) * percentage + fromAlpha;
    
    // return the fade colour
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)pageChanged {
    
    long int pageNumber = pageControl.currentPage;
    
    CGRect frame = scroll.frame;
    frame.origin.x = frame.size.width*pageNumber;
    frame.origin.y=0;
    
    [scroll scrollRectToVisible:frame animated:YES];
}

- (IBAction)skipTapped:(id)sender
{
    //Push to Login screen
    AppDelegate* appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    appDelegate.window.rootViewController = [[UIStateMachine sharedStateMachineObj]getRootViewController];
}

- (IBAction)enterTapped:(id)sender
{
    CGFloat viewWidth = scroll.frame.size.width;
    if (pageControl.currentPage == 0) {
        CGPoint contentOffset = scroll.contentOffset;
        contentOffset.x = viewWidth;
        [scroll setContentOffset:contentOffset animated:YES];
    }else if (pageControl.currentPage == 1){
        CGPoint contentOffset = scroll.contentOffset;
        contentOffset.x = viewWidth * 2;
        [scroll setContentOffset:contentOffset animated:YES];
    }else if (pageControl.currentPage == 2){
        CGPoint contentOffset = scroll.contentOffset;
        contentOffset.x = viewWidth * 3;
        [scroll setContentOffset:contentOffset animated:YES];
    }else if (pageControl.currentPage == 3){
        //Push to Login Screen
        AppDelegate* appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
        appDelegate.window.rootViewController = [[UIStateMachine sharedStateMachineObj]getRootViewController];
    }
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
