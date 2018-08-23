//
//  VoipSetting.h
//  InstaVoice
//
//  Created by Pandian on 7/3/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingModelVoip.h"
#import "ConfigurationReader.h"

@protocol VoipSettingDelegate <NSObject>
@optional
-(void)fetchVoipSettingCompletWith:(SettingModelVoip*)info withFetchStatus:(BOOL)fetchStatus;
@end

@interface VoipSetting : NSObject
{
    SettingModelVoip* _voipInfo;
}

@property (nonatomic, strong)SettingModelVoip* voipInfo;
@property (nonatomic, weak)id<VoipSettingDelegate> delegate;

+(VoipSetting*)sharedVoipSetting;
-(void)getVoipSetting;

@end
