//
//  SelectCountryTableViewCell.m
//  ReachMe
//
//  Created by Bhaskar Munireddy on 19/07/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "SelectCountryTableViewCell.h"

@implementation SelectCountryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)configureCountryCell:(NSMutableDictionary *)country
{
    [self setFlag:country];
    NSString *countryFlag = [country valueForKey:@"COUNTRY_FLAG"];
    [self.imageView setImage:[UIImage imageNamed:countryFlag]];
    
    NSString *isd =@"+";
    isd = [isd stringByAppendingString:[country valueForKey:@"COUNTRY_ISD_CODE"]];
    self.countryCode.text = isd;
    
    NSString* countryName = [country valueForKey:@"COUNTRY_NAME"];
    self.countryName.text = countryName;
    
}

-(void)setFlag : (NSMutableDictionary *)flagDic
{
    NSString *country_flag = [flagDic valueForKey:@"COUNTRY_NAME"];
    
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
