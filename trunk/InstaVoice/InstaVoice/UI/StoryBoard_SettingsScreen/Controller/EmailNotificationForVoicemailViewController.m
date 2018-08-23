//
//  EmailNotificationForVoicemailViewController.m
//  InstaVoice
//
//  Created by kirusa on 2/5/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "EmailNotificationForVoicemailViewController.h"
#import "MZFormSheetController.h"
#import "MZCustomTransition.h"
#import "Common.h"

@interface EmailNotificationForVoicemailViewController ()

@end

@implementation EmailNotificationForVoicemailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _verifyEmailView.hidden = YES;
    _enterEmailView.hidden = NO;
    [_emailId becomeFirstResponder];
    _isCancelled = false;
    _isDone = false;
    _emailId.text = self.emailAddress;

    self.hidesBottomBarWhenPushed = YES;//KM
}

#pragma mark @ text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_emailId resignFirstResponder];
    return YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    NSString *text = [NSString stringWithString:textField.text];
//    text = [text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

#pragma mark @button actions

- (IBAction)doneButtonAction:(id)sender {
    
    //Nivedita - Added this check to fix the issue: 9300, Date 12th Apr
    if ([_emailId.text isEqualToString:self.emailAddress]) {

        [self cancelButtonAction:nil];
    }
    
    else if(![Common isValidEmail:_emailId.text]){
        //[ScreenUtility showAlertMessage:@"Please enter valid Email Id"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter valid Email Id" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [_emailId becomeFirstResponder];
    }
    else {
        _verifyEmailView.hidden = NO;
        _enterEmailView.hidden = YES;
        _emailIdLabel.text = _emailId.text;
        _isDone = true;
        _emailAddress = _emailId.text;
        [_emailId resignFirstResponder];
    }
    
}

- (IBAction)cancelButtonAction:(id)sender {
    _isCancelled = true;
    _isDone = false;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
}

- (IBAction)verifyButtonAction:(id)sender {
    _isCancelled = false;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
