//
//  FetchServiceSettingsModule.m
//  
//
//  Created by Vinoth Meganathan on 4/23/14.
//
//

#import "FetchServiceSettingsModule.h"

@implementation FetchServiceSettingsModule
- (NSArray *)getTableArraySectionedWith:(NSString*)order andLook:(NSString*)look
{
    NSMutableArray *settingsModelArray01 = [[NSMutableArray alloc]initWithCapacity:0];
    
    NSArray *menuOrderArraySec01 = [[FetchLocalization getLocalizedString:order] componentsSeparatedByString:@"@"];
    
    NSArray *menuLookArraySec01 = [[FetchLocalization getLocalizedString:look] componentsSeparatedByString:@"@"];
    
    for (int i=0; i< [menuOrderArraySec01 count]; i++) {
        ModelSettings *objModelSettings = [[ModelSettings alloc]initSettingsTableWithLocalizedKey:menuOrderArraySec01[i] andCellStructure:menuLookArraySec01[i]];
        [settingsModelArray01 addObject:objModelSettings];
    }
    return [NSArray arrayWithArray:settingsModelArray01];
}

- (NSArray *)getTableArrayForMissedCallSectionedWith:(NSString*)order andLook:(NSString*)look
{
    NSMutableArray *settingsModelArray01 = [[NSMutableArray alloc]initWithCapacity:0];
    
    NSArray *menuOrderArraySec01 = [[FetchLocalization getLocalizedString:order] componentsSeparatedByString:@"@"];
    
    NSArray *menuLookArraySec01 = [[FetchLocalization getLocalizedString:look] componentsSeparatedByString:@"@"];
    
    for (int i=0; i< [menuOrderArraySec01 count]; i++) {
        MissedCallModelSettings *objModelSettings = [[MissedCallModelSettings alloc]initSettingsTableWithLocalizedKey:menuOrderArraySec01[i] andCellStructure:menuLookArraySec01[i]];
        [settingsModelArray01 addObject:objModelSettings];
    }
    return [NSArray arrayWithArray:settingsModelArray01];
}


@end
