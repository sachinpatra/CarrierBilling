//
//  CreateNewGroupMembersCell.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 9/2/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "CreateNewGroupMembersCell.h"
#import "Common.h"
#import "IVFileLocator.h"
#import "Contacts.h"
#import "ImgMacro.h"

@interface CreateNewGroupMembersCell()

@property(nonatomic, assign) NSInteger defaultNameLabelHeight;
@property(nonatomic, assign) NSInteger defaultNameLabelTopSpace;

@end


@implementation CreateNewGroupMembersCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)awakeFromNib {
    
    self.defaultNameLabelHeight = self.nameLabelHeighConstraint.constant;
    self.defaultNameLabelTopSpace = self.nameLabelTopSpaceConstraint.constant - 5;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithGroupMemberData:(CreateGroupMemberData *)withGroupMemberData {
    
    self.phoneNumberLabel.font = self.nameLabel.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    
    NSString *name = [Common setPlusPrefixChatWithMobile:withGroupMemberData.memberName];
    if(name != nil) {
        NSString *formattedNumber = [Common getFormattedNumber:[Common addPlus:name] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        self.phoneNumberLabel.text = formattedNumber;
        self.nameLabelHeighConstraint.constant = 0;
        self.nameLabelTopSpaceConstraint.constant = 0;
        
        //OCt 3, 2016
        if([self.nameLabel.text isEqualToString:formattedNumber]) {
            self.phoneNumberLabel.hidden = YES;
        } else {
            self.phoneNumberLabel.hidden = NO;
        }
        //
    }
    else {
        self.nameLabelHeighConstraint.constant = self.defaultNameLabelHeight;
        self.nameLabelTopSpaceConstraint.constant = self.defaultNameLabelTopSpace;
        self.nameLabel.text = withGroupMemberData.memberName;
        NSString* phoneNumberWithFormat = [Common getFormattedNumber:[Common setPlusPrefixChatWithMobile:withGroupMemberData.memberPhoneNumber] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        self.phoneNumberLabel.text = phoneNumberWithFormat;
        //OCt 3, 2016
        if([self.nameLabel.text isEqualToString:phoneNumberWithFormat]) {
            self.nameLabelHeighConstraint.constant = 0;
            self.nameLabelTopSpaceConstraint.constant = 0;
            //self.phoneNumberLabel.hidden = YES;
        } else {
            //self.phoneNumberLabel.hidden = NO;
        }
        //
    }
    
    self.iconImageView.image = ([withGroupMemberData.memberType isEqualToString:IV_TYPE])?[UIImage imageNamed:IMG_IC_LOGO_M]:nil;

    //Set the profile picture.
    NSString *pic = [IVFileLocator getNativeContactPicPath:withGroupMemberData.picPath];
    [self setUserPicWithContactName:nil picPath:pic picURL:nil isGroup:NO profilePicDownloadState:nil];
    
}

- (void)setUserPicWithContactName:(NSString *)contactName picPath:(NSString *)picPath picURL:(NSString*)picURL isGroup:(BOOL)isUserGroup profilePicDownloadState:(NSString*)downloadState
{
    //KM
    for(UIView *view in [self.circleView subviews]) {[view removeFromSuperview];}
    self.circleView.backgroundColor = [UIColor clearColor];
    self.circleView.clipsToBounds = YES;
    
    UIImage *image = picPath ? [UIImage imageWithContentsOfFile:picPath] : nil;
    UIImageView *imageView = imageView = [[UIImageView  alloc]init];
    imageView.frame = CGRectMake(0, 0, 40, 40);
    imageView.layer.cornerRadius = imageView.frame.size.height / SIZE_2;
    imageView.layer.masksToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if (image) {
        [imageView setImage:image];
    }
    else {
        if (picURL && picURL.length > 0) {
            [[Contacts sharedContact] downloadAndSavePicWithURL:picURL picPath:picPath];
        }
        //TODO: use downloadState
        if(isUserGroup)
            [imageView setImage:[UIImage imageNamed:@"default_profile_img_group"]];
        else
            [imageView setImage:[UIImage imageNamed:@"default_profile_img_user"]];
    }
    [self.circleView addSubview:imageView];
}

@end
