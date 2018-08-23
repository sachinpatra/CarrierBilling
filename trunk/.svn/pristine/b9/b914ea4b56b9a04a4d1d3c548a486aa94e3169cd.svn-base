//
//  IVFileLocator.h
//  InstaVoice
//
//  Created by adwivedi on 24/07/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"

//Directory name constants

#define KIRUSA                           @"kirusa"
#define INSTAVOICE                       @"instavoice"
#define SENT                             @"sent"
#define RECEIVED                         @"received"
#define IMAGES                           @"images"

#define DEVICE_CONTACT_IMG               @"contactimages"
#define CHAT_IMG                         @"chatImage"

#define DIR_FB_USER_IMAGE                @"FBUserImage"

#define DIR_MEDIA                        @"Media"

#define DIR_MEDIA_CONTACT                @"ContactImages"
#define DIR_MEDIA_CONTACT_NATIVE         @"Native"
#define DIR_MEDIA_CONTACT_PROFILE        @"MyProfile"
#define DIR_MEDIA_CONTACT_CHAT_GRID      @"ChatGrid"

#define DIR_MEDIA_AUDIO                  @"Audio"

#define DIR_MEDIA_SENT                   @"Sent"
#define DIR_MEDIA_RECEIVED               @"Received"

#define DIR_MEDIA_IMAGES                  @"Image"
#define DIR_MEDIA_IMAGES_PROCESSED                  @"Processed"



@interface IVFileLocator : NSObject

+(NSString*)getDocumentDirectoryPath;
+(NSString*)getLibraryDirectoryPath;
+(NSString*)getLibraryCacheDirectoryPath;
+(NSString*)getMediaDirectory;

+(NSString*)getFBUserPicPath:(NSString*)fileName;
+(NSString*)getNativeContactPicPath:(NSString*)fileName;
+(NSString*)getMyProfilePicPath:(NSString*)fileName;
+(NSString*)getCarrierLogoPath:(NSString *)fileName;
+(NSString *)getPromoImagePath:(NSString *)fileName;

+(NSString*)getMediaAudioDirectory;
+(NSString*)getMediaAudioReceivedDirectory;
+(NSString*)getMediaAudioSentDirectory;

+(NSString*)getMediaImageDirectory;
+(NSString*)getMediaImageProcessedDirectory;
+(NSString*)getMediaImagePath:(NSString*)fileName;


+(unsigned long long int)folderSize:(NSString *)folderPath;
+(BOOL)deleteDirAndSubDir:(NSString*)dirPath;
+(BOOL)deleteFileAtPath:(NSString*)filePath;

@end
