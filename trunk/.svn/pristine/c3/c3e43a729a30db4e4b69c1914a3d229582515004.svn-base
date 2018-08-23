/* LinphoneCoreSettingsStore.h
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import <Foundation/Foundation.h>
#import "IASKSettingsStore.h"
#import "LinphoneManager.h"
#import "VoipSetting.h"

//- This header should be present in REGISTER method
#define kCustomHdrStatus    @"rtpStatus"

//- Possible values for kCustomHdrStatus
#define kNatUnknown             @"unknown"
#define kNatSymmetric           @"symm"
#define kNatNonSymmetric        @"nonsymm"
//

//- This header should be present both in "REGISTER" and "200 OK" methods. Value will be the currently logged-in device id.
#define kCustomHdrDeviceId      @"DeviceID"
//------------------

typedef enum : NSInteger {
    NATType_unknown=1,
    NATType_symmetric,
    NATType_nonSymmetric
} NATType;

@interface LinphoneCoreSettingsStore : IASKAbstractSettingsStore {
  @public
	NSDictionary* dict;
	NSDictionary* changedDict;
    
  @private
    NATType _natType;
    NSInteger _regAttempt;
    SettingModelVoip* voipInfo;
    SettingModelVoip* viFromPN;
    //Juy 23, 2018
    NSString* _publicIPAddr;
    NSString* _publicPort;
    //
    //NSTimer* regTimer;
    
}

@property (atomic) NSString* publicIPAddr;
@property (atomic) NSString* publicPort;

@property (atomic) NATType natType;
@property (atomic) NSInteger regAttempt;

+ (LinphoneCoreSettingsStore *)sharedLinphoneCoreSettingsStore;
+ (NSString*)getCallStateString:(LinphoneCallState)state;

- (void)setVoipInfo:(SettingModelVoip*)info;
- (NSInteger)setVoipInfoFromPN:(NSString*)info;
- (BOOL)synchronize;
- (void)unRegister;
- (BOOL)isRegistered;
- (void)reEnable;
- (void)refreshRegister:(BOOL)isTransportChanged;
- (NSString*)getDeviceID;
- (NSString*)getServerHost;
- (NSString*)getNatType;
- (NSString*)myPrimaryNumber;
- (LinphoneAddress *)normalizePhoneAddress:(NSString *)value;

@end
