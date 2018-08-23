//
//  SharingIVViewController.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 11/4/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "SharingIVViewController.h"
#import "MZFormSheetController.h"
#import "MZCustomTransition.h"
#import "Macro.h"
#import "SettingModel.h"
#import "Setting.h"
#import "ConversationApi.h"
#import "IVColors.h"
#import "Logger.h"


@interface SharingIVViewController ()
- (IBAction)removeOverLayFromUI:(id)sender;
- (IBAction)messageLikeTouched:(id)sender;
- (IBAction)sharingIVTouched:(id)sender;
- (IBAction)sharingFBTouched:(id)sender;
- (IBAction)sharingTWTouched:(id)sender;
- (IBAction)sharingVoboloTouched:(id)sender;
- (IBAction)sharingSocialTouched:(id)sender;
- (IBAction)messageCopyTouched:(id)sender;
- (IBAction)messageDeleteTouched:(id)sender;
- (IBAction)messageCallTouched:(id)sender;
//
- (IBAction)messageWithdrawTouched:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *socialSharingView;
@property (weak, nonatomic) IBOutlet UIView *voboloSharingView;
@property (weak, nonatomic) IBOutlet UIView *sendingFailedView;

@property (weak, nonatomic) IBOutlet UIButton *deleteMissedCallButton;
@property (weak, nonatomic) IBOutlet UIButton *callBackMissedCallButton;

@property (weak, nonatomic) IBOutlet UIButton *deleteFailedSentMessage;

// these are the buttons on the social sharing view, sans the copypaste icon
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *instavoiceButton;
@property (weak, nonatomic) IBOutlet UIButton *socialNetworkingButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *topConstraintsForButtons;


@end

@implementation SharingIVViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMessageDictionary:(NSDictionary*)dic isVobolo:(BOOL)isVoboloPage andFrameForSelectedIndexPath:(CGRect)frame;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //DC
        isReceivedVoiceMail = NO;
        isSentVoiceMail = NO;
        isReceivedMissedCall = NO;
        isSentMissedCall = NO;
        isReceivedTextMessage = NO;
        isSentTextMessage = NO;
        
        isWithDrawMessage = NO;
        isDeleteMessage = NO;
        isGroupSentMessage = NO;
        isGroupReceivedMessage = NO;
        
        self.voiceToTextEnabled = NO;
        self.rectangleForHighlightedCell = frame;
        
        if ([[dic valueForKey:MSG_CONTENT_TYPE] isEqualToString:@"t"]) {
            self.copyEnabled = YES;
        }
        else {
            self.copyEnabled = NO;
        }
        
        if ([[dic valueForKey:MSG_TYPE] isEqualToString:MISSCALL]) {
            self.isMissedCallMsg = YES;
            self.copyEnabled = NO;
        }
        else {
            self.isMissedCallMsg = NO;
        }
        
        self.isVoboloPage = isVoboloPage;
        if([[dic valueForKey:MSG_STATE] isEqualToString:API_NETUNAVAILABLE] || [[dic valueForKey:MSG_STATE] isEqualToString:API_UNSENT])
        {
            self.isMsgSendingFailed = YES;
        }
        
        //DC
        NSString* msgType = [dic valueForKey:MSG_TYPE];
        NSString* conversationType = [dic valueForKey:CONVERSATION_TYPE];
        NSString* msgFlow = [dic valueForKey:MSG_FLOW];
        
        if ([msgType isEqualToString:NOTES_TYPE] || [msgType isEqualToString:VB_TYPE]) {
            isSentTextMessage = YES;
        }
        else if ([msgType isEqualToString:IV_TYPE] && [msgFlow isEqualToString:MSG_FLOW_R] &&
            ![conversationType isEqualToString:GROUP_TYPE])
        {
            isReceivedTextMessage = YES;
            KLog(@"isReceivedTextMessage");
        }
        else if ([msgType isEqualToString:IV_TYPE] && [msgFlow isEqualToString:MSG_FLOW_S] &&
                 ![conversationType isEqualToString:GROUP_TYPE])
        {
            isSentTextMessage = YES;
            KLog(@"isSentTextMessage");
        }
        else if ([msgType isEqualToString:@"mc"] && [msgFlow isEqualToString:MSG_FLOW_S] && ![conversationType isEqualToString:GROUP_TYPE])
        {
            isSentMissedCall = YES;
            KLog(@"isSentMissedCall");
        }
        else if([msgType isEqualToString:@"mc"] && [msgFlow isEqualToString:MSG_FLOW_R] && ![conversationType isEqualToString:GROUP_TYPE])
        {
            isReceivedMissedCall = YES;
            KLog(@"isReceivedMissedCall");
        }
        else if ([msgType isEqualToString:@"vsms"] && [msgFlow isEqualToString:MSG_FLOW_S] && ![conversationType isEqualToString:GROUP_TYPE])
        {
            NSString* msgSubType = [[dic valueForKey:MSG_SUB_TYPE]lowercaseString];
            if([msgSubType isEqualToString:AVS_TYPE]) {
                isSentVoiceMail = YES;
                KLog(@"isSentVoiceMail");
            }
            else {
                isSentTextMessage = YES;
                KLog(@"isSentTextMessage");
            }
            
        }
        else if ([msgType isEqualToString:@"vsms"] && [msgFlow isEqualToString:MSG_FLOW_R] && ![conversationType isEqualToString:GROUP_TYPE])
        {
            isReceivedVoiceMail = YES;
            KLog(@"isReceivedVoiceMail");
        }
        else if([conversationType isEqualToString:GROUP_TYPE])
        {
            if ([msgFlow isEqualToString:MSG_FLOW_R]) {
                isGroupReceivedMessage = YES;
            }
            else if ([msgFlow isEqualToString:MSG_FLOW_S]) {
                isGroupSentMessage = YES;
            }
        }
    }
    return self;
}

- (void)setRectangleForHighlightedCell:(CGRect)rectangleForHighlightedCell
{
    float yPos = rectangleForHighlightedCell.origin.y;
    float height = rectangleForHighlightedCell.size.height;
    
    if(yPos < 0)
    {
        yPos = 0;
        height = 55;
        rectangleForHighlightedCell.origin.y = yPos;
        rectangleForHighlightedCell.size.height = height;
    }
    else
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenHeight = screenRect.size.height;
        if(yPos + height > screenHeight)
        {
            height = 55;
            rectangleForHighlightedCell.size.height = height;
        }
    }
    _rectangleForHighlightedCell = rectangleForHighlightedCell;
}
//

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.normalMenu setBackgroundColor:[UIColor clearColor]];
    [self.missedCallMenu setBackgroundColor:[UIColor clearColor]];
    [self.normalMenu setBackgroundColor:[UIColor clearColor]];

    // create the view to overlay on top of the cell
    if (!CGRectIsNull(self.rectangleForHighlightedCell)) {
        UIView *cellOverlayView = [[UIView alloc] initWithFrame:CGRectMake(self.rectangleForHighlightedCell.origin.x, 66 + self.rectangleForHighlightedCell.origin.y, self.rectangleForHighlightedCell.size.width, self.rectangleForHighlightedCell.size.height)];
        cellOverlayView.backgroundColor = [UIColor colorWithWhite:1 alpha:.95];
        [self.view addSubview:cellOverlayView];
        [self.view sendSubviewToBack:cellOverlayView];

        UIBezierPath *topLine = [UIBezierPath new];
        [topLine moveToPoint:CGPointMake(0, 0)];
        [topLine addLineToPoint:CGPointMake(cellOverlayView.frame.size.width, 0)];
        CAShapeLayer *topLineLayer = [CAShapeLayer layer];
        topLineLayer.path = topLine.CGPath;
        topLineLayer.strokeColor = [UIColor colorWithWhite:.85 alpha:1].CGColor;
        topLineLayer.borderWidth = 1;
        [cellOverlayView.layer addSublayer:topLineLayer];

        UIBezierPath *bottomLine = [UIBezierPath new];
        [bottomLine moveToPoint:CGPointMake(0, cellOverlayView.frame.size.height)];
        [bottomLine addLineToPoint:CGPointMake(cellOverlayView.frame.size.width, cellOverlayView.frame.size.height)];
        CAShapeLayer *bottomLineLayer = [CAShapeLayer layer];
        bottomLineLayer.path = bottomLine.CGPath;
        bottomLineLayer.strokeColor = topLineLayer.strokeColor;
        bottomLineLayer.borderWidth = topLineLayer.borderWidth;
        [cellOverlayView.layer addSublayer:bottomLineLayer];

//        [self.view insertSubview:cellOverlayView belowSubview:self.socialSharingView];

        for (NSLayoutConstraint *constraint in self.topConstraintsForButtons) {
            constraint.constant = self.rectangleForHighlightedCell.origin.y + (self.rectangleForHighlightedCell.size.height / 2) + 44;
        }
    }
	//
    if(self.isMissedCallMsg)
    {
        self.normalMenu.hidden = YES;
        self.sendingFailedView.hidden = YES;
    }
    else if(self.isMsgSendingFailed)
    {
        self.normalMenu.hidden = YES;
        self.missedCallMenu.hidden = YES;
    }
    else
    {
        self.missedCallMenu.hidden = YES;
        self.sendingFailedView.hidden = YES;
        
        if (!self.copyEnabled) {
            [self.cpyPasteButton setAlpha:0.2];
        }
//        if (!self.copyEnabled && !self.voiceToTextEnabled) {
//            [self.cpyPasteButton setAlpha:0.2];
//        }
//        else if (self.voiceToTextEnabled){
//            [self.cpyPasteButton setImage:nil forState:UIControlStateNormal];
//            [self.cpyPasteButton setImage:[UIImage imageNamed:@"add_number_icon"] forState:UIControlStateNormal];
//        }
    }

    self.socialSharingView.layer.borderColor = [IVColors lightGreyColor].CGColor;
    self.socialSharingView.layer.borderWidth = 1;
    self.socialSharingView.layer.cornerRadius = 10;
    self.socialSharingView.clipsToBounds = YES;
    [self.socialSharingView setHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SettingModel* setting = [Setting sharedSetting].data;
    BOOL vbEnable = setting.vbEnabled;
    [self.voboloSharingView setHidden:!vbEnable];
    if (self.isVoboloPage) {
        [self.voboloSharingView setHidden:YES];
    }

    // set up the images for the icons
    [self.likeButton setImage:[[UIImage imageNamed:@"longpress-like"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.likeButton setImage:[[UIImage imageNamed:@"longpress-like-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    self.likeButton.tintColor = [IVColors redColor];

    [self.socialNetworkingButton setImage:[[UIImage imageNamed:@"longpress-share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.socialNetworkingButton setImage:[[UIImage imageNamed:@"longpress-share-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    self.socialNetworkingButton.tintColor = [IVColors blueOutlineColor];

    [self.cpyPasteButton setImage:[[UIImage imageNamed:@"longpress-copy"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.cpyPasteButton setImage:[[UIImage imageNamed:@"longpress-copy-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    self.cpyPasteButton.tintColor = [IVColors blueOutlineColor];
    //DC
    //WithdrawButton on longpress
    [self.withdrawButton setImage:[[UIImage imageNamed:@"longpress-undo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.withdrawButton setImage:[[UIImage imageNamed:@"longpress-undo-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    self.withdrawButton.tintColor = [IVColors redOutlineColor];
   
    //WithdrawMissedCallButton on longpress
    [self.withDrawMissedCallButton setImage:[[UIImage imageNamed:@"longpress-undo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.withDrawMissedCallButton setImage:[[UIImage imageNamed:@"longpress-undo-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    self.withDrawMissedCallButton.tintColor = [IVColors redOutlineColor];
    
    //
    
    [self.deleteButton setImage:[[UIImage imageNamed:@"longpress-delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.deleteButton setImage:[[UIImage imageNamed:@"longpress-delete-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    self.deleteButton.tintColor = [IVColors redOutlineColor];

    // buttosn on the missed call menu
    [self.deleteMissedCallButton setImage:[[UIImage imageNamed:@"longpress-delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.deleteMissedCallButton setImage:[[UIImage imageNamed:@"longpress-delete-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    self.deleteMissedCallButton.tintColor = [IVColors redOutlineColor];

    [self.callBackMissedCallButton setImage:[[UIImage imageNamed:@"return-call"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.callBackMissedCallButton setImage:[[UIImage imageNamed:@"return-call-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    self.callBackMissedCallButton.tintColor = [IVColors blueOutlineColor];


    // buttons on the failed sending menu
    [self.deleteFailedSentMessage setImage:[[UIImage imageNamed:@"longpress-delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.deleteFailedSentMessage setImage:[[UIImage imageNamed:@"longpress-delete-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    self.deleteFailedSentMessage.tintColor = [IVColors redOutlineColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)removeOverLayFromUI:(id)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}

- (IBAction)messageLikeTouched:(id)sender {
    [self.delegate shareMessageAction:menuOptionLikeMessage];
    [self removeOverLayFromUI:nil];
}

- (IBAction)sharingIVTouched:(id)sender {
    [self.delegate shareMessageAction:menuOptionShareMessage];
    [self removeOverLayFromUI:nil];
}

- (IBAction)sharingFBTouched:(id)sender
{
    [self.delegate shareMessageAction:menuOptionPostOnFB];
    [self removeOverLayFromUI:nil];
}

- (IBAction)sharingTWTouched:(id)sender
{
    [self.delegate shareMessageAction:menuOptionPostOnTW];
    [self removeOverLayFromUI:nil];
}

- (IBAction)sharingVoboloTouched:(id)sender
{
    [self.delegate shareMessageAction:menuOptionPostOnVobolo];
    [self removeOverLayFromUI:nil];
}


- (IBAction)sharingSocialTouched:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        [self.socialSharingView setHidden:NO];
    }];
}

- (IBAction)messageCopyTouched:(id)sender
{
    [self.delegate shareMessageAction:menuOptionCopy];
    [self removeOverLayFromUI:nil];
}

- (IBAction)messageDeleteTouched:(id)sender {
    //DC
    isDeleteMessage = YES;
    isWithDrawMessage =NO;
    if (isSentTextMessage || isReceivedTextMessage)
    {
        [self commonAlert:@"Delete message?" :@"This message will be deleted from your account." :@"Delete"];
    }
    else if(isReceivedMissedCall || isSentMissedCall)
    {
        [self commonAlert:@"Delete missed call?" :@"This missed call will be deleted from your account." :@"Delete"];
    }
    else if(isReceivedVoiceMail || isSentVoiceMail)
    {
        [self commonAlert:@"Delete voicemail?" :@"This voicemail call will be deleted from your account." :@"Delete"];
    }
    else
    if (isGroupReceivedMessage || isGroupSentMessage) {
        [self commonAlert:@"Delete message?" :@"This message will be deleted from your account." :@"Delete"];
    }
    else if(self.isNotesPage || self.isVoboloPage) {
        [self.delegate shareMessageAction:menuOptionDelete];
    } else {
        [self commonAlert:@"Delete message?" :@"This message will be deleted from your account." :@"Delete"];
    }
    
    [self removeOverLayFromUI:nil];
}

- (IBAction)messageCallTouched:(id)sender {
    [self.delegate shareMessageAction:menuOptionMakeCall];
    [self removeOverLayFromUI:nil];
}
//DC
- (IBAction)messageWithdrawTouched:(id)sender{
    isWithDrawMessage =YES;
    isDeleteMessage = NO;
    if (isSentTextMessage)
    {
        [self commonAlert:@"Withdraw message?" :@"This message will be deleted from your account and the recipient's account." :@"Withdraw"];
    }
    else if(isSentMissedCall)
    {
        [self commonAlert:@"Withdraw missed call?" :@"This missed call will be deleted from your account and the recipient's account." :@"Withdraw"];
    }
    else if(isSentVoiceMail)
    {
        [self commonAlert:@"Withdraw voicemail?" :@"This voicemail will be deleted from your account and the recipient's account." :@"Withdraw"];
    }
    else if(isGroupSentMessage){
        [self commonAlert:@"Withdraw message?" :@"This message will be deleted from your account and group members accounts." :@"Withdraw"];
    }
    
    [self removeOverLayFromUI:nil];
}
//DC
-(void)commonAlert:(NSString*) alertTitle : (NSString*) alertMessage :(NSString*)okButton
{
    UIAlertView *commonAlert = [[UIAlertView alloc]initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:okButton, nil];
    [commonAlert show];
}
//DC
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (isDeleteMessage)
    {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            KLog(@"Deleting Messages isSentTextMessage");
            [self.delegate shareMessageAction:menuOptionDelete];
        }
    }
    else if (isWithDrawMessage)
    {
        if (buttonIndex != [alertView cancelButtonIndex])
        {
            if (isSentTextMessage) {
                KLog(@"Withdrwaing SentTextMessage");
            } else if(isSentMissedCall) {
                KLog(@"Withdrwaing SentMissedCall");
            }
            else if (isSentVoiceMail) {
                KLog(@"Withdrwaing SentVoiceMail");
            }
            else if (isGroupReceivedMessage) {
                KLog(@"Withdrwaing GroupReceivedMessage");
            }
            
            [self.delegate shareMessageAction:menuOptionWithdraw];
        }
    }
    
    [self removeOverLayFromUI:nil];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

@end
