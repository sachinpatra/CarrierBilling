//
//  IVChatTableViewCellReachMeCallReceived.h
//  InstaVoice
//
//  Created by Pandian on 8/9/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVChatTableViewCell.h"

@interface IVChatTableViewCellReachMeCallReceived : IVChatTableViewCell //UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadMsgCount;
@property (weak, nonatomic) IBOutlet UIButton *callbackIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *msgIndicator;
//@property (weak, nonatomic) IBOutlet UILabel *lblReachMe;
@property (weak, nonatomic) IBOutlet UILabel *labelFromTo;

-(void)configureCellForChatTile:(NSMutableDictionary *)dic forRow:(int)rowValue;
-(void)setupFields;
@end
