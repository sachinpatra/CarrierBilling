//
//  GroupUtility.h
//  InstaVoice
//
//  Created by adwivedi on 01/09/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupUtility : NSObject
{
    NSManagedObjectContext* _managedObjectContext;
    NSInteger _contextType;
}

-(id)initWithData:(NSInteger)contextType;

-(void)updateGroupMemberInfoFromServerResponse:(NSMutableDictionary*)groupData syncMember:(BOOL)syncMember;
-(NSMutableArray*)getCreateGroupMemberDataList:(NSString*)groupId;

-(NSMutableDictionary*)createGroupMessageForGroupName:(NSString*)name groupId:(NSString*)groupId picPath:(NSString*)picPath memberList:(NSMutableArray*)memberList isNewGroup:(BOOL)isNewGroup;

-(void)sendLeaveGroupMessage;

//CMP MAR 04,16
-(BOOL)checkIfGroupAlreadyExist:(NSString*)groupIdStr;
//

@end

@interface GroupEventMessage : NSObject
@property (nonatomic,strong)NSString* eventType;
@property (nonatomic,strong)NSString* ownerContact;
@property (nonatomic,strong)NSString* ownerName;
@property (nonatomic,strong)NSString* ownerUserId;
@property (nonatomic,strong)NSString* targetContact;
@property (nonatomic,strong)NSString* targetName;
@property (nonatomic,strong)NSString* targetUserId;
@end

@interface GroupApiHeader : NSObject
@property (nonatomic,strong)NSString* groupName;
@property (nonatomic)NSInteger groupType;
@property (nonatomic,strong)NSString* groupDesc;
@property (nonatomic,strong)NSString* groupAbout;
@property (nonatomic,strong)NSString* groupPicFileType;
@property (nonatomic,strong)NSString* groupPicFileName;
@property (nonatomic,strong)NSString* groupPicFilePath;
@property (nonatomic,strong)NSMutableArray* memberList;
@end

@interface CreateGroupMemberData : NSObject
@property (nonatomic,strong)NSString* memberName;
@property (nonatomic,strong)NSString* memberIvId;
@property (nonatomic,strong)NSString* memberPhoneNumber;
@property (nonatomic,strong)NSString* operationType;
@property (nonatomic,strong)NSString* memberType;
@property (nonatomic,strong)NSString* picPath;
@property (nonatomic) BOOL memberSelected;
@end
