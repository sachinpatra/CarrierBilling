//
//  SettingModelVoip.h
//  InstaVoice
//
//  Created by Pandian on 7/3/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#ifndef SettingModelVoip_h
#define SettingModelVoip_h

#import <Foundation/Foundation.h>

/* 
 - Sample response for the cmd request "fetch_voip_settings"
 - TODO: Discuss -- why do we need user_info and phone_info in server's response?
======
{
    "cmd":"fetch_voip_settings",
    "status":"ok",
    "user_info":{
        "is_iv_user":true,
        "user_id":11743727,
        "pwd":"b2ff39658db492a38b3c749e007948c2",
        "user_token":"b2ff39658db492a38b3c749e007948c2",
        "sender_id":"Mayank",
        "iv_device_cnt":4
    },
    "phone_info":{
        "phone":"919535012911",
        "is_pimary":true,
        "country_code":"091",
        "kvsms_id":5,
        "kvsms_network_id":"11",
        "new_user":false
    },
    "voip_info":{
        "ip":"54.148.51.116",
        "port":5060,
        "login":"admin",
        "pwd":"admin"
    }
}
======
*/

@interface SettingModelVoip : NSObject <NSCoding>
{
    NSString*  _serverUrl; //IP address of reachMe server
    NSInteger  _serverPort;
    NSString*  _userName;
    NSString*  _password;
    
    int _udpPort;
    int _tcpPort;
    int _priority; //0-udp, 1-tcp
}

-(id) initWithObject:(SettingModelVoip*)setting;

@property(nonatomic,strong) NSString* serverUrl;
@property(nonatomic) NSInteger serverPort;
@property(nonatomic,strong) NSString* userName;
@property(nonatomic,strong) NSString* password;

@property(nonatomic) int udpPort;
@property(nonatomic) int tcpPort;
@property(nonatomic) int priority;

@end

#endif /* SettingModelVoip_h */
