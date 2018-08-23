//
//  Contacts.m
//  InstaVoice
//
//  Created by adwivedi on 02/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "Contacts.h"
#import "CoreDataSetup.h"
#import "ContactSyncOperation.h"
#import "EnquireIVUsersAPI.h"
#import "ContactsApi.h"
#import <AddressBook/AddressBook.h>
#import "ContactSyncSavePicOperation.h"
#import "FetchContactsAPI.h"
#import "Macro.h"
#import "ContactsApi.h"
#import "ConfigurationReader.h"
#import "ContactSyncUtility.h"
#import "Profile.h"

#ifndef REACHME_APP
#import "FetchGroupUpdateAPI.h"
#import "GroupUtility.h"
#endif

#import "ServerErrorMsg.h"
//Move this to some other file
#import "ContactData.h"
#import "ContactDetailData.h"
#import "IVFileLocator.h"
#import "ContactsApi.h"
#import "RegistrationApi.h"
#import "UIDataMgt.h"
#import "Engine.h"
#import "TableColumns.h"
#import "PendingEventManager.h"
#import "Common.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "ChatGridViewController.h"
    #import "AppDelegate.h"
#endif

#import "Logger.h"
#import "FetchUserContactAPI.h"
#import "Setting.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"
#import "ScreenUtility.h"

@interface Contacts() <ContactSyncOperationDelegate,ContactPicSyncOperationDelegate>

@end


static Contacts* _sharedContactObj = nil;

@implementation Contacts

-(id)init
{
    if(self = [super init])
    {
        _mainQueueContext = [AppDelegate sharedMainQueueContext];
        _privateQueueContext = [AppDelegate sharedPrivateQueueContext];
        
        _contactSyncQueue = [[NSOperationQueue alloc]init];
        _contactSyncQueue.maxConcurrentOperationCount = 1;
        _contactPicSyncQueue = [[NSOperationQueue alloc]init];
        _contactPicSyncQueue.maxConcurrentOperationCount = 1;
        _ivContactList = [[NSMutableArray alloc]init];
        _pbContactList = [[NSMutableArray alloc]init];
        _batchCountYetToBeProcessed = 0;
        
        _syncIteration = 0;
        _allNativeContacts = nil;
        _isSyncInProgress = NO;
        _saveInProgress = NO;
        [self registerExternalChangeAddressBook];
        appDelegate = (AppDelegate *)APP_DELEGATE;
    }
    return self;
}

+(id)sharedContact
{
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        _sharedContactObj = [Contacts new];
        
    });
    return _sharedContactObj;
}

/*
+(void)clearSharedContact
{
    KLog(@"ClearSharedContact");
    if(_sharedContactObj != Nil) {
        _sharedContactObj = Nil;
    }
}*/

-(void)resetContactRelatedFlags
{
    _syncedPBContact = 0;
    [[ConfigurationReader sharedConfgReaderObj] setContactSyncPermissionFlag:FALSE];
    [[ConfigurationReader sharedConfgReaderObj] setContactServerSyncFlag:FALSE];
    [[ConfigurationReader sharedConfgReaderObj] setContactLocalSyncFlag:FALSE];
    [[ConfigurationReader sharedConfgReaderObj] setContactPermissionAlertFlag:NO];
    [[ConfigurationReader sharedConfgReaderObj] setContactAccessPermissionFlag:FALSE];
    [[ConfigurationReader sharedConfgReaderObj]removeValueForKey:CONFG_FB_LAST_FETCH_TIME];
    [[ConfigurationReader sharedConfgReaderObj]removeValueForKey:CONFG_AB_LAST_SYNC_TIME];
    [[ConfigurationReader sharedConfgReaderObj]removeValueForKey:LAST_MSG_UPDATE_FROM_CONTACT_TIME];
    [[ConfigurationReader sharedConfgReaderObj]removeValueForKey:CONFG_TOTAL_IV_CONTACT];
    [[ConfigurationReader sharedConfgReaderObj]removeValueForKey:CONFG_TOTAL_CONTACT];
    [[ConfigurationReader sharedConfgReaderObj]removeValueForKey:CONFG_LAST_TRNO];
    [[ConfigurationReader sharedConfgReaderObj]removeValueForKey:CONFG_GROUP_UPDATE_LAST_TRANS_NO];
    
    [_contactSyncQueue cancelAllOperations];
    [_contactPicSyncQueue cancelAllOperations];
    _batchCountYetToBeProcessed = 0;
    _saveInProgress = NO;//NOV 2017
}

-(void)clearTheOperations {
    KLog(@"Clear the operations - Contact sync Q and Pic sync Q");
    EnLogd(@"Clear the operations - Contact sync Q and Pic sync Q");
    _allNativeContacts = 0;
    _syncedPBContact = 0;
    [_contactSyncQueue cancelAllOperations];
    [_contactPicSyncQueue cancelAllOperations];
    //_isSyncInProgress = NO;
}

-(int)registerExternalChangeAddressBook
{
    int result = 0;
    CFErrorRef error = NULL;
    ABAddressBookRef addessBook = ABAddressBookCreateWithOptions(NULL, &error);
    if(addessBook != nil)
    {
        KLog(@"Registering for addressbook change");
        ABAddressBookRegisterExternalChangeCallback(addessBook, addressBookDataChanged, (__bridge void *)(self));
        result = 1;
    }
    return result;
}

void addressBookDataChanged(ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
    KLog1(@"AB -- addressBookDataChanged");
    [[Contacts sharedContact] syncContactFromNativeContactOnContactChange];
    
#ifndef REACHME_APP
    //TODO
    int uiCurrentType = [[UIStateMachine sharedStateMachineObj]getCurrentUIType];
    if(CHAT_GRID_SCREEN == uiCurrentType) {
        BaseUI* curUI = [[UIStateMachine sharedStateMachineObj]getCurrentUI];
        ChatGridViewController* vc = (ChatGridViewController*) curUI;
        if([vc respondsToSelector:@selector(clearSearch)]) {
            KLog1(@"AB -- Debug");
            [vc clearSearch];
        }
    }
#endif
    
    KLog1(@"Address book changed");
    EnLogd(@"Address book changed");
}

-(void)raiseABEntryChangeNotification
{
    KLog(@"AB -- raiseABEntryChangeNotification");
    [[NSNotificationCenter defaultCenter]postNotificationName:kNewABRecordNotification object:nil];
}


#pragma mark - Contact operations
-(void)syncContactFromNativeContact
{
    if(!_saveInProgress) {
        ContactSyncOperation* op = [[ContactSyncOperation alloc]initWithData:Nil syncType:SyncTypeInitialContactSync sharedPSC:_sharedStoreCoordinator];
        op.delegate = self;
        [[ConfigurationReader sharedConfgReaderObj]setClearAddressBookFlag:true];
        [_contactSyncQueue addOperation:op];
        _saveInProgress=YES;
    } else {
        KLog(@"Contacts-save operation is in progress");
        EnLogd(@"Contacts-save operation is in progress");
    }
}

-(void)syncContactFromNativeContactOnContactChange
{
    KLog(@"AB -- syncContactFromNativeContactOnContactChange");
    if(![self checkIfOperationAlreadyExistForABChange])
    {
        [[ConfigurationReader sharedConfgReaderObj]setABChangeSynced:NO];//SEP 27, 2016
        ContactSyncOperation* op = [[ContactSyncOperation alloc]initWithData:Nil syncType:SyncTypeAddressBookChangeSync sharedPSC:_sharedStoreCoordinator];
        op.delegate = self;
        [_contactSyncQueue addOperation:op];
    } else {
        KLog(@"AB -- syncContactFromNativeContactOnContactChange -- Operation is already in progress");
    }
}

-(BOOL)checkIfOperationAlreadyExistForABChange
{
    for(NSOperation* op in [_contactSyncQueue operations])
    {
        if([op isKindOfClass:[ContactSyncOperation class]])
        {
            if([(ContactSyncOperation*)op syncType] == SyncTypeAddressBookChangeSync)
                return true;
        }
    }
    return false;
}

-(void)updateContactFromServerWithFetchFriendsAPI
{
    KLog(@"updateContactFromServerWithFetchFriendsAPI");
    NSMutableDictionary *fetchContactDic = [[NSMutableDictionary alloc] init];
    FetchContactsAPI* api = [[FetchContactsAPI alloc]initWithRequest:fetchContactDic];
    [api callNetworkRequest:fetchContactDic withSuccess:^(FetchContactsAPI *req, NSMutableDictionary *responseObject) {
        EnLoge(@"ContactSync. Response:%@",responseObject);
        NSNumber *lasttrn = [responseObject valueForKey:API_LAST_TRNO];
        [[ConfigurationReader sharedConfgReaderObj] setLast_trno:lasttrn];
        NSArray *contacts = [responseObject valueForKey:API_CONTACTS];
        if([contacts count] > 0)
        {
            //AVN_TO_DO -- check for better way
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(mergeChangedData:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:nil];
            ContactSyncOperation* op = [[ContactSyncOperation alloc]initWithData:responseObject syncType:SyncTypeFetchFriendBasedSync sharedPSC:_sharedStoreCoordinator];
            [_contactSyncQueue addOperation:op];
        }
        [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidSucceedWithResponse:responseObject forPendingEventType:PendingEventTypeFetchContact];
        
    } failure:^(FetchContactsAPI *req, NSError *error) {
        [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidFailWithError:error forPendingEventType:PendingEventTypeFetchContact];
    }];
}

-(void)enquireAndInsertContactRecord:(NSMutableArray*)contactList
{
    KLog(@"enquireAndInsertContactRecord");
    NSMutableDictionary* req = [[NSMutableDictionary alloc]init];
    [req setValue:contactList forKey:API_CONTACT_IDS];
    EnquireIVUsersAPI* api = [[EnquireIVUsersAPI alloc]initWithRequest:req];
    [api callNetworkRequest:req withSuccess:^(EnquireIVUsersAPI *req, NSMutableDictionary *responseObject) {
        //AVN_TO_DO -- check for better way
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mergeChangedData:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
        EnLoge(@"ContactSync. Response:%@ for List %@",responseObject,contactList);
        ContactSyncOperation* op = [[ContactSyncOperation alloc]initWithData:responseObject syncType:SyncTypeIVMsgBasedSync sharedPSC:_sharedStoreCoordinator];
        op.data = contactList;
        op.delegate = self;
        [_contactSyncQueue addOperation:op];
    } failure:^(EnquireIVUsersAPI *req, NSError *error) {
        KLog(@"ContactSync. Error:%@ for List %@",error,contactList);
        EnLoge(@"ContactSync. Error:%@ for List %@",error,contactList);
    }];
}

-(void)getIVUserFromServerForList:(NSMutableArray*)contactList
{
    if(![[ConfigurationReader sharedConfgReaderObj]getContactSyncPermissionFlag]) {
        KLog(@"No contact sync permission. returns.");
        return;
    }
    
    if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE) {
     //TODO Save synced data status
        [ScreenUtility showAlert:@"Network is not connected."];
        KLog(@"Network is not connected. returns.");
        return;
    }
    
    KLog(@"getIVUserFromServerForList: %@",contactList);
    
    NSMutableDictionary* req = [[NSMutableDictionary alloc]init];
    [req setValue:contactList forKey:API_CONTACT_IDS];
    EnquireIVUsersAPI* api = [[EnquireIVUsersAPI alloc]initWithRequest:req];
    [api callNetworkRequest:req withSuccess:^(EnquireIVUsersAPI *req, NSMutableDictionary *responseObject) {
        EnLoge(@"EnquireIVUsersAPI Response:%@ for List %@",responseObject,contactList);
        KLog(@"EnquireIVUsersAPI Response:%@ for the list %@",responseObject,contactList);
        //KLog(@"ContactSync Response received for List %@",contactList);
        ContactSyncOperation* op = [[ContactSyncOperation alloc]initWithData:Nil syncType:SyncTypeIVServerSync sharedPSC:_sharedStoreCoordinator];
        EnquireIVServerResponseContact* data = [[EnquireIVServerResponseContact alloc]init];
        data.ivListFromResponse = [responseObject valueForKey:API_IV_CONTACT_IDS];
        data.pbListSynced = contactList;
        op.data = data;
        op.delegate = self;
        [_contactSyncQueue addOperation:op];
        _batchCountYetToBeProcessed = _batchCountYetToBeProcessed - 1;
        
        [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];
        
    } failure:^(EnquireIVUsersAPI *req, NSError *error) {
        _batchCountYetToBeProcessed = _batchCountYetToBeProcessed - 1;
        //TODO : how to retry?
        KLog(@"EnquireIVUsersAPI failed with the error = %@, for the list %@", error, contactList);
        EnLoge(@"EnquireIVUsersAPI failed with the error = %@,  for the list %@",error,contactList);
        EnLoge(@"ContactSync Error:%@ for List %@",error,contactList);
        if([Common isNetworkAvailable] == NETWORK_NOT_AVAILABLE) {
            //TODO Save synced data status
            [ScreenUtility showAlert:@"Network is not connected."];
            return;
        }
    }];
}

-(void)notify {
    [self syncOperationOfType:SyncTypeContactSyncWithServer completedWithResponse:nil];
}

-(NSArray*)getUnsyncedContactList
{
    if(![[ConfigurationReader sharedConfgReaderObj]getContactLocalSyncFlag]) {
        //TODO check
        //KLog(@"Contact local sync was not done.");
        EnLogd(@"Contact local sync was not done.");
        return 0;
    }
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_mainQueueContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"serverSync = 0"];
    [request setPredicate:condition];
    request.propertiesToFetch = [NSArray arrayWithObjects:@"contactDataValue", nil];
    
    NSError *error;
    NSArray *array = nil;
    @try {
        array = [_mainQueueContext executeFetchRequest:request error:&error];
    } @catch(NSException* ex) {
        EnLogd(@"*** Exception occurred:%@",ex);
    }
    
    NSMutableArray* pendingSyncList = [[NSMutableArray alloc]init];
    for(ContactDetailData* detail in array)
    {
        [pendingSyncList addObject:detail.contactDataValue];
    }
    return pendingSyncList;
}

-(void)syncPendingContactWithServer
{
    if(![[ConfigurationReader sharedConfgReaderObj]getContactSyncPermissionFlag]) {
        KLog(@"syncPendingContactWithServer: ContactSynPermissionFalg is false");
        return;
    }
    
    [Contacts sharedContact];
    
    if(![[ConfigurationReader sharedConfgReaderObj]getContactLocalSyncFlag]) {
        return;
    }
    
    if(![[ConfigurationReader sharedConfgReaderObj]getContactServerSyncFlag] && !_isSyncInProgress) {
        
        //KLog(@"clearing the pending operations: %ld",[_contactSyncQueue operationCount]);
        EnLogd(@"clearing the pending operations: %ld",[_contactSyncQueue operationCount]);
        [self clearTheOperations];
        
        [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];
    }
}

-(void)deleteDuplicateRecordForIV
{
    ContactSyncOperation* op = [[ContactSyncOperation alloc]initWithData:Nil syncType:SyncTypeDeleteDuplicateIVRecord sharedPSC:_sharedStoreCoordinator];
    op.delegate = self;
    [_contactSyncQueue addOperation:op];
}


#pragma mark - Contact operations completion handling
-(void)syncOperationOfType:(SyncType)type completedWithResponse:(NSMutableDictionary *)response
{
    if(type == SyncTypeInitialContactSync || type == SyncTypeAddressBookChangeSync)
    {
        NSMutableArray* contactList = [response valueForKey:kInitSyncBatchDataSync];
        _syncedPBContact = _syncedPBContact + [contactList count];
        if(type == SyncTypeAddressBookChangeSync)
        {
            KLog(@"AB -- Contacts:syncOperationOfType SyncTypeAddressBookChangeSync");
            [self loadAndSaveABChangedPic:contactList];
            KLog(@"Calling getIVUserFromServerForList...");
            [self getIVUserFromServerForList:contactList];
            [self raiseABEntryChangeNotification];
        }
        else
        {
            _batchCountYetToBeProcessed = _batchCountYetToBeProcessed + 1;
            KLog(@"Calling getIVUserFromServerForList...");
            [self getIVUserFromServerForList:contactList];
        }
    }
    else if(type == SyncTypeContactSyncWithServer)
    {
        _isSyncInProgress = YES;
        if(!_allNativeContacts) {
            _syncedPBContact = 0;
            _allNativeContacts = [self getUnsyncedContactList];
            //KLog(@"unsynced contacts: %ld", [_allNativeContacts count]);
            EnLogd(@"unsynced contacts: %ld", [_allNativeContacts count]);
            if(_allNativeContacts && [_allNativeContacts count]) {
                NSInteger total = [[[ConfigurationReader sharedConfgReaderObj]getTotalContact]integerValue];
                _syncedPBContact = total - [_allNativeContacts count];
                if(_syncedPBContact < 0) {
                    [[ConfigurationReader sharedConfgReaderObj]setTotalContactValues:
                                [NSNumber numberWithInteger:[_allNativeContacts count]]];
                    _syncedPBContact = 0;
                }
                _syncIteration = 0;
            }
        }
        
        if(![[ConfigurationReader sharedConfgReaderObj]getContactSyncPermissionFlag]) {
            _allNativeContacts = nil;
        }
        
        long count = [_allNativeContacts count];
        if((_syncIteration * kChunkSyncSize) < count) {
            int startIndex = 0 + kChunkSyncSize*_syncIteration;
            long len = MIN(count-startIndex,kChunkSyncSize);
            /*
            if(len < kChunkSyncSize) {
                KLog(@"less than %d contacts",kChunkSyncSize);
            }*/
            NSMutableArray* batchData = [[NSMutableArray alloc]initWithArray:[_allNativeContacts subarrayWithRange:NSMakeRange(startIndex, len)]];
            KLog(@"Calling getIVUserFromServerForList...");
            [self getIVUserFromServerForList:batchData];
            _syncedPBContact = _syncedPBContact + len;
            _syncIteration++;
        }
        else {
            _allNativeContacts = nil;
            [self deleteDuplicateRecordForIV];
            KLog(@"Server sync completed");
            EnLogd(@"Server sync completed");
            KLog(@"Calling fetchMsgRequest...");
            [[Engine sharedEngineObj]fetchMsgRequest:nil];
#ifndef REACHME_APP
            [[Engine sharedEngineObj]fetchCelebrityMsgRequest:nil];
#endif
            [self downloadAndSaveServerPic:[NSMutableArray arrayWithArray:[self fetchIVContactFromDB]]];
            [self loadAndSaveAllNativeContactPic];
            [[Profile sharedUserProfile]getProfileDataFromServer];
            [[ConfigurationReader sharedConfgReaderObj]setContactServerSyncFlag:YES]; //JUNE 10, 2016
            [[ConfigurationReader sharedConfgReaderObj]setABChangeSynced:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:NSManagedObjectContextDidSaveNotification object:nil];//FEB 8, 2017
        }
    }
    else if(type == SyncTypeIVServerSync)
    {
        if([[ConfigurationReader sharedConfgReaderObj]getContactServerSyncFlag])
        {
            [self deleteDuplicateRecordForIV];
        }
        else
        {
            if(_batchCountYetToBeProcessed < 1)
            {
                KLog(@"Server sync completed");
                EnLogd(@"Server sync completed");
                [[Engine sharedEngineObj]fetchMsgRequest:nil];
                [[Engine sharedEngineObj]fetchCelebrityMsgRequest:nil];
                [[ConfigurationReader sharedConfgReaderObj]setContactServerSyncFlag:YES];
                [self downloadAndSaveServerPic:[NSMutableArray arrayWithArray:[self fetchIVContactFromDB]]];
                [self loadAndSaveAllNativeContactPic];
                [[Profile sharedUserProfile]getProfileDataFromServer];
            }
        }
    }
    else if (type == SyncTypeIVMsgBasedSync)
    {
        [[Engine sharedEngineObj]updateMsgOnContactSync];
    }
}



#pragma mark - Contact Pic Download
-(void)loadAndSaveAllNativeContactPic
{
    ContactSyncSavePicOperation* op = [[ContactSyncSavePicOperation alloc]initWithData:Nil syncType:PicSaveOperationTypeLocalAllContact];
    [_contactPicSyncQueue addOperation:op];
}

-(void)loadAndSaveABChangedPic:(NSMutableArray*)contactList
{
    KLog(@"AB -- loadAndSaveABChangedPic. list = %@",contactList);
    
    NSMutableArray* downloadPicList = [[NSMutableArray alloc]init];
    for(NSString* phoneNum in contactList)
    {
        NSArray* contactDetailList = [self getContactForPhoneNumber:phoneNum];
        if([contactDetailList count] > 0)
        {
            ContactDetailData* detail = [contactDetailList objectAtIndex:0];
            ContactPicDownloadData* pic = [[ContactPicDownloadData alloc]init];
            pic.isServerPic = NO;
            pic.serverPicURL = detail.contactIdParentRelation.contactPicURI;
            pic.localPicPath = detail.contactIdParentRelation.contactPic;
            pic.nativeRecordId = [detail.contactId integerValue];
            [downloadPicList addObject:pic];
        }
    }
    if([downloadPicList count] > 0)
    {
        ContactSyncSavePicOperation* op = [[ContactSyncSavePicOperation alloc]initWithData:downloadPicList syncType:PicSaveOperationTypePendingList];
        op.delegate = self;
        [_contactPicSyncQueue addOperation:op];
    }
}

-(void)downloadAndSaveServerPic:(NSMutableArray*)ivList
{
    ContactSyncSavePicOperation* op = [[ContactSyncSavePicOperation alloc]initWithData:[self getPicDownloadListFromContactList:ivList] syncType:PicSaveOperationTypePendingList];
    op.delegate = self;
    [_contactPicSyncQueue addOperation:op];
}

-(NSMutableArray*)getPicDownloadListFromContactList:(NSMutableArray*)contactList
{
    NSMutableArray* downloadPicList = [[NSMutableArray alloc]init];
    for(ContactData* data in contactList)
    {
        ContactPicDownloadData* pic = [[ContactPicDownloadData alloc]init];
        pic.isServerPic = YES;
        pic.serverPicURL = data.contactPicURI;
        pic.localPicPath = data.contactPic;
        [downloadPicList addObject:pic];
    }
    return downloadPicList;
}

-(void)loadAndSavePendingPic:(NSMutableArray*)picDataList
{
    ContactSyncSavePicOperation* op = [[ContactSyncSavePicOperation alloc]initWithData:picDataList syncType:PicSaveOperationTypePendingList];
    op.delegate = self;
    [_contactPicSyncQueue addOperation:op];
}

-(void)downloadAndSavePicWithURL:(NSString*)picURL picPath:picPath
{
    if([[ConfigurationReader sharedConfgReaderObj]getContactServerSyncFlag])
    {
        if(![self checkIfOperationAlreadyExistForURL:picURL])
        {
            ContactPicDownloadData* data = [[ContactPicDownloadData alloc]init];
            data.isServerPic = YES;
            data.serverPicURL = picURL;
            data.localPicPath = picPath;
            data.nativeRecordId = 0;
            ContactSyncSavePicOperation* op = [[ContactSyncSavePicOperation alloc]initWithData:[NSMutableArray arrayWithObjects:data, nil] syncType:PicSaveOperationTypePendingList];
            op.delegate = self;
            [_contactPicSyncQueue addOperation:op];
        }
    }
}

/* TODO check: it is not used
-(void)updateFriendsProfilePicForContact:(NSArray*)contactList ivUserId:(NSNumber*)ivUserId picUrl:picUrl
{
    NSArray* contactDetailList = [self getContactForIVUserId:ivUserId];
    for(ContactDetailData* data in contactDetailList)
    {
        NSString* localPicPath = data.contactIdParentRelation.contactPic;
        if(localPicPath != Nil && localPicPath.length > 0)
        {
            //pic already exist change the pic url and remove the pic
            data.contactIdParentRelation.contactPicURI = picUrl;
            [self downloadAndSavePicWithURL:picUrl picPath:localPicPath];
        }
    }
    NSError* error = Nil;
    if(![_mainQueueContext save:&error])
    {
        //KLog(@"CoreData: Error Saving Pic");
        EnLogd(@"CoreData: Error Saving Pic");
    }
}*/

-(BOOL)checkIfOperationAlreadyExistForURL:(NSString*)picUrl
{
    for(NSOperation* op in [_contactPicSyncQueue operations])
    {
        if([op isKindOfClass:[ContactSyncSavePicOperation class]])
        {
            NSArray* dataList = [(ContactSyncSavePicOperation*)op contactData];
            for(ContactPicDownloadData* data in dataList)
            {
                if([data.serverPicURL isEqualToString:picUrl])
                    return true;
            }
        }
    }
    return false;
}

#pragma mark - Contact Pic operations failure handling
-(void)picDownloadOperationFailedForURL:(NSString *)picURL
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:_mainQueueContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"isIV == 1 AND contactPicURI = %@",picURL];
    [request setPredicate:condition];
    
    NSError *error;
    NSArray *array = nil;
    @try {
        array = [_mainQueueContext executeFetchRequest:request error:&error];
        if(array != Nil && [array count]>0)
        {
            for(ContactData* data in array)
            {
                data.contactPicURI = Nil;
            }
            if (![_mainQueueContext save:&error]) {
                //KLog(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
                EnLogd(@"CoreData: Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
    } @catch(NSException* ex) {
        EnLogd(@"*** Exception occurred:%@",ex);
    }
}

#pragma mark - misc
-(NSArray*)fetchIVContactFromDB
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:_mainQueueContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    request.fetchBatchSize = 200;
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"isIV == 1 AND contactType != %d",ContactTypeCelebrity];
    [request setPredicate:condition];
    
    NSSortDescriptor *sortName = [[NSSortDescriptor alloc]initWithKey:@"contactName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortIsNewJoinee = [[NSSortDescriptor alloc]initWithKey:@"isNewJoinee" ascending:YES];
    [request setSortDescriptors:@[sortIsNewJoinee,sortName]];
    NSError *error;
    
    NSArray *array = nil;
    @try {
        array = [_mainQueueContext executeFetchRequest:request error:&error];
    } @catch(NSException* ex) {
        EnLogd(@"*** Exception occurred:%@",ex);
    }
    
    if (array == nil) {
        //KLog(@"No Record Found");
        array = [NSArray array];
    }
    
    return array;
}

-(NSInteger)getTotalContactCount:(BOOL)isIV
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:_mainQueueContext]];
    [request setIncludesSubentities:NO];
    if(isIV)
    {
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"isIV = 1 AND contactType != %d",ContactTypeCelebrity];
        [request setPredicate:condition];
    }
    else
    {
        NSPredicate* condition = [NSPredicate predicateWithFormat:@"(isIV = 1 AND contactType != %d) || (isIV = 0 AND contactType != %@)",ContactTypeCelebrity,[NSNumber numberWithInteger:ContactTypeMsgSyncContact]];
        [request setPredicate:condition];
    }
    
    NSError *err;
    NSUInteger count = [_mainQueueContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
    }
    return count;
}

-(NSArray*)getContactForPhoneNumber:(NSString*)phoneNum
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_mainQueueContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    /* Crashlytics - #1422 @691
       predicateWithFormat Raises an NSInvalidArgumentException if format is invalid. Look for same condition in entire source
     */
    NSPredicate* condition=nil;
    @try {
        condition = [NSPredicate predicateWithFormat:@"contactDataValue = %@",phoneNum];
    }
    @catch (NSException *exception) {
        EnLogd(@"phoneNum=%@. Exception occurred:%@",phoneNum,exception);
        return nil;
        //TODO: FIXME. Do NOT pass invalid phoneNum.
    }
    
    [request setPredicate:condition];
    
    NSError *error;
    NSArray *array = nil;
    @try {
        array = [_mainQueueContext executeFetchRequest:request error:&error];
    } @catch(NSException* ex) {
        EnLogd(@"*** Exception occurred:%@",ex);
    }
    
    if (array == nil) {
        //KLog(@"No Record Found");
        array = [NSArray array];
    }
    
    return array;
}


-(NSArray*)getGroupMemberDataForPhoneNumber:(NSString*)phoneNum
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GroupMemberData" inManagedObjectContext:_mainQueueContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
     NSString* phoneNumwWithPlus = [Common setPlusPrefixChatWithMobile:phoneNum];
    
    //NSPredicate* condition = [NSPredicate predicateWithFormat:@"memberContactDataValue contains %@",phoneNum];
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"memberContactDataValue = %@",phoneNumwWithPlus];
    [request setPredicate:condition];
    
    NSError *error;
    NSArray *array = nil;
    @try {
        array = [_mainQueueContext executeFetchRequest:request error:&error];
    } @catch(NSException* ex) {
        EnLogd(@"*** Exception occurred:%@",ex);
    }
    
    if (array == nil) {
        //KLog(@"No Record Found");
        array = [NSArray array];
    }
    
    return array;
}


/*
 <_PFArray 0xb641420>(
 <ContactDetailData: 0xb9a78e0> (entity: ContactDetailData; id: 0xb9a1a50 <x-coredata://675FB94B-4755-4558-BD96-6E698BC92D26/ContactDetailData/p45> ; data: {
 blockedFlag = 0;
 contactDataId = 0;
 contactDataSubType = nil;
 contactDataType = tel;
 contactDataValue = 919597465668;
 contactId = 5953971;
 contactIdParentRelation = "0xb98b8a0 <x-coredata://675FB94B-4755-4558-BD96-6E698BC92D26/ContactData/p75>";
 ivJoinedTime = 0;
 ivUserId = 5953971;
 localSync = 1;
 serverSync = 1;
 status = nil;
 vsmsUser = nil;
 })
 )
 
 
 po [[array objectAtIndex:0] contactIdParentRelation]
 <ContactData: 0xb670650> (entity: ContactData; id: 0xb98b8a0 <x-coredata://675FB94B-4755-4558-BD96-6E698BC92D26/ContactData/p75> ; data: {
 contactId = 5953971;
 contactIdDetailRelation =     (
 "0xb9a1a50 <x-coredata://675FB94B-4755-4558-BD96-6E698BC92D26/ContactDetailData/p45>"
 );
 contactName = "Deep Senvincen";
 contactPic = nil;
 contactPicURI = nil;
 contactType = 1;
 firstName = "Deep Senvincen";
 groupId = nil;
 isIV = 1;
 isInvited = 0;
 isNewJoinee = 0;
 lastName = nil;
 localSyncTime = 0;
 picDownloadState = nil;
 removeFlag = 0;
 })
 */
-(NSArray*)getCustomContactForNewPhoneNumber:(NSString*)phoneNum
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:_mainQueueContext];
    ContactData *unassociatedObject = (ContactData*)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    NSEntityDescription *entityDetail = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_mainQueueContext];
    ContactDetailData *unassociatedObjectDetail = (ContactDetailData*)[[NSManagedObject alloc] initWithEntity:entityDetail insertIntoManagedObjectContext:nil];
    unassociatedObjectDetail.hideBlockContact = 0;
    unassociatedObjectDetail.contactDataId = 0;
    unassociatedObjectDetail.contactDataSubType = nil;
    unassociatedObjectDetail.contactDataType = @"tel";
    unassociatedObjectDetail.contactDataValue = phoneNum;
    unassociatedObjectDetail.ivJoinedTime = 0;
    unassociatedObjectDetail.contactId = [NSNumber numberWithInteger:[phoneNum integerValue]];
    unassociatedObjectDetail.ivJoinedTime = 0;
    unassociatedObjectDetail.ivUserId = 0;
    unassociatedObjectDetail.localSync = 0;
    unassociatedObjectDetail.serverSync = 0;
    unassociatedObjectDetail.status = nil;
    unassociatedObjectDetail.vsmsUser = nil;
    
    unassociatedObject.contactId = [NSNumber numberWithInteger:[phoneNum integerValue]];
    [unassociatedObject addContactIdDetailRelationObject:unassociatedObjectDetail];
    unassociatedObject.contactName = phoneNum;
    unassociatedObject.contactPic = nil;
    unassociatedObject.contactPicURI = nil;
    unassociatedObject.contactType = [NSNumber numberWithInteger:ContactTypeMsgSyncContact];
    unassociatedObject.firstName = @"";
    unassociatedObject.groupId = nil;
    unassociatedObject.isIV = 0;
    unassociatedObject.isInvited = 0;
    unassociatedObject.isNewJoinee = 0;
    unassociatedObject.lastName = @"";
    unassociatedObject.localSyncTime = 0;
    unassociatedObject.picDownloadState = nil;
    unassociatedObject.removeFlag = 0;
    unassociatedObjectDetail.contactIdParentRelation = unassociatedObject;
    
    NSArray *array = @[unassociatedObjectDetail];
    if (array == nil)
    {
        //KLog(@"No Record Found");
        array = [NSArray array];
    }
    
    return array;
}

-(NSArray*)getContactForIVUserId:(NSNumber *)ivUserId usingMainContext:(BOOL)isMainContext
{
    NSManagedObjectContext* moc = nil;
    if(isMainContext)
        moc = _mainQueueContext;
    else
        moc = _privateQueueContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    request.fetchBatchSize = 200;
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"ivUserId = %@",ivUserId];
    [request setPredicate:condition];
    
    NSError *error;
    NSArray *array = nil;
    @try {
        array = [moc executeFetchRequest:request error:&error];
    } @catch(NSException* ex) {
        EnLogd(@"*** Exception occurred:%@",ex);
    }
    
    if (array == nil) {
        //KLog(@"No Record Found");
        array = [NSArray array];
    }
    
    return array;
}

-(NSMutableDictionary*)getContactDictionaryForChatGridScreen:(NSArray*)phoneNumList
{
    KLog(@"getContactDictionaryForChatGridScreen");
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactDetailData" inManagedObjectContext:_mainQueueContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"contactDataValue IN %@",phoneNumList];
    [request setPredicate:condition];
    
    NSError *error;
    NSArray *array = nil;
    @try {
        array = [_mainQueueContext executeFetchRequest:request error:&error];
    } @catch(NSException* ex) {
        EnLogd(@"*** Exception occurred:%@",ex);
    }
    
    if (array == nil) {
        //KLog(@"No Record Found");
        array = [NSArray array];
    }
    
    for(ContactDetailData* detail in array)
    {
        if([detail.contactDataValue length]) {
            [dic setValue:detail forKey:detail.contactDataValue];
        } else {
            KLog(@"contactDataValue is null. why? %@",detail);
            EnLogd(@"contactDataValue is null. detail =  %@",detail);
        }
    }
    
    return dic;
}










-(void)saveCelebrityContactList:(NSMutableArray*)contactList
{
    ContactSyncOperation* op = [[ContactSyncOperation alloc]initWithData:nil syncType:SyncTypeCelebrity sharedPSC:_sharedStoreCoordinator];
    op.data = contactList;
    op.delegate = self;
    [_contactSyncQueue addOperation:op];
}

-(void)saveIVSupportContact:(NSArray*)supportContactIds
{
    for (NSMutableDictionary *supportContact in supportContactIds)
    {
        ContactData* data = [NSEntityDescription insertNewObjectForEntityForName:@"ContactData" inManagedObjectContext:_mainQueueContext];
        
        NSNumber *ivId = 0;
        NSString* ivIdStr = @"";
        if([[supportContact valueForKey:SUPPORT_IV_ID] isKindOfClass:[NSNumber class]])
        {
            ivId = [supportContact valueForKey:SUPPORT_IV_ID];
        }
        else
        {
            ivIdStr = [supportContact valueForKey:SUPPORT_IV_ID];
            ivId = [NSNumber numberWithLong:[ivIdStr longLongValue]];
        }
        
        NSNumber *isIv = [NSNumber numberWithBool:YES];
        NSString *picUri = [supportContact valueForKey:SUPPORT_PIC_URI];
        
        //NSString *localImagePath = [IVFileLocator createDeviceContactImgDir];
        NSString *imgName =[NSString stringWithFormat:@"%@.png",[ivId stringValue]];
        /*NSMutableString *fullPath = [[NSMutableString alloc]init];
         [fullPath appendString:localImagePath];
         [fullPath appendString:imgName];*/
        
        data.contactId = ivId;
        data.contactName = [supportContact valueForKey:SUPPORT_NAME];
        data.isIV = isIv;
        data.contactType = [NSNumber numberWithInteger:ContactTypeHelpSuggestion];
        data.contactPicURI = picUri;
        data.contactPic = imgName;
        
        NSString *phone = [supportContact valueForKey:SUPPORT_DATA_VALUE];
        if(phone != nil && [phone length] > 0)
        {
            ContactDetailData* detail = [NSEntityDescription insertNewObjectForEntityForName:@"ContactDetailData" inManagedObjectContext:_mainQueueContext];
            detail.contactId = ivId;
            detail.contactDataType = PHONE_MODE;
            detail.ivUserId = ivId;
            detail.contactDataValue = phone;
            detail.contactDataId = ivId;
            detail.serverSync = [NSNumber numberWithBool:TRUE];
            detail.localSync = [NSNumber numberWithBool:TRUE];
            
            [data addContactIdDetailRelationObject:detail];
        }
        [_mainQueueContext insertObject:data];
    }
    NSError* error = Nil;
    if(![_mainQueueContext save:&error]) {
        //KLog(@"CoreData: Couldn't save IV Support contact: %@", [error localizedDescription]);
        EnLogd(@"CoreData: Couldn't save IV Support contact: %@", [error localizedDescription]);
    }
}

//Not used currently
-(NSMutableArray*) getIVContactList
{
    if([_ivContactList count] > 0)
        return _ivContactList;
    _ivContactList = [NSMutableArray arrayWithArray:[self fetchIVContactFromDB]];
    return _ivContactList;
}

-(NSMutableArray*) getPBContactList:(NSManagedObjectContext*)moc
{
    if([_pbContactList count] > 0)
        return _pbContactList;
    _pbContactList = [NSMutableArray arrayWithArray:[self fetchPBContactFromDB:moc]];
    return _pbContactList;
}

-(NSArray*)fetchPBContactFromDB:(NSManagedObjectContext*) moc
{
    if(!moc) {
        EnLogd(@"*** moc is nil");
        return nil;
    }
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    request.fetchBatchSize = 0;//200;
    
    NSSortDescriptor *sortName = [[NSSortDescriptor alloc]initWithKey:@"contactName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortISIV = [[NSSortDescriptor alloc]initWithKey:@"isIV" ascending:NO];
    NSSortDescriptor *sortIsNewJoinee = [[NSSortDescriptor alloc]initWithKey:@"isNewJoinee" ascending:YES];
    [request setSortDescriptors:@[sortIsNewJoinee,sortISIV,sortName]];
    NSError *error;
    
    NSArray *array = nil;
    @try {
        array = [moc executeFetchRequest:request error:&error];
    } @catch(NSException* ex) {
        EnLogd(@"*** Exception occurred:%@",ex);
    }
    
    if (array == nil) {
        //KLog(@"No Record Found");
        array = [NSArray array];
    }
    
    return array;
}


#pragma mark -- Group related code
-(void)updateGroupMemberInfoFromServer:(BOOL)syncDB
{
#ifndef REACHME_APP
    NSMutableDictionary *fetchContactDic = [[NSMutableDictionary alloc] init];
    FetchGroupUpdateAPI* api = [[FetchGroupUpdateAPI alloc]initWithRequest:fetchContactDic];
    [api callNetworkRequest:fetchContactDic withSuccess:^(FetchGroupUpdateAPI *req, NSMutableDictionary *responseObject) {
        
        ContactSyncOperation* op = [[ContactSyncOperation alloc]initWithData:nil syncType:SyncTypeGroupUpdate sharedPSC:_sharedStoreCoordinator];
    
        op.data = responseObject;
        op.delegate = self;
        [_contactSyncQueue addOperation:op];
    } failure:^(FetchGroupUpdateAPI *req, NSError *error) {
        [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidFailWithError:error forPendingEventType:PendingEventTypeFetchGroupUpdates];
    }];
#endif
    
}

-(NSArray*)getGroupMemberInfoForGroupId:(NSString*)groupIdStr
{
#ifndef REACHME_APP
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GroupMemberData" inManagedObjectContext:_mainQueueContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"groupId = %@ AND status = %d",groupIdStr,GroupMemberStatusActive];
    [request setPredicate:condition];
    NSSortDescriptor *sortName = [[NSSortDescriptor alloc]initWithKey:@"memberDisplayName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sortIsOwner = [[NSSortDescriptor alloc]initWithKey:@"isOwner" ascending:NO];
    
    [request setSortDescriptors:@[sortIsOwner,sortName]];
    NSError *error;
    NSArray *array = nil;
    @try {
        array = [_mainQueueContext executeFetchRequest:request error:&error];
    } @catch(NSException* ex) {
        EnLogd(@"*** Exception occurred:%@",ex);
    }
    
    if(array == nil) {
        array = [NSArray array];
    }
    
    return array;
#else
    return nil;
#endif
    
}

-(ContactData*)getGroupHeaderForGroupId:(NSString*)groupId usingMainQueue:(BOOL)isMainQueue
{
#ifndef REACHME_APP
    NSManagedObjectContext* moc;
    if(isMainQueue)
        moc = [AppDelegate sharedMainQueueContext];
    else
        moc = [AppDelegate sharedPrivateQueueContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactData" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate* condition = [NSPredicate predicateWithFormat:@"groupId = %@",groupId];
    [request setPredicate:condition];
    
    
    __block NSArray *array = nil;
    [moc performBlockAndWait:^{
        NSError *error;
        @try {
            array = [moc executeFetchRequest:request error:&error];
        } @catch(NSException* ex) {
            EnLogd(@"*** Exception occurred:%@",ex);
        }
    }];
    
    if(array.count > 0)
        return [array objectAtIndex:0];
    
    return NULL;
#else
    return NULL;
#endif
}


// this is called via observing "NSManagedObjectContextDidSaveNotification" from our APLParseOperation
- (void)mergeChangedData:(NSNotification *)notification {
    if (notification.object != _mainQueueContext) {
        [self performSelectorOnMainThread:@selector(updateMainContextData:) withObject:notification waitUntilDone:NO];
    }
}

// merge changes to main context,fetchedRequestController will automatically monitor the changes and update tableview.
- (void)updateMainContextData:(NSNotification *)notification {
    assert([NSThread isMainThread]);
    [_mainQueueContext mergeChangesFromContextDidSaveNotification:notification];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
}





- (void)fetchSecondaryNumbers {
    
    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        return;
    }
    NSMutableDictionary *req = [[NSMutableDictionary alloc]init];
    long ivUserId = [[ConfigurationReader sharedConfgReaderObj] getIVUserId];
    NSNumber *num = [NSNumber numberWithLong:ivUserId];
    
    [req setValue:[appDelegate.confgReader getDeviceUUID] forKey:API_DEVICE_ID];
    [req setValue:num forKey:IV_USER_ID];
    [req setValue:[appDelegate.confgReader getUserSecureKey] forKey:API_USER_SECURE_KEY];
    
    FetchUserContactAPI* api = [[FetchUserContactAPI alloc]initWithRequest:req];
    [api callNetworkRequest:req withSuccess:^(FetchUserContactAPI *req, NSMutableDictionary *responseObject) {
        if(![[responseObject valueForKey:STATUS] isEqualToString:STATUS_OK]) {
            EnLogd(@"** Error fetching the user %@ and api request %@",req,api.request);
        } else {
            NSArray *userContacts = [responseObject valueForKey:@"user_contacts"];
            UserProfileModel *model = [[Profile sharedUserProfile]profileData];
            NSMutableArray *additionalNonVerifiedNumbers = [model.additionalNonVerifiedNumbers mutableCopy];
            NSMutableArray *additionalVerifiedNumbers = [model.additionalVerifiedNumbers mutableCopy];
            NSArray *verifiedNumbersInProfileData = [model.additionalVerifiedNumbers valueForKeyPath:@"contact_id"];//TODO crash Fatal Exception: NSUnknownKeyException

            [additionalVerifiedNumbers removeAllObjects];
            
            for (int i=0; i<[userContacts count]; i++) {
                NSDictionary *userContact = [userContacts objectAtIndex:i];
                if([[userContact valueForKey:@"contact_type"] isEqualToString:@"p"]){
                    NSMutableDictionary *verifiedNumberInfo = [[NSMutableDictionary alloc]init];

                    int isPrimary = [[userContact valueForKey:@"is_primary"] intValue];
                    NSArray *filteredNonVerifiedNumbers = [additionalNonVerifiedNumbers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_id = %@",[userContact valueForKey:@"contact_id"]]];
                    [verifiedNumberInfo setValue:[userContact valueForKey:@"contact_id"] forKey:@"contact_id"];
                    [verifiedNumberInfo setValue:[userContact valueForKey:@"country_code"] forKey:@"country_code"];
                    [verifiedNumberInfo setValue:[userContact valueForKey:@"is_primary"]  forKey:@"is_primary"];
                    [verifiedNumberInfo setValue:[userContact valueForKey:@"is_virtual"]  forKey:@"is_virtual"];
                    if(isPrimary == 1){
                        [additionalVerifiedNumbers insertObject:verifiedNumberInfo atIndex:0];
                    }
                    else{
                        [additionalVerifiedNumbers addObject:verifiedNumberInfo];
                    }
                    
                    if(([verifiedNumbersInProfileData containsObject:[userContact valueForKey:@"contact_id"]]) && ([filteredNonVerifiedNumbers count] != 0)){
                        [additionalNonVerifiedNumbers removeObjectsInArray:filteredNonVerifiedNumbers];
                    }
                }
            }
            
            model.additionalVerifiedNumbers = additionalVerifiedNumbers;
            model.additionalNonVerifiedNumbers = additionalNonVerifiedNumbers;
            [[Profile sharedUserProfile]writeProfileDataInFile];
            
        //Check we have secondary numbers - If so start fetching the list_carriers.
            if ([model.additionalVerifiedNumbers count]) {
                [[Setting sharedSetting]fetchCarrierList];
            }
        }
    }failure:^(FetchUserContactAPI *req, NSError *error) {
        EnLogd(@"*** Error fetching user contact: %@, %@",req,[error description]);
        NSInteger errorCode = error.code;
        NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
        if([errorMsg length]) {
            KLog(@"*** Failed to get secondary number(s).%@",errorMsg);
            EnLogd(@"*** Failed to get seconday numbers(s).%@",errorMsg);
            //TODO SEP 23 [ScreenUtility showAlertMessage: errorMsg];
        }
    }];


}

#pragma mark -- App Upgrade Utility
-(void)deleteDuplicateCelebrityRecord
{
    ContactSyncOperation* op = [[ContactSyncOperation alloc]initWithData:Nil syncType:SyncTypeDeleteDuplicateCelebRecord sharedPSC:_sharedStoreCoordinator];
    op.delegate = self;
    [_contactSyncQueue addOperation:op];
}

-(NSArray*)readFromNativeAddressBook
{
    //KLog(@"reading from AB starts");
    EnLogd(@"reading from AB starts");
    CFErrorRef error = NULL;
    if( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        [[ConfigurationReader sharedConfgReaderObj] setContactAccessPermissionFlag:TRUE];
    }
    ABAddressBookRef _nativeAddressBook = ABAddressBookCreateWithOptions(NULL, &error);
    NSArray* allNativeContact = (CFBridgingRelease)(ABAddressBookCopyArrayOfAllPeople(_nativeAddressBook));
    [[ConfigurationReader sharedConfgReaderObj]setTotalContact:[NSNumber numberWithInteger:[allNativeContact count]]];
    //KLog(@"reading from AB ends");
    EnLogd(@"reading from AB ends");
    CFRelease(_nativeAddressBook);
    return allNativeContact;
}

- (NSArray *)retrieveListOfPhoneNumbersFromABRecord:(ABRecordRef)contactPerson {
    
    NSMutableArray *contactDataList = [[NSMutableArray alloc]init];
    NSString *contactDataValue = nil;
    NSString *contactName = @"";

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
            
            if(contactName == nil || [contactName length] == 0)
            {
                contactName = contactDataValue;
            }
            [contactDataList addObject:contactDataValue];
        }
        CFRelease(phones);
    }
    
    return contactDataList;
}

@end