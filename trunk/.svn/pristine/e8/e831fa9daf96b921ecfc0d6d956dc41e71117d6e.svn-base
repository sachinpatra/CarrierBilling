//
//  UploadProfilePicAPI.h
//  InstaVoice
//
//  Created by adwivedi on 13/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadProfilePicAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(UploadProfilePicAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(UploadProfilePicAPI* req, NSError *error))failure;

@end
