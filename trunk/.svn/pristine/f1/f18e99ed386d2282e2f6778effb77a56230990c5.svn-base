//
//  IVMediaLoader.h
//  InstaVoice
//
//  Created by adwivedi on 12/08/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVImageProcessingOperation.h"
#import <UIKit/UIKit.h>

@protocol IVMediaLoaderDelegate <NSObject>
-(void)ivMediaLoaderDidFinishDownloadingImageData:(IVImageData*)imageData;
@end

@interface IVMediaLoader : NSObject
{
    NSOperationQueue* _imageProcessingQueue;
}
+(id)sharedIVMediaLoader;
+(void)clearSharedIVMediaLoader;

@property(nonatomic,weak)id<IVMediaLoaderDelegate> delegate;

-(UIImage*)getImageForLocalPath:(NSString*)localPath serverPath:(NSString*)serverPath;
-(UIImage*)getThumbnailImageForLocalPath:(NSString*)localPath serverPath:(NSString*)serverPath base64String:(NSString*)base64String;


@end
