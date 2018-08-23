//
//  InsideConversationScreen.h
//  InstaVoice
//
//  Created by Eninov User on 04/10/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseConversationScreen.h"
#import "ViewForContactScreen.h"
#import "ViewForGroupChatContactScreen.h"
#import "ContactDetailData.h"
#import "ContactSyncUtility.h"
#import "ContactData.h"
#import "ContactSyncSavePicOperation.h"
#import "Contacts.h"
#import "ContactInvitePopUPAction.h"
#import "CoreDataSetup.h"
#import <MessageUI/MessageUI.h>
#import "CustomIOS7AlertView.h"

#ifndef REACHME_APP
#import "CreateNewGroupViewController.h"
#endif


@interface InsideConversationScreen : BaseConversationScreen<ChatPhoneNumberProtocol,ChatPhoneNumberGroupChatProtocol,MFMessageComposeViewControllerDelegate>
{
    //DC - For CoachMarkView in Baseconversation screen
    UIButton* coachMarkViewButton;
    UIView *coachMarkNavigationView;
    //
    NSMutableDictionary *voiceMsgDic;
    BOOL voiceMsgFlag;
    UIView *viewToShowBackgroundAsTransparent;
    ViewForContactScreen *viewAfterTap;
    
#ifndef REACHME_APP
    ViewForGroupChatContactScreen *viewForGroupChatMembers;
#endif
    
    ContactData* _invitedContact;
    NSMutableArray  *inviteList;
    CustomIOS7AlertView     *popUp;                     //PopUp: For Share Message View
    NSMutableDictionary* _activeConversationDictionary;
    BOOL addOrDeleteMemeber;
    UIAlertController* acWithdraw;
}

@property (strong, nonatomic) NSString *currentMobileNumber;
@property (strong, nonatomic) NSString *currentNavigationTitle;
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIImage *profilePictureImage;

-(void)cancel;
-(void)dismissAlert;

@end
