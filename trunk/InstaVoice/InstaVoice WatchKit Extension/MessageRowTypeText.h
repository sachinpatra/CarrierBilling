//
//  MessageRowTypeText.h
//  InstaVoice
//
//  Created by adwivedi on 13/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface MessageRowTypeText : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* textMessage;
@end