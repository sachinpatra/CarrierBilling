//
//  IVChatTableViewCellTextReceived.m
//  InstaVoice
//
//  Created by Pandian on 30/09/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "IVChatTableViewCellTextReceived.h"
#import "IVColors.h"
#import "Macro.h"
#import "TableColumns.h"
#import "Common.h"
#import "ChatGridViewController.h"

@implementation IVChatTableViewCellTextReceived

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupFields
{
    //- remote user name
    NSString *remoteUserName = [self.dic valueForKey:REMOTE_USER_NAME];
    if(!remoteUserName || ![remoteUserName length]) {
        remoteUserName = [self.dic valueForKey:FROM_USER_ID];
    }
    
    //- format the number
    //TODO performance
    NSString* formattedString = [self formatPhoneNumberString:remoteUserName];
    if([formattedString length])
        self.usernameLabel.text = formattedString;
    else
        self.usernameLabel.text = remoteUserName;
    //
    
    self.messageContentLabel.textColor = [IVColors colorWithHexString:@"666666"];//[UIColor darkGrayColor];
    NSString* conversationType = [self.dic valueForKey:@"CONVERSATION_TYPE"];
    if([conversationType isEqualToString:@"g"])
    {
        self.profilePictureView.image = [UIImage imageNamed:@"default_profile_img_group"];
        if([[self.dic valueForKey:MSG_SUB_TYPE] isEqualToString:GROUP_MSG_EVENT_TYPE])
            self.messageContentLabel.text =  [Common formattedGroupChatEventInformation:[self.dic valueForKey:MSG_CONTENT]];
        else
            self.messageContentLabel.text = [self.dic valueForKey:@"MSG_CONTENT"];
    }
    else
    {
        self.profilePictureView.image = [UIImage imageNamed:@"default_profile_img_user"];
        self.messageContentLabel.text = [self.dic valueForKey:@"MSG_CONTENT"];
    }
    
    // load the user's profile picture, if they have one. If they don't, load the view to display instead
    NSArray* arr = [[Contacts sharedContact]getContactForPhoneNumber:[self.dic valueForKey:FROM_USER_ID]];
    ContactDetailData* detail = Nil;
    if([arr count]>0)
        detail = [arr objectAtIndex:0];
    
    if (detail)  {
        ContactData *data = detail.contactIdParentRelation;
        NSString *imageURLString = [IVFileLocator getNativeContactPicPath:data.contactPic];
        UIImage *profilePicture = [ScreenUtility getPicImage:imageURLString];
        if (profilePicture) {
            self.profilePictureView.image = profilePicture;
        }
        else if(data.contactPicURI) {
            [[Contacts sharedContact]downloadAndSavePicWithURL:data.contactPicURI picPath:imageURLString];
        }
    }
    
    // set up the cell's profile picture view constraints
    self.profilePictureView.clipsToBounds = YES;
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2;
    self.profilePictureView.contentMode = UIViewContentModeScaleAspectFill;
    
    // set up the date label on the cell
    NSNumber *remoteDate  = [self.dic valueForKey:@"MSG_DATE"];
    if (remoteDate) {
        /*Debug
        if([remoteUserName isEqualToString:@"918765768658"]) {
            KLog(@"yes");
        }*/
        
        self.dateLabel.text = [ScreenUtility dateConverter:remoteDate dateFormateString:NSLocalizedString(@"DATE_FORMATE_CHATGRID",nil)];
        
        int readCount = [[self.dic valueForKey:MSG_READ_CNT]intValue];
        if(!readCount) {
            self.dateLabel.textColor = [UIColor blackColor];
            [self.dateLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
        } else {
            self.dateLabel.textColor = [IVColors colorWithHexString:@"666666"];
            [self.dateLabel setFont:[UIFont systemFontOfSize:13.0]];
        }
    }
}

-(void)configureCellForChatTile:(NSMutableDictionary *)dic forRow:(int)rowValue
{
    [self setupFields];
    
    // load the user's name and the information from the last message sent
    [self.messageContentLabel sizeToFit];

    // unread message count
    self.unreadMsgCount.backgroundColor = UIColorFromRGB(0xff4422);
    self.unreadMsgCount.textColor = [UIColor whiteColor];
    self.unreadMsgCount.font = [UIFont systemFontOfSize:SIZE_12];
    self.unreadMsgCount.textAlignment = NSTextAlignmentCenter;
    self.unreadMsgCount.layer.masksToBounds = YES;
    self.unreadMsgCount.text = [self.dic valueForKey:UNREAD_MSG_COUNT];
    
    NSString* strUnreadMsgCount = [self.dic valueForKey:UNREAD_MSG_COUNT];
    int unreadMsgCount = [strUnreadMsgCount intValue];
    if(!unreadMsgCount) {
        self.unreadMsgCount.hidden = YES;
    }
    else {
        self.unreadMsgCount.hidden = NO;
        self.unreadMsgCount.text = strUnreadMsgCount;
        if([self.unreadMsgCount.text length]>2) {
            self.unreadMsgCount.text = @"99+";
            self.unreadMsgCount.layer.cornerRadius = 9;
        }
        else
            self.unreadMsgCount.layer.cornerRadius = self.unreadMsgCount.frame.size.width / 2;
    }
    
    [self.msgIndicator setImage:[UIImage imageNamed:@"chat-icon-seg"]];
    
}
@end
