//
//  Database.h
//  InstaVoice
//
//  Created by EninovUser on 16/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBHelper.h"

#define DATABASE_NAME @"instavoice.db"

@interface Database : NSObject
{
    DBHelper *dbHelper;
    sqlite3 *sqlite3Db;
}

+(Database*)sharedDBObj;

/**
 *This function is used to create the database and Table.
 * @return : result;
 */
-(BOOL)createDatabase;


/**
 * This function is used to execute the db Query;
 */
-(BOOL)executeQuery:(sqlite3_stmt*)stmt;


-(sqlite3*)getSqlite3Obj;
-(BOOL)executeSelectQuery:(sqlite3_stmt*)stmt;


@end
