//
//  Macro.h
//  InstaVoice
//
//  Created by Eninov on 12/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>


#define SUCCESS                 0
#define FAILURE                 -1
#define VALUE500MB              50*1024*1024
#define DEVICE_WIDTH            [UIScreen mainScreen].bounds.size.width // 320
#define DEVICE_HEIGHT            [UIScreen mainScreen].bounds.size.height
#define NAVIGATION_HEIGHT_IOS6  44
#define NAVIGATION_HEIGHT_IOS7  60
#define AUDIO_MSG_TYPE @"a"
#define TEXT_MSG_TYPE @"t"

#define VOICEVIEW_MIN_WIDTH         144 //124                                              //points for 1 to 10 secs duration
#define VOICEVIEW_WIDTH_MULTIPLIER  (383.0/750.0)      //max width 343 pix for the device which has width of 750 pix
#define VOICEVIEW_MAX_WIDTH         DEVICE_WIDTH * VOICEVIEW_WIDTH_MULTIPLIER
#define VOICEVIEW_DELTA_WIDTH      ((VOICEVIEW_MAX_WIDTH - VOICEVIEW_MIN_WIDTH)/110) //points for one 1 sec duration

#define VOICEVIEW_WIDTH(_durationInSecs) \
(_durationInSecs <= 10)?VOICEVIEW_MIN_WIDTH:VOICEVIEW_MIN_WIDTH+((_durationInSecs - 10)*VOICEVIEW_DELTA_WIDTH)

#define OLD_USER_ID     @"OLD_USER_ID"
#define NEW_USER_ID     @"NEW_USER_ID"



//#define SERVICE_NAME    @"ContactsSyncService"
#define NET_TIME_OUT    @"Unable to connect to Server. Check your Internet connection"
#define MAX_TIME_ON_VARIFICATION_SCREEN     31 //120 //As per the latest requirement - OTP Page:OTP/Call me timer should be set to 30 seconds in all places - Date 23rd May, 2016 - Nivedita
//Macro for Contacts



#define REQUEST_DIC         @"REQUESTDIC"
#define FILE_PATH           @"FILEPATH"
#define FILE_NAME           @"FILENAME"
#define DEVICE_CONTACT_IDS  @"DEVICECONTACTIDS"
#define IS_LAST_CHUNK       @"ISLASTCHUNK"
#define IS_FIRST_CHUNK      @"ISFIRSTCHUNK"
#define NETWORK_RETRY       @"NETWORK_RETRY"
#define SYNC_STATE          @"SYNC_STATE"

/**************** Event Object************************/

#define EVENT_MODE          @"eventMode"
#define EVENT_TYPE          @"eventType"
#define EVENT_OBJECT        @"eventObject"
#define UI_EVENT            @"UIEVENT"
#define NET_EVENT           @"NETEVENT"

/**************** Registration/Login Constants *******************/

/******** UI elements **********/

/** Sign Up   **/
#define FORGOT_TYPE                   @"Forget"
#define REGISTER_TYPE                 @"Register"
#define MANAGE_USER_CONTACT_TYPE      @"ManageUserContact"
/**-- Menu Screen --**/

//#define FB_CONFIRMATION                 @"Connect to Facebook"
//#define FB_CONFIRMATION_DES             @"Connect InstaVoice to Facebook to see your Facebook friends and post to your Wall."
//#define MENU_CONVERSATION_SUB           @"Speak, Connect & Share with your friends"
//#define MENU_VOBOLO_SUB                 @"Share messages using Blogs"
//#define MENU_FRIENDS_SUB2               @"%ld friends on InstaVoice"
//#define MENU_NOTE_SUB                   @"Create a Voice Note"
//#define MENU_SETTING_SUB                @"Customize your InstaVoice experience"
#define MENU_FEEDBACK                   @"Suggestions"
#define SUPPORT_HELP                    @"Help"

/**-- Conversation Screen --**/

#define TEXT_TYPE                       @"t"
#define AUDIO_TYPE                      @"a"
#define IMAGE_TYPE                      @"i"
#define SENDER_TYPE                     @"s"
#define RECEIVER_TYPE                   @"r"
#define VOIP_TYPE                       @"voip"
#define VOIP_OUT                        @"voip_out"
#define SUBTYPE_GSM                     @"gsm"
#define MISSCALL_MSG                    @"1 Missed call."

/*
 #define LIKEMSG_ACTIVITY            @"0"
 #define SHAREMESSAGE_ACTIVITY       @"1"
 #define VOBOLO_ACTIVITY             @"2"
 #define FACEBOOK_ACTIVITY           @"3"
 #define TWITTER_ACTIVITY            @"4"
 #define DELETE_ACTIVITY             @"5"
 #define CALL_ACTIVITY               @"6"
 #define COPY_ACTIVITY               @"7"
 #define WITHDRAW_ACTIVITY           @"8"
 */

//
typedef enum : NSInteger {
    menuOptionLikeMessage,
    menuOptionSaveImage,
    menuOptionShareImage,
    menuOptionShareMessage,
    menuOptionPostOnVobolo,
    menuOptionPostOnFB,
    menuOptionPostOnTW,
    menuOptionDelete,
    menuOptionMakeCall,
    menuOptionCopy,
    menuOptionCopyNumber,
    menuOptionWithdraw
} SliderMenuOption ;

//temp**************************?

#pragma mark - MY PROFILE MACRO

#define FEMALE_TYPE                     @"f"
#define MALE_TYPE                       @"m"
//#define OTHERS_TYPE                     @"o"

/*-- New Chat Screen --*/

#define ALERT_SHARE_MSG                 @"ALERT_SHARE_MSG"

/********** constants for Login/Reg-Engine interface *********/

#define USER_ID                       @"userId"
#define USER_PWD                      @"password"
#define LOGIN_MODE                    @"loginMode"
#define PHONE_MODE                    @"tel"
#define EMAIL_MODE                    @"e"
//#define BOTH                          @"both"
#define DISPLAY_NAME                  @"display_name"
#define VERIFY_PIN                    @"verify_pin"


//Country List Constant

#define COUNTRY_SIM_MCC         @"country_sim_mcc"
#define COUNTRY_SIM_MNC         @"country_sim_mnc"
#define COUNTRY_SIM_CARRIER     @"country_sim_carrier"

#ifdef REACHME_APP
//ReachMe Type
#define REACHME_INTERNATIONAL   @"reachme_international"
#define REACHME_HOME            @"reachme_home"
#define REACHME_VOICEMAIL       @"reachme_voicemail"
#endif


/* CONATCTID    : NSString contains unique id for each record
 * CONATCTNAME  : NSString contains display name
 * PIC          : NSString contains profile pic name
 * IS_IV        : NSSting having value YES if any id of record is IV_USER otherwise NO
 * CONTACTDETAIL         : NSMutableDictonary contains
 * CONATCT_DATA_ID       : contains id of each data field Id in record
 * CONATCT_DATA_VALUE    : contains data field value either email or phone number
 * CONTACT_DATA_TYPE     : contains data field type "p" for email and "e" for email
 * IV_ID                 : contains IV_ID is user is also an IV_USER otherwise contains 0
 * IS_VSMS               : contains YES if user is VSMS otherwise NO
 * IS_BLOCKED            : conatins YES if user is blocked by logged-in user otherwise NO */

// used by contact List in UI-Engine interface

#define UI_CONTACT_ID               @"contactId"
#define UI_CONTACT_NAME             @"contactName"
#define UI_CONTACT_PICS             @"contactPic"
#define UI_IS_IV                    @"isIv"
#define UI_CONTACT_DETAIL           @"contactDetail"
#define UI_CONTACT_DATA_ID          @"contactDataId"
#define UI_CONTACT_DATA_VALUE       @"contactDataValue"
#define UI_CONTACT_DATA_TYPE        @"contactDataType"
#define UI_IV_ID                    @"ivId"
#define UI_IS_VSMS                  @"idVsms"
#define UI_IS_BLOCKED               @"isBlocked"
#define ISSELECT                    @"ISSELECT"

//register screen macro

#define TERMS_POLICY @"By clciking 'Register', you have read and agree to our Terms of Service and Privacy Policy"

/**
 * Network is available or not.
 */
#define NETWORK_NOT_AVAILABLE 0
#define NETWORK_AVAILABLE     1
#define SERVER_ERROR          @"server error"

/**
 * SIM available or not.
 */
#define SIM_NOT_AVAILABLE     0
#define SIM_AVAILABLE         1

/**
 * IMAGE TYPE
 */
#define NATIVE_CONTACT_IMAGE  1


#pragma mark FONT MACRO

#define HELVETICANEUE_MEDIUM    @"HelveticaNeue-Medium"
#define HELVETICANEUE_LIGHT     @"HelveticaNeue-Light"
#define HELVETICANEUE_BOLD      @"HelveticaNeue-Bold"
#define HELVETICANEUE           @"HelveticaNeue"
#define TABBAR_FONT_NAME        @"#1284ff"
#define FRNDZ_FONT_NAME         @"#222222"
#pragma mark CONTACT MACRO

#define PHONEBOOK_ACCESS @"To find your friends on InstaVoice, we'd like to get access to your Phonebook"


//inside conversation Type

#define CONVERSATION        1
#define NOTES               2
#define MYVOBOLO            3


#pragma mark MSG TYPE

#define MISSCALL                @"mc"
#define RING_MC                 @"ring"
#define IV_TYPE                 @"iv"
#define VB_TYPE                 @"vb"
#define FB_TYPE                 @"fb"
#define TW_TYPE                 @"tw"
#define INV_TYPE                @"inv"
#define NOTES_TYPE              @"notes"
#define SUPPORT_TYPE            @"Support"
#define FEEDBACK_TYPE           @"Feedback"
#define FOLLOW_STATUS           @"G"
#define UNFOLLOW_STATUS         @"F"
#define MSG_FLOW_R              @"r"
#define MSG_FLOW_S              @"s"
#define CELEBRITY_TYPE          @"cl"
#define VSMS_TYPE               @"vsms"
#define AVS_TYPE                @"avs"
#define IS_FORWORD_MSG          @"fwd"
#define MSG_LIST                @"MSG_LIST"
#define MISSED_CALL_COUNT       @"MISSED_CALL_COUNT"
#define NOTIFY_UI               @"NOTIFY_UI"
#define MSG_DIC                 @"MSG_DIC"
#define IS_EXPANDED             @"isExpanded"
// Audio Mode
#define SPEAKER_MODE            1
#define CALLER_MODE             2
#define CURRENT_CHAT_USER       @"CURRENT_CHAT_USER"
#define NOTIFICATION_DIC        @"NOTIFICATION_DIC"
#define HELP_NUMBER             @"912222222222"
#define SUGGESTION_NUMBER       @"911111111111"
#define MAX_NETWORK_RETRY 2

//Table index key
#define TABLE_TITLE             @"title"
#define TABLE_INDEX             @"index"
#define TABLE_VALUE             @"value"


// web view type

#define PRIVACY_TYPE        1
#define TERMS_N_CONDN       2
#define FAQS                3
#define MISSEDCALL_HELP     4


// DISCONNECT FROM TW / FB

#define  APP_TYPE              @"app_type"

#define INVITE_ALERT            @"invite"
#define MANY_ID_ALERT           @"manyID"

#define GROUP_TYPE              @"g"
#define GROUP_MSG_TYPE          @"group"
#define GROUP_MSG_EVENT_TYPE    @"group_event"


#define MSG_PLAYBACK_STATUS  @"PLAYBACK_STATUS"

#define     RING_MC_TEXT           @"Ring Missed Call"
#define     RING_MC_SUCCESS        RING_MC_TEXT
#define     RING_MC_FAILED         @"Ring Missed Call Failed"
#define     RING_MC_REQUESTED      @"Ring Missed Call Requested"
#define     RING_MC_ACK_FAILED     @"Ring Missed Call Failed. Sent only on InstaVoice"
#define     RING_MC_REQUESTED_ALREADY @"Ring Missed Call Already Requested"
#define     IV_RING_MC             @"IV Ring Missed Call"

#define SHOW_MORE_LEN       500 //Enable show more option for text bubble if len of msg exceeds 500
#define kShareLocationSettingsValue @"ShareLocationSettingsValue"

#define MSG_WITHDRAWN_TEXT    @"Message has been withdrawn"


#define PN_RECIEVED_AT      @"pn_received_at"
#define FROM_PHONE          @"from_phone"
#define TO_PHONE            @"to_phone"
#define VOIP_CALL_STATUS    @"status"
#define VOIP_CALL_ACCEPTED  @"accepted"
#define VOIP_CALL_REJECTED  @"rejected"
#define VOIP_CALL_MISSED    @"missed"
#define VOIP_CALL_ABORT     @"abort"
#define VOIP_CALL_SIPERROR  @"sip_error"
#define VOIP_CALL_INCOMING  @"incoming"
#define VOIP_CALL_OUTGOING  @"outgoing"
#define VOIP_CALL_ID        @"call_id"
#define VOIP_CALL_DIC       @"VOIP_CALL_DIC"
#define HANGUP_TAPPED       @"hangup_tapped"
#define VOIP_CALL_CANCELED  @"canceled"

@interface Macro : NSObject

@end
