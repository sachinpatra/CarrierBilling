//
//  InterfaceController.h
//  InstaVoice WatchKit Extension
//
//  Created by adwivedi on 10/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceTable *tilesListView;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *brandImage;
@property (strong, nonatomic) NSArray* chatList;
@property (strong,nonatomic) NSArray *dateArray;
@end
