//
//  NotificationDataManager.m
//  InstaVoice
//
//  Created by adwivedi on 16/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "NotificationDataManager.h"
#import "IVAudioLoader.h"
#import "Logger.h"

static NotificationDataManager* _dataManager = nil;
@implementation NotificationDataManager

-(id)init
{
    if(self = [super init])
    {
        NSString *archiveFilePath = [[IVAudioLoader getTempSharedDirectoryPath]stringByAppendingPathComponent:@"notification.dat"];
        @try {
            _topNotificationDataList = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];
        }
        @catch (NSException *exception) {
            KLog(@"Unable to create notification data from archive file");
        }
        
        if (_topNotificationDataList == nil) {
            _topNotificationDataList = [[NSMutableArray alloc]init];
        }
    }
    return self;
}

+(id)sharedNotificationDataManager
{
    if(_dataManager == Nil)
    {
        _dataManager = [self new];
    }
    return _dataManager;
}

-(void)addNewNotification:(NotificationData*)data
{
    BOOL existed = NO;
    for (int i = 0; i < [_topNotificationDataList count]; i++) {
        NotificationData *existingData = [_topNotificationDataList objectAtIndex:i];
        if ([data.msgId isEqualToString:existingData.msgId]) {
            existed = YES;
        }

    }
    if(_topNotificationDataList.count > 19)
        [_topNotificationDataList removeObjectAtIndex:0];
    if (!existed)
        [_topNotificationDataList addObject:data];
        
   
    
//    if(_topNotificationDataList.count > 10)
//        [_topNotificationDataList removeObjectAtIndex:0];
//    [_topNotificationDataList addObject:data];
//    
    
    [self writeDataToFile];
}

-(NSArray*)getTopNotificationDataList
{
    NSArray* reverseList = [[_topNotificationDataList reverseObjectEnumerator]allObjects];
    return reverseList;
}

-(void)writeDataToFile
{
    NSString *archiveFilePath = [[IVAudioLoader getTempSharedDirectoryPath] stringByAppendingPathComponent:@"notification.dat"];
    [NSKeyedArchiver archiveRootObject:_topNotificationDataList toFile:archiveFilePath];
}

@end
