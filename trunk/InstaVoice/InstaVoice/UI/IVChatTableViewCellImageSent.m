//
//  IVChatTableViewCellImageSent.m
//  InstaVoice
//
//  Created by Pandian on 30/09/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "IVChatTableViewCellImageSent.h"
#import "IVColors.h"
#import "Macro.h"
#import "TableColumns.h"
#import "ConversationApi.h"
#import "Logger.h"
#import "Common.h"

@implementation IVChatTableViewCellImageSent

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
    NSString* formattedString = [self formatPhoneNumberString:remoteUserName];
    if(formattedString.length)
        self.usernameLabel.text = formattedString;
    else
        self.usernameLabel.text = remoteUserName;
    
    NSString* conversationType = [self.dic valueForKey:@"CONVERSATION_TYPE"];
    if([conversationType isEqualToString:@"g"])
    {
        self.profilePictureView.image = [UIImage imageNamed:@"default_profile_img_group"];
    }
    else
    {
        self.profilePictureView.image = [UIImage imageNamed:@"default_profile_img_user"];
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
        //self.profilePictureView.image = profilePicture ? profilePicture : nil;
        if (profilePicture) {
            self.profilePictureView.image = profilePicture;
        }
        else if(data.contactPicURI)
        {
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
        /*
        if([remoteUserName isEqualToString:@"918765768658"]) {
            KLog(@"yes");
        }*/
        
        self.dateLabel.text = [ScreenUtility dateConverter:remoteDate dateFormateString:NSLocalizedString(@"DATE_FORMATE_CHATGRID",nil)];
        //UIFont* boldFont = [UIFont  boldSystemFontOfSize:[UIFont systemFontSize]];
        NSString* tickImage = @"";
        int readCount = [[self.dic valueForKey:MSG_READ_CNT]intValue];
        NSString* msgState = [self.dic valueForKey:MSG_STATE];
        if(readCount>0) {
            if ([conversationType isEqualToString:GROUP_TYPE])
                    tickImage = @"single_tick";
            else
                tickImage = @"double_tick";
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
        //[UIColor lightGrayColor];
        [self.dateLabel setFont:[UIFont systemFontOfSize:13.0]];
        
        NSMutableString* dateString = [[NSMutableString alloc]initWithString:@" "];
        [dateString appendString:self.dateLabel.text];
        
        //combine image and label
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        if(![msgState isEqualToString:API_WITHDRAWN]) {
            attachment.image = [UIImage imageNamed:tickImage];
        }
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:dateString];
        [myString insertAttributedString:attachmentString atIndex:0];
        self.dateLabel.attributedText = myString;
        //
    }
}

-(void)configureCellForChatTile:(NSMutableDictionary *)dic forRow:(int)rowValue
{
    [self setupFields];
    [self.messageContentLabel sizeToFit];
    
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
    
    // unread message count
    self.unreadMsgCount.backgroundColor = [UIColor redColor];
    self.unreadMsgCount.textColor = [UIColor whiteColor];
    self.unreadMsgCount.font = [UIFont systemFontOfSize:SIZE_12];
    self.unreadMsgCount.textAlignment = NSTextAlignmentCenter;
    self.unreadMsgCount.layer.masksToBounds = YES;
    
    [self.msgIndicator setImage:[UIImage imageNamed:@"image_icon"]];
    
    /* MAY 2017
    NSError *jsonError = nil;
    NSDictionary *imageContent = [NSJSONSerialization JSONObjectWithData:[[dic valueForKey:@"MSG_CONTENT"] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    if (jsonError) {
        self.messageContentLabel.text = @"Image";
    } else {
        NSString* imgCaption = [[imageContent valueForKey:@"txt"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([imgCaption length])
            self.messageContentLabel.text = [NSString stringWithFormat:@"%@", [imageContent valueForKey:@"txt"]];
        else
            self.messageContentLabel.text = @"Image";
    }*/
    
    NSString* annotation = [[dic valueForKey:ANNOTATION]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(annotation.length) {
        self.messageContentLabel.text = [NSString stringWithFormat:@"%@", annotation];
    } else {
        self.messageContentLabel.text = @"Image";
    }
    
}
@end
