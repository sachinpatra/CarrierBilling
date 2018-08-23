//
//  ChatsCommon.h
//  InstaVoice
//
//  Created by Pandian on 12/28/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#ifndef __ChatsCommon_h__
#define __ChatsCommon_h__

#import "BaseUI.h"
#import "ContactDetailData.h"

#ifndef REACHME_APP
    #define COMPOSE_BUTTON
#endif

#define SECTION_CHAT_TAG   0x678876
#define SECTION_OTHER_TAG  0x678875

typedef enum : NSInteger {
    ChatTypeCalls=0, //Missed calls, RingMC and ReachMe calls
    ChatTypeVoiceMail,
    ChatTypeAll,
    ChatTypeBlocked
} ChatType;

@interface ChatsCommon: NSObject
{
    NSMutableArray* _allMsgsList; //chats, calls, missed calls, voice mails
    NSMutableArray* _hiddenUserIDList;
    NSMutableArray* _blockedUserIDList;
    NSMutableArray* _missedCallList;
    NSMutableArray* _voicemailList;
    
    BaseUI* _delegate;
}

@property (strong) NSMutableArray* allMsgsList;
@property (strong) NSMutableArray* hiddenUserIDList;
@property (strong) NSMutableArray* blockedUserIDList;
@property (strong) NSMutableArray* missedCallList;
@property (strong) NSMutableArray* voicemailList;


+(ChatsCommon *)sharedChatsCommon;

-(void)setDelegate:(BaseUI*)delegate;
-(void)prepareHiddenUsers;
-(void)prepareBlockedUsers;
-(void)markReadMessagesFromThisList:(NSArray *)aList;

-(void)composeNewMessage;
//-(void)getVoicemailStatus:(BOOL*)vmStatus andVoipStatus:(BOOL*)voipStatus;
-(BOOL)redirectToVoicemailOrSettingsScreen;
-(NSString*)formatPhoneNumber:(NSString*)strNumber;

-(NSMutableArray*)filterChatsForDisplayType:(int)displayType;

-(NSMutableDictionary *)setUserInfoForConversation:(ContactDetailData *)detailData;
-(void)moveToGroupChatScreen:(ContactData*)data;

-(void)updateBadgeValues:(NSNumber*)objChatType;

-(void)clearData;

@end

#endif /* __ChatsCommon_h__ */
