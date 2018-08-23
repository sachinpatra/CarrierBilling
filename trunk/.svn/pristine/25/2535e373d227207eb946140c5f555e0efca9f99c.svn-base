//
//  Engine.m
//  InstaVoice
//
//  Created by Eninov on 10/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "Engine.h"
#import "Common.h"
#import "EventType.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif

#import "NotificationIds.h"
#import "ConversationApi.h"
#import "TableColumns.h"
#import "ContactsApi.h"
#import "MyProfileApi.h"
#import "HttpConstant.h"
#import "Setting.h"
#import "Profile.h"
#import "CoreDataSetup.h"
#import "Contacts.h"
#import "ChatActivity.h"
#import "Conversations.h"
#import "MQTTReceivedData.h"
#import "ScreenUtility.h"
#import "NetworkCommon.h"
#import "InsideConversationScreen.h"
#import "IVFileLocator.h"
#import "ChatsCommon.h"

#ifdef REACHME_APP
#define kMaxCallChargeValuesCached  99
#define kMinDurationForUserRating   10  //in seconds
#import "ReachMe-Swift.h"
#import "InsideConversationScreen.h"
#import "FetchObdDebitPolicyAPI.h"
#import "DebitRates.h"
#endif

static Engine *engObj = nil;

@interface Engine()
#ifdef REACHME_APP
@property (atomic) NSMutableArray* callCharges;
#endif

@end

@implementation Engine

+(Engine *)sharedEngineObj
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engObj = [[Engine alloc]init];
    });
    return engObj;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        [self start];
        appDelegate = (AppDelegate *)APP_DELEGATE;
        conversationObj = [Conversation sharedConversationObj];
        self.eventQueueSize = 0;
#ifdef REACHME_APP
        callLogMgr = [[CallLogMgr alloc]init];
#endif
    }
    return self;
}

-(int)addEvent:(NSMutableDictionary *)evObj
{
    self.eventQueueSize+=1;
        
    return [super addEvent:evObj];
}

-(void)cancelEvent
{
    [super cancelEvent];
}

-(int)handleEvent:(NSMutableDictionary *)evObj
{
    self.eventQueueSize -= 1;
    
    int result = FAILURE;
    
    @autoreleasepool
    {
        
        if(evObj != nil)
        {
            /* Crashlytics: #1425 @78
             Fatal Exception: NSUnknownKeyException
             */
            NSString *eventMode=nil;
            @try {
                eventMode = [evObj valueForKey:EVENT_MODE];
            } @catch (NSException *exception) {
                EnLogd(@"evObj=%@, Exception:%@",evObj, exception);
            }
            //  KLog(@"check handle event:%@",eventMode);
            if(eventMode != nil)
            {
                int eventType = [[evObj valueForKey:EVENT_TYPE] intValue];
                NSMutableDictionary *objDic = [evObj valueForKey:EVENT_OBJECT];
                if([eventMode isEqualToString:UI_EVENT])
                {
                    [self handleUIEvent:eventType dataObject:objDic];
                }
                else if([eventMode isEqualToString:NET_EVENT])
                {
                    [self handleNetEvent:eventType dataObject:objDic];
                }
                else
                {
                    // incorrect event mode
                }
            }
        }
    }
    
    return result;
}

-(int)handleUIEvent:(int)eventType dataObject:(NSMutableDictionary *)dataDic
{
    @autoreleasepool
    {
        BaseModel *modelObj = [self getModelObject:eventType];
        [modelObj handleUIEvent:eventType objectDic:dataDic];
    }
    
    return SUCCESS;
}


-(int)handleNetEvent:(int)eventType dataObject:(NSMutableDictionary *)dataDic
{
    @autoreleasepool
    {
        BaseModel *modelObj = [self getModelObject:eventType];
        [modelObj handleNetEvent:eventType objectDic:dataDic];
    }
    return SUCCESS;
}

-(BaseModel *)getModelObject:(int)eventType
{
    BaseModel *modelObj = NULL;
    switch (eventType)
    {
        case FETCH_OLDER_MSG:
        case DELETE_MSG_TABLE:
        case GET_ACTIVE_CONVERSATION_LIST:
        case GET_MISSEDCALL_LIST:
        case GET_VOICEMAIL_LIST:
        case GET_CURRENT_CHAT:
        case SEND_MSG:
        case SEND_MC:
        case SEND_VOIP_CALL_LOG:
        case SEND_APP_STATUS:
        case SEND_TEXT_MSG:
        case SEND_VOICE_MSG:
        case SEND_IMAGE_MSG:
        case DOWNLOAD_VOICE_MSG:
        case SEND_ALL_PENDDING_MSG:
        case STOP_SEND_MSG:
        case UPDATE_ACTIVITYIES:
        case FORWARD_MSG:
        case GET_NOTES:
        case GET_MYVOBOLO_MSG:
        case GET_CURRENT_CHAT_USER:
        case UPDATE_PLAY_DURATION:
        case GET_VSMS_LIMIT:
        case UPDATE_MSG_ON_CONTACT_SYNC:
        case MISS_CALL_GET_INFO:
        case FETCH_CELEBRITY_MSG:
        case CHANGE_USER_ID:
        case CHAT_ACTIVITY:
        case MQTT_DATA_RECEIVED:
        case PURGE_OLD_DATA:
        case ADD_MSG_HEADER:
        case DELETE_CHATS:
        case UPDATE_MISSEDCALL_REASON:
            modelObj = conversationObj;
            break;
        default:
            break;
    }
    return modelObj;
}

-(void)notifyUI:(NSMutableDictionary *)resultDic
{
    [appDelegate.stateMachineObj notifyUI:resultDic];
}

-(int)resetLoginData:(BOOL)isMainThread
{
    NSManagedObjectContext* moc = nil;
    if(isMainThread)
        moc = [AppDelegate sharedMainQueueContext];
    else
        moc = [AppDelegate sharedPrivateQueueContext];
    
    KLog(@"resetLoginData starts");
    [self resetDataForUploadContactAgain];
    [[Setting sharedSetting]resetSettingData];
    [[Profile sharedUserProfile]resetProfileData];
    [[ConfigurationReader sharedConfgReaderObj]setCloudSecureKey:@""];
    [[ConfigurationReader sharedConfgReaderObj]setABChangeSynced:YES];
    
    KLog(@"Clearing core data starts");
    [self deleteAllObjects:@"ContactData" usingContext:moc];
    [self deleteAllObjects:@"GroupMemberData" usingContext:moc];
    [self deleteAllObjects:@"ContactDetailData" usingContext:moc];
    //[[CoreDataSetup sharedCoredDataSetup] removeAllTables:moc];
    
    KLog(@"Clearing core data ends");
    KLog(@"resetLoginData ends");
#ifdef REACHME_APP
    LinphoneManager* instance = LinphoneManager.instance;
    [instance becomeActive];
#endif
    
    //FEB 22, 2018
    [self resetListOnLogout];
    [[ChatsCommon sharedChatsCommon] clearData];
    //
    
    return 0;
}

//- deleteAllObjects should be called from main thread only.
- (void) deleteAllObjects: (NSString *) entityDescription  usingContext:(NSManagedObjectContext*)moc {
    
    KLog(@"Delete all records from %@", entityDescription);
    EnLogd(@"Delete all records from %@", entityDescription);
    /* NOV 2017
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    */
    
    //
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityDescription];
    [request setIncludesSubentities:NO];
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    //
    
    [moc performBlockAndWait:^{
        
        @try {
            NSError *error;
            [moc reset];
            //[moc refreshAllObjects];
            [moc save:&error];
            
            //NOV 2017 NSArray *items = [moc executeFetchRequest:fetchRequest error:&error];
            [moc executeRequest:deleteRequest error:&error];
            /*
            for (NSManagedObject *managedObject in items) {
                [moc deleteObject:managedObject];
                KLog(@"%@ object deleted",entityDescription);
                EnLogd(@"%@ object deleted",entityDescription);
            }*/
            if (![moc save:&error]) {
                KLog(@"Error deleting %@ - error:%@",entityDescription,error);
                EnLogd(@"Error deleting %@ - error:%@",entityDescription,error);
            }
        } @catch(NSException* ex) {
            KLog(@"Exception occurred: %@",ex);
        }
    }];
}
//

-(void)resetDataForUploadContactAgain
{
    KLog(@"resetDataForUploadContactAgain starts");
    [[ConfigurationReader sharedConfgReaderObj]setShowContactUploadDlg:YES];
    [[Contacts sharedContact]resetContactRelatedFlags];
    [conversationObj resetConversations];
    KLog(@"resetDataForUploadContactAgain ends");
}

-(int)fetchMsgRequest:(NSDictionary *)dic
{
    //TODO: check for InstaVoice app
#ifdef REACHME_APP
    if([appDelegate.confgReader getIsLoggedIn])
#else
    if([appDelegate.confgReader getIsLoggedIn] && [appDelegate.confgReader getContactLocalSyncFlag])
#endif
    {
        [[Conversations sharedConversations]fetchMessageFromServerWithSkipMsgId:0 notificationDic:dic];
    }
    return 0;
}

-(int)fetchCelebrityMsgRequest:(NSDictionary *)dic
{
#ifdef REACHME_APP
    if([appDelegate.confgReader getIsLoggedIn])
#else
    if([appDelegate.confgReader getIsLoggedIn] && [appDelegate.confgReader getContactLocalSyncFlag])
#endif
    {
        NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
        [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
        [eventObj setValue:[NSNumber numberWithInt:FETCH_CELEBRITY_MSG] forKey:EVENT_TYPE];
        [eventObj setValue:dic forKey:EVENT_OBJECT];
        [self addEvent:eventObj];
    }
    return 0;
}

-(int)fetchOlderMsgRequest:(NSDictionary *)dic
{
#ifdef REACHME_APP
    if([appDelegate.confgReader getIsLoggedIn])
#else
    if([appDelegate.confgReader getIsLoggedIn] && [appDelegate.confgReader getContactLocalSyncFlag])
#endif
    {
        NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
        [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
        [eventObj setValue:[NSNumber numberWithInt:FETCH_OLDER_MSG] forKey:EVENT_TYPE];
        [eventObj setValue:dic forKey:EVENT_OBJECT];
        [self addEvent:eventObj];
    }
    return 0;
}

-(int)deleteMsgTable
{
    NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInt:DELETE_MSG_TABLE] forKey:EVENT_TYPE];
    [eventObj setValue:nil forKey:EVENT_OBJECT];
    
    return [self addEvent:eventObj];
}

-(NSMutableArray *)getActiveConversationList:(BOOL)isNewList
{
    return [conversationObj getActiveConversationList:isNewList];
}

-(NSMutableArray *)getMissedCallList:(BOOL)isNewList
{
    return [conversationObj getMissedCallList:isNewList];
}

-(NSMutableArray *)getVoicemailList:(BOOL)isNewList
{
    return [conversationObj getVoicemailList:isNewList];
}

-(void)setCurrentChatUser:(NSMutableDictionary*)infoList
{
    [conversationObj setCurrentChatUser:infoList];
}

-(NSMutableArray*)getCurrentChat
{
    return [conversationObj getCurrentChat];
}

-(int)sendMsg:(NSMutableDictionary*)message
{
    NSMutableDictionary* currentChatUser = [self getCurrentChatUser];
    [self sendMessage:message toChatUser:currentChatUser];
    return SUCCESS;
}

-(void)sendRingMissedCall:(NSMutableDictionary*)message
{
    NSMutableDictionary* currentChatUser = [self getCurrentChatUser];
    
    if(message != nil && [message count] >0)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:UI_EVENT forKey:EVENT_MODE];
        [dic setValue:[NSNumber numberWithInt:SEND_MC] forKey:EVENT_TYPE];
        NSMutableDictionary *newMsgDic = [Engine createMsgDic:message forChatUser:currentChatUser];
        
        [newMsgDic setValue:@"RING_MC" forKey:@"CMD"];
        
        [dic setValue:newMsgDic forKey:EVENT_OBJECT];
        [appDelegate.engObj addEvent:dic];
        
        KLog(@"Debug: %@",dic);
    }
}

#ifdef REACHME_APP
-(void)displayUserRatingOptions:(NSDictionary*)message CallType:(NSString*)callType {
    
    KLog(@"displayUserRatingOptions");
    int callDuration = [[message valueForKey:DURATION]intValue];
    if(LinphoneManager.instance.showUserRating && callDuration > kMinDurationForUserRating)
    {
        lastCallLog = [[NSDictionary alloc]initWithDictionary:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController* alert = [[UIAlertController alloc] initWithStyle:UIAlertControllerStyleAlert
                                                                         source:nil
                                                                          title:@"Rate your ReachMe call experience?"
                                                                        message:nil tintColor:nil];
            alert.view.tag = ratingAlertTag;
            UIAlertAction *skipButton = [alert addActionWithImage:nil
                                                            title:@"Skip"
                                                            color:[UIColor colorWithRed:210/255.0 green:0 blue:0 alpha:1.0] style:UIAlertActionStyleCancel
                                                        isEnabled:true handler:^(UIAlertAction* alertAction) {
                                                            [self sendVoipCallLog:message withUserRating:nil CallType:callType];
                                         }];
            
            
            __weak typeof(alert) weakAlert = alert;
            UIAlertAction* submitButton = [alert addActionWithImage:nil
                                                              title:@"Submit"
                                                              color:[UIColor colorWithRed:210/255.0 green:0 blue:0 alpha:1.0] style:UIAlertActionStyleDefault
                                                          isEnabled:false handler:^(UIAlertAction* alertAction)
                                           {
                                               
                                               __strong typeof(alert) strongAlert = weakAlert;
                                               RatingFeedbackTableController* ratingVC = (RatingFeedbackTableController*)[strongAlert valueForKey:@"contentViewController"];
                                               //NSLog(@"value = %@", ratingVC.infoList);
                                               NSMutableDictionary* info = nil;
                                               int count = (int)ratingVC.infoList.count;
                                               if(count>1) {
                                                   info = [[NSMutableDictionary alloc]init];
                                                   [info setValue:[ratingVC.infoList objectAtIndex:0] forKey:RATING_NUMBER];
                                                   [info setValue:[ratingVC.infoList objectAtIndex:1] forKey:USER_COMMENTS];
                                                   NSString* reason = @"";
                                                   for(int index=2; index<count; index++) {
                                                       reason = [reason stringByAppendingFormat:@"%@,",[ratingVC.infoList objectAtIndex:index]];
                                                   }
                                                   if(count>2) {
                                                       reason = [reason substringToIndex:[reason length]-1];
                                                   }
                                                   [info setValue:reason forKey:REASON_SELECTED];
                                               }
                                               [[Engine sharedEngineObj] sendVoipCallLog:message withUserRating:info CallType:callType];
                                           }];
            
            [alert addFeedbackControllerWithAlertButtons:[NSArray arrayWithObjects:skipButton, submitButton, nil]
                                                  action:^(NSArray<NSString*>* infoList) {} ];
            [alert showWithAnimated:true completion:nil];
        });
    }
    else {
        [self sendVoipCallLog:message withUserRating:nil CallType:callType];
    }
}

-(void)sendCallStatsLog
{
    KLog(@"sendCallStatsLog");
    
    if(callLogMgr) {
        [callLogMgr sendLog];
    }
}

-(void)sendLastCallLog {
    if(lastCallLog) {
        KLog(@"Debug");
        //[self sendVoipCallLog:lastCallLog withUserRating:nil];
    }
    lastCallLog = nil;
}

/*
 In message dic,
 PN_RECIEVED_AT key would have 0, when VOIP PN was not received till end of the connected call.
*/
-(void)sendVoipCallLog:(NSDictionary*)message withUserRating:(NSDictionary *)dicRating CallType:(NSString *)callType
{
    KLog(@"*** pushDict = %@",message);

    /*
    call_at -- time stamp
    status - accepted, rejected, missed
    duration - call duration in seconds
    GUID - call-id in voip push notification and append status_deviceid
    from_phone - caller phone number
    contact_ids -- from and to number from push notification
    pn_delay - delay in milliseconds. It is the difference between the time when pn receieved and value of "call_at" field
    quality - "quality; reason=1,2; comment =" (optional).
    header - optional.
    */
    
    if(message) {
        NSMutableDictionary* evDic = [[NSMutableDictionary alloc]init];
        NSMutableDictionary* voipDic = [[NSMutableDictionary alloc]initWithDictionary:message];
        [voipDic setValue:callType forKey:@"call_type"];
        NSString* status = [voipDic valueForKey:API_STATUS];
        if([status isEqualToString:VOIP_CALL_INCOMING]) {
            /*
             status = incoming; <— remote UA terminates when ringing.
             Status = incoming; <- local UA is not answering and call times out.
             Status = rejected; <— local UA terminates when ringing
             status = accepted; <- remotes UA terminates the connected call.
             status = accepted; <- local UA terminates the connected call.
             */
            [voipDic setValue:VOIP_CALL_MISSED forKey:VOIP_CALL_STATUS];
        }
        
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * SIZE_1000);
        NSNumber *date = [NSNumber numberWithLongLong:milliseconds];
        
        [evDic setValue:date forKey:MSG_DATE];
        [evDic setValue:TEXT_TYPE forKey:MSG_CONTENT_TYPE];
        
        if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE)
            [evDic setValue:API_NETUNAVAILABLE forKey:MSG_STATE];
        else
            [evDic setValue:API_INPROGRESS forKey:MSG_STATE];
        
        [evDic setValue:[self prepareGUID:voipDic] forKey:MSG_GUID];
        
        [evDic setValue:[appDelegate.confgReader getLoginId] forKey:LOGGEDIN_USER_ID];
        NSNumber* ivid = [voipDic valueForKey:REMOTE_USER_IV_ID];
        if([ivid integerValue]<=0) {
            [evDic setValue:PHONE_MODE forKey:REMOTE_USER_TYPE];
        } else {
            [evDic setValue:ivid forKey:REMOTE_USER_IV_ID];
            [evDic setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
        }
        [evDic setValue:[voipDic valueForKey:REMOTE_USER_NAME] forKey:REMOTE_USER_NAME];
        [evDic setValue:[voipDic valueForKey:REMOTE_USER_PIC] forKey:REMOTE_USER_PIC];
        [evDic setValue:@"ivc" forKey:SOURCE_APP_TYPE];
        
        if([callType isEqualToString:@"p2p"]) {
            //outgoing call
            [evDic setValue:SENDER_TYPE forKey:MSG_FLOW];
            [evDic setValue:VOIP_OUT forKey:MSG_TYPE];
        } else {
            [evDic setValue:RECEIVER_TYPE forKey:MSG_FLOW];
            [evDic setValue:VOIP_TYPE forKey:MSG_TYPE];
        }
        
        //- Remove + from from_phone of VOIP_CALL_DIC
        NSString* fromPhone = [voipDic valueForKey:FROM_PHONE];
        if(fromPhone.length) {
            NSString* trimmedFromName = [fromPhone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            trimmedFromName = [trimmedFromName stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
            if(trimmedFromName.length)
                [voipDic setValue:trimmedFromName forKey:FROM_PHONE];
        }
        
        if(dicRating.count) {
            KLog(@"dicRating");
            NSString* rating = [dicRating valueForKey:RATING_NUMBER];
            NSString* reason = [dicRating valueForKey:REASON_SELECTED];
            NSString* comments = [dicRating valueForKey:USER_COMMENTS];
            NSString* qualityString = [NSString stringWithFormat:@"%@; %@; %@",rating,reason,comments];
            [voipDic setValue:qualityString forKey:@"quality"];
        }
        
        if(([callType isEqualToString:@"p2p"] && LinphoneManager.instance.isReachMeHdrPresent) ||
           ([callType isEqualToString:@"gsm"] && !LinphoneManager.instance.isReachMeHdrPresent) ||
           ([callType isEqualToString:@"p2pin"] && !LinphoneManager.instance.isReachMeHdrPresent &&
           ![status isEqualToString:VOIP_CALL_ACCEPTED])) {
            [evDic setObject:voipDic forKey:VOIP_CALL_DIC];
            NSMutableDictionary* reqDic = [[NSMutableDictionary alloc] init];
            [reqDic setValue:UI_EVENT forKey:EVENT_MODE];
            [reqDic setValue:[NSNumber numberWithInt:SEND_VOIP_CALL_LOG] forKey:EVENT_TYPE];
            [reqDic setValue:evDic forKey:EVENT_OBJECT];
            [appDelegate.engObj addEvent:reqDic];
            KLog(@"*** reqParams = %@",reqDic);
        } else if(([callType isEqualToString:@"p2p"] && !LinphoneManager.instance.isReachMeHdrPresent) &&
                  ![status isEqualToString:VOIP_CALL_ACCEPTED]) {
            [evDic setObject:voipDic forKey:VOIP_CALL_DIC];
            NSMutableDictionary* reqDic = [[NSMutableDictionary alloc] init];
            [reqDic setValue:UI_EVENT forKey:EVENT_MODE];
            [reqDic setValue:[NSNumber numberWithInt:SEND_VOIP_CALL_LOG] forKey:EVENT_TYPE];
            [reqDic setValue:evDic forKey:EVENT_OBJECT];
            [appDelegate.engObj addEvent:reqDic];
            KLog(@"*** reqParams = %@",reqDic);
        } else if ([callType isEqualToString:@"p2pin"] && !LinphoneManager.instance.isReachMeHdrPresent &&
                   [status isEqualToString:VOIP_CALL_ACCEPTED]) {
            
            NSString* reason = [message valueForKey:API_REASON];
            if(![reason hasPrefix:@"p2p"]) {
                //Incoming reachme call
                [evDic setObject:voipDic forKey:VOIP_CALL_DIC];
                NSMutableDictionary* reqDic = [[NSMutableDictionary alloc] init];
                [reqDic setValue:UI_EVENT forKey:EVENT_MODE];
                [reqDic setValue:[NSNumber numberWithInt:SEND_VOIP_CALL_LOG] forKey:EVENT_TYPE];
                [reqDic setValue:evDic forKey:EVENT_OBJECT];
                [appDelegate.engObj addEvent:reqDic];
                KLog(@"*** reqParams = %@",reqDic);
            }
        }
        
        //if(dicRating.count)
        {
            NSString* callID = [voipDic valueForKey:@"call_id"];
            NSString* fromPhone = [voipDic valueForKey:@"from_phone"];
            NSString* toPhone = [voipDic valueForKey:@"to_phone"];
            if(fromPhone.length)
                callLogMgr.callerNumber = fromPhone;
            if(toPhone.length)
                callLogMgr.calledNymber = toPhone;
            
            [callLogMgr sendLogWithUserRating:dicRating forCallID:callID];
        }/*
        else {
            [callLogMgr sendLog];
        }*/
    }
    
    int uiType =  [[UIStateMachine sharedStateMachineObj]getCurrentUIType];
    if(INSIDE_CONVERSATION_SCREEN==uiType) {
        BaseUI* obj = [[UIStateMachine sharedStateMachineObj]getCurrentUI];
        if([obj isKindOfClass:[InsideConversationScreen class]]) {
            InsideConversationScreen* vc = (InsideConversationScreen*)obj;
            if([vc respondsToSelector:@selector(enableFirstResponder)])
               [vc enableFirstResponder];
        }
    }
}

/*
 If data is available, return the data immediately without fetching from server.
 Else fetch data from server asynchrnously. So, nil is expected in this case.
 */
 -(NSArray*)fetchObdDebitPolicy:(BOOL)forceFetch {
    
     KLog(@"fetchObdDebitPolicy - START");
     NSManagedObjectContext *managedObjectContext = [AppDelegate sharedPrivateQueueContext];
     NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"DebitRates"];
     //NSArray *result = [managedObjectContext executeFetchRequest:fetch error:nil];
     
     __block NSArray *result=nil;
     [managedObjectContext performBlockAndWait:^{
         NSError *error;
         @try {
             result = [managedObjectContext executeFetchRequest:fetch error:&error];
             if (result == nil) {
                 KLog(@"No Record Found");
                 result = [NSArray array];
             }
         } @catch(NSException* ex) {
             EnLogd(@"ERROR fetching debit rates");
         }
     }];
     
     if (result.count>0 && !forceFetch) {
         DebitRates *dbRates = [result objectAtIndex:0];
         //TODO: Do we need copy of the dbRates.debit_rates
         //NSArray* obdDebitRatesArray = [[NSArray alloc] initWithArray: dbRates.debit_rates];
         KLog(@"fetchObdDebitPolicy - END");
         //return obdDebitRatesArray;
         return dbRates.debit_rates;
     }
     
     FetchObdDebitPolicyAPI* api = [[FetchObdDebitPolicyAPI alloc]initWithRequest:nil];
     NSMutableDictionary* requestDic = [[NSMutableDictionary alloc] init];
     [api callNetworkRequest:requestDic withSuccess:^(FetchObdDebitPolicyAPI *req, NSMutableDictionary* responseObject) {
         NSArray *obdRatesArray = [responseObject valueForKey:@"obd_debit_policies"];
         DebitRates *obdRates = [NSEntityDescription insertNewObjectForEntityForName:@"DebitRates" inManagedObjectContext:managedObjectContext];
         obdRates.debit_rates = obdRatesArray;
         NSError *error = nil;
         if (![managedObjectContext save:&error]) {
             KLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
             EnLogd(@"Can't Save! %@ %@", error, [error localizedDescription]);
         } else {
             [self resetCallCharges];
             KLog(@"fetchObdDebitPolicy API succeeded.");
         }
     } failure:^(FetchObdDebitPolicyAPI *req, NSError *error) {
         KLog(@"fetchObdDebitPolicy API Failure %@ %@", error, [error localizedDescription]);
         EnLogd(@"fetchObdDebitPolicy API Failure %@ %@", error, [error localizedDescription]);
     }];
     
     KLog(@"fetchObdDebitPolicy - END");
     return nil;
}

/*
 self.CallCharges is an array which contains array of dictionaries with the following key,value
 PHONE_NUMBER = mobile number
 CALL_CHARGE = value with a text suffix
 */
-(NSString*)getCallChargesForNumber:(NSString *)phoneNumber {
    
    if(self.callCharges.count) {
        NSPredicate* searchPredicate = [NSPredicate predicateWithFormat:@"PHONE_NUMBER = %@", phoneNumber];
        NSArray* result = [NSMutableArray arrayWithArray:[self.callCharges filteredArrayUsingPredicate:searchPredicate]];
        if(result.count) {
            @try {
                NSDictionary* dic = [result objectAtIndex:0];
                NSString* charge = [dic valueForKey:@"CALL_CHARGE"];
                if(charge && charge.length)
                    return charge;
            } @catch(NSException* ex) {
                EnLogd(@"ERROR getting call charge");
            }
        }
    }
    return nil;
}

-(void)setCallChargeForNumber:(NSString*)phoneNumber WithCharge:(NSString*)charge {
    
    if(!self.callCharges) {
        self.callCharges = [[NSMutableArray alloc]init];
    }
    
    if(self.callCharges) {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        [dic setValue:phoneNumber forKey:@"PHONE_NUMBER"];
        [dic setValue:charge forKey:@"CALL_CHARGE"];
        
        if(![self getCallChargesForNumber:phoneNumber]) {
            if(self.callCharges.count>kMaxCallChargeValuesCached)
                [self.callCharges removeObjectAtIndex:0];
            
            [self.callCharges addObject:dic];
        }
    }
    
    KLog(@"callCharges: %@",self.callCharges);
}

-(void)resetCallCharges {
    self.callCharges = nil;
}
#endif
//- Prepare GUID from the VOIP_CALL_ID. i.e GUID = VOIP_CALL_ID_status_deviceID
//
-(NSString*)prepareGUID:(NSDictionary*)voipDic {
    
    NSString* callIdFromPN = [voipDic valueForKey:VOIP_CALL_ID];
    NSString* status = [voipDic valueForKey:VOIP_CALL_STATUS];
    /*
     int callDuration = [[voipDic valueForKey:DURATION]intValue];
     BOOL hangUpTapped = [[voipDic valueForKey:HANGUP_TAPPED]boolValue];
     */
    
    SettingModelMqtt* mqttSetting = [[[Setting sharedSetting]data]mqttSetting];
    NSString* deviceID = [mqttSetting.deviceId stringValue];
    if(!deviceID || !deviceID.length)
        deviceID = @"unknown";
    
    NSString* newStatus = status;
    if(!status)
        newStatus = @"unknown";
    
    NSString* guid = [callIdFromPN stringByAppendingFormat:@"_%@_%@",newStatus,deviceID];
    
    return guid;
}

-(void)downloadVoiceMsg:(NSMutableDictionary*)msg
{
    NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInt:DOWNLOAD_VOICE_MSG] forKey:EVENT_TYPE];
    [eventObj setValue:msg forKey:EVENT_OBJECT];
    [appDelegate.engObj addEvent:eventObj];
}

-(void)sendAllPendingMsg
{
#ifndef REACHME_APP
    if([[ConfigurationReader sharedConfgReaderObj] getContactLocalSyncFlag])
#endif
    {
        NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
        [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
        [eventObj setValue:[NSNumber numberWithInt:SEND_ALL_PENDDING_MSG] forKey:EVENT_TYPE];
        [eventObj setValue:nil forKey:EVENT_OBJECT];
        
        [self addEvent:eventObj];
    }
}

-(void)stopSenddingAllMsg
{
    NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInt:STOP_SEND_MSG] forKey:EVENT_TYPE];
    [eventObj setValue:nil forKey:EVENT_OBJECT];
    
    [self addEvent:eventObj];
}

-(void)postOnWall:(NSMutableDictionary*)msgDic
{
    if ([[msgDic valueForKey:POST_TYPE] isEqualToString:VB_TYPE]) {
        [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeVoboloShare withData:msgDic];
    }
    else if ([[msgDic valueForKey:POST_TYPE] isEqualToString:FB_TYPE]){
        [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeFacebookShare withData:msgDic];
    }
    else if ([[msgDic valueForKey:POST_TYPE] isEqualToString:TW_TYPE]){
        [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeTwitterShare withData:msgDic];
    }
}

//AVN_ACT
-(void)deleteMSG:(NSMutableDictionary*)msgDic
{
    if([[msgDic valueForKey:MISSED_CALL_COUNT]intValue] > 1){
        [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeDelete withData:msgDic];
        
        NSArray *otherMissedCalls = [msgDic valueForKey:MSG_LIST];
        for (NSMutableDictionary *temp in otherMissedCalls) {
            [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeDelete withData:temp];
        }
    }
    else{
        [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeDelete withData:msgDic];
    }
}

-(void)withdrawMSG:(NSMutableDictionary*)msgDic
{
    if(![Common isNetworkAvailable]) {
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE",nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    if([[msgDic valueForKey:MISSED_CALL_COUNT]intValue] > 1){
        [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeWithdraw withData:msgDic];
        
        NSArray *otherMissedCalls = [msgDic valueForKey:MSG_LIST];
        for (NSMutableDictionary *temp in otherMissedCalls) {
            [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeWithdraw withData:temp];
        }
    }
    else{
        [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeWithdraw withData:msgDic];
    }
}

-(void)forwardMessage:(NSMutableDictionary*)msgDic
{
    NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInt:FORWARD_MSG] forKey:EVENT_TYPE];
    [eventObj setValue:msgDic forKey:EVENT_OBJECT];
    [self addEvent:eventObj];
}

-(void)msgActivity:(NSMutableDictionary *)msgDIc
{
    if([[msgDIc valueForKey:@"MSG_LIKED"]intValue] == 0)
        [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeLike withData:msgDIc];
    else
        [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeUnlike withData:msgDIc];
}

-(NSMutableArray*)getMyNotes:(BOOL)fetchFromDB
{
    return [conversationObj getMyNotes:fetchFromDB];
}


-(void)clearCurrentChatUser
{
    [conversationObj clearCurrentChatUser];
}

#ifdef REACHME_APP
-(void)setHelpAsCurrentChat
{
    NSMutableArray* supportContactList = [[Setting sharedSetting].supportContactList mutableCopy];
    if(supportContactList != nil && [supportContactList count] > 0)
    {
        NSUInteger count = (NSUInteger)[supportContactList count];
        for(NSUInteger  i = 0; i < count; i++)
        {
            NSMutableDictionary *dic = [supportContactList objectAtIndex:i];
            NSString *supportName = [dic valueForKey:SUPPORT_NAME];
            if([supportName isEqualToString:SUPPORT_HELP])
            {
                [self setChatInfo:dic];
            }
        }
    }
    
}

-(void)setChatInfo:(NSDictionary *)supportDic
{
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
    
    NSString *ivUserId = [supportDic valueForKey:SUPPORT_IV_ID];
    [newDic setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
    [newDic setValue:ivUserId forKey:REMOTE_USER_IV_ID];
    [newDic setValue:[supportDic valueForKey:SUPPORT_DATA_VALUE] forKey:FROM_USER_ID];
    [newDic setValue:[supportDic valueForKey:SUPPORT_NAME] forKey:REMOTE_USER_NAME];
    [newDic setValue:[supportDic valueForKey:SUPPORT_PIC_URI] forKey:REMOTE_USER_PIC];
    [newDic setValue:@"" forKey:@"HELP_TEXT"];
    
    //- get the pic
    NSNumber* iVID = [NSNumber numberWithLong:[ivUserId longLongValue]];
    NSArray* arr = [[Contacts sharedContact]getContactForIVUserId:iVID usingMainContext:YES];
    ContactDetailData* detailData = Nil;
    if([arr count]>0)
        detailData = [arr objectAtIndex:0];
    
    if(detailData)
        [newDic setValue:[IVFileLocator getNativeContactPicPath:detailData.contactIdParentRelation.contactPic]
                  forKey:REMOTE_USER_PIC];
    
    [appDelegate.dataMgt setCurrentChatUser:newDic];
}

#endif


-(NSMutableArray*)getMyVoboloList:(BOOL)fetchFromDB
{
    return [conversationObj getMyVoboloList:fetchFromDB];
}

-(long)getActiveConversationCount
{
    return [conversationObj getActiveConversationCount];
}

-(NSMutableDictionary*)getCurrentChatUser
{
    return [conversationObj getCurrentChatUser];
}

-(void)clearNetworkData
{
    [appDelegate.shortNetObj clearNetworkQueue];
    [appDelegate.longNetObj clearNetworkQueue];
    [appDelegate.preemptedNetObj clearNetworkQueue];
    [appDelegate.picDownloadNetObj clearNetworkQueue];
#ifdef REACHME_APP
    [appDelegate.lphoneCoreSettings unRegister];
#endif
}

-(void)resetListOnLogout
{
    [conversationObj resetConversations];
}

-(long)getUnreadMsgCount
{
    return [conversationObj getUnreadMsgCount];
}

-(long)getUnreadHiddenMsgCount
{
    return [conversationObj getUnreadHiddenMsgCount];
}

-(long)getUnreadBlockedMsgCount
{
    return [conversationObj getUnreadBlockedMsgCount];
}

-(NSArray*)getUnreadMessages
{
    return [conversationObj getUnreadMessages];
}

-(void)updatePlayDuration:(NSMutableDictionary*)dic
{
    NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInt:UPDATE_PLAY_DURATION] forKey:EVENT_TYPE];
    [eventObj setValue:dic forKey:EVENT_OBJECT];
    [self addEvent:eventObj];
}

-(NSMutableDictionary*)getLastMsgInfo:(NSString*)msgType
{
    return [conversationObj getLastMsgInfo:msgType];
}

-(void)setLastMsgInfo:(NSMutableDictionary*)dic;
{
    [conversationObj setLastMsgInfo:dic];
}

-(NSMutableArray*)getVsmsLimitList
{
    return [conversationObj getVsmsLimitList];
}
-(NSMutableDictionary*)getChatUserFrmActiveConvList:(NSString*)userID
{
    return [conversationObj getChatUserFrmActiveConvList:userID];
}

-(void)updateMsgOnContactSync
{
    NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInt:UPDATE_MSG_ON_CONTACT_SYNC] forKey:EVENT_TYPE];
    [eventObj setValue:nil forKey:EVENT_OBJECT];
    [self addEvent:eventObj];
    //CMP [conversationObj updateMsgOnContactSync];
}

-(void)getMissedCallInfo:(NSString*)nativeContactID
{
    NSMutableDictionary *evDic = [[NSMutableDictionary alloc]init];
    [evDic setValue:nativeContactID forKey:NATIVE_CONTACT_ID];
    
    NSMutableDictionary* eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInt:MISS_CALL_GET_INFO] forKey:EVENT_TYPE];
    [eventObj setValue:evDic forKey:EVENT_OBJECT];
    [self addEvent:eventObj];
}

-(void)updateUserIdFrom:(NSString *)oldUserId toNew:(NSString *)newUserId
{
    KLog(@"oldUserID = %@, newUserId = %@", oldUserId,newUserId);
#ifdef REACHME_APP
    if([appDelegate.confgReader getIsLoggedIn])
#else
    if([appDelegate.confgReader getIsLoggedIn] && [appDelegate.confgReader getContactLocalSyncFlag])
#endif
    {
        NSMutableDictionary* dicUserIDs = [[NSMutableDictionary alloc]init];
        [dicUserIDs setValue:oldUserId forKey:OLD_USER_ID];
        [dicUserIDs setValue:newUserId forKey:NEW_USER_ID];
        NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
        [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
        [eventObj setValue:[NSNumber numberWithInt:CHANGE_USER_ID] forKey:EVENT_TYPE];
        [eventObj setValue:dicUserIDs forKey:EVENT_OBJECT];
        [self addEvent:eventObj];
    }
}

-(void)addMQTTReceivedDataEvent:(MQTTReceivedData*)data
{
    NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInteger:MQTT_DATA_RECEIVED] forKey:EVENT_TYPE];
    [eventObj setValue:data forKey:EVENT_OBJECT];
    [self addEvent:eventObj];
}

#ifdef REACHME_APP
-(void)updateMissedCallReason:(NSMutableDictionary*)dic
{
    NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInteger:UPDATE_MISSEDCALL_REASON] forKey:EVENT_TYPE];
    [eventObj setValue:dic forKey:EVENT_OBJECT];
    [self addEvent:eventObj];
}
#endif


-(void)addMessageHeaderIntoTable:(NSDictionary*)data
{
    NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInteger:ADD_MSG_HEADER] forKey:EVENT_TYPE];
    [eventObj setValue:data forKey:EVENT_OBJECT];
    [self addEvent:eventObj];
}

#pragma mark -- Send message message creation
//TODO -- Move this to engine
-(void)sendMessage:(NSMutableDictionary*)msgDic toChatUser:(NSMutableDictionary*)currentChatUser
{
    int result = FAILURE;
    if(msgDic != nil && [msgDic count] >0)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:UI_EVENT forKey:EVENT_MODE];
        [dic setValue:[NSNumber numberWithInt:SEND_MSG] forKey:EVENT_TYPE];
        NSMutableDictionary *newMsgDic = [Engine createMsgDic:msgDic forChatUser:currentChatUser];
        
        [dic setValue:newMsgDic forKey:EVENT_OBJECT];
        KLog(@"sendMessage = %@",dic);
        result = [appDelegate.engObj addEvent:dic];
    }
}

//This method is already present in MQTTManager object
//TODO: refactor the code
-(void)sendAppStatus:(BOOL)isForeground
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    if(isForeground)
    {
        [dic setValue:@"fg" forKey:@"status"];
        long afterID = [[ConfigurationReader sharedConfgReaderObj] getAfterMsgId];
        if(afterID > 0)
        {
            NSNumber *afterNum = [NSNumber numberWithLong:afterID];
            [dic setValue:afterNum forKey:@"last_msg_id"];
        }
    }
    else
        [dic setValue:@"bg" forKey:@"status"];
    
    [dic setValue:UI_EVENT forKey:EVENT_MODE];
    [dic setValue:[NSNumber numberWithInt:SEND_APP_STATUS] forKey:EVENT_TYPE];
    
    NSMutableDictionary* eventObj = [[NSMutableDictionary alloc]initWithDictionary:dic];
    [eventObj setValue:dic forKey:EVENT_OBJECT];
    [appDelegate.engObj addEvent:eventObj];
    
    /*
    [NetworkCommon addCommonData:dic eventType:APP_STATUS];
    NSString* reqJson = [NetworkCommon getRequestJson:dic];
    */
}

// This function is used to Create a New Msg Dic for List and DB.
+(NSMutableDictionary*)createMsgDic:(NSMutableDictionary*)msgDic forChatUser:(NSMutableDictionary*)currentChatUser
{
    NSMutableDictionary *dic = nil;
    if(msgDic != nil && [msgDic count])
    {
        dic = [[NSMutableDictionary alloc] init];
        [dic setValue:[[ConfigurationReader sharedConfgReaderObj] getLoginId] forKey:LOGGEDIN_USER_ID];
        [dic setValue:[NSNumber numberWithInt:0] forKey:MSG_ID];
        [dic setValue:[msgDic valueForKey:MSG_GUID] forKey:MSG_GUID];
        [dic setValue:[msgDic valueForKey:MSG_DATE] forKey:MSG_DATE];
        [dic setValue:@"ivc" forKey:SOURCE_APP_TYPE];
        [dic setValue:[msgDic valueForKey:MSG_FLOW] forKey:MSG_FLOW];
        [dic setValue:[msgDic valueForKey:MSG_CONTENT_TYPE] forKey:MSG_CONTENT_TYPE];
        
        [dic setValue:[msgDic valueForKey:MSG_TYPE] forKey:MSG_TYPE];
        
        if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE)
        {
            [dic setValue:API_NETUNAVAILABLE forKey:MSG_STATE];
        }
        else
        {
            [dic setValue:[msgDic valueForKey:MSG_STATE] forKey:MSG_STATE];
        }
        
        if(currentChatUser != nil && [currentChatUser count]>0)
        {
            [dic setValue:[currentChatUser valueForKey:REMOTE_USER_IV_ID] forKey:REMOTE_USER_IV_ID];
            [dic setValue:[currentChatUser valueForKey:REMOTE_USER_NAME]forKey:REMOTE_USER_NAME];
            [dic setValue:[currentChatUser valueForKey:FROM_USER_ID] forKey:FROM_USER_ID];
            [dic setValue:[currentChatUser valueForKey:REMOTE_USER_PIC] forKey:REMOTE_USER_PIC];
            [dic setValue:[currentChatUser valueForKey:REMOTE_USER_TYPE] forKey:REMOTE_USER_TYPE];
            if([[currentChatUser valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE])
            {
                [dic setValue:[currentChatUser valueForKey:CONVERSATION_TYPE] forKey:CONVERSATION_TYPE];
                if([msgDic valueForKey:MSG_SUB_TYPE] == Nil || [[msgDic valueForKey:MSG_SUB_TYPE]isEqualToString:@""])
                {
                    [dic setValue:GROUP_MSG_TYPE forKey:MSG_SUB_TYPE];
                }
                else
                    [dic setValue:[msgDic valueForKey:MSG_SUB_TYPE] forKey:MSG_SUB_TYPE];
                
                [dic setValue:IV_TYPE forKey:MSG_TYPE];
            }
            else
            {
                if( [[dic valueForKey:MSG_TYPE] isEqualToString:MISSCALL]) {
                    [dic setValue:[msgDic valueForKey:MSG_SUB_TYPE] forKey:MSG_SUB_TYPE];
                    [dic setValue:@"" forKey:CONVERSATION_TYPE];
                }
                else {
                    [dic setValue:@"" forKey:MSG_SUB_TYPE];
                    [dic setValue:@"" forKey:CONVERSATION_TYPE];
                }
            }
        }
        
        [dic setValue:[NSNumber numberWithBool:NO] forKey:MSG_BASE64];
        [dic setValue:[msgDic valueForKey:MSG_CONTENT] forKey:MSG_CONTENT];
        if([msgDic valueForKey:ANNOTATION])
            [dic setValue:[msgDic valueForKey:ANNOTATION] forKey:ANNOTATION];
        else
            [dic setValue:@"" forKey:ANNOTATION];
        if([[msgDic valueForKey:MSG_CONTENT_TYPE] isEqualToString:@"t"])
        {
            [dic setValue:@"" forKey:MEDIA_FORMAT];
            [dic setValue:[NSNumber numberWithInt:0] forKey:DURATION];
            [dic setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAY_DURATION];
            [dic setValue:@"" forKey:MSG_LOCAL_PATH];
        }
        else
        {
            [dic setValue:[msgDic valueForKey:MEDIA_FORMAT] forKey:MEDIA_FORMAT];
            [dic setValue:[msgDic valueForKey:DURATION]forKey:DURATION];
            
            [dic setValue:[msgDic valueForKey:MSG_LOCAL_PATH] forKey:MSG_LOCAL_PATH];
        }
        [dic setValue:[NSNumber numberWithInt:0] forKey:MSG_PLAY_DURATION];
        [dic setValue:[NSNumber numberWithInt:0] forKey:MSG_READ_CNT];
        [dic setValue:[NSNumber numberWithInt:0] forKey:MSG_DOWNLOAD_CNT];
        [dic setValue:[msgDic valueForKey:LATITUDE] forKey:LATITUDE];
        [dic setValue:[msgDic valueForKey:LONGITUTE] forKey:LONGITUTE];
        [dic setValue:[msgDic valueForKey:LOCALE] forKey:LOCALE];
        [dic setValue:[msgDic valueForKey:LOCATION_NAME] forKey:LOCATION_NAME];
        [dic setValue:@"" forKey:LINKED_OPR];
        [dic setValue:@"" forKey:LINKED_MSG_TYPE];
        [dic setValue:[NSNumber numberWithInt:0] forKey:LINKED_MSG_ID];
        NSNumber *num = [NSNumber numberWithBool:NO];
        [dic setValue:num forKey:MSG_LIKED];
        [dic setValue:num forKey:MSG_LISTENED];
        [dic setValue:num forKey:MSG_FB_POST];
        [dic setValue:num forKey:MSG_TW_POST];
        [dic setValue:num forKey:MSG_VB_POST];
        [dic setValue:num forKey:MSG_FORWARD];
        
    }
    return dic;
}

-(void)purgeOldData
{
    NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInteger:PURGE_OLD_DATA] forKey:EVENT_TYPE];
    [eventObj setValue:[NSMutableDictionary dictionary] forKey:EVENT_OBJECT];
    [self addEvent:eventObj];
}

-(void)notifyUIOfNetConnection:(BOOL)isInternetConnected {
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    [resultDic setValue:ENG_SUCCESS forKey:RESPONSE_CODE];
    
    if(isInternetConnected)
        [resultDic setValue:[NSNumber numberWithInteger:INTERNET_UP] forKey:EVENT_TYPE];
    
    else
        [resultDic setValue:[NSNumber numberWithInteger:INTERNET_DOWN] forKey:EVENT_TYPE];

    [appDelegate.stateMachineObj notifyUI:resultDic];
}

-(void)deleteAllChats:(NSArray*)forTheContactList
{
    NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInteger:DELETE_CHATS] forKey:EVENT_TYPE];
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setValue:forTheContactList forKey:PHONE_NO];
    [eventObj setValue:dic forKey:EVENT_OBJECT];
    [self addEvent:eventObj];
}


@end
