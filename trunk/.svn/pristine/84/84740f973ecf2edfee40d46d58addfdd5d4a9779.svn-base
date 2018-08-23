//
//  AboutUSScreen.m
//  InstaVoice
//
//  Created by Vivek Mudgil on 18/10/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "BaseWebViewScreen.h"
#import  "Logger.h"
#import "SizeMacro.h"
#import "ScreenUtility.h"



@interface BaseWebViewScreen ()

@end

@implementation BaseWebViewScreen

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
    webView.delegate = self;
    address = [appDelegate.confgReader getDocsUrl];
    EnLogd(@"Url is %@",address);

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addSubview:topView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [topView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showProgressBar];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideProgressBar];
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideProgressBar];
    int erroeCode = (int)[error code];
    NSString *errorStr = nil;
    EnLoge(@"Error for WEBVIEW: %d %@", erroeCode,[error description]);
    switch (erroeCode)
    {
        case NSURLErrorTimedOut:
            errorStr = NSLocalizedString(@"NET_TIME_OUT", nil);
            break;
        case NSURLErrorCannotFindHost:
            errorStr = NSLocalizedString(@"SERVER_NOT_FOUND", nil);
            break;
        case NSURLErrorCannotConnectToHost:
            errorStr = NSLocalizedString(@"SERVER_NOT_RECHABLE", nil);
            break;
        case NSURLErrorNetworkConnectionLost:
            errorStr = NSLocalizedString(@"NET_NOT_AVAILABLE", nil);
            break;
        default:
          //  errorStr = NSLocalizedString(@"SERVER_NOT_RECHABLE", nil);
            break;
    }
    
    if(errorStr != nil && [errorStr length]>0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
       // [appDelegate.stateMachineObj nextState:BACKBTNCLICK];
    }
}
@end
