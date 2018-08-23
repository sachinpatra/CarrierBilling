//
//  MQTTManager.m
//  InstaVoice
//
//  Created by adwivedi on 22/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "MQTTManager.h"
#import "ConfigurationReader.h"
#import "Logger.h"
#import "Setting.h"
#import "SettingModelMqtt.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "MQTTReceivedData.h"
#import "Engine.h"
#import "PendingEventManager.h"
#import "ChatActivity.h"
#import "ConversationApi.h"
#import "NotificationBar.h"
#import "UIStateMachine.h"
#import "UIType.h"
#import "NotificationIds.h"
#import "TableColumns.h"
#import "Macro.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif
#import "Engine.h"
#import "Contacts.h"
#import "ConfigurationReader.h"
#import "UpdateAppStatus.h"

static MQTTManager* _sharedManager = nil;

@interface MQTTManager()
@property (strong,nonatomic)KMQTTClient* mqttClient;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskID;
@end

@implementation MQTTManager
NSLock* arrayLock;

-(id)init{
    if(self = [super init])
    {
        self.mqttClient = [KMQTTClient sharedMQTTClientObj];
        self.canProcessThroughMQTT = NO;
        _publishedMessageList = [[NSMutableArray alloc]init];
        _connectionTrialCount = 0;
        arrayLock = [[NSLock alloc]init];
    }
    return self;
}

+(id)sharedMQTTManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self new];
    });
    return _sharedManager;
}

-(void)connectMQTTClient
{
    if([self isConnected]) {
        return;
    }
    
    SettingModelMqtt* mqttSetting = [[[Setting sharedSetting]data]mqttSetting];
    
    if(!mqttSetting.chatHostName || ![mqttSetting.chatHostName length]) {
        EnLogd(@"mqtt host is null. set to default");
        mqttSetting.chatHostName = [NSString stringWithFormat:@"%@",MQTT_SERVER_URL];
    }
    
    if(!mqttSetting.chatPortSSL) {
        EnLogd(@"mqtt server port is null. set to default.");
        mqttSetting.chatPortSSL = MQTT_SERVER_PORT;
    }
    
    [self.mqttClient setServerURI:mqttSetting.chatHostName PortNumber:mqttSetting.chatPortSSL];
    [self.mqttClient setDelegate:self];
    
    BOOL isLogin = [[ConfigurationReader sharedConfgReaderObj]getIsLoggedIn];
    if(isLogin) {
        if([mqttSetting.deviceId longValue] > 0) {
            NSString* myDeviceID = [[NSString alloc]initWithFormat:@"iv/pn/device%012ld", (long)[mqttSetting.deviceId integerValue]];
            //KLog(@"MQTT Client ID = %@",myDeviceID);
            EnLogd(@"MQTT Client ID = %@",myDeviceID);
            if(![self.mqttClient isConnected]) {
                KLog(@"Start MQTT Connection");
                EnLogd(@"Start MQTT Connection");
                [self.mqttClient connectToHostUsingDeviceID:myDeviceID];
            } else {
                KLog(@"Client is connected");
                EnLogd(@"Client is connected");
            }
        }
        else
        {
            _connectionTrialCount++;
            if(_connectionTrialCount < 3) {
                //Freshly fetch the user settings
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setValue:@NO forKey:kUserSettingsFetched];
                [userDefaults synchronize];
                [[Setting sharedSetting]getUserSettingFromServer];

            }
        }
    }
}

- (void) disconnectMQTTClient
{
    self.canProcessThroughMQTT = false;
    
    [self beginBackgroundTask];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(self.isConnected)
        {
            [self.mqttClient disconnect];
            KLog(@"Disconnect the MQTT client");
            EnLogd(@"Disconnect the MQTT client");
            while(TRUE)
            {
                /* can not be called in background thread
                KLog(@"Background time Remaining: %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
                EnLogd(@"Background time Remaining: %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
                 */
                [NSThread sleepForTimeInterval:1]; //wait for 1 sec
                if(![self.mqttClient isConnected]) break;
                [self.mqttClient disconnect];
            }
            [self.mqttClient closeClient];
            KLog(@"MQTT client disconnect is DONE");
            EnLogd(@"MQTT client disconnect is DONE");
        }
        else
        {
            // send the app background status via HTTP
            //-
            __block BOOL isApiCallFinished = NO;
            __block int retryCount = 1;
            
            if(![[ConfigurationReader sharedConfgReaderObj]getIsLoggedIn]) {
                EnLogd(@"User signed-out");
                isApiCallFinished = YES;
            }
            
            NSCondition *condition = [[NSCondition alloc]init];
            [condition lock];
            while(!isApiCallFinished)
            {
                KLog(@"Sending app-bg-status via HTTP");
                EnLogd(@"Sending app-bg-status via HTTP");
                UpdateAppStatusAPI* api = [[UpdateAppStatusAPI alloc]initWithRequest:nil];
                [api callNetworkRequest:NO withSuccess:^(UpdateAppStatusAPI *req, BOOL responseObject) {
                    [condition lock];
                    KLog(@"UpdateAppStatus success.");
                    EnLogd(@"UpdateAppStatus success");
                    isApiCallFinished = YES;
                    retryCount = 0;
                    [condition signal];
                    [condition unlock];
                } failure:^(UpdateAppStatusAPI *req, NSError *error) {
                    [condition lock];
                    KLog(@"UpdateAppStatus failed: %@",error);
                    EnLogd(@"UpdateAppStatus failed: %@",error);
                    isApiCallFinished  = YES;
                    [condition signal];
                    [condition unlock];
                }];
                
                [condition wait];
                if(retryCount>0 && isApiCallFinished) {
                    KLog(@"UpdateStatusAPI -- retry");
                    EnLogd(@"UpdateStatusAPI -- retry");
                    isApiCallFinished = NO;
                    retryCount--;
                }
            }
            [condition unlock];
        }
        
        [[Contacts sharedContact]clearTheOperations];
        [[Contacts sharedContact]setIsSyncInProgress:NO];
        
        [self endBackgroundTask];
    });
}

- (void) beginBackgroundTask
{
    self.bgTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
}

- (void) endBackgroundTask
{
    [[UIApplication sharedApplication] endBackgroundTask: self.bgTaskID];
    self.bgTaskID = UIBackgroundTaskInvalid;
}

- (BOOL) isConnected
{
    return ([self.mqttClient isConnected]);
}

#pragma mark -- Send App Status
-(void) publishAppStatusInForeground
{
    KLog(@"Send App status.");
    EnLogd(@"Send App status.");
    NSString* message =  [self createAppStatusMessage:YES];
    
    if([self isConnected]) {
        MQTTPublishedData* data = [[MQTTPublishedData alloc]init];
        data.dataType = MQTTPublishedDataTypeAppStatus;
        data.publishData = nil;
        data.msgGuid = nil;
        
        NSString* topic = [NSString stringWithFormat:@"%@",[[[Setting sharedSetting]data]mqttSetting].chatTopic];
        KLog(@"Publish: topic=%@, msg=%@",topic,message);
        EnLogd(@"Publish: topic=%@, msg=%@",topic,message);
        
        int token = [self.mqttClient publish:message ToTheTopic:topic];
        if(token) {
            data.publishedMessageToken = token;
        }
        else {
            KLog(@"NULL token received. topic=%@, msg=%@",topic,message);
            EnLogd(@"NULL token received. topic=%@, msg=%@",topic,message);
        }
    }
}

-(void) publishAppStatusInBackground
{
    if([self isConnected]) {
        KLog(@"Send App status.");
        EnLogd(@"Send App status.");
        NSString* message =  [self createAppStatusMessage:NO];
        
        MQTTPublishedData* data = [[MQTTPublishedData alloc]init];
        data.dataType = MQTTPublishedDataTypeAppStatus;
        data.publishData = nil;
        data.msgGuid = nil;
        
        NSString* topic = [NSString stringWithFormat:@"%@",[[[Setting sharedSetting]data]mqttSetting].chatTopic];
        int token = [self.mqttClient publish:message ToTheTopic:topic];
        
        if(token) {
            data.publishedMessageToken = token;
            KLog(@"Publish: topic=%@,msg=%@,token=%d",topic,message,token);
            EnLogd(@"Publish: topic=%@,msg=%@,token=%d",topic,message,token);
        }
        else {
            KLog(@"NULL token received. topic=%@, msg=%@",topic,message);
            EnLogd(@"NULL token received. topic=%@, msg=%@",topic,message);
        }
    } else {
        KLog(@"MQTT is not connected. Could not send App status.");
        EnLogd(@"MQTT is not connected. Could not send App status.");
    }
}

-(NSString*)createAppStatusMessage:(BOOL)isForeground
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
    [NetworkCommon addCommonData:dic eventType:APP_STATUS];
    NSString* reqJson = [NetworkCommon getRequestJson:dic];
    
    /*
    NSString *encodedString = [reqJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSData *reqData = [reqJson dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *mutableReqData = [[NSMutableData alloc] initWithData:reqData];
    NSString *encodedString=[[NSString alloc] initWithBytes:[mutableReqData mutableBytes]
    length:[mutableReqData length] encoding:NSUTF8StringEncoding];
    return encodedString;
    */
    
    return reqJson;
}

#pragma mark -- Send Text Message
-(void) publishTextMessage:(NSMutableDictionary *)message
{
    SettingModelMqtt* mqttSetting = [[[Setting sharedSetting]data]mqttSetting];
    if([self.mqttClient isConnected])
    {
        NSString *reqJson  = [NetworkCommon getRequestJson:message];
        int token = [self.mqttClient publish:reqJson ToTheTopic:mqttSetting.chatTopic];
        if(token)
        {
            KLog(@"Publishing: topic=%@,msg=%@,token=%d",mqttSetting.chatTopic,message,token);
            EnLogd(@"Publishing: topic=%@,msg=%@,token=%d",mqttSetting.chatTopic,message,token);
            MQTTPublishedData* data = [[MQTTPublishedData alloc]init];
            data.dataType = MQTTPublishedDataTypeTextMessage;
            data.publishData = message;
            data.msgGuid = [message valueForKey:@"guid"];
            data.publishedMessageToken = token;
            
            [arrayLock lock];
            [_publishedMessageList addObject:data];
            [arrayLock unlock];
            
            if(_sendMessageTimer != Nil)
                [_sendMessageTimer invalidate];
            
            //TODO scheduledTimerWithTimeInterval oldVal: 5
            /*
            _sendMessageTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkMqttTimeoutForData:)  userInfo:data repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:_sendMessageTimer forMode:NSRunLoopCommonModes];
             */
        }
        else
        {
            KLog(@"NULL token received. topic=%@,msg=%@",mqttSetting.chatTopic,message);
            EnLogd(@"NULL token received. topic=%@,msg=%@",mqttSetting.chatTopic,message);
            [self processMQTTSendMessageError:message];
        }
    }
    else
    {
        KLog(@"MQTT is not connected.");
        EnLogd(@"MQTT is not connected.");
        [self processMQTTSendMessageError:message];
    }
}

-(void)checkMqttTimeoutForData:(NSTimer*)timer
{
    KLog(@"MQTT time out");
    EnLogd(@" MQTT time out");
    MQTTPublishedData* mqttData = timer.userInfo;
    if([_publishedMessageList containsObject:mqttData])
    {
        //MQTT Failure.
        KLog(@"MQTT failure.");
        EnLogd(@"MQTT failure.");
        [self processMQTTSendMessageError:mqttData.publishData];
    }
    [_sendMessageTimer invalidate];
}

-(void)processMQTTSendMessageError:(NSMutableDictionary*)message
{
    KLog(@"processMQTTSendMessageError:%@",message);
    MQTTReceivedData* errorResponse = [[MQTTReceivedData alloc]init];
    errorResponse.dataType = MQTTReceivedDataTypeSendMessage;
    errorResponse.responseData = nil;
    errorResponse.errorType = MQTTErrorTypeReadReceiptSendFailedTimeoutError;
    errorResponse.error = Nil;
    errorResponse.requestData = message;
    [[Engine sharedEngineObj]addMQTTReceivedDataEvent:errorResponse];
    self.canProcessThroughMQTT = false;
}

#pragma mark -- Send Read Receipt Message
-(void)publishReadReceiptData:(ChatActivityData*)activity
{
    if([self.mqttClient isConnected])
    {
        NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
        [requestDic setValue:activity.msgDataList forKey:API_MSG_IDS];
        [requestDic setValue:activity.msgType forKey:API_MSG_IDS_TYPE];
        [NetworkCommon addCommonData:requestDic eventType:INCREMENT_READ_COUNT];
        NSString *reqJson  = [NetworkCommon getRequestJson:requestDic];
        
        SettingModelMqtt* mqttSetting = [[[Setting sharedSetting]data]mqttSetting];
        int token = [self.mqttClient publish:reqJson ToTheTopic:mqttSetting.chatTopic];
        if(token)
        {
            KLog(@"Publishing read receipt: topic=%@, token=%d",mqttSetting.chatTopic,token);
            KLog(@"ReadReceipt req Dic: %@",requestDic);
            EnLogd(@"Publishing read receipt: topic=%@, token=%d",mqttSetting.chatTopic,token);
            MQTTPublishedData* data = [[MQTTPublishedData alloc]init];
            data.publishedMessageToken = token;
            data.dataType = MQTTPublishedDataTypeReadReceipt;
            data.publishData = activity;
            
            [arrayLock lock];
            [_publishedMessageList addObject:data];
            [arrayLock unlock];
        }
        else
        {
            KLog(@"NULL token recieved in publishing to the topic: %@",mqttSetting.chatTopic);
            EnLogd(@"NULL token recieved in publishing to the topic: %@",mqttSetting.chatTopic);
            [self processMQTTSendReadReceiptError:activity];
        }
    }
    else
    {
        KLog(@"MQTT is not connected.");
        EnLogd(@"MQTT is not connected.");
        [self processMQTTSendReadReceiptError:activity];
    }
}

-(void)processMQTTSendReadReceiptError:(ChatActivityData*)activity
{
    KLog(@"Error publishing Read Receipt: %@",activity.msgGuid);
    EnLogd(@"Error publishing Read Receipt: %@",activity.msgGuid);
    [[ChatActivity sharedChatActivity]chatActivity:activity processedSuccessfully:NO];
    self.canProcessThroughMQTT = false;
}

#pragma mark MQTTClientManagerDelegate implementation

-(void)mqttClientDidFinishConnectingWithStatusCode:(MQTTClientStatusCode)statusCode
{
    KLog(@"Client connected successfully.");
    EnLogd(@"Client connected successfully.");
    [[Engine sharedEngineObj]sendAllPendingMsg];
}

-(void)mqttClientDidFailToConnect
{
    KLog(@"MQTT client failed to connect.");
    EnLogd(@"MQTT client failed to connect.");
    _connectionTrialCount++;
    if(_connectionTrialCount < 3) {
        [[Setting sharedSetting]getUserSettingFromServer];
    }
    else {
        self.canProcessThroughMQTT = false;
        [[Engine sharedEngineObj]sendAppStatus:TRUE];
    }
}

-(void)mqttClientDidLoseConnection
{
    KLog(@"MQTT Connection lost.");
    EnLogd(@"MQTT Connecttion lost.");
    self.canProcessThroughMQTT = false;
}

-(void)mqttClientDidFinishSubscription
{
    KLog(@"Subscription succeeded.");
    EnLogd(@"Subscription succeeded.");
    self.canProcessThroughMQTT = YES;
    [self publishAppStatusInForeground];
}

-(void)mqttClientDidFailToSubscribe
{
    KLog(@"Subscription failed.");
    EnLogd(@"Subscription failed.");
    [[Engine sharedEngineObj]sendAppStatus:TRUE];
}

-(void)mqttClientDidSubmitForPublishingRequestData:(NSInteger)deliveryToken
{
    //KLog(@"");
    //KLog(@"Message submitted for publish. token = %ld", (long)deliveryToken);
}

-(void)mqttClientDidFailPublishingRequestData:(NSInteger)causeCode withToken:(NSInteger)deliveryToken
{
    KLog(@"");
    EnLogd(@"");
    
    [self processPublishResponseWithDeliveryToken:deliveryToken forSuccess:NO];
    self.canProcessThroughMQTT = false;
}

//Message delivery confirmed
-(void)mqttClientDidFinishPublishing:(NSInteger)deliveryToken
{
    KLog(@"Message published. token = %ld", (long)deliveryToken);
    EnLogd(@"Message published. token = %ld", deliveryToken);
    [self processPublishResponseWithDeliveryToken:deliveryToken forSuccess:YES];
    self.canProcessThroughMQTT = true;
}

-(void)mqttClientDidReceiveSubscriptionData:(NSMutableDictionary*)responseData
{
    KLog(@"Received subscription data cmd: %@",[responseData valueForKey:@"cmd"]);
    EnLogd(@"Received subscription data cmd: %@",[responseData valueForKey:@"cmd"]);
    [self processMQTTReceivedData:responseData];
    self.canProcessThroughMQTT = true;
}

-(void)mqttClientDidDisconnectWithStatusCode:(MQTTClientStatusCode)statusCode
{
    KLog(@"Client disconnected: %d",(int)statusCode);
    EnLogd(@"Client disconnected: %d",(int)statusCode);
    self.canProcessThroughMQTT = false;
}

#pragma mark -- MQTT Received Data
-(void)processMQTTReceivedData:(NSMutableDictionary*)responseData
{
    KLog(@"processMQTTReceivedData:%@",responseData);
    /*
    NSArray* msgs = [responseData valueForKey:@"msgs"];
    if(msgs.count>1) {
        KLog(@"oops...!");
    }
    */
    NSString* cmd = [responseData valueForKey:@"cmd"];
    NSString* pendingEvents = [responseData valueForKey:@"events"];
    double mid = [[responseData valueForKey:@"mid"]doubleValue];
    NSString* additionalEvent = @"0";
    long skipId = 0;
    if([cmd isEqualToString:@"ivnew"]/* || [cmd isEqualToString:@"send_text"]*/)
    {
        MQTTReceivedData* data = [[MQTTReceivedData alloc]init];
        data.responseData = responseData;
        data.errorType = 0;
        data.error = Nil;
        data.requestData = Nil;
        data.dataType = MQTTReceivedDataTypeFetchMessageAsNotification;
        //New Message Arrived Check it for message sent and add to engine accordingly.
        MQTTPublishedData* sendData = [self checkAndGetPublishDataforSendMessageResponse:responseData];
        if(sendData != Nil)
        {
            data.dataType = MQTTReceivedDataTypeSendMessage;
            data.requestData = sendData.publishData;
            
            [arrayLock lock];
            [_publishedMessageList removeObject:sendData];
            [arrayLock unlock];
        }
        
        [[Engine sharedEngineObj]addMQTTReceivedDataEvent:data];
        
        NSMutableArray* msgList = [responseData valueForKey:API_MSGS];
        if(msgList.count)
        {
            skipId = [[msgList[0] valueForKey:API_MSG_ID]longValue];
        }
        additionalEvent = @"2";//PendingEventTypeFetchMessage
        
        if(sendData == Nil)
            [self createNotificationBarWithPayload:responseData fromApns:NO];
    }
    else if([cmd isEqualToString:@"ivupd"])
    {
        MQTTReceivedData* data = [[MQTTReceivedData alloc]init];
        data.dataType = MQTTReceivedDataTypeFetchMessageActivityAsNotification;
        data.responseData = responseData;
        data.errorType = 0;
        data.error = Nil;
        data.requestData = Nil;
        [[Engine sharedEngineObj]addMQTTReceivedDataEvent:data];
        
        additionalEvent = @"5";//PendingEventTypeFetchMessageActivity
        skipId = [[responseData valueForKey:API_MSG_ACTIVITY_ID]longLongValue];
    }
#ifdef TRANSCRIPTION_ENABLED
    else if([cmd isEqualToString:@"ivtrans"])
    {
        MQTTReceivedData* data = [[MQTTReceivedData alloc]init];
        data.dataType = MQTTReceivedDataTypeTranscriptionStatusAndText;
        data.responseData = responseData;
        data.errorType = 0;
        data.error = Nil;
        data.requestData = Nil;
        [[Engine sharedEngineObj]addMQTTReceivedDataEvent:data];
    }
#endif
    /*
    else if([cmd isEqualToString:@"pe"])
    {
        KLog(@"pe: %@",responseData);
    }*/
    
    [self processPendingEvent:pendingEvents withAdditionalEvent:additionalEvent skipId:skipId atTime:mid];
    
}

//DEC 2017 -(MQTTPublishedData*)checkAndGetPublishDataforSendMessageResponse:(NSMutableArray*)msgList
-(MQTTPublishedData*)checkAndGetPublishDataforSendMessageResponse:(NSMutableDictionary*)msgDic
{
    NSArray* msgList = [msgDic valueForKey:@"msgs"];
    if(_publishedMessageList.count && msgList.count)
    {
        for(NSMutableDictionary* msg in msgList)
        {
            NSString* responseGuid = [msg valueForKey:@"guid"];
            @synchronized(_publishedMessageList) {
                for (MQTTPublishedData* data in _publishedMessageList){
                    if([data.msgGuid isEqualToString:responseGuid])
                    {
                        return data;
                    }
                }
            }
        }
    }
    
    /* DEC 2017 -- TODO: later. To get send_text response for group
    else if(msgDic.count) {
        NSString* responseGuid = [msgDic valueForKey:@"guid"];
        @synchronized(_publishedMessageList) {
            for (MQTTPublishedData* data in _publishedMessageList){
                if([data.msgGuid isEqualToString:responseGuid])
                {
                    return data;
                }
            }
        }
    }*/
    //
    return Nil;
}

-(void)processPendingEvent:(NSString*)pendingEvents withAdditionalEvent:(NSString*)event skipId:(long)skipId atTime:(double)mid
{
    NSMutableArray* pendingEventList = [[NSMutableArray alloc]init];
    if(pendingEvents.length)
    {
        NSMutableArray *pendingEventStringList = [NSMutableArray arrayWithArray:[pendingEvents componentsSeparatedByString:@", "]];
        [pendingEventStringList filterUsingPredicate:[NSPredicate predicateWithFormat:@"self != %@",event]];
        if(event.integerValue)
           [pendingEventStringList addObject:event];
        for(NSString* number in pendingEventStringList)
        {
            [pendingEventList addObject:[NSNumber numberWithInteger:[number integerValue]]];
        }
    }
    else
    {
        //TODO FIXME - This makes processPendingEvent method call in a loop when 1st and 2nd args be null.
        if(event.integerValue)
        {
            [pendingEventList addObject:[NSNumber numberWithInteger:event.integerValue]];
        }
    }
    
    if(skipId > 0)
        [[PendingEventManager sharedPendingEventManager]setSkipId:skipId];
    
    if(pendingEventList.count) {
        KLog(@"pendingEventList = %@",pendingEventList);
        [[PendingEventManager sharedPendingEventManager] addPendingEvents:pendingEventList atTime:mid];
    }
    
}

#pragma mark -- MQTT Publish Response Processing
-(void)processPublishResponseWithDeliveryToken:(NSInteger)token forSuccess:(BOOL)success
{
    KLog(@"%ld and success flag %d",(long)token,success);
    EnLogd(@"%ld and success flag %d",(long)token,success);
    if(success)
    {
        MQTTPublishedData* successData = nil;
        [arrayLock lock];
        @try {
            for(MQTTPublishedData* data in _publishedMessageList)
            {
                if(data.publishedMessageToken == token && data.dataType == MQTTPublishedDataTypeReadReceipt)
                {
                    KLog(@"Response for publised MQTTPublishedDataTypeReadReceipt. %@",data);
                    if([data.publishData isKindOfClass:[ChatActivityData class]])
                    {
                        successData = data;
                        [[ChatActivity sharedChatActivity]chatActivity:(ChatActivityData*)successData.publishData processedSuccessfully:YES];
                    }
                    
                    break;
                }
                
                //NOV 2017
                /*
                for(MQTTPublishedData* data in _publishedMessageList)
                {
                    if(data.publishedMessageToken == token && data.dataType == MQTTPublishedDataTypeTextMessage)
                        [self processMQTTSendMessageSuccess:data.publishData];
                    successData = data;
                }
                */
            }
            
            if(successData)
            {
                [_publishedMessageList removeObject:successData];
            }
            
            
            [arrayLock unlock];
        }
        @catch(NSException* ex) {
            [arrayLock unlock];
            EnLogd(@"Exception occurred:%@",ex);
        }
    }
    else
    {
        BOOL disconnect = false;
        @synchronized(_publishedMessageList) {
            for(MQTTPublishedData* data in _publishedMessageList)
            {
                if(data.publishedMessageToken == token)
                {
                    if(data.dataType == MQTTPublishedDataTypeReadReceipt && [data.publishData isKindOfClass:[ChatActivityData class]])
                    {
                        disconnect = true;
                        [self processMQTTSendReadReceiptError:data.publishData];
                    }
                    else if(data.dataType == MQTTPublishedDataTypeTextMessage)
                    {
                        disconnect = true;
                        [self processMQTTSendMessageError:data.publishData];
                    }
                }
            }
            if(disconnect)
            {
                [_publishedMessageList removeAllObjects];
            }
        }
    }
}


#pragma mark -- Process APNS Received notification.
-(void)processAPNSPushNotificationData:(NSDictionary*)payload showOnBar:(BOOL)show
{
    //get mid and pe and fetch the message.
    // NSString* cmd = [payload valueForKey:@"cmd"];
    NSString* pendingEvents = [payload valueForKey:@"events"];
    double mid = [[payload valueForKey:@"mid"]doubleValue];
    NSString* additionalEvent = @"2";
    long skipId = 0;
    if (show) {
        [self createNotificationBarWithPayload:payload fromApns:YES];
    }
    if(pendingEvents.length)
        [self processPendingEvent:pendingEvents withAdditionalEvent:additionalEvent skipId:skipId atTime:mid];
}

-(void)createNotificationBarWithPayload:(NSDictionary*)notificationDic fromApns:(BOOL)isApns
{
    if(notificationDic != nil && [notificationDic count]>0)
    {
        if([MQTTManager isMessageEligibleForNotificationBar:notificationDic])
        {
            NSString* message = [MQTTManager getNotificationBarText:notificationDic];
            if(message.length)
            {
                NSMutableDictionary* mqttNotificationDic = [NSMutableDictionary dictionaryWithDictionary:notificationDic];
                BOOL showNotif=YES;
                if(!isApns)
                {
                    //AVN_TODO_MQTT -- set user_id and ph and group_id field here
                    NSArray* msgs = [notificationDic valueForKey:@"msgs"];
                    if(msgs.count)
                    {
                        NSDictionary* msg = [msgs objectAtIndex:0];
                        if([[msg valueForKey:@"msg_flow"]isEqualToString:@"r"])
                        {
                            NSString* msgType = [msg valueForKey:API_TYPE];
                            if([msgType isEqualToString:VOIP_TYPE] || [msgType isEqualToString:VOIP_OUT])
                                showNotif = NO;
                            
                            NSString* groupId = Nil;
                            NSArray* contactIds = [msg valueForKey:@"contact_ids"];
                            for(NSDictionary* contact in contactIds)
                            {
                                if([[contact valueForKey:@"type"]isEqualToString:@"g"])
                                {
                                    groupId = [contact valueForKey:@"contact"];
                                }
                            }
                            if(groupId.length)
                            {
                                [mqttNotificationDic setValue:groupId forKey:@"group_id"];
                            }
                            else
                            {
                                NSString* fromPhoneNumber = [msg valueForKey:@"from_phone_num"];
                                if(fromPhoneNumber.length)
                                    [mqttNotificationDic setValue:fromPhoneNumber forKey:@"ph"];
                                NSNumber* fromIvUserId = [msg valueForKey:@"from_iv_user_id"];
                                if([fromIvUserId longValue])
                                    [mqttNotificationDic setValue:[fromIvUserId stringValue] forKey:@"user_id"];
                            }
                        }
                    }
                }
                
                //- Donot create notification if msg is voip type
                if(!showNotif) {
                    KLog(@"DONOT show notification");
                    EnLogd(@"DONOT show notification");
                    return;
                }
                
                //Notify the ChatGrid UI
                int eventToNotif = NOTIFY_IVMSG;
                NSArray* msgs = [notificationDic valueForKey:@"msgs"];
                if(msgs.count)
                {
                    NSDictionary* msg = [msgs objectAtIndex:0];
                    if([[msg valueForKey:@"msg_content_type"]isEqualToString:@"t"])
                    {
                        if([[msg valueForKey:@"type"]isEqualToString:@"mc"]) {
                            eventToNotif = NOTIFY_MISSEDCALL;
                        }
                    }
                    else if([[msg valueForKey:@"msg_content_type"]isEqualToString:@"a"])
                    {
                        if(/*APR 18 [[msg valueForKey:@"msg_subtype"]isEqualToString:@"avs"] &&*/
                           [[msg valueForKey:@"type"]isEqualToString:@"vsms"] ) {
                            eventToNotif = NOTIFY_VOICEMAIL;
                        }
                    }
                    else
                    {
                        eventToNotif = NOTIFY_IVMSG;
                        KLog(@" what else");
                    }
                }
                
                [mqttNotificationDic setValue:[NSNumber numberWithInt:eventToNotif] forKey:@"NOTIFY_UI"];
                NSString* notifHeading = @"InstaVoice";
#ifdef REACHME_APP
                notifHeading = @"ReachMe";
#endif
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NotificationBar notifyWithText:notifHeading detail:message
                                              image:[UIImage imageNamed:@"launcher_Icon"]
                                        andDuration:2.0 msgPayLoad:mqttNotificationDic];
                });
                
                if(eventToNotif>0) {
                    NSMutableDictionary* notifDic = [[NSMutableDictionary alloc]init];
                    [notifDic setValue:@"ENG_SUCCESS" forKey:@"ResponseCode"];
                    [notifDic setValue:[NSNumber numberWithInt:eventToNotif] forKey:EVENT_TYPE];
                    [[Engine sharedEngineObj]notifyUI:notifDic];
                }
                //
            }
        }
    }
}

+(BOOL)isMessageEligibleForNotificationBar:(NSDictionary*)notificationDic
{
    BOOL showNotification = false;
    BOOL isLoggedIn = [[ConfigurationReader sharedConfgReaderObj]getIsLoggedIn];
    BOOL localContactSync = [[ConfigurationReader sharedConfgReaderObj] getContactLocalSyncFlag];
#ifdef REACHME_APP
    localContactSync = TRUE;
#endif
    if(isLoggedIn && localContactSync)
    {
        NSString* groupId = nil;
        NSString* fromPhoneNumber = nil;
        NSString* fromIvUserId = nil;
        NSDictionary* aps = [notificationDic valueForKey:@"aps"];
        if(aps.count)
        {
            //Apple Push Notification
            //NSString *body    =  [[[notificationDic valueForKey:APS_NOTIFICATION] valueForKey:ALERT_NOTIFICATION] valueForKey:BODY_NOTIFICATION];
            groupId = [notificationDic valueForKey:@"group_id"];
            if(!groupId.length)
            {
                fromIvUserId = [notificationDic valueForKey:@"user_id"];
                fromPhoneNumber = [notificationDic valueForKey:@"ph"];
            }
        }
        else
        {
            //AVN_TODO_MQTT get the phone number iv user id and group id
            //MQTT Push Notification.
            NSArray* msgs = [notificationDic valueForKey:@"msgs"];
            if(msgs.count)
            {
                NSDictionary* msg = [msgs objectAtIndex:0];
                NSString* msgSubType = [msg valueForKey:@"msg_subtype"];
                if([msgSubType isEqualToString:GROUP_MSG_EVENT_TYPE])
                {
                    return false;
                }
                if([[msg valueForKey:@"msg_flow"]isEqualToString:@"r"])
                {
                    NSArray* contactIds = [msg valueForKey:@"contact_ids"];
                    for(NSDictionary* contact in contactIds)
                    {
                        if([[contact valueForKey:@"type"]isEqualToString:@"g"])
                        {
                            groupId = [contact valueForKey:@"contact"];
                        }
                    }
                    if(!groupId.length)
                    {
                        fromPhoneNumber = [msg valueForKey:@"from_phone_num"];
                        fromIvUserId = [[msg valueForKey:@"from_iv_user_id"]stringValue];
                    }
                }
            }
        }
        
        if(groupId.length || fromPhoneNumber.length || fromIvUserId.length)
        {
            showNotification = true;
            int uiType = [[UIStateMachine sharedStateMachineObj] getCurrentUIType];
            if(uiType == INSIDE_CONVERSATION_SCREEN)
            {
                NSMutableDictionary* currentChatUser = [[Engine sharedEngineObj]getCurrentChatUser];
                if(groupId.length)
                {
                    //group message
                    if([[currentChatUser valueForKey:FROM_USER_ID]isEqualToString:groupId])
                        showNotification = false;
                }
                else if(fromIvUserId.length)
                {
                    if([[currentChatUser valueForKey:REMOTE_USER_IV_ID]isEqualToString:fromIvUserId])
                        showNotification = false;
                }
                else
                    if([[currentChatUser valueForKey:FROM_USER_ID]isEqualToString:fromPhoneNumber])
                        showNotification = false;
            }
        }
    }
    return showNotification;
}

+(NSString*)getNotificationBarText:(NSDictionary*)notificationDic
{
    NSString* message = Nil;
    NSDictionary* aps = [notificationDic valueForKey:APS_NOTIFICATION];
    if(aps.count)
    {
        message = [[aps valueForKey:ALERT_NOTIFICATION]valueForKey:BODY_NOTIFICATION];
    }
    else
    {
        //MQTT -- AVN_TODO_MQTT -- create message from the data
        //message = @"MQTT Notification Received";
        NSArray* msgs = [notificationDic valueForKey:@"msgs"];
        if(msgs.count)
        {
            NSDictionary* msg = [msgs objectAtIndex:0];
            if([[msg valueForKey:@"msg_flow"]isEqualToString:@"r"])
            {
                __block NSString *sender = [msg valueForKey:@"sender_id"];
                
                //SEP 26
                //FIXME TODO server gives the sender ID in APNS payload but not in mqtt payload. Discuss with the server team.
                NSArray* contactIds = [msg valueForKey:@"contact_ids"];
                NSString* groupIdStr = nil;
                for(NSDictionary* contact in contactIds)
                {
                    if([[contact valueForKey:@"type"]isEqualToString:@"g"])
                    {
                        groupIdStr = [contact valueForKey:@"contact"];
                    }
                }
                if(groupIdStr.length) {
                    NSManagedObjectContext* moc = [AppDelegate sharedPrivateQueueContext];//NOV 2017
                    [moc performBlockAndWait:^{//NOV 2017
                        ContactData* data = [[Contacts sharedContact]getGroupHeaderForGroupId:groupIdStr usingMainQueue:NO];
                        //NSLog(@"groupInfo: %@",data.contactName);
                        if(nil!=data && [data.contactName length]) {
                            sender = [NSString stringWithFormat:@"%@@%@",sender,data.contactName];
                        }
                    }];
                }
                //---
                
                if(!sender.length)
                    sender = [msg valueForKey:@"from_phone_num"];
                
                if([[msg valueForKey:@"msg_content_type"]isEqualToString:@"t"])
                {
                    if([[msg valueForKey:@"type"]isEqualToString:@"mc"])
                    {
                        if([[msg valueForKey:@"msg_subtype"]isEqualToString:RING_MC])
                            message = [NSString stringWithFormat:@"%@: Ring Missed Call",sender];
                        else
                            message = [NSString stringWithFormat:@"%@: Missed Call",sender];
                    }
                    else{
                        message = [NSString stringWithFormat:@"%@: %@",sender,[msg valueForKey:@"msg_content"]];
                    }
                }else if ([[msg valueForKey:@"msg_content_type"]isEqualToString:@"a"])
                {
                    message = [NSString stringWithFormat:@"%@: Voice Message",sender];
                }else if ([[msg valueForKey:@"msg_content_type"]isEqualToString:@"i"])
                {
                    message = [NSString stringWithFormat:@"%@: Image",sender];
                }
               // message = [NSString stringWithFormat:@"MQTT Notification Received from %@",[msg valueForKey:@"from_phone_num"]];
            }
        }
    }
    return message;
}


@end
