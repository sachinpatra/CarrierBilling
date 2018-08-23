//
//  NotificationData.m
//  InstaVoice
//
//  Created by adwivedi on 16/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "NotificationData.h"

@implementation NotificationData

-(id)init
{
    if(self = [super init])
    {
        _msgId      = @"0";
        _msgDate = @"0";
        _msgDuration = 0;
        _msgType = @"";
        //DC MAY 26 2016
        _msgSubType = @"";
        _msgContent = @"";
        _msgFormat = @"";
        _msgContentType = @"";
        
        _contactNumber = @"";
        _contactType = @"";
        _contactName = @"";
        _contactPicURL = @"";
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [self init])
    {
        _msgId    = [aDecoder decodeObjectForKey:@"MSG_ID"];
        _msgDate = [aDecoder decodeObjectForKey:@"MSG_DATE"];
        _msgDuration = [aDecoder decodeIntegerForKey:@"MSG_DURATION"];
        _msgType = [aDecoder decodeObjectForKey:@"MSG_TYPE"];
        _msgSubType = [aDecoder decodeObjectForKey:@"MSG_SUBTYPE"];
        _msgContent = [aDecoder decodeObjectForKey:@"MSG_CONTENT"];
        _msgFormat = [aDecoder decodeObjectForKey:@"MSG_FORMAT"];
        _msgContentType = [aDecoder decodeObjectForKey:@"MSG_CONTENT_TYPE"];
        
        _contactName = [aDecoder decodeObjectForKey:@"CONTACT_NAME"];
        _contactPicURL = [aDecoder decodeObjectForKey:@"CONTACT_PIC_URL"];
        _contactNumber = [aDecoder decodeObjectForKey:@"CONTACT_NUMBER"];
        _contactType = [aDecoder decodeObjectForKey:@"CONTACT_TYPE"];
        
    }
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_msgId forKey:@"MSG_ID"];
    [aCoder encodeObject:_msgDate forKey:@"MSG_DATE"];
    [aCoder encodeInteger:_msgDuration forKey:@"MSG_DURATION"];
    [aCoder encodeObject:_msgType forKey:@"MSG_TYPE"];
    [aCoder encodeObject:_msgSubType forKey:@"MSG_SUBTYPE"];
    [aCoder encodeObject:_msgContent forKey:@"MSG_CONTENT"];
    [aCoder encodeObject:_msgFormat forKey:@"MSG_FORMAT"];
    [aCoder encodeObject:_msgContentType forKey:@"MSG_CONTENT_TYPE"];
    
    [aCoder encodeObject:_contactName forKey:@"CONTACT_NAME"];
    [aCoder encodeObject:_contactPicURL forKey:@"CONTACT_PIC_URL"];
    [aCoder encodeObject:_contactNumber forKey:@"CONTACT_NUMBER"];
    [aCoder encodeObject:_contactType forKey:@"CONTACT_TYPE"];
}

-(NSString*)description
{
    NSString *setting = [NSString stringWithFormat:@"Message of type %@ from %@ with content %@",_msgContentType,_contactNumber,_msgContent];
    return setting;
}


@end
