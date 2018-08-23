//
//  IVVoiceMailGreetingsRecordTableViewCell.h
//  InstaVoice
//
//  Created by Nivedita Angadi on 10/03/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVVoiceMailCarrierSelectionProtocol.h"

@interface IVVoiceMailGreetingsRecordTableViewCell : UITableViewCell

- (IBAction)valueChanged:(id)sender;
- (IBAction)touchOutSide:(id)sender;
- (IBAction)touchInSide:(id)sender;
- (IBAction)dragOutSide:(id)sender;
- (IBAction)dragInside:(id)sender;
- (IBAction)touchCancel:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *audioDuration;
@property (weak, nonatomic) IBOutlet UISlider *audioSlider;
@property (weak, nonatomic) IBOutlet UIImageView *playButton;
@property (weak, nonatomic) IBOutlet UIView *voiceView;
@property (weak, nonatomic) IBOutlet UILabel *recordDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) id<IVVoiceMailCarrierSelectionProtocol> greetingsRecordTableViewCellDelegate;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *currentRecorindgButton;
@property (weak, nonatomic) IBOutlet UILabel *recordInfoTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailsLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonHeightConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentRecoridngHeightConstraints;
- (IBAction)cancelRecordButtonTapped:(id)sender;
- (IBAction)recordButtonTapped:(id)sender;
- (IBAction)playRecordingButtonTapped:(id)sender;

@end
