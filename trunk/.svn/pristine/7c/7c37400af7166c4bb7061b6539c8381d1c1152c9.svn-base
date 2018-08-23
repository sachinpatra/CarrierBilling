//
//  ChangePrimaryNumberViewController.m
//  InstaVoice
//
//  Created by kirusa on 1/12/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "MZFormSheetController.h"
#import "MZCustomTransition.h"
#import "ChangePrimaryNumberViewController.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"
#import "Setting.h"
#import "Common.h"
#import "SizeMacro.h"

#define CELL_HEIGHT 40
@interface ChangePrimaryNumberViewController ()

@end

@implementation ChangePrimaryNumberViewController
@synthesize verifiedMobileNumberList;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.hidesBottomBarWhenPushed = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isSelected = false;
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [verifiedNumbersTable setTableFooterView:v];
    [verifiedNumbersTable reloadData];
}

- (BOOL)shouldAutorotate {
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskPortrait);
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark - UITableView's Delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{
    return [verifiedMobileNumberList count];
}


-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *someCell = @"cellIdentifier";
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:someCell];
    }
    
    UILabel *lblVerifiedNumber = [[UILabel alloc]initWithFrame:CGRectMake(SIZE_20, SIZE_4, SIZE_170, SIZE_30)];
    lblVerifiedNumber.textColor = [UIColor blackColor];
    lblVerifiedNumber.backgroundColor= [UIColor clearColor];
    
    lblVerifiedNumber.text = [Common getFormattedNumber:[verifiedMobileNumberList objectAtIndex:indexPath.row] withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    
    lblVerifiedNumber.font = [Common preferredFontForTextStyleInApp:UIFontTextStyleBody];
    lblVerifiedNumber.minimumScaleFactor = 0.5;
    lblVerifiedNumber.adjustsFontSizeToFitWidth = YES;
    
    [lblVerifiedNumber setLineBreakMode:NSLineBreakByTruncatingTail];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell addSubview:lblVerifiedNumber];
    if(indexPath.row == 0){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentPrimaryNumber = [verifiedMobileNumberList objectAtIndex:indexPath.row];
    
    _isSelected = true;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
}


#pragma mark - Action associated with buttons

-(IBAction)cancelBtnAction:(id)sender
{
    _isSelected = false;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
}

#pragma mark - Content Size Changed Notification Method -
- (void)preferredContentSizeChanged:(NSNotification *)withContentSizeChangedNotification {
    [verifiedNumbersTable reloadData];
}


//Clean Up Methods
- (void)dealloc {
    //Remove ContentSizeCategoryDidChangeNotification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    
}



@end
