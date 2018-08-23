//
//  IVMediaLoader.m
//  InstaVoice
//
//  Created by adwivedi on 12/08/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "IVMediaLoader.h"
#import "IVImageProcessingOperation.h"
#import "IVFileLocator.h"
#import "CustomAlbum.h"

#define CUSTOMALBUM                 @"InstaVoice"

@interface IVMediaLoader() <IVImageProcessingOperationDelegate>
@end

static IVMediaLoader* _sharedMediaLoaderObj = Nil;
@implementation IVMediaLoader
-(id)init
{
    if(self = [super init])
    {
        _imageProcessingQueue = [[NSOperationQueue alloc]init];
        _imageProcessingQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

+(id)sharedIVMediaLoader
{
    if(_sharedMediaLoaderObj == nil)
    {
        _sharedMediaLoaderObj = [IVMediaLoader new];
    }
    return _sharedMediaLoaderObj;
}

+(void)clearSharedIVMediaLoader
{
    if(_sharedMediaLoaderObj != Nil)
        _sharedMediaLoaderObj = Nil;
}

#pragma mark - Image Download

-(UIImage*)getImageForLocalPath:(NSString *)localPath serverPath:(NSString *)serverPath
{
    localPath = [[localPath stringByDeletingPathExtension]stringByAppendingPathExtension:@"jpg"];
    localPath = [IVFileLocator getMediaImagePath:localPath];
    UIImage *image = nil;
    if(localPath != nil)
    {
        image = [UIImage imageWithContentsOfFile:localPath];
    }
    
    if(image == Nil)
    {
        if(![self checkIfImageIsAlreadyAddedInDownloadQueueForURL:localPath])
        {
            IVImageData* data = [[IVImageData alloc]init];
            data.imgLocalPath = localPath;
            data.imgServerPath = serverPath;
            data.thumbnailImage = NO;
            IVImageProcessingOperation* op = [[IVImageProcessingOperation alloc]initWithImageData:data ivImageProcessingOperationType:IVImageProcessingOperationTypeDownloadImage];
            op.delegate = self;
            [_imageProcessingQueue addOperation:op];
        }
    }
    return image;
}

#pragma mark - Thumbnail Image Download
-(UIImage*)getThumbnailImageForLocalPath:(NSString*)localPath serverPath:(NSString*)serverPath base64String:(NSString*)base64String
{
    localPath = [[localPath stringByDeletingPathExtension]stringByAppendingPathExtension:@"thumb"];
    localPath = [IVFileLocator getMediaImagePath:localPath];
    UIImage *image = nil;
    if(localPath != nil)
    {
        image = [UIImage imageWithContentsOfFile:localPath];
    }
    if(image == Nil && base64String != Nil && base64String.length > 0)
    {
        /* CMP
        NSString* formattedString = [@"data:image/png;base64," stringByAppendingString:base64String];
        NSURL *url = [NSURL URLWithString:formattedString];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:imageData];
         */
        image = [self decodeBase64ToImage:base64String saveToPath:localPath];
    }
    
    if(image == Nil)
    {
        if(![self checkIfImageIsAlreadyAddedInDownloadQueueForURL:localPath])
        {
            IVImageData* data = [[IVImageData alloc]init];
            data.imgLocalPath = localPath;
            data.imgServerPath = serverPath;
            data.thumbnailImage = YES;
            IVImageProcessingOperation* op = [[IVImageProcessingOperation alloc]initWithImageData:data ivImageProcessingOperationType:IVImageProcessingOperationTypeDownloadImage];
            op.queuePriority = NSOperationQueuePriorityHigh;
            op.delegate = self;
            [_imageProcessingQueue addOperation:op];
        }
    }
    return image;
    
}

-(BOOL)checkIfImageIsAlreadyAddedInDownloadQueueForURL:(NSString*)localPath
{
    for(IVImageProcessingOperation* op in [_imageProcessingQueue operations])
    {
        if([op.imageData.imgLocalPath isEqualToString:localPath])
            return TRUE;
    }
    return FALSE;
}

-(void)saveImageToLibraryAfterDownload:(NSDictionary *)imageDic
{
    NSDictionary *dic = imageDic;
    NSString* msgLocalPath = [dic valueForKey:@"MSG_LOCAL_PATH"];
    UIImage *image = nil;
    if(msgLocalPath && msgLocalPath.length > 1)
    {
        NSString* localPath = [[IVFileLocator getMediaImagePath:msgLocalPath]stringByAppendingPathExtension:@"jpg"];
        if(localPath != nil)
        {
            image = [UIImage imageWithContentsOfFile:localPath];
            if(image)
            {
                NSUserDefaults *imageIdentifier = [NSUserDefaults standardUserDefaults];
                NSString *msgID = [NSString stringWithFormat:@"%ld",[[dic valueForKey:@"MSG_ID"] integerValue]];
                
                __block PHAssetCollection *collection;
                PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
                fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@",CUSTOMALBUM];
                collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions].firstObject;
                fetchOptions.predicate = [NSPredicate predicateWithFormat:@"localIdentifier = %@",[imageIdentifier valueForKey:msgID]];
                PHFetchResult *collectionResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
                
                if (collectionResult.count == 0) {
                    [CustomAlbum addNewAssetWithImage:image toAlbum:[CustomAlbum getMyAlbumWithName:CUSTOMALBUM] onSuccess:^(NSString *ImageId) {
                        [imageIdentifier setValue:ImageId forKey:msgID];
                        [imageIdentifier synchronize];
                    } onError:^(NSError *error) {
                        //CMP NSLog(@"probelm in saving image");
                    }];
                }
                
            }else{
                NSUserDefaults *imageLocalPath = [NSUserDefaults standardUserDefaults];
                [imageLocalPath setBool:NO forKey:localPath];
                [imageLocalPath synchronize];
            }
        }
    }
    if(image == Nil)
    {
        NSString *msgContent = [dic valueForKey:@"MSG_CONTENT"];
        NSData *data = [msgContent dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSMutableDictionary *imageData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSMutableArray* imageArr = [imageData valueForKey:@"img"];
        for(NSMutableDictionary* imageDic in imageArr)
        {
            NSString* imageUrl = [imageDic valueForKey:@"url"];
            NSString* msgLocalPath = [dic valueForKey:@"MSG_LOCAL_PATH"];
            if(!msgLocalPath || msgLocalPath.length == 0)
            {
                msgLocalPath = [[dic valueForKey:@"MSG_ID"]stringValue];
            }
            
            UIImage* imgMain = [[IVMediaLoader sharedIVMediaLoader]getImageForLocalPath:msgLocalPath serverPath:imageUrl];
            if(imgMain)
            {
                NSUserDefaults *imageIdentifier = [NSUserDefaults standardUserDefaults];
                NSString *msgID = [NSString stringWithFormat:@"%ld",[[dic valueForKey:@"MSG_ID"] integerValue]];
                
                __block PHAssetCollection *collection;
                PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
                fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@",CUSTOMALBUM];
                collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions].firstObject;
                fetchOptions.predicate = [NSPredicate predicateWithFormat:@"localIdentifier = %@",[imageIdentifier valueForKey:msgID]];
                PHFetchResult *collectionResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
                
                if (collectionResult.count == 0) {
                    [CustomAlbum addNewAssetWithImage:imgMain toAlbum:[CustomAlbum getMyAlbumWithName:CUSTOMALBUM] onSuccess:^(NSString *ImageId) {
                        [imageIdentifier setValue:ImageId forKey:msgID];
                        [imageIdentifier synchronize];
                    } onError:^(NSError *error) {
                        //CMP NSLog(@"probelm in saving image");
                    }];
                }
            }
        }
    }
}


#pragma mark - Image Download Response Handling
-(void)ivImageProcessingOperationType:(IVImageProcessingOperationType)type completedWithResponse:(IVImageData *)imageData
{
    //Received Image Data from server.
    switch (type) {
            
        case IVImageProcessingOperationTypeDownloadImage:
        {
            if(imageData.thumbnailImage)
            {
                if(![self checkIfPendingThumnailDownload])
                {
                //tell base conversation screen to reload data.
                    [self.delegate ivMediaLoaderDidFinishDownloadingImageData:imageData];
                }
            }
            else
            {
//                UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData.imgData], nil, nil, nil);
                if([_imageProcessingQueue operationCount] == 0)
                {
                    NSUserDefaults *imageLocalPath = [NSUserDefaults standardUserDefaults];
                    if ([imageLocalPath valueForKey:[imageData valueForKey:@"imgLocalPath"]]) {
                        [imageLocalPath setBool:NO forKey:[imageData valueForKey:@"imgLocalPath"]];
                        [imageLocalPath synchronize];
                        [self saveImageToLibraryAfterDownload:[imageLocalPath dictionaryForKey:[imageData valueForKey:@"imgServerPath"]]];
                    }
                    [self.delegate ivMediaLoaderDidFinishDownloadingImageData:imageData];
                }
            }
        }
            break;
            
        case IVImageProcessingOperationTypeProcessImage:
            break;
            
        case IVImageProcessingOperationTypeUploadImage:
            break;
            
        default:
            break;
    }
}

-(BOOL)checkIfPendingThumnailDownload
{
    NSArray* operations = [_imageProcessingQueue operations];
    for(IVImageProcessingOperation* op in operations)
    {
        IVImageData* data = op.imageData;
        if(data.thumbnailImage)
            return true;
    }
    return false;
}

-(UIImage *)decodeBase64ToImage:(NSString *)strBase64SData saveToPath:(NSString*)localPath
{
    
    NSData* data;
    if ([NSData instancesRespondToSelector:@selector(initWithBase64EncodedString:options:)])
    {
        data = [[NSData alloc] initWithBase64EncodedString:strBase64SData
                                                   options:NSDataBase64DecodingIgnoreUnknownCharacters];  // iOS 7.0 and later
    }
    /*
    else
    {
        data = [[NSData alloc] initWithBase64Encoding:strBase64SData];  // pre iOS7
    }*/
    
    if(data) {
        [data writeToFile:localPath  atomically:YES];
        return [UIImage imageWithData:data];
    }
    
    return nil;
}

@end
