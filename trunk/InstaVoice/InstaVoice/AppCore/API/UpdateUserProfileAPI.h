//
//  UpdateUserProfileAPI.h
//  InstaVoice
//
//  Created by adwivedi on 05/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfileModel.h"

@interface UpdateUserProfileAPI : NSObject
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(UserProfileModel*) model withSuccess:(void (^)(UpdateUserProfileAPI* req , BOOL responseObject))success failure:(void (^)(UpdateUserProfileAPI* req, NSError *error))failure;

- (void)updatePassword:(NSString*)newPassword withSuccess:(void (^)(UpdateUserProfileAPI* req , BOOL responseObject))success failure:(void (^)(UpdateUserProfileAPI* req, NSError *error))failure;

- (void)updateVoicemailSubscription:(NSDictionary*)dic withSuccess:(void (^)(UpdateUserProfileAPI* req , BOOL responseObject))success failure:(void (^)(UpdateUserProfileAPI* req, NSError *error))failure;

@end
