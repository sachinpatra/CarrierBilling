//
//  ConversationTableCellAudioSent.h
//  InstaVoice
//
//  Created by Pandian on 12/12/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "ConversationTableCell.h"

@interface ConversationTableCellAudioSent : ConversationTableCell
{
    int msgReadFlag;
    BOOL playing;
    int shareCount;
    NSString* msgStatus;
    NSString* msgType;
}

@property (weak, nonatomic) IBOutlet UIImageView *icon1;//VB
@property BOOL scrubbing;
- (IBAction)touchUpInside:(id)sender;
- (IBAction)dragInside:(id)sender;
- (IBAction)touchCancel:(id)sender;
- (IBAction)dragOutside:(id)sender;
- (IBAction)touchUpOutside:(id)sender;

@end
