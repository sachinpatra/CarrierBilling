//
//  EditableTextTableViewCell.m
//  InstaVoice
//
//  Created by adwivedi on 26/08/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "EditableTextTableViewCell.h"

@interface EditableTextTableViewCell()

@end

@implementation EditableTextTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)textFieldValueChanged:(id)sender {
    [self.delegate editableFieldOfType:self.editableFieldType textEntered:self.fieldValue.text];
}

- (IBAction)textFieldEditingEnded:(id)sender {
    //[self.delegate editableFieldOfType:self.editableFieldType textEntered:self.fieldValue.text];
}

@end
