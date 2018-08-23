//
//  ModelSettings.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 4/14/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ModelBasicTable.h"

@interface ModelSettings : ModelBasicTable

@property(nonatomic,strong)NSString *settingsRHSButtonNormalText;
@property(nonatomic,strong)NSString *settingsRHSButtonSelectedText;
@property(nonatomic,strong)NSString *settingsRHSButtonNormalImageName;
@property(nonatomic,strong)NSString *settingsRHSButtonSelectedImageName;

@property(nonatomic,strong)NSString *settingsRHSLabelText;
@property(nonatomic,strong)NSString *settingsRHSImageName;
@property(nonatomic,assign)BOOL *settingsRHSSwitchStatus;
@property(nonatomic,assign)NSString *settingsLengthyDetailText;

- (instancetype)initSettingsTableWithTitleImageLHSLabelRHS:(id)details;
- (instancetype)initSettingsTableWithTitleImageLHSButtonRHS:(id)details;
- (instancetype)initSettingsTableWithTitleButtonRHS:(id)details;
- (instancetype)initSettingsTableWithTitleLengthyImageLHS:(id)details;


- (instancetype)initSettingsTableWithLocalizedKey:(id)details andCellStructure:(NSString*)cellStructure;
@end
