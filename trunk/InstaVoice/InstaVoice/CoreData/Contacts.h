//
//  Contacts.h
//  InstaVoice
//
//  Created by adwivedi on 02/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactData.h"
#import <AddressBook/AddressBook.h>

@class AppDelegate;

@interface Contacts : NSObject
{
    NSMutableArray* _ivContactList;
    NSMutableArray* _pbContactList;
    NSPersistentStoreCoordinator* _sharedStoreCoordinator;
    NSManagedObjectContext* _mainQueueContext;
    NSManagedObjectContext* _privateQueueContext;
    NSOperationQueue* _contactSyncQueue;
    NSOperationQueue* _contactPicSyncQueue;
    int _batchCountYetToBeProcessed;
    int _syncIteration;
    NSArray* _allNativeContacts;
    AppDelegate *appDelegate;
    BOOL _saveInProgress;
}

@property(atomic)NSInteger syncedPBContact;
@property(atomic)BOOL isSyncInProgress;

+(id)sharedContact;

-(void)clearTheOperations;

//Sync related functions
-(void)syncContactFromNativeContact;
-(void)syncContactFromNativeContactOnContactChange;
-(void)updateContactFromServerWithFetchFriendsAPI;
-(void)enquireAndInsertContactRecord:(NSMutableArray*)contactList;
-(void)syncPendingContactWithServer;
-(void)saveCelebrityContactList:(NSMutableArray*)contactList;

-(void)saveIVSupportContact:(NSArray*)supportContactIds;
-(NSArray*)fetchIVContactFromDB;
-(void)resetContactRelatedFlags;
-(NSInteger)getTotalContactCount:(BOOL)isIV;
-(void)downloadAndSavePicWithURL:(NSString*)picURL picPath:picPath;

-(NSArray*)getContactForPhoneNumber:(NSString*)phoneNum;
-(NSArray*)getContactForIVUserId:(NSNumber *)ivUserId usingMainContext:(BOOL)isMainContext;
-(NSArray*)getCustomContactForNewPhoneNumber:(NSString*)phoneNum;
//-(void)updateFriendsProfilePicForContact:(NSArray*)contactList ivUserId:(NSNumber*)ivUserId picUrl:picUrl;
-(NSMutableDictionary*)getContactDictionaryForChatGridScreen:(NSArray*)phoneNumList;

//Group related information
-(NSArray*)getGroupMemberInfoForGroupId:(NSString*)groupId;
-(void)updateGroupMemberInfoFromServer:(BOOL)syncDB;
-(ContactData*)getGroupHeaderForGroupId:(NSString*)groupId usingMainQueue:(BOOL)isMainQueue;
-(NSArray*)getGroupMemberDataForPhoneNumber:(NSString*)phoneNum;

-(void)deleteDuplicateCelebrityRecord;

//- Fetch User Contact
-(void)fetchSecondaryNumbers;
-(NSArray *)retrieveListOfPhoneNumbersFromABRecord:(ABRecordRef)recordRef;
-(NSArray*)getPBContactList:(NSManagedObjectContext*)moc;

@end
