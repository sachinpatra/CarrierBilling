//
//  IVMediaSendingViewController.h
//  InstaVoice
//
//  Created by adwivedi on 11/09/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "BaseUI.h"

@protocol IVMediaSendingViewControllerDelegate <NSObject>
-(void)ivMediaSendingViewControllerDidCompleteSelectingImages:(NSMutableArray *)imageList shouldSetFrame:(BOOL)shouldSetFrame;
@end

@interface IVMediaSendingViewController : BaseUI <UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    NSMutableArray* _selectedImageList;
    UIImagePickerController* _imagePickerViewController;
    UIActionSheet* _addImageSheet;
    BOOL _firstTime;
}
@property(nonatomic,weak)id<IVMediaSendingViewControllerDelegate>delegate;
@property(nonatomic)UIImagePickerControllerSourceType sourceType;

@property (weak, nonatomic) IBOutlet UITextField *annotationView;
@property(nonatomic,strong)NSString* fromUserId;
@property (weak, nonatomic) IBOutlet UIButton *addMore;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *multipleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property(nonatomic,assign)NSInteger screenType; //- the screen name from which this viewcontroller is launched.
- (IBAction)sendImage:(id)sender;
- (IBAction)addImage:(id)sender;
- (IBAction)backButton:(id)sender;
- (IBAction)imageTapped:(id)sender;
- (void)cancel;
@end


@interface IVMediaData : NSObject
@property(nonatomic,strong)NSString* picName;
@property(nonatomic,strong)NSString* annotation;
@property(nonatomic,strong)UIImage* image;
@property(nonatomic,strong)NSString* picType;

@end
