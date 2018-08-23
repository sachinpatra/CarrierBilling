//
//  BaseDB.m
//  InstaVoice
//
//  Created by Eninov on 02/12/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "BaseDB.h"
#import "Database.h"
#import "DBTables.h"

@interface BaseDB()

@end

@implementation BaseDB

-(id)init
{
    self = [super init];
    if(self)
    {
        dbObj = [Database sharedDBObj];
        sqlite3Db = [dbObj getSqlite3Obj];
    }
    return self;
}


-(BOOL)insertInTable:(NSMutableArray *)dataList tableType:(int)tableType
{
    BOOL result = FALSE;
    @autoreleasepool
    {
        if(dataList == nil || [dataList count] == 0)
        {
            EnLoge(@"data list for tableType : %d to insert is nil",tableType);
            return result;
        }
        char* errorMessage = nil;
        sqlite3_exec(sqlite3Db, BEGIN_TRANSACTION, NULL, NULL, &errorMessage);
        if(errorMessage != NULL)
        {
            EnLoge(@"Error in Begin Transaction: %s",errorMessage);
            return result;
        }
        BaseDB *baseDb = [[DBTables sharedDBTables] getTableObj:tableType];
        NSString *stmnt =  [baseDb getInsertStatement];
        const char *stmt = [stmnt UTF8String];
        int errorCode = sqlite3_prepare_v2(sqlite3Db, stmt,strlen(stmt), &statment, NULL);
        if(errorCode != SQLITE_OK )
        {
            KLog(@"Error in prepare statement for tableType : %d : error is : %s",tableType, sqlite3_errmsg(sqlite3Db));
            EnLoge(@"Error in prepare statement for tableType : %d : error is : %s",tableType, sqlite3_errmsg(sqlite3Db));
            return result;
        }
        int count = 0;
        int dataCount = [dataList count];
        for (NSMutableDictionary *dic in dataList)
        {
            //CMP TODO : use try/catch
            [baseDb bindStatementData:dic];
            if([dbObj executeQuery:statment])
            {
                count+=1;
            }
            sqlite3_reset(statment);
        }
        if(dataCount != count)
        {
            EnLoge(@"Execute query is not successfull for all rows for tableType : %d",tableType);
        }
        sqlite3_finalize(statment);
        sqlite3_exec(sqlite3Db, COMMIT_TRANSACTION, NULL, NULL, &errorMessage);
        if(errorMessage != NULL)
        {
            EnLoge(@"Error in COMMIT Transaction : %@ for tableType : %d",errorMessage,tableType);
            result = NO;
        }
        else
        {
            result = YES;
        }

    }
       return  result;
}


-(BOOL)updateTable:(NSMutableDictionary *)dic whereClause:(NSString *)whereClause tableType:(int)tableType
{
    BOOL result = FALSE;
    @autoreleasepool
    {
        if(dic == nil || [dic count] == 0)
        {
            EnLoge(@"dictionary for tableType : %d to update is nil",tableType);
            return result;
        }
        NSString *tableName = [BaseDB getTableName:tableType];
        if([tableName isEqualToString:@""])
        {
            EnLoge(@"tablename for tableType : %d is empty",tableType);
            return result;
        }
        NSMutableString *updateStr = [[NSMutableString alloc] initWithFormat:@"UPDATE %@ SET",tableName];
        NSArray *keys = [dic allKeys];
        for (int i = 0; i < [dic count]; i++)
        {
            [updateStr appendFormat:@" %@= ?,",[keys objectAtIndex:i]];
        }
        [updateStr deleteCharactersInRange:NSMakeRange([updateStr length]-1, 1)];
        if(whereClause != nil && [whereClause length] > 0)
        {
            [updateStr appendFormat:@" %@;",whereClause];
        }
        const char *stmt = [updateStr UTF8String];
        int errorCode = sqlite3_prepare_v2(sqlite3Db, stmt,-1, &statment, NULL);
        if(errorCode != SQLITE_OK)
        {
            EnLoge(@"Error in prepare statement for tableType : %d : error is : %s",tableType, sqlite3_errmsg(sqlite3Db));
            KLog(@"Error in prepare statement for tableType : %d : error is : %s",tableType, sqlite3_errmsg(sqlite3Db));
            return result;
        }
        for (int i =0; i <[dic count]; i++)
        {
            NSString *value = [[NSString alloc]initWithFormat:@"%@",[dic valueForKey:[keys objectAtIndex:i]]];
            sqlite3_bind_text(statment, i+1, [value UTF8String], -1, NULL);
        }
        if(!([dbObj executeQuery:statment]))
        {
            EnLoge(@"Error in update for table type : %d",tableType);
        }
        else
        {
            result = YES;
        }
        sqlite3_reset(statment);
    }
    return  result;
}

-(NSMutableArray*)queryTable:(NSMutableArray*)columns whereClause:(NSString*)whereClause groupBy:(NSString*)groupBy having:(NSString*)having orderBy:(NSString*)orderBy tableType:(int)tableType;
{
    NSMutableArray *dataList = nil;
    @autoreleasepool
    {
        NSString *tableName = @"";
        tableName = [BaseDB getTableName:tableType];
        NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"SELECT"];
        if((columns != nil && [columns count] >0))
        {
            int count = [columns count];
            for (int i=0; i < count; i++)
            {
                [query appendFormat:@" %@,",[columns objectAtIndex:i]];
            }
            [query deleteCharactersInRange:NSMakeRange([query length]-1, 1)];
            [query appendFormat:@" FROM %@",tableName];
        }
        else
        {
            [query appendFormat:@" * FROM %@",tableName];
        }
        
        //where cluse
        if(whereClause != nil && [whereClause length] >0)
        {
            [query appendFormat:@" %@",whereClause];
        }
        
        //GroupBy clause
        if(groupBy != nil && [groupBy length] >0)
        {
            [query appendFormat:@" %@",groupBy];
        }
        
        //Having clause
        if(having != nil && [having length] >0)
        {
            [query appendFormat:@" %@",having];
        }
        
        //OrderBy clause
        if(orderBy != nil && [orderBy length] >0)
        {
            [query appendFormat:@" %@",orderBy];
        }
        [query appendFormat:@";"];
        
        const char *stmt = [query UTF8String];
        int errorCode = sqlite3_prepare_v2(sqlite3Db, stmt,strlen(stmt), &statment, NULL);
        BaseDB *tableObj = [[DBTables sharedDBTables] getTableObj:tableType];
        if(errorCode == SQLITE_OK)
        {
            dataList = [[NSMutableArray alloc]init];
            while ([dbObj executeSelectQuery:statment])
            {
                NSMutableDictionary *dic = [tableObj getTableDic:statment];
                //CMP if(dic != nil)
                if( dic && [dic count])
                {
                    [dataList addObject:dic];
                }
            }
            sqlite3_reset(statment);
        }
        else
        {
            EnLoge(@"Error in prepare statement: error is : %s",sqlite3_errmsg(sqlite3Db));
            KLog(@"Error in prepare statement: error is : %s",sqlite3_errmsg(sqlite3Db));
        }

    }
       return  dataList;
}



-(BOOL)deleteFromTable:(NSString*)whereClause tableType:(int)tableType
{
    BOOL result = FALSE;
    @autoreleasepool
    {
        NSString *delStr = @"";
        NSString *tableName = [BaseDB getTableName:tableType];
        if(whereClause != nil && [whereClause length] >0)
        {
            delStr = [[NSString alloc] initWithFormat:@"DELETE FROM %@ %@",tableName,whereClause];
        }
        else
        {
            delStr = [[NSString alloc] initWithFormat:@"DELETE FROM %@",tableName];
        }
        
        const char *stmt = [delStr UTF8String];
        int errorCode = sqlite3_prepare_v2(sqlite3Db, stmt,-1, &statment, NULL);
        if(errorCode == SQLITE_OK)
        {
            if(![dbObj executeQuery:statment])
            {
                EnLoge(@"Error in deletion for tableType : %d",tableType)
            }
            else
            {
                result = YES;
            }
            sqlite3_reset(statment);
        }
        else
        {
            EnLoge(@"Error in prepare statement for Table Type : %d error is:%s",tableType, sqlite3_errmsg(sqlite3Db));
        }

    }
       return  result;
}


+(NSString *)getTableName:(int)tableType
{
    NSString *tableName = @"";
    switch (tableType)
    {
        case MESSAGE_TABLE_TYPE:
            tableName = MESSAGE_TABLE;
            break;
        case VSMS_LIMIT_TABLE_TYPE:
            tableName = VSMS_LIMIT_TABLE;
            break;
        default:
            tableName = @"";
            break;
    }
    return tableName;
}

-(int)getRowCount:(NSString *)where tableType:(int)tableType
{
    int rows = 0;
    @autoreleasepool
    {
        NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"SELECT COUNT(*) FROM "];
        NSString *tableName = [BaseDB getTableName:tableType];
        [query appendFormat:@"%@",tableName];
        if(where != nil && where.length > 0 )
        {
            [query appendFormat:@" %@",where];
        }
        [query appendFormat:@";"];
        const char *stmt = [query UTF8String];
        if(sqlite3_prepare_v2(sqlite3Db, stmt,-1, &statment, NULL) == SQLITE_OK)
        {
            
            if (sqlite3_step(statment) == SQLITE_ROW)
            {
                rows = sqlite3_column_int(statment, 0);
            }
            else
            {
                EnLogd(@"ERROR IN GETTING NUMBER OF ROWS : %s",sqlite3_errmsg(sqlite3Db));
            }
        }
        
    }
    return rows;
}

@end
