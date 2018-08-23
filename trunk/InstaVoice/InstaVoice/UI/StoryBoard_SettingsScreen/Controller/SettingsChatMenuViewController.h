//
//  MaxRecordTimeScreen.h
//  InstaVoice
//
//  Created by EninovUser on 08/11/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "BaseUI.h"
#import "SettingModel.h"

@interface SettingsChatMenuViewController : BaseUI
{
    SettingModel* _model;
}

@property (weak, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *recordTimeSlider;
@property (strong, nonatomic) IBOutlet UISwitch *switchLocationDisplay;//KM
//@property (strong, nonatomic) NSMutableDictionary *userSettings;

@end
