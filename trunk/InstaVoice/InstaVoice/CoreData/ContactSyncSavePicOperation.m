//
//  ContactSyncSavePicOperation.m
//  InstaVoice
//
//  Created by adwivedi on 04/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ContactSyncSavePicOperation.h"
#import <AddressBook/AddressBook.h>
#import "IVFileLocator.h"
#import "ContactData.h"
#import "Logger.h"
#import "ConfigurationReader.h"
#import "NetworkCommon.h"

@implementation ContactSyncSavePicOperation

-(id)initWithData:(NSMutableArray *)contactData syncType:(PicSaveOperationType)picSaveOperationType
{
    if(self = [super init])
    {
        _contactData = [contactData copy];
        _picSaveOperationType = picSaveOperationType;
        _session = nil;
    }
    return self;
}

-(void)dealloc
{
    [self.session invalidateAndCancel];
}

/* MAY 18, 2017
- (NSURLSession *)session {
    
    if (!_session) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    return _session;
}
*/

-(void)main
{
    switch (self.picSaveOperationType)
    {
        case PicSaveOperationTypeLocalAllContact:
        {
            NSArray* allNativeContact = [self readFromNativeAddressBook];
            [self saveAllNativeABPicData:allNativeContact];
            //CFRelease((__bridge CFArrayRef) allNativeContact);//JAN 18
        }
            break;
            
        case PicSaveOperationTypePendingList:
        {
            [self downloadAndSavePicInPicDataList:self.contactData];
        }
            break;
    }
}

-(NSArray*)readFromNativeAddressBook
{
    CFErrorRef error = NULL;
    ABAddressBookRef _nativeAddressBook = ABAddressBookCreateWithOptions(NULL, &error);
    NSArray* allNativeContact = (CFBridgingRelease)(ABAddressBookCopyArrayOfAllPeople(_nativeAddressBook));
    return allNativeContact;
}

#pragma mark -PicSaveOperationTypeLocalAllContact
-(void)saveAllNativeABPicData:(NSArray*)allNativeContact
{
    KLog(@"Save all contacts pics from natvie phonebook - START");
    @autoreleasepool {
        NSInteger count = [allNativeContact count];
        for (NSInteger i=0; i<count; i++)
        {
            @autoreleasepool
            {
                ABRecordRef contactPerson = (__bridge ABRecordRef)([allNativeContact objectAtIndex:i]);
                [self saveLocalImageForPersonRecord:contactPerson];
                //CFRelease(contactPerson);
            }
        }
    }
    KLog(@"Save all contacts pics from natvie phonebook - END");
}


#pragma mark -PicSaveOperationTypeServer and PicSaveOperationTypePendingList
-(void)downloadAndSavePicInPicDataList:(NSMutableArray*)picList
{
    KLog(@"download pics from server -- START");
    
    for(ContactPicDownloadData* data in picList)
    {
        if([data isKindOfClass:[ContactPicDownloadData class]])
        {
            if(data.isServerPic)
            {
                [self downloadPicFromServer:data.serverPicURL andSaveToPicPath:data.localPicPath];
            }
            else
            {
                CFErrorRef error = NULL;
                ABAddressBookRef _nativeAddressBook = ABAddressBookCreateWithOptions(NULL, &error);
                ABRecordRef person = ABAddressBookGetPersonWithRecordID (_nativeAddressBook,data.nativeRecordId);
                [self saveLocalImageForPersonRecord:person];
            }
        }
    }

    KLog(@"download pics from server -- END");
}


#pragma mark - Download and Save Pic Server
-(void)downloadPicFromServer:(NSString*)picURL andSaveToPicPath:(NSString*)picPath
{
    KLog(@"downloadPicFromServer");
    
    NSDate *__block startTime = [NSDate date];
    NSDate *__block finishTime;
    
    if(!picURL || ![picURL length]) {
        KLog(@"### picURL should not be nil");
        return;
    }
    
    //Create URL request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:picURL]];
    [request setHTTPMethod:@"GET"];
    //[request addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    
    //MAY 18, 2017
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    //
    
    NSURLSessionDownloadTask* downloadTask =
    [self.session downloadTaskWithRequest:request
                        completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                            
                    finishTime = [NSDate date];
                    NSTimeInterval executionTime = [finishTime timeIntervalSinceDate:startTime];
                    KLog(@"downloadPicFromServer -- elapsed time in secs : %.2f", executionTime);
                    
                    if(error) {
                        KLog(@"### downloadPicFromServer failed: %@", error);
                        [self notifyResponseToMainThread:picURL];
                    }
                    else {
                        KLog(@"### downloadPicFromServer succeeded.");
                        
                        NSData* data = [NSData dataWithContentsOfURL:location options:NSDataReadingMappedIfSafe error:&error];
                        if(nil != data)
                        {
                            [data writeToFile:[IVFileLocator getNativeContactPicPath:picPath]  atomically:YES];
                        }
                    }
    }];
    
    [downloadTask resume];
}


#pragma mark - Load and Save Pic Local
-(void)saveLocalImageForPersonRecord:(ABRecordRef)contactPerson
{
    KLog(@"saveLocalImageForPersonRecord");
    int contactID = ABRecordGetRecordID(contactPerson);
    //NSMutableString *fullPath = [[NSMutableString alloc]init];
    //NSString* imgPath = [IVFileLocator createDeviceContactImgDir];
    //[fullPath appendString:imgPath];
    //[fullPath appendString:[NSString stringWithFormat:@"/%d.png",contactID]];
    [self getImageAndSave:contactPerson picLocalPath:[NSString stringWithFormat:@"%d.png",contactID]];
}

-(void)getImageAndSave:(ABRecordRef)contactPerson picLocalPath:(NSString *)lclPicPath
{
    CFDataRef imgData = ABPersonCopyImageDataWithFormat(contactPerson, kABPersonImageFormatThumbnail);
    if(imgData != nil)
    {
        NSData *pic = CFBridgingRelease(imgData);
        
        [self saveContactImage:pic filePath:lclPicPath];
        CFRelease(imgData);
        pic = nil;
    }
    else
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isFileExist = [fm fileExistsAtPath:[IVFileLocator getNativeContactPicPath:lclPicPath]];
        if(isFileExist)
        {
            [IVFileLocator deleteFileAtPath:[IVFileLocator getNativeContactPicPath:lclPicPath]];
        }
    }
}

-(void)saveContactImage:(NSData*)picData filePath:(NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:[IVFileLocator getNativeContactPicPath:filePath] contents:picData attributes:nil];
}


#pragma mark -Response notification to main thread
-(void)notifyResponseToMainThread:(id)response
{
    [self performSelectorOnMainThread:@selector(notifyResponse:) withObject:response waitUntilDone:NO];
}

-(void)notifyResponse:(id)response
{
    [self.delegate picDownloadOperationFailedForURL:response];
}

@end
