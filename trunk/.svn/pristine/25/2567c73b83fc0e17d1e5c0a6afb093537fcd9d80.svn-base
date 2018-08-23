//
//  SharingSettingsViewController.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 4/16/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
#import "FetchSettingsSharingMenu.h"
#import "SettingsTableViewCell.h"
#import "FacebookWebViewScreen.h"
#import "SettingModel.h"


@interface SettingsSharingMenuViewController : BaseUI<FetchServiceOutput,UITableViewDataSource,UITableViewDelegate>
{
    FetchSettingsSharingMenu *objFetchSharingSettings;
    BOOL flag;
    BOOL fbflag;
    BOOL twflag;
    BOOL fbPostFlag;
    BOOL twPostFlag;

    __weak IBOutlet UIButton *appstoreConntectButton;
    __weak IBOutlet UIButton *closeBannerButton;
    
    UIView *bannerTopView;
    UIView *statusBarView;
    
    NSString               *_alertType;
    BOOL _fetchSettingFromServer;
    BOOL _btnClicked;
}
@property(nonatomic,strong) NSArray *fetchServiceResultArray;
@property(nonatomic,weak) IBOutlet UITableView *shareSettingsTableView;

@property (weak, nonatomic) IBOutlet UIView *channelsBannerView;
@property (weak, nonatomic) IBOutlet UIImageView *appStoreIcon;
@property (weak, nonatomic) IBOutlet UIView *bannerBackGroundView;
@property (weak, nonatomic) IBOutlet UILabel *bannerNoteLabel;

@end
