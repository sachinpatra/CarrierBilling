//
//  LinkAdditionalMobileNumberViewController.h
//  InstaVoice
//
//  Created by kirusa on 12/19/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinkAdditionalMobileNumberViewController : UIViewController<UITextFieldDelegate>
{
    NSString *countryIsdCode;
    UIAlertView *alertMobileConfirmation;
    NSString *numberE164format;
}
@property (strong, nonatomic) IBOutlet UITextField *plusField;
@property (strong, nonatomic) IBOutlet UILabel *selectCountryLabel;
@property (weak, nonatomic) IBOutlet UIView *numberBorder;
@property (strong,nonatomic) NSString *mobileNumberEntered;
@property (strong,nonatomic) NSString *countryCodeEntered;
@property (weak, nonatomic) IBOutlet UIButton *selectCountryButton;
@property (strong,nonatomic) NSString *numberWithoutFormat;
@property (nonatomic) BOOL isOkButtonClicked;

@property (strong, nonatomic) IBOutlet UITextField *userId;
@property (strong, nonatomic) IBOutlet UIImageView *flagView;
- (IBAction)selectCountryButtonAction:(id)sender;

- (IBAction)okButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
@end
