//
//  ConversationTableCellAudioReceived.h
//  InstaVoice
//
//  Created by Pandian on 19/12/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "ConversationTableCell.h"

@interface ConversationTableCellAudioReceived : ConversationTableCell
{
    int msgReadFlag;
    BOOL playing;
    int shareCount;
    NSString* msgType;
}

@property (weak, nonatomic) IBOutlet UIImageView *icon1;//VB
@property (weak, nonatomic) IBOutlet UILabel *fromName;
@property BOOL scrubbing;
- (IBAction)touchUpInside:(id)sender;
- (IBAction)dragInside:(id)sender;
- (IBAction)touchCancel:(id)sender;
- (IBAction)dragOutside:(id)sender;
- (IBAction)touchUpOutside:(id)sender;

@end
