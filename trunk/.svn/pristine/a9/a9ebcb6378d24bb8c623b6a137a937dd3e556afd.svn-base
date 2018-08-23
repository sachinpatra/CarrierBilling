//
//  WatchDataManager.m
//  InstaVoice
//
//  Created by adwivedi on 10/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "WatchDataManager.h"
#import "BaseDB.h"
#import "Database.h"
#import "DBTables.h"
#import "CoreDataSetup.h"

static WatchDataManager* _dataManager = nil;
@implementation WatchDataManager

-(id)init
{
    if(self = [super init])
    {
        _sharedStoreCoordinator = [[CoreDataSetup sharedCoredDataSetup]persistentStoreCoordinator];
        _managedObjectContext = [[NSManagedObjectContext alloc]init];
        [_managedObjectContext setPersistentStoreCoordinator:_sharedStoreCoordinator];
    }
    return self;
}

+(id)sharedWatchManager
{
    if(_dataManager == nil)
    {
        _dataManager = [WatchDataManager new];
        [Database sharedDBObj];//create DB Data
    }
    return _dataManager;
}

+(NSMutableArray *)getUnreadChatMessages
{
   MessageTable* msgTableObj = (MessageTable*)[[DBTables sharedDBTables] getTableObj:MESSAGE_TABLE_TYPE];
    NSMutableArray *msges = nil;
    //where msg_flow = 'r' and msg_read_cnt = 0
    NSString *whrereClause = [[NSString alloc]initWithFormat:@"WHERE MSG_FLOW = \"r\" AND MSG_READ_CNT = 0 "];
    
    msges = [msgTableObj queryTable:nil whereClause:whrereClause groupBy:@"GROUP BY FROM_USER_ID" having:nil orderBy:@"ORDER BY MSG_DATE DESC" tableType:MESSAGE_TABLE_TYPE];
    
    return msges;
}

-(NSArray*)getContactForIVUserId:(NSNumber *)ivUserId
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    request.fetchBatchSize = 200;
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"ivUserId = %@",ivUserId];
    [request setPredicate:condition];
    
    NSError *error;
    NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
    
    if (array == nil)
    {
        KLog(@"No Record Found");
        array = [NSArray array];
    }
    
    return array;
}

@end
