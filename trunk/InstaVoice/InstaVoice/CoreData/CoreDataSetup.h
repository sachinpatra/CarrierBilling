//
//  CoreDataSetup.h
//  InstaVoice
//
//  Created by adwivedi on 27/05/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataSetup : NSObject

+(id)sharedCoredDataSetup;
//+(void)clearCoreDataInstance;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)removeAllTables:(NSManagedObjectContext*)moc;

@end
