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
#import "ContactTableViewCell.h"
/*
@protocol ContactTableViewCellDelegate <NSObject>
-(void)inviteButtonClickedForCellAtRow:(NSIndexPath*)row;
@end
*/

@interface ContactTableViewCellIv : ContactTableViewCell
{
}

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *subType;
@property (weak, nonatomic) IBOutlet UIImageView *instaBlue;
@property (weak, nonatomic) IBOutlet UIImageView *firstIcon;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;

@property (weak, nonatomic) IBOutlet UILabel *freshJoin;
@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblNameTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subTypeTopSpace;


//FEB 23, 2017 @property (nonatomic,weak)id<ContactTableViewCellDelegate> delegate;

-(IBAction)inviteButtonAction:(id)sender;
//-(void)configurePBCellWithDetailData:(ContactDetailData *)contactDetailData;
//-(void)configurePBCellWithData:(ContactData *)contactData;

@end
