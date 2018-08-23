//
//  DeleteMessageAPI.h
//  InstaVoice
//
//  Created by adwivedi on 16/03/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatActivity.h"

@interface DeleteMessageAPI : NSObject
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(ChatActivityData*) model withSuccess:(void (^)(DeleteMessageAPI* req , BOOL responseObject))success failure:(void (^)(DeleteMessageAPI* req, NSError *error))failure;

@end
