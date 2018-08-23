//
//  UpdateAppStatus.h
//  InstaVoice
//
//  Created by Pandian on 27/04/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateAppStatusAPI : NSObject
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(BOOL)isAppForeground withSuccess:(void (^)(UpdateAppStatusAPI* req , BOOL responseObject))success failure:(void (^)(UpdateAppStatusAPI* req, NSError *error))failure;

@end
