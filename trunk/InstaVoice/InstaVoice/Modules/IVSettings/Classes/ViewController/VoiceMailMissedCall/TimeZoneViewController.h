//
//  TimeZoneViewController.h
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 30/06/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeZoneViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *timeZoneTableView;
@end
