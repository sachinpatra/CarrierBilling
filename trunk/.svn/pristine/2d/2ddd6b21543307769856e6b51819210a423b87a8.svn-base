//
//  TranscriptionAPI.h
//  InstaVoice
//
//  Created by Bhaskar Munireddy on 26/03/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatActivity.h"

@interface TranscriptionAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(TranscriptionAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(TranscriptionAPI* req, NSError *error))failure;

@end
