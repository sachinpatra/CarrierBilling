//
//  CallsViewController.h
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

@interface CallsViewController : BaseUI<ChatMobileNumberProtocol>
{
    NSMutableArray          *_currentFilteredList;   // Filter display type list based on search string
    NSMutableArray          *_displayTypeFilteredList; // Filter complete list based on current filter selection
    NSMutableDictionary*   _activeConversationDictionary;
    BOOL isSearching;
    int  _currentTile; //0 based
    NSString* _searchString;
    BOOL _needToUpdateTable;
    BOOL isDeleteMissedCall;
    
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
@property(nonatomic) NSMutableDictionary *voiceDic;


-(int)getChatType;
-(void)buttonTappedRespond:(id)sender withUniqueIdentifier:(NSString*)uniqueIdentifier;
-(void)clearSearch;
-(void)dismissAlert;

@end
