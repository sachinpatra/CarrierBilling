//
//  WatchDataManager.h
//  InstaVoice
//
//  Created by adwivedi on 10/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface WatchDataManager : NSObject
{
    NSPersistentStoreCoordinator* _sharedStoreCoordinator;
    NSManagedObjectContext* _managedObjectContext;
}

+(id)sharedWatchManager;
+(NSMutableArray*)getUnreadChatMessages;
-(NSArray*)getContactForIVUserId:(NSNumber *)ivUserId;
@end
