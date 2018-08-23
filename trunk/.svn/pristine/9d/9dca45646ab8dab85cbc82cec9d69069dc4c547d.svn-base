//
//  SettingsTableViewCell.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 4/14/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "SettingsTableViewCell.h"
#import "IVMediaLoader.h"
#import "ConfigurationReader.h"
#import "Common.h"
@implementation SettingsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithModel:(id) model
{
    ModelSettings *modelSettings = model;

    //CMP SEP self.basicTableTitleMain.font = [UIFont systemFontOfSize:17];//KM
    
    if (modelSettings.basicTableMainTitle.length >0 )
    {
        self.basicTableTitleMain.text = modelSettings.basicTableMainTitle;
        //Start: Nivedita - Date 20th Jan set font
        self.basicTableTitleMain.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    }
    
    if (modelSettings.basicTableSubTitle.length >0 )
    {
        self.basicTableSubTitle.text = modelSettings.basicTableSubTitle;
        self.basicTableSubTitle.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];

    }
    
    if (modelSettings.basicTableImageNameLHS.length >0 )
    {
       self.basicTableLeftSideImage.image = [UIImage imageNamed:modelSettings.basicTableImageNameLHS];
    }
    
    if (modelSettings.settingsRHSLabelText.length >0 )
    {
        [self.settingsRHSLabel setText:modelSettings.settingsRHSLabelText];
        self.settingsRHSLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];

    }
    
    if (modelSettings.settingsRHSButtonNormalText.length >0 )
    {
        NSString* text = modelSettings.settingsRHSButtonNormalText;
        ConfigurationReader *confgReader= [ConfigurationReader sharedConfgReaderObj];
        if([text isEqualToString:@"Password_set_change"])
        {
            if([confgReader getPassword].length==0)
                text = @"Set";
            else
                text = @"Change";
        }
        [self.settingsRHSButton setDefaultText:text];
    }
    
    if (modelSettings.settingsRHSButtonSelectedText.length >0 )
    {
        [self.settingsRHSButton setEnabledText:modelSettings.settingsRHSButtonSelectedText];
    }
    
    if (modelSettings.settingsRHSButtonNormalImageName.length >0 )
    {
        [self.settingsRHSButton setDefaultImage:modelSettings.settingsRHSButtonNormalImageName];
    }
    
    if (modelSettings.settingsRHSButtonSelectedImageName.length >0 )
    {
        [self.settingsRHSButton setEnabledImage:modelSettings.settingsRHSButtonSelectedImageName];
    }
    
    if (modelSettings.settingsLengthyDetailText.length >0 )
    {
        [self.settingsLengthyDetailLabel setText:modelSettings.settingsLengthyDetailText];
        self.settingsLengthyDetailLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];

    }
    [self.settingsRHSButton setButtonConnected:NO];
}


@end
