
//
//  Logger.m
//  InstaVoice
//
//  Created by Eninov on 11/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "Logger.h"
#import "IVFileLocator.h"

int logLevel = ERROR;
NSString *logFilePath;
NSString *logFileName;
NSString *tag;
NSFileHandle *fileHandle;

#define MAXLOGS 10000

NSLock *logLock = Nil;

int logInit(NSString *fileName, bool bEnable)
{

    if(!bEnable) {
        fileHandle=NULL;
        return 0;
    }
    
    logFilePath = [IVFileLocator getDocumentDirectoryPath];
    logFileName = [logFilePath stringByAppendingPathComponent:fileName];
#ifdef ENABLE_NSLOG
    NSLog(@"logFilePath = %@",logFilePath);
    NSLog(@"fileName = %@",fileName);
    NSLog(@"logFileName = %@",logFileName);
#endif
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //[fileManager removeItemAtPath:logFileName error:NULL];
    
    if(![fileManager fileExistsAtPath:logFileName])
    {
        NSLog(@"File does not exist");
        BOOL bRet = [fileManager createFileAtPath:logFileName contents:nil attributes:nil];
        if(!bRet) {
            NSLog(@"ERROR creating log file");
            return 1;
        }
    } else {
        NSLog(@"File exists");
        fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:logFileName];
        if(fileHandle != NULL)
        {
            [fileHandle seekToEndOfFile];
            if(logLock) {
                logLock = nil;
            }
            
            logLock = [[NSLock alloc]init];
        } else {
             NSLog(@"fileHandleForUpdatingAtPath failed");
        }
    }
    
    if(!fileHandle) {
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:logFileName];
        if(fileHandle != NULL) {
            [fileHandle seekToEndOfFile];
        }
        
        if(logLock) {
            logLock = nil;
        }
        
        logLock = [[NSLock alloc]init];
    }
    
    return 0;
}

int logClose()
{
    [logLock lock];
    [fileHandle closeFile];
    fileHandle = NULL;
    [logLock unlock];
    
    return 0;
}

int setLogLevel(int level)
{
    if((level >= DEBUG)&&(level <= ERROR))
        logLevel = level;
    return 0;
}

int logRotate()
{
    return 0;
}

void sendLogs(NSString *format, va_list args)
{
    //NSLogv(format, args);
    
    /* Format with NSString */
    @autoreleasepool {
        
        NSString *pnssBuffer=NULL;
        pnssBuffer=[[NSString alloc] initWithFormat:format arguments:args];
        
        NSDate *now = [[NSDate alloc] init];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss:"];
        NSString *date = [dateFormat stringFromDate:now];
        date = [date stringByAppendingString:pnssBuffer];
        date = [date stringByAppendingString:@"\n"];
        NSData *logData = [date dataUsingEncoding:NSUTF8StringEncoding];
        
        [logLock lock];
        @try {
            [fileHandle writeData:logData];
        }
        @catch (NSException *exception) {
            NSLog(@"ERROR: Exception occurred while writing logs. CHECK THE CODE");
        }
        @finally {
            [logLock unlock];
        }
    }
}


void enLog(int level, NSString *format, ...)
{
    va_list args;
    
    if(!fileHandle) return;
    
    if(level >= logLevel)
    {
        va_start(args, format);
        sendLogs(format,args);
        va_end(args);
    }
}
