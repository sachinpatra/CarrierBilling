//
//  ShareFriendsListCellNonIv.h
//  InstaVoice
//
//  Created by Pandian on 27/03/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactData.h"
#import "ContactDetailData.h"
#import "ShareFriendsListCell.h"

@interface ShareFriendsListCellNonIv : ShareFriendsListCell
{
}

@property (weak, nonatomic) IBOutlet UILabel *contactName;
@property (weak, nonatomic) IBOutlet UIImageView *firstIcon;
@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (weak, nonatomic) IBOutlet UILabel *contactValue;
@property (weak, nonatomic) IBOutlet UILabel *contactSubType;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTrailingDistance;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactNameTopSpace;

- (void)configureShareMessageCellWithData:(ContactDetailData *)contatcData;

@end
