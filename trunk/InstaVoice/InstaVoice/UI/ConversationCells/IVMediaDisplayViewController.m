//
//  IVMediaDisplayViewController.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 8/12/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "IVMediaDisplayViewController.h"
#import "IVMediaLoader.h"
#import "IVFileLocator.h"

@interface IVMediaDisplayViewController ()<UIScrollViewDelegate>

@end

@implementation IVMediaDisplayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _showOnlyImage = YES;
        _annotationAvlbl = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _currentIndex = 0;
    _totalCount = [self.mediaList count];
    long currentMsgId = 0;
    if([self.currentMedia valueForKey:MSG_ID])
    {
        currentMsgId =  [[self.currentMedia valueForKey:MSG_ID] longValue];
    }
    for(int i =0;i<[self.mediaList count];i++)
    {
        long msgId = [[[self.mediaList objectAtIndex:i]valueForKey:MSG_ID]longValue];
        if(currentMsgId == msgId)
        {
            _currentIndex = i;
            break;
        }
    }
    /*if(self.currentChatUserName && self.currentChatUserName.length > 0)
        [self.backButton setTitle:self.currentChatUserName forState:UIControlStateNormal];*/
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_currentIndex < _totalCount)
    {
        [self imageDataSetupForDictionary:[self.mediaList objectAtIndex:_currentIndex]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPreviousImage:(id)sender {
    _currentIndex = _currentIndex - 1;
    [self imageDataSetupForDictionary:[self.mediaList objectAtIndex:_currentIndex]];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)showNextImage:(id)sender {
    _currentIndex = _currentIndex + 1;
    [self imageDataSetupForDictionary:[self.mediaList objectAtIndex:_currentIndex]];
}

-(void)imageDataSetupForDictionary:(NSDictionary*)mediaDic
{
    [self changeButtonState];
    NSString      *msgContentType   = [[mediaDic valueForKey:MSG_CONTENT_TYPE] lowercaseString];
    if([msgContentType isEqualToString:IMAGE_TYPE])
    {
        //sender side image data
        UIImage *image = nil;
        NSString* msgLocalPath = [mediaDic valueForKey:MSG_LOCAL_PATH];
        if(msgLocalPath && msgLocalPath.length > 1)
        {
            NSString* localPath = [IVFileLocator getMediaImagePath:msgLocalPath];
            localPath = [[localPath stringByDeletingPathExtension]stringByAppendingPathExtension:@"jpg"];
            if(localPath != nil)
            {
                image = [UIImage imageWithContentsOfFile:localPath];
                if(image)
                {
                    self.magnifiedImageView.image = image;
                    //self.imageScrollView.contentSize = image.size;
                    self.imageScrollView.zoomScale = 1.0;
                    [self.imageScrollView setNeedsUpdateConstraints];
                }
            }
        }
        
        if(image == Nil)
        {
            NSString *msgContent = [mediaDic valueForKey:MSG_CONTENT];
            NSData *data = [msgContent dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *imageData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSMutableArray* imageArr = [imageData valueForKey:@"img"];
            for(NSMutableDictionary* imageDic in imageArr)
            {
                NSString* thumbnailURL = [imageDic valueForKey:@"thumb_url"];
                NSString* imageUrl = [imageDic valueForKey:@"url"];
                NSString* base64String = [imageDic valueForKey:@"thumb_base64"];
                
                NSString* msgLocalPath = [mediaDic valueForKey:MSG_LOCAL_PATH];
                if(!msgLocalPath || msgLocalPath.length == 0)
                {
                    msgLocalPath = [[mediaDic valueForKey:MSG_ID]stringValue];
                }
                
                UIImage* imgThumbnail = [[IVMediaLoader sharedIVMediaLoader]getThumbnailImageForLocalPath:msgLocalPath serverPath:thumbnailURL base64String:base64String];
                
                UIImage* imgMain = [[IVMediaLoader sharedIVMediaLoader]getImageForLocalPath:msgLocalPath serverPath:imageUrl];
                
                
                if(imgMain)
                    self.magnifiedImageView.image = imgMain;
                else if(imgThumbnail)
                    self.magnifiedImageView.image = imgThumbnail;
                else
                {
                    self.magnifiedImageView.image = Nil;
                }
            }
        }
        
    }
    NSString* annotation = [mediaDic valueForKey:ANNOTATION];
    if(annotation && annotation.length > 0)
    {
        _annotationAvlbl = YES;
        self.annotation.hidden = NO;
        self.annotation.text = annotation;
        self.labelImageView.hidden = NO;
    }
    else
    {
        _annotationAvlbl = NO;
        self.annotation.hidden = YES;
        self.annotation.text = @"";
        self.labelImageView.hidden = YES;
    }
}

-(void)changeButtonState
{
    if(_currentIndex == 0)
    {
        self.previousImage.enabled = NO;
        self.rightSwipeGesture.enabled = NO;
    }
    else
    {
        self.previousImage.enabled = YES;
        self.rightSwipeGesture.enabled = YES;
    }
    
    if(_currentIndex == _totalCount - 1)
    {
        self.nextImage.enabled = NO;
        self.leftSwipeGesture.enabled = NO;
    }
    else
    {
        self.nextImage.enabled = YES;
        self.leftSwipeGesture.enabled = YES;
    }
    
    self.mediaTitle.text = [NSString stringWithFormat:@"%d of %d",_currentIndex+1,_totalCount];
}


- (IBAction)rightSwipe:(UISwipeGestureRecognizer *)sender {
    [self showPreviousImage:Nil];
}

- (IBAction)viewTapped:(id)sender {
    if(_showOnlyImage)
    {
        [self hideView:YES];
        _showOnlyImage = NO;
    }
    else
    {
        [self hideView:NO];
        _showOnlyImage = YES;
    }
}

-(void)hideView:(BOOL)hide
{
    [self.topView setHidden:hide];
    [self.bottomView setHidden:hide];
    
    if(hide)
        self.view.backgroundColor = [UIColor blackColor];
    else
        self.view.backgroundColor = [UIColor whiteColor];
    
    if(!hide && _annotationAvlbl)
        self.annotationView.hidden = hide;
    else
        self.annotationView.hidden = YES;
}
- (IBAction)leftSwipe:(UISwipeGestureRecognizer *)sender {
    [self showNextImage:Nil];
}

//-(BOOL)shouldAutorotate{
//    return NO;
//}
//
//-(NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}
//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}
//
//-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    self.imageScrollView.zoomScale = 1.0;
//    //[self centerScrollViewContents];
//    [self.imageScrollView setNeedsUpdateConstraints];
//    [self.imageScrollView setNeedsLayout];
//}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.magnifiedImageView;
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.imageScrollView.bounds.size;
    CGRect contentsFrame = self.magnifiedImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.magnifiedImageView.frame = contentsFrame;
}


- (void)removeOverlayViewsIfAnyOnPushNotification;
{
    [self dismissViewController];
}

@end
