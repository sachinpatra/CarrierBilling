//
//  CustomAlbum.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 22/06/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "CustomAlbum.h"

@implementation CustomAlbum

#pragma mark - PHPhoto

+(void)makeAlbumWithTitle:(NSString *)title onSuccess:(void(^)(NSString *AlbumId))onSuccess onError: (void(^)(NSError * error)) onError
{
    //Check weather the album already exist or not
    if (![self getMyAlbumWithName:title]) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            // Request editing the album.
            PHAssetCollectionChangeRequest *createAlbumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
            
            // Get a placeholder for the new asset and add it to the album editing request.  "_OBJC_CLASS_$_PHPhotoLibrary", referenced from:

            PHObjectPlaceholder * placeHolder = [createAlbumRequest placeholderForCreatedAssetCollection];
            if (placeHolder) {
                onSuccess(placeHolder.localIdentifier);
            }
            
        } completionHandler:^(BOOL success, NSError *error) {
            //CMP NSLog(@"Finished adding asset. %@", (success ? @"Success" : error));
            if (error) {
                onError(error);
            }
        }];
    }
}

+(void)addNewAssetWithImage:(UIImage *)image toAlbum:(PHAssetCollection *)album onSuccess:(void(^)(NSString *ImageId))onSuccess onError: (void(^)(NSError * error)) onError
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // Request creating an asset from the image.
        PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        // Request editing the album.
        PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:album];
        
        // Get a placeholder for the new asset and add it to the album editing request.
        PHObjectPlaceholder * placeHolder = [createAssetRequest placeholderForCreatedAsset];
        [albumChangeRequest addAssets:@[ placeHolder ]];
        
        if (placeHolder) {
            onSuccess(placeHolder.localIdentifier);
        }
        
        
    } completionHandler:^(BOOL success, NSError *error) {
        
        if (error) {
            onError(error);
        }
    }];
}


+(PHAssetCollection *)getMyAlbumWithName:(NSString*)AlbumName
{
#if 0
    NSString * identifier = [[NSUserDefaults standardUserDefaults]objectForKey:kAlbumIdentifier];
    if (!identifier) return nil;
    PHFetchResult *assetCollections = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[identifier]
                                                                                           options:nil];
#else
    PHFetchResult *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                               subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                               options:nil];
#endif
    //CMP NSLog(@"assetCollections.count = %lu", assetCollections.count);
    if (assetCollections.count == 0) return nil;
    
    __block PHAssetCollection * myAlbum;
    [assetCollections enumerateObjectsUsingBlock:^(PHAssetCollection *album, NSUInteger idx, BOOL *stop) {
        //CMP NSLog(@"album:%@", album);
        //CMP NSLog(@"album.localizedTitle:%@", album.localizedTitle);
        if ([album.localizedTitle isEqualToString:AlbumName]) {
            myAlbum = album;
            *stop = YES;
        }
    }];
    
    if (!myAlbum) return nil;
    return myAlbum;
}

+(NSArray *)getAssets:(PHFetchResult *)fetch
{
    __block NSMutableArray * assetArray = NSMutableArray.new;
    [fetch enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        //CMP NSLog(@"asset:%@", asset);
        [assetArray addObject:asset];
    }];
    return assetArray;
}

@end
