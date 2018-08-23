//
//  ChatDetailInterfaceController.h
//  InstaVoice
//
//  Created by adwivedi on 13/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface ChatDetailInterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleText;
@property (weak, nonatomic) IBOutlet WKInterfaceTable *messageListView;

@property(nonatomic,strong)NSMutableArray* chatDataList;
@property(nonatomic,strong)NSMutableDictionary* userMessageDic;
@end
