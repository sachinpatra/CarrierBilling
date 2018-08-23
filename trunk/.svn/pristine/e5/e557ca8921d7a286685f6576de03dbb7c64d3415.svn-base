//
//  ContactSyncUtility.h
//  InstaVoice
//
//  Created by adwivedi on 07/07/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kInitSyncBatchDataSync;
extern NSString *kInitSyncBatchDataSyncComplete;
extern NSString *kDownloadPicKey;
extern NSString *kNewABRecordNotification;

static NSUInteger const kChunkSyncSize = 500;
static NSUInteger const kMaxContactLimitHack = 4000;

typedef enum : NSInteger {
	ContactInitialSyncStateABUploadCompleted = 1,
	ContactInitialSyncStateServerSycnCompleted = 2,
    ContactInitialSyncStateServerPicDownloadCompleted = 4,
    ContactInitialSyncStateLocalPicDownloadCompleted = 8
} ContactInitialSyncState;

typedef enum : NSInteger {
	ContactABChangeSyncStateABUploadCompleted = 1,
	ContactABChangeSyncStateServerSycnCompleted = 2,
    ContactABChangeSyncStateServerPicDownloadCompleted = 4,
    ContactABChangeSyncStateLocalPicDownloadCompleted = 8
} ContactABChangeSyncState;

typedef enum : NSInteger {
	SyncTypeInitialContactSync = 0,
	SyncTypeAddressBookChangeSync,
	SyncTypeIVServerSync,
    SyncTypeIVMsgBasedSync,
    SyncTypeFetchFriendBasedSync,
    SyncTypeDeleteDuplicateIVRecord,
    SyncTypeGroupUpdate,
    SyncTypeCelebrity,
    SyncTypeDeleteDuplicateCelebRecord,
    SyncTypeContactSyncWithServer //DEC 29
} SyncType;

typedef enum : NSInteger {
	ContactTypeNativeContact = 0,
	ContactTypeMsgSyncContact,
    ContactTypeIVGroup,
    ContactTypeHelpSuggestion,
    ContactTypeCelebrity
} ContactType;

typedef enum : NSInteger {
	PicSaveOperationTypeLocalAllContact = 0,
	PicSaveOperationTypePendingList
} PicSaveOperationType;

typedef enum : NSInteger {
	GroupMemberStatusActive = 0,
	GroupMemberStatusDeleted,
    GroupMemberStatusLeft
} GroupMemberStatus;

typedef enum : NSInteger {
	ContactInviteTypeSMS = 0,
	ContactInviteTypeEmail,
    ContactInviteTypeFacebook
} ContactInviteType;

@interface EnquireIVServerResponseContact : NSObject
@property (nonatomic,strong)NSMutableArray* ivListFromResponse;
@property (nonatomic,strong)NSMutableArray* pbListSynced;
@end

@interface ContactPicDownloadData : NSObject
@property(nonatomic,strong)NSString* localPicPath;
@property(nonatomic,strong)NSString* serverPicURL;
@property(nonatomic)NSInteger nativeRecordId;
@property(nonatomic)BOOL isServerPic;
@end

@interface ContactSyncUtility : NSObject
@end


@protocol FriendInviteListProtocol <NSObject>
@optional
-(void)listSelected:(NSMutableArray*)inviteList forInviteType:(ContactInviteType)inviteType;
-(void)shareFriendListDidFinishSelectingList:(NSMutableArray *)shareFriendList forMessage:(NSDictionary *)msgDictionary;
@end


