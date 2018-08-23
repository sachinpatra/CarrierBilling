//
//  WatchScreenUtility.m
//  InstaVoice
//
//  Created by Deepak Carpenter on 2/15/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "WatchScreenUtility.h"
static WatchScreenUtility* _watchUtilityManager = nil;
@implementation WatchScreenUtility
+(id)sharedWatchUtility{
    if(_watchUtilityManager == Nil)
    {
        _watchUtilityManager = [self new];
    }
    return _watchUtilityManager;
}
//To Convert Date in specific formate
// Mins Ago (if message arrives in between of 0-60 mins)
// Time AM/PM (if message arrives in between 1-24 hours)
// Yesterday (if message arrives in between 1-2 days)
// Day Name (if message arrives in 2 days - 1 week)
// Date minimum formate style ( if message arrives after 1 week)
-(NSString*)dateConverter:(NSNumber *)dateTime dateFormateString:(NSString *)dateFormat{
    NSString   __block     *convertedString = nil;

        dispatch_queue_t concurrentQueue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_sync(concurrentQueue, ^{
      
        
    double val =   ([dateTime doubleValue])/INT_1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:val];
    double val1 = [[NSDate date]timeIntervalSince1970];
    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:val1];
    
    NSTimeInterval timeSinceDate = [currentDate timeIntervalSinceDate:date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    
    if(timeSinceDate < 3600.00) // untill 3 hours
    {
            if ((int)(timeSinceDate/60) <= 1)
                convertedString = [NSString stringWithFormat:@"%d min ago",(int)(timeSinceDate/60)];
            else
                convertedString = [NSString stringWithFormat:@"%d mins ago",(int)(timeSinceDate/60)];
    }
    else if (timeSinceDate > 3600.00 && timeSinceDate < 86400){
        [formatter setDateFormat:@"hh:mm a"];
        convertedString = [formatter stringFromDate:date];
    }
    else if (timeSinceDate > 86400.00 && timeSinceDate < 172800.00){
        convertedString = @"Yesterday" ;
    }
    else if ( timeSinceDate > 172800.00 && timeSinceDate < 604800.00){
        [formatter setDateFormat:@"EEEE"];
        convertedString = [formatter stringFromDate:date];
        
    }else if (timeSinceDate > 604800.00 && timeSinceDate < 31536000.00){
        [formatter setDateFormat:@"MMM dd"];
        convertedString = [formatter stringFromDate:date];
    }
    else {
        [formatter setDateFormat:@"MMM dd, hh:mm a"];
        convertedString = [formatter stringFromDate:date];
    }
      });
    
    return convertedString;
  
}
//Get boolean to decide profile pic needs to download or not
-(BOOL)fetchProfilePic: (UIImage *)oldPic :(UIImage *)newPic{
    NSData *data1 = UIImagePNGRepresentation(oldPic);
    NSData *data2 = UIImagePNGRepresentation(newPic);
    
    return [data1 isEqual:data2];
}

@end
