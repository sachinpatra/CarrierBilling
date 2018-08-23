//
//  ContactInvitePopUPAction.m
//  InstaVoice
//
//  Created by adwivedi on 16/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "ContactInvitePopUPAction.h"
#import "FriendsScreen.h"
#import "Macro.h"
#import "TableColumns.h"
#import "DrawCircle.h"
#import "IVFileLocator.h"
#import "ImgMacro.h"
#import "SizeMacro.h"
#import "ContactDetailData.h"
#import "IVFileLocator.h"
#import "NBPhoneNumberUtil.h"
#import "NBAsYouTypeFormatter.h"

#define NON_RETINA_IPHONE_HEIGHT 480

static ContactInvitePopUPAction *_sharedPopUPAction = nil;

@implementation ContactInvitePopUPAction
static  FriendsScreen *friend;

+(id)sharedPopUPAction
{
    if(_sharedPopUPAction == Nil)
    {
        _sharedPopUPAction = [ContactInvitePopUPAction new];
    }
    return _sharedPopUPAction;
}

+(void)setParentView:(id)parent
{
    friend = (FriendsScreen *)parent;
}

+(void)createContactAlert:(ContactData *)data alertType:(NSString *) alertType deviceHeight:(CGSize)deviceHeight alertView:(CustomIOS7AlertView *)popUp
{
    [popUp setDelegate:friend];
    NSInteger alertPos         = 0;
    NSInteger alertLength      = 0;
    
    UIView *container = [[UIView alloc]init];
    container.userInteractionEnabled = YES;
    [container setBackgroundColor:[UIColor colorWithRed:SIZE_216/SIZE_255 green:SIZE_221/SIZE_255 blue:SIZE_222/SIZE_255 alpha:SIZE_1]];
    container.layer.cornerRadius = SIZE_6;
    
    if(data != nil)
    {
        NSString *cntName = data.contactName;
        NSString * invitestr = nil;
        
        UILabel *inviteLabel = [[UILabel alloc]init];
        [inviteLabel setFont:[UIFont fontWithName:HELVETICANEUE_MEDIUM size:SIZE_18]];
        inviteLabel.numberOfLines = 2;
        [inviteLabel setTextColor:[UIColor blackColor]];
        [inviteLabel setBackgroundColor:[UIColor clearColor]];
        inviteLabel.textAlignment = NSTextAlignmentCenter;
        
        UILabel *carrierLabel = [[UILabel alloc]init];
        [carrierLabel setFont:[UIFont fontWithName: HELVETICANEUE_LIGHT size:SIZE_13]];
        carrierLabel.numberOfLines = 2;
        [carrierLabel setTextColor:[UIColor blackColor]];
        [carrierLabel setBackgroundColor:[UIColor clearColor]];
        carrierLabel.textAlignment = NSTextAlignmentCenter;
        
        NSArray *detailArray = [data.contactIdDetailRelation allObjects];
        UIScrollView  *scroll = [[UIScrollView alloc]init];
        
        int mCount = 0;
        int eCount = 0;
        int index  = 0;
        int count = 0;
        for(ContactDetailData *detailData in detailArray)
        {
            if([detailData.contactDataType isEqualToString:EMAIL_MODE])
                continue;
            
            if([detailData.ivUserId intValue] > 0 && [alertType isEqualToString:@"invite"])
                continue;
            
            UIView *contactView = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0, count, SIZE_268, SIZE_45)];
            UIView *separator = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0, SIZE_0, SIZE_268, SIZE_1)];
            contactView.tag = index;
            [separator setBackgroundColor:[UIColor lightGrayColor]];
            UIImageView *contactTypeImg = [[UIImageView alloc]initWithFrame:CGRectMake(SIZE_20, SIZE_15, SIZE_16, SIZE_16)];
            
            UILabel *contactId = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_50, SIZE_8, SIZE_150, SIZE_30)];
            if ([detailData.contactDataType isEqualToString:PHONE_MODE])
            {
                contactId.text = [Common getFormattedNumber:detailData.contactDataValue withCountryIsdCode:nil withGivenNumberisCannonical:YES];
            }
            else
            {
                contactId.text = detailData.contactDataValue;
            }
            contactId.backgroundColor = [UIColor clearColor];
            [contactId setFont:[UIFont fontWithName:HELVETICANEUE_LIGHT size:SIZE_15]];
            if([alertType isEqualToString:INVITE_ALERT])
            {
                UIButton *selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(SIZE_220, SIZE_1, SIZE_44, SIZE_44)];
                selectBtn.tag = 1;
                [selectBtn setImage:[UIImage imageNamed:IMG_IC_TICK_GRN_M] forState:UIControlStateNormal];
                [friend byDefaultSelected:detailData tag:index];
                [selectBtn addTarget:friend action:@selector(selectBtnInviteAction:) forControlEvents:UIControlEventTouchUpInside];
                [contactView addSubview:selectBtn];
            }
            else if([alertType isEqualToString:MANY_ID_ALERT])
            {
                UIImageView *rightArr = [[UIImageView alloc]initWithFrame:CGRectMake(SIZE_240, SIZE_14, SIZE_7, SIZE_16)];
                [rightArr setImage:[UIImage imageNamed:IMG_RIGHT_ARR_GRAY]];
                UIButton *conversationBtn = [[UIButton alloc]initWithFrame:CGRectMake(SIZE_0, SIZE_1, SIZE_268, SIZE_44)];
                conversationBtn.tag = [detailData.contactDataId integerValue];
                [conversationBtn addTarget:friend action:@selector(conversationBtnAction:) forControlEvents:UIControlEventTouchUpInside];
                [contactView addSubview:rightArr];
                [contactView addSubview:conversationBtn];
                
            }
            if(cntName ==  nil || [cntName length] == 0)
            {
                cntName = detailData.contactDataValue;
            }
            long long ivUserId = [detailData.ivUserId longLongValue];
            
            if(ivUserId > 0)
            {
                [contactTypeImg setImage:[UIImage imageNamed:IMG_IC_LOGO_M]];
                if([detailData.contactDataType isEqualToString:PHONE_MODE])
                {
                    mCount++;
                }
                else
                {
                    eCount++;
                }
            }
            else
            {
                if([detailData.contactDataType isEqualToString:PHONE_MODE])
                {
                    [contactTypeImg setImage:[UIImage imageNamed:IMG_IC_MOB_GREY]];
                    mCount++;
                }
                else
                {
                    [contactTypeImg setImage:[UIImage imageNamed:IMG_IC_EMAIL]];
                    eCount++;
                }
            }
            
            [contactView addSubview:contactTypeImg];
            [contactView addSubview:separator];
            
            [contactView addSubview:contactId];
            [scroll addSubview:contactView];
            count = count + 46;
            index = index + 1;
        }
        
        CGSize expectedLabelSize;
        CGSize expectedCarrierSize;
        
        __weak FriendsScreen *friends_ = friend;
        if([alertType isEqualToString:INVITE_ALERT])
        {
            carrierLabel.textAlignment = NSTextAlignmentLeft;
            inviteLabel.textAlignment = NSTextAlignmentLeft;
            
            invitestr = NSLocalizedString(@"INVITE_STR", nil);
            
            NSString *contactNumberWithFormatting = cntName;
            
            NSString *name = [Common setPlusPrefix:cntName];
            if(name != nil){
                contactNumberWithFormatting = [Common getFormattedNumber:name withCountryIsdCode:nil withGivenNumberisCannonical:YES];
            }
            
            if(mCount > 0 && eCount > 0)
            {
                invitestr = [invitestr stringByAppendingFormat:@"%@ %@",contactNumberWithFormatting, NSLocalizedString(@"INVITE_PERSON_NAME_SMS_EMAIL",nil)];
                
                // DC MAY 26 2016
                NSAttributedString *textAttributedString ;
                if (invitestr.length) {
                    textAttributedString = [[NSAttributedString alloc]initWithString:invitestr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:SIZE_20]}];
                }
                else
                    textAttributedString = [[NSAttributedString alloc]initWithString:@"" attributes:@{}];
                
                CGRect textStringRect = [textAttributedString boundingRectWithSize:CGSizeMake(SIZE_260, SIZE_59) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                
                expectedLabelSize = textStringRect.size;

                
                //expectedLabelSize = [invitestr sizeWithFont:[UIFont systemFontOfSize:SIZE_20] constrainedToSize:CGSizeMake(SIZE_260, SIZE_59) lineBreakMode:NSLineBreakByWordWrapping];
                inviteLabel.frame = CGRectMake(SIZE_10, SIZE_10, expectedLabelSize.width, expectedLabelSize.height);
                
                carrierLabel.text = NSLocalizedString(@"CHARGES_APPLY", nil);
                
                //
                // DC MAY 26 2016
                NSAttributedString *carrierTextAttributedString ;
                if (carrierLabel.text.length) {
                   carrierTextAttributedString = [[NSAttributedString alloc]initWithString:carrierLabel.text  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:SIZE_13]}];
                }
                else
                carrierTextAttributedString = [[NSAttributedString alloc]initWithString:@""  attributes:@{}];
                
                CGRect carrierTextStringRect = [carrierTextAttributedString boundingRectWithSize:CGSizeMake(SIZE_250, SIZE_35) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                
                expectedCarrierSize = carrierTextStringRect.size;
               // expectedCarrierSize = [carrierLabel.text sizeWithFont:[UIFont systemFontOfSize:SIZE_13] constrainedToSize:CGSizeMake(SIZE_250, SIZE_35) lineBreakMode:NSLineBreakByWordWrapping];
                
                carrierLabel.frame = CGRectMake(SIZE_10, expectedLabelSize.height + SIZE_10, expectedCarrierSize.width, expectedCarrierSize.height);
                
            }
            else if(mCount >0)
            {
                invitestr = [invitestr stringByAppendingFormat:@"%@ %@",contactNumberWithFormatting,NSLocalizedString(@"INVITE_PERSON_NAME_SMS",nil)];
                    //
                // DC MAY 26 2016
                NSAttributedString *expectedLabelAttributedString;
                if (invitestr.length) {
                    expectedLabelAttributedString = [[NSAttributedString alloc]initWithString:invitestr  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:SIZE_20]}];
                }
                else
                    expectedLabelAttributedString = [[NSAttributedString alloc]initWithString:@""  attributes:@{}];
                
                CGRect expectedLabelTextStringRect = [expectedLabelAttributedString boundingRectWithSize:CGSizeMake(SIZE_260, SIZE_59) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                
                expectedLabelSize = expectedLabelTextStringRect.size;
                //
                //expectedLabelSize = [invitestr sizeWithFont:[UIFont systemFontOfSize:SIZE_20] constrainedToSize:CGSizeMake(SIZE_260, SIZE_59) lineBreakMode:NSLineBreakByWordWrapping];
                inviteLabel.frame = CGRectMake(SIZE_10, SIZE_10, expectedLabelSize.width, expectedLabelSize.height);
                
                carrierLabel.text = NSLocalizedString(@"CHARGES_APPLY_SMS", nil);
                // DC MAY 26 2016
                NSAttributedString *carrierTextAttributedString ;
                if(carrierLabel.text.length)
                {
                    carrierTextAttributedString = [[NSAttributedString alloc]initWithString:carrierLabel.text  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:SIZE_13]}];
                }
                else
                   carrierTextAttributedString = [[NSAttributedString alloc]initWithString:@""  attributes:@{}];
                    
                CGRect carrierTextStringRect = [carrierTextAttributedString boundingRectWithSize:CGSizeMake(SIZE_250, SIZE_35) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                
                expectedCarrierSize = carrierTextStringRect.size;
                
                //expectedCarrierSize = [carrierLabel.text sizeWithFont:[UIFont systemFontOfSize:SIZE_13] constrainedToSize:CGSizeMake(SIZE_250, SIZE_35) lineBreakMode:NSLineBreakByWordWrapping];
                
                carrierLabel.frame = CGRectMake(SIZE_10, expectedLabelSize.height + SIZE_10, expectedCarrierSize.width, expectedCarrierSize.height);
            }
            else
            {
                invitestr =  [invitestr stringByAppendingFormat:@"%@ %@",contactNumberWithFormatting, NSLocalizedString(@"INVITE_PERSON_NAME_EMAIL", nil)];
                NSAttributedString *expectedLabelAttributedString;
                if (invitestr.length) {
                    expectedLabelAttributedString = [[NSAttributedString alloc]initWithString:invitestr  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:SIZE_20]}];
                }
                else
                    expectedLabelAttributedString = [[NSAttributedString alloc]initWithString:@""  attributes:@{}];
                CGRect expectedLabelTextStringRect = [expectedLabelAttributedString boundingRectWithSize:CGSizeMake(SIZE_260, SIZE_59) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                
                expectedLabelSize = expectedLabelTextStringRect.size;
                
               // expectedLabelSize = [invitestr sizeWithFont:[UIFont systemFontOfSize:SIZE_20] constrainedToSize:CGSizeMake(SIZE_260, SIZE_59) lineBreakMode:NSLineBreakByWordWrapping];
                inviteLabel.frame = CGRectMake(SIZE_10, SIZE_10, expectedLabelSize.width, expectedLabelSize.height);
            }
            
            inviteLabel.text  = invitestr;
            [popUp setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"CANCEL", nil), NSLocalizedString(@"SEND", nil), nil]];
            [popUp setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex)
             {
                 if (buttonIndex == 0)
                 {
                     [friends_ cancelBtnInviteAction];
                 }
                 else
                 {
                     [friends_ sendBtnInviteAction];
                 }
                 [alertView close];
             }];
        }
        else
        {
            inviteLabel.frame = CGRectMake(SIZE_10,SIZE_10, SIZE_250, SIZE_30);
            inviteLabel.text = cntName;
            
            carrierLabel.frame = CGRectMake(SIZE_10, SIZE_40, SIZE_250, SIZE_32);
            carrierLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"SELECT_IV_ID", nil),cntName];
            
            [popUp setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"CANCEL", nil), nil]];
            [popUp setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex)
             {
                 if (buttonIndex == 0)
                 {
                     [friends_ cancelBtnInviteAction];
                 }
                 [alertView close];
             }];
        }
        
        
        NSString *photo = [IVFileLocator getNativeContactPicPath:data.contactPic];
        float topSpace = inviteLabel.frame.size.height + carrierLabel.frame.size.height + SIZE_20;
        
        count = [detailArray count];
        int scrollViewHeight = 0;
        if(deviceHeight.height > NON_RETINA_IPHONE_HEIGHT)
        {
            if(count == 1)
            {
                scrollViewHeight = 42;
            }
            else if(count == 2)
            {
                scrollViewHeight = 84;
            }
            else if(count >=3)
            {
                scrollViewHeight = 126;
            }
        }
        else
        {
            if(count == 1)
            {
                scrollViewHeight = 42;
            }
            else if(count >= 2)
            {
                scrollViewHeight = 84;
            }
        }
        alertLength = topSpace + scrollViewHeight + 30;
        alertPos   = 150;
        if( (photo != nil) && (![photo isEqualToString:@""]))
        {
            UIImageView *contactPic = [[UIImageView alloc] initWithFrame:CGRectMake(SIZE_7_5, SIZE_7_5, SIZE_35, SIZE_35)];
            contactPic.layer.cornerRadius = contactPic.frame.size.height / SIZE_2;
            contactPic.layer.masksToBounds = YES;
            contactPic.layer.borderWidth = SIZE_2;
            contactPic.layer.borderColor = (__bridge CGColorRef)([UIColor blackColor]);
            UIImage *image = [UIImage imageWithContentsOfFile:photo];
            
            if(image != nil)
            {
                // image = [Common resizeImageToSize:image targerSize:imageView.frame.size];
                [contactPic setImage:image];
                alertLength = alertLength + 50;
                DrawCircle *circleView = [[DrawCircle alloc] initWithFrame:CGRectMake(SIZE_109, topSpace, 48, 48) color:cntName radius:SIZE_20];
                circleView.backgroundColor = [UIColor clearColor];
                [circleView addSubview:contactPic];
                [container addSubview:circleView];
                scroll.frame = CGRectMake(SIZE_0, topSpace + 50, SIZE_268, scrollViewHeight);
            }
            else
            {
                scroll.frame = CGRectMake(SIZE_0, topSpace, SIZE_268, scrollViewHeight);
            }
        }
        else
        {
            scroll.frame = CGRectMake(SIZE_0, topSpace, SIZE_268, scrollViewHeight);
        }
        scroll.userInteractionEnabled = YES;
        scroll.showsVerticalScrollIndicator = NO;
        scroll.contentSize = CGSizeMake(SIZE_268, SIZE_45 *[detailArray count]+SIZE_10);
        
        container.frame = CGRectMake(SIZE_0, SIZE_0, SIZE_268, alertLength - SIZE_14);
        container.backgroundColor = [UIColor clearColor];
        UIView *separator = [[UIView alloc]initWithFrame:CGRectMake(SIZE_0, alertLength - SIZE_59, SIZE_268, SIZE_1)];
        
        [separator setBackgroundColor:[UIColor lightGrayColor]];
        
        [container addSubview:carrierLabel];
        [container addSubview:scroll];
        [container addSubview:inviteLabel];
        
        [popUp setUseMotionEffects:true];
        [popUp setFrame:CGRectMake(SIZE_20, alertPos, SIZE_280, alertLength)];
        [popUp setContainerView:container];
        [popUp show];
    }
}
@end
