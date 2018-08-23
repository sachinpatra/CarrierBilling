//
//  IVColors.h
//  InstaVoice
//
//  Created by Kieraj Mumick on 6/12/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

// RGB color value in hex
#define LOCATION_TEXT           0x767779
#define FROM_USER_TEXT          0x767779
#define MSG_TIME_TEXT           0x5c5c5c
#define DURATION_AUDIO_LISTENED 0xa2a5a5
#define DURATION_AUDIO_NONIV    0xa2a5a5
#define DURATION_AUDIO_SENT     0x30af02
#define TIMESTAMP_AUDIO_SENT    0x30af02

#define FROM_USER_TEXT_COLOR    0x0090ff
#define TO_USER_TEXT_COLOR      FROM_USER_TEXT_COLOR

@interface IVColors : NSObject

+ (UIColor *)redColor;
+ (UIColor *)greenColor;
+ (UIColor *)orangeColor;
+ (UIColor *)pinkColor;
+ (UIColor *)tealColor;
+ (UIColor *)darkGreyColor;
+ (UIColor *)lightGreyColor;

+ (UIColor *)greenOutlineColor;
+ (UIColor *)greenFillColor;
+ (UIColor *)blueOutlineColor;
+ (UIColor *)blueFillColor;
+ (UIColor *)bluePlayNewColor;
+ (UIColor *)redOutlineColor;
+ (UIColor *)redFillColor;
+ (UIColor *)redPlayNewColor;
+ (UIColor *)orangeOutlineColor;
+ (UIColor *)orangePlayNewColor;
+ (UIColor *)orangeFillColor;
+ (UIColor *)grayOutlineColor;
+ (UIColor *)grayFillColor;


+ (UIColor *)greyChatTextColor;
+ (UIColor*)colorWithHexString:(NSString*)hex;
+ (UIColor *)convertHexValueToUIColor:(NSString *)hexString;
@end
