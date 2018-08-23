//
//  IVAccountSettingsLinkedNumberCell.h
//  InstaVoice
//
//  Created by Nivedita Angadi on 02/05/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVAccountSettingsProtocol.h"
@interface IVAccountSettingsLinkedNumberCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *linkedNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *successfullyVerifiedIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteLinkedNumberButton;
@property (nonatomic, assign) id<IVAccountSettingsDelegate> ivAccountSettingsDelegate;
@property (weak, nonatomic) IBOutlet UIButton *addLinkedNumberButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelToAddButtonHorizontalSpaceConstraint;

- (IBAction)verifyButtonTapped:(id)sender;
- (IBAction)deleteLinkedNumberButtonTapped:(id)sender;
- (IBAction)addLinkedNumberButtonTapped:(id)sender;

@end
