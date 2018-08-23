//
//  ConversationScreen.h
//  InstaVoice
//
//  Created by Eninov on 13/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConversationApi.h"
#import "Audio.h"
#import "DrawCircle.h"
#import <CoreLocation/CoreLocation.h>
#import "CustomIOS7AlertView.h"
#import  <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "ConversationTableCell.h"
#import "ODRefreshControl.h"
#import "SharingIVViewController.h"
#import "BaseUI.h"
#import "EZAudio.h"
#import "MZFormSheetController.h"
#import "MZCustomTransition.h"
#import "SharingIVViewController.h"
#import "ShareFriendsListViewController.h"

@class CircleProgressView;
@class Common;

#define audioPlayUpdateInterval     0.050 //in seconds
#define ERROR_REASON                @"error_reason"

#define groupInfoAlertViewTag   191
#define ringAlertControllerTag  0x3232

typedef NS_ENUM(NSInteger,DSMessageType) {
    eNewMessage,
    eOldMessage,
    eOtherMessage
};

/**
 * This constitues of six subviews
 * * Screen Header View: This is modified navigation bar
 * * Chat View: This view contains the text and voice chat messages
 * * Footer View: This controls the recording and texting controls
 * * Keyboard View: This view allows typing of text message and provides
 *                  controls for sending text messages
 * * Recording View: This shows the recording animation and controls for the same
 * * Confirmation View: This is for taking action on reaching full recording
 */

@interface BaseConversationScreen : BaseUI <UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate,UITextViewDelegate,CLLocationManagerDelegate,AVAudioSessionDelegate,ShareMessageDelegate,AudioDelegate>
{
    NSMutableDictionary     *currentChatUserInfo;   //Get infomation of current chat user
    //Jan 23, 2017 NSMutableArray          *conversationList;      //Conversation List
    
    //APR 2017 IBOutlet UITableView*   chatView;
    IBOutlet UILabel        *msgTextLabel;          //show the msg like loading,no conversation
    
    //CMP UIView                  *_topView;              //Navigation bar view
    
    NSTimer                 *drawStripTimer;        //This is used to draw overlapping strip
    NSIndexPath             *activeIndexChatView;   //index of chat row which is in action
    UIImageView             *voiceCellView;         //Last clicked voice cell
    
    NSMutableDictionary* dicSections;
    NSMutableArray *arrDatesSorted;
    NSDateFormatter *sectionDateFormatter;
    
/** ------Varible for Recording setting------- **/
    int _maxVoiceMsgDuration;         //Maximum Recording Limit
    NSIndexPath* buttonTag;
    
   
#pragma mark Footer View

    IBOutlet UIImageView    *headsetImage;

#pragma mark Keyboard View
    //UITextView     *text;                      //textField
    
#pragma mark Recording View
    CircleProgressView      *circleDraw;                //View responsbile for animation
    IBOutlet UIView         *recordingView;             //recording view
    IBOutlet UIView         *circleSubView;             //recording circle view
    IBOutlet UILabel        *headingLabel;              //heading label for Recording
    __weak IBOutlet UIButton *appstoreConntectButton;
    __weak IBOutlet UIButton *closeBannerButton;
    
    UIView *bannerTopView;
    UIView *statusBarView;
    UIView *bannerView;
    NSTimer                 *recorderTimer;             //Timer For recording
    CGPoint                 imageViewPosition;          //x,y codinate of image rotate in view
    UILabel                 *timerLabel;                //Recording Timer Lable
    int                     setState;                   //State of recording
    BOOL                    _hasBeenExpanded;           // keeps tabs on if the text view has been expanded or not

    UIView         *containerView;
    UIView         *micButtonView1;
    UIView         *recordingArea1;
    UIButton       *cancelVoiceBtn1;
    UILabel        *swipeToCancelLabel1;
    UITextView     *text1;
    UIButton       *sendTextButton1;
    UIButton       *sendImageGalleryButton1;
    UIButton       *sendImageCameraButton1;
    UIImageView    *footerView1;
    UIButton       *micButton1;
    UIToolbar      *chatToolbar1;
    //UIToolbar      *toolbar;
    BOOL            hasExpanded, isPasteDone;
    CGRect          frame;
    CGFloat         height;
    BOOL            keyboardHide, isVoicemailHelpSent;
    
#pragma mark Varible for get the Location
    NSTimer                 *imageTime;
    BOOL                    _displayLoc;
    NSString                *audiofilePath; // it can be removed.
    BOOL                    _msgLimitExceeded;
    BOOL                    isRecordPause;
    
    BOOL  _isAlertPresent;
    BOOL _speakerMode;
    BOOL  isKeyboardPresent;
    CGRect tableViewFrameWhileLoading;
    CGRect tableViewFrameForImage;
    CGSize _kbSheetSize;
    BOOL _allowMessaging;
    NSIndexPath* _curIndexPath;
    CGFloat _tvHeight; //Height of the table view
    
    /** ------- Gesture Recognizer  ------- **/
    //In mic
    UIPanGestureRecognizer  *panRecognizer;//Gesture Recognizer for micButton Postion
    UIPinchGestureRecognizer *pinchRecognizer ;
    UISwipeGestureRecognizer *swipeRecognizer;
    //In Table view for bringing share menu
    UIGestureRecognizer *gestureMenuRecognizer;
    //DC
    UITapGestureRecognizer *tapGestureRecognizer;

    ODRefreshControl *_refreshControl;
    BOOL _beginRefreshingOldMessages;
    NSIndexPath* indexForAudioPlayed;
    CGFloat _textFieldWidth;
    BOOL    _shareMessage;
    ShareFriendsListViewController* _shareFriendsListVC;
    //DC
    int textViewLineNumber;
    BOOL _textViewChangeAfterMicIconTap;
    BOOL saveLastMsg;
    //MAY 2017
    BOOL isScrolling;
    BOOL recvdNewMsg;
    BOOL sendNewMsg;
    //BOOL getHeightForRows;
    BOOL deleteMsg;
    //
    UIAlertView* recordAlertView;
}

@property (atomic) BOOL getHeightForRows;
@property (nonatomic) BOOL setTextViewWhenAppGoesInBG;
@property (nonatomic) BOOL callConnected;

@property (nonatomic, retain) IBOutlet UITableView* chatView;
@property (nonatomic, retain) UITableViewCell* shareMenuSelectedCell;

@property(nonatomic)    NSString          *msgType;
@property(nonatomic)    Audio             *audioObj;
@property(nonatomic)    NSMutableDictionary *voiceDic;

@property (nonatomic, strong) UIAlertController *actionSheet;

-(void)sendRecording;
-(void)stopRecordingTimer;

-(UIImageView *)setImageView;
-(UIImageView *)setImageViewGroupTitle;

/**
 * This Function Set state of Load data
 */
-(void)loadData;
-(void)reloadAndScrollToSection:(long)sectionNumber;
-(void)scrollToBottom;

/**
 * This Function Set state of Unload data
 */
-(void)unloadData;

/**
 * This Function to pause the recording
 */
-(void)pauseRecording;
/**
 * This Function show alertRecording
 */
-(void)alertRecording;
/**
 * This Function show the keyboad
 */
//-(void)showKeyboard;
/**
 * Function call when app goes down
 */
-(void)pausePlayingAction;

-(void)stopAudioPlayback;

//Setting for footerView after the click on Micophone button of KeyboadView
- (IBAction)closeBannerView:(id)sender;

-(NSString*)getTextFieldValue;

-(void)removeTextFromTheTextField;

-(void)hideRecordingView;

-(void)setIsRecordingPause:(BOOL)value;

-(NSMutableDictionary*)getCurrentChatUserInfo;

-(void)imageTappedAtIndex:(NSIndexPath*)indexPath;

-(void) updateTableView;

-(BOOL)isIVUser:(NSNumber*)ivID;
@property (weak, nonatomic) IBOutlet UIView *channelsBannerView;
@property (weak, nonatomic) IBOutlet UIImageView *appStoreIcon;
@property (weak, nonatomic) IBOutlet UIView *bannerBackGroundView;
@property (weak, nonatomic) IBOutlet UILabel *bannerNoteLabel;

- (void)alignTextField:(NSUInteger)newLength;

- (void) resignTextResponder;
- (void) enableFirstResponder;
- (BOOL) isAudioRecording;

- (void)dismissActiveAlertController;

-(void)markReadMessagesFromThisList:(NSArray *)list;

-(NSDate*)getDateWithDayMonthYear:(NSDate *)inDate;
-(NSDate*)getDateFromMilliSeconds:(NSNumber*)dateInMilliSecs;
-(void)prepareDataSourceFromMessages:(NSArray*)list withInsertion:(BOOL)bInsertMsg MsgType:(DSMessageType)eMessageType;

-(void)tableContentInsets;

-(void)createAudioObj;
-(void)dismissAlertRecordView;

@end

@interface CustomView : UIView

@end
