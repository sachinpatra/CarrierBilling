//
//  IVInAppPromoViewController.m
//  InstaVoice
//
//  Created by Nivedita Angadi on 04/08/16.
//  Copyright © 2016 Kirusa. All rights reserved.
//

#import "IVInAppPromoViewController.h"
#import "ConfigurationReader.h"
#import "IVFileLocator.h"
#import "Setting.h"

@interface IVInAppPromoViewController () <SettingProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *inAppPromoImageView;

@end

@implementation IVInAppPromoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadPromoImage];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action Methods -
- (IBAction)promoImageScreenTapped:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        [[ConfigurationReader sharedConfgReaderObj]setInAppPromoImageShownStatus:YES];

    }];
}

#pragma mark - Private Methods -
- (void)loadPromoImage {
    
    // get your window screen size
   /* CGRect screenRect = [[UIScreen mainScreen] bounds];
    //create a new view with the same size
    UIView* coverView = [[UIView alloc] initWithFrame:screenRect];
    // change the background color to black and the opacity to 0.6
    coverView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1];
    // add this new view to your main view
    [self.view addSubview:coverView];
    */
    
    //Check for carrier logo information - for primary number.
    NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
    NSString* localFileName = [NSString stringWithFormat:@"PromoImage_%@.png",loginId];
    
    NSString *storagePathName   = [IVFileLocator getPromoImagePath:localFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:storagePathName]) {
        //We have carrier logo information.
        UIImage *promoImage = [UIImage imageWithContentsOfFile:storagePathName];
        self.inAppPromoImageView.image = promoImage;
    }
    else {
#ifndef REACHME_APP
        [[Setting sharedSetting]checkAndDownloadPromoImage:[Setting sharedSetting].data];
#endif
    }
    
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
