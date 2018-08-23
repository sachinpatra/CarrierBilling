//
//  ScreenUtility.h
//  InstaVoice
//
//  Created by Vivek Mudgil on 21/01/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "CustomIOS7AlertView.h"
#import "SizeMacro.h"

#ifndef NSFoundationVersionNumber_iOS_6_1
#define NSFoundationVersionNumber_iOS_6_1 993.00
#endif

@interface ScreenUtility : NSObject

#pragma mark Varibles
+(CustomIOS7AlertView *)alertPopup ;                //For alerts of Text messages


#pragma mark dateConverter Funtion
+(NSString *)dateConverter:(NSNumber *)dateTime dateFormateString:(NSString *)dateFormat;
+(void)closeAlert;                                  //Close the alert after 1.5 sec
#pragma mark Alert Message View
+(void)showAlertMessage:(NSString *)alertMsg;
#pragma mark set Image as background color
+(UIImage*) imageFilledWith:(UIColor*)color using:(UIImage*)startImage;
#pragma mark for convert the recording duration into string
+(NSString *)durationIntoString:(int)duration;
#pragma mark Setting voiceView width
+(float)voiceViewWidth:(int)msgDuration;
#pragma mark get the Image from the path
+(UIImage *)getPicImage:(NSString *)imgPath;
+(void)showAlert:(NSString *)alertMsg;

/**
 * This function is used to get the CGSize of String.
 */
+(CGSize)sizeOfString:(NSString *)string withFont:(UIFont *)font;

@end
