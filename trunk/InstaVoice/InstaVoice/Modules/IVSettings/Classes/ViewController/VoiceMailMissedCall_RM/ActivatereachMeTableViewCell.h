//
//  ActivatereachMeTableViewCell.h
//  InstaVoice
//
//  Created by Bhaskar Munireddy on 18/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivatereachMeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *flagImage;
@property (weak, nonatomic) IBOutlet UIButton *editDetailsButton;
@property (weak, nonatomic) IBOutlet UILabel *numberLable;
@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UIButton *unLinkNumber;
@property (weak, nonatomic) IBOutlet UIImageView *reachMeTypeIcon;
@property (weak, nonatomic) IBOutlet UILabel *reachMeTypeLable;
@property (weak, nonatomic) IBOutlet UILabel *reachMeTypeSubLable;
@property (weak, nonatomic) IBOutlet UITextView *carrierName;
@property (weak, nonatomic) IBOutlet UIView *reachMeModeView;
@property (weak, nonatomic) IBOutlet UITextView *infoText;
@property (weak, nonatomic) IBOutlet UILabel *activeStatus;
@property (weak, nonatomic) IBOutlet UIButton *requestSupport;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unlinkNumberTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoTextBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *infoIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoTextLeadingConstraint;
@property (weak, nonatomic) IBOutlet UITextView *reachMeDetailsTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reachMeDetailsTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UIButton *finishSetupButton;
@property (weak, nonatomic) IBOutlet UIButton *continueToPersonalisation;
@property (weak, nonatomic) IBOutlet UIButton *activateButton;

//Sachin
@property (weak, nonatomic) IBOutlet UIButton *bundleSubcriptionBtn;
@property (weak, nonatomic) IBOutlet UILabel *bundleSubscriptionValidLabel;

@end
