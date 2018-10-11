//
//  ServerApi.m
//  InstaVoice
//
//  Created by EninovUser on 07/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "ServerApi.h"
#import "EventType.h"
#import "Logger.h"

@implementation ServerApi

/*
 This function return the cmd parameter according to the Eevent Type
 */
+(NSString*)getServerApi:(int)eventType
{
    NSString *serverApi = @"";
    
    switch (eventType)
    {
        case SIGN_IN:
        {
            serverApi = @"sign_in";
        }
            break;
        case SIGN_OUT:
        {
            serverApi = @"sign_out";
        }
            break;
        case REG_USER:
        {
            serverApi = @"reg_user";
        }
            break;
        case VERIFY_USER:
        {
            serverApi = @"verify_user";
        }
            break;
        case SET_DEVICE_INFO:
        {
            serverApi = @"set_device_info";
        }
            break;
        case SEND_TEXT_MSG:
        {
            serverApi = @"send_text";
        }
            break;
            
        case SEND_MC:
        {
            serverApi = @"send_mc";
        }
            break;
            
        case SEND_VOIP_CALL_LOG:
        {
            serverApi = @"voip_call_log";
        }
            break;
            
        case SEND_VOICE_MSG:
        {
            serverApi = @"send_voice";
        }
            break;
        case SEND_IMAGE_MSG:
        {
            serverApi = @"send_image";
        }
            break;
        case FETCH_OLDER_MSG://rakesh code
        case FETCH_MSG:
        {
            serverApi = @"fetch_msgs";
        }
            break;
        case FETCH_MSG_ACTIVITY:
        {
            serverApi = @"fetch_msg_activities";
        }
            break;
        case DOWNLOAD_VOICE_MSG:
        {
            serverApi = @"";
        }
            break;
        case UPDATE_PROFILE_INFO:
        {
            serverApi = @"update_profile_info";
        }
            break;
        case FETCH_STATES:
        {
            serverApi = @"list_states";
        }
            break;
        case FETCH_CONTACTS:
        {
            serverApi = @"fetch_contacts";
        }
            break;
        case GEN_NEW_PWD:
        {
            serverApi = @"generate_pwd";
        }
            break;
        case REGEN_VALIDATION_CODE:
        {
            serverApi = @"generate_veri_code";
        }
            break;
        case INCREMENT_READ_COUNT:
        {
            serverApi = @"read_msgs";
        }
            break;
        case POST_ON_WALL:
        {
            serverApi = @"post_on_wall";
        }
            break;
        case GET_USER_PROFILE_REQ:
        {
            serverApi = @"get_profile_info";
        }
            break;
        case UPLOAD_PROFILE_PIC:
        {
            serverApi = @"upload_pic";
        }
            break;
        case FORWARD_MSG:
        {
            serverApi = @"forward_msg";
        }
            break;
        case FETCH_USER_SETTINGS_REQ:
        {
            serverApi = @"fetch_settings";
        }
            break;
            
        case FETCH_VOIP_SETTING_REQ:
        {
            serverApi = @"fetch_voip_settings";
        }
            break;
            
        case UPDATE_USER_SETTINGS:
        {
            serverApi = @"update_settings";
        }
            break;
        case FETCH_FRIENDS:
        {
            serverApi = @"fetch_friends";
        }
            break;
        case ENQUIRE_IV_USERS:
        {
            serverApi = @"enquire_iv_users";
        }
            break;
        case VERIFY_PWD:
        {
            serverApi = @"verify_pwd";
        }
            break;
            
        case WITHDRAW_MSG:
        case DELETE_MSG:
        {
            serverApi = @"delete_msg";
        }
            break;
            
        case MSG_ACTIVITY:
        {
            serverApi = @"msg_activity";
        }
            break;
        case DISCONNECT_FROM_FB_TW:
        {
            serverApi = @"disconnect";
        }
            break;
        case FETCH_GROUP_UPDATE:
        {
            serverApi = @"fetch_group_updates";
        }
            break;
        case CREATE_GROUP:
        {
            serverApi = @"create_group";
        }
            break;
        case UPDATE_GROUP:
        {
            serverApi = @"update_group";
        }
            break;
        case FETCH_GROUP_INFO:
        {
            serverApi = @"fetch_group_info";
        }
            break;
        case GET_CARRIER_DETAILS:
        {
            serverApi = @"list_carriers";
        }
            break;
        case SET_GREETINGS:
        {
            serverApi = @"set_greetings";
        }
            break;
            
        case FETCH_CELEBRITY_MSG:
        {
            serverApi = @"fetch_vobolos";
            break;
        }
        
        case BLOCK_UNBLOCK:
        {
            serverApi = @"block_unblock_users";
            break;
        }
        case FETCH_BLOCK_USER_LIST:
        {
            serverApi = @"fetch_blocked_users";
            break;
        }
        case MANAGE_USER_CONTACT:
        {
            serverApi  = @"manage_user_contact";
            break;
        }
        case FETCH_USER_CONTACTS:
        {
            serverApi = @"fetch_user_contacts";
            break;
        }
        case APP_STATUS:
        {
            serverApi = @"app_status";
            break;
        }
        case JOIN_USER:
        {
            serverApi = @"join_user";
            break;
        }
        case VOICEMAIL_SETTINGS:
        {
            serverApi = @"voicemail_setting";
            break;
        }
        case FETCH_OBD_CALL_DEBIT:
        {
            serverApi = @"fetch_obd_call_debit";
            break;
        }
        case REFFERAL_CODE:
        {
            serverApi = @"validate_coupon";
            break;
        }
        case FETCH_PURCHASE_PRODUCTS:
        {
            serverApi = @"fetch_purchase_products";
            break;
        }
        case FETCH_PURCHASE_HISTORY:
        {
            serverApi = @"fetch_purchase_history";
            break;
        }
        case PURCHASE_PRODUCT:
        {
            serverApi = @"purchase_credits";
            break;
        }
        case USAGE_SUMMARY:
        {
            serverApi = @"rm_call_summ";
            break;
        }
        case VOICE_MESSAGE_TRANSCRIPTION:
        {
            serverApi = @"trans_msg";
            break;
        }
        case VOICE_MESSAGE_TRANSCRIPTION_RATING:
        {
            serverApi = @"trans_msg_rate";
            break;
        }
        case SUBSCRIPTION_PLANLIST:
        {
            serverApi = @"vn_sub_plan_list";
            break;
        }
        case SUBSCRIPTION_NUMBER_LIST:
        {
            serverApi = @"vn_pool_list";
            break;
        }
        case LOCK_VERTUAL_NUMBER:
        {
            serverApi = @"lock_vn";
            break;
        }
        case VIRTUALNUMBER_SUBSCRIPTION:
        {
            serverApi = @"vn_sub";
            break;
        }
            //Sachin
        case FETCH_BUNDLE_LIST:
        {
            serverApi = @"fetch_opr_bundles";
            break;
        }
        case BUNDLE_STATUS:
        {
            serverApi = @"opr_bundle_status";
            break;
        }
        case BUNDLE_PURCHASE:
        {
            serverApi = @"opr_bundle_purchase";
            break;
        }
                //Sachin
        default:
        {
            KLog(@"Event Type is not matched");
        }
            break;
    }
    
    return serverApi;
}

@end
