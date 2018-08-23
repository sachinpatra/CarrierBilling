//
//  ContactTableViewCell.h
//  InstaVoice
//
//  Created by adwivedi on 15/05/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawCircle.h"
#import "FacebookData.h"
#import "ContactData.h"
#import "ContactDetailData.h"

@interface ContactTableViewInviteCell : UITableViewCell
{
}

@property (weak, nonatomic) IBOutlet UILabel *contactName;
@property (weak, nonatomic) IBOutlet UIImageView *firstIcon;
@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (weak, nonatomic) IBOutlet UILabel *contactValue;
@property (weak, nonatomic) IBOutlet UILabel *contactSubType;
@property (nonatomic,strong) NSIndexPath* selectedRowIndex;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTrailingDistance;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactNameTopSpace;


-(void)configureSMSInviteCellWithData:(ContactDetailData *)contactData withFlag:(BOOL)isSMS;
-(void)configureFBInviteCellWithData:(FacebookData *)dataDic;
-(void)configureShareMessageCellWithData:(ContactDetailData *)contatcData;

@end
