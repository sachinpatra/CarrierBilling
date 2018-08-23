//
//  BrandingScreenViewController.m
//  InstaVoice
//
//  Created by Jatin Mitruka on 3/25/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "BrandingScreenViewController.h"
#import "ConfigurationReader.h"
#import "MobileEntryViewController.h"
#import "IVFileLocator.h"
#import "Setting.h"
#import "UIImage+IVImageScale.h"
#import "IVColors.h"
@interface BrandingScreenViewController () <SettingProtocol>

@end

@implementation BrandingScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadCarrierLogoImage];
    [self updateBackgrounColorOfView];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
 // self.ivIcon.layer.cornerRadius=10.0f;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods - 
- (void)loadCarrierLogoImage {

    
    //Check for carrier logo information - for primary number.
    NSString *loginId = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
    NSString* localFileName = [NSString stringWithFormat:@"CarrierLogo_%@.png",loginId];
    
    NSString *storagePathName   = [IVFileLocator getCarrierLogoPath:localFileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:storagePathName]) {
        //We have carrier logo information.
        UIImage *logoImage = [UIImage imageWithContentsOfFile:storagePathName];
        
        if((logoImage.size.height < logoImage.size.width) || (logoImage.size.height > logoImage.size.width)) { //Rectangular image.
            //scale image to the same size as that of the - height of view.
            logoImage = [logoImage scaleImageToSize:CGSizeMake(_logoImageHolderView.frame.size.width, _logoImageHolderView.frame.size.height)];
            
            UIImageView *logoImageView = [[UIImageView alloc]initWithImage:logoImage];
            logoImageView.contentMode = UIViewContentModeScaleAspectFill;
            logoImageView.backgroundColor = [UIColor clearColor];
            [_logoImageHolderView addSubview:logoImageView];
            
        }
        
        else if(logoImage.size.height == logoImage.size.width) { //Square image
                //scale image to the same size as that of the - height of view.
                logoImage = [logoImage scaleImageToSize:CGSizeMake(_logoImageHolderView.frame.size.height, _logoImageHolderView.frame.size.height)];
                
                UIImageView *logoImageView = [[UIImageView alloc]initWithImage:logoImage];
                logoImageView.backgroundColor = [UIColor clearColor];
                [logoImageView setImage:logoImage];
                logoImageView.contentMode = UIViewContentModeScaleAspectFill;

                [_logoImageHolderView addSubview:logoImageView];
        }
        
    }
    else {
        //If no carrier logo for primary number - check do we have carrier logo path - try to download the information and update the logo, if failed to download the logo image - show the default logo.
        VoiceMailInfo *currentVoiceMailInfo = [[Setting sharedSetting]voiceMailInfoForPhoneNumber:[ConfigurationReader sharedConfgReaderObj].getLoginId];
        
        if ([currentVoiceMailInfo.carrierLogoPath length]) {
            //Start downlaoding the carrier logo image.
            [Setting sharedSetting].delegate = self;
            [[Setting sharedSetting]downloadAndSaveCarrierLogoImage:currentVoiceMailInfo.carrierLogoPath];
        }
        else {
            //We do not have carrier logo image
            NSString *mccmnc =[[ConfigurationReader sharedConfgReaderObj]getCountryMCCMNC];
            
            //Start: Nivedita - Date 1st Feb - As per latest requirement adding branding image for : TNM Malawi MCC MNC Code : 650 01
            if([mccmnc isEqualToString:NSLocalizedString(@"TNMMalawi", nil)])// require image and code for airtel nigeria
            {
                [_operatorBrandImage setImage:[UIImage imageNamed:@"TNMLogo"]];
            }
            //End: Nivedita
            else if([mccmnc isEqualToString:NSLocalizedString(@"AIRTEL_NIGERIA", nil)])// require image and code for airtel nigeria
            {
                [_operatorBrandImage setImage:[UIImage imageNamed:@"airtel_new"]];
            }
            else if([mccmnc isEqualToString:NSLocalizedString(@"VODAFONE_GHANA", nil)])// require image and code for airtel nigeria
            {
                [_operatorBrandImage setImage:[UIImage imageNamed:@"vodafone_ghana"]];
            }
            else if([mccmnc isEqualToString:NSLocalizedString(@"GLO_NIGERIA", nil)])//require image and code for glo nigeria
            {
                [_operatorBrandImage setContentMode:UIViewContentModeLeft];
                [_operatorBrandImage setImage:[UIImage imageNamed:@"glo_new"]];
            }
            // [_operatorBrandImage setImage:[UIImage imageNamed:@"airtel_new"]];//testing purpose -default image set
        }
    }
}

- (void)updateBackgrounColorOfView {
    
#if DEFAULT_THEMECOLOR_ENABLED
    self.view.backgroundColor = [IVColors redColor];
    
#else
        //NSString *primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
        NSString *carrierThemeColor = [[ConfigurationReader sharedConfgReaderObj]getLatestCarrierThemeColor];

        //NSString *carrierThemeColor = [[Setting sharedSetting]getCarrierThemeColorForNumber:primaryNumber];
        if (carrierThemeColor && [carrierThemeColor length])
            self.view.backgroundColor = [IVColors convertHexValueToUIColor:carrierThemeColor];
        else
            self.view.backgroundColor = [IVColors redColor];
#endif
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Setting Protocol Delegate Methods - 
- (void)fetchCarrierLogoPathCompletedWithStatus:(BOOL)withFetchStatus {
    [self loadCarrierLogoImage];
}


- (CGSize)resizeImageViewFromImageSize:(CGSize)imageSize toFitShowSize:(CGSize)showSize {
    CGFloat ratioW = imageSize.width / showSize.width;
    CGFloat ratioH = imageSize.height / showSize.height;
    
    CGFloat ratio = imageSize.width / imageSize.height;
    
    if (ratioW > 1 && ratioH > 1) {
        
        if (ratioW > ratioH) {
            imageSize.width = showSize.width;
            imageSize.height = imageSize.width / ratio;
        } else {
            imageSize.height = showSize.height;
            imageSize.width = imageSize.height * ratio;
        }
        
    } else if (ratioW > 1) {
        
        imageSize.width = showSize.width;
        imageSize.height = imageSize.width / ratio;
        
    } else if (ratioH > 1) {
        
        imageSize.height = showSize.height;
        imageSize.width = imageSize.height * ratio;
        
    } else {
        
        if (ratioW > ratioH) {
            
            if (showSize.width / imageSize.width <= 2) {
                imageSize.width = showSize.width;
                imageSize.height = imageSize.width / ratio;
            }
            
        } else {
            
            if (showSize.height / imageSize.height <= 2) {
                imageSize.height = showSize.height;
                imageSize.width = imageSize.height * ratio;
            }
            
        }
        
    }
    
    return imageSize;
}


@end
