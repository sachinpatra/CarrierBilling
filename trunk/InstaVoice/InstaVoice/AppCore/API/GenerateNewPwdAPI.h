//
//  GenerateNewPwdAPI.h
//  InstaVoice
//
//  Created by adwivedi on 06/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenerateNewPwdAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(GenerateNewPwdAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(GenerateNewPwdAPI* req, NSError *error))failure;
@end
