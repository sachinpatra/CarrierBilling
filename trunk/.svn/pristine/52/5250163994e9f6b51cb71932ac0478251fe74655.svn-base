//
//  EditableTextTableViewCell.h
//  InstaVoice
//
//  Created by adwivedi on 26/08/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {
    EditableFieldTypeName,
    EditableFieldTypeEmail,
    EditableFieldTypeCity
} EditableFieldType;

@protocol EditableTextTableViewCellDelegate <NSObject>
-(void)editableFieldOfType:(EditableFieldType)type textEntered:(NSString*)text;
@end


@interface EditableTextTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fieldType;
@property (weak, nonatomic) IBOutlet UITextField *fieldValue;
@property (strong, nonatomic) IBOutlet UIImageView *cellImage;

- (IBAction)textFieldValueChanged:(id)sender;
- (IBAction)textFieldEditingEnded:(id)sender;

@property(weak) id<EditableTextTableViewCellDelegate> delegate;
@property EditableFieldType editableFieldType;

@end
