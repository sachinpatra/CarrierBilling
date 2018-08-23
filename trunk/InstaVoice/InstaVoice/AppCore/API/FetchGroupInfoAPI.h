//
//  FetchGroupInfoAPI.h
//  InstaVoice
//
//  Created by adwivedi on 02/09/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FetchGroupInfoAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchGroupInfoAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(FetchGroupInfoAPI* req, NSError *error))failure;

@end
