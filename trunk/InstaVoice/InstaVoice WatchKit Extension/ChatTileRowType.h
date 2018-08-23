//
//  ChatTileRowType.h
//  InstaVoice
//
//  Created by adwivedi on 13/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface ChatTileRowType : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* rowDescription;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *messageIcon;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *timeIcon;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *groupForImage;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *remoteUserImage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;

@end
