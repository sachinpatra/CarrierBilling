//
//  FetchGroupUpdateAPI.h
//  InstaVoice
//
//  Created by adwivedi on 13/08/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FetchGroupUpdateAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchGroupUpdateAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(FetchGroupUpdateAPI* req, NSError *error))failure;

@end
