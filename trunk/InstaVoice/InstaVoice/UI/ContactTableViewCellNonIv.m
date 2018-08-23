//
//  ContactTableViewCellNonIv.m
//  InstaVoice
//
//  Created by Pandian on 21/02/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactTableViewCellNonIv.h"
#import "ImgMacro.h"

#ifdef REACHME_APP
#import "AppDelegate_rm.h"
#else
#import "AppDelegate.h"
#endif

#import "FriendsScreen.h"
#import "Macro.h"
#import "TableColumns.h"
#import "IVFileLocator.h"
#import "SizeMacro.h"
#import "Contacts.h"
#import "ContactSyncUtility.h"
#import "NBPhoneNumberUtil.h"
#import "NBAsYouTypeFormatter.h"
#import "IVImageUtility.h"

@implementation ContactTableViewCellNonIv

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectedRowIndex = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.separatorInset = UIEdgeInsetsMake(self.separatorInset.top, self.lblName.frame.origin.x, self.separatorInset.bottom, self.separatorInset.right);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)configurePBCellWithDetailData:(ContactDetailData *)contactDetailData
{
    NSString *contactName=nil;
    @try {
        contactName = contactDetailData.contactIdParentRelation.contactName;
        contactName = (contactName.length)?contactDetailData.contactIdParentRelation.contactName: contactDetailData.contactDataValue;
    } @catch (NSException *exception) {
        KLog(@"Debug");
    }
    
    NSString *pic = [IVFileLocator getNativeContactPicPath:contactDetailData.contactIdParentRelation.contactPic];
    NSString* picURL = Nil;
    if([contactDetailData.ivUserId boolValue])
        picURL = contactDetailData.contactIdParentRelation.contactPicURI;
    
    BOOL isGroup = ([[contactDetailData.contactIdParentRelation valueForKey:@"groupId"] length]);
    [self setUserPicWithContactName:contactName picPath:pic picURL:picURL isGroup:isGroup
            profilePicDownloadState:contactDetailData.contactIdParentRelation.picDownloadState];
    
    NSString* phoneNumber = nil;
    NSString *name = [Common setPlusPrefix:contactName];
    if(name != nil) {
        if([[contactDetailData.contactIdParentRelation valueForKey:@"groupId"] length] != 0) {
            self.lblName.text = contactName;
        } else {
            self.lblName.text = [Common getFormattedNumber:name withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        }
    }
    else {
        self.lblName.text = contactName;
    }
    
    if(!name.length && contactName.length) {
        phoneNumber = [Common getFormattedNumber:contactDetailData.contactDataValue withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        self.lblNameTopSpace.constant = 1;
        self.subTypeTopSpace.constant = 1;
    } else {
        phoneNumber = nil;
        //self.lblNameTopSpace.constant = (self.contentView.frame.size.height/2)-21;
        //self.subTypeTopSpace.constant = self.lblNameTopSpace.constant;
    }
    
    self.lblName.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    
    NSNumber *isNewJoin = contactDetailData.contactIdParentRelation.isNewJoinee;
    if([isNewJoin boolValue])
    {
        self.freshJoin.hidden = NO;
        self.freshJoin.text = NSLocalizedString(@"JUST_JOINED",nil);
    }
    else
    {
        self.freshJoin.hidden = YES;
    }
    
    [self.instaBlue setImage:nil];
    
    BOOL isIv = [contactDetailData.ivUserId boolValue];
    if(isIv)
    {
        if([contactDetailData.contactIdParentRelation.contactType integerValue] == ContactTypeIVGroup)
        {
            [self.instaBlue setImage: [[UIImage imageNamed:@"user_type_group"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            self.instaBlue.tintColor = [UIColor lightGrayColor];
        }
        else
        {
            [self.instaBlue setImage: nil];
        }
        //self.phoneNumberLeadingSpace.constant = 8+16+8;
    }
    else
    {
        //self.phoneNumberLeadingSpace.constant = 8;
    }
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.subType.text = contactDetailData.contactDataSubType;
    self.subType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    
    self.phoneNumber.text = phoneNumber;
    self.phoneNumber.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    self.phoneNumber.textColor = UIColorFromRGB(0x767779);
    
    NSArray* supportContact = [Setting sharedSetting].supportContactList;
    for(NSDictionary* dic in supportContact) {
        NSString* supportContactData = [dic valueForKey:SUPPORT_DATA_VALUE];
        if([contactDetailData.contactDataValue isEqualToString: supportContactData] ) {
            self.phoneNumber.text = @"";
        }
    }
    
    /* Debug
    self.freshJoin.text = NSLocalizedString(@"JUST_JOINED",nil);
    self.freshJoin.hidden = NO;
     */
}

-(void)configurePBCellWithData:(ContactData *)contactData {
    EnLogd(@"NO_IMPL");
}

- (IBAction)inviteButtonAction:(id)sender {
    [self.delegate inviteButtonClickedForCellAtRow:self.selectedRowIndex];
}

-(void)setUserPicWithContactName:(NSString *)contactName picPath:(NSString *)picPath picURL:(NSString*)picURL isGroup:(BOOL)isUserGroup profilePicDownloadState:(NSString*)downloadState
{
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
