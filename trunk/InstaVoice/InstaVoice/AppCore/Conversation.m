//
//  Conversation.m
//  InstaVoice
//
//  Created by Eninov on 13/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.


#import "Conversation.h"
#import "EventType.h"
#import "Macro.h"
#import "ConversationApi.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif

#import "TableColumns.h"
#import "HttpConstant.h"
#import "ContactsApi.h"
#import "Common.h"
#import "NotificationIds.h"
#import "Logger.h"
#import "DBTables.h"
#import "Setting.h"

#import "ContactData.h"
#import "ContactDetailData.h"
#import "Contacts.h"
#import "IVFileLocator.h"
#import "ContactSyncUtility.h"
#import "ServerErrorMsg.h"
#import "ChatActivity.h"
#import "MQTTManager.h"
#import "MQTTReceivedData.h"
#import "NotificationBar.h"
#import "Conversations.h"
#import "UserProfileModel.h"
#import "Profile.h"

#ifndef REACHME_APP
#import "UpdateGroupAPI.h"
#endif


#define MAX_ROWS  1000
#define VSMS_LIMIT  50
#define MAX_RECORD_TO_KEEP 5000
#define DAYS_OLDER_FILE_TO_KEEP 60.0 //60 days
#define PURGE_CYCLE 15.0 //15 days

extern NSString* const kChatsUpdateEvent;

static Conversation *conversationObj = nil;
@interface Conversation()
@end

@implementation Conversation

-(id)init
{
    self = [super init];
    if(self)
    {
        _fetchMsgCount = 0;
        _fetchCelebMsgCount = 0;
        _sendCount = 0;
        _activeConversationList = nil;
        _unreadMsgs = nil;
        _currentChat = nil;
        _currentChatUser = nil;
        _pendingMsgQueue = nil;
        _notesList = nil;
        _myVoboloList = nil;
        _pendingFetchMsgFlag = FALSE;
        _pendingFetchCelebMsgFlag = FALSE;
        _msgTableObj = (MessageTable*)[[DBTables sharedDBTables] getTableObj:MESSAGE_TABLE_TYPE];
    }
    return self;
}


+(Conversation *)sharedConversationObj
{
    if(conversationObj == nil)
    {
        conversationObj = [[Conversation alloc] init];
    }
    return conversationObj;
}

-(void)resetConversations
{
    [self lockAndResetConversationList];
    [appDelegate.confgReader setAfterMsgId:0];
    [appDelegate.confgReader setLastBlogId:0];//MAR 3, 2017
    [appDelegate.confgReader setAfterMsgActivityId:0];
    
    if(_lastMsgStateList != nil)
    {
        [_lastMsgStateList removeAllObjects];
        _lastMsgStateList = nil;
    }
    
    _pendingFetchMsgFlag = FALSE;
    [self deleteVsmsLimitTableData];
    [self deleteMsgTableData];
}

-(void)lockAndResetConversationList
{
    [lockObj lock];
    if(_currentChat != nil)
    {
        [_currentChat removeAllObjects];
        _currentChat = nil;
    }
    if(_activeConversationList != nil)
    {
        [_activeConversationList removeAllObjects];
        _activeConversationList = nil;
    }
    if(_notesList != nil)
    {
        [_notesList removeAllObjects];
        _notesList = nil;
    }
    if(_myVoboloList != nil)
    {
        [_myVoboloList removeAllObjects];
        _myVoboloList = nil;
    }
    if(_vsmsLimitList != nil)
    {
        [_vsmsLimitList removeAllObjects];
        _vsmsLimitList = nil;
    }
    [lockObj unlock];
}

-(void)deleteVsmsLimitTableData
{
    VsmsLimitTable *vsmsTable = (VsmsLimitTable*)[[DBTables sharedDBTables] getTableObj:VSMS_LIMIT_TABLE_TYPE];
    if(![vsmsTable deleteFromTable:nil tableType:VSMS_LIMIT_TABLE_TYPE])
    {
        EnLoge(@"Error in Deletion of VSMS Table");
    }
}

//This function delete the message Table Data.
-(void)deleteMsgTableData
{
    if(![_msgTableObj deleteFromTable:nil tableType:MESSAGE_TABLE_TYPE])
    {
        EnLoge(@"Error in Message deletion");
    }
}

-(NSMutableDictionary*)getLastMsgInfo:(NSString*)msgType
{
    NSMutableDictionary *lastDic = nil;
    
    if(_lastMsgStateList != nil && [_lastMsgStateList count]>0)
    {
        if(([msgType isEqualToString:VB_TYPE]) || ([msgType isEqualToString:NOTES_TYPE]))
        {
            long count = [_lastMsgStateList count];
            for (long i=0; i<count; i++)
            {
                lastDic = [_lastMsgStateList objectAtIndex:i];
                if([msgType isEqualToString:[lastDic valueForKey:MSG_TYPE]])
                {
                    [_lastMsgStateList removeObjectAtIndex:i];
                    break;
                }
                else
                {
                    lastDic = nil;
                }
            }
        }
        else
        {
            [lockObj lock];
            NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:_currentChatUser];
            [lockObj unlock];
            long count = [_lastMsgStateList count];
            NSString *userID = [newDic valueForKey:FROM_USER_ID];
            if(userID ==  nil || [userID length] == 0)
            {
                userID = [newDic valueForKey:REMOTE_USER_IV_ID];
            }
            for (int i =0; i<count; i++)
            {
                lastDic = [_lastMsgStateList objectAtIndex:i];
                NSMutableDictionary *userDic = [lastDic valueForKey:CURRENT_CHAT_USER];
                NSString *remoteUserID = [userDic valueForKey:FROM_USER_ID];
                if(remoteUserID == nil || [remoteUserID length] == 0)
                {
                    remoteUserID = [userDic valueForKey:REMOTE_USER_IV_ID];
                }
                if([userID isEqualToString:remoteUserID])
                {
                    [_lastMsgStateList removeObjectAtIndex:i];//CMP FIXED the big: 5345 client is sending the same audio...
                    break;
                }
                else
                {
                    lastDic = nil;
                }
            }
        }
    }
    return lastDic;
}

-(void)setLastMsgInfo:(NSMutableDictionary*)dic
{
    
    NSString *msgType = [dic valueForKey:MSG_TYPE];
    if(([msgType isEqualToString:VB_TYPE]) || ([msgType isEqualToString:NOTES_TYPE]))
    {
        if(_lastMsgStateList == nil)
        {
            _lastMsgStateList = [[NSMutableArray alloc] init];
            [_lastMsgStateList addObject:dic];
            return;
        }
        long count = [_lastMsgStateList count];
        NSMutableDictionary *existDic = nil;
        for (long i=0; i<count; i++)
        {
            existDic = [_lastMsgStateList objectAtIndex:i];
            
            if([msgType isEqualToString:[existDic valueForKey:MSG_TYPE]])
            {
                break;
            }
            else
            {
                existDic = nil;
            }
        }
        
        if(existDic != nil)
        {
            [_lastMsgStateList removeObject:existDic];
        }
        if([dic valueForKey:MSG_CONTENT] != nil)
        {
            [_lastMsgStateList addObject:dic];
        }
    }
    else if(_currentChatUser != nil)
    {
        [lockObj lock];
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:_currentChatUser];
        [lockObj unlock];
        if(_lastMsgStateList == nil)
        {
            _lastMsgStateList = [[NSMutableArray alloc] init];
            [dic setValue:newDic forKey:CURRENT_CHAT_USER];
            [_lastMsgStateList addObject:dic];
            return;
        }
        long count = [_lastMsgStateList count];
        NSString *userID = [newDic valueForKey:FROM_USER_ID];
        if(userID ==  nil || [userID length] == 0)
        {
            userID = [newDic valueForKey:REMOTE_USER_IV_ID];
        }
        NSMutableDictionary *existDic = nil;
        for (int i =0; i<count; i++)
        {
            existDic = [_lastMsgStateList objectAtIndex:i];
            NSMutableDictionary *userDic = [existDic valueForKey:CURRENT_CHAT_USER];
            NSString *remoteUserID = [userDic valueForKey:FROM_USER_ID];
            if(remoteUserID == nil || [remoteUserID length] == 0)
            {
                remoteUserID = [userDic valueForKey:REMOTE_USER_IV_ID];
            }
            if([userID isEqualToString:remoteUserID])
            {
                break;
            }
            else
            {
                existDic = nil;
            }
        }
        
        if(existDic != nil)
        {
            [_lastMsgStateList removeObject:existDic];
        }
        if([dic valueForKey:MSG_CONTENT] != nil)
        {
            [dic setValue:newDic forKey:CURRENT_CHAT_USER];
            [_lastMsgStateList addObject:dic];
        }
    }
    
}

-(NSMutableDictionary*)getChatUserFrmActiveConvList:(NSString*)userID
{
    NSMutableDictionary *newDic =  nil;
    [lockObj lock];
    if(_activeConversationList != nil && [_activeConversationList count] >0)
    {
        long count = [_activeConversationList count];
        for (long i = 0; i<count; i++)
        {
            NSMutableDictionary *dic = [_activeConversationList objectAtIndex:i];
            NSString *ivID = [dic valueForKey:REMOTE_USER_IV_ID];
            NSString *frmUserID = [dic valueForKey:FROM_USER_ID];
            if(ivID != nil)
            {
                if([ivID isEqualToString:userID])
                {
                    NSMutableDictionary *changeDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
                    newDic = changeDic;
                    break;
                }
            }
            if(frmUserID != nil)
            {
                if([frmUserID isEqualToString:userID])
                {
                    NSMutableDictionary *changeDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
                    newDic = changeDic;
                    break;
                }
            }
        }
    }
    [lockObj unlock];
    return newDic;
}

-(void) getLocationPermission
{
    KLog(@"getLocationPermission -- START");
    if([Setting sharedSetting].data.displayLocation)
    {
        if(_locationManager == nil && _geocoder == nil)
        {
            _locationManager = [[CLLocationManager alloc] init];
            _geocoder = [[CLGeocoder alloc] init];
            _locationManager.delegate = self;
            // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_locationManager requestWhenInUseAuthorization];
            }
            [self getCurrentLocation];
        }
    }
    KLog(@"getLocationPermission -- END");
}


#pragma mark Get The Current Loction & Address

-(void)getCurrentLocation
{
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _location = [locations lastObject];
    [_locationManager stopUpdatingLocation];
    [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            EnLoge(@"%@", error.debugDescription);
            return;
        }
        _locationName = [Common getLocationName:placemarks];
        KLog(@"LS: _locationName = %@",_locationName);
    } ];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

#pragma mark Change User ID
-(void) changeUserID:(NSMutableDictionary*)dicUserIDs
{
    KLog(@"User IDs = %@",dicUserIDs);
    EnLogd(@"User IDs = %@",dicUserIDs);
    
    NSString* oldID = [dicUserIDs valueForKey:OLD_USER_ID];
    NSString* newID = [dicUserIDs valueForKey:NEW_USER_ID];
    
    NSString *oldUserID = [oldID stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *newUserID = [newID stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    if(!newUserID || [newUserID length] <= 0) {
        return;
    }
    
    NSMutableDictionary* dicLoggedInID = [[NSMutableDictionary alloc]init];
    [dicLoggedInID setValue:newUserID forKey:LOGGEDIN_USER_ID];
    
    NSString *updateClause = [[NSString alloc] initWithFormat:@"WHERE %@ = %@ ",LOGGEDIN_USER_ID,oldUserID];
    if(![_msgTableObj updateTable:dicLoggedInID whereClause:updateClause tableType:MESSAGE_TABLE_TYPE])
    {
        //TODO: we need to set the older primary number in AccountSettings page.
        EnLoge(@"***Error updating LOGGEDIN_USER_ID");
        KLog(@"***ERROR: Error updating LOGGEDIN_USER_ID");
    } else {
        EnLogd(@"Primary no. Changed from %@ to %@.",oldUserID,newUserID);
    }
    
    KLog(@"column = %@",dicLoggedInID);
    KLog(@"updateClause = %@",updateClause);
}

-(void)updateMissedCallInfo:(NSString*)nativeContactID
{
    NSMutableArray* columnsDetail = [[NSMutableArray alloc]initWithObjects:@"msg_date", nil];
    
    NSString *whereClause = [[NSString alloc] initWithFormat:@"WHERE NATIVE_CONTACT_ID = %@ and msg_flow = 'r' and (msg_type = 'mc' or msg_type = 'vsms')",nativeContactID];
    
    NSString *orderby = @"ORDER BY msg_date DESC";
    
    NSMutableArray *msgs = [_msgTableObj queryTable:columnsDetail whereClause:whereClause groupBy:nil having:nil orderBy:orderby tableType:MESSAGE_TABLE_TYPE];
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    
    if(msgs != nil && [msgs count]>0)
    {
        [resultDic setValue:msgs forKey:RESPONSE_DATA];
    }
    [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
    [resultDic setValue:[NSNumber numberWithInt:MISS_CALL_GET_INFO] forKey:EVENT_TYPE];
    [self notifyUI:resultDic];
}

-(void)updatePlayDuration:(NSMutableDictionary*)dic
{
    if(dic != nil)
    {
        NSString *guid = [dic valueForKey:MSG_GUID];
        if(guid != nil && [guid length]>0)
        {
            NSString *whereClause = [NSString stringWithFormat:@"WHERE %@ = \"%@\"",MSG_GUID,guid];
            if(![_msgTableObj updateTable:dic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE])
            {
                EnLogd(@"Download Count Updation Error");
            }
        }
    }
}

#pragma mark -- Notes
-(NSMutableArray*)getMyNotes:(BOOL)fetchFromDB
{
    [lockObj lock];
    if(fetchFromDB)
        _notesList = nil;
    
    NSMutableArray *notes = [[NSMutableArray alloc]init];
    if(_notesList != nil && [_notesList count]>0)
    {
        notes = [[NSMutableArray alloc] initWithArray:_notesList];
    }
    else
    {
        EnLogd(@"Notes List is null");
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:UI_EVENT forKey:EVENT_MODE];
        [dic setValue:[NSNumber numberWithInt:GET_NOTES] forKey:EVENT_TYPE];
        [dic setValue:nil forKey:EVENT_OBJECT];
        [appDelegate.engObj addEvent:dic];
    }
    [lockObj unlock];
    
    return notes;
}

//MAY 2017
-(NSMutableArray*)getOlderNotesBeforeMessageId:(long)msgId withLimit:(NSInteger)limit
{
    NSString *whereClause = nil;
    
    if(0==msgId) {
        whereClause = [[NSMutableString alloc] initWithFormat:@"WHERE %@ = \"%@\" ",MSG_TYPE,NOTES_TYPE];
    }
    else {
        whereClause = [[NSMutableString alloc] initWithFormat:@"WHERE (%@ = \"%@\") AND (%@ < %ld and %@ > 0)",MSG_TYPE,NOTES_TYPE,MSG_ID,msgId,MSG_ID];
    }
    NSInteger maxLimit = limit;
    if(limit<=0)
        maxLimit = 25;
    
    NSString *orderby = [[NSString alloc] initWithFormat:@"ORDER BY %@ DESC,%@ DESC LIMIT %ld",MSG_DATE,MSG_ID,maxLimit];
    NSMutableArray* msges = [_msgTableObj queryTable:nil whereClause:whereClause
                                             groupBy:nil having:nil orderBy:orderby tableType:MESSAGE_TABLE_TYPE];
    
   /*
    NSMutableArray* reverseOldMsgList = [[NSMutableArray alloc]init];
    if(msges.count)
        reverseOldMsgList = [NSMutableArray arrayWithArray:[[msges reverseObjectEnumerator]allObjects]];
    return reverseOldMsgList;
    */
    
    NSMutableArray* oldMsgList = [[NSMutableArray alloc]init];
    if(msges.count)
        oldMsgList = [NSMutableArray arrayWithArray:msges];
    return oldMsgList;
}
//

//This function is used to get Notes list from DB.
-(NSMutableArray*)populateNotesListFromDB
{
    NSMutableArray *msges = [self getOlderNotesBeforeMessageId:0 withLimit:0];
    
    /* MAY 2017
    NSString *whereClause = [[NSMutableString alloc] initWithFormat:@"WHERE %@ = \"%@\" ",MSG_TYPE,NOTES_TYPE];
    NSString *orderby = [[NSString alloc] initWithFormat:@"ORDER BY %@ DESC,%@ DESC LIMIT %d",MSG_DATE,MSG_ID,MSG_COUNT];
    msges = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:orderby tableType:MESSAGE_TABLE_TYPE];
    */
    
    [lockObj lock];
    if(_notesList != nil && [_notesList count]>0)
    {
        [_notesList removeAllObjects];
        _notesList = nil;
    }
    if(msges != nil && [msges count]>0)
    {
        NSArray *list = [[msges reverseObjectEnumerator] allObjects];
        
        _notesList = [[NSMutableArray alloc] initWithArray:list];
        NSMutableArray *unsntMsgList = [[NSMutableArray alloc] init];
        long chatCount = [_notesList count];
        for (long i =0; i<chatCount; i++)
        {
            NSMutableDictionary *msgDic = [_notesList objectAtIndex:i];
            NSString *msgState = [msgDic valueForKey:MSG_STATE];
            if([msgState isEqualToString:API_UNSENT] || [msgState isEqualToString:API_INPROGRESS]|| [msgState isEqualToString:API_NETUNAVAILABLE])
            {
                if([msgState isEqualToString:API_NETUNAVAILABLE] || [msgState isEqualToString:API_UNSENT]) {
                    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
                        [msgDic setValue:API_INPROGRESS forKey:MSG_STATE];
                    }
                }
                [unsntMsgList addObject:msgDic];
            }
        }
        
        if([unsntMsgList count]>0)
        {
            [_notesList removeObjectsInArray:unsntMsgList];
            [_notesList addObjectsFromArray:unsntMsgList];
        }
    }
    [lockObj unlock];
    
    return msges;
}

#pragma mark -- Vobolo
-(NSMutableArray*)getMyVoboloList:(BOOL)fetchFromDB
{
    if(fetchFromDB)
        _myVoboloList = nil;
    
    NSMutableArray *list = nil;
    if(_myVoboloList != nil && [_myVoboloList count]>0)
    {
        [lockObj lock];
        list = [[NSMutableArray alloc] initWithArray:_myVoboloList];
        [lockObj unlock];
    }
    else
    {
        NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
        [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
        [eventObj setValue:[NSNumber numberWithInt:GET_MYVOBOLO_MSG] forKey:EVENT_TYPE];
        [eventObj setValue:nil forKey:EVENT_OBJECT];
        [appDelegate.engObj addEvent:eventObj];
    }
    
    return list;
}

//This function is used to Get the Vobolo Msg From DB
-(NSMutableArray*)populateMyVoboloListFromDB
{
    NSMutableArray *msges = nil;
    NSString *whereClause = nil;
    
    NSString *orderby = [[NSString alloc] initWithFormat:@"ORDER BY %@ DESC,%@ DESC LIMIT %d",MSG_DATE,MSG_ID,MSG_COUNT];
    whereClause = [[NSMutableString alloc] initWithFormat:@"WHERE %@ = \"%@\"",MSG_TYPE,VB_TYPE];
    msges = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:orderby tableType:MESSAGE_TABLE_TYPE];
    
    [lockObj lock];//lock
    if(_myVoboloList != nil && [_myVoboloList count]>0)
    {
        [_myVoboloList removeAllObjects];
        _myVoboloList = nil;
    }
    
    if(msges != nil)
    {
        NSArray *list = [[msges reverseObjectEnumerator] allObjects];
        _myVoboloList = [[NSMutableArray alloc] initWithArray:list];
        NSMutableArray *unsntMsgList = [[NSMutableArray alloc] init];
        long chatCount = [_myVoboloList count];
        for (long i =0; i<chatCount; i++)
        {
            NSMutableDictionary *msgDic = [_myVoboloList objectAtIndex:i];
            NSString *msgState = [msgDic valueForKey:MSG_STATE];
            if([msgState isEqualToString:API_UNSENT] || [msgState isEqualToString:API_INPROGRESS]|| [msgState isEqualToString:API_NETUNAVAILABLE])
            {
                if([msgState isEqualToString:API_NETUNAVAILABLE] || [msgState isEqualToString:API_UNSENT]) {
                    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
                        [msgDic setValue:API_INPROGRESS forKey:MSG_STATE];
                    }
                }
                [unsntMsgList addObject:msgDic];
            }
        }
        
        if([unsntMsgList count]>0)
        {
            [_myVoboloList removeObjectsInArray:unsntMsgList];
            [_myVoboloList addObjectsFromArray:unsntMsgList];
        }
    }
    [lockObj unlock];
    return msges;
}

#pragma mark -- Current Chat
-(NSMutableArray*)getCurrentChat
{
    NSMutableArray *currentMsgList = nil;
    [lockObj lock];
    if(_currentChat != nil && [_currentChat count] >0)
    {
        currentMsgList = [[NSMutableArray alloc] initWithArray:_currentChat];
    }
    else
    {
        EnLogd(@"Current Chat List is NULL");
        NSMutableDictionary *evntDic = [[NSMutableDictionary alloc] init];
        [evntDic setValue:UI_EVENT forKey:EVENT_MODE];
        [evntDic setValue:[NSNumber numberWithInt:GET_CURRENT_CHAT] forKey:EVENT_TYPE];
        [appDelegate.engObj addEvent:evntDic];
    }
    [lockObj unlock];
    
    return currentMsgList;
}

/**
 * This function is used to Create the current Chat List Based on Current User.
 */
-(void)populateCurrentChat
{
    NSMutableArray *list = [self getOlderChatBeforeMessageId:0 withLimit:0];
    
    [lockObj lock];//lock
    if(_currentChat != nil && [_currentChat count]>0)
    {
        [_currentChat removeAllObjects];
        _currentChat = nil;
    }
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if(list.count)
    {
        _currentChat = [[NSMutableArray alloc] initWithArray:list];
        long count = [_currentChat count];
        
        //TODO Miss call combine
        for(int i =0; i <count; i++)
        {
            NSMutableArray *tempArry = [[NSMutableArray alloc] init];
            for(int j =i;j<count;j++)
            {
                NSMutableDictionary *dic = [_currentChat objectAtIndex:j];
                NSMutableDictionary* prevDic = nil;
                NSString* msgFlow = nil;
                NSString* nativeContactID = nil;
                NSString* msgType = nil;
                NSString* msgSubType = nil;
                if(j>0) {
                    prevDic = [_currentChat objectAtIndex:j-1];
                    msgFlow = [prevDic valueForKey:MSG_FLOW];
                    msgType = [prevDic valueForKey:MSG_TYPE];
                    msgSubType = [prevDic valueForKey:MSG_SUB_TYPE];
                    nativeContactID = [prevDic valueForKey:NATIVE_CONTACT_ID];
                }
                
                if(([[dic valueForKey:MSG_TYPE] isEqualToString:MISSCALL]) &&
                   ([msgType isEqualToString:MISSCALL] && ![msgSubType isEqualToString:RING_MC]) &&
                   ([[dic valueForKey:MSG_FLOW] isEqualToString:msgFlow]) &&
                   ![[dic valueForKey:MSG_SUB_TYPE] isEqualToString:RING_MC] &&
                   ([[dic valueForKey:NATIVE_CONTACT_ID] isEqualToString:nativeContactID]))
                {
                    if(!tempArry.count)
                       [tempArry addObject:prevDic];
                    
                    [tempArry addObject:dic];
                    i = j;
                }
                else
                {
                    break;
                }
            }
            
            if([tempArry count] > 0)
            {
                long cnt = [tempArry count];
                NSMutableDictionary *tempDic = [tempArry objectAtIndex:cnt-1];
                [tempDic setValue:[NSNumber numberWithLong:cnt] forKey:MISSED_CALL_COUNT];
                [tempArry removeObject:tempDic];
                [tempDic setValue:tempArry forKey:MSG_LIST];
                [arr addObjectsFromArray:tempArry];
            }
        }
        if([arr count] >0)
        {
            [_currentChat removeObjectsInArray:arr];
        }
        NSMutableArray *unsntMsgList = [[NSMutableArray alloc] init];
        long chatCount = [_currentChat count];
        for (long i =0; i<chatCount; i++)
        {
            NSMutableDictionary *msgDic = [_currentChat objectAtIndex:i];
            NSString *msgState = [msgDic valueForKey:MSG_STATE];
            if([msgState isEqualToString:API_UNSENT] || [msgState isEqualToString:API_INPROGRESS] || [msgState isEqualToString:API_NETUNAVAILABLE])
            {
                if([msgState isEqualToString:API_NETUNAVAILABLE] || [msgState isEqualToString:API_UNSENT]) {
                    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
                        //[msgDic setValue:API_INPROGRESS forKey:MSG_STATE];
                    }
                }
                [unsntMsgList addObject:msgDic];
            }
        }
        
        if([unsntMsgList count]>0)
        {
            [_currentChat removeObjectsInArray:unsntMsgList];
            [_currentChat addObjectsFromArray:unsntMsgList];
        }
    }
    
    [lockObj unlock];
}

-(NSMutableArray*)getOlderChatBeforeMessageId:(long)msgId withLimit:(NSInteger)limit
{
    //msgId = 0  means fetch latest 50 messages
    NSMutableArray *msges = nil;
    if(_currentChatUser != nil && [_currentChatUser count] > 0)
    {
        NSString *fromUserID = [_currentChatUser valueForKey:FROM_USER_ID];
        NSString *remoteIVID = [_currentChatUser valueForKey:REMOTE_USER_IV_ID];
        if(remoteIVID != nil && ([remoteIVID integerValue] == 0))
        {
            remoteIVID = fromUserID;
        }
        
        NSString *whereClause = Nil;
        
        if(msgId == 0)
        {
            whereClause = [[NSString alloc] initWithFormat:@"WHERE (%@ = \"%@\" OR %@ = \"%@\") AND (%@ != \"%@\" AND %@ != \"%@\") AND (%@ is NULL OR %@ != \"%@\" AND %@ != \"%@\" AND %@ != \"%@\" AND %@ != \"%@\")",REMOTE_USER_IV_ID,remoteIVID,FROM_USER_ID,fromUserID,MSG_TYPE,NOTES_TYPE,MSG_TYPE,VB_TYPE,MSG_SUB_TYPE,MSG_SUB_TYPE,VOIP_CALL_REJECTED,MSG_SUB_TYPE,VOIP_CALL_MISSED, MSG_SUB_TYPE, @"abort", MSG_SUB_TYPE, @"sip_error"];
        }
        else
        {
            whereClause = [[NSString alloc] initWithFormat:@"WHERE (%@ = \"%@\" OR %@ = \"%@\")\
                           AND (%@ < %ld and %@ > 0) AND (%@ != \"%@\" AND %@ != \"%@\") AND\
                           (%@ is NULL OR %@ != \"%@\" AND %@ != \"%@\" AND %@ != \"%@\" AND %@ != \"%@\")",
                           REMOTE_USER_IV_ID,remoteIVID,FROM_USER_ID,fromUserID,MSG_ID,msgId,MSG_ID,MSG_TYPE,NOTES_TYPE,MSG_TYPE,VB_TYPE,MSG_SUB_TYPE,MSG_SUB_TYPE,VOIP_CALL_MISSED,MSG_SUB_TYPE,VOIP_CALL_REJECTED,MSG_SUB_TYPE,@"abort",MSG_SUB_TYPE,@"sip_error"];
        }
        //MAR 24, 2017
        NSInteger maxLimit = limit;
        if(limit<=0)
            maxLimit = 25;
        //
        
        NSString *orderby = [[NSString alloc] initWithFormat:@"ORDER BY %@ DESC,%@ DESC LIMIT %ld",MSG_DATE,MSG_ID,maxLimit];
        //MAR 24, 2017 NSString *orderby = [[NSString alloc] initWithFormat:@"ORDER BY %@ DESC,%@ DESC",MSG_DATE,MSG_ID];
        
        msges = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:orderby tableType:MESSAGE_TABLE_TYPE];
    }
    
    NSMutableArray* reverseOldMsgList = [[NSMutableArray alloc]init];
    if(msges.count)
        reverseOldMsgList = [NSMutableArray arrayWithArray:[[msges reverseObjectEnumerator]allObjects]];
    return reverseOldMsgList;
}

#pragma mark -- Current Chat User

-(void)setCurrentChatUser:(NSMutableDictionary*)infoList
{
    if(infoList != nil && [infoList count] > 0)
    {
        [lockObj lock];
        if(_currentChatUser != nil)
        {
            [_currentChatUser removeAllObjects];
            _currentChatUser = nil;
            
        }
        if(_currentChat != nil)
        {
            [_currentChat removeAllObjects];
            _currentChat = nil;
        }
        
        _currentChatUser = infoList;
        [lockObj unlock];
        
    }
}

-(NSMutableDictionary*)getCurrentChatUser
{
    NSMutableDictionary *dic = nil;
    if(_currentChatUser != nil && [_currentChatUser count]>0)
    {
        [lockObj lock];
        dic = [[NSMutableDictionary alloc] initWithDictionary:_currentChatUser];
        [lockObj unlock];
    }
    return dic;
}

-(void)clearCurrentChatUser
{
    if(_currentChatUser != nil)
    {
        [lockObj lock];
        [_currentChatUser removeAllObjects];
        _currentChatUser = nil;
        [lockObj unlock];
    }
}

#pragma mark Voicemail List
-(NSMutableArray *)getVoicemailList:(BOOL)isNewList
{
    NSMutableArray *resultList = nil;
    /*
     if(_activeConversationList.count)
     {
     [lockObj lock];
     resultList = [[NSMutableArray alloc] initWithArray:_activeConversationList];
     [lockObj unlock];
     }
     
     if(isNewList || (_activeConversationList.count == 0))
     */
    {
        NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
        [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
        [eventObj setValue:[NSNumber numberWithInt:GET_VOICEMAIL_LIST] forKey:EVENT_TYPE];
        [eventObj setValue:nil forKey:EVENT_OBJECT];
        [appDelegate.engObj addEvent:eventObj];
    }
    
    return resultList;
}

#pragma mark MissedCall List
-(NSMutableArray *)getMissedCallList:(BOOL)isNewList
{
    NSMutableArray *resultList = nil;
    /*
    if(_activeConversationList.count)
    {
        [lockObj lock];
        resultList = [[NSMutableArray alloc] initWithArray:_activeConversationList];
        [lockObj unlock];
    }
    
    if(isNewList || (_activeConversationList.count == 0))
     */
    {
        NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
        [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
        [eventObj setValue:[NSNumber numberWithInt:GET_MISSEDCALL_LIST] forKey:EVENT_TYPE];
        [eventObj setValue:nil forKey:EVENT_OBJECT];
        [appDelegate.engObj addEvent:eventObj];
    }
    
    return resultList;
}


#pragma mark - Active Conversation List
-(NSMutableArray *)getActiveConversationList:(BOOL)isNewList
{
    NSMutableArray *resultList = nil;
    
    [lockObj lock];
    NSInteger convCount = _activeConversationList.count;
    if(convCount) {
        resultList = [[NSMutableArray alloc] initWithArray:_activeConversationList];
    }
    [lockObj unlock];
    
    if(isNewList /*NOV 2017 || convCount*/)
    {
        NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
        [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
        [eventObj setValue:[NSNumber numberWithInt:GET_ACTIVE_CONVERSATION_LIST] forKey:EVENT_TYPE];
        [eventObj setValue:nil forKey:EVENT_OBJECT];
        [appDelegate.engObj addEvent:eventObj];
    }
    
    return resultList;
}

-(long)getActiveConversationCount
{
    long count = 0;
    [lockObj lock];
    if(_activeConversationList != nil && [_activeConversationList count]>0)
    {
        count = [_activeConversationList count];
    }
    [lockObj unlock];
    
    [self updateBlockedUsers:_activeConversationList];
    
    return count;
}

-(void)createMissedCallList
{
    NSMutableArray *msgs=nil;
    msgs = [self getMissedCallConversation];
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
    [resultDic setValue:msgs forKey:RESPONSE_DATA];
    [resultDic setValue:[NSNumber numberWithInt:GET_MISSEDCALL_LIST] forKey:EVENT_TYPE];
    [self notifyUI:resultDic];
    
    // Post event
    [NSNotificationCenter.defaultCenter postNotificationName:kChatsUpdateEvent object:self userInfo:resultDic];
}

-(void)createVoicemailList
{
    NSMutableArray *msgs=nil;
    msgs = [self getVoicemailConversation];
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
    [resultDic setValue:msgs forKey:RESPONSE_DATA];
    [resultDic setValue:[NSNumber numberWithInt:GET_VOICEMAIL_LIST] forKey:EVENT_TYPE];
    [self notifyUI:resultDic];
    
    [NSNotificationCenter.defaultCenter postNotificationName:kChatsUpdateEvent object:self userInfo:resultDic];
}


//TODO: CMP -- refactor
-(void)createActiveConversation:(NSMutableArray*)uniqueChats
{
    NSMutableArray *msgs=nil;
    
    if(!uniqueChats || ![uniqueChats count]) {
        msgs = [self getUniqueConversation];
    }
    else {
        msgs = uniqueChats;
    }
    
    NSMutableArray *tempConversationList = nil;
    if(msgs != nil && [msgs count] >0)
    {
        tempConversationList = [[NSMutableArray alloc] init];
        long msgCount = [msgs count];
        for (long i=0; i< msgCount; i++)
        {
            NSMutableDictionary *dic = [msgs objectAtIndex:i];
            
            NSString *contactId = [dic valueForKey:FROM_USER_ID];
            //SEP 28, 2016
            NSString *nativeContactId = [dic valueForKey:NATIVE_CONTACT_ID];
            if( [contactId length] && [nativeContactId length] && [contactId isEqualToString:nativeContactId]) {
                KLog(@"*** Exclude self Vm & MC");
                continue;
            }
            //
            if(contactId != nil && [contactId length] >0)
            {
                NSString* sRemUserIvId = @"0";
                
                if([dic valueForKey:REMOTE_USER_IV_ID]) {
                    sRemUserIvId = [dic valueForKey:REMOTE_USER_IV_ID];
                }
                
                NSString *userID = [dic valueForKey:FROM_USER_ID];
                if(userID != nil && [userID length]>0)
                {
                    //NOV 17 [resultDic setValue:userID forKey:REMOTE_USER_NAME];
                }
                else
                {
                    //NOV 17 [resultDic setValue:userIVID forKey:REMOTE_USER_NAME];
                }
                NSString *userName = [dic valueForKey:REMOTE_USER_NAME];
                if(userName != nil && [userName length]>0)
                {
                    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
                    if ([[userName stringByTrimmingCharactersInSet: set] length] != 0)
                    {
                        //NOV 17 [resultDic setValue:userName forKey:REMOTE_USER_NAME];
                    }
                }
                
                if([[dic valueForKey:REMOTE_USER_TYPE] isEqualToString:@"cl"]) {
                    NSString* fromUserId = [dic valueForKey:FROM_USER_ID];
                    NSString* phoneNum = [self getPhonenumber:fromUserId];
                    if(nil != phoneNum) {
                        [dic setValue:phoneNum forKey:FROM_USER_ID];
                        [dic setValue:@"iv" forKey:REMOTE_USER_TYPE];
                    }
                }
            }
            
            if(![self checkForDuplicateIvRecord:dic inList:tempConversationList])
                [tempConversationList addObject:dic];
            else {
                KLog(@"Duplicate records..! Check the code.");
            }
        }//for loop
    }
    [lockObj lock];
    if(_activeConversationList != nil)
    {
        [_activeConversationList removeAllObjects];
        _activeConversationList = nil;
    }
    if(tempConversationList != nil && [tempConversationList count]>0)
    {
        _activeConversationList = tempConversationList;
    }
    _unreadMsgs = [self getUnreadMessageFromDB]; //TODO: need to allocate?
    [lockObj unlock];
}

//TODO: CMP -- check the implementation
-(BOOL)checkForDuplicateIvRecord:(NSMutableDictionary*)record inList:(NSMutableArray*)tempConversationList
{
    NSString* remoteUserId = [record valueForKey:REMOTE_USER_IV_ID];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:remoteUserId];
    long long currentRemoteUserId = [myNumber longLongValue];
    NSString* unreadMsgCount = [record valueForKey:UNREAD_MSG_COUNT];
    
    if([[record valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE] ||
       [record valueForKey:REMOTE_USER_IV_ID] == Nil || currentRemoteUserId <= 1)
    {
        return NO;
    }
    
    for(int i=0; i < [tempConversationList count]; i++)
    {
        NSDictionary* dic = [tempConversationList objectAtIndex:i];
        if(![[dic valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE] && [[dic valueForKey:REMOTE_USER_IV_ID]isEqualToString:remoteUserId]) {
            if([unreadMsgCount intValue] > 0) {
                int nUnreadMsgCount1 = [[[tempConversationList objectAtIndex:i]
                                             valueForKey:UNREAD_MSG_COUNT]intValue];
                int nUnreadMsgCount2 = [unreadMsgCount intValue];
                int nUnreadMsgCount = nUnreadMsgCount1+nUnreadMsgCount2;
                
                unreadMsgCount = [NSString stringWithFormat:@"%d",nUnreadMsgCount];
                [[tempConversationList objectAtIndex:i] setValue:unreadMsgCount forKey:UNREAD_MSG_COUNT];
            }
            return YES;
        }
    }
    
    return NO;
}

//- getPhonenumber should not be called from main thread
-(NSString*) getPhonenumber:(NSString*)ivID
{
    //Convert NSString to NSNumber
    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* ivIDNum = [f numberFromString:ivID];
    
    //NOV 2017
    __block NSString* retValue = nil;
    NSManagedObjectContext* moc = [AppDelegate sharedPrivateQueueContext];
    //
    [moc performBlockAndWait:^{ //NOV 2017
        
        if([ivIDNum longValue]>0)
        {
            NSArray* contactDetailList = [self getContactForIVUserId:ivIDNum];
            EnLogd(@"IV ID: %@",ivID);
            
            for(ContactDetailData* detail in contactDetailList)
            {
                NSInteger contactType = [detail.contactIdParentRelation.contactType integerValue];//TODO crash EXC_BAD_ACCESS..
                if((contactType == ContactTypeNativeContact || contactType == ContactTypeMsgSyncContact) && [detail.contactDataType isEqualToString:PHONE_MODE])
                {
                    //NOV 2017 return detail.contactDataValue;
                    retValue = detail.contactDataValue;
                    break;
                }
            }
        }
    }];
    
    return retValue;
}

//- getContactForIVUserId should not be called from main thread
-(NSArray*)getContactForIVUserId:(NSNumber *)ivUserId
{
    NSManagedObjectContext* ctx = [AppDelegate sharedPrivateQueueContext];

    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:ctx];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    request.fetchBatchSize = 0;
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"ivUserId = %@",ivUserId];
    [request setPredicate:condition];
    
    __block NSArray *array=nil;
    [ctx performBlockAndWait:^{
        NSError *error;
        array = [ctx executeFetchRequest:request error:&error];
        if (array == nil) {
            KLog(@"No Record Found");
            array = [NSArray array];
        }
    }];
    
    return array;
}

-(NSMutableArray*)getMissedCallConversation
{
#ifdef REACHME_APP
    NSString *orderby = [[NSString alloc] initWithFormat:@"ORDER BY %@ DESC",MSG_DATE];
    NSString *whrereClause = [[NSString alloc]initWithFormat:@"WHERE %@ =\"%@\" AND (MSG_TYPE = \"mc\" OR MSG_TYPE = \"voip\" OR MSG_TYPE = \"voip_out\") AND (MSG_SUB_TYPE IS NULL OR MSG_SUB_TYPE NOT IN (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")) AND (%@ NOT NULL AND %@ != '') AND (%@ != %@) %@" ,LOGGEDIN_USER_ID,[appDelegate.confgReader getLoginId],VOIP_CALL_REJECTED,VOIP_CALL_MISSED,VOIP_CALL_ABORT,VOIP_CALL_SIPERROR,RING_MC, FROM_USER_ID, FROM_USER_ID, FROM_USER_ID,NATIVE_CONTACT_ID, orderby];
    
    NSMutableArray *msgs = [_msgTableObj queryTable:nil whereClause:whrereClause groupBy:nil having:nil orderBy:nil tableType:MESSAGE_TABLE_TYPE];
    
    return msgs;
#else
    NSString *orderby = [[NSString alloc] initWithFormat:@"ORDER BY %@ DESC",MSG_DATE];
    NSString *whrereClause = [[NSString alloc]initWithFormat:@"WHERE %@ =\"%@\" AND (MSG_TYPE = \"mc\" OR MSG_TYPE = \"voip\") AND (MSG_SUB_TYPE IS NULL OR MSG_SUB_TYPE NOT IN (\"%@\",\"%@\",\"%@\",\"%@\")) AND (%@ NOT NULL AND %@ != '') AND (%@ != %@) %@" ,LOGGEDIN_USER_ID,[appDelegate.confgReader getLoginId],VOIP_CALL_REJECTED,VOIP_CALL_MISSED,VOIP_CALL_ABORT,VOIP_CALL_SIPERROR, FROM_USER_ID, FROM_USER_ID, FROM_USER_ID,NATIVE_CONTACT_ID, orderby];
    
    NSMutableArray *msgs = [_msgTableObj queryTable:nil whereClause:whrereClause groupBy:nil having:nil orderBy:nil tableType:MESSAGE_TABLE_TYPE];
    
    return msgs;
#endif
    
}

-(NSMutableArray*)getVoicemailConversation
{
    NSString *orderby = [[NSString alloc] initWithFormat:@"ORDER BY %@ DESC",MSG_DATE];
    
    NSString *whrereClause = [[NSString alloc]initWithFormat:@"WHERE %@ =\"%@\" AND (MSG_TYPE = \"vsms\" AND (MSG_SUB_TYPE = \"avs\" OR MSG_SUB_TYPE = \"vsms\") AND MSG_CONTENT_TYPE=\"a\") AND (%@ NOT NULL AND %@ != '') AND (%@ != %@) %@" ,LOGGEDIN_USER_ID,[appDelegate.confgReader getLoginId],FROM_USER_ID,FROM_USER_ID,FROM_USER_ID, NATIVE_CONTACT_ID,orderby];
    
    NSMutableArray *msgs = [_msgTableObj queryTable:nil whereClause:whrereClause groupBy:nil having:nil orderBy:nil tableType:MESSAGE_TABLE_TYPE];
    
    return msgs;
    
}

-(NSMutableArray *)getUniqueConversation
{
    KLog(@"getUniqueConversation");
#ifdef REACHME_APP
    NSMutableArray* columns = [[NSMutableArray alloc]initWithObjects:@"m.*",@"IFNULL(c.UNREAD_MSG_COUNT,0) AS UNREAD_MSG_COUNT", nil];
    NSString* leftJoin = @"LEFT JOIN (SELECT FROM_USER_ID, count(*) UNREAD_MSG_COUNT FROM MessageTable WHERE MSG_READ_CNT = 0 and MSG_FLOW=\"r\" GROUP BY FROM_USER_ID) as c on m.FROM_USER_ID = c.FROM_USER_ID";
    
    NSString *ignoreMsg = [NSString stringWithFormat:@"%@ NOT IN (\"%@\",\"%@\",\"%@\",\"%@\") AND (%@ IS NULL OR %@ NOT IN (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\"))",MSG_TYPE,FB_TYPE,VB_TYPE,NOTES_TYPE,INV_TYPE,MSG_SUB_TYPE,MSG_SUB_TYPE,VOIP_CALL_MISSED,VOIP_CALL_REJECTED,VOIP_CALL_ABORT,VOIP_CALL_SIPERROR,RING_MC];
    NSString *groupBy = [[NSString alloc]initWithFormat:@"GROUP BY %@", FROM_USER_ID];
    NSString *groupBy1 = [[NSString alloc]initWithFormat:@"GROUP BY m.%@", FROM_USER_ID];
    NSString *orderby = [[NSString alloc] initWithFormat:@"ORDER BY m.%@ DESC",MSG_DATE];
    NSString *innerQuery = [NSString stringWithFormat:@"SELECT %@ || '-' || max(%@) from %@ WHERE %@ %@",FROM_USER_ID,MSG_DATE,MESSAGE_TABLE,ignoreMsg,groupBy];
    
    NSString *whrereClause = [[NSString alloc]initWithFormat:@"m %@ WHERE %@ =\"%@\" AND %@ AND (m.%@ NOT NULL AND m.%@ != '') AND m.%@ || '-' || %@ IN (%@) %@",leftJoin,LOGGEDIN_USER_ID,[appDelegate.confgReader getLoginId],ignoreMsg,FROM_USER_ID,FROM_USER_ID,FROM_USER_ID,MSG_DATE,innerQuery,groupBy1];
    
    
    NSMutableArray *msgs=nil;
#ifndef REACHME_APP
    if([appDelegate.confgReader getContactServerSyncFlag])
#endif
    {
        KLog(@"QUERY starts");
        msgs = [_msgTableObj queryTable:columns whereClause:whrereClause groupBy:nil having:nil orderBy:orderby tableType:MESSAGE_TABLE_TYPE];
        KLog(@"QUERY ends");
    }
#ifndef REACHME_APP
    else {
        KLog(@"getUniqueConversation: Not server synched.");
    }
#endif
    
    [self updateBlockedUsers:msgs];
    
    return msgs;
#else
    NSMutableArray* columns = [[NSMutableArray alloc]initWithObjects:@"m.*",@"IFNULL(c.UNREAD_MSG_COUNT,0) AS UNREAD_MSG_COUNT", nil];
    NSString* leftJoin = @"LEFT JOIN (SELECT FROM_USER_ID, count(*) UNREAD_MSG_COUNT FROM MessageTable WHERE MSG_READ_CNT = 0 and MSG_FLOW=\"r\" GROUP BY FROM_USER_ID) as c on m.FROM_USER_ID = c.FROM_USER_ID";
    
    NSString *ignoreMsg = [NSString stringWithFormat:@"%@ NOT IN (\"%@\",\"%@\",\"%@\",\"%@\") AND (%@ IS NULL OR %@ NOT IN (\"%@\",\"%@\",\"%@\",\"%@\"))",MSG_TYPE,FB_TYPE,VB_TYPE,NOTES_TYPE,INV_TYPE,MSG_SUB_TYPE,MSG_SUB_TYPE,VOIP_CALL_MISSED,VOIP_CALL_REJECTED,VOIP_CALL_ABORT,VOIP_CALL_SIPERROR];
    NSString *groupBy = [[NSString alloc]initWithFormat:@"GROUP BY %@", FROM_USER_ID];
    NSString *groupBy1 = [[NSString alloc]initWithFormat:@"GROUP BY m.%@", FROM_USER_ID];
    NSString *orderby = [[NSString alloc] initWithFormat:@"ORDER BY m.%@ DESC",MSG_DATE];
    NSString *innerQuery = [NSString stringWithFormat:@"SELECT %@ || '-' || max(%@) from %@ WHERE %@ %@",FROM_USER_ID,MSG_DATE,MESSAGE_TABLE,ignoreMsg,groupBy];
    
    NSString *whrereClause = [[NSString alloc]initWithFormat:@"m %@ WHERE %@ =\"%@\" AND %@ AND (m.%@ NOT NULL AND m.%@ != '') AND m.%@ || '-' || %@ IN (%@) %@",leftJoin,LOGGEDIN_USER_ID,[appDelegate.confgReader getLoginId],ignoreMsg,FROM_USER_ID,FROM_USER_ID,FROM_USER_ID,MSG_DATE,innerQuery,groupBy1];
    
   
    NSMutableArray *msgs=nil;
    if([appDelegate.confgReader getContactServerSyncFlag]) {
        KLog(@"QUERY starts");
        msgs = [_msgTableObj queryTable:columns whereClause:whrereClause groupBy:nil having:nil orderBy:orderby tableType:MESSAGE_TABLE_TYPE];
        KLog(@"QUERY ends");
    } else {
        KLog(@"getUniqueConversation: Not server synched.");
    }
    
    [self updateBlockedUsers:msgs];
    
    return msgs;
#endif
    
}

-(void)updateBlockedUsers:(NSArray*) chatList
{
    NSArray* blockedUsersIvIDList = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"BLOCKED_USERS_SRV_LIST"];
    NSMutableArray* blockedUsers = [[NSMutableArray alloc]init];
    
    if([blockedUsersIvIDList count]) {
        for(NSDictionary* dic in chatList)
        {
            NSNumber* remoteUserIvID = [dic valueForKey:REMOTE_USER_IV_ID];
            if(remoteUserIvID != nil && [blockedUsersIvIDList containsObject:remoteUserIvID] ) {
                [blockedUsers addObject:remoteUserIvID];
            }
        }
    }
    
    if([blockedUsers count]) {
        [[ConfigurationReader sharedConfgReaderObj]setObject:blockedUsers forTheKey:@"BLOCKED_TILES"];
        [[ConfigurationReader sharedConfgReaderObj]setObject:nil forTheKey:@"BLOCKED_USERS_SRV_LIST"];
        //NOV 2017 blockedUsersIvIDList = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"BLOCKED_USERS_SRV_LIST"];
    } else {
        //TODO:CMP -- check whether any blocked users in local settings and that blocked users are in the current active conv. chats
        blockedUsers = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"BLOCKED_TILES"];
        if([blockedUsers count]) {
            EnLogd(@"blocked user list in local settings: %@",blockedUsers);
        }
    }
}

#pragma mark -- VSMS limit
-(NSMutableArray*)getVsmsLimitList
{
    NSMutableArray *arr = nil;
    if(_vsmsLimitList != nil && [_vsmsLimitList count]>0)
    {
        [lockObj lock];
        arr = [[NSMutableArray alloc] initWithArray:_vsmsLimitList];
        [lockObj unlock];
    }
    else
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:UI_EVENT forKey:EVENT_MODE];
        [dic setValue:[NSNumber numberWithInt:GET_VSMS_LIMIT] forKey:EVENT_TYPE];
        [appDelegate.engObj addEvent:dic];
    }
    return arr;
}


-(void)getVsmsListFromDB
{
    VsmsLimitTable *vsmsTable = (VsmsLimitTable*)[[DBTables sharedDBTables] getTableObj:VSMS_LIMIT_TABLE_TYPE];
    NSMutableArray *arr = [vsmsTable queryTable:nil whereClause:nil groupBy:nil having:nil orderBy:nil tableType:VSMS_LIMIT_TABLE_TYPE];
    if(arr != nil && [arr count]>0)
    {
        [lockObj lock];
        _vsmsLimitList = arr;
        [lockObj unlock];
    }
}

-(void)saveVsmsLimit:(NSString*)vsmsLimit andNotifyUI:(BOOL)notify
{
    if(vsmsLimit != nil && [vsmsLimit length]>0)
    {
        NSData *vsmsLimitData = [vsmsLimit dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *vsmsLimitDic = [NSJSONSerialization JSONObjectWithData:vsmsLimitData options:0 error:&error];
        if(error != nil || vsmsLimitDic == nil)
        {
            EnLoge(@"Error in VSMS LIMIT:%@",error);
        }
        else
        {
            NSNumber *limit = [vsmsLimitDic valueForKey:API_LIMIT];
            [appDelegate.confgReader setVsmsLimit:[limit intValue]];
            NSArray *user = [vsmsLimitDic valueForKey:API_USER];
            if(user != nil && [user count] != 0)
            {
                long count = [user count];
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                for (int i =0; i<count; i++)
                {
                    NSDictionary *dic = [user objectAtIndex:i];
                    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
                    [newDic setValue:[dic valueForKey:API_PHONE] forKey:PHONE_NO];
                    [newDic setValue:[dic valueForKey:API_BAL] forKey:BALANCE];
                    [arr addObject:newDic];
                }
                [lockObj lock];
                _vsmsLimitList = arr;
                [lockObj unlock];
                [self deleteVsmsLimitTableData];
                VsmsLimitTable *vsmsTable = (VsmsLimitTable*)[[DBTables sharedDBTables] getTableObj:VSMS_LIMIT_TABLE_TYPE];
                if(![vsmsTable insertInTable:arr tableType:VSMS_LIMIT_TABLE_TYPE])
                {
                    EnLoge(@"Error in insertion of VSMS LIMIT Table");
                }
                if(notify) {
                    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
                    [resultDic setValue:[NSNumber numberWithInt:GET_VSMS_LIMIT] forKey:EVENT_TYPE];
                    [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
                    [self notifyUI:resultDic];
                }
            }
        }
    }
    else
    {
        int vsmsLimit  = [appDelegate.confgReader getVsmsLimit];
        if(vsmsLimit == -1)
        {
            [appDelegate.confgReader setVsmsLimit:VSMS_LIMIT];
        }
    }
}

#pragma mark -- Read and Unread Msg
//- Returns the number of new messages from all users that include hidden and blocked users
-(long)getUnreadMsgCount
{
    if(_unreadMsgs != nil && [_unreadMsgs count]>0)
    {
        return [_unreadMsgs count];
    }
    return 0;
}

-(NSArray*)getUnreadMessages
{
    return _unreadMsgs;
}

-(long)getUnreadHiddenMsgCount
{
    return _unreadMsgCountOfHiddenUsers;
}

-(long) getUnreadBlockedMsgCount
{
    return _unreadMsgCountOfBlockedUsers;
}

//TODO: CMP -- do we need this?
-(NSMutableArray*)getUnreadMessageFromDB
{
    NSMutableArray *msges = nil;
    
    NSString *ignoreMsg = [NSString stringWithFormat:@"%@ NOT IN (\"%@\",\"%@\",\"%@\",\"%@\")",MSG_TYPE,FB_TYPE,VB_TYPE,NOTES_TYPE,INV_TYPE];
    NSString *groupBy = [[NSString alloc]initWithFormat:@"GROUP BY %@",FROM_USER_ID];
    NSString *orderby = [[NSString alloc] initWithFormat:@"ORDER BY %@ DESC",MSG_DATE];
    NSString *innerQuery = [NSString stringWithFormat:@"SELECT %@ || '-' || max(%@) from %@ WHERE %@ %@",FROM_USER_ID,MSG_DATE,MESSAGE_TABLE,ignoreMsg,groupBy];
    
    NSString *whrereClause = [[NSString alloc]initWithFormat:@"WHERE %@ =\"%@\" AND (%@ NOT NULL AND %@ != '') AND %@ = \"%@\" AND %@ = 0 AND %@ AND %@ || '-' || %@ IN (%@) %@" ,LOGGEDIN_USER_ID,[appDelegate.confgReader getLoginId],FROM_USER_ID, FROM_USER_ID, MSG_FLOW,MSG_FLOW_R,MSG_READ_CNT,ignoreMsg,FROM_USER_ID,MSG_DATE,innerQuery,groupBy];
    msges = [_msgTableObj queryTable:nil whereClause:whrereClause groupBy:nil having:nil orderBy:orderby tableType:MESSAGE_TABLE_TYPE];
    
    //- find a number of new messages from hidden users
    NSArray* hiddenUsers = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"HIDDEN_TILES"];
    _unreadMsgCountOfHiddenUsers = 0;
    for(NSDictionary* dic in msges) {
        
        NSString* convType = [dic valueForKey:CONVERSATION_TYPE];
        NSString* fromUserID = nil;
        if( [convType isEqualToString:GROUP_TYPE]) {
            fromUserID = [dic valueForKey:FROM_USER_ID];
        }
        else {
            fromUserID = [dic valueForKey:REMOTE_USER_IV_ID];
            if(!fromUserID || ![fromUserID length] || [fromUserID isEqualToString:@"0"])
                fromUserID = [dic valueForKey:FROM_USER_ID];
        }
        
        if( [hiddenUsers containsObject:fromUserID] )
            _unreadMsgCountOfHiddenUsers++;
    }
    
    //find a number of new messages from blocked users
    NSArray* blockedUsers = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"BLOCKED_TILES"];
    _unreadMsgCountOfBlockedUsers = 0;
    for(NSDictionary* dic in msges)
    {
        NSString* ivIDfromDb = [dic valueForKey:REMOTE_USER_IV_ID];
        if(!ivIDfromDb || ![ivIDfromDb length] || [ivIDfromDb isEqualToString:@"0"])
            ivIDfromDb = [dic valueForKey:FROM_USER_ID];
        
        if( [blockedUsers containsObject:ivIDfromDb] )
            _unreadMsgCountOfBlockedUsers++;
        
    }
    return msges;
}

#pragma mark -- Purge Old Data
-(void)purgeOldData
{
    //Purge will happen once in 15 days.
    BOOL purgeRequired = false;
    NSDate* lastPurgeDate = [[ConfigurationReader sharedConfgReaderObj]getLastPurgeDate];
    if(lastPurgeDate == nil)
        purgeRequired = true;
    else
    {
        NSDate *daysOlder =[[NSDate date] dateByAddingTimeInterval:-(PURGE_CYCLE*24*60*60)];
        if ([lastPurgeDate compare:daysOlder] == NSOrderedAscending)
        {
            purgeRequired = true;
        }
    }
    
    if(purgeRequired)
    {
        //NSLog(@"purgeOldData - START");
        //Purge only in case number of message > MAX_RECORD_TO_KEEP
        int rowCount = [_msgTableObj getRowCount:nil tableType:MESSAGE_TABLE_TYPE];
        if(rowCount > MAX_RECORD_TO_KEEP)
        {
            int deleteRecordPerIteration = 500;
            NSMutableArray* columnsDetail = [[NSMutableArray alloc]initWithObjects:@"msg_date",@"msg_id",@"msg_content_type",@"msg_local_path",@"media_format",nil];
            NSString *orderby = [[NSString alloc] initWithFormat:@"ORDER BY %@ ASC LIMIT %d",MSG_DATE,deleteRecordPerIteration];
            NSMutableArray *msgToBeDeleted = [_msgTableObj queryTable:columnsDetail whereClause:nil groupBy:nil having:nil orderBy:orderby tableType:MESSAGE_TABLE_TYPE];
            
            //Filter audio and image message
            /* NSArray *filteredImageMsg = [msgToBeDeleted filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(MSG_CONTENT_TYPE == %@)", IMAGE_TYPE]];
             for(NSDictionary* message in filteredImageMsg)
             {
             //delete image file
             NSString* msgLocalPath = [message valueForKey:MSG_LOCAL_PATH];
             if(msgLocalPath.length)
             {
             NSString* filePath = [[IVFileLocator getMediaImagePath:msgLocalPath] stringByAppendingPathExtension:[message valueForKey:MEDIA_FORMAT]];
             [IVFileLocator deleteFileAtPath:filePath];
             }
             }
             
             NSArray *filteredAudioMsg = [msgToBeDeleted filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(MSG_CONTENT_TYPE == %@)", AUDIO_TYPE]];
             for(NSDictionary* message in filteredAudioMsg)
             {
             //delete audio file
             NSString* msgLocalPath = [message valueForKey:MSG_LOCAL_PATH];
             [IVFileLocator deleteFileAtPath:msgLocalPath];
             }*/
            
            //Delete Message
            NSMutableArray* msgId = [msgToBeDeleted valueForKey:MSG_ID];
            NSString* deleteMsgIdList = [msgId componentsJoinedByString:@","];
            NSString *whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ IN (%@) ",MSG_ID ,deleteMsgIdList];
            [_msgTableObj deleteFromTable:whereClause tableType:MESSAGE_TABLE_TYPE];
            
            //Add event to engine for purging
            NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
            [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
            [eventObj setValue:[NSNumber numberWithInteger:PURGE_OLD_DATA] forKey:EVENT_TYPE];
            [eventObj setValue:[NSMutableDictionary dictionary] forKey:EVENT_OBJECT];
            [appDelegate.engObj addEvent:eventObj];
        }
        else
        {
            [self purgeFilesOlderThan:DAYS_OLDER_FILE_TO_KEEP];
            //set purge time as the current time
            NSDate* currentPurgeDate = [NSDate new];//purge date to be set in configuration reader
            [[ConfigurationReader sharedConfgReaderObj]setLastPurgeDate:currentPurgeDate];
        }
        //NSLog(@"purgeOldData - END");
    }
}

-(void)purgeFilesOlderThan:(float)days
{
    [self purgeFilesInDirectory:[IVFileLocator getMediaAudioReceivedDirectory] olderThan:days];
    [self purgeFilesInDirectory:[IVFileLocator getMediaAudioSentDirectory] olderThan:days];
    [self purgeFilesInDirectory:[IVFileLocator getMediaImageProcessedDirectory] olderThan:days];
}

-(void)purgeFilesInDirectory:(NSString*)dirPath olderThan:(float)days
{
    NSFileManager* fileManager =  [NSFileManager defaultManager];
    NSDirectoryEnumerator* en = [fileManager enumeratorAtPath:dirPath];
    
    NSString* file;
    while(file = [en nextObject])
    {
        NSError *error= nil;
        NSString *filepath =[NSString stringWithFormat:[dirPath stringByAppendingString:@"/%@"],file];
        
        NSDate* creationDate =[[fileManager attributesOfItemAtPath:filepath error:&error] fileCreationDate];
        NSDate *daysOlder =[[NSDate date] dateByAddingTimeInterval:-days*24*60*60];
        
        if ([creationDate compare:daysOlder] == NSOrderedAscending)
        {
            NSString* fileType = [[fileManager attributesOfItemAtPath:filepath error:&error] fileType];
            if([fileType isEqualToString:NSFileTypeRegular])
                [IVFileLocator deleteFileAtPath:filepath];
        }
    }
}

#pragma mark -- Handle Engine Event.
-(int) handleUIEvent:(int)eventType objectDic:(NSMutableDictionary *)objDic
{
    isPushNotification = NO;
    BOOL isLooggedIn = [appDelegate.confgReader getIsLoggedIn];
    if(!isLooggedIn)
    {
        [appDelegate.engObj cancelEvent];
        EnLogd(@"User is not logged in");
        return 0;
    }
    
    switch (eventType)
    {
        case SEND_MC:
        case SEND_MSG:
        case SEND_VOIP_CALL_LOG:
        {
            int type = MessageUser;
            if([[objDic valueForKey:MSG_TYPE]isEqualToString:NOTES_TYPE])
            {
                type = MessageNotes;
            }
            else if([[objDic valueForKey:MSG_TYPE]isEqualToString:VB_TYPE])
            {
                type = MessageVobolo;
            }
            
            NSMutableArray *pendingMsgList = [self getPendingMsgList:type];
            KLog(@"Pending msgs (to be sent) in DB: %ld",(long)[pendingMsgList count]);
            
            if(nil == _pendingMsgQueue) {
                _pendingMsgQueue = [[NSMutableArray alloc] init];
            }
            else {
                KLog(@"Messages in _pendingMsgQueue %ld", (long)[_pendingMsgQueue count]);
            }
            
            if(pendingMsgList != nil && [pendingMsgList count]>0)
            {
                KLog(@"Adding pending msgs retrieved from DB into _pendingMsgQueue");
                [self addPendingMsgToQueue:pendingMsgList];
            }
            
            KLog(@"Save a new msg into DB : %@",[objDic valueForKey:MSG_GUID]);
            if([self saveNewMsgInDB:objDic])
                [_pendingMsgQueue addObject:objDic];

            if([_pendingMsgQueue count]) {
                [self sendAllMsg];
            }
            
            BOOL bRet = [self checkSpaceAndDeleteMsgs];
            if(bRet) {
                [self createActiveConversation:nil];
                NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
                if(_activeConversationList != nil && [_activeConversationList count]>0)
                    [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
                else
                    [resultDic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
                
                [resultDic setValue:[NSNumber numberWithInt:GET_ACTIVE_CONVERSATION_LIST] forKey:EVENT_TYPE];
                [self notifyUI:resultDic];
            }
            
            if(type == MessageNotes || type == MessageVobolo)
            {
                [self refreshChatDataAndNotifyAllUI:NO];
            }
            
            break;
        }
            
        case SEND_APP_STATUS:
        {
            [self sendAppStatus:objDic];
            break;
        }
            
        case FETCH_CELEBRITY_MSG:
        {
            [self fetchCelebrityMsg:objDic];
            break;
        }
            
        case FETCH_OLDER_MSG:
        {
            [self fetchOlderMsgReqDic:objDic];
            break;
        }
            
        case DELETE_MSG_TABLE:
        {
            [self deleteMsgTableData];
            break;
        }
            
        case GET_ACTIVE_CONVERSATION_LIST:
        {
            [self createActiveConversation:nil];
            
            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
            if(_activeConversationList != nil && [_activeConversationList count] > 0)
            {
                [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
            }
            else
            {
                [resultDic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
            }
            [resultDic setValue:[NSNumber numberWithInt:GET_ACTIVE_CONVERSATION_LIST] forKey:EVENT_TYPE];
            [resultDic setValue:_activeConversationList forKey:RESPONSE_DATA];//Jan 17
            [self notifyUI:resultDic];
            
            [NSNotificationCenter.defaultCenter postNotificationName:kChatsUpdateEvent object:self userInfo:resultDic];
            break;
        }
            
        case GET_MISSEDCALL_LIST:
        {
            [self createMissedCallList];
            break;
        }
        
        case GET_VOICEMAIL_LIST:
        {
            [self createVoicemailList];
            break;
        }
        
        case GET_CURRENT_CHAT:
        {
            [self populateCurrentChat];
            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
            if(_currentChat != nil && [_currentChat count] > 0)
            {
                [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
            }
            else
            {
                [resultDic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
            }
            [resultDic setValue:[NSNumber numberWithInt:GET_CURRENT_CHAT] forKey:EVENT_TYPE];
            [self notifyUI:resultDic];
            
            break;
        }
            
        case DOWNLOAD_VOICE_MSG:
        {
            KLog(@"DOWNLOAD_VOICE_MSG");
            
            if([Common isNetworkAvailable] == NETWORK_AVAILABLE)
            {
                NSMutableDictionary* dicWithLocalPath = [self isAudioAvailable:objDic];
                if(!dicWithLocalPath) {
                    EnLogd(@"download voicemsg");
                    KLog(@"download voicemsg = %@",objDic);
                    NSMutableDictionary *evDic = [[NSMutableDictionary alloc]init];
                    [evDic setValue:objDic forKey:REQUEST_DIC];
                    [self eventToNetwork:DOWNLOAD_VOICE_MSG eventDic:evDic];
                } else {
                    EnLogd(@"Msg already got downloaded");
                    KLog(@"Msg already got downloaded");
                    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
                    [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
                    [resultDic setValue:dicWithLocalPath forKey:RESPONSE_DATA];
                    [resultDic setValue:[NSNumber numberWithInt:DOWNLOAD_VOICE_MSG] forKey:EVENT_TYPE];
                    [self notifyUI:resultDic];
                }
            }
            else
            {
                NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
                [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
                [resultDic setValue:objDic forKey:RESPONSE_DATA];
                [resultDic setValue:[NSNumber numberWithInt:DOWNLOAD_VOICE_MSG] forKey:EVENT_TYPE];
                [self notifyUI:resultDic];
            }
            break;
        }
            
        case STOP_SEND_MSG:
        {
            [self stopSenddingAllMsg];
            break;
        }
            
        case SEND_ALL_PENDDING_MSG:
        {
            [self sendAllPendingMsg];
            break;
        }
            
        case UPDATE_ACTIVITYIES:
        {
            if(objDic.count)
            {
                NSMutableDictionary* activity = [[NSMutableDictionary alloc]init];
                [activity setValue:[NSArray arrayWithObject:objDic] forKey:API_MSG_ACTIVITIES];
                [self processActivityData:activity forEventType:FETCH_MSG_ACTIVITY];
            }
            break;
        }

        case FORWARD_MSG:
        {
            [self forwardmsgReq:objDic];
            break;
        }
        
        case GET_NOTES:
        {
            [self populateNotesListFromDB];
            
            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
            if(_notesList != nil && [_notesList count]>0)
            {
                [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
            }
            else
            {
                [resultDic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
            }
            [resultDic setValue:[NSNumber numberWithInt:GET_NOTES] forKey:EVENT_TYPE];
            [self notifyUI:resultDic];
            
            break;
        }
            
        case GET_MYVOBOLO_MSG:
        {
            [self populateMyVoboloListFromDB];
            
            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
            if(_myVoboloList != nil && [_myVoboloList count]>0)
            {
                [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
            }
            else
            {
                [resultDic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
            }
            [resultDic setValue:[NSNumber numberWithInt:GET_MYVOBOLO_MSG] forKey:EVENT_TYPE];
            [self notifyUI:resultDic];

            break;
        }
        
        case UPDATE_PLAY_DURATION:
        {
            [self updatePlayDuration:objDic];
            break;
        }
            
        case GET_VSMS_LIMIT:
        {
            [self getVsmsListFromDB];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            if(_vsmsLimitList != nil && [_vsmsLimitList count]>0)
            {
                [dic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
            }
            else
            {
                [dic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
            }
            [dic setValue:[NSNumber numberWithInt:GET_VSMS_LIMIT] forKey:EVENT_TYPE];
            [self notifyUI:dic];

            break;
        }
            
        case UPDATE_MSG_ON_CONTACT_SYNC:
        {
            [self updateMsgOnContactSync];
            break;
        }
            
        case MISS_CALL_GET_INFO:
        {
            NSString* nativeContactID = [objDic valueForKey:NATIVE_CONTACT_ID];
            [self updateMissedCallInfo:nativeContactID];
            break;
        }
            
        case CHANGE_USER_ID:
        {
            //Set the new primary number as log-in user
            [self changeUserID:objDic];
            break;
        }
        
        case CHAT_ACTIVITY:
        {
            ChatActivityData* data = (ChatActivityData*)objDic;
            [self processChatActivity:data];
            break;
        }
            
        case MQTT_DATA_RECEIVED:
        {
            MQTTReceivedData* data = (MQTTReceivedData*)objDic;
            [self processMQTTReceivedData:data];
            break;
        }
        
        case ADD_MSG_HEADER:
        {
            
            BOOL isMsgAvail = [self isMessageAvailable:objDic OutMessage:nil];
            EnLogd(@"ADD_MSG_HEADER. %d",isMsgAvail);
            if(objDic.count && !isMsgAvail) {
                [self addMessageHeader:objDic];
            }
            break;
        }
            
        case PURGE_OLD_DATA:
        {
            [self purgeOldData];
            break;
        }
            
        case DELETE_CHATS:
        {
            if([objDic count]) {
                NSArray* phoneNumberList = [objDic valueForKey:PHONE_NO];
                [self handleDeleteChats:phoneNumberList];
            }
            break;
        }
            
#ifdef REACHME_APP
        case UPDATE_MISSEDCALL_REASON:
        {
            if(objDic.count) {
                isPushNotification = YES;
                [self updateMissedCallReason:objDic];
            }
            break;
        }
#endif
    }
    
    return SUCCESS;
}

-(int)handleNetEvent:(int)eventType objectDic:(NSMutableDictionary *)objDic
{
    BOOL isLooggedIn = [appDelegate.confgReader getIsLoggedIn];
    if(!isLooggedIn)
    {
        [appDelegate.engObj cancelEvent];
        EnLogd(@"User is not logged in");
        return 0;
    }
    switch (eventType)
    {
        case SEND_TEXT_MSG:
        case SEND_VOICE_MSG:
        case SEND_IMAGE_MSG:
        case SEND_MC:
        case SEND_VOIP_CALL_LOG:
        {
            [self handleSendMsgResponse:objDic];
        }
            break;
            
        case SEND_APP_STATUS:
        {
            [self handleAppStatusResponse:objDic];
            break;
        }
            
        case FETCH_CELEBRITY_MSG:
        {
            [self handleFetchCelebrityMsgResponse:objDic];
            break;
        }
            
        case FETCH_OLDER_MSG:
        {
            [self handleFetchOlderMsgResponse:objDic];
        }
            break;
        case DOWNLOAD_VOICE_MSG:
        {
            [self handleDownlodMsgResp:objDic];
        }
            break;
        
        case FORWARD_MSG:
        {
            [self handleforwardmsgResp:objDic];
        }
            break;
            
        default:
            break;
    }
    return SUCCESS;
}

-(void)refreshChatDataAndNotifyAllUI:(BOOL)notify
{
    int currentUIType = [appDelegate.stateMachineObj getCurrentUIType];
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    if(currentUIType == INSIDE_CONVERSATION_SCREEN)
    {
        [self populateCurrentChat];
        
        if(_currentChat != nil && [_currentChat count]>0)
        {
            [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
        }
        else
        {
            [resultDic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
        }
        [resultDic setValue:[NSNumber numberWithInt:GET_CURRENT_CHAT] forKey:EVENT_TYPE];
    }
    else if(currentUIType == MY_VOBOLO_SCREEN)
    {
        [self populateMyVoboloListFromDB];
        if(_myVoboloList != nil && [_myVoboloList count]>0)
        {
            [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
        }
        else
        {
            [resultDic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
        }
        
        [resultDic setValue:[NSNumber numberWithInt:GET_MYVOBOLO_MSG] forKey:EVENT_TYPE];
    }
    else if(currentUIType == NOTES_SCREEN)
    {
        [self populateNotesListFromDB];
        if(_notesList != nil && [_notesList count]>0)
        {
            [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
        }
        else
        {
            [resultDic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
        }
        [resultDic setValue:[NSNumber numberWithInt:GET_NOTES] forKey:EVENT_TYPE];
    }
    //FEB 24
    else if (CHAT_GRID_SCREEN == currentUIType) {
        [self createActiveConversation:nil];
    }
    //
    if(notify)
        [self notifyUI:resultDic];
}

#pragma mark -- Download voice message
-(void)handleDownlodMsgResp:(NSMutableDictionary*)objDic
{
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    if(objDic != nil && [objDic count] >0)
    {
        NSString *responseCode = [objDic valueForKey:RESPONSE_CODE];
        NSMutableDictionary *respDic = [objDic valueForKey:REQUEST_DIC];
        if([responseCode isEqualToString:NET_SUCCESS])
        {
            long dwnloadCount = [[respDic valueForKey:MSG_DOWNLOAD_CNT] integerValue];
            NSNumber *num = [NSNumber numberWithLong:(dwnloadCount+1)];
            [respDic setValue:num forKey:MSG_DOWNLOAD_CNT];
            //KLog(@"handleDownlodMsgResp SUCCESS: MSG_CONTENT = %@",[respDic valueForKey:MSG_CONTENT]);
            EnLogd(@"handleDownlodMsgResp SUCCESS");
        }
        else
        {
            [respDic setValue:[NSNumber numberWithLongLong:0] forKey:DOWNLOAD_TIME];
            EnLogi(@"ERROR downloading voice message");
            return;
        }
        
        NSString *whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\"",MSG_ID,[respDic valueForKey:MSG_ID]];
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
        
#ifdef OPUS_ENABLED
        
        NSString* msgLocalPath = [respDic valueForKey:MSG_LOCAL_PATH];
        if( !msgLocalPath ) {
            EnLogi(@" MSG_LOCAL_PATH not found");
            return;
        }
        
        EnLogd(@"Msg local path = %@",msgLocalPath);
        NSString* fileName = [[NSString alloc]initWithString:msgLocalPath];
        NSString* wavFileName = [[NSString alloc]initWithString:[fileName stringByDeletingPathExtension]];
        NSString* ext = [fileName pathExtension];
        
        if( [ext isEqualToString:@"iv"] ) {
            NSString* pcmFileName = [[NSString alloc]initWithString:wavFileName];
            pcmFileName = [pcmFileName stringByAppendingPathExtension:@"pcm"];
            wavFileName = [wavFileName stringByAppendingPathExtension:@"wav"];
            
            const char* cOpusFile = [fileName UTF8String];
            const char* cPcmFile = [pcmFileName UTF8String];
            const char* cWavFile = [wavFileName UTF8String];
            
            int iResult = [OpusCoder DecodeAudio:8000 OPUSFile:cOpusFile PCMFile:cPcmFile WAVFile:cWavFile];
            if(SUCCESS == iResult) {
                [IVFileLocator deleteFileAtPath:pcmFileName];
                [IVFileLocator deleteFileAtPath:fileName];//Delete the opus file
                [newDic setValue:wavFileName forKey:MSG_LOCAL_PATH];
                [respDic setValue:wavFileName forKey:MSG_LOCAL_PATH];
                EnLogd(@"Decoded successfully. OPUS = %s, PCM = %s, WAV = %s",cOpusFile,cPcmFile,cWavFile);
            }
            else {
                EnLoge(@"ERROR: Error in decoding file:%@",fileName);
            }
        } else {
            [newDic setValue:[respDic valueForKey:MSG_LOCAL_PATH] forKey:MSG_LOCAL_PATH];
        }
#else
        [newDic setValue:[respDic valueForKey:MSG_LOCAL_PATH] forKey:MSG_LOCAL_PATH];
#endif
        
        [newDic setValue:[respDic valueForKey:MSG_DOWNLOAD_CNT] forKey:MSG_DOWNLOAD_CNT];
        [newDic setValue:[respDic valueForKey:MSG_STATE] forKey:MSG_STATE];
        [newDic setValue:[respDic valueForKey:DOWNLOAD_TIME] forKey:DOWNLOAD_TIME];
        KLog(@"update table. dic = %@",newDic);
        
        //MAY 2017
        //- Before msg gets downloaded, it could have been withdrawn. So, update the MSG_STATE accordingly.
        NSString* msgID = [respDic valueForKey:MSG_ID];
        NSString* wc = [[NSString alloc] initWithFormat:@"WHERE MSG_ID = \"%@\"",msgID];
        NSMutableArray *arr = [_msgTableObj queryTable:nil whereClause:wc groupBy:nil having:nil orderBy:nil tableType:MESSAGE_TABLE_TYPE];
        
        if(arr.count) {
            NSDictionary* rDic = [arr objectAtIndex:0];
            NSString* msgState = [rDic valueForKey:MSG_STATE];
            if([msgState isEqualToString:API_WITHDRAWN]) {
                [newDic setValue:API_WITHDRAWN forKey:MSG_STATE];
            }
        }
        //
        
        if(![_msgTableObj updateTable:newDic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE])
        {
            EnLoge(@"Error in Messaege Updation");
        }
        
        [self refreshChatDataAndNotifyAllUI:NO];
        [self checkSpaceAndDeleteMsgs];
        
        EnLogd(@"Notify the UI to play the downloaded file");
        [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
        [resultDic setValue:respDic forKey:RESPONSE_DATA];
        [resultDic setValue:[NSNumber numberWithInt:DOWNLOAD_VOICE_MSG] forKey:EVENT_TYPE];
        [self notifyUI:resultDic];
    }
}

#pragma mark -- Forward Msg
-(void)forwardmsgReq:(NSMutableDictionary*)msgDic
{
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE)
    {
        if(msgDic != nil && [msgDic count]>0)
        {
            NSMutableArray *contactList = [msgDic valueForKey:CONTACT_LIST];
            if(contactList != nil && [contactList count]>0)
            {
                NSMutableDictionary *forwardMsg = [[NSMutableDictionary alloc] init];
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                NSMutableDictionary *loggedInUser = [[NSMutableDictionary alloc] init];
                NSString *ivIdStr = [[NSString alloc] initWithFormat:@"%@",[NSNumber numberWithLong:[appDelegate.confgReader getIVUserId]]];
                [loggedInUser setValue:ivIdStr forKey:API_CONTACT];
                [loggedInUser setValue:IV_TYPE forKey:API_TYPE];
                [arr addObject:loggedInUser];
                
                for (NSDictionary* personDic in contactList)
                {
                    NSString* shareMsgType = [personDic valueForKey:@"shareMsgType"];
                    NSString* shareMsgContactValue = @"";
                   
                    if([shareMsgType isEqualToString:IV_TYPE])
                    {
                        shareMsgContactValue = [[personDic valueForKey:@"shareMsgDataValue"]stringValue];
                    }
                    else
                    {
                        shareMsgContactValue = [personDic valueForKey:@"shareMsgDataValue"];
                    }
                     NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setValue:shareMsgContactValue forKey:API_CONTACT];
                    [dic setValue:shareMsgType forKey:API_TYPE];
                    [arr addObject:dic];
                }

                [forwardMsg setValue:arr forKey:API_CONTACT_IDS];
                [self addCommonData:forwardMsg eventType:FORWARD_MSG];
#ifndef REACHME_APP
                [self getLocationPermission];
#endif
                NSString *latitude = @"";
                NSString *longitute = @"";
                NSString *locName = @"";
                if([Setting sharedSetting].data.displayLocation)
                {
                    NSMutableDictionary *fromLoc = [[NSMutableDictionary alloc] init];
                    if(_location != nil)
                    {
                        
                        latitude = [[NSNumber numberWithFloat:_location.coordinate.latitude] stringValue];
                        longitute = [[NSNumber numberWithFloat:_location.coordinate.longitude] stringValue];
                    }
                    if(_locationName != nil)
                    {
                        locName = _locationName;
                    }
                    
                    [fromLoc setValue:longitute forKey:API_LOGITUDE];
                    [fromLoc setValue:latitude forKey:API_LATITUDE];
                    [fromLoc setValue:locName forKey:API_LOCATION_NM];
                    [forwardMsg setValue:fromLoc forKey:API_FROM_LOCATION];
                }
                
                if([[msgDic valueForKey:MSG_TYPE] isEqualToString:CELEBRITY_TYPE]) {
                    [forwardMsg setValue:VB_TYPE forKey:API_MSG_CONTENT_TYPE];
                } else {
                    [forwardMsg setValue:IV_TYPE forKey:API_MSG_TYPE];
                }
                [forwardMsg setValue:[msgDic valueForKey:MSG_ID] forKey:API_MSG_ID];
                [forwardMsg setValue:[NSNumber numberWithBool:YES] forKey:API_FETCH_MSGS];
                [forwardMsg setValue:[msgDic valueForKey:MSG_DATE] forKey:API_MSG_DT];//Jan 19, 2017
                //[forwardMsg setValue:[Common getGuid] forKey:API_GUID];
                [forwardMsg setValue:[NSNumber numberWithLong:[appDelegate.confgReader getAfterMsgId]] forKey:API_FETCH_AFTER_MSGS_ID];
                [forwardMsg setValue:[NSNumber numberWithBool:YES] forKey:API_FETCH_OPPONENT_CONTACTIDS];
                
                NSMutableDictionary *evDic = [[NSMutableDictionary alloc]init];
                [evDic setValue:forwardMsg forKey:REQUEST_DIC];
                [self eventToNetwork:FORWARD_MSG eventDic:evDic];
            }
        }
    }
}

-(void)handleforwardmsgResp:(NSMutableDictionary*)objDic
{
    NSMutableDictionary *shareResultDic = [[NSMutableDictionary alloc] init];
    NSString *shareMsg = NSLocalizedString(@"MSG_NOT_SENT_SUCCESSFULLY",nil);
    KLog(@"handleforwardmsgResp = %@",objDic);
    if(objDic != nil && [objDic count]>0)
    {
        NSString *responseCode = [objDic valueForKey:RESPONSE_CODE];
        NSDictionary *respDic = [objDic valueForKey:RESPONSE_DATA];
        NSDictionary *reqstDic = [objDic valueForKey:REQUEST_DIC];
        
        if([responseCode isEqualToString:NET_SUCCESS])
        {
            NSString *status = [respDic valueForKey:@"status"];
            if([status isEqualToString:@"ok"])
            {
                //update the forward icon.
                
                [self processMessageResponseFromServer:respDic forEventType:FORWARD_MSG requestDic:reqstDic];
                shareMsg = NSLocalizedString(@"MSG_SHARE_SUCCESSFULLY", nil);
                NSNumber* msgID = [reqstDic valueForKey:API_MSG_ID];
                [shareResultDic setValue:msgID forKey:MSG_ID];
                
                //JAN 19, 2017
                NSNumber* nuDate = [reqstDic valueForKey:API_MSG_DT];
                [shareResultDic setValue:nuDate forKey:MSG_DATE];
                //
            }
        }
    }
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    [shareResultDic setValue:shareMsg forKey:ALERT_SHARE_MSG];
    
    [resultDic setValue:shareResultDic forKey:RESPONSE_DATA];
    [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
    [resultDic setValue:[NSNumber numberWithInt:FORWARD_MSG] forKey:EVENT_TYPE];
    [self notifyUI:resultDic];
    
    if([appDelegate.stateMachineObj getCurrentUIType] == CHAT_GRID_SCREEN)
    {
        NSMutableDictionary *resultDic1 = [[NSMutableDictionary alloc] init];
        if(_activeConversationList != nil && [_activeConversationList count] > 0)
            [resultDic1 setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
        else
            [resultDic1 setValue:ENG_FALIURE forKey:RESPONSE_CODE];
        
        [resultDic1 setValue:[NSNumber numberWithInt:GET_ACTIVE_CONVERSATION_LIST] forKey:EVENT_TYPE];
        [self notifyUI:resultDic1];
    }
    
}

#pragma mark -- Fetch Message.
-(void)fetchCelebrityMsg:(NSMutableDictionary*)notifDic
{
    if(!_pendingFetchCelebMsgFlag && [Common isNetworkAvailable] == NETWORK_AVAILABLE)
    {
        NSMutableDictionary *fetchMsgDIc = [[NSMutableDictionary alloc] init];
        [self addCommonData:fetchMsgDIc eventType:FETCH_CELEBRITY_MSG];
        
        [fetchMsgDIc setValue:[NSNumber numberWithBool:YES] forKey:API_FETCH_PIC_URI_TYPE];
        long lastBlogId = [appDelegate.confgReader getLastBlogId];
        
        if( lastBlogId <= 0) {
            NSNumber *maxRow = [NSNumber numberWithInt:50];//MAX_ROWS
            [fetchMsgDIc setValue:maxRow forKey:API_FETCH_MAX_ROWS];
        }
        
        [fetchMsgDIc setValue:[NSNumber numberWithLong:lastBlogId] forKey:API_LAST_BLOG_ID];
        NSMutableDictionary *evDic = [[NSMutableDictionary alloc]init];
        KLog(@"fetchCelebrityMsg:%@",fetchMsgDIc);
        [evDic setValue:fetchMsgDIc forKey:REQUEST_DIC];
        [self eventToNetwork:FETCH_CELEBRITY_MSG eventDic:evDic];
        _pendingFetchCelebMsgFlag = TRUE;
    }
}

-(void)fetchOlderMsgReqDic:(NSDictionary *)dic
{
    //check in DB before we go back to server to get old list
    long beforeMsgId = [[dic objectForKey:MSG_ID]longLongValue];
    NSString* msgType = [dic valueForKey:MSG_TYPE];//MAY 2017
    BOOL fetchFromServer = true;
    if(beforeMsgId > 0)
    {
        NSMutableArray* oldMsgList = nil;
        if(_currentChatUser && ![msgType isEqualToString:NOTES_TYPE])
            oldMsgList = [self getOlderChatBeforeMessageId:beforeMsgId withLimit:0];
        else if([msgType isEqualToString:NOTES_TYPE])
            oldMsgList = [self getOlderNotesBeforeMessageId:beforeMsgId withLimit:0];
        
        if(oldMsgList.count > 0)
        {
            if(oldMsgList.count < 25)
            {
                fetchFromServer = true;
                beforeMsgId = [[oldMsgList[0] valueForKey:MSG_ID]longLongValue];
            }
            else
                fetchFromServer = false;
            
            /*
             //MAR 24, 2017 TODO
             //There is a possiblity, (if beforeMsgId is of blog message id), values of msg-ids are smaller than beforeMsgId. Discuss with Ajay
             
            NSDictionary* dic = [oldMsgList firstObject];
            long long ivMsgId = [[dic valueForKey:MSG_ID]longLongValue];
            if(ivMsgId>0 && beforeMsgId > ivMsgId) {
                fetchFromServer = YES;
                beforeMsgId = ivMsgId;
            }
            */
            
            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
            [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
            [resultDic setValue:[NSNumber numberWithInt:FETCH_OLDER_MSG] forKey:EVENT_TYPE];
            [resultDic setValue:oldMsgList forKey:RESPONSE_DATA];
            [self notifyUI:resultDic];
        }
    }
    
    if(fetchFromServer) //Fetch from server
    {
        if(!_pendingFetchMsgFlag && [Common isNetworkAvailable] == NETWORK_AVAILABLE)
        {
            NSMutableDictionary *fetchMsgDIc = [[NSMutableDictionary alloc] init];
            [self addCommonData:fetchMsgDIc eventType:FETCH_OLDER_MSG];
            long afterID = -beforeMsgId;//[[dic objectForKey:MSG_ID]longLongValue];
            NSNumber *afterNum = [NSNumber numberWithLong:afterID];
            
            [fetchMsgDIc setValue:afterNum forKey:API_FETCH_AFTER_MSGS_ID];
            
            [fetchMsgDIc setValue:[NSNumber numberWithBool:YES] forKey:API_FETCH_MSG_ACTIVITIES];
            [fetchMsgDIc setValue:[NSNumber numberWithBool:NO] forKey:API_FETCH_OPPONENT_CONTACTIDS];
            
            [fetchMsgDIc setValue:[NSNumber numberWithInt:25] forKey:@"fetch_max_rows"];
            
            /*   if([[dic valueForKey:MSG_TYPE] isEqualToString:@"vb"]) {
             long ivUserId = [appDelegate.confgReader getIVUserId];
             if(ivUserId > 0)
             {
             NSNumber *num = [NSNumber numberWithLong:ivUserId];
             [fetchMsgDIc setValue:num forKey:@"for_iv_user_id"];
             }
             
             } else*/ if ([[dic valueForKey:MSG_TYPE] isEqualToString:@"notes"]) {
                 long ivUserId = [appDelegate.confgReader getIVUserId];
                 if(ivUserId > 0)
                 {
                     NSNumber *num = [NSNumber numberWithLong:ivUserId];
                     [fetchMsgDIc setValue:num forKey:@"for_iv_user_id"];
                 }
                 
             }
             else if([[dic valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE])
             {
                 NSString* fromUserId = [dic valueForKey:FROM_USER_ID];
                 if([fromUserId length]) {
                     [fetchMsgDIc setValue:fromUserId forKeyPath:@"for_contact_id"];
                 }
             }
             else {
                 //CMP
                 NSString* remoteUserType = [_currentChatUser valueForKey:REMOTE_USER_TYPE];
                 if( [ remoteUserType isEqualToString:@"tel"]) {
                     NSString* remoteContactID = [_currentChatUser valueForKey:FROM_USER_ID];
                     if([remoteContactID length]) {
                         [fetchMsgDIc setValue:remoteContactID forKeyPath:@"for_contact_id"];
                     }
                 }
                 //
                 else
                 {
                     if([[dic valueForKey:REMOTE_USER_IV_ID]length])
                     {
                         [fetchMsgDIc setValue:[NSNumber numberWithInt:[[dic valueForKey:REMOTE_USER_IV_ID] intValue]] forKey:@"for_iv_user_id"];
                     }
                     else if([[_currentChatUser valueForKey:REMOTE_USER_IV_ID]length])
                     {
                         [fetchMsgDIc setValue:[NSNumber numberWithInt:[[_currentChatUser valueForKey:REMOTE_USER_IV_ID] intValue]] forKey:@"for_iv_user_id"];
                     }
                     else
                     {
                         NSString* remoteContactID = [_currentChatUser valueForKey:FROM_USER_ID];
                         if([remoteContactID length]) {
                             [fetchMsgDIc setValue:remoteContactID forKeyPath:@"for_contact_id"];
                         }
                     }
                 }
             }
            
            
            NSMutableDictionary *evDic = [[NSMutableDictionary alloc]init];
            [evDic setValue:fetchMsgDIc forKey:REQUEST_DIC];
            [self eventToNetwork:FETCH_OLDER_MSG eventDic:evDic];
            _pendingFetchMsgFlag = TRUE;
            
        } else {
            KLog(@"#### pendingMsgFlag %d, isNetworkAvailable = %d",_pendingFetchMsgFlag,[Common isNetworkAvailable]);
            /* MAR 22, 2017
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:[NSNumber numberWithInt:FETCH_OLDER_MSG] forKey:EVENT_TYPE];
            [dic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
            [self notifyUI:dic];
            */
        }
    }
}

-(int)handleFetchOlderMsgResponse:(NSMutableDictionary*)objDic
{
    _pendingFetchMsgFlag = FALSE;
    int result = FAILURE;
    KLog(@"handleFetchOlderMsgResponse %@",objDic);
    
    NSString *responseCode = [objDic valueForKey:RESPONSE_CODE];
    
    if([responseCode isEqualToString:NET_SUCCESS])
    {
        NSDictionary *respDic = [objDic valueForKey:RESPONSE_DATA];
        NSDictionary *reqstDic = [objDic valueForKey:REQUEST_DIC];
        NSString *status = [respDic valueForKey:@"status"];
        if([status isEqualToString:@"ok"])
        {
            [self processMessageResponseFromServer:respDic forEventType:FETCH_OLDER_MSG requestDic:reqstDic];
            result = SUCCESS;
        }
    }
    
    if(FAILURE==result) {
        EnLogd(@"handleFetchOlderMsgResponse %@",objDic);
        NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
        [resultDic setValue:[NSNumber numberWithInt:FETCH_OLDER_MSG] forKey:EVENT_TYPE];
        [resultDic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
        [self notifyUI:resultDic];
    }
    return result;
}

-(int)handleFetchCelebrityMsgResponse:(NSMutableDictionary*)objDic
{
    KLog(@"handleFetchCelebrityMsgResponse:%@",objDic);
    _pendingFetchCelebMsgFlag = FALSE;
    if(objDic != nil && [objDic count] >0)
    {
        NSString *responseCode = [objDic valueForKey:RESPONSE_CODE];
        NSDictionary *respDic = [objDic valueForKey:RESPONSE_DATA];
        
        if([responseCode isEqualToString:NET_SUCCESS])
        {
            _fetchCelebMsgCount = 0;
            NSString *status = [respDic valueForKey:@"status"];
            if([status isEqualToString:@"ok"])
            {
                NSArray* msgList = [respDic valueForKey:API_BLOG_MSGS];
                if(msgList != nil && [msgList count]>0)
                {
                    [self saveCelebMsgInAppDatabase:msgList];
                    NSNumber *lastBlogId = [respDic valueForKey:API_LAST_BLOG_ID];
                    [appDelegate.confgReader setLastBlogId:[lastBlogId longValue]];
                }
            }
            else
            {
                EnLoge(@"Fetch-vobolos Message Response is not OK");
            }
        }
        else
        {
            if(_fetchCelebMsgCount < MAX_NETWORK_RETRY)
            {
                [self fetchCelebrityMsg:nil];
                _fetchCelebMsgCount++;
            }
            else
                _fetchCelebMsgCount = 0;
            
        }
    }
    return SUCCESS;
}

-(void)processMessageResponseFromServer:(NSDictionary*)respDic forEventType:(int)eventType requestDic:(NSDictionary*)reqstDic
{
    EnLoge(@"processMessageResponseFromServer:eventType = %d,respDic = %@",eventType,respDic);
    KLog(@"processMessageResponseFromServer:eventType = %d,respDic = %@",eventType,respDic);
    
    NSArray* msgList = [respDic valueForKey:API_MSGS];
    NSMutableArray* listOfMsg = Nil;
    
    if(msgList != nil && [msgList count]>0)
    {
        listOfMsg = [self processAndInsertMessageListFromServer:msgList];
        KLog(@"listOfMsg = %@",listOfMsg);
    }
    
    NSMutableDictionary* resDic = [[NSMutableDictionary alloc]initWithDictionary:respDic];
    [self processActivityData:resDic forEventType:eventType];

    switch (eventType) {
        case FORWARD_MSG:
        {
            NSNumber *num = [reqstDic valueForKey:API_MSG_ID];
            NSString *whereClause = [NSString stringWithFormat:@"WHERE %@ = \"%@\"",MSG_ID,num];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:[NSNumber numberWithBool:YES] forKey:MSG_FORWARD];
            if(![_msgTableObj updateTable:dic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE]) {
                EnLoge(@"Error in Message updation");
            }
        }
            break;
            
        case SEND_MC:
        case SEND_MSG:
        case SEND_VOIP_CALL_LOG:
        {
            //update msg local path in returned list
            for(NSMutableDictionary* msg in listOfMsg)
            {
                if([[msg valueForKey:MSG_GUID] isEqualToString:[reqstDic valueForKey:MSG_GUID]])
                {
                    [msg setValue:[reqstDic valueForKey:MSG_LOCAL_PATH] forKey:MSG_LOCAL_PATH];
                    if(![msg valueForKey:DURATION])
                        [msg setValue:[reqstDic valueForKey:DURATION] forKey:DURATION];
                    
                    NSString* fromUserID = [reqstDic valueForKey:FROM_USER_ID];
                    if(fromUserID.length)
                        [msg setValue:fromUserID forKey:FROM_USER_ID];
                    [msg setValue:[reqstDic valueForKey:MSG_READ_CNT] forKey:MSG_READ_CNT];
                }
            }
            
            NSMutableDictionary* sendMsgResp = [[NSMutableDictionary alloc]init];
            if(listOfMsg.count > 0)
                [sendMsgResp setValue:listOfMsg forKey:@"MSG_LIST_FROM_SERVER"];
            if(reqstDic)
                [sendMsgResp setObject:reqstDic forKey:@"MSG_SENT_BY_USER"];
            
            [self refreshChatDataAndNotifyAllUI:NO];
            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
            [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
            [resultDic setValue:sendMsgResp forKey:RESPONSE_DATA];
            [resultDic setValue:[NSNumber numberWithInt:eventType] forKey:EVENT_TYPE];
            if([respDic objectForKey:INSUFFICIENT_CREDITS] != nil)
                [resultDic setValue:[respDic valueForKey:INSUFFICIENT_CREDITS] forKey:INSUFFICIENT_CREDITS];
            [self notifyUI:resultDic];
            
        }
            break;
            
        case FETCH_OLDER_MSG:
        {
            //Fetch it from DB again and send it.
            long beforeMsgId = -([[reqstDic valueForKey:API_FETCH_AFTER_MSGS_ID]integerValue]);
            NSMutableArray* oldMsgList = Nil;
            //if(_currentChatUser)
              //  msgType = [_currentChatUser valueForKey:MSG_TYPE];//TODO identify fetch_msg is for notes
            
            long ivUserID = [[ConfigurationReader sharedConfgReaderObj]getIVUserId];
            long forIvUserID = [[reqstDic valueForKey:@"for_iv_user_id"]longValue];
            
            if(_currentChatUser && ivUserID != forIvUserID)
                oldMsgList = [self getOlderChatBeforeMessageId:beforeMsgId withLimit:0];
            else if([appDelegate.stateMachineObj getCurrentUIType] == NOTES_SCREEN) {
                oldMsgList = [self getOlderNotesBeforeMessageId:beforeMsgId withLimit:0];
            }
            else
                [self refreshChatDataAndNotifyAllUI:NO];
            
            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
            [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
            [resultDic setValue:[NSNumber numberWithInt:FETCH_OLDER_MSG] forKey:EVENT_TYPE];
            if(oldMsgList.count) {
                [resultDic setValue:oldMsgList forKey:RESPONSE_DATA];
                [resultDic setValue:reqstDic forKey:REQUEST_DIC];
            }
            [self notifyUI:resultDic];
        }
            break;
            
#ifdef TRANSCRIPTION_ENABLED
        case VOICE_MESSAGE_TRANSCRIPTION_TEXT:
        {
            NSMutableDictionary* dic = [self updateTranscriptionTextResponse:respDic forRequest:reqstDic];
            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
            [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
            [resultDic setValue:[NSNumber numberWithInt:VOICE_MESSAGE_TRANSCRIPTION_TEXT] forKey:EVENT_TYPE];
            if([dic count]) {
                [resultDic setValue:dic forKey:RESPONSE_DATA];
            }
            [self notifyUI:resultDic];
        }
            break;
#endif
            
        default:
            break;
    }
    
    [self removeHiddenUsersFromSettings:listOfMsg];
    [self updateMsgLocalPathForForwardedMessages:listOfMsg];
    [self updateMsgTableBasedOnContactTable];
    
    if(listOfMsg.count)
    {
        [self createActiveConversation:nil];
        if(eventType == FETCH_MSG || eventType == FORWARD_MSG /*NOV 2017|| eventType == SEND_MSG*/ || eventType == SEND_VOIP_CALL_LOG) {
            [self notifyUiWithData:listOfMsg forEventType:FETCH_MSG];
        } /*else if (eventType == SEND_VOIP_CALL_LOG) {
            [self notifyUiWithData:listOfMsg forEventType:SEND_VOIP_CALL_LOG];
        }*/
    }
    
    NSString *vsmsLimit = [respDic valueForKey:API_VSMS_LIMIT];
    
    //NOV 23, 2016
    BOOL notifyUI = YES;
    for(NSDictionary* aMsg in msgList) {
        NSString* msgSubType = [aMsg valueForKey:API_SUBTYPE];
        if(msgSubType.length && [msgSubType isEqualToString:GROUP_MSG_TYPE]) {
            notifyUI = NO;
        }
    }
    //
    [self saveVsmsLimit:vsmsLimit andNotifyUI:notifyUI];
}

-(NSMutableArray*)processAndInsertMessageListFromServer:(NSArray*)msgList
{
    KLog(@"processAndInsertMessageListFromServer - START");
    
    NSMutableArray *listofMsg = [[NSMutableArray alloc] init];
    BOOL fetchGroupUpdate = NO;
    BOOL isMissedCall = NO;
    BOOL isVoiceMail = NO;
    @autoreleasepool
    {
        for(NSDictionary* msgDic in msgList)
        {
            NSMutableDictionary *newDic = [Conversation getMsgDicForDB:msgDic];
            if(!newDic) continue;
            
            //CMP KLog(@"new = %@",newDic);
            NSString* subType = [newDic valueForKey:MSG_SUB_TYPE];
            NSString* msgFlow = [newDic valueForKey:MSG_FLOW];
            if([subType isEqualToString:RING_MC] && [msgFlow isEqualToString:MSG_FLOW_S]) {
                [newDic setValue:RING_MC_REQUESTED forKey:MSG_CONTENT];
                isMissedCall = YES;
                
                NSNumber *requestedTime = [newDic valueForKey:MSG_DATE];
                long long requestedTimeInMilliseconds = [requestedTime longLongValue];
                if(requestedTimeInMilliseconds <= 0) {
                    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
                    requestedTime = [NSNumber numberWithLongLong:milliseconds];
                }
            }
            //Ignore location shared message
            /*NSString* msgContent = [[newDic valueForKey:MSG_CONTENT]lowercaseString];
              if([msgContent isEqualToString:@"locationshared"])
                 continue;
             */
            if(subType && [subType isEqualToString:@"loc_share"])
                continue;
            //
            
            if(subType && [subType isEqualToString:GROUP_MSG_EVENT_TYPE]) {
                fetchGroupUpdate = YES;
                /*
                //- If "send_text" is modified to not to send "leave" message, the following is not required
                NSString* msgContent = [newDic valueForKey:MSG_CONTENT];
                NSMutableDictionary *msgContentDic = [Common convertStringJsonToDictionaryJson:msgContent];
                if(msgContentDic && [msgContentDic count]) {
                    NSString* eventType = [msgContentDic valueForKey:EVENT_TYPE];
                    if([eventType isEqualToString:@"left"]) {
                        [self leaveGroup:newDic];
                    }
                }
                */
            }
            
#ifdef REACHME_APP
            if(![self IsValidMessage:newDic]) {
                continue;
            }
#endif
            
            NSString* msgType = [newDic valueForKey:MSG_TYPE];
            [listofMsg addObject:newDic];
            
            NSString* msgContentType = [newDic valueForKey:MSG_CONTENT_TYPE];
            if([msgFlow isEqualToString:MSG_FLOW_R]) {
                if([msgType isEqualToString:MISSCALL]) {
                    isMissedCall = YES;
                    [self updateMissedCallReason:newDic];
                }
                else if([msgType isEqualToString:VSMS_TYPE] && [msgContentType isEqualToString:AUDIO_TYPE]) {
                     [self updateMissedCallReason:newDic];
                    isVoiceMail = YES;
                }
                
                if([msgContentType isEqualToString:AUDIO_TYPE]) {
                    //- download the audio msg
                    //[newDic setValue:API_DOWNLOAD_INPROGRESS forKey:MSG_STATE];
                    NSMutableDictionary *reqDic =[[NSMutableDictionary alloc]initWithDictionary:newDic];
                    [appDelegate.engObj downloadVoiceMsg:reqDic];
                }
            }
        }
    }
    
    for (NSMutableDictionary* dic in listofMsg) {
        
        NSMutableDictionary* theMsgDic = [[NSMutableDictionary alloc]init];
        if( [self isMessageAvailable:dic OutMessage:theMsgDic] ) {
            NSString* msgType = [dic valueForKey:MSG_TYPE];
            if([msgType isEqualToString:VOIP_TYPE]) {
                [dic setValue:[NSNumber numberWithInt:1] forKey:MSG_READ_CNT];
            } else {
                [dic removeObjectForKey:MSG_READ_CNT];
            }
            
            NSMutableDictionary* newDic = [[NSMutableDictionary alloc]initWithDictionary:dic];
            
            /*DEBUG NOV 2017
            NSString* msgID = [theMsgDic valueForKey:MSG_ID];
            NSString* msgGUID = [theMsgDic valueForKey:MSG_GUID];
            */
            
            NSString *whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\" OR %@ = \"%@\"",
                                     MSG_ID,[newDic valueForKey:MSG_ID],MSG_GUID,[newDic valueForKey:MSG_GUID]];
            if(![_msgTableObj updateTable:newDic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE]) {
                KLog(@"Error in Message update. %@",[newDic valueForKey:MSG_ID]);
                EnLogd(@"Error in Message update. %@",[newDic valueForKey:MSG_ID]);
            } else {
                KLog(@"Message updated. %@. dic = %@",[newDic valueForKey:MSG_ID],newDic);
                EnLogd(@"Message updated. %@", [newDic valueForKey:MSG_ID]);
            }
        }
        else {
            NSString* msgType = [dic valueForKey:MSG_TYPE];
            if([msgType isEqualToString:VOIP_TYPE] || [msgType isEqualToString:VOIP_OUT]) {
                [dic setValue:[NSNumber numberWithInt:1] forKey:MSG_READ_CNT];
            }
            if([[dic valueForKey:ANNOTATION] length]) {
                KLog(@"transcription = %@",[dic valueForKey:ANNOTATION]);
            }
            NSMutableArray* aMsg = [[NSMutableArray alloc]initWithObjects:dic, nil];
            if(![_msgTableObj insertInTable:aMsg tableType:MESSAGE_TABLE_TYPE]) {
                KLog(@"Error in message insertion:%@",[dic valueForKey:MSG_ID]);
                EnLogd(@"Error in message insertion:%@",[dic valueForKey:MSG_ID]);
            } else {
                KLog(@"Message inserted. %@",[dic valueForKey:MSG_ID]);
                EnLogd(@"Message inserted. %@", [dic valueForKey:MSG_ID]);
            }
        }
    }
    
    KLog(@"processAndInsertMessageListFromServer - END");
    
    if(isMissedCall)
        [self createMissedCallList];
    if(isVoiceMail)
        [self createVoicemailList];
    
    if(fetchGroupUpdate) {
        KLog(@"update group member info");
        [self updateGroupMemberInfoFromServerInMainThread];
    }
    
    return listofMsg;
}

#ifdef TRANSCRIPTION_ENABLED

/*
 The following macro definitions (which are used in image message) are redefined used for audio and voicemail messages to store transcription details.
  MSG_SIZE_LONG (== "MSG_SIZE") - transcription rating - MSG_TRANS_RATING
  ANNOTATION (== "ANNOTATION") - transcription text - MSG_TRANS_TEXT
  CROP_REMOTE_USER_PIC (== "CROP_REMOTE_USER_PIC") transcription status - MSG_TRANS_STATUS
 */
- (NSMutableDictionary*) updateTranscriptionTextResponse:(NSDictionary *)respDic forRequest:(NSDictionary*)reqDic
{
    NSMutableDictionary* res = nil;
    NSString* whereClause = nil;
    
    if ([respDic valueForKey:@"transcription_rating"] > 0 && [[respDic valueForKey:@"cmd"] isEqualToString:@"trans_msg_rate"]) {
        long transMsgId  = [[respDic valueForKey:@"msg_id"] longLongValue];
        NSString *msgID = nil;
        if(transMsgId>0)
            msgID = [[NSNumber numberWithLong:transMsgId] stringValue];
        
        if (msgID.length) {
            whereClause = [[NSString alloc] initWithFormat:@"WHERE MSG_ID = \"%@\"",msgID];
            
            NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
            [newDic setValue:[respDic valueForKey:@"transcription_rating"] forKey:MSG_TRANS_RATING];
            
            if(![_msgTableObj updateTable:newDic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE])
            {
                EnLoge(@"Error in Messaege Updation");
            } else {
                [newDic setObject:msgID forKey:MSG_ID];
                res = [[NSMutableDictionary alloc]initWithDictionary:newDic];
            }
        }
    }else{
        NSString *transStatus = [respDic valueForKey:@"trans_status"];
        NSString *score;
        NSString *transText;
        NSString *transScoreAndText;
        if ([transStatus isEqualToString:@"q"] || [transStatus isEqualToString:@"e"] || [transStatus isEqualToString:@"api_error"]) {
            transScoreAndText = @"";
        }else if ([transStatus isEqualToString:@"c"]){
            score = [[respDic valueForKey:@"score"] stringValue];
            transText = [respDic valueForKey:@"trans_text"];
            transScoreAndText = [NSString stringWithFormat:@"Transcription confidence: %@\n%@",score,transText];
        }
        
        long transMsgId  = [[respDic valueForKey:@"msg_id"] longLongValue];
        NSString *msgID = nil;
        if(transMsgId>0)
            msgID = [[NSNumber numberWithLong:transMsgId] stringValue];
        else
            msgID = [[reqDic valueForKey:@"msg_id"]stringValue];
        
        if (msgID.length) {
            whereClause = [[NSString alloc] initWithFormat:@"WHERE MSG_ID = \"%@\"",msgID];
            
            NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
            [newDic setValue:transScoreAndText forKey:MSG_TRANS_TEXT];
            [newDic setValue:transStatus forKey:MSG_TRANS_STATUS];
            
            if(![_msgTableObj updateTable:newDic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE])
            {
                EnLoge(@"Error in Messaege Updation");
            } else {
                [newDic setObject:msgID forKey:MSG_ID];
                res = [[NSMutableDictionary alloc]initWithDictionary:newDic];
            }
        }
    }
    
    if(res.count) {
        NSMutableArray *arr = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:nil tableType:MESSAGE_TABLE_TYPE];
        if(arr.count) {
            NSDictionary* dic = [arr objectAtIndex:0];
            if(dic.count) {
                [res setObject:[dic valueForKey:MSG_DATE] forKey:MSG_DATE];
            }
        }
    }
    return res;
}
#endif

/*
 MISSED_CALL_REASON = Dictionary of  {
    "phone_number1" = "reason"
    "pheon_number2" = "reason"
 }
 phone_number1, phone_number2 are primary and secondary numbers.
 reason is the text present in the missed call message of fetch_msgs, and MQTT and push notifications.
 */
-(void)updateMissedCallReason:(NSMutableDictionary*)dic
{
#ifdef REACHME_APP
    KLog(@"updateMissedCallReason:%@",dic);
    NSString* nativeContactId = [dic valueForKey:NATIVE_CONTACT_ID];
    NSString* reason = [dic valueForKey:API_MISSEDCALL_REASON];
    KLog(@"NATIVE_CONTACT_ID: %@",nativeContactId);
    KLog(@"reason: %@",reason);
    NSMutableDictionary* mcReasonDic = [[[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:MISSED_CALL_REASON]mutableCopy];
    KLog(@"MISSED_CALL_REASON: %@",mcReasonDic);
    if(!mcReasonDic)
        mcReasonDic = [[NSMutableDictionary alloc]init];
    
    if(nativeContactId.length && reason.length && ![reason isEqualToString:@"p2p"]) {
        [mcReasonDic setValue:reason forKey:nativeContactId];
        [[ConfigurationReader sharedConfgReaderObj]setObject:mcReasonDic forTheKey:MISSED_CALL_REASON];
        [[ConfigurationReader sharedConfgReaderObj] setMissedCallReasonForNumber:nativeContactId shouldUpdate:YES];
        if (isPushNotification) {
            [self updateCarrierSettingsForMisscallReason:reason phoneNumber:nativeContactId];
        }
        KLog(@"MISSED_CALL_REASON: %@",mcReasonDic);
    }
    
    /*DEBUG
    NSString* reasonTest = [[ConfigurationReader sharedConfgReaderObj]getMissedCallReasonForTheNumber:@"19089928362"];
    KLog(@"reason = %@", reasonTest);
    */
#endif
}

#ifdef REACHME_APP
- (void)updateCarrierSettingsForMisscallReason:(NSString *)activeString phoneNumber:(NSString *)phoneNumber
{
    UserProfileModel *model = [[Profile sharedUserProfile]profileData];
    BOOL isReachMeNumber = NO;
    for (NSDictionary *numberInfo in model.additionalVerifiedNumbers) {
        if ([[numberInfo valueForKey:@"contact_id"] isEqualToString:phoneNumber]) {
            isReachMeNumber = [[numberInfo valueForKey:@"is_virtual"] boolValue];
        }
    }
    
    if(isReachMeNumber)
    {
        return;
    }
    
    SettingModel *currentSettingsModel = [Setting sharedSetting].data;
    VoiceMailInfo *currentVoiceMailInfo;
    if (currentSettingsModel) {
        if (currentSettingsModel.voiceMailInfo && [currentSettingsModel.voiceMailInfo count]) {
            for (VoiceMailInfo *voiceMailInfo in currentSettingsModel.voiceMailInfo) {
                if([voiceMailInfo.phoneNumber isEqualToString:phoneNumber]) {
                    currentVoiceMailInfo = voiceMailInfo;
                }
            }
            
        }
    }
    
    CarrierInfo *carrierDetails = [[Setting sharedSetting]customCarrierInfoForPhoneNumber:phoneNumber];
    
    if ([activeString isEqualToString:@"unconditional"] && !carrierDetails.isReachMeIntlActive) {
        [self fireLocalNotification:phoneNumber rmSwitchType:@"unconditional"];
    } else if (![activeString isEqualToString:@"unconditional"] && !carrierDetails.isReachMeHomeActive){
        [self fireLocalNotification:phoneNumber rmSwitchType:@"busy"];
    }
    
    CarrierInfo *currentCarrierInfo = [[CarrierInfo alloc]init];
    currentCarrierInfo.phoneNumber = phoneNumber;
    if(carrierDetails) {
        currentCarrierInfo.countryCode = carrierDetails.countryCode;
        currentCarrierInfo.networkId = carrierDetails.networkId;
        currentCarrierInfo.vSMSId = carrierDetails.vSMSId;
        if([activeString isEqualToString:@"unconditional"]){
            currentCarrierInfo.isReachMeIntlActive = YES;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = NO;
        }else if (currentVoiceMailInfo.reachMeHome){
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = YES;
            currentCarrierInfo.isReachMeVMActive = NO;
        }else{
            currentCarrierInfo.isReachMeIntlActive = NO;
            currentCarrierInfo.isReachMeHomeActive = NO;
            currentCarrierInfo.isReachMeVMActive = YES;
        }
    }
    [[Setting sharedSetting]updateCarrierSettingsInfo:currentCarrierInfo];
    
}

- (void)fireLocalNotification:(NSString *)phoneNumber rmSwitchType:(NSString *)rmType
{
    NSString *notificationInfo = @"";
    if ([rmType isEqualToString:@"unconditional"]) {
        notificationInfo = [NSString stringWithFormat:@"ReachMe International is active on %@",[Common getFormattedNumber:phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
    }else{
        notificationInfo = [NSString stringWithFormat:@"ReachMe Home is active on %@",[Common getFormattedNumber:phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES]];
    }
    
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"ACTIVATION SUCCESSFULL" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:notificationInfo
                                                         arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"rm_switch",@"notification_type", nil];
    content.userInfo = userInfo;
    
    // Deliver the notification in five seconds.
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:5 repeats:NO];
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                                                          content:content trigger:trigger];
    
    // Schedule the notification.
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:nil];
}

#endif

-(void)updateSentMessageFromResponse:(NSMutableArray*)responseList forRequest:(NSMutableDictionary*)requestDic
{
    NSString* guid = [requestDic valueForKey:MSG_GUID];
    NSArray* filteredList = [responseList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.MSG_GUID = %@",guid]];
    if(filteredList.count)
    {
        NSString *whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\"",MSG_GUID,guid];
        if(![_msgTableObj updateTable:filteredList[0] whereClause:whereClause tableType:MESSAGE_TABLE_TYPE]) {
            EnLoge(@"Error in Message updation");
        } else {
            KLog(@"Message updated:%@, dic = %@",[filteredList[0] valueForKey:MSG_ID],filteredList[0]);
        }
    }
    
}

-(void)notifyUiWithData:(NSMutableArray*)listofMsg forEventType:(int)eventType
{
    //- Notify UI for fetch older message or fetch message
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
    
    if([appDelegate.stateMachineObj getCurrentUIType] == CHAT_GRID_SCREEN || [appDelegate.stateMachineObj getCurrentUIType] == MENU_SCREEN ) {
        [resultDic setValue:[NSNumber numberWithInt:GET_ACTIVE_CONVERSATION_LIST] forKey:EVENT_TYPE];
    }
    else{
        [resultDic setValue:[NSNumber numberWithInt:eventType] forKey:EVENT_TYPE];
        if(listofMsg.count)
            [resultDic setValue:listofMsg forKey:RESPONSE_DATA];
    }
    [self notifyUI:resultDic];
    
    [NSNotificationCenter.defaultCenter postNotificationName:kChatsUpdateEvent object:self userInfo:resultDic];
}


-(void)saveCelebMsgInAppDatabase:(NSArray*)msgList
{
    KLog(@"Save celeb msgs in DB - START");
    
    NSMutableArray *listofMsg = [[NSMutableArray alloc] init];
    for(NSDictionary* msgDic in msgList)
    {
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
        [newDic setValue:[appDelegate.confgReader getLoginId] forKey:LOGGEDIN_USER_ID];
        [newDic setValue:[[msgDic valueForKey:API_FROM_BLOGGER_ID]stringValue]  forKey:FROM_USER_ID];
        [newDic setValue:[[msgDic valueForKey:API_FROM_BLOGGER_ID]stringValue]  forKey:REMOTE_USER_IV_ID];
        [newDic setValue:[msgDic valueForKey:API_BLOGGER_DISPLAY_NAME] forKey:REMOTE_USER_NAME];
        [newDic setValue:[msgDic valueForKey:API_PIC_URI] forKey:REMOTE_USER_PIC];
        [newDic setValue:[msgDic valueForKey:API_CONTENT_TYPE] forKey:MSG_CONTENT_TYPE];
        //[newDic setValue:[msgDic valueForKey:API_MSG_FLOW] forKey:MSG_FLOW];
        [newDic setValue:MSG_FLOW_R forKey:MSG_FLOW];
        [newDic setValue:[msgDic valueForKey:API_MSG_ID] forKey:MSG_ID];
        [newDic setValue:CELEBRITY_TYPE forKey:MSG_TYPE];
        [newDic setValue:[msgDic valueForKey:API_MSG_CONTENT] forKey:MSG_CONTENT];
        [newDic setValue:[msgDic valueForKey:API_MSG_DT] forKey:MSG_DATE];
        [newDic setValue:[msgDic valueForKey:API_DURATION] forKey:DURATION];
        [newDic setValue:CELEBRITY_TYPE forKey:REMOTE_USER_TYPE];
        
        //MAY 26, 2016
        //Server will not give "msg_read_cnt" field.
        [newDic setValue:[NSNumber numberWithBool:NO] forKey:MSG_READ_CNT];
        //
        
        //Ignore location shared message
        /*
        NSString* msgContent = [[newDic valueForKey:MSG_CONTENT]lowercaseString];
        if([msgContent isEqualToString:@"locationshared"])
            continue;
        */
        NSString* subType = [msgDic valueForKey:API_MSG_CONTENT_TYPE];
        if(subType && [subType isEqualToString:@"loc_share"])
            continue;
        //
        
        //TODO: CMP check FEB 17
        NSString* bloggerID = [newDic valueForKey:FROM_USER_ID];
        if(bloggerID.length) {
            NSString* phoneNumber = [self getPhonenumber:bloggerID];//TODO crash
            if(phoneNumber.length > 0)
            {
                [newDic setValue:phoneNumber forKey:FROM_USER_ID];
            }
        }
        //
        
        if([msgDic valueForKey:API_MEDIA_FORMAT] != nil)
        {
            [newDic setValue:[msgDic valueForKey:API_MEDIA_FORMAT] forKey:MEDIA_FORMAT];
        }
        else
        {
            [newDic setValue:@"" forKey:MEDIA_FORMAT];
        }
        
        if([[newDic valueForKey:MSG_CONTENT_TYPE]isEqualToString:IMAGE_TYPE])
        {
            NSString* msgLocalPath = [[newDic valueForKey:MSG_ID] stringValue];
            [newDic setValue:msgLocalPath forKey:MSG_LOCAL_PATH];
        }
        
        if([msgDic valueForKey:API_ANNOTATION] != nil)
        {
            [newDic setValue:[msgDic valueForKey:API_ANNOTATION] forKey:ANNOTATION];
        }
        else
        {
            [newDic setValue:@"" forKey:ANNOTATION];
        }
        
        /* Need to visit again-- Celebrity msg will not have GUID
         if([msgDic valueForKey:MSG_GUID] == nil) {
         [newDic setValue:[msgDic valueForKey:MSG_ID] forKey:MSG_GUID];
         }*/
        
        EnLogd(@"new celeb dic: %@",newDic);
        
        [listofMsg addObject:newDic];
    }
    
    for (NSMutableDictionary* dic in listofMsg) {
        if( [self isMessageAvailable:dic OutMessage:nil] ) {
            NSString *whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\"",MSG_ID,[dic valueForKey:MSG_ID]];
            if(![_msgTableObj updateTable:dic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE]) {
                EnLoge(@"Error in Message update");
                KLog(@"Error in Message update. %@",[dic valueForKey:MSG_ID]);
            } else {
                KLog(@"Celeb message updated. %@",[dic valueForKey:MSG_ID]);
            }
        }
        else {
            NSMutableArray* aMsg = [[NSMutableArray alloc]initWithObjects:dic, nil];
            if(![_msgTableObj insertInTable:aMsg tableType:MESSAGE_TABLE_TYPE]) {
                EnLoge(@"Error in Message Insertion");
                KLog(@"Error in message insertion:%@",[dic valueForKey:MSG_ID]);
            } else {
                KLog(@"Celeb message inserted. %@",[dic valueForKey:MSG_ID]);
            }
        }
    }
    
    [self removeHiddenUsersFromSettings:listofMsg];
    NSMutableArray *msgs = [self getUniqueConversation];
    [self insertCelebrityContactInMainThread:msgs];
    
    [self createActiveConversation:nil];

    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
    
    if([appDelegate.stateMachineObj getCurrentUIType] == CHAT_GRID_SCREEN || [appDelegate.stateMachineObj getCurrentUIType] == MENU_SCREEN) {
        [resultDic setValue:[NSNumber numberWithInt:GET_ACTIVE_CONVERSATION_LIST] forKey:EVENT_TYPE];
    }
    else{
        [resultDic setValue:[NSNumber numberWithInt:FETCH_MSG] forKey:EVENT_TYPE];
        [resultDic setValue:listofMsg forKey:RESPONSE_DATA];
    }
    [self notifyUI:resultDic];
    
    KLog(@"Save celeb msgs in DB - END"); //JUNE 10, 2016
}

+(BOOL)needToSave:(NSDictionary*)dic {
    /* When VOIP outgoing call is cancelled at the caller side, server sends MC message to both the caller and callee.
       Is this MC message should be shown at the callee side and not be shown at the caller side? NOT CLEAR.
       Also callee receives rejected voip_out message. Should it be shown? NOT CLEAR.
       Right, I am not saving MC message at the caller side and MC & rejected voip_out messages at the caller side.
       DO NOT CALL THIS METHOD IF THOSE MESSAGES SHOULD BE PROCESSED.
     */
    
    NSString* msgSubType = [dic valueForKey:API_SUBTYPE];
    NSString* msgType = [dic valueForKey:API_MSG_TYPE];
    NSString* missedCallReason = [dic valueForKey:API_MISSEDCALL_REASON];
    NSString* msgFlow = [dic valueForKey:API_MSG_FLOW];
    
    if([msgType isEqualToString:MISSCALL] && [msgSubType isEqualToString:AVS_TYPE]) {
        if([msgFlow isEqualToString:MSG_FLOW_S] && [missedCallReason isEqualToString:@"p2p"]) {
            return NO;
        }
    } else if([msgType isEqualToString:VOIP_OUT] && [msgSubType isEqualToString:VOIP_TYPE]) {
        NSString* msgGUID = [dic valueForKey:API_GUID];
        if([msgFlow isEqualToString:MSG_FLOW_R] && [msgGUID containsString:VOIP_CALL_REJECTED]) {
            return NO;
        }
    }
    return YES;
}

+(NSMutableDictionary*)getMsgDicForDB:(NSDictionary*)dic
{
    if(![self needToSave:dic]) {
        return nil;
    }
    
    //Native contact id will be set to phone number of the message sender in case of group message.
    //In case of misscall/avs it will be set to the number from which misscall/avs has been received.
    NSMutableDictionary *newDic = nil;
    if(dic != nil && [dic count] >0)
    {
        /*
        if([[dic valueForKey:API_MSG_ID]integerValue] == 3999740) {
            KLog(@"Debug");
        }*/
        
        NSString* voipType = [dic valueForKey:API_TYPE];
#ifndef REACHME_APP
        if([voipType isEqualToString:VOIP_TYPE] || [voipType isEqualToString:VOIP_OUT])
            return nil;
#endif
        
        NSString* msgSubType = [dic valueForKey:API_SUBTYPE];
        NSString* msgType = [dic valueForKey:API_MSG_TYPE];
        NSString* missedCallReason = [dic valueForKey:API_MISSEDCALL_REASON];
        NSString* msgFlow = [dic valueForKey:API_MSG_FLOW];
        
        newDic = [[NSMutableDictionary alloc] init];
        [newDic setValue:msgType forKey:MSG_TYPE];
        if([voipType isEqualToString:VOIP_OUT]) {
            
            //- ignore app-to-gsm call message at the receiver side. TODO: Ideally, server should not send this message to client.
            if([msgSubType isEqualToString:SUBTYPE_GSM] && [msgFlow isEqualToString:MSG_FLOW_R]) {
                EnLogd(@"Ignore app-to-gsm msg");
                return nil;
            }
            
            [newDic setValue:[dic valueForKey:@"from_phone_num"] forKey:NATIVE_CONTACT_ID];
            NSString* jsHeader = [dic valueForKey:API_HEADER];
            NSError* error=nil;
            NSData* jsData = [jsHeader dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* header = [NSJSONSerialization JSONObjectWithData:jsData options:0 error:&error];
            if(header) {
                NSString* status = [header valueForKey:API_STATUS];
                if(status.length)
                   [newDic setValue:status forKey:MSG_CONTENT];
            }
            KLog(@"Debug");
        }
        
        //- Find if response dic contains the iv id of the contact to which the message was sent to ( as non-iv)
        NSMutableArray* fromContactIds = [dic valueForKey:API_CONTACT_IDS];
        BOOL bContactIDsChanged = [[dic valueForKey:API_CONTACT_IDS_CHANGED]boolValue];
        if(bContactIDsChanged)
        {
            for(NSDictionary* contactDic in fromContactIds)
            {
                NSString* phoneNumber = [contactDic valueForKey:API_CONTACT_ID];
                if(phoneNumber.length)
                {
                    if([phoneNumber longLongValue] == [[ConfigurationReader sharedConfgReaderObj]getIVUserId])
                        continue;//mine
                    
                    //CMP NSString* msgSubType = [dic valueForKey:API_SUBTYPE];
                    NSString* msgContentType = [dic valueForKey:@"msg_content_type"];
                    
                    if( msgSubType && [msgSubType isEqualToString:AVS_TYPE] && [msgContentType isEqualToString:@"t"])
                        [newDic setValue:@"mc" forKey:MSG_TYPE];
                    else if( msgSubType && [msgSubType isEqualToString:RING_MC] && [msgContentType isEqualToString:@"t"])
                        [newDic setValue:@"mc" forKey:MSG_TYPE];
                    else if (msgSubType && [msgSubType isEqualToString:AVS_TYPE] && [msgContentType isEqualToString:@"a"])
                        [newDic setValue:@"vsms" forKey:MSG_TYPE];
                    else if (msgSubType && [msgSubType isEqualToString:VSMS_TYPE] && [msgContentType isEqualToString:@"a"])
                        [newDic setValue:@"vsms" forKey:MSG_TYPE];
                }
            }
        }
        else
        {
            //CMP TODO - Revisit again
            //NSString* msgFlow = [dic valueForKey:API_MSG_FLOW];
            
            for(NSDictionary* contactDic in fromContactIds)
            {
                NSString* remoteUserId = [contactDic valueForKey:API_CONTACT];
                if([remoteUserId length])
                {
                    NSString* contactType = [contactDic valueForKey:API_TYPE];
                    if([contactType isEqualToString:IV_TYPE])
                    {
                        if([remoteUserId longLongValue] == [[ConfigurationReader sharedConfgReaderObj]getIVUserId])
                            continue;//mine
                        else
                        {
                            NSString* msgContentType = [dic valueForKey:MSG_CONTENT_TYPE];
                            if( msgSubType && [msgSubType isEqualToString:AVS_TYPE] && [msgContentType isEqualToString:@"t"])
                                [newDic setValue:@"mc" forKey:MSG_TYPE];
                            else if (msgSubType && [msgSubType isEqualToString:AVS_TYPE] && [msgContentType isEqualToString:@"a"])
                                [newDic setValue:@"vsms" forKey:MSG_TYPE];
                        }
                    }
                    else
                    {
                        if( [msgFlow isEqualToString:MSG_FLOW_S]) {
                            if([msgSubType isEqualToString:RING_MC])
                                [newDic setValue:MISSCALL forKey:MSG_TYPE];
                            else if ([msgSubType isEqualToString:SUBTYPE_GSM]);
                            else
                                [newDic setValue:VSMS_TYPE forKey:MSG_TYPE];
                        }
                        else
                            [newDic setValue:[dic valueForKey:API_TYPE] forKey:MSG_TYPE];
                    }
                }
            }
        }
        //
        //NSString *msgType = [dic valueForKey:API_MSG_TYPE];
        //NSString *msgFlow = [dic valueForKey:API_MSG_FLOW];
        [newDic setValue:msgFlow forKey:MSG_FLOW];
        if([msgType isEqualToString:VB_TYPE] || [msgType isEqualToString:NOTES_TYPE] || [msgType isEqualToString:INV_TYPE])
        {
            [newDic setValue:@"" forKey:FROM_USER_ID];
            [newDic setValue:@"" forKey:REMOTE_USER_IV_ID];
            [newDic setValue:@"" forKey:REMOTE_USER_PIC];
            [newDic setValue:@"" forKey:REMOTE_USER_TYPE];
        }
        else if([msgFlow isEqualToString:MSG_FLOW_S] || [msgFlow isEqualToString:MSG_FLOW_R])
        {
            NSArray *fromContactIds = [dic valueForKey:API_CONTACT_IDS];
            for (NSDictionary *fromContactDic in fromContactIds)
            {
                NSString *ividStr = [[NSString alloc] initWithFormat:@"%ld",[[ConfigurationReader sharedConfgReaderObj] getIVUserId]];
                NSString *contactId = [fromContactDic valueForKey:API_CONTACT];
                if(![contactId isEqualToString:ividStr])
                {
                    NSString *contactType = [fromContactDic valueForKey:API_TYPE];
                    if([contactType isEqualToString:IV_TYPE])
                    {
                        [newDic setValue:contactId forKey:REMOTE_USER_IV_ID];
                        [newDic setValue:contactType forKey:REMOTE_USER_TYPE];
                    }
                    else
                    {
                        [newDic setValue:contactId forKey:FROM_USER_ID];
                        [newDic setValue:@"" forKey:REMOTE_USER_IV_ID];
                        [newDic setValue:contactType forKey:REMOTE_USER_TYPE];
                    }
                }
            }
        }
        
        if([msgFlow isEqualToString:MSG_FLOW_R])
        {
            NSString* fromUserId = [dic valueForKey:API_FROM_PHONE_NUM];
            if(fromUserId.length)
                [newDic setValue:fromUserId forKey:FROM_USER_ID];
            else
            {
                NSArray *senderCntIds = [dic valueForKey:API_SENDER_CONTACT_IDS];
                if(senderCntIds != nil && [senderCntIds count])
                {
                    NSMutableDictionary *contactDic = [senderCntIds objectAtIndex:0];
                    NSString* sContactId = [contactDic valueForKey:API_CONTACT];
                    if(sContactId.length) {
                        [newDic setValue:sContactId forKey:FROM_USER_ID];
                    }
                }
            }
            //NSString* reason = [dic valueForKey:API_MISSEDCALL_REASON];
            if(missedCallReason.length) {
                [newDic setValue:missedCallReason forKey:API_MISSEDCALL_REASON];
            }
        }
        else
        {
            NSArray *recipientCntIds = [dic valueForKey:API_RECIPIENT_CONTACT_IDS];
            if(recipientCntIds != nil && [recipientCntIds count]>0)
            {
                NSMutableDictionary *contactDic = [recipientCntIds objectAtIndex:0];
                NSString* sContactId = [contactDic valueForKey:API_CONTACT];
                if(sContactId.length) {
                    [newDic setValue:sContactId forKey:FROM_USER_ID];
                }
                else {
                    EnLoge(@"ERROR: FROM_USER_ID is null");
                }
            }
        }
        
        //Group message handling
        //CMP NSString* msgSubType = [dic valueForKey:API_SUBTYPE];
        [newDic setValue:msgSubType forKey:MSG_SUB_TYPE];
        [newDic setValue:@"" forKey:CONVERSATION_TYPE];
        if(msgSubType != Nil && ([msgSubType isEqualToString:GROUP_MSG_TYPE] || [msgSubType isEqualToString:GROUP_MSG_EVENT_TYPE]||
                                 [msgSubType isEqualToString:@"loc_share"]))
        {
            //Set native contact id as the phone number of user sending the message.
            NSString* fromPhoneNum = [dic valueForKey:API_FROM_PHONE_NUM];
            if(fromPhoneNum.length)
                [newDic setValue:fromPhoneNum forKey:NATIVE_CONTACT_ID];
            
            NSArray *fromContactIds = [dic valueForKey:API_CONTACT_IDS];
            for(NSDictionary* contactDicData in fromContactIds)
            {
                if([[contactDicData valueForKey:API_TYPE] isEqualToString:GROUP_TYPE])
                {
                    [newDic setValue:[contactDicData valueForKey:API_CONTACT] forKey:FROM_USER_ID];
                    [newDic setValue:@"0" forKey:REMOTE_USER_IV_ID];
                    [newDic setValue:GROUP_TYPE forKey:CONVERSATION_TYPE];
                }
                else
                {
                    [newDic setValue:[contactDicData valueForKey:API_TYPE] forKey:REMOTE_USER_TYPE];
                    [newDic setValue:[contactDicData valueForKey:API_TYPE] forKey:MSG_TYPE];
                }
            }
        }
        
        //CMP
        if([dic valueForKey:API_DURATION] != nil)
            [newDic setValue:[dic valueForKey:API_DURATION] forKey:DURATION];
        else
            [newDic setValue:[NSNumber numberWithInt:0] forKey:DURATION];
        //
        
        //Missed call and AVS handling
        NSString* type = [dic valueForKey:API_TYPE];
        if(([msgSubType isEqualToString:AVS_TYPE] || [msgSubType isEqualToString:VSMS_TYPE] ||
            [msgSubType isEqualToString:RING_MC] || [msgSubType isEqualToString:VOIP_CALL_ACCEPTED] ||
            [msgSubType isEqualToString:VOIP_TYPE] || [msgSubType isEqualToString:SUBTYPE_GSM]) &&
           ([type isEqualToString:VSMS_TYPE] || [type isEqualToString:MISSCALL] ||
            [type isEqualToString:VOIP_TYPE] || [type isEqualToString:VOIP_OUT]))
        {
            NSArray *fromContactIds = [dic valueForKey:API_CONTACT_IDS];
            NSString *myIvId = [[NSString alloc] initWithFormat:@"%ld",[[ConfigurationReader sharedConfgReaderObj] getIVUserId]];
            for (NSDictionary *contactDic in fromContactIds)
            {
                NSString* contactType = [contactDic valueForKey:API_TYPE];
                NSString* ivUserId = @"";
                NSString* phoneNumber = @"";
                if([contactType isEqualToString:IV_TYPE])
                {
                    ivUserId = [contactDic valueForKey:API_CONTACT];
                    phoneNumber = [contactDic valueForKey:API_CONTACT_ID];
                }
                else
                {
                    phoneNumber = [contactDic valueForKey:API_CONTACT];
                }
                if([ivUserId isEqualToString:myIvId])
                {
                    //Mine -- set it to native contact
                    [newDic setValue:phoneNumber forKey:NATIVE_CONTACT_ID];
                }
                else
                {
                    //Others -- set it to from user id
                    if(phoneNumber.length)
                        [newDic setValue:phoneNumber forKey:FROM_USER_ID];
                }
            }
        }
        
        if([dic valueForKey:API_SENDER_ID])
            [newDic setValue:[dic valueForKey:API_SENDER_ID] forKey:REMOTE_USER_NAME];
        [newDic setValue:[[ConfigurationReader sharedConfgReaderObj] getLoginId] forKey:LOGGEDIN_USER_ID];
        [newDic setValue:[dic valueForKey:API_MSG_ID] forKey:MSG_ID];
        [newDic setValue:[dic valueForKey:API_GUID] forKey:MSG_GUID];
        [newDic setValue:[dic valueForKey:API_MSG_DT] forKey:MSG_DATE];
        [newDic setValue:[dic valueForKey:API_SOURCE_APP_TYPE] forKey:SOURCE_APP_TYPE];
        
        [newDic setValue:[dic valueForKey:API_CONTENT_TYPE] forKey:MSG_CONTENT_TYPE];
        if([[newDic valueForKey:MSG_CONTENT_TYPE]isEqualToString:IMAGE_TYPE])
        {
            if([msgFlow isEqualToString:MSG_FLOW_R])//MAY 2017 TODO: test
            {
                NSString* msgLocalPath = [[newDic valueForKey:MSG_ID] stringValue];
                [newDic setValue:msgLocalPath forKey:MSG_LOCAL_PATH];
            }
        }
        
        [newDic setValue:API_DELIVERED forKey:MSG_STATE];
        
        if([dic valueForKey:API_IS_MSG_BASE64] != nil)
            [newDic setValue:[dic valueForKey:API_IS_MSG_BASE64] forKey:MSG_BASE64];
        else
            [newDic setValue:[NSNumber numberWithBool:NO] forKey:MSG_BASE64];
        
        if(![msgType isEqualToString:VOIP_OUT])
            [newDic setValue:[dic valueForKey:API_MSG_CONTENT] forKey:MSG_CONTENT];
        
        if([dic valueForKey:API_ANNOTATION] != nil)
            [newDic setValue:[dic valueForKey:API_ANNOTATION] forKey:ANNOTATION];
        else
            [newDic setValue:@"" forKey:ANNOTATION];
        
#ifdef TRANSCRIPTION_ENABLED
        //Transcription text from server
        NSString *score = [[dic valueForKey:@"score"] stringValue];
        NSString *transText = [dic valueForKey:@"trans_text"];
        NSString *transScoreAndText = [NSString stringWithFormat:@"Transcription confidence: %@\n%@",score,transText];
        
        if(![[newDic valueForKey:MSG_CONTENT_TYPE]isEqualToString:IMAGE_TYPE])
        {
            if(transText.length)
                [newDic setValue:transScoreAndText forKey:MSG_TRANS_TEXT];
            else
                [newDic setValue:@"" forKey:MSG_TRANS_TEXT];
        }
        //
#endif
        if([dic valueForKey:API_MEDIA_FORMAT] != nil)
            [newDic setValue:[dic valueForKey:API_MEDIA_FORMAT] forKey:MEDIA_FORMAT];
        else
            [newDic setValue:@"" forKey:MEDIA_FORMAT];
        //CMP
        if([dic valueForKey:API_DURATION] != nil)
            [newDic setValue:[dic valueForKey:API_DURATION] forKey:DURATION];
        else
            [newDic setValue:[NSNumber numberWithInt:0] forKey:DURATION];
        //
        
        //Location
        NSDictionary *fromLocation = [dic valueForKey:API_FROM_LOCATION];
        if([fromLocation valueForKey:API_LATITUDE] != nil)
            [newDic setValue:[fromLocation valueForKey:API_LATITUDE] forKey:LATITUDE];
        else
            [newDic setValue:@"" forKey:LATITUDE];
        
        if([fromLocation valueForKey:API_LOGITUDE] != nil)
            [newDic setValue:[fromLocation valueForKey:API_LOGITUDE] forKey:LONGITUTE];
        else
            [newDic setValue:@"" forKey:LONGITUTE];
        
        if([fromLocation valueForKey:API_LOCATION_NM] != nil) {
            NSString* loc = [fromLocation valueForKey:API_LOCATION_NM];
            if([loc length])
               loc = [loc stringByReplacingOccurrencesOfString:@"," withString:@" | "];
            if([loc length])
                [newDic setValue:loc forKey:LOCATION_NAME];
        }
        else
            [newDic setValue:@"" forKey:LOCATION_NAME];
        
        if([fromLocation valueForKey:API_LOCALE] != nil)
            [newDic setValue:[fromLocation valueForKey:API_LOCALE] forKey:LOCALE];
        else
            [newDic setValue:@"" forKey:LOCALE];
        
        //Message Activity.
        if([dic valueForKey:API_LINKED_OPR] != nil)
            [newDic setValue:[dic valueForKey:API_LINKED_OPR] forKey:LINKED_OPR];
        else
            [newDic setValue:@"" forKey:LINKED_OPR];
        
        if([dic valueForKey:API_LINKED_MSG_TYPE] != nil)
            [newDic setValue:[dic valueForKey:API_LINKED_MSG_TYPE] forKey:LINKED_MSG_TYPE];\
        else
            [newDic setValue:@"" forKey:LINKED_MSG_TYPE];
        
        if([dic valueForKey:API_LINKED_MSG_ID] != nil)
            [newDic setValue:[dic valueForKey:API_LINKED_MSG_ID] forKey:LINKED_MSG_ID];
        else
            [newDic setValue:[NSNumber numberWithLong:0] forKey:LINKED_MSG_ID];
        
        NSNumber *boolValue = [NSNumber numberWithBool:NO];
        [newDic setValue:boolValue forKey:MSG_LIKED];
        [newDic setValue:boolValue forKey:MSG_LISTENED];
        [newDic setValue:boolValue forKey:MSG_FB_POST];
        [newDic setValue:boolValue forKey:MSG_TW_POST];
        [newDic setValue:boolValue forKey:MSG_VB_POST];
        [newDic setValue:boolValue forKey:MSG_FORWARD];

        [newDic setValue:[dic valueForKey:API_MSG_READ_CNT] forKey:MSG_READ_CNT];
        [newDic setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAY_DURATION];
        [newDic setValue:[dic valueForKey:API_MSG_DOWNLOAD_CNT] forKey:MSG_DOWNLOAD_CNT];
        [newDic setValue:[NSNumber numberWithLongLong:0] forKey:DOWNLOAD_TIME];
        [newDic setValue:[NSNumber numberWithInt:0] forKey:MSG_SIZE_LONG];
        
        
/* Transcription. TODO - remove
        //- The output will be "<confidence-text><sp>\n"<transcription-text>""
        NSString* transText = [dic valueForKey:@"trans_text"];
        if(transText) {
            KLog(@"TRANS...%@",dic);
            NSInteger score = [[dic valueForKey:@"score"]integerValue];
            KLog(@"trans_text = %@, score = %ld",transText,score);
            NSString* confidence = @"";
            if(1==score) {
                transText = @"Sorry, the message was either blank or inaudible for transcription";
            } else {
                confidence = [self getTransConfidenceText:score];
            }
            
            if(0!=score) {
                if(score>1)
                    transText = [confidence stringByAppendingFormat:@" \n\"%@\"",transText];
                [newDic setValue:transText forKey:ANNOTATION];
                KLog(@"final trans_text: %@",transText);
            }
        }
*/
    }
    else
    {
        EnLoge(@"Message Dictionry is NULL");
    }
    
    return newDic;
}

+(NSString*)getTransConfidenceText:(NSInteger)score {
    NSString* text = @"";
    switch(score) {
        case 2: text = @"Transcription confidence: Low"; break;
        case 3: text = @"Transcription confidence: Medium"; break;
        case 4: text = @"Transcription confidence: High"; break;
        case 5: text = @"Transcription confidence: Very high"; break;
    }
    return text;
}

/*
 Get the user's IV ID or tel or group id from the array of message dictionary and
 remove the user from the saved hidden list in settings
 */
-(void)removeHiddenUsersFromSettings:(NSArray*) msgList
{
    NSArray* hiddenListFromSettings = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"HIDDEN_TILES"];
    
    NSMutableArray* hiddenList = [[NSMutableArray alloc]init];
    if(hiddenListFromSettings && [hiddenListFromSettings count])
        [hiddenList addObjectsFromArray:hiddenListFromSettings];
    
    if(![hiddenList count])
        return;
    
    for(NSDictionary* msgDic in msgList)
    {
        NSString* userID = nil;
        NSString* convType = [msgDic valueForKey:CONVERSATION_TYPE];
        if( [convType isEqualToString:GROUP_TYPE]) {
            userID = [msgDic valueForKey:FROM_USER_ID]; //group id
        }
        else {
            userID = [msgDic valueForKey:REMOTE_USER_IV_ID]; //iv id
            if(!userID || ![userID length] || [userID isEqualToString:@"0"])
                userID = [msgDic valueForKey:FROM_USER_ID]; //tel number
        }
        
        if([hiddenList containsObject:userID])
            [hiddenList removeObject:userID];
    }
    
    [[ConfigurationReader sharedConfgReaderObj]setObject:hiddenList forTheKey:@"HIDDEN_TILES"];
}

#pragma mark - Image share handling for the messages in case of forwarding.
-(void)updateMsgLocalPathForForwardedMessages:(NSMutableArray*)msgList
{
    NSArray *filteredMsg = [msgList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(MSG_CONTENT_TYPE == %@ AND LINKED_MSG_ID > 0)", IMAGE_TYPE]];
    if(filteredMsg && [filteredMsg count] > 0)
    {
        NSArray* filteredMsgIdList = [filteredMsg valueForKey:LINKED_MSG_ID];
        NSString* linkedMsgIdList = [filteredMsgIdList componentsJoinedByString:@","];
        
        NSString *whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ IN (%@) ",MSG_ID ,linkedMsgIdList];
        NSMutableArray *arr = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:nil tableType:MESSAGE_TABLE_TYPE];
        
        if(arr && [arr count] > 0)
        {
            for(NSDictionary* linkedMsg in filteredMsg)
            {
                NSArray* linkedMsgArr = [arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(MSG_ID == %@)", [linkedMsg valueForKey:LINKED_MSG_ID]]];
                if(linkedMsgArr && [linkedMsgArr count] > 0)
                {
                    NSDictionary* msgData = [linkedMsgArr objectAtIndex:0];
                    
                    NSNumber* msgIDToUpdate = [linkedMsg valueForKey:MSG_ID];
                    NSString *updateClause = [[NSString alloc] initWithFormat:@"WHERE %@ = %@ ",MSG_ID ,msgIDToUpdate];
                    NSMutableDictionary* newDic = [[NSMutableDictionary alloc]init];
                    [newDic setValue:[msgData valueForKey:MSG_LOCAL_PATH] forKey:MSG_LOCAL_PATH];
                    if(![_msgTableObj updateTable:newDic whereClause:updateClause tableType:MESSAGE_TABLE_TYPE])
                    {
                        EnLoge(@"Error in Messaege Updation");
                    }
                }
            }
        }
    }
}

//This function is used to Update the Msg Activity Status in MessageTable.
-(NSDictionary*)updateMsgActivityInDBAndList:(NSDictionary*)msgActivity ResponseData:(NSMutableDictionary*)responseData
{
    if(msgActivity != nil && [msgActivity count]>0)
    {
        //We get activity_type or activity as the key depending on fetch or mqtt channel
        NSString *activityType = [msgActivity valueForKey:API_ACTIVITY_TYPE];
        if(!activityType.length)
            activityType = [msgActivity valueForKey:API_ACTIVITY];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSNumber *msgId = [msgActivity valueForKey:API_MSG_ID];
        NSString *whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ =\"%@\"",MSG_ID,msgId];
        if([msgActivity valueForKey:@"msg_guid"] && [activityType isEqualToString:API_LISTEN])//In MQTT channel update based on guid
        {
            whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ =\"%@\"",MSG_GUID,[msgActivity valueForKey:@"msg_guid"]];
            for(NSMutableDictionary* pendingMsg in _pendingMsgQueue)
            {
                if([[pendingMsg valueForKey:MSG_GUID]isEqualToString:[msgActivity valueForKey:@"msg_guid"]])
                {
                    [pendingMsg setValue:[NSNumber numberWithBool:YES] forKey:MSG_READ_CNT];
                }
            }
        }
        
        if([activityType isEqualToString:API_LIKE])
        {
            [dic setValue:[NSNumber numberWithBool:YES] forKey:MSG_LIKED];
        }
        else if ([activityType isEqualToString:API_UNLIKE])
        {
            [dic setValue:[NSNumber numberWithBool:NO] forKey:MSG_LIKED];
        }
        else if([activityType isEqualToString:API_LISTEN])
        {
            [dic setValue:[NSNumber numberWithBool:1] forKey:MSG_READ_CNT];
        }
        else if([activityType isEqualToString:API_MC_ERROR]) {
            //APR 27, 16 if([[responseData valueForKey:API_MSG_FLOW] isEqualToString:MSG_FLOW_S])
            NSMutableDictionary* curUser = [self getCurrentChatUser];
            NSString* remoteUserType = [curUser valueForKey:REMOTE_USER_TYPE];
            if(!remoteUserType || ![remoteUserType length]) {
                EnLogd(@"REMOTE_USER_TYPE is nil");
                
                //- JAN 31, 2017 -- TODO check
                /*
                if(46396338 == [[msgActivity valueForKey:API_MSG_ID]intValue]) {
                    NSLog(@"Debug");
                }*/
                NSArray* msgsList = [responseData valueForKey:API_MSGS];
                NSInteger iMsgId = [[msgActivity valueForKey:API_MSG_ID]integerValue];
                NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(msg_id = %ld)",iMsgId];;
                NSArray* resultList = [NSMutableArray arrayWithArray:[msgsList filteredArrayUsingPredicate:resultPredicate]];
                if(resultList.count) {
                    NSDictionary* dic = resultList[0];
                    NSArray *fromContactIds = [dic valueForKey:API_CONTACT_IDS];
                    for (NSDictionary *contactDic in fromContactIds)
                    {
                        NSString* contactType = [contactDic valueForKey:API_TYPE];
                        if([contactType isEqualToString:IV_TYPE]) {
                            remoteUserType = IV_TYPE;
                        }
                    }
                }//
            }
            
            if([remoteUserType isEqualToString:IV_TYPE])
                [dic setValue:RING_MC_ACK_FAILED forKey:MSG_CONTENT];
            else
                [dic setValue:RING_MC_FAILED forKey:MSG_CONTENT];
        }
        else if([activityType isEqualToString:API_MC_OK]) {
            [dic setValue:RING_MC_SUCCESS forKey:MSG_CONTENT];
        }
        
        NSString *byUser = [msgActivity valueForKey:API_BY_IV_USER_ID];
        long long int loggedInIvId = [appDelegate.confgReader getIVUserId];
        //FEB 18 API_BY_IV_USER_ID will not be present when cmd is ivuppd
        if([byUser longLongValue] == loggedInIvId || !byUser)
        {
            if([activityType isEqualToString:API_DELETE])
            {
                NSMutableArray *arr = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:nil tableType:MESSAGE_TABLE_TYPE];
                if(arr != nil && [arr count]>0)
                {
                    NSMutableDictionary *arrDic = [arr objectAtIndex:0];
                    NSString *str = [arrDic valueForKey:MSG_LOCAL_PATH];
                    if(str != nil && [str length]>0)
                    {
                        [IVFileLocator deleteFileAtPath:str];
                    }
                    NSString* msgType = [arrDic valueForKey:MSG_CONTENT_TYPE];
                    if(msgType && [msgType isEqualToString:IMAGE_TYPE])
                    {
                        NSString* filePath = [[IVFileLocator getMediaImagePath:[arrDic valueForKey:MSG_LOCAL_PATH]] stringByAppendingPathExtension:[arrDic valueForKey:MEDIA_FORMAT]];
                        [IVFileLocator deleteFileAtPath:filePath];
                    }
                }
                NSString* reason = [msgActivity valueForKey:API_REASON];
                if([reason length] && ([reason isEqualToString:API_REVOKE] || [reason containsString:API_REVOKE])) {
                    NSMutableDictionary* revDic = [[NSMutableDictionary alloc]init];
                    [revDic setValue:API_WITHDRAWN forKey:MSG_STATE];
                    [revDic setValue:MSG_WITHDRAWN_TEXT forKey:MSG_CONTENT];
                    [revDic setValue:TEXT_TYPE forKey:MSG_CONTENT_TYPE];
                    [revDic setValue:IV_TYPE forKey:MSG_TYPE];
                    [revDic setValue:@"" forKey:MSG_SUB_TYPE];
                    KLog(@"update Table: %@",revDic);
                    if(![_msgTableObj updateTable:revDic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE]) {
                        KLog(@"Error updating table:%@",whereClause);
                        EnLogd(@"Error updating table");
                    }
                }
                else
                if(![_msgTableObj deleteFromTable:whereClause tableType:MESSAGE_TABLE_TYPE])
                {
                    KLog(@"Error deleting a message:%@",whereClause);
                    EnLoge(@"Error in Message Deletion");
                }
            }
            if([activityType isEqualToString:API_FBP])
            {
                [dic setValue:[NSNumber numberWithBool:YES] forKey:MSG_FB_POST];
            }
            else if([activityType isEqualToString:API_TWP])
            {
                [dic setValue:[NSNumber numberWithBool:YES] forKey:MSG_TW_POST];
            }
            else if([activityType isEqualToString:API_VBP])
            {
                [dic setValue:[NSNumber numberWithBool:YES] forKey:MSG_VB_POST];
            }
            else if ([activityType isEqualToString:API_FORWORD])
            {
                [dic setValue:[NSNumber numberWithBool:YES] forKey:MSG_FORWARD];
            }
        }
        
        if(dic != nil && [dic count]>0)
        {
            //TODO: Server should not give "mc_err" activity for the recipient who received ring_mc
            //Need to remove this once server side fix is done.
            if([activityType isEqualToString:API_MC_ERROR])
            {
                NSArray* res = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:nil tableType: MESSAGE_TABLE_TYPE];
                if([res count]) {
                    NSDictionary* resDic = [res objectAtIndex:0];
                    KLog(@"Ring Message: %@",resDic);
                    NSString* msgFlow = [resDic valueForKey:MSG_FLOW];
                    if([msgFlow isEqualToString:MSG_FLOW_R]) {
                        [dic setValue:RING_MC_SUCCESS forKey:MSG_CONTENT];
                    }
                }
            }
            //
            
            KLog(@"update Table1: %@",dic);
            if(![_msgTableObj updateTable:dic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE]) {
                EnLogd(@"Error in Message Updation dic=%@");
            }
            else {
                return dic;
            }
        }
    }
    return nil;
}

#pragma mark -- Refactoring Msg Update from Contact info
//check and update the new message user info based on contact record
//This function is used update Message Table Based on  Contat Table.
-(void)updateMsgTableBasedOnContactTable
{
    NSMutableArray *msgs = [self getUniqueConversation];
    NSMutableArray* filteredList = [[NSMutableArray alloc]init];
    if([appDelegate.confgReader getLastMsgUpdateFromContactTime] != Nil)
    {
        for(NSMutableDictionary* dic in msgs)
        {
            if([[dic valueForKey:MSG_DATE]longLongValue] >  [[appDelegate.confgReader getLastMsgUpdateFromContactTime]longLongValue])
            {
                [filteredList addObject:dic];
            }
            else
            {
                break;
            }
        }
    }
    else
    {
        filteredList = msgs;
    }
    
    if([filteredList count] > 0)
        [self updateMessageRecordFromContactRecordForMessageList:filteredList];
}

//Update message record based on contact enquire iv response.
-(void)updateMsgOnContactSync
{
    KLog(@"updateMsgOnContactSync");
    NSMutableArray *msgs = [self getUniqueConversation];
    [self updateMessageRecordFromContactRecordForMessageList:msgs];
    
    if([msgs count]>0)
        [appDelegate.confgReader setLastMsgUpdateFromContactTime:[[msgs objectAtIndex:0]valueForKey:MSG_DATE]];
    
    [self createActiveConversation:msgs];
    
    if([appDelegate.stateMachineObj getCurrentUIType] == CHAT_GRID_SCREEN)
    {
        //KLog(@"Notify ChatGridScreen of contact sync completion");
        NSMutableDictionary *resultDic = [[NSMutableDictionary alloc]init];
        if(_activeConversationList != nil && [_activeConversationList count]>0)
        {
            [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
        }
        else
        {
            [resultDic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
        }
        
        [resultDic setValue:[NSNumber numberWithInt:GET_ACTIVE_CONVERSATION_LIST] forKey:EVENT_TYPE];
        [self notifyUI:resultDic];
    }
}

/* check contact data and update the message record, if contact not present add it for insertion in contact table
   updateMessageRecordFromContactRecordForMessageList should not be called from main thread
 */
-(void)updateMessageRecordFromContactRecordForMessageList:(NSMutableArray*)msgArrayList
{
    KLog(@"updateMessageRecordFromContactRecordForMessageList");
    //Get phone number record for the message
    NSManagedObjectContext* ctx = [AppDelegate sharedPrivateQueueContext];
    
    NSMutableArray* enquireList = [[NSMutableArray alloc]init];
    __block BOOL fetchGroupUpdate = NO;
    
    [ctx performBlockAndWait:^{//NOV 2017
        for(NSMutableDictionary* record in msgArrayList)
        {
            NSString* phoneNum = [record valueForKey:FROM_USER_ID];//TODO: FIX remove leading/trailing spaces
            phoneNum = [phoneNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:ctx];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            request.fetchBatchSize = 10;
            
            NSPredicate* condition=nil;
            @try {
                condition = [NSPredicate predicateWithFormat:@"contactDataValue = %@",phoneNum];
            }@catch (NSException *exception) {
                EnLogd(@"phoneNum = %@,Exception occurred: %@",exception);
                //TODO: FIXME. Remove such Invalid phoneNum from the array.
                continue;
            }
            [request setPredicate:condition];
            
            
            /* Crashlytics: #1423 @ 3554
             Fatal Exception: NSGenericException
             *** Collection <__NSCFSet: 0x170046d50> was mutated while being enumerated.
             */
            NSArray *array=nil;
            
            NSError *error;
            @try {
                array = [ctx executeFetchRequest:request error:&error];
            }
            @catch (NSException *exception) {
                EnLogd(@"Exception occurred: %@",exception);
            }
            
            if (array == nil || [array count] == 0)
            {
                EnLogd(@"No Record Found");
                //check if user is iv and add it to the list for enquire
                NSString* msgSubType = [record valueForKey:MSG_SUB_TYPE];
                if(msgSubType != Nil && ([msgSubType isEqualToString:GROUP_MSG_TYPE] || [msgSubType isEqualToString:GROUP_MSG_EVENT_TYPE]))
                {
                    fetchGroupUpdate = YES;
                }
                else
                {
                    [enquireList addObject:phoneNum];
                }
            }
            else
            {
                ContactDetailData* detailData = [array objectAtIndex:0];
                [self updateMessageDic:record withContactDetailData:detailData];
            }
        }
    }];
    
    if([msgArrayList count]>0)
        [appDelegate.confgReader setLastMsgUpdateFromContactTime:[[msgArrayList objectAtIndex:0]valueForKey:MSG_DATE]];
    if([enquireList count] > 0)
    {
        KLog(@"Enquire List:%@", enquireList);
        [self enquireAndInsertContactRecordInMainThread:enquireList];
    }
    
    if(fetchGroupUpdate) {
        KLog(@"update group member info");
        [self updateGroupMemberInfoFromServerInMainThread];
    }
}

-(void)updateMessageDic:(NSMutableDictionary*)dic withContactDetailData:(ContactDetailData*)detailData
{
    //update remote user and other info from contact table in msg table.
    ContactData* data = detailData.contactIdParentRelation;
    if([data.contactType integerValue] != ContactTypeIVGroup)
    {
        NSString *name = data.contactName;
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
        
        if(name != nil && [name length]>0)
        {
            [newDic setValue:name forKey:REMOTE_USER_NAME];
        }
        else
        {
            [newDic setValue:detailData.contactDataValue forKey:REMOTE_USER_NAME];
        }
        
        [newDic setValue:[dic valueForKey:REMOTE_USER_TYPE] forKey:REMOTE_USER_TYPE];
        NSString *contactPic =[IVFileLocator getNativeContactPicPath:data.contactPic];
        [newDic setValue:contactPic forKey:REMOTE_USER_PIC];
        NSString *wherclause = [NSString stringWithFormat:@"WHERE %@ = \"%@\"",FROM_USER_ID,detailData.contactDataValue];
        [_msgTableObj updateTable:newDic whereClause:wherclause tableType:MESSAGE_TABLE_TYPE];
    }
}

-(void)insertCelebrityContactInMainThread:(NSMutableArray*)contactList
{
    NSMutableArray* updatedContactList = [[NSMutableArray alloc]init];
    
    //- Remove the celebrity user if it is in Contacts (i.e it was already synched with the server)
    for(NSMutableDictionary* dic in contactList) {
        
        if( [[dic valueForKey:REMOTE_USER_TYPE] isEqualToString:CELEBRITY_TYPE]) {
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * ivID = [f numberFromString:[dic valueForKey:REMOTE_USER_IV_ID]];
            
            //TO DEBUG celebrity a/c: Archana
            /*
             if( [ivID longLongValue] == 5076 || [ivID longLongValue] == 5074) {
             BOOL bRet = [self isIVUser:ivID];
             }
             */
            if([ivID longValue]>0)
            {
                BOOL bRet = [self isCelebRecordAlreadyExist:ivID];
                if(bRet) {
                    EnLogd(@"NOT UPDATING this user with Contacts:%@",ivID);
                } else {
                    [updatedContactList addObject:dic];
                }
            }
        }
    }
    if(updatedContactList.count)
        [self performSelectorOnMainThread:@selector(insertCelebrityContact:) withObject:updatedContactList waitUntilDone:NO];
}

-(void)insertCelebrityContact:(NSMutableArray*)contactList
{
    [[Contacts sharedContact]saveCelebrityContactList:contactList];
}

-(void)enquireAndInsertContactRecordInMainThread:(NSMutableArray*)contactList
{
    [self performSelectorOnMainThread:@selector(enquireAndInsertContactRecord:) withObject:contactList waitUntilDone:NO];
}

-(void)enquireAndInsertContactRecord:(NSMutableArray*)contactList
{
    [[Contacts sharedContact]enquireAndInsertContactRecord:contactList];
}

-(void)updateGroupMemberInfoFromServerInMainThread
{
    [self performSelectorOnMainThread:@selector(updateGroupMemberInfoFromServer) withObject:Nil waitUntilDone:NO];
}

-(void)updateGroupMemberInfoFromServer
{
    [[Contacts sharedContact]updateGroupMemberInfoFromServer:YES];
}

-(BOOL)isCelebRecordAlreadyExist:(NSNumber*)ivID
{
    __block BOOL retValue = NO;
    NSManagedObjectContext* moc = [AppDelegate sharedPrivateQueueContext];//NOV 2017
    [moc performBlockAndWait:^{//NOV 2017
        NSArray* contactDetailList = [self getContactForIVUserId:ivID];
        EnLogd(@"isCelebRecordAlreadyExist: %@",ivID);
        
        for(ContactDetailData* detail in contactDetailList){
            if([detail.ivUserId longValue] > 0 && detail.contactIdParentRelation.groupId.length == 0) {
                //return true;
                retValue = YES;
                break;
            }
        }
    }];
    
    return retValue;
}

#pragma mark -- Refactoring Msg Update from Contact info Ends


#pragma mark -- Send Message
// This function is used to get the Message List that are not sent.
-(NSMutableArray*)getPendingMsgList:(eMessage)type
{
    NSString *whereClause = nil;
    if(type == MessageUser)
    {
        if(_currentChatUser != nil && [_currentChatUser count]>0)
        {
            whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\" AND %@ = \"%@\" AND (%@ = \"%@\" OR %@ = \"%@\" OR %@ = \"%@\" )",LOGGEDIN_USER_ID,[appDelegate.confgReader getLoginId],FROM_USER_ID,[_currentChatUser valueForKey:FROM_USER_ID],MSG_STATE,API_UNSENT,MSG_STATE,API_INPROGRESS,MSG_STATE,API_NETUNAVAILABLE];
        }
    }
    else if(type == MessageNotes)
    {
        whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\" AND (%@ = \"%@\" OR %@ = \"%@\" OR %@ = \"%@\") AND %@ = \"%@\"",LOGGEDIN_USER_ID,[appDelegate.confgReader getLoginId],MSG_STATE,API_UNSENT,MSG_STATE,API_NETUNAVAILABLE,MSG_STATE,API_INPROGRESS,MSG_TYPE,NOTES_TYPE];
    }
    else if(type == MessageVobolo)
    {
        whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\" AND (%@ = \"%@\" OR %@ = \"%@\" OR %@ = \"%@\")  AND %@ = \"%@\"",LOGGEDIN_USER_ID,[appDelegate.confgReader getLoginId],MSG_STATE,API_UNSENT,MSG_STATE,API_NETUNAVAILABLE,MSG_STATE,API_INPROGRESS,MSG_TYPE,VB_TYPE];
    }
    else
    {
        whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\" AND (%@ = \"%@\" OR %@ = \"%@\" OR %@ = \"%@\")",LOGGEDIN_USER_ID,[appDelegate.confgReader getLoginId],MSG_STATE,API_UNSENT,MSG_STATE,API_NETUNAVAILABLE,MSG_STATE,API_INPROGRESS];
    }
    
    NSMutableArray *pendingMsgList=nil;
    if(whereClause.length) {
        @try {
            pendingMsgList = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:nil tableType:MESSAGE_TABLE_TYPE];
        }
        @catch (NSException *exception) {
            EnLogd(@"***EXCEPTION: Conversation:get Pending MsgList -- %@",exception);
        }
    }
    
    return pendingMsgList;
}

//This function is used to add all unsent message in pendding Queue.
-(void)addPendingMsgToQueue:(NSMutableArray*)pendingMsgList
{
    KLog(@"addPendingMsgToQueue");
   
    long count = [pendingMsgList count];
    KLog(@"Messages to be added into _pendingMsgQueue: %ld, %@",count,pendingMsgList);
    
    long queueCount = [_pendingMsgQueue count];
    KLog(@"Messages in _pendingMsgQueue: %ld, %@", queueCount,_pendingMsgQueue);
    
    if(queueCount >0)
    {
        for(long i =0; i<count;i++)
        {
            BOOL checkFlag = NO;
            NSString *listGUID = [[pendingMsgList objectAtIndex:i] valueForKey:MSG_GUID];
            for(int j=0; j<queueCount;j++)
            {
                NSString *queueGUID =[[_pendingMsgQueue objectAtIndex:j]valueForKey:MSG_GUID];
                
                if([listGUID isEqualToString:queueGUID])
                {
                    checkFlag = YES;
                    break;
                }
            }
            if(!checkFlag)
            {
                if([_pendingMsgQueue count] <= MSG_COUNT)
                {
                    [_pendingMsgQueue addObject:[pendingMsgList objectAtIndex:i]];
                }
            }
        }
    }
    else
    {
        _pendingMsgQueue = pendingMsgList;
    }
}

-(NSMutableDictionary *)removeMsgFromQueue:(NSString*)respMsgGUID
{
    KLog(@"removeMsgFromQueue. GUID = %@",respMsgGUID);
    
    NSMutableDictionary *dic = nil;
    if(_pendingMsgQueue != nil && [_pendingMsgQueue count] >0)
    {
        long count = [_pendingMsgQueue count];
        NSMutableDictionary *tempDic = nil;
        for(long i =0 ;i<count;i++)
        {
            dic = [_pendingMsgQueue objectAtIndex:i];
            if([respMsgGUID isEqualToString:[dic valueForKey:MSG_GUID]])
            {
                tempDic = dic;
                break;
            }
            else
            {
                dic =  nil;
                tempDic = nil;
            }
        }
        if(tempDic != nil)
        {
            KLog(@"Removing message from _pendingMsgQueue. GUID = %@",respMsgGUID);
            [_pendingMsgQueue removeObject:tempDic];
        }
    }
    else
    {
        KLog(@"Pending message queue is NULL");
        EnLoge(@"Pending message queue is NULL");
    }
    
    return dic;
}

/* 
 - msgDic will have VOIP_CALL_DIC key which points to a dic, if MSG_TYPE is VOIP_TYPE.
 - VOIP_CALL_DIC contains the voip call ralatd info: REMOTE_USER_IV_ID,REMOTE_USER_NAME,REMOTE_USER_PIC and DURATION
 */
-(BOOL)saveNewMsgInDB:(NSMutableDictionary*)msgDic
{
    if(msgDic != nil)
    {
        NSMutableDictionary* savDic = [[NSMutableDictionary alloc]initWithDictionary:msgDic];
        NSString* msgType = [savDic valueForKey:MSG_TYPE];
        if([msgType isEqualToString:VOIP_TYPE] || [msgType isEqualToString:VOIP_OUT]) {
            NSDictionary* voipDic = [savDic objectForKey:VOIP_CALL_DIC];
            if(voipDic.count) {
                [savDic setValue:[voipDic valueForKey:REMOTE_USER_IV_ID] forKey:REMOTE_USER_IV_ID];
                [savDic setValue:[voipDic valueForKey:REMOTE_USER_NAME] forKey:REMOTE_USER_NAME];
                [savDic setValue:[voipDic valueForKey:REMOTE_USER_PIC] forKey:REMOTE_USER_PIC];
                [savDic setValue:[voipDic valueForKey:DURATION] forKey:DURATION];
                NSString* status = [voipDic valueForKey:STATUS];
                [savDic setValue:status forKey:MSG_SUB_TYPE];
                if([status isEqualToString:VOIP_CALL_REJECTED])
                   [savDic setValue:VOIP_CALL_CANCELED forKey:MSG_CONTENT];
                
                /*
                NSString* guid = [self prepareGUID:voipDic];
                KLog(@"*** guid = %@",guid);
                [savDic setValue:guid forKey:MSG_GUID];
                 */
                /*
                 Save the voipDic into ANNOTATION as json string so that it can be used when reading unsent msgs from MessageTable.
                 ANNOTATION column is not used for the "voip" MSG_TYPE.
                 TODO: Use/create a new column, when ANNOTATION is used.
                 */
                //NSString* jsonString = [self jsonStringFromDictionary:voipDic WithPrettyPrint:YES];
                NSString* jsnString = [self jsonStringFromDictionary:voipDic WithPrettyPrint:NO];
                [savDic setValue:jsnString forKey:ANNOTATION];
                
                //
            } else {
                EnLogd(@"*** voip dic is null. check the code.");
                return FALSE;
            }
            
            [savDic removeObjectForKey:VOIP_CALL_DIC];
        }
        
        NSString* msgGUID = [savDic valueForKey:MSG_GUID];
        NSString* msgSubType = [savDic valueForKey:MSG_SUB_TYPE];
        BOOL isMsgPresent = [self isMessageAvailableWithGuid:savDic];
        
        if(msgSubType && [msgSubType isEqualToString:GROUP_MSG_EVENT_TYPE]) {
            [[ConfigurationReader sharedConfgReaderObj]setFetchGroupInfoFromServer:TRUE];
            return TRUE;
        }
        
        if(!isMsgPresent) {
            KLog(@"Message is not available in DB. Insert msg: %@", savDic);
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:savDic, nil];
            if(![_msgTableObj insertInTable:array tableType:MESSAGE_TABLE_TYPE]) {
                EnLogd(@"Error in Message insertion. GUID = %@",msgGUID);
                KLog(@"Error in Message insertion. GUID = %@",msgGUID);
            } else {
                KLog(@"Message inserted. GUID = %@",msgGUID);
            }
        }
        else {
            NSString *whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\"",MSG_GUID,msgGUID];
            if(![_msgTableObj updateTable:savDic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE]) {
                EnLogd(@"Error in Message update. GUID = %@",msgGUID);
                KLog(@"Error in Message update. GUID = %@",msgGUID);
            }
            else {
                KLog(@"Message updated. GUID = %@",msgGUID);
            }
        }
        return TRUE;
    }
    
    return FALSE;
}

//- Prepare GUID from the VOIP_CALL_ID. i.e GUID = VOIP_CALL_ID_status_deviceID
/*
-(NSString*)prepareGUID:(NSDictionary*)voipDic {
    
    NSString* callIdFromPN = [voipDic valueForKey:VOIP_CALL_ID];
    NSString* status = [voipDic valueForKey:VOIP_CALL_STATUS];
    
    SettingModelMqtt* mqttSetting = [[[Setting sharedSetting]data]mqttSetting];
    NSString* deviceID = [mqttSetting.deviceId stringValue];
    if(!deviceID || !deviceID.length)
        deviceID = @"unknown";
    
    NSString* newStatus = status;
    if(!status)
        newStatus = @"unknown";
    
        
    NSString* guid = [callIdFromPN stringByAppendingFormat:@"_%@_%@",newStatus,deviceID];
    
    return guid;
}*/

-(void)stopSenddingAllMsg
{
    KLog(@"stopSenddingAllMsg");
    KLog(@"Messages in _pendingMsgQueye: %@",_pendingMsgQueue);
    
    if(_pendingMsgQueue != nil && [_pendingMsgQueue count]>0)
    {
        long count = [_pendingMsgQueue count];
        for (long i =0; i <count; i++)
        {
            NSMutableDictionary *dic = [_pendingMsgQueue objectAtIndex:i];
            [self updateMsgStateInDB:API_UNSENT msgDic:dic];
        }

        [_pendingMsgQueue removeAllObjects];
        [self refreshChatDataAndNotifyAllUI:NO];
    }
    else
    {
        KLog(@"Pending message queue is NULL");
        EnLoge(@"Pending message queue is NULL");
    }
}

-(void)sendAllPendingMsg
{
    KLog(@"sendAllPendingMsg");
    
    NSMutableArray *pendingMsgList = [self getPendingMsgList:MessageAll];
    
    if(_pendingMsgQueue == nil)
    {
        _pendingMsgQueue = [[NSMutableArray alloc] init];
    }
    else
    {
        [_pendingMsgQueue removeAllObjects];
    }
    
    if(pendingMsgList != nil && [pendingMsgList count]>0)
    {
        [self addPendingMsgToQueue:pendingMsgList];
    }
    [self refreshChatDataAndNotifyAllUI:NO];
    
    if([_pendingMsgQueue count]) {
        [self sendAllMsg];
    }
}

//This Function is used to send the messages from Message Pending Queue.
-(void)sendAllMsg
{
    KLog(@"SendAllMsg. _pendingMsgQueue = %ld",(long)[_pendingMsgQueue count]);
    
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        KLog(@"Network is not connected. Return.");
        return;
    }
    
    NSMutableDictionary *sendMsgDic = nil;
    BOOL isGroupMsg = NO;
    for(int i=0; i<[_pendingMsgQueue count]; i++)
    {
        NSMutableDictionary* dic = [_pendingMsgQueue objectAtIndex:i];
        //KLog(@"sending a message");
        
        if([[dic valueForKey:MSG_STATE] isEqualToString:API_MSG_REQ_SENT] && [[dic valueForKey:MSG_ID]longValue]>0)
        {
            KLog(@"Remove msg from _pendingMsgQueue. API_MSG_REQ_SENT");
            [self removeMsgFromQueue:[dic valueForKey:MSG_GUID]];
            continue;
        }
        else if ([[dic valueForKey:MSG_STATE] isEqualToString:API_MSG_REQ_SENT])
        {
            continue;
        }
        else
        {
            KLog(@"MSG_STATE = %@",[dic valueForKey:MSG_STATE]);//NOV 2017
            [dic setValue:API_MSG_REQ_SENT forKey:MSG_STATE];
            
            NSString* mType = [dic valueForKey:MSG_TYPE];
            if([mType isEqualToString:VOIP_TYPE] || [mType isEqualToString:VOIP_OUT]) {
                [self sendVoipCallLog:dic];
                continue;
            }
            
            sendMsgDic = [[NSMutableDictionary alloc] init];
            int eventType ;
            [sendMsgDic setValue:[dic valueForKey:MSG_CONTENT_TYPE] forKey:API_MSG_CONTENT_TYPE];
            
            //CMP [sendMsgDic setValue:[dic valueForKey:MSG_TYPE] forKey:API_MSG_TYPE];
            NSString* msgSubType = [dic valueForKey:MSG_SUB_TYPE];
            if(msgSubType && [msgSubType length])
                [sendMsgDic setValue:msgSubType forKey:API_SUBTYPE];
            
            //Set Parameter for Fetch Msg
            [sendMsgDic setValue:[NSNumber numberWithBool:YES] forKey:API_FETCH_MSGS];
            [sendMsgDic setValue:[NSNumber numberWithLongLong:[appDelegate.confgReader getAfterMsgId]] forKey:API_FETCH_AFTER_MSGS_ID];
            [sendMsgDic setValue:[NSNumber numberWithBool:YES] forKey:API_FETCH_MSG_ACTIVITIES];
            [sendMsgDic setValue:[NSNumber numberWithLongLong:[appDelegate.confgReader getAfterMsgActivityId]] forKey:API_FETCH_AFTER_MSG_ACTIVITY_ID];
            [sendMsgDic setValue:[NSNumber numberWithBool:YES] forKey:API_FETCH_OPPONENT_CONTACTIDS];
            
            [sendMsgDic setValue:[dic valueForKey:MSG_GUID] forKey:API_GUID];
            NSMutableDictionary *fromLoc = [[NSMutableDictionary alloc] init];
            NSString *latitude = [dic valueForKey:LATITUDE];
            NSString *longitute = [dic valueForKey:LONGITUTE];
            NSString *locName = [dic valueForKey:LOCATION_NAME];
            if(latitude != nil && longitute != nil && locName != nil)
            {
                [fromLoc setValue:longitute forKey:API_LOGITUDE];
                [fromLoc setValue:latitude forKey:API_LATITUDE];
                [fromLoc setValue:[dic valueForKey:LOCALE] forKey:API_LOCALE];
                [fromLoc setValue:locName forKey:API_LOCATION_NM];
            }
            else
            {
                /* NOV 2017
                [self getLocationPermission];
                if([Setting sharedSetting].data.displayLocation)
                {
                    if(_location != nil)
                    {
                        latitude = [[NSNumber numberWithFloat:_location.coordinate.latitude] stringValue];
                        longitute = [[NSNumber numberWithFloat:_location.coordinate.longitude] stringValue];
                    }
                    if(_locationName != nil)
                    {
                        locName = _locationName;
                    }
                }
                [fromLoc setValue:longitute forKey:API_LOGITUDE];
                [fromLoc setValue:latitude forKey:API_LATITUDE];
                [fromLoc setValue:locName forKey:API_LOCATION_NM];
                 */
            }
            [sendMsgDic setValue:fromLoc forKey:API_FROM_LOCATION];
            NSMutableArray *contactIds = [[NSMutableArray alloc] init];
            NSMutableDictionary *contactDic = [[NSMutableDictionary alloc] init];
            NSString *ivIdStr = [[NSString alloc] initWithFormat:@"%@",[NSNumber numberWithLong:[appDelegate.confgReader getIVUserId]]];
            [contactDic setValue:ivIdStr forKey:API_CONTACT];
            [contactDic setValue:IV_TYPE forKey:API_TYPE];
            if([msgSubType isEqualToString:RING_MC])
                [contactDic setValue:[appDelegate.confgReader getLoginId] forKey:API_CONTACT_ID];
            [contactIds addObject:contactDic];
            NSString *msgType = [dic valueForKey:MSG_TYPE];
            if([msgType isEqualToString:FB_TYPE])
            {
                [sendMsgDic setValue:[dic valueForKey:FROM_USER_ID] forKey:API_FRIEND_FB_USER_IDS];
            }
            else if([msgType isEqualToString:IV_TYPE] || [msgType isEqualToString:VSMS_TYPE] ||
                    [msgType isEqualToString:MISSCALL])
            {
                NSString *remoteIVUser = [dic valueForKey:REMOTE_USER_IV_ID];
                NSString *ividStr = [[NSString alloc] initWithFormat:@"%@",remoteIVUser];
                long ivid = [ividStr longLongValue];
                contactDic = [[NSMutableDictionary alloc] init];
                if(ivid >0)
                {
                    [contactDic setValue:remoteIVUser forKey:API_CONTACT];
                    [contactDic setValue:IV_TYPE forKey:API_TYPE];
                    if([msgSubType isEqualToString:RING_MC])
                        [contactDic setValue:[dic valueForKey:FROM_USER_ID] forKey:API_CONTACT_ID];//MAR 30
                }
                else
                {
                    [contactDic setValue:[dic valueForKey:FROM_USER_ID] forKey:API_CONTACT];
                    NSString *type = [dic valueForKey:REMOTE_USER_TYPE];
                    [contactDic setValue:type forKey:API_TYPE];
                    if([msgSubType isEqualToString:RING_MC])
                        [contactDic setValue:[dic valueForKey:FROM_USER_ID] forKey:API_CONTACT_ID];//MAR 30
                    if([type isEqualToString:PHONE_MODE])
                    {
                        [contactDic setValue:@"tel" forKey:API_TYPE];
                    }
                }
                if([[dic valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE]) {
                    [contactDic setValue:GROUP_TYPE forKey:API_TYPE];
                    isGroupMsg = YES;
                }
                [contactIds addObject:contactDic];
            }
            else if ([msgType isEqualToString:VB_TYPE]) {
                
            }
            else if ([msgType isEqualToString:NOTES_TYPE]) {
            }
            
            NSString *localFilePath = nil;
            NSString *fileName = nil;
            NSMutableDictionary *evDic = [[NSMutableDictionary alloc]init];
            
            if([[dic valueForKey:MSG_CONTENT_TYPE] isEqualToString:TEXT_TYPE])
            {
                eventType = SEND_TEXT_MSG;
                NSString* textMsg = [dic valueForKey:MSG_CONTENT];
                [sendMsgDic setValue:textMsg forKey:API_MSG_TEXT];
                [evDic setValue:sendMsgDic forKey:REQUEST_DIC];
            }
            else if([[dic valueForKey:MSG_CONTENT_TYPE] isEqualToString:AUDIO_TYPE])
            {
                eventType = SEND_VOICE_MSG;
                [sendMsgDic setValue:[dic valueForKey:MEDIA_FORMAT] forKey:API_MSG_FORMAT];
                localFilePath = [dic valueForKey:MSG_LOCAL_PATH]; //WAV file name with full path
                fileName = [dic valueForKey:MSG_CONTENT];
                
                //Find file size of the recorded WAV file
                NSFileManager *fm = [NSFileManager defaultManager];
                NSDictionary *attrs = [fm attributesOfItemAtPath: localFilePath error: NULL];
                UInt32 pcmFileSize = [attrs fileSize]/16000;
                [sendMsgDic setValue:[NSNumber numberWithInt:pcmFileSize] forKey:API_DURATION];
                
#ifdef OPUS_ENABLED
                //Encode the PCM recorded file and change the file name's ext to .IV
                NSString* opusFile = [[NSString alloc]initWithString:[fileName stringByDeletingPathExtension]];
                NSString* opusFileWithPath = [[NSString alloc]initWithString:[localFilePath stringByDeletingPathExtension]];
                opusFile = [opusFile stringByAppendingPathExtension:@"iv"];
                opusFileWithPath = [opusFileWithPath stringByAppendingPathExtension:@"iv"];
                
                const char* cWavFileName = [localFilePath UTF8String];
                const char* cOpusFileName = [opusFileWithPath UTF8String];
                
                int iResult = [OpusCoder EncodeAudio:8000 Bitrate:12000 Bandwidth:OPUS_BANDWIDTH_SUPERWIDEBAND
                                              PCMFile:cWavFileName OPUSFile:cOpusFileName];
                if(SUCCESS == iResult) {
                    localFilePath = opusFileWithPath;
                    fileName = opusFile;
                }
                else {
                    EnLoge(@"ERROR: Encoding failed.");
                    //TODO error : what to do?
                    //Remove this message and continue with other message
                    KLog(@"remove msg from _pendingMsgQueue. Encoding failed.");
                    [self removeMsgFromQueue:[dic valueForKey:MSG_GUID]];
                    [self deleteUnsentMessageWithGuid:[dic valueForKey:MSG_GUID]];
                    continue;
                }
#endif
                
                [evDic setValue:sendMsgDic forKey:REQUEST_DIC];
                
                if(localFilePath) {
                    [evDic setValue:localFilePath forKey:FILE_PATH];
                }
                if(fileName) {
                    [evDic setValue:fileName forKey:FILE_NAME];
                }
            }
            else
            {
                eventType = SEND_IMAGE_MSG;

                NSString* annotation = [dic valueForKey:ANNOTATION];
                if(annotation && annotation.length > 0)
                   [sendMsgDic setValue:annotation /*urlEncodeUsingEncoding:NSUTF8StringEncoding*/forKey:API_ANNOTATION];
                
                [sendMsgDic setValue:[dic valueForKey:MEDIA_FORMAT] forKey:API_MSG_FORMAT];
                localFilePath = [[IVFileLocator getMediaImagePath:[dic valueForKey:MSG_LOCAL_PATH]]stringByAppendingPathExtension:[dic valueForKey:MEDIA_FORMAT]]; //WAV file name with full path
                fileName = [[dic valueForKey:MSG_CONTENT]stringByAppendingPathExtension:[dic valueForKey:MEDIA_FORMAT]];
                
                [evDic setValue:sendMsgDic forKey:REQUEST_DIC];
                if(localFilePath) {
                    [evDic setValue:localFilePath forKey:FILE_PATH];
                }
                
                if(fileName) {
                    [evDic setValue:fileName forKey:FILE_NAME];
                }
            }
            
            //-
            //- client has to set "type" field as "iv" when it sends a msg(text/voice) to a non-iv user.
            NSString* tmpMsgType = [dic valueForKey:MSG_TYPE];
            if([tmpMsgType isEqualToString:VSMS_TYPE]) {
                [sendMsgDic setValue:IV_TYPE forKey:API_MSG_TYPE];
            } else {
                [sendMsgDic setValue:[dic valueForKey:MSG_TYPE] forKey:API_MSG_TYPE];
            }
            
            [sendMsgDic setValue:contactIds forKey:API_CONTACT_IDS];
            [sendMsgDic setValue:@"true" forKey:API_NON_IV];
            
            //Check if the dic has "cmd" = "RING_MC"
            NSString* cmd = [dic valueForKey:@"CMD"];
            BOOL isRingMissedCall = NO;
            if([cmd isEqualToString:@"RING_MC"]) {
                isRingMissedCall = YES;
                eventType = SEND_MC;
            }
            //
            
            [self addCommonData:sendMsgDic eventType:eventType];
            EnLogi(@"SEND-MSG dic : %@",sendMsgDic);
            /* DEC 2017 -- TODO: Remove the !isGroupMsg check once send_text cmd for group via MQTT channel is done */
            if([[MQTTManager sharedMQTTManager]canProcessThroughMQTT] && (eventType == SEND_TEXT_MSG) && !isGroupMsg)
            {
                KLog(@"Send msg via MQTT channel. %@",[sendMsgDic valueForKey:API_MSG_TEXT]);
                EnLogd(@" Send msg to MQTT server.");
                //NOV 2017 [self performSelectorOnMainThread:@selector(publishSendTextInMainThread:) withObject:sendMsgDic waitUntilDone:NO];
                [self performSelectorInBackground:@selector(publishSendTextInMainThread:) withObject:sendMsgDic];
            }
            else
            {
                KLog(@"Send msg via HTTP channel.");
                [self eventToNetwork:eventType eventDic:evDic];
            }
        }
        break;//NOV 2017
    }
}



/*
 - Executes "voip_call_log" command.
=
 VOIP_CALL_DIC should contain the following, if voip pn is received.
 
 call_at -- time stamp
 status - accepted, rejected, missed
 duration - call duration in seconds
 GUID - call-id in voip push notification and append status_deviceid
 from_phone - caller phone number
 contact_ids -- from and to number from push notification
 pn_delay - delay in milliseconds. It is the difference between the time when pn receieved and value of "call_at" field
 quality - {excellent, very good, good, poor} optional.
 header - optional.
*/

-(void)sendVoipCallLog:(NSDictionary*)dic
{
    NSDictionary* voipDic = [dic objectForKey:VOIP_CALL_DIC];
    
    if(!voipDic) {
        /* check if ANNOTATION has jsonString. If it has, convert into NSDictionary object.
           Refer saveNewMsgInDB method.
         */
        
        NSString* jsonString = [dic valueForKey:ANNOTATION];
        if(jsonString.length) {
            voipDic = [self dictionaryFromJsonString:jsonString];
        }
    }
    
    KLog(@"voipDic = %@",voipDic);
    NSMutableDictionary* reqParams = [[NSMutableDictionary alloc]init];
    NSString* fromPhone = [voipDic valueForKey:API_FROM_PHONE];
    NSString* toPhone = [voipDic valueForKey:API_TO_PHONE];
    NSNumber* callStartedAt = [voipDic valueForKey:API_CALL_AT];
    NSNumber* pnReceivedAt = [voipDic valueForKey:PN_RECIEVED_AT];
    NSString* status = [voipDic valueForKey:VOIP_CALL_STATUS];
    
    NSInteger callDuration = [[voipDic valueForKey:DURATION]integerValue];
    SettingModelMqtt* mqttSetting = [[[Setting sharedSetting]data]mqttSetting];
    NSString* deviceID = [mqttSetting.deviceId stringValue];
    if(!deviceID || !deviceID.length)
        deviceID = @"unknown";
    
    long pnDelay = [pnReceivedAt longLongValue] - [callStartedAt longLongValue];
    KLog(@"call_at = %@",callStartedAt);
    KLog(@"pn_received_at = %@",pnReceivedAt);
    KLog(@"pn_delay %ld ms", pnDelay);
    
    long long lCallStatedAt = [callStartedAt longLongValue];
    [reqParams setValue:[NSNumber numberWithLongLong:lCallStatedAt] forKey:API_CALL_AT];
    [reqParams setValue:fromPhone forKey:API_FROM_PHONE];
    [reqParams setValue:[NSNumber numberWithLong:pnDelay] forKey:API_PN_DELAY];
    [reqParams setValue:[NSNumber numberWithInteger:callDuration] forKey:API_DURATION];

    //NSString* callID = [self prepareGUID:voipDic];
    
    [reqParams setValue:[dic valueForKey:MSG_GUID] forKey:API_GUID];
    [reqParams setValue:status forKey:STATUS];
    [reqParams setValue:status forKey:API_SUBTYPE];//duplicate of "status"
    NSString* callType = [voipDic valueForKey:@"call_type"];
    NSString* type = @"";
    if([callType isEqualToString:@"p2p"] || [callType isEqualToString:@"gsm"]) {
        [reqParams setValue:VOIP_OUT forKey:API_MSG_TYPE];
        if([callType isEqualToString:@"p2p"])
            [reqParams setValue:VOIP_TYPE forKey:API_SUBTYPE];
        else
            [reqParams setValue:callType forKey:API_SUBTYPE];
        type = VOIP_OUT;
    }
    else {
        [reqParams setValue:@"voip" forKey:API_MSG_TYPE];
        type = VOIP_TYPE;//incoming voice call
    }
    
    NSNumber* ivid = [NSNumber numberWithLong:[appDelegate.confgReader getIVUserId]];
    NSString *ivIdStr = [[NSString alloc] initWithFormat:@"%@",ivid?[ivid stringValue]:@""];
    
    //- prepare CONTACT_IDS:[ {from}, {to} ]
    NSMutableArray *contactIds = [[NSMutableArray alloc] init];
    NSMutableDictionary *fromContactDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *toContactDic = [[NSMutableDictionary alloc] init];
    if([type isEqualToString:VOIP_OUT]) {
        [fromContactDic setValue:ivIdStr forKey:API_CONTACT];
        [fromContactDic setValue:IV_TYPE forKey:API_TYPE];
        [toContactDic setValue:toPhone forKey:API_CONTACT];
        [toContactDic setValue:PHONE_MODE forKey:API_TYPE];
    }
    else {
        [fromContactDic setValue:fromPhone forKey:API_CONTACT];
        [fromContactDic setValue:PHONE_MODE forKey:API_TYPE];
        [toContactDic setValue:ivIdStr forKey:API_CONTACT];
        [toContactDic setValue:IV_TYPE forKey:API_TYPE];
    }
    [fromContactDic setValue:fromPhone forKey:API_CONTACT_ID];
    [toContactDic setValue:toPhone forKey:API_CONTACT_ID];
    [contactIds addObject:fromContactDic];
    [contactIds addObject:toContactDic];
    
    [reqParams setValue:contactIds forKey:API_CONTACT_IDS];
    KLog(@"reqParams = %@",dic);
    
    int eventType = SEND_VOIP_CALL_LOG;
    [self addCommonData:reqParams eventType:eventType];
    EnLogi(@"voip_call_log dic : %@",reqParams);
    KLog(@"voip_call_log dic : %@",reqParams);
    
    NSMutableDictionary *voipCallLog = [[NSMutableDictionary alloc]init];
    [voipCallLog setValue:reqParams forKey:REQUEST_DIC];

    /*
    if([[MQTTManager sharedMQTTManager]canProcessThroughMQTT]) {
        KLog(@"voip_call_log via MQTT server.");
        EnLogd(@"voip_call_log to MQTT server.");
        [self performSelectorOnMainThread:@selector(publishSendTextInMainThread:) withObject:voipCallLog waitUntilDone:NO];
    }
    else*/ {
        KLog(@"voip_call_log via HTTP channel");
        [self eventToNetwork:eventType eventDic:voipCallLog];
    }
}


-(void)publishSendTextInMainThread:(NSMutableDictionary*) publishDic
{
    //KLog(@"sending msg...%@",[publishDic valueForKey:API_MSG_TEXT]);
    [[MQTTManager sharedMQTTManager]publishTextMessage:publishDic];
}

-(int)handleSendMsgResponse:(NSMutableDictionary*)objDic
{
    int result = FAILURE;
    if(objDic != nil && [objDic count] >0)
    {
        NSString *responseCode = [objDic valueForKey:RESPONSE_CODE];
        KLog(@"handleSendMsgResponse. %@",responseCode);
        
        NSDictionary *respDic = [objDic valueForKey:RESPONSE_DATA];
        NSDictionary *reqstDic = [objDic valueForKey:REQUEST_DIC];
        NSString* sentMsgGuid = [reqstDic valueForKey:API_GUID];
        NSString* cmdString = [reqstDic valueForKey:@"cmd"];
        int cmd = SEND_MSG;
        if([cmdString isEqualToString:@"send_mc"])
            cmd = SEND_MC;
        else if ([cmdString isEqualToString:@"voip_call_log"])
            cmd = SEND_VOIP_CALL_LOG;
        else {
            KLog(@"");
        }
        
        if([responseCode isEqualToString:NET_SUCCESS])
        {
            NSString *status = [respDic valueForKey:@"status"];
            if([status isEqualToString:@"ok"])
            {
                _sendCount = 0;

                NSMutableDictionary *msgDic = nil;
                if(_pendingMsgQueue != nil && [_pendingMsgQueue count]>0)
                {
                    KLog(@"Message sent. remove from the _pendingMsgQueue. GUID = %@",sentMsgGuid);
                    msgDic = [self removeMsgFromQueue:sentMsgGuid];
                    [self sendAllMsg];
                }
                else {
                    KLog(@"_pendingMsgQueue is null");
                    msgDic = [[NSMutableDictionary alloc]initWithDictionary:reqstDic];
                }
                KLog(@"msgDic = %@",msgDic);
                KLog(@"Sent msg via HTTP = %@", [msgDic valueForKey:MSG_CONTENT]);
                
                /* NOV 2017. TODO
                 If there is no corresponding msg in the _pendingMsgQueue how can we update the message status.
                 Check if the msg was sent via MQTT channel.
                 */
                if(msgDic.count) {
#ifndef REACHME_APP
                    [self leaveGroup:msgDic];
#endif
                    [self processMessageResponseFromServer:respDic forEventType:cmd requestDic:msgDic];
                    NSNumber *lastMsgId = [respDic valueForKey:API_LAST_FETCHED_MSG_ID];
                    if(lastMsgId.longValue > 0)
                        [appDelegate.confgReader setAfterMsgId:[lastMsgId longValue]];
                } else {
                    KLog(@"*** CHECK");
                }
            }
            else
            {
                _sendCount++;
                //Error handling for server error.
                NSInteger errorCode = [[respDic valueForKey:ERROR_CODE]integerValue];
                KLog(@"handleSendMessageError:code = %ld, guid = %@",(long)errorCode,sentMsgGuid);
                EnLogd(@"handleSendMessageError:code = %ld, guid = %@",errorCode,sentMsgGuid);
                
                //1 is system error.
                if(errorCode > 1)
                {
                    //error 84, 85 is for group member removal.
                    NSMutableDictionary *msgDic = nil;
                    if(_pendingMsgQueue != nil && [_pendingMsgQueue count]>0)
                    {
                        KLog(@"Message can't be sent. remove from the _pendingMsgQueue. GUID = %@",sentMsgGuid);
                        NSMutableDictionary* dic = [self removeMsgFromQueue:sentMsgGuid];
                        if(dic != nil)
                            msgDic = [[NSMutableDictionary alloc]initWithDictionary:dic];
                       // [self sendAllMsg];//NOV 2017
                    }
                    
                    _sendCount = 0;
                    [self deleteUnsentMessageWithGuid:sentMsgGuid];
                    
                    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
                    [dic setValue:[NSNumber numberWithInt:cmd] forKey:EVENT_TYPE];
                    [dic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
                    [dic setValue:respDic forKey:ERROR_DATA];
                    [dic setValue:msgDic forKey:REQUEST_DIC];
                    [self notifyUI:dic];
                }
            }
        }
        else if([responseCode isEqualToString:NULL_DATA])
        {
            KLog(@"Delete unsent message:%@",sentMsgGuid);
            _sendCount = 0;
            [self deleteUnsentMessageWithGuid:sentMsgGuid];
            [self sendAllMsg];//NOV 2017
        }
        else
        {
            //Network failure cases
            _sendCount++;
        }
        
        if(_sendCount > 0)
        {
            if(_sendCount < MAX_NETWORK_RETRY)
            {
                if(_pendingMsgQueue != nil && [_pendingMsgQueue count] >0)
                {
                    KLog(@"Update pending message\'s send status in DB. retry count = %d",_sendCount);
                    [self updateMsgStateInDB:API_UNSENT msgDic:[_pendingMsgQueue objectAtIndex:0]];
                }
            }
            else //_sendCount == MAX_NETWORK_RETRY
            {
                _sendCount =0;
                //in case of network time out after maximum retry.
                //empty the pending queue right now and notify the ui.
                if([responseCode isEqualToString:REQUEST_TIME_OUT])
                {
                    KLog(@"Request timedout. Update all the pendind messages in DB. Retry count = %d",_sendCount);
                    EnLogd(@"Request timedout. Update all the pendind messages in DB. Retry count = %d",_sendCount);
                    //update status of all the message in queue
                    for(NSMutableDictionary* unsentMsg in _pendingMsgQueue)
                    {
                        [self updateMsgStateInDB:API_NETUNAVAILABLE msgDic:unsentMsg];
                    }
                    [_pendingMsgQueue removeAllObjects];
                    
                    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
                    [dic setValue:[NSNumber numberWithInt:cmd] forKey:EVENT_TYPE];
                    [dic setValue:ENG_FALIURE forKey:RESPONSE_CODE];
                    [self notifyUI:dic];
                }
                else
                {
                    //this is done so that other message can also try but it may not be required
                    //instead we can empty the queue and start sending only after we get a new msg
                    KLog(@"Remove msg from _pendingMsgQueue. ResponseCode=%@",responseCode);
                    EnLogd(@"Remove msg from _pendingMsgQueue. ResponseCode=%@",responseCode);
                    /*
                    NSString *guid = [reqstDic valueForKey:API_GUID];
                    [self removeMsgFromQueue:guid];
                     */
                }
            }
        }
        //NOV 2017 [self sendAllMsg];
    }
    return result;
}

#ifndef REACHME_APP
-(void)leaveGroup:(NSMutableDictionary*)msgDic {
    
    BOOL bCallUpdateGroupAPI = NO;
    
    NSString* subType = [msgDic valueForKey:MSG_SUB_TYPE];
    if(subType && [subType isEqualToString:GROUP_MSG_EVENT_TYPE]) {
        NSString* msgContent = [msgDic valueForKey:MSG_CONTENT];
        NSMutableDictionary *msgContentDic = [Common convertStringJsonToDictionaryJson:msgContent];
        if(msgContentDic && [msgContentDic count]) {
            NSString* eventType = [msgContentDic valueForKey:EVENT_TYPE];
            if([eventType isEqualToString:@"left"]) {
                bCallUpdateGroupAPI = YES;
            }
        }
    }
    
    if(bCallUpdateGroupAPI) {
        NSMutableDictionary* groupDic = [[NSMutableDictionary alloc]init];
    
        NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
        [requestDic setValue:[msgDic valueForKey:FROM_USER_ID] forKey:@"group_id"];
        [requestDic setValue:@"u" forKey:@"group_operation"];
        [requestDic setValue:[NSNumber numberWithInt:1] forKey:@"group_type"];
        NSMutableArray* memberList = [[NSMutableArray alloc]init];
        
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        [dic setValue:[NSString stringWithFormat:@"%ld",[[ConfigurationReader sharedConfgReaderObj]getIVUserId]] forKey:@"contact"];
        [dic setValue:IV_TYPE forKey:@"type"];
        [dic setValue:@"l" forKey:@"operation"];
        [memberList addObject:dic];
        
        [requestDic setValue:memberList forKey:@"member_updates"];
        [groupDic setValue:requestDic forKey:@"group_server_request"];
        
        UpdateGroupAPI* api = [[UpdateGroupAPI alloc]initWithRequest:groupDic];
        [api callNetworkRequest:groupDic withSuccess:^(UpdateGroupAPI *req, NSMutableDictionary *responseObject) {
            EnLogd(@"Left the group successfully.");
            KLog(@"Left the group successfully.");
            
        } failure:^(UpdateGroupAPI *req, NSError *error) {
            EnLogd(@"Unable to leave group");
            KLog(@"Unable to leave group");
            //error TODO
        }];
    }
}
#endif


-(void)deleteUnsentMessageWithGuid:(NSString*)guid
{
    KLog(@"Remove unsent message from the _pendingMsgQueue and delete it from DB. GUID = %@",guid);
    [self removeMsgFromQueue:guid];
    NSString *where = [NSString stringWithFormat:@"WHERE %@ = \"%@\"",MSG_GUID,guid];
    if(![_msgTableObj deleteFromTable:where tableType:MESSAGE_TABLE_TYPE]) {
        KLog(@"Error deleting the message. where = %@, GUID = %@",where,guid);
    }
    else {
        KLog(@"Message deleted. GUID = %@",guid);
    }
}


/* This function is used to Update a Message State after the response received from Server or sent to server.
 TODO -- When a msg is successfully delivered to the server, but n/w gets disconnected, before response from
         the server is received. In this case, the recipient will get the msg, but status of the msg at the sender side
         will remain NOT SENT. When n/w is connected and if fetch_msg API includes the info about the last message sent,
         then the status will be updated as SENT. Otherwise, it will be as UNSENT.
         -- Discuss with Ajay.
 */
-(void)updateMsgStateInDB:(NSString*)state msgDic:(NSMutableDictionary*)msgDic
{
    if(msgDic != nil)
    {
        KLog(@"updateMsgStateInDB: %@",msgDic);
        [msgDic setValue:state forKey:MSG_STATE];
        NSString *guid = [msgDic valueForKey:MSG_GUID];
        EnLogd(@"Msg GUID: %@,  Msg content:  %@ ",guid,[msgDic valueForKey:MSG_CONTENT]);
        NSString *whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\"",MSG_GUID,guid];
        
        if(![_msgTableObj updateTable:msgDic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE])
        {
            EnLoge(@"Error in Message Updation");
        }
    }
}

//This function is used to Check Space in User Directory and Delete Older Msg File.
-(BOOL)checkSpaceAndDeleteMsgs
{
    BOOL bRet = FALSE;
    if(VALUE500MB < [IVFileLocator folderSize:[IVFileLocator getMediaAudioDirectory]])
    {
        EnLogd(@"Audio folder exceeds more than 500 MB");
        NSMutableArray *msgs = [self getOlderDownloadMsgListFrmDB];
        if(msgs != nil && [msgs count]>0)
        {
            long count = [msgs count];
            for (long i = 0; i < count; i++)
            {
                NSMutableDictionary *dic = [msgs objectAtIndex:0];
                NSString *path = [dic valueForKey:MSG_LOCAL_PATH];
                if([IVFileLocator deleteFileAtPath:path])
                {
                    [dic setValue:@"" forKey:MSG_LOCAL_PATH];
                    NSNumber *num = [NSNumber numberWithLongLong:0];
                    [dic setValue:num forKey:DOWNLOAD_TIME];
                    NSString *whereClause = [NSString stringWithFormat:@"WHERE %@ = \"%@\"",MSG_GUID,[dic valueForKey:MSG_GUID]];
                    if(![_msgTableObj updateTable:dic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE])
                    {
                        EnLoge(@"Error in Message Table Updation");
                    }
                    bRet = TRUE;
                }
            }
        }
    }
    
    return bRet;
}

-(NSMutableArray*)getOlderDownloadMsgListFrmDB
{
    NSString *orderBy = [NSString stringWithFormat:@"ORDER BY %@ LIMIT 10",DOWNLOAD_TIME];
    NSString *whereClause = [NSString stringWithFormat:@"WHERE %@ != 0 AND %@ = \"%@\"",DOWNLOAD_TIME,MSG_CONTENT_TYPE,AUDIO_TYPE];
    NSMutableArray *msgs = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:orderBy tableType:MESSAGE_TABLE_TYPE];
    return msgs;
}

#pragma mark -- Activity DB Processing
-(void)processChatActivity:(ChatActivityData*)activity
{
    switch (activity.activityType) {
        
        case ChatActivityTypeWithdraw:
            [self withdrawMessageActivity:activity];
            break;
            
        case ChatActivityTypeDelete:
            [self deleteMessageActivity:activity];
            break;
        
        case ChatActivityTypeLike:
        case ChatActivityTypeUnlike:
            [self likeUnlikeMessageActivity:activity];
            break;
            
        case ChatActivityTypeVoboloShare:
        case ChatActivityTypeFacebookShare:
        case ChatActivityTypeTwitterShare:
            [self shareMessageActivity:activity];
            break;
        
        case ChatActivityTypeReadMessage:
            [self readMessageCountActivity:activity MsgReadStatus:MessageReadStatusRead];
            break;
            
        case ChatActivityTypeSeenMessage:
            [self readMessageCountActivity:activity MsgReadStatus:MessageReadStatusSeen];
            break;
            
            
        case ChatActivityTypeSeenAllMsg:
            [self setAllMessagesAsSeen:activity];
            break;
            
        default:
            break;
    }
    
    [self refreshChatDataAndNotifyAllUI:NO];
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
    [resultDic setValue:[NSNumber numberWithInt:CHAT_ACTIVITY] forKey:EVENT_TYPE];
    [resultDic setValue:activity forKey:RESPONSE_DATA];
    [self notifyUI:resultDic];
}

-(void)withdrawMessageActivity:(ChatActivityData*)activity
{
    //delete from msgTable where msg_id = '' or msg_guid = '';
    NSString *whereClause;
    if(activity.msgId > 0)
    {
        whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%ld\"",MSG_ID ,activity.msgId];
    }
    else
    {
        whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\"",MSG_GUID,activity.msgGuid];
    }
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setValue:MSG_WITHDRAWN_TEXT forKey:MSG_CONTENT];
    [dic setValue:TEXT_TYPE forKey:MSG_CONTENT_TYPE];
    [dic setValue:API_WITHDRAWN forKey:MSG_STATE];
    [dic setValue:IV_TYPE forKey:MSG_TYPE];
    [dic setValue:@"" forKey:MSG_SUB_TYPE];
    if(![_msgTableObj updateTable:dic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE])
    {
        KLog(@"Error updating the msg: %@",whereClause);
        EnLoge(@"Error updating the msg");
    }
}

-(void)deleteMessageActivity:(ChatActivityData*)activity
{
    //delete from msgTable where msg_id = '' or msg_guid = '';
    NSString *whereClause;
    if(activity.msgId > 0)
    {
        whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%ld\"",MSG_ID ,activity.msgId];
    }
    else
    {
        whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\"",MSG_GUID,activity.msgGuid];
        KLog(@"Remove msg from _pendingMsgQue.");
        [self removeMsgFromQueue:activity.msgGuid];
    }
    if(![_msgTableObj deleteFromTable:whereClause tableType:MESSAGE_TABLE_TYPE])
    {
        KLog(@"Error deleting the msg: %@",whereClause);
        EnLoge(@"Error in Message Deletion");
    }
}

-(void)likeUnlikeMessageActivity:(ChatActivityData *)activity
{
    NSNumber *msgID = [NSNumber numberWithInteger:activity.msgId];
    
    NSString *whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ = \"%@\"",MSG_ID,msgID];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if(activity.activityType == ChatActivityTypeLike)
    {
        [dic setValue:[NSNumber numberWithBool:YES] forKey:MSG_LIKED];
    }
    else
    {
        [dic setValue:[NSNumber numberWithBool:NO] forKey:MSG_LIKED];
    }
    
    if(![_msgTableObj updateTable:dic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE])
    {
        EnLoge(@"Error in Message Updation");
    }
}

-(void)shareMessageActivity:(ChatActivityData *)activity
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSNumber *msgId = [NSNumber numberWithInteger:activity.msgId];
    
    if(activity.activityType == ChatActivityTypeFacebookShare)
    {
        [dic setValue:[NSNumber numberWithBool:YES] forKey:MSG_FB_POST];
    }
    else if(activity.activityType == ChatActivityTypeTwitterShare)
    {
        [dic setValue:[NSNumber numberWithBool:YES] forKey:MSG_TW_POST];
    }
    else if(activity.activityType == ChatActivityTypeVoboloShare)
    {
        [dic setValue:[NSNumber numberWithBool:YES] forKey:MSG_VB_POST];
    }
    
    NSString *whereClause = [[NSString alloc] initWithFormat:@"WHERE %@ =\"%@\"",MSG_ID,msgId];
    if(![_msgTableObj updateTable:dic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE])
    {
        EnLoge(@"Error in Message updation");
    }
}

-(void)readMessageCountActivity:(ChatActivityData *)activity MsgReadStatus:(MessageReadStatus)readStatus
{
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
    [newDic setValue:[NSNumber numberWithInt:readStatus] forKey:MSG_READ_CNT];
    
    for(NSNumber* msgID in activity.msgDataList) {
        NSString *whereClause = [NSString stringWithFormat:@"WHERE %@ = \"%@\"",MSG_ID,msgID];
        if(![_msgTableObj updateTable:newDic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE])
        {
            EnLogd(@"Error updating MSG TABL for MSG_READ_CNT. MSG ID=%@",msgID);
        }
    }
    
    [self getMissedCallList:YES];
    [self getVoicemailList:YES];
    [self getActiveConversationList:YES];
}

//APR, 2017
-(void)setAllMessagesAsSeen:(ChatActivityData*)activity
{
    KLog(@"setAllMessagesAsSeen - START");
    
    NSString* ivUserID = nil;
    NSString* fromUserID = nil;
    NSString* convType = nil;
    if(nil != activity.dic) {
        ivUserID = [activity.dic valueForKey:REMOTE_USER_IV_ID];
        fromUserID = [activity.dic valueForKey:FROM_USER_ID];//FROM_USER_ID containns group ID in case of group msg
        convType = [activity.dic valueForKey:CONVERSATION_TYPE];
    }
    
    
    if(ivUserID.length && [ivUserID longLongValue]>0) {
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
        [newDic setValue:[NSNumber numberWithInt:MessageReadStatusSeen] forKey:MSG_READ_CNT];
        //- "where FROM_USER_ID=ivUserID AND MSG_READ_CNT==0 AND MSG_FLOW_R=='r'
        NSString* whereClause = [NSString stringWithFormat:@"WHERE (%@=\"%@\" OR %@=\"%@\") AND %@=0 AND %@=\"%@\"",FROM_USER_ID,fromUserID,REMOTE_USER_IV_ID,ivUserID, MSG_READ_CNT,MSG_FLOW,MSG_FLOW_R];
        if(![_msgTableObj updateTable:newDic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE])
        {
            EnLogd(@"Error updating MSG_READ_CNT with seen-status");
        }
    }
    else if([convType isEqualToString:GROUP_TYPE]) {
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
        [newDic setValue:[NSNumber numberWithInt:MessageReadStatusSeen] forKey:MSG_READ_CNT];
        //- "where FROM_USER_ID=ivUserID AND MSG_READ_CNT==0 AND MSG_FLOW_R=='r'
        //- ivUserID is group id
        NSString* whereClause = [NSString stringWithFormat:@"WHERE (%@=\"%@\") AND %@=0 AND %@=\"%@\"",FROM_USER_ID,fromUserID, MSG_READ_CNT,MSG_FLOW,MSG_FLOW_R];
        if(![_msgTableObj updateTable:newDic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE])
        {
            EnLogd(@"Error updating MSG_READ_CNT with seen-status");
        }
    }
    
    KLog(@"setAllMessagesAsSeen - END");
}
//

#pragma mark -- MQTT Data Received.
-(void)processMQTTReceivedData:(MQTTReceivedData*)data
{
    isPushNotification = NO;
    switch (data.dataType) {
        case MQTTReceivedDataTypeFetchMessage:
        {
            [self processMessageResponseFromServer:data.responseData forEventType:FETCH_MSG requestDic:data.requestData];
            NSNumber *lastMsgId = [data.responseData valueForKey:API_LAST_FETCHED_MSG_ID];
            if(lastMsgId.longValue > 0)
                [appDelegate.confgReader setAfterMsgId:[lastMsgId longValue]];
            
            //KLog(@"AVN___LAST_MSG_ID After processMQTTReceivedData = %ld",[appDelegate.confgReader getAfterMsgId]);
        }
            break;
        case MQTTReceivedDataTypeFetchMessageAsNotification:
        {
            isPushNotification = YES;
            [self processMessageResponseFromServer:data.responseData forEventType:FETCH_MSG requestDic:data.requestData];
        }
            break;
            
#ifdef TRANSCRIPTION_ENABLED
        case MQTTReceivedDataTypeTranscriptionStatusAndText:
        {
            isPushNotification = NO;
            [self processMessageResponseFromServer:data.responseData forEventType:VOICE_MESSAGE_TRANSCRIPTION_TEXT requestDic:data.requestData];
        }
            break;
#endif
            
        case MQTTReceivedDataTypeFetchMessageAsBackgroundNotification:
        {
            isPushNotification = YES;
            [self processMessageResponseFromServer:data.responseData forEventType:FETCH_MSG requestDic:data.requestData];
            NSNumber *lastMsgId = [data.responseData valueForKey:API_LAST_FETCHED_MSG_ID];
            if(lastMsgId.longValue > 0)
                [appDelegate.confgReader setAfterMsgId:[lastMsgId longValue]];
            //MAR 14, 2018 TODO -- Is it required to call markCompletionOfDataDownload?
            //TODO March 30, 2018
            //[self performSelectorOnMainThread:@selector(markCompletionOfDataDownload) withObject:nil waitUntilDone:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self markCompletionOfDataDownload];
            });
            break;
        }
        case MQTTReceivedDataTypeFetchMessageActivity:
        {
            [self processActivityData:data.responseData forEventType:FETCH_MSG_ACTIVITY];
            NSNumber *lastActivityId = [data.responseData valueForKey:API_LAST_FETCH_MSG_ACTIVITY_ID];
            if(lastActivityId.longValue > 0)
                [appDelegate.confgReader setAfterMsgActivityId:[lastActivityId longValue]];
        }
            break;
        case MQTTReceivedDataTypeFetchMessageActivityAsNotification:
        {
            NSMutableDictionary* activity = [[NSMutableDictionary alloc]init];
            [activity setValue:[NSArray arrayWithObject:data.responseData] forKey:API_MSG_ACTIVITIES];
            [self processActivityData:activity forEventType:FETCH_MSG_ACTIVITY];
        }
            break;
        case MQTTReceivedDataTypeSendMessage:
        {
            MQTTErrorType errorType = data.errorType;
            if(errorType == MQTTErrorTypeReadReceiptSendFailedTimeoutError)
            {
                KLog(@"Received MQTTErrorTypeReadReceiptSendFailedTimeoutError.");
                if(_pendingMsgQueue != nil && [_pendingMsgQueue count] >0)
                {
                    NSMutableDictionary* dic = [_pendingMsgQueue objectAtIndex:0];
                    KLog(@"Update the status of the failed msg in DB.");
                    [self updateMsgStateInDB:API_UNSENT msgDic:dic];
                }
            }
            else
            {
                KLog(@"Received MQTT status = %ld.", (long)errorType);
                NSString* sentMsgGuid = [data.requestData valueForKey:API_GUID];
                NSMutableDictionary *msgDic = nil;
                if(_pendingMsgQueue != nil && [_pendingMsgQueue count]>0)
                {
                    KLog(@"Msg Sent. Remove it from _pendingMsgQueue. GUID = %@",sentMsgGuid);
                    msgDic = [self removeMsgFromQueue:sentMsgGuid];
                    //NOV 2017
                    if(msgDic) {
                        [msgDic setValue:API_DELIVERED forKey:MSG_STATE];
                        KLog(@"Sent msg via MQTT: %@",[msgDic valueForKey:MSG_CONTENT]);
                    }
                    //
                } else {
                    KLog(@"*** CHECK");
                }
                if(!msgDic.count) {
                    KLog(@"*** CHECK");
                }
#ifndef REACHME_APP
                [self leaveGroup:msgDic];
#endif
                [self processMessageResponseFromServer:data.responseData forEventType:SEND_MSG requestDic:msgDic];
            }
            [self sendAllMsg];
        }
            break;
            
        case MQTTReceivedDataTypeSendReadReceipt:
        {
            
        }
            break;
        case MQTTReceivedDataTypePendingEvent:
            break;
        default:
            break;
    }
}

-(void)markCompletionOfDataDownload
{
    [[Conversations sharedConversations]markCompletionOfDataDownload:YES];
}

-(void)processActivityData:(NSMutableDictionary*)responseData forEventType:(NSInteger)eventType
{
    NSArray* activityList = [responseData valueForKey:API_MSG_ACTIVITIES];
    NSMutableArray* listOfMsgRead = [[NSMutableArray alloc]init];
    if(activityList != nil && [activityList count]>0)
    {
        for(NSDictionary *msgActivity in activityList)
        {
            NSDictionary* updDic = [self updateMsgActivityInDBAndList:msgActivity ResponseData:(NSMutableDictionary*) responseData];
            NSString *activityType = [msgActivity valueForKey:API_ACTIVITY_TYPE];
            if(!activityType.length)
                activityType = [msgActivity valueForKey:API_ACTIVITY];
            
            KLog(@"processActivityData:%@",activityType);
            ChatActivityData* data = [[ChatActivityData alloc]init];
            BOOL notify = true;
            if([activityType isEqualToString:API_LISTEN])
            {
                data.activityType = ChatActivityTypeReadMessage;
                data.msgGuid = [msgActivity valueForKey:@"msg_guid"];
            }
            else if([activityType isEqualToString:API_LIKE])
            {
                data.activityType = ChatActivityTypeLike;
            }
            else if([activityType isEqualToString:API_UNLIKE])
            {
                data.activityType = ChatActivityTypeUnlike;
            }
            else if([activityType isEqualToString:API_DELETE]) {
                data.activityType = ChatActivityTypeDelete;
                NSString* reason = [msgActivity valueForKey:API_REASON];
                if([reason length] && ([reason isEqualToString:API_REVOKE] || [reason containsString:API_REVOKE]))
                    data.activityType = ChatActivityTypeWithdraw;
                
                KLog(@"Delete msg. msg_id = %@",API_MSG_ID);
            }
            else if([activityType isEqualToString:API_MC_OK]) {
                data.activityType = ChatActivityTypeRing;
            }
            else if ([activityType isEqualToString:API_MC_ERROR]) {
                data.activityType = ChatActivityTypeRing;
                data.dic = [[NSMutableDictionary alloc]initWithDictionary:updDic];
            }
            else
            {
                notify = false;
            }
            if(notify)
            {
                data.msgId = [[msgActivity valueForKey:API_MSG_ID]longLongValue];
                [listOfMsgRead addObject:data];
            }
        }
    }
    //Notify read receipt to UI.
    if(listOfMsgRead.count && eventType != FETCH_OLDER_MSG)
    {
        //only listen receipt will be notified in case of fetch message or send message response
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:listOfMsgRead forKey:RESPONSE_DATA];
        [dic setValue:[NSNumber numberWithInt:NOTIFY_UI_ON_ACTIVITY] forKey:EVENT_TYPE];
        [dic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
        [self notifyUI:dic];
    }
}

-(void)setAudioDownloadStatus:(NSString*)status Info:(NSMutableDictionary*)dic
{
    NSString* msgID = [dic valueForKey:API_MSG_ID];
    
    if(!msgID) {
        msgID = [dic valueForKey:MSG_ID];
    }
    
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
    [newDic setValue:status forKey:MSG_STATE];
    NSString* whereClause = [[NSString alloc]initWithFormat:@"WHERE %@ IN (%@) ", MSG_ID, msgID];
    if(![_msgTableObj updateTable:newDic whereClause:whereClause tableType:MESSAGE_TABLE_TYPE]) {
        KLog(@"setAudioDownloadStatus: DB update failed");
    } else {
         KLog(@"setAudioDownloadStatus: DB updated.");
    }
}

-(NSMutableDictionary*)isAudioAvailable:(NSMutableDictionary*)dic
{
    NSString* msgID = [dic valueForKey:API_MSG_ID];
    
    if(!msgID) {
        msgID = [dic valueForKey:MSG_ID];
    }
    
    KLog(@"isMessageAvailable -- msgID: %@", msgID);
    
    NSString* whereClause = [[NSString alloc]initWithFormat:@"WHERE %@ IN (%@) ", MSG_ID, msgID];
    NSMutableArray *arr = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:nil tableType:MESSAGE_TABLE_TYPE];
    if(arr && [arr count]) {
        NSMutableDictionary* resDic = [arr objectAtIndex:0];
        if(resDic && [resDic count]) {
            if([[resDic valueForKey:MSG_CONTENT_TYPE] isEqualToString:AUDIO_MSG_TYPE]) {
                NSString* msgLocalPath = [resDic valueForKey:MSG_LOCAL_PATH];
                if([msgLocalPath length]) {
                    return resDic;
                }
            } else {
                KLog(@"***ERROR: Undefined msg_content_type");
            }
        }
    }
    
    return nil;
}

-(BOOL)isMessageAvailable:(NSMutableDictionary*)dic OutMessage:(NSMutableDictionary*)outDic
{
    NSString* msgID = [dic valueForKey:API_MSG_ID];
    
    if(!msgID) {
        msgID = [dic valueForKey:MSG_ID];
    }
    
    KLog(@"isMessageAvailable -- msgID: %@", msgID);
    
    NSString* whereClause = [[NSString alloc]initWithFormat:@"WHERE %@ IN (%@) ", MSG_ID, msgID];
    NSMutableArray *arr = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:nil tableType:MESSAGE_TABLE_TYPE];
    
    if(!msgID || ![arr count]) {
        
        NSString* msgGUID = [dic valueForKey:API_GUID];
        if(!msgGUID) {
            msgGUID = [dic valueForKey:MSG_GUID];
        }
        whereClause = [[NSString alloc]initWithFormat:@"WHERE %@ = \"%@\" ", MSG_GUID, msgGUID];
        arr = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:nil tableType:MESSAGE_TABLE_TYPE];
    }
    
    if(arr && [arr count]) {
        NSDictionary* resDic = [arr objectAtIndex:0];
        //FEB 20, 2017
        if(outDic)
            [outDic addEntriesFromDictionary:resDic];
        //
        if(resDic && [resDic count]) {
            if([[resDic valueForKey:MSG_CONTENT_TYPE] isEqualToString:TEXT_MSG_TYPE]) {
                return YES;
            }
            if([[resDic valueForKey:MSG_CONTENT_TYPE] isEqualToString:IMAGE_TYPE]) {
                return YES;
            }
            else if([[resDic valueForKey:MSG_CONTENT_TYPE] isEqualToString:AUDIO_MSG_TYPE]) {
                return YES;
            } else {
                KLog(@"***ERROR: Undefined msg_content_type");
            }
        }
    }
    
    KLog(@"msg = %@",arr);
    return NO;
}

-(BOOL)isMessageAvailableWithGuid:(NSMutableDictionary*)dic
{
    NSString* msgGUID = [dic valueForKey:API_GUID];
    
    if(!msgGUID) {
        msgGUID = [dic valueForKey:MSG_GUID];
    }
    
    //KLog(@"isMessageAvailable -- msgGUID: %@", msgGUID);
    
    //NSString* whereClause = [[NSString alloc]initWithFormat:@"WHERE %@ IN (%@)", MSG_GUID, msgGUID];
    NSString* whereClause = [[NSString alloc]initWithFormat:@"WHERE %@ = \'%@\'", MSG_GUID, msgGUID];
    NSMutableArray *arr = [_msgTableObj queryTable:nil whereClause:whereClause groupBy:nil having:nil orderBy:nil tableType:MESSAGE_TABLE_TYPE];
    if(arr && [arr count]) {
        NSDictionary* resDic = [arr objectAtIndex:0];
        if(resDic && [resDic count]) {
            if([[resDic valueForKey:MSG_CONTENT_TYPE] isEqualToString:TEXT_MSG_TYPE]) {
                return YES;
            }
            if([[resDic valueForKey:MSG_CONTENT_TYPE] isEqualToString:IMAGE_TYPE]) {
                return YES;
            }
            else if([[resDic valueForKey:MSG_CONTENT_TYPE] isEqualToString:AUDIO_MSG_TYPE]) {
                return YES;
            } else {
                KLog(@"***ERROR: Undefined msg_content_type");
            }
        }
    }
    
    //KLog(@"msg = %@",arr);
    return NO;
}

-(void)addMessageHeader:(NSMutableDictionary*)dic
{
    KLog(@"addMessageHeader. dic = %@",dic);
    EnLogd(@"addMessageHeader. dic = %@",dic);
    
    NSMutableDictionary* newDic = [[NSMutableDictionary alloc] init];
    [newDic setValue:[[ConfigurationReader sharedConfgReaderObj] getLoginId] forKey:LOGGEDIN_USER_ID];
    NSNumber* msgID = [NSNumber numberWithLong:[[dic valueForKey:API_MSG_ID]longLongValue]];
    [newDic setValue: msgID forKey:MSG_ID];
    [newDic setValue:[dic valueForKey:API_MSG_DT] forKey:MSG_DATE];
    [newDic setValue:[dic valueForKey:MSG_TYPE] forKey:MSG_TYPE];
    
    NSString* msgSubType = [dic valueForKey:API_SUBTYPE];
    NSString* msgContentType = [dic valueForKey:@"msg_content_type"];
    
    if( msgSubType && [msgSubType isEqualToString:AVS_TYPE] && [msgContentType isEqualToString:@"t"])
        [newDic setValue:@"mc" forKey:MSG_TYPE];
    else if (msgSubType && [msgSubType isEqualToString:AVS_TYPE] && [msgContentType isEqualToString:@"a"])
        [newDic setValue:@"vsms" forKey:MSG_TYPE];
    else if (msgSubType && [msgSubType isEqualToString:VSMS_TYPE] && [msgContentType isEqualToString:@"a"])
        [newDic setValue:@"vsms" forKey:MSG_TYPE];
    else if (msgSubType && [msgSubType isEqualToString:RING_MC] && [msgContentType isEqualToString:@"t"])
        [newDic setValue:MISSCALL forKey:MSG_TYPE];
    else
        [newDic setValue:IV_TYPE forKey:MSG_TYPE];
    
    
    [newDic setValue:MSG_FLOW_R forKey:MSG_FLOW];
    
    NSString *ividStr = [[NSString alloc] initWithFormat:@"%ld",[[ConfigurationReader sharedConfgReaderObj] getIVUserId]];
    NSString *contactId = [dic valueForKey:API_CONTACT_ID];
    if(![contactId isEqualToString:ividStr])
    {
        NSString *contactType = [dic valueForKey:API_CONTACT_TYPE];
        if([contactType isEqualToString:IV_TYPE])
        {
            [newDic setValue:contactId forKey:REMOTE_USER_IV_ID];
            [newDic setValue:contactType forKey:REMOTE_USER_TYPE];
        }
        else
        {
            [newDic setValue:contactId forKey:FROM_USER_ID];
            [newDic setValue:@"" forKey:REMOTE_USER_IV_ID];
            [newDic setValue:contactType forKey:REMOTE_USER_TYPE];
        }
    }

    NSString* fromUserId = [dic valueForKey:API_PHONE];
    if(fromUserId.length)
        [newDic setValue:fromUserId forKey:FROM_USER_ID];
    
    NSString* senderId = [dic valueForKey:API_SENDER_ID];
    if(senderId.length)
        [newDic setValue:senderId forKey:REMOTE_USER_NAME];
    
    
    [newDic setValue:[dic valueForKey:@"msg_content_type"] forKey:MSG_CONTENT_TYPE];
    
    NSString* msgContent = [dic valueForKey:@"content"];
    if(!msgContent) {
        msgContent = [dic valueForKey:@"msg_uri"];
    }
    [newDic setValue:msgContent forKey:MSG_CONTENT];
    
    if(msgContentType) {
        [newDic setValue:[dic valueForKey:@"msg_format"] forKey:MEDIA_FORMAT];
    }
    
    if([dic valueForKey:API_DURATION] != nil)
        [newDic setValue:[dic valueForKey:API_DURATION] forKey:DURATION];
    else
        [newDic setValue:[NSNumber numberWithInt:0] forKey:DURATION];
    
    [newDic setValue:API_DELIVERED forKey:MSG_STATE];
    [newDic setValue:[NSNumber numberWithInt:MessageReadStatusUnread] forKey:MSG_READ_CNT];
    
    // Missed call and AVS handling
    //
    NSString* type = [dic valueForKey:API_MSG_CONTENT_TYPE];
    if(([msgSubType isEqualToString:AVS_TYPE] || [msgSubType isEqualToString:VSMS_TYPE]) &&
       ([type isEqualToString:VSMS_TYPE] || [type isEqualToString:MISSCALL]))
    {
            NSString* phoneNumber = @"";
            [newDic setValue:[[ConfigurationReader sharedConfgReaderObj] getLoginId] forKey:NATIVE_CONTACT_ID];
           
            phoneNumber = [dic valueForKey:API_PHONE];
            if(phoneNumber.length)
                    [newDic setValue:phoneNumber forKey:FROM_USER_ID];
    }
    
    // Group message handling
    //
    [newDic setValue:msgSubType forKey:MSG_SUB_TYPE];
    [newDic setValue:@"" forKey:CONVERSATION_TYPE];
    if(msgSubType != Nil && ([msgSubType isEqualToString:GROUP_MSG_TYPE] || [msgSubType isEqualToString:GROUP_MSG_EVENT_TYPE]))
    {
        //Set native contact id as the phone number of user sending the message.
        NSString* fromPhoneNum = [dic valueForKey:API_PHONE];
        if(fromPhoneNum.length)
            [newDic setValue:fromPhoneNum forKey:NATIVE_CONTACT_ID];
        
        [newDic setValue:[dic valueForKey:@"group_id"] forKey:FROM_USER_ID];
        [newDic setValue:@"0" forKey:REMOTE_USER_IV_ID];
        [newDic setValue:GROUP_TYPE forKey:CONVERSATION_TYPE];
        
        [newDic setValue:[dic valueForKey:API_CONTACT_TYPE] forKey:REMOTE_USER_TYPE];
        [newDic setValue:[dic valueForKey:API_MSG_CONTENT_TYPE] forKey:MSG_TYPE];
    }
    //
    
    NSMutableArray* msg = [[NSMutableArray alloc]initWithObjects:newDic, nil];
    KLog(@"newDic = %@", newDic);
    
    if(![_msgTableObj insertInTable:msg tableType:MESSAGE_TABLE_TYPE]) {
        EnLogd(@"Error in Message Insertion. msg=%@",msg);
        KLog(@"Error in Message Insertion");
    } else {
        KLog(@"Message Inserted.%@",[dic valueForKey:API_MSG_ID]);
        EnLogd(@"Message Inserted.%@",[dic valueForKey:API_MSG_ID]);
    }
    
    if(msg.count)
    {
        [self createActiveConversation:nil];
        [self notifyUiWithData:msg forEventType:FETCH_MSG];
    }
    
    //DEC 2017
    if([msgContentType isEqualToString:IMAGE_TYPE] ||
       [msgContentType isEqualToString:AUDIO_TYPE]) {
        KLog(@"Call fetchMsgRequest");
        EnLogd(@"Call fetchMsgRequest");
        [[Engine sharedEngineObj]fetchMsgRequest:nil];
    }
    //
}

-(void)sendAppStatus:(NSMutableDictionary*)dic
{
    NSMutableDictionary* evDic = [[NSMutableDictionary alloc]init];
    NSMutableDictionary* msgDic = [[NSMutableDictionary alloc]initWithDictionary:dic];
    [self addCommonData:msgDic eventType:APP_STATUS];
    [evDic setValue:msgDic forKey:REQUEST_DIC];
    
    KLog(@"Sending app status via HTTP. Req dic = %@",evDic);
    EnLogd(@"Sending app status via HTTP. Req dic = %@",evDic);
    [self eventToNetwork:SEND_APP_STATUS eventDic:evDic];
}

-(void)handleAppStatusResponse:(NSMutableDictionary*)dic
{
    NSString *responseCode = [dic valueForKey:RESPONSE_CODE];
    if([responseCode isEqualToString:NET_SUCCESS]) {
        NSDictionary *responseData = [dic valueForKey:RESPONSE_DATA];
        NSDictionary *reqstDic = [dic valueForKey:REQUEST_DIC];
        
        double mid = [[responseData valueForKey:@"mid"]doubleValue];
        NSString* pendingEvents = [responseData valueForKey:@"pending_events"];
        NSString* additionalEvent = [responseData valueForKey:@"events"];
        
        long skipId = [[reqstDic valueForKey:API_MSG_ID]longValue];
        
        KLog(@"Calling processPendingEvent... skipId = %ld, pendingEvents = %@, additionalEvents = %@, mid=%lf",skipId,pendingEvents,additionalEvent,mid);
        EnLogd(@"Calling processPendingEvent... skipId = %ld, pendingEvents = %@, additionalEvents = %@, mid = %lf",skipId,pendingEvents,additionalEvent,mid);
        
        [[MQTTManager sharedMQTTManager] processPendingEvent:pendingEvents withAdditionalEvent:additionalEvent skipId:skipId atTime:mid];
    }
}

-(void)handleDeleteChats:(NSArray*)thePhoneNumList
{
    for(NSString* phoneNumber in thePhoneNumList) {
        NSString *where = [NSString stringWithFormat:@"WHERE %@ = \"%@\"",FROM_USER_ID,phoneNumber];
        if(![_msgTableObj deleteFromTable:where tableType:MESSAGE_TABLE_TYPE]) {
            KLog(@"Error deleting chats. whereClause = %@",where);
        }
        else {
            KLog(@"All chats were deleted for the contact = %@",phoneNumber);
        }
    }
}

#pragma mark Utility

-(NSString*)jsonStringFromDictionary:(NSDictionary*)dic WithPrettyPrint:(BOOL)prettyPrint {
    
    KLog(@"dic = %@",dic);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:(NSJSONWritingOptions)(prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (!jsonData) {
        KLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

-(NSDictionary*)dictionaryFromJsonString:(NSString*)jsonString {
    
    KLog(@"jsonString = %@",jsonString);
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    return json;
}

#ifdef REACHME_APP
//- CHeck wthether the message is a valid message for the ReachMe app.
-(BOOL)IsValidMessage:(NSDictionary*)message
{
    KLog(@"IsValidMessage");
    NSString* msgType = [message valueForKey:MSG_TYPE];
    NSString* msgSubType = [message valueForKey:MSG_SUB_TYPE];
    NSUInteger remoteUserIvId = [[message valueForKey:REMOTE_USER_IV_ID]integerValue];
    //NSString* msgFlow = [message valueForKey:MSG_FLOW];
    NSUInteger helpChatIvId = [[ConfigurationReader sharedConfgReaderObj]getHelpChatIvId];
    NSUInteger suggestChatIvId = [[ConfigurationReader sharedConfgReaderObj]getSuggestionChatIvId];
    /*
    if([[message valueForKey:MSG_ID]integerValue]==8653313 ||
       [[message valueForKey:MSG_ID]integerValue]==8653312) {
        KLog(@"");
    }*/
    
    if([msgType isEqualToString:IV_TYPE] && (remoteUserIvId == helpChatIvId || remoteUserIvId == suggestChatIvId)) {
        return YES;
    }
    else if([msgType isEqualToString:VSMS_TYPE] ||
            [msgType isEqualToString:VOIP_TYPE] ||
            [msgType isEqualToString:VOIP_OUT]) {
        return YES;
    }
    else if([msgType isEqualToString:MISSCALL] && [msgSubType isEqualToString:AVS_TYPE]) {
        return YES;
    }
    
    return NO;
}
#endif


@end