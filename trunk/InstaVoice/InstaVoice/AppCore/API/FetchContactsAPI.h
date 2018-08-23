//
//  FetchContactsAPI.h
//  InstaVoice
//
//  Created by adwivedi on 05/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FetchContactsAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchContactsAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(FetchContactsAPI* req, NSError *error))failure;
@end
