//
//  FetchUserSettingAPI.h
//  InstaVoice
//
//  Created by adwivedi on 24/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingModel.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif

@interface FetchUserSettingAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;
@property(nonatomic,strong)NSDictionary *customUSSDSim;
@property(nonatomic,strong)NSDictionary *customUSSDPhone;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchUserSettingAPI* req , SettingModel* responseObject))success failure:(void (^)(FetchUserSettingAPI* req, NSError *error))failure;

@end
