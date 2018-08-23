//
//  AppUpdateUtility_rm.m
//  ReachMe
//
//  Created by Pandian on 16/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppUpdateUtility_rm.h"
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
    
    if([oldVersion isEqualToString:currentVersion])
        return;
    
    //NSInteger oldVersionNumber = [oldVersion integerValue];
    
    [[ConfigurationReader sharedConfgReaderObj]setClientAppBuildNumber:currentVersion];
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //For Help chat image
    NSString* filePath = [documentsPath stringByAppendingPathComponent:@"/Media/ContactImages/Native/2624836.png"];
    
    UIImage* img = [UIImage imageNamed:@"RMSupport"];
    NSData* imgData = UIImagePNGRepresentation(img);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(imgData.length) {
         [fileManager createFileAtPath:[IVFileLocator getNativeContactPicPath:filePath] contents:imgData attributes:nil];
    } else {
        EnLogd(@"Failed to get RMSupport image");
    }
    
    // For Suggestions chat image
    filePath = [documentsPath stringByAppendingPathComponent:@"/Media/ContactImages/Native/2624835.png"];
    img = [UIImage imageNamed:@"RMSuggestion"];
    imgData = UIImagePNGRepresentation(img);
    
    if(imgData.length) {
        fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:[IVFileLocator getNativeContactPicPath:filePath] contents:imgData attributes:nil];
    } else {
        EnLogd(@"Failed to get RMSuggestion image");
    }
}

@end
