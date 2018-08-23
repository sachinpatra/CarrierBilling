//
//  TextMessageInterfaceController.h
//  InstaVoice
//
//  Created by Jatin Mitruka on 4/17/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface TextMessageInterfaceController : WKInterfaceController
{
    NSString* _contactNumber;

}
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *remoteUserName;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *groupForTextMessage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *textMessageLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *remoteUserImage;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *groupForImage;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;
- (IBAction)callAction;
- (IBAction)forceTouceButtonAction;
@end
