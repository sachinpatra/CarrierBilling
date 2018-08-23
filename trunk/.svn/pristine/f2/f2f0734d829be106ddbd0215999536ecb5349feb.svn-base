//
//  Engine.h
//  InstaVoice
//
//  Created by Eninov on 10/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

// Event (NSDictionary Object) from UI and Network contains EVENT_MODE , EVENT_TYPE and EVENT_OBJECT which is further dictionary
// Event From Engine to Network contains EVENT_TYPE and REQUESTDIC  and From ENGINE To UI contains EVENT_TYPE , RESPONSE_CODE( and RESPONSE_DATA(response from network corresponding to event)
// RESPONSE_CODE will be success if server responds and we further need to check status in RESPONSE_DATA

#import <AddressBookUI/AddressBookUI.h>
#import "EventLoop.h"
#import "BaseModel.h"
#import "Conversation.h"

#ifdef REACHME_APP
#import "CallLog.h"
#define ratingAlertTag  0x783387
#endif

@class AppDelegate;
@class MQTTReceivedData;

@interface Engine : EventLoop
{
    AppDelegate *appDelegate;
    Conversation *conversationObj;
    NSInteger _eventQueueSize;
#ifdef REACHME_APP
    CallLogMgr* callLogMgr;
    NSDictionary* lastCallLog;
    NSMutableArray* _callCharges;
#endif
}

@property (atomic) NSInteger eventQueueSize;

/*
 * This function is to create Engine Object if already not craeted
 */
+(Engine *)sharedEngineObj;

/**
 * This function is to add events to Engine Thread either from Main thread or from Network Thread.
 * @paramevObj evObj contains eventType and dataDic
 * @return : SUCCESS, FAILURE OR PROGRESS.
 */
-(int)addEvent:(NSMutableDictionary *)evObj;

/**
 *This Function is to handle All Events from UI
 * @param eventType and dataDic corresponding to event
 * @return : SUCCESS or FAILURE
 */
-(int)handleUIEvent:(int)eventType dataObject:(NSMutableDictionary *)dataDic;

/**
 *This Function is to handle All Events from Network
 * @param eventType and dataDic corresponding to event
 * @return : SUCCESS or FAILURE
 */
-(int)handleNetEvent:(int)eventType dataObject:(NSMutableDictionary *)dataDic;

/**
 * This function is to get model object corresponding to event type
 * @return : modelObject corresponding to event
 */
-(BaseModel *)getModelObject:(int)eventType;


/**
 * This function notifies UI after getting completion of requested event from UI.
 * @param resultDic : NSMutableDictionary contains eventType and responseCodes.
 */
-(void)notifyUI:(NSMutableDictionary *)resultDic;

/**
 * This function clears previous login data if user is logged in by other id.
 */
-(int)resetLoginData:(BOOL)isMainThread;

-(void)resetDataForUploadContactAgain;
/**
 *This function sets the permission to access the addressbook contacts.
 */
 //-(void)setContactAccessPermission;

/**
 * This function is used to get the All messages from the Server.
 */
-(int)fetchMsgRequest:(NSDictionary *)dic;

-(int)fetchCelebrityMsgRequest:(NSDictionary *)dic;

/**
 * This function is used to delete the message Table row.
 */
-(int)deleteMsgTable;
/**
 * This function is used get the Conversation List.
 */
-(NSMutableArray *)getActiveConversationList:(BOOL)isNewList;

/**
 * This function set the current selected chat user info.
 */
-(void)setCurrentChatUser:(NSMutableDictionary*)infoList;

-(NSMutableDictionary*)getCurrentChatUser;

/**
 * This function return the Msg List of current selected chat user.
 */
-(NSMutableArray*)getCurrentChat;
/**
 * This function is used to send the message.
 */
-(int)sendMsg:(NSMutableDictionary*)message;

-(void)sendRingMissedCall:(NSMutableDictionary*)message;

//-(void)setNotificationDic:(NSDictionary*)notificationDic;

/**
 * This functipn is used to download the voice message.
 */
-(void)downloadVoiceMsg:(NSMutableDictionary*)msg;

/**
 * This function is used to stop sendding all message when n/w is off.
 */
-(void)stopSenddingAllMsg;

/**
 * This function is used to send all pendding message.
 */
-(void)sendAllPendingMsg;


/**
 * This function is used to Post the Msg on FB,TW,VB.
 */
-(void)postOnWall:(NSMutableDictionary*)msgDic;

/**
 * This function is used to delete the Message From Server.
 */
-(void)deleteMSG:(NSMutableDictionary*)msgDic;

-(void)withdrawMSG:(NSMutableDictionary*)msgDic;

/**
 * This function is used to forward a message to muliple contacts.
 */
-(void)forwardMessage:(NSMutableDictionary*)msgDic;

/**
 * This function is used to set flag as LIke or Unlike.
 */
-(void)msgActivity:(NSMutableDictionary *)msgDIc;

/**
 * This function is used to get Notes List.
 */
-(NSMutableArray*)getMyNotes:(BOOL)fetchFromDB;

/**
 * This function is used to clear the current chat user.
 */
-(void)clearCurrentChatUser;

/**
 * This function is used to set the Help contact as the current chat user
 * @return : resultDic;
 */
#ifdef REACHME_APP
-(void)setHelpAsCurrentChat;
#endif

/**
 * This function is used get the vobolo message List.
 */
-(NSMutableArray*)getMyVoboloList:(BOOL)fetchFromDB;

/**
 * This function is used to get the conversation count.
 */
-(long)getActiveConversationCount;

-(void)clearNetworkData;
-(void)resetListOnLogout;

/**
 * This function is used to get the unsent MSG Read Count;
 */
-(long)getUnreadMsgCount;

-(long)getUnreadHiddenMsgCount;

-(long)getUnreadBlockedMsgCount;

-(NSArray*)getUnreadMessages;


/**
 * This function is used to update Play Duration in Database.
 */
-(void)updatePlayDuration:(NSMutableDictionary*)dic;

/**
 * This function is used to get Last Message Info.
 */
-(NSMutableDictionary*)getLastMsgInfo:(NSString*)msgType;

/**
 * This function is used to save last msg Info.
 */
-(void)setLastMsgInfo:(NSMutableDictionary*)dic;

/**
 * This function is used to get VSMS LIMIT LIST
 */
-(NSMutableArray*)getVsmsLimitList;

-(NSMutableDictionary*)getChatUserFrmActiveConvList:(NSString*)userID;

-(void)updateMsgOnContactSync;

/**
 * This function is used to update userId when secondary number is changed to primary
 */
-(void)updateUserIdFrom:(NSString *)oldUserId toNew:(NSString *)newUserId;


-(void)getMissedCallInfo:(NSString*)nativeContactID;

-(int)fetchOlderMsgRequest:(NSDictionary *)dic;

//MQTT
-(void)addMQTTReceivedDataEvent:(MQTTReceivedData*)data;
-(void)purgeOldData;


-(NSMutableArray *)getMissedCallList:(BOOL)isNewList;
-(NSMutableArray *)getVoicemailList:(BOOL)isNewList;

-(void)notifyUIOfNetConnection:(BOOL)isInternetConnected;

-(void)addMessageHeaderIntoTable:(NSDictionary*)data;

-(void)sendAppStatus:(BOOL)isForeground;

-(void)deleteAllChats:(NSArray*)forTheContactList;

#ifdef REACHME_APP
-(void)displayUserRatingOptions:(NSDictionary*)message CallType:(NSString*)callType;
-(void)sendCallStatsLog;
-(void)sendLastCallLog;
-(void)updateMissedCallReason:(NSMutableDictionary*)dic;
-(void)sendVoipCallLog:(NSDictionary*)message withUserRating:(NSDictionary*)dicRating CallType:(NSString*)callType;
-(NSArray*)fetchObdDebitPolicy:(BOOL)forceFetch;
-(NSString*)getCallChargesForNumber:(NSString*)phoneNumber;
-(void)setCallChargeForNumber:(NSString*)phoneNumber WithCharge:(NSString*)charge;
-(void)resetCallCharges;
#endif


@end
