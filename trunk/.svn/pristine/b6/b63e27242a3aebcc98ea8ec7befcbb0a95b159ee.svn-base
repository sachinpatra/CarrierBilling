//
//  FetchCarriersListAPI.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 9/15/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FetchCarriersListAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchCarriersListAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(FetchCarriersListAPI* req, NSError *error))failure;

@end
