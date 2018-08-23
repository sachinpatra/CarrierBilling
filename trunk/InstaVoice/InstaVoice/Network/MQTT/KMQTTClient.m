//
//  KMQTTClient.m
//  InstaVoice
//
//  Created by Pandian on 10/01/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "KMQTTClient.h"
#import "Logger.h"


#pragma mark c_callback_functions protype
static void _onConnect(void* context, MQTTAsync_successData* response);
static void _onConnectionLost(void *context, char *cause);
static void _onConnectFailure(void* context, MQTTAsync_failureData* response);
static void _onSend(void* context, MQTTAsync_successData* response);
static void _onSendFailure(void* context, MQTTAsync_failureData* response);
static void _onMsgDelivered(void *context, MQTTAsync_token token);
static int _onMsgArrived(void *context, char *topicName, int topicLen, MQTTAsync_message *message);
static void _onSubscribe(void* context, MQTTAsync_successData* response);
static void _onSubscribeFailure(void* context, MQTTAsync_failureData* response);
static void _onDisconnect(void* context, MQTTAsync_successData* response);
static void _onDisconnectFailure(void* context, MQTTAsync_failureData* response);


@interface KMQTTClient()

//- private methods
- (KMQTTClient*) init;
- (KMQTTClient*) initWithServerURI:(NSString*)serverURI;
- (void) connect;
- (void) subscribe:(NSString*)topic;
- (void) reconnect;

- (void) onConnect:(NSInteger)causeCode;
- (void) onConnectionLost;
- (void) onConnectFailure:(NSInteger)causeCode;
- (void) onSend:(NSInteger)token;
- (void) onSendFailure:(NSInteger)causeCode withToken:(NSInteger)token;
- (void) onMsgDelivered:(NSInteger)token;
- (void) onMsgArrived:(NSData*)data;
- (void) onSubscribe:(NSInteger)causeCode;
- (void) onSubscribeFailure:(NSInteger)causeCode;
- (void) onDisconnect:(NSInteger)causeCode;
@end

@implementation KMQTTClient

+(KMQTTClient *)sharedMQTTClientObj
{
    static KMQTTClient* mqttClienObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mqttClienObj = [[self alloc]init];
#ifdef ENABLE_NSLOG
        setenv("MQTT_C_CLIENT_TRACE", "ON", 1);
        setenv("MQTT_C_CLIENT_TRACE_LEVEL", "ERROR", 1);
        MQTTAsync_nameValue* version = MQTTAsync_getVersionInfo();
        NSString* value = [NSString stringWithUTF8String: version->value];
        KLog(@"%@",value);
#endif
    });
    return mqttClienObj;
}

-(void)dealloc
{
    [self disconnect];
}

-(KMQTTClient*)init
{
    if((self = [super init])) {
        self.status = Idle;
        _subscribed = FALSE;
    }
    return self;
}

-(KMQTTClient*)initWithServerURI:(NSString *)serverURI
{
    if ((self = [super init])) {
        _serverURI = serverURI;
        self.status = Idle;
        _subscribed = FALSE;
    }
    
    return self;
}

-(void)setServerURI:(NSString*)host PortNumber:(NSInteger)port
{
    NSString* mqttHost = [NSString stringWithFormat:@"ssl://%@:%ld",host,port];
    _serverURI = mqttHost;
    
    //KLog(@"MQTT server URI:%@",mqttHost);
    EnLogd(@"MQTT server URI:%@",mqttHost);
}

-(void)connectToHostUsingDeviceID:(NSString *)clientID
{
    if(clientID && [clientID length]) {
        _clientID = clientID;
        [self connect];
    } else {
        EnLogd(@"Client ID null.");
        KLog(@"Client ID null.");
    }
}

-(void) connect
{
    if(Connecting == self.status) {
        KLog(@"MQTT client is already in connecting state; return.");
        EnLogd(@"MQTT client is already in connecting state; return.");
        return;
    }
    
    if(Connected == self.status) {
        KLog(@"MQTT client is already in connected state; return.");
        EnLogd(@"MQTT client is already in connected state; return.");
        return;
    }
    
    KLog(@"MQTT client is Connecting...");
    EnLogd(@"MQTT client is Connecting...");
    
    const char* cstrClientId = [_clientID cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cstrServerURI = [_serverURI cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSString* trustStore = [[NSBundle mainBundle] pathForResource:@"trustStore.pem" ofType:nil]; //server Cert
    NSString* keyStore = [[NSBundle mainBundle] pathForResource:@"keyStore.pem" ofType:nil]; //client cert
    NSString* clientKey = [[NSBundle mainBundle] pathForResource:@"client.key" ofType:nil];
    
    const char* cstrTrustStore = [trustStore cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cstrKeyStore = [keyStore cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cstrClientKey = [clientKey cStringUsingEncoding:NSUTF8StringEncoding];
    
    MQTTAsync_create(&_clientHandle, cstrServerURI, cstrClientId, MQTTCLIENT_PERSISTENCE_NONE, NULL);
    //MQTTAsync_setCallbacks(_clientHandle, (__bridge void*)(self), _onConnectionLost, _onMsgArrived, _onMsgDelivered);
    //_onSend is used to confirm msg delivery
    MQTTAsync_setCallbacks(_clientHandle, (__bridge void*)(self), _onConnectionLost, _onMsgArrived, NULL);
    
    MQTTAsync_connectOptions optsInit= MQTTAsync_connectOptions_initializer;
    _connectionOpts = optsInit;
    
    _connectionOpts.keepAliveInterval = KEEP_ALIVE_INTERVAL;//in secs
    _connectionOpts.cleansession = 1;
    _connectionOpts.onSuccess = _onConnect;
    _connectionOpts.onFailure = _onConnectFailure;
    _connectionOpts.context = (__bridge void*)(self);
    
    _connectionOpts.username = "guest";
    _connectionOpts.password = "guest";
    MQTTAsync_SSLOptions sslopts = MQTTAsync_SSLOptions_initializer;
    _connectionOpts.ssl = &sslopts;
    _connectionOpts.ssl->trustStore = cstrTrustStore;
    _connectionOpts.ssl->keyStore = cstrKeyStore;
    _connectionOpts.ssl->privateKey = cstrClientKey;
    _connectionOpts.ssl->privateKeyPassword = "123456";
    
    self.status = Connecting;
    int rc;
    if(!_clientHandle) {
        KLog(@"MQTTAsync_connect:_clientHandle is nil. Check the code.");
        EnLogd(@"MQTTAsync_connect:_clientHandle is nil. Check the code.");
        self.status = Idle;
        return;
    }
    if ((rc = MQTTAsync_connect(_clientHandle, &_connectionOpts)) != MQTTASYNC_SUCCESS)
    {
        KLog(@"Failed to start connect, return code:%d",rc);
        EnLogd(@"Failed to start connect, return code:%d",rc);
        self.status = Idle;
    }
}

-(void) reconnect
{
    const char* cstrClientId = [_clientID cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cstrServerURI = [_serverURI cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSString* trustStore = [[NSBundle mainBundle] pathForResource:@"trustStore.pem" ofType:nil]; //server Cert
    NSString* keyStore = [[NSBundle mainBundle] pathForResource:@"keyStore.pem" ofType:nil]; //client cert
    NSString* clientKey = [[NSBundle mainBundle] pathForResource:@"client.key" ofType:nil];
    
    const char* cstrTrustStore = [trustStore cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cstrKeyStore = [keyStore cStringUsingEncoding:NSUTF8StringEncoding];
    const char* cstrClientKey = [clientKey cStringUsingEncoding:NSUTF8StringEncoding];
    
    MQTTAsync_create(&_clientHandle, cstrServerURI, cstrClientId, MQTTCLIENT_PERSISTENCE_NONE, NULL);
    //MQTTAsync_setCallbacks(_clientHandle, (__bridge void*)(self), _onConnectionLost, _onMsgArrived, _onMsgDelivered);
    
    //_onSend is used to confirm msg delivery
    MQTTAsync_setCallbacks(_clientHandle, (__bridge void*)(self), _onConnectionLost, _onMsgArrived, NULL);
    
    MQTTAsync_connectOptions optsInit= MQTTAsync_connectOptions_initializer;
    _connectionOpts = optsInit;
    
    _connectionOpts.keepAliveInterval = KEEP_ALIVE_INTERVAL; //in seconds
    _connectionOpts.cleansession = 1;
    _connectionOpts.onSuccess = _onConnect;
    _connectionOpts.onFailure = _onConnectFailure;
    _connectionOpts.context = (__bridge void*)(self);
    
    _connectionOpts.username = "guest";
    _connectionOpts.password = "guest";
    MQTTAsync_SSLOptions sslopts = MQTTAsync_SSLOptions_initializer;
    _connectionOpts.ssl = &sslopts;
    _connectionOpts.ssl->trustStore = cstrTrustStore;
    _connectionOpts.ssl->keyStore = cstrKeyStore;
    _connectionOpts.ssl->privateKey = cstrClientKey;
    _connectionOpts.ssl->privateKeyPassword = "123456";
    
    self.status = Connecting;
    int rc;
    if ((rc = MQTTAsync_connect(_clientHandle, &_connectionOpts)) != MQTTASYNC_SUCCESS)
    {
        KLog(@"Failed to start re-connect, return code:%d",rc);
        EnLogd(@"Failed to start re-connect, return code:%d",rc);
        self.status = Idle;
    }
}

-(void) subscribe:(NSString *)topic
{
    MQTTAsync_responseOptions opts = MQTTAsync_responseOptions_initializer;
    const char* cstrTopic = [_clientID cStringUsingEncoding:NSUTF8StringEncoding]; //Client ID is topic here
    
    KLog(@"Subscribing to topic %s using QoS%d\n\n", cstrTopic, QOS);
    EnLogd(@"Subscribing to topic %s using QoS%d\n\n", cstrTopic, QOS);
    
    opts.onSuccess = _onSubscribe;
    opts.onFailure = _onSubscribeFailure;
    opts.context = (__bridge void*)(self);
    
    int rc;
    if ((rc = MQTTAsync_subscribe(_clientHandle, cstrTopic, QOS, &opts)) != MQTTASYNC_SUCCESS)
    {
        KLog(@"Failed to start subscribe, return code %d\n", rc);
        EnLogd(@"Failed to start subscribe, return code %d\n", rc);
    }
}

/*
 Returns token number on success, otherwise returns -1.
 */
-(int) publish:(NSString*)message ToTheTopic:(NSString*)topic;
{
    MQTTAsync_responseOptions opts = MQTTAsync_responseOptions_initializer;
    MQTTAsync_message pubmsg = MQTTAsync_message_initializer;
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    
    const char* cstrMessage = [message cStringUsingEncoding:NSUTF8StringEncoding];
    
    opts.onSuccess = _onSend;
    opts.onFailure = _onSendFailure;
    opts.context = (__bridge void*)(self);;
    
    pubmsg.payload = (void*)cstrMessage;
    pubmsg.payloadlen = strlen(cstrMessage);
    pubmsg.qos = QOS;
    pubmsg.retained = 0;
    
    //KLog(@"Publishing topic: %s", cstrTopic);
    int rc = MQTTAsync_sendMessage(_clientHandle, cstrTopic, &pubmsg, &opts);
    if(MQTTASYNC_SUCCESS != rc) {
        KLog(@"Failed to send the message, return code:%d", rc);
        EnLogd(@" Failed to send the message, return code:%d",rc);
        if( rc >= 0) rc = -1;
    }
    else {
        //KLog(@"MQTTAsync_sendMessage succeeded.");
        rc = opts.token;
    }
    
    return rc;
}

-(void) disconnect
{
    if(!_subscribed) {
        KLog(@"NOT previously subscribed. just return.");
        EnLogd(@"NOT previously subscribed. just return.");
        self.status = Idle;
        return;
    }
    
    if(self.status == Disconnected)
        return;
    
    MQTTAsync_disconnectOptions opts = MQTTAsync_disconnectOptions_initializer;
    opts.onSuccess = _onDisconnect;
    opts.onFailure = _onDisconnectFailure;
    opts.context = (__bridge void*)(self);
    
    self.status = Disconnecting;
    int rc;
    if ((rc = MQTTAsync_disconnect(_clientHandle, &opts)) != MQTTASYNC_SUCCESS)
    {
        KLog(@"Failed to start disconnect, return code %d\n", rc);
        EnLogd(@"Failed to start disconnect, return code %d\n", rc);
        self.status = Idle;
        return;
    }
}

- (void)closeClient
{
    self.status = Disconnecting;
    if(_clientHandle)
        MQTTAsync_destroy(&_clientHandle);
 
    self.status = Idle;
    _clientHandle = NULL;
}

-(BOOL)isConnected {
    /*
     int rc = MQTTAsync_isConnected(_clientHandle);
     return _connected;
     */
    return (self.status == Connected);
}

#pragma mark Calling Delegate Methods on Main Thread

- (void) onConnectInMainThread:(MQTTClientStatusCode)statusCode
{
    [self.delegate mqttClientDidFinishConnectingWithStatusCode:statusCode];
}

- (void) onConnectionLostInMainThread
{
    [self.delegate mqttClientDidLoseConnection];
}

- (void) onConnectFailureInMainThread
{
    [self.delegate mqttClientDidFailToConnect];
}

- (void) onSendInMainThread:(NSNumber*)token
{
    NSInteger iToken = [token longValue];
    [self.delegate mqttClientDidFinishPublishing:iToken];
}

- (void) onSendFailureInMainThread:(NSNumber*)token
{
    NSInteger iToken = [token longValue];
    [self.delegate mqttClientDidFailPublishingRequestData:-1 withToken:iToken];
}

- (void) onMsgDeliveredInMainThread:(NSNumber*)token
{
    NSInteger iToken = [token longValue];
    [self.delegate mqttClientDidFinishPublishing:iToken];
}

-(void) onMsgArrivedInMainThread:(NSData *)data
{
    //KLog(@"OnMsgArrived");
    NSError *error = nil;
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    [self.delegate mqttClientDidReceiveSubscriptionData:dic];
}

-(void) onSubscribeInMainThread
{
    [self.delegate mqttClientDidFinishSubscription];
}

- (void) onSubscribeFailureInMainThread
{
    [self.delegate mqttClientDidFailToSubscribe];
}

- (void) onDisconnectInMainThread:(NSNumber*)causeCode
{
    NSInteger iCauseCode = [causeCode longValue];
    [self.delegate mqttClientDidDisconnectWithStatusCode:iCauseCode];
}


#pragma mark MQTTClient-obj methods correspond to c_callback_functions
- (void) onConnect:(NSInteger)causeCode
{
    self.status = Connected;
    //DEC 26 [self performSelectorOnMainThread:@selector(onConnectInMainThread:) withObject:ConnectionAccepted waitUntilDone:NO];
    [self performSelectorInBackground:@selector(onConnectInMainThread:) withObject:ConnectionAccepted];//DEC 26, 2016
    [self subscribe:_clientID];
}

- (void) onConnectionLost
{
    self.status = Disconnected;
    _subscribed = FALSE;
    //MAY 14, 2017 [self performSelectorOnMainThread:@selector(onConnectionLostInMainThread) withObject:nil waitUntilDone:NO];
    [self performSelectorInBackground:@selector(onConnectionLostInMainThread) withObject:nil];//APR 29,16
}

- (void) onConnectFailure:(NSInteger)causeCode
{
    self.status = Disconnected;
    //MAY 14, 2017 [self performSelectorOnMainThread:@selector(onConnectFailureInMainThread) withObject:nil waitUntilDone:NO];
    [self performSelectorInBackground:@selector(onConnectFailureInMainThread) withObject:nil];//APR 29,16
}

-(void) onSend:(NSInteger)token;
{
    //MAY 14, 2017 [self performSelectorOnMainThread:@selector(onSendInMainThread:) withObject:[NSNumber numberWithLong:token] waitUntilDone:NO];
    [self performSelectorInBackground:@selector(onSendInMainThread:) withObject:[NSNumber numberWithLong:token]];//APR 29,16
    
}

-(void) onSendFailure:(NSInteger)causeCode withToken:(NSInteger)token
{
    //MAY 14, 2017 [self performSelectorOnMainThread:@selector(onSendFailureInMainThread:) withObject:[NSNumber numberWithLong:token] waitUntilDone:NO];
    [self performSelectorInBackground:@selector(onSendFailureInMainThread:) withObject:[NSNumber numberWithLong:token]];//APR 29,16
}

-(void) onMsgDelivered:(NSInteger)token
{
    //MAY 14, 2017 [self performSelectorOnMainThread:@selector(onMsgDeliveredInMainThread:) withObject:[NSNumber numberWithLong:token] waitUntilDone:NO];
    [self performSelectorInBackground:@selector(onMsgDeliveredInMainThread:) withObject:[NSNumber numberWithLong:token]];
}

-(void) onMsgArrived:(NSData *)data
{
    //MAY 14, 2017 [self performSelectorOnMainThread:@selector(onMsgArrivedInMainThread:) withObject:data waitUntilDone:NO];
    [self performSelectorInBackground:@selector(onMsgArrivedInMainThread:) withObject:data];//APR 29,16
}

- (void) onSubscribe:(NSInteger)causeCode
{
    _subscribed = TRUE;
    //MAY 14, 2017 [self performSelectorOnMainThread:@selector(onSubscribeInMainThread) withObject:nil waitUntilDone:NO];
    [self performSelectorInBackground:@selector(onSubscribeInMainThread) withObject:nil];//APR 29,16
}

-(void) onSubscribeFailure:(NSInteger)causeCode
{
    _subscribed = FALSE;
    //MAy 14, 2017 [self performSelectorOnMainThread:@selector(onSubscribeFailureInMainThread) withObject:nil waitUntilDone:NO];
    [self performSelectorInBackground:@selector(onSubscribeFailureInMainThread) withObject:nil];//APR 29,16
}

-(void) onDisconnect:(NSInteger)causeCode
{
    self.status = Disconnected;
    _subscribed = FALSE;
    
    if(!causeCode) {
        //KLog(@"Disconnection succeeded.");
    } else {
        //KLog(@"Disconnection failed.");
    }
    
    //MAY 14, 2017 [self performSelectorOnMainThread:@selector(onDisconnectInMainThread:) withObject:[NSNumber numberWithLong:causeCode] waitUntilDone:NO];
    
    [self performSelectorInBackground:@selector(onDisconnectInMainThread:) withObject:[NSNumber numberWithLong:causeCode]];//APR 29,16
}

@end


#pragma mark C_CALLBACK_FUNCTIONS

static void _onConnect(void* context, MQTTAsync_successData* response)
{
    KMQTTClient* clientObj = (__bridge KMQTTClient*)context;
    [clientObj onConnect:0];
}

static void _onConnectionLost(void *context, char *cause)
{
    KMQTTClient* clientObj = (__bridge KMQTTClient*)context;
    [clientObj onConnectionLost];
}

static void _onConnectFailure(void* context, MQTTAsync_failureData* response)
{
    KMQTTClient* clientObj = (__bridge KMQTTClient*)context;
    int rc = response ? response->code : 0;
    [clientObj onConnectFailure:rc];
}

static void _onSend(void* context, MQTTAsync_successData* response)
{
    KMQTTClient* clientObj = (__bridge KMQTTClient*)context;
    MQTTAsync_token token = response->token;
    [clientObj onSend:token];
}

static void _onSendFailure(void* context, MQTTAsync_failureData* response)
{
    KMQTTClient* clientObj = (__bridge KMQTTClient*)context;
    int rc = response ? response->code : 0;
    int token = response ? response->token : 0;
    [clientObj onSendFailure:rc withToken:token];
}

static void _onMsgDelivered(void *context, MQTTAsync_token token)
{
    KMQTTClient* clientObj = (__bridge KMQTTClient*)context;
    [clientObj onMsgDelivered:(long)token];
}

static int _onMsgArrived(void *context, char *topicName, int topicLen, MQTTAsync_message *message)
{
    
    KMQTTClient* clientObj = (__bridge KMQTTClient*)context;
    
    /*
     int i;
     char* payloadptr;
     char msgPayload[1024];
     */
    
    /*
     printf("Message arrived\n");
     printf("     topic: %s\n", topicName);
     printf("   message: ");
     */
    
    /*
     payloadptr = message->payload;
     for(i=0; i<message->payloadlen; i++)
     {
     msgPayload[i] = (*payloadptr);
     putchar(*payloadptr++);
     }
     msgPayload[i] = '\0';
     putchar('\n');
     */
    
    @autoreleasepool {
        NSString* strMessage = [[NSString alloc] initWithBytes:message->payload length:message->payloadlen encoding:NSUTF8StringEncoding];
        NSData *data = [strMessage dataUsingEncoding:NSUTF8StringEncoding];
        [clientObj onMsgArrived:data];
    }
    
    MQTTAsync_freeMessage(&message);
    MQTTAsync_free(topicName);
    return 1;
}

static void _onSubscribe(void* context, MQTTAsync_successData* response)
{
    KMQTTClient* clientObj = (__bridge KMQTTClient*)context;
    [clientObj onSubscribe:0];
}

static void _onSubscribeFailure(void* context, MQTTAsync_failureData* response)
{
    KMQTTClient* clientObj = (__bridge KMQTTClient*)context;
    int rc = response ? response->code : 0;
    [clientObj onSubscribeFailure:rc];
}

static void _onDisconnect(void* context, MQTTAsync_successData* response)
{
    KMQTTClient* clientObj = (__bridge KMQTTClient*)context;
    [clientObj onDisconnect:0];
}

static void _onDisconnectFailure(void* context, MQTTAsync_failureData* response)
{
    KMQTTClient* clientObj = (__bridge KMQTTClient*)context;
    [clientObj onDisconnect:1];
}
