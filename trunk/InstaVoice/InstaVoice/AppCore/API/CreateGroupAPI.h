//
//  CreateGroupAPI.h
//  InstaVoice
//
//  Created by adwivedi on 01/09/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateGroupAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(CreateGroupAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(CreateGroupAPI* req, NSError *error))failure;

@end
