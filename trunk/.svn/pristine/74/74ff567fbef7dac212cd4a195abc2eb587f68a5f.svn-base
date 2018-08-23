//
//  CoreDataQueryOperation.h
//  InstaVoice
//
//  Created by adwivedi on 09/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
	QueryTypeFetchPBContact = 0,
	QueryTypeFetchDeleteAllContact
} QueryType;

@protocol CoreDataQueryOperationDelegate <NSObject>
-(void)queryOperationOfType:(QueryType)type completedWithResponse:(id)response;
@end

@interface CoreDataQueryOperation : NSOperation

@property (nonatomic)QueryType queryType;
@property (nonatomic,weak)id<CoreDataQueryOperationDelegate> delegate;
- (id)initWithQueryType:(QueryType)queryType sharedPSC:(NSPersistentStoreCoordinator *)psc;

@end
