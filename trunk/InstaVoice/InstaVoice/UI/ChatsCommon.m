//
//  ChatsCommon.m
//  InstaVoice
//
//  Created by Pandian on 1/2/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatsCommon.h"
#import "ConfigurationReader.h"
#import "CreateNewSingleChatViewController.h"

#ifndef REACHME_APP
#import "CreateNewGroupViewController.h"
#endif

#import "ChatMobileNumberViewController.h"
#import "Profile.h"
#import "ContactsApi.h"
#import "IVVoiceMailListViewController.h"
#import "IVSettingsListViewController.h"
#import "NBPhoneNumberUtil.h"
#import "NBAsYouTypeFormatter.h"
#import "ConversationApi.h"
#import "ChatActivity.h"
#import "IVFileLocator.h"
#import "InsideConversationScreen.h"
#import "BaseConversationScreen.h"
#import "UIStateMachine.h"
#import "Logger.h"

NSString *const kChatsUpdateEvent = @"ChatsUpdate";

static ChatsCommon* chatsCommonObj=nil;

@implementation ChatsCommon
AppDelegate* appDelegate;

+(ChatsCommon *)sharedChatsCommon
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chatsCommonObj = [[ChatsCommon alloc]init];
    });
    return chatsCommonObj;
}

-(id)init {
    
    self = [super init];
    if(self) {
        
        self.allMsgsList = [[NSMutableArray alloc]init];
        self.hiddenUserIDList = [[NSMutableArray alloc]init];
        self.blockedUserIDList = [[NSMutableArray alloc]init];
        self.missedCallList = [[NSMutableArray alloc]init];
        self.voicemailList = [[NSMutableArray alloc]init];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(chatsUpdateEvent:)
                                                   name:kChatsUpdateEvent
                                                 object:nil];
    }
    
    return self;
}

-(void)setDelegate:(BaseUI *)delegate {
    _delegate = delegate;
     appDelegate = (AppDelegate *)APP_DELEGATE;
}

-(void)prepareHiddenUsers {
    //- Read the hidden users, if any, from the configuration setting
    NSArray* arrHidenListFromSettings = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"HIDDEN_TILES"];
    [self.hiddenUserIDList removeAllObjects];
    if(arrHidenListFromSettings)
        [self.hiddenUserIDList addObjectsFromArray:arrHidenListFromSettings];
    
    //KLog(@"Hidden users' IDs: %@",_hiddenUserIDList);
}

-(void)prepareBlockedUsers {
    
    //- Read the blocked users, if any, from the configuration settings
     NSArray* arrBlockedListFromSettings = [[ConfigurationReader sharedConfgReaderObj]getObjectForTheKey:@"BLOCKED_TILES"];
     [_blockedUserIDList removeAllObjects];
     if(arrBlockedListFromSettings)
     [_blockedUserIDList addObjectsFromArray:arrBlockedListFromSettings];

    //KLog(@"Blocked users's IDs: %@",_blockedUserIDList);
}

#ifdef COMPOSE_BUTTON
-(void)composeNewMessage {
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    // create the screens for the tab bar controller
    CreateNewSingleChatViewController *singleChatScreen = [[CreateNewSingleChatViewController alloc] initWithNibName:@"FriendsScreen" bundle:[NSBundle mainBundle]];
    CreateNewGroupViewController *groupChatScreen = [[CreateNewGroupViewController alloc] initWithNibName:@"CreateNewGroupViewController" bundle:[NSBundle mainBundle]];
    ChatMobileNumberViewController *mobileNumberChatScreen = [[ChatMobileNumberViewController alloc] initWithNibName:@"ChatMobileNumberViewController" bundle:[NSBundle mainBundle]];
    
    singleChatScreen.callingTabBarController = _delegate.tabBarController;
    groupChatScreen.callingTabBarController = _delegate.tabBarController;
    mobileNumberChatScreen.callingTabBarController = _delegate.tabBarController;
    
    // embed each screen in a navigation controller
    UINavigationController *singleChatNavController = [[UINavigationController alloc] initWithRootViewController:singleChatScreen];
    UINavigationController *groupChatNavController = [[UINavigationController alloc] initWithRootViewController:groupChatScreen];
    UINavigationController *mobileNumberNavController = [[UINavigationController alloc] initWithRootViewController:mobileNumberChatScreen];
    
    tabBarController.viewControllers = @[singleChatNavController, groupChatNavController, mobileNumberNavController];
    [_delegate.navigationController presentViewController:tabBarController animated:YES completion:nil];
}
#endif

/*
 Returns the enabled or disable status of voiceMail and voip via pointer
 variables vmStatus and voipStatus.
 */
/*
-(void)getVoicemailStatus:(BOOL *)vmStatus andVoipStatus:(BOOL *)voipStatus {
    
    SettingModel* currentSettingsModel = [Setting sharedSetting].data;
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    if (currentSettingsModel) {
        if (currentSettingsModel.voiceMailInfo && [currentSettingsModel.voiceMailInfo count]) {
            for (VoiceMailInfo *voiceMailInfo in currentSettingsModel.voiceMailInfo) {
                
                NSString *primaryNumber = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
                
                if([voiceMailInfo.phoneNumber isEqualToString:primaryNumber]) {
                    if (voiceMailInfo.isVoiceMailEnabled)
                        *vmStatus = YES;
                    
                    if(voiceMailInfo.isVoipEnabled)
                        *voipStatus = YES;
                    
                }
                if (!*vmStatus) {
                    for (int i = 0; i < currentUserProfileDetails.additionalVerifiedNumbers.count; i++) {
                        
                        KLog(@"Additional Nums:%@",currentUserProfileDetails.additionalVerifiedNumbers);
                        NSDictionary* dicObj = [currentUserProfileDetails.additionalVerifiedNumbers objectAtIndex:i];
                        NSString* contactID = @"";
                        if(dicObj && dicObj.count>0) {
                            contactID = [dicObj valueForKey:API_CONTACT_ID];
                        }
                        
                        if([voiceMailInfo.phoneNumber isEqualToString:contactID]) {
                            if (voiceMailInfo.isVoiceMailEnabled)
                                *vmStatus = YES;
                            
                            if(voiceMailInfo.isVoipEnabled)
                                *voipStatus = YES;
                        }
                    }
                }
            }
        }
    }
}*/

-(BOOL)redirectToVoicemailOrSettingsScreen {
    
    NSString* primaryNumber = [ConfigurationReader sharedConfgReaderObj].getLoginId;
    
    NSMutableArray* additionalNumbers = [[NSMutableArray alloc]init];
    
    UserProfileModel *currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    if (nil != currentUserProfileDetails) {
        if ([currentUserProfileDetails.additionalVerifiedNumbers count]) {
            NSArray *verifiedNumbers = [currentUserProfileDetails.additionalVerifiedNumbers valueForKeyPath:@"contact_id"];
            NSMutableArray *additionalNumbersList = [[NSMutableArray alloc]init];
            for (NSString* number in verifiedNumbers) {
                if (![number isEqualToString:primaryNumber])
                    [additionalNumbersList addObject: number];
            }
            additionalNumbers = additionalNumbersList;
        }
    }
    
    VoiceMailInfo* primaryNumberVoiceMailInfo = nil;
    NSMutableArray* additionalNumbersVoiceMailInfo = [[NSMutableArray alloc]init];
    //Check for the settings information - Settings response has the information about the user contacts.
    SettingModel *currentSettingsModel = [Setting sharedSetting].data;
    if (currentSettingsModel.voiceMailInfo && [currentSettingsModel.voiceMailInfo count]) {
        for (VoiceMailInfo *voiceMailInfo in currentSettingsModel.voiceMailInfo) {
            if(![voiceMailInfo.phoneNumber isEqualToString:primaryNumber]) {
                [additionalNumbersVoiceMailInfo addObject:voiceMailInfo];
            }
            else
                primaryNumberVoiceMailInfo = voiceMailInfo;
        }
    }
    
    if (additionalNumbers && [additionalNumbers count]) {
        additionalNumbers = [NSMutableArray arrayWithArray:[additionalNumbers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    
    if ((additionalNumbers && [additionalNumbers count]) || (additionalNumbersVoiceMailInfo && [additionalNumbersVoiceMailInfo count])) {
        //We have additional numbers - so redirect it to listing page.
#ifdef REACHME_APP
        if (![_delegate.navigationController.topViewController isKindOfClass:[IVSettingsListViewController class]]) {
            [appDelegate.tabBarController setSelectedIndex:5];
            [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[5]];
            return TRUE;
        }
#endif
        if (additionalNumbers.count > 3) {
            if (![_delegate.navigationController.topViewController isKindOfClass:[IVVoiceMailListViewController class]]) {
                UIStoryboard *voiceMailSettingsStorybaord = [UIStoryboard storyboardWithName:@"IVVoiceMailMissedCallSettingsStoryBoard" bundle:[NSBundle mainBundle]];
                IVVoiceMailListViewController *voiceListViewController = [voiceMailSettingsStorybaord instantiateViewControllerWithIdentifier:@"IVVoiceMailListView"];
                //We have additional numbers - we need to show the voicemail list viewcontroller.
                voiceListViewController.primaryNumberVoiceMailInfo = primaryNumberVoiceMailInfo;
                voiceListViewController.primaryNumber = primaryNumber;
                voiceListViewController.additionalNumbersVoiceMailInfo = additionalNumbersVoiceMailInfo;
                voiceListViewController.additionalNumbers = additionalNumbers;
                voiceListViewController.hidesBottomBarWhenPushed = YES;
                [_delegate.navigationController pushViewController:voiceListViewController animated:NO];
                return TRUE;
            }
        } else {
            if (![_delegate.navigationController.topViewController isKindOfClass:[IVSettingsListViewController class]]) {
                
                int tabBarIndex = 0;
                if([[Setting sharedSetting] data].vbEnabled)
                    tabBarIndex = 8;
                else
                    tabBarIndex = 7;
                
                [appDelegate.tabBarController setSelectedIndex:tabBarIndex];
                [appDelegate.tabBarController setSelectedViewController:appDelegate.tabBarController.viewControllers[tabBarIndex]];
                return TRUE;
            }
        }
    }
    return NO;
}

-(NSString*)formatPhoneNumber:(NSString *)strNumber {
    
    NSString* strResult = nil;
    NSCharacterSet *alphaSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    NSRange r = [strNumber rangeOfCharacterFromSet:alphaSet];
    if(r.location == NSNotFound) {
        
        NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
        NSNumber *countryIsdCode = [phoneUtil extractCountryCode:([Common addPlus:strNumber]) nationalNumber:nil];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSString *countryIsdCodeString = [formatter stringFromNumber:countryIsdCode];
        
        NSString *countrySimIso = [[Setting sharedSetting]getCountrySimIsoFromCountryIsd:countryIsdCodeString];
        NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:countrySimIso];
        
        strResult = [f inputString:[Common addPlus:strNumber]];
    }
    return strResult;
}

-(void)markReadMessagesFromThisList:(NSArray *)aList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *unreadMessages = nil;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@" !(MSG_CONTENT_TYPE LIKE %@) && (MSG_FLOW LIKE %@) && (MSG_READ_CNT == 0)",@"a",@"r"];
        unreadMessages = [aList filteredArrayUsingPredicate:predicate];
        
        NSMutableArray* list1=[[NSMutableArray alloc]init];
        NSArray* unreadMessages1=nil;
        for(NSDictionary* dic in aList) {
            NSArray* msgList =  [dic valueForKey:MSG_LIST];
            if([[dic valueForKey:MSG_TYPE] isEqualToString:VOIP_TYPE])
                continue;
            if([[dic valueForKey:MSG_READ_CNT]intValue] == 0) {
                [list1 addObject:dic];
            }
            if([msgList count]) {
                [list1 addObjectsFromArray:msgList];
            }
        }
        if([list1 count]) {
            unreadMessages1 = [list1 filteredArrayUsingPredicate:predicate];
        }
        
        NSMutableArray* unreadMessageList = [[NSMutableArray alloc]init];
        if([unreadMessages count])
            [unreadMessageList addObjectsFromArray:unreadMessages];
        
        if([unreadMessages1 count])
            [unreadMessageList addObjectsFromArray:unreadMessages1];
        
        
        NSMutableArray *msgIdsOfUnreadMsgs = [[NSMutableArray alloc]init];
        NSMutableArray *msgIdsOfUnreadMsgsForCeleb = [[NSMutableArray alloc]init];
        
        for (NSDictionary *temp in unreadMessageList) {
            [temp setValue:[NSNumber numberWithInt:1] forKey:MSG_READ_CNT];
            
            if([[temp valueForKey:MSG_TYPE]isEqualToString:CELEBRITY_TYPE])
            {
                if([temp valueForKey:MSG_ID])
                    [msgIdsOfUnreadMsgsForCeleb addObject:[temp valueForKey:MSG_ID]];
            }
            else
            {
                if([temp valueForKey:MSG_ID])
                    [msgIdsOfUnreadMsgs addObject:[temp valueForKey:MSG_ID]];
            }
        }
        
        if(msgIdsOfUnreadMsgs.count>0)
        {
            KLog(@"Read messages: %@",msgIdsOfUnreadMsgs);
            EnLogd(@"Read messages: %@",msgIdsOfUnreadMsgs);
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:IV_TYPE forKey:MSG_TYPE];
            [dic setValue:msgIdsOfUnreadMsgs forKey:API_MSG_IDS];
            
            [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeReadMessage withData:dic];
        }
        if(msgIdsOfUnreadMsgsForCeleb.count>0)
        {
            KLog(@"Read messages: %@",msgIdsOfUnreadMsgsForCeleb);
            EnLogd(@"Read messages: %@",msgIdsOfUnreadMsgsForCeleb);
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:CELEBRITY_TYPE forKey:MSG_TYPE];
            [dic setValue:msgIdsOfUnreadMsgsForCeleb forKey:API_MSG_IDS];
            
            [[ChatActivity sharedChatActivity]addActivityOfType:ChatActivityTypeReadMessage withData:dic];
        }
        });
}

-(NSMutableArray*)filterChatsForDisplayType:(int)displayType {
    
    /*
     KLog(@"Current Display type: %ld",displayType);
     KLog(@"Hidden users' IDs: %@, Total = %d",_hiddenUserIDList, (int)[_hiddenUserIDList count]);
     KLog(@"Blocked users's IDs: %@, Total = %d",_blockedUserIDList,(int)[_blockedUserIDList count]);
     for( NSMutableDictionary* userDic in self.allMsgsList) {
     NSString* fromUserID = [userDic valueForKey:FROM_USER_ID];
     KLog(@"ALL Users' IDs: %@",fromUserID);
     }
     KLog(@"ALL Users' IDs count: %d",(int)[self.allMsgsList count]);
     */
    
    EnLogd(@"Current Display type: %ld",displayType);
    NSMutableArray* filteredArray = [[NSMutableArray alloc]init];
    
    if(displayType == ChatTypeCalls) {
        
        for(NSMutableDictionary* msgDic in self.missedCallList) {
            NSString* fromUserID = [msgDic valueForKey:REMOTE_USER_IV_ID];
            NSString* msgType = [msgDic valueForKey:MSG_TYPE];
            if(!([msgType isEqualToString:MISSCALL] || [msgType isEqualToString:VOIP_TYPE] || [msgType isEqualToString:VOIP_OUT]))
                continue;
            
            if(!fromUserID || ![fromUserID length] || [fromUserID isEqualToString:@"0"])
                fromUserID = [msgDic valueForKey:FROM_USER_ID];
            
            //- Don't add hidden and blocked users into the filteredArray
            if([self.hiddenUserIDList containsObject:fromUserID] || [self.blockedUserIDList containsObject:fromUserID])
                continue;
            [filteredArray addObject:msgDic];
        }
    }
    else if(displayType == ChatTypeVoiceMail)
    {
        for(NSMutableDictionary* msgDic in self.voicemailList) {
            NSString* fromUserID = [msgDic valueForKey:REMOTE_USER_IV_ID];
            NSString* msgType = [msgDic valueForKey:MSG_TYPE];
            NSString* msgContentType = [msgDic valueForKey:MSG_CONTENT_TYPE];
            if(![msgType isEqualToString:VSMS_TYPE] || ![msgContentType isEqualToString:AUDIO_TYPE])
                continue;
            
            if(!fromUserID || ![fromUserID length] || [fromUserID isEqualToString:@"0"])
                fromUserID = [msgDic valueForKey:FROM_USER_ID];
            
            //- Don't add hidden and blocked users into the filteredArray
            if([self.hiddenUserIDList containsObject:fromUserID] || [_blockedUserIDList containsObject:fromUserID])
                continue;
            [filteredArray addObject:msgDic];
        }
    }
#ifndef REACHME_APP
    else if(displayType == ChatTypeAll) {
        for(NSMutableDictionary* msgDic in self.allMsgsList) {
            NSString* fromUserID = [msgDic valueForKey:REMOTE_USER_IV_ID];
            if(!fromUserID || ![fromUserID length] || [fromUserID isEqualToString:@"0"])
                fromUserID = [msgDic valueForKey:FROM_USER_ID];
            
            //- Don't add hidden and blocked users into the filteredArray
            if([self.hiddenUserIDList containsObject:fromUserID] || [_blockedUserIDList containsObject:fromUserID])
                continue;
            [filteredArray addObject:msgDic];
        }
    }
#endif
    
    else if(displayType == ChatTypeBlocked) {
        for (NSMutableDictionary* msgDic in self.allMsgsList) {
            NSString* fromUserID = [msgDic valueForKey:REMOTE_USER_IV_ID];
            if(!fromUserID || ![fromUserID length] || [fromUserID isEqualToString:@"0"])
                fromUserID = [msgDic valueForKey:FROM_USER_ID];
            
            if([self.blockedUserIDList containsObject:fromUserID]) {
                [filteredArray addObject:msgDic];
            }
        }
    }
    else {
        EnLogd(@"Current Display type: Unknow -- SHOULD NOT HAPPEN");
    }
    
    return filteredArray;
}

-(BOOL)isLoggenInUser:(ContactDetailData*)userDic
{
    BOOL result = NO;
    NSString *loginID = [appDelegate.confgReader getLoginId];
    long ivID = [appDelegate.confgReader getIVUserId];
    
    NSNumber *ivIDNum = userDic.ivUserId;
    if(ivIDNum !=  nil)
    {
        long value = [ivIDNum longValue];
        if(value == ivID)
        {
            result = YES;
        }
    }
    else
    {
        NSString *value = userDic.contactDataValue;
        if([value isEqualToString:loginID])
        {
            result = YES;
        }
    }
    return result;
}

-(NSMutableDictionary *)setUserInfoForConversation:(ContactDetailData *)detailData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    if([self isLoggenInUser:detailData])
    {
        dic = nil;
    }
    else
    {
        NSNumber *ivUserId = detailData.ivUserId;
        [dic setValue:detailData.contactDataType forKey:REMOTE_USER_TYPE];
        if([ivUserId longLongValue]>0)
        {
            [dic setValue:[NSString stringWithFormat:@"%@",ivUserId] forKey:REMOTE_USER_IV_ID];
            [dic setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
        }
        else
        {
            [dic setValue:@"0" forKey:REMOTE_USER_IV_ID];
        }
        
        [dic setValue:detailData.contactDataValue forKey:FROM_USER_ID];
        [dic setValue:detailData.contactIdParentRelation.contactName forKey:REMOTE_USER_NAME];
        [dic setValue:[IVFileLocator getNativeContactPicPath:detailData.contactIdParentRelation.contactPic] forKey:REMOTE_USER_PIC];
    }
    
    return dic;
}

-(void)moveToGroupChatScreen:(ContactData*)data
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    [dic setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
    [dic setValue:GROUP_TYPE forKey:CONVERSATION_TYPE];
    [dic setValue:data.groupId forKey:FROM_USER_ID];
    [dic setValue:data.contactName forKey:REMOTE_USER_NAME];
    [dic setValue:[IVFileLocator getNativeContactPicPath:data.contactPic] forKey:REMOTE_USER_PIC];
    
    [_delegate dismissViewControllerAnimated:NO completion:nil];
    
    [appDelegate.dataMgt setCurrentChatUser:dic];
    
    BaseUI* uiObj = [[InsideConversationScreen alloc]
                     initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    [_delegate.navigationController pushViewController:uiObj animated:YES];
}

-(void)updateBadgeValues:(NSNumber*)objChatType
{
    int chatType = [objChatType intValue];
    
    NSMutableArray* msgList = nil;
    NSPredicate* predicate = nil;
    
    if(ChatTypeCalls == chatType) {
        msgList =  [self filterChatsForDisplayType:chatType];
        predicate = [NSPredicate predicateWithFormat:@"SELF.MSG_READ_CNT == 0 AND SELF.MSG_FLOW == %@",MSG_FLOW_R];
    }
    else if (ChatTypeVoiceMail == chatType) {
        msgList = [self filterChatsForDisplayType:chatType];
        predicate = [NSPredicate predicateWithFormat:@"(SELF.MSG_READ_CNT == 0 OR SELF.MSG_READ_CNT == -1) AND SELF.MSG_FLOW == %@",MSG_FLOW_R];
    }
    else {
        msgList =  [self filterChatsForDisplayType:chatType];
        predicate = [NSPredicate predicateWithFormat:@"SELF.UNREAD_MSG_COUNT != '0'"];
    }
    
    NSArray* resList = [msgList filteredArrayUsingPredicate:predicate];
    NSString* strBadgeCount = @"";
    
    if (resList.count>0 && (chatType < 3 && chatType >= 0)) {
        strBadgeCount = [NSString stringWithFormat:@"%lu",(unsigned long)resList.count];
        [[appDelegate.tabBarController.tabBar.items objectAtIndex:chatType] setBadgeValue:strBadgeCount];
    } else {
        [[appDelegate.tabBarController.tabBar.items objectAtIndex:chatType] setBadgeValue:nil];
    }
}

-(void)chatsUpdateEvent:(NSNotification*)notif
{
    int uiType = [[UIStateMachine sharedStateMachineObj] getCurrentUIType];
    int evType = [[notif.userInfo valueForKey:EVENT_TYPE] intValue];
    NSString *respCode = [notif.userInfo valueForKey:RESPONSE_CODE];
 
    KLog(@"chatsUpdateEvent. uiType = %d, evType = %d",uiType,evType);
    if(![respCode isEqualToString:ENG_SUCCESS]) {
        KLog(@"TODO: Error");
        return;
    }
    
    /*
    if( uiType == INSIDE_CONVERSATION_SCREEN ||
        uiType == NOTES_SCREEN ||
        uiType == MY_VOBOLO_SCREEN ||
        uiType == CHAT_GRID_SCREEN ||
        uiType == CALLS_SCREEN ||
        uiType == VOICEMAIL_SCREEN ) {
        KLog(@"No badgeUpdate. Return.");
        return;
    }*/
    
    if((CALLS_SCREEN == uiType && GET_MISSEDCALL_LIST ==  evType) ||
       (VOICEMAIL_SCREEN == uiType && GET_VOICEMAIL_LIST == evType) ||
       (CHAT_GRID_SCREEN == uiType && GET_ACTIVE_CONVERSATION_LIST == evType)) {
        KLog(@"Message gets updated in respective handleEvent method:%d",evType);
        return;
    }
        
    
    switch (evType) {
        case GET_MISSEDCALL_LIST:
        {
            NSMutableArray* missedCallList = [notif.userInfo valueForKey:RESPONSE_DATA];
            if(missedCallList.count) {
                [self.missedCallList removeAllObjects];
                [self.missedCallList addObjectsFromArray:missedCallList];
                self.missedCallList = [self filterChatsForDisplayType:ChatTypeCalls];
                [self performSelectorOnMainThread:@selector(updateBadgeValues:)
                                       withObject:[NSNumber numberWithInt:ChatTypeCalls] waitUntilDone:NO];
            }
#ifndef REACHME_APP
            [appDelegate.engObj getActiveConversationList:TRUE];
#endif
        }
            break;
            
        case GET_VOICEMAIL_LIST:
        {
            NSMutableArray *voicemailList = [notif.userInfo valueForKey:RESPONSE_DATA];
            if(voicemailList.count) {
                [self.voicemailList removeAllObjects];
                [self.voicemailList addObjectsFromArray:voicemailList];
                self.voicemailList = [self filterChatsForDisplayType:ChatTypeVoiceMail];
                [self performSelectorOnMainThread:@selector(updateBadgeValues:)
                                       withObject:[NSNumber numberWithInt:ChatTypeVoiceMail] waitUntilDone:NO];
            }
            
#ifndef REACHME_APP
            [appDelegate.engObj getActiveConversationList:TRUE];
#endif
            
        }
            break;
            
#ifndef REACHME_APP
        case FETCH_MSG:
        case GET_ACTIVE_CONVERSATION_LIST:
        {
            NSMutableArray *allMsgs = [notif.userInfo valueForKey:RESPONSE_DATA];
            if(allMsgs.count) {
                [self.allMsgsList removeAllObjects];
                [self.allMsgsList addObjectsFromArray:[appDelegate.engObj getActiveConversationList:FALSE]];
                [self performSelectorOnMainThread:@selector(updateBadgeValues:)
                                       withObject:[NSNumber numberWithInt:ChatTypeAll] waitUntilDone:NO];
            }
        }
            break;
#endif
#ifdef REACHME_APP
        case FETCH_MSG:
#endif
        case SEND_VOIP_CALL_LOG: {
            KLog(@"SEND_VOIP_CALL_LOG");
            [appDelegate.engObj getMissedCallList:YES];
            break;
        }
            
        default: {
            KLog(@"Other");
        }
            break;
    }
}

-(void)clearData {
    
    [self.allMsgsList removeAllObjects];
    [self.hiddenUserIDList removeAllObjects];
    [self.blockedUserIDList removeAllObjects];
    [self.missedCallList removeAllObjects];
    [self.voicemailList removeAllObjects];
}

@end

