//
//  SettingModelMqtt.m
//  InstaVoice
//
//  Created by adwivedi on 18/05/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "SettingModelMqtt.h"

@implementation SettingModelMqtt
-(id)init
{
    if(self = [super init])
    {
        _chatTopic = @"";
        _chatHostName = @"";
        _chatPortSSL = 0;
        _chatUser = @"";
        _chatPassword = @"";
        _mqttHostName = @"";
        _mqttPortSSL = 0;
        _mqttPassword = @"";
        _mqttUser = @"";
        _deviceId = [NSNumber numberWithLong:0];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [self init])
    {
        _chatTopic = [aDecoder decodeObjectForKey:@"CHAT_TOPIC"];
        _chatHostName = [aDecoder decodeObjectForKey:@"CHAT_HOST_NAME"];
        _chatPortSSL = [aDecoder decodeIntegerForKey:@"CHAT_PORT_SSL"];
        _chatUser = [aDecoder decodeObjectForKey:@"CHAT_USER"];
        _chatPassword = [aDecoder decodeObjectForKey:@"CHAT_PASSWORD"];
        _mqttHostName = [aDecoder decodeObjectForKey:@"MQTT_HOST_NAME"];
        _mqttPortSSL = [aDecoder decodeIntegerForKey:@"MQTT_PORT_SSL"];
        _mqttPassword = [aDecoder decodeObjectForKey:@"MQTT_PASSWORD"];
        _mqttUser = [aDecoder decodeObjectForKey:@"MQTT_USER"];
        _deviceId = [aDecoder decodeObjectForKey:@"DEVICE_ID"];
    }
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_chatTopic forKey:@"CHAT_TOPIC"];
    [aCoder encodeObject:_chatHostName forKey:@"CHAT_HOST_NAME"];
    [aCoder encodeInteger:_chatPortSSL forKey:@"CHAT_PORT_SSL"];
    [aCoder encodeObject:_chatUser forKey:@"CHAT_USER"];
    [aCoder encodeObject:_chatPassword forKey:@"CHAT_PASSWORD"];
    [aCoder encodeObject:_mqttHostName forKey:@"MQTT_HOST_NAME"];
    [aCoder encodeInteger:_mqttPortSSL forKey:@"MQTT_PORT_SSL"];
    [aCoder encodeObject:_mqttPassword forKey:@"MQTT_PASSWORD"];
    [aCoder encodeObject:_mqttUser forKey:@"MQTT_USER"];
    [aCoder encodeObject:_deviceId forKey:@"DEVICE_ID"];
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"MQTT Topic: %@, Host: %@, Port: %ld",_chatTopic,_mqttHostName,_mqttPortSSL];
}

@end
