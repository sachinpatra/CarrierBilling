//
//  GroupUtility.m
//  InstaVoice
//
//  Created by adwivedi on 01/09/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "GroupUtility.h"
#import "CreateGroupAPI.h"
#import "FetchGroupInfoAPI.h"
#import "TableColumns.h"
#import "Macro.h"
#import "Engine.h"
#import "ConversationApi.h"

#import "Contacts.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "GroupMemberData.h"
#import "CoreDataSetup.h"
#import "ContactSyncUtility.h"
#import "ConfigurationReader.h"
#import "IVFileLocator.h"
#import "Common.h"

#ifdef REACHME_APP
#import "AppDelegate_rm.h"
#else
#import "AppDelegate.h"
#endif

extern NSString *const kGroupDataUpdated;

@implementation GroupUtility

// 0 - privatequeue, 1 - mainqueue
-(id)initWithData:(NSInteger)contextType
{
    if(self = [super init])
    {
        _contextType = contextType;
        if(!_contextType)
            _managedObjectContext = [AppDelegate sharedPrivateQueueContext];
        else
            _managedObjectContext = [AppDelegate sharedMainQueueContext];
            
    }
    return self;
}


-(NSMutableArray*)getCreateGroupMemberDataList:(NSString*)groupId
{
    KLog(@"getCreateGroupMemberDataList START");
    
    __block NSMutableArray* allContactsFinal = [[NSMutableArray alloc]init];
    
    //[_managedObjectContext performBlockAndWait:^{//NOV 2017
        
        NSArray* groupMemberList;
        BOOL checkGroupMemberShip = FALSE;
        
        //- Get all the members for the selected groupId
        if(groupId != Nil && groupId.length > 0)
        {
            groupMemberList = [[Contacts sharedContact]getGroupMemberInfoForGroupId:groupId];
            if(groupMemberList.count > 0)
                checkGroupMemberShip = TRUE;
        }
        
        //- Get all the contacts except the celebrity, group, help & suggestion types
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactData"
                                                             inManagedObjectContext:_managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        request.fetchBatchSize = 200;
        
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"((isIV = 1) OR (isIV = 0)) AND (contactType != %d && contactType != %d && contactType != %d)",ContactTypeCelebrity,ContactTypeIVGroup,ContactTypeHelpSuggestion];
        [request setPredicate:condition];
        
        NSSortDescriptor *sortName = [[NSSortDescriptor alloc]initWithKey:@"contactName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        [request setSortDescriptors:@[sortName]];
        
        NSError *error=nil;
        NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
        if (array == nil) {
            KLog(@"No Record Found");
            array = [NSArray array];
        }
        //
        
        NSMutableArray* dataList = [[NSMutableArray alloc]init];
        NSString *groupIvID =@"g";
        NSString *ivIDFirstChar=[[NSString alloc]init];
        
        KLog(@"Prepare Unique member list - START");
        for(ContactData* data in array)
        {
            NSArray* detailDataArray = [data.contactIdDetailRelation allObjects];
            for(ContactDetailData* detail in detailDataArray)
            {
                if([detail.contactDataType isEqualToString:@"tel"]) {
                    CreateGroupMemberData* groupMember  = [[CreateGroupMemberData alloc]init];
                    groupMember.memberName = data.contactName;
                    groupMember.memberIvId = [detail.ivUserId stringValue];
                    groupMember.memberPhoneNumber = detail.contactDataValue;
                    groupMember.operationType = @"";
                    
                    if(![detail.ivUserId integerValue])
                    {
                        groupMember.memberType = @"tel";
                        groupMember.memberIvId = detail.contactDataValue;
                    }
                    else {
                        groupMember.memberType = IV_TYPE;
                    }
                    
                    groupMember.picPath = data.contactPic;
                    groupMember.memberSelected = NO;
                    
                    ivIDFirstChar=[groupMember.memberIvId substringToIndex:1];
                    if(![ivIDFirstChar isEqual:groupIvID])
                        [dataList addObject:groupMember];
                }
            }
        }
        KLog(@"Prepare Unique member list - END");
        
        NSMutableArray* dataList1 = [[NSMutableArray alloc]init];
        NSMutableArray* memberIdList = [[NSMutableArray alloc]init];
        for(GroupMemberData* grpMemberData in groupMemberList) {
            CreateGroupMemberData* groupMember  = [[CreateGroupMemberData alloc]init];
            groupMember.memberName = grpMemberData.memberDisplayName;
            groupMember.memberIvId = grpMemberData.memberId;
            groupMember.memberPhoneNumber = grpMemberData.memberContactDataValue;
            groupMember.operationType = @"a";
            groupMember.memberType = grpMemberData.memberType;
            groupMember.picPath = grpMemberData.picLocalPath;
            groupMember.memberSelected = YES;
            [dataList1 addObject:groupMember];
            [memberIdList addObject:grpMemberData.memberId];
        }
        
        NSPredicate *grpPredicate = [NSPredicate predicateWithFormat:@"NOT(SELF.memberIvId IN %@)", memberIdList];
        NSArray* result = [dataList filteredArrayUsingPredicate:grpPredicate];
        NSMutableArray* allContacts = [[NSMutableArray alloc]initWithArray:dataList1];
        
        [allContacts addObjectsFromArray:result];
        NSString *ivID=[NSString stringWithFormat: @"%ld",[[ConfigurationReader sharedConfgReaderObj]getIVUserId]];
        //TODO Discuss with Divya NSString *ivNumber=[[ConfigurationReader sharedConfgReaderObj]getFormattedUserName];
        NSString *ivNumber=[[ConfigurationReader sharedConfgReaderObj]getLoginId];
        NSMutableArray *loggedIvID=[[NSMutableArray alloc]init];
        
        if([ivNumber length])
            [loggedIvID addObject:ivNumber];
        if([ivID length])
            [loggedIvID addObject:ivID];
        
        NSMutableArray *helpSuggestion=[[NSMutableArray alloc]init];
        [helpSuggestion addObject:HELP_NUMBER];
        [helpSuggestion addObject:SUGGESTION_NUMBER];
        NSPredicate *grpPredicateFinal = [NSPredicate predicateWithFormat:@"NOT(SELF.memberIvId IN %@ OR SELF.memberPhoneNumber IN %@)",loggedIvID,helpSuggestion];
        result = [allContacts filteredArrayUsingPredicate:grpPredicateFinal];
        
        [allContactsFinal addObjectsFromArray:result];
    //}];
    
    KLog(@"getCreateGroupMemberDataList END");
    
    return allContactsFinal;
}

-(BOOL)checkIfMemberExistInGroup:(NSArray*)groupMemberList withIvId:(NSNumber*)ivUserId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberId = %@", [ivUserId stringValue]];
    NSArray *filteredArray = [groupMemberList filteredArrayUsingPredicate:predicate];
    if (filteredArray.count > 0)
        return TRUE;
    return FALSE;
}

#pragma mark -- messaging for the selected members
/*
 create_group" API should satisfy the creation of a new group with relevent request params.
 Why do we need to send member and owner details as a group event using the "send_text" API, after "create_group" API call?
 Server pushes all the complexity of group creation API to the client, which is more error prone. 
 Similiarly, "update_group" API requires the client to send the update events like leave from grp, adding/removing new members
 etc.
 
 - Event messages should be sent from the Server to all the members of the group as a result of new group creation,
   addition/deletion of member etc.
 
 TODO -- Discuss with Ajay.
 */
-(NSMutableDictionary*)createGroupMessageForGroupName:(NSString*)name groupId:(NSString*)groupId picPath:(NSString*)picPath memberList:(NSMutableArray*)memberList isNewGroup:(BOOL)isNewGroup
{
    NSMutableDictionary* currentChatUser = [[NSMutableDictionary alloc]init];
    [currentChatUser setValue:groupId forKey:FROM_USER_ID];
    [currentChatUser setValue:GROUP_TYPE forKey:CONVERSATION_TYPE];
    [currentChatUser setValue:@"0" forKey:REMOTE_USER_IV_ID];
    [currentChatUser setValue:name forKey:REMOTE_USER_NAME];
    [currentChatUser setValue:picPath forKey:REMOTE_USER_PIC];
    
    if(isNewGroup)
    {
        [[Engine sharedEngineObj]setCurrentChatUser:currentChatUser];
        NSMutableDictionary* msgDic = [self getMessageDic:[self getCreateMessageString:memberList.count]];
        [[Engine sharedEngineObj]sendMsg:msgDic];
        [currentChatUser addEntriesFromDictionary:msgDic];
        return currentChatUser;
    }
    else
    {
        for(CreateGroupMemberData* member in memberList)
        {
            NSString* msgTextString = [self getGroupUpdateMessage:member];
            [[Engine sharedEngineObj]sendMsg:[self getMessageDic:msgTextString]];
        }
    }
    return nil;
}

-(void)sendLeaveGroupMessage
{
    [[Engine sharedEngineObj]sendMsg:[self getMessageDic:[self getLeaveMessageString]]];
}

-(NSMutableDictionary*)getMessageDic:(NSString*)msgTextString
{
    NSMutableDictionary* conversationDic = [[NSMutableDictionary alloc]init];
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    NSNumber *date = [NSNumber numberWithLongLong:milliseconds];
    [conversationDic setValue:[Common getGuid] forKey:MSG_GUID];
    [conversationDic setValue:date forKey:MSG_DATE];
    [conversationDic setValue:SENDER_TYPE forKey:MSG_FLOW];
    [conversationDic setValue:TEXT_TYPE forKey:MSG_CONTENT_TYPE];
    [conversationDic setValue:msgTextString forKey:MSG_CONTENT];
    [conversationDic setValue:API_INPROGRESS forKey:MSG_STATE];
    [conversationDic setValue:IV_TYPE forKey:MSG_TYPE];
    [conversationDic setValue:GROUP_TYPE forKey:CONVERSATION_TYPE];
    [conversationDic setValue:GROUP_MSG_EVENT_TYPE forKey:MSG_SUB_TYPE];
    return conversationDic;
}


-(NSString*)getCreateMessageString:(NSUInteger)memberCount
{
    NSString* ownerContact = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
    NSString* ownerIvId = [NSString stringWithFormat:@"%ld",[[ConfigurationReader sharedConfgReaderObj]getIVUserId]];
    NSString* ownerName = [[ConfigurationReader sharedConfgReaderObj]getScreenName];
    NSMutableDictionary* msgDic = [[NSMutableDictionary alloc]init];
    
    [msgDic setValue:@"create" forKey:@"eventType"];
    
    [msgDic setValue:ownerContact forKey:@"ownerContact"];
    [msgDic setValue:ownerName forKey:@"ownerName"];
    [msgDic setValue:ownerIvId forKey:@"ownerUserId"];
    [msgDic setValue:[NSString stringWithFormat:@"%lu",(unsigned long)memberCount] forKey:@"targetContact"];
    [msgDic setValue:ownerName forKey:@"targetName"];
    [msgDic setValue:ownerIvId forKey:@"targetUserId"];
    
    NSString* msgStr = [self getMsgString:msgDic];
    return msgStr;
}

-(NSString*)getLeaveMessageString
{
    NSString* myContact = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
    NSString* myIvId = [NSString stringWithFormat:@"%ld",[[ConfigurationReader sharedConfgReaderObj]getIVUserId]];
    NSString* myName = [[ConfigurationReader sharedConfgReaderObj]getScreenName];
    NSMutableDictionary* msgDic = [[NSMutableDictionary alloc]init];
    
    [msgDic setValue:@"left" forKey:@"eventType"];
    [msgDic setValue:myContact forKey:@"ownerContact"];
    [msgDic setValue:myName forKey:@"ownerName"];
    [msgDic setValue:myIvId forKey:@"ownerUserId"];
    [msgDic setValue:myContact forKey:@"targetContact"];
    [msgDic setValue:myName forKey:@"targetName"];
    [msgDic setValue:myIvId forKey:@"targetUserId"];
    
    NSString* msgStr = [self getMsgString:msgDic];
    return msgStr;
}

-(NSString*)getGroupUpdateMessage:(CreateGroupMemberData*)member
{
    NSString* ownerContact = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
    NSString* ownerIvId = [NSString stringWithFormat:@"%ld",[[ConfigurationReader sharedConfgReaderObj]getIVUserId]];
    NSString* ownerName = [[ConfigurationReader sharedConfgReaderObj]getScreenName];
    NSMutableDictionary* msgDic = [[NSMutableDictionary alloc]init];
    if([member.operationType isEqualToString:@"d"])
        [msgDic setValue:@"deleted" forKey:@"eventType"];
    else if([member.operationType isEqualToString:@"l"])
        [msgDic setValue:@"left" forKey:@"eventType"];
    else
        [msgDic setValue:@"joined" forKey:@"eventType"];
    
    [msgDic setValue:ownerContact forKey:@"ownerContact"];
    [msgDic setValue:ownerName forKey:@"ownerName"];
    [msgDic setValue:ownerIvId forKey:@"ownerUserId"];
    [msgDic setValue:member.memberPhoneNumber forKey:@"targetContact"];
    [msgDic setValue:member.memberName forKey:@"targetName"];
    [msgDic setValue:member.memberIvId forKey:@"targetUserId"];
    
    /*
     {"eventType":"joined","ownerContact":"917259774305","ownerName":"917259774305","ownerUserId":"5076","targetContact":"918147355398","targetName":"Avneesh Dwivedi","targetUserId":"5953605"}
     */
    NSString* msgStr = [self getMsgString:msgDic];
    return msgStr;
}


-(NSString *)getMsgString:(NSMutableDictionary *)requestDic
{
    NSError *error = nil;
    NSData *jsonData = nil;
    NSString *jsonStr = @"";
    
    @try
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:requestDic options:0 error:&error];
    }
    @catch (NSException *exception)
    {
        EnLogd(@"Exception is thrown %@",exception);
        return jsonStr;
    }
    
    if(!error)
    {
        jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonStr;
}


#pragma mark -- SyncTypeGroupUpdate
/*
-(void)saveGroupDataOnMainThread {
    NSError* error = Nil;
    if([_managedObjectContext hasChanges])
    {
        KLog(@"Save the changes in group");
        @try {
            if (![_managedObjectContext save:&error]) {
                KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
                EnLogd(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
        @catch(NSException* ex) {
            KLog(@"CoreData: ERROR: couldn't save: %@", [error localizedDescription]);
            EnLogd(@"CoreData: ERROR: couldn't save: %@", [error localizedDescription]);
        }
    }
}*/

-(void)updateGroupMemberInfoFromServerResponse:(NSMutableDictionary*)groupData syncMember:(BOOL)syncMember
{
    KLog(@"update group member info -- START");
   //KLog(@"groupData = %@", groupData);
    
    //[_managedObjectContext performBlockAndWait:^{//NOV 2017
        
        NSArray* groupList = [groupData valueForKey:@"groups"];
        NSArray* selfDeletedGroupList = [groupData valueForKey:@"deleted_from_groups"];
        NSMutableArray* groupDataList = [NSMutableArray arrayWithArray:groupList];
        if(selfDeletedGroupList && selfDeletedGroupList.count > 0)
        {
            [groupDataList addObjectsFromArray:selfDeletedGroupList];
        }
        for(NSDictionary* group in groupDataList)
        {
            NSString* groupIdStr = [group valueForKey:@"group_id_str"];
            /*
            if([groupIdStr isEqualToString:@"g3979"]) {
                KLog(@"Debug");
            }*/
            
            if([self checkIfGroupAlreadyExist:groupIdStr])
            {
                KLog(@"Update the group %@", groupIdStr);
                /*
                if([groupIdStr isEqualToString:@"g3979"]) {
                    KLog(@"Debug");
                }*/
                
                [self updateGroupHeaderData:group forGroupID:groupIdStr];
            }
            else
            {
                /*
                if([groupIdStr isEqualToString:@"g3979"]) {
                    KLog(@"Debug");
                }*/
                KLog(@"create group header for %@",groupIdStr);
                [self createGroupHeaderData:group];
            }
            
            if(syncMember)
            {
                NSArray* groupUserList = [group valueForKey:@"group_user_list"];
                NSMutableArray* newMember = [[NSMutableArray alloc]init];
                for(NSDictionary* member in groupUserList)
                {
                    NSString* memberId = [member valueForKey:@"contact_id"];
                    if([self checkIfMember:memberId existInGroup:groupIdStr])
                    {
                        [self updateGroupMemberData:member withMemberId:memberId forGroupId:groupIdStr];
                    }
                    else
                    {
                        [newMember addObject:member];
                    }
                }
                if([newMember count] > 0)
                {
                    KLog(@"create group member data for %@, %@",groupIdStr,newMember);
                    [self createGroupMemberData:newMember forGroupId:groupIdStr];
                }
            }
        }
        if([groupData valueForKey:@"last_group_trno"])
        {
            NSNumber *lasttrn = [groupData valueForKey:@"last_group_trno"];
            [[ConfigurationReader sharedConfgReaderObj] setGroupUpdateLastTransNo:lasttrn];
        }
    //}];
    
    [NSNotificationCenter.defaultCenter postNotificationName:kGroupDataUpdated
                                                      object:self
                                                    userInfo:nil];
    KLog(@"update group member info -- END");
}


#pragma mark -- SyncTypeGroupUpdate -- utility implementation
-(BOOL)checkIfGroupAlreadyExist:(NSString*)groupIdStr
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"groupId = %@",groupIdStr];
    [request setPredicate:condition];
    
    /*
    if([groupIdStr isEqualToString:@"g3014"]) {
        KLog(@"Debug");
    }*/
    
    __block NSArray *array=nil;
    [_managedObjectContext performBlockAndWait:^{
       NSError *error;
       array = [_managedObjectContext executeFetchRequest:request error:&error];
    }];
    
    if (array == nil || [array count] <= 0)
    {
        return NO;
    }
    
    return YES;
}
//TODO: sometimes, createGroupHeaderData is crashing at PSC
-(void)createGroupHeaderData:(NSDictionary*)groupHeader
{
    KLog(@"groupHeader = %@",groupHeader);
    ContactData* data = [NSEntityDescription insertNewObjectForEntityForName:@"ContactData" inManagedObjectContext:_managedObjectContext];
    
    ContactDetailData* detailData = [NSEntityDescription insertNewObjectForEntityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
    
    //KLog(@"groupHeader = %@",groupHeader);
    NSString* groupName = [groupHeader valueForKey:@"subject"];
    /*
    if([groupName isEqualToString:@"Cmp1"]) {
        KLog(@"Debug");
    }*/
    
    NSString* groupIdStr = [groupHeader valueForKey:@"group_id_str"];
    NSString* strGroupId = [groupHeader valueForKey:@"group_id"];
    NSNumber* groupId = [NSNumber numberWithLongLong:[strGroupId longLongValue]];
    data.contactName = groupName;
    data.contactId = groupId;// [NSNumber numberWithLongLong:(LONG_MAX - [[groupHeader valueForKey:@"group_id"]longLongValue])];
    data.contactType = [NSNumber numberWithInteger:ContactTypeIVGroup];
    data.isIV = [NSNumber numberWithBool:YES];
    data.groupId = groupIdStr;
    data.localSyncTime = [groupHeader valueForKey:@"creation_date_long"];
    data.firstName = data.contactName;
    /*
    if([data.contactId longLongValue] == 1243174) {
        KLog(@"Debug");
    }*/
    
    /* If we had created GroupdHeader entity (like ContactData), we would not need insert the
       following dummy details into ContactDataDetail.
       TODO: Create a separate entity for Group Header data
     */
    detailData.contactId = groupId; //data.contactId;
    detailData.ivUserId = [NSNumber numberWithInt:1];//[groupHeader valueForKey:@"group_creator_userid"];
    detailData.contactDataValue = groupIdStr;
    detailData.contactDataType = PHONE_MODE;
    detailData.localSync = [NSNumber numberWithBool:YES];
    detailData.serverSync = [NSNumber numberWithBool:YES];
    
    if([groupHeader valueForKey:@"profile_pic_path"])
    {
        NSString* picUri = [NSString stringWithFormat:@"%@%@",SERVER_PIC_URL,[groupHeader valueForKey:@"profile_pic_path"]];
        data.contactPicURI = picUri;
        NSString *imgName =[data.groupId stringByAppendingPathExtension:@"jpg"];
        data.contactPic = imgName;
    }
    
    NSString* status = [groupHeader valueForKey:@"status"];
    if([status isEqualToString:@"a"])
        data.removeFlag = [NSNumber numberWithBool:NO];
    else if([status isEqualToString:@"d"])
        data.removeFlag = [NSNumber numberWithBool:YES];
    
    [data addContactIdDetailRelationObject:detailData];
    [_managedObjectContext insertObject:data];
    
    KLog(@"CreateGroupHeaderData");
    NSError* error = Nil;
    if([_managedObjectContext hasChanges])
    {
        KLog(@"Save the changes in group");
        @try {
            if (![_managedObjectContext save:&error]) {
                KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
                EnLogd(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
        @catch(NSException* ex) {
            KLog(@"CoreData: ERROR: couldn't save: %@", [error localizedDescription]);
            EnLogd(@"CoreData: ERROR: couldn't save: %@", [error localizedDescription]);
        }
    }
   
    //[self performSelectorOnMainThread:@selector(saveGroupDataOnMainThread) withObject:nil waitUntilDone:NO];
}

-(void)updateGroupHeaderData:(NSDictionary*)groupHeader forGroupID:(NSString*)groupIdStr
{
    KLog(@"groupHeader = %@",groupHeader);
    EnLogd(@"groupHeader = %@",groupHeader);
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"groupId = %@",groupIdStr];
    [request setPredicate:condition];
    
    NSError *error;
    NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
    if(array != Nil && [array count]>0)
    {
        //APR 4, 2018
        ContactData* data = array[0];
        NSString* groupName = [groupHeader valueForKey:@"subject"];
        if(groupName.length)
            data.contactName = groupName;
        NSString* existingPicUri = data.contactPicURI;
        if([groupHeader valueForKey:@"profile_pic_path"])
        {
            NSString* picUri = [NSString stringWithFormat:@"%@%@",SERVER_PIC_URL,[groupHeader valueForKey:@"profile_pic_path"]];
            if(existingPicUri && ![picUri isEqualToString:existingPicUri])
            {
                [IVFileLocator deleteFileAtPath:[IVFileLocator getNativeContactPicPath:[data.groupId stringByAppendingPathExtension:@"jpg"]]];
            }
            data.contactPicURI = picUri;
            NSString *imgName =[data.groupId stringByAppendingPathExtension:@"jpg"];
            data.contactPic = imgName;
        }
        
        NSString* status = [groupHeader valueForKey:@"status"];
        if([status isEqualToString:@"a"])
            data.removeFlag = [NSNumber numberWithBool:NO];
        else if([status isEqualToString:@"d"])
            data.removeFlag = [NSNumber numberWithBool:YES];
        //
        
        KLog(@"updateGroupHeaderData");
        if (![_managedObjectContext save:&error]) {
            KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        //[self performSelectorOnMainThread:@selector(saveGroupDataOnMainThread) withObject:nil waitUntilDone:NO];
    }
}

-(BOOL)checkIfMember:(NSString*)memberId existInGroup:(NSString*)groupIdStr
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GroupMemberData" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"groupId = %@ AND memberId = %@",groupIdStr,memberId];
    [request setPredicate:condition];
    
    NSError *error;
    NSArray *array = nil;
    @try {
         array = [_managedObjectContext executeFetchRequest:request error:&error];
    } @catch (NSException *exception) {
        EnLogd(@"Exception thrown: %@. Member ID = %ld, Group ID = %@",exception,memberId,groupIdStr);
    } @finally {
        //TODO
    }
   
    if (array == nil || [array count] <= 0)
    {
        return false;
    }
    
    return true;
}

-(void)createGroupMemberData:(NSArray*)memberList forGroupId:(NSString*)groupIdStr
{
    /*
    if([groupIdStr isEqualToString:@"g1524"]) {
        KLog(@"Debug");
    }*/
    
    for(NSDictionary* member in memberList)
    {
        /* 
         TODO: In the server's response, "phone_number" key is not present for some of the members.
         So, the client will not add those members who does not have phone numbers.
         */
        
        NSString* phoneNumber = [member valueForKey:@"phone_number"];
        if(!phoneNumber || ![phoneNumber length] ) {
            KLog(@"Why \"phone_number\" is not present in memeber details. Check with the server");
            EnLogd(@"Member (id = %@) does not have phone_number. Not added.",[member valueForKey:@"contact_id"]);
            KLog(@"Member (id = %@) does not have phone_number. Not added.",[member valueForKey:@"contact_id"]);
            continue;
        }
        
        GroupMemberData* data = [NSEntityDescription insertNewObjectForEntityForName:@"GroupMemberData" inManagedObjectContext:_managedObjectContext];
        data.groupId = groupIdStr;
        data.memberContactDataValue = [Common setPlusPrefixChatWithMobile:phoneNumber];
        
        data.isAdmin = [member valueForKey:@"is_admin"];
        data.isOwner = [member valueForKey:@"is_owner"];
        data.isAgent = [member valueForKey:@"is_agent"];
        data.isMember = [member valueForKey:@"is_member"];
        data.memberId = [member valueForKey:@"contact_id"];
        data.memberType = [member valueForKey:@"contact_type"];
        if([member valueForKey:@"display_name"] != Nil)
            data.memberDisplayName = [member valueForKey:@"display_name"];
        else
            data.memberDisplayName = data.memberContactDataValue;
        
        if([member valueForKey:@"profile_pic_path"])
        {
            data.picLocalPath = [NSString stringWithFormat:@"%@.png",data.memberId];
            data.picRemoteUri =[NSString stringWithFormat:@"%@%@",SERVER_PIC_URL,[member valueForKey:@"profile_pic_path"]];
        }
        
        NSString* status = [member valueForKey:@"status"];
        if([status isEqualToString:@"a"])
            data.status = [NSNumber numberWithInteger:GroupMemberStatusActive];
        else if([status isEqualToString:@"d"])
            data.status = [NSNumber numberWithInteger:GroupMemberStatusDeleted];
        else
            data.status = [NSNumber numberWithInteger:GroupMemberStatusLeft];
        
        [_managedObjectContext insertObject:data];
    }
    
    KLog(@"CreateGroupMemberData");
    NSError* error = Nil;
    if (![_managedObjectContext save:&error]) {
        KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    //[self performSelectorOnMainThread:@selector(saveGroupDataOnMainThread) withObject:nil waitUntilDone:NO];
}

-(void)updateGroupMemberData:(NSDictionary*)member withMemberId:(NSString*)memberId forGroupId:(NSString*)groupIdStr
{
    /*
    KLog(@"updateGroupMemberData: %@",member);
    if([[member valueForKey:@"phone_number"] isEqualToString:@"918143641035"]) {
        KLog(@"Debug");
    }*/
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GroupMemberData" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"groupId = %@ AND memberId = %@",groupIdStr,memberId];
    [request setPredicate:condition];
    
    NSError *error;
    NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
    if(array != Nil && [array count]>0)
    {
        for(GroupMemberData* data in array)
        {
            data.isAdmin = [member valueForKey:@"is_admin"];
            data.isOwner = [member valueForKey:@"is_owner"];
            data.isAgent = [member valueForKey:@"is_agent"];
            data.isMember = [member valueForKey:@"is_member"];
            data.memberType = [member valueForKey:@"contact_type"];
            
            KLog(@"======");
            KLog(@"group data = %@",data);
            KLog(@"======");
            
            if([member valueForKey:@"display_name"] != Nil)
                data.memberDisplayName = [member valueForKey:@"display_name"];
            else{
                if (data.memberDisplayName == nil)
                    data.memberDisplayName = data.memberContactDataValue;
                    
            }
            if([member valueForKey:@"profile_pic_path"])
            {
                data.picLocalPath = [NSString stringWithFormat:@"%@.png",data.memberId];
                NSString* newRemoteURI = [NSString stringWithFormat:@"%@%@",SERVER_PIC_URL,[member valueForKey:@"profile_pic_path"]];
                if(!(data.picRemoteUri && [data.picRemoteUri isEqualToString:newRemoteURI]))
                {
                    [IVFileLocator deleteFileAtPath:[IVFileLocator getNativeContactPicPath:data.picLocalPath]];
                    data.picRemoteUri =[NSString stringWithFormat:@"%@%@",SERVER_PIC_URL,[member valueForKey:@"profile_pic_path"]];
                }
            }
            
            NSString* status = [member valueForKey:@"status"];
            if([status isEqualToString:@"a"])
                data.status = [NSNumber numberWithInteger:GroupMemberStatusActive];
            else if([status isEqualToString:@"d"])
                data.status = [NSNumber numberWithInteger:GroupMemberStatusDeleted];
            else
                data.status = [NSNumber numberWithInteger:GroupMemberStatusLeft];
        }
        
        KLog(@"updateGroupMemberData");
        if (![_managedObjectContext save:&error]) {
            KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        //[self performSelectorOnMainThread:@selector(saveGroupDataOnMainThread) withObject:nil waitUntilDone:NO];
    }
}
@end


@implementation GroupEventMessage

@end

@implementation GroupApiHeader

@end

@implementation CreateGroupMemberData
-(NSString*)description
{
    return [NSString stringWithFormat:(@"Name %@, ivId %@, No %@, operationType %@, selected %d"),_memberName,_memberIvId,_memberPhoneNumber,_operationType,_memberSelected];
}

@end
