//
//  UIStateMachine.m
//  InstaVoice
//
//  Created by Eninov on 22/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "UIStateMachine.h"
#import "Macro.h"
#import "BaseUI.h"
#import "UIType.h"

#import "FriendsScreen.h"

#import "InsideConversationScreen.h"
#import "VerificationOTPViewController.h"
#import "UIEventType.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "ChatGridViewController.h"
    #import "AppDelegate.h"
#endif

#import "MyNotesScreen.h"
#import "MyVoboloScreen.h"

#import "BaseWebViewScreen.h"
#import "AboutUsWebViewScreen.h"
#import "FacebookWebViewScreen.h"
#import "MobileEntryViewController.h"
#import "BrandingScreenViewController.h"

#define NON_RETINA_IPHONE_HEOGHT  480
#define NEW_MENU_SCREEN 1


static UIStateMachine *stateMechineObj = NULL;

@implementation UIStateMachine
-(id)init
{
    self = [super init];
    if(self)
    {
        curUI = nil;
        initialVC = nil;
        appDelegate = (AppDelegate *)APP_DELEGATE;
        self.tabIndex = 2; //ChatTypeAll
    }
    
    return self;
}

/*
   getRootViewController returns the rootViewController object which should be the first view to the user
 */
-(UINavigationController*)getRootViewController {
    
    if(nil == initialVC) {
        MobileEntryViewController* vc = [[MobileEntryViewController alloc]initWithNibName:@"MobileEntryViewController" bundle:nil];
        initialVC = [[UINavigationController alloc]initWithRootViewController:vc];
    } else {
         [initialVC popToRootViewControllerAnimated:NO];
    }
    
    return initialVC;
}

+(UIStateMachine *)sharedStateMachineObj
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stateMechineObj = [[UIStateMachine alloc]init];
    });
    return stateMechineObj;
}

-(int)setCurrentUI:(BaseUI *)curView
{
    curUI = curView;
    return SUCCESS;
}

-(int)getCurrentUIType
{
    int uiType = -1;
    if(curUI != nil)
    {
        uiType = curUI.uiType;
    }
    return uiType;
}

-(BaseUI *)getCurrentUI
{
    return curUI;
}

-(int)notifyUI:(NSMutableDictionary *)resultDic
{
    [self performSelectorOnMainThread:@selector(handleEvent:) withObject:resultDic waitUntilDone:NO];
    return SUCCESS;
}

-(int)handleEvent:(NSMutableDictionary *)resultDic
{
    if(curUI != nil)
    {
        [curUI handleEvent:resultDic];
    }
    else
    {
        EnLoge(@"Current UI Object is nil");
    }
    return SUCCESS;
}

-(int)setCurrentPresentedUI:(BaseUI *)curView
{
    curPresentedUI = curView;
    return SUCCESS;
}

-(BaseUI *)getCurrentPresentedUI
{
    return curPresentedUI;
}

@end
