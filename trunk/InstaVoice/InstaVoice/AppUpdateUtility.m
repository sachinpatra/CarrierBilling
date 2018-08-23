//
//  AppUpdateUtility.m
//  InstaVoice
//
//  Created by adwivedi on 17/07/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "AppUpdateUtility.h"
#import "ConfigurationReader.h"
#import "Engine.h"
#import "IVFileLocator.h"
#import "Contacts.h"

static AppUpdateUtility* _sharedInstance = Nil;
@implementation AppUpdateUtility

+(id)sharedAppUpdateUtility
{
    if(_sharedInstance == nil)
    {
        _sharedInstance = [AppUpdateUtility new];
    }
    return _sharedInstance;
}

+(void)upgradeAppData
{
    NSString* oldVersion = [[ConfigurationReader sharedConfgReaderObj]getClientAppBuildNumber];
    NSString* currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if(oldVersion == Nil)
    {
        //Fresh install or old version <= 14
        //[[Engine sharedEngineObj]resetLoginData];
        [IVFileLocator deleteDirAndSubDir:[[IVFileLocator getDocumentDirectoryPath]stringByAppendingPathComponent:KIRUSA]];
        
        [[ConfigurationReader sharedConfgReaderObj]setClientAppBuildNumber:currentVersion];
        oldVersion = currentVersion;
        
        //[[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    }
    
    if([oldVersion integerValue] < [currentVersion integerValue]) {
        //Maintain same settings as in the previous version.
        //Do we need to refresh the setttings?? I do not think so..!!!
        //Added by Nivedita - to handle the latest changes in profile data model.
       [IVFileLocator deleteFileAtPath:[[IVFileLocator getDocumentDirectoryPath]
                                         stringByAppendingPathComponent:@"Profile.dat"]];

        //FEB 22, 2017
        /* If the build number is 076, delete the contact data and do contact sysnc againa */
        if(([oldVersion integerValue] < 77) && ([currentVersion integerValue] >= 77)) {
            //NSLog(@"**** Delete contact and resync again");
            [[Engine sharedEngineObj]resetLoginData:YES];
        }
        //
        
        //MAY 11, 2017
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setFloat:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue] forKey:@"version"];
        //
    }
    
    if([oldVersion isEqualToString:currentVersion])
        return;
    
    
    NSInteger oldVersionNumber = [oldVersion integerValue] + 143; //last version is 1.21.143 before 2.0.0
    if(oldVersionNumber <= 88)
    {
        [IVFileLocator deleteFileAtPath:[[IVFileLocator getDocumentDirectoryPath]
                                         stringByAppendingPathComponent:@"Profile.dat"]];
    }
    if(oldVersionNumber <= 119)
    {
        //Delete multiple records from contact table
        [[Contacts sharedContact]deleteDuplicateCelebrityRecord];
    }
    if(oldVersionNumber <= 123)
    {
        //delete the country list .dat file so that it can load from the .csv file.
        [IVFileLocator deleteFileAtPath:[[IVFileLocator getDocumentDirectoryPath]
                                         stringByAppendingPathComponent:@"Country.dat"]];
    }
    
    if (![oldVersion isEqualToString:currentVersion]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"/Media/ContactImages/Native/2624836.png"];
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (success) {
            KLog(@"delete file Success");
        }
        else
        {
            KLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        }
    }
    
    [[ConfigurationReader sharedConfgReaderObj]setClientAppBuildNumber:currentVersion];
}

@end
