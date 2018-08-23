//
//  CustomAlbum.h
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 22/06/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface CustomAlbum : NSObject

//Creating album with given name
+(void)makeAlbumWithTitle:(NSString *)title onSuccess:(void(^)(NSString *AlbumId))onSuccess onError: (void(^)(NSError * error)) onError;

//Get the album by name
+(PHAssetCollection *)getMyAlbumWithName:(NSString*)AlbumName;

//Add a image
+(void)addNewAssetWithImage:(UIImage *)image toAlbum:(PHAssetCollection *)album onSuccess:(void(^)(NSString *ImageId))onSuccess onError: (void(^)(NSError * error)) onError;

+(NSArray *)getAssets:(PHFetchResult *)fetch;

@end
