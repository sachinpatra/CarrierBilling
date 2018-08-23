//
//  AddressEntryTableViewCell.m
//  ThreadLearning
//
//  Created by adwivedi on 25/08/15.
//  Copyright (c) 2015 kirusa. All rights reserved.
//

#import "AddressEntryTableViewCell.h"

@implementation AddressEntryTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)cityDataEntered:(id)sender {
    [self.addressDelegate addressCell:self didEnteredCity:self.cityField.text];
}
- (IBAction)stateButtonClicked:(id)sender {
    [self.addressDelegate addressCellDidClickStateButtonInCell:self];
}
- (IBAction)countryButtonClicked:(id)sender {
    [self.addressDelegate addressCellDidClickCountryButtonInCell:self];
}
- (IBAction)cityValueChanged:(UITextField *)sender {
    [self.addressDelegate addressCell:self didEnteredCity:self.cityField.text];
}

-(void)configureCellWithCity:(NSString*)city state:(NSString*)state country:(NSString*)country inEditingMode:(BOOL)editingMode
{
    if(editingMode)
    {
        self.addressLabel.hidden = YES;
        self.editableView.hidden = NO;
        
        self.cityField.text = city;
        [self.stateButton setTitle:state forState:UIControlStateNormal];
        [self.countryButton setTitle:country forState:UIControlStateNormal];
    }
    else
    {
        self.addressLabel.hidden = NO;
        self.editableView.hidden = YES;
        NSString* address = [NSString stringWithFormat:@"%@ \n%@ \n%@",city,state,country];
        self.addressLabel.text = address;
    }
}

@end
