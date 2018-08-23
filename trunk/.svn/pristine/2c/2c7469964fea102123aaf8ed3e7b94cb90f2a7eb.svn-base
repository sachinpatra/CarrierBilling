//
//  SettingModelVoip.m
//  InstaVoice
//
//  Created by Pandian on 7/3/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingModelVoip.h"

@implementation SettingModelVoip
-(id)init
{
    if(self = [super init])
    {
        _serverUrl = @"";
        _serverPort = 0;
        _userName = @"";
        _password = @"";
        
        _udpPort = 5060;
        _tcpPort = 5228;
        _priority = 1;
    }
    return self;
}

-(id) initWithObject:(SettingModelVoip*)setting {
    
    if(self = [super init]){
        _serverUrl = setting.serverUrl;
        _serverPort = setting.serverPort;
        _userName = setting.userName;
        _password = setting.password;
        
        _udpPort = setting.udpPort;
        _tcpPort = setting.tcpPort;
        _priority = setting.priority;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [self init])
    {
        _serverUrl = [aDecoder decodeObjectForKey:@"VOIP_SERVER_URL"];
        _serverPort = [aDecoder decodeIntegerForKey:@"VOIP_PORT"];
        _userName = [aDecoder decodeObjectForKey:@"VOIP_USER_NAME"];
        _password = [aDecoder decodeObjectForKey:@"VOIP_PASSWORD"];
        _udpPort = [aDecoder decodeIntForKey:@"VOIP_UDP_PORT"];
        _tcpPort = [aDecoder decodeIntForKey:@"VOIP_TCP_PORT"];
        _priority = [aDecoder decodeIntForKey:@"VOIP_PORT_PRIORITY"];
    }
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_serverUrl forKey:@"VOIP_SERVER_URL"];
    [aCoder encodeInteger:_serverPort forKey:@"VOIP_PORT"];
    [aCoder encodeObject:_userName forKey:@"VOIP_USER_NAME"];
    [aCoder encodeObject:_password forKey:@"VOIP_PASSWORD"];
    
    [aCoder encodeInt:_udpPort forKey:@"VOIP_UDP_PORT"];
    [aCoder encodeInt:_tcpPort forKey:@"VOIP_TCP_PORT"];
    [aCoder encodeInt:_priority forKey:@"VOIP_PORT_PRIORITY"];
    
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"Host:%@, Port:%ld, Username:%@, Pwd:%@, udp=%d, tcp=%d, priority=%d",_serverUrl,_serverPort,_userName,_password, _udpPort, _tcpPort, _priority];
}

@end
