//
//  MissedCallModelSettings.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 5/29/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "MissedCallModelSettings.h"
#import "Logger.h"
#import "FetchLocalization.h"

#define MISSEDCALL @"MC"

@implementation MissedCallModelSettings

- (instancetype)initMissedCallSteps:(id)details;
{
    self = [super init];
    if (self) {
        _basicTableLocalizedString = [FetchLocalization getLocalizedString:details];
        _brokenLocalizedArray = [_basicTableLocalizedString componentsSeparatedByString:@"@##@"];
        _basicTableLocalizedNumberKey = [[_brokenLocalizedArray objectAtIndex:0] intValue];
        _stepOneTitle = [self.brokenLocalizedArray objectAtIndex:1];
        _stepOneSubTitleOne = [self.brokenLocalizedArray objectAtIndex:2];
        _stepOneSubTitleTwo = [self.brokenLocalizedArray objectAtIndex:3];
        _stepOneRHSButton = [self.brokenLocalizedArray objectAtIndex:4];
        _stepTwoTitle = [self.brokenLocalizedArray objectAtIndex:5];
        _stepTwoSubTitleOne = [self.brokenLocalizedArray objectAtIndex:6];
        _stepTwoSubTitleTwo = [self.brokenLocalizedArray objectAtIndex:7];
        _stepTwoRHSButton = [self.brokenLocalizedArray objectAtIndex:8];
        _stepOneRHSImage = [self.brokenLocalizedArray objectAtIndex:9];
        _stepTwoRHSMsgReplyTitle = [self.brokenLocalizedArray objectAtIndex:10];
        _stepTwoRHSMsgReplyContent = [self.brokenLocalizedArray objectAtIndex:11];
        
    }

    return self;
}

- (instancetype)initSettingsTableWithLocalizedKey:(id)details andCellStructure:(id)cellStructure;
{
    NSString *cellStructureString = (NSString*)cellStructure;
    if ([cellStructureString isEqualToString:MISSEDCALL]) {
        return [self initMissedCallSteps:details];
    }
    else{
        KLog(@"Cell is nil");
        return nil;
    }
    
}

@end
