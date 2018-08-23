//
//  CallDirectoryHandler.m
//  CallDirectory
//
//  Created by Pandian on 7/2/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "CallDirectoryHandler.h"


@interface CallDirectoryHandler () <CXCallDirectoryExtensionContextDelegate>
@end

@implementation CallDirectoryHandler

- (void)beginRequestWithExtensionContext:(CXCallDirectoryExtensionContext *)context {
    context.delegate = self;

    if (![self addBlockingPhoneNumbersToContext:context]) {
        NSLog(@"Unable to add blocking phone numbers");
        NSError *error = [NSError errorWithDomain:@"CallDirectoryHandler" code:1 userInfo:nil];
        [context cancelRequestWithError:error];
        return;
    }
    
    if (![self addIdentificationPhoneNumbersToContext:context]) {
        //CMP NSLog(@"Unable to add identification phone numbers");
        NSError *error = [NSError errorWithDomain:@"CallDirectoryHandler" code:2 userInfo:nil];
        [context cancelRequestWithError:error];
        return;
    }
    
    [context completeRequestWithCompletionHandler:nil];
}

- (BOOL)addBlockingPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    
    // Retrieve phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
    // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
    //
    // Numbers must be provided in numerically ascending order.
    /*
    CXCallDirectoryPhoneNumber phoneNumbers[] = { 14085555555, 18005555555 };
    NSUInteger count = (sizeof(phoneNumbers) / sizeof(CXCallDirectoryPhoneNumber));
    
    for (NSUInteger index = 0; index < count; index += 1) {
        CXCallDirectoryPhoneNumber phoneNumber = phoneNumbers[index];
        [context addBlockingEntryWithNextSequentialPhoneNumber:phoneNumber];
    }
    */
    /* TODO
    NSUserDefaults* groupSettings = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.kirusa.InstaVoiceGroup"];
    NSMutableArray* phoneNumbers = [groupSettings objectForKey:@"PHONE_NUMBERS_BLKD"];
    NSUInteger count = phoneNumbers.count;

    
    for (NSUInteger i = 0; i < count; i += 1) {
        CXCallDirectoryPhoneNumber phoneNumber = [[phoneNumbers objectAtIndex:i]longLongValue];
        [context addBlockingEntryWithNextSequentialPhoneNumber:phoneNumber];
    }*/

    return YES;
}

- (BOOL)addIdentificationPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    
    /*
     TODO - check if this works for large number of contacts
     Observed - In Debug build, contacts are not loaded; but works in release build. why?
     */
    
    //NSLog(@"addIdentificationPhoneNumbersToContext");
    
    // Retrieve phone numbers to identify and their identification labels from data store. For optimal performance and memory usage when there are many phone numbers,
    // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
    //
    // Numbers must be provided in numerically ascending order.
    /*
    CXCallDirectoryPhoneNumber phoneNumbers[] = {19086566050, 19086566404};
    NSArray<NSString *> *labels = @[ @"Test050", @"Test404" ];
    NSUInteger count = (sizeof(phoneNumbers) / sizeof(CXCallDirectoryPhoneNumber));
    for (NSUInteger i = 0; i < count; i += 1) {
        CXCallDirectoryPhoneNumber phoneNumber = phoneNumbers[i];
        NSString *label = [labels objectAtIndex:i];
        [context addIdentificationEntryWithNextSequentialPhoneNumber:phoneNumber label:label];
    }*/
    
    NSUserDefaults* groupSettings = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.kirusa.InstaVoiceGroup"];
    NSMutableArray* phoneNumbers = [groupSettings objectForKey:@"PHONE_NUMBERS"];
    NSMutableArray* contactNames = [groupSettings objectForKey:@"CONTACT_NAMES"];
    NSUInteger count = phoneNumbers.count;
    //NSLog(@"count = %ld, phoneNumbers = %@",(unsigned long)phoneNumbers.count, phoneNumbers);
    //NSLog(@"count = %ld, contactName = %@",(unsigned long)contactNames.count, contactNames);
    if(phoneNumbers.count != contactNames.count) {
        //NSLog(@"*** phoneNumbers are not matched with contactNames");
        return NO;
    }
    
    for (NSUInteger i = 0; i < count; i += 1) {
        CXCallDirectoryPhoneNumber phoneNumber = [[phoneNumbers objectAtIndex:i]longLongValue];
        NSString *label = [contactNames objectAtIndex:i];
        [context addIdentificationEntryWithNextSequentialPhoneNumber:phoneNumber label:label];
    }
    
    return YES;
}

#pragma mark - CXCallDirectoryExtensionContextDelegate

- (void)requestFailedForExtensionContext:(CXCallDirectoryExtensionContext *)extensionContext withError:(NSError *)error {
    
    // An error occurred while adding blocking or identification entries, check the NSError for details.
    // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
    //
    // This may be used to store the error details in a location accessible by the extension's containing app, so that the
    // app may be notified about errors which occured while loading data even if the request to load data was initiated by
    // the user in Settings instead of via the app itself.
    
    NSLog(@"Error: %@", error);
}

@end
