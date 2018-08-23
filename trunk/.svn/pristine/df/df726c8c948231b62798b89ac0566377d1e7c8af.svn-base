//
//  SharingIVViewController.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 11/4/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableColumns.h"
#import "UIType.h"
#import "Macro.h"

@protocol ShareMessageDelegate <NSObject>
-(void)shareMessageAction:(SliderMenuOption)userSelection;
-(void)voiceToTextButtonAction:(NSString *)convertedText;
@end

@interface SharingIVViewController : UIViewController{
    //DC
    BOOL isReceivedVoiceMail;
    BOOL isSentVoiceMail;
    
    BOOL isReceivedMissedCall;
    BOOL isSentMissedCall;
    
    BOOL isReceivedTextMessage;
    BOOL isSentTextMessage;
    
    BOOL isDeleteMessage;
    BOOL isWithDrawMessage;
    
    BOOL isGroupSentMessage;
    BOOL isGroupReceivedMessage;
}
@property (weak, nonatomic) IBOutlet UIButton *cpyPasteButton;
//
@property (weak, nonatomic) IBOutlet UIButton *withdrawButton;
@property (strong, nonatomic) IBOutlet UIButton *withDrawMissedCallButton;
//
@property (assign, nonatomic) BOOL copyEnabled;
@property (assign, nonatomic) BOOL voiceToTextEnabled;
@property (assign, nonatomic) BOOL isMissedCallMsg;
@property (assign, nonatomic) BOOL isVoboloPage;
@property (assign, nonatomic) BOOL isNotesPage;
@property (assign, nonatomic) BOOL isMsgSendingFailed;
@property (weak, nonatomic) id<ShareMessageDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *missedCallMenu;
@property (weak, nonatomic) IBOutlet UIView *normalMenu;
//KM
@property (nonatomic) CGRect rectangleForHighlightedCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMessageDictionary:(NSDictionary*)dic isVobolo:(BOOL)isVoboloPage andFrameForSelectedIndexPath:(CGRect)frame;
- (IBAction)removeOverLayFromUI:(id)sender;
@end
