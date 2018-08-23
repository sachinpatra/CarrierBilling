//
//  FetchLocalizedString.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 4/15/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "FetchLocalization.h"

@implementation FetchLocalization
+(NSString*)getLocalizedString:(NSString*)string
{
    return NSLocalizedString(string, nil);
}
@end
