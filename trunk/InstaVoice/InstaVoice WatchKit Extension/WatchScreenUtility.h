//
//  WatchScreenUtility.h
//  InstaVoice
//
//  Created by Deepak Carpenter on 2/15/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define INT_1000                1000
#define INT_60                  60
#define INT_9                   9
#define SIZE_1YEAR 31536000.00
#define SIZE_1WEEK 604800.00
#define SIZE_2DAY 172800.00
#define SIZE_1DAY  86400.00
#define SIZE_1HOUR   3600.00

@interface WatchScreenUtility : NSObject
+(id)sharedWatchUtility;
-(NSString *)dateConverter:(NSNumber *)dateTime dateFormateString:(NSString *)dateFormat;
-(BOOL)fetchProfilePic: (UIImage *)oldPic :(UIImage *)newPic;

@end
