//
//  Conversations.m
//  InstaVoice
//
//  Created by adwivedi on 18/05/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "Conversations.h"
#import "FetchMessageAPI.h"
#import "FetchMessageActivityAPI.h"
#import "Engine.h"
#import "MQTTReceivedData.h"
#import "PendingEventManager.h"

#import "NetworkCommon.h"
#import "EventType.h"
#import "ConfigurationReader.h"
#import "ConversationApi.h"
#import "ServerErrorMsg.h"
#import "Logger.h"

#define BG_SESSION_ID   @"com.kirusa.backgroundFetchData"

@interface Conversations() <NSURLSessionDelegate,NSURLSessionDownloadDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
@property (nonatomic)NSURLSessionDataTask* fetchDataTask;
@property (nonatomic)NSURLSession* backgroundFetchDataSession;
@property (nonatomic)NSMutableData* responseData;
@property (copy,nonatomic) void(^backgroundFetchWithNotification)(UIBackgroundFetchResult);

@end

static Conversations* _sharedConversationObj = nil;
@implementation Conversations

//RM NSDate* startTime;

-(id)init
{
    if(self = [super init])
    {
        self.backgroundFetchDataSession = [self createBackgroundFetchDataSession];
        startTime = nil;
    }
    return self;
}
+(id)sharedConversations
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConversationObj = [self new];
    });
    return _sharedConversationObj;
}

-(void)fetchMessageFromServerWithSkipMsgId:(long)msgId notificationDic:(NSDictionary*) notificationDic
{
    KLog1(@"Fetch Message Request with skip id %ld",msgId);
    EnLogd(@"Fetch Message Request with skip id %ld",msgId);
    
    NSMutableDictionary* request = [[NSMutableDictionary alloc]init];
    if(msgId > 0)
        [request setValue:[NSNumber numberWithLong:msgId] forKey:@"skip_msg_id"];
    
    FetchMessageAPI* api = [[FetchMessageAPI alloc]initWithRequest:request];
    [api callNetworkRequest:request withSuccess:^(FetchMessageAPI *req, NSMutableDictionary *responseObject) {
        KLog1(@"Fetch Message Response with skip id %ld",msgId);
        EnLogd(@"Fetch Message Response with skip id %ld",msgId);
        //call engine event to process the response.
        if(notificationDic.count)
            [responseObject setValue:notificationDic forKey:@"NotificationData"];
        
        if([[responseObject valueForKey:@"status"]isEqualToString:@"ok"])
        {
            //new message from server. add engine event to process.
            MQTTReceivedData* data = [[MQTTReceivedData alloc]init];
            data.dataType = MQTTReceivedDataTypeFetchMessage;
            data.errorType = 0;
            data.responseData = responseObject;
            data.requestData = req.request;
            data.error = Nil;
            [[Engine sharedEngineObj]addMQTTReceivedDataEvent:data];
            
            [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidSucceedWithResponse:responseObject forPendingEventType:PendingEventTypeFetchMessage];
        }
        else
        {
            [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidFailWithError:Nil forPendingEventType:PendingEventTypeFetchMessage];
        }
        
    } failure:^(FetchMessageAPI *req, NSError *error) {
        KLog1(@"FetchMessageAPI failed: %@",error);
        EnLogd(@"FetchMessageAPI failed: %@",error);
        [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidFailWithError:Nil forPendingEventType:PendingEventTypeFetchMessage];
    }];
    
    //KLog1(@"Debug");
}

-(void)fetchMessageActivitiesWithSkipActivityId:(long)activityId
{
    NSMutableDictionary* request = [[NSMutableDictionary alloc]init];
    if(activityId > 0)
        [request setValue:[NSNumber numberWithLong:activityId] forKey:@"skip_activity_id"];
    
    FetchMessageActivityAPI* api = [[FetchMessageActivityAPI alloc]initWithRequest:request];
    [api callNetworkRequest:request withSuccess:^(FetchMessageActivityAPI *req, NSMutableDictionary *responseObject) {
        KLog(@"Fetch Message activity with skip id %ld",activityId);
        //call engine event to process the response
        if([[responseObject valueForKey:@"status"]isEqualToString:@"ok"])
        {
            MQTTReceivedData* data = [[MQTTReceivedData alloc]init];
            data.dataType = MQTTReceivedDataTypeFetchMessageActivity;
            data.errorType = 0;
            data.responseData = responseObject;
            data.requestData = req.request;
            data.error = Nil;
            [[Engine sharedEngineObj]addMQTTReceivedDataEvent:data];
            
            [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidSucceedWithResponse:responseObject forPendingEventType:PendingEventTypeFetchMessageActivity];
        }
        else
        {
            [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidFailWithError:Nil forPendingEventType:PendingEventTypeFetchMessageActivity];
        }
    } failure:^(FetchMessageActivityAPI *req, NSError *error) {
        KLog(@"FetchMessageActivityAPI failed. %@",error);
        [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidFailWithError:Nil forPendingEventType:PendingEventTypeFetchMessageActivity];
    }];
}


-(NSURLSession*)createBackgroundFetchDataSession
{
    KLog(@"BG_FETCH: createBackgroundFetchDataSession");
    
    /* SEP 3, 2016
    static NSURLSession* session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        NSURLSessionConfiguration* backgroundConfig;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f) {
            KLog(@"BG_FETCH -- NSURLSession with default session config.");
            backgroundConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        
        session = [NSURLSession sessionWithConfiguration:backgroundConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
    });*/
    
    if( !([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f)) {
        KLog(@"BG_FETCH -- The app does only supprt iOS 8 and later. return");
    }
    
    KLog(@"BG_FETCH -- NSURLSession with default session config.");
    NSURLSessionConfiguration* backgroundConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:backgroundConfig
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    return session;
}


-(void)fetchMessageFromServerInBackgroundWithNotification:(NSDictionary*)notificationDic fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if(!self.backgroundFetchDataSession) {
        KLog(@"BG_FETCH background is already not running. create it.");
        self.backgroundFetchDataSession = [self createBackgroundFetchDataSession];
    }
    
    if(self.fetchDataTask)
    {
        EnLoge(@"BG_FETCH Already running in Background");
        KLog(@"BG_FETCH Already running in Background. return.");
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    startTime = [NSDate date];
    
    EnLoge(@"BG_FETCH Message Request in Background");
    KLog(@"BG_FETCH Message Request in Background");
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [NetworkCommon addCommonData:requestDic eventType:FETCH_MSG];
    long afterID = [[ConfigurationReader sharedConfgReaderObj] getAfterMsgId];
    NSNumber *afterNum = [NSNumber numberWithLong:afterID];
    [requestDic setValue:afterNum forKey:API_FETCH_AFTER_MSGS_ID];
    [requestDic setValue:@"bg" forKey:@"status"];
    
    NSNumber *maxRow = [NSNumber numberWithInt:500];
    [requestDic setValue:maxRow forKey:API_FETCH_MAX_ROWS];
    [requestDic setValue:[NSNumber numberWithBool:YES] forKey:API_FETCH_OPPONENT_CONTACTIDS];
    
    NSString* reqJson = [NetworkCommon getRequestJson:requestDic];
    NSCharacterSet *customCharacterset = [[NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]{}% "] invertedSet];
    NSString *req = [reqJson stringByAddingPercentEncodingWithAllowedCharacters:customCharacterset];
    
    NSMutableURLRequest *request = [NetworkCommon setHttpPostRequest:req serverUrl:SERVER_URL];
    request.HTTPMethod = @"POST";
    
    self.fetchDataTask = [self.backgroundFetchDataSession dataTaskWithRequest:request];
    
    [self.fetchDataTask resume];
    
    self.backgroundFetchWithNotification = completionHandler;
}

-(void)markCompletionOfDataDownload:(BOOL)success
{
    KLog(@"markCompletionOfDataDownload");
    EnLogd(@"markCompletionOfDataDownload");
    
    NSDate* finishTime = [NSDate date];
    NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:startTime];
    KLog(@"BG_FETCH markCompletionOfDataDownload. Elapsed time = %.2f",executionTime);
    
    if(self.backgroundFetchWithNotification)
    {
        EnLogd(@"markCompletionOfDataDownload:%d",success);
        void(^completionHandler)(UIBackgroundFetchResult) = self.backgroundFetchWithNotification;
        self.backgroundFetchWithNotification = nil;
        if(success)
            completionHandler(UIBackgroundFetchResultNewData);
        else
            completionHandler(UIBackgroundFetchResultNoData);
    }
}

//-(void)downloadFileWithURL:(NSString*)urlString
//{
//    if(self.fileDownloadTask)
//        return;
//
//    NSURL* url = [NSURL URLWithString:urlString];
//    NSURLRequest* request = [NSURLRequest requestWithURL:url];
//    self.fileDownloadTask = [[self backgroundFileDownloadSession]downloadTaskWithRequest:request]; // set it to nil after getting the response in delegate
//}

-(void)callCompletionHandlerIfFinished
{
    KLog(@"callCompletionHandlerIfFinished");
    
    [self.backgroundFetchDataSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSUInteger count = dataTasks.count + uploadTasks.count + downloadTasks.count;
        if(count == 0)
        {
            //set completion handler that we copied in app delegate in the callback method for handling events.
            //            AppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
            //            if(appDelegate.backgroundSessionCompletionHandler)
            //            {
            //                void(^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
            //                appDelegate.backgroundSessionCompletionHandler = nil;
            //                completionHandler();
            //            }
            
        }
    }];
}

#pragma mark -- NSURLSessionDelegate.
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    EnLoge(@"BG_FETCH: didBecomeInvalidWithError");
    KLog(@"BG_FETCH: didBecomeInvalidWithError");
    self.fetchDataTask = nil;
    self.backgroundFetchDataSession = nil;
    [self createBackgroundFetchDataSession];
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    //call completion handler here.
    EnLoge(@"BG_FETCH: URLSessionDidFinishEventsForBackgroundURLSession");
    KLog(@"BG_FETCH: URLSessionDidFinishEventsForBackgroundURLSession");
    [self callCompletionHandlerIfFinished];
}

-(void)URLSession:(NSURLSession *)session
            didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
              completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    EnLoge(@"BG_FETCH: didReceiveChallenge");
    KLog(@"BG_FETCH: didReceiveChallenge");
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        KLog(@"BG_FETCH: authentication required");
        if (challenge.previousFailureCount == 0)
        {
            KLog(@"BG_FETCH: authentication attempt is 0");
            
            NSURLCredential* credential =
                                [NSURLCredential credentialWithUser:[[ConfigurationReader sharedConfgReaderObj] getLoginId]
                                                           password:[[ConfigurationReader sharedConfgReaderObj] getPassword]
                                                        persistence:NSURLCredentialPersistenceForSession];
            
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
        else
        {
            KLog(@"BG_FETCH: authentication attempt :%ld",(long)challenge.previousFailureCount);
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
}

#pragma mark -- NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler

{
    EnLoge(@"BG_FETCH: task didReceiveChallenge");
    KLog(@"BG_FETCH: task didReceiveChallenge");
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        if (challenge.previousFailureCount == 0)
        {
            NSURLCredential* credential = [NSURLCredential credentialWithUser:[[ConfigurationReader sharedConfgReaderObj] getLoginId]
                                                                     password:[[ConfigurationReader sharedConfgReaderObj] getPassword]
                                                                  persistence:NSURLCredentialPersistenceForSession];
            
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
        else
        {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(!error)
    {
        KLog(@"BG_FETCH: didCompleteWithError task completed");
        EnLogd(@"BG_FETCH: didCompleteWithError task completed");
        NSMutableDictionary* serverResponse = [NetworkCommon getResponseDic:self.responseData];
        NSString* responseCode = [serverResponse valueForKey:STATUS];
        if([responseCode isEqualToString:STATUS_OK])
        {
            MQTTReceivedData* data = [[MQTTReceivedData alloc]init];
            data.dataType = MQTTReceivedDataTypeFetchMessageAsBackgroundNotification;
            data.errorType = 0;
            data.responseData = serverResponse;
            data.requestData = nil;
            data.error = Nil;
            [[Engine sharedEngineObj]addMQTTReceivedDataEvent:data];
        }
    }
    else
    {
        EnLoge(@"BG_FETCH: didCompleteWithError %@",error);
        KLog(@"BG_FETCH: didCompleteWithError %@",error);
        [self markCompletionOfDataDownload:false];
    }
    
    self.fetchDataTask = nil;
    
}

#pragma mark -- NSURLSessionDataDelegate
-(void)URLSession:(NSURLSession*)session dataTask:(NSURLSessionDataTask *)dataTask
                               didReceiveResponse:(NSURLResponse *)response
                                completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    KLog(@"BG_FETCH: didReceiveResponse");
    
    // The server answers with an error because it doesn't receive the params
    if(self.responseData != nil)
    {
        KLog(@"BG_FETCH: didReceiveResponse: responseData is not null.");
        EnLogd(@"BG_FETCH: didReceiveResponse: responseData is not null.");
        self.responseData = nil;
    }
    self.responseData = [[NSMutableData alloc]init];
    
    completionHandler(NSURLSessionResponseAllow);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                    didReceiveData:(NSData *)data
{
    KLog(@"BG_FETCH: didReceiveData");
    [self.responseData appendData:data];
}

-(void)URLSession:(NSURLSession*)session dataTask:(NSURLSessionDataTask *)dataTask
                            didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    KLog(@"BG_FETCH: didBecomeDownloadTask");
}

#pragma mark -- NSURLSessionDownloadDelegate
-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    EnLoge(@"BG_FETCH: didFinishDownloadingToURL");
    KLog(@"BG_FETCH: didFinishDownloadingToURL");
}

@end
