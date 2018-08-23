//
//  TableColumns.h
//  InstaVoice
//
//  Created by Eninov on 28/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#ifndef InstaVoice_TableColumns_h
#define InstaVoice_TableColumns_h

/************************   Contact Table  ***********************/

#define CONTACT_TABLE             @"ContactTable"
#define CONTACT_TABLE_TYPE        1

#define CONTACT_ID                @"CONTACT_ID"   //Unique identity for each contacts used in both contact table and contact detail table
#define CONTACT_NAME              @"CONTACT_NAME"
#define REMOVE_FLAG               @"REMOVE_FLAG"          //
#define IS_IV                     @"IS_IV"
#define CONTACT_PIC               @"CONTACT_PIC"
#define LOCAL_SYNC_TIME           @"LOCAL_SYNC_TIME"
#define IS_INVITED                @"IS_INVITED"
#define IS_NEW_JOINEE             @"IS_NEW_JOINEE"
#define CONTACT_PIC_URI           @"CONTACT_PIC_URI"
#define PIC_DOWNLOAD_STATE        @"PIC_DOWNLOAD_STATE"


// These constants are not the columns, used for PIC_DOWNLOAD_STATE values
#define IMG_NOT_DOWNLOADED        @"NOT_DOWNLOADED"
#define IMG_DOWNLOAD_INPROGRESS   @"DOWNLOAD_INPROGRESS"
#define IMG_DOWNLOADED            @"DOWNLOADED"


/************************  Contact Detail Table *************************/

#define CONTACT_DETAIL_TABLE      @"ContactDetailTable"
#define CONTACT_DETAIL_TABLE_TYPE      2

#define EMAIL_DATA                @"EMAIL_DATA"
#define PHONE_DATA                @"PHONE_DATA"
#define CONTACT_DATA_ID           @"CONTACT_DATA_ID"      //Unique identity for each data field
#define CONTACT_DATA_TYPE         @"CONTACT_DATA_TYPE"    //Type of data field either p or e
#define CONTACT_DATASUBTYPE       @"CONTACT_DATASUBTYPE"  //Sub type of datafield(home,office)
#define CONTACT_DATA_VALUE        @"CONTACT_DATA_VALUE"   //Data field value either email or ph.no.
#define INDEX   @"index"

#define LOCAL_SYNC                @"LOCAL_SYNC"
#define SERVER_SYNC               @"SERVER_SYNC"          //

#define IV_USER_ID                @"IV_USER_ID"
#define IV_JOINED_TIME            @"IV_JOINED_TIME"       //
#define VSMS_USER                 @"VSMS_USER"            //
#define BLOCKED_FLAG              @"BLOCKED_FLAG"         //

#define CONTACT_LIST              @"CONTACT_LIST"



/**************************  Message Table **************************/

#define MESSAGE_TABLE       @"MessageTable"
#define MESSAGE_TABLE_TYPE  3

#define NATIVE_CONTACT_ID   @"NATIVE_CONTACT_ID"
#define LOGGEDIN_USER_ID    @"LOGGEDIN_USER_ID"
#define MSG_ID              @"MSG_ID"
#define MSG_GUID            @"MSG_GUID"
#define MSG_DATE            @"MSG_DATE"
#define SOURCE_APP_TYPE     @"SOURCE_APP_TYPE"
#define MSG_FLOW            @"MSG_FLOW"
#define MSG_TYPE            @"MSG_TYPE"
#define MSG_SUB_TYPE        @"MSG_SUB_TYPE"
#define MSG_CONTENT_TYPE    @"MSG_CONTENT_TYPE"
#define INSUFFICIENT_CREDITS @"insufficient_credits"
#define MSG_STATE           @"MSG_STATE"

#define REMOTE_USER_IV_ID   @"REMOTE_USER_IV_ID"
#define REMOTE_USER_TYPE    @"REMOTE_USER_TYPE"
#define FROM_USER_ID        @"FROM_USER_ID" // This can be email , phone num or fb_id

#define VB_IMG              @"VB_IMG"
#define FOLLOWER_COUNT      @"FOLLOWER_COUNT"
#define BLOGGER_ID          @"BLOGGER_ID"
#define STATE               @"STATE"
//dp
#define NONIV_ENABLED       @"NONIV_ENABLED"
#define MSG_BASE64          @"MSG_BASE64"
#define MSG_CONTENT         @"MSG_CONTENT"

#define ANNOTATION          @"ANNOTATION"
#define MSG_TRANS_TEXT      ANNOTATION
#define MEDIA_FORMAT        @"MEDIA_FORMAT"
#define DURATION            @"DURATION"
#define MSG_PLAY_DURATION   @"MSG_PLAY_DURATION"
#define MSG_READ_CNT        @"MSG_READ_CNT"
#define MSG_DOWNLOAD_CNT    @"MSG_DOWNLOAD_CNT"
#define MSG_SIZE_LONG       @"MSG_SIZE"
#define MSG_TRANS_RATING    MSG_SIZE_LONG
#define MSG_LOCAL_PATH      @"MSG_LOCAL_PATH"
#define LATITUDE            @"LATITUDE"
#define LONGITUTE           @"LONGITUTE"
#define LOCATION_NAME       @"LOCATION_NAME"
#define LOCALE              @"LOCALE"

#define VOICE_READ_CNT      @"VOICE_READ_CNT"
#define LINKED_OPR          @"LINKED_OPR"
#define LINKED_MSG_TYPE     @"LINKED_MSG_TYPE"
#define LINKED_MSG_ID       @"LINKED_MSG_ID"
#define MSG_LIKED           @"MSG_LIKED"
#define MSG_LISTENED        @"MSG_LISTENED"
#define MSG_FB_POST         @"MSG_FB_POST"
#define MSG_TW_POST         @"MSG_TW_POST"
#define MSG_VB_POST         @"MSG_VB_POST"
#define MSG_FORWARD         @"MSG_FORWARD"
#define CONVERSATION_TYPE   @"CONVERSATION_TYPE"
#define POST_TYPE           @"POST_TYPE"

#define REMOTE_USER_NAME    @"REMOTE_USER_NAME"
#define REMOTE_USER_PIC     @"REMOTE_USER_PIC"
#define REMOTE_USER_INFO    @"REMOTE_USER_INFO"
#define CONTACT_IDS         @"CONTACT_IDS"
#define DOWNLOAD_TIME       @"DOWNLOAD_TIME"
#define CROP_REMOTE_USER_PIC    @"CROP_REMOTE_USER_PIC"
#define MSG_TRANS_STATUS        CROP_REMOTE_USER_PIC

#define UNREAD_MSG_COUNT    @"UNREAD_MSG_COUNT"
#define VOICE_TO_TEXT       @"VOICE_TO_TEXT"
#define IS_VOICE_TO_TEXT_HIDDEN     @"IS_VOICE_TO_TEXT_HIDDEN"
/************************** States Table ****************************/

#define STATES_TABLE              @"StatesTable"
#define STATES_TABLE_TYPE         4

#define STATE_ID                  @"STATE_ID"
#define STATE_NAME                @"STATE_NAME"
#define COUNTRY_CODE              @"COUNTRY_CODE"


/************************* Support Contacts Table ********************/

#define SUPPORT_CONTACT_TABLE     @"SupportContacTTable"

#define SUPPORT_CONTACT_TABLE_TYPE 5

#define SUPPORT_CATEGORY          @"SUPPORT_CATEGORY"
#define CONTACT_TYPE              @"CONTACT_TYPE"
#define SUPPORT_CONTACT_ID        @"SUPPORT_CONTACT_ID"
#define SUPPORT_CAT_ID            @"SUPPORT_CAT_ID"


#define SUPPORT_NAME            @"SUPPORT_NAME"
#define SUPPORT_IV_ID           @"SUPPORT_IV_ID"
#define SUPPORT_DATA_VALUE      @"SUPPORT_DATA_VALUE"
#define SUPPORT_DATA_TYPE       @"SUPPORT_DATA_TYPE"
#define SUPPORT_PIC_URI         @"SUPPORT_PIC_URI"
#define SUPPORT_PIC_PATH        @"SUPPORT_PIC_PATH"



/************************ Facebook Table *****************************/

#define FACEBOOK_TABLE            @"FacebookTable"
#define FACEBOOK_TABLE_TYPE       6

#define FACEBOOK_ID               @"FACEBOOK_ID"
#define FB_IV_ID                  @"FB_IV_ID"
#define FACEBOOK_NAME             @"FACEBOOK_NAME"
#define FACEBOOK_PIC_URL          @"FACEBOOK_PIC_URL"
#define FACEBOOK_LOCAL_PIC_PATH   @"FACEBOOK_LOCAL_PIC_PATH"
#define CURRENT_TIME              @"CURRENT_TIME"

/************************ MyProfile Tbale ****************************/

#define MYPROFILE_TABLE           @"MyProfileTable"
#define MYPROFILE_TABLE_TYPE      7

#define IV_USER_ID                @"IV_USER_ID"
#define LOGIN_ID                  @"LOGIN_ID"
//#define USER_ID                   @"USER_ID"
#define COUNTRY_NAME              @"COUNTRY_NAME"
#define COUNTRY_CODE              @"COUNTRY_CODE"
#define CITY_NAME                 @"CITY_NAME"
#define STATE_NAME                @"STATE_NAME"
#define GENDER                    @"GENDER"
#define DOB                       @"DOB"
#define SCREEN_NAME               @"SCREEN_NAME"
#define PROFILE_PIC_PATH          @"PROFILE_PIC_PATH"
#define CROP_PROFILE_PIC_PATH     @"CROP_PROFILE_PIC_PATH"
#define LOCAL_PIC_PATH            @"LOCAL_PIC_PATH"
#define PIC_TYPE                  @"PIC_TYPE"
#define PROFILE_SYNC_FLAG         @"PROFILE_SYNC_FLAG"
#define PIC_SYNC_FLAG             @"PIC_SYNC_FLAG"


/************************ Settings Table *****************************/

#define SETTINGS_TABLE          @"SettingsTable"
#define SETTINGS_TABLE_TYPE     8


#define IV_USER_ID              @"IV_USER_ID"
#define SYNCFLAG                @"SYNCFLAG"

#define MAX_RECORD_TIME         @"recording_time" //@"MAX_RECORD_TIME" //Changed by Nivedita, Date: 16th Dec - As per conversation with Ajay and Andriod team. But to support old clients, we need to compare "MAX_RECORD_TIME" also.

#define FB_CONNECTED            @"FB_CONNECTED"
#define TW_CONNECTED            @"TW_CONNECTED"
#define VB_ENABLE               @"vb_enable" //@"VB_ENABLE" //Changed by Nivedita, Date: 16th Dec - As per conversation with Ajay and Andriod team. But to support old clients, we need to compare "VB_ENABLE" also.
#define VOICEMAIL_INFO         @"voicemails_info" //Represents the vocie mail information.

#define FB_POST_ENABLED         @"FB_POST_ENABLED"
#define TW_POST_ENABLED         @"TW_POST_ENABLED"
#define DISPLAY_LOCATION        @"share_location"//@"DISPLAY_LOCATION" //Changed by Nivedita, Date: 16th Dec - As per conversation with Ajay and Andriod team. But to support old clients, we need to compare "DISPLAY_LOCATION" also.

//Latest custom keys added as per the conversation with Ajay : Date: 16th Dec
#define kDefaultRecordMode      @"default_record_mode"
#define kDefaultVoiceMode       @"default_voice_mode"
#define kShareLocation          @"share_location"
#define kCarrierInfo            @"carrier" //Key responsible for holding the carrier details, like country code, mccmnc_list, network_id, network_name etc. Please refer the JSON response for further keys.
#define kNumberInfo            @"ph_dtls" //Key responsible for holding the number details, like image name, title name. Please refer the JSON response for further keys.
#define kShowFBFriend         @"show_fb_frnd"
#define kShowTwitterFriend    @"show_tw_frnd"
#define kStorageLocation      @"storage_location"


#define kDefaultRecordModeDefaultValue @"Release to send"
#define kDefaultVoiceModeDefaultValue @"Speaker"
#define kShowFBFriendDefaultValue @"true"
#define kShowTWFriendDefaultValue @"true"

/*********************** Country Table ********************************/
#define COUNTRY_TABLE    @"CountryTable"
#define COUNTRY_TABLE_TYPE 9

#define COUNTRY_SIM_ISO      @"COUNTRY_SIM_ISO"
#define COUNTRY_ISD_CODE      @"COUNTRY_ISD_CODE"
#define COUNTRY_MIN_PHONE_LENGTH @"MIN_PHONE_LENGTH"
#define COUNTRY_MAX_PHONE_LENGTH @"MAX_PHONE_LENGTH"


/************************ BLOGGER TABLE ********************************/

#define BLOGGER_TABLE               @"BloggerTable"
#define BLOGGER_TABLE_TYPE          10

#define BLOGGER_TYPE                @"BLOGGER_TYPE"
#define BLOGGER_NAME                @"BLOGGER_NAME"
#define BLOGGER_PIC_URL             @"BLOGGER_PIC_URL"
#define BLOGGER_PIC_LOCAL_PATH      @"BLOGGER_PIC_LOCAL_PATH"
#define BLOGGER_FOLLOW_STATUS       @"BLOGGER_FOLLOW_STATUS"

/********************** BLOG TABLE ***************************/

#define BLOG_TABLE           @"BlogTable"
#define BLOG_TABLE_TYPE      11


#define BLOG_ID              @"BLOG_ID"
#define BLOG_TYPE            @"BLOG_TYPE"
#define BLOG_DURATION        @"BLOG_DURATION"
#define BLOG_DATE            @"BLOG_DATE"
#define BLOG_ANNOTATION      @"BLOG_ANNOTATION"
#define BLOG_HEARD_CNT       @"BLOG_HEARD_CNT"
#define BLOG_WEB_DATA_URI    @"BLOG_WEB_DATA_URI"

/************************* VSMS LIMIT TABLE ************************/

#define VSMS_LIMIT_TABLE             @"VsmsLimitTable"
#define VSMS_LIMIT_TABLE_TYPE        12

#define PHONE_NO                @"PHONE_NO"
#define BALANCE                 @"BALANCE"

//- MessageReadStatus is more meaningful for voice messages
typedef enum : NSInteger {
    MessageReadStatusSeen = -1,
    MessageReadStatusUnread = 0,
    MessageReadStatusRead = 1
} MessageReadStatus;
//

#endif
