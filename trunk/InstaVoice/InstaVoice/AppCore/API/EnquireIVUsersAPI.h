//
//  EnquireIVUsersAPI.h
//  InstaVoice
//
//  Created by adwivedi on 03/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnquireIVUsersAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(EnquireIVUsersAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(EnquireIVUsersAPI* req, NSError *error))failure;
@end
