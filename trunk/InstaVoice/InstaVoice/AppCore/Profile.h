//
//  Profile.h
//  InstaVoice
//
//  Created by adwivedi on 05/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfileModel.h"

@protocol ProfileProtocol <NSObject>
@optional
-(void)fetchProfileCompletedWith:(UserProfileModel*)modelData;
-(void)updateProfileCompletedWith:(UserProfileModel*)modelData;
-(void)uploadPicCompletedWithPath:(NSString*)path;
-(void)downloadPicCompletedWithPath:(NSString*)path;
@end

@interface Profile : NSObject
{
    UserProfileModel* _profileData;
}

+(Profile*)sharedUserProfile;

@property(nonatomic,strong)UserProfileModel* profileData;
@property(nonatomic,weak)id<ProfileProtocol> delegate;

-(void)getProfileDataFromServer;
-(UserProfileModel*)getUserProfile;
-(void)updateUserProfile:(UserProfileModel *)profileData;
-(void)uploadProfilePicWithPath:(NSString*)path fileName:(NSString*)fileName;
-(void)downloadProfilePic:(NSString*)filePath;
-(void)writeProfileDataInFile;
-(void)resetProfileData;

//-(void)updateUserProfileFromNativeAB:(NSMutableDictionary*)dic;
-(void)fetchBlockedUserList;

@end
