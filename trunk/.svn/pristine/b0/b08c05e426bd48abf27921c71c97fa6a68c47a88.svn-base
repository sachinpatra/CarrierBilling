//
//  IVChatTableViewCellTextSent.m
//  InstaVoice
//
//  Created by Pandian on 30/09/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "IVChatTableViewCellTextSent.h"
#import "IVColors.h"
#import "Macro.h"
#import "TableColumns.h"
#import "Common.h"
#import "ChatGridViewController.h"
#import "NBPhoneNumberUtil.h"
#import "NBAsYouTypeFormatter.h"
#import "ConversationApi.h"

@implementation IVChatTableViewCellTextSent

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
    
    /*
    if( [remoteUserName isEqualToString:@"cmp"]) {
        KLog(@"Debug");
    }*/
    
    self.messageContentLabel.textColor = [IVColors colorWithHexString:@"666666"];
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
        //UIFont* boldFont = [UIFont  boldSystemFontOfSize:[UIFont systemFontSize]];
        self.msgReadIndicator.hidden = NO;
        NSString* tickImage = @"";
        int readCount = [[self.dic valueForKey:MSG_READ_CNT]intValue];
        NSString* msgState = [self.dic valueForKey:MSG_STATE];
        if(readCount>0) {
            if ([conversationType isEqualToString:GROUP_TYPE]) {
                if([[self.dic valueForKey:MSG_SUB_TYPE] isEqualToString:GROUP_MSG_EVENT_TYPE])
                    tickImage = @"";
                else
                    tickImage = @"single_tick";
            } else {
                tickImage = @"double_tick";
            }
        }
        else if([msgState isEqualToString:API_DELIVERED] ||
                [msgState isEqualToString:API_DOWNLOADED] ) {
            tickImage = @"single_tick";
        }
        else if([msgState isEqualToString:API_NETUNAVAILABLE] || [msgState isEqualToString:API_UNSENT]) {
            tickImage = @"failed-msg";
        }
        else {
            tickImage = @"hour-glass";
        }
            
        self.dateLabel.textColor = [IVColors colorWithHexString:@"666666"];
        [self.dateLabel setFont:[UIFont systemFontOfSize:13.0]];
        
        NSMutableString* dateString = [[NSMutableString alloc]initWithString:@" "];
        [dateString appendString:self.dateLabel.text];
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:dateString];
        
        //combine image and label
        NSTextAttachment *attachment = nil;
        //OCT 6, 2016
        if(![msgState isEqualToString:API_WITHDRAWN]) {
            attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:tickImage];
        }
        //
        NSAttributedString *attachmentString=nil;
        if(attachment) {
            attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            [myString insertAttributedString:attachmentString atIndex:0];
            attachment = Nil;
        }
        self.dateLabel.attributedText = myString;
        //
    }
}


-(void)configureCellForChatTile:(NSMutableDictionary *)dic forRow:(int)rowValue
{
    [self setupFields];
    [self.messageContentLabel sizeToFit];
    
    // unread message count
    self.unreadMsgCount.backgroundColor = [UIColor redColor];
    self.unreadMsgCount.textColor = [UIColor whiteColor];
    self.unreadMsgCount.font = [UIFont systemFontOfSize:SIZE_12];
    self.unreadMsgCount.textAlignment = NSTextAlignmentCenter;
    self.unreadMsgCount.layer.masksToBounds = YES;
    self.unreadMsgCount.text =[self.dic valueForKey:UNREAD_MSG_COUNT];
    
    NSString* strUnreadMsgCount = [self.dic valueForKey:UNREAD_MSG_COUNT];
    int unreadMsgCount = [strUnreadMsgCount intValue];
    if(!unreadMsgCount) {
        self.unreadMsgCount.hidden = YES;
    }
    else {
        self.unreadMsgCount.hidden = NO;
        self.unreadMsgCount.text = strUnreadMsgCount;
        if([self.unreadMsgCount.text length]>2)
            self.unreadMsgCount.layer.cornerRadius = 9;
        else
            self.unreadMsgCount.layer.cornerRadius = self.unreadMsgCount.frame.size.width / 2;
    }
    
    //NSString* msgType = [dic valueForKey:MISSCALL];
    [self.msgIndicator setImage:[UIImage imageNamed:@"chat-icon-seg"]];
}

@end
