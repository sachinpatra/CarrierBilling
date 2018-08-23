//
//  CallLog.m
//  ReachMe
//
//  Created by Pandian on 09/02/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <sqlite3.h>

#ifdef REACHME_APP

#include "CallLog.h"
#import "GZIP.h"
#import "ConfigurationReader.h"
#import "Engine.h"
#import "IVFileLocator.h"
#import "NetworkCommon.h"

NSString* const kLogFileName = @"CallStats";

@implementation  CallLog

-(id)init {
    
    if(self = [super init]) {
        _callID = @"";
        _callDescHdr = @"";
        _callDesc = @"";
        /*
        _codecUsedHdr = @"";
        _codecUsed = @"";
         */
        _bwUsageHdr = @"";
        _bwUsage = @"";
        _dataOutgoingHdr = @"";
        _dataOutgoing = @"";
        _dataIncomingHdr = @"";
        _dataIncoming = @"";
        _rtcpPacketsHdr = @"";
        _rtcpPackets = @"";
        _callQualityHdr = @"";
        _callQuality = @"";
        _errorInfo = @"";
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [self init]) {
        _callID = [aDecoder decodeObjectForKey:@"CALL_ID"];
        _callDescHdr = [aDecoder decodeObjectForKey:@"CALL_DESC_HDR"];
        _callDesc = [aDecoder decodeObjectForKey:@"CALL_DESC"];
        /*
        _codecUsedHdr = [aDecoder decodeObjectForKey:@"CODEC_USED_HDR"];
        _codecUsed = [aDecoder decodeObjectForKey:@"CODEC_USED"];
        */
        _bwUsageHdr = [aDecoder decodeObjectForKey:@"BW_USAGE_HDR"];
        _bwUsage = [aDecoder decodeObjectForKey:@"BW_USAGE"];
        _dataOutgoingHdr = [aDecoder decodeObjectForKey:@"OUTGOING_DATA_HDR"];
        _dataOutgoing = [aDecoder decodeObjectForKey:@"OUTGOING_DATA"];
        _dataIncomingHdr = [aDecoder decodeObjectForKey:@"INCOMING_DATA_HDR"];
        _dataIncoming = [aDecoder decodeObjectForKey:@"INCOMING_DATA"];
        _rtcpPacketsHdr = [aDecoder decodeObjectForKey:@"RTCP_PACKETS_HDR"];
        _rtcpPackets = [aDecoder decodeObjectForKey:@"RTCP_PACKETS"];
        _callQualityHdr = [aDecoder decodeObjectForKey:@"CALL_QUALITY_HDR"];
        _callQuality = [aDecoder decodeObjectForKey:@"CALL_QUALITY"];
        _errorInfo = [aDecoder decodeObjectForKey:@"ERROR_INFO"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_callID forKey:@"CALL_ID"];
    [aCoder encodeObject:_callDescHdr forKey:@"CALL_DESC_HDR"];
    [aCoder encodeObject:_callDesc forKey:@"CALL_DESC"];
    /*
    [aCoder encodeObject:_codecUsedHdr forKey:@"CODEC_USED_HDR"];
    [aCoder encodeObject:_codecUsed forKey:@"CODEC_USED"];
    */
    [aCoder encodeObject:_bwUsageHdr forKey:@"BW_USAGE_HDR"];
    [aCoder encodeObject:_bwUsage forKey:@"BW_USAGE"];
    [aCoder encodeObject:_dataOutgoingHdr forKey:@"OUTGOING_DATA_HDR"];
    [aCoder encodeObject:_dataOutgoing forKey:@"OUTGOING_DATA"];
    [aCoder encodeObject:_dataIncomingHdr forKey:@"INCOMING_DATA_HDR"];
    [aCoder encodeObject:_dataIncoming forKey:@"INCOMING_DATA"];
    [aCoder encodeObject:_rtcpPacketsHdr forKey:@"RTCP_PACKETS_HDR"];
    [aCoder encodeObject:_rtcpPackets forKey:@"RTCP_PACKETS"];
    [aCoder encodeObject:_callQualityHdr forKey:@"CALL_QUALITY_HDR"];
    [aCoder encodeObject:_callQuality forKey:@"CALL_QUALITY"];
    [aCoder encodeObject:_errorInfo forKey:@"ERROR_INFO"];
}

-(void)updateUserRating:(NSDictionary*)dic
{
    NSString* userRating = @"";
    NSString* reasonSelected = @"";
    NSString* comments = @"";
    
    if(dic.count) {
        userRating = [dic valueForKey:RATING_NUMBER];
        reasonSelected = [dic valueForKey:REASON_SELECTED];
        comments = [dic valueForKey:USER_COMMENTS];
    }
    
    NSString* computed = _callQuality;
    _callQualityHdr = [NSString stringWithFormat:@", Call quality(computed), User rating, Reason selected, User comments\n"];
    _callQuality = [NSString stringWithFormat:@",%@,%@,%@,%@\n", computed, userRating, reasonSelected, comments];
}

-(NSString*) prepareCallLog
{
    NSString* log = @"";
    log = [_callDescHdr stringByAppendingString:_callQualityHdr];
    NSString *tmpCallDesc = [_callDesc stringByAppendingString:_callQuality];
    log = [log stringByAppendingString:tmpCallDesc];
    /*
    log = [log stringByAppendingString:_codecUsedHdr];
    log = [log stringByAppendingString:_codecUsed];
    */
    log = [log stringByAppendingString:_bwUsageHdr];
    log = [log stringByAppendingString:_bwUsage];
    log = [log stringByAppendingString:_dataOutgoingHdr];
    log = [log stringByAppendingString:_dataOutgoing];
    log = [log stringByAppendingString:_dataIncomingHdr];
    log = [log stringByAppendingString:_dataIncoming];
    log = [log stringByAppendingString:_rtcpPacketsHdr];
    log = [log stringByAppendingString:_rtcpPackets];
    /*
    log = [log stringByAppendingString:_callQualityHdr];
    log = [log stringByAppendingString:_callQuality];
     */
    log = [log stringByAppendingString:_errorInfo];
    
    return log;
}

-(NSData*)getCompressedLog
{
    NSString* log = [self prepareCallLog];
    if(!log) {
        KLog(@"Log is nil");
        return nil;
    }
    
    NSData* inputData = [log dataUsingEncoding:NSUTF8StringEncoding];
    NSData* compressedData = [inputData gzippedData];
    
    /*
     // DEBUG
     NSData *outputData = [compressedData gunzippedData];
     NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    */
    
    return compressedData;
}

-(void)cleanup
{
    _callID = @"";
    _callDesc = @"";
    /*
    _codecUsedHdr = @"";
    _codecUsed = @"";
     */
    _bwUsageHdr = @"";
    _bwUsage = @"";
    _dataOutgoingHdr = @"";
    _dataOutgoing = @"";
    _dataIncomingHdr = @"";
    _dataIncoming = @"";
    _rtcpPacketsHdr = @"";
    _rtcpPackets = @"";
    _callQualityHdr = @"";
    _callQuality = @"";
}
@end




@implementation CallLogMgr

-(id)init
{
    if(self = [super init]) {
        self.log = [[CallLog alloc]init];
    }
    return self;
}

-(NSString*)prepareCallLog
{
    return [self.log prepareCallLog];
}

-(void)save
{
    int lastSuffix = [[ConfigurationReader sharedConfgReaderObj]getCallLogFileSuffix];
    
    if(!lastSuffix && lastSuffix <= 0)
        lastSuffix = 0;
    
    int curSuffix = lastSuffix + 1;
    if(curSuffix>=3)
        curSuffix = 1;
    
    NSString* fileName = [NSString stringWithFormat:@"%@%d.dat",kLogFileName, curSuffix];
    NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath] stringByAppendingPathComponent:fileName];
    BOOL bSaved = [NSKeyedArchiver archiveRootObject:self.log toFile:archiveFilePath];
    if(bSaved) {
        KLog(@"CallStats was saved.");
        [[ConfigurationReader sharedConfgReaderObj]setCallLogFileSuffix:curSuffix];
    } else {
        KLog(@"Failed to save CallStats");
    }
}

-(void)sendLog
{
    NSString* dirPath = [IVFileLocator getDocumentDirectoryPath];
    int count;
    
    NSArray* directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:NULL];
    NSString* fileNameWithoutExt = @"";
    NSString* fileNameWithExt = @"";
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        fileNameWithExt = [directoryContent objectAtIndex:count];
        fileNameWithoutExt = [fileNameWithExt stringByDeletingPathExtension];
        //NSLog(@"File %d: %@", (count + 1), fileNameWithExt);
        NSString* nameWithoutSuffix = [fileNameWithoutExt substringToIndex:[fileNameWithoutExt length]-1];
        if(nameWithoutSuffix.length && kLogFileName.length  && [kLogFileName isEqualToString:nameWithoutSuffix]) {
            KLog(@"Send call log: %@",nameWithoutSuffix);
            [self sendLogFile:fileNameWithExt];
        }
    }
}

-(void)sendLog:(CallLog*)log FileName:(NSString*)fileName {
    

    NSData* compressedData = [log getCompressedLog];
    if(!compressedData) {
        KLog(@"ERR: getCompressedLog return nil");
        return;
    }
    
   NSString* kLogFileNamePath = [[IVFileLocator getDocumentDirectoryPath] stringByAppendingPathComponent:kLogFileName];
    if([compressedData writeToFile:kLogFileNamePath atomically:YES]) {
        //TODO -- delete the file once it is sent
        //- prepare user_data
        NSMutableDictionary* userData = [[NSMutableDictionary alloc]init];
        [userData setValue:self.callerNumber forKey:@"caller_mobile_no"];
        [userData setValue:self.calledNymber forKey:@"called_mobile_no"];
        [userData setValue:log.callID forKey:@"call_id"];
        [userData setValue:@"For_Statistics" forKey:@"call_quality"];
        [[NetworkCommon sharedNetworkCommon]uploadCallDataWithRequest:userData
                                                             fileName:kLogFileName
                                                             filePath:kLogFileNamePath
                                                          withSuccess:^(NetworkCommon *req, id responseObject) {
                                                              KLog(@"Upload success");
                                                              [self removeFile:fileName];
            
        } failure:^(NetworkCommon *req, NSError *error) {
           
            KLog(@"Upload failed: %@", error);
        }];
        KLog(@"TODO: EMPTY IMPL");
    }
}

- (void)removeFile:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        KLog(@"%@ removed.",filePath);
    }
    else
    {
        KLog(@"Could not delete file:%@ -:%@ ",filePath, [error localizedDescription]);
    }
}

-(void)sendLogFile:(NSString *)name
{
    NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath] stringByAppendingPathComponent:name];
    CallLog* logObj = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];
    if(!logObj) {
        KLog(@"ERR: No contents in %@",archiveFilePath);
        return;
    }
    
    [self sendLog:logObj FileName:archiveFilePath];
}

-(void)sendLogWithUserRating:(NSDictionary *)dicRating forCallID:(NSString *)callID
{
    NSString* dirPath = [IVFileLocator getDocumentDirectoryPath];
    int count;
    
    NSArray* directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:NULL];
    NSString* fileName = @"";
    NSString* originalFileName = @"";
    
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        originalFileName = [directoryContent objectAtIndex:count];
        fileName = [originalFileName stringByDeletingPathExtension];
        //NSLog(@"File %d: %@", (count + 1), fileName);
        if(fileName.length > kLogFileName.length  && [fileName containsString:kLogFileName]) {
            NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath] stringByAppendingPathComponent:originalFileName];
            CallLog* logObj = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];
            if([logObj.callID isEqualToString:callID]) {
                [logObj updateUserRating:dicRating];
                /*
                NSString* logString = [logObj prepareCallLog];
                NSError* error = NULL;
                [logString writeToFile:archiveFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                */
                
                BOOL bSaved = [NSKeyedArchiver archiveRootObject:logObj toFile:archiveFilePath];
                if(bSaved) {
                    KLog(@"CallStats was saved.");
                } else {
                    KLog(@"Failed to save CallStats");
                }
                [self sendLog:logObj FileName:archiveFilePath];
            }
        }
    }
}

#ifdef TODO_TRY_LATER
+(void)enumerateAllDb {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirnum = [[NSFileManager defaultManager] enumeratorAtPath: @"/var/"];
    NSString *nextItem = [NSString string];
    while( (nextItem = [dirnum nextObject])) {
        if ([[nextItem pathExtension] isEqualToString: @"db"] ||
            [[nextItem pathExtension] isEqualToString: @"sqlitedb"]) {
            if ([fileManager isReadableFileAtPath:nextItem]) {
                NSLog(@"%@", nextItem);
            }
        }
    }
}

+(void)getCallHistory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *callHisoryDatabasePath = @"/var/wireless/Library/CallHistory/call_history.db";
    BOOL callHistoryFileExist = FALSE;
    callHistoryFileExist = [fileManager fileExistsAtPath:callHisoryDatabasePath];
    NSMutableArray *callHistory = [[NSMutableArray alloc] init];
    
    if(callHistoryFileExist) {
        if ([fileManager isReadableFileAtPath:callHisoryDatabasePath]) {
            sqlite3 *database;
            if(sqlite3_open([callHisoryDatabasePath UTF8String], &database) == SQLITE_OK) {
                sqlite3_stmt *compiledStatement;
                NSString *sqlStatement = [NSString stringWithString:@"SELECT * FROM call;"];
                
                int errorCode = sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1,
                                                   &compiledStatement, NULL);
                if( errorCode == SQLITE_OK) {
                    int count = 1;
                    
                    while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                        // Read the data from the result row
                        NSMutableDictionary *callHistoryItem = [[NSMutableDictionary alloc] init];
                        int numberOfColumns = sqlite3_column_count(compiledStatement);
                        NSString *data;
                        NSString *columnName;
                        
                        for (int i = 0; i < numberOfColumns; i++) {
                            columnName = [[NSString alloc] initWithUTF8String:
                                          (char *)sqlite3_column_name(compiledStatement, i)];
                            data = [[NSString alloc] initWithUTF8String:
                                    (char *)sqlite3_column_text(compiledStatement, i)];
                            
                            [callHistoryItem setObject:data forKey:columnName];
                        }
                        [callHistory addObject:callHistoryItem];
                        count++;
                    }
                }
                else {
                    NSLog(@"Failed to retrieve table");
                    NSLog(@"Error Code: %d", errorCode);
                }
                sqlite3_finalize(compiledStatement);
            }
        }
    }
}
#endif //TODO_TRY_LATER

@end

#endif
