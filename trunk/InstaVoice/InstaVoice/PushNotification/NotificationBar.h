//
//  NotificationBar.h
//  ServerAPITest
//
//  Created by EninovUser on 11/09/13.
//  Copyright (c) 2013 Eninov. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NotificationBar;

extern NSString *kNotificationBarTapReceivedNotification;

@interface NotificationBar : UIView

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *detailTextLabel;
@property (nonatomic, strong) IBOutlet UIImageView *logoImageView;

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSDictionary *msgPayLoad;

+ (NotificationBar *) notifyWithText:(NSString*)text
                              detail:(NSString*)detail
                               image:(UIImage*)image
                         andDuration:(NSTimeInterval)duration msgPayLoad:(NSDictionary*)payload;

+ (void) showNextNotification;

+ (UIImage*) screenImageWithRect:(CGRect)rect;

@end
