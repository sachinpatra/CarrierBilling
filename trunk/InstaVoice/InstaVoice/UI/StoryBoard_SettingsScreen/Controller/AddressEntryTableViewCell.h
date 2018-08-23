//
//  AddressEntryTableViewCell.h
//  ThreadLearning
//
//  Created by adwivedi on 25/08/15.
//  Copyright (c) 2015 kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddressEntryTableViewCell;

@protocol AddressEntryDelegate <NSObject>
-(void)addressCell:(AddressEntryTableViewCell*)cell didEnteredCity:(NSString*)city;
-(void)addressCellDidClickStateButtonInCell:(AddressEntryTableViewCell*)cell;
-(void)addressCellDidClickCountryButtonInCell:(AddressEntryTableViewCell*)cell;
@end

@interface AddressEntryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *editableView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *countryButton;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (weak, nonatomic) IBOutlet UITextField *cityField;

@property(weak) id<AddressEntryDelegate> addressDelegate;

-(void)configureCellWithCity:(NSString*)city state:(NSString*)state country:(NSString*)country inEditingMode:(BOOL)editingMode;
@end
