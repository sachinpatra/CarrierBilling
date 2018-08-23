//
//  IVImageUtility.m
//  InstaVoice
//
//  Created by adwivedi on 12/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVImageUtility.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

const CFStringRef kUTTypeHEVC  = CFSTR("public.heic");

@implementation IVImageUtility
#pragma mark - Image related work
+(UIImage *)getUIImageFromFilePath:(NSString*)filePath
{
    UIImage *image = nil;
    if(filePath != nil && [filePath length] >0)
    {
        image = [[UIImage alloc] initWithContentsOfFile:filePath];
    }
    return image;
}

+(UIColor *)setColorDefaultImage:(NSString *)receiverId {
    
    int hashValue = 0;
    int startRange = 0;
    if (receiverId != nil && [receiverId length]>0)
    {
        for (int i = 1; i <=receiverId.length; i++)
        {
            if(i == 0)
            {
                startRange = 0;
            }
            else
            {
                startRange = i-1;
            }
            char h = [[receiverId substringWithRange:NSMakeRange(startRange, 1)] characterAtIndex:0];
            hashValue = (int)h + hashValue;
        }
    }
    hashValue = (int) (hashValue % 5);
    switch (hashValue)
    {
        // the UIDs for this pallette on http://paletton.com are as follows:
        // 700220kiCFn8GVde7NVmtwSqXtg
        // 7000u0kiCFn8GVde7NVmtwSqXtg
        // you can view the pallette by going to http://paletton.com/palette.php?uid=<<UID>>
        case 0: return [UIColor colorWithRed:1 green:.42 blue:.42 alpha:1]; // Pastel Red
        case 1: return [UIColor colorWithRed:1 green:.682 blue:.42 alpha:1]; // Pastel Orange
        case 2: return [UIColor colorWithRed:.361 green:.867 blue:.351 alpha:1]; // Pastel Green
        case 3: return [UIColor colorWithRed:.702 green:.329 blue:.769 alpha:1]; // Pastel Purple
        case 4: return  [UIColor colorWithRed:.306 green:.729 blue:.729 alpha:1]; // Pastel Teal
        default: return [UIColor colorWithRed:.918 green:.984 blue:.412 alpha:1]; // Pastel Yellow
    }
}


+(UIImage*)cropImage:(UIImage*)oldImg targetSize:(CGSize)targetSize
{
    int orgImgHeight = oldImg.size.height;
    int orgImgWidth = oldImg.size.width;
    
    double inRatio = (double)orgImgHeight/orgImgWidth;
    double outRatio = (double)targetSize.height/targetSize.width;
    
    int x1 = 0;
    int y1 = 0;
    int x2 = orgImgWidth;
    int y2 = orgImgHeight;
    
    if(inRatio > outRatio)
    {
        double temp = outRatio*(double)x2;
        int hNew = (int)temp;
        int hCut = y2-hNew;
        y1 = hCut/4;
        y2 = y1 + hNew;
    }
    else
    {
        double temp = (double)y2 / outRatio;
        int wNew = (int)temp;
        int wCut = x2 - wNew;
        x1 = wCut / 2;
        x2 = x1 + wNew;
    }
    UIImage *newImage = nil;
    
    
    
    CGPoint p1 = CGPointMake(x1, y1);
    CGPoint p2 = CGPointMake(x1, y2);
    int newHigth = [self getDistance:p1 :p2];
    p2 = CGPointMake(x2, y1);
    int newWidth = [self getDistance:p1 :p2];
    
    CGRect cropRect = CGRectMake(x1, y1, newWidth, newHigth);
    CGImageRef imageRef = CGImageCreateWithImageInRect([oldImg CGImage], cropRect);
    newImage = [UIImage imageWithCGImage:imageRef];
    if(imageRef != nil)
        CFRelease(imageRef);
    return newImage;
}

+(UIImage *)resizeImageToSize:(UIImage*)sourceImage targerSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    newImage = [self scaleImage:sourceImage toSize:targetSize];
    return newImage ;
}

+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize {
    
    float width = newSize.width;
    float height = newSize.height;
    
    UIGraphicsBeginImageContext(newSize);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    float widthRatio = image.size.width / width;
    float heightRatio = image.size.height / height;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    width = image.size.width / divisor;
    height = image.size.height / divisor;
    
    rect.size.width  = width;
    rect.size.height = height;
    
    //indent in case of width or height difference
    float offset = (width - height) / 2;
    if (offset > 0) {
        rect.origin.y = offset;
    }
    else {
        rect.origin.x = -offset;
    }
    
    [image drawInRect: rect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
    
}



+(UIColor*)colorWithHex:(NSString*)hex alpha:(CGFloat)alpha
{
    
    //    assert(7 == [hex length]);
    //    assert('#' == [hex characterAtIndex:0]);
    NSString *redHex = @"";
    NSString *greenHex = @"";
    NSString *blueHex = @"";
    if(hex != nil && [hex length]>0)
    {
        redHex = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(1, 2)]];
        greenHex = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(3, 2)]];
        blueHex = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(5, 2)]];
    }
    unsigned red = 0;
    NSScanner *rScanner = [NSScanner scannerWithString:redHex];
    [rScanner scanHexInt:&red];
    
    
    unsigned green = 0;
    NSScanner *gScanner = [NSScanner scannerWithString:greenHex];
    [gScanner scanHexInt:&green];
    
    unsigned blue = 0;
    NSScanner *bScanner = [NSScanner scannerWithString:blueHex];
    [bScanner scanHexInt:&blue];
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
    
    
}



+(UIImage *)fixrotation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp)
    {
        return image;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+(double)getDistance:(CGPoint)one :(CGPoint)two
{
    return sqrt((two.x - one.x)*(two.x - one.x) + (two.y - one.y)*(two.y - one.y));
}

+(CGSize)getImageDimensions:(NSString*)imagePath
{
    CGSize size = CGSizeMake(0, 0);
    NSURL *imageFileURL = [NSURL fileURLWithPath:imagePath];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)imageFileURL, NULL);
    if (imageSource == NULL) {
        // Error loading image
        return size;
    }
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache,
                             nil];
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
    if (imageProperties) {
        NSNumber *width = (NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        NSNumber *height = (NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        CFRelease(imageProperties);
        size = CGSizeMake(width.floatValue, height.floatValue);
    }
    CFRelease(imageSource);
    return size;
}

+(BOOL)isImageValidForServerUpload:(NSDictionary*)info
{
    BOOL processImage = false;
    NSURL *assetURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    NSString *extension = [assetURL pathExtension];
    CFStringRef imageUTI = (UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)extension , NULL));
    
    if (UTTypeConformsTo(imageUTI, kUTTypeJPEG)){
        processImage = true;
    }
    else if (UTTypeConformsTo(imageUTI, kUTTypePNG)){
        processImage = true;
    }
    else if(UTTypeConformsTo(imageUTI,kUTTypeHEVC)) {
        processImage = true;
    }
    else {
        processImage = false;
    }
    CFRelease(imageUTI);
    
    return processImage;
}
@end
