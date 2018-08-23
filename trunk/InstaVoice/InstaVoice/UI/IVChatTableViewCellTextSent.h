//
//  IVChatTableViewCellTextSent.h
//  InstaVoice
//
//  Created by Pandian on 30/09/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVChatTableViewCell.h"

@interface IVChatTableViewCellTextSent : IVChatTableViewCell //UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadMsgCount;
@property (weak, nonatomic) IBOutlet UIImageView *msgIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *msgReadIndicator;

-(void)configureCellForChatTile:(NSMutableDictionary *)dic forRow:(int)rowValue;
-(void)setupFields;

@end
