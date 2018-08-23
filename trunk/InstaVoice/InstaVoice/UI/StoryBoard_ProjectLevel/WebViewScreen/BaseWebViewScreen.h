//
//  AboutUSScreen.h
//  InstaVoice
//
//  Created by Vivek Mudgil on 18/10/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
@interface BaseWebViewScreen : BaseUI<UIWebViewDelegate>
{
    IBOutlet UIWebView  *webView;
    NSString            *address;
    UIView              *topView;
}
@property(nonatomic,assign) BOOL isPresentedViewController;

@end
