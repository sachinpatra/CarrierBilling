//
//  ContactTableViewCell.m
//  InstaVoice
//
//  Created by adwivedi on 15/05/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "ContactTableViewInviteCell.h"
#import "ImgMacro.h"
#import "TableColumns.h"
#import "IVFileLocator.h"
#import "Contacts.h"
#import "ContactSyncUtility.h"
#import "Common.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"
#import "Setting.h"
#import "ConfigurationReader.h"
#import "IVImageUtility.h"

@interface ContactTableViewInviteCell()
@property (nonatomic, assign) NSInteger defaultNameTrailingSpace;

@end

@implementation ContactTableViewInviteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectedRowIndex = 0;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)configureSMSInviteCellWithData:(ContactDetailData *)contactDetailData withFlag:(BOOL)isSMS
{
    self.defaultNameTrailingSpace = 140.0;
    ContactData* contactData = contactDetailData.contactIdParentRelation;
    NSString *contactName = contactData.contactName;
    if(!contactName || !contactName.length) {
        contactName = contactDetailData.contactDataValue;
    }
    NSString *pic = [IVFileLocator getNativeContactPicPath:contactData.contactPic];
    NSString* picURL = Nil;
    if([contactData.isIV boolValue])
        picURL = contactData.contactPicURI;

    BOOL isGroup = NO;
    if([contactData.contactType integerValue] == ContactTypeIVGroup)
        isGroup = YES;

    [self setUserPicWithContactName:contactName picPath:pic picURL:picURL isGroup:isGroup
            profilePicDownloadState:contactData.picDownloadState];
    
    self.contactName.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    self.contactSubType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    self.contactValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    
    NSString* phoneNumber = nil;
    NSString *name = [Common setPlusPrefix:contactName];
    if(name != nil){
        self.contactName.text = [Common getFormattedNumber:name withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    }else{
        self.contactName.text = contactName;
    }
    
    //FEB 15, 2017
    if(!name.length && contactName.length) {
        phoneNumber = [Common getFormattedNumber:contactDetailData.contactDataValue withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        if(isSMS)
            self.contactNameTopSpace.constant = 3;
    } else {
        phoneNumber = nil;
        if(isSMS)
            self.contactNameTopSpace.constant = (self.contentView.frame.size.height/2)-21;
    }
    //
    
    self.firstIcon.hidden = YES;
    if (contactDetailData.contactDataSubType && ![contactDetailData.contactDataSubType isEqualToString:@""]) {
        self.contactSubType.text = contactDetailData.contactDataSubType;
        
    }
    else {
         self.contactSubType.text = @"";
    }
    
    if([contactDetailData.contactDataType isEqualToString:PHONE_MODE])
    {
        self.contactValue.text =  phoneNumber;
    }
    else
    {
        if([contactName isEqualToString:contactDetailData.contactDataValue])
            self.contactValue.text = @"";
        else
            self.contactValue.text = contactDetailData.contactDataValue;
    }

    if (contactDetailData.contactDataSubType && ![contactDetailData.contactDataSubType isEqualToString:@""]) {
        self.nameTrailingDistance.constant = self.defaultNameTrailingSpace;
    
    }
    else {
        self.nameTrailingDistance.constant = 0.0;
    }
    
    [self layoutSubviews];
}


-(void)configureFBInviteCellWithData:(FacebookData *)dataDic
{
    NSString  *contactName = dataDic.facebookName;
    NSString *pic = [IVFileLocator getFBUserPicPath:dataDic.facebookLocalPicPath];
    [self setUserPicWithContactName:contactName picPath:pic picURL:nil isGroup:NO
            profilePicDownloadState:@"Unknown"];
    
    NSString *name = [Common setPlusPrefix:contactName];
    if(name != nil){
        self.contactName.text = [Common getFormattedNumber:[Common addPlus:name] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    }else
        self.contactName.text = contactName;
    
    long fbIvId = [dataDic.fbIvId integerValue];
    if(fbIvId > 0)
    {
        [self.firstIcon setImage:[UIImage imageNamed:IMG_IC_LOGO_M]];
    }
    else
    {
        [self.firstIcon setImage:[UIImage imageNamed:IMG_IC_FB_M]];
    }
    self.contactValue.hidden = YES;
    self.contactSubType.hidden = YES;
}
 

-(void)setUserPicWithContactName:(NSString *)contactName picPath:(NSString *)picPath picURL:(NSString*)picURL isGroup:(BOOL)isUserGroup profilePicDownloadState:(NSString*)picDownloadState
{
    for(UIView *view in [self.circleView subviews])
    {
        [view removeFromSuperview];
    }
    
    UIImage *image = nil;
    if(picPath != nil)
    {
        image = [UIImage imageWithContentsOfFile:picPath];
    }
    
    UIImageView *imageView = [[UIImageView  alloc]init];
    imageView.frame = self.circleView.bounds; //CGRectMake(8.3, 8.3, SIZE_45, SIZE_45);
    imageView.layer.cornerRadius = imageView.frame.size.height / SIZE_2;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 2;
    imageView.layer.borderColor = (__bridge CGColorRef)([UIColor blackColor]);
    
    if(image != nil)
    {
        [imageView setImage:image];
        [self.circleView addSubview:imageView];
    }
    else
    {
        if(picURL != nil && picURL.length > 0)
        {
            [[Contacts sharedContact]downloadAndSavePicWithURL:picURL picPath:picPath];
        }
        //TODO: use picDownloadState
        if(isUserGroup)
            [imageView setImage:[UIImage imageNamed:@"default_profile_img_group"]];
        else
            [imageView setImage:[UIImage imageNamed:@"default_profile_img_user"]];
    }
    
    [self.circleView addSubview:imageView];
}

- (void)configureShareMessageCellWithData:(ContactDetailData *)contactDetailData {
    
    ContactData* contactData = contactDetailData.contactIdParentRelation;
    NSString *contactName = contactData.contactName;
    NSString *pic = [IVFileLocator getNativeContactPicPath:contactData.contactPic];
    NSString* picURL = Nil;
    if([contactData.isIV boolValue])
        picURL = contactData.contactPicURI;
    
    BOOL isGroup = NO;
    if([contactData.contactType integerValue] == ContactTypeIVGroup)
        isGroup = YES;
    
    [self setUserPicWithContactName:contactName picPath:pic picURL:picURL isGroup:isGroup
            profilePicDownloadState:contactData.picDownloadState];
    
    self.contactName.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    self.contactSubType.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    self.contactValue.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleCaption1];
    
    NSString *name = [Common setPlusPrefix:contactName];
    if(name != nil){
        NSString* fName = [Common getFormattedNumber:name withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        if(!fName)
            fName = contactName;
        self.contactName.text = fName;
    }else {
        self.contactName.text = contactName;
    }
    
    self.firstIcon.hidden = YES;
    if (contactDetailData.contactDataSubType && ![contactDetailData.contactDataSubType isEqualToString:@""]) {
        self.contactSubType.text = contactDetailData.contactDataSubType;
        
    }
    else {
        self.contactSubType.text = @"";
        
    }
    if([contactDetailData.contactDataType isEqualToString:PHONE_MODE])
    {
        NSString* contactDataValue = [NSString stringWithFormat:@"+%@",contactDetailData.contactDataValue];
        if(ContactTypeHelpSuggestion == (ContactType)[contactData.contactType intValue])
            self.contactValue.text = @"IV Support";
        else {
            //Format the number.
            if(contactDataValue != nil){
                NSString* formattedContact = [Common getFormattedNumber:contactDataValue withCountryIsdCode:nil withGivenNumberisCannonical:YES];
                if(!formattedContact)
                    formattedContact = contactDataValue;
                self.contactValue.text = formattedContact;
            }else {
                self.contactValue.text = contactDataValue;
            }
            
        }
        if(contactDetailData.contactIdParentRelation.groupId != Nil)
            self.contactValue.text = @"Group";
    }
    else
    {
        self.contactValue.text = contactDetailData.contactDataValue;
    }
}


@end
