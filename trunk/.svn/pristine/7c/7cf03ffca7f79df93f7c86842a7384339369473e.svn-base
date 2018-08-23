
//
//  Database.m
//  InstaVoice
//
//  Created by EninovUser on 16/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "Database.h"
#import "IVFileLocator.h"
#import "TableColumns.h"
#import "Macro.h"
#import "Logger.h"


@implementation Database
static Database *dbObj = nil;


-(id)init
{
    self = [super init];
    if(self)
    {
        dbHelper = [[DBHelper alloc] init];
        if(![self createDatabase])
        {
            EnLoge(@"Database Creation Fail");
        }
        
    }
    return self;
}

+(Database*)sharedDBObj
{
    if(dbObj == nil)
    {
        dbObj = [[Database alloc] init];
    }
    return dbObj;
}

-(BOOL)createDatabase
{
    BOOL isSuccess = NO;
    
    //Document Directory Path
    NSString *kirusaDir = [IVFileLocator getDocumentDirectoryPath];
    if(kirusaDir == nil || [kirusaDir isEqualToString:@""])
    {
        EnLoge(@"not able to create Kirusa Directory");
        return isSuccess;
    }
    
    // Build the path to the database file
    NSString* databasePath = [[NSString alloc] initWithString:[kirusaDir stringByAppendingPathComponent: DATABASE_NAME]];
    EnLogi(@"database path : %@",databasePath);
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if (![filemgr fileExistsAtPath: databasePath ])
    {
        isSuccess = [self openDatabase:databasePath];
        if(isSuccess)
        {
            if([dbHelper createDatabaseTables:sqlite3Db])
            {
                isSuccess = YES;
            }
            else
            {
                isSuccess = NO;
                EnLoge(@"Failed to create tables");
            }
        }
    }
    else
    {
        isSuccess = [self openDatabase:databasePath];
    }
    return isSuccess;
}

-(BOOL)openDatabase:(NSString*)databasePath
{
    BOOL result = YES;
    const char *dbpath = [databasePath UTF8String];
    if(!(sqlite3_open(dbpath, &sqlite3Db) == SQLITE_OK))
    {
        result = NO;
         EnLoge(@"Error in opening/creating database : %s",sqlite3_errmsg(sqlite3Db));
    }
    return result;
}

-(BOOL)closeDatabase
{
    sqlite3_close(sqlite3Db);
    return YES;
}

-(sqlite3*)getSqlite3Obj
{
    return sqlite3Db;
}

-(BOOL)executeQuery:(sqlite3_stmt*)stmt
{
    BOOL result =  NO;
    int code = sqlite3_step(stmt);
    if (code == SQLITE_DONE)
    {
        result = YES;
    }
    else
    {
       EnLoge(@"error in executeQuery : %s",sqlite3_errmsg(sqlite3Db));
    }
    return result;
}

-(BOOL)executeSelectQuery:(sqlite3_stmt*)stmt
{
    BOOL result = NO;
    if(sqlite3_step(stmt) == SQLITE_ROW)
    {
        result = YES;
    }
    return result;
}





@end
