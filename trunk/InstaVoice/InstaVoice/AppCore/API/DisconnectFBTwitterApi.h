//
//  DisconnectFBTwitterApi.h
//  InstaVoice
//
//  Created by adwivedi on 24/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisconnectFBTwitterApi : NSObject

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(DisconnectFBTwitterApi* req , BOOL responseObject))success failure:(void (^)(DisconnectFBTwitterApi* req, NSError *error))failure;

@end
