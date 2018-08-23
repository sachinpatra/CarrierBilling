//
//  IVChatTableViewCell.m
//  InstaVoice
//
//  Created by Kieraj Mumick on 6/9/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "IVChatTableViewCell.h"
#import "IVColors.h"

#import "TableColumns.h"
#import "Common.h"
#import "ImgMacro.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"
#import "Setting.h"
#import "Logger.h"

@interface IVChatTableViewCell()

@property (strong, nonatomic) UIImageView *voiceStatImage;
@property (strong, nonatomic) UIImageView *statusIcon;
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UIImageView *transparentView;
@property (strong, nonatomic) UIImageView *transparentStripImageView;


@end

@implementation IVChatTableViewCell

-(float)voiceViewWidth:(int)duration
{
    float width = 0.0;
    int maxWidth = [UIScreen mainScreen].bounds.size.width - 180; //in pixels
    //int minWidth = 50;
    int minWidth = 85;
    int diff = maxWidth - minWidth;
    double div = (double)diff/120;
    double dur = (double)duration*div;
    width = minWidth+dur;
    
    //KLog(@"duration=%d,maxWidth=%d, minWidth=%d,width=%f,div=%f",duration,maxWidth,minWidth,width,div);
    return MIN(width, maxWidth);
}

-(void)setStatusIcon:(NSString *)status isAvs:(int)avsMsg readCount:(int)readCount msgType:(NSString *)msgType
{
    KLog(@"IVChatTableViewCell:setStatusIcon -- NO IMPL");
}

-(void)swapPlayPause:(id)sender
{
    KLog(@"IVChatTableViewCell:swapPlayPause -- NO IMPL");
}

//Place this function into common code
-(NSString*)formatPhoneNumberString:(NSString *)strNumber
{
    NSString* strResult = nil;
    NSCharacterSet *alphaSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    NSRange r = [strNumber rangeOfCharacterFromSet:alphaSet];
    if(r.location == NSNotFound) {
        /*DEBUG
        if([strNumber isEqualToString:@"007"]) {
            KLog(@"Debug");
        }*/
        NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
        
        NSNumber *countryIsdCode = [phoneUtil extractCountryCode:([Common addPlus:strNumber]) nationalNumber:nil];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSString *countryIsdCodeString = [formatter stringFromNumber:countryIsdCode];
        
        NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCodeString];
        
        NBPhoneNumber *myNumber = [phoneUtil parse:strNumber
                                     defaultRegion:countrySimIso error:nil];
        
        if([phoneUtil isValidNumber:myNumber]) {
            NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:countrySimIso];
            strResult = [f inputString:[Common addPlus:strNumber]];
        } else
            strResult = strNumber;
    }
    return strResult;
}

- (IBAction)buttonClicked:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioButtonClickedAtIndex:)]) {
        [self.delegate audioButtonClickedAtIndex:self.cellIndex];
    }
}

@end

