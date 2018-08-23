//
//  ChangePrimaryNumberViewController.h
//  InstaVoice
//
//  Created by kirusa on 1/12/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePrimaryNumberViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView    *verifiedNumbersTable;
}
@property (nonatomic) BOOL isSelected;
@property (strong, nonatomic) NSString *currentPrimaryNumber;
@property (nonatomic) NSMutableArray *verifiedMobileNumberList;

-(IBAction)cancelBtnAction:(id)sender;

@end
