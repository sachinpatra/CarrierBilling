//
//  ShareFriendsListViewController.h
//  InstaVoice
//
//  Created by kirusa on 11/13/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
#import "ContactSyncUtility.h"

@interface ShareFriendsListViewController : BaseUI <UITextFieldDelegate>
@property (nonatomic) BOOL isCancelled;
@property (strong, nonatomic) NSMutableArray *inviteList;
@property (nonatomic,weak)id<FriendInviteListProtocol> shareMessageDelegate;
@property (nonatomic, strong) NSDictionary *messageDictionary;

- (void)dismissViewController;
@end


