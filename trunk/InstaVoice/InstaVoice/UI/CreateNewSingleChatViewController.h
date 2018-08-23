//
//  CreateNewSingleChatViewController.h
//  InstaVoice
//
//  Created by Kieraj Mumick on 6/26/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "FriendsScreen.h"

@interface CreateNewSingleChatViewController : FriendsScreen <UITableViewDataSource, UITableViewDelegate>

/**
 *  This must be set up before the this controller is presented.
 *
 *  This allows for us to push the new chat onto the correct navigation stack in the tab bar controller
 */
@property (strong, nonatomic) UITabBarController *callingTabBarController;


@end
