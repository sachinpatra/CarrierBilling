//
//  EventType.h
//  InstaVoice
//
//  Created by EninovUser on 07/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#ifndef InstaVoice_EventType_h
#define InstaVoice_EventType_h


/************************************/
/*
 This event type used in send request to server and get response from server.
 */

#define SIGN_IN                  1
#define REG_USER                 2
#define VERIFY_USER              3
#define SIGN_OUT                 4
#define SET_DEVICE_INFO          5
#define SEND_VOICE_MSG           6
#define SEND_TEXT_MSG            7
#define FETCH_MSG                8
#define DOWNLOAD_VOICE_MSG       9
#define FETCH_MSG_ACTIVITY      10

#define UPDATE_PROFILE_INFO     11
#define FETCH_STATES            12
#define FETCH_COUNTRIES         13
#define FETCH_CONTACTS          14
#define APP_STATUS              15

#define GEN_NEW_PWD             16
#define REGEN_VALIDATION_CODE   17
#define MQTT_DATA_RECEIVED      18
#define PURGE_OLD_DATA          19

#define JOIN_USER               20

#define POST_ON_WALL            21
#define GET_USER_PROFILE        22
#define UPLOAD_PROFILE_PIC      23

#define DELETE_CHATS            24

#define FORWARD_MSG             26
#define FETCH_USER_SETTINGS     27
#define UPDATE_USER_SETTINGS    28

#define UPDATE_MISSEDCALL_REASON    29

#define FETCH_FRIENDS           30
#define BLOCK_UNBLOCK           31
#define FETCH_BLOCK_USER_LIST   32
#define ENQUIRE_IV_USERS        33

#define SEND_MC                 34

#define SEND_APP_STATUS               35
#define SEND_VOIP_CALL_LOG            36
#define DELETE_MSG_TABLE              43
#define GET_ACTIVE_CONVERSATION_LIST  45
#define GET_CURRENT_CHAT              46
#define SEND_MSG                      47
#define SEND_ALL_PENDDING_MSG         48
#define STOP_SEND_MSG                 49
#define VERIFY_PWD                    50

#define UPDATE_ACTIVITYIES            52
#define DELETE_MSG                    53
#define WITHDRAW_MSG                  54
#define MSG_ACTIVITY                  55
#define GET_NOTES                     56

#define GET_MYVOBOLO_MSG              61
#define FETCH_CELEBRITY_MSG           64

#define NOTIFICATION_TAP              67 //NOT USED: REMOVE
#define GET_CURRENT_CHAT_USER         69
#define GET_USER_PROFILE_REQ          71

#define INCREMENT_READ_COUNT          83
#define FETCH_USER_SETTINGS_REQ       85
#define FETCH_VOIP_SETTING_REQ        86

#define DISCONNECT_FROM_FB_TW         87
#define UPDATE_PLAY_DURATION          88
#define GET_VSMS_LIMIT                89

#define NOTIFY_UI_ON_ACTIVITY         96

#define UPDATE_MSG_ON_CONTACT_SYNC    98
#define CHAT_ACTIVITY                 99
#define MISS_CALL_GET_INFO           100
#define FETCH_OLDER_MSG                101
#define FETCH_GROUP_UPDATE              102
#define CREATE_GROUP                    103
#define UPDATE_GROUP                    104
#define FETCH_GROUP_INFO                105
#define SEND_IMAGE_MSG                  106
#define GET_CARRIER_DETAILS             107

#define SET_GREETINGS                   109

#define MANAGE_USER_CONTACT           110
#define FETCH_USER_CONTACTS           111
#define CHANGE_USER_ID                112

#define GET_MISSEDCALL_LIST           113
#define GET_VOICEMAIL_LIST            114

#define NOTIFY_MISSEDCALL             115
#define NOTIFY_VOICEMAIL              116
#define NOTIFY_IVMSG                  117

#define INTERNET_UP                118
#define INTERNET_DOWN              119

#define ADD_MSG_HEADER             120

/**
 Max Event Type
 */
#define MAX_EVENT_TYPE                117

//HLR Event Type
#define VOICEMAIL_SETTINGS            121

//Refferal Code Event Type
#define REFFERAL_CODE            122

#define FETCH_PURCHASE_PRODUCTS       130
#define FETCH_PURCHASE_HISTORY        131
#define PURCHASE_PRODUCT              132
#define SUBSCRIPTION_PLANLIST           133
#define SUBSCRIPTION_NUMBER_LIST        134
#define LOCK_VERTUAL_NUMBER             135
#define VIRTUALNUMBER_SUBSCRIPTION      136

//Sachin
#define FETCH_BUNDLE_LIST       140
#define BUNDLE_STATUS           141
#define BUNDLE_PURCHASE         142
//Sachin


#define USAGE_SUMMARY            123

#define VOICE_MESSAGE_TRANSCRIPTION 124
#define VOICE_MESSAGE_TRANSCRIPTION_TEXT 125
#define VOICE_MESSAGE_TRANSCRIPTION_RATING 126

//OBD Debit call rate
#define FETCH_OBD_CALL_DEBIT            127

#endif
