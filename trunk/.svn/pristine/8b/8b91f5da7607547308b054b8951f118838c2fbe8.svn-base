//
//  IVAudioLoader.h
//  InstaVoice
//
//  Created by adwivedi on 13/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IVAudioLoader : NSObject

+(void)loadAudioFileFromServerWithURL:(NSString*)serverPath andSaveToLocalPath:(NSString*)localPath withCompletionHandler:(void (^)(BOOL result))completionHandler;

+(void)loadImageFileFromServerWithURL:(NSString*)serverPath andSaveToLocalPath:(NSString*)localPath withCompletionHandler:(void (^)(BOOL result))completionHandler;

+(void)loadContactPicFileFromServerWithURL:(NSString*)serverPath andSaveToLocalPath:(NSString*)localPath withCompletionHandler:(void (^)(BOOL result))completionHandler;

+(NSString*)getTempSharedDirectoryPath;
+(BOOL)deleteFileAtPath:(NSString*)filePath;

+(BOOL) isNumeric:(NSString *) Numeric;
@end
