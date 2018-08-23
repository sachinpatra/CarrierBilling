//
//  NotificationData.h
//  InstaVoice
//
//  Created by adwivedi on 16/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationData : NSObject
{
    NSString* _msgId;
    NSString* _msgDate;
    NSInteger _msgDuration;
    NSString* _msgType;
    NSString* _msgContent;
    NSString* _msgFormat;
    NSString* _msgContentType;
    
    NSString* _contactName;
    NSString* _contactPicURL;
    NSString* _contactNumber;
    NSString* _contactType;
}
@property (nonatomic,strong) NSString *msgId;//msg_id
@property (nonatomic,strong) NSString *msgDate;//msg_dt -- long long
@property (nonatomic) NSInteger msgDuration;//duration
@property (nonatomic,strong) NSString *msgType;//msg_type iv mc or vsms
//DC MAY 26 2016
@property (nonatomic,strong) NSString *msgSubType;//msg_type iv Ring mc
@property (nonatomic,strong) NSString *msgContent;//content or msg_uri
@property (nonatomic,strong) NSString *msgFormat;//msg_format opus
@property (nonatomic,strong) NSString *msgContentType;// t a or i

@property (nonatomic,strong) NSString *contactName;//sender_id
@property (nonatomic,strong) NSString *contactPicURL;//pic_uri
@property (nonatomic,strong) NSString *contactNumber;//phone
@property (nonatomic,strong) NSString *contactType;//sender_type else non iv user

@end
