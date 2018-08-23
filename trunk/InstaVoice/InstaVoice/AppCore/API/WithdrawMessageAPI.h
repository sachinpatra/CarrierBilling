//
//  WithdrawMessageAPI.h
//  InstaVoice
//
//  Created by Pandian on 29/02/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatActivity.h"

@interface WithdrawMessageAPI : NSObject
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(ChatActivityData*) model withSuccess:(void (^)(WithdrawMessageAPI* req , BOOL responseObject))success failure:(void (^)(WithdrawMessageAPI* req, NSError *error))failure;

@end
