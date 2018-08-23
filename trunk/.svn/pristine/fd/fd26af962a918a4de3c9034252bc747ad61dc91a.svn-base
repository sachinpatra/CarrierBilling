//
//  ChatActivity.m
//  InstaVoice
//
//  Created by adwivedi on 16/03/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "ChatActivity.h"
#import "IVFileLocator.h"
#import "DeleteMessageAPI.h"
#import "WithdrawMessageAPI.h"
#import "LikeUnlikeMessageAPI.h"
#import "ShareMessageAPI.h"
#import "ReadMessageCountAPI.h"
#import "ScreenUtility.h"

#import "TableColumns.h"
#import "Engine.h"
#import "EventType.h"
#import "Common.h"
#import "ConversationApi.h"
#import "MQTTManager.h"

@implementation ChatActivityData

-(id)init
{
    if(self = [super init])
    {
        _activityType = 0;
        _msgId = 0;
        _msgType = @"";
        _msgGuid = @"";
        _msgDataList = Nil;
        _dic = nil;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [self init])
    {
        _msgId = [aDecoder decodeIntegerForKey:@"MSG_ID"];
        _activityType = [aDecoder decodeIntegerForKey:@"ACTIVITY_TYPE"];
        _msgType = [aDecoder decodeObjectForKey:@"MSG_TYPE"];
        _msgGuid = [aDecoder decodeObjectForKey:@"MSG_GUID"];
        _msgDataList = [aDecoder decodeObjectForKey:@"MSG_DATA_LIST"];
    }
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_msgId forKey:@"MSG_ID"];
    [aCoder encodeInteger:_activityType forKey:@"ACTIVITY_TYPE"];
    [aCoder encodeObject:_msgType forKey:@"MSG_TYPE"];
    [aCoder encodeObject:_msgGuid forKey:@"MSG_GUID"];
    [aCoder encodeObject:_msgDataList forKey:@"MSG_DATA_LIST"];
}

-(NSString*)description
{
    NSString *chatActivity = [NSString stringWithFormat:@"Activity With msg id %ld, activity type %d and msg guid %@ ,msgType %@ and msgDataList %@",_msgId,(int)_activityType,_msgGuid,_msgType,_msgDataList];
    return chatActivity;
}

-(NSString*)debugDescription
{
    return [self description];
}

@end

static ChatActivity* _sharedChatActivity = nil;
@implementation ChatActivity

-(id)init
{
    if(self = [super init])
    {
        NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath]
                                     stringByAppendingPathComponent:@"ChatActivity.dat"];
        
        @try {
            self.activityList = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];
        }
        @catch (NSException *exception) {
            self.activityList = [[NSMutableArray alloc]init];
            KLog(@"Unable to create object from archive file");
        }
    
        if(self.activityList == Nil)
        {
            self.activityList = [[NSMutableArray alloc]init];
        }
        
        _canProcessActivity = YES;
        _isActivityProcessing = NO;
        _networkFailureAttempt = 0;
        
        _lockEvents = [[NSLock alloc]init];
    }
    return self;
}

+(id)sharedChatActivity
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedChatActivity = [ChatActivity new];
    });
    return _sharedChatActivity;
}

-(void)writeActivityDataInFile
{
    NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath]
                                 stringByAppendingPathComponent:@"ChatActivity.dat"];
    [NSKeyedArchiver archiveRootObject:self.activityList toFile:archiveFilePath];
}
/* NOT USED
-(void)resetActivityData
{
    self.activityList = [[NSMutableArray alloc]init];
    [self writeActivityDataInFile];
}*/

-(void)startProcessActivity
{
    _canProcessActivity = YES;
    [self processServerActivity];
}

-(void)stopProcessActivity
{
    _canProcessActivity = NO;
}

-(void)addActivityOfType:(ChatActivityType)type withData:(NSMutableDictionary*)activityDic
{
    ChatActivityData* activity = [[ChatActivityData alloc]init];
    activity.activityType = type;
    //Jan 16, 2017 activity.dic = nil;
    activity.dic = activityDic;
    
    BOOL isProcessingRequired = true;
    
    switch (type) {
        case ChatActivityTypeSeenMessage:
        case ChatActivityTypeReadMessage:
        {
            if ([[activityDic valueForKey:API_MSG_IDS] count] > 0)
            {
                //CMP
                activity.msgGuid = [activityDic valueForKey:MSG_GUID];
                activity.msgId = [[activityDic valueForKey:MSG_ID]intValue];
                //
                activity.msgDataList = [activityDic valueForKey:API_MSG_IDS];
                activity.msgType = [activityDic valueForKey:MSG_TYPE];
            }
            else
                isProcessingRequired = false;
            break;
        }
            
        case ChatActivityTypeSeenAllMsg:
        {
            KLog(@"addActivityOfType: ChatActivityTypeSeenAllMsg");
            [self addDBEventToEngine:activity];
            break;
        }
 
        default:
        {
            activity.msgGuid = [activityDic valueForKey:MSG_GUID];
            activity.msgId = [[activityDic valueForKey:MSG_ID]longValue];
            activity.msgType = [activityDic valueForKey:MSG_TYPE];
        }
            break;
    }
    
    if(isProcessingRequired)
    {
        if(ChatActivityTypeWithdraw == activity.activityType || ChatActivityTypeDelete == activity.activityType) {
             NSString* msgStatus =[activityDic valueForKey:MSG_STATE];
            if( [msgStatus isEqualToString:API_NETUNAVAILABLE] || [msgStatus isEqualToString:API_UNSENT]) {
                [self addDBEventToEngine:activity];
            }
            else {
                [self addActivityForServerProcessing:activity];
                [self processServerActivity];
            }
        }
        else {
            [self preprocessActivity:activity forData:activityDic];
            [self addDBEventToEngine:activity];
            [self addActivityForServerProcessing:activity];
            [self processServerActivity];
        }
    }
}

-(void)preprocessActivity:(ChatActivityData*)activity forData:(NSMutableDictionary*)activityDic
{
    switch (activity.activityType) {
            
        case ChatActivityTypeWithdraw:
            break;
            
        case ChatActivityTypeDelete:
        {
            //process deletion of miss call list.
            //process deletion of file.
            /* CMP MAR 17
            NSString *path = [activityDic valueForKey:MSG_LOCAL_PATH];
            if(path != nil && [path length]>0)
            {
                [IVFileLocator deleteFileAtPath:path];
            }
            NSString* msgType = [activityDic valueForKey:MSG_CONTENT_TYPE];
            if(msgType && [msgType isEqualToString:IMAGE_TYPE])
            {
                NSString* filePath = [[IVFileLocator getMediaImagePath:[activityDic valueForKey:MSG_LOCAL_PATH]] stringByAppendingPathExtension:[activityDic valueForKey:MEDIA_FORMAT]];
                [IVFileLocator deleteFileAtPath:filePath];
            }*/
        }
            break;
        
        case ChatActivityTypeSeenMessage:
        case ChatActivityTypeReadMessage:
        {
            if(([activity.msgType isEqualToString:@"vb"] || [activity.msgType isEqualToString:@"cl" ]))
            {
                activity.msgType = @"vb";
            }
            else
            {
                activity.msgType = @"iv";
            }
        }
            break;
            
        default:
            break;
    }
}

-(void)addDBEventToEngine:(ChatActivityData*)activityData
{
    NSMutableDictionary *eventObj = [[NSMutableDictionary alloc]init];
    [eventObj setValue:UI_EVENT forKey:EVENT_MODE];
    [eventObj setValue:[NSNumber numberWithInt:CHAT_ACTIVITY] forKey:EVENT_TYPE];
    [eventObj setValue:activityData forKey:EVENT_OBJECT];
    [[Engine sharedEngineObj] addEvent:eventObj];
}

-(void)addActivityForServerProcessing:(ChatActivityData *)activityData
{
    [_lockEvents lock];
    [self.activityList addObject:activityData];
    [self writeActivityDataInFile];
    [_lockEvents unlock];
}

#pragma mark -- Network Activity
//AVN_ACT -- call api
-(void)processServerActivity
{
    KLog(@"processServerActivity, isActivityProcessing=%d",_isActivityProcessing);
    if([Common isNetworkAvailable])
    {
        if(_canProcessActivity && !_isActivityProcessing && self.activityList.count > 0)
        {
            _isActivityProcessing = YES;
            ChatActivityData* activity = nil;
            
            @try {
                activity = [self.activityList objectAtIndex:0];
            } @catch(NSException* ex) {
                EnLogd(@"Exception: %@", ex);
            }
            
            if(!activity)
                return;
            
            switch (activity.activityType) {
                case ChatActivityTypeDelete:
                    [self deleteActivity:activity];
                    break;
                    
                case ChatActivityTypeWithdraw:
                    [self withdrawActivity:activity];
                    break;
                    
                case ChatActivityTypeLike:
                case ChatActivityTypeUnlike:
                    [self likeUnlikeActivity:activity];
                    break;
                    
                case ChatActivityTypeVoboloShare:
                case ChatActivityTypeFacebookShare:
                case ChatActivityTypeTwitterShare:
                    [self shareActivity:activity];
                    break;
                    
                case ChatActivityTypeSeenMessage:
                    [self processSuccessForActivity:activity];
                    break;
                    
                case ChatActivityTypeReadMessage:
                    if(![activity.msgType isEqualToString:VB_TYPE]) {
                        [self readMsgCount:activity];
                    } else {
                        KLog(@"Do not call read_msgs API");
                        [self processSuccessForActivity:activity];
                    }
                    break;
                    
                default:
                    [self processSuccessForActivity:activity];
                    break;
            }
        }
    }
}

-(void)deleteActivity:(ChatActivityData*)activity
{
    KLog(@"deleteActivity: %@",activity);
    if(activity.msgId > 0)
    {
        DeleteMessageAPI* api = [[DeleteMessageAPI alloc]initWithRequest:nil];
        KLog(@"Calling DeleteMessageAPI");
        [api callNetworkRequest:activity withSuccess:^(DeleteMessageAPI *req, BOOL responseObject) {
            KLog(@"DeleteMessaeAPI %d",responseObject);
            [self addDBEventToEngine:activity];
            [self preprocessActivity:activity forData:activity.dic];
            [self processSuccessForActivity:activity];
        } failure:^(DeleteMessageAPI *req, NSError *error) {
            KLog(@"DeleteMessaeAPI %@",error);
            [self processError:error forActivity:activity];
        }];
    }
    else
    {
        [self processSuccessForActivity:activity];
    }
}

-(void)withdrawActivity:(ChatActivityData*)activity
{
    if(activity.msgId > 0)
    {
        WithdrawMessageAPI* api = [[WithdrawMessageAPI alloc]initWithRequest:nil];
        [api callNetworkRequest:activity withSuccess:^(WithdrawMessageAPI *req, BOOL responseObject) {
            [self addDBEventToEngine:activity];
            [self preprocessActivity:activity forData:activity.dic];
            [self processSuccessForActivity:activity];
        } failure:^(WithdrawMessageAPI *req, NSError *error) {
            [self processError:error forActivity:activity];
        }];
    }
    else
    {
        [self processSuccessForActivity:activity];
    }
}

-(void)likeUnlikeActivity:(ChatActivityData *)activity
{
    LikeUnlikeMessageAPI *api = [[LikeUnlikeMessageAPI alloc]initWithRequest:nil];
    [api callNetworkRequest:activity withSuccess:^(LikeUnlikeMessageAPI *req, BOOL responseObject) {
        [self processSuccessForActivity:activity];
    } failure:^(LikeUnlikeMessageAPI *req, NSError *error) {
        [self processError:error forActivity:activity];
    }];
}

-(void)shareActivity:(ChatActivityData *)activity
{
    ShareMessageAPI *api = [[ShareMessageAPI alloc]initWithRequest:nil];
    [api callNetworkRequest:activity withSuccess:^(ShareMessageAPI *req, BOOL responseObject) {
        [self processSuccessForActivity:activity];
    } failure:^(ShareMessageAPI *req, NSError *error) {
        [self processError:error forActivity:activity];
    }];
}

-(void)readMsgCount:(ChatActivityData *)activity {
    if([[MQTTManager sharedMQTTManager]canProcessThroughMQTT])
    {   //AVN_TO_DO_MQTT
        //call for MQTT read receipt.
        
        //NOV 2017 [[MQTTManager sharedMQTTManager]publishReadReceiptData:activity];
        
        //NOV 2017
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[MQTTManager sharedMQTTManager]publishReadReceiptData:activity];
        });
        //
        
        //success handler
        //[self processSuccessForActivity:activity];
        //error handler
       // NSError* error = [NSError errorWithDomain:@"IVError" code:-1 userInfo:nil];
        //[self processError:error forActivity:activity];
    }
    else
    {
        ReadMessageCountAPI *api = [[ReadMessageCountAPI alloc]initWithRequest:nil];
        [api callNetworkRequest:activity withSuccess:^(ReadMessageCountAPI *req, BOOL responseObject) {
            [self processSuccessForActivity:activity];
        } failure:^(ReadMessageCountAPI *req, NSError *error) {
            [self processError:error forActivity:activity];
        }];
    }
}

-(void)processSuccessForActivity:(ChatActivityData*)activity
{
    _networkFailureAttempt = 0;
    _isActivityProcessing = NO;
    
    if(ChatActivityTypeDelete == activity.activityType || ChatActivityTypeWithdraw == activity.activityType) {
        NSString *path = [activity.dic valueForKey:MSG_LOCAL_PATH];
        if(path != nil && [path length]>0)
        {
            [IVFileLocator deleteFileAtPath:path];
        }
        NSString* msgType = [activity.dic valueForKey:MSG_CONTENT_TYPE];
        if(msgType && [msgType isEqualToString:IMAGE_TYPE])
        {
            NSString* filePath = [[IVFileLocator getMediaImagePath:[activity.dic valueForKey:MSG_LOCAL_PATH]] stringByAppendingPathExtension:[activity.dic valueForKey:MEDIA_FORMAT]];
            [IVFileLocator deleteFileAtPath:filePath];
        }
    }
    
    [_lockEvents lock];
    [self.activityList removeObject:activity];
    [self writeActivityDataInFile];
    [_lockEvents unlock];
    [self processServerActivity];
}

-(void)processError:(NSError*)error forActivity:(ChatActivityData*)activity
{
    _isActivityProcessing = NO;
    if([error.domain isEqualToString:@"IVError"] && error.code > 1)
    {
        //except for system error no need to retry the request as server will always fail.
        KLog(@"Server not able to process activity %@ for error reason %@ and code %ld",activity,error.userInfo,(long)error.code);
        if(ChatActivityTypeWithdraw ==  activity.activityType) {
            [ScreenUtility showAlert:@"Message could not be withdrawn. Please try later."];
        }
        [_lockEvents lock];
        [self.activityList removeObject:activity];
        [self writeActivityDataInFile];
        [_lockEvents unlock];
        
        _networkFailureAttempt = 0;
    }
    else
    {
        //Network error or server not reachable
        _networkFailureAttempt++;
        if(_networkFailureAttempt < 3)
            [self processServerActivity];
    }
}

-(void)chatActivity:(ChatActivityData*)activity processedSuccessfully:(BOOL)success;
{
    if(success)
    {
        [self processSuccessForActivity:activity];
    }
    else
    {
        NSError* error = [NSError errorWithDomain:@"MQTTError" code:1 userInfo:nil];
        [self processError:error forActivity:activity];
    }
}

@end
