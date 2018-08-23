//
//  FetchObdDebitPolicyAPI.h
//  ReachMe
//
//  Created by Pandian on 03/07/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkCommon.h"
#import "ConfigurationReader.h"
#import "ServerApi.h"
#import "EventType.h"
#import "Common.h"

@interface FetchObdDebitPolicyAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*)requestDic
               withSuccess:(void (^)(FetchObdDebitPolicyAPI* req , NSMutableDictionary* responseObject))success
                   failure:(void (^)(FetchObdDebitPolicyAPI* req, NSError *error))failure;

@end
