//
//  ProfilePicView.h
//  InstaVoice
//
//  Created by kirusa on 4/4/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"

#ifdef REACHME_APP
#import "AppDelegate_rm.h"
#else
#import "AppDelegate.h"
#endif

@class ProfilePicView;
@protocol ProfilePicViewDelegate <NSObject>
-(void) profilePickerController:(ProfilePicView*)view withImagePicker:(UIImagePickerController*)imagePickerView;
-(void) profilePickerController:(NSString*)selectedOrCancelled;
-(void) pathToSendTheFile:(NSString *)path;
@end

@interface ProfilePicView : UIView {
    UIImagePickerController *imagePickerViewController;
       AppDelegate *appDelegate;
     CustomIOS7AlertView *alertView;
}
@property(nonatomic,strong)UIButton *changePicButton;
@property(nonatomic,strong)UIImageView *userPicView;
@property (nonatomic,weak)id<ProfilePicViewDelegate> delegate;
@end
