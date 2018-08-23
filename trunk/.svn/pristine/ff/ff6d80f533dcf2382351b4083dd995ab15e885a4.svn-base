//
//  FetchVoipSettingAPI.h
//  InstaVoice
//
//  Created by Pandian on 7/3/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#ifndef FetchVoipSettingAPI_h
#define FetchVoipSettingAPI_h

#import <Foundation/Foundation.h>
#import "SettingModelVoip.h"

@interface FetchVoipSettingAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchVoipSettingAPI* req , SettingModelVoip* responseObject))success failure:(void (^)(FetchVoipSettingAPI* req, NSError *error))failure;

@end


#endif /* FetchVoipSettingAPI_h */
