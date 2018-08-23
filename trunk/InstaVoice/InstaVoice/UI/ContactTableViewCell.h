//
//  ContactTableViewCell.h
//  InstaVoice
//
//  Created by Pandian on 23/02/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ContactData.h"
#import "ContactDetailData.h"

@protocol ContactTableViewCellDelegate <NSObject>
-(void)inviteButtonClickedForCellAtRow:(NSIndexPath*)row;
@end

@interface ContactTableViewCell : UITableViewCell

@property (nonatomic,strong) NSIndexPath* selectedRowIndex;
@property (nonatomic,weak)id<ContactTableViewCellDelegate> delegate;

-(void)configurePBCellWithDetailData:(ContactDetailData *)contactDetailData;

@end

