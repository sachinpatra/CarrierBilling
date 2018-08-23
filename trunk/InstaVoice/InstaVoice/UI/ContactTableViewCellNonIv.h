//
//  ContactTableViewCellNonIv.h
//  InstaVoice
//
//  Created by Pandian on 21/02/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactData.h"
#import "ContactDetailData.h"
#import "ContactTableViewCell.h"

/* FEb 23, 2017
@protocol ContactTableViewCellDelegate <NSObject>
-(void)inviteButtonClickedForCellAtRow:(NSIndexPath*)row;
@end
*/

@interface ContactTableViewCellNonIv : ContactTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *subType;
@property (weak, nonatomic) IBOutlet UIImageView *instaBlue;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;

@property (weak, nonatomic) IBOutlet UILabel *freshJoin;
@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblNameTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subTypeTopSpace;


//FEB 23, 2017 @property (nonatomic,weak)id<ContactTableViewCellDelegate> delegate;

- (IBAction)inviteButtonAction:(id)sender;

-(void)configurePBCellWithDetailData:(ContactDetailData *)contactDetailData;
//-(void)configurePBCellWithData:(ContactData *)contactData;
@end
