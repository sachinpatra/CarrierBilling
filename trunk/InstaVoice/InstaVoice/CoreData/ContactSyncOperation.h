//
//  ContactSyncOperation.h
//  InstaVoice
//
//  Created by adwivedi on 02/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactSyncUtility.h"

@protocol ContactSyncOperationDelegate <NSObject>
-(void)syncOperationOfType:(SyncType)type completedWithResponse:(NSMutableDictionary*)response;
@end


@interface ContactSyncOperation : NSOperation

@property (nonatomic)SyncType syncType;
@property (copy, readonly) NSMutableDictionary *contactData;
@property (nonatomic,strong)id data;
@property (nonatomic,weak)id<ContactSyncOperationDelegate> delegate;

- (id)initWithData:(NSMutableDictionary *)contactData syncType:(SyncType)syncType sharedPSC:(NSPersistentStoreCoordinator *)psc;

@end

