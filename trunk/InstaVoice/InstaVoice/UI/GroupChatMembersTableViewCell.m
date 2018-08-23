//
//  GroupChatMembersTableViewCell.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 8/14/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "GroupChatMembersTableViewCell.h"
#import "IVImageUtility.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "Common.h"

@implementation GroupChatMembersTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureGroupMemberCellWithData:(GroupMemberData *)groupMember;
{
    
    NSString *pic = [IVFileLocator getNativeContactPicPath:groupMember.picLocalPath];
    
    //NOV 29, 2016
    if(nil==pic || !pic.length) {
        NSString* withoutPlus = [Common removePlus:groupMember.memberContactDataValue];
        NSArray* arr = [[Contacts sharedContact]getContactForPhoneNumber:withoutPlus];
        ContactDetailData* detail = nil;
        if([arr count]>0) {
            detail = [arr objectAtIndex:0];
        }
        
        if (detail)  {
            ContactData *data = detail.contactIdParentRelation;
            pic = [IVFileLocator getNativeContactPicPath:data.contactPic];
        }
    }
    //
    
    [self setUserPicWithContactName:groupMember.memberDisplayName picPath:pic picURL:groupMember.picRemoteUri profilePicDownloadState:@"Unknown"];
}

-(void)configureNewGroupCreationCellWithData:(CreateGroupMemberData *)contactData;
{
    NSString *pic = [IVFileLocator getNativeContactPicPath:contactData.picPath];
    [self setUserPicWithContactName:contactData.memberName picPath:pic picURL:nil
            profilePicDownloadState:@"Unknown"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.circleView.frame;
    self.imageView.center = self.circleView.center;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = self.imageView.frame.size.height / 2;
    //Jan 4, 2017 [self.callButton setImage:[UIImage imageNamed:@"callback"] forState:UIControlStateNormal];
    self.separatorInset = UIEdgeInsetsMake(self.separatorInset.top, self.memberPhoneNumber.frame.origin.x, self.separatorInset.bottom, self.separatorInset.right);
}

-(void)setUserPicWithContactName:(NSString *)contactName picPath:(NSString *)picPath picURL:(NSString*)picURL profilePicDownloadState:(NSString*)picDownloadState
{
    for(UIView *view in [self.circleView subviews])
    {
        [view removeFromSuperview];
    }
    
    DrawCircle* circleView = [[DrawCircle alloc]initWithFrame:CGRectMake(SIZE_0, SIZE_0, 50, 50) color:contactName radius:SIZE_22];
    circleView.backgroundColor = [UIColor clearColor];

    UIImage *image = nil;
    if(picPath != nil) {
        image = [UIImage imageWithContentsOfFile:picPath];
    }
    
    if(image) {
        self.imageView.image = image;
        
    } else {
        if(picURL != nil && picURL.length > 0)
        {
            [[Contacts sharedContact] downloadAndSavePicWithURL:picURL picPath:picPath];
        }

        //TODO: use picDownloadState
        [self.imageView setImage:[UIImage imageNamed:@"default_profile_img_user"]];
    }
}

@end
