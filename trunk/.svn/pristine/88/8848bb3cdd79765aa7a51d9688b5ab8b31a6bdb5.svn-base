//
//  FacebookWebViewScreen.m
//  InstaVoice
//
//  Created by Vivek Mudgil on 25/10/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "FacebookWebViewScreen.h"
#import "SizeMacro.h"
#define FACEBOOK_TITLE  @"Facebook"
#define TWITTER_TITLE   @"Twitter"
@interface FacebookWebViewScreen ()

@end

@implementation FacebookWebViewScreen
@synthesize isFBCLick;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andFB:(BOOL)fb
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (fb) {
            self.isFBCLick = YES;
        }
        else
        {
            self.isFBCLick = NO;
        }
        self.isFromStoryboard = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *url= @"";
    if(isFBCLick)
    {
        url = [appDelegate.confgReader getFBConnectUrl];
    }
    else
    {
        url = [appDelegate.confgReader getTWConnectUrl];
    }
    NSString *userSecureKey = [appDelegate.confgReader getUserSecureKey];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",url,userSecureKey];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    EnLogd(@"Url is:%@",urlString);
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.uiType = FACEBOOK_WEB_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    [self customNavigationTitle];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}



-(void)customNavigationTitle
{
    UILabel *titleLabel = nil;
    //[[UILabel alloc]initWithFrame:CGRectMake(SIZE_59, SIZE_8, SIZE_218, SIZE_30)];
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_59, SIZE_8, SIZE_218, SIZE_30)];
    }
    else
    {
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_59, SIZE_23, SIZE_218, SIZE_30)];
    }
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont fontWithName:HELVETICANEUE_MEDIUM size:SIZE_18]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor blackColor]];
    if(self.isFBCLick)
    {
        titleLabel.text = NSLocalizedString(@"FACEBOOK_TITLE", nil);
    }
    else
    {
        titleLabel.text = NSLocalizedString(@"TWITTER_TITLE", nil);
    }
    [topView addSubview:titleLabel];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
