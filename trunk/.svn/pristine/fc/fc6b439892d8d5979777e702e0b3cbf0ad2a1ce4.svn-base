//
//  DBHelper.m
//  InstaVoice
//
//  Created by EninovUser on 16/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "DBHelper.h"
#import "TableColumns.h"
#import "Logger.h"

@implementation DBHelper

/*
 This function is used to create the tables in Application's Database.
 */
-(BOOL)createDatabaseTables:(sqlite3*)db 
{
    //Message Table
    NSMutableString *msgTable = [self getMessageTable];
    
    if(msgTable != nil && [msgTable length] >0)
    {
        if(![self createTable:msgTable database:db])
        {
            EnLoge(@"Failed to create Message table");
           // return NO;
        }
        
        NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"CREATE INDEX messagtable_idx1 ON %@ (%@);",MESSAGE_TABLE,FROM_USER_ID];
        if(![self createTable:str database:db])
        {
            EnLoge(@"Failed to create Message table");
        }
        str = [[NSMutableString alloc] initWithFormat:@"CREATE INDEX messagtable_idx2 ON %@ (%@);",MESSAGE_TABLE,MSG_TYPE];
        if(![self createTable:str database:db])
        {
            EnLoge(@"Failed to create Message table");
        }
        
        str = [[NSMutableString alloc] initWithFormat:@"CREATE INDEX messagtable_idx3 ON %@ (%@);",MESSAGE_TABLE,MSG_DATE];
        if(![self createTable:str database:db])
        {
            EnLoge(@"Failed to create Message table");
        }
    }
    
    //VSMS Limit Table
    NSMutableString *vsmsLimitTable = [self getVsmsLimit];
    if(vsmsLimitTable != nil && [vsmsLimitTable length] >0)
    {
        if(![self createTable:vsmsLimitTable database:db])
        {
            EnLoge(@"Failed to create VSMS Limit Table");
            // return NO;
        }
    }
    return YES;
}


//This function is used to execute SQL command for creating a table.
-(BOOL)createTable:(NSMutableString*)statment database:(sqlite3*)db
{
    BOOL result = YES;
    char *errMsg = nil;
    const char *sql_stmt = [statment UTF8String] ;
    if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
    {
        EnLoge(@"Failed to create table : error : %s",errMsg);
       result = NO;
    }
    return result;
}


/*
 This function return a create Message table string
 */
-(NSMutableString*)getMessageTable
{
    NSMutableString *msgTable = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE %@(",MESSAGE_TABLE];
    [msgTable appendFormat:@"%@ TEXT,",LOGGEDIN_USER_ID];//Current logged in User.
    [msgTable appendFormat:@"%@ BIGINT,",MSG_ID];//Unique Message ID from server
    [msgTable appendFormat:@"%@ TEXT PRIMARY KEY,",MSG_GUID];//Client can set any device specific message identifier, which is stored and returned with each message
    [msgTable appendFormat:@"%@ BIGINT,",MSG_DATE];//Msg creation Date
    [msgTable appendFormat:@"%@ TEXT,",SOURCE_APP_TYPE];//AVN_REMOVE
    [msgTable appendFormat:@"%@ TEXT,",MSG_FLOW];//r”=Received, “s”=Sent
    [msgTable appendFormat:@"%@ TEXT,",MSG_CONTENT_TYPE];//“a”=Audio , “t”=Text.
    [msgTable appendFormat:@"%@ TEXT,",MSG_SUB_TYPE];
    [msgTable appendFormat:@"%@ TEXT,",MSG_TYPE];// types are "iv" "inv" "notes" "vsms" "mc" "fb" "tw" "vb" "cl"
    [msgTable appendFormat:@"%@ TEXT,",MSG_STATE];
    [msgTable appendFormat:@"%@ TEXT,",REMOTE_USER_NAME];
    
    [msgTable appendFormat:@"%@ TEXT,",REMOTE_USER_IV_ID];//Sender’s iv_user_id
    [msgTable appendFormat:@"%@ TEXT,",FROM_USER_ID];// // This can be email , phone num or fb_id
   
    [msgTable appendFormat:@"%@ BOOLEAN,",MSG_BASE64];//AVN_REMOVE This field is applicable only when￼msg_content_type=’a’ .
    [msgTable appendFormat:@"%@ TEXT,",MSG_CONTENT];//The value is Text when msg_content_type=’t’,otherwise it is URI.
   
    [msgTable appendFormat:@"%@ TEXT,",ANNOTATION];//Applicable whenr msg_content_type is other than ‘t’.
    [msgTable appendFormat:@"%@ TEXT,",MEDIA_FORMAT];//Possible values ‘a-law’ and ‘pcm’.
    [msgTable appendFormat:@"%@ INT,",DURATION];//Applicable when msg_content_type is other than ‘t’
    [msgTable appendFormat:@"%@ INT,",MSG_PLAY_DURATION];//AVN_REMOVE
    [msgTable appendFormat:@"%@ INT,",MSG_READ_CNT];//To know whether user has already read the message.
    [msgTable appendFormat:@"%@ INT,",MSG_DOWNLOAD_CNT];//AVN_REMOVE -- To know how many times this message is downloaded
    [msgTable appendFormat:@"%@ INT,",MSG_SIZE_LONG];//AVN_REMOVE
    [msgTable appendFormat:@"%@ TEXT,",MSG_LOCAL_PATH];
    [msgTable appendFormat:@"%@ TEXT,",LATITUDE];//AVN_REMOVE -- LATITUDE of the message sender
    [msgTable appendFormat:@"%@ TEXT,",LONGITUTE];//AVN_REMOVE -- LONGITUTE of the message sender
    [msgTable appendFormat:@"%@ TEXT,",LOCATION_NAME];//Location of the message sender
    [msgTable appendFormat:@"%@ TEXT,",LOCALE];//LOCALE of the message sender
    
    [msgTable appendFormat:@"%@ TEXT,",LINKED_OPR];//the possible values are "fwd" if message is a forwarded one
    [msgTable appendFormat:@"%@ TEXT,",LINKED_MSG_TYPE];//the possible values are "iv" and "vb".
    [msgTable appendFormat:@"%@ BIGINT,",LINKED_MSG_ID];
    [msgTable appendFormat:@"%@ BOOLEAN,",MSG_LIKED];
    [msgTable appendFormat:@"%@ BOOLEAN,",MSG_LISTENED];//AVN_REMOVE
    [msgTable appendFormat:@"%@ BOOLEAN,",MSG_FB_POST];
    [msgTable appendFormat:@"%@ BOOLEAN,",MSG_TW_POST];
    [msgTable appendFormat:@"%@ BOOLEAN,",MSG_VB_POST];
    [msgTable appendFormat:@"%@ TEXT,",CONVERSATION_TYPE];
    [msgTable appendFormat:@"%@ TEXT,",NATIVE_CONTACT_ID];//AVN_REMOVE
    [msgTable appendFormat:@"%@ BOOLEAN,",MSG_FORWARD];
    [msgTable appendFormat:@"%@ TEXT,",REMOTE_USER_PIC];
    [msgTable appendFormat:@"%@ TEXT,",REMOTE_USER_TYPE];
    [msgTable appendFormat:@"%@ BIGINT,",DOWNLOAD_TIME];
    [msgTable appendFormat:@"%@ TEXT",CROP_REMOTE_USER_PIC];//AVN_REMOVE
    //CMP NOV-14 [msgTable appendFormat:@"UNIQUE (%@) ON CONFLICT REPLACE",MSG_GUID];
    [msgTable appendFormat:@" );"];
    
    return msgTable;
}

-(NSMutableString*)getVsmsLimit
{
    NSMutableString *vsmsLimit = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE %@(",VSMS_LIMIT_TABLE];
    [vsmsLimit appendFormat:@"%@ TEXT,",PHONE_NO];
    [vsmsLimit appendFormat:@"%@ INT",BALANCE];
    [vsmsLimit appendFormat:@");"];
    
    return vsmsLimit;
}
@end
