//
//  ConversationTableCell.m
//  InstaVoice
//
//  Created by Vivek Mudgil on 15/01/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "ConversationTableCell.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "IVFileLocator.h"
#import "SizeMacro.h"
#import "Logger.h"

#define TRANSPARENT_VIEW            100
#define STATUS_IMG                  101
#define MIN_WIDTH                   110
#define FONT_18_5                   18.5
#define INT_1                       1
#define INT_2                       2
#define INT_3                       3
#define INT_4                       4
#define INT_5                       5
#define SIZE_17_3                   17.3
#define SIZE_9_5                    9.5
#define SIZE_16_5                   16.5




@implementation ConversationTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self imageSetup];
    }
    return self;
}

- (void)setSharingIcons
{
    /* APR, 2017
    if(!twitterIcon)
        twitterIcon = [UIImage imageNamed:IMG_TWITTER_POST];
    
    if(!twitterGreyIcon)
        twitterGreyIcon = [UIImage imageNamed:IMG_TW_GREY_POST];
    
    if(!fbIcon)
        fbIcon = [UIImage imageNamed:IMG_FACEBOOK_POST];
    
    if(!fbGreyIcon)
        fbGreyIcon = [UIImage imageNamed:IMG_FB_GREY_POST];
    */
    if(!vbIcon)
        vbIcon = [UIImage imageNamed:IMG_VOBOLO_POST];
    
    if(!vbGreyIcon)
        vbGreyIcon = [UIImage imageNamed:IMG_VB_GREY_POST];
    
    /* APR 2017
    if(!fwdWhiteIcon)
        fwdWhiteIcon = [UIImage imageNamed:IMG_FWD_WHITE_IMG];//white iv icon
    
    if(!instaGreyIcon)
        instaGreyIcon = [UIImage imageNamed:IMG_INSTA_FWD_ICON];//iv icon
    
    if(!fwdWhiteMsgIcon)
        fwdWhiteMsgIcon = [UIImage imageNamed:IMG_FWD_MSG_WHITE_IMG];//arrow
    
    if(!fwdGreyIcon)
        fwdGreyIcon = [UIImage imageNamed:IMG_FWD_GREY_TEXT_IMG];//arrow
    
    if(!likedIcon)
        likedIcon = [UIImage imageNamed:IMG_LIKED];
    */
}

-(void) imageSetup
{
    [self setSharingIcons];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)configureCellForConversationListArray:(NSMutableArray *)conversationList cellForRowAtIndexPath:(NSIndexPath *)indexPath idType:(id)conversationClass withAddingEmptyCell:(BOOL)addempty
{
    arrayDictionary = conversationList;//TODO  TEST Jan 16, 2017
    [self configureCell];
}


-(void)configureCell
{
    // implemented by subclass
}


-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        if (((UITapGestureRecognizer *)gestureRecognizer).numberOfTapsRequired == 2)
        {
            return NO;
        }
    }
    return YES;
}

- (NSString*) getGroupMemberNameFromDic:(NSMutableDictionary*)dic {
    NSString *tempStr = [Common setPlusPrefix:[dic valueForKey:REMOTE_USER_NAME]];
    if( !tempStr )
        tempStr = [dic valueForKey:REMOTE_USER_NAME];
    
    if ([tempStr length] > 0)
        tempStr = [dic valueForKey:REMOTE_USER_NAME];
    
    NSString *formattedString = [Common getFormattedNumber:tempStr withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    if([formattedString length] != 0)
    {
        tempStr = formattedString;
    }

    return tempStr;
}

- (NSMutableAttributedString *)getMemberNameGroupChat:(NSString *)timeLocationString dic:(NSMutableDictionary *)dic
{
    NSMutableAttributedString *groupMemberNameString;
    NSString *tempStr = [Common setPlusPrefix:[dic valueForKey:REMOTE_USER_NAME]];
    if( !tempStr )
        tempStr = [dic valueForKey:REMOTE_USER_NAME];
    
    if ([tempStr length] > 0)
        tempStr = [dic valueForKey:REMOTE_USER_NAME];

    NSString *formattedString = [Common getFormattedNumber:tempStr withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    if([formattedString length] != 0)
    {
        tempStr = formattedString;
    }

    
    groupMemberNameString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@",tempStr,timeLocationString ]];
    [groupMemberNameString addAttributes:@{
                                           NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:10],
                                           NSForegroundColorAttributeName: [UIColor colorWithWhite:.45 alpha:1]
                                           }
                                   range:NSMakeRange(0, [tempStr length])];
    return groupMemberNameString;
    
}

-(void)showMenu:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [recognizer.view becomeFirstResponder];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect:recognizer.view.frame inView:recognizer.view.superview];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (void)tapOnLink:(UITapGestureRecognizer *)tapGesture
{
    
    if([self.delegate isAudioRecording])
        return;
    
   // UIButton* showMore = (UIButton*)tapGesture.view;
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        KLog(@"User tapped on the message");
    }
    
    SharedMenuLabel *textView = (SharedMenuLabel *)tapGesture.view;
    CGPoint point = [tapGesture locationInView:textView];
    
    if (textView.stringText.attributedText.length > 0 && CGRectContainsPoint(textView.stringText.bounds, point)) {
        UITextPosition *position = [textView.stringText closestPositionToPoint:point];
        
        UITextPosition *Pos1 = [textView.stringText positionFromPosition:position offset:-1];
        UITextPosition *Pos2 = [textView.stringText positionFromPosition:position offset:1];
        
        UITextRange *range = [textView.stringText textRangeFromPosition:Pos1 toPosition:Pos2];
        
        NSInteger startOffset = [textView.stringText offsetFromPosition:textView.stringText.beginningOfDocument toPosition:range.start];
        NSInteger endOffset = [textView.stringText offsetFromPosition:textView.stringText.beginningOfDocument toPosition:range.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        NSURL *url = nil;
        if (offsetRange.location == NSNotFound) {
            //return textView.stringText.superview;
        }
        if (offsetRange.location +offsetRange.length > textView.stringText.attributedText.length) {
            //return textView.stringText.superview;
        }
        @try {
            NSAttributedString *substring = [textView.stringText.attributedText attributedSubstringFromRange:offsetRange];
            if ([substring length] > 0) {
                url = [substring attribute:NSLinkAttributeName atIndex:0 effectiveRange:Nil];
                if(url) {
                    [[UIApplication sharedApplication] openURL:url];
                    [self.delegate resignTextResponder];
                    
                } else {
                    //[self.delegate showMore:msg_Dic withIndexNumber:rowNumber];
                }
            }
        }
        @catch (NSException * e) {
        }
    }
    else {
        [self.delegate showMore:(NSMutableDictionary*)self.dic withIndexPath:self.cellIndex];
    }
}

@end
