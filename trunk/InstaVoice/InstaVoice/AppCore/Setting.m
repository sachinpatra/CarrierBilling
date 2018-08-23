//
//  Setting.m
//  InstaVoice
//
//  Created by adwivedi on 24/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "Setting.h"
#import "FetchUserSettingAPI.h"
#import "UpdateUserSettingAPI.h"
#import "DisconnectFBTwitterApi.h"
#import "Macro.h"
#import "TableColumns.h"
#import "RegistrationApi.h"
#import "ConfigurationReader.h"
#import "Common.h"
#import "SetDeviceInfoAPI.h"
#import "IVFileLocator.h"
#import "MQTTManager.h"
#import "PendingEventManager.h"
#import "ConfigurationReader.h"
#import "Profile.h"
#import "FetchCarriersListAPI.h"
#import "DownloadProfilePic.h"
#import "IVSettingsCountryCarrierInfo.h"
#import "ConfigurationReader.h"
#import "ScreenUtility.h"

static Setting* sharedSetting = nil;

@implementation Setting

-(id)init
{
    if(self = [super init])
    {
        NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath]
                                     stringByAppendingPathComponent:@"Setting.dat"];
        
        @try {
            self.data = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];
        }
        @catch (NSException *exception) {
            KLog(@"Unable to create object from archive file");
        }
        
        
        NSString* archiveFilePathContact = [[IVFileLocator getDocumentDirectoryPath]
                                            stringByAppendingPathComponent:@"SupportContact.dat"];
        @try {
            self.supportContactList = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePathContact];
        }
        @catch (NSException *exception) {
            KLog(@"Unable to create object from archive file");
        }
        
        NSString* archiveFilePathCountry = [[IVFileLocator getDocumentDirectoryPath]
                                            stringByAppendingPathComponent:@"Country.dat"];
        @try {
            _countryList = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePathCountry];
        }
        @catch (NSException *exception) {
            KLog(@"Unable to create object from archive file");
        }
        
        
        if(self.data == Nil)
        {
            self.data = [[SettingModel alloc]init];
        }
        if(_supportContactList == Nil)
        {
            _supportContactList = [[NSArray alloc]init];
        }
        if(_countryList == Nil)
        {
            _countryList = [self getCountryListFromFile];
            [NSKeyedArchiver archiveRootObject:_countryList toFile:archiveFilePathCountry];
        }
        
        _isVoicemailSupported = FALSE;
    }
    return self;
}

+(Setting *)sharedSetting
{
    static Setting *sharedSettings;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSettings = [[self alloc]init];
    });
    return sharedSettings;
}

//Modified the logic of method by Nivedita -Date 13th Jan, Saved the status fetch settings in the user defaults.
-(void)getUserSettingFromServer
{
    KLog(@"getUserSettingFromServer");
    
    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        EnLogd(@"No Network");
        return;
    }
    
    NSMutableDictionary* reqDic = [[NSMutableDictionary alloc]init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
#ifdef REACHME_APP
    if ([[ConfigurationReader sharedConfgReaderObj] getCarrierInfoUpdateStatus] && [Common isNetworkAvailable] == NETWORK_AVAILABLE)
    {
        NSMutableDictionary* request = [[NSMutableDictionary alloc]init];
        // Initialise a new, empty mutable array
        NSMutableArray *unique = [NSMutableArray array];
        
        for (id obj in self.data.carrierInfoList) {
            if (![unique containsObject:obj]) {
                [unique addObject:obj];
            }
        }
        self.data.carrierInfoList = unique;
        [request setObject:self.data.carrierInfoList forKey:kCarrierInfo];
        
        [self writeSettingDataInFile];
        
        UpdateUserSettingAPI* api = [[UpdateUserSettingAPI alloc]initWithRequest:request];
        [api callNetworkRequest:self.data withSuccess:^(UpdateUserSettingAPI *req, BOOL responseObject) {
            [[ConfigurationReader sharedConfgReaderObj] setCarrierInfoUpdateStatus:NO];
            [self getUserSettingFromServer];
        } failure:^(UpdateUserSettingAPI *req, NSError *error) {
            [[ConfigurationReader sharedConfgReaderObj] setCarrierInfoUpdateStatus:YES];
            [self getUserSettingFromServer];
        }];
        return;
    }
#endif
    
    BOOL fetchServerSettingsStatus = [[userDefaults valueForKey:kUserSettingsFetched] boolValue];
    
    //Start fetching the data - if we already not fetched the data or we do not have locally saved data.
    if(!fetchServerSettingsStatus || nil == self.data) {
        
        FetchUserSettingAPI* req = [[FetchUserSettingAPI alloc]initWithRequest:reqDic];
        [req callNetworkRequest:reqDic withSuccess:^(FetchUserSettingAPI *req, SettingModel* responseObject) {
            //save support contact
            EnLogd(@"Fetch Settings:%@", responseObject);
            KLog(@"Fetch Settings:%@", responseObject);
            NSString *supportIDs = [req.response valueForKey:API_IV_SUPPORT_CONTACT_IDS];
            NSData *data = [supportIDs dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            [self saveSupportContacts:arr];
            self.data = responseObject;
            
            NSString *primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
            NSString *themeColorForPrimaryNo = [self getCarrierThemeColorForNumber:primaryNumber];
            [self setCarrierThemeColorForNumber:themeColorForPrimaryNo number:primaryNumber];
            [self writeSettingDataInFile];
            
#ifdef MQTT_ENABLED
            if(![[MQTTManager sharedMQTTManager]isConnected])
                [[MQTTManager sharedMQTTManager]connectMQTTClient];
#endif
            
            //Set the user defaults.
            if(userDefaults) {
                [userDefaults setObject:@YES forKey:kUserSettingsFetched];
                [userDefaults synchronize];
            }
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(fetchSettingCompletedWith:withFetchStatus:)])
                [self.delegate fetchSettingCompletedWith:self.data withFetchStatus:YES];
            
            //July 18, 2018
            AppDelegate *appDelegate = (AppDelegate *)APP_DELEGATE;
            [appDelegate fetchSettingCompleteWithStatus:YES];
            //
            
            [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidSucceedWithResponse:reqDic forPendingEventType:PendingEventTypeFetchSetting];
            
            //Data migration related.
            if (self.data.shouldUpdateToServer) {
                //Update carrier data to server.
                //Check we have carrier data, if so remove "+" sign in the phone number,update the network ID and country code id.
                if (self.data.carrierDetails) {
                    
                    NSMutableArray *carrierList = [[NSMutableArray alloc]init];
                    NSData *carrierData = [self.data.carrierDetails dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *error = nil;
                    NSMutableDictionary *carrierInfoList = [NSJSONSerialization JSONObjectWithData:carrierData options:0 error:&error];
                    if(carrierInfoList && [[carrierInfoList allKeys]count]) {
                        for(id phoneNumber in carrierInfoList) {
                            // KLog(@"Carrier info details =%@", [carrierInfoList objectForKey:phoneNumber]);
                            CarrierInfo *carrierInfoObj = [[CarrierInfo alloc]initWithPhoneNumber:phoneNumber withCarrierDetails:[carrierInfoList objectForKey:phoneNumber]];
                            [carrierList addObject:carrierInfoObj];
                            
                            //Update the carrier information
                            [self updateCarrierSettingsInfo:carrierInfoObj];
                        }
                    }
                }
                
                if (self.data.numberDetails) {
                    
                    NSMutableArray *numberList = [[NSMutableArray alloc]init];
                    NSData *numberData = [self.data.numberDetails dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *error = nil;
                    NSMutableDictionary *numberInfoList = [NSJSONSerialization JSONObjectWithData:numberData options:0 error:&error];
                    if(numberInfoList && [[numberInfoList allKeys]count]) {
                        for(id phoneNumber in numberInfoList) {
                            // KLog(@"Carrier info details =%@", [carrierInfoList objectForKey:phoneNumber]);
                            NumberInfo *numberInfoObj = [[NumberInfo alloc]initWithPhoneNumber:phoneNumber withNumberDetails:[numberInfoList objectForKey:phoneNumber]];
                            [numberList addObject:numberInfoObj];
                            
                            //Update the carrier information
                            [self updateNumberSettingsInfo:numberInfoObj];
                        }
                    }
                }
                
            }
        } failure:^(FetchUserSettingAPI *req, NSError *error) {
            EnLogd(@"Fetch Settings Failure:%@",error);
            KLog(@"Fetch Settings Failure:%@",error);
            PendingEventManager* peEvtMgr = [PendingEventManager sharedPendingEventManager];
            if(nil != peEvtMgr) { //SEP 13, 2016
                [[PendingEventManager sharedPendingEventManager]pendingEventManagerDidFailWithError:error
                                                                                forPendingEventType:PendingEventTypeFetchSetting];
            }
            
            //Set the user defaults.
            if(userDefaults) {
                [userDefaults setObject:@NO forKey:kUserSettingsFetched];
                [userDefaults synchronize];
            }
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(fetchSettingCompletedWith:withFetchStatus:)])
                [self.delegate fetchSettingCompletedWith:self.data withFetchStatus:NO];
            
            //July 18, 2018
            AppDelegate *appDelegate = (AppDelegate *)APP_DELEGATE;
            [appDelegate fetchSettingCompleteWithStatus:NO];
            //
        }];
    }
}


-(void)writeSettingDataInFile
{
    NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath]
                                 stringByAppendingPathComponent:@"Setting.dat"];
    BOOL bSaved = [NSKeyedArchiver archiveRootObject:self.data toFile:archiveFilePath];
    if(bSaved) {
        KLog(@"archiveRootObject returns TRUE");
        /* Debug
        SettingModel* pdata= [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];
        for (VoiceMailInfo *voiceMailInfo in pdata.voiceMailInfo) {
            KLog(@"Debug");
        }*/
        
    } else {
        KLog(@"archiveRootObject returns FALSE");
        EnLogd(@"Error saving settings");
    }
}


-(void)updateUserSettingType:(SettingType)type andValue:(NSUInteger)value
{
    NSMutableDictionary* request = [[NSMutableDictionary alloc]init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    switch (type) {
        case SettingTypeMaxRecordTime: {
            [request setValue:[NSNumber numberWithInteger:value] forKey:MAX_RECORD_TIME];
            self.data.maxRecordTime = value;
            break;
            
        }
        case SettingTypeVoboloEnable: {
            [request setValue:[NSNumber numberWithInteger:value] forKey:VB_ENABLE];
            self.data.vbEnabled = value;
            break;
        }
        case SettingTypeVoboloFBAutoPostEnable: {
            [request setValue:[NSNumber numberWithInteger:value] forKey:FB_POST_ENABLED];
            NSNumber *boolValueOfFbPostEnabled = [NSNumber numberWithInteger:value];
            self.data.fbPostEnabled = [boolValueOfFbPostEnabled boolValue];
            break;
        }
        case SettingTypeVoboloTWAutoPostEnable: {
            [request setValue:[NSNumber numberWithInteger:value] forKey:TW_POST_ENABLED];
            NSNumber *boolValueOfTWPostEnabled = [NSNumber numberWithInteger:value];
            self.data.twPostEnabled = [boolValueOfTWPostEnabled boolValue];
            break;
        }case SettingTypeUserManualTrans: {
            [request setValue:[NSNumber numberWithInteger:value] forKey:API_USER_MANUAL_ENABLED];
            NSNumber *boolValueOfTWPostEnabled = [NSNumber numberWithInteger:value];
            self.data.userManualTrans = [boolValueOfTWPostEnabled boolValue];
            break;
        }
        default:
            break;
    }
    
    [self writeSettingDataInFile];
    //Commented by Nivedita to fix the bug : 8233
    if(type != SettingTypeDisplayLocation)
    {
        UpdateUserSettingAPI* api = [[UpdateUserSettingAPI alloc]initWithRequest:request];
        [api callNetworkRequest:self.data withSuccess:^(UpdateUserSettingAPI *req, BOOL responseObject) {
            //[self writeSettingDataInFile];
            [userDefaults setObject:@YES forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            
            //Update to the server is successful. So, for the next fetch operation - we need to fetch settings data freshly.
            [userDefaults setObject:@NO forKey:kUserSettingsFetched];
            [userDefaults synchronize];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:YES];
            
        } failure:^(UpdateUserSettingAPI *req, NSError *error) {
            [userDefaults setObject:@NO forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            if(self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)]) {
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:NO];
            }
        }];
    }
    else if(type == SettingTypeDisplayLocation) {
        
        //Get the location status from the user defaults and update the server.
        BOOL shareLocationStatus = [[userDefaults valueForKey:kShareLocationSettingsValue]boolValue];
        
        //Get the latest value of share location status in the Settings Model.
        SettingModel *latestSettingsData = [Setting sharedSetting].data;
        
        BOOL savedSettingsShareLocationStatus = latestSettingsData.displayLocation;
        //If saved settings share location is differ from the latest share location changes then update, do not blindly update the staus.
        if (savedSettingsShareLocationStatus != shareLocationStatus) {
            self.data.displayLocation = shareLocationStatus;
            [request setValue:[NSNumber numberWithInteger:shareLocationStatus] forKey:DISPLAY_LOCATION];
            UpdateUserSettingAPI* api = [[UpdateUserSettingAPI alloc]initWithRequest:request];
            [api callNetworkRequest:self.data withSuccess:^(UpdateUserSettingAPI *req, BOOL responseObject) {
                //[self writeSettingDataInFile];
                [userDefaults setObject:@YES forKey:kUserSettingsUpdated];
                [userDefaults synchronize];
                
                //Update to the server is successful. So, for the next fetch operation - we need to fetch settings data freshly.
                [userDefaults setObject:@NO forKey:kUserSettingsFetched];
                [userDefaults synchronize];
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                    [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:YES];
                
                
            } failure:^(UpdateUserSettingAPI *req, NSError *error) {
                [userDefaults setObject:@NO forKey:kUserSettingsUpdated];
                [userDefaults synchronize];
                if(self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                    [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:NO];
            }];
            
        }
        
    }
}

//Nivedita
/**
 Method to update the carrier settings information
 @param carrierDetails : Carrier details information
 */

- (void)updateCarrierSettingsInfo:(CarrierInfo *)carrierDetails numberSettingsInfo:(NumberInfo *)numberDetails
{
    NSMutableDictionary* request = [[NSMutableDictionary alloc]init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *carrierList = [[NSMutableArray alloc]init];
    
    if(self.data) {
        if(self.data.carrierDetails) {
            NSData *carrierData = [self.data.carrierDetails dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *carrierInfoList = [NSJSONSerialization JSONObjectWithData:carrierData options:0 error:&error];
            if(carrierInfoList && [[carrierInfoList allKeys]count]) {
                for(id phoneNumber in carrierInfoList) {
                    // KLog(@"Carrier info details =%@", [carrierInfoList objectForKey:phoneNumber]);
                    CarrierInfo *carrierInfoObj = [[CarrierInfo alloc]initWithPhoneNumber:phoneNumber withCarrierDetails:[carrierInfoList objectForKey:phoneNumber]];
                    [carrierList addObject:carrierInfoObj];
                }
            }
        }
        
        //We have settings CarrierList Array, check for the uniq
        if (carrierList && [carrierList count]) {
            for (int i = 0; i<[carrierList count];i++) {
                CarrierInfo *carrierInfoDetails = [carrierList objectAtIndex:i];
                //Remove "+" sign if any.
                NSString *carrierInfoPhoneNumber = [carrierInfoDetails.phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                NSString *carrierDetailsPhoneNumber = [carrierDetails.phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                if ([carrierInfoPhoneNumber isEqualToString:carrierDetailsPhoneNumber])
                    [carrierList replaceObjectAtIndex:i withObject:carrierDetails];
                else {
                    if (![carrierList containsObject:carrierDetails]) {
                        [carrierList addObject:carrierDetails];
                    }
                }
            }
        }
        else {
            [carrierList addObject:carrierDetails];
        }
        
        if(carrierList && [carrierList count])
            self.data.carrierInfoList = carrierList;
        
        //Check we have carrierInfo in the settings model if not create it.
        [request setObject:self.data.carrierInfoList forKey:kCarrierInfo];
        
        NSMutableArray *numberList = [[NSMutableArray alloc]init];
        
        if(self.data.numberDetails) {
            NSData *numberData = [self.data.numberDetails dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *numberInfoList = [NSJSONSerialization JSONObjectWithData:numberData options:0 error:&error];
            if(numberInfoList && [[numberInfoList allKeys]count]) {
                for(id phoneNumber in numberInfoList) {
                    // KLog(@"Carrier info details =%@", [carrierInfoList objectForKey:phoneNumber]);
                    NumberInfo *numberInfoObj = [[NumberInfo alloc]initWithPhoneNumber:phoneNumber withNumberDetails:[numberInfoList objectForKey:phoneNumber]];
                    [numberList addObject:numberInfoObj];
                }
            }
        }
        
        //We have settings CarrierList Array, check for the uniq
        if (numberList && [numberList count]) {
            for (int i = 0; i<[numberList count];i++) {
                NumberInfo *numberInfoDetails = [numberList objectAtIndex:i];
                //Remove "+" sign if any.
                NSString *carrierInfoPhoneNumber = [numberInfoDetails.phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                NSString *carrierDetailsPhoneNumber = [numberDetails.phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                if ([carrierInfoPhoneNumber isEqualToString:carrierDetailsPhoneNumber])
                    [numberList replaceObjectAtIndex:i withObject:numberDetails];
                else {
                    if (![numberList containsObject:numberDetails]) {
                        [numberList addObject:numberDetails];
                    }
                }
            }
        }
        else {
            [numberList addObject:numberDetails];
        }
        
        if(numberList && [numberList count])
            self.data.numberInfoList = numberList;
        
        //Check we have carrierInfo in the settings model if not create it.
        [request setObject:self.data.numberInfoList forKey:kNumberInfo];
        
        [self writeSettingDataInFile];
        EnLogd(@"update Carrier settings to server = %@", request);
        UpdateUserSettingAPI* api = [[UpdateUserSettingAPI alloc]initWithRequest:request];
        [api callNetworkRequest:self.data withSuccess:^(UpdateUserSettingAPI *req, BOOL responseObject) {
            //[self writeSettingDataInFile];
            EnLogd(@"update Carrier settings success =%d", responseObject);
            [userDefaults setObject:@YES forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            
            //Update to the server is successful. So, for the next fetch operation - we need to fetch settings data freshly.
            [userDefaults setObject:@NO forKey:kUserSettingsFetched];
            [userDefaults synchronize];
            
            self.data.shouldUpdateToServer = NO;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:YES];
        } failure:^(UpdateUserSettingAPI *req, NSError *error) {
            EnLogd(@"update Carrier settings failed =%@", error);
            
            NSInteger errorCode = error.code;
            NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
            if([errorMsg length]) {
                [ScreenUtility showAlertMessage: errorMsg];
            }
            
            [userDefaults setObject:@NO forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:NO];
            
        }];
    }
}

- (void)updateCarrierSettingsInfo:(CarrierInfo *)carrierDetails {
    
    NSMutableDictionary* request = [[NSMutableDictionary alloc]init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *carrierList = [[NSMutableArray alloc]init];
    
    if(self.data) {
        if(self.data.carrierDetails) {
            NSData *carrierData = [self.data.carrierDetails dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *carrierInfoList = [NSJSONSerialization JSONObjectWithData:carrierData options:0 error:&error];
            if(carrierInfoList && [[carrierInfoList allKeys]count]) {
                for(id phoneNumber in carrierInfoList) {
                    // KLog(@"Carrier info details =%@", [carrierInfoList objectForKey:phoneNumber]);
                    CarrierInfo *carrierInfoObj = [[CarrierInfo alloc]initWithPhoneNumber:phoneNumber withCarrierDetails:[carrierInfoList objectForKey:phoneNumber]];
                    [carrierList addObject:carrierInfoObj];
                }
            }
        }
        
        //We have settings CarrierList Array, check for the uniq
        if (carrierList && [carrierList count]) {
            for (int i = 0; i<[carrierList count];i++) {
                CarrierInfo *carrierInfoDetails = [carrierList objectAtIndex:i];
                //Remove "+" sign if any.
                NSString *carrierInfoPhoneNumber = [carrierInfoDetails.phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                NSString *carrierDetailsPhoneNumber = [carrierDetails.phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                if ([carrierInfoPhoneNumber isEqualToString:carrierDetailsPhoneNumber])
                    [carrierList replaceObjectAtIndex:i withObject:carrierDetails];
                else {
                    if (![carrierList containsObject:carrierDetails]) {
                        [carrierList addObject:carrierDetails];
                    }
                }
            }
        }
        else {
            [carrierList addObject:carrierDetails];
        }
        
        if(carrierList && [carrierList count])
            self.data.carrierInfoList = carrierList;
        
        //Check we have carrierInfo in the settings model if not create it.
        [request setObject:self.data.carrierInfoList forKey:kCarrierInfo];
        
        [self writeSettingDataInFile];
        KLog(@"update Carrier settings to server = %@", request);
        EnLogd(@"update Carrier settings to server = %@", request);
        UpdateUserSettingAPI* api = [[UpdateUserSettingAPI alloc]initWithRequest:request];
        [api callNetworkRequest:self.data withSuccess:^(UpdateUserSettingAPI *req, BOOL responseObject) {
            //[self writeSettingDataInFile];
            KLog(@"update Carrier settings success =%d", responseObject);
            EnLogd(@"update Carrier settings success =%d", responseObject);
            [userDefaults setObject:@YES forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            
            //Update to the server is successful. So, for the next fetch operation - we need to fetch settings data freshly.
            [userDefaults setObject:@NO forKey:kUserSettingsFetched];
            [userDefaults synchronize];
            
            self.data.shouldUpdateToServer = NO;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:YES];
        } failure:^(UpdateUserSettingAPI *req, NSError *error) {
            EnLogd(@"update Carrier settings failed =%@", error);
            KLog(@"update Carrier settings failed =%@", error);
            NSInteger errorCode = error.code;
            NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
            if([errorMsg length]) {
                [ScreenUtility showAlertMessage: errorMsg];
            }
            
            [userDefaults setObject:@NO forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:NO];
            
        }];
    }
}

- (void)updateNumberSettingsInfo:(NumberInfo *)numberDetails {
    
    NSMutableDictionary* request = [[NSMutableDictionary alloc]init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *numberList = [[NSMutableArray alloc]init];
    
    if(self.data) {
        if(self.data.numberDetails) {
            NSData *numberData = [self.data.numberDetails dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *numberInfoList = [NSJSONSerialization JSONObjectWithData:numberData options:0 error:&error];
            if(numberInfoList && [[numberInfoList allKeys]count]) {
                for(id phoneNumber in numberInfoList) {
                    // KLog(@"Carrier info details =%@", [carrierInfoList objectForKey:phoneNumber]);
                    NumberInfo *numberInfoObj = [[NumberInfo alloc]initWithPhoneNumber:phoneNumber withNumberDetails:[numberInfoList objectForKey:phoneNumber]];
                    [numberList addObject:numberInfoObj];
                }
            }
        }
        
        //We have settings CarrierList Array, check for the uniq
        if (numberList && [numberList count]) {
            for (int i = 0; i<[numberList count];i++) {
                NumberInfo *numberInfoDetails = [numberList objectAtIndex:i];
                //Remove "+" sign if any.
                NSString *carrierInfoPhoneNumber = [numberInfoDetails.phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                NSString *carrierDetailsPhoneNumber = [numberDetails.phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                if ([carrierInfoPhoneNumber isEqualToString:carrierDetailsPhoneNumber])
                    [numberList replaceObjectAtIndex:i withObject:numberDetails];
                else {
                    if (![numberList containsObject:numberDetails]) {
                        [numberList addObject:numberDetails];
                    }
                }
            }
        }
        else {
            [numberList addObject:numberDetails];
        }
        
        if(numberList && [numberList count])
            self.data.numberInfoList = numberList;
        
        //Check we have carrierInfo in the settings model if not create it.
        [request setObject:self.data.numberInfoList forKey:kNumberInfo];
        
        [self writeSettingDataInFile];
        
        UpdateUserSettingAPI* api = [[UpdateUserSettingAPI alloc]initWithRequest:request];
        [api callNetworkRequest:self.data withSuccess:^(UpdateUserSettingAPI *req, BOOL responseObject) {
            //[self writeSettingDataInFile];
            [userDefaults setObject:@YES forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            
            //Update to the server is successful. So, for the next fetch operation - we need to fetch settings data freshly.
            [userDefaults setObject:@NO forKey:kUserSettingsFetched];
            [userDefaults synchronize];
            
            self.data.shouldUpdateToServer = NO;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:YES];
        } failure:^(UpdateUserSettingAPI *req, NSError *error) {
            
            NSInteger errorCode = error.code;
            NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
            if([errorMsg length]) {
                [ScreenUtility showAlertMessage: errorMsg];
            }
            
            [userDefaults setObject:@NO forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:NO];
            
        }];
    }
}

-(void)disconnectFBTwitter:(NSString*) type
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    if([type isEqualToString:@"FB"]) {
        [dic setValue:FB_TYPE forKey:API_APP];
        self.data.fbConnected = NO;
    }
    else {
        [dic setValue:TW_TYPE forKey:API_APP];
        self.data.twConnected = NO;
    }
    DisconnectFBTwitterApi* api = [[DisconnectFBTwitterApi alloc]initWithRequest:dic];
    [api callNetworkRequest:dic withSuccess:^(DisconnectFBTwitterApi *req, BOOL responseObject) {
        [self writeSettingDataInFile];
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
            [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:YES];
    } failure:^(DisconnectFBTwitterApi *req, NSError *error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
            [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:NO];
    }];
}

-(void)saveSupportContacts:(NSArray *)list
{
    if([self.supportContactList count] == 0)
    {
        self.supportContactList = [NSArray arrayWithArray:[self createSupportContactDic:list]];
        NSString* archiveFilePath = [[IVFileLocator getDocumentDirectoryPath]
                                     stringByAppendingPathComponent:@"SupportContact.dat"];
        [NSKeyedArchiver archiveRootObject:self.supportContactList toFile:archiveFilePath];
    }
    
    [[UIDataMgt sharedDataMgtObj]configureHelpAndSuggestion];//FEB 1, 2018
}

-(NSMutableArray*)createSupportContactDic:(NSArray *)supportContacts
{
    NSMutableArray *supportCntList = nil;
    
    if(supportContacts != nil && [supportContacts count]>0)
    {
        supportCntList = [[NSMutableArray alloc] init];
        int index = 0;
        NSDictionary *dic = [supportContacts objectAtIndex:index];
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]init];
        
        NSString *supportName = [dic valueForKey:API_SUPPORT_CATG];
        [tempDic setValue:supportName forKey:SUPPORT_NAME];
        NSString *supportIvId =@"";
        if([[dic valueForKey:API_IV_USER_ID]isKindOfClass:[NSNumber class]])
        {
            supportIvId = [[dic valueForKey:API_IV_USER_ID]stringValue];
        }
        else
        {
            supportIvId = [dic valueForKey:API_IV_USER_ID];
        }
        [tempDic setValue:supportIvId forKey:SUPPORT_IV_ID];
        
#ifdef REACHME_APP
        [[ConfigurationReader sharedConfgReaderObj]setHelpChatIvId:[supportIvId integerValue]];
#endif
        
        NSString *supportPicUri = [dic valueForKey:API_THUMBNAIL_PROFILE_PIC_URI];
        [tempDic setValue:supportPicUri forKey:SUPPORT_PIC_URI];
        
        NSString *email = [dic valueForKey:API_SUPPORT_EMAIL];
        NSString *phone = [dic valueForKey:API_SUPPORT_PHONE];
        
        NSMutableDictionary *supportEmailDic = [[NSMutableDictionary alloc]initWithDictionary:tempDic];
        
        [supportEmailDic setValue:EMAIL_MODE forKey:SUPPORT_DATA_TYPE];
        [supportEmailDic setValue:email forKey:SUPPORT_DATA_VALUE];
        
        NSMutableDictionary *supportPhoneDic = [[NSMutableDictionary alloc] initWithDictionary:tempDic];
        
        [supportPhoneDic setValue:PHONE_MODE forKey:SUPPORT_DATA_TYPE];
        [supportPhoneDic setValue:phone forKey:SUPPORT_DATA_VALUE];
        
        //[supportCntList addObject:supportEmailDic];
        [supportCntList addObject:supportPhoneDic];
        
        index = index + 1;
        
        dic = [supportContacts objectAtIndex:index];
        tempDic = [[NSMutableDictionary alloc]init];
        
        supportName = [dic valueForKey:API_FEDDBACK_CATG];
        [tempDic setValue:supportName forKey:SUPPORT_NAME];
        
        if([[dic valueForKey:API_IV_USER_ID]isKindOfClass:[NSNumber class]])
        {
            supportIvId = [[dic valueForKey:API_IV_USER_ID]stringValue];
        }
        else
        {
            supportIvId = [dic valueForKey:API_IV_USER_ID];
        }
        
#ifdef REACHME_APP
        [[ConfigurationReader sharedConfgReaderObj]setSuggestionChatIvId:[supportIvId integerValue]];
#endif
        [tempDic setValue:supportIvId forKey:SUPPORT_IV_ID];
        
        supportPicUri = [dic valueForKey:API_THUMBNAIL_PROFILE_PIC_URI];
        [tempDic setValue:supportPicUri forKey:SUPPORT_PIC_URI];
        
        email = [dic valueForKey:API_SUPPORT_EMAIL];
        phone = [dic valueForKey:API_SUPPORT_PHONE];
        
        NSMutableDictionary *feedbackEmailDic = [[NSMutableDictionary alloc]initWithDictionary:tempDic];
        
        [feedbackEmailDic setValue:EMAIL_MODE forKey:SUPPORT_DATA_TYPE];
        [feedbackEmailDic setValue:email forKey:SUPPORT_DATA_VALUE];
        
        NSMutableDictionary *feedbackPhoneDic = [[NSMutableDictionary alloc] initWithDictionary:tempDic];
        
        [feedbackPhoneDic setValue:PHONE_MODE forKey:SUPPORT_DATA_TYPE];
        [feedbackPhoneDic setValue:phone forKey:SUPPORT_DATA_VALUE];
        
        //[supportCntList addObject:feedbackEmailDic];
        [supportCntList addObject:feedbackPhoneDic];
    }
    
    return supportCntList;
}

-(NSMutableArray*)getCountryList
{
    if(_countryList == Nil)
    {
        _countryList = [self getCountryListFromFile];
        NSString* archiveFilePathCountry = [[IVFileLocator getDocumentDirectoryPath]
                                            stringByAppendingPathComponent:@"Country.dat"];
        [NSKeyedArchiver archiveRootObject:_countryList toFile:archiveFilePathCountry];
    }
    return _countryList;
}

-(void)setCountryInfo
{
    NSMutableDictionary *dic = [Common getSIMInfo];
    
    if(dic != nil && [dic count] >0)
    {
        NSString *mcc = [dic valueForKey:COUNTRY_SIM_MCC];
        NSString *mnc = [dic valueForKey:COUNTRY_SIM_MNC];
        if((mcc != nil && [mcc length] >0) && (mnc != nil && [mnc length]>0))
        {
            NSString *mccmnc = [[NSString alloc] initWithFormat:@"%@%@",mcc,mnc];
            [[ConfigurationReader sharedConfgReaderObj] setCountryMCCMNC:mccmnc];
        }
        else
        {
            [[ConfigurationReader sharedConfgReaderObj] setCountryMCCMNC:nil];
        }
        NSString *iso = [dic valueForKey:COUNTRY_SIM_ISO];
        if(iso != nil && [iso length] >0)
        {
            //below line commented unused variable
            //NSString *where = [[NSString alloc] initWithFormat:@"WHERE %@=\"%@\"",COUNTRY_SIM_ISO,[iso uppercaseString]];
            NSMutableArray *countries = [NSMutableArray arrayWithArray:_countryList];
            if(countries != nil && [countries count] >0)
            {
                for (int i= 0; i< [countries count]; i++)
                {
                    NSMutableDictionary *dic = [countries objectAtIndex:i];
                    NSString *countruIso = [dic valueForKey:COUNTRY_SIM_ISO];
                    if([[iso uppercaseString] isEqualToString:countruIso])
                    {
                        NSString *phoneMaxLen = [dic valueForKey:COUNTRY_MAX_PHONE_LENGTH];
                        NSString *phoneMinLen = [dic valueForKey:COUNTRY_MIN_PHONE_LENGTH];
                        NSString *isdCode  = [dic valueForKey:COUNTRY_ISD_CODE];
                        NSString *countryCode = [dic valueForKey:COUNTRY_CODE];
                        NSString *countryName = [dic valueForKey:COUNTRY_NAME];
                        
                        if([[ConfigurationReader sharedConfgReaderObj] getCountryISD] == nil)
                        {
                            [[ConfigurationReader sharedConfgReaderObj] setCountryCode:countryCode];
                            [[ConfigurationReader sharedConfgReaderObj] setMaxPhoneLen:[phoneMaxLen intValue]];
                            [[ConfigurationReader sharedConfgReaderObj] setMinPhoneLen:[phoneMinLen intValue]];
                            [[ConfigurationReader sharedConfgReaderObj] setCountryISD:isdCode];
                            [[ConfigurationReader sharedConfgReaderObj] setCountryName:countryName];
                        }
                        [[ConfigurationReader sharedConfgReaderObj] setSIMIsdCode:isdCode];
                        return;
                    }
                }
            }
        }
    }
    
}

-(NSMutableArray*)getCountryListFromFile
{
    NSMutableArray *countries = [[NSMutableArray alloc] init];
    NSString * cvsFileOPath = [[NSBundle mainBundle] pathForResource:@"Countries" ofType:@"csv"];
    NSString * cvsFileContent = [NSString stringWithContentsOfFile:cvsFileOPath encoding:NSASCIIStringEncoding error:NULL];
    
    NSArray * rowsOfCSVFile= [cvsFileContent componentsSeparatedByString:@"\n"];
    NSArray * columnsOfRow = nil;
    if(rowsOfCSVFile != nil && [rowsOfCSVFile count] > 0)
    {
        
        for(NSString * pstrRow in rowsOfCSVFile)
        {
            columnsOfRow= [pstrRow componentsSeparatedByString:@","];
            if(columnsOfRow != nil && [columnsOfRow count] >0)
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                for (int i = 0; i < [columnsOfRow count]; i++)
                {
                    switch (i)
                    {
                        case 0:
                        {
                            NSString *countryName = [columnsOfRow objectAtIndex:0];
                            [dic setValue:countryName forKey:COUNTRY_NAME];
                        }
                            break;
                            
                        case 1:
                        {
                            NSString *countryCode = [columnsOfRow objectAtIndex:1];
                            [dic setValue:countryCode forKey:COUNTRY_CODE];
                        }
                            
                            break;
                            
                        case 2:
                        {
                            NSString *isoCode = [columnsOfRow objectAtIndex:2];
                            [dic setValue:isoCode forKey:COUNTRY_SIM_ISO];
                        }
                            
                            break;
                        case 3:
                        {
                            NSString *isdCode = [columnsOfRow objectAtIndex:3];
                            [dic setValue:isdCode forKey:COUNTRY_ISD_CODE];
                        }
                            
                            break;
                        case 4:
                        {
                            NSString *minPhoneLen = [columnsOfRow objectAtIndex:4];
                            [dic setValue:minPhoneLen forKey:COUNTRY_MIN_PHONE_LENGTH];
                        }
                            
                            break;
                        case 5:
                        {
                            NSString *maxPhoneLen = [columnsOfRow objectAtIndex:5];
                            [dic setValue:maxPhoneLen forKey:COUNTRY_MAX_PHONE_LENGTH];
                        }
                            
                            break;
                        default:
                            break;
                    }
                    
                }
                [countries addObject:dic];
            }
        }
    }
    
    return countries;
}

-(NSString*)getCountryNameFromCountryCode:(NSString*)countryCode
{
    NSMutableArray *countries = [NSMutableArray arrayWithArray:_countryList];
    NSString* countryName = @"";
    if(countries != nil && [countries count] >0)
    {
        for(NSMutableDictionary* dic in countries)
        {
            NSString *code = [dic valueForKey:COUNTRY_CODE];
            if([code isEqualToString:countryCode])
            {
                countryName = [dic valueForKey:COUNTRY_NAME];
                return countryName;
            }
        }
    }
    return countryName;
}

-(NSString*)getCountryCodeFromCountryIsd:(NSString *)countryIsd{
    NSMutableArray *countries = [NSMutableArray arrayWithArray:_countryList];
    NSString *countryCode = @"";
    if(countries != nil && [countries count] >0)
    {
        for(NSMutableDictionary* dic in countries)
        {
            NSString *code = [dic valueForKey:COUNTRY_NAME];
            if([code isEqualToString:countryIsd])
            {
                countryCode = [dic valueForKey:COUNTRY_CODE];
                return countryCode;
            }
        }
    }
    return countryCode;
}

-(NSString*)getCountrySimIsoFromCountryIsd:(NSString *)countryIsd{
    NSMutableArray *countries = [NSMutableArray arrayWithArray:_countryList];
    NSString *countrySimIso = @"";
    if(countries != nil && [countries count] >0)
    {
        for(NSMutableDictionary* dic in countries)
        {
            NSString *code = [dic valueForKey:COUNTRY_ISD_CODE];
            if([code isEqualToString:countryIsd])
            {
                countrySimIso = [dic valueForKey:COUNTRY_SIM_ISO];
                return countrySimIso;
            }
        }
    }
    return countrySimIso;
}

- (void)setDeviceInfoWithVoipToken:(NSString*)token
{
    KLog(@"setDeviceInfoWithVoipToken:%@",token);
    
    NSMutableDictionary *setDevInfoDic = [[NSMutableDictionary alloc] init];
    __block NSString* voipPushToken = nil;
    
    if(!token) {
        voipPushToken = [[ConfigurationReader sharedConfgReaderObj]getVoipPushToken];
    } else {
        voipPushToken = token;
    }
    
    __block NSString* cloudKey = [[ConfigurationReader sharedConfgReaderObj]getCloudSecureKey];
    
    if(voipPushToken.length)
    {
        
        if(cloudKey.length)
            [setDevInfoDic setValue:cloudKey forKey:API_CLOUD_SECURE_KEY];
        
        [setDevInfoDic setValue:voipPushToken forKey:API_VOIP_PUSH_TOKEN];
        SetDeviceInfoAPI* api = [[SetDeviceInfoAPI alloc]initWithRequest:setDevInfoDic];
        KLog(@"***SetDeviceInfoWithVoipTokeneviceInfoAPI req dic = %@",setDevInfoDic);
        [api callNetworkRequest:setDevInfoDic withSuccess:^(SetDeviceInfoAPI *req, NSMutableDictionary *responseObject) {
            KLog(@"***setDeviceInfoWithVoipToken succeeded. resp = %@", responseObject);
            [[ConfigurationReader sharedConfgReaderObj] setVoipPushToken:voipPushToken];
            EnLogd(@"***setDeviceInfoWithVoipToken succeeded. Save the token.");
            
        } failure:^(SetDeviceInfoAPI *req, NSError *error) {
            KLog(@"setDeviceInfoWithVoipToken Failed.Err=%@", error);
            EnLogd(@"setDeviceInfoWithVoipToken Failed. Clear the token. Err=%@", error);
            //Clear the token
            [[ConfigurationReader sharedConfgReaderObj]setVoipPushToken:@""];
        }];
    } else {
        EnLogd(@"voipPushToken is nil. Check the code.");
        //AppDelegate *appDelegate = (AppDelegate *)APP_DELEGATE;
        //[appDelegate registerForPushNotification];
    }
}

- (void)setDeviceInfo:(NSString*)token
{
    KLog(@"setDeviceInfo:%@",token);
    
    NSMutableDictionary *setDevInfoDic = [[NSMutableDictionary alloc] init];
    __block NSString* cloudKey = nil;
    
    if(!token) {
        cloudKey = [[ConfigurationReader sharedConfgReaderObj]getCloudSecureKey];
    } else {
        cloudKey = token;
    }
    
#ifdef REACHME_APP
    __block NSString* voipPushToken = [[ConfigurationReader sharedConfgReaderObj]getVoipPushToken];
#endif
    
    if(cloudKey.length)
    {
        [setDevInfoDic setValue:cloudKey forKey:API_CLOUD_SECURE_KEY];
        
#ifdef REACHME_APP
        if(voipPushToken.length)
            [setDevInfoDic setValue:voipPushToken forKey:API_VOIP_PUSH_TOKEN];
#endif
        
        SetDeviceInfoAPI* api = [[SetDeviceInfoAPI alloc]initWithRequest:setDevInfoDic];
        KLog(@"***SetDeviceInfoAPI req dic = %@",setDevInfoDic);
        [api callNetworkRequest:setDevInfoDic withSuccess:^(SetDeviceInfoAPI *req, NSMutableDictionary *responseObject) {
            KLog(@"***SetDeviceInfo succeeded. resp = %@", responseObject);
            [[ConfigurationReader sharedConfgReaderObj] setCloudSecureKey:cloudKey];
            EnLogd(@"***SetDeviceInfo succeeded. Save the token.");
        } failure:^(SetDeviceInfoAPI *req, NSError *error) {
            KLog(@"SetDeviceInfo Failed.Err=%@", error);
            EnLogd(@"SetDeviceInfo Failed. Clear the token. Err=%@", error);
            //Clear the token
            [[ConfigurationReader sharedConfgReaderObj]setCloudSecureKey:@""];
        }];
    } else {
        EnLogd(@"cloudKey is nil.");
        [self performSelectorOnMainThread:@selector(registerForPushNotification) withObject:nil waitUntilDone:NO];
    }
}

-(void)registerForPushNotification {
    AppDelegate *appDelegate = (AppDelegate *)APP_DELEGATE;
    [appDelegate registerForPushNotification];
#ifdef REACHME_APP
    [appDelegate registerForVOIPPush];
#endif
}

- (void)resetSettingData {
    self.data = [[SettingModel alloc]init];
    
    [self writeSettingDataInFile];
    
    //TODO: Need to verify this logic.
    [self resetFetchAndUpdateStatus];
    
}

/**
 * Method responsible for update the user custom settings
 * @param withLoginUserType Instance indicates the type of user.
 */
- (void)updateUserSettingsWithDefaultValueOfCustomSettingsForUserType:(enum LoggedInUserType)withLoginUserType {
    
    if(withLoginUserType == eFreshSignInUser) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSMutableDictionary* request = [[NSMutableDictionary alloc]init];
        //This case is the fresh sign in case, so set the default values for the custom settings and vb_enable = true.
        //Get all the default values for custom settings and set the value.
        BOOL bVal = YES;
#ifdef REACHME_APP
        bVal = NO;
#endif
        [request setValue:[NSNumber numberWithInteger:bVal] forKey:VB_ENABLE];
        self.data.vbEnabled = bVal;
        
        //Set the default value display location.
        //TODO: Need to write the logic of - location enable status update when user provides the permission.
        [request setValue:[NSNumber numberWithInteger:YES] forKey:DISPLAY_LOCATION];
        self.data.displayLocation = YES;
        
        //Set the default value for record mode
        [request setValue:kDefaultRecordModeDefaultValue forKey:kDefaultRecordMode];
        self.data.defaultRecordMode = kDefaultRecordModeDefaultValue;
        
        //Set the default value default voice mode
        [request setValue:kDefaultVoiceModeDefaultValue forKey:kDefaultVoiceMode];
        self.data.defaultVoiceMode = kDefaultVoiceModeDefaultValue;
        
        //Set the default value show fb friend
        [request setValue:kShowFBFriendDefaultValue forKey:kShowFBFriend];
        self.data.showFBFriend = kShowFBFriendDefaultValue;
        
        //Set the default value show twitter friend
        [request setValue:kShowTWFriendDefaultValue forKey:kShowTwitterFriend];
        self.data.showTwitterFriend = kShowTWFriendDefaultValue;
        
        NSMutableArray *carrierList = [[NSMutableArray alloc]init];
        if(self.data.carrierDetails) {
            NSData *carrierData = [self.data.carrierDetails dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *carrierInfoList = [NSJSONSerialization JSONObjectWithData:carrierData options:0 error:&error];
            if(carrierInfoList && [[carrierInfoList allKeys]count]) {
                for(id phoneNumber in carrierInfoList) {
                    // KLog(@"Carrier info details =%@", [carrierInfoList objectForKey:phoneNumber]);
                    CarrierInfo *carrierInfoObj = [[CarrierInfo alloc]initWithPhoneNumber:phoneNumber withCarrierDetails:[carrierInfoList objectForKey:phoneNumber]];
                    [carrierList addObject:carrierInfoObj];
                }
            }
        }
        
        if(carrierList && [carrierList count])
        self.data.carrierInfoList = carrierList;
        
        //Check we have carrierInfo in the settings model if not create it.
        [request setObject:self.data.carrierInfoList forKey:kCarrierInfo];
        
        NSMutableArray *numberList = [[NSMutableArray alloc]init];
        if(self.data.numberDetails) {
            NSData *numberData = [self.data.numberDetails dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *numberInfoList = [NSJSONSerialization JSONObjectWithData:numberData options:0 error:&error];
            if(numberInfoList && [[numberInfoList allKeys]count]) {
                for(id phoneNumber in numberInfoList) {
                    // KLog(@"Carrier info details =%@", [carrierInfoList objectForKey:phoneNumber]);
                    NumberInfo *numberInfoObj = [[NumberInfo alloc]initWithPhoneNumber:phoneNumber withNumberDetails:[numberInfoList objectForKey:phoneNumber]];
                    [numberList addObject:numberInfoObj];
                }
            }
        }
        
        if(numberList && [numberList count])
        self.data.numberInfoList = numberList;
        
        //Check we have numberInfo in the settings model if not create it.
        [request setObject:self.data.numberInfoList forKey:kNumberInfo];
        
        [self writeSettingDataInFile];
        UpdateUserSettingAPI* api = [[UpdateUserSettingAPI alloc]initWithRequest:request];
        [api callNetworkRequest:self.data withSuccess:^(UpdateUserSettingAPI *req, BOOL responseObject) {
            //[self writeSettingDataInFile];
            //Save the status to user defaults.
            [userDefaults setObject:@YES forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            
            //Update to the server is successful. So, for the next fetch operation - we need to fetch settings data freshly.
            [userDefaults setObject:@NO forKey:kUserSettingsFetched];
            [userDefaults synchronize];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:YES];
            
        } failure:^(UpdateUserSettingAPI *req, NSError *error) {
            //Save the status to user defaults.
            [userDefaults setObject:@NO forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:NO];
        }];
    }
}
/**
 */
- (void)clearUpdateSettingsStatus {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //TODO: Need to check this logic.
    if(![userDefaults boolForKey:kUserSettingsUpdated]) {
        [userDefaults setBool:YES forKey:kUserSettingsUpdated];
        [userDefaults synchronize];
    }
}

/**
 * Method responsible to reset the fetch and update status for the login
 */
- (void)resetFetchAndUpdateStatus {
    //For account login we need to fetch the settings freshly, so its necessary to reset the fetch status.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@NO forKey:kUserSettingsFetched];
    [userDefaults synchronize];
}

- (void)fetchCarrierList {
    
    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        return;
    }
    
    //Fetch the primary number carrier list.
    //Get the profile data - additional verified numbers.
    UserProfileModel *profileData = [Profile sharedUserProfile].profileData;
    //Its array of dictionaries - dictionary contains country code information which we use to fetch the list_carrier information.
    NSOrderedSet *orderedCountryList = [NSOrderedSet orderedSetWithArray:[profileData.additionalVerifiedNumbers valueForKeyPath:@"country_code"]];
    
    NSArray *countryList = [orderedCountryList array];
    
    if ([Setting sharedSetting].data.listOfCarriers.count) {
        for (NSInteger i=0; i<[countryList count]; i++) {
            
            NSString *country = [countryList objectAtIndex:i];
            NSArray *allCountryList = [[Setting sharedSetting].data.listOfCarriers valueForKeyPath:@"@distinctUnionOfArrays.@allKeys"];
            
            if (![allCountryList containsObject:country]) {
                [self fetchListOfCarriersForCountry:country];
            }
        }
    }
    else {
        for (NSInteger i=0; i<[countryList count]; i++) {
            NSString *country = [countryList objectAtIndex:i];
            [self fetchListOfCarriersForCountry:country];
        }
    }
}

- (void)fetchListOfCarriersForCountry:(NSString *)countryCode {
    
    if (countryCode == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(fetchListOfCarriersForCountry:withFetchStatus:)])
            [self.delegate fetchListOfCarriersForCountry:self.data withFetchStatus:NO];//NOV 24, 2016
        return;
    }
    
    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(fetchListOfCarriersForCountry:withFetchStatus:)])
            [self.delegate fetchListOfCarriersForCountry:self.data withFetchStatus:NO];//NOV 24, 2016
        else
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    
        return;
    }
    
    KLog(@"Fetching carrier list for country = %@", countryCode);
    NSMutableDictionary *requestData = [[NSMutableDictionary alloc]init];
    [requestData setObject:countryCode forKey:@"country_code"];
    [requestData setValue:[NSNumber numberWithBool:1] forKey:@"fetch_voicemails_info"];//NOV 16, 2016
    
    FetchCarriersListAPI* fetchCarrierListRequest = [[FetchCarriersListAPI alloc]initWithRequest:requestData];
    
    [fetchCarrierListRequest callNetworkRequest:requestData withSuccess:^(FetchCarriersListAPI *req, NSMutableDictionary *responseObject) {
        
        NSArray *currentCarrierList = responseObject[@"country_list"];
        if (currentCarrierList && [currentCarrierList count]) {
            //Sort array based on the alphabetical order.
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"networkName"
                                                                             ascending:YES
                                                                              selector:@selector(caseInsensitiveCompare:)];
            [currentCarrierList sortedArrayUsingDescriptors:@[sortDescriptor]];
        }
        
        NSDictionary *carrierListDictionary = @{countryCode:currentCarrierList};
        
        if (!([Setting sharedSetting].data.listOfCarriers.count)) {
            [Setting sharedSetting].data.listOfCarriers = [[NSMutableArray alloc]init];
        }
        
        NSArray *allCountryList = [[Setting sharedSetting].data.listOfCarriers valueForKeyPath:@"@distinctUnionOfArrays.@allKeys"];
        
        if (![allCountryList containsObject:countryCode]) {
            [[Setting sharedSetting].data.listOfCarriers addObject:carrierListDictionary];
        }
        //CMP NOV 21, 2016
        else {
            int i=0;
            NSDictionary* obj=nil;
            for(i=0; i<[[Setting sharedSetting].data.listOfCarriers count];i++) {
                obj = [[Setting sharedSetting].data.listOfCarriers objectAtIndex:i];
                NSArray* list = [obj objectForKey:countryCode];
                if([list count]) break;
            }
    
            if([obj count]) {
                if(i < [[Setting sharedSetting].data.listOfCarriers count]) {
                    [[Setting sharedSetting].data.listOfCarriers removeObjectAtIndex:i];
                    [[Setting sharedSetting].data.listOfCarriers addObject:carrierListDictionary];
                    [[Setting sharedSetting]writeSettingDataInFile];//TODO check for the race condition
                }
            }
        }
        //
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(fetchListOfCarriersForCountry:withFetchStatus:)])
            [self.delegate fetchListOfCarriersForCountry:self.data withFetchStatus:YES];
        
        
    } failure:^(FetchCarriersListAPI *req, NSError *error) {
        KLog(@"Failure in fetching carrier list");
        
        NSInteger errorCode = 0;
        NSString *errorReason;
        if (error.userInfo) {
            errorCode = [error.userInfo[@"error_code"]integerValue];
            errorReason = error.userInfo[@"error_reason"];
            EnLogd(@"error = %ld, reason = %@",errorCode, errorReason);
        }
        //TODO log the error
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(fetchListOfCarriersForCountry:withFetchStatus:)])
            [self.delegate fetchListOfCarriersForCountry:self.data withFetchStatus:NO];
    }];
    
}

- (void)updateCarrierSettingsInfoForDeletedSecondaryNumber:(NSString *)deletedSecondaryNumber {
    
    NSMutableArray *carrierListInfo = [[Setting sharedSetting].data.carrierInfoList mutableCopy];
    
    CarrierInfo *removedCarrierInfo;
    if (carrierListInfo && [carrierListInfo count]) {
        
        for (int i=0; i< [carrierListInfo count]; i++) {
            CarrierInfo *carrierInfo = [carrierListInfo objectAtIndex:i];
            if ([carrierInfo.phoneNumber isEqualToString:deletedSecondaryNumber]) {
                removedCarrierInfo = carrierInfo;
                break;
            }
        }
    }
    
    if (removedCarrierInfo) {
        
        NSMutableDictionary *request = [[NSMutableDictionary alloc]init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [carrierListInfo removeObject:removedCarrierInfo];
        [Setting sharedSetting].data.carrierInfoList = carrierListInfo;
        //Update Settings Information.
        //Check we have carrierInfo in the settings model if not create it.
        [request setObject:self.data.carrierInfoList forKey:kCarrierInfo];
        
        [self writeSettingDataInFile];
        
        UpdateUserSettingAPI* api = [[UpdateUserSettingAPI alloc]initWithRequest:request];
        [api callNetworkRequest:self.data withSuccess:^(UpdateUserSettingAPI *req, BOOL responseObject) {
            //[self writeSettingDataInFile];
            [userDefaults setObject:@YES forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            
            //Update to the server is successful. So, for the next fetch operation - we need to fetch settings data freshly.
            [userDefaults setObject:@NO forKey:kUserSettingsFetched];
            [userDefaults synchronize];
            
            self.data.shouldUpdateToServer = NO;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:YES];
        } failure:^(UpdateUserSettingAPI *req, NSError *error) {
            
            [userDefaults setObject:@NO forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:NO];
            
        }];
        
    }
}

- (void)updateNumberSettingsInfoForDeletedSecondaryNumber:(NSString *)deletedSecondaryNumber {
    
    NSMutableArray *numberListInfo = [[Setting sharedSetting].data.numberInfoList mutableCopy];
    
    NumberInfo *removedNumberInfo;
    if (numberListInfo && [numberListInfo count]) {
        
        for (int i=0; i< [numberListInfo count]; i++) {
            NumberInfo *numberInfo = [numberListInfo objectAtIndex:i];
            if ([numberInfo.phoneNumber isEqualToString:deletedSecondaryNumber]) {
                removedNumberInfo = numberInfo;
                break;
            }
        }
    }
    
    if (removedNumberInfo) {
        
        NSMutableDictionary *request = [[NSMutableDictionary alloc]init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [numberListInfo removeObject:removedNumberInfo];
        [Setting sharedSetting].data.numberInfoList = numberListInfo;
        //Update Settings Information.
        //Check we have carrierInfo in the settings model if not create it.
        [request setObject:self.data.numberInfoList forKey:kNumberInfo];
        
        [self writeSettingDataInFile];
        
        UpdateUserSettingAPI* api = [[UpdateUserSettingAPI alloc]initWithRequest:request];
        [api callNetworkRequest:self.data withSuccess:^(UpdateUserSettingAPI *req, BOOL responseObject) {
            //[self writeSettingDataInFile];
            [userDefaults setObject:@YES forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            
            //Update to the server is successful. So, for the next fetch operation - we need to fetch settings data freshly.
            [userDefaults setObject:@NO forKey:kUserSettingsFetched];
            [userDefaults synchronize];
            
            self.data.shouldUpdateToServer = NO;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:YES];
        } failure:^(UpdateUserSettingAPI *req, NSError *error) {
            
            [userDefaults setObject:@NO forKey:kUserSettingsUpdated];
            [userDefaults synchronize];
            if (self.delegate && [self.delegate respondsToSelector:@selector(updateSettingCompletedWith:withUpdateStatus:)])
                [self.delegate updateSettingCompletedWith:self.data withUpdateStatus:NO];
            
        }];
        
    }
}

- (NSArray *)carrierListForCountry:(NSString *)withCountryCode {
    
    NSArray *carrierList;
    
    if (withCountryCode) {
        //Get the current country carrier list.
        if ([[Setting sharedSetting].data.listOfCarriers count]) {
            
            NSDictionary *carrierDetails;
            BOOL statusOfExistanceOfCarrierList = NO;
            for (carrierDetails in [Setting sharedSetting].data.listOfCarriers) {
                
                NSString *countryCode = [[carrierDetails allKeys]objectAtIndex:0];
                if([countryCode isKindOfClass:[NSNumber class]]) {
                    countryCode = [NSString stringWithFormat:@"%@",countryCode];
                }
                
                @try {
                    if ([countryCode isEqualToString:withCountryCode]) {
                        statusOfExistanceOfCarrierList = YES;
                        break;
                    }
                    else {
                        statusOfExistanceOfCarrierList = NO;
                    }
                }
                @catch (NSException *exception) {
                    EnLogd(@"FIXME");
                    if([withCountryCode isKindOfClass:[NSNumber class]]) {
                        EnLogd(@"Why withCountryCode is of NSNumber type?");
                    }
                }
            }
            
            if (statusOfExistanceOfCarrierList) {
                carrierList = [carrierDetails objectForKey:withCountryCode];
            }
        }
        else {
            carrierList = nil;
        }
    }
    return carrierList;
}

- (CarrierInfo *)customCarrierInfoForPhoneNumber:(NSString *)phoneNumber {
    
    CarrierInfo *customCarrierInfo;
    if (phoneNumber) {
        
        if ([Setting sharedSetting].data.carrierInfoList && [[Setting sharedSetting].data.carrierInfoList count]) {
            
            for (int i=0; i<[Setting sharedSetting].data.carrierInfoList.count; i++) {
                
                CarrierInfo *carrierInfo = [[Setting sharedSetting].data.carrierInfoList objectAtIndex:i];
                if ([carrierInfo.phoneNumber isEqualToString:phoneNumber]) {
                    customCarrierInfo = carrierInfo;
                    break;
                }
            }
        }
    }
    return customCarrierInfo;
}


- (NumberInfo *)customNumberInfoForPhoneNumber:(NSString *)phoneNumber {
    
    NumberInfo *customNumberInfo;
    if (phoneNumber) {
        
        if ([Setting sharedSetting].data.numberInfoList && [[Setting sharedSetting].data.numberInfoList count]) {
            
            for (int i=0; i<[Setting sharedSetting].data.numberInfoList.count; i++) {
                
                NumberInfo *numberInfo = [[Setting sharedSetting].data.numberInfoList objectAtIndex:i];
                if ([numberInfo.phoneNumber isEqualToString:phoneNumber]) {
                    customNumberInfo = numberInfo;
                    break;
                }
            }
        }
    }
    return customNumberInfo;
}

- (void)checkAndDownloadLatestCarrierLogo:(NSMutableDictionary *)serverResponse
{
    SettingModel *currentSettingModel = [Setting sharedSetting].data;
    
    NSArray *currentSettingsVoiceMailInfoList = currentSettingModel.voiceMailInfo;
    
    NSArray *serverSettingsVoiceMailInfoList = serverResponse[@"voicemails_info"];
    
    id voiceMailInformation = serverResponse[VOICEMAIL_INFO];
    
    if(voiceMailInformation) {
        
        NSMutableArray *voiceMailInfoList = [[NSMutableArray alloc]init];
        if([voiceMailInformation isKindOfClass:[NSArray class]]) {
            
            NSArray *voiceMailInfoArray = voiceMailInformation;
            for (NSUInteger i=0; i<[voiceMailInfoArray count]; i++) {
                
                VoiceMailInfo *voiceMailInfo = [[VoiceMailInfo alloc]initWithVoiceMailInfo:[voiceMailInfoArray objectAtIndex:i]];
                [voiceMailInfoList addObject:voiceMailInfo];
                
            }
            serverSettingsVoiceMailInfoList = voiceMailInfoList;
        }
        
    }
    else
        serverSettingsVoiceMailInfoList = nil;
    
    
    
    
    //Only download the carrier logo for primary number.
    
    NSString *primaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
    
    VoiceMailInfo *currentPrimaryNumberVoiceMailInfo;
    
    VoiceMailInfo *serverPrimaryNumberVoiceMailInfo;
    
    for (VoiceMailInfo *mailInfo in currentSettingsVoiceMailInfoList) {
        if ([mailInfo.phoneNumber isEqualToString: primaryNumber]) {
            currentPrimaryNumberVoiceMailInfo = mailInfo;
            break;
        }
    }
    
    for (VoiceMailInfo *mailInfo in serverSettingsVoiceMailInfoList) {
        if ([mailInfo.phoneNumber isEqualToString:primaryNumber]) {
            serverPrimaryNumberVoiceMailInfo = mailInfo;
            break;
        }
    }
    
    if (!([currentPrimaryNumberVoiceMailInfo.carrierLogoPath isEqualToString:serverPrimaryNumberVoiceMailInfo.carrierLogoPath])) {
        [self downloadAndSaveCarrierLogoImage:serverPrimaryNumberVoiceMailInfo.carrierLogoPath];
    }
    
}

- (VoiceMailInfo *)voiceMailInfoForPhoneNumber:(NSString *)withPhoneNumber {
    
    SettingModel *currentSettingModel = [Setting sharedSetting].data;
    
    NSArray *currentSettingsVoiceMailInfoList = currentSettingModel.voiceMailInfo;
    
    VoiceMailInfo *currentVoiceMailInfo;
    
    for (VoiceMailInfo *mailInfo in currentSettingsVoiceMailInfoList) {
        if ([mailInfo.phoneNumber isEqualToString: withPhoneNumber]) {
            currentVoiceMailInfo = mailInfo;
            break;
        }
    }
    return currentVoiceMailInfo;
}

- (void)downloadAndSaveCarrierLogoImage:(NSString*)carrierLogoImagePath
{
    if (carrierLogoImagePath && ![carrierLogoImagePath isEqualToString:@""]) {
        DownloadProfilePic* api = [[DownloadProfilePic alloc]initWithRequest:Nil];
        [api callNetworkRequest:carrierLogoImagePath withSuccess:^(DownloadProfilePic *req, NSData *responseObject) {
            NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            NSString* localFileName = [NSString stringWithFormat:@"CarrierLogo_%@.png",loginId];
            [IVFileLocator deleteFileAtPath:[IVFileLocator getCarrierLogoPath:localFileName]];
            BOOL isWritten = [responseObject writeToFile:[IVFileLocator getCarrierLogoPath:localFileName] atomically:YES];
            if(isWritten)
            {
                if (self.delegate && [self.delegate respondsToSelector:@selector(fetchCarrierLogoPathCompletedWithStatus:)])
                    [self.delegate fetchCarrierLogoPathCompletedWithStatus:YES];
            }
            
        } failure:^(DownloadProfilePic *req, NSError *error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(fetchCarrierLogoPathCompletedWithStatus:)])
                [self.delegate fetchCarrierLogoPathCompletedWithStatus:NO];
            
        }];
    }
    else {
        //We do not have carrierLogoImagePath - delete If its already existed.
        
        NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
        NSString* localFileName = [NSString stringWithFormat:@"CarrierLogo_%@.png",loginId];
        [IVFileLocator deleteFileAtPath:[IVFileLocator getCarrierLogoPath:localFileName]];
        if (self.delegate && [self.delegate respondsToSelector:@selector(fetchCarrierLogoPathCompletedWithStatus:)])
            [self.delegate fetchCarrierLogoPathCompletedWithStatus:YES];
    }
    
}

//DEC 3, 2016
- (void)downloadAndSaveSupportedCarrierLogoImage:(NSString*)carrierLogoImagePath
{
    KLog(@"downloadAndSaveSupportedCarrierLogoImage");
    if (carrierLogoImagePath && ![carrierLogoImagePath isEqualToString:@""]) {
        DownloadProfilePic* api = [[DownloadProfilePic alloc]initWithRequest:Nil];
        [api callNetworkRequest:carrierLogoImagePath withSuccess:^(DownloadProfilePic *req, NSData *responseObject) {
            NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            NSString* localFileName = [NSString stringWithFormat:@"CarrierLogoSupport_%@.png",loginId];
            [IVFileLocator deleteFileAtPath:[IVFileLocator getCarrierLogoPath:localFileName]];
            BOOL isWritten = [responseObject writeToFile:[IVFileLocator getCarrierLogoPath:localFileName] atomically:YES];
            if(isWritten)
            {
                if(self.delegate && [self.delegate respondsToSelector:@selector(fetchSupportedCarrierLogoCompletedWithStatus:)]) {
                    [self.delegate fetchSupportedCarrierLogoCompletedWithStatus:YES];
                 } else {
                     EnLogd(@"*** ERR: downloadAndSaveSupportedCarrierLogoImage: not found. CHECK");
                     KLog(@"*** ERR: downloadAndSaveSupportedCarrierLogoImage: not found. CHECK");
                 }
                
                //TODO
            }
            
        } failure:^(DownloadProfilePic *req, NSError *error) {
            //TODO
        }];
    }
    else {
        //We do not have carrierLogoImagePath - delete If its already existed.
    }
}
//

//TODO: do we need this mehod? FIXME
- (BOOL)shouldShowEnableVoiceMailInHomeTab {
    //Get primary number and secondary numbers voicemail info.
    BOOL shouldShowEnableVoiceMailInfoInHomeTab = YES;
    SettingModel *currentSettingModel = [Setting sharedSetting].data;
    
    NSArray *currentSettingsVoiceMailInfoList = currentSettingModel.voiceMailInfo;
    
    for (NSInteger i=0; i< [currentSettingsVoiceMailInfoList count]; i++) {
        VoiceMailInfo *voiceMailInfo = [currentSettingsVoiceMailInfoList objectAtIndex:i];
        //As per the discussion - If any number has been activated no need to show the option of "Enable" in home tab.
        if (voiceMailInfo.isVoiceMailEnabled) {
            shouldShowEnableVoiceMailInfoInHomeTab = NO;
            break;
        }
    }
    
  //check whether we have custom settings for primary number.
    NSString *primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];

    if ([self customCarrierInfoForPhoneNumber:primaryNumber]) {
        if ([self hasSupportedCustomCarrierInfo:primaryNumber]) {
            
            IVSettingsCountryCarrierInfo *carrierInfo = [self supportedCarrierInfoFromCustomSettingsForPhoneNumber:primaryNumber];
            if (![self hasCarrierContainsValidUSSDInfo:carrierInfo]) {
                shouldShowEnableVoiceMailInfoInHomeTab = NO;
            }
        }
    }
   
    return shouldShowEnableVoiceMailInfoInHomeTab;
}

- (BOOL)hasSupportedCustomCarrierInfo:(NSString *)phoneNumber {
    
    BOOL hasSupportedCustomCarrierInfo = NO;
    
    if ([self customCarrierInfoForPhoneNumber:phoneNumber]) {
        //Get the carrier info.
        CarrierInfo *customCarrierInfo = [self customCarrierInfoForPhoneNumber:phoneNumber];
        
        VoiceMailInfo *voiceMailInfo = [self voiceMailInfoForPhoneNumber:phoneNumber];
        //We have carrier info - check in the carrier list we have corresponding supported carrier info in the carrier list.
        //Take the country code 
        NSString *countryCode;
        if (voiceMailInfo)
            countryCode = voiceMailInfo.carrierCountryCode;
        else
            countryCode = customCarrierInfo.countryCode;

        NSArray *carrierList = [self carrierListForCountry:countryCode];
        
        if (carrierList && [carrierList count]) {
            BOOL hasMatchingCarrierInfo = NO;
            for (NSInteger i=0; i<[carrierList count]; i++) {
                IVSettingsCountryCarrierInfo *carrierInfoInList = [carrierList objectAtIndex:i];
                if ([carrierInfoInList.countryCode isEqualToString:customCarrierInfo.countryCode] && [carrierInfoInList.vsmsNodeId isEqual:customCarrierInfo.vSMSId] && [carrierInfoInList.networkId isEqualToString:customCarrierInfo.networkId]) {
                    hasMatchingCarrierInfo = YES;
                }
            }
            
            if (hasMatchingCarrierInfo) {
                hasSupportedCustomCarrierInfo = YES;
            }
            else
                hasSupportedCustomCarrierInfo = NO;
        }
        else
            hasSupportedCustomCarrierInfo = NO;
    }
    else
        hasSupportedCustomCarrierInfo = NO;
    
    return hasSupportedCustomCarrierInfo;
    
}



- (BOOL)hasSupportedVoiceMailInfo:(NSString *)phoneNumber {
    
    BOOL hasSupportedCustomCarrierInfo = NO;
    
    if ([self voiceMailInfoForPhoneNumber:phoneNumber]) {
        //Get the voicemail info.
        VoiceMailInfo *voiceMailInfo = [self voiceMailInfoForPhoneNumber:phoneNumber];
        //We have carrier info - check in the carrier list we have corresponding supported carrier info in the carrier list.
        NSString *countryCode = voiceMailInfo.carrierCountryCode;
        NSArray *carrierList = [self carrierListForCountry:countryCode];
        
        if (carrierList && [carrierList count]) {
            BOOL hasMatchingCarrierInfo = NO;
            for (NSInteger i=0; i<[carrierList count]; i++) {
                IVSettingsCountryCarrierInfo *carrierInfoInList = [carrierList objectAtIndex:i];
                if ([carrierInfoInList.countryCode isEqualToString:voiceMailInfo.carrierCountryCode] && [carrierInfoInList.vsmsNodeId isEqual:voiceMailInfo.vSMSNodeId] && [carrierInfoInList.networkId isEqualToString:voiceMailInfo.networkId]) {
                    hasMatchingCarrierInfo = YES;
                }
            }
            
            if (hasMatchingCarrierInfo) {
                hasSupportedCustomCarrierInfo = YES;
            }
            else
                hasSupportedCustomCarrierInfo = NO;
        }
        else
            hasSupportedCustomCarrierInfo = NO;
    }
    else
        hasSupportedCustomCarrierInfo = NO;
    
    return hasSupportedCustomCarrierInfo;
    
}

- (IVSettingsCountryCarrierInfo *)supportedCarrierInfoFromCustomSettingsForPhoneNumber:(NSString *)phoneNumber {
    
    IVSettingsCountryCarrierInfo *carrierInfo;
    
    BOOL hasSupportedCustomCarrierInfo = NO;
    
    if ([self customCarrierInfoForPhoneNumber:phoneNumber]) {
        //Get the carrier info.
        CarrierInfo *customCarrierInfo = [self customCarrierInfoForPhoneNumber:phoneNumber];
        //We have carrier info - check in the carrier list we have corresponding supported carrier info in the carrier list.
        VoiceMailInfo *voiceMailInfo = [self voiceMailInfoForPhoneNumber:phoneNumber];
        //Take the country code
        NSString *countryCode;
        if (voiceMailInfo)
            countryCode = voiceMailInfo.carrierCountryCode;
        else
            countryCode = customCarrierInfo.countryCode;
        NSArray *carrierList = [self carrierListForCountry:countryCode];
        
        if (carrierList && [carrierList count]) {
            for (NSInteger i=0; i<[carrierList count]; i++) {
                IVSettingsCountryCarrierInfo *carrierInfoInList = [carrierList objectAtIndex:i];
                if ([carrierInfoInList.countryCode isEqualToString:customCarrierInfo.countryCode] && [carrierInfoInList.vsmsNodeId isEqual:customCarrierInfo.vSMSId] && [carrierInfoInList.networkId isEqualToString:customCarrierInfo.networkId]) {
                    hasSupportedCustomCarrierInfo = YES;
                    carrierInfo = carrierInfoInList;
                }
            }
            
            if (!hasSupportedCustomCarrierInfo) {
                carrierInfo = nil;
            }
            
        }
        else {
            carrierInfo = nil;
        }
    }
    else {
        carrierInfo = nil;
        
    }
    return carrierInfo;
}

- (IVSettingsCountryCarrierInfo *)supportedCarrierInfoFromVoiceMailInfoForPhoneNumber:(NSString *)phoneNumber {
    
    IVSettingsCountryCarrierInfo *carrierInfo;
    
    BOOL hasSupportedCustomCarrierInfo = NO;
    
    if ([self voiceMailInfoForPhoneNumber:phoneNumber]) {
        //Get the carrier info.
        VoiceMailInfo *voiceMailInfo = [self voiceMailInfoForPhoneNumber:phoneNumber];
        //We have carrier info - check in the carrier list we have corresponding supported carrier info in the carrier list.
        NSString *countryCode = voiceMailInfo.carrierCountryCode;
        NSArray *carrierList = [self carrierListForCountry:countryCode];
        
        if (carrierList && [carrierList count]) {
            for (NSInteger i=0; i<[carrierList count]; i++) {
                IVSettingsCountryCarrierInfo *carrierInfoInList = [carrierList objectAtIndex:i];
                if ([carrierInfoInList.countryCode isEqualToString:voiceMailInfo.carrierCountryCode] && [carrierInfoInList.vsmsNodeId isEqual:voiceMailInfo.vSMSNodeId] && [carrierInfoInList.networkId isEqualToString:voiceMailInfo.networkId]) {
                    carrierInfo = carrierInfoInList;
                    hasSupportedCustomCarrierInfo = YES;
                }
            }
            
            if (!hasSupportedCustomCarrierInfo) {
                carrierInfo = nil;
            }
            
        }
        else {
            carrierInfo = nil;
        }
    }
    else {
        carrierInfo = nil;
        
    }
    return carrierInfo;
}

- (BOOL)hasValidSimInfoForPhoneNumber:(NSString *)phoneNumber {
    
    BOOL hasValidSimInfo = NO;
    //Check for MCCMNC code of sim with the carrier mccmnc, country code of sim and country code of carrier.
    NSString *simMCCMNC =[Common simMCCMNCCode];
    //simMCCMNC = @"40492";
    NSString *simCountry = [Common simCountryCode];
   // simCountry = @"091";
    if (simMCCMNC && simCountry) {
        hasValidSimInfo = YES;
    }
    return hasValidSimInfo;
}

- (BOOL)hasSupportedSimCarrierInfo:(NSString *)phoneNumber {
    IVSettingsCountryCarrierInfo *carrierInfo;
    BOOL hasSupportedCustomCarrierInfo = NO;
    
    //Check for valid SIM info for number
    if ([self hasValidSimInfoForPhoneNumber:phoneNumber]) {
        
        //Check for MCCMNC code of sim with the carrier mccmnc, country code of sim and country code of carrier.
        NSString *simMCCMNC =[Common simMCCMNCCode];
        //simMCCMNC = @"40492";
        NSString *simCountry = [Common simCountryCode];
        //simCountry = @"091";
        //Yes, we have valid sim info for phone number.
        VoiceMailInfo *voiceMailInfo = [self voiceMailInfoForPhoneNumber:phoneNumber];
        //We have carrier info - check in the carrier list we have corresponding supported carrier info in the carrier list.
        NSString *countryCode = voiceMailInfo.carrierCountryCode;
        NSArray *carrierList = [self carrierListForCountry:countryCode];
        if (carrierList && [carrierList count]) {
            for (NSInteger i=0; i<[carrierList count]; i++) {
                IVSettingsCountryCarrierInfo *carrierInfoInList = [carrierList objectAtIndex:i];
                //check mccmnc list in the carrier info
                if (carrierInfoInList.mccmncList && [carrierInfoInList.mccmncList count]) {
                    //We have MCCMNC List, check whether mccmnc sim is in the list.
                    BOOL isMCCMNCListInCarrierList = [carrierInfoInList.mccmncList containsObject:simMCCMNC];
                    if (isMCCMNCListInCarrierList && [simCountry isEqualToString:carrierInfoInList.countryCode]) {
                        hasSupportedCustomCarrierInfo = YES;
                        carrierInfo = carrierInfoInList;
                        break;
                    }
                }
            }
            
            if (!hasSupportedCustomCarrierInfo) {
                carrierInfo = nil;
            }
            
        }
        else
            carrierInfo = nil;
    }
    else
        carrierInfo = nil;
    
    return hasSupportedCustomCarrierInfo;
}

- (IVSettingsCountryCarrierInfo *)supportedCarrierInfoFromSimInfoForPhoneNumber:(NSString *)phoneNumber {
    
    IVSettingsCountryCarrierInfo *carrierInfo;
    BOOL hasSupportedCustomCarrierInfo = NO;

    //Check for valid SIM info for number
    if ([self hasValidSimInfoForPhoneNumber:phoneNumber]) {
        
        //Check for MCCMNC code of sim with the carrier mccmnc, country code of sim and country code of carrier.
        NSString *simMCCMNC =[Common simMCCMNCCode];
        //simMCCMNC = @"40492";
        NSString *simCountry = [Common simCountryCode];
        //simCountry = @"091";
        //Yes, we have valid sim info for phone number.
        VoiceMailInfo *voiceMailInfo = [self voiceMailInfoForPhoneNumber:phoneNumber];
        //We have carrier info - check in the carrier list we have corresponding supported carrier info in the carrier list.
        NSString *countryCode = voiceMailInfo.carrierCountryCode;
        NSArray *carrierList = [self carrierListForCountry:countryCode];
        if (carrierList && [carrierList count]) {
            for (NSInteger i=0; i<[carrierList count]; i++) {
                IVSettingsCountryCarrierInfo *carrierInfoInList = [carrierList objectAtIndex:i];
                //check mccmnc list in the carrier info
                if (carrierInfoInList.mccmncList && [carrierInfoInList.mccmncList count]) {
                    //We have MCCMNC List, check whether mccmnc sim is in the list.
                    BOOL isMCCMNCListInCarrierList = [carrierInfoInList.mccmncList containsObject:simMCCMNC];
                    if (isMCCMNCListInCarrierList && [simCountry isEqualToString:carrierInfoInList.countryCode]) {
                        hasSupportedCustomCarrierInfo = YES;
                        carrierInfo = carrierInfoInList;
                        break;
                    }
                }
                
            }
            
            if (!hasSupportedCustomCarrierInfo) {
                carrierInfo = nil;
            }
            
        }
        else
            carrierInfo = nil;
    }
    else
        carrierInfo = nil;
    
    return carrierInfo;
}

- (BOOL)hasCarrierContainsValidUSSDInfo:(IVSettingsCountryCarrierInfo *)carrierInfo {
 
    BOOL hasCarrierContainsValidUSSDInfo = NO;
    
    if (carrierInfo.ussdInfo) {
        BOOL isCarrierSupportedForVoiceMailSetup = NO;
        BOOL isVoiceMailAndMissedCallDeactivated = NO;
        isCarrierSupportedForVoiceMailSetup = (carrierInfo.ussdInfo.actiAll && (![carrierInfo.ussdInfo.actiAll isEqualToString:@""]|| !([carrierInfo.ussdInfo.actiAll length] == 0)))? YES:NO;
        isVoiceMailAndMissedCallDeactivated = (carrierInfo.ussdInfo.deactiAll && (![carrierInfo.ussdInfo.deactiAll isEqualToString:@""]|| !([carrierInfo.ussdInfo.deactiAll length] == 0)))? YES:NO;
        if (isCarrierSupportedForVoiceMailSetup && isVoiceMailAndMissedCallDeactivated) {
            hasCarrierContainsValidUSSDInfo = YES;
        }
    }
    return hasCarrierContainsValidUSSDInfo;
}


//Carrier theme color set and get method
- (NSString *)getCarrierThemeColorForNumber:(NSString *)phoneNumber {
    NSString *themeColor;
    VoiceMailInfo *voiceMailInfo = [self voiceMailInfoForPhoneNumber:phoneNumber];
    if (voiceMailInfo && voiceMailInfo.carrierThemeColor) {
        themeColor = voiceMailInfo.carrierThemeColor;
    }
    
    
    return themeColor;
}

- (void)setCarrierThemeColorForNumber:(NSString *)themeColor number:(NSString *)phoneNumber {

    VoiceMailInfo *voiceMailInfo = [self voiceMailInfoForPhoneNumber:phoneNumber];
    if (voiceMailInfo) {
        voiceMailInfo.carrierThemeColor = themeColor;
        [[ConfigurationReader sharedConfgReaderObj]setLatestCarrierThemeColor:themeColor];
    }
}

- (void)clearCarrierList {
    if ([Setting sharedSetting].data.listOfCarriers && [[Setting sharedSetting].data.listOfCarriers count]) {
        
        [[Setting sharedSetting].data.listOfCarriers removeAllObjects];
        [Setting sharedSetting].data.listOfCarriers = nil;
    }
}

- (void)removeOrAddTestCarrierBasedOnShowCarrierStatus {
   
#if SHOW_CARRIER_IN_LIST
    {
        [self clearCarrierList];
        [self fetchCarrierList];

    }
#else
    {
        NSMutableArray *finalData = [[NSMutableArray alloc]init];
        NSArray *settingsCarrierList  = [Setting sharedSetting].data.listOfCarriers;
        for (NSInteger i=0; i<[settingsCarrierList count]; i++) {
            NSDictionary *countryWiseCarrierList = [settingsCarrierList objectAtIndex:i];
            NSMutableDictionary *finalDataDictionary = [[NSMutableDictionary alloc]init];
            NSString *key = countryWiseCarrierList.allKeys.firstObject;
            NSMutableArray *carrierList = countryWiseCarrierList[key];
            NSMutableArray *carrierNeedsToRemove = [[NSMutableArray alloc]init];
            for (IVSettingsCountryCarrierInfo *carrierInfo in carrierList) {
                if ([carrierInfo.ussdInfo.skip isEqualToString:@"y"] && [carrierInfo.ussdInfo.test isEqualToString:@"y"]) {
                    [carrierNeedsToRemove addObject: carrierInfo];
                }
            }
            if (carrierNeedsToRemove && [carrierNeedsToRemove count]) {
                [carrierList removeObjectsInArray:carrierNeedsToRemove];
            }
            [finalDataDictionary setObject:carrierList forKey:key];
            [finalData addObject:countryWiseCarrierList];
        }
        
        if ([Setting sharedSetting].data.listOfCarriers && [[Setting sharedSetting].data.listOfCarriers count]) {
            [[Setting sharedSetting].data.listOfCarriers removeAllObjects];
            [Setting sharedSetting].data.listOfCarriers = nil;
        }
        
        if (finalData && [finalData count]) {
            [Setting sharedSetting].data.listOfCarriers = finalData;
        }
    }
#endif

}


#ifndef REACHME_APP
- (void)checkAndDownloadPromoImage:(SettingModel *)serverResponse
{
    //Only download the carrier logo for primary number.
    NSString *primaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
    VoiceMailInfo *currentVoiceMailInfo = [self voiceMailInfoForPhoneNumber:primaryNumber];
    
    //TODO: remove hardcoding
   // currentVoiceMailInfo.showInAppImage = YES;
    //check for the app promo image
    if (currentVoiceMailInfo && currentVoiceMailInfo.inAppPromoImageURL && currentVoiceMailInfo.showInAppImage) {
        [self downloadAndSavePromoImage:currentVoiceMailInfo.inAppPromoImageURL];
    }
}

- (void)downloadAndSavePromoImage:(NSString *)promoImagePath {
    if (promoImagePath && ![promoImagePath isEqualToString:@""]) {
        DownloadProfilePic* api = [[DownloadProfilePic alloc]initWithRequest:Nil];
        [api callNetworkRequest:promoImagePath withSuccess:^(DownloadProfilePic *req, NSData *responseObject) {
            NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            NSString* localFileName = [NSString stringWithFormat:@"PromoImage_%@.png",loginId];
            [IVFileLocator deleteFileAtPath:[IVFileLocator getPromoImagePath:localFileName]];
            BOOL isWritten = [responseObject writeToFile:[IVFileLocator getPromoImagePath:localFileName] atomically:YES];
            if(isWritten)
            {
                if (self.delegate && [self.delegate respondsToSelector:@selector(fetchPromoImageCompletedWithStatus:)])
                    [self.delegate fetchPromoImageCompletedWithStatus:YES];
            }
            
        } failure:^(DownloadProfilePic *req, NSError *error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(fetchPromoImageCompletedWithStatus:)])
                [self.delegate fetchPromoImageCompletedWithStatus:NO];
            
        }];
    }
    else {
        //We do not have carrierLogoImagePath - delete If its already existed.
        NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
        NSString* localFileName = [NSString stringWithFormat:@"PromoImage_%@.png",loginId];
        [IVFileLocator deleteFileAtPath:[IVFileLocator getPromoImagePath:localFileName]];
        if (self.delegate && [self.delegate respondsToSelector:@selector(fetchPromoImageCompletedWithStatus:)])
            [self.delegate fetchPromoImageCompletedWithStatus:YES];
    }
}

- (BOOL)shouldShowInAppPromoImage {
    
    BOOL shouldShowInAppPromoImage = NO;
    NSString *primaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
    VoiceMailInfo *currentVoiceMailInfo = [self voiceMailInfoForPhoneNumber:primaryNumber];
    
    if ([[ConfigurationReader sharedConfgReaderObj]isFreshSignUp] && currentVoiceMailInfo && currentVoiceMailInfo.inAppPromoImageURL && currentVoiceMailInfo.showInAppImage && ![[ConfigurationReader sharedConfgReaderObj]didInAppPromoImageShown]) {
        NSString* localFileName = [NSString stringWithFormat:@"PromoImage_%@.png",primaryNumber];
        NSString *storagePathName   = [IVFileLocator getPromoImagePath:localFileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:storagePathName]) {
            shouldShowInAppPromoImage = YES;
        }
        else {
            [self checkAndDownloadPromoImage:[Setting sharedSetting].data];
        }
    }
    return shouldShowInAppPromoImage;
}
#endif

@end
