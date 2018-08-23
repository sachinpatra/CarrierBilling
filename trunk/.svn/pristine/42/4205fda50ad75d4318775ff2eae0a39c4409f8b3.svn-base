//
//  VoiceMailHLRAPI.h
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 03/08/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceMailHLRAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
    NSTimer *timer;
    NSString *phoneNumber;
    NSInteger counter;
}
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(VoiceMailHLRAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(VoiceMailHLRAPI* req, NSError *error))failure;

@end
