
//
//  NetworkController.m
//  InstaVoice
//
//  Created by Eninov on 10/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "NetworkController.h"
#import "Macro.h"

#import "HttpConstant.h"

#ifdef REACHME_APP
#import "AppDelegate_rm.h"
#else
#import "AppDelegate.h"
#endif

#import "EventType.h"
#import "Logger.h"
#import "Common.h"
#import "ConversationApi.h"
#import "ConfigurationReader.h"
#import "IVFileLocator.h"
#import "TableColumns.h"
#import "ServerErrorMsg.h"

#define ADDEDINRUNLOOP  @"addedInRunLoop"
#define REQUEST_ID      @"requestId"

@interface  NetworkController() <NSURLSessionDelegate, NSURLSessionTaskDelegate>


/**
 * This function convert request data dictionary to json string .
 * @param : reqDic : NSMutableDictionary dictionary which is to convert
 * @return : NSString jsonString converted from given dictionary
 */
-(NSString *)getRequestJson:(NSMutableDictionary *)reqDic;

/**
 * This function converts NSData response to dictionary
 * @param : responseData NSMutableData response received from server.
 * @return : NSMutableDictionary converted from given data.
 */
-(NSMutableDictionary *)getResponseDic:(NSData *)respData;

/**
 *
 */
-(void)manageEventQueue:(NSMutableDictionary *)processedEventDic;


@end


@implementation NetworkController
NSDate *startTime;
NSDate *finishTime;

-(id)init
{
    self = [super init];
    if(self)
    {
        appDelegate      = (AppDelegate *)APP_DELEGATE;
        serverUrl        = SERVER_URL;
        reqEvObj         = nil;
        isRequestDone    = FALSE;
        eventQueue       = nil;
        netLock          = [[NSLock alloc]init];
        isAddedInRunLoop = FALSE;
        requestId = 0;
        reqTime = 0;
        startTime = 0;
        finishTime = 0;
        
        [self start];     // this will spawn new network thread and invoke EventLoop main method
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

#pragma mark - ADD EVENT
-(int)addEvent:(NSMutableDictionary *)evObj
{
    if(evObj != nil)
    {
        [netLock lock]; //To prevent non-atomic changes in Managed event
        [evObj setValue:[NSNumber numberWithLong:[self getRequestId]] forKey:REQUEST_ID];
        if(((eventQueue == nil)||([eventQueue count] == 0) ) && !isAddedInRunLoop)
        {
            [evObj setValue:[NSNumber numberWithBool:YES] forKey:ADDEDINRUNLOOP];
            [super addEvent:evObj];
            isAddedInRunLoop = TRUE;
            //EnLogd(@"event added in run loop");
        }
        else
        {
            [evObj setValue:[NSNumber numberWithBool:NO] forKey:ADDEDINRUNLOOP];
            //EnLogd(@"%@",@"event is already in run loop adding in network queue");
        }
        [self addToEventQueue:evObj];
        //EnLogd(@"event added in event queue of event type : %d",[[evObj valueForKey:EVENT_TYPE] intValue]);
        [netLock unlock];
    }
    return 0;
}

-(NSInteger)getRequestId
{
    return requestId++;
}

-(void)addToEventQueue:(NSMutableDictionary *)evDic
{
    if(evDic != nil)
    {
        if(eventQueue == nil)
        {
            eventQueue = [[NSMutableArray alloc]init];
        }
        [eventQueue addObject:evDic];
    }
}


#pragma mark - HANDLE EVENT
- (int)handleEvent:(NSMutableDictionary *)eventObj {
    
    int result = FAILURE;
    
    if(nil == eventObj) {
        EnLoge(@"nil event object");
        return result;
    }
    
    reqEvObj = eventObj;
    NSNumber *evType = [reqEvObj valueForKey:EVENT_TYPE];
    
    if(nil == evType) {
        EnLogi(@" event type is nil");
        return FAILURE;
    }
    
    curReqEvType = [evType intValue];
    //EnLogi(@"proccessing event of event type : %d",curReqEvType);
    reqDic = [eventObj valueForKey:REQUEST_DIC];
    if(nil == reqDic) {
        EnLoge(@"request dictionary is nil for event Type : %d", curReqEvType);
        [self manageEventQueue:reqEvObj];
        return result;
    }
    
    if (curReqEvType == DOWNLOAD_VOICE_MSG)
    {
        NSString *fileUrl = [self getFileUrl:curReqEvType requestDic:reqDic];
        if(fileUrl && [fileUrl length]) {
            [self downloadFile:fileUrl];
        } else {
            KLog(@"URL to file is nil");
            EnLoge(@"fileUrl is nil %@, reqEvType=%d",reqDic,curReqEvType);
        }
    }
    else
    {
        NSString *reqJson  = [self getRequestJson:reqDic];
        NSCharacterSet *customCharacterset = [[NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]{}% "] invertedSet];
        NSString *encodedString = [reqJson stringByAddingPercentEncodingWithAllowedCharacters:customCharacterset];
        
        if(reqJson == nil)
        {
            EnLoge(@"request json is nil for event type : %d",curReqEvType);
            [self manageEventQueue:reqEvObj];
            return result;
        }
        
        EnLogi(@"request json of event type : %d is : %@",curReqEvType, reqJson);
        if(curReqEvType == SEND_VOICE_MSG || curReqEvType == SEND_IMAGE_MSG)
        {
            NSString *filePath = [eventObj valueForKey:FILE_PATH];
            NSString *fileName = [eventObj valueForKey:FILE_NAME];
    
            NSInteger res = [self uploadDataToServer:encodedString serverUrl:serverUrl filePath:filePath fileName:fileName];
            if( SUCCESS != res) {
                [reqEvObj setValue:NULL_DATA forKey:RESPONSE_CODE];
                [self manageEventQueue:reqEvObj];
                [self sendResponse:reqEvObj];
                return FAILURE;
            }
        }
        else
        {
            NSInteger res = [self sendDataToServer:encodedString serverUrl:serverUrl];
            if(SUCCESS != res) {
                [reqEvObj setValue:NULL_DATA forKey:RESPONSE_CODE];
                [self manageEventQueue:reqEvObj];
                [self sendResponse:reqEvObj];
                return FAILURE;
            }
        }
        
        while(1)
        {
            [netLock lock];
            BOOL done = isRequestDone;
            [netLock unlock];
            if(done) break;
            
            NSDate *timeOut = [[NSDate alloc] initWithTimeIntervalSinceNow:120];//2 mins -- TODO
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeOut];
            KLog(@"**** runLoop");
        }
    }
    
    return result;
}

-(NSString *)getRequestJson:(NSMutableDictionary *)requestDic
{
    NSString *jsonStr = nil;
    
    NSError *error = nil;
    NSData *jsonData = nil;
    
    @try
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:requestDic options:0 error:&error];
    }
    @catch (NSException *exception)
    {
        EnLogd(@"Exception is thrown %@",exception);
        return jsonStr;
    }
    if(!error)
    {
        jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    else
    {
        EnLoge(@"error : %@  while converting to json for event Type : %d ",error,curReqEvType);
    }
    
    return jsonStr;
}


-(void)manageEventQueue:(NSMutableDictionary *)processedEventDic
{
    if(processedEventDic != nil)
    {
        long reqId = [[processedEventDic valueForKey:REQUEST_ID] longValue];
        [netLock lock];
        if(eventQueue != nil && [eventQueue count] > 0)
        {
            NSMutableDictionary *evDic = [eventQueue objectAtIndex:0];
            if(evDic != nil && reqId == [[evDic valueForKey:REQUEST_ID] longValue])
            {
                [eventQueue removeObject:evDic];
            }
            else
            {
                EnLoge(@"request id is different from processed event and added in event queue");
            }
            isAddedInRunLoop = FALSE;
        }
        if(eventQueue != nil && [eventQueue count] > 0 && !isAddedInRunLoop)
        {
            NSMutableDictionary *evDic = [eventQueue objectAtIndex:0];
            [evDic setValue:[NSNumber numberWithBool:YES] forKey:ADDEDINRUNLOOP];//NOV 2017
            [super addEvent:evDic];
            isAddedInRunLoop = TRUE;
            isRequestDone = FALSE;
        }
        else
        {
            isAddedInRunLoop = FALSE;
            requestId = 0;
            isRequestDone = FALSE;
        }
        
        if(nil==eventQueue) {
            KLog(@"eventQueue is nil");
            isRequestDone = TRUE;
        }
        
        [netLock unlock];
    }
}


-(NSInteger)sendDataToServer:(NSString *)requestJson serverUrl:(NSString *)url
{
    if(!requestJson || [requestJson isEqualToString:@""] ||
       !url || [url isEqualToString:@""])
    {
        KLog(@"*** sendDataToServer: Invalid params. returns.");
        return -1;
    }
    
    
    startTime = [NSDate date];

    //- create url request
    NSMutableURLRequest *serverRequest = [[NSMutableURLRequest alloc] init];
    NSURL *URL = [NSURL URLWithString:url];
    NSString *data = @"data=";
    
    [serverRequest setURL:URL];
    [serverRequest setHTTPMethod:POST];
    requestJson = [data stringByAppendingString:requestJson];
    [serverRequest setHTTPBody:[requestJson dataUsingEncoding:NSUTF8StringEncoding]];
    
    //- Create a session with default configuration and
    /*
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
     */
    //NSURLSession* session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
                [self.session dataTaskWithRequest:serverRequest
                           completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                 {
                     
                     finishTime = [NSDate date];
                     NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:startTime];
                     
                     KLog(@"### Execution time in secs: %.2f",executionTime);
                     
                     if (error) {
                         KLog(@"### Failed sending data to server: %@", error);
                          EnLogd(@"Failed sending data to server : %d, error : %@",curReqEvType,error);
                         
                         NSString *respError = [self getResponseError:error.code];
                         [reqEvObj setValue:respError forKey:RESPONSE_CODE];
                     }
                     else {
                         KLog(@"### sendDataToServer succeeded");
                         
                         NSMutableDictionary* responseDictionary = [self getResponseDic:data];
                         NSString* responseCode = [responseDictionary valueForKey:STATUS];
                         //OCT 14, 2016 -- server is now giving staus as "error" against "ok"
                         if([responseCode isEqualToString:STATUS_OK] || [responseCode isEqualToString:@"error"]) {
                             EnLogi(@"response of event type %d is : %@",curReqEvType,responseDictionary);
                             if(nil == responseDictionary) {
                                 [reqEvObj setValue:NET_FAILURE forKey:RESPONSE_CODE];
                             }
                             else {
                                 [reqEvObj setValue:NET_SUCCESS forKey:RESPONSE_CODE];
                                 [reqEvObj setValue:responseDictionary forKey:RESPONSE_DATA];
                             }
                             
                             [self setEventSpecificResult:curReqEvType resultDic:reqEvObj];
                         }
                         else {
                             NSString *respError = [self getResponseError:error.code];
                             EnLogd(@"Error in network request for event type : %d error : %@",curReqEvType,error);
                             [reqEvObj setValue:respError forKey:RESPONSE_CODE];
                         }
                     }
                     //dispatch_async(dispatch_get_main_queue(), ^{
                         [self sendResponse:reqEvObj];
                         [self manageEventQueue:reqEvObj];
                     //});
                 }];
    
    [dataTask resume];
    
    return 0;
}


#pragma mark - DOWNLOAD FILE
-(NSString *)getFileUrl:(int)eventType requestDic:(NSMutableDictionary *)requestDic
{
    NSString *fileUrl = @"";
    switch (eventType)
    {
        case DOWNLOAD_VOICE_MSG:
            fileUrl = [requestDic valueForKey:MSG_CONTENT];
            break;
        default:
            break;
    }
    return fileUrl;
}

-(NSInteger)downloadFile:(NSString*)url
{
    startTime = [NSDate date];
    
    //Create URL request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    
    //- create Session with the default configuration
    /*
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration];
    */
    //NSURLSession* session = [NSURLSession sharedSession];
    
    KLog(@"downloadFile starts");
    NSURLSessionDownloadTask* downloadTask =
       [self.session downloadTaskWithRequest:request
                      completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
                          finishTime = [NSDate date];
                          NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:startTime];
                          KLog(@"Download time in secs : %.2f", executionTime);
                          if(error) {
                              KLog(@"### downloadFile failed: %@", error);
                              EnLogd(@"Error in network request for event type : %d error : %@",curReqEvType,error);
                              
                              NSString *respError = [self getResponseError:error.code];
                              [reqEvObj setValue:respError forKey:RESPONSE_CODE];
                              if(DOWNLOAD_VOICE_MSG == curReqEvType) {
                                  [reqDic setValue:API_NOT_DOWNLOADED forKey:MSG_STATE];
                              }
                              
                          } else {
                              KLog(@"### downloadFile succeeded: %@", location);
                              NSMutableData *data = [NSMutableData dataWithContentsOfURL:location];
                              responseData = data;
                              BOOL bDownloadFile = (DOWNLOAD_VOICE_MSG == curReqEvType);
                              if(bDownloadFile) {
                                  if(nil == data) {
                                      [reqEvObj setValue:NET_FAILURE forKey:RESPONSE_CODE];
                                  }
                                  else {
                                      //NOV 2017 result = SUCCESS;
                                      [reqEvObj setValue:NET_SUCCESS forKey:RESPONSE_CODE];
                                      [reqEvObj setValue:data forKey:RESPONSE_DATA];
                                  }
                              }
                              [self setEventSpecificResult:curReqEvType resultDic:reqEvObj];
                          }
                          
                          //dispatch_async(dispatch_get_main_queue(), ^{
                              [self sendResponse:reqEvObj];
                              [self manageEventQueue:reqEvObj];
                          //});
                      }];
    
    [downloadTask resume];
    
    return 0;
}

-(NSInteger)uploadDataToServer:(NSString *)reqJson serverUrl:(NSString *)url filePath:(NSString *)filePath fileName:(NSString *)fileName
{
    if(!reqJson || [reqJson isEqualToString:@""] ||
       !url || [url isEqualToString:@""] ||
       !filePath || [filePath isEqualToString:@""])
    {
        KLog(@"*** uploadDataToServer: Invalid params. returns.");
        return -1;
    }
    
    startTime = [NSDate date];
    
    NSString * lineEnd = @"\r\n";
    NSString * twoHyphens = @"--";
    NSString * boundary = @"*****";
    NSData *voiceData = [NSData dataWithContentsOfFile:filePath];
    
    //- create url request with headers
    NSMutableURLRequest *serverRequest = [[NSMutableURLRequest alloc] init];
    [serverRequest setURL: [NSURL URLWithString:serverUrl]];
    [serverRequest setHTTPMethod:POST];
    [serverRequest addValue:reqJson forHTTPHeaderField:@"data"];
    [serverRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    //- create body data
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendData:[[NSString stringWithFormat:@"%@%@%@",twoHyphens, boundary,lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data;  name=\"content\"; filename=%@ %@",fileName,lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"%@", lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [bodyData appendData:voiceData];
    
    [bodyData appendData:[[NSString stringWithFormat:@"%@", lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[[NSString stringWithFormat:@"%@%@%@%@",twoHyphens, boundary,twoHyphens, lineEnd] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionUploadTask *uploadTask =
            [self.session uploadTaskWithRequest:serverRequest
                                         fromData:bodyData
                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        finishTime = [NSDate date];
        NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:startTime];
        KLog(@"#### Execution time in secs: %.2f",executionTime);
        
        if(error) {
            KLog(@"#### upload task failed: %@",error);
            
            NSString *respError = [self getResponseError:error.code];
            [reqEvObj setValue:respError forKey:RESPONSE_CODE];
        }
        else {
            KLog(@"#### upload task completed.");
            NSMutableDictionary* responseDictionary = [self getResponseDic:data];
            NSString* responseCode = [responseDictionary valueForKey:STATUS];
            if([responseCode isEqualToString:STATUS_OK]) {
                if(response != nil)
                {
                    EnLogi(@"response of event type %d is : %@",curReqEvType,responseDictionary);
                    if(responseDictionary == nil)
                    {
                        [reqEvObj setValue:NET_FAILURE forKey:RESPONSE_CODE];
                    }
                    else
                    {
                        [reqEvObj setValue:NET_SUCCESS forKey:RESPONSE_CODE];
                        [reqEvObj setValue:responseDictionary forKey:RESPONSE_DATA];
                    }
                }
                else
                {
                    [reqEvObj setValue:NET_FAILURE forKey:RESPONSE_CODE];
                }
                
                [self setEventSpecificResult:curReqEvType resultDic:reqEvObj];
            }
            else {
                //Even though response we got - its error in the response due to request faulty..!!
                NSString *respError = [self getResponseError:error.code];
                EnLogd(@"Error in network request for event type : %d error : %@",curReqEvType,error);
                [reqEvObj setValue:respError forKey:RESPONSE_CODE];
                //DEC 2017
                if(responseDictionary == nil)
                {
                    [reqEvObj setValue:NET_FAILURE forKey:RESPONSE_CODE];
                }
                else
                {
                    [reqEvObj setValue:NET_SUCCESS forKey:RESPONSE_CODE];
                    [reqEvObj setValue:responseDictionary forKey:RESPONSE_DATA];
                }
                //
            }
        }
        
        //dispatch_async(dispatch_get_main_queue(), ^{
            [self sendResponse:reqEvObj];
            [self manageEventQueue:reqEvObj];
        //});
    }];
    
    [uploadTask resume];
    
    return 0;
}


#pragma mark -- NSURLSessionDelegate
/*
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    KLog(@"*** NetworkController: didBecomeInvalidWithError:");
}*/

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

- (NSString*)saveFile
{
    NSString *localFilePath = nil;
    
    BOOL isWritten = FALSE;
    if(reqDic != nil && responseData != nil)
    {
        if(responseData != nil)
        {
            switch (curReqEvType)
            {
                case DOWNLOAD_VOICE_MSG:
                {
                    NSString *msgFlow = [reqDic valueForKey:MSG_FLOW];
                    if([msgFlow isEqualToString:@"s"])
                    {
                        localFilePath = [IVFileLocator getMediaAudioSentDirectory];
                    }
                    else
                    {
                        localFilePath = [IVFileLocator getMediaAudioReceivedDirectory];
                    }
                    
                    long long fileName= (long long)([[NSDate date] timeIntervalSince1970] * 1000);
                    [reqDic setValue:[NSNumber numberWithLongLong:fileName] forKey:DOWNLOAD_TIME];
                    NSString* mediaFormat = [[NSString alloc] initWithString:[reqDic valueForKey:MEDIA_FORMAT]];
                    
#ifdef OPUS_ENABLED
                    if( [mediaFormat isEqualToString:AUDIO_FORMAT] ) {
                        localFilePath = [localFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%llu.iv",fileName]];
                    }
                    else if( [mediaFormat isEqualToString:@"A"] ) {
                        localFilePath = [localFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%llu.wav",fileName]];
                    }
                    else {
                        EnLoge(@"ERROR: Unknown Media format %@",mediaFormat);
                    }
#else
                    if( [mediaFormat isEqualToString:AUDIO_FORMAT] ) {
                        localFilePath = [localFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%llu.wav",fileName]];
                    }
                    else {
                        EnLoge(@"ERROR: Unknown Media format %@",mediaFormat);
                    }
#endif
                    break;
                }
                default:
                    break;
            }
            
            isWritten = [responseData writeToFile:localFilePath atomically:YES];
            
            if(!isWritten)
            {
                localFilePath = nil;
            }
        }
    }
    
    return localFilePath;
}


#pragma mark - RESPONSE DATA
-(NSString *)getResponseError:(NSInteger)errorCode
{
    NSString *respError = nil;
    if(errorCode == NSURLErrorUnknown || errorCode == NSURLErrorUnsupportedURL)
    {
        respError = SERVER_NOT_REACHABLE;
    }
    else if(errorCode == NSURLErrorTimedOut)
    {
        respError = REQUEST_TIME_OUT;
    }
    else
    {
        respError = NET_FAILURE;
    }
    return respError;
}

-(void)setEventSpecificResult:(int)eventType resultDic:(NSMutableDictionary *)responseDic
{
    switch (eventType)
    {
        case DOWNLOAD_VOICE_MSG:
        {
            responseData = responseDic[RESPONSE_DATA];
            
            NSString *filePath = [self saveFile];
            if(filePath != nil && [filePath length]>0)
            {
                [reqDic setValue:filePath forKey:MSG_LOCAL_PATH];
                [reqDic setValue:API_DOWNLOADED forKey:MSG_STATE];
                [responseDic setValue:NET_SUCCESS forKey:RESPONSE_CODE];
            }
            else
            {
                [reqDic setValue:API_NOT_DOWNLOADED forKey:MSG_STATE];
                [responseDic setValue:NET_FAILURE forKey:RESPONSE_CODE];
            }
        }
            break;
        default:
            break;
    }
    
}

-(NSMutableDictionary *)getResponseDic:(NSData *)respData
{
    NSError *error = nil;
    NSMutableDictionary *respDic = nil ;
    if(respData != nil )
    {
        respDic = [NSJSONSerialization JSONObjectWithData:respData options:NSJSONReadingMutableContainers error:&error];
        if(error )
        {
            EnLoge(@"error in conversion of json to response dic : %@",error);
        }
    }
    return respDic;
}

-(void)sendResponse:(NSMutableDictionary *)resultDic
{
    NSMutableDictionary *responseDic = [[NSMutableDictionary alloc]init];
    [responseDic setValue:NET_EVENT forKey:EVENT_MODE];
    [responseDic setValue:[NSNumber numberWithInt:curReqEvType] forKey:EVENT_TYPE];
    [responseDic setValue:[[NSMutableDictionary alloc]initWithDictionary:resultDic] forKey:EVENT_OBJECT];
    [appDelegate.engObj addEvent:responseDic];
}

-(void)clearNetworkQueue
{
    [netLock lock];
    if(eventQueue != nil)
    {
        [eventQueue removeAllObjects];
        eventQueue = nil;
    }
    requestId = 0;
    [netLock unlock];
    
    reqEvObj = nil;
    reqDic = nil;
    curReqEvType = -1;
    isAddedInRunLoop = FALSE;
    responseData = nil;
    isRequestDone = TRUE;
}

@end
