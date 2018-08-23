//
//  IVAudioLoader.m
//  InstaVoice
//
//  Created by adwivedi on 13/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "IVAudioLoader.h"
#import "OpusCoder.h"

@implementation IVAudioLoader

+(void)loadAudioFileFromServerWithURL:(NSString*)serverPath andSaveToLocalPath:(NSString*)localPath withCompletionHandler:(void (^)(BOOL result))completionHandler
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        BOOL downloadFile = [self downloadFileFromServer:serverPath andSaveToPath:localPath];
        
        NSString* wavFileName = localPath;
        
        
        NSString* pcmFileName = [[NSString alloc]initWithString:wavFileName];
        pcmFileName = [pcmFileName stringByAppendingPathExtension:@"pcm"];
        wavFileName = [wavFileName stringByAppendingPathExtension:@"wav"];
        
        const char* cOpusFile = [localPath UTF8String];
        const char* cPcmFile = [pcmFileName UTF8String];
        const char* cWavFile = [wavFileName UTF8String];
        
        int iResult = [OpusCoder DecodeAudio:8000 OPUSFile:cOpusFile PCMFile:cPcmFile WAVFile:cWavFile];
        if(0 == iResult) {
            [IVAudioLoader deleteFileAtPath:pcmFileName];
            [IVAudioLoader deleteFileAtPath:localPath];//Delete the opus file
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            completionHandler(downloadFile);
        });
    });
}

+(void)loadImageFileFromServerWithURL:(NSString*)serverPath andSaveToLocalPath:(NSString*)localPath withCompletionHandler:(void (^)(BOOL result))completionHandler
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        BOOL downloadFile = [self downloadFileFromServer:serverPath andSaveToPath:localPath];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            completionHandler(downloadFile);
        });
    });
}

+(void)loadContactPicFileFromServerWithURL:(NSString*)serverPath andSaveToLocalPath:(NSString*)localPath withCompletionHandler:(void (^)(BOOL result))completionHandler
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        BOOL downloadFile = [self downloadFileFromServer:serverPath andSaveToPath:localPath];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            completionHandler(downloadFile);
        });
    });
    
}
//Deepak_Carpenter : Added this method to download data in <iOS8.4 version
#pragma mark - Synchronous Request Call Method for  < iOS 8.4 Version
// ------------------/// Start ///---------------------------//
+ (NSData *)sendMySynchronousRequest:(NSURLRequest *)request
                   returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                               error:(__autoreleasing NSError **)errorPtr {
    dispatch_semaphore_t    sem;
    __block NSData *        result;
    
    result = nil;
    
    sem = dispatch_semaphore_create(0);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         if (errorPtr != NULL) {
                                             *errorPtr = error;
                                         }
                                         if (responsePtr != NULL) {
                                             *responsePtr = response;
                                         }
                                         if (error == nil) {
                                             result = data;
                                         }
                                         dispatch_semaphore_signal(sem);
                                     }] resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return result;
}  
// ---------------------/// END ///-----------------------------//
+(BOOL)downloadFileFromServer:(NSString*)fileURL andSaveToPath:(NSString*)filePath
{
    BOOL downloadCompleted = false;
    if(fileURL != Nil && [fileURL length]>0)
    {
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL]];
        
        NSError* error = nil;
        NSURLResponse* response = nil;
        
       // NSData* audioData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        
//Deepak_Carpenter : Added this code to download data in <iOS8.4 version
// ------------------/// Start ///---------------------------//

        __block NSData *audioData;
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
            audioData = [self sendMySynchronousRequest:urlRequest returningResponse:&response error:&error];
        }
        else {
            
            audioData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        }
        
///--------------------/// END ///-----------------------///
        
        long statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if(statusCode >= 400)
        {
            //error downloading data
        }
        else
        {
            if(audioData != nil)
            {
                [audioData writeToFile:filePath  atomically:YES];
                downloadCompleted = true;
            }
        }
    }
    return downloadCompleted;
}


+(NSString*)getTempSharedDirectoryPath
{
    NSString *documentDirPath = @"";
    
    NSURL* sharedPath = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.kirusa.InstaVoiceGroup"];
    documentDirPath = [[sharedPath path]stringByAppendingPathComponent:@"Temp"];
    [IVAudioLoader checkAndCreateDirectoryIfNotExist:documentDirPath];
    return documentDirPath;
}

+(BOOL)deleteFileAtPath:(NSString*)filePath
{
    BOOL result = TRUE;
    if(filePath != nil && [filePath length]>0)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isFileExist = [fm fileExistsAtPath:filePath];
        if(isFileExist)
        {
            NSError *error = nil;
            BOOL success = [fm removeItemAtPath:filePath error:&error];
            if (!success || error)
            {
                result = FALSE;
            }
        }
    }
    else
    {
        result = FALSE;
    }
    return result;
}

+(BOOL)mkDirectory:(NSString*)dirPath
{
    NSError *error;
    if (dirPath == nil || [dirPath length]== 0)
    {
        return NO;
    }
    return  [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
}

+(BOOL)checkIfFileExistAtPath:(NSString*)path isDirectory:(BOOL*)isDirectory
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:isDirectory];
}

+(BOOL)checkAndCreateDirectoryIfNotExist:(NSString*)path
{
    BOOL isDirectory = FALSE;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    
    if(!(isFileExist && isDirectory))
    {
        if(![self mkDirectory:path])
        {
            return FALSE;
        }
    }
    return TRUE;
}

+(BOOL) isNumeric:(NSString *) Numeric
{
    BOOL valid = FALSE;
    if(Numeric != nil && Numeric.length > 0)
    {
        NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:Numeric];
        valid = ([alphaNums isSupersetOfSet:inStringSet]) ;
    }
    return valid;
}


@end
