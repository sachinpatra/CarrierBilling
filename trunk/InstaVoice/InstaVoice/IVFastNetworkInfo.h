//
//  IVFastNetworkInfo.h
//  InstaVoice
//
//  Created by Nivedita Angadi on 21/04/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

/** IVFastNetworkInfo : IVFastNetworkInfo is singleton class - responsible to provide the information - of slow nethwork(2G) and fast network  (WiFi, 3G and above).
*/

#import <Foundation/Foundation.h>
#import "Macro.h"
#import "Logger.h"

typedef NS_ENUM(NSUInteger,CurrentNetworkType){
    eNoNetworkType = 0,
    eCurrentNetworkTypeWiFi = 1,
    eCurrentNetworkType2G = 2,
    eCurrentNetworkTypeFastData =3
};

@interface IVFastNetworkInfo : NSObject

@property (nonatomic, assign) BOOL isFastNetwork;

+ (IVFastNetworkInfo *)sharedIVFastNetworkInfo;

- (CurrentNetworkType)currentDataNetworkType;
//- (void) registerForRadioAccessChange;
- (void) updateFastNetworkStatus;
- (void) updateFastNetworkStatusForCurrentRadioAccessTechnology:(NSString*)radioAccess;

@end
