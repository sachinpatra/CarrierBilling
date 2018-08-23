//
//  SettingsApi.h
//  InstaVoice
//
//  Created by EninovUser on 23/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#ifndef InstaVoice_SettingsApi_h
#define InstaVoice_SettingsApi_h

/**********************************************
 *  NAME OF API THAT ARE USED IN THIS FILE    *
 *  6.34 update user settings                 *
 *  6.35 fetch user settings                  *
 *                                            *
 **********************************************/


// update user settings request Parameter

#define API_FB_POST_ENABLED                 @"fb_post_enabled"
#define API_TW_POST_ENABLED                 @"tw_post_enabled"
#define API_FB_CONNECTED                    @"fb_connected"
#define API_TW_CONNECTED                    @"tw_connected"
#define API_CUSTOM_SETTINGS                 @"custom_settings"


#define API_SEND_EMAIL_FOR_IV               @"send_email_for_iv"
#define API_SEND_SMS_FOR_VSMS               @"send_sms_for_vsms"
#define API_SEND_EMAIL_FOR_VSMS             @"send_email_for_vsms"
#define API_SEND_SMS_FOR_VB                 @"send_sms_for_vb"
#define API_SEND_EMAIL_FOR_VB               @"send_email_for_vb"


// disconnect from tw n fb

#define API_APP                             @"app"

// fetch user settings request Parameter

#define FB_CONNECT_URL                  @"fb_connect_url"
#define TW_CONNECT_URL                  @"tw_connect_url"
#define LAST_FETCHED_MSG_ID             @"last_fetched_msg_id"
#define LAST_FETCHED_CONTACT_TRNO       @"last_fetched_contact_trno"
#define LAST_FETCHED_MSG_ACTIVITY_ID    @"last_fetched_msg_activity_id"
#define LAST_FETCHED_PROFILE_TRNO       @"last_fetched_profile_trno"


#endif
