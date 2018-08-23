//
//  FetchFBFriendsAPI.h
//  InstaVoice
//
//  Created by adwivedi on 26/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FetchFBFriendsAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchFBFriendsAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(FetchFBFriendsAPI* req, NSError *error))failure;

@end
