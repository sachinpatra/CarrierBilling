//
//  TranscriptionAPI.m
//  InstaVoice
//
//  Created by Bhaskar Munireddy on 26/03/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "TranscriptionAPI.h"
#import "NetworkCommon.h"
#import "ConfigurationReader.h"
#import "ServerApi.h"
#import "EventType.h"
#import "Common.h"

@implementation TranscriptionAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(TranscriptionAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(TranscriptionAPI* req, NSError *error))failure
{
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:VOICE_MESSAGE_TRANSCRIPTION];//cmd = "trans_msg"
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
