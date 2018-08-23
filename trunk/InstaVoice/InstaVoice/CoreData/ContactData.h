//
//  ContactData.h
//  InstaVoice
//
//  Created by adwivedi on 18/07/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContactDetailData;

@interface ContactData : NSManagedObject

@property (nonatomic, retain) NSNumber * contactId;
@property (nonatomic, retain) NSString * contactName;
@property (nonatomic, retain) NSString * contactPic;
@property (nonatomic, retain) NSString * contactPicURI;
@property (nonatomic, retain) NSNumber * contactType;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * isInvited;
@property (nonatomic, retain) NSNumber * isIV;
@property (nonatomic, retain) NSNumber * isNewJoinee;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * localSyncTime;
@property (nonatomic, retain) NSString * picDownloadState;
@property (nonatomic, retain) NSNumber * removeFlag;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSSet *contactIdDetailRelation;
@end

@interface ContactData (CoreDataGeneratedAccessors)

- (void)addContactIdDetailRelationObject:(ContactDetailData *)value;
- (void)removeContactIdDetailRelationObject:(ContactDetailData *)value;
- (void)addContactIdDetailRelation:(NSSet *)values;
- (void)removeContactIdDetailRelation:(NSSet *)values;

@end
