//
//  ModelBasicTable.m
//  
//
//  Created by Vinoth Meganathan on 4/21/14.
//
//

#import "ModelBasicTable.h"

@implementation ModelBasicTable

- (instancetype)initBasicTableWithTitle:(id)details;
{
    self = [super init];
    if (self) {
        _basicTableLocalizedString = [FetchLocalization getLocalizedString:details];
        _brokenLocalizedArray = [_basicTableLocalizedString componentsSeparatedByString:@"@##@"];
        _basicTableLocalizedNumberKey = [[_brokenLocalizedArray objectAtIndex:0] intValue];
        _basicTableMainTitle = [_brokenLocalizedArray objectAtIndex:1];
    }
    return self;
}

- (instancetype)initBasicTableWithTitleSubTitle:(id)details;
{
    self = [super init];
    if (self) {
        _basicTableLocalizedString = [FetchLocalization getLocalizedString:details];
        _brokenLocalizedArray = [_basicTableLocalizedString componentsSeparatedByString:@"@##@"];
        _basicTableLocalizedNumberKey = [[_brokenLocalizedArray objectAtIndex:0] intValue];
        _basicTableMainTitle = [self.brokenLocalizedArray objectAtIndex:1];
        _basicTableSubTitle = [self.brokenLocalizedArray objectAtIndex:2];
        
    }
    return self;
}

- (instancetype)initBasicTableWithTitleImageLHS:(id)details;
{
    self = [super init];
    if (self) {
        _basicTableLocalizedString = [FetchLocalization getLocalizedString:details];
        _brokenLocalizedArray = [_basicTableLocalizedString componentsSeparatedByString:@"@##@"];
        _basicTableLocalizedNumberKey = [[_brokenLocalizedArray objectAtIndex:0] intValue];
        _basicTableMainTitle = [self.brokenLocalizedArray objectAtIndex:1];
        _basicTableImageNameLHS = [self.brokenLocalizedArray objectAtIndex:2];
        
    }
    return self;
}

- (instancetype)initBasicTableWithTitleSubTitleImageLHS:(id)details;
{
    self = [super init];
    if (self) {
        _basicTableLocalizedString = [FetchLocalization getLocalizedString:details];
        _brokenLocalizedArray = [_basicTableLocalizedString componentsSeparatedByString:@"@##@"];
        _basicTableLocalizedNumberKey = [[_brokenLocalizedArray objectAtIndex:0] intValue];
        _basicTableMainTitle = [_brokenLocalizedArray objectAtIndex:1];
        _basicTableSubTitle = [_brokenLocalizedArray objectAtIndex:2];
        _basicTableImageNameLHS = [_brokenLocalizedArray objectAtIndex:3];
    }
    return self;
}



@end
