//
//  JoinUserAPI.h
//  InstaVoice
//
//  Created by adwivedi on 22/09/15.
//  Copyright © 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AppDelegate;
@interface JoinUserAPI : NSObject
{
    AppDelegate *appDelegate;
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(JoinUserAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(JoinUserAPI* req, NSError *error))failure;
@end
