//
//  GroupMemberData.h
//  InstaVoice
//
//  Created by adwivedi on 13/08/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GroupMemberData : NSManagedObject

@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSNumber * isAdmin;
@property (nonatomic, retain) NSNumber * isMember;
@property (nonatomic, retain) NSNumber * isOwner;
@property (nonatomic, retain) NSNumber * joiningDate;
@property (nonatomic, retain) NSString * memberContactDataValue;
@property (nonatomic, retain) NSString * memberDisplayName;
//memberId specifies iv user ID in case of memberType is iv; otherwise specifies memberContactDataValue
@property (nonatomic, retain) NSString * memberId;
@property (nonatomic, retain) NSNumber * memberIvUserId;
@property (nonatomic, retain) NSString * memberType;
@property (nonatomic, retain) NSString * picLocalPath;
@property (nonatomic, retain) NSString * picRemoteUri;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * isAgent;

@end
