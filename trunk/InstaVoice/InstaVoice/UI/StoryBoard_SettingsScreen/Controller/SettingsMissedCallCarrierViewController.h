//
//  SettingsMissedCallCarrierViewController.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 9/15/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"

@interface SettingsMissedCallCarrierViewController : BaseUI<UITableViewDataSource,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *mobileNumberLabel;
@property (weak, nonatomic) IBOutlet UITableView *carrierTableView;
@property (strong, nonatomic) NSString *mobileNumberString;
@property (strong, nonatomic) NSString *defaultNetworkCarrier;
@property (strong, nonatomic) NSArray *mobileCarrierArray;
@property (assign, nonatomic) NSInteger selectedRow;
@property (assign, nonatomic) BOOL isOkTapped;
- (id)initWithMobileString:(NSString*)mobNumber andCarrier:(NSString*)defaultCarrier andDataArray:(NSArray*)array;
- (IBAction)selectTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;
@end
