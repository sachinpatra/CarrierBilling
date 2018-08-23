//
//  ContactsApi.h
//  InstaVoice
//
//  Created by EninovUser on 23/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#ifndef InstaVoice_ContactsApi_h
#define InstaVoice_ContactsApi_h

/**********************************************
 *  NAME OF API THAT ARE USED IN THIS FILE    *
 *                                            *
 *  6.7 enquire phone                         *
 *  6.12 Fetch contacts                       *
 *  6.13 Update contacts                      *
 *  6.29 follow unfollow blogger              *
 *  6.31 fetch User's following list          *
 *  6.38 fetch friends                        *
 *  6.39 Block or Unblock user                *
 *                                            *
 **********************************************/



//  Enquire Phone IV Status (Extension) Request Parameter

#define API_CONTACTS                       @"contacts"
#define API_DEVICE_CONTACT_ID              @"device_contact_id"
#define API_CONTACT_LIST                   @"contact_list"
#define API_DISPLAY_NAME                   @"display_name"
#define API_CONTACT_ID                     @"contact_id"
#define API_CNT_ID                         @"contactId"
#define API_CONTACT_TYPE                   @"contact_type"
#define API_CONTACT_SUB_TYPE               @"contact_sub_type"
#define API_CONTACT_NUMBER                 @"contact_number"
#define API_IV_USER_ID                     @"iv_user_id"
#define API_IVUSER_ID                      @"ivUserId"
#define API_VSMS_USER                      @"vsms_user"
#define API_TR_DATE                        @"trDate"
#define API_DAY                            @"dayOfMonth"
#define API_MONTH                          @"month"
#define API_YEAR                           @"year"
#define API_HOUR                           @"hourOfDay"
#define API_MIN                            @"minute"
#define API_SEC                            @"second"
#define API_HEADER                         @"header"

//  Enquire Phone IV User  Request/Response Parameter
#define API_CONTACT_IDS                    @"contact_ids"
#define API_IV_CONTACT_IDS                 @"iv_contact_ids"
#define API_CLEAR_ADDRESS_BOOK             @"clear_address_book"
#define API_FETCH_PIC_URI_TYPE             @"fetch_pic_uri_type"
#define API_PIC_URI                        @"pic_uri"

// Fetch Contacts Request parameter

#define API_FETCH_AFTER_TRNO               @"fetch_after_trno"
#define API_FETCH_BLOCKED_USER_LIST        @"fetch_blocked_user_list"

// Fetch Contacts Response parameter
#define API_LAST_TRNO                      @"last_trno"
#define API_BLOCKED_USER_LIST              @"blocked_user_list"
#define BLOCK_ISD                      @"block_id"
#define CREATION_DATE                  @"creation_date"
#define BY_IV_USER_ID                  @"by_iv_user_id"
#define BLOCKED_CONTACT_ID             @"blocked_contact_id"
#define BLOCKED_CONTACT_TYPE           @"blocked_contact_type"
#define FROM_USER_DEVICE_ID            @"from_user_device_id"

//Update Contacts Request Parameter

#define OPERATION                      @"operation"

// Fetch User’s Following List Response Parameter

#define API_FOLLOWING_LIST                 @"following_list"
#define API_CELEBRITY_LIST                 @"celebrity_list"
#define API_BLOGGER_ID                     @"blogger_id"
#define API_BLOGGER_DISP_NAME              @"display_name"
#define API_BLOGGER_TYPE                   @"blogger_type"
#define API_PROFILE_PICTURE_URI            @"profile_picture_URI"
#define API_PROFILE_PIC_THUMBNAIL_URI      @"profile_picture_thumbnail_URI"
#define API_FOLLOW_STATUS                  @"follow_status"

//  Fetch Friends Response Parameter

#define API_FRIEND_LIST                    @"friend_list"
#define API_USER_ID                        @"user_id"
#define API_NAME                           @"name"
#define API_PIC_INFO                       @"pic_info"
#define API_DATA                           @"data"
#define API_URL                            @"url"
#define API_IS_SILHOUETTE                  @"is_silhouette"

//  Block or Unblock Users Request parameter

#define API_OPERATION       @"operation"

// Fetch List of Blocked Users Response parameter

//#define API_BLOCKED_USER_LIST              @"blocked_user_list"

// FolloworUnfollowa Blogger Request parameter

#define API_FOLLOWING_USER_ID              @"following_user_id"
#define API_FOLLOW_UNFOLLOW_FLAG           @"follow_unfollow_flag"

#define API_CONTACT_BLOCK_UNBLOCK      @"cbu"

// for "fetch_vobolos" cmd param

#define API_LAST_BLOG_ID    @"last_blog_id"

#endif
