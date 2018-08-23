//
//  ChangePwd.m
//  InstaVoice
//
//  Created by EninovUser on 19/09/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "SettingsChangePwdViewController.h"
#import "ScreenUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "UpdateUserProfileAPI.h"

#define PWD_MIN 6
#define PWD_MAX 25

@interface SettingsChangePwdViewController ()

@end

@implementation SettingsChangePwdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateViewConstraintsForStoryBoard];

    CGRect rect = CGRectMake(SIZE_0, SIZE_0, SIZE_5, SIZE_34);
    UIView *ped = [[UIView alloc] initWithFrame:rect];
    UIView *ped1 = [[UIView alloc] initWithFrame:rect];
    UIView *ped2 = [[UIView alloc] initWithFrame:rect];
    
    self.hidesBottomBarWhenPushed = YES;//KM

    if([appDelegate.confgReader getPassword].length==0)
    {
        [self.pwdOld setHidden:YES];
        [self.pwdNew becomeFirstResponder];
         self.title = @"Set Password";
        
        self.pwdNew.leftView = ped1;
        self.pwdNew.leftViewMode = UITextFieldViewModeAlways;
        
        self.pwdNewAgain.leftView = ped2;
        self.pwdNewAgain.leftViewMode = UITextFieldViewModeAlways;
  
    }
    
  //  self.hidesBottomBarWhenPushed = YES;//KM
    else
    {
   
    [self.pwdOld becomeFirstResponder];
 
    self.title = @"Change Password";
    
    self.pwdOld.leftView = ped;
    self.pwdOld.leftViewMode = UITextFieldViewModeAlways;

    self.pwdNew.leftView = ped1;
    self.pwdNew.leftViewMode = UITextFieldViewModeAlways;

    self.pwdNewAgain.leftView = ped2;
    self.pwdNewAgain.leftViewMode = UITextFieldViewModeAlways;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)viewWillAppear:(BOOL)animated
{
    self.uiType = CHANGE_PWD_SCREEN;
    [appDelegate.stateMachineObj setCurrentUI:self];
    [super viewWillAppear:animated];
    [self createTopViewStoryBoardWithTitle:@"CHANGE_PASSS_TITLE"];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/**
 *This function renders back to the previous screen.
 */

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:shouldAnimatePushPop];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITextField's delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.pwdOld)
    {
        [self.pwdNew becomeFirstResponder];
    }
    else if(textField == self.pwdNew)
    {
        [self.pwdNewAgain becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        
    }
    return YES;
}

-(BOOL)emptyFieldValidation
{
    BOOL flag = NO;
    if(self.pwdOld.text == nil || [self.pwdOld.text length] == 0 )
    {
        [ScreenUtility showAlert: NSLocalizedString(@"OLD_PASS", nil)];
        self.pwdOld.text = @"";
        self.pwdOld.placeholder = NSLocalizedString(@"BLANK_PWD_HINT", nil);
        [self.pwdOld setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        return flag;
    }
    else if(![self.pwdOld.text isEqualToString:[appDelegate.confgReader getPassword]])
    {
        [ScreenUtility showAlert: NSLocalizedString(@"OLD_PWD_NOT_MATCHED", nil)];
        self.pwdOld.text = @"";
        self.pwdOld.placeholder = NSLocalizedString(@"OLD_PASS", nil);
        [self.pwdOld setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        return flag;
    }
    else if(self.pwdNew.text == nil || [self.pwdNew.text length] == 0 )
    {
        [ScreenUtility showAlert: NSLocalizedString(@"NEW_PASS",nil)];
        self.pwdNew.text = @"";
        self.pwdNew.placeholder = NSLocalizedString(@"BLANK_PWD_HINT",nil);
        [self.pwdNew setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        return flag;
        
    }
    else if([self.pwdNew.text length] < PWD_MIN  || [self.pwdNewAgain.text length] > PWD_MAX)
    {
        if([self.pwdNew.text length] < PWD_MIN)
            [ScreenUtility showAlert:NSLocalizedString(@"ALERT_PWD", nil)];
        else
            [ScreenUtility showAlert:NSLocalizedString(@"PWD_MAX_LIMIT", nil)];
        self.pwdNew.text = @"";
        self.pwdNewAgain.text = @"";
        self.pwdNew.placeholder = NSLocalizedString(@"HINT_PWD_ALERT", nil) ;
        [self.pwdNew setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [self.pwdNew becomeFirstResponder];
        return flag;
        
    }
    
    else if(self.pwdNewAgain.text == nil || [self.pwdNewAgain.text length] == 0)
    {
        [ScreenUtility showAlert: NSLocalizedString(@"NEW_PASS_AGAIN",nil)];
        self.pwdNewAgain.text = @"";
        self.pwdNewAgain.placeholder =  NSLocalizedString(@"BLANK_PWD_HINT",nil);
        [self.pwdNewAgain setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [self.pwdNewAgain becomeFirstResponder];
        return flag;
        
    }
    else if( !([self.pwdNew.text isEqualToString: self.pwdNewAgain.text]) )
    {
                [ScreenUtility showAlert: NSLocalizedString(@"PWD_NOT_MATCH",nil)];//FIELDS_ARE_NOT_MATCHED
        self.pwdNew.text      = @"";
        self.pwdNewAgain.text = @"";
        self.pwdNew.placeholder =  NSLocalizedString(@"PASSWORD",nil);
        self.pwdNewAgain.placeholder = NSLocalizedString(@"CONF_PASSWORD",nil);
        [self.pwdNew setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [self.pwdNewAgain setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [self.pwdNew becomeFirstResponder];
        EnLoge(@"new Password and new Password again TextField are not Equal");
        return flag;
    }
    else
    {
        int lenth = (int)[self.pwdNew.text length];
        char char1 = [self.pwdNew.text characterAtIndex:0];
        char char2 = [self.pwdNew.text characterAtIndex:lenth-1];
        if(char1 == ' ' || char2 == ' ')
        {
            [ScreenUtility showAlert:NSLocalizedString(@"PWD_LEADING_SPACES", nil)];
            self.pwdNew.text = @"";
            self.pwdNewAgain.text = @"";
            return flag;
        }

         flag = YES;
    }
   
    return flag;

}

///////modified by dpatel///////////
-(BOOL)emptyFieldValidationNewPassword
{
    BOOL flag = NO;
    if(self.pwdNew.text == nil || [self.pwdNew.text length] == 0 )
    {
        [ScreenUtility showAlert: NSLocalizedString(@"NEW_PASS",nil)];
        self.pwdNew.text = @"";
        self.pwdNew.placeholder = NSLocalizedString(@"BLANK_PWD_HINT",nil);
        [self.pwdNew setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        return flag;
        
    }
    else if([self.pwdNew.text length] < PWD_MIN  || [self.pwdNewAgain.text length] > PWD_MAX)
    {
        if([self.pwdNew.text length] < PWD_MIN)
            [ScreenUtility showAlert:NSLocalizedString(@"ALERT_PWD", nil)];
        else
            [ScreenUtility showAlert:NSLocalizedString(@"PWD_MAX_LIMIT", nil)];
        self.pwdNew.text = @"";
        self.pwdNewAgain.text = @"";
        self.pwdNew.placeholder = NSLocalizedString(@"HINT_PWD_ALERT", nil) ;
        [self.pwdNew setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [self.pwdNew becomeFirstResponder];
        return flag;
        
    }
    
    else if(self.pwdNewAgain.text == nil || [self.pwdNewAgain.text length] == 0)
    {
        [ScreenUtility showAlert: NSLocalizedString(@"NEW_PASS_AGAIN",nil)];
        self.pwdNewAgain.text = @"";
        self.pwdNewAgain.placeholder =  NSLocalizedString(@"BLANK_PWD_HINT",nil);
        [self.pwdNewAgain setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [self.pwdNewAgain becomeFirstResponder];
        return flag;
        
    }
    else if( !([self.pwdNew.text isEqualToString: self.pwdNewAgain.text]) )
    {
        [ScreenUtility showAlert: NSLocalizedString(@"PWD_NOT_MATCH",nil)];//FIELDS_ARE_NOT_MATCHED
        self.pwdNew.text      = @"";
        self.pwdNewAgain.text = @"";
        self.pwdNew.placeholder =  NSLocalizedString(@"PASSWORD",nil);
        self.pwdNewAgain.placeholder = NSLocalizedString(@"CONF_PASSWORD",nil);
        [self.pwdNew setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [self.pwdNewAgain setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [self.pwdNew becomeFirstResponder];
        EnLoge(@"new Password and new Password again TextField are not Equal");
        return flag;
    }
    else
    {
        int lenth = (int)[self.pwdNew.text length];
        char char1 = [self.pwdNew.text characterAtIndex:0];
        char char2 = [self.pwdNew.text characterAtIndex:lenth-1];
        if(char1 == ' ' || char2 == ' ')
        {
            [ScreenUtility showAlert:NSLocalizedString(@"PWD_LEADING_SPACES", nil)];
            self.pwdNew.text = @"";
            self.pwdNewAgain.text = @"";
            return flag;
        }
        
        flag = YES;
    }
    
    return flag;
    
}





///////////////////////////////////



-(IBAction)savePwdBtnAction:(id)sender
{
   
    
    
    
    
    int isNet = [Common isNetworkAvailable];
    if(isNet == NETWORK_AVAILABLE)
    {
        if([appDelegate.confgReader getPassword].length==0)
        {
          if([self emptyFieldValidationNewPassword])
          {
              NSMutableDictionary *userDic = [[NSMutableDictionary alloc]init];
              [userDic setValue:self.pwdNew.text forKey:USER_PWD];
              
              [self showProgressBar];
              UpdateUserProfileAPI* api = [[UpdateUserProfileAPI alloc]initWithRequest:userDic];
              [api updatePassword:self.pwdNew.text withSuccess:^(UpdateUserProfileAPI *req, BOOL responseObject) {
                  [self hideProgressBar];
                  [appDelegate.confgReader setPassword:self.pwdNew.text withTime:nil];
                  [self.navigationController popViewControllerAnimated:YES];
                  [ScreenUtility showAlertMessage:NSLocalizedString(@"PWD_CHANGED", nil)];
              } failure:^(UpdateUserProfileAPI *req, NSError *error) {
                  [self hideProgressBar];
                  NSInteger errorCode = error.code;
                  NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
                  [ScreenUtility showAlertMessage: errorMsg];
              }];
              
            }
        }
      else
        
        if([self emptyFieldValidation])
        {
            NSMutableDictionary *userDic = [[NSMutableDictionary alloc]init];
            [userDic setValue:self.pwdNew.text forKey:USER_PWD];
            
            [self showProgressBar];
            UpdateUserProfileAPI* api = [[UpdateUserProfileAPI alloc]initWithRequest:userDic];
            [api updatePassword:self.pwdNew.text withSuccess:^(UpdateUserProfileAPI *req, BOOL responseObject) {
                [self hideProgressBar];
                [appDelegate.confgReader setPassword:self.pwdNew.text withTime:nil];
                [self.navigationController popViewControllerAnimated:YES];
                [ScreenUtility showAlertMessage:NSLocalizedString(@"PWD_CHANGED", nil)];
            } failure:^(UpdateUserProfileAPI *req, NSError *error) {
                [self hideProgressBar];
                NSInteger errorCode = error.code;
                NSString *errorMsg = [Common convertErrorCodeToErrorString:(int)errorCode];
                [ScreenUtility showAlertMessage: errorMsg];
            }];
            
        }
        
    }
    else
    {
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

@end
