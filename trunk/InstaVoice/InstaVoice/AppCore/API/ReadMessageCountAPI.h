//
//  ReadMessageCountAPI.h
//  InstaVoice
//
//  Created by Jatin Mitruka on 3/27/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatActivity.h"

@interface ReadMessageCountAPI : NSObject
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(ChatActivityData*) model withSuccess:(void (^)(ReadMessageCountAPI* req , BOOL responseObject))success failure:(void (^)(ReadMessageCountAPI* req, NSError *error))failure;

@end
