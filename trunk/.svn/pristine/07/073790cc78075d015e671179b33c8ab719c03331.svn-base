//
//  FetchUserContactAPI.h
//  InstaVoice
//
//  Created by kirusa on 12/22/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FetchUserContactAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchUserContactAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(FetchUserContactAPI* req, NSError *error))failure;

@end
