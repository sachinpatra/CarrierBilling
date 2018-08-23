//
//  FetchStatesAPI.h
//  InstaVoice
//
//  Created by adwivedi on 05/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FetchStatesAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchStatesAPI* req , NSMutableArray* responseObject))success failure:(void (^)(FetchStatesAPI* req, NSError *error))failure;


@end
