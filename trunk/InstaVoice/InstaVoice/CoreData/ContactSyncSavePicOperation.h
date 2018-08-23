//
//  ContactSyncSavePicOperation.h
//  InstaVoice
//
//  Created by adwivedi on 04/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactSyncUtility.h"

@protocol ContactPicSyncOperationDelegate <NSObject>
-(void)picDownloadOperationFailedForURL:(NSString*)picURL;
@end

@interface ContactSyncSavePicOperation : NSOperation
@property (nonatomic)PicSaveOperationType picSaveOperationType;
@property (copy, readonly) NSMutableArray *contactData;
@property (nonatomic,weak)id<ContactPicSyncOperationDelegate> delegate;
@property (strong, nonatomic) NSURLSession *session;

- (id)initWithData:(NSMutableArray *)contactData syncType:(PicSaveOperationType)picSaveOperationType ;
@end


