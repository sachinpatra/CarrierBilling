//
//  ContactSyncUtility.m
//  InstaVoice
//
//  Created by adwivedi on 07/07/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ContactSyncUtility.h"
NSString *kInitSyncBatchDataSync = @"InitSyncBatchDataSync";
NSString *kInitSyncBatchDataSyncComplete = @"InitSyncBatchDataSyncComplete";
NSString *kDownloadPicKey = @"DownloadPicKey";
NSString *kNewABRecordNotification = @"NewABRecordNotification";

@implementation EnquireIVServerResponseContact
@synthesize ivListFromResponse,pbListSynced;
@end

@implementation ContactPicDownloadData
@synthesize localPicPath,serverPicURL,isServerPic,nativeRecordId;
@end

@implementation ContactSyncUtility
@end
