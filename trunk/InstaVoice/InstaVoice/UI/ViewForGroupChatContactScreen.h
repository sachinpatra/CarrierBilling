//
//  ViewForGroupChatContactScreen.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 8/14/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif

#import "MarqueeLabel.h"
#import "MBProgressHUD.h"

typedef enum : NSInteger {
    GroupInfoSectionImage = 0,
    GroupInfoSectionTitle,
    GroupInfoSectionOwner,
    GroupInfoSectionMember
} GroupInfoSection;

@protocol ChatPhoneNumberGroupChatProtocol <NSObject>
    -(void)dismissedTheViewControllerGroupChat:(id)sender withIdentity:(NSString*)str;
@end

@interface ViewForGroupChatContactScreen : UIView<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{
    UILabel *nameLabelCreatedTime;
    UITableView *tableToSeeTheUserPhoneNo;
    //NSArray *nameArray;
    NSArray* grpMemberList;
    NSMutableArray* grpOwner;
    
    NSString* _groupIDString;
    AppDelegate *appDelegate;
    NSMutableDictionary* _activeConversationDictionary;
    MBProgressHUD *progressBar;
}

@property (strong, nonatomic) NSString *currentMobileNumber;
@property (nonatomic,strong)UIBarButtonItem *nameLabel;
@property (nonatomic,strong)UIBarButtonItem *cancelButton;
@property (nonatomic,strong)UIBarButtonItem *editLeaveButton;
@property (weak, nonatomic) id delegate;
@property (nonatomic, strong) UIImage *groupImage;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSString *titleLabelText;
@property BOOL editLeaveButtonClicked;

- (id)initWithFrame:(CGRect)frame withPhoneNumber:(NSString*)phoneNumber;
- (void)initializeVariable;
- (void)forReloadingOfTable;
- (void)fetchGroupInfo:(NSString*)groupId;

@end
