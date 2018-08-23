//
//  IVMediaDisplayViewController.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 8/12/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "BaseUI.h"

@interface IVMediaDisplayViewController : BaseUI
{
    NSInteger _currentIndex;
    NSInteger _totalCount;
    BOOL _showOnlyImage;
    BOOL _annotationAvlbl;
}
@property(nonatomic,strong)NSArray *mediaList;
@property(nonatomic,strong)NSDictionary* currentMedia;
@property (weak, nonatomic) IBOutlet UIView *annotationView;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;

@property (weak, nonatomic) IBOutlet UITextView *annotation;

@property (weak, nonatomic) IBOutlet UIImageView *magnifiedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *labelImageView    ;

- (IBAction)showPreviousImage:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)showNextImage:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *mediaTitle;
@property (weak, nonatomic) IBOutlet UIButton *previousImage;
@property (weak, nonatomic) IBOutlet UIButton *nextImage;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipeGesture;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipeGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
- (IBAction)leftSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)rightSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)viewTapped:(id)sender;


@property(nonatomic,strong)NSString* currentChatUserName;

@end
