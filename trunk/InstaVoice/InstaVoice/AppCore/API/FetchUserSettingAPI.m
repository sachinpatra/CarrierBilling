//
//  FetchUserSettingAPI.m
//  InstaVoice
//
//  Created by adwivedi on 24/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "FetchUserSettingAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "SettingModel.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "RegistrationApi.h"
#import "Setting.h"
#import "Common.h"

#define kDefaultCacheType @"Device Cache"

@implementation FetchUserSettingAPI

-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(FetchUserSettingAPI* req , SettingModel* responseObject))success failure:(void (^)(FetchUserSettingAPI* req, NSError *error))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:FETCH_USER_SETTINGS_REQ];
    
    [requestDic setObject:@"true" forKey:@"fetch_voicemails_info"];
    
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        EnLogd(@"FetchUserSettings = %@",responseObject);
        KLog(@"FetchUserSettings = %@",responseObject);
        self.response=responseObject;
        //Get the older voicemail info, check with latest server data if any changes - start downloading the carrier logo image if any.
        [[Setting sharedSetting]checkAndDownloadLatestCarrierLogo:responseObject];
        
        
        SettingModel* model = [self createSettingModelObjectFromDictionary:responseObject];
        //Start downloading the In App PromoImage for fresh signup
#ifndef REACHME_APP
        if ([[ConfigurationReader sharedConfgReaderObj]isFreshSignUp] && ![[ConfigurationReader sharedConfgReaderObj]didInAppPromoImageShown]) {
            [[Setting sharedSetting]checkAndDownloadPromoImage:model];
        }
#endif

        success(self,model);
    } failure:^(NetworkCommon *req, NSError *error) {
        EnLogd(@"FetchUserSettings failed: %@",error);
        KLog(@"FetchUserSettings = %@",error);
        failure(self,error);
    }];
}

-(SettingModel*)createSettingModelObjectFromDictionary:(NSMutableDictionary*)responseDic
{
    SettingModel* model = [Setting sharedSetting].data;
    if(responseDic != nil && [responseDic count] > 0)
    {
        int expiryTime = [[responseDic valueForKey:CONFG_RING_EXPIRY_MIN]intValue];//in minutes
        if( expiryTime <= 0) {
            expiryTime = 15;//Default value
            [[ConfigurationReader sharedConfgReaderObj]setRingExpiryTime:expiryTime];
        }
        
        long long ivUserId = [[ConfigurationReader sharedConfgReaderObj] getIVUserId];
        NSNumber *ivID = [[NSNumber alloc]initWithLongLong:ivUserId];
        model.ivUserId = [ivID stringValue];
        
        NSNumber *fbConn = [responseDic valueForKey:API_FB_CONNECTED];
        model.fbConnected = [fbConn boolValue];
        
        NSNumber *twConn = [responseDic valueForKey:API_TW_CONNECTED];
        model.twConnected = [twConn boolValue];
        
        NSNumber *fbPostEnbl = [responseDic valueForKey:API_FB_POST_ENABLED];
        model.fbPostEnabled = [fbPostEnbl boolValue];
        NSNumber *twPostEnbl = [responseDic valueForKey:API_TW_POST_ENABLED];
        model.twPostEnabled = [twPostEnbl boolValue];
        
        //Transcription
        NSNumber *userManualTransEnbl = [responseDic valueForKey:API_USER_MANUAL_ENABLED];
        model.userManualTrans = [userManualTransEnbl boolValue];
        
        NSNumber *countryManualTransEnbl = [responseDic valueForKey:API_COUNTRY_MANUAL_ENABLED];
        model.countryManualTrans = [countryManualTransEnbl boolValue];
        
        //MQTT Setting
        SettingModelMqtt* mqttSetting = [[SettingModelMqtt alloc]init];
        NSString* chatTopic = [responseDic valueForKey:@"chat_topic"];
        NSString* chatUser = [responseDic valueForKey:@"chat_user"];
        NSString* chatPassword = [responseDic valueForKey:@"chat_password"];
        NSString* chatHostName = [responseDic valueForKey:@"chat_hostname"];
        NSInteger chatPortSSL = [[responseDic valueForKey:@"chat_port_ssl"]integerValue];
        
        if(chatTopic && [chatTopic length]) {
            mqttSetting.chatTopic = chatTopic;
        } else {
            EnLogd("Recvd chat_topic is nil.");
        }
        
        if(chatUser && [chatUser length]) {
            mqttSetting.chatUser = chatUser;
        } else {
            EnLogd(@"Recvd chat_user is nil");
        }
        
        if(chatHostName && [chatHostName length]) {
            mqttSetting.chatHostName = chatHostName;
        } else {
            EnLogd(@"Recvd chat_hostname is nil");
        }
        
        if(chatPortSSL && chatPortSSL >= 0) {
            mqttSetting.chatPortSSL = chatPortSSL;
        } else {
            EnLogd(@"Recvd chat_port_ssl is %ld",chatPortSSL);
        }
        
        mqttSetting.chatPassword = chatPassword; //Not used by the app
        mqttSetting.mqttHostName = [responseDic valueForKey:@"mqtt_hostname"]; //Not used
        mqttSetting.mqttPassword = [responseDic valueForKey:@"mqtt_password"]; //Not used
        mqttSetting.mqttUser = [responseDic valueForKey:@"mqtt_user"]; //Not used
        mqttSetting.mqttPortSSL = [[responseDic valueForKey:@"mqtt_port_ssl"]integerValue]; //Not used
        mqttSetting.deviceId = [responseDic valueForKey:@"iv_user_device_id"];
        
        model.mqttSetting = mqttSetting;

        EnLogd(@"mqttSetting: %@",mqttSetting);
        KLog(@"mqttSetting: %@",mqttSetting);
        
        //Old
        /*"custom_settings":"[{\"recording_time\":\"2 Min\"},{\"show_fb_frnd\":true},{\"show_tw_frnd\":true},{\"vb_enable\":true},{\"share_location\":false},{\"carrier\":\"{\\\"917386315477\\\":\\\"{\\\\\\\"country_code\\\\\\\":\\\\\\\"091\\\\\\\",\\\\\\\"mccmnc_list\\\\\\\":\\\\\\\"40486\\\\\\\",\\\\\\\"network_id\\\\\\\":\\\\\\\"11\\\\\\\",\\\\\\\"network_name\\\\\\\":\\\\\\\"Vodafone Karnataka\\\\\\\",\\\\\\\"ussd_string\\\\\\\":\\\\\\\"{\\\\\\\\\\\\\\\"network\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"Vodafone Karnataka\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"chk_ph\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"*282#\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"chk_all\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"chk_busy\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"*#67#\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"chk_noreply\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"*#61#\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"chk_off\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"*#62#\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"acti_all\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"**004*9742255719#\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"acti_busy\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"**67*#9742255719\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"acti_noreply\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"**61*9742255719#\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"acti_off\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"**62*9742255719#\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"deacti_all\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"#004#\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"deacti_busy\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"#67#\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"deacti_noreply\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"#61#\\\\\\\\\\\\\\\",\\\\\\\\\\\\\\\"deacti_off\\\\\\\\\\\\\\\":\\\\\\\\\\\\\\\"#62#\\\\\\\\\\\\\\\"}\\\\\\\",\\\\\\\"vsms_node_id\\\\\\\":5}\\\",\\\"910909090909\\\":\\\"{\\\\\\\"country_code\\\\\\\":\\\\\\\"091\\\\\\\",\\\\\\\"mccmnc_list\\\\\\\":\\\\\\\"\\\\\\\",\\\\\\\"network_id\\\\\\\":\\\\\\\"98\\\\\\\",\\\\\\\"network_name\\\\\\\":\\\\\\\"Aircel  Bihar\u0026Jharkhand\\\\\\\",\\\\\\\"ussd_string\\\\\\\":\\\\\\\"\\\\\\\",\\\\\\\"vsms_node_id\\\\\\\":5}\\\"}\"}]"
         */
        
        //New
        /*
         {"cmd":"fetch_settings","status":"ok","pns_app_id":"318755574741","docs_url":"http://stagingblogs.instavoice.com/vobolo/iv/docs/","mqtt_hostname":"pn-staging14.instavoice.com","iv_support_contact_ids":"[{\"support_catg_id\":\"IVSupport\",\"support_catg\":\"Help\",\"show_as_iv_user\":true,\"iv_user_id\":\"2624836\",\"phone\":\"912222222222\",\"profile_pic_uri\":\"http:\\/\\/stagingblogs.instavoice.com\\/vobolo\\/profile-images\\/2222\\/2624836_8504055293382408531_1447324710221.png\",\"thumbnail_profile_pic_uri\":\"http:\\/\\/stagingblogs.instavoice.com\\/vobolo\\/thumbnails\\/2222\\/2624836_8504055293382408531_1447324710221.png\",\"support_send_iv\":true,\"support_send_sms\":false,\"support_send_email\":false},{\"feedback_catg_id\":\"IVFeedback\",\"feedback_catg\":\"Suggestions\",\"show_as_iv_user\":false,\"iv_user_id\":\"2624835\",\"phone\":\"911111111111\",\"profile_pic_uri\":\"http:\\/\\/stagingblogs.instavoice.com\\/vobolo\\/static-contents\\/images\\/default_profile_pic.jpg\",\"thumbnail_profile_pic_uri\":\"http:\\/\\/stagingblogs.instavoice.com\\/vobolo\\/static-contents\\/images\\/default_profile_pic_thumbnail.jpg\",\"feedback_send_iv\":true,\"feedback_send_sms\":false,\"feedback_send_email\":false}]","iv_user_id":11374145,"iv_user_device_id":205413,"screen_name":"42293051","is_profile_pic_set":false,"profile_pic_uri":"http://stagingblogs.instavoice.com/vobolo/static-contents/images/default_profile_pic.jpg","thumbnail_profile_pic_uri":"http://stagingblogs.instavoice.com/vobolo/static-contents/images/default_profile_pic_thumbnail.jpg","facebook_connection":false,"twitter_connection":false,"fb_connected":false,"tw_connected":false,"fb_post_enabled":true,"tw_post_enabled":true,"fb_connect_url":"http://stagingblogs.instavoice.com/iv/fbc/","tw_connect_url":"http://stagingblogs.instavoice.com/iv/twc/","vsms_allowed":true,"country_isd":"233","phone_len":9,"custom_settings":"[{\"recording_time\":\"1 Min\"},{\"default_voice_mode\":\"Speaker\"},{\"storage_location\":\"Device Cache\"},{\"show_fb_frnd\":true},{\"show_tw_frnd\":true},{\"vb_enable\":true},{\"share_location\":false},{\"carrier\":\"{\\\"919999393393\\\":{\\\"country_cd\\\":\\\"091\\\",\\\"network_id\\\":\\\"11\\\",\\\"vsms_id\\\":5},\\\"233272617111\\\":{\\\"country_cd\\\":\\\"233\\\",\\\"network_id\\\":\\\"01\\\",\\\"vsms_id\\\":6}}\"}]","last_fetched_msg_id":3937043,"last_fetched_contact_trno":0,"last_fetched_msg_activity_id":0,"last_fetched_profile_trno":0,"send_email_for_iv":false,"send_sms_for_iv":false,"send_email_for_vb":false,"send_sms_for_vb":false,"send_email_for_vsms":false,"send_sms_for_vsms":false,"ussd_err":"network_notsupported","device_id":205413,"chat_hostname":"pn-staging14.instavoice.com","chat_port_ssl":"8883","chat_user":"guest","chat_password":"guest","mqtt_port_ssl":8883,"mqtt_password":"guest","mqtt_user":"guest","chat_topic":"VirtualTopic/ivChat003"}
         */
        
        //VoiceMail Information related.
        
        id voiceMailInformation = responseDic[VOICEMAIL_INFO];
        
        if(voiceMailInformation) {
            
            NSMutableArray *voiceMailInfoList = [[NSMutableArray alloc]init];
            if([voiceMailInformation isKindOfClass:[NSArray class]]) {
                
                NSArray *voiceMailInfoArray = voiceMailInformation;
                for (NSUInteger i=0; i<[voiceMailInfoArray count]; i++) {
                    
                    VoiceMailInfo *voiceMailInfo = [[VoiceMailInfo alloc]initWithVoiceMailInfo:[voiceMailInfoArray objectAtIndex:i]];
                    [voiceMailInfoList addObject:voiceMailInfo];
                    
                }
                model.voiceMailInfo = voiceMailInfoList;
            }
            
            //NOV 16, 2016
            BOOL flag = [self isVoicemailSupported:voiceMailInfoList];
            [Setting sharedSetting].isVoicemailSupported = flag;
            [[ConfigurationReader sharedConfgReaderObj]setVoicemailSupportedFlag:flag];
            EnLogd(@"isVoicemailSupported: %d",flag);
            //
        }
        else
            model.voiceMailInfo = nil;
        
        //Custom Settings Related
        NSString *customSettStr = [responseDic valueForKey:API_CUSTOM_SETTINGS];
        if(customSettStr != nil && [customSettStr length]>0)
        {
            NSMutableArray *carrierList = [[NSMutableArray alloc]init];
            NSMutableArray *numberList = [[NSMutableArray alloc]init];
            
            NSData *data = [customSettStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableArray *customSett = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if(customSett != nil && [customSett count]>0)
            {
                for( NSMutableDictionary *customDic in customSett)
                {
                    //Max Recoridng Time
                    NSString *maxRecordTm = customDic[MAX_RECORD_TIME]?customDic[MAX_RECORD_TIME]:customDic [@"MAX_RECORD_TIME"];
                    if(maxRecordTm != nil) {// check the values : 2MIN, 1MIN and 30 Sec, Here assuming we are considering only these three values. This is not good approach..!!!! - change it to secs values.
                        
                        if([maxRecordTm isKindOfClass:[NSString class]]){
                            if([maxRecordTm isEqualToString:@"1 Min"])
                                model.maxRecordTime = 60;
                            else if([maxRecordTm isEqualToString:@"2 Min"])
                                model.maxRecordTime = 120;
                            else //30 sec
                                model.maxRecordTime = 30;
                        }
                        else
                            model.maxRecordTime = [maxRecordTm integerValue];
                    }
                    //VBEnable
                    NSNumber *vbEnbl =  customDic[VB_ENABLE]?customDic[VB_ENABLE]:customDic[@"VB_ENABLE"];
                    if(vbEnbl != nil)
                        model.vbEnabled = [vbEnbl boolValue];
                    
                    //Sharelocation
                    NSNumber *disLoc = customDic[DISPLAY_LOCATION]?customDic[DISPLAY_LOCATION]:customDic[@"DISPLAY_LOCATION"];
                    
                    if(disLoc != nil)
                        model.displayLocation = [disLoc boolValue];
                    //model.recievedDisplayLocation = [disLoc boolValue];
                    
                    //ShowFBFriend: Need to verify the default value of showFBFriend.
                    model.showFBFriend = [customDic valueForKey:kShowFBFriend]?[[customDic valueForKey:kShowFBFriend]boolValue]:TRUE;
                    
                    //ShowTwitterFriend: Need to verify the default value of showTwitterFriend.
                    model.showTwitterFriend = customDic[kShowTwitterFriend]?[customDic[kShowTwitterFriend]boolValue ]:TRUE;
                    
                    // model.recievedStorageLocation = customDic[kStorageLocation]?customDic[kStorageLocation]:@"Device Cache";
                    model.storageLocation = customDic[kStorageLocation]?customDic[kStorageLocation]:@"Device Cache";
                    
                    //setting default values.
                    model.defaultRecordMode = customDic[kDefaultRecordMode]?customDic[kDefaultRecordMode]:@"Release to send";
                    
                    //setting default values.
                    model.defaultVoiceMode = customDic[kDefaultVoiceMode]?customDic[kDefaultVoiceMode]:@"Speaker";
                    
                    //Get the carrier information
                    id carriedInfo = customDic[kCarrierInfo];
                    if(carriedInfo && carriedInfo != nil) {
                        NSData *carrierData = [carriedInfo dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *error = nil;
                        NSMutableDictionary *carrierInfoList = [NSJSONSerialization JSONObjectWithData:carrierData options:0 error:&error];
                        if(carrierInfoList && [[carrierInfoList allKeys]count]) {
                            for(id phoneNumber in carrierInfoList) {
                                
                                NSString *phoneNumberString = phoneNumber;
                                if (![phoneNumber isKindOfClass:[NSString class]]) {
                                    phoneNumberString = [NSString stringWithFormat:@"%@",phoneNumber];
                                }
                                // KLog(@"Carrier info details =%@", [carrierInfoList objectForKey:phoneNumber]);
                                CarrierInfo *carrierInfoObj = [[CarrierInfo alloc]initWithPhoneNumber:phoneNumberString withCarrierDetails:[carrierInfoList objectForKey:phoneNumber]];
                                [carrierList addObject:carrierInfoObj];
                            }
                            
                            for (CarrierInfo *carrierInfo in carrierList) {
                                if(carrierInfo.shouldUpdateToServer)
                                    model.shouldUpdateToServer = YES;
                                break;
                            }
                        }
                        model.carrierDetails = carriedInfo;
                    }
                    
                    //Get the carrier information
                    id numberInfo = customDic[kNumberInfo];
                    if(numberInfo && numberInfo != nil) {
                        NSData *numberData = [numberInfo dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *error = nil;
                        NSMutableDictionary *numberInfoList = [NSJSONSerialization JSONObjectWithData:numberData options:0 error:&error];
                        if(numberInfoList && [[numberInfoList allKeys]count]) {
                            for(id phoneNumber in numberInfoList) {
                                
                                NSString *phoneNumberString = phoneNumber;
                                if (![phoneNumber isKindOfClass:[NSString class]]) {
                                    phoneNumberString = [NSString stringWithFormat:@"%@",phoneNumber];
                                }
                                NumberInfo *numberInfoObj = [[NumberInfo alloc]initWithPhoneNumber:phoneNumberString withNumberDetails:[numberInfoList objectForKey:phoneNumber]];
                                [numberList addObject:numberInfoObj];
                            }
                            
                            for (NumberInfo *numberInfo in numberList) {
                                if(numberInfo.shouldUpdateToServer)
                                    model.shouldUpdateToServer = YES;
                                break;
                            }
                        }
                        model.numberDetails = numberInfo;
                    }
                    
                }
                model.carrierInfoList = carrierList;
                model.numberInfoList = numberList;
            }
        }
    }
    
    //by Vinoth
    // NSString *tempUSSDErrStr;// = @"network_not_Supported";
    // NSString *tempUSSDPhone = @"{\"network\":\"Vodafone Phone\",\"make_call\":true,\"chk_ph\":\"*282#\",\"chk_all\":\"**67*#9742255719\",\"chk_busy\":\"*#67#\",\"chk_noreply\":\"*#61#\",\"chk_off\":\"*#62#\",\"acti_all\":\"\",\"acti_busy\":\"**67*#9742255719\",\"acti_noreply\":\"**61*9742255719#\",\"acti_off\":\"**62*9742255719#\",\"deacti_all\":\"#004#\",\"deacti_busy\":\"#67#\",\"deacti_noreply\":\"#61#\",\"deacti_off\":\"#62#\"}";
    // NSString *tempUSSDSim;// = @"{\"network\":\"Vodafone SIM\",\"chk_ph\":\"*282#\",\"chk_all\":\"\",\"chk_busy\":\"*#67#\",\"chk_noreply\":\"*#61#\",\"chk_off\":\"*#62#\",\"acti_all\":\"**67*#9742255719\",\"acti_busy\":\"**67*#9742255719\",\"acti_noreply\":\"**61*9742255719#\",\"acti_off\":\"**62*9742255719#\",\"deacti_all\":\"#005#\",\"deacti_busy\":\"#67#\",\"deacti_noreply\":\"#61#\",\"deacti_off\":\"#62#\"}";
    
    NSString *tempUSSDPhone = [responseDic valueForKey:API_USSD_PH];
    NSString *tempUSSDSim = [responseDic valueForKey:API_USSD_SIM];
    //DC MEMLEAK MAY 25 2016
    // NSString *tempUSSDErrStr = [responseDic valueForKey:API_USSD_ERR];
    
    //KLog(@"🎯🎯🎯🎯🎯\nResponseDic %@\n🎯🎯🎯🎯🎯🎯",responseDic);
    
    if (tempUSSDPhone!=nil && [tempUSSDPhone rangeOfString:@"\"skip\":\"y\""].location == NSNotFound) {
        //do nothing since skip:y not found
    } else {
        tempUSSDPhone = @"";
    }
    
    if (tempUSSDSim!=nil && [tempUSSDSim rangeOfString:@"\"skip\":\"y\""].location == NSNotFound) {
        //do nothing since skip:y not found
    } else {
        tempUSSDSim = @"";
    }
    
    if(tempUSSDPhone != nil && [tempUSSDPhone length]>0)
    {
        [self parseCustomUSSDPhone:tempUSSDPhone];
    }
    if(tempUSSDSim != nil && [tempUSSDSim length]>0)
    {
        [self parseCustomUSSDSim:tempUSSDSim];
    }
    
    BOOL isUSSDofPhoneSimMatches = NO;
    BOOL phone_acti_all_exists = NO;
    BOOL sim_acti_all_exists = NO;
    
    NSString *acti_all_sim = [self.customUSSDSim objectForKey:@"acti_all"];
    NSString *acti_all_ph = [self.customUSSDPhone objectForKey:@"acti_all"];
    
    NSString *network_sim = [self.customUSSDSim objectForKey:@"network"];
    NSString *network_phone = [self.customUSSDPhone objectForKey:@"network"];
    
    isUSSDofPhoneSimMatches = [acti_all_ph isEqualToString:acti_all_sim];
    phone_acti_all_exists = acti_all_ph.length>0;
    sim_acti_all_exists = acti_all_sim.length>0;
    
    BOOL make_call_sim = (BOOL)[self.customUSSDSim objectForKey:@"make_call"];
    //BOOL make_call_ph = (BOOL)[self.customUSSDPhone objectForKey:@"make_call"];
    
    model.isNetworkSupportedMissedCall = NO;
    NSString *mccmnc = [[ConfigurationReader sharedConfgReaderObj] getCountryMCCMNC];
    
    if(mccmnc != nil && [mccmnc length] >0)
    {
        //do nothing if SIM is there
    }
    else
    {
        if(tempUSSDPhone != nil && [tempUSSDPhone length]>0)
        {
            if (phone_acti_all_exists) {
                [self phonePriorityWithModel:model];
                [Setting sharedSetting].data = model;
                return model;
            }
            else
            {
                [model updateOnlyNetworkFromUSSDPhone:network_phone];
                model.isNetworkSupportedMissedCall = NO;
                [Setting sharedSetting].data = model;
                return model;
            }
        }
        else
        {
            NSMutableDictionary *dic = [Common getSIMInfo];
            if(dic != nil && [dic count] >0)
            {
                NSString *counCode = [dic valueForKey:@"country_sim_carrier"];
                [model updateOnlyNetworkFromUSSDPhone:counCode];
            }
            
            model.isNetworkSupportedMissedCall = NO;
            [Setting sharedSetting].data = model;
            return model;
        }
    }
    
    if((tempUSSDSim != nil && [tempUSSDSim length]>0) && (tempUSSDPhone != nil && [tempUSSDPhone length]>0))
    {
        if (phone_acti_all_exists && sim_acti_all_exists) {
            if(isUSSDofPhoneSimMatches)
            {
                [self simPriorityWithModel:model];
                [Setting sharedSetting].data = model;
                return model;
            }
            else
            {
                if (make_call_sim) {
                    [self simPriorityWithModel:model];
                    [Setting sharedSetting].data = model;
                    return model;
                }
                else
                {
                    [self phonePriorityWithModel:model];
                    
                    [Setting sharedSetting].data = model;
                    return model;
                }
            }
        }
        else if (sim_acti_all_exists) {
            if (make_call_sim) {
                [self simPriorityWithModel:model];
                [Setting sharedSetting].data = model;
                return model;
            }
            else
            {
                [model updateOnlyNetworkFromUSSDSim:network_sim];
                model.isNetworkSupportedMissedCall = NO;
                [Setting sharedSetting].data = model;
                return model;
            }
        }
        else if (phone_acti_all_exists) {
            [self phonePriorityWithModel:model];
            [Setting sharedSetting].data = model;
            return model;
        }
        else
        {
            [model updateOnlyNetworkFromUSSDPhone:network_phone];
            model.isNetworkSupportedMissedCall = NO;
            [Setting sharedSetting].data = model;
            return model;
        }
    }
    
    if(tempUSSDSim != nil && [tempUSSDSim length]>0)
    {
        if (make_call_sim) {
            [self simPriorityWithModel:model];
            [Setting sharedSetting].data = model;
            return model;
        }
        else
        {
            [model updateOnlyNetworkFromUSSDSim:network_sim];
            model.isNetworkSupportedMissedCall = NO;
            [Setting sharedSetting].data = model;
            return model;
        }
    }
    
    if(tempUSSDPhone != nil && [tempUSSDPhone length]>0)
    {
        if (phone_acti_all_exists) {
            [self phonePriorityWithModel:model];
            [Setting sharedSetting].data = model;
            return model;
        }
        else
        {
            [model updateOnlyNetworkFromUSSDPhone:network_phone];
            model.isNetworkSupportedMissedCall = NO;
            [Setting sharedSetting].data = model;
            return model;
        }
    }
    
    if((tempUSSDSim == nil && [tempUSSDSim length]<=0) && (tempUSSDPhone == nil && [tempUSSDPhone length]<=0))
    {
        NSMutableDictionary *dic = [Common getSIMInfo];
        if(dic != nil && [dic count] >0)
        {
            NSString *counCode = [dic valueForKey:@"country_sim_carrier"];
            [model updateOnlyNetworkFromUSSDPhone:counCode];
        }
        model.isNetworkSupportedMissedCall = NO;
        [Setting sharedSetting].data = model;
        return model;
    }
    
    [Setting sharedSetting].data = model;
    return model;
}

- (void)phonePriorityWithModel:(SettingModel *)model
{
    if(self.customUSSDPhone != nil && [self.customUSSDPhone count]>0)
    {
        model.ivUSSDDictPhone = self.customUSSDPhone;
        [model updateCallNumbersFromUSSDPhone];
        model.isNetworkSupportedMissedCall = YES;
    }
    else
    {
        model.isNetworkSupportedMissedCall = NO;
    }
    model.loginMatchesInstaVoiceNumber = NO;
}

- (void)simPriorityWithModel:(SettingModel *)model
{
    if(self.customUSSDSim != nil && [self.customUSSDSim count]>0)
    {
        model.ivUSSDDictSim = self.customUSSDSim;
        [model updateCallNumbersFromUSSDSim];
        model.isNetworkSupportedMissedCall = YES;
    }
    else
    {
        model.isNetworkSupportedMissedCall = NO;
    }
    model.loginMatchesInstaVoiceNumber = YES;
}

-(void)parseCustomUSSDSim:(NSString *)tempUSSDSim
{
    NSData *data = [tempUSSDSim dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    self.customUSSDSim = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
}

-(void)parseCustomUSSDPhone:(NSString *)tempUSSDPhone
{
    NSData *data = [tempUSSDPhone dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    self.customUSSDPhone = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
}

-(BOOL)isVoicemailSupported:(NSMutableArray*)vmInfoList {
    
    BOOL result = FALSE;
    if([vmInfoList count]) {
        for(VoiceMailInfo* vmInfo in vmInfoList) {
            result = vmInfo.countryVoicemailSupport;
            if(result) break;
        }
    }
    
    return result;
}

@end
