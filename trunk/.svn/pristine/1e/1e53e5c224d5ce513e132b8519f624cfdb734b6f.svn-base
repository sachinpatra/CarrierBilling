//
//  GroupChatEventCell.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 8/18/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "GroupChatEventCell.h"
#import "IVColors.h"
@implementation GroupChatEventCell

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

-(void)configureCell
{
    NSString *lineText = [Common formattedGroupChatEventInformation:[self.dic valueForKey:MSG_CONTENT]];
    
    NSNumber *msgTime  = [self.dic valueForKey:MSG_DATE];
    if(msgTime != Nil)
    {
        lineText = [NSString stringWithFormat:@"%@\n%@", lineText, [ScreenUtility dateConverter:msgTime dateFormateString:NSLocalizedString(@"DATE_FORMATE_CHATGRID",nil)]];//KM
//        lineText = [lineText stringByAppendingString:[ScreenUtility dateConverter:msgTime dateFormateString:NSLocalizedString(@"DATE_FORMATE_CHATGRID",nil)]];
    }
	//KM
    //self.groupInfoDetails.text = lineText;
    //DC MAY 17 2016
   // self.groupInfoDetails.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleFootnote];
    //self.groupInfoDetails.textColor = [IVColors colorWithHexString:@"666666"];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lineText];
    [attributedString addAttributes:@{
                                      NSForegroundColorAttributeName: [IVColors colorWithHexString:@"666666"],
                                      NSFontAttributeName: [Common preferredFontForTextStyleInApp:UIFontTextStyleFootnote]
                                      
                                      }
                              range:NSMakeRange(0, [lineText length])];//((NSString *)[[lineText componentsSeparatedByString:@"\n"] objectAtIndex:0]).length + 1)];

    
    self.groupInfoDetails.attributedText = attributedString;
    self.groupInfoDetails.preferredMaxLayoutWidth = 50.0;
	//
}

@end
