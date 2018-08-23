//
//  ConversationApi.h
//  InstaVoice
//
//  Created by EninovUser on 23/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#ifndef InstaVoice_ConversationApi_h
#define InstaVoice_ConversationApi_h


/**********************************************
 *  NAME OF API THAT ARE USED IN THIS FILE    *
 *                                            *
 *  6.2  send Voice                           *
 *  6.3  send text                            *
 *  6.4  fetch msg                            *
 *  6.17 increment msg count                  *
 *  6.24 post IV msg on external App          *
 *  6.26 delete an existing IV or Vobolo msg  *
 *  6.32 fetch Vobolo post by a user          *
 *  6.33 forward and Existing IV or Vobolo    *
 *  6.36 IV and Vobolo msg Activity           *
 *  6.37 fetch IV msg Activities              *
 *                                            *
 **********************************************/

// Send Voice message Request parameter

#define API_TYPE                            @"type"
#define API_FRIEND_FB_USER_IDS              @"friend_fb_user_ids"
#define API_MSG_TYPE                        @"type"
#define API_MSG_CONTENT_TYPE                @"msg_type"
#define API_MSG_FORMAT                      @"msg_format"
#define API_CONTACT_IDS                     @"contact_ids"
#define API_CONTACT                         @"contact"
#define API_FETCH_MSGS                      @"fetch_msgs"
#define API_FETCH_AFTER_MSGS_ID             @"fetch_after_msgs_id"
#define API_FETCH_MAX_ROWS                  @"fetch_max_rows"
#define API_FROM_LOCATION                   @"from_location"
#define API_LOGITUDE                        @"longitude"
#define API_LATITUDE                        @"latitude"
#define API_LOCATION_NM                     @"location_nm"
#define API_LOCALE                          @"locale"
#define API_GUID                            @"guid"
#define API_SUB_SER_ID                      @"sub_ser_id"
#define API_DEF_SER_ID                      @"def_ser_id"
#define API_CONTACT_ID                      @"contact_id"
#define API_FETCH_MSG_ACTIVITIES            @"fetch_msg_activities"
#define API_FETCH_AFTER_MSG_ACTIVITY_ID     @"fetch_after_msg_activity_id"
#define API_USER_SECURE_KEY                 @"user_secure_key"
#define API_CONTACT_IDS_CHANGED             @"contact_ids_changed"

// Send Voice message Response parameter

#define API_LAST_FETCHED_MSG_ID             @"last_fetched_msg_id"
#define API_MSGS                            @"msgs"
#define API_MSG_ID                          @"msg_id"
#define API_IV_MSG_ID                       @"iv_msg_id"
#define API_MSG_DT                          @"msg_dt"
#define API_SUBTYPE                         @"msg_subtype"
#define API_SOURCE_APP_TYPE                 @"source_app_type"
#define API_MSG_FLOW                        @"msg_flow"
#define API_FROM_IV_USER_ID                 @"from_iv_user_id"
#define API_FROM_PHONE_NUM                  @"from_phone_num"
#define API_SENDER_ID                       @"sender_id"
#define API_CONTENT_TYPE                    @"msg_content_type"
#define API_IS_MSG_BASE64                   @"is_msg_base64"
#define API_MSG_CONTENT                     @"msg_content"
#define API_ANNOTATION                      @"annotation"
#define API_MEDIA_FORMAT                    @"media_format"
#define API_DURATION                        @"duration"
#define API_MSG_READ_CNT                    @"msg_read_cnt"
#define API_MSG_DOWNLOAD_CNT                @"msg_download_cnt"
#define API_INVITE_URL                      @"invite_url"
#define API_LINKED_OPR                      @"linked_opr"
#define API_LINKED_MSG_TYPE                 @"linked_msg_type"
#define API_LINKED_MSG_ID                   @"linked_msg_id"
#define API_FRIEND_FB_USER_IDS              @"friend_fb_user_ids"
#define API_SENDER_CONTACT_ID               @"sender_contact_id"
#define API_INVALID_CONTACT_IDS             @"invalid_contact_ids"
#define API_LAST_FETCH_MSG_ACTIVITY_ID      @"last_fetched_msg_activity_id"
#define API_MSG_ACTIVITIES                  @"msg_activities"
#define API_BLOG_MSGS                       @"blog_msgs"
#define API_NON_IV                          @"noniv_enabled"

#define  API_STATUS                         @"status"
#define  API_FROM_PHONE                     @"from_phone"
#define  API_TO_PHONE                       @"to_phone"
#define  API_CALL_AT                        @"call_at"
#define  API_PN_DELAY                       @"pn_delay"

//send text message Request Parameter

#define API_MSG_TEXT                        @"msg_text"

// Fetch Messages Request Parameter

#define API_FETCH_MSG_ID_RELATED            @"fetch_msg_id_related"
#define API_SENDER_CONTACT_IDS              @"sender_contact_ids"
#define API_RECIPIENT_CONTACT_IDS           @"recipient_contact_ids"
#define API_FETCH_OPPONENT_CONTACTIDS       @"fetch_opponent_contactids"

// Increment Message Read Count Request Parameter

#define API_MSG_IDS                         @"msg_ids"
#define API_MSG_IDS_TYPE                    @"msg_ids_type"

// "post_on_wall" Request Parameter

#define API_APP                             @"app"

// "fetch_iv_user_vobolos" Request Parameter

#define API_USER_ID                         @"user_id"
#define API_AFTER_BLOG_ID                   @"after_blog_id"
#define API_COUNT_LIMIT                     @"count_limit"

// "fetch_iv_user_vobolos" Response Parameter

#define API_BLOG_LIST                       @"blog_list"
#define API_BLOGGER_ID                      @"blogger_id"
#define API_BLOG_ID                         @"blog_id"
#define API_BLOG_TYPE                       @"blog_type"
#define API_BLOG_DURATION                   @"blog_duration"
#define API_BLOG_DATE                       @"blog_date"
#define API_BLOG_DATE_LONG                  @"blog_date_long"
#define API_IV_BLOG_HEARD_CNT               @"iv_blog_heard_cnt"
#define API_BLOG_WEB_DATA_URI               @"blog_web_data_URI"

// "msg_activity" Request Parameter

#define API_ACTIVITY                        @"activity"
#define API_LIKE                            @"like"
#define API_DOWNLOAD                        @"download"
#define API_LISTEN                          @"listen"
#define API_UNLIKE                          @"unlike"
#define API_FORWORD                         @"forward"
#define API_DELETE                          @"delete"
#define API_REASON                          @"reason"
#define API_MISSEDCALL_REASON               @"misscall_reason"
#define API_REVOKE                          @"REVOKE"
#define API_FBP                             @"fbp"
#define API_TWP                             @"twp"
#define API_VBP                             @"vbp"
#define API_AFTER_MSG_ACTIVTY_ID            @"fetch_after_msg_activity_id"
#define API_MC_ERROR                        @"mc_err"
#define API_MC_OK                           @"mc_ok"

//APP type

#define API_FB                              @"fb"
#define API_TW                              @"tw"
#define API_FBTW                            @"fbtw"
#define API_VB                              @"vb"


// "fetch_msg_activities" Response Parameter

#define API_MSG_ACTIVITIES                  @"msg_activities"
#define API_MSG_ACTIVITY_ID                 @"msg_activity_id"
#define API_CREATION_DATE                   @"creation_date"
#define API_BY_IV_USER_ID                   @"by_iv_user_id"
#define API_ACTIVITY_TYPE                   @"activity_type"
#define API_FROM_USER_DEVICE_ID             @"from_user_device_id"
#define API_SOURCE_APP_TYPE                 @"source_app_type"
#define API_VSMS_LIMIT                      @"vsms_limits"
#define API_LIMIT                           @"limit"
#define API_USER                            @"users"
#define API_PHONE                           @"phone"
#define API_BAL                             @"bal"

// "fetch_vobolos" response param

#define API_LAST_BLOGID                     @"last_blog_id"
#define API_BLOGGER_DISPLAY_NAME            @"blogger_display_name"
#define API_FROM_BLOGGER_ID                 @"from_blogger_id"
#define API_PROFILE_PIC_NAME                @"profilePictureName"


//Messages States
#define API_UNSENT                          @"UNSENT"
#define API_NETUNAVAILABLE                  @"API_NETUNAVAILABLE"
#define API_INPROGRESS                      @"INPROGRESS"
#define API_DELIVERED                       @"DELIVERED"
#define API_WITHDRAWN                       @"W"

#define API_NOT_DOWNLOADED                  @"NOT_DOWNLOADED"
#define API_DOWNLOAD_INPROGRESS             @"DOWNLOAD_INPROGRESS"
#define API_DOWNLOADED                      @"DOWNLOADED"

#define API_MSG_REQ_SENT                    @"REQSENT"
#define API_MSG_PALYING                     @"PLAYING"

#ifdef OPUS_ENABLED
#define AUDIO_FORMAT                @"opus"
#else
#define AUDIO_FORMAT                @"a-law"
#endif

#endif
