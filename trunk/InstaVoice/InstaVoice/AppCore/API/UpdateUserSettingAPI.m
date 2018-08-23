//
//  UpdateUserSettingAPI.m
//  InstaVoice
//
//  Created by adwivedi on 24/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "UpdateUserSettingAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "SettingModel.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "RegistrationApi.h"
#import "Logger.h"


#define k2Min 120
#define k1Min  60
#define k30Sec 30

@implementation UpdateUserSettingAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(SettingModel *)model withSuccess:(void (^)(UpdateUserSettingAPI *, BOOL))success failure:(void (^)(UpdateUserSettingAPI *, NSError *))failure
{
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    NSMutableDictionary* requestDic = [[NSMutableDictionary alloc]init];
    [NetworkCommon addCommonData:requestDic eventType:UPDATE_USER_SETTINGS];
    [self updateReqDic:requestDic with:model];
    EnLogd(@"IVSettings:%@",requestDic);
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        KLog(@"UpdateUserSettingAPI succeeded:%@",requestDic);
        success(self,YES);
        EnLogd(@"IVSettings Success:%@",responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
        EnLogd(@"IVSettings Failure:%@",error);
        KLog(@"UpdateUserSettingAPI failed:%@",requestDic);
    }];    
}

-(void)updateReqDic:(NSMutableDictionary*)updateUserSet with:(SettingModel*)model
{
    /*
     [updateUserSet setValue:[NSNumber numberWithBool:model.fbPostEnabled] forKey:API_FB_POST_ENABLED];
     [updateUserSet setValue:[NSNumber numberWithBool:model.twPostEnabled] forKey:API_TW_POST_ENABLED];
     [updateUserSet setValue:[NSNumber numberWithBool:model.displayLocation] forKey:DISPLAY_LOCATION];
     
     //Newly added keys
     [updateUserSet setValue:model.defaultRecordMode forKey:kDefaultRecordMode];
     
     
     NSMutableArray *customSetArr = [[NSMutableArray alloc]init];
     NSNumber *maxRecordTm =  [NSNumber numberWithInteger:model.maxRecordTime];
     
     if(maxRecordTm != nil)
     {
     NSMutableDictionary *maxRecordTmDic = [[NSMutableDictionary alloc]init];
     [maxRecordTmDic setValue:maxRecordTm forKey:MAX_RECORD_TIME];
     [customSetArr addObject:maxRecordTmDic];
     }
     
     NSNumber *vbEnbl =  [NSNumber numberWithBool:model.vbEnabled];
     if(vbEnbl != nil)
     {
     NSMutableDictionary *vbEnblDic = [[NSMutableDictionary alloc]init];
     [vbEnblDic setValue:vbEnbl forKey:VB_ENABLE];
     [customSetArr addObject:vbEnblDic];
     }
     [updateUserSet setValue:customSetArr forKey:API_CUSTOM_SETTINGS];
     */
    
    //Start: Nivedita , Date: 17th Dec - As per the latest implementation changes, changing the custom settings key, values based on the converstaion with the andriod team and Ajay
    
    // [updateUserSet setValue:model.defaultRecordMode forKey:kDefaultRecordMode];
    // [updateUserSet setValue:model.defaultVoiceMode forKey:kDefaultVoiceMode];
    // [updateUserSet setValue:model.storageLocation forKey:kStorageLocation];
    // [updateUserSet setValue:[NSNumber numberWithBool:model.displayLocation] forKey:DISPLAY_LOCATION];
    
    [updateUserSet setValue:[NSNumber numberWithBool:model.fbPostEnabled] forKey:API_FB_POST_ENABLED];
    [updateUserSet setValue:[NSNumber numberWithBool:model.twPostEnabled] forKey:API_TW_POST_ENABLED];
    
    //Transcription
    [updateUserSet setValue:[NSNumber numberWithBool:model.userManualTrans] forKey:API_USER_MANUAL_ENABLED];
    
    NSMutableArray *customSetArr = [[NSMutableArray alloc]init];
    NSNumber *maxRecordTm =  [NSNumber numberWithInteger:model.maxRecordTime];
    //As per the conversation, we need to follow the convention of "2 Min", "1 Min" and "30 Sec" sending it to server.
    if(maxRecordTm) {
        //By default - its 2Min;
        NSString *maxRecordingTime = @"2 Min";
        NSMutableDictionary *maxRecordTmDic = [[NSMutableDictionary alloc]init];
        
        if(k2Min == [maxRecordTm integerValue])
            maxRecordingTime = @"2 Min";
        else if(k1Min == [maxRecordTm integerValue])
            maxRecordingTime = @"1 Min";
        else
            maxRecordingTime = @"30 Sec";
        
        [maxRecordTmDic setValue:maxRecordingTime forKey:MAX_RECORD_TIME];
        [customSetArr addObject:maxRecordTmDic];
        
    }
    //Storage Location
    if(nil != model.storageLocation) {
        NSMutableDictionary *defaultStorageLocationDict = [[NSMutableDictionary alloc]init];
        [defaultStorageLocationDict setValue:model.storageLocation forKey:kStorageLocation];
        [customSetArr addObject:defaultStorageLocationDict];
    }
    
    //Default Record Mode
    if(nil != model.defaultRecordMode) {
        NSMutableDictionary *defaultRecordModeDict = [[NSMutableDictionary alloc]init];
        [defaultRecordModeDict setValue:model.defaultRecordMode forKey:kDefaultRecordMode];
        [customSetArr addObject:defaultRecordModeDict];
    }
    
    //Default Voice Mode
    if(nil != model.defaultVoiceMode) {
        NSMutableDictionary *defaultsVoiceModeDict = [[NSMutableDictionary alloc]init];
        [defaultsVoiceModeDict setValue:model.defaultVoiceMode forKey:kDefaultVoiceMode];
        [customSetArr addObject:defaultsVoiceModeDict];
    }
    
    //Show FB Friend settings
    NSNumber *showFBFriend =  [NSNumber numberWithBool:model.showFBFriend];
    if(model.showFBFriend) {
        NSMutableDictionary *showFBFriendDict = [[NSMutableDictionary alloc]init];
        [showFBFriendDict setValue:showFBFriend forKey:kShowFBFriend];
        [customSetArr addObject:showFBFriendDict];
    }
    
    //Show TW Friend settings
    NSNumber *showTWFriend =  [NSNumber numberWithBool:model.showTwitterFriend];
    if(model.showTwitterFriend) {
        NSMutableDictionary *showTWFriendDict = [[NSMutableDictionary alloc]init];
        [showTWFriendDict setValue:showTWFriend  forKey:kShowTwitterFriend];
        [customSetArr addObject:showTWFriendDict];
        
    }
    
    //Show sharelocation
    NSNumber *shareLocation =  [NSNumber numberWithBool:model.displayLocation];
    if(shareLocation != nil) {
        NSMutableDictionary *shareLocationDict = [[NSMutableDictionary alloc]init];
        [shareLocationDict setValue:shareLocation forKey:DISPLAY_LOCATION];
        [customSetArr addObject:shareLocationDict];
    }
    
    
    NSNumber *vbEnbl =  [NSNumber numberWithBool:model.vbEnabled];
    if(vbEnbl != nil) {
        NSMutableDictionary *vbEnblDic = [[NSMutableDictionary alloc]init];
        [vbEnblDic setValue:vbEnbl forKey:VB_ENABLE];
        [customSetArr addObject:vbEnblDic];
    }
    
    
    
    if(model.carrierInfoList && [model.carrierInfoList count]) {
        
        NSMutableDictionary *finalCarrierDetails = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *carrierDetailsDict = [[NSMutableDictionary alloc]init];
        //Get the carrier information for the various numbers.
        //Verify we have carrier info
            for(id carrierInfo in model.carrierInfoList) {
                
                if([carrierInfo isKindOfClass:[CarrierInfo class]]) {
                    CarrierInfo *carrierDetails = carrierInfo;
                    
                    NSMutableDictionary *carrierCompleteDetails =[[NSMutableDictionary alloc]init];
                    //TODO: Reverify the fields.
                    //Country Code
                    //[carrierCompleteDetails setObject:carrierDetails.countryCode forKey:@"country_cd"];
                    
                    //Data migration issue fixes:
                        if([carrierDetails.countryCode isEqualToString:@"91"])
                            carrierDetails.countryCode = @"091";
                        if([carrierDetails.countryCode isEqualToString:@"1"] || [carrierDetails.countryCode isEqualToString:@"01"])
                            carrierDetails.countryCode = @"001";
                    
                    //Country Code
                    if (carrierDetails.countryCode)
                        [carrierCompleteDetails setObject:carrierDetails.countryCode forKey:@"country_cd"];
                    
                    //NetworkId
                    if (carrierDetails.networkId)
                       [carrierCompleteDetails setObject:carrierDetails.networkId forKey:@"network_id"];
                    
                    //VSMS Id
                    if (carrierDetails.vSMSId)
                       [carrierCompleteDetails setObject:carrierDetails.vSMSId forKey:@"vsms_id"];
                    
                    if (carrierDetails.phoneNumber)
                         [carrierDetailsDict setObject:carrierCompleteDetails forKey:carrierDetails.phoneNumber];
                    
#ifdef REACHME_APP
                    [carrierCompleteDetails setObject:[NSNumber numberWithBool:carrierDetails.isReachMeIntlActive] forKey:@"rm_intl_acti"];
                    [carrierCompleteDetails setObject:[NSNumber numberWithBool:carrierDetails.isReachMeHomeActive] forKey:@"rm_home_acti"];
                    [carrierCompleteDetails setObject:[NSNumber numberWithBool:carrierDetails.isReachMeVMActive] forKey:@"vm_acti"];
                    
#else
                    //Voip
                    [carrierCompleteDetails setObject:[NSNumber numberWithBool:carrierDetails.isVoipEnabled] forKey:@"vp_enbld"];
                    
                    //Voip Status
                    [carrierCompleteDetails setObject:[NSNumber numberWithBool:carrierDetails.isVoipStatusEnabled] forKey:@"voip_status"];
#endif
                
            }
        }
        //Carrier info set into the customSetArr
        NSString *carrierDetailsJSONString = [self convertDataIntoJSONString:carrierDetailsDict];
        carrierDetailsJSONString = [carrierDetailsJSONString stringByReplacingOccurrencesOfString:@" " withString:@""];
        [finalCarrierDetails setObject:carrierDetailsJSONString forKey:kCarrierInfo];
        [customSetArr addObject:finalCarrierDetails];
    }
    
    
    if(model.numberInfoList && [model.numberInfoList count]) {
        
        NSMutableDictionary *finalNumberDetails = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *numberDetailsDict = [[NSMutableDictionary alloc]init];
        //Get the carrier information for the various numbers.
        //Verify we have carrier info
        for(id numberInfo in model.numberInfoList) {
            
            if([numberInfo isKindOfClass:[NumberInfo class]]) {
                NumberInfo *numberDetails = numberInfo;
                
                NSMutableDictionary *numberCompleteDetails =[[NSMutableDictionary alloc]init];
                
                //Image Name
                if (numberDetails.imgName)
                    [numberCompleteDetails setObject:numberDetails.imgName forKey:@"img_nm"];
                
                //Title Name
                if (numberDetails.titleName){
                    NSString *name = [numberDetails.titleName stringByReplacingOccurrencesOfString:@" " withString:@"titlenamespace"];
                    [numberCompleteDetails setObject:name forKey:@"title_nm"];
                }
                
                if (numberDetails.phoneNumber)
                    [numberDetailsDict setObject:numberCompleteDetails forKey:numberDetails.phoneNumber];
                
                
            }
        }
        //Carrier info set into the customSetArr
        NSString *carrierDetailsJSONString = [self convertDataIntoJSONString:numberDetailsDict];
        carrierDetailsJSONString = [carrierDetailsJSONString stringByReplacingOccurrencesOfString:@" " withString:@""];
        carrierDetailsJSONString = [carrierDetailsJSONString stringByReplacingOccurrencesOfString:@"titlenamespace" withString:@" "];
        [finalNumberDetails setObject:carrierDetailsJSONString forKey:kNumberInfo];
        [customSetArr addObject:finalNumberDetails];
    }
    
    [updateUserSet setValue:customSetArr forKey:API_CUSTOM_SETTINGS];
    
}


- (NSString *)convertDataIntoJSONString:(id)withData {
    
    NSString *jsonString;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:withData options:NSJSONWritingPrettyPrinted error:&error];
    
    if (! jsonData) {
        KLog(@"JSON string failed: error: %@", error.localizedDescription);
        return @"{}";
    } else
        
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

       jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
    
}
@end
