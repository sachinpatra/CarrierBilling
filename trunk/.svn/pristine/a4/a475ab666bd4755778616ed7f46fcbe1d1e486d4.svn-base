//
//  CoreDataQueryOperation.m
//  InstaVoice
//
//  Created by adwivedi on 09/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "CoreDataQueryOperation.h"
#import "Logger.h"

@interface CoreDataQueryOperation()
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@end

@implementation CoreDataQueryOperation
-(id)initWithQueryType:(QueryType)queryType sharedPSC:(NSPersistentStoreCoordinator *)psc
{
    if(self = [super init])
    {
        self.sharedPSC = psc;
        self.queryType = queryType;
    }
    return self;
}

- (void)main {
    
    // Creating context in main function here make sure the context is tied to current thread.
    // init: use thread confine model to make things simpler.
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    
    switch (self.queryType) {
        case QueryTypeFetchPBContact:
        {
            NSArray* allPBContact = [self fetchPBContactFromDB];
            [self notifyResponseToMainThread:allPBContact];
        }
            break;
        default:
            break;
    }
}

-(NSArray*)fetchPBContactFromDB
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    //request.fetchBatchSize = 200;
    
    NSSortDescriptor *sortName = [[NSSortDescriptor alloc]initWithKey:@"contactName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortISIV = [[NSSortDescriptor alloc]initWithKey:@"isIV" ascending:NO];
    NSSortDescriptor *sortIsNewJoinee = [[NSSortDescriptor alloc]initWithKey:@"isNewJoinee" ascending:YES];
    [request setSortDescriptors:@[sortIsNewJoinee,sortISIV,sortName]];
    NSError *error;
    
    NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
    
    if (array == nil)
    {
        KLog(@"No Record Found");
        array = [NSArray array];
    }
    return array;
}

-(void)notifyResponseToMainThread:(id)response
{
    [self performSelectorOnMainThread:@selector(notifyResponse:) withObject:response waitUntilDone:NO];
}
-(void)notifyResponse:(id)response
{
    [self.delegate queryOperationOfType:self.queryType completedWithResponse:response];
}



@end
