//
//  IVImageProcessingOperation.m
//  InstaVoice
//
//  Created by adwivedi on 21/07/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "IVImageProcessingOperation.h"
#import "Logger.h"
#import "ConfigurationReader.h"
#import "IVFileLocator.h"

@implementation IVImageData
@synthesize imgLocalPath,imgServerPath,imgData;
@end

@implementation IVImageProcessingOperation
{
    NSURLSession* _session;
}

-(id)initWithImageData:(IVImageData *)imageData ivImageProcessingOperationType:(IVImageProcessingOperationType)operationType
{
    if(self = [super init])
    {
        self.imageData = imageData;
        self.ivImageProcessingOperationType = operationType;
    }
    return self;
}

- (void)main {
    
    switch (self.ivImageProcessingOperationType)
    {
        case IVImageProcessingOperationTypeDownloadImage:
        {
            [self downloadPicFromServer:self.imageData.imgServerPath andSaveToPicPath:self.imageData.imgLocalPath];
        }
            break;
            
        case IVImageProcessingOperationTypeProcessImage:
            break;
            
        case IVImageProcessingOperationTypeUploadImage:
            break;
            
        default:
            break;
    }
}

//MAY 18, 2017
-(void)dealloc
{
    [_session invalidateAndCancel];
}
//

-(void)downloadPicFromServer:(NSString*)picURL andSaveToPicPath:(NSString*)picPath
{
    NSDate *__block startTime = [NSDate date];
    NSDate *__block finishTime;
    if(!picURL && ![picURL length]) {
        KLog(@"*** downloadPicFromServer -- picURL is nil");
        return;
    }
    
    NSURL* URL = [NSURL URLWithString:picURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //MAY 18, 2017 NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDownloadTask *downloadTask =
    [_session downloadTaskWithRequest:request
                        completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                            
                finishTime = [NSDate date];
                NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:startTime];
                //NSLog(@"Execution Time:%f",executionTime);
                            
                KLog(@"*** downloadPicFromServer execution time in secs: %.2f", executionTime);
                
                if(error) {
                    KLog(@"*** downloadPicFromServer failed: %@", error);
                }
                else {
                    KLog(@"*** downloadPicFromServer succeeded.");
                    /*
                     NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                     NSURL* newFilePath = [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                     */
                    
                    NSData* data = [NSData dataWithContentsOfURL:location options:NSDataReadingMappedIfSafe error:&error];
                    if(data != nil)
                    {
                        self.imageData.imgData = data;
                        [data writeToFile:picPath atomically:YES];
                        [self notifyResponseToMainThread:self.imageData];
                    }
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


//MAY 18, 2017
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {

   //CMP  NSLog(@"Invalidate session");
}
//

#pragma mark -Response notification to main thread
-(void)notifyResponseToMainThread:(IVImageData*)imageData
{
    [self performSelectorOnMainThread:@selector(notifyResponse:) withObject:imageData waitUntilDone:NO];
}
-(void)notifyResponse:(IVImageData*)imageData
{
    [self.delegate ivImageProcessingOperationType:self.ivImageProcessingOperationType completedWithResponse:imageData];
}

@end
