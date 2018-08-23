//
//  ChatGridViewController.h
//  InstaVoice
//
//  Created by adwivedi on 30/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
#import "PopoverView.h"
#import "IVDropDownView.h"
#import "FriendsScreen.h"
#import "ChatMobileNumberViewController.h"

#ifndef REACHME_APP
#import "CreateNewGroupViewController.h"
#endif

#import "Audio.h"
#import "ChatsCommon.h"


@interface ChatGridViewController : BaseUI<PopoverViewDelegate, ChatMobileNumberProtocol, AudioDelegate>
{
    NSMutableArray          *_currentFilteredList;   // Filter display type list based on search string
    NSMutableArray          *_displayTypeFilteredList; // Filter complete list based on current filter selection
    //NSMutableArray          *_savedCompleteList; // Complete list from Engine
    NSMutableArray          *_hiddenUserIDList; //
    //NSMutableArray          *_blockedUserIDList; //
    //NSMutableArray          *_missedCallList;
    //NSMutableArray          *_voicemailList;
    NSMutableDictionary*  _activeConversationDictionary;
    ChatType _displayUserType;
    
    BOOL isSearching;
    int  _currentTile; //0 based
    
    //NSInteger _newVoiceMails;
    //NSInteger _newMissedCalls;
    //NSInteger _newMessages;
    NSString* _searchString;
    NSTimer* drawStripTimer;
    long _buttonTag;
    NSInteger _indexForAudioPlayed;
    BOOL _needToUpdateTable;
    
    BOOL isWithDrawSentMissedCall;
    BOOL isDeleteMissedCall;
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
@property (nonatomic) Audio  *audioObj;
@property(nonatomic) NSMutableDictionary *voiceDic;

@property int setTab;

-(int)getChatType;
-(NSMutableArray*)filterChatGridWithElement:(NSMutableArray*)conversationList forDisplayType:(int)displayType;
-(void)buttonTappedRespond:(id)sender withUniqueIdentifier:(NSString*)uniqueIdentifier;
-(void)stopAudioPlayback;
-(void)clearSearch;
-(void)unBlockUserFromContactPage:(NSMutableDictionary*)userList;

@end

