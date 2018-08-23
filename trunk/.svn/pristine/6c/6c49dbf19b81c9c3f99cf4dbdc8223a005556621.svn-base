//
//  Common.m
//  InstaVoice
//
//  Created by EninovUser on 12/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "Common.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CoreTelephonyDefines.h>
#import "ServerErrorMsg.h"
#import "Reachability.h"
#import "EventType.h"
#import "TableColumns.h"
#import "SSKeychain.h"
#import "ConfigurationReader.h"
#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>
#import "Logger.h"
#import "Setting.h"
#import "MQTTManager.h"
#import "ScreenUtility.h"

#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif

#import "Contacts.h"
#import "IVFileLocator.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

//VOIP
#define APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
//

#define kBodyTextMaxFontSize 20
#define kBodyTextMinFontSize 11
#define kCaption1TextMaxFontSize 17
#define kCaption1TextMinFontSize 14
#define kTextMaxFontSize 20
#define kTextMinFontSize 17
#define kFontMaxScaleFactor 0.5
#define kFontMinScaleFactor 0.8
//Deepak C
#define kFootNoteTextMaxFontSize 17
#define kFootNoteMinFontSize 13
#define kCaption2TextMaxFontSize 13
#define kCaption2TextMinFontSize 11
#define kHeadlineTextMaxFontSize 20
#define kHeadlineTextMinFontSize 14
#define kSubheadlineTextMaxFontSize 18
#define kSubheadlineTextMinFontSize 12

#define kHostReachableSuccessfully 200

#define NUMERIC_DIGITS       @"0123456789"
@implementation Common


//This function returns the information about the SIM.
+(NSMutableDictionary*)getSIMInfo
{
    NSMutableDictionary *dic = nil;
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    if(carrier != nil)
    {
        dic  = [[NSMutableDictionary alloc] init];
        
        // Get carrier name
        NSString *carrierName = [carrier carrierName];
        if (carrierName != nil)
        {
            [dic setValue:carrierName forKey:COUNTRY_SIM_CARRIER];
        }
        else
        {
            [dic removeObjectForKey:COUNTRY_SIM_CARRIER];
        }
        
        // Get mobile country code
        NSString *mcc = [carrier mobileCountryCode];
        if (mcc != nil)
        {
            [dic setValue:mcc forKey:COUNTRY_SIM_MCC];
        }
        else
        {
            [dic removeObjectForKey:COUNTRY_SIM_MCC];
        }
        
        // Get mobile network code
        NSString *mnc = [carrier mobileNetworkCode];
        
        if (mnc != nil)
        {
            [dic setValue:mnc forKey:COUNTRY_SIM_MNC];
        }
        else
        {
            [dic removeObjectForKey:COUNTRY_SIM_MNC];
        }
        
        //get SIM iso code
        NSString *iso = [carrier isoCountryCode];
        if (iso != nil)
        {
            [dic setValue:iso forKey:COUNTRY_SIM_ISO];
        }
        else
        {
            [dic removeObjectForKey:COUNTRY_SIM_ISO];
        }
    }
    return dic;
}

+(int)isSIMAvailable
{
    int simAvailable = SIM_NOT_AVAILABLE;
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    NSString *iso = [carrier isoCountryCode];
    if(iso != nil && [iso length]>0)
    {
        simAvailable = SIM_AVAILABLE;
    }
    return simAvailable;
}

+(NSString*)getCanonicalPhoneNumber:(NSString *)phone
{
    NSString *canonicalPhone = nil;
    if(phone != nil && [phone length] >0)
    {
        canonicalPhone = phone;
        NSMutableString *strippedString = [NSMutableString stringWithCapacity:canonicalPhone.length];
        NSScanner *scanner = [NSScanner scannerWithString:canonicalPhone];
        NSCharacterSet *numbers = [NSCharacterSet
                                   characterSetWithCharactersInString:NUMERIC_DIGITS];
        
        while ([scanner isAtEnd] == NO)
        {
            NSString *buffer;
            if ([scanner scanCharactersFromSet:numbers intoString:&buffer])
            {
                [strippedString appendString:buffer];
                
            }
            else
            {
                [scanner setScanLocation:([scanner scanLocation] + 1)];
            }
        }
        if(strippedString != nil && [strippedString length] > 0)
        {
            NSString *zeroPos = [strippedString substringWithRange:NSMakeRange(0, 1)];
            if([zeroPos isEqualToString:@"0"])
            {
                canonicalPhone = [strippedString substringFromIndex:1];
            }
            else
            {
                canonicalPhone = strippedString;
            }
        }
        ConfigurationReader *confgReader = [ConfigurationReader sharedConfgReaderObj];
        NSString *isdCode = [confgReader getCountryISD];
        int minLength = [confgReader getMinPhoneLen];
        int maxLength = [confgReader getMaxPhoneLen];
        int phoneLength = [canonicalPhone length];
        
        if(phoneLength >= minLength && phoneLength <= maxLength)
        {
            canonicalPhone = [isdCode stringByAppendingString:canonicalPhone];
        }
    }
    return canonicalPhone;
}

+(NSString*)getUniqueDeviceID
{
    NSString *uuidString = [SSKeychain passwordForService:@"reachme" account:@"user"];
    if(uuidString == nil || [uuidString length] == 0)
    {
        CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuid = (CFUUIDCreateString(kCFAllocatorDefault, theUUID));
        NSString *lclUUID = (__bridge NSString *)uuid;
        CFRelease(theUUID);
        
        NSString *charsNotNeeded = @"<>-";
        NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:charsNotNeeded];
        uuidString = [[lclUUID componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""]; //Remove -, <, >
        
        [SSKeychain setPassword:uuidString forService:@"reachme" account:@"user"];
        
        CFRelease(uuid);
    }
    
    NSString *charsNotNeeded = @"<>-";
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:charsNotNeeded];
    uuidString = [[uuidString componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""]; //Remove -, <, >
    
#ifdef REACHME_APP
    NSString* retString = [NSString stringWithFormat:@"rm%@",uuidString];
#else
    NSString* retString = [NSString stringWithFormat:@"%@",uuidString];
#endif
    
    return retString;
}

+(NSString *)getGuid
{
    CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strUUID = (CFUUIDCreateString(kCFAllocatorDefault, theUUID));
    NSString *lclGUID = (__bridge NSString *)strUUID;
    
    NSString *hyphens = @"-";
    NSCharacterSet *hyphensCharSet = [NSCharacterSet characterSetWithCharactersInString:hyphens];
    NSString *retrieveuuid = [NSString stringWithFormat:@"%@",lclGUID];
    retrieveuuid = [[retrieveuuid componentsSeparatedByCharactersInSet:hyphensCharSet] componentsJoinedByString:@""];
    
    //GUID format is -- deviceID-generated unique ID
    NSString* deviceID = [[ConfigurationReader sharedConfgReaderObj] getDeviceUUID];
    NSString* retDeviceID = [NSString stringWithFormat:@"%@",deviceID];
    retDeviceID = [[retDeviceID componentsSeparatedByCharactersInSet:hyphensCharSet] componentsJoinedByString:@""];
    NSString* sGUID = [NSString stringWithFormat:@"%@-%@",retDeviceID,retrieveuuid];
    
    CFRelease(theUUID);
    CFRelease(strUUID);
    return sGUID;
}


// return true for numeric data.
+(BOOL) validateNumeric:(NSString *) Numeric
{
    BOOL valid = FALSE;
    if(Numeric != nil && Numeric.length > 0)
    {
        NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:Numeric];
        valid = ([alphaNums isSupersetOfSet:inStringSet]) ;
    }
    return valid;
    
}

+(NSString *)setPlusPrefix:(NSString *)nameStr
{
    NSString *str = nil;
    if(nameStr != nil && nameStr.length > 0)
    {
        BOOL isNumeric = [Common validateNumeric:nameStr];
        //NSString *countryIsd = [[ConfigurationReader sharedConfgReaderObj] getCountryISD];
        if(isNumeric)// && [nameStr hasPrefix:countryIsd])
        {
            str = [NSString stringWithFormat:@"+%@",nameStr];
        }
    }
    return str;
}

+(NSString *)setPlusPrefixChatWithMobile:(NSString *)nameStr
{
    NSString *str = nil;
    nameStr = [self removePlus:nameStr];
    if(nameStr != nil && nameStr.length > 0)
    {
        BOOL isNumeric = [Common validateNumeric:nameStr];
        if(isNumeric)
        {
            str = [NSString stringWithFormat:@"+%@",nameStr];
        }
    }
    return str;
}

+(NSString *)setPlusPrefixForMobileNumber:(NSString *)nameStr
{
    NSString *str = nil;
    if(nameStr != nil && nameStr.length > 0)
    {
        BOOL isNumeric = [Common validateNumeric:nameStr];
        if(isNumeric)
        {
            NSString *prefixedMobileNumber = [nameStr hasPrefix:@"+"]?nameStr:[NSString stringWithFormat:@"+%@",nameStr];
            str = [NSString stringWithFormat:@"+%@",prefixedMobileNumber];
        }
    }
    return str;
}

+(NSString *)removePlus:(NSString *)number{
    NSString *numberWithoutPlus = nil;
    
    if ([number hasPrefix:@"+"]) {
        numberWithoutPlus = [number stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }
    else{
        numberWithoutPlus = number;
    }
    
    return numberWithoutPlus;
}

+(NSString *)addPlus:(NSString *)number{
    NSString *numberWithPlus = nil;
    
    if ([number hasPrefix:@"+"]) {
        numberWithPlus = number;
    }
    else{
        numberWithPlus = [@"+" stringByAppendingString:number];
    }
    
    return numberWithPlus;
}

+(int)isNetworkAvailable
{
    int netAvailable = NETWORK_NOT_AVAILABLE;
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    switch (networkStatus)
    {
        case NotReachable:
            EnLogi(@"N/W Not reachable");
            KLog(@"N/W Not reachable");
            netAvailable = NETWORK_NOT_AVAILABLE;
            break;
        case ReachableViaWiFi:
            EnLogi(@"Wifi connected");
            KLog(@"Wifi connected");
            [self isNetworkReachable];//FEb 8, 2017
            netAvailable = NETWORK_AVAILABLE;
            [IVFastNetworkInfo sharedIVFastNetworkInfo].isFastNetwork = YES; //TODO crash once.h
            break;
        case ReachableViaWWAN:
            EnLogi(@"WWAN connected");
            KLog(@"WWAN connected");
            [self isNetworkReachable];//FEB 8, 2017
            netAvailable = NETWORK_AVAILABLE;
            [[IVFastNetworkInfo sharedIVFastNetworkInfo]updateFastNetworkStatus];
            break;
        default:
            break;
    }
    
    /* Debug
    if([IVFastNetworkInfo sharedIVFastNetworkInfo].isFastNetwork) {
        KLog(@"Fast network");
    }
    else {
        KLog(@"Slow network");
    }*/
    
#ifdef MQTT_ENABLED
    if(NETWORK_AVAILABLE == netAvailable && [[ConfigurationReader sharedConfgReaderObj]getContactServerSyncFlag]) {
        
        MQTTManager* mqtt = [MQTTManager sharedMQTTManager];
        BOOL isMainThread = [NSThread isMainThread];
        BOOL isAppActive = NO;
        if(isMainThread)
            isAppActive = ([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive);
        
        if( ![mqtt isConnected] && (!isMainThread || isAppActive) ) {
            KLog(@"MQTT is not connected. Reconnect");
            EnLoge(@"MQTT is not connected. Reconnect");
            [mqtt connectMQTTClient];
        } else {
            KLog(@"MQTT is in connected-state");
            EnLoge(@"MQTT is in connected-state.");
        }
    }
    else if(NETWORK_AVAILABLE == netAvailable && ![[ConfigurationReader sharedConfgReaderObj]getContactServerSyncFlag]) {
        [[Contacts sharedContact]syncPendingContactWithServer];
    }
#endif
    
    return netAvailable;
}

+(BOOL)isNetworkReachable
{
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef address;
    address = SCNetworkReachabilityCreateWithName(NULL, "www.apple.com" );
    Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
    CFRelease(address);
    
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    KLog(@"*** isNetworkReachable: %d",canReach);
    
    return canReach;
}

+(BOOL)networkReachable
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr *) &zeroAddress);
    
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
        if ((flags & kSCNetworkReachabilityFlagsReachable))
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
        
        //        if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        //            // if target host is reachable and no connection is required
        //            //  then we'll assume (for now) that your on Wi-Fi
        //            return YES; // This is a wifi connection.
        //        }
        //
        //
        //        if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0)
        //             ||(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        //            // ... and the connection is on-demand (or on-traffic) if the
        //            //     calling application is using the CFSocketStream or higher APIs
        //
        //            if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
        //                // ... and no [user] intervention is needed
        //                return YES; // This is a wifi connection.
        //            }
        //        }
        
        if ((flags & kSCNetworkReachabilityFlagsIsWWAN)) {
            // ... but WWAN connections are OK if the calling application
            //     is using the CFNetwork (CFSocketStream?) APIs.
            return YES; // This is a cellular connection.
        }
    }
    
    return NO;
}


+(NSDate*)getDateAndTimeInMiliSec:(int)year month:(int)month dateOfMonth:(int)dateOfmonth hourOfDay:(int)hrOfDay minute:(int)min second:(int)sec
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:dateOfmonth];
    [comps setHour:hrOfDay];
    [comps setMinute:min];
    [comps setSecond:sec];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorian dateFromComponents:comps];
    //    timeInMiliSec = [date timeIntervalSince1970];
    
    return date;
}




+(NSMutableArray*)topFiveCountryList
{
    NSMutableArray *fiveCountryList = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *con1Dic = [[NSMutableDictionary alloc] init];
    [con1Dic setValue:@"001" forKey:COUNTRY_CODE];
    [con1Dic setValue:@"1" forKey:COUNTRY_ISD_CODE];
    [con1Dic setValue:@"United States" forKey:COUNTRY_NAME];
    [con1Dic setValue:@"US" forKey:COUNTRY_SIM_ISO];
    [con1Dic setValue:@"10" forKey:COUNTRY_MAX_PHONE_LENGTH];
    [con1Dic setValue:@"10" forKey:COUNTRY_MIN_PHONE_LENGTH];
    [fiveCountryList addObject:con1Dic];
    
    NSMutableDictionary *con2Dic = [[NSMutableDictionary alloc] init];
    [con2Dic setValue:@"091" forKey:COUNTRY_CODE];
    [con2Dic setValue:@"91" forKey:COUNTRY_ISD_CODE];
    [con2Dic setValue:@"India" forKey:COUNTRY_NAME];
    [con2Dic setValue:@"IN" forKey:COUNTRY_SIM_ISO];
    [con2Dic setValue:@"10" forKey:COUNTRY_MAX_PHONE_LENGTH];
    [con2Dic setValue:@"10" forKey:COUNTRY_MIN_PHONE_LENGTH];
    [fiveCountryList addObject:con2Dic];
    
    NSMutableDictionary *con3Dic = [[NSMutableDictionary alloc] init];
    [con3Dic setValue:@"nga" forKey:COUNTRY_CODE];
    [con3Dic setValue:@"234" forKey:COUNTRY_ISD_CODE];
    [con3Dic setValue:@"Nigeria" forKey:COUNTRY_NAME];
    [con3Dic setValue:@"NG" forKey:COUNTRY_SIM_ISO];
    [con3Dic setValue:@"10" forKey:COUNTRY_MAX_PHONE_LENGTH];
    [con3Dic setValue:@"7" forKey:COUNTRY_MIN_PHONE_LENGTH];
    [fiveCountryList addObject:con3Dic];
    
    NSMutableDictionary *con4Dic = [[NSMutableDictionary alloc] init];
    [con4Dic setValue:@"233" forKey:COUNTRY_CODE];
    [con4Dic setValue:@"233" forKey:COUNTRY_ISD_CODE];
    [con4Dic setValue:@"Ghana" forKey:COUNTRY_NAME];
    [con4Dic setValue:@"GH" forKey:COUNTRY_SIM_ISO];
    [con4Dic setValue:@"9" forKey:COUNTRY_MAX_PHONE_LENGTH];
    [con4Dic setValue:@"9" forKey:COUNTRY_MIN_PHONE_LENGTH];
    [fiveCountryList addObject:con4Dic];
    
    NSMutableDictionary *con5Dic = [[NSMutableDictionary alloc] init];
    [con5Dic setValue:@"chn" forKey:COUNTRY_CODE];
    [con5Dic setValue:@"86" forKey:COUNTRY_ISD_CODE];
    [con5Dic setValue:@"China" forKey:COUNTRY_NAME];
    [con5Dic setValue:@"CN" forKey:COUNTRY_SIM_ISO];
    [con5Dic setValue:@"12" forKey:COUNTRY_MAX_PHONE_LENGTH];
    [con5Dic setValue:@"6" forKey:COUNTRY_MIN_PHONE_LENGTH];
    [fiveCountryList addObject:con5Dic];
    
#ifdef REACHME_APP
    //ReachMe Top five countries
    NSMutableArray *reachMeFiveCountryList = [[NSMutableArray alloc] init];
    [reachMeFiveCountryList addObject:con1Dic];
    
    NSMutableDictionary *rmCon2Dic = [[NSMutableDictionary alloc] init];
    [rmCon2Dic setValue:@"gbr" forKey:COUNTRY_CODE];
    [rmCon2Dic setValue:@"44" forKey:COUNTRY_ISD_CODE];
    [rmCon2Dic setValue:@"United Kingdom" forKey:COUNTRY_NAME];
    [rmCon2Dic setValue:@"GB" forKey:COUNTRY_SIM_ISO];
    [rmCon2Dic setValue:@"10" forKey:COUNTRY_MAX_PHONE_LENGTH];
    [rmCon2Dic setValue:@"9" forKey:COUNTRY_MIN_PHONE_LENGTH];
    [reachMeFiveCountryList addObject:rmCon2Dic];
    
    NSMutableDictionary *rmCon3Dic = [[NSMutableDictionary alloc] init];
    [rmCon3Dic setValue:@"zaf" forKey:COUNTRY_CODE];
    [rmCon3Dic setValue:@"27" forKey:COUNTRY_ISD_CODE];
    [rmCon3Dic setValue:@"South Africa" forKey:COUNTRY_NAME];
    [rmCon3Dic setValue:@"ZA" forKey:COUNTRY_SIM_ISO];
    [rmCon3Dic setValue:@"9" forKey:COUNTRY_MAX_PHONE_LENGTH];
    [rmCon3Dic setValue:@"7" forKey:COUNTRY_MIN_PHONE_LENGTH];
    [reachMeFiveCountryList addObject:rmCon3Dic];
    
    NSMutableDictionary *rmCon4Dic = [[NSMutableDictionary alloc] init];
    [rmCon4Dic setValue:@"fra" forKey:COUNTRY_CODE];
    [rmCon4Dic setValue:@"33" forKey:COUNTRY_ISD_CODE];
    [rmCon4Dic setValue:@"France" forKey:COUNTRY_NAME];
    [rmCon4Dic setValue:@"FR" forKey:COUNTRY_SIM_ISO];
    [rmCon4Dic setValue:@"10" forKey:COUNTRY_MAX_PHONE_LENGTH];
    [rmCon4Dic setValue:@"9" forKey:COUNTRY_MIN_PHONE_LENGTH];
    [reachMeFiveCountryList addObject:rmCon4Dic];
    
    NSMutableDictionary *rmCon5Dic = [[NSMutableDictionary alloc] init];
    [rmCon5Dic setValue:@"esp" forKey:COUNTRY_CODE];
    [rmCon5Dic setValue:@"34" forKey:COUNTRY_ISD_CODE];
    [rmCon5Dic setValue:@"Spain" forKey:COUNTRY_NAME];
    [rmCon5Dic setValue:@"ES" forKey:COUNTRY_SIM_ISO];
    [rmCon5Dic setValue:@"9" forKey:COUNTRY_MAX_PHONE_LENGTH];
    [rmCon5Dic setValue:@"9" forKey:COUNTRY_MIN_PHONE_LENGTH];
    [reachMeFiveCountryList addObject:rmCon5Dic];
    return reachMeFiveCountryList;
#endif
    
    return fiveCountryList;
}


+(NSMutableArray *) loadDataAtIndexArray :(NSMutableArray *)elementList key:(NSString*)key indexArray:(NSMutableArray*)indexArray
{
    NSMutableArray *dataAtIndex = [[NSMutableArray alloc]init];
    int i = 0;
    BOOL found = NO;
    NSMutableDictionary *dataDic = nil;
    if(elementList != nil && [elementList count] > 0)
    {
        for(NSMutableDictionary *dic in elementList)
        {
            NSString *fullName = [dic valueForKey:key];
            NSString *name = @"";
            if(fullName != nil && [fullName length]>0)
            {
                name = [[dic valueForKey:key] substringWithRange:NSMakeRange(0, 1)];
            }
            for(NSMutableDictionary *tempDic in dataAtIndex)
            {
                NSString *str = [tempDic valueForKey:TABLE_TITLE];
                name = [name uppercaseString];
                if([str hasPrefix:name] || ([Common validateNumeric:name] && [str hasPrefix:@"#"]))
                {
                    found = YES;
                    break;
                }
                else
                {
                    found = NO;
                    
                }
            }
            
            if(!found)
            {
                dataDic =[[NSMutableDictionary alloc]init];
                [dataDic setValue:name forKey:TABLE_TITLE];
                [dataDic setValue:[NSString stringWithFormat:@"%d",i] forKey:TABLE_VALUE];
                [dataAtIndex addObject:dataDic];
            }
            i++; //friendlist index
        }
        if([indexArray count] != [dataAtIndex count])
        {
            for(NSString *str in indexArray)
            {
                for(NSMutableDictionary *dic in dataAtIndex)
                {
                    NSString *tempStr  = [dic valueForKey:TABLE_TITLE];
                    if([tempStr isEqualToString:str] || ([Common validateNumeric:tempStr] && [str hasPrefix:@"#"]))
                    {
                        found = YES;
                        break;
                    }
                    else
                    {
                        found = NO;
                    }
                }
                if(!found)
                {
                    dataDic =[[NSMutableDictionary alloc]init];
                    [dataDic setValue:str forKey:TABLE_TITLE];
                    [dataDic setValue:@"0" forKey:TABLE_VALUE];
                    [dataAtIndex addObject:dataDic];
                }
                //                else
                //                {
                //                    dataDic =[[NSMutableDictionary alloc]init];
                //                    dataDic = [dataAtIndex objectAtIndex:i];
                //                    i++;
                //                }
                //                j++;
            }
        }
        NSSortDescriptor * nameSortDescriptor = [[NSSortDescriptor alloc]initWithKey:TABLE_TITLE ascending:YES];
        NSArray *sortedArray = [dataAtIndex sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameSortDescriptor]];
        if(sortedArray != nil && [sortedArray count] > 0)
        {
            [dataAtIndex removeAllObjects];
            dataAtIndex = [[NSMutableArray alloc]initWithArray:sortedArray];
        }
        
    }
    
    return dataAtIndex;
}

+(NSMutableArray *)loadIndexArray
{
    NSMutableArray *indexArray = [[NSMutableArray alloc]init];
    for(char c ='A' ; c <= 'Z' ;  c++)
    {
        [indexArray addObject:[NSString stringWithFormat:@"%c",c]];
    }
    return indexArray;
}


+(BOOL)getNativeContactAccessPermission
{
    ABAddressBookRef nativeAddressBook = nil;
    __block BOOL accessGranted = NO;
    if (&ABAddressBookRequestAccessWithCompletion != NULL)
    {
        // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(nativeAddressBook, ^(bool granted, CFErrorRef error){
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    { // we're on iOS 5 or older
        accessGranted = YES;
    }
    return accessGranted;
    
}

+(NSString*)getLocationName:(NSArray*)placemarks
{
    NSString *locationName = nil;
    if (placemarks && placemarks.count > 0)
    {
        CLPlacemark *placemark = placemarks[0];
        /*
         (lldb) po [placemark thoroughfare]
         Ellis St
         (lldb) po [placemark subLocality]
         Union Square
         (lldb) po [placemark locality]
         San Francisco
         (lldb) po [placemark administrativeArea]
         CA
         (lldb) po [placemark country]
         United States
         */
        NSString* thoroughfare = [placemark thoroughfare];
        NSString* subLocality = [placemark subLocality];
        if(thoroughfare != Nil)
        {
            if(subLocality != Nil)
            {
                locationName = [NSString stringWithFormat:@"%@ | %@",thoroughfare,subLocality];
            }
            else
            {
                locationName = thoroughfare;
            }
            return locationName;
        }
        if(subLocality != nil)
        {
            locationName = subLocality;
            return locationName;
        }
        
        NSString* locality = [placemark locality];
        NSString* administrativeArea = [placemark administrativeArea];
        if(locality != Nil)
        {
            if(administrativeArea != Nil)
            {
                locationName = [NSString stringWithFormat:@"%@ | %@",locality,administrativeArea];
            }
            else
            {
                locationName = locality;
            }
            return locationName;
        }
        if(administrativeArea != nil)
        {
            locationName = administrativeArea;
            return locationName;
        }
        
        NSString* country = [placemark country];
        if(country != nil)
        {
            locationName = country;
            return country;
        }
        
        /*NSDictionary *addressDictionary =
         placemark.addressDictionary;
         NSString *street = [addressDictionary
         objectForKey:(NSString *)kABPersonAddressStreetKey];
         NSString *city = [addressDictionary
         objectForKey:(NSString *)kABPersonAddressCityKey];
         NSString *state = [addressDictionary
         objectForKey:(NSString *)kABPersonAddressStateKey];
         if(street != nil)
         {
         EnLogd(@"Street is not null");
         if (city != nil)
         {
         EnLogd(@"City is not null");
         street      = [street stringByAppendingString:@","];
         street = [street stringByAppendingString:city];
         if(state != nil)
         {
         EnLogd(@"State is not null");
         street      = [state stringByAppendingString:@","];
         street = [state stringByAppendingString:city];
         }
         locationName = street;
         }
         else
         locationName = street;
         }
         else
         {
         EnLogd(@"Street is null");
         if (city != nil)
         {
         if(state != nil)
         {
         city = [city stringByAppendingString:@","];
         locationName = [city stringByAppendingString:state];
         }
         else
         locationName = city;
         }
         else if(state != nil)
         locationName = state;
         
         }*/
    }
    return locationName;
}

#ifdef REACHME_APP
+ (void) callNumber:(NSString *)toPhoneNumber FromNumber:(NSString *) fromPhoneNumber UserType:(NSString *)userType {
    
    KLog(@"ToNumber = %@, FromNumber=%@", toPhoneNumber,fromPhoneNumber);
    [LinphoneManager.instance makeCall:toPhoneNumber FromAddress:nil UserType:userType CalleeInfo:nil];
}
#endif

+ (void)callWithNumber:(NSString *)phoneNo {
    
    /* July 22, 2016 -- Uses telprompt scheme
    NSString *prefixedMobileNumber = [phoneNo hasPrefix:@"+"]?phoneNo:[NSString stringWithFormat:@"+%@",phoneNo];
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:prefixedMobileNumber];
    NSURL* phoneURL = [NSURL URLWithString:phoneNumber];
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    } else {
        KLog(@"Not able to open URL %@",phoneNumber);
    }
     */
    
    //July 22, 2016 Uses tel scheme
    NSString *prefixedMobileNumber = [phoneNo hasPrefix:@"+"]?phoneNo:[NSString stringWithFormat:@"+%@",phoneNo];
    NSString *phoneNumber = [@"tel://" stringByAppendingString:prefixedMobileNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    //
}

+ (void)callWithNumberWithoutPrompt:(NSString *)phoneNo {
    NSString *prefixedMobileNumber = [phoneNo hasPrefix:@"+"]?phoneNo:[NSString stringWithFormat:@"+%@",phoneNo];
    NSString *phoneNumber = [@"tel://" stringByAppendingString:prefixedMobileNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}


/* This Function Convert Error Code Into Error String. */
+(NSString *) convertErrorCodeToErrorString:(int)errorCode
{
    NSString *errorString = nil;
    switch (errorCode) {
        case 1:
            break;
        case 2:
            errorString = NSLocalizedString(@"ERROR_CODE_2", nil);
            break;
        case 3:
            errorString = NSLocalizedString(@"ERROR_CODE_3", nil);
            break;
        case 4:
            errorString = NSLocalizedString(@"ERROR_CODE_4", nil);
            break;
        case 5:
            errorString = NSLocalizedString(@"ERROR_CODE_5", nil);
            break;
        case 6:
            errorString = NSLocalizedString(@"ERROR_CODE_6", nil);
            break;
        case 7:
            errorString = NSLocalizedString(@"ERROR_CODE_7", nil);
            break;
        case 8:
            errorString = NSLocalizedString(@"ERROR_CODE_8", nil);
            break;
        case 9:
            errorString = NSLocalizedString(@"ERROR_CODE_9", nil);
            break;
        case 10:
            errorString = NSLocalizedString(@"ERROR_CODE_10", nil);
            break;
        case 11:
            errorString = NSLocalizedString(@"ERROR_CODE_11", nil);
            break;
        case 12:
            errorString = NSLocalizedString(@"ERROR_CODE_12", nil);
            break;
        case 13:
            errorString = NSLocalizedString(@"ERROR_CODE_13", nil);
            break;
        case 14:
            errorString = NSLocalizedString(@"ERROR_CODE_14", nil);
            break;
        case 15:
            errorString = NSLocalizedString(@"ERROR_CODE_15", nil);
            break;
        case 16:
            errorString = NSLocalizedString(@"ERROR_CODE_16", nil);
            break;
        case 17:
            errorString = NSLocalizedString(@"ERROR_CODE_17", nil);
            break;
        case 18:
            errorString = NSLocalizedString(@"ERROR_CODE_18", nil);
            break;
        case 19:
            errorString = NSLocalizedString(@"ERROR_CODE_19", nil);
            break;
        case 20:
            errorString = NSLocalizedString(@"ERROR_CODE_20", nil);
            break;
        case 21:
            errorString = NSLocalizedString(@"ERROR_CODE_21", nil);
            break;
        case 22:
            errorString = NSLocalizedString(@"ERROR_CODE_22", nil);
            break;
        case 23:
            errorString = NSLocalizedString(@"ERROR_CODE_23", nil);
            break;
        case 24:
            errorString = NSLocalizedString(@"ERROR_CODE_24", nil);
            break;
        case 25:
            errorString = NSLocalizedString(@"ERROR_CODE_25", nil);
            break;
        case 26:
            errorString = NSLocalizedString(@"ERROR_CODE_26", nil);
            break;
        case 27:
            errorString = NSLocalizedString(@"ERROR_CODE_27", nil);
            break;
        case 28:
            errorString = NSLocalizedString(@"ERROR_CODE_28", nil);
            break;
        case 29:
            errorString = NSLocalizedString(@"ERROR_CODE_29", nil);
            break;
        case 30:
            errorString = NSLocalizedString(@"ERROR_CODE_30", nil);
            break;
        case 31:
            errorString = NSLocalizedString(@"ERROR_CODE_31", nil);
            break;
        case 32:
            errorString = NSLocalizedString(@"ERROR_CODE_32", nil);
            break;
        case 33:
            errorString = NSLocalizedString(@"ERROR_CODE_33", nil);
            break;
        case 34:
            errorString = NSLocalizedString(@"ERROR_CODE_34", nil);
            break;
        case 35:
            errorString = NSLocalizedString(@"ERROR_CODE_35", nil);
            break;
        case 36:
            errorString = NSLocalizedString(@"ERROR_CODE_36", nil);
            break;
        case 37:
            errorString = NSLocalizedString(@"ERROR_CODE_37", nil);
            break;
        case 38:
            errorString = NSLocalizedString(@"ERROR_CODE_38", nil);
            break;
        case 39:
            errorString = NSLocalizedString(@"ERROR_CODE_39", nil);
            break;
        case 40:
            errorString = NSLocalizedString(@"ERROR_CODE_40", nil);
            break;
        case 41:
            errorString = NSLocalizedString(@"ERROR_CODE_41", nil);
            break;
        case 42:
            errorString = NSLocalizedString(@"ERROR_CODE_42", nil);
            break;
        case 43:
            errorString = NSLocalizedString(@"ERROR_CODE_43", nil);
            break;
        case 44:
            errorString = NSLocalizedString(@"ERROR_CODE_44", nil);
            break;
        case 45:
            errorString = NSLocalizedString(@"ERROR_CODE_45", nil);
            break;
        case 46:
            errorString = NSLocalizedString(@"ERROR_CODE_46", nil);
            break;
        case 47:
            errorString = NSLocalizedString(@"ERROR_CODE_47", nil);
            break;
        case 48:
            errorString = NSLocalizedString(@"ERROR_CODE_48", nil);
            break;
        case 49:
            errorString = NSLocalizedString(@"ERROR_CODE_49", nil);
            break;
        case 50:
            errorString = NSLocalizedString(@"ERROR_CODE_50", nil);
            break;
        case 51:
            errorString = NSLocalizedString(@"ERROR_CODE_51", nil);
            break;
        case 52:
            errorString = NSLocalizedString(@"ERROR_CODE_52", nil);
            break;
        case 53:
            errorString = NSLocalizedString(@"ERROR_CODE_53", nil);
            break;
        case 54:
            errorString = NSLocalizedString(@"ERROR_CODE_54", nil);
            break;
        case 55:
            errorString = NSLocalizedString(@"ERROR_CODE_55", nil);
            break;
        case 56:
            errorString = NSLocalizedString(@"ERROR_CODE_56", nil);
            break;
        case 57:
            errorString = NSLocalizedString(@"ERROR_CODE_57", nil);
            break;
        case 58:
            errorString = NSLocalizedString(@"ERROR_CODE_58", nil);
            break;
        case 59:
            errorString = NSLocalizedString(@"ERROR_CODE_59", nil);
            break;
        case 60:
            errorString = NSLocalizedString(@"ERROR_CODE_60", nil);
            break;
        case 61:
            errorString = NSLocalizedString(@"ERROR_CODE_61", nil);
            break;
        case 62:
            errorString = NSLocalizedString(@"ERROR_CODE_62", nil);
            break;
        case 63:
            errorString = NSLocalizedString(@"ERROR_CODE_63", nil);
            break;
        case 64:
            errorString = NSLocalizedString(@"ERROR_CODE_64", nil);
            break;
        case 65:
            errorString = NSLocalizedString(@"ERROR_CODE_65", nil);
            break;
        case 66:
            errorString = NSLocalizedString(@"ERROR_CODE_66", nil);
            break;
        case 67:
            errorString = NSLocalizedString(@"ERROR_CODE_67", nil);
            break;
        case 68:
            errorString = NSLocalizedString(@"ERROR_CODE_68", nil);
            break;
        case 69:
            errorString = NSLocalizedString(@"ERROR_CODE_69", nil);
            break;
        case 70:
            errorString = NSLocalizedString(@"ERROR_CODE_70", nil);
            break;
        case 71:
            errorString = NSLocalizedString(@"ERROR_CODE_71", nil);
            break;
        case 72:
            errorString = NSLocalizedString(@"ERROR_CODE_72", nil);
            break;
        case 73:
            errorString = NSLocalizedString(@"ERROR_CODE_73", nil);
            break;
        case 74:
            errorString = NSLocalizedString(@"ERROR_CODE_74", nil);
            break;
        case 75:
            errorString = NSLocalizedString(@"ERROR_CODE_75", nil);
            break;
        case 76:
            errorString = NSLocalizedString(@"ERROR_CODE_76", nil);
            break;
            
        case 84:
            errorString = NSLocalizedString(@"ERROR_CODE_84", nil);
            break;
        case 85:
            errorString = NSLocalizedString(@"ERROR_CODE_85", nil);
            break;
        case 88:
            errorString = NSLocalizedString(@"ERROR_CODE_88", nil);
            break;
        case 94:
            errorString = NSLocalizedString(@"ERROR_CODE_94", nil);
            break;
        case NSURLErrorTimedOut://-1001
            errorString = NSLocalizedString(@"ERROR_CODE_1001", nil);
            break;
            
        case NSURLErrorCannotConnectToHost://-1004
            errorString = NSLocalizedString(@"ERROR_CODE_1004", nil);
            break;
            
        case kCFURLErrorNetworkConnectionLost://-1005
            errorString = NSLocalizedString(@"ERROR_CODE_1005", nil);
            break;
            
        case NSURLErrorBadServerResponse://-1011
            errorString = NSLocalizedString(@"ERROR_CODE_1004", nil);
            break;
        case -1009:
            errorString=NSLocalizedString(@"ERROR_CODE_1009", nil);
            break;
            
        default:
            break;
    }
    return errorString;
    
}

+(NSMutableDictionary *)convertStringJsonToDictionaryJson:(NSString*)stringJson
{
    if(stringJson != nil && [stringJson length]>0)
    {
        NSData *data = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSMutableDictionary *dictionaryJson =
        [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if(dictionaryJson != nil && [dictionaryJson count]>0)
        {
            return dictionaryJson;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}


+(NSString *)formattedGroupChatEventInformation:(NSString*)stringJson
{
    NSString *lineText;
    NSMutableDictionary *customSett = [Common convertStringJsonToDictionaryJson:stringJson];
    if(customSett != nil && [customSett count]>0)
    {
        NSString* currentStatusOfMember = [customSett valueForKey:@"eventType"];
        NSString *memberName = [customSett valueForKey:@"targetName"]!=[NSNull null] &&[[customSett valueForKey:@"targetName"] length]>0?[customSett valueForKey:@"targetName"]:[NSString stringWithFormat:@"+%@",[customSett valueForKey:@"targetContact"]];
        NSString *ownerName = [[customSett valueForKey:@"ownerName"] length]>0?[customSett valueForKey:@"ownerName"]:[NSString stringWithFormat:@"+%@",[customSett valueForKey:@"ownerContact"]];
        
        NSString* formattedString = [Common getFormattedNumber:memberName withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        
        if(!formattedString || !formattedString.length)
            formattedString = memberName;
        
        if ([@"deleted" isEqualToString:currentStatusOfMember]){
            lineText = [NSString stringWithFormat:@"%@ has been deleted from the group. ",formattedString];
        }
        else if ([@"create" isEqualToString:currentStatusOfMember]){
            NSString* memberCount = [customSett valueForKey:@"targetContact"];
            if(memberCount == [NSNull null]) { //TODO: CHECK
                memberCount = @"";
            }
            
            if(memberCount && memberCount.length > 0 && ![memberCount isEqualToString:[customSett valueForKey:@"ownerContact"]])
            {
                lineText = [NSString stringWithFormat:@"%@ has created the group with %d members.",ownerName,[memberCount intValue]];
            }
            else
            {
                lineText = [NSString stringWithFormat:@"%@ has created the group. ",ownerName];
            }
        }
        else if ([@"left" isEqualToString:currentStatusOfMember]) {
            lineText = [NSString stringWithFormat:@"%@ has left the group. ",formattedString];
        }
        else if ([@"joined" isEqualToString:currentStatusOfMember]) {
            
            lineText = [NSString stringWithFormat:@"%@ has been added to this group. ",formattedString];
        }
    }
    return lineText;
}

//- Call this method if phoneNumber is a valid phone number against the given country code
+(NSString *)removeCountryCodeFrom:(NSString*)phoneNumber CCMaxLength:(NSInteger)maxLen CCMinLength:(NSInteger)minLen {
    
    NBPhoneNumberUtil* phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSString* numberWithoutCountryCode = @"";
    NSNumber* countryIsdCode = [phoneUtil extractCountryCode:phoneNumber nationalNumber:&numberWithoutCountryCode];
    
    if(maxLen > numberWithoutCountryCode.length || minLen < numberWithoutCountryCode.length)
        return phoneNumber;
    else
        return [phoneNumber substringFromIndex:[[countryIsdCode stringValue] length]];
}

+(NSString *)getFormattedNumber:(NSString *)number withCountryIsdCode:(NSString *)providedCountryIsdCode withGivenNumberisCannonical:(BOOL)isCannonical
{
    number = [self removePlus:number];
    
    //FEB 20, 2017 NSString *trimmedString = [number stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    NSString* trimmedString = [number stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(![trimmedString length]) {
        return nil;
    }
    
    if(number.length > 0)
    {
        NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
        NSNumber *countryIsdCode;
        
        if(isCannonical)
        {
            countryIsdCode = [phoneUtil extractCountryCode:number nationalNumber:nil];
            number = [number substringFromIndex:[[countryIsdCode stringValue] length]];
        }
        
        if([[countryIsdCode stringValue] length] == 0)
        {
            if ([providedCountryIsdCode length] != 0) {
                countryIsdCode = [NSNumber numberWithInt:[providedCountryIsdCode intValue]];
            }
            else
            {
                countryIsdCode = [NSNumber numberWithInt:[[[ConfigurationReader sharedConfgReaderObj]getCountryISD] intValue]];
            }
        }
        
        NSString *countryIsdCodeString = [NSString stringWithFormat:@"%@",countryIsdCode];
        
        NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCodeString];
        NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:countrySimIso];
        
        NBPhoneNumber *myNumber = [phoneUtil parse:number defaultRegion:countrySimIso error:nil];
        
        NSString *formattedNumber=nil;
        if(nil != myNumber)
        {
            NSString *numberE164format = [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164 error:nil];
            
            if([numberE164format length] != 0){
                formattedNumber = [f inputString:numberE164format];
            } else {
                formattedNumber = [f inputString:[@"+" stringByAppendingString:number]];
            }
        } else {
            //Debug KLog(@"myNumber is nil");
        }
        
        return formattedNumber;
    }
    return nil;
}

+(BOOL)isValidNumber:(NSString *)number withContryISDCode:(NSString *)countryIsdCode{
    BOOL isValid = false;
    NSError *anError = nil;
    
    NSString *trimmedString = [number stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if ([trimmedString length] > 0) {
        return false;
    }
    
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCode];
    
    if([countrySimIso length] == 0)
    {
        NSNumber *extractedCountryIsdCode = [phoneUtil extractCountryCode:number nationalNumber:nil];
        countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:[extractedCountryIsdCode stringValue]];
    }
    
    NBPhoneNumber *myNumber = [phoneUtil parse:number
                                 defaultRegion:countrySimIso error:&anError];
    if (anError == nil) {
        if([phoneUtil isValidNumber:myNumber]){
            isValid = true;
        }
    }
    else{
        KLog(@"Error : %@", [anError localizedDescription]);
        [ScreenUtility showAlert:NSLocalizedString(@"ENTER_CORRECT_NUMBER", nil)];
    }
    
    return isValid;
}

+ (NSString*)getCountryCodeFrom:(NSString *)phoneNumber {
    NBPhoneNumberUtil* phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSNumber* extractedCountryIsdCode = [phoneUtil extractCountryCode:phoneNumber nationalNumber:nil];
    return [extractedCountryIsdCode stringValue];
}

+(BOOL)isPossibleNumber:(NSString *)number withContryISDCode:(NSString *)countryIsdCode showAlert:(BOOL)alert {
    
    BOOL isPossible = false;
    NSError *anError = nil;
    
    NSString *trimmedString = [number stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if ([trimmedString length] > 0) {
        return false;
    }
    
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCode];
    
    if([countrySimIso length] == 0)
    {
        NSNumber *extractedCountryIsdCode = [phoneUtil extractCountryCode:number nationalNumber:nil];
        countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:[extractedCountryIsdCode stringValue]];
    }
    NBPhoneNumber *myNumber = [phoneUtil parse:number
                                 defaultRegion:countrySimIso error:&anError];
    if (anError == nil) {
        //[[ConfigurationReader sharedConfgReaderObj]setPossibleNumber:@"YES"];
        [self performSelectorOnMainThread:@selector(setPossibleNumber) withObject:nil waitUntilDone:NO];
        if([phoneUtil isPossibleNumber:myNumber error:nil]){
            isPossible = true;
            
        }
    }
    else {
        KLog(@"Error : %@", [anError localizedDescription]);
        if(alert)
            [ScreenUtility showAlert:NSLocalizedString(@"ENTER_CORRECT_NUMBER", nil)];
        [[ConfigurationReader sharedConfgReaderObj]setPossibleNumber:@"NO"];
    }
    
    return isPossible;
}

+(void)setPossibleNumber {
    [[ConfigurationReader sharedConfgReaderObj]setPossibleNumber:@"YES"];
}

+(NSString *)getE164FormatNumber:(NSString *)numberWithoutFormat withCountryIsdCode:(NSString *)countryIsdCode
{
    NSString *numberE164format = nil;
    
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCode];
    NSError *anError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:numberWithoutFormat
                                 defaultRegion:countrySimIso error:&anError];
    numberE164format        = [phoneUtil format:myNumber
                                   numberFormat:NBEPhoneNumberFormatE164
                                          error:&anError];
    
    return numberE164format;
}

+(NSString *)getInternationalFormatNumber:(NSString *)numberWithoutFormat
{
    NSString *numberInternationalformat = nil;
    
    //NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCode];
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSError *anError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parseWithPhoneCarrierRegion:[NSString stringWithFormat:@"+%@",numberWithoutFormat] error:&anError];
    numberInternationalformat = [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:&anError];
    
    return numberInternationalformat;
}

+(NSString *)getFormattedNumberForTextFieldWithNumber:(NSString *)numberWithoutFormat andCountryIsdCode:(NSString *)countryIsdCode{
    NSString *formattedNumber;
    
    NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCode];
    NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:countrySimIso];
    
    formattedNumber = [f inputString:numberWithoutFormat];
    
    return formattedNumber;
}

+(BOOL)isValidEmail:(NSString*)emailId
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailId];
}

/**Method to check if branding screen to be shown or not*/
+ (BOOL)showBrandingScreenViewController{
   BOOL check = false;
    
    //Check for carrier logo information - for primary number.
    NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
    NSString* localFileName = [NSString stringWithFormat:@"CarrierLogo_%@.png",loginId];
    
    NSString *storagePathName   = [IVFileLocator getCarrierLogoPath:localFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:storagePathName]) {
        //We have carrier logo information.
        check = true;
    }
    else {
        //If no carrier logo for primary number - check do we have carrier logo path - try to download the information and update the logo, if failed to download the logo image - show the default logo.
        VoiceMailInfo *currentVoiceMailInfo = [[Setting sharedSetting]voiceMailInfoForPhoneNumber:[ConfigurationReader sharedConfgReaderObj].getLoginId];
        if ([currentVoiceMailInfo.carrierLogoPath length] && [[ConfigurationReader sharedConfgReaderObj]getIsLoggedIn]) {
            check = true; 
            //Start downlaoding the carrier logo image.
            [[Setting sharedSetting]downloadAndSaveCarrierLogoImage:currentVoiceMailInfo.carrierLogoPath];
        }
        else {
            NSString *mccmnc = [[ConfigurationReader sharedConfgReaderObj]getCountryMCCMNC];
            //Start: Nivedita - Date 1st Feb - As per latest requirement adding branding image for : TNM Malawi MCC MNC Code : 650 01
            if([mccmnc isEqualToString:NSLocalizedString(@"TNMMalawi", nil)] && [[ConfigurationReader sharedConfgReaderObj]getShowBrandingScreen])
                check = true;
            //End:Nivedita
            else if(([mccmnc isEqualToString:NSLocalizedString(@"AIRTEL_NIGERIA", nil)] || [mccmnc isEqualToString:NSLocalizedString(@"GLO_NIGERIA", nil)]||[mccmnc isEqualToString:NSLocalizedString(@"VODAFONE_GHANA", nil)])&& [[ConfigurationReader sharedConfgReaderObj]getShowBrandingScreen]){
                check = true;
            }

        }
    }
    
    return check;
}


/** Method responsible to decide the font based on the dynamic font changes in the device settings.
 * @param fontStyle : Indicates the font of the text.
 * @param fontScale : Indicates the font scale.
 */

+ (UIFont *)preferredFontForTextStyleInApp:(NSString *)fontStyle {
    
    // We first get prefered font descriptor for provided style.
    UIFontDescriptor *currentDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:fontStyle];
    
    // Then we get the default size from the descriptor.
    // This size can change between iOS releases.
    // and should never be hard-codded.
    CGFloat headlineSize = [currentDescriptor pointSize];
    CGFloat scaledHeadlineSize = headlineSize;
    // KLog(@"Headline Size =%f", headlineSize);
    
    
    if([UIFontTextStyleBody isEqualToString:fontStyle]) {
        // CGFloat fontScale = 0.0;
        if(headlineSize >= kBodyTextMaxFontSize) {
            scaledHeadlineSize = kBodyTextMaxFontSize;
            /* fontScale = kFontMaxScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize * fontScale);
             */
        }
        //This is safer side calculating - Minimum font size in the iOS is 11.
        else if(headlineSize <= kBodyTextMinFontSize) {
            
            scaledHeadlineSize = kBodyTextMinFontSize;
            /* fontScale = kFontMinScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize/fontScale);
             */
        }
        
    }
    
    else if([UIFontTextStyleCaption1 isEqualToString:fontStyle]) {
        // CGFloat fontScale = 0.0;
        if(headlineSize >= kCaption1TextMaxFontSize) {
            scaledHeadlineSize = kCaption1TextMaxFontSize;
            /* fontScale = kFontMaxScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize * fontScale);
             */
        }
        //This is safer side calculating - Minimum font size in the iOS is 11.
        else if(headlineSize <= kCaption1TextMinFontSize) {
            scaledHeadlineSize = kCaption1TextMinFontSize;
            /* fontScale = kFontMinScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize/fontScale);
             */
        }
    }
    //DC
    else if([UIFontTextStyleFootnote isEqualToString:fontStyle]) {
        // CGFloat fontScale = 0.0;
        if(headlineSize >= kFootNoteTextMaxFontSize) {
            scaledHeadlineSize = kFootNoteTextMaxFontSize;
            /* fontScale = kFontMaxScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize * fontScale);
             */
        }
        //This is safer side calculating - Minimum font size in the iOS is 11.
        else if(headlineSize <= kFootNoteMinFontSize) {
            scaledHeadlineSize = kFootNoteMinFontSize;
            /* fontScale = kFontMinScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize/fontScale);
             */
        }
    }
    else if([UIFontTextStyleCaption2 isEqualToString:fontStyle]) {
        // CGFloat fontScale = 0.0;
        if(headlineSize >= kCaption2TextMaxFontSize) {
            scaledHeadlineSize = kCaption2TextMaxFontSize;
            /* fontScale = kFontMaxScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize * fontScale);
             */
        }
        //This is safer side calculating - Minimum font size in the iOS is 11.
        else if(headlineSize <= kCaption2TextMinFontSize) {
            scaledHeadlineSize = kCaption2TextMinFontSize;
            /* fontScale = kFontMinScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize/fontScale);
             */
        }
    }
    else if([UIFontTextStyleSubheadline isEqualToString:fontStyle]) {
        // CGFloat fontScale = 0.0;
        if(headlineSize >= kSubheadlineTextMaxFontSize) {
            scaledHeadlineSize = kSubheadlineTextMaxFontSize;
            /* fontScale = kFontMaxScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize * fontScale);
             */
        }
        //This is safer side calculating - Minimum font size in the iOS is 11.
        else if(headlineSize <= kSubheadlineTextMinFontSize) {
            scaledHeadlineSize = kSubheadlineTextMinFontSize;
            /* fontScale = kFontMinScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize/fontScale);
             */
        }
    }
    
    else if([UIFontTextStyleHeadline isEqualToString:fontStyle]) {
        // CGFloat fontScale = 0.0;
        if(headlineSize >= kHeadlineTextMaxFontSize) {
            scaledHeadlineSize = kHeadlineTextMaxFontSize;
            /* fontScale = kFontMaxScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize * fontScale);
             */
        }
        //This is safer side calculating - Minimum font size in the iOS is 11.
        else if(headlineSize <= kHeadlineTextMinFontSize) {
            scaledHeadlineSize = kHeadlineTextMinFontSize;
            /* fontScale = kFontMinScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize/fontScale);
             */
        }
    }
    //
    else {
        // CGFloat fontScale = 0.0;
        if(headlineSize > kTextMaxFontSize) {
            scaledHeadlineSize = kTextMaxFontSize;
            /* fontScale = kFontMaxScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize * fontScale);
             */
        }
        //This is safer side calculating - Minimum font size in the iOS is 11.
        else if(headlineSize < kTextMinFontSize) {
            scaledHeadlineSize = kTextMinFontSize;
            /* fontScale = kFontMinScaleFactor;
             // We are calculating new size using the provided scale.
             scaledHeadlineSize = lrint(headlineSize/fontScale);
             */
        }
        
    }
    
    UIFont *selectedFont = [UIFont fontWithDescriptor:currentDescriptor size:scaledHeadlineSize];
    
    // This method will return a font which matches the given descriptor
    // (keeping all the attributes like 'bold' etc. from currentDescriptor),
    // but it will use provided size if it's greater than 0.0.
    return selectedFont;
}

/** Method responsible to calculate the size of the rect based on the font and text.
 * @param withText: Instance indicates the text
 * @param withFont: Instance indicates the font used for displaying the text.
 */

+ (CGSize)sizeOfViewWithText:(NSString *)withText withFont:(UIFont *)withFont {
    
    CGSize max = CGSizeMake(DEVICE_WIDTH - 80,CGFLOAT_MAX);
    CGRect rect;
    
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        
        NSMutableParagraphStyle *pstyle = [NSMutableParagraphStyle new];
        pstyle.lineBreakMode = NSLineBreakByWordWrapping;
        UIFont *font = [Common preferredFontForTextStyleInApp:withFont.fontName];
        rect = [withText boundingRectWithSize:CGSizeMake(DEVICE_WIDTH - 80, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :font,NSParagraphStyleAttributeName:[pstyle copy]} context:nil];
        
        
    }
    else {
        CGRect textRect = [withText boundingRectWithSize:max
                                                 options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                              attributes:@{NSFontAttributeName:withFont}
                                                 context:nil];
        rect.size.width = textRect.size.width;
    }
    
    return rect.size;
    
}

/*
 #import "mach/mach.h"
 
 vm_size_t usedMemory(void) {
 struct task_basic_info info;
 mach_msg_type_number_t size = sizeof(info);
 kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
 return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
 }
 
 vm_size_t freeMemory(void) {
 mach_port_t host_port = mach_host_self();
 mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
 vm_size_t pagesize;
 vm_statistics_data_t vm_stat;
 
 host_page_size(host_port, &pagesize);
 (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
 return vm_stat.free_count * pagesize;
 }
 
 +(void) logMemUsage {
 // compute memory usage and log if different by >= 100k
 static long prevMemUsage = 0;
 long curMemUsage = usedMemory();
 long memUsageDiff = curMemUsage - prevMemUsage;
 
 if (memUsageDiff > 100000 || memUsageDiff < -100000) {
 prevMemUsage = curMemUsage;
 KLog(@"Memory used %7.1f (%+5.0f), free %7.1f kb", curMemUsage/1000.0f, memUsageDiff/1000.0f, freeMemory()/1000.0f);
 }
 }
 */


//Caution: Please call this method - if only network is available
/** Method returns the current networkType
 @return Returns the current network type - WiFi, 2G or 3G
 */

+ (NSInteger)currentNetworkType {
    
    NSInteger currentNetworkType = eNoNetworkType;
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [reachability currentReachabilityStatus];
        switch (networkStatus)
        {
            case NotReachable:
                currentNetworkType = eNoNetworkType;
                break;
            case ReachableViaWiFi:
                currentNetworkType = eCurrentNetworkTypeWiFi;
                break;
            case ReachableViaWWAN:
                currentNetworkType = [[IVFastNetworkInfo sharedIVFastNetworkInfo]currentDataNetworkType];
                break;
            default:
                break;
        }
    
    return currentNetworkType;
}

+ (float)currentiOSVersion {
    float currentiOSVersion = 0.0;
    currentiOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
    return currentiOSVersion;
}

+ (NSString *)simMCCMNCCode {
    
    NSString *simMCCMNCCode;
    if (SIM_AVAILABLE == [self isSIMAvailable]) {
        NSMutableDictionary *dic = [Common getSIMInfo];
        if(dic != nil && [dic count] >0)
        {
            NSString *mcc = [dic valueForKey:COUNTRY_SIM_MCC];
            NSString *mnc = [dic valueForKey:COUNTRY_SIM_MNC];
            if((mcc != nil && [mcc length] >0) && (mnc != nil && [mnc length]>0))
                simMCCMNCCode = [[NSString alloc] initWithFormat:@"%@%@",mcc,mnc];
        }
    }
    return simMCCMNCCode;
}

+ (NSString *)simCountryCode {
  
    NSString *countryCode;
    NSMutableDictionary *dic = [Common getSIMInfo];
    if(dic != nil && [dic count] >0)
    {
        NSString *iso = [dic valueForKey:COUNTRY_SIM_ISO];
        if(iso != nil && [iso length] >0)
        {
            //below line commented unused variable
            //NSString *where = [[NSString alloc] initWithFormat:@"WHERE %@=\"%@\"",COUNTRY_SIM_ISO,[iso uppercaseString]];
            NSArray *countryList = [[Setting sharedSetting]getCountryList];
            NSMutableArray *countries = [NSMutableArray arrayWithArray:countryList];
            if(countries != nil && [countries count] >0)
            {
                for (int i= 0; i< [countries count]; i++)
                {
                    NSMutableDictionary *dic = [countries objectAtIndex:i];
                    NSString *countruIso = [dic valueForKey:COUNTRY_SIM_ISO];
                    if([[iso uppercaseString] isEqualToString:countruIso])
                       countryCode = [dic valueForKey:COUNTRY_CODE];
                }
            }
        }
    }
    return countryCode;
}

//- DEBUG
/*
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <netdb.h>
+(void)enumeateIfAddresses {

    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSInteger success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Get NSString from C String
                NSString* ifaName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString* address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_addr)->sin_addr)];
                NSString* mask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_netmask)->sin_addr)];
                NSString* gateway = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_dstaddr)->sin_addr)];
                NSLog(@"*** IF -- %@;%@;%@;%@",ifaName,address,mask,gateway);
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    int index = if_nametoindex("pdp_ip0");
    NSLog(@"*** index of pdp_ip0: %d",index);
}
*/

@end
