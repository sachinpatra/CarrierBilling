//
//  AboutUsWebViewScreen.m
//  InstaVoice
//
//  Created by Vivek Mudgil on 25/10/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "AboutUsWebViewScreen.h"
#import "SizeMacro.h"


#define PARAMETER1              @"https://reachme.instavoice.com/privacy-policy"
#define PARAMETER2              @"https://reachme.instavoice.com/terms"
#define PARAMETER3              @"https://reachme.instavoice.com/faq"
#define PARAMETER4              @"https://reachme.instavoice.com/faq"

@interface AboutUsWebViewScreen ()

@end

@implementation AboutUsWebViewScreen
@synthesize webViewType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self webViewLoad];
 }


-(void)webViewLoad
{
    NSString *urlString = @"";

    switch (webViewType)
    {
        case PRIVACY_TYPE:
        {
            urlString = PARAMETER1;
        }
            break;
        case TERMS_N_CONDN:
        {
            urlString = PARAMETER2;
        }
             break;
        case FAQS:
        {
            urlString = PARAMETER3;
        }
            break;
        case MISSEDCALL_HELP:
        {
            urlString = PARAMETER4;
        }
            break;
        default:
            break;
    }
    //dp:added for faster and smooth scroll
    webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    [webView setScalesPageToFit:YES];
     webView.delegate = self;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    KLog(@"Error : %@",error);
}

- (void)viewWillAppear:(BOOL)animated
{
     self.uiType = ABOUTUS_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)customNavigationTitle
{
    UILabel *titleLabel = nil;
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_59, SIZE_8, SIZE_218, SIZE_30)];
    }
    else
    {
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_59, SIZE_23, SIZE_218, SIZE_30)];
    }
    [titleLabel setFont:[UIFont fontWithName:HELVETICANEUE_MEDIUM size:SIZE_18]];//[Common preferredFontForTextStyleInApp:UIFontTextStyleBody]];//[UIFont fontWithName:HELVETICANEUE_MEDIUM size:SIZE_18]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor blackColor]];
    switch (webViewType)
    {
        case PRIVACY_TYPE:
        {
           titleLabel.text = NSLocalizedString(@"PRIVACY_POLICY", nil);;
        }
            break;
        case TERMS_N_CONDN:
        {
           titleLabel.text = NSLocalizedString(@"TERMS_AND_CONDITIONS", nil);
        }
            break;
        case FAQS:
        {
            titleLabel.text = NSLocalizedString(@"FAQ_TITLE", nil);
        }
            break;
        case MISSEDCALL_HELP:
        {
            titleLabel.text = NSLocalizedString(@"MISSED_CALL_HELP", nil);
        }
            break;
        default:
            break;
    }

    
    [topView addSubview:titleLabel];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideProgressBar];    
}
@end
