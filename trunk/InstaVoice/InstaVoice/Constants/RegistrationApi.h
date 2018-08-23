//
//  RegistrationApi.h
//  InstaVoice
//
//  Created by Eninov on 22/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#ifndef InstaVoice_RegistrationApi_h
#define InstaVoice_RegistrationApi_h

/**********************************************
 *  NAME OF API THAT ARE USED IN THIS FILE    *
 *  6.1 reg_user or verify_user               *
 *  6.10 fetch states                         *
 *  6.11 fetch country                        *
 *  6.14 sign_in                              *
 *  6.15 generate new password                *
 *  6.16 re-generate validation code          *
 *  6.18 sign_out                             *
 *  6.19 set device info                      *
 *  6.21 validate change password             *
 *                                            *
 **********************************************/

// “reg_user” Command and Request Parameters

#define API_EMAIL_ID                            @"email_id"
#define API_PHONE_NUM                           @"phone_num"
#define API_PWD                                 @"pwd"
#define API_LOGIN_NAME                          @"login_name"
#define API_DEVICE_ID                           @"device_id"
#define API_PHONE_NUM_EDITED                    @"phone_num_edited"
#define API_OPR_INFO_EDITED                     @"opr_info_edited"
#define API_SIM_OPR_MCC_MNC                     @"sim_opr_mcc_mnc"
#define API_SIM_COUNTRY_ISO                     @"sim_country_iso"
#define API_SIM_SERIAL_NUM                      @"sim_serial_num"
#define API_SIM_OPR_NM                          @"sim_opr_nm"
#define API_SIM_NETWORK_OPR_MCC_MNC             @"sim_network_opr_mcc_mnc"
#define API_SIM_NETWORK_OPR_NM                  @"sim_network_opr_nm"
#define API_DEVICE_MAC_ADDR                     @"device_mac_addr"
#define API_IMEI_MEID_ESN                       @"imei_meid_esn"
#define API_DEVICE_MODEL                        @"device_model"
#define API_DEVICE_DENSITY                      @"device_density"
#define API_DEVICE_RESOLUTION                   @"device_resolution"

// “reg_user” Command and response Parameters

#define API_REG_SECURE_KEY                      @"reg_secure_key"
#define API_PNS_APP_ID                          @"pns_app_id"
#define API_DOCS_URL                            @"docs_url"
#define API_IV_SUPPORT_CONTACT_IDS              @"iv_support_contact_ids"
#define API_SEND_SMS_FOR_IV                     @"send_sms_for_iv"

// “verify_user” Command and Request Parameters

#define API_PIN                                 @"pin"
//Regular push token
#define API_CLOUD_SECURE_KEY                    @"cloud_secure_key"
//VOIP push token
#define API_VOIP_PUSH_TOKEN                     @"voip_cloud_secure_key"
#define SEND_PIN_BY                             @"send_pin_by"
#define OBD                                     @"obd"

// "verify_user” Command and Response Parameters

#define API_USER_SECURE_KEY                     @"user_secure_key"
#define API_IV_USER_ID                          @"iv_user_id"
#define API_LOGIN_ID                            @"login_id"
#define API_COUNTRY_ISD                         @"country_isd"
#define API_PHONE_LEN                           @"phone_len"
#define API_CALL_FWD_USSD                       @"call_fwd_ussd"
#define API_FB_CONNECT_URL                      @"fb_connect_url"
#define API_TW_CONNECT_URL                      @"tw_connect_url"
#define API_FB_CONNECTED                        @"fb_connected"
#define API_TW_CONNECTED                        @"tw_connected"
#define API_FB_POST_ENABLED                     @"fb_post_enabled"
#define API_TW_POST_ENABLED                     @"tw_post_enabled"
#define API_USER_MANUAL_ENABLED                 @"usr_manual_trans"
#define API_COUNTRY_MANUAL_ENABLED              @"country_manual_trans"
#define API_SEND_EMAIL_FOR_IV                   @"send_email_for_iv"
#define API_SEND_SMS_FOR_VSMS                   @"send_sms_for_vsms"
#define API_SEND_EMAIL_FOR_VSMS                 @"send_email_for_vsms"
#define API_SEND_SMS_FOR_VB                     @"send_sms_for_vb"
#define API_SEND_EMAIL_FOR_VB                   @"send_email_for_vb"
#define API_CUSTOM_SETTINGS                     @"custom_settings"
#define API_LAST_FETCHED_MSG_ID                 @"last_fetched_msg_id"
#define API_LAST_FETCHED_CONTACT_TRNO           @"last_fetched_contact_trno"
#define API_LAST_FETCHED_MSG_ACTIVITY_ID        @"last_fetched_msg_activity_id"
#define API_LAST_FETCHED_PROFILE_TRNO           @"last_fetched_profile_trno"

#define API_USSD_PH @"ussd_ph"
#define API_USSD_SIM @"ussd_sim"
#define API_USSD_ERR @"ussd_err"

// Fetch States of a Country request Parameter

#define API_COUNTRY_CODE                        @"country_code"
#define API_LOCALE                              @"locale"

// Fetch States of a Country Response Parameter

#define API_STATES                              @"state_list"
#define API_STATE_ID                            @"stateId"
#define API_STATE_NM                            @"stateName"


// sign_in Request Parameter

#define API_OS_BUILD_NUM                        @"os_build_num"
#define API_OS_KERNEL_VERSION                   @"os_kernel_version"

// sign_in Response Parameter

#define API_IV_SUPPORT_CONTACT_IDS              @"iv_support_contact_ids"
#define API_IS_PROFILE_PIC_SET                  @"is_profile_pic_set"
#define API_PROFILE_PIC_URI                     @"profile_pic_uri"
#define API_THUMBNAIL_PROFILE_PIC_URI           @"thumbnail_profile_pic_uri"
#define API_SCREEN_NAME                         @"screen_name"

#define API_SUPPORT_CATG                        @"support_catg"
#define API_SUPPORT_CATG_ID                     @"support_catg_id"
#define API_FEDDBACK_CATG                       @"feedback_catg"
#define API_FEDDBACK_CATG_ID                    @"feedback_catg_id"
#define API_SHOWAS_IVUSER                       @"show_as_iv_user"
#define API_SUPPORT_EMAIL                       @"email"
#define API_SUPPORT_PHONE                       @"phone"

#define API_VOIP_INFO                           @"voip_info"
#define API_USER_INFO                           @"user_info"
#define API_IP                                  @"ip"
#define API_PORT                                @"port"
//#define API_USER_ID                             @"user_id"


// disconnect from tw n fb

#define API_APP                             @"app"






#endif
