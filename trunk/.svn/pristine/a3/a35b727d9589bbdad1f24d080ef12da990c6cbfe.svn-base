//
//  ModelSettings.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 4/14/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "ModelSettings.h"
#import "Logger.h"

/*
 Tableviewcell all possible structures
 */
#define TITLE @"T"
#define TITLE_SUBTITLE @"TS"
#define TITLE_IMGLEFT @"TiL"
#define TITLELENGTHY_IMGLEFT @"lTiL"
#define TITLE_SUBTITLE_IMGLEFT @"TSiL"
#define TITLE_SUBTITLE_IMGLEFT_LBLRIGHT @"TSiLlR"
#define TITLE_IMGLEFT_IMGRIGHT @"TiLiR"
#define TITLE_IMGLEFT_BTNRIGHT @"TiLbR"
#define TITLE_BTNRIGHT @"TbR"
#define TITLE_IMGLEFT_LBLRIGHT @"TiLlR"
#define TITLE_SUBTITLE_IMGLEFT_BTNRIGHT @"TSiLbR"
#define TITLE_SUBTITLE_IMGLEFT_BTNRIGHT_LBLRIGHT @"TSiLbRlR"


@implementation ModelSettings

- (instancetype)initSettingsTableWithTitleImageLHSLabelRHS:(id)details;
{
    self = [super initBasicTableWithTitleImageLHS:details];
    if (self) {
        _settingsRHSLabelText = [self.brokenLocalizedArray objectAtIndex:3];
    }
    return self;
}

- (instancetype)initSettingsTableWithTitleImageLHSButtonRHS:(id)details;
{
    self = [super initBasicTableWithTitleImageLHS:details];
    if (self) {
        _settingsRHSButtonNormalText = [self.brokenLocalizedArray objectAtIndex:3];
        _settingsRHSButtonNormalImageName = [self.brokenLocalizedArray objectAtIndex:4];
        if (self.brokenLocalizedArray.count == 7) {
            _settingsRHSButtonSelectedText = [self.brokenLocalizedArray objectAtIndex:5];
            _settingsRHSButtonSelectedImageName = [self.brokenLocalizedArray objectAtIndex:6];
        }
    }
    return self;
}

- (instancetype)initSettingsTableWithTitleSubTitleImageLHSButtonRHS:(id)details;
{
    self = [super initBasicTableWithTitleSubTitleImageLHS:details];
    if (self) {
        _settingsRHSButtonNormalText = [self.brokenLocalizedArray objectAtIndex:4];
        _settingsRHSButtonNormalImageName = [self.brokenLocalizedArray objectAtIndex:5];
        if (self.brokenLocalizedArray.count == 8) {
            _settingsRHSButtonSelectedText = [self.brokenLocalizedArray objectAtIndex:6];
            _settingsRHSButtonSelectedImageName = [self.brokenLocalizedArray objectAtIndex:7];
        }
    }
    return self;
}

- (instancetype)initSettingsTableWithTitleSubTitleImageLHSButtonRHSLabelRHS:(id)details;
{
    self = [self initSettingsTableWithTitleSubTitleImageLHSButtonRHS:details];
    if (self) {
        _settingsRHSLabelText = [self.brokenLocalizedArray objectAtIndex:6];
        }
    return self;
}

- (instancetype)initSettingsTableWithTitleSubTitleImageLHSLabelRHS:(id)details;
{
    self = [super initBasicTableWithTitleSubTitleImageLHS:details];
    if (self) {
        _settingsRHSLabelText = [self.brokenLocalizedArray objectAtIndex:4];
        }
    return self;
}


- (instancetype)initSettingsTableWithTitleButtonRHS:(id)details;
{
    self = [super initBasicTableWithTitle:details];
    if (self) {
        _settingsRHSButtonNormalText = [self.brokenLocalizedArray objectAtIndex:2];
        _settingsRHSButtonNormalImageName = [self.brokenLocalizedArray objectAtIndex:3];
        if (self.brokenLocalizedArray.count == 6) {
            _settingsRHSButtonSelectedText = [self.brokenLocalizedArray objectAtIndex:4];
            _settingsRHSButtonSelectedImageName = [self.brokenLocalizedArray objectAtIndex:5];
        }
    }
    return self;
}

- (instancetype)initSettingsTableWithTitleLengthyImageLHS:(id)details;
{
    self = [super initBasicTableWithTitleImageLHS:details];
    if (self) {
        _settingsLengthyDetailText = [self.brokenLocalizedArray objectAtIndex:1];
    }
    return self;
}


- (instancetype)initSettingsTableWithLocalizedKey:(id)details andCellStructure:(id)cellStructure;
{
    NSString *cellStructureString = (NSString*)cellStructure;
    if ([cellStructureString isEqualToString:TITLE_IMGLEFT_IMGRIGHT]) {
        return [self initSettingsTableWithTitleImageLHSLabelRHS:details];
    }
    else if ([cellStructureString isEqualToString:TITLE_IMGLEFT_BTNRIGHT]) {
        return [self initSettingsTableWithTitleImageLHSButtonRHS:details];
    }
    else if ([cellStructureString isEqualToString:TITLE_BTNRIGHT]) {
        return [self initSettingsTableWithTitleButtonRHS:details];
    }
    else if ([cellStructureString isEqualToString:TITLE]) {
        return [self initBasicTableWithTitle:details];
    }
    else if ([cellStructureString isEqualToString:TITLE_SUBTITLE]) {
        return [self initBasicTableWithTitleSubTitle:details];
    }
    else if ([cellStructureString isEqualToString:TITLE_IMGLEFT]) {
        return [self initBasicTableWithTitleImageLHS:details];
    }
    else if ([cellStructureString isEqualToString:TITLE_SUBTITLE_IMGLEFT]) {
        return [self initBasicTableWithTitleSubTitleImageLHS:details];
    }
    else if ([cellStructureString isEqualToString:TITLE_IMGLEFT_LBLRIGHT]) {
        return [self initSettingsTableWithTitleImageLHSLabelRHS:details];
    }
    else if ([cellStructureString isEqualToString:TITLE_SUBTITLE_IMGLEFT_BTNRIGHT]) {
        return [self initSettingsTableWithTitleSubTitleImageLHSButtonRHS:details];
    }
    else if ([cellStructureString isEqualToString:TITLE_SUBTITLE_IMGLEFT_BTNRIGHT_LBLRIGHT]) {
        return [self initSettingsTableWithTitleSubTitleImageLHSButtonRHSLabelRHS:details];
    }
    else if ([cellStructureString isEqualToString:TITLE_SUBTITLE_IMGLEFT_LBLRIGHT]) {
        return [self initSettingsTableWithTitleSubTitleImageLHSLabelRHS:details];
    }
    else if ([cellStructureString isEqualToString:TITLELENGTHY_IMGLEFT]) {
        return [self initSettingsTableWithTitleLengthyImageLHS:details];
    }
    else{
        KLog(@"Cell is nil");
        return nil;
    }

}



@end
