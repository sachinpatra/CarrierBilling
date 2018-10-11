//
//  IVFileLocator.m
//  InstaVoice
//
//  Created by adwivedi on 24/07/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "IVFileLocator.h"
#import "Logger.h"

@implementation IVFileLocator

#pragma mark - Document, Library and Caches directory.
+(NSString*)getDocumentDirectoryPath
{
    NSString *documentDirPath = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    //document Dir Path
    documentDirPath = [paths objectAtIndex:0];
    return documentDirPath;
}

+(NSString*)getLibraryDirectoryPath
{
    NSString *documentDirPath = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSLibraryDirectory, NSUserDomainMask, YES);
    //document Dir Path
    documentDirPath = [paths objectAtIndex:0];
    return documentDirPath;
}

+(NSString*)getLibraryCacheDirectoryPath
{
    NSString *documentDirPath = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    //document Dir Path
    documentDirPath = [paths objectAtIndex:0];
    return documentDirPath;
}


/*
 This function create directory to given path
 */
+(BOOL)mkDirectory:(NSString*)dirPath
{
    NSError *error;
    if (dirPath == nil || [dirPath length]== 0)
    {
        return NO;
    }
    return  [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
}

+(BOOL)checkIfFileExistAtPath:(NSString*)path isDirectory:(BOOL*)isDirectory
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:isDirectory];
}

+(BOOL)checkAndCreateDirectoryIfNotExist:(NSString*)path
{
    BOOL isDirectory = FALSE;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    
    if(!(isFileExist && isDirectory))
    {
        if(![self mkDirectory:path])
        {
            return FALSE;
        }
    }
    return TRUE;
}


#pragma mark - FB Directory /Library/Caches/FBUserImage

+(NSString*)getFBUserPicDirectory
{
    NSString* path = [[self getLibraryCacheDirectoryPath]stringByAppendingPathComponent:DIR_FB_USER_IMAGE];
    [self checkAndCreateDirectoryIfNotExist:path];
    return path;
}

+(NSString*)getFBUserPicPath:(NSString*)fileName
{
    if(fileName == Nil || fileName.length == 0)
        return @"";
    return [[self getFBUserPicDirectory]stringByAppendingPathComponent:[fileName lastPathComponent]];
}


#pragma mark - Contact Directory /Library/Media/Contact/NativeContact

+(NSString*)getMediaDirectory
{
    NSString* path = [[self getLibraryDirectoryPath]stringByAppendingPathComponent:DIR_MEDIA];
    [self checkAndCreateDirectoryIfNotExist:path];
    return path;
}

+(NSString*)getMediaContactDirectory
{
    NSString* path = [[self getMediaDirectory]stringByAppendingPathComponent:DIR_MEDIA_CONTACT];
    [self checkAndCreateDirectoryIfNotExist:path];
    return path;
}

+(NSString*)getMediaContactNativeDirectory
{
    NSString* path = [[self getMediaContactDirectory]stringByAppendingPathComponent:DIR_MEDIA_CONTACT_NATIVE];
    [self checkAndCreateDirectoryIfNotExist:path];
    return path;
}

+(NSString*)getNativeContactPicPath:(NSString*)fileName
{
    if(fileName == Nil || fileName.length == 0)
        return @"";
    return [[self getMediaContactNativeDirectory]stringByAppendingPathComponent:[fileName lastPathComponent]];
}

//Sachin
#pragma mark - Contact Directory /Library/Media/Bundle
+(NSString*)getBundleDirectory {
    NSString* path = [[self getMediaDirectory]stringByAppendingPathComponent:DIR_BUNDLE];
    [self checkAndCreateDirectoryIfNotExist:path];
    return path;
}
+(NSString*)getBundlePicPath:(NSString*)fileName {
    if(fileName == Nil || fileName.length == 0)
        return @"";
    return [[self getBundleDirectory]stringByAppendingPathComponent:[fileName lastPathComponent]];
}

//Sachin

#pragma mark - Contact Directory /Library/Media/Contact/MyProfile
+(NSString*)getMediaContactMyProfileDirectory
{
    NSString* path = [[self getMediaContactDirectory]stringByAppendingPathComponent:DIR_MEDIA_CONTACT_PROFILE];
    [self checkAndCreateDirectoryIfNotExist:path];
    return path;
}

+(NSString*)getMyProfilePicPath:(NSString*)fileName
{
    if(fileName == Nil || fileName.length == 0)
        return @"";
    return [[self getMediaContactMyProfileDirectory]stringByAppendingPathComponent:[fileName lastPathComponent]];
}

+(NSString *)getCarrierLogoPath:(NSString *)fileName {
    
    if (fileName == nil || fileName.length == 0)
        return @"";
    return [[self getMediaImageDirectory]stringByAppendingPathComponent:[fileName lastPathComponent]];
}

+(NSString *)getPromoImagePath:(NSString *)fileName {
    
    if (fileName == nil || fileName.length == 0)
        return @"";
    return [[self getMediaImageDirectory]stringByAppendingPathComponent:[fileName lastPathComponent]];
}


#pragma mark - Contact Directory /Library/Media/Contact/ChatGrid
+(NSString*)getMediaContactChatGridDirectory
{
    NSString* path = [[self getMediaContactDirectory]stringByAppendingPathComponent:DIR_MEDIA_CONTACT_CHAT_GRID];
    [self checkAndCreateDirectoryIfNotExist:path];
    return path;
}

+(NSString*)getChatGridContactPicPath:(NSString*)fileName
{
    if(fileName == Nil || fileName.length == 0)
        return @"";
    return [[self getMediaContactChatGridDirectory]stringByAppendingPathComponent:[fileName lastPathComponent]];
}

#pragma mark - Contact Directory /Library/Media/Audio/ sent and received
+(NSString*)getMediaAudioDirectory
{
    NSString* path = [[self getMediaDirectory]stringByAppendingPathComponent:DIR_MEDIA_AUDIO];
    [self checkAndCreateDirectoryIfNotExist:path];
    return path;
}

+(NSString*)getMediaAudioSentDirectory
{
    NSString* path = [[self getMediaAudioDirectory]stringByAppendingPathComponent:DIR_MEDIA_SENT];
    [self checkAndCreateDirectoryIfNotExist:path];
    return path;
}

+(NSString*)getMediaAudioReceivedDirectory
{
    NSString* path = [[self getMediaAudioDirectory]stringByAppendingPathComponent:DIR_MEDIA_RECEIVED];
    [self checkAndCreateDirectoryIfNotExist:path];
    return path;
}

#pragma mark - Contact Directory /Library/Media/Image/ sent and received
+(NSString*)getMediaImageDirectory
{
    NSString* path = [[self getMediaDirectory]stringByAppendingPathComponent:DIR_MEDIA_IMAGES];
    [self checkAndCreateDirectoryIfNotExist:path];
    return path;
}
+(NSString*)getMediaImageProcessedDirectory
{
    NSString* path = [[self getMediaImageDirectory]stringByAppendingPathComponent:DIR_MEDIA_IMAGES_PROCESSED];
    [self checkAndCreateDirectoryIfNotExist:path];
    return path;
}
+(NSString*)getMediaImagePath:(NSString*)fileName
{
    if(fileName == Nil || fileName.length == 0)
        return @"";
    return [[self getMediaImageProcessedDirectory]stringByAppendingPathComponent:[fileName lastPathComponent]];
}



+(unsigned long long int)folderSize:(NSString *)folderPath
{
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject])
    {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}


+(BOOL)deleteDirAndSubDir:(NSString*)dirPath
{
    BOOL result = TRUE;
    if(dirPath != nil && [dirPath length]>0)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        for (NSString *file in [fm contentsOfDirectoryAtPath:dirPath error:&error])
        {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", dirPath, file] error:&error];
            if (!success || error)
            {
                result = FALSE;
                EnLoge(@"Error in Dir file Deletion");
            }
        }
        if(result)
        {
            BOOL success =  [fm removeItemAtPath:dirPath error:&error];
            if (!success || error)
            {
                result = FALSE;
                EnLoge(@"Error in Dir Deletion");
            }
        }
    }
    else
    {
        result = FALSE;
    }
    return result;
}

+(BOOL)deleteFileAtPath:(NSString*)filePath
{
    BOOL result = TRUE;
    if(filePath != nil && [filePath length]>0)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isFileExist = [fm fileExistsAtPath:filePath];
        if(isFileExist)
        {
            NSError *error = nil;
            BOOL success = [fm removeItemAtPath:filePath error:&error];
            if (!success || error)
            {
                result = FALSE;
                EnLoge(@"Error in file Deletion : %@",error);
            }
        }
        else
        {
            EnLogi(@"file does not exist at given path : %@",filePath);
        }
    }
    else
    {
        result = FALSE;
    }
    return result;
}

@end
