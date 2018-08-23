//
//  FetchSharingSettings.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 4/16/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "FetchSettingsSharingMenu.h"

@implementation FetchSettingsSharingMenu
-(id)fetchData:(id)sender
{
    NSArray *settingsModelArray01 = [self getTableArraySectionedWith:@"SETTING_SHARING_MENU_ORDER" andLook:@"SETTING_SHARING_MENU_LOOK"];
    
    if (settingsModelArray01!=nil) {
        [self.delegateFetchService callBackFetchedData:settingsModelArray01];
    }
    else
    {
        [self.delegateFetchService callBackFetchedData:nil];
    }
    return nil;

}
@end
