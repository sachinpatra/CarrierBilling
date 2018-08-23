//
//  ProfileFieldSelectionTableViewCell.m
//  InstaVoice
//
//  Created by adwivedi on 24/08/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "ProfileFieldSelectionTableViewCell.h"
#import "Common.h"

@implementation ProfileFieldSelectionTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCountryCell:(NSMutableDictionary *)country
{
    [self setFlag:country];
    NSString *countryFlag = [country valueForKey:@"COUNTRY_FLAG"];
    [self.imageView setImage:[UIImage imageNamed:countryFlag]];
    
    NSString *isd =@"+";
    isd = [isd stringByAppendingString:[country valueForKey:@"COUNTRY_ISD_CODE"]];
    self.countryCode.text = isd;
    
    //Text flow related chages - Nivedita - Date 23rd May
    self.countryCode.font = self.countryName.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    
    NSString* countryName = [country valueForKey:@"COUNTRY_NAME"];
    self.countryName.text = countryName;
    
}

-(void)setFlag : (NSMutableDictionary *)flagDic
{
    NSString *country_flag = [flagDic valueForKey:@"COUNTRY_NAME"];
    //country_flag = [country_flag stringByAppendingString:@".png"];
    
    for(int i=0;i<[country_flag length];i++)
    {
        if([country_flag characterAtIndex:i]==' ')
        {
            country_flag = [country_flag stringByReplacingOccurrencesOfString:@" "
                                                                   withString:@"-"];
        }
    }
    [flagDic setValue: country_flag forKey:@"COUNTRY_FLAG"];
}

@end
