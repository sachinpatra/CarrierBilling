//
//  BaseModel.m
//  InstaVoice
//
//  Created by EninovUser on 07/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "BaseModel.h"
#import "ServerApi.h"
#import "ConfigurationReader.h"
#import "Macro.h"
#import "EventType.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif

#import "HttpConstant.h"
#import "Engine.h"
#import "Common.h"


@implementation BaseModel

-(id)init
{
    self = [super init];
    if(self)
    {
        appDelegate = (AppDelegate *)APP_DELEGATE;
        lockObj = [[NSLock alloc]init];
        
    }
    return self;
}

/*
 This function add the common request parameter
 */
-(void)addCommonData:(NSMutableDictionary*)dic eventType:(int)eventType
{
    UIDevice *currentDevice    = [UIDevice currentDevice];
    NSString *systemVersion    = [currentDevice systemVersion];
    NSString *cmd              = [ServerApi getServerApi:eventType];
    NSString *appSecureKey     = @"b2ff398f8db492c19ef89b548b04889c";
    NSString *clientAppVer     = CLIENT_APP_VER;
    
    [dic setValue:cmd forKey:@"cmd"];
    [dic setValue:appSecureKey forKey:@"app_secure_key"];
    [dic setValue:@"i" forKey:@"client_os"];
    [dic setValue:systemVersion forKey:@"client_os_ver"];
    [dic setValue:clientAppVer forKey:@"client_app_ver"];
    
#ifdef REACHME_APP
    [dic setValue:@"rm" forKey:APP_TYPE];
#else
    [dic setValue:@"iv" forKey:APP_TYPE];
#endif
    
    NSString *userSecureKey = [appDelegate.confgReader getUserSecureKey];
    if(userSecureKey != nil && [userSecureKey length]>0 )
    {
        [dic setValue:userSecureKey forKey:@"user_secure_key"];
    }
    long ivUserId = [appDelegate.confgReader getIVUserId];
    if(ivUserId > 0)
    {
        NSNumber *num = [NSNumber numberWithLong:ivUserId];
        [dic setValue:num forKey:@"iv_user_id"];
    }
    [dic setValue:@"2" forKey:@"api_ver"];
    
    KLog(@"*** AddCommonData ***\n%@",dic);
}


-(int)eventToNetwork:(int)eventType eventDic:(NSMutableDictionary *)evDic
{
    [evDic setValue:[NSNumber numberWithInt:eventType] forKey:EVENT_TYPE];
    switch (eventType)
    {
        case SEND_VOICE_MSG:
        case SEND_IMAGE_MSG:
            [evDic setValue:[evDic valueForKey:FILE_PATH] forKey:FILE_PATH];
            [evDic setValue:[evDic valueForKey:FILE_NAME] forKey:FILE_NAME];
        case SEND_TEXT_MSG:
        case SEND_MC:
        case SEND_VOIP_CALL_LOG:
        case SEND_APP_STATUS:
        case FORWARD_MSG:
            [appDelegate.shortNetObj addEvent:evDic];
            break;
        case FETCH_OLDER_MSG:
        case FETCH_CELEBRITY_MSG:
            [appDelegate.longNetObj addEvent:evDic];
            break;
        case DOWNLOAD_VOICE_MSG:
            [appDelegate.preemptedNetObj addEvent:evDic];
            break;
        default:
            break;
    }
    return SUCCESS;
}

-(void)notifyUI:(NSMutableDictionary *)responseData
{
    [appDelegate.engObj notifyUI:responseData];
}
@end
