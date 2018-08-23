//
//  DBTables.m
//  InstaVoice
//
//  Created by Eninov User on 17/01/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "DBTables.h"

#define BOOLTRUE    @"1"
#define BOOLFALSE   @"0"

#pragma-mark MESSAGE TABLE
@implementation MessageTable
{
    
}
-(NSMutableString*)getInsertStatement
{
    NSMutableString *insertStr = [[NSMutableString alloc] initWithString:@"INSERT OR IGNORE INTO MessageTable ("]; //NOV-14 CMP needed for avoid inserting duplicate message
    
    [insertStr appendFormat:@"%@,",LOGGEDIN_USER_ID];
    [insertStr appendFormat:@"%@,",MSG_ID];
    [insertStr appendFormat:@"%@,",MSG_GUID];
    [insertStr appendFormat:@"%@,",MSG_DATE];
    [insertStr appendFormat:@"%@,",SOURCE_APP_TYPE];
    [insertStr appendFormat:@"%@,",MSG_FLOW];
    [insertStr appendFormat:@"%@,",MSG_CONTENT_TYPE];
    [insertStr appendFormat:@"%@,",MSG_SUB_TYPE];
    [insertStr appendFormat:@"%@,",MSG_TYPE];
    [insertStr appendFormat:@"%@,",MSG_STATE];
    [insertStr appendFormat:@"%@,",REMOTE_USER_NAME];
    
    [insertStr appendFormat:@"%@,",REMOTE_USER_IV_ID];
    [insertStr appendFormat:@"%@,",FROM_USER_ID];
    
    [insertStr appendFormat:@"%@,",MSG_BASE64];
    [insertStr appendFormat:@"%@,",MSG_CONTENT];
    
    [insertStr appendFormat:@"%@,",ANNOTATION];
    [insertStr appendFormat:@"%@,",MEDIA_FORMAT];
    [insertStr appendFormat:@"%@,",DURATION];
    [insertStr appendFormat:@"%@,",MSG_PLAY_DURATION];
    [insertStr appendFormat:@"%@,",MSG_READ_CNT];
    [insertStr appendFormat:@"%@,",MSG_DOWNLOAD_CNT];
    [insertStr appendFormat:@"%@,",MSG_SIZE_LONG];
    [insertStr appendFormat:@"%@,",MSG_LOCAL_PATH];
    [insertStr appendFormat:@"%@,",LATITUDE];
    [insertStr appendFormat:@"%@,",LONGITUTE];
    [insertStr appendFormat:@"%@,",LOCATION_NAME];
    [insertStr appendFormat:@"%@,",LOCALE];
    
    [insertStr appendFormat:@"%@,",LINKED_OPR];
    [insertStr appendFormat:@"%@,",LINKED_MSG_TYPE];
    [insertStr appendFormat:@"%@,",LINKED_MSG_ID];
    [insertStr appendFormat:@"%@,",MSG_LIKED];
    [insertStr appendFormat:@"%@,",MSG_LISTENED];
    [insertStr appendFormat:@"%@,",MSG_FB_POST];
    [insertStr appendFormat:@"%@,",MSG_TW_POST];
    [insertStr appendFormat:@"%@,",MSG_VB_POST];
    [insertStr appendFormat:@"%@,",CONVERSATION_TYPE];
    [insertStr appendFormat:@"%@,",NATIVE_CONTACT_ID];
    [insertStr appendFormat:@"%@,",MSG_FORWARD];
    [insertStr appendFormat:@"%@,",REMOTE_USER_PIC];
    [insertStr appendFormat:@"%@,",REMOTE_USER_TYPE];
    [insertStr appendFormat:@"%@,",DOWNLOAD_TIME];
    [insertStr appendFormat:@"%@",CROP_REMOTE_USER_PIC];
    [insertStr appendFormat:@" ) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"];
    
    return insertStr;
}

/* ---------------Bind the data into insert query statement --------------*/
-(void)bindStatementData:(NSMutableDictionary*)dic
{
    NSString *baseStr       = BOOLFALSE;
    NSString *msgLikedStr   = BOOLFALSE;
    NSString *msgListendStr = BOOLFALSE;
    NSString *msgFBPostStr  = BOOLFALSE;
    NSString *msgTWPostStr  = BOOLFALSE;
    NSString *msgVBPostStr  = BOOLFALSE;
    NSString *msgForwordStr = BOOLFALSE;
    
    NSString *loggedInID = [dic valueForKey:LOGGEDIN_USER_ID];
    sqlite3_bind_text(statment, 1, [loggedInID UTF8String], -1, NULL);
    
    //NSString *msgID = [[NSString alloc]initWithFormat:@"%@",[dic valueForKey:MSG_ID]];
    long long int msgID = [[dic valueForKey:MSG_ID] longLongValue];
    sqlite3_bind_int64(statment, 2, msgID);
    
    NSString *msgGuid = [dic valueForKey:MSG_GUID];
    sqlite3_bind_text(statment, 3, [msgGuid UTF8String], -1, NULL);
    
    //NSString *msgDate = [[NSString alloc]initWithFormat:@"%@",[dic valueForKey:MSG_DATE]];
    long long int msgDate = [[dic valueForKey:MSG_DATE] longLongValue];
    sqlite3_bind_int64(statment, 4, msgDate);
    
    NSString *appType  = [dic valueForKey:SOURCE_APP_TYPE];
    sqlite3_bind_text(statment, 5, [appType UTF8String], -1, NULL);
    
    NSString *msgFlow = [dic valueForKey:MSG_FLOW];
    sqlite3_bind_text(statment, 6, [msgFlow UTF8String], -1, NULL);
    
    NSString *msgContentType = [dic valueForKey:MSG_CONTENT_TYPE];
    sqlite3_bind_text(statment, 7, [msgContentType UTF8String], -1, NULL);
    
    NSString *msgSubType = [dic valueForKey:MSG_SUB_TYPE];
    sqlite3_bind_text(statment, 8, [msgSubType UTF8String], -1, NULL);
    
    NSString *msgType = [dic valueForKey:MSG_TYPE];
    sqlite3_bind_text(statment, 9, [msgType UTF8String], -1, NULL);
    
    NSString *msgState = [dic valueForKey:MSG_STATE];
    sqlite3_bind_text(statment, 10, [msgState UTF8String], -1, NULL);
    
    NSString *remoteUserName = [dic valueForKey:REMOTE_USER_NAME];
    sqlite3_bind_text(statment, 11, [remoteUserName UTF8String], -1, NULL);
    
    
    /*CMP
    NSString *remoteUserIVID = [dic valueForKey:REMOTE_USER_IV_ID];
    sqlite3_bind_text(statment, 12, [remoteUserIVID UTF8String], -1, NULL);
    */
    //TODO - provide correct value type
    NSString *remoteUserIVID = [dic valueForKey:REMOTE_USER_IV_ID];
    if( [remoteUserIVID isKindOfClass:[NSNumber class]] ) {
        NSString* sTempUserIVID = [[dic valueForKey:REMOTE_USER_IV_ID] stringValue];
        sqlite3_bind_text(statment, 12, [sTempUserIVID UTF8String], -1, NULL);
    }
    else {
        sqlite3_bind_text(statment, 12, [remoteUserIVID UTF8String], -1, NULL);
    }
    
    NSString *fromUserID = [dic valueForKey:FROM_USER_ID];
    sqlite3_bind_text(statment, 13, [fromUserID UTF8String], -1, NULL);
    
    NSNumber *base = [dic valueForKey:MSG_BASE64];
    
    if([base boolValue])
    {
        baseStr = BOOLTRUE;
    }
    sqlite3_bind_text(statment, 14, [baseStr UTF8String], -1, NULL);
    
    NSString *msgContent = [dic valueForKey:MSG_CONTENT];
    sqlite3_bind_text(statment, 15, [msgContent UTF8String], -1, NULL);
    
    NSString *annotation = [dic valueForKey:ANNOTATION];
    sqlite3_bind_text(statment, 16, [annotation UTF8String], -1, NULL);
    
    NSString *mediaFormate = [dic valueForKey:MEDIA_FORMAT];
    sqlite3_bind_text(statment, 17, [mediaFormate UTF8String], -1, NULL);
    
    NSNumber *duration = [dic valueForKey:DURATION];
    sqlite3_bind_int(statment, 18, [duration integerValue]);
    
    NSNumber *msgPlayDur = [dic valueForKey:MSG_PLAY_DURATION];
    sqlite3_bind_int(statment, 19, [msgPlayDur integerValue]);
    
    NSNumber *magReadCnt = [dic valueForKey:MSG_READ_CNT];
    sqlite3_bind_int(statment, 20, [magReadCnt integerValue]);
    
    NSNumber *dwnloadCnt = [dic valueForKey:MSG_DOWNLOAD_CNT];
    sqlite3_bind_int(statment, 21, [dwnloadCnt integerValue]);
    
    NSNumber *msgSize = [dic valueForKey:MSG_SIZE_LONG];
    sqlite3_bind_int(statment, 22, [msgSize integerValue]);
    
    NSString *localPath = [dic valueForKey:MSG_LOCAL_PATH];
    sqlite3_bind_text(statment, 23, [localPath UTF8String], -1, NULL);
    
    NSString *latitude = [dic valueForKey:LATITUDE];
    sqlite3_bind_text(statment, 24, [latitude UTF8String], -1, NULL);
    
    NSString *longitute = [dic valueForKey:LONGITUTE];
    sqlite3_bind_text(statment, 25, [longitute UTF8String], -1, NULL);
    
    NSString *locationName = [dic valueForKey:LOCATION_NAME];
    sqlite3_bind_text(statment, 26, [locationName UTF8String], -1, NULL);
    
    NSString *locale = [dic valueForKey:LOCALE];
    sqlite3_bind_text(statment, 27, [locale UTF8String], -1, NULL);
    
    NSString *linkedOpr = [dic valueForKey:LINKED_OPR];
    sqlite3_bind_text(statment, 28, [linkedOpr UTF8String], -1, NULL);
    NSString *linkedMsgType = [dic valueForKey:LINKED_MSG_TYPE];
    sqlite3_bind_text(statment, 29, [linkedMsgType UTF8String], -1, NULL);
    /*NSString *linkedMSGID = [[NSString alloc]initWithFormat:@"%@",[dic valueForKey:LINKED_MSG_ID] ];
    sqlite3_bind_text(statment, 30, [linkedMSGID UTF8String], -1, NULL);*/
    long long int linkedMsgID = [[dic valueForKey:LINKED_MSG_ID] longLongValue];
    sqlite3_bind_int64(statment, 30, linkedMsgID);
    
    NSNumber *msgLiked = [dic valueForKey:MSG_LIKED];
    
    if([msgLiked boolValue])
    {
        msgLikedStr = BOOLTRUE;
    }
    sqlite3_bind_text(statment, 31, [msgLikedStr UTF8String], -1, NULL);
    
    NSNumber *msgListend = [dic valueForKey:MSG_LISTENED];
    
    if([msgListend boolValue])
    {
        msgListendStr = BOOLTRUE;
    }
    sqlite3_bind_text(statment, 32, [msgListendStr UTF8String], -1, NULL);
    
    NSNumber *msgFBPost = [dic valueForKey:MSG_FB_POST];
    
    if([msgFBPost boolValue])
    {
        msgFBPostStr = BOOLTRUE;
    }
    sqlite3_bind_text(statment, 33, [msgFBPostStr UTF8String], -1, NULL);
    
    NSNumber *msgTWPost = [dic valueForKey:MSG_TW_POST];
    
    if([msgTWPost boolValue])
    {
        msgTWPostStr = BOOLTRUE;
    }
    sqlite3_bind_text(statment, 34, [msgTWPostStr UTF8String], -1, NULL);
    
    NSNumber *msgVBPost = [dic valueForKey:MSG_VB_POST];
    
    if([msgVBPost boolValue])
    {
        msgVBPostStr = BOOLTRUE;
    }
    sqlite3_bind_text(statment, 35, [msgVBPostStr UTF8String], -1, NULL);
    
    NSString *conversationType = [dic valueForKey:CONVERSATION_TYPE];
    sqlite3_bind_text(statment, 36, [conversationType UTF8String], -1, NULL);
    
    NSString *nativecontactID = [dic valueForKey:NATIVE_CONTACT_ID];
    //CMP TODO -- provid dic value with correct data type
    if( [nativecontactID isKindOfClass:[NSNumber class]] ) {
        NSString* temp = [[NSString alloc]initWithString:[[dic valueForKey:NATIVE_CONTACT_ID] stringValue]];
        sqlite3_bind_text(statment, 37, [temp UTF8String], -1, NULL);
    } else {
        sqlite3_bind_text(statment, 37, [nativecontactID UTF8String], -1, NULL);
    }
    
    NSNumber *msgForword = [dic valueForKey:MSG_FORWARD];
    
    if([msgForword boolValue])
    {
        msgForwordStr = BOOLTRUE;
    }
    sqlite3_bind_text(statment, 38, [msgForwordStr UTF8String], -1, NULL);
    
    NSString *pic = [dic valueForKey:REMOTE_USER_PIC];
    sqlite3_bind_text(statment, 39, [pic UTF8String], -1, NULL);
    NSString *contacttype = [dic valueForKey:REMOTE_USER_TYPE];
    sqlite3_bind_text(statment, 40, [contacttype UTF8String], -1, NULL);
    
    long long int downloadTime = [[dic valueForKey:DOWNLOAD_TIME] longLongValue];
    sqlite3_bind_int64(statment, 41, downloadTime);
    
    NSString *cropPic = [dic valueForKey:CROP_REMOTE_USER_PIC];
    sqlite3_bind_text(statment, 42, [cropPic UTF8String], -1, NULL);
}

-(NSMutableDictionary*)getTableDic:(sqlite3_stmt*)stmt
{
    NSMutableDictionary *dic = nil;
    if(stmt != NULL)
    {
        dic = [[NSMutableDictionary alloc] init];
        int count = sqlite3_column_count(stmt);
        
        for (int i =0; i <count; i++)
        {
            NSString *columnName = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_name(stmt, i)];
            
            if([columnName isEqualToString:LOGGEDIN_USER_ID])
            {
                const char *loggedinChar = (const char*)sqlite3_column_text(stmt, i);
                if(loggedinChar != NULL)
                {
                    NSString *loggedinID = [[NSString alloc] initWithUTF8String:loggedinChar];
                    [dic setValue:loggedinID forKey:LOGGEDIN_USER_ID];
                }
            }
            else if ([columnName isEqualToString:MSG_ID])
            {
                long long int msgID = sqlite3_column_int64(stmt, i);
                NSNumber *num = [NSNumber numberWithLongLong:msgID];
                [dic setValue:num forKey:MSG_ID];
            }
            else if([columnName isEqualToString:DOWNLOAD_TIME])
            {
                long long int time = sqlite3_column_int64(stmt, i);
                NSNumber *num = [NSNumber numberWithLongLong:time];
                [dic setValue:num forKey:DOWNLOAD_TIME];
            }
            else if([columnName isEqualToString:REMOTE_USER_NAME])
            {
                const char *rmoteUsrNmChar = (const char*)sqlite3_column_text(stmt, i);
                if(rmoteUsrNmChar!= NULL)
                {
                    NSString *name = [[NSString alloc] initWithUTF8String:rmoteUsrNmChar];
                    [dic setValue:name forKey:REMOTE_USER_NAME];
                }
            }
            else if ([columnName isEqualToString:NATIVE_CONTACT_ID])
            {
                const char *nativeCIDChar = (const char*)sqlite3_column_text(stmt, i);
                if(nativeCIDChar != NULL)
                {
                    NSString *contactID = [[NSString alloc] initWithUTF8String:nativeCIDChar];
                    [dic setValue:contactID forKey:NATIVE_CONTACT_ID];
                }
            }
            else if ([columnName isEqualToString:REMOTE_USER_PIC])
            {
                const char *remoteUserPic = (const char*)sqlite3_column_text(stmt, i);
                if(remoteUserPic != NULL)
                {
                    NSString *pic = [[NSString alloc] initWithUTF8String:remoteUserPic];//TODO crash
                    [dic setValue:pic forKey:REMOTE_USER_PIC];
                }
            }
            else if ([columnName isEqualToString:CROP_REMOTE_USER_PIC])
            {
                const char *cropRemoteUserPic = (const char*)sqlite3_column_text(stmt, i);
                if(cropRemoteUserPic != NULL)
                {
                    NSString *pic = [[NSString alloc] initWithUTF8String:cropRemoteUserPic];
                    [dic setValue:pic forKey:CROP_REMOTE_USER_PIC];
                }
            }
            else if ([columnName isEqualToString:REMOTE_USER_TYPE])
            {
                const char *cType = (const char*)sqlite3_column_text(stmt, i);
                if(cType != NULL)
                {
                    NSString *type = [[NSString alloc] initWithUTF8String:cType];
                    [dic setValue:type forKey:REMOTE_USER_TYPE];
                }
            }
            else if ([columnName isEqualToString:MSG_GUID])
            {
                const char *msgGuidchar = (const char*)sqlite3_column_text(stmt, i);
                if(msgGuidchar != NULL)
                {
                    NSString *msgGUID = [[NSString alloc] initWithUTF8String:msgGuidchar];
                    [dic setValue:msgGUID forKey:MSG_GUID];
                }
            }
            else if ([columnName isEqualToString:MSG_DATE])
            {
                long long int date = sqlite3_column_int64(stmt, i);
                NSNumber *num = [NSNumber numberWithLongLong:date];
                [dic setValue:num forKey:MSG_DATE];
            }
            else if ([columnName isEqualToString:SOURCE_APP_TYPE])
            {
                const char *sAppTypechar = (const char*)sqlite3_column_text(stmt, i);
                if(sAppTypechar != NULL)
                {
                    NSString *sourceAppType = [[NSString alloc] initWithUTF8String:sAppTypechar];
                    [dic setValue:sourceAppType forKey:SOURCE_APP_TYPE];
                }
                
            }
            else if ([columnName isEqualToString:MSG_FLOW])
            {
                const char *msgFlowChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgFlowChar != NULL)
                {
                    NSString *msgFlow = [[NSString alloc] initWithUTF8String:msgFlowChar];
                    [dic setValue:msgFlow forKey:MSG_FLOW];
                }
            }
            else if ([columnName isEqualToString:MSG_TYPE])
            {
                const char *msgTypeChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgTypeChar != NULL)
                {
                    NSString *msgType = [[NSString alloc] initWithUTF8String:msgTypeChar];
                    [dic setValue:msgType forKey:MSG_TYPE];
                }
            }
            else if ([columnName isEqualToString:MSG_SUB_TYPE])
            {
                const char*msgsubTypeChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgsubTypeChar != NULL)
                {
                    NSString *msgSubType = [[NSString alloc] initWithUTF8String:msgsubTypeChar];
                    [dic setValue:msgSubType forKey:MSG_SUB_TYPE];
                }
            }
            else if ([columnName isEqualToString:MSG_CONTENT_TYPE])
            {
                const char *msgCTypeChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgCTypeChar != NULL)
                {
                    NSString *msgContentType = [[NSString alloc] initWithUTF8String:msgCTypeChar];
                    [dic setValue:msgContentType forKey:MSG_CONTENT_TYPE];
                }
            }
            else if ([columnName isEqualToString:MSG_STATE])
            {
                const char *msgStChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgStChar != NULL)
                {
                    NSString *msgState = [[NSString alloc] initWithUTF8String:msgStChar];
                    [dic setValue:msgState forKey:MSG_STATE];
                }
            }
            else if ([columnName isEqualToString:REMOTE_USER_IV_ID])
            {
                const char * rmtIvIDChar = (const char*)sqlite3_column_text(stmt, i);
                if(rmtIvIDChar != NULL)
                {
                    NSString *fromIvID = [[NSString alloc] initWithUTF8String:rmtIvIDChar];
                    [dic setValue:fromIvID forKey:REMOTE_USER_IV_ID];
                }
            }
            else if ([columnName isEqualToString:FROM_USER_ID])
            {
                const char *frmUsrIDChar = (const char*)sqlite3_column_text(stmt, i);
                if(frmUsrIDChar != NULL)
                {
                    NSString *fromUserID = [[NSString alloc] initWithUTF8String:frmUsrIDChar];
                    [dic setValue:fromUserID forKey:FROM_USER_ID];
                }
            }
            else if ([columnName isEqualToString:MSG_BASE64])
            {
                const char *msgBase64Char = (const char*)sqlite3_column_text(stmt, i);
                if(msgBase64Char != NULL)
                {
                    NSString *msgBase64 = [[NSString alloc] initWithUTF8String:msgBase64Char];
                    if([msgBase64 isEqualToString:@"1"])
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:YES];
                        [dic setValue:num forKey:MSG_BASE64];
                    }
                    else
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:NO];
                        [dic setValue:num forKey:MSG_BASE64];
                    }
                }
            }
            else if ([columnName isEqualToString:MSG_CONTENT])
            {
                const char *msgContentChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgContentChar != NULL)
                {
                    NSString *msgContent = [[NSString alloc] initWithUTF8String:msgContentChar];
                    [dic setValue:msgContent forKey:MSG_CONTENT];
                }
            }
            else if ([columnName isEqualToString:ANNOTATION])
            {
                const char *annotationChar = (const char*)sqlite3_column_text(stmt, i);
                if(annotationChar != NULL)
                {
                    NSString *annotation = [[NSString alloc] initWithUTF8String:annotationChar];
                    [dic setValue:annotation forKey:ANNOTATION];
                }
            }
            else if ([columnName isEqualToString:MEDIA_FORMAT])
            {
                const char *mediafrmtChar = (const char*)sqlite3_column_text(stmt, i);
                if(mediafrmtChar != NULL)
                {
                    NSString *mediaFormat = [[NSString alloc] initWithUTF8String:mediafrmtChar];
                    [dic setValue:mediaFormat forKey:MEDIA_FORMAT];
                }
            }
            else if ([columnName isEqualToString:DURATION])
            {
                int duration = sqlite3_column_int(stmt, i);
                NSNumber *num = [[NSNumber alloc] initWithInt:duration];
                [dic setValue:num forKey:DURATION];
            }
            else if ([columnName isEqualToString:MSG_PLAY_DURATION])
            {
                int playduration = sqlite3_column_int(stmt, i);
                NSNumber *num = [[NSNumber alloc] initWithInt:playduration];
                [dic setValue:num forKey:MSG_PLAY_DURATION];
            }
            else if ([columnName isEqualToString:MSG_READ_CNT])
            {
                int readCount = sqlite3_column_int(stmt, i);
                NSNumber *num = [[NSNumber alloc] initWithInt:readCount];
                [dic setValue:num forKey:MSG_READ_CNT];
            }
            else if ([columnName isEqualToString:MSG_DOWNLOAD_CNT])
            {
                int downloadCount = sqlite3_column_int(stmt, i);
                NSNumber *num = [[NSNumber alloc] initWithInt:downloadCount];
                [dic setValue:num forKey:MSG_DOWNLOAD_CNT];
                
            }
            else if ([columnName isEqualToString:MSG_SIZE_LONG])
            {
                int msgSizeLong = sqlite3_column_int(stmt, i);
                NSNumber *num = [[NSNumber alloc] initWithInt:msgSizeLong];
                [dic setValue:num forKey:MSG_SIZE_LONG];
            }
            else if ([columnName isEqualToString:MSG_LOCAL_PATH])
            {
                const char *msgLocalPathChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgLocalPathChar != NULL)
                {
                    NSString *msgLocalPath = [[NSString alloc] initWithUTF8String:msgLocalPathChar];
                    [dic setValue:msgLocalPath forKey:MSG_LOCAL_PATH];
                }
                
            }
            else if ([columnName isEqualToString:LATITUDE])
            {
                const char *latitudeChar = (const char*)sqlite3_column_text(stmt, i);
                if(latitudeChar != NULL)
                {
                    NSString *latitude = [[NSString alloc] initWithUTF8String:latitudeChar];
                    [dic setValue:latitude forKey:LATITUDE];
                }
                
            }
            else if ([columnName isEqualToString:LONGITUTE])
            {
                const char *longituteChar = (const char*)sqlite3_column_text(stmt, i);
                if(longituteChar != NULL)
                {
                    NSString *longitute = [[NSString alloc] initWithUTF8String:longituteChar];
                    [dic setValue:longitute forKey:LONGITUTE];
                }
            }
            else if ([columnName isEqualToString:LOCATION_NAME])
            {
                const char *lNmChar = (const char*)sqlite3_column_text(stmt, i);
                if(lNmChar != NULL)
                {
                    NSString *locationName = [[NSString alloc] initWithUTF8String:lNmChar];
                    [dic setValue:locationName forKey:LOCATION_NAME];
                }
            }
            else if ([columnName isEqualToString:LOCALE])
            {
                const char *localeChar = (const char*)sqlite3_column_text(stmt, i);
                if(localeChar != NULL)
                {
                    NSString *locale = [[NSString alloc] initWithUTF8String:localeChar];
                    [dic setValue:locale forKey:LOCALE];
                }
            }
            else if ([columnName isEqualToString:LINKED_OPR])
            {
                const char *linjedOprChar = (const char*)sqlite3_column_text(stmt, i);
                if(linjedOprChar != NULL)
                {
                    NSString *linkedOpr = [[NSString alloc] initWithUTF8String:linjedOprChar];
                    [dic setValue:linkedOpr forKey:LINKED_OPR];
                }
            }
            else if ([columnName isEqualToString:LINKED_MSG_TYPE])
            {
                const char *linkedMsgTypechar = (const char*)sqlite3_column_text(stmt, i);
                if(linkedMsgTypechar != NULL)
                {
                    NSString *linkedMsgType = [[NSString alloc] initWithUTF8String:linkedMsgTypechar];
                    [dic setValue:linkedMsgType forKey:LINKED_MSG_TYPE];
                }
            }
            else if ([columnName isEqualToString:LINKED_MSG_ID])
            {
                /*
                const char *linkedMsgIDChar = (const char*)sqlite3_column_text(stmt, i);
                if(linkedMsgIDChar != NULL)
                {
                    NSString *linkedMsgID = [[NSString alloc] initWithUTF8String:linkedMsgIDChar];
                    long longValue = [linkedMsgID longLongValue];
                    NSNumber *num = [[NSNumber alloc] initWithLong:longValue];
                    [dic setValue:num forKey:LINKED_MSG_ID];
                }*/
                long long int linkedMsgId = sqlite3_column_int64(stmt, i);
                NSNumber *num = [NSNumber numberWithLongLong:linkedMsgId];
                [dic setValue:num forKey:LINKED_MSG_ID];
            }
            else if ([columnName isEqualToString:MSG_LIKED])
            {
                const char *msgLikedChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgLikedChar != NULL)
                {
                    NSString *msgLiked = [[NSString alloc] initWithUTF8String:msgLikedChar];
                    if([msgLiked isEqualToString:@"1"])
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:YES];
                        [dic setValue:num forKey:MSG_LIKED];
                    }
                    else
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:NO];
                        [dic setValue:num forKey:MSG_LIKED];
                    }
                }
            }
            else if ([columnName isEqualToString:MSG_LISTENED])
            {
                const char *msgListenedChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgListenedChar != NULL)
                {
                    NSString *msgListed = [[NSString alloc] initWithUTF8String:msgListenedChar];
                    if([msgListed isEqualToString:@"1"])
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:YES];
                        [dic setValue:num forKey:MSG_LISTENED];
                    }
                    else
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:NO];
                        [dic setValue:num forKey:MSG_LISTENED];
                    }
                }
            }
            else if ([columnName isEqualToString:MSG_FB_POST])
            {
                const char *msgFBPostChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgFBPostChar != NULL)
                {
                    NSString *msgFBPost = [[NSString alloc] initWithUTF8String:msgFBPostChar];
                    if([msgFBPost isEqualToString:@"1"])
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:YES];
                        [dic setValue:num forKey:MSG_FB_POST];
                    }
                    else
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:NO];
                        [dic setValue:num forKey:MSG_FB_POST];
                    }
                }
            }
            else if ([columnName isEqualToString:MSG_TW_POST])
            {
                const char *msgTWPostChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgTWPostChar != NULL)
                {
                    NSString *msgTWPost = [[NSString alloc] initWithUTF8String:msgTWPostChar];
                    if([msgTWPost isEqualToString:@"1"])
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:YES];
                        [dic setValue:num forKey:MSG_TW_POST];
                    }
                    else
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:NO];
                        [dic setValue:num forKey:MSG_TW_POST];
                    }
                }
            }
            else if ([columnName isEqualToString:MSG_VB_POST])
            {
                const char *msgVBPostChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgVBPostChar != NULL)
                {
                    NSString *msgVBPost = [[NSString alloc] initWithUTF8String:msgVBPostChar];
                    if([msgVBPost isEqualToString:@"1"])
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:YES];
                        [dic setValue:num forKey:MSG_VB_POST];
                    }
                    else
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:NO];
                        [dic setValue:num forKey:MSG_VB_POST];
                    }
                }
            }
            else if ([columnName isEqualToString:MSG_FORWARD])
            {
                const char *msgForwrdChar = (const char*)sqlite3_column_text(stmt, i);
                if(msgForwrdChar != NULL)
                {
                    NSString *msgforward = [[NSString alloc] initWithUTF8String:msgForwrdChar];
                    if([msgforward isEqualToString:@"1"])
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:YES];
                        [dic setValue:num forKey:MSG_FORWARD];
                    }
                    else
                    {
                        NSNumber *num = [[NSNumber alloc] initWithBool:NO];
                        [dic setValue:num forKey:MSG_FORWARD];
                    }
                }
            }
            else if ([columnName isEqualToString:CONVERSATION_TYPE])
            {
                const char *cTypeChar = (const char*)sqlite3_column_text(stmt, i);
                if(cTypeChar != NULL)
                {
                    NSString *convType = [[NSString alloc] initWithUTF8String:cTypeChar];
                    [dic setValue:convType forKey:CONVERSATION_TYPE];
                }
            }
            else {//alias columns
                const char *cTypeChar = (const char*)sqlite3_column_text(stmt, i);
                if(cTypeChar != NULL)
                {
                    NSString *count = [[NSString alloc] initWithUTF8String:cTypeChar];
                    [dic setValue:count forKey:UNREAD_MSG_COUNT];
                }
            }
        }
    }
    else{
        EnLogd(@"passing statement varible is nil");
    }
    return dic;
}

@end


#pragma mark - VSMS LIMIT TABLE
@implementation VsmsLimitTable

-(NSMutableString*)getInsertStatement
{
    NSMutableString *vsmsLimit = [[NSMutableString alloc] initWithFormat:@"INSERT INTO %@ (",VSMS_LIMIT_TABLE];
    
    [vsmsLimit appendFormat:@"%@,",PHONE_NO];
    [vsmsLimit appendFormat:@"%@",BALANCE];
    [vsmsLimit appendFormat:@" ) VALUES(?,?);"];
    return vsmsLimit;
}


-(NSMutableDictionary*)getTableDic:(sqlite3_stmt*)stmt
{
    NSMutableDictionary *dic = nil;
    if(stmt != NULL)
    {
        dic = [[NSMutableDictionary alloc] init];
        int count = sqlite3_column_count(stmt);
        
        for (int i =0; i <count; i++)
        {
            NSString *columnName = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_name(stmt, i)];
            
            if ([columnName isEqualToString:PHONE_NO])
            {
                const char *phoneNumChar = (const char*)sqlite3_column_text(stmt, i);
                if(phoneNumChar != NULL)
                {
                    NSString *phoneName = [[NSString alloc] initWithUTF8String:phoneNumChar];
                    [dic setValue:phoneName forKey:PHONE_NO];
                }
            }
            else if ([columnName isEqualToString:BALANCE])
            {
                int balanceChar = sqlite3_column_int(stmt, i);
                NSNumber *num = [NSNumber numberWithInt:balanceChar];
                [dic setValue:num forKey:BALANCE];
            }
        }
    }
    return dic;
}

-(void)bindStatementData:(NSMutableDictionary*)dic
{
    NSString *phoneNum = [dic valueForKey:PHONE_NO];
    sqlite3_bind_text(statment, 1, [phoneNum UTF8String], -1, NULL);
    
    NSNumber *balance = [dic valueForKey:BALANCE];
    sqlite3_bind_int(statment, 2, [balance integerValue]);
}

@end


static DBTables * _sharedDBTables =nil;
@implementation DBTables

+(id)sharedDBTables
{
    if(_sharedDBTables == nil)
    {
        _sharedDBTables = [DBTables new];
    }
    return _sharedDBTables;
}

-(id)init
{
    if(self = [super init])
    {
        [self allDBTableInit];
    }
    return self;
}

-(void)allDBTableInit
{
    msgTableObj = [[MessageTable alloc] init];
    vsmsLimitTblObj = [[VsmsLimitTable alloc]init];
}

-(BaseDB *)getTableObj:(int)tableType
{
    BaseDB *tableObj = nil;
    switch (tableType)
    {
        case MESSAGE_TABLE_TYPE:
            tableObj = msgTableObj;
            break;
        case VSMS_LIMIT_TABLE_TYPE:
            tableObj = vsmsLimitTblObj;
            break;
        default:
            break;
    }
    return tableObj;
}


@end