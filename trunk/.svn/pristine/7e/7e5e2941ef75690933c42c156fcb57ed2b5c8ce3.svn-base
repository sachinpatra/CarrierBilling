//
//  FetchBlockedUsersAPI.h
//  InstaVoice
//
//  Created by adwivedi on 11/12/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkCommon.h"
#import "ConfigurationReader.h"
#import "ServerApi.h"
#import "EventType.h"

#import "Common.h"
@interface FetchBlockedUsersAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchBlockedUsersAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(FetchBlockedUsersAPI* req, NSError *error))failure;

@end
