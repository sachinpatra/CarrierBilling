//
//  IVImageUtility.h
//  InstaVoice
//
//  Created by adwivedi on 12/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVImageUtility : NSObject

/**
 * This Function is used to create UIImage object from  filePath.
 */
+(UIImage *)getUIImageFromFilePath:(NSString*)filePath;

+(UIImage*)cropImage:(UIImage*)oldImg targetSize:(CGSize)targetSize;

+(UIImage *)resizeImageToSize:(UIImage*)sourceImage targerSize:(CGSize)targetSize;

+(UIColor *)setColorDefaultImage:(NSString *)receiverId ;



+(UIColor*)colorWithHex:(NSString*)hex alpha:(CGFloat)alpha;

/**
 * This function is used to fixed the rotation of image.
 */
+(UIImage *)fixrotation:(UIImage *)image;

+(CGSize)getImageDimensions:(NSString*)imagePath;

+(BOOL)isImageValidForServerUpload:(NSDictionary*)dic;

@end
