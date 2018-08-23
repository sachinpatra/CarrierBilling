//
//  IVSettingsWebViewController.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 16/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVSettingsWebViewController.h"
#import "Logger.h"

#ifdef REACHME_APP
    #define kTermsAndConditionsURL   @"https://reachme.instavoice.com/terms"
    #define kPrivacyPolicyURL        @"https://reachme.instavoice.com/privacy-policy"
    #define kFrequentlyAskedQuestionsURL @"https://reachme.instavoice.com/faq"
#else
    #define kTermsAndConditionsURL   @"https://instavoice.com/terms.html"
    #define kPrivacyPolicyURL        @"https://instavoice.com/privacy.html"
    #define kFrequentlyAskedQuestionsURL @"https://instavoice.com/faqs.html"
#endif

//Enums
#ifdef REACHME_APP
typedef NS_ENUM(NSUInteger,AboutInstaVoiceCells){
    eTermsAndConditionsCell = 2,
    ePrivacyPolicyCell = 3,
    eFrequentlyAskedQuestions = 0
};
#else
typedef NS_ENUM(NSUInteger,AboutInstaVoiceCells){
    eTermsAndConditionsCell = 3,
    ePrivacyPolicyCell = 4,
    eFrequentlyAskedQuestions = 0
};
#endif



@interface IVSettingsWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *settingsWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation IVSettingsWebViewController

#pragma mark - View Life Cycle - 
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadURLInWebViewForSelectedOption:self.selectedSettingOptions];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WebView Delegate Methods - 
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self stopAnimatingLoadingView];

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    [self stopAnimatingLoadingView];
    KLog(@"Error while loading the URL");
}
#pragma mark - Private Methdos -
- (void)loadURLInWebViewForSelectedOption:(NSInteger)withSelectedOption {
   
    [self startAnimatingLoadingView];
    self.loadingIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5);
    NSString *urlToLoad;
    NSString *viewTitle;
    switch (withSelectedOption) {
        case eTermsAndConditionsCell: {
            viewTitle = NSLocalizedString(@"Terms and Conditions", nil);
            urlToLoad = kTermsAndConditionsURL;
            break;
        }
        case ePrivacyPolicyCell: {
            viewTitle = NSLocalizedString(@"Privacy Policy", nil);
            urlToLoad = kPrivacyPolicyURL;
            break;
        }
        case eFrequentlyAskedQuestions: {
            viewTitle = NSLocalizedString(@"Frequently Asked Questions", nil);
            urlToLoad = kFrequentlyAskedQuestionsURL;
            break;
        }
            
        default:
            break;
    }
    self.title = viewTitle;
    [self.settingsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlToLoad]]];
    
}

- (void)stopAnimatingLoadingView {
    [self.loadingIndicator stopAnimating];
    self.loadingIndicator.hidden = YES;
}
- (void)startAnimatingLoadingView {
    [self.loadingIndicator startAnimating];
    self.loadingIndicator.hidden = NO;
}

#pragma mark - Memory CleanUp Methods - 
- (void)dealloc {
    self.selectedSettingOptions = 0;
    self.settingsWebView = nil;
    self.loadingIndicator = nil;
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
