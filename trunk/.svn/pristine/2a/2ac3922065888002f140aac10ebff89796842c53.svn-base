//
//  VoipUtils.m
//  InstaVoice
//
//  Created by Pandian on 6/29/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>
#import "VoipUtils.h"
#import "Logger.h"

@implementation VoipUtils

+ (NSString *)deviceModelIdentifier {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([machine isEqual:@"iPad1,1"])
        return @"iPad";
    else if ([machine isEqual:@"iPad2,1"])
        return @"iPad 2";
    else if ([machine isEqual:@"iPad2,2"])
        return @"iPad 2";
    else if ([machine isEqual:@"iPad2,3"])
        return @"iPad 2";
    else if ([machine isEqual:@"iPad2,4"])
        return @"iPad 2";
    else if ([machine isEqual:@"iPad3,1"])
        return @"iPad 3";
    else if ([machine isEqual:@"iPad3,2"])
        return @"iPad 3";
    else if ([machine isEqual:@"iPad3,3"])
        return @"iPad 3";
    else if ([machine isEqual:@"iPad3,4"])
        return @"iPad 4";
    else if ([machine isEqual:@"iPad3,5"])
        return @"iPad 4";
    else if ([machine isEqual:@"iPad3,6"])
        return @"iPad 4";
    else if ([machine isEqual:@"iPad4,1"])
        return @"iPad Air";
    else if ([machine isEqual:@"iPad4,2"])
        return @"iPad Air";
    else if ([machine isEqual:@"iPad4,3"])
        return @"iPad Air";
    else if ([machine isEqual:@"iPad5,3"])
        return @"iPad Air 2";
    else if ([machine isEqual:@"iPad5,4"])
        return @"iPad Air 2";
    else if ([machine isEqual:@"iPad6,7"])
        return @"iPad Pro 12.9";
    else if ([machine isEqual:@"iPad6,8"])
        return @"iPad Pro 12.9";
    else if ([machine isEqual:@"iPad6,3"])
        return @"iPad Pro 9.7";
    else if ([machine isEqual:@"iPad6,4"])
        return @"iPad Pro 9.7";
    else if ([machine isEqual:@"iPad2,5"])
        return @"iPad mini";
    else if ([machine isEqual:@"iPad2,6"])
        return @"iPad mini";
    else if ([machine isEqual:@"iPad2,7"])
        return @"iPad mini";
    else if ([machine isEqual:@"iPad4,4"])
        return @"iPad mini 2";
    else if ([machine isEqual:@"iPad4,5"])
        return @"iPad mini 2";
    else if ([machine isEqual:@"iPad4,6"])
        return @"iPad mini 2";
    else if ([machine isEqual:@"iPad4,7"])
        return @"iPad mini 3";
    else if ([machine isEqual:@"iPad4,8"])
        return @"iPad mini 3";
    else if ([machine isEqual:@"iPad4,9"])
        return @"iPad mini 3";
    else if ([machine isEqual:@"iPad5,1"])
        return @"iPad mini 4";
    else if ([machine isEqual:@"iPad5,2"])
        return @"iPad mini 4";
    
    else if ([machine isEqual:@"iPhone1,1"])
        return @"iPhone";
    else if ([machine isEqual:@"iPhone1,2"])
        return @"iPhone 3G";
    else if ([machine isEqual:@"iPhone2,1"])
        return @"iPhone 3GS";
    else if ([machine isEqual:@"iPhone3,1"])
        return @"iPhone 4";
    else if ([machine isEqual:@"iPhone3,2"])
        return @"iPhone 4";
    else if ([machine isEqual:@"iPhone3,3"])
        return @"iPhone 4";
    else if ([machine isEqual:@"iPhone4,1"])
        return @"iPhone 4S";
    else if ([machine isEqual:@"iPhone5,1"])
        return @"iPhone5,2	iPhone 5";
    else if ([machine isEqual:@"iPhone5,3"])
        return @"iPhone5,4	iPhone 5c";
    else if ([machine isEqual:@"iPhone6,1"])
        return @"iPhone6,2	iPhone 5s";
    else if ([machine isEqual:@"iPhone7,2"])
        return @"iPhone 6";
    else if ([machine isEqual:@"iPhone7,1"])
        return @"iPhone 6 Plus";
    else if ([machine isEqual:@"iPhone8,1"])
        return @"iPhone 6s";
    else if ([machine isEqual:@"iPhone8,2"])
        return @"iPhone 6s Plus";
    else if ([machine isEqual:@"iPhone8,4"])
        return @"iPhone SE";
    else if ([machine isEqual:@"iPhone9,1"])
        return @"iPhone 7";
    else if ([machine isEqual:@"iPhone9,3"])
        return @"iPhone 7";
    else if ([machine isEqual:@"iPhone9,2"])
        return @"iPhone 7 Plus";
    else if ([machine isEqual:@"iPhone9,4"])
        return @"iPhone 7 Plus";
    else if ([machine isEqual:@"iPhone10,1"])
        return @"iPhone 8";
    else if ([machine isEqual:@"iPhone10,4"])
        return @"iPhone 8";
    else if ([machine isEqual:@"iPhone10,2"])
        return @"iPhone 8 Plus";
    else if ([machine isEqual:@"iPhone10,5"])
        return @"iPhone 8 Plus";
    else if ([machine isEqual:@"iPhone10,3"])
        return @"iPhone X";
    else if ([machine isEqual:@"iPhone10,6"])
        return @"iPhone X";
    
    
    else if ([machine isEqual:@"iPod1,1"])
        return @"iPod touch";
    else if ([machine isEqual:@"iPod2,1"])
        return @"iPod touch 2G";
    else if ([machine isEqual:@"iPod3,1"])
        return @"iPod touch 3G";
    else if ([machine isEqual:@"iPod4,1"])
        return @"iPod touch 4G";
    else if ([machine isEqual:@"iPod5,1"])
        return @"iPod touch 5G";
    else if ([machine isEqual:@"iPod7,1"])
        return @"iPod touch 6G";
    
    else if ([machine isEqual:@"x86_64"])
        return @"simulator 64bits";
    
    // none matched: cf https://www.theiphonewiki.com/wiki/Models for the whole list
    KLog1(@"%s: Oops, unknown machine %@... consider completing me!", __FUNCTION__, machine);
    return machine;
}

@end

@implementation UIImage (squareCrop)

- (UIImage *)squareCrop {
    // This calculates the crop area.
    
    size_t originalWidth = CGImageGetWidth(self.CGImage);
    size_t originalHeight = CGImageGetHeight(self.CGImage);
    
    size_t edge = MIN(originalWidth, originalHeight);
    
    float posX = (originalWidth - edge) / 2.0f;
    float posY = (originalHeight - edge) / 2.0f;
    
    CGRect rect = CGRectMake(posX, posY, edge, edge);
    
    // Create bitmap image from original image data,
    // using rectangle to specify desired crop area
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return img; /*
                 UIImage *ret = nil;
                 
                 
                 
                 CGRect cropSquare = CGRectMake(posX, posY, edge, edge);
                 
                 //	CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], cropSquare);
                 //	ret = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
                 //
                 //	CGImageRelease(imageRef);
                 
                 CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropSquare);
                 ret = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
                 CGImageRelease(imageRef);
                 
                 
                 return ret;*/
}

- (UIImage *)scaleToSize:(CGSize)size squared:(BOOL)squared {
    UIImage *scaledImage = self;
    if (squared) {
        //		scaledImage = [self squareCrop];
        size.width = size.height = MAX(size.width, size.height);
    }
    
    UIGraphicsBeginImageContext(size);
    
    [scaledImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end

