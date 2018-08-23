//
//  RHSTableViewCellButton.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 5/16/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RHSTableViewCellButton : UIButton
@property(nonatomic,strong)NSString *defaultText;
@property(nonatomic,strong)NSString *enabledText;
@property(nonatomic,strong)NSString *defaultImage;
@property(nonatomic,strong)NSString *enabledImage;
-(void)setButtonConnected:(BOOL)selected;
@end
