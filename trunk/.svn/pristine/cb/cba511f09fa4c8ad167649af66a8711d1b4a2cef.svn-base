//
//  UIStateMachine.h
//  InstaVoice
//
//  Created by Eninov on 22/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIType.h"
#import "UIEventType.h"

#define MAXUISTACK     MAX_UI_TYPE //10

@class BaseUI;
@class AppDelegate;
@interface UIStateMachine : NSObject
{
    BaseUI *curUI;
    BaseUI *curPresentedUI;
    UINavigationController* initialVC;
    AppDelegate *appDelegate;
}

@property (atomic) NSInteger tabIndex;
@property (atomic) NSInteger pnClicked;
@property(nonatomic,strong)NSString* currentCallStatus;

+(UIStateMachine *)sharedStateMachineObj;
-(UINavigationController*)getRootViewController;


-(int)setCurrentUI:(BaseUI *)curView;
-(int)notifyUI:(NSMutableDictionary *)resultDic;
-(int)getCurrentUIType;
-(BaseUI *)getCurrentUI;
-(int)setCurrentPresentedUI:(BaseUI *)curView;
-(BaseUI *)getCurrentPresentedUI;


@end
