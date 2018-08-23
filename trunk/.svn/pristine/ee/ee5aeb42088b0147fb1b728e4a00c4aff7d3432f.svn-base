//
//  KMQTTClient.h
//  InstaVoice
//
//  Created by Pandian on 10/01/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "MQTTAsync.h"

#define QOS   1
#define KEEP_ALIVE_INTERVAL  60 //in secs

#ifdef ENABLE_NSLOG
    #define MQTT_C_CLIENT_TRACE ON
    #define MQTT_C_CLIENT_TRACE_LEVEL PROTOCOL
#endif


typedef enum MQTTClientStatusCode : NSInteger {
    ConnectionAccepted,
    ConnectionRefusedServerUnavailable,
    ConnectionLost,
    SubscriptionStartFailed,
    SubscriptionFailed,
    SubscriptionSucceeded,
    PublishStartFailed,
    PublishFailed,
    PublishSucceeded,
    DisconnectionSucceeded
} MQTTClientStatusCode;

typedef enum MQTTClientConnectStatus: NSInteger {
    Idle,
    Connecting,
    Connected,
    Disconnecting,
    Disconnected
}MQTTClientConnectStatus;

@protocol MQTTClientManagerDelegate <NSObject>
-(void)mqttClientDidFinishConnectingWithStatusCode:(MQTTClientStatusCode)statusCode;
-(void)mqttClientDidFailToConnect;
-(void)mqttClientDidLoseConnection;
-(void)mqttClientDidFinishSubscription;
-(void)mqttClientDidFailToSubscribe;
-(void)mqttClientDidSubmitForPublishingRequestData:(NSInteger)deliveryToken;
-(void)mqttClientDidFailPublishingRequestData:(NSInteger)causeCode withToken:(NSInteger)deleiveryToken;
-(void)mqttClientDidFinishPublishing:(NSInteger)deliveryToken;
-(void)mqttClientDidReceiveSubscriptionData:(NSMutableDictionary*)responseData;
-(void)mqttClientDidDisconnectWithStatusCode:(MQTTClientStatusCode)statusCode;
@end

@interface KMQTTClient : NSObject
{
    MQTTAsync_connectOptions _connectionOpts;
    MQTTAsync _clientHandle;
    NSString* _clientID;
    NSString* _serverURI;
    BOOL _subscribed;
    //MQTTClientConnectStatus _status;
}

@property (atomic)MQTTClientStatusCode status;

+ (KMQTTClient *)sharedMQTTClientObj;

@property(nonatomic,strong)id<MQTTClientManagerDelegate> delegate;

- (void) setServerURI:(NSString*)host PortNumber:(NSInteger)port;
- (void) connectToHostUsingDeviceID:(NSString*)clientID;
- (int) publish:(NSString *)message ToTheTopic:(NSString *)topic;
- (void) disconnect;
- (void) closeClient;
- (BOOL) isConnected;

@end


