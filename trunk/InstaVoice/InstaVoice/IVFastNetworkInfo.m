//
//  IVFastNetworkInfo.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 21/04/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVFastNetworkInfo.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Common.h"

@interface IVFastNetworkInfo()
@property (nonatomic, strong) CTTelephonyNetworkInfo *networkInfo;
@end

@implementation IVFastNetworkInfo

- (id)init {
    self = [super init];
    if (self) {
        self.isFastNetwork = NO;
        self.networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        //Is it necessary?? Its not - we are setting isFastNetwork - in the isNetworkAvailable of Common class.
        // [self updateFastNetworkStatusForCurrentRadioAccessTechnology];
    }
    return self;
}

/**
 Singleton object for the IVFastNetworkInfo
 @return returns the instance of IVFastNetworkInfo
 */

+ (IVFastNetworkInfo *)sharedIVFastNetworkInfo {
    
    static IVFastNetworkInfo *sharedIVFastNetworkInfo;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedIVFastNetworkInfo = [[IVFastNetworkInfo alloc]init];
        
    });
    return sharedIVFastNetworkInfo;
}


/*
-(void)registerForRadioAccessChange {
    
    self.networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFastNetworkStatus)
                                                 name:CTRadioAccessTechnologyDidChangeNotification object:nil];
}
*/

-(void)updateFastNetworkStatus {
    self.networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    [self updateFastNetworkStatusForCurrentRadioAccessTechnology: self.networkInfo.currentRadioAccessTechnology];
}

/** Method is responsible to update fast network status based on the radio access technology*/
- (void)updateFastNetworkStatusForCurrentRadioAccessTechnology:(NSString*)radioAccess
{
        if ([radioAccess isEqualToString:CTRadioAccessTechnologyGPRS]) {
            self.isFastNetwork = NO;
            KLog(@"*** Radio : 2G");
        }
        else if ([radioAccess isEqualToString:CTRadioAccessTechnologyEdge]) {
            self.isFastNetwork = NO;
            KLog(@"*** Radio : 2G");
        }
        else if ([radioAccess isEqualToString:CTRadioAccessTechnologyWCDMA]) {
            self.isFastNetwork = YES;
            KLog(@"*** Radio : 3G");
        }
        else if ([radioAccess isEqualToString:CTRadioAccessTechnologyHSDPA]) {
            self.isFastNetwork = YES;
            KLog(@"*** Radio : 3G");
        }
        else if ([radioAccess isEqualToString:CTRadioAccessTechnologyHSUPA]) {
            self.isFastNetwork = YES;
            KLog(@"*** Radio : 3G");
        }
        else if ([radioAccess isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
            self.isFastNetwork = NO;
            KLog(@"*** Radio : 2G");
        }
        else if ([radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
            self.isFastNetwork = YES;
            KLog(@"*** Radio : 3G");
        }
        else if ([radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
            self.isFastNetwork = YES;
            KLog(@"*** Radio : 3G");
        }
        else if ([radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
            self.isFastNetwork = YES;
            KLog(@"*** Radio : 3G");
        }
        else if ([radioAccess isEqualToString:CTRadioAccessTechnologyeHRPD]) {
            self.isFastNetwork = YES;
            KLog(@"*** Radio : 3G");
        }
        else if ([radioAccess isEqualToString:CTRadioAccessTechnologyLTE]) {
            self.isFastNetwork = YES;
            KLog(@"*** Radio : 4G");
        }
        else {
            self.isFastNetwork = NO;
            KLog(@"*** Radio : unknown");
        }
}

/** Method responsible for returning the current data network type: 2G, 3G
 @return Returns the network type - 2G 0r 3G*/
- (CurrentNetworkType)currentDataNetworkType {
    
    CurrentNetworkType currentNetworkType = eNoNetworkType;
    
    if ([self.networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
        currentNetworkType = eCurrentNetworkType2G;
    }
    else if ([self.networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
        currentNetworkType = eCurrentNetworkType2G;
    }
    else if ([self.networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
        currentNetworkType = eCurrentNetworkTypeFastData;
    }
    else if ([self.networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
        currentNetworkType = eCurrentNetworkTypeFastData;
    }
    else if ([self.networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
        currentNetworkType = eCurrentNetworkTypeFastData;
    }
    else if ([self.networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        currentNetworkType = eCurrentNetworkType2G;
    }
    else if ([self.networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
        currentNetworkType = eCurrentNetworkTypeFastData;
    }
    else if ([self.networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
        currentNetworkType = eCurrentNetworkTypeFastData;
    }
    else if ([self.networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
        currentNetworkType = eCurrentNetworkTypeFastData;
    }
    else if ([self.networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        currentNetworkType = eCurrentNetworkTypeFastData;
    }
    else if ([self.networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        currentNetworkType = eCurrentNetworkTypeFastData;
    }

    return currentNetworkType;
}

@end
