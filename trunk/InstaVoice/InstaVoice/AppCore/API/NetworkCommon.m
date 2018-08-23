//
//  NetworkCommon.m
//  InstaVoice
//
//  Created by adwivedi on 24/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "NetworkCommon.h"
#import "ConfigurationReader.h"
#import "ServerApi.h"
#import "ServerErrorMsg.h"
#import "HttpConstant.h"
#import "Logger.h"
#import "Macro.h"
#ifdef REACHME_APP
#import "LinphoneCoreSettingsStore.h"
#endif

static NetworkCommon* networkCommonObj = NULL;

@implementation NetworkCommon

+(NetworkCommon *)sharedNetworkCommon
{
    if(networkCommonObj == nil)
        networkCommonObj = [[NetworkCommon alloc]init];
    return networkCommonObj;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        _session = nil;
    }
    return self;
}

- (NSURLSession *)session {
    
    if (!_session) {
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    
    return _session;
}


#pragma mark -- Class Methods
+(NSString *)getRequestJson:(NSMutableDictionary *)requestDic
{
    NSString *jsonStr = @"https://iv.vobolo.com/iv";
    NSError *error = nil;
    NSData *jsonData = nil;
    
    @try
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:requestDic options:0 error:&error];
    }
    @catch (NSException *exception)
    {
        return jsonStr;
    }
    if(!error)
    {
        jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonStr;
}

+(NSMutableURLRequest *)setHttpPostRequest:(NSString *)requestJson serverUrl:(NSString *)url
{
    NSURL *URL                         = [NSURL URLWithString:url];
    NSString *data                     = @"data=";
    NSMutableURLRequest *serverRequest = [[NSMutableURLRequest alloc] init];
    
    [serverRequest setTimeoutInterval:30];
    [serverRequest setURL:URL];
    [serverRequest setHTTPMethod:@"POST"];
    
    requestJson = [data stringByAppendingString:requestJson];
    [serverRequest setHTTPBody:[requestJson dataUsingEncoding:NSUTF8StringEncoding]];
    return serverRequest;
}

//TODO
#ifdef REMOVE_LATER
+(NSMutableURLRequest *)setMultipartRequest:(NSString *)reqJson serverUrl:(NSString *)url filePath:(NSString *)filePath fileName:(NSString *)fileName
{
    NSMutableURLRequest *serverRequest = nil;
    
    if(reqJson != nil || ![reqJson isEqualToString:@""] || url != nil || ![url isEqualToString:@""] || filePath != nil || ![filePath isEqualToString:@""])
    {
        NSURL *URL = [NSURL URLWithString:url];
        NSString * lineEnd = @"\r\n";
        NSString * twoHyphens = @"--";
        NSString * boundary = @"*****";
        NSData *voiceData = nil;
        voiceData = [NSData dataWithContentsOfFile:filePath];
        if(voiceData != nil)
        {
            serverRequest = [[NSMutableURLRequest alloc] init];
            [serverRequest setTimeoutInterval:REQTIMEOUTINTERVAL];
            [serverRequest setURL:URL];
            [serverRequest setHTTPMethod:POST];
            [serverRequest addValue:reqJson forHTTPHeaderField:@"data"];
            [serverRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
            NSMutableData *bodyData = [[NSMutableData alloc] init];
            [bodyData appendData:[[NSString stringWithFormat:@"%@%@%@",twoHyphens, boundary,lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
            [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data;  name=\"content\"; filename=%@ %@",fileName,lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
            [bodyData appendData:[[NSString stringWithFormat:@"%@", lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [bodyData appendData:voiceData];
            
            [bodyData appendData:[[NSString stringWithFormat:@"%@", lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
            [bodyData appendData:[[NSString stringWithFormat:@"%@%@%@%@",twoHyphens, boundary,twoHyphens, lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
            [serverRequest setHTTPBody:bodyData];
        }
    }
    return serverRequest;
}
#endif

+(NSMutableDictionary *)getResponseDic:(NSData *)respData
{
    NSError *error = nil;
    NSMutableDictionary *respDic = nil ;
    if(respData != nil )
    {
        respDic = [NSJSONSerialization JSONObjectWithData:respData options:NSJSONReadingMutableContainers error:&error];
        //debug KLog(@"JSON Data =%@",  [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding]);
    }
    //KLog(@"JSON Data =%@",  [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding]);
    return respDic;
}

+(void)addCommonData:(NSMutableDictionary*)dic eventType:(int)eventType
{
    UIDevice *currentDevice    = [UIDevice currentDevice];
    NSString *systemVersion    = [currentDevice systemVersion];
    NSString *cmd              = [ServerApi getServerApi:eventType];
    NSString *appSecureKey     = @"b2ff398f8db492c19ef89b548b04889c";
    NSString *clientAppVer     = CLIENT_APP_VER;
    
    [dic setValue:cmd forKey:@"cmd"];
    [dic setValue:appSecureKey forKey:@"app_secure_key"];
    [dic setValue:@"i" forKey:@"client_os"];
    [dic setValue:systemVersion forKey:@"client_os_ver"];
    [dic setValue:clientAppVer forKey:@"client_app_ver"];
    
#ifdef REACHME_APP
    [dic setValue:@"rm" forKey:APP_TYPE];
#else
    [dic setValue:@"iv" forKey:APP_TYPE];
#endif
    
    NSString *userSecureKey = [[ConfigurationReader sharedConfgReaderObj] getUserSecureKey];
    if(userSecureKey != nil && [userSecureKey length]>0 )
    {
        [dic setValue:userSecureKey forKey:@"user_secure_key"];
    } else {
        KLog(@"userSecureKey is nil");
    }
    long ivUserId = [[ConfigurationReader sharedConfgReaderObj] getIVUserId];
    if(ivUserId > 0)
    {
        NSNumber *num = [NSNumber numberWithLong:ivUserId];
        [dic setValue:num forKey:@"iv_user_id"];
    }
    [dic setValue:@"2" forKey:@"api_ver"];
    
    //KLog(@"*** AddCommonData ***\n%@",dic);
}

#pragma mark -- Data Task, Upload Task, Download Task

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic
               withSuccess:(void (^)(NetworkCommon* req , NSMutableDictionary* responseObject))success
                   failure:(void (^)(NetworkCommon* req, NSError *error))failure
{
    NSDate *__block startTime = [NSDate date];
    NSDate *__block finishTime;
    
    //KLog(@"callNetworkRequest:%@",requestDic);
    
    NSString* reqJson =[NetworkCommon getRequestJson:requestDic];
    //OCT, 2017 NSString* req = [reqJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    NSCharacterSet *customCharacterset = [[NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]{}% "] invertedSet];
    NSString *req = [reqJson stringByAddingPercentEncodingWithAllowedCharacters:customCharacterset];
    //OCT 2017
    
    //- create url request
    NSMutableURLRequest *serverRequest = [[NSMutableURLRequest alloc] init];
    
    NSURL* URL = [NSURL URLWithString:SERVER_URL];
    NSString *data = @"data=";
    
    [serverRequest setURL:URL];
    [serverRequest setHTTPMethod:POST];
    [serverRequest addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];// Sep 1, 201
    req = [data stringByAppendingString:req];
    [serverRequest setHTTPBody:[req dataUsingEncoding:NSUTF8StringEncoding]];
    
    //- Create a session with default configuration and
    /*
     NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
     NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration];
     */
    //NSURLSession* session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask* dataTask =
    [self.session dataTaskWithRequest:serverRequest
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
     {
         finishTime = [NSDate date];
         NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:startTime];
         KLog(@"### calNetworkRequest execution time in secs: %.2f", executionTime);
         
         if (error) {
             KLog(@"### callNetworkRequest failed: %@", error);
             dispatch_async(dispatch_get_main_queue(), ^{
                 failure(self,error);
             });
             
             /*
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 failure(self,error);
             });*/
         }
         else {
             KLog(@"### callNetworkRequest succeeded.");
             
             NSMutableDictionary* responseDictionary = [NetworkCommon getResponseDic:data];
             NSString* responseCode = [responseDictionary valueForKey:STATUS];
             
             if([responseCode isEqualToString:STATUS_OK]) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     success(self,responseDictionary);
                 });
                 
                 /*
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     success(self,responseDictionary);
                 });*/
             }
             else {
                 //Even though response we got - its error in the response due to request faulty..!!
                 NSError* error = [NSError errorWithDomain:@"IVError"
                                                      code:[[responseDictionary valueForKey:@"error_code"]integerValue]
                                                  userInfo:responseDictionary];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     failure(self,error);
                 });
                 /*
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     failure(self,error);
                 });*/
             }
         }
     }];
    
    [dataTask resume];
}


- (void)uploadDataWithRequest:(NSMutableDictionary*)requestDic
                     fileName:(NSString*)fileName
                     filePath:(NSString*)filePath
                  withSuccess:(void (^)(NetworkCommon* req , id responseObject))success
                      failure:(void (^)(NetworkCommon* req, NSError *error))failure
{
    NSDate *__block startTime = [NSDate date];
    NSDate *__block finishTime;
    
    if( !filePath || ![filePath length] || !fileName || ![fileName length])
    {
        KLog(@"*** uploadDataWithRequest : Invalid params. returns.");
        return;
    }
    
    NSString* reqJson =[NetworkCommon getRequestJson:requestDic];
    NSCharacterSet *customCharacterset = [[NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]{}% "] invertedSet];
    NSString *req = [reqJson stringByAddingPercentEncodingWithAllowedCharacters:customCharacterset];
    
    NSString* lineEnd = @"\r\n";
    NSString* twoHyphens = @"--";
    NSString* boundary = @"*****";
    NSData* voiceData = [NSData dataWithContentsOfFile:filePath];
    
    //- create url request with headers
    NSMutableURLRequest *serverRequest = [[NSMutableURLRequest alloc] init];
    [serverRequest setURL: [NSURL URLWithString:SERVER_URL]];
    [serverRequest setHTTPMethod:POST];
    [serverRequest addValue:req forHTTPHeaderField:@"data"];
    [serverRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    //- create body data
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendData:[[NSString stringWithFormat:@"%@%@%@",twoHyphens, boundary,lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data;  name=\"content\"; filename=%@ %@",fileName,lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"%@", lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [bodyData appendData:voiceData];
    
    [bodyData appendData:[[NSString stringWithFormat:@"%@", lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"%@%@%@%@",twoHyphens, boundary,twoHyphens, lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //- create and perform an upload task
    NSURLSessionUploadTask *uploadTask =
    [self.session uploadTaskWithRequest:serverRequest
                               fromData:bodyData
                      completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
     {
    
         finishTime = [NSDate date];
         NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:startTime];
         KLog(@"### uploadDataWithRequest -- elapsed time: %.2f", executionTime);
         
         if (error) {
             KLog(@"### uploadDataWithRequest failed: %@", error);
             dispatch_async(dispatch_get_main_queue(), ^{
                 failure(self,error);
             });
             
             /*
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 failure(self,error);
             });*/
         }
         else {
             KLog(@"### uploadDataWithRequest succeeded.");
             
             NSMutableDictionary* responseDictionary = [NetworkCommon getResponseDic:data];
             NSString* responseCode = [responseDictionary valueForKey:STATUS];
             if([responseCode isEqualToString:STATUS_OK]) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     success(self,responseDictionary);
                 });
                 
                 /*
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     success(self,responseDictionary);
                 });*/
                 
             }
             else {
                 //Even though response we got - its error in the response due to request faulty..!!
                 NSError* error = [NSError errorWithDomain:@"IVError" code:[[responseDictionary valueForKey:@"error_code"]integerValue] userInfo:responseDictionary];
                 //Handle the operation in main queue.
                 dispatch_async(dispatch_get_main_queue(), ^{
                     failure(self,error);
                 });
                 
                 /*
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     failure(self,error);
                 });*/
             }
         }
     }];
    
    [uploadTask resume];
}

#ifdef REACHME_APP
- (void)uploadCallDataWithRequest:(NSMutableDictionary*)requestDic
                     fileName:(NSString*)fileName
                     filePath:(NSString*)filePath
                  withSuccess:(void (^)(NetworkCommon* req , id responseObject))success
                      failure:(void (^)(NetworkCommon* req, NSError *error))failure
{
    NSDate *__block startTime = [NSDate date];
    NSDate *__block finishTime;
    
    if( !filePath || ![filePath length] || !fileName || ![fileName length])
    {
        KLog(@"*** uploadCallDataWithRequest : Invalid params. returns.");
        return;
    }
    
    
    NSString* reqJson = [NetworkCommon getRequestJson:requestDic];
    NSCharacterSet *customCharacterset = [[NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]{}% "] invertedSet];
    NSString *req = [reqJson stringByAddingPercentEncodingWithAllowedCharacters:customCharacterset];
    
    
    NSString* lineEnd = @"\r\n";
    NSString* twoHyphens = @"--";
    NSString* boundary = @"*****";
    NSData* callLogData = [NSData dataWithContentsOfFile:filePath];
    
    //- create url request with headers
    NSMutableURLRequest *serverRequest = [[NSMutableURLRequest alloc] init];
    NSString* serverUrl = [[LinphoneCoreSettingsStore sharedLinphoneCoreSettingsStore]getServerHost];
    serverUrl = [NSString stringWithFormat:@"http://%@:8080/project/rest/upload/",serverUrl];
    [serverRequest setURL: [NSURL URLWithString:serverUrl]];
    [serverRequest setHTTPMethod:POST];
    [serverRequest setValue:@"n" forHTTPHeaderField:@"user_data_zipped"];
    [serverRequest setValue:@"y" forHTTPHeaderField:@"multi_part_zipped"];
    
    [serverRequest addValue:req forHTTPHeaderField:@"user_data"];
    [serverRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    //- create body data
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendData:[[NSString stringWithFormat:@"%@%@%@",twoHyphens, boundary,lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data;  name=\"content\"; filename=%@ %@",fileName,lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"%@", lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [bodyData appendData:callLogData];
    
    [bodyData appendData:[[NSString stringWithFormat:@"%@", lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"%@%@%@%@",twoHyphens, boundary,twoHyphens, lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //- create and perform an upload task
    NSURLSessionUploadTask *uploadTask =
    [self.session uploadTaskWithRequest:serverRequest
                               fromData:bodyData
                      completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
     {
         
         finishTime = [NSDate date];
         NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:startTime];
         KLog(@"### uploadCallDataWithRequest -- elapsed time: %.2f", executionTime);
         
         if (error) {
             KLog(@"### uploadCallDataWithRequest failed: %@", error);
             dispatch_async(dispatch_get_main_queue(), ^{
                 failure(self,error);
             });
         }
         else {
             KLog(@"### uploadCallDataWithRequest succeeded.");
             NSMutableDictionary* responseDictionary = [[NSMutableDictionary alloc]init];
             [responseDictionary setValue:STATUS_OK forKey:STATUS];
             dispatch_async(dispatch_get_main_queue(), ^{
                 success(self,responseDictionary);
             });
             
             /* TODO - use this when we upload calllog to IV server
             NSMutableDictionary* responseDictionary = [NetworkCommon getResponseDic:data];
             NSString* responseCode = [responseDictionary valueForKey:STATUS];
             if([responseCode isEqualToString:STATUS_OK]) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     success(self,responseDictionary);
                 });
             }
             else {
                 //Even though response we got - its error in the response due to request faulty..!!
                 NSError* error = [NSError errorWithDomain:@"IVError" code:[[responseDictionary valueForKey:@"error_code"]integerValue] userInfo:responseDictionary];
                 //Handle the operation in main queue.
                 dispatch_async(dispatch_get_main_queue(), ^{
                     failure(self,error);
                 });
             }*/
         }
     }];
    
    [uploadTask resume];
}
#endif

- (void)downloadDataWithURLString:(NSString*) filePath withSuccess:(void (^)(NetworkCommon* req , id responseObject))success failure:(void (^)(NetworkCommon* req, NSError *error))failure
{
    
    NSDate *__block startTime = [NSDate date];
    NSDate *__block finishTime;
    
    NSURL* URL = [NSURL URLWithString:filePath];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];// Sep 1, 201
    
     NSURLSessionDownloadTask *downloadTask =
        [self.session downloadTaskWithRequest:request
                            completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                
                    finishTime = [NSDate date];
                    NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:startTime];
                    KLog(@"### downloadDataWithURLString execution time in secs: %.2f", executionTime);
                    
                    if (error) {
                        KLog(@"### downloadDataWithURLString failed: %@", error);
                        
                        //Handle the operation in main queue.
                        dispatch_async(dispatch_get_main_queue(), ^{
                            failure(self,error);
                        });
                        
                        /*
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            failure(self,error);
                        });*/
                    }
                    else {
                        KLog(@"### downloadDataWithURLString succeeded.");
                        /*
                        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                        NSURL* newFilePath = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                        */
                        
                        NSData* data = [NSData dataWithContentsOfURL:location options:NSDataReadingMappedIfSafe error:&error];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success(self, data);
                        });
                        /*
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            success(self,data);
                        });*/
                    }
        }];
    
    [downloadTask resume];
}


#pragma mark -- NSURLSessionDelegate

-(void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    EnLoge(@"didReceiveChallenge");
    KLog(@"NetworkController: didReceiveChallenge");
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        KLog(@"NetworkController: authentication required");
        if (challenge.previousFailureCount == 0)
        {
            KLog(@"NetworkController: authentication attempt is 0");
            
            NSURLCredential* credential =
            [NSURLCredential credentialWithUser:[[ConfigurationReader sharedConfgReaderObj] getLoginId]
                                       password:[[ConfigurationReader sharedConfgReaderObj] getPassword]
                                    persistence:NSURLCredentialPersistenceForSession];
            
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
        else
        {
            KLog(@"NetworkController: authentication attempt :%ld",(long)challenge.previousFailureCount);
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
}

#pragma mark -- NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    EnLoge(@"didReceiveChallenge");
    KLog(@"NetworkController: didReceiveChallenge");
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        KLog(@"NetworkController: authentication required");
        if (challenge.previousFailureCount == 0)
        {
            KLog(@"NetworkController: authentication attempt is 0");
            
            NSURLCredential* credential =
            [NSURLCredential credentialWithUser:[[ConfigurationReader sharedConfgReaderObj] getLoginId]
                                       password:[[ConfigurationReader sharedConfgReaderObj] getPassword]
                                    persistence:NSURLCredentialPersistenceForSession];
            
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
        else
        {
            KLog(@"NetworkController: authentication attempt :%ld",(long)challenge.previousFailureCount);
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
}

@end
