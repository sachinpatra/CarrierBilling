//
//  ConversationTableCell.h
//  InstaVoice
//
//  Created by Vivek Mudgil on 15/01/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgMacro.h"
#import "Macro.h"
#import "ScreenUtility.h"
#import "ConversationApi.h"
#import "BaseConversationScreen.h"
#import "SharedMenuLabel.h"
#import "TableColumns.h"
#import "Common.h"

#define VOICE_VIEW_ID           122340
#define PLAY_BUTTON_ID          122341
#define DURATION_LABEL_ID       122342
#define TIME_LOCATION_LABEL_ID  122343
#define READ_RECIPT_VIEW_ID     122344
#define TEXT_VIEW_ID            122355
#define TICK_VIEW_ID            132

//APR 2017
#define LOCATION_LBL_TAG  0x601008
#define FROMTO_LBL_TAG    0x601009
//

#define TRANSPARENT_VIEW            100
#define STATUS_IMG                  101
#define MIN_WIDTH                   110
#define FONT_18_5                   18.5
#define INT_1                       1
#define INT_2                       2
#define INT_3                       3
#define INT_4                       4
#define INT_5                       5
#define SIZE_17_3                   17.3
#define SIZE_9_5                    9.5
#define SIZE_16_5                   16.5
#define ChatFont [UIFont fontWithName:HELVETICANEUE size:SIZE_17]
#define TimeStampFont [UIFont fontWithName:HELVETICANEUE size:SIZE_10]
#define DurationVoiceFont [UIFont fontWithName:HELVETICANEUE size:SIZE_13]

@protocol ConversationDelegate <NSObject>
-(void)deleteWithdrawn:(NSMutableDictionary*)dic withIndexPath:(NSIndexPath*)index;
-(void)showMore:(NSMutableDictionary *)dic withIndexPath:(NSIndexPath*)index;
//Jan 19, 2017 -(void)missedCallExpandedView:(int)tag;
-(void)missedCallExpandedViewAtIndex:(NSIndexPath*)indexPath;
//Bhaskar April 13th--> To Show Transcription text which is hiding behind keypad
//Bug ID --> 12526
-(void)transcriptionExpandedViewAtIndex:(NSIndexPath*)indexpath;
//Jan 19, 2017 -(void)audioButtonClickedAtIndex:(NSInteger)index;
-(void)audioButtonClickedAtIndex:(NSIndexPath*)indexPath;
-(void)imageTappedAtIndex:(NSIndexPath*)indexPath;
-(void)setCurrentTime:(double)time;
-(void)resignTextResponder;
-(BOOL)isAudioRecording;

-(void)transcriptionButtonTapped:(NSDictionary*)msgDic;

-(void)ratingButtonTappedAtIndex:(NSDictionary *)msgDic;

@end

@class BaseConversationScreen;
@interface ConversationTableCell : UITableViewCell <UITextViewDelegate>
{
#pragma mark All the Images variables
    NSMutableDictionary *msg_Dic;
    NSMutableArray *arrayDictionary;
    
    UIImage                 *fbIcon;                     //Facebook Like Icon for recording
    UIImage                 *vbIcon;                     //Vobolo Like Icon for recording
    UIImage                 *twitterIcon;                //Twitter Like Icon for recording
    UIImage                 *likedIcon;                  //Message Like Icon
    UIImage                 *transparentStrip;           //transparentstrip of recording
    
    UIImage                 *fbGreyIcon;                 //Facebook  Icon for Text Message
    UIImage                 *vbGreyIcon;                 //Vobolo  Icon for Text Message
    UIImage                 *twitterGreyIcon;            //Twitter  Icon for Text Message
    UIImage                 *fwdGreyIcon;                //Forword msg  Icon for Text Message
    UIImage                 *fwdWhiteIcon;               //Forword Icon for Voice msg
    UIImage                 *fwdWhiteMsgIcon;             //Forword Icon for Voice msg
    UIImage                 *instaGreyIcon;               //Forword msg  Icon for Text Message
}

@property (strong,nonatomic)BaseConversationScreen* baseConversationObj;
@property (nonatomic,weak) id<ConversationDelegate> delegate;
@property (nonatomic) NSDictionary* dic;
//Jan 19, 2017 @property (nonatomic) NSInteger cellIndex;
@property (nonatomic) NSIndexPath* cellIndex;

//Cell configuration method
-(void)configureCell;

//Factory Method
-(void)configureCellForConversationListArray:(NSMutableArray *)conversationList cellForRowAtIndexPath:(NSIndexPath *)indexPath idType:(id)conversationClass withAddingEmptyCell:(BOOL)addempty;

#pragma mark ShareMessage Action

- (NSMutableAttributedString *)getMemberNameGroupChat:(NSString *)timeLocationString dic:(NSMutableDictionary *)dic;
- (NSString*)getGroupMemberNameFromDic:(NSMutableDictionary*)dic;

-(void)updateVoiceView:(NSDictionary*)voiceDic;
-(void)setStatusIcon:(NSString *)status isAvs:(int)avsMsg readCount:(int)readCount  msgType:(NSString *)msgType;
-(void)swapPlayPause:(id)sender;
-(void)stopPlaying:(id)sender;

-(void) imageSetup;

@end
