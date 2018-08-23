//
//  IVVoiceMailEmailNotificationViewController.h
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 29/06/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
@interface IVVoiceMailEmailNotificationViewController : BaseUI<UITableViewDelegate,UITableViewDataSource>{
    NSString *timeZone;
}
@property (weak, nonatomic) IBOutlet UITableView *voiceMailEmailNotificationTableView;

@end
