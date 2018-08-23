//
//  ChangePwd.h
//  InstaVoice
//
//  Created by Vinoth on 23/04/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "BaseUI.h"

@interface SettingsChangePwdViewController : BaseUI
@property(nonatomic,weak)IBOutlet UITextField *pwdOld;
@property(nonatomic,weak)IBOutlet UITextField *pwdNew;
@property(nonatomic,weak)IBOutlet UITextField *pwdNewAgain;
@property(nonatomic,weak)IBOutlet UIView *containerView;
@property(nonatomic,weak)IBOutlet UIButton *saveBtn;

-(IBAction)savePwdBtnAction:(id)sender;

@end
