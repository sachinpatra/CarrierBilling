//
//  TranscriptionRatingAPI.h
//  InstaVoice
//
//  Created by Bhaskar Munireddy on 05/04/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatActivity.h"

@interface TranscriptionRatingAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(TranscriptionRatingAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(TranscriptionRatingAPI* req, NSError *error))failure;

@end
