//
//  ChatActivity.h
//  InstaVoice
//
//  Created by adwivedi on 16/03/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    ChatActivityTypeDelete = 1,
    ChatActivityTypeLike = 2,
    ChatActivityTypeUnlike = 3,
    ChatActivityTypeVoboloShare = 4,
    ChatActivityTypeFacebookShare = 5,
    ChatActivityTypeTwitterShare = 6,
    ChatActivityTypeReadMessage = 7,
    ChatActivityTypeSeenMessage = 8,
    ChatActivityTypeWithdraw = 9,
    ChatActivityTypeRing = 10,
    ChatActivityTypeSeenAllMsg=11 //APR 2017
} ChatActivityType;

@interface ChatActivityData : NSObject
{
    ChatActivityType _activityType;
    NSInteger _msgId;
    NSString* _msgType;
    NSString* _msgGuid;
    NSArray* _msgDataList;
    NSMutableDictionary* dic;
}
@property(nonatomic) NSInteger msgId;
@property(nonatomic) ChatActivityType activityType;
@property(nonatomic) NSString* msgType;
@property(nonatomic) NSString* msgGuid;
@property(nonatomic) NSArray* msgDataList;
@property(nonatomic) NSMutableDictionary* dic;//CMP FEB 29

@end

@interface ChatActivity : NSObject
{
    NSMutableArray* _activityList;
    BOOL _canProcessActivity;
    BOOL _isActivityProcessing;
    NSInteger _networkFailureAttempt;
    NSLock* _lockEvents;
}

@property (atomic)BOOL isActivityProcessing;//NOV 2017
@property(nonatomic,strong)NSMutableArray* activityList;
+(id)sharedChatActivity;
//NOT USED -(void)resetActivityData;
-(void)addActivityOfType:(ChatActivityType)type withData:(NSMutableDictionary*)activityDic;
-(void)startProcessActivity;
-(void)stopProcessActivity;
-(void)chatActivity:(ChatActivityData*)activity processedSuccessfully:(BOOL)success;
@end
