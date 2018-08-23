//
//  SetGreetingsAPI.h
//  InstaVoice
//
//  Created by adwivedi on 14/10/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetGreetingsAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(SetGreetingsAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(SetGreetingsAPI* req, NSError *error))failure;

-(void)deleteFileForRequest:(NSMutableDictionary *)requestDic withSuccess:(void (^)(SetGreetingsAPI *, NSMutableDictionary *))success failure:(void (^)(SetGreetingsAPI *, NSError *))failure;
@end
