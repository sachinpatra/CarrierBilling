//
//  IVColors.m
//  InstaVoice
//
//  Created by Kieraj Mumick on 6/12/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "IVColors.h"

@implementation IVColors

+ (UIColor *)colorFromRed:(int)red green:(int)green andBlue:(int)blue {return [UIColor colorWithRed:red/255. green:green/255. blue:blue/255. alpha:1];}

+ (UIColor *)redColor {return [UIColor colorWithRed:233./255 green:88./255 blue:75./255 alpha:1];}
+ (UIColor *)greenColor {return [UIColor colorWithRed:86./255 green:223./255 blue:82./255 alpha:1];}
+ (UIColor *)orangeColor {return [UIColor colorWithRed:1 green:175./255 blue:101./255 alpha:1];}
+ (UIColor *)pinkColor {return [UIColor colorWithRed:1 green:106./255 blue:103./255 alpha:1];}
+ (UIColor *)tealColor {return [UIColor colorWithRed:72./255 green:186./255 blue:187./255 alpha:1];}
+ (UIColor *)darkGreyColor {return [UIColor darkGrayColor];}
+ (UIColor *)lightGreyColor {return [UIColor lightGrayColor];}

//+ (UIColor *)greenFillColor {return [self colorFromRed:248 green:254 andBlue:248];}
//0xf7fef7
+ (UIColor *)greenFillColor {return [self colorFromRed:0xed green:0xfe andBlue:0xe7];}

//+ (UIColor *)greenOutlineColor {return [self colorFromRed:80 green:180 andBlue:73];}
//0x8fd788
+ (UIColor *)greenOutlineColor {return [self colorFromRed:0x30 green:0xaf andBlue:0x02];}

//+ (UIColor *)blueFillColor {return [self colorFromRed:240 green:251 andBlue:253];}
//0xeffafd
+ (UIColor *)blueFillColor {return [self colorFromRed:0xdf green:0xf3 andBlue:0xff];}

//+ (UIColor *)blueOutlineColor {return [self colorFromRed:83 green:175 andBlue:252];}
//0x60b3f0
+ (UIColor *)blueOutlineColor {return [self colorFromRed:0x00 green:0x8e andBlue:0xe0];}
//0x539acf
+ (UIColor *)bluePlayNewColor {return [self colorFromRed:83 green:154 andBlue:207];}



//+ (UIColor *)redFillColor {return [self colorFromRed:253 green:242 andBlue:242];}
//0xffe5e3
+ (UIColor *)redFillColor {return [self colorFromRed:0xf9 green:0xe1 andBlue:0xdf];}

//+ (UIColor *)redOutlineColor {return [self colorFromRed:241 green:91 andBlue:78];}
//0xf87c76
+ (UIColor *)redOutlineColor {return [self colorFromRed:0xda green:0x43 andBlue:0x36];}

//0xe1716b
+ (UIColor *)redPlayNewColor {return [self colorFromRed:0xe1 green:0x71 andBlue:0x6b];}

//+ (UIColor *)orangeOutlineColor {return [self colorFromRed:255 green:116 andBlue:0];}
//0xf2aa6f
+ (UIColor *)orangeOutlineColor {return [self colorFromRed:0xef green:0x9d andBlue:0x19];}

//+ (UIColor *)orangeFillColor {return [self colorFromRed:255 green:245 andBlue:240];}
//0xf9e8d3
+ (UIColor *)orangeFillColor {return [self colorFromRed:0xfb green:0xe6 andBlue:0xc4];}

//0xdc9b65
+ (UIColor *)orangePlayNewColor {return [self colorFromRed:0xdc green:0x9b andBlue:0x65];}

//+ (UIColor *)grayFillColor {return [UIColor colorWithWhite:.95 alpha:1];}
//0xf4f4f4
+ (UIColor *)grayFillColor {return [self colorFromRed:0xf4 green:0xf4 andBlue:0xf4];}

//+ (UIColor *)grayOutlineColor {return [UIColor colorWithWhite:.4 alpha:1];}
//0xb5b5b5
+ (UIColor *)grayOutlineColor {return [self colorFromRed:0x98 green:0x98 andBlue:0x98];}

+ (UIColor *)greyChatTextColor {return [self colorFromRed:130 green:130 andBlue:130];}

//DC
+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
    
    
}
+ (UIColor *)convertHexValueToUIColor:(NSString *)hexString {
      UIColor *color;
     if (hexString && [hexString length]) {
     unsigned rgbValue = 0;
     NSScanner *scanner = [NSScanner scannerWithString:hexString];
     [scanner setScanLocation:1]; // bypass '#' character
     [scanner scanHexInt:&rgbValue];
     
     color = [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
     }
     
     return color;
}
@end
