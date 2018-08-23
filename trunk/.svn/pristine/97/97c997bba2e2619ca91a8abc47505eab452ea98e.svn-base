//
//  Conversation.h
//  InstaVoice
//
//  Created by Eninov on 13/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "BaseModel.h"
#import <CoreLocation/CoreLocation.h>
#import "OpusCoder.h"

#define MSG_COUNT  500
/*
#define ALL_MSG   0
#define SPECIFIC_USER_MSG 1
#define NOTES_MSG 2
#define VOBOLO_MSG 3
*/

typedef enum: NSInteger {
    MessageAll,
    MessageUser,
    MessageNotes,
    MessageVobolo,
} eMessage;

@class MessageTable;

@interface Conversation : BaseModel <CLLocationManagerDelegate>
{
    //NSMutableArray *_unsentMsgList; //This variable is used to hold Unsent Msgs.  -- remove it
    NSMutableArray *_currentChat; //This variable is used for Current Chat user's Msg List.
    NSMutableArray *_notesList; // This variable is used for logged in user's Notes List.
    NSMutableArray *_myVoboloList;//This variable is used for logged in User's Vobolo list.
    NSMutableDictionary *_currentChatUser; // This variable is used for get the current chat user info.
    NSMutableArray *_activeConversationList;// This variable is used for active conversation list for chat grid screen.
    NSMutableArray *_pendingMsgQueue; // This variable is used for Pending Msg list.
    NSMutableArray *_unreadMsgs; //
   
    int _sendCount;//This variable is used to retry send msg request.
    int _fetchMsgCount;//This variable is used to retry fetch Msg request.
    int _fetchCelebMsgCount;
    int _unreadMsgCountOfHiddenUsers;
    int _unreadMsgCountOfBlockedUsers;

    //BOOL _NOTIFY; // This variable is used to show the Notification Bar after fetch Msg.
    BOOL _pendingFetchMsgFlag; // This variable is used for fetch Pending Msg From Server.
    BOOL _pendingFetchCelebMsgFlag;
    
    MessageTable *_msgTableObj;
    NSMutableArray *_lastMsgStateList;
//    long deleteReqTime;// used for testing purpose
    
    //Location Work
    CLLocationManager       *_locationManager;           //Location Management Varible
    CLGeocoder              *_geocoder;                  //Provide the address string
    CLLocation              *_location;                  //Loction varible for get latitude,longitude
    NSString                *_locationName;              //String of address
    BOOL isPushNotification;
    NSMutableArray *_vsmsLimitList;
}

+(Conversation *)sharedConversationObj;
-(void)resetConversations;

-(NSMutableArray *)getMissedCallList:(BOOL)isNewList;
-(NSMutableArray *)getVoicemailList:(BOOL)isNewList;

-(NSMutableArray *)getActiveConversationList:(BOOL)isNewList;
-(long)getActiveConversationCount;

-(NSMutableDictionary*)getChatUserFrmActiveConvList:(NSString*)userID;

-(void)setCurrentChatUser:(NSMutableDictionary*)infoList;
-(NSMutableDictionary*)getCurrentChatUser;
-(void)clearCurrentChatUser;

-(NSMutableArray*)getCurrentChat;
-(NSMutableArray*)getMyNotes:(BOOL)fetchFromDB;
-(NSMutableArray*)getMyVoboloList:(BOOL)fetchFromDB;
-(NSMutableArray*)getVsmsLimitList;

-(long)getUnreadMsgCount;
-(NSArray*)getUnreadMessages;
-(long)getUnreadHiddenMsgCount;
-(long)getUnreadBlockedMsgCount;

-(NSMutableDictionary*)getLastMsgInfo:(NSString*)msgType;
-(void)setLastMsgInfo:(NSMutableDictionary*)dic;

-(void)updateMsgOnContactSync;

@end
