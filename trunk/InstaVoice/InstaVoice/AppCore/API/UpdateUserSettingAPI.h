//
//  UpdateUserSettingAPI.h
//  InstaVoice
//
//  Created by adwivedi on 24/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingModel.h"

@interface UpdateUserSettingAPI : NSObject
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(SettingModel*) model withSuccess:(void (^)(UpdateUserSettingAPI* req , BOOL responseObject))success failure:(void (^)(UpdateUserSettingAPI* req, NSError *error))failure;
@end
