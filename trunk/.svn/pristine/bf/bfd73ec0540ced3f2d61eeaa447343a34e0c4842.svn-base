//
//  ConversationTableCellVMailSent.h
//  InstaVoice
//
//  Created by Pandian on 04/01/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "ConversationTableCell.h"
#import "KAudioSlider.h"

@interface ConversationTableCellVMailSent : ConversationTableCell
{
    int msgReadFlag;
    BOOL playing;
    int shareCount;
    NSString* msgType;
}

@property (weak, nonatomic) IBOutlet UIView *voiceView;
@property (weak, nonatomic) IBOutlet UIView *transcriptView;
@property (weak, nonatomic) IBOutlet UIImageView *transcriptImg;
@property (weak, nonatomic) IBOutlet UIImageView *playButton;
@property (weak, nonatomic) IBOutlet KAudioSlider *audioSlider;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UIImageView *icon1;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UILabel *fromUser;
@property (weak, nonatomic) IBOutlet UILabel *toUserAndLocation;
@property (weak, nonatomic) IBOutlet UITextView *transTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *tickImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transTextViewHeight;
@property BOOL scrubbing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callbackButtonLeadingSpaceToSV;

- (IBAction)callbackButtonAction:(id)sender;
- (IBAction)dragInside:(id)sender;
- (IBAction)touchUpInside:(id)sender;
- (IBAction)touchCancel:(id)sender;
- (IBAction)dragOutside:(id)sender;
- (IBAction)touchUpOutside:(id)sender;
@end
