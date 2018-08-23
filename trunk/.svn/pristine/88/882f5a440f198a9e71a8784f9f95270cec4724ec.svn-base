//
//  NetworkCommon.h
//  InstaVoice
//
//  Created by adwivedi on 24/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkCommon : NSObject<NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (strong, nonatomic) NSURLSession* session;

+(NetworkCommon *)sharedNetworkCommon;
+(void)addCommonData:(NSMutableDictionary*)dic eventType:(int)eventType;
+(NSMutableURLRequest *)setHttpPostRequest:(NSString *)requestJson serverUrl:(NSString *)url;
//TODO +(NSMutableURLRequest *)setMultipartRequest:(NSString *)reqJson serverUrl:(NSString *)url filePath:(NSString *)filePath fileName:(NSString *)fileName;
+(NSString *)getRequestJson:(NSMutableDictionary *)requestDic;
+(NSMutableDictionary *)getResponseDic:(NSData *)respData;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(NetworkCommon* req , NSMutableDictionary* responseObject))success failure:(void (^)(NetworkCommon* req, NSError *error))failure;

- (void)downloadDataWithURLString:(NSString*) filePath withSuccess:(void (^)(NetworkCommon* req , id responseObject))success failure:(void (^)(NetworkCommon* req, NSError *error))failure;

- (void)uploadDataWithRequest:(NSMutableDictionary*)requestDic fileName:(NSString*)fileName filePath:(NSString*) filePath withSuccess:(void (^)(NetworkCommon* req , id responseObject))success failure:(void (^)(NetworkCommon* req, NSError *error))failure;

#ifdef REACHME_APP
- (void)uploadCallDataWithRequest:(NSMutableDictionary*)requestDic
                         fileName:(NSString*)fileName
                         filePath:(NSString*)filePath
                      withSuccess:(void (^)(NetworkCommon* req , id responseObject))success
                          failure:(void (^)(NetworkCommon* req, NSError *error))failure;
#endif

@end
