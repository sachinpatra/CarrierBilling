//
//  GroupChatMembersTableViewCell.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 8/14/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawCircle.h"
#import "GroupMemberData.h"
#import "IVFileLocator.h"
#import "Contacts.h"
#import "GroupUtility.h"

@interface GroupChatMembersTableViewCell : UITableViewCell
@property(nonatomic,weak)IBOutlet UIButton *callButton;
@property(nonatomic,weak)IBOutlet UILabel *memberName;
@property(nonatomic,weak)IBOutlet UILabel *memberPhoneNumber;
@property(nonatomic,weak)IBOutlet UILabel *memberPhoneNumberType;
@property (weak, nonatomic) IBOutlet UIView *circleView;
-(void)configureGroupMemberCellWithData:(GroupMemberData *)groupMember;
-(void)configureNewGroupCreationCellWithData:(CreateGroupMemberData *)contactData;
@end
