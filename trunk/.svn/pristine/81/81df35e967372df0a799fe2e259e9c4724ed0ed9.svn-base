//
//  CoreDataSetup.m
//  InstaVoice
//
//  Created by adwivedi on 27/05/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "CoreDataSetup.h"
#import "Logger.h"

static CoreDataSetup* sharedInstance = nil;
@implementation CoreDataSetup

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


-(id)init
{
    if(self = [super init])
    {
        
    }
    return self;
}

+(id)sharedCoredDataSetup
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       sharedInstance = [CoreDataSetup new];
    });
    
    return  sharedInstance;
}

/* NOV 2017
+(void)clearCoreDataInstance
{
    if(sharedInstance != nil)
    {
        sharedInstance = Nil;
    }
}*/

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            KLog(@"CoreData: Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ContactModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

//CMP
- (void)removeFiles:(NSRegularExpression*)regex inPath:(NSString*)path {
    NSDirectoryEnumerator *filesEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    
    NSString *file;
    NSError *error;
    while (file = [filesEnumerator nextObject]) {
        NSUInteger match = [regex numberOfMatchesInString:file
                                                  options:0
                                                    range:NSMakeRange(0, [file length])];
        
        if (match) {
            [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
        }
    }
}
//

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ContactModel.sqlite"];
    
    //CMP
    /*
    NSError* error1 = nil;
    BOOL bError = [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error1];
    if(!bError ) {
        KLog(@"removeItemAtURL: %@",error1);
    }
    
    NSError* error1 = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"ContactModel.*"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error1];
    [self removeFiles:regex inPath:NSHomeDirectory()];
    */
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        KLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //NOV 2017 [self removeAllTables];
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/*
 NSManagedObjectContext* context = [[CoreDataSetup sharedCoredDataSetup]managedObjectContext];
 ContactData* contactData = [NSEntityDescription insertNewObjectForEntityForName:@"ContactData" inManagedObjectContext:context];
 contactData.contactId = [NSNumber numberWithInt:1];
 contactData.contactName = @"Avneesh";
 NSError *error;
 if (![context save:&error]) {
 KLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
 }
*/

#ifdef FEB_8_2017
-(void)removeAllTables
{
    NSError * error;
    // retrieve the store URL
    NSURL * storeURL = [[self.managedObjectContext persistentStoreCoordinator] URLForPersistentStore:[[[self.managedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    [self.managedObjectContext lock];
    [self.managedObjectContext reset];//to drop pending changes
    //delete the store from the current managedObjectContext
    if ([[self.managedObjectContext persistentStoreCoordinator] removePersistentStore:[[[self.managedObjectContext persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        NSError* error1 = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"ContactModel.*"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error1];
        [self removeFiles:regex inPath:NSHomeDirectory()];
        //recreate the store like in the  appDelegate method
        [[self.managedObjectContext persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
    }
    [self.managedObjectContext unlock];
    //that's it !
}
#endif

//FEB 8, 2017
-(void)removeAllTables:(NSManagedObjectContext*)moc
{
    [moc performBlockAndWait:^{ //NOV 2017
        
        // retrieve the store URL
        NSURL * storeURL = [[moc persistentStoreCoordinator] URLForPersistentStore:[[[moc persistentStoreCoordinator] persistentStores] lastObject]];
        
        @synchronized (moc) {
            [moc reset];//to drop pending changes
            NSError * error;
            //delete the store from the current managedObjectContext
            if ([[moc persistentStoreCoordinator] removePersistentStore:[[[moc persistentStoreCoordinator] persistentStores] lastObject] error:&error])
            {
                // remove the file containing the data
                [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
                NSError* error1 = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"ContactModel.*"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error1];
                [self removeFiles:regex inPath:NSHomeDirectory()];
                //recreate the store like in the  appDelegate method
                [[moc persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
            }
        }
    }];
    //that's it !
}

//


@end
