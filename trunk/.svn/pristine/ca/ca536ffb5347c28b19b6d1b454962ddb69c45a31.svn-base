//
//  VoiceMailViewController.h
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 26/12/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
//#import "PopoverView.h"
//#import "IVDropDownView.h"
#import "FriendsScreen.h"
#import "ChatMobileNumberViewController.h"

#ifndef REACHME_APP
#import "CreateNewGroupViewController.h"
#endif

#import "Audio.h"
#import "ChatsCommon.h"

@interface VoiceMailViewController : BaseUI<ChatMobileNumberProtocol, AudioDelegate>
{
    NSMutableArray          *_currentFilteredList;   // Filter display type list based on search string
    NSMutableArray          *_displayTypeFilteredList; // Filter complete list based on current filter selection
    NSMutableArray          *_blockedUserIDList;
    NSMutableDictionary* _activeConversationDictionary;
    
    BOOL isSearching;
    int  _currentTile; //0 based
    NSString* _searchString;
    NSTimer* drawStripTimer;
    long _buttonTag;
    NSInteger _indexForAudioPlayed;
    BOOL _needToUpdateTable;
    
    BOOL isWithDrawSentVoiceMail;
    BOOL isDeleteVoiceMail;
    
    NSIndexPath *currentIndexPath;
    UIAlertView *_delAlertView;
    BOOL _isAlertShown;
    BOOL _isNumber;
    BOOL _showFromToNumber;
    
    ChatsCommon* cc;
}

@property (atomic) BOOL showFromToNumber;
@property (strong, nonatomic) UIView *sectionHeaderViewChats;
@property (strong, nonatomic) UIView *sectionHeaderViewOthers;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (nonatomic)  Audio  *audioObj;
@property(nonatomic) NSMutableDictionary *voiceDic;

@property int setTab;

-(int)getChatType;
-(NSMutableArray*)filterChatGridWithElement:(NSMutableArray*)conversationList forDisplayType:(int)displayType;
-(void)buttonTappedRespond:(id)sender withUniqueIdentifier:(NSString*)uniqueIdentifier;
-(void)stopAudioPlayback;
-(void)pausePlayingAction;
-(void)clearSearch;
-(void)dismissAlert;

@end
