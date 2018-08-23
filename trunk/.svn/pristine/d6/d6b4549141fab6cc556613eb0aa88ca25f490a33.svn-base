//
//  EditVoiceMailImageIconViewController.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 28/07/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "EditVoiceMailImageIconViewController.h"
#import "IVPrimaryNumberVoiceMailViewController.h"

#define imageXPos ((DEVICE_WIDTH/3) - 80)/2
#define imageWidth 80.0
#define imageheight 80.0
#define tickMarkWidth 20.0
#define tickMarkHeight 20.0

@interface EditVoiceMailImageIconViewController ()
@property (nonatomic, strong) IVSettingsCountryCarrierInfo *selectedCountryCarrierInfo;
@end

@implementation EditVoiceMailImageIconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Select icon", nil);
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [self createImageView];
    // Do any additional setup after loading the view.
}

- (void)createImageView
{
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0.0, 60.0, DEVICE_WIDTH/3, imageheight)];
    
    self.homeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(imageXPos, 0.0, imageWidth, imageheight)];
    self.homeIcon.image = [UIImage imageNamed:@"settings_home"];
    [view1 addSubview:self.homeIcon];
    
    self.voiceMailHomeSelected = [[UIImageView alloc]initWithFrame:CGRectMake(self.homeIcon.frame.size.width - tickMarkWidth, self.homeIcon.frame.size.height - tickMarkHeight, tickMarkWidth, tickMarkHeight)];
    self.voiceMailHomeSelected.image = [UIImage imageNamed:@"voicemail_active"];
    [self.homeIcon addSubview:self.voiceMailHomeSelected];
    
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH/3, 60.0, DEVICE_WIDTH/3, imageheight)];
    
    self.workIcon = [[UIImageView alloc]initWithFrame:CGRectMake(imageXPos, 0.0, imageWidth, imageheight)];
    self.workIcon.image = [UIImage imageNamed:@"work"];
    [view2 addSubview:self.workIcon];
    
    self.voiceMailWorkSelected = [[UIImageView alloc]initWithFrame:CGRectMake(self.homeIcon.frame.size.width - tickMarkWidth, self.homeIcon.frame.size.height - tickMarkHeight, tickMarkWidth, tickMarkHeight)];
    self.voiceMailWorkSelected.image = [UIImage imageNamed:@"voicemail_active"];
    [self.workIcon addSubview:self.voiceMailWorkSelected];
    
    UIView *view3 = [[UIView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3)*2, 60.0, DEVICE_WIDTH/3, imageheight)];
    
    self.mobileRedIcon = [[UIImageView alloc]initWithFrame:CGRectMake(imageXPos, 0.0, imageWidth, imageheight)];
    self.mobileRedIcon.image = [UIImage imageNamed:@"mobile_red"];
    [view3 addSubview:self.mobileRedIcon];
    
    self.voiceMailRedSelected = [[UIImageView alloc]initWithFrame:CGRectMake(self.homeIcon.frame.size.width - tickMarkWidth, self.homeIcon.frame.size.height - tickMarkHeight, tickMarkWidth, tickMarkHeight)];
    self.voiceMailRedSelected.image = [UIImage imageNamed:@"voicemail_active"];
    [self.mobileRedIcon addSubview:self.voiceMailRedSelected];
    
    UIView *view4 = [[UIView alloc]initWithFrame:CGRectMake(0.0, view1.frame.size.height + 110.0, DEVICE_WIDTH/3, imageheight)];
    
    self.iPhoneIcon = [[UIImageView alloc]initWithFrame:CGRectMake(imageXPos, 0.0, imageWidth, imageheight)];
    self.iPhoneIcon.image = [UIImage imageNamed:@"iphone"];
    [view4 addSubview:self.iPhoneIcon];
    
    self.voiceMailIphoneSelected = [[UIImageView alloc]initWithFrame:CGRectMake(self.homeIcon.frame.size.width - tickMarkWidth, self.homeIcon.frame.size.height - tickMarkHeight, tickMarkWidth, tickMarkHeight)];
    self.voiceMailIphoneSelected.image = [UIImage imageNamed:@"voicemail_active"];
    [self.iPhoneIcon addSubview:self.voiceMailIphoneSelected];
    
    UIView *view5 = [[UIView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH/3, view1.frame.size.height + 110.0, DEVICE_WIDTH/3, imageheight)];
    
    self.mobileGreenIcon = [[UIImageView alloc]initWithFrame:CGRectMake(imageXPos, 0.0, imageWidth, imageheight)];
    self.mobileGreenIcon.image = [UIImage imageNamed:@"mobile_green"];
    [view5 addSubview:self.mobileGreenIcon];
    
    self.voiceMailGreenSelected = [[UIImageView alloc]initWithFrame:CGRectMake(self.homeIcon.frame.size.width - tickMarkWidth, self.homeIcon.frame.size.height - tickMarkHeight, tickMarkWidth, tickMarkHeight)];
    self.voiceMailGreenSelected.image = [UIImage imageNamed:@"voicemail_active"];
    [self.mobileGreenIcon addSubview:self.voiceMailGreenSelected];
    
    UIView *view6 = [[UIView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3)*2, view1.frame.size.height + 110.0, DEVICE_WIDTH/3, imageheight)];
    
    self.mobilePurpleIcon = [[UIImageView alloc]initWithFrame:CGRectMake(imageXPos, 0.0, imageWidth, imageheight)];
    self.mobilePurpleIcon.image = [UIImage imageNamed:@"mobile_purple"];
    [view6 addSubview:self.mobilePurpleIcon];
    
    self.voiceMailPurpleSelected = [[UIImageView alloc]initWithFrame:CGRectMake(self.homeIcon.frame.size.width - tickMarkWidth, self.homeIcon.frame.size.height - tickMarkHeight, tickMarkWidth, tickMarkHeight)];
    self.voiceMailPurpleSelected.image = [UIImage imageNamed:@"voicemail_active"];
    [self.mobilePurpleIcon addSubview:self.voiceMailPurpleSelected];
    
    self.homeIcon.userInteractionEnabled = YES;
    self.workIcon.userInteractionEnabled = YES;
    self.mobileRedIcon.userInteractionEnabled = YES;
    self.iPhoneIcon.userInteractionEnabled = YES;
    self.mobileGreenIcon.userInteractionEnabled = YES;
    self.mobilePurpleIcon.userInteractionEnabled = YES;
    
    self.voiceMailHomeSelected.hidden = YES;
    self.voiceMailWorkSelected.hidden = YES;
    self.voiceMailRedSelected.hidden = YES;
    self.voiceMailIphoneSelected.hidden = YES;
    self.voiceMailGreenSelected.hidden = YES;
    self.voiceMailPurpleSelected.hidden = YES;
    
    [self.view addSubview:view1];
    [self.view addSubview:view2];
    [self.view addSubview:view3];
    [self.view addSubview:view4];
    [self.view addSubview:view5];
    [self.view addSubview:view6];
    
    [self showTickMarkIconForSpecificImage];
    [self setGesturesForIcons];
    
}

- (void)setGesturesForIcons
{
    UITapGestureRecognizer *workImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(workIconSelected:)];
    [self.workIcon addGestureRecognizer:workImage];
    
    UITapGestureRecognizer *homeImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(homeIconSelected:)];
    [self.homeIcon addGestureRecognizer:homeImage];
    
    UITapGestureRecognizer *iPhoneImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iPhoneIconSelected:)];
    [self.iPhoneIcon addGestureRecognizer:iPhoneImage];
    
    UITapGestureRecognizer *redImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(redIconSelected:)];
    [self.mobileRedIcon addGestureRecognizer:redImage];
    
    UITapGestureRecognizer *greenImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(greenIconSelected:)];
    [self.mobileGreenIcon addGestureRecognizer:greenImage];
    
    UITapGestureRecognizer *purpleImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(purpleIconSelected:)];
    [self.mobilePurpleIcon addGestureRecognizer:purpleImage];
}

- (void)workIconSelected:(UITapGestureRecognizer *)reco
{
    self.iconName = @"work";
    self.voiceMailWorkSelected.hidden = NO;
    self.voiceMailHomeSelected.hidden = YES;
    self.voiceMailIphoneSelected.hidden = YES;
    self.voiceMailRedSelected.hidden = YES;
    self.voiceMailGreenSelected.hidden = YES;
    self.voiceMailPurpleSelected.hidden = YES;
}

- (void)homeIconSelected:(UITapGestureRecognizer *)reco
{
    self.iconName = @"settings_home";
    self.voiceMailWorkSelected.hidden = YES;
    self.voiceMailHomeSelected.hidden = NO;
    self.voiceMailIphoneSelected.hidden = YES;
    self.voiceMailRedSelected.hidden = YES;
    self.voiceMailGreenSelected.hidden = YES;
    self.voiceMailPurpleSelected.hidden = YES;
}

- (void)iPhoneIconSelected:(UITapGestureRecognizer *)reco
{
    self.iconName = @"iphone";
    self.voiceMailWorkSelected.hidden = YES;
    self.voiceMailHomeSelected.hidden = YES;
    self.voiceMailIphoneSelected.hidden = NO;
    self.voiceMailRedSelected.hidden = YES;
    self.voiceMailGreenSelected.hidden = YES;
    self.voiceMailPurpleSelected.hidden = YES;
}

- (void)redIconSelected:(UITapGestureRecognizer *)reco
{
    self.iconName = @"mobile_red";
    self.voiceMailWorkSelected.hidden = YES;
    self.voiceMailHomeSelected.hidden = YES;
    self.voiceMailIphoneSelected.hidden = YES;
    self.voiceMailRedSelected.hidden = NO;
    self.voiceMailGreenSelected.hidden = YES;
    self.voiceMailPurpleSelected.hidden = YES;
}

- (void)greenIconSelected:(UITapGestureRecognizer *)reco
{
    self.iconName = @"mobile_green";
    self.voiceMailWorkSelected.hidden = YES;
    self.voiceMailHomeSelected.hidden = YES;
    self.voiceMailIphoneSelected.hidden = YES;
    self.voiceMailRedSelected.hidden = YES;
    self.voiceMailGreenSelected.hidden = NO;
    self.voiceMailPurpleSelected.hidden = YES;
}

- (void)purpleIconSelected:(UITapGestureRecognizer *)reco
{
    self.iconName = @"mobile_purple";
    self.voiceMailWorkSelected.hidden = YES;
    self.voiceMailHomeSelected.hidden = YES;
    self.voiceMailIphoneSelected.hidden = YES;
    self.voiceMailRedSelected.hidden = YES;
    self.voiceMailGreenSelected.hidden = YES;
    self.voiceMailPurpleSelected.hidden = NO;
}

- (void)showTickMarkIconForSpecificImage
{
    if ([self.iconName isEqualToString:@"work"]) {
        self.voiceMailWorkSelected.hidden = NO;
    }else if ([self.iconName isEqualToString:@"settings_home"]){
        self.voiceMailHomeSelected.hidden = NO;
    }else if ([self.iconName isEqualToString:@"iphone"]){
        self.voiceMailIphoneSelected.hidden = NO;
    }else if ([self.iconName isEqualToString:@"mobile_red"]){
        self.voiceMailRedSelected.hidden = NO;
    }else if ([self.iconName isEqualToString:@"mobile_green"]){
        self.voiceMailGreenSelected.hidden = NO;
    }else if ([self.iconName isEqualToString:@"mobile_purple"]){
        self.voiceMailPurpleSelected.hidden = NO;
    }
}

- (void)doneAction
{
    NumberInfo *currentNumberInfo = [[Setting sharedSetting]customNumberInfoForPhoneNumber:self.phoneNumber];
    NumberInfo *updateNumberInfo = [[NumberInfo alloc]init];
    
    updateNumberInfo.phoneNumber = self.phoneNumber;
    updateNumberInfo.titleName = currentNumberInfo.titleName;
    updateNumberInfo.imgName = self.iconName;
    [[Setting sharedSetting]updateNumberSettingsInfo:updateNumberInfo];
    [self.navigationController popViewControllerAnimated:YES];
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
