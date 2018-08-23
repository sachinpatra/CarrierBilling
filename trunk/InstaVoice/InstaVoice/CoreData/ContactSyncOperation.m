//
//  ContactSyncOperation.m
//  InstaVoice
//
//  Created by adwivedi on 02/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ContactSyncOperation.h"
#import <AddressBook/AddressBook.h>
#import "ConfigurationReader.h"
#import "EventType.h"
#import "Macro.h"
#import "ContactsApi.h"
#import "HttpConstant.h"
#import "ServerErrorMsg.h"
#import "TableColumns.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif

#import "IVFileLocator.h"
#import "Common.h"
#import "RegistrationApi.h"
#import "NotificationIds.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "ConfigurationReader.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"
#import "Setting.h"
#import "Contacts.h"

#ifndef REACHME_APP
#import "GroupUtility.h"
#import "FetchGroupUpdateAPI.h"
#endif

#import "PendingEventManager.h"
#import "NotificationBar.h"
#import "Profile.h"

@interface ContactSyncOperation()
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@end

@implementation ContactSyncOperation

-(id)initWithData:(NSMutableDictionary *)contactData syncType:(SyncType)syncType sharedPSC:(NSPersistentStoreCoordinator *)psc
{
    if(self = [super init])
    {
        _contactData = [contactData copy];
        self.sharedPSC = psc;
        self.syncType = syncType;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        // Creating context in main function here make sure the context is tied to current thread.
        // init: use thread confine model to make things simpler.
        /* CMP MAR 04,16
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
         */
        //id delegate = [[UIApplication sharedApplication]delegate];
        self.managedObjectContext = [AppDelegate sharedPrivateQueueContext];
        
        switch (self.syncType) {
            case SyncTypeInitialContactSync:
            {
                KLog(@"SyncTypeInitialContactSync");
                NSArray* allNativeContact = [self readFromNativeAddressBook];
                [_managedObjectContext performBlockAndWait:^{
                    [self initialContactSync:allNativeContact];
                }];
                allNativeContact = Nil;
            }
                break;
                
            case SyncTypeContactSyncWithServer:
            {
                KLog(@"SyncTypeContactSyncWithServer");
                [self syncContactsWithServer:self.data];
            }
                break;
                
            case SyncTypeAddressBookChangeSync:
            {
                KLog(@"SyncTypeAddressBookChangeSync");
                NSArray* allNativeContact = [self readFromNativeAddressBook];
                [_managedObjectContext performBlockAndWait:^{
                    [self updateContactDataBasedOnABChange:allNativeContact];
                }];
                //[self deleteDuplicateRecordOnABChange];
                allNativeContact = Nil;
            }
                break;
            case SyncTypeIVServerSync:
            {
                KLog(@"SyncTypeIVServerSync");
                if([self.data isKindOfClass:[EnquireIVServerResponseContact class]])
                {
                    [_managedObjectContext performBlockAndWait:^{
                         [self updateContactDataFromEnquireIVResponse:self.data];
                    }];
                }
            }
                break;
            case SyncTypeFetchFriendBasedSync:
            {
                KLog(@"SyncTypeFetchFriendBasedSync");
                NSArray *contacts = [_contactData valueForKey:API_CONTACTS];
                [_managedObjectContext performBlockAndWait:^{//NOV 2017
                    [self updateContactFromServerWithFetchFriendsAPIResponse:contacts];
                }];
            }
                break;
                
            case SyncTypeIVMsgBasedSync:
            {
                KLog(@"SyncTypeIVMsgBasedSync");
                //get contact list from response and insert it in contact.
                NSArray* contacts = [_contactData valueForKey:API_IV_CONTACT_IDS];
                [_managedObjectContext performBlockAndWait:^{//NOV 2017
                    [self insertNewContactSyncedForNewMessage:contacts];
                }];
            }
                break;
                
            case SyncTypeDeleteDuplicateIVRecord:
            {
                KLog(@"SyncTypeDeleteDuplicateIVRecord");
                [_managedObjectContext performBlockAndWait:^{ //NOV 2017
                    [self deleteDuplicateRecordOnABChange];
                }];
            }
                break;
                
            case SyncTypeGroupUpdate:
            {
                KLog(@"SyncTypeGroupUpdate");
#ifndef REACHME_APP
                [_managedObjectContext performBlockAndWait:^{
                    [self updateGroupMemberInfoFromServer:self.data];
                }];
                NSError* error = nil;
                @try {
                    if(![_managedObjectContext save:&error]) {
                        KLog(@"error:%@",error);
                    }
                } @catch(NSException* ex) {
                    KLog(@"Exception:%@",ex);
                }
#endif
            }
                break;
                
            case SyncTypeCelebrity:
            {
                KLog(@"SyncTypeCelebrity");
                [_managedObjectContext performBlockAndWait:^{
                    [self saveCelebrityContact:self.data];
                }];
            }
                break;
                
            case SyncTypeDeleteDuplicateCelebRecord:
            {
                KLog(@"SyncTypeDeleteDuplicateCelebRecord");
                [_managedObjectContext performBlockAndWait:^{
                    [self deleteDuplicateCelebrityRecord];
                }];
            }
                break;
            default:
                break;
        }
    }
}

#ifndef REACHME_APP
-(void)updateGroupMemberInfoFromServer:(NSMutableDictionary*)dataDic
{
    GroupUtility* util = [[GroupUtility alloc]initWithData:0];
    /*
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate privateQueueContext];
    */
    [util updateGroupMemberInfoFromServerResponse:dataDic syncMember:YES];
    [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidSucceedWithResponse:dataDic forPendingEventType:PendingEventTypeFetchGroupUpdates];
}
#endif


- (NSArray*)readFromNativeAddressBook
{
    KLog(@"reading from AB starts");
    CFErrorRef error = NULL;
    if( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
        [[ConfigurationReader sharedConfgReaderObj] setContactAccessPermissionFlag:TRUE];
    
    ABAddressBookRef _nativeAddressBook = ABAddressBookCreateWithOptions(NULL, &error);
    NSArray* allNativeContact = (CFBridgingRelease)(ABAddressBookCopyArrayOfAllPeople(_nativeAddressBook));
    [[ConfigurationReader sharedConfgReaderObj]setTotalContact:[NSNumber numberWithInteger:[allNativeContact count]]];
    KLog(@"reading from AB ends");
    return allNativeContact;
}


#pragma mark -- SyncTypeInitialContactSync
-(void)initialContactSync:(NSArray*)nativeContact
{
    [self deleteAllExistingRecord];
    KLog(@"Sync Start");
    EnLogd(@"Sync Start");
    NSInteger count = [nativeContact count];
    if(count == 0)
    {
        NSMutableDictionary* response = [[NSMutableDictionary alloc]init];
        [response setValue:[NSMutableArray array] forKey:kInitSyncBatchDataSync];
        [self notifyResponseToMainThread:response];
    }
    NSInteger syncedContacts = 0;
    [[Contacts sharedContact]setSyncedPBContact:0];
    for(int i=0; (i * kChunkSyncSize) < count; i++)
    {
        @autoreleasepool
        {
            int startIndex = 0 + kChunkSyncSize*i;
            NSInteger len = MIN(count-startIndex,kChunkSyncSize);
            
            NSArray* batchData = [nativeContact subarrayWithRange:NSMakeRange(startIndex, len)];
            [self saveContactInBatch:batchData];
            syncedContacts += len;
            [[Contacts sharedContact]setSyncedPBContact:syncedContacts];
        }
    }
    
    if(syncedContacts == count) {
        NSError* error;
        if (![self.managedObjectContext save:&error]) {
            KLog(@"CoreData: Error %@",[error localizedDescription]);
        }
    }
    
    NSDate *date = [NSDate date];
    long long  time = [date timeIntervalSince1970];
    [[ConfigurationReader sharedConfgReaderObj]setABLastSyncTime:[NSNumber numberWithLongLong:time]];//TODO:CMP
    [[ConfigurationReader sharedConfgReaderObj]setContactLocalSyncFlag:TRUE];
    KLog(@"Sync End");
    EnLogd(@"Sync End");
    [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];
}

-(void) notify {
    
    [self.delegate syncOperationOfType:SyncTypeContactSyncWithServer completedWithResponse:nil];
}

-(void)syncContactsWithServer:(NSArray*)batchData
{
    @autoreleasepool
    {
        [self syncContactListWithserver:batchData];
    }
}

-(void)deleteAllExistingRecord
{
    EnLogd(@"Delete all existing records");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if([items count]) {
        
        for (NSManagedObject *managedObject in items) {
            [_managedObjectContext deleteObject:managedObject];
        }
        if (![_managedObjectContext save:&error]) {
            KLog(@"CoreData: Error deleting %@ - error:%@",@"ContactData",error);
            EnLogd(@"CoreData: Error deleting %@ - error:%@",@"ContactData",error);
        }
    }
}

#pragma mark -- SyncTypeAddressBookChangeSync
-(void)updateContactDataBasedOnABChange:(NSArray*)nativeContact
{
    KLog(@"AB -- updateContactDataBasedOnABChange");
    NSMutableArray* abPendingSyncRecord = [[NSMutableArray alloc]init];
    for(int i=0;i<[nativeContact count];i++)
    {
        ABRecordRef contactPerson = (__bridge ABRecordRef)([nativeContact objectAtIndex:i]);
        NSDate *modificationDate = (__bridge_transfer NSDate *)(ABRecordCopyValue(contactPerson, kABPersonModificationDateProperty));
        long long modifyLongValue = [modificationDate timeIntervalSince1970];
        long long lastABSyncTime = [[[ConfigurationReader sharedConfgReaderObj]getABLastSyncTime]longLongValue];
        
        if(modifyLongValue > lastABSyncTime)
        {
            BOOL synRecord = YES;//FEB 23, 2017
            int contactID = ABRecordGetRecordID(contactPerson);
            NSNumber* cid = [NSNumber numberWithInt:contactID];
            
            if ([self checkForValidABContactIDInTheStore:cid]) {
                KLog(@"AB -- Duplicate record found in the Contact store for the contact ID = %@",cid);
                EnLogd(@"AB -- Duplicate record found in the Contact store for the contact ID = %@",cid);
                [self deleteContactRecordWithId:cid];
            }
            else {
                //Get the phone numbers from the contactPerson
                NSArray *listOfPhoneNumbers = [[Contacts sharedContact]retrieveListOfPhoneNumbersFromABRecord:contactPerson];
                
                if ([listOfPhoneNumbers count]) {
                    for (NSInteger i=0; i<[listOfPhoneNumbers count]; i++) {
                        
                        NSString *phoneNumberString = [listOfPhoneNumbers objectAtIndex:i];
                        NSNumber *phoneNumber = [NSNumber numberWithInteger:[[listOfPhoneNumbers objectAtIndex:0]integerValue]];
                        KLog(@"AB -- List of phone numbers =%@",phoneNumber);
                        EnLogd(@"AB -- List of phone numbers =%@",phoneNumber);
                        if ([self checkForValidABContactIDInTheStore:phoneNumber]) {
                            KLog(@"AB -- Duplicate record found in the Contact store for the phone number = %@",phoneNumber);
                            EnLogd(@"AB -- Duplicate record found in the Contact store for the phone number = %@",phoneNumber);
                            [self deleteContactRecordWithId:phoneNumber];
                        }
                        else {
                            //Retrieve the IVID.
                            //Get the contactDetail for the phonenumber.
                            ContactDetailData *detailData = [self contactDetailsDataForPhoneNumber:phoneNumberString]; //TODO crash
                            KLog(@"AB -- IV ID for the phone number %@ is = %@", phoneNumberString, detailData.ivUserId);
                            EnLogd(@"AB -- IV ID for the phone number %@ is = %@", phoneNumberString, detailData.ivUserId);
                            NSNumber *ivUserId = detailData.contactId;
                            if (ivUserId) {
                                [self deleteContactRecordWithId:ivUserId];
                                /*
                                synRecord = NO;
                                [self updateContactRecordWithId:(contactPerson)
                                                usingDetailData:detailData
                                                 AndPhoneNumber:phoneNumberString];
                                 */
                            } else {
                                //[abPendingSyncRecord addObject:[nativeContact objectAtIndex:i]];
                            }
                        }
                    }
                }
            }
            
            if(synRecord)
                [abPendingSyncRecord addObject:[nativeContact objectAtIndex:i]];
        }
    }
    
    NSInteger count = [abPendingSyncRecord count];
    for(int i=0; (i * kChunkSyncSize) < count; i++)
    {
        NSInteger startIndex = 0 + kChunkSyncSize*i;
        NSInteger len = MIN(count-startIndex,kChunkSyncSize);
        
        NSArray* batchData = [abPendingSyncRecord subarrayWithRange:NSMakeRange(startIndex, len)];
        [self saveContactInBatch:batchData];
    }
    NSDate *date = [NSDate date];
    long long  time = [date timeIntervalSince1970];
    [[ConfigurationReader sharedConfgReaderObj]setABLastSyncTime:[NSNumber numberWithLongLong:time]];
}


//{ SEP 16, 2016
- (ContactDetailData *)contactDetailsDataForPhoneNumber:(NSString *)forPhoneNumber {
    
    ContactDetailData *contactDetailsDataInfo;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"contactDataValue = %@",forPhoneNumber];
    [fetchRequest setPredicate:condition];
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];//TODO crash
    
    if ([items count]) {
        contactDetailsDataInfo = [items objectAtIndex:0];
    }
    return contactDetailsDataInfo;
}
//} SEP 16, 2016


//Added by Nivedita - To fix the issue - 8983 - Duplicate record in the friends screen
- (BOOL)checkForValidABContactIDInTheStore:(NSNumber *)contactID {
    
    BOOL isValidContactID = NO;
    //KLog(@"Duplicate Record: DeleteContactRecordWithId:%@",contactID);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"contactId = %@",contactID];
    [fetchRequest setPredicate:condition];
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if([items count]) {
        for (NSInteger i=0; i< [items count]; i++) {
            ContactData *contactDataInfo = [items objectAtIndex:i];
            if ([contactDataInfo.contactId isEqualToNumber:contactID]) {
                 isValidContactID = YES;
                break;
            }
        }
    }
    else
        isValidContactID = NO;
    
    return isValidContactID;
    
}

//FEB 23, 2017
-(void)updateContactRecordWithId:(ABRecordRef)contactPerson usingDetailData:(ContactDetailData*)detailData AndPhoneNumber:(NSString*)phoneNumber
{
 
    EnLogd(@"updateContactRecordWithId: %@",phoneNumber);
    CFTypeRef fName = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
    CFTypeRef lName = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
    NSString *firstName = (__bridge_transfer NSString *)fName;
    NSString *lastName =  (__bridge_transfer NSString *)lName;
    NSString* contactName = @"";
    
    if((firstName != nil && [firstName length]>0))
    {
        contactName = [contactName stringByAppendingFormat:@"%@ ",firstName];
    }
    if(lastName != nil && [lastName length] >0)
    {
        contactName = [contactName stringByAppendingFormat:@"%@",lastName];
    }
    
    EnLogd(@"name = %@",contactName);
    ContactData* data = detailData.contactIdParentRelation;
    NSSet* all = data.contactIdDetailRelation;
    
    BOOL updateDb = NO;
    for(ContactDetailData* obj in all)
    {
        NSString* contactDataValue =  obj.contactDataValue;
        NSString* type = obj.contactDataType; //Phone mode or email-mode
        //NSString* subtype = obj.contactDataSubType; //home,work,other..
        //NSNumber* IVUserID = obj.ivUserId;
        
        if([type isEqualToString:PHONE_MODE] && [phoneNumber isEqualToString:contactDataValue]) {
            KLog(@"contactName = %@",contactName);
            data.contactName = contactName;
            updateDb = YES;
        }
    }
    
    if(updateDb) {
        NSError *error;
        if (![_managedObjectContext save:&error]) {
            KLog(@"CoreData: Error deleting %@ - error:%@",@"ContactData",error);
            EnLogd(@"*** Failed saving db");
        }
    }
}

- (void)deleteContactRecordWithId:(NSNumber*)contactID
{
    KLog(@"DeleteContactRecordWithId : %@",contactID);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"contactId = %@",contactID];
    [fetchRequest setPredicate:condition];
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
        [_managedObjectContext deleteObject:managedObject];
    }
    if (![_managedObjectContext save:&error]) {
        KLog(@"CoreData: Error deleting %@ - error:%@",@"ContactData",error);
    }
}


#pragma mark -- SyncTypeInitialContactSync and SyncTypeAddressBookChangeSync Common
-(void)saveContactInBatch:(NSArray*)batchData
{
    NSMutableArray* contactDataList =[[NSMutableArray alloc]init];
    for(int i=0;i<[batchData count];i++)
    {
        @try {
            ABRecordRef contactPerson = (__bridge ABRecordRef)([batchData objectAtIndex:i]);
            [self setDictionaryFromABRecord:contactPerson andAddDataForServerSync:contactDataList];
        }
        @catch (NSException *exception) {
            ABRecordRef contactPerson = (__bridge ABRecordRef)([batchData objectAtIndex:i]);
            CFTypeRef fName = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            CFTypeRef lName = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *firstName = (__bridge_transfer NSString *)fName;
            NSString *lastName =  (__bridge_transfer NSString *)lName;
            
            KLog(@"Exception received while getting contact from AddressBook for contact with error name %@, reason %@, userInfo %@, for firstName %@ and lastName %@ ",exception.name,exception.reason,exception.userInfo,firstName,lastName);
            EnLogd(@"Exception received while getting contact from AddressBook for contact with error name %@, reason %@, userInfo %@, for firstName %@ and lastName %@ ",exception.name,exception.reason,exception.userInfo,firstName,lastName);
        }
    }
    
    [_managedObjectContext performBlockAndWait:^{ //NOV 2017
        NSError *error;
        if (![_managedObjectContext save:&error]) {
            KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
        }
        else
        {
            KLog(@"Save contacts into DB:%ld",[batchData count]);
            
            if(self.syncType == SyncTypeAddressBookChangeSync) {
                NSMutableDictionary* response = [[NSMutableDictionary alloc]init];
                [response setValue:contactDataList forKey:kInitSyncBatchDataSync];
                [self notifyResponseToMainThread:response];
            }
        }
    }];
}

-(void)syncContactListWithserver:(NSArray*)batchData
{
    NSMutableArray* contactDataList =[[NSMutableArray alloc]init];
    for(int i=0;i<[batchData count];i++)
    {
        @try {
            ABRecordRef contactPerson = (__bridge ABRecordRef)([batchData objectAtIndex:i]);
            [self setDictionaryForContactSync:contactPerson andAddDataForServerSync:contactDataList];
        }
        @catch (NSException *exception) {
            ABRecordRef contactPerson = (__bridge ABRecordRef)([batchData objectAtIndex:i]);
            CFTypeRef fName = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            CFTypeRef lName = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *firstName = (__bridge_transfer NSString *)fName;
            NSString *lastName =  (__bridge_transfer NSString *)lName;
            
            KLog(@"Exception received while getting contact from AddressBook for contact with error name %@, reason %@, userInfo %@, for firstName %@ and lastName %@ ",exception.name,exception.reason,exception.userInfo,firstName,lastName);
            EnLogd(@"Exception received while getting contact from AddressBook for contact with error name %@, reason %@, userInfo %@, for firstName %@ and lastName %@ ",exception.name,exception.reason,exception.userInfo,firstName,lastName);
        }
    }
    
    KLog(@"Sync contacts with server:%ld",[batchData count]);
    NSMutableDictionary* response = [[NSMutableDictionary alloc]init];
    [response setValue:contactDataList forKey:kInitSyncBatchDataSync];
    self.syncType = SyncTypeInitialContactSync;
    [self notifyResponseToMainThread:response];
}

-(void)setDictionaryForContactSync:(ABRecordRef)contactPerson andAddDataForServerSync:(NSMutableArray*)contactDataList
{
    CFTypeRef fName = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
    CFTypeRef lName = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
    
    NSString *firstName = (__bridge_transfer NSString *)fName;
    NSString *lastName =  (__bridge_transfer NSString *)lName;
    NSString *contactName = @"";
    
    if((firstName != nil && [firstName length]>0))
    {
        contactName = [contactName stringByAppendingFormat:@"%@ ",firstName];
    }
    if(lastName != nil && [lastName length] >0)
    {
        contactName = [contactName stringByAppendingFormat:@"%@",lastName];
    }
    
    NSString *contactDataValue = nil;
    
    BOOL detailExist = NO;
    
    ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
    if(phones != NULL)
    {
        NSInteger phoneCount = ABMultiValueGetCount(phones);
        for (int k = 0; k <phoneCount ; k++)
        {
            NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, k);
            
            NSCharacterSet* set = [NSCharacterSet characterSetWithCharactersInString:@"*#;,"];
            NSRange range = [phone rangeOfCharacterFromSet:set];
            if(range.location != NSNotFound)
            {
                continue;
            }
            
            NSString *phoneLabel = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phones, k));
            if(phoneLabel == Nil)
                phoneLabel = @"";
            
            NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
            NSString *countryIsdCode = [[ConfigurationReader sharedConfgReaderObj]getCountryISD];
            NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCode];
            
            NSError *anError = nil;
            NBPhoneNumber *myNumber = [phoneUtil parse:phone
                                         defaultRegion:countrySimIso error:&anError];
            
            if (anError == nil)
            {
                // Should check error
                if(![phoneUtil isValidNumber:myNumber])
                {
                    if (![phoneUtil isPossibleNumber:myNumber error:nil])
                    {
                        //discard it
                        continue;
                    }
                    else
                    {
                        // possible but not valid
                        NSString *numberE164format = [phoneUtil format:myNumber
                                                          numberFormat:NBEPhoneNumberFormatE164
                                                                 error:&anError];
                        if(numberE164format && numberE164format.length > 7)
                            contactDataValue = [Common removePlus:numberE164format];
                        else
                            contactDataValue  = [Common getCanonicalPhoneNumber:phone];
                    }
                }
                else
                {
                    //valid
                    NSString *numberE164format = [phoneUtil format:myNumber
                                                      numberFormat:NBEPhoneNumberFormatE164
                                                             error:&anError];
                    contactDataValue = [Common removePlus:numberE164format];
                }
            }
            else
            {
                continue;
            }
            
            if([contactDataValue length] < 8)
            {
                continue;
            }
            detailExist = YES;
            
            if(contactName == nil || [contactName length] == 0)
            {
                contactName = contactDataValue;
            }
            [contactDataList addObject:contactDataValue];
        }
        CFRelease(phones);
    }
}

-(void)setDictionaryFromABRecord:(ABRecordRef)contactPerson andAddDataForServerSync:(NSMutableArray*)contactDataList
{
    [_managedObjectContext performBlockAndWait:^{//NOV 2017
        ContactData* data = [NSEntityDescription insertNewObjectForEntityForName:@"ContactData" inManagedObjectContext:_managedObjectContext];
        
        CFTypeRef fName = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
        CFTypeRef lName = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
        CFTypeRef modifyDate = (ABRecordCopyValue(contactPerson, kABPersonModificationDateProperty));
        
        NSString *firstName = (__bridge_transfer NSString *)fName;
        NSString *lastName =  (__bridge_transfer NSString *)lName;
        NSString *contactName = @"";
        
        
        if((firstName != nil && [firstName length]>0))
        {
            contactName = [contactName stringByAppendingFormat:@"%@ ",firstName];
            data.firstName = firstName;
        }
        if(lastName != nil && [lastName length] >0)
        {
            contactName = [contactName stringByAppendingFormat:@"%@",lastName];
            data.lastName = lastName;
        }
        
        int contactID = ABRecordGetRecordID(contactPerson);
        NSNumber *cidNum = [NSNumber numberWithInt:contactID];
        data.contactId = cidNum;
        
        
        NSString *imgName =[NSString stringWithFormat:@"%d.png",contactID];
        //NSMutableString *fullPath = [[NSMutableString alloc]init];
        //NSString* imgPath = [IVFileLocator createDeviceContactImgDir];
        //[fullPath appendString:imgPath];
        //[fullPath appendString:imgName];
        data.contactPic = imgName;
        
        NSDate *modificationDate = (__bridge_transfer NSDate *)modifyDate;
        long long int datelongValue = [modificationDate timeIntervalSince1970];
        NSNumber *date = [NSNumber numberWithLongLong:datelongValue];
        data.localSyncTime = date;
        
        NSString *contactDataValue = nil;
        
        BOOL detailExist = NO;
        
        ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
        if(phones != NULL)
        {
            NSInteger phoneCount = ABMultiValueGetCount(phones);
            for (int k = 0; k <phoneCount ; k++)
            {
                NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, k);
                
                NSCharacterSet* set = [NSCharacterSet characterSetWithCharactersInString:@"*#;,"];
                NSRange range = [phone rangeOfCharacterFromSet:set];
                if(range.location != NSNotFound)
                {
                    continue;
                }
                
                NSString *phoneLabel = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phones, k));
                if(!phoneLabel.length) {
                    phoneLabel = @"phone";//TODO - CMP why "phone" label is not returned, when a contact is saved from recent call list
                }
                
                int detailID = ABMultiValueGetIdentifierAtIndex(phones, k);
                NSNumber *detailIDNum = [NSNumber numberWithInt:detailID];
                
                NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
                NSString *countryIsdCode = [[ConfigurationReader sharedConfgReaderObj]getCountryISD];
                NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCode];
                
                /*
                 //SEP 13, 2016
                 NSString* nationalNumber = nil;
                 NSNumber* countryCode = [phoneUtil extractCountryCode:phone nationalNumber:&nationalNumber];
                 NSString* strCountryCode = [countryCode stringValue];
                 if([countryCode integerValue]>0) {
                 countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:strCountryCode];
                 }
                 //
                 */
                
                NSError *anError = nil;
                NBPhoneNumber *myNumber = [phoneUtil parse:phone defaultRegion:countrySimIso error:&anError];
                
                /*DEBUG
                 if([phone containsString:@"89919"]) {
                 KLog(@"Debug");
                 }
                 */
                
                if (anError == nil)
                {
                    // Should check error
                    if(![phoneUtil isValidNumber:myNumber])
                    {
                        if (![phoneUtil isPossibleNumber:myNumber error:nil])
                        {
                            //discard it
                            continue;
                        }
                        else
                        {
                            // possible but not valid
                            NSString *numberE164format = [phoneUtil format:myNumber
                                                              numberFormat:NBEPhoneNumberFormatE164
                                                                     error:&anError];
                            
                            if(numberE164format && numberE164format.length > 7)
                                contactDataValue = [Common removePlus:numberE164format];
                            else
                                contactDataValue  = [Common getCanonicalPhoneNumber:phone];
                        }
                    }
                    else
                    {
                        //valid
                        NSString *numberE164format = [phoneUtil format:myNumber
                                                          numberFormat:NBEPhoneNumberFormatE164
                                                                 error:&anError];
                        contactDataValue = [Common removePlus:numberE164format];
                    }
                }
                else
                {
                    continue;
                }
                
                if([contactDataValue length] < 8)
                {
                    continue;
                }
                detailExist = YES;
                ContactDetailData* detailData = [NSEntityDescription insertNewObjectForEntityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
                //KLog(@"### DD = %@",contactDataValue);
                detailData.contactDataValue = contactDataValue;
                detailData.contactDataId = detailIDNum;
                detailData.contactDataType = PHONE_MODE;
                detailData.contactId = cidNum;
                detailData.contactDataSubType = phoneLabel;
                
                /*
                 if([contactDataValue containsString:@"8892724917"]) {
                 KLog(@"Debug");
                 }*/
                
                if(contactName == nil || [contactName length] == 0)
                {
                    //FEB 17, 2017 contactName = contactDataValue;
                }
                [data addContactIdDetailRelationObject:detailData];
                [contactDataList addObject:contactDataValue];
            }
            CFRelease(phones);
        }
        
        ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
        if(emails != NULL)
        {
            NSInteger emailCount = ABMultiValueGetCount(emails);
            for (int j = 0; j < emailCount ; j++)
            {
                contactDataValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                if(![Common isValidEmail:contactDataValue])
                    continue;
                
                detailExist = YES;
                ContactDetailData* detailData = [NSEntityDescription insertNewObjectForEntityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
                
                NSString *emailLabel = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(emails, j));
                if(emailLabel == Nil) {
                    emailLabel = @"";
                }
                else {
                    KLog(@"emailLabel = %@",emailLabel);
                }
                
                int detailID = ABMultiValueGetIdentifierAtIndex(emails, j);
                //KLog(@"### DD = %@",contactDataValue);
                detailData.contactDataValue = contactDataValue;
                detailData.contactDataId = [NSNumber numberWithInteger:detailID];
                detailData.contactDataType = EMAIL_MODE;
                detailData.contactDataSubType = emailLabel;
                detailData.contactId = cidNum;
                detailData.localSync = [NSNumber numberWithBool:YES];
                detailData.serverSync = [NSNumber numberWithBool:YES];
                if(contactName == nil || [contactName length] == 0)
                {
                    //FEB 21, 2017 contactName = contactDataValue;
                }
                [data addContactIdDetailRelationObject:detailData];
            }
            CFRelease(emails);
        }
        data.contactName = contactName;
        if(detailExist)
            [_managedObjectContext insertObject:data];
        else
            [_managedObjectContext deleteObject:data]; //TODO: CMP
    
        }];
}

#pragma mark -- SyncTypeIVServerSync
-(void)updateContactDataFromEnquireIVResponse:(EnquireIVServerResponseContact*)data
{
    
    //for(NSString* contactData in data.pbListSynced)
    {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"contactDataValue in %@",data.pbListSynced];
        [request setPredicate:condition];
    
        NSError *error;
        NSArray* array = [_managedObjectContext executeFetchRequest:request error:&error];
    
        for(ContactDetailData* data in array)
        {
            data.serverSync = [NSNumber numberWithBool:YES];
        }
    }

    NSError* error = nil;
    if (![_managedObjectContext save:&error]) {
        KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    for (NSMutableDictionary* ivData in data.ivListFromResponse){
        NSString *ivUserId = [ivData valueForKey:API_IV_USER_ID];
        long long ivID = [ivUserId longLongValue];
        NSString *contactId = [ivData valueForKey:API_CONTACT_ID];
        NSString *picUri = [ivData valueForKey:API_PIC_URI];
        NSString* displayName = [ivData valueForKey:API_DISPLAY_NAME];
        
        //Debug
        /*
        if([contactId containsString:@"9980078452"]) {
            KLog(@"Debug");
        }
        if([contactId containsString:@"8892724917"] || ivID == 1243174 ) {
            KLog(@"Debug");
        }*/
        
        if(ivID > 0)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSPredicate* condition = [NSPredicate predicateWithFormat:@"contactDataValue = %@",contactId];
            [request setPredicate:condition];
            
            NSError *error;
            NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
            
            for(ContactDetailData* data in array)
            {
                data.serverSync = [NSNumber numberWithBool:YES];
                data.ivUserId = [NSNumber numberWithLongLong:ivID];
                /*
                 if(ivID == 1243174) {
                 KLog(@"Debug");
                 }*/
                
                data.contactIdParentRelation.isIV = [NSNumber numberWithBool:YES];
                if(picUri)
                {
                    data.contactIdParentRelation.contactPicURI = picUri;
                    NSString *imgName =[NSString stringWithFormat:@"%d.png",[data.ivUserId intValue]];
                    //NSMutableString *fullPath = [[NSMutableString alloc]init];
                    //NSString* imgPath = [IVFileLocator createDeviceContactImgDir];
                    //[fullPath appendString:imgPath];
                    //[fullPath appendString:imgName];
                    data.contactIdParentRelation.contactPic = imgName;
                }
                if([data.contactIdParentRelation.contactName length] < 1)
                {
                    if(displayName)
                    {
                        KLog(@"contactName = %@",displayName);
                        data.contactIdParentRelation.contactName = displayName;
                        data.contactIdParentRelation.firstName = displayName;
                    }
                }
            }
        }
    }
    if (![_managedObjectContext save:&error]) {
        KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
    }
//DEC 29[self notifyResponseToMainThread:Nil];
}

#pragma mark -- SyncTypeFetchFriendBasedSync
-(void)updateContactFromServerWithFetchFriendsAPIResponse:(NSArray*)contacts
{
    KLog(@"updateContactFromServerWithFetchFriendsAPIResponse :%@", contacts);
    //Start: Nivedita - Maintaining the array to hold the new joinees to Instavoice - as per the requirement we need to show the notifictaion for the same.
    NSMutableArray *latestJoineeList;
    //End:Nivedita
    for(NSMutableDictionary* contactDic in contacts)
    {
        NSString *contactID = [contactDic valueForKey:API_CNT_ID]; //phone num or email id
        NSDictionary *trDate = [contactDic valueForKey:API_TR_DATE];
        NSNumber *ivIDNum = [contactDic valueForKey:API_IVUSER_ID];
        long long ivIdLong = [ivIDNum longLongValue];
        long long joinDate = 0;
        if(trDate != nil && [trDate count] > 0)
        {
            NSNumber *day = [trDate valueForKey:API_DAY];
            NSNumber *month = [trDate valueForKey:API_MONTH];
            NSNumber *year  = [trDate valueForKey:API_YEAR];
            NSNumber *hour  = [trDate valueForKey:API_HOUR];
            NSNumber *min   = [trDate valueForKey:API_MIN];
            NSNumber *sec = [trDate valueForKey:API_SEC];
            NSDate *joinDur = [Common getDateAndTimeInMiliSec:[year intValue] month:[month intValue] dateOfMonth:[day intValue] hourOfDay:[hour intValue] minute:[min intValue] second:[sec intValue]];
            joinDate = ([joinDur timeIntervalSince1970] * 1000);
        }
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"contactDataValue = %@",contactID];
        [request setPredicate:condition];
        
        NSError *error;
        NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
        
        if(array && [array count])
            latestJoineeList = [[NSMutableArray alloc]init];
        if(ivIdLong > 0)
        {
            for(ContactDetailData* data in array)
            {
                NSString* picURI = [contactDic valueForKey:API_PIC_URI];
                if([data.ivUserId longLongValue] == ivIdLong)
                {
                    //existing iv only image change
                    if(picURI != Nil && picURI.length > 0)
                    {
                        NSString* fileName = data.contactIdParentRelation.contactPic;
                        EnLogd(@"fileName = %@", fileName);
                        [IVFileLocator deleteFileAtPath:[IVFileLocator getNativeContactPicPath:fileName]];
                    }
                }
                else
                {
                    //new joinee
                    data.ivJoinedTime = [NSNumber numberWithLongLong:joinDate];
                    data.ivUserId = [NSNumber numberWithLongLong:ivIdLong];
                    data.contactIdParentRelation.isIV = [NSNumber numberWithBool:YES];
                    data.contactIdParentRelation.isNewJoinee = [NSNumber numberWithBool:YES];
                    
                    //Add new joinee details in an array of latetsJoineeList.
                    [latestJoineeList addObject:data];
                    //[[Contacts sharedContact]getAllContactsForIVUserId:data.ivUserId];//FEB 23, 2017
                    //NSLog(@"Debug");
                }
                
                //Contact Pic
                if(picURI != nil)
                {
                    data.contactIdParentRelation.contactPicURI = picURI;//TODO crash
                    NSString *imgName =[NSString stringWithFormat:@"%lld.png",[data.ivUserId longLongValue]];
                    data.contactIdParentRelation.contactPic = imgName;
                }
                //display name update only in case of contact not in address book.
                NSString* displayName = [contactDic valueForKeyPath:API_DISPLAY_NAME];
                if(data.contactIdParentRelation.contactType.integerValue == ContactTypeMsgSyncContact && displayName.length)
                {
                    KLog(@"contactName = %@",displayName);
                    data.contactIdParentRelation.contactName = displayName;
                    data.contactIdParentRelation.firstName = displayName;
                }
            }
        }
        else
        {
            for(ContactDetailData* data in array)
            {
                data.ivJoinedTime = [NSNumber numberWithLongLong:0];
                data.ivUserId = [NSNumber numberWithLongLong:0];
                data.contactIdParentRelation.isIV = [NSNumber numberWithBool:NO];
                data.contactIdParentRelation.isNewJoinee = [NSNumber numberWithBool:NO];
                /*TODO
                if([contactID isEqualToString:data.contactDataValue]) {
                    KLog(@"delete object:%@",data.contactDataValue);
                    EnLogd(@"delete object:%@",data.contactDataValue);
                    [_managedObjectContext deleteObject:data];
                }*/
            }
        }
    }
    NSError* error = Nil;
    if (![_managedObjectContext save:&error]) {
        KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
    }
    else {
        //Check do we have new joinee exists, if so send the notification - Local
        if(latestJoineeList && [latestJoineeList count]) {
            
            NSMutableArray* additionalNumberList = [[NSMutableArray alloc] initWithArray:[Profile sharedUserProfile].profileData.additionalVerifiedNumbers];
            
            for (int i=0; i<[latestJoineeList count]; i++) {
                
                ContactDetailData *latestJoineeInfo = [latestJoineeList objectAtIndex:i];
                
                /* Donot display the "joined" notification, if secondary number is added
                   TODO: Check if server is sending event update for all devices logged-in with the same number.
                         Otherwise info will not be the same.
                */
                /*
                if([self isSecondaryNumber:latestJoineeInfo.contactDataValue]) {
                    KLog(@"Debug");
                    continue;
                }*/
                
                NSString* contact = latestJoineeInfo.contactDataValue;
                if([self isSecondary:contact inTheList:additionalNumberList]) {
                    KLog(@"The newly added secondary number synched with server.%@",contact);
                    EnLogd(@"The newly added secondary number synched with server.%@",contact);
                    continue;
                }
            
                NSString *displayMessage = [NSString stringWithFormat:@"%@ has joined", latestJoineeInfo.contactIdParentRelation.contactName];
                
                //Create a Notification dictionary.
                NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc]init];
                
                NSMutableDictionary *apsDictionary = [[NSMutableDictionary alloc]init];
                
                //Alert Dictionary
                NSMutableDictionary * alertDictionary = [[NSMutableDictionary alloc]init];
                
                NSDictionary *bodyDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:displayMessage, @"body", nil];
                
                [alertDictionary setObject:bodyDictionary forKey:@"alert"];
                [apsDictionary setObject:alertDictionary forKey:@"alert"];
                [apsDictionary setObject:@"1" forKey:@"badge"];
                [apsDictionary setObject:@"ivMsg" forKey:@"category"];
                [apsDictionary setObject:@"default" forKey:@"sound"];
                [apsDictionary setObject:@"1" forKey:@"content-available"];
                
                [notificationDictionary setObject:apsDictionary forKey:@"aps"];
                [notificationDictionary setObject:kNewJoineeMessageType forKey:@"msg_type"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self displayNewJoineeInNotificationBar:displayMessage withPayLoad:notificationDictionary];
                });
            }
        }
    }
}

-(BOOL)isSecondaryNumber:(NSString*)phoneNumber {
    
    NSArray* phoneNumberList = [Profile sharedUserProfile].profileData.additionalVerifiedNumbers;
    for(NSDictionary* dic in phoneNumberList) {
        NSString* contactId = [dic valueForKey:API_CONTACT_ID];
        if([contactId isEqualToString:phoneNumber])
            return TRUE;
    }
    
    return FALSE;
}

- (void)displayNewJoineeInNotificationBar:(NSString *)withMessage withPayLoad:(NSDictionary *)withInfoDictionary {
    
    [NotificationBar notifyWithText:@"InstaVoice" detail:withMessage
                              image:[UIImage imageNamed:@"launcher_Icon"]
                        andDuration:3.0 msgPayLoad:withInfoDictionary];
    
}

-(BOOL)isSecondary:(NSString*)number inTheList:(NSArray*)secondaryNumberList
{
    if([number length] && [secondaryNumberList count]) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"contact_id like %@",number];
        NSArray* result = [secondaryNumberList filteredArrayUsingPredicate:predicate];
        return ([result count]);
    }
    
    return NO;
}


#pragma mark -- SyncTypeIVMsgBasedSync
-(void)insertNewContactSyncedForNewMessage:(NSArray*)contactList
{
    NSMutableArray* contactListSynced = Nil;
    if([self.data isKindOfClass:[NSArray class]])
        contactListSynced = [NSMutableArray arrayWithArray:self.data];
    
    //Get IV IDs of Help and Suggestions
    NSArray* supportContactList = [Setting sharedSetting].supportContactList;
    NSMutableArray* ividList = [[NSMutableArray alloc]init];
    
    for(NSDictionary* dic in supportContactList) {
        NSString* ivid = [dic valueForKey:SUPPORT_IV_ID];
        if(ivid && [ivid length])
           [ividList addObject:[NSNumber numberWithLongLong:[ivid longLongValue]]];
    }
    //
    
    for(NSMutableDictionary* ivData in contactList)
    {
        NSString *ivUserId = [ivData valueForKey:API_IV_USER_ID];
        long long ivID = [ivUserId longLongValue];
        NSString *contactId = [ivData valueForKey:API_CONTACT_ID];
        NSString *picUri = [ivData valueForKey:API_PIC_URI];
        NSString* displayName = [ivData valueForKey:API_DISPLAY_NAME];
        
        /* DEBUG
        if([contactId containsString:@"9986"] || ivID == 1243174 ) {
            KLog(@"Debug");
        }*/
        
        if(![self checkAndUpdateRecord:ivData])
        {
            ContactData* data = [NSEntityDescription insertNewObjectForEntityForName:@"ContactData" inManagedObjectContext:_managedObjectContext];
            
            //July 26, 2016
            if([ividList containsObject:[NSNumber numberWithLongLong:ivID]]) {
                KLog(@"Help and Suggestions");
                data.contactType = [NSNumber numberWithInteger:ContactTypeHelpSuggestion];
            }
            else
                data.contactType = [NSNumber numberWithInteger:ContactTypeMsgSyncContact];
           
            
            if(displayName != Nil && displayName.length > 0)
            {
                KLog(@"contactName = %@",displayName);
                //FEB 21, 2017
                if([displayName isEqualToString:contactId] && [self isNumber:displayName]) {
                    KLog(@"contactId and displayName are equal -- %@:%@",contactId, displayName);
                }//
                else {
                    data.contactName = displayName;
                    data.firstName = displayName;
                }
            }
            else
                data.contactName = contactId;
            
            ContactDetailData* detailData = [NSEntityDescription insertNewObjectForEntityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
            detailData.contactDataValue = contactId;
            detailData.contactDataType = PHONE_MODE;
            detailData.localSync = [NSNumber numberWithBool:YES];
            detailData.serverSync = [NSNumber numberWithBool:YES];
            
            if(ivID > 0)
            {
                data.isIV = [NSNumber numberWithBool:YES];
                detailData.ivUserId = [NSNumber numberWithLongLong:ivID];
                
                data.contactId = [NSNumber numberWithLongLong:ivID];
                detailData.contactId = [NSNumber numberWithLongLong:ivID];
            }
            else
            {
                KLog(@"Not an IV user");
                data.contactId = [NSNumber numberWithLongLong:[contactId longLongValue]];
                detailData.contactId = [NSNumber numberWithLongLong:[contactId longLongValue]];
            }
            if(picUri)
            {
                data.contactPicURI = picUri;
                NSString *imgName =[NSString stringWithFormat:@"%lld.png",[data.contactId longLongValue]];
                data.contactPic = imgName;
            }
            [data addContactIdDetailRelationObject:detailData];
            [_managedObjectContext insertObject:data];
            [contactListSynced removeObject:contactId];
        }
    }
    
    /*
    contactListSynced has all the numbers sent to the server.
    contactList has all the ivuser id for the sent numbers.
     */
    if([contactListSynced count] && ![contactList count]) {
        KLog(@"Insert new Contact for the synced phone number(s):%@",contactListSynced);
        for(NSString* contactPB in contactListSynced) {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entityDescription];
            
            NSPredicate* condition = [NSPredicate predicateWithFormat:@"contactDataValue == %@",contactPB];
            [request setPredicate:condition];
            
            NSError *error;
            NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
            if(![array count]) {
                ContactData* data = [NSEntityDescription insertNewObjectForEntityForName:@"ContactData" inManagedObjectContext:_managedObjectContext];
                ContactDetailData* detailData = [NSEntityDescription insertNewObjectForEntityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
                data.contactName = contactPB;
                data.contactId = [NSNumber numberWithLongLong:[contactPB longLongValue]];
                data.contactType = [NSNumber numberWithInteger:ContactTypeMsgSyncContact];
                detailData.contactId = [NSNumber numberWithLongLong:[contactPB longLongValue]];
                detailData.contactDataValue = contactPB;
                detailData.contactDataType = PHONE_MODE;
                detailData.localSync = [NSNumber numberWithBool:YES];
                detailData.serverSync = [NSNumber numberWithBool:YES];
                
                [data addContactIdDetailRelationObject:detailData];
                [_managedObjectContext insertObject:data];
            }
           // NSLog(@"Debug");
        }
    }
    
    NSError* error = Nil;
    if (![_managedObjectContext save:&error]) {
        KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
    }
    else {
        if([contactListSynced count]>0) {
            [self notifyResponseToMainThread:_contactData];//TODO sometimes makes indefinite loop
        }
    }
}

-(BOOL)isNumber:(NSString*)text
{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber* number = [numberFormatter numberFromString:text];
    
    if (number != nil)
        return TRUE;
    
    return FALSE;
}

/* 
 Returns FALSE, if contact record does not exist.
 Otherwise returns TRUE
 */
-(BOOL)checkAndUpdateRecord:(NSDictionary*)ivData
{
    __block BOOL retValue = FALSE;
    NSString *ivUserId = [ivData valueForKey:API_IV_USER_ID];
    long long ivID = [ivUserId longLongValue];
    if(ivID > 0)
    {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"ivUserId = %@",ivUserId];
        [request setPredicate:condition];
        
        [_managedObjectContext performBlockAndWait:^{//NOV 2017
            
            NSError *error;
            NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
            
            NSString *contactId = [ivData valueForKey:API_CONTACT_ID];
            for(ContactDetailData* existingDetailData in array)
            {
                if(![existingDetailData.contactDataValue isEqualToString:contactId])
                {
                    KLog(@"IF: exs name = %@, existing contactDataValue = %@, contactId = %@",[ivData valueForKey:API_DISPLAY_NAME], existingDetailData.contactDataValue,contactId);
                    
                    //JUNE 3, 2016
                    ContactType contactType = (ContactType)[[existingDetailData.contactIdParentRelation contactType]intValue];
                    if(ContactTypeCelebrity == contactType) {
                        continue;
                    }
                    //
                    
                    ContactDetailData* detailData = [NSEntityDescription insertNewObjectForEntityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
                    detailData.contactDataValue = contactId;
                    detailData.contactDataType = PHONE_MODE;
                    detailData.localSync = [NSNumber numberWithBool:YES];
                    detailData.serverSync = [NSNumber numberWithBool:YES];
                    
                    detailData.ivUserId = [NSNumber numberWithLongLong:ivID];
                    detailData.contactId = [NSNumber numberWithLongLong:ivID];
                    /*
                     if([detailData.ivUserId longLongValue] == 1243174) {
                     KLog(@"Debug");
                     }*/
                    
                    [existingDetailData.contactIdParentRelation addContactIdDetailRelationObject:detailData];
                    NSError* error = Nil;
                    if(![_managedObjectContext save:&error])
                    {
                        EnLoge(@"Error adding detail");
                    }
                    //FEB 6 return true;
                } else {
                    KLog(@"ELSE: existingDetailData.contactDataValue = %@, contactId = %@",existingDetailData.contactDataValue,contactId);
                }
                retValue = TRUE;
                break;
            }
        }];
    }
    
    return retValue;
}

#pragma mark -- SyncTypeDeleteDuplicateIVRecord
-(void)deleteDuplicateRecordOnABChange
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSSortDescriptor *sortPhoneNum = [[NSSortDescriptor alloc]initWithKey:@"contactDataValue" ascending:YES];
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"ivUserId > 0"];
    [request setPredicate:condition];
    [request setSortDescriptors:@[sortPhoneNum]];
    
    NSError *error;
    NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableArray* duplicateRecord = [[NSMutableArray alloc]init];
    ContactDetailData* record = Nil;
    NSString* phoneNum = @"";
    BOOL added = false;
    for(ContactDetailData* detail in array)
    {
        if([detail.contactDataValue isEqualToString:phoneNum])
        {
            if(!added)
            {
                ContactData* data = detail.contactIdParentRelation;
                if([data.contactType integerValue] == ContactTypeMsgSyncContact)
                {
                    [duplicateRecord addObject:data.contactId];
                    added = true;
                }
                data = record.contactIdParentRelation;
                if([data.contactType integerValue] == ContactTypeMsgSyncContact)
                {
                    [duplicateRecord addObject:data.contactId];
                    added = true;
                }
            }
        }
        else
        {
            added = false;
            record = detail;
            phoneNum = detail.contactDataValue;
        }
    }
    
    if ([duplicateRecord count]) {
        KLog(@"Duplicate Records:%@",duplicateRecord);
        for(NSNumber* contactId in duplicateRecord)
        {
            [self deleteContactRecordWithId:contactId];
        }
    }
}

#pragma mark -- SyncTypeCelebrity

-(void)saveCelebrityContact:(NSMutableArray*)contactList
{
    KLog(@"Save celeb contact -- START"); //JUNE 10, 2016
    
    for(NSMutableDictionary* dicCelebrity in contactList)
    {
        if(![[dicCelebrity valueForKey:REMOTE_USER_TYPE] isEqualToString:CELEBRITY_TYPE]) continue;
        
        NSString *ivUserId = [dicCelebrity valueForKey:REMOTE_USER_IV_ID];
        long long ivID = [ivUserId longLongValue];
        
        if(ivID > 0 && ![self isContactDataAvailableWith:ivUserId])
        {
            ContactData* data = [NSEntityDescription insertNewObjectForEntityForName:@"ContactData" inManagedObjectContext:_managedObjectContext];
            
            NSNumber* ivIDNum = [NSNumber numberWithLongLong:ivID];
            data.contactId = ivIDNum;
            data.contactType = [NSNumber numberWithInteger:ContactTypeCelebrity];
            data.isIV = [NSNumber numberWithBool:YES];
            
            NSString* displayName = [dicCelebrity valueForKey:REMOTE_USER_NAME];
            if(displayName != Nil && displayName.length > 0)
            {
                KLog(@"contactName=%@",displayName);
                data.contactName = displayName;
                data.firstName = displayName;
            }
            else
                data.contactName = [dicCelebrity valueForKey:FROM_USER_ID];
            
            NSString *picUri = [dicCelebrity valueForKey:REMOTE_USER_PIC];
            if(picUri)
            {
                data.contactPicURI = picUri;
                NSString *imgName =[NSString stringWithFormat:@"%lld.png",[data.contactId longLongValue]];
                data.contactPic = imgName;
            }
            
            ContactDetailData* detail = [NSEntityDescription insertNewObjectForEntityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
            /*
            if([ivIDNum longLongValue] == 1243174) {
                KLog(@"Debug");
            }*/
            
            detail.ivUserId = ivIDNum;
            detail.contactId = ivIDNum;
            detail.contactDataValue = [dicCelebrity valueForKey:FROM_USER_ID];
            detail.contactDataType = PHONE_MODE;
            detail.localSync = [NSNumber numberWithBool:YES];
            detail.serverSync = [NSNumber numberWithBool:YES];
            
            //KLog(@"### DD = %@",detail.contactDataValue);
            [data addContactIdDetailRelationObject:detail];
            [_managedObjectContext insertObject:data];
        }
    }
    
    NSError* error = Nil;
    if(![_managedObjectContext save:&error]) {
        KLog(@"CoreData: Couldn't save celebrity contact: %@", [error localizedDescription]);
    }
    
    KLog(@"Save celeb contact -- END"); //JUNE 10, 2016
}

-(BOOL)isContactDataAvailableWith:(NSString*)ivUserID
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"ivUserId = %@",ivUserID];
    [request setPredicate:condition];
    
    NSError *error;
    NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
    if([array count]) {
        return YES;
    }
    
    return NO;
}

-(void)deleteDuplicateCelebrityRecord
{
    KLog(@"Delete duplicate celeb record -- START"); //JUNE 10,2016
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"contactType = %@",[NSNumber numberWithInteger:ContactTypeCelebrity]];
    [fetchRequest setPredicate:condition];
    NSSortDescriptor *sortContactId = [[NSSortDescriptor alloc]initWithKey:@"contactId" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortContactId]];
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    EnLogd(@"Celeb Record Count = %d",items.count);
    EnLoge(@"Celeb Record Count = %d",items.count);
    long contactId = 0;
    for (ContactData *celebData in items) {
        if(contactId == [celebData.contactId longValue])
        {
            [_managedObjectContext deleteObject:celebData];
        }
        else
        {
            contactId = [celebData.contactId longValue];
        }
    }
    if (![_managedObjectContext save:&error]) {
        KLog(@"CoreData: Error deleting %@ - error:%@",@"ContactData",error);
    }
    
    KLog(@"Delete duplicate celeb record -- END"); //JUNE 10,2016
}

#pragma mark -- Response notification to main thread
-(void)notifyResponseToMainThread:(NSMutableDictionary*)response
{
    [self performSelectorOnMainThread:@selector(notifyResponse:) withObject:response waitUntilDone:NO];
}

-(void)notifyResponse:(NSMutableDictionary*)response
{
    [self.delegate syncOperationOfType:self.syncType completedWithResponse:response];
}

@end
