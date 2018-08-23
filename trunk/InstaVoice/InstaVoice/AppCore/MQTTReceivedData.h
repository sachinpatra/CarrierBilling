//
//  MQTTReceivedData.h
//  InstaVoice
//
//  Created by adwivedi on 20/05/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    MQTTReceivedDataTypeFetchMessage = 1, //update last fetched msg id
    MQTTReceivedDataTypeFetchMessageActivity = 2,//update last
    MQTTReceivedDataTypeSendMessage = 3,
    MQTTReceivedDataTypeSendReadReceipt = 4,
    MQTTReceivedDataTypePendingEvent = 5,
    MQTTReceivedDataTypeFetchMessageAsNotification = 6, //same as 1 but dont update the last fetched msg id
    MQTTReceivedDataTypeFetchMessageActivityAsNotification = 7, //same as 2 but dont update the last activity id
    MQTTReceivedDataTypeFetchMessageAsBackgroundNotification = 8, //same as 1 but dont update the last fetched msg id
    MQTTReceivedDataTypeTranscriptionStatusAndText = 9
} MQTTReceivedDataType;

typedef enum : NSInteger {
    MQTTErrorTypeConnectionErrorPermanent = 1, //Host has changed or user credential has changed. fetch setting and reconnect
    MQTTErrorTypeConnectionErrorTemporary = 2, //Temporary network issue, will get resolved in some time by reconnecting next time.
    MQTTErrorTypeSendFailedError = 3,
    MQTTErrorTypeSendFailedTimeoutError = 4,
    MQTTErrorTypeReadReceiptSendFailedError = 5,
    MQTTErrorTypeReadReceiptSendFailedTimeoutError = 6
} MQTTErrorType;

typedef enum : NSInteger {
    MQTTPublishedDataTypeTextMessage = 1, //update last fetched msg id
    MQTTPublishedDataTypeReadReceipt = 2,//update last
    MQTTPublishedDataTypeAppStatus = 3
} MQTTPublishedDataType;

@interface MQTTReceivedData : NSObject
@property(nonatomic) MQTTReceivedDataType dataType;
@property(nonatomic) NSMutableDictionary* responseData;
@property(nonatomic) NSMutableDictionary* requestData;
@property(nonatomic) NSError* error;
@property(nonatomic) MQTTErrorType errorType;
@end


@interface MQTTPublishedData : NSObject
@property(nonatomic) MQTTPublishedDataType dataType;
@property(nonatomic) id publishData;
@property(nonatomic) NSString* msgGuid;
@property(nonatomic) NSInteger publishedMessageToken;
@end
