//
//  CustomCellForViewTableViewCell.h
//  InstaVoice
//
//  Created by kirusa on 7/7/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCellForViewTableViewCell : UITableViewCell
@property(nonatomic,weak)IBOutlet UIButton *callButton;
//@property(nonatomic,weak)IBOutlet UIButton *addToPhoneBookButton;
@property(nonatomic,weak)IBOutlet UIButton *inviteButton;
@property(nonatomic,weak)IBOutlet UIButton *chatButton;
@property(nonatomic,weak)IBOutlet UILabel *phoneLabel;
@property(nonatomic,weak)IBOutlet UIImageView *instavoiceImage;
@property(nonatomic,weak)IBOutlet UILabel *lblType;
@end
