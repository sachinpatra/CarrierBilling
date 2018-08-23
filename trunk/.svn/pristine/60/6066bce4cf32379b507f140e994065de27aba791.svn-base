//
//  BaseDB.h
//  InstaVoice
//
//  Created by Eninov on 02/12/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "TableColumns.h"
#import "Logger.h"

#define BEGIN_TRANSACTION  "BEGIN TRANSACTION"
#define COMMIT_TRANSACTION  "COMMIT TRANSACTION"

@class Database;

@interface BaseDB : NSObject
{
    Database* dbObj;
    sqlite3 *sqlite3Db;
    sqlite3_stmt *statment;
}

-(BOOL)insertInTable:(NSMutableArray *)dataList tableType:(int)tableType;
-(BOOL)updateTable:(NSMutableDictionary *)dic whereClause:(NSString *)whereClause tableType:(int)tableType;
-(NSMutableArray*)queryTable:(NSMutableArray*)columns whereClause:(NSString*)whereClause groupBy:(NSString*)groupBy having:(NSString*)having orderBy:(NSString*)orderBy tableType:(int)tableType;
-(BOOL)deleteFromTable:(NSString*)whereClause tableType:(int)tableType;
-(int)getRowCount:(NSString *)where tableType:(int)tableType;

-(NSMutableString *)getInsertStatement;
-(void)bindStatementData:(NSMutableDictionary *)dic;
-(NSMutableDictionary *)getTableDic:(sqlite3_stmt *)stmnt;

@end
