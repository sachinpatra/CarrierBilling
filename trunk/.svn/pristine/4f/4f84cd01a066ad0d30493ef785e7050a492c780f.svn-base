//
//  IVMediaSendingViewController.m
//  InstaVoice
//
//  Created by adwivedi on 11/09/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "IVMediaSendingViewController.h"
#import "IVFileLocator.h"
#import "IVImageUtility.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ScreenUtility.h"

@implementation IVMediaData
@synthesize image,annotation,picName,picType;
-(NSString*)description
{
    return [NSString stringWithFormat:@"Image name: %@, type: %@ and annotation: %@",picName,picType,annotation];
}
@end

@interface IVMediaSendingViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addMoreTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;

@end

@implementation IVMediaSendingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedImageList = [[NSMutableArray alloc]init];
        _firstTime = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat topPadding;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        if(DEVICE_HEIGHT > 800.0)
            topPadding = window.safeAreaInsets.top;
        else
            topPadding = 20.0;
    }else{
        topPadding = 20.0f;
    }
    
    self.backTopConstraint.constant = topPadding;
    self.sendButtonTopConstraint.constant = topPadding;
    self.titleLabelTopConstraint.constant = topPadding;
    self.addMoreTopConstraint.constant = topPadding;
    
    self.multipleImageView.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    _imagePickerViewController = [[UIImagePickerController alloc] init];
    _imagePickerViewController.delegate = (id)self;
    _imagePickerViewController.allowsEditing = NO;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        _addImageSheet = [[UIActionSheet alloc]initWithTitle:@"Image Selection" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Photo Library",@"Saved Photos Album", @"Camera", nil];
    }
    else
    {
        _addImageSheet = [[UIActionSheet alloc]initWithTitle:@"Image Selection" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Photo Library",@"Saved Photos Album", nil];
    }
    
    if(self.screenType == NOTES_SCREEN) {
        [self.sendButton setTitle:@"Save" forState:UIControlStateNormal];
    }
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [appDelegate.stateMachineObj setCurrentPresentedUI:self];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [appDelegate.stateMachineObj setCurrentPresentedUI:nil];
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(_firstTime)
    {
        _firstTime = NO;
        self.sendButton.enabled = NO;
        _imagePickerViewController.sourceType = self.sourceType;
        [self presentViewController:_imagePickerViewController animated:YES completion:^{
            [appDelegate.stateMachineObj setCurrentPresentedUI:self];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel
{
    [ScreenUtility closeAlert];
    [_imagePickerViewController dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -- Button click handling
- (IBAction)backButton:(id)sender {
    [self.annotationView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate ivMediaSendingViewControllerDidCompleteSelectingImages:nil shouldSetFrame:YES];
    }];
}

- (IBAction)imageTapped:(id)sender {
    [self.annotationView resignFirstResponder];
}

- (IBAction)sendImage:(id)sender {
    [self.annotationView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        if(_selectedImageList.count > 0)
            [self.delegate ivMediaSendingViewControllerDidCompleteSelectingImages:_selectedImageList shouldSetFrame:NO];
    }];
}

- (IBAction)addImage:(id)sender {
    [self.annotationView resignFirstResponder];
    [_addImageSheet showFromRect:CGRectMake(0, 0, 100, 100) inView:self.view animated:YES];
}

#pragma mark -- Text field data handling

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [NSString stringWithString:self.annotationView.text];
    text = [text stringByReplacingCharactersInRange:range withString:string];
    if(text.length > 50)
    {
        [ScreenUtility showAlertMessage:@"Sorry, text cannot exceed 50 characters"];
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString* annotation = [textField text];
    if(annotation != nil && annotation.length > 0)
    {
        for(IVMediaData* data in _selectedImageList)
        {
            data.annotation = annotation;
        }
    }
}

#pragma mark-UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    KLog(@"didFinishPickingMediaWithInfo: %@",info);
    
    [_imagePickerViewController dismissViewControllerAnimated:NO completion:nil];
    
    @try
    {
        UIImage *image=nil;
        if(_imagePickerViewController.allowsEditing)
            image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        else
            image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        if(image != Nil)
        {
            if(_imagePickerViewController.sourceType == UIImagePickerControllerSourceTypeCamera)
            {
                //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                [self processAndSaveImage:image];
            }
            else
            {
                BOOL processImage = [IVImageUtility isImageValidForServerUpload:info];
                NSURL *assetURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
                NSString *extension = [assetURL pathExtension];
                if(!processImage)
                {
                    [ScreenUtility showAlertMessage:[NSString stringWithFormat:@"Unsupported image type: %@",extension]];
                    [self dismissViewControllerAnimated:NO completion:nil];
                }
                
                if(processImage)
                {
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        KLog(@"Size: %lld KB", asset.defaultRepresentation.size/1024);
                        if(asset.defaultRepresentation.size < (10 * 1024 * 1024))
                        {
                            [self processAndSaveImage:image];
                        }
                        else
                        {
                            [ScreenUtility showAlertMessage:@"Please select an image of size less than 10 MB"];
                            [self dismissViewControllerAnimated:NO completion:nil];
                        }
                    } failureBlock:nil];
                }
            }
        }
    }
    @catch (NSException *exception) {
        KLog(@"Exception occurred: %@",exception);
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_imagePickerViewController dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)processAndSaveImage:(UIImage*)image
{
    KLog(@"Image Processing Started");
    if(image != nil)
    {
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
        NSString* picName = [NSString stringWithFormat:@"img_%@_%lld",self.fromUserId,milliseconds];
        image = [IVImageUtility fixrotation:image];
        
        /*NSData* origImage = UIImageJPEGRepresentation(image, 1);
        NSString* origName = [@"orig_" stringByAppendingString:picName];
        [origImage writeToFile:[IVFileLocator getMediaImagePath:origName] atomically:YES];*/
        
        NSData *imageData = [self compressImage:image withMaxHeight:1000 maxWidth:1000 compressionQuality:.5];
        if(!imageData) {
            KLog(@"Should not happen");
        }
        [imageData writeToFile:[IVFileLocator getMediaImagePath:[picName stringByAppendingPathExtension:@"jpg"]] atomically:YES];
        
        IVMediaData* img = [[IVMediaData alloc]init];
        img.picName = picName;
        img.image = [UIImage imageWithData:imageData];
        img.picType = @"jpg";
        if(self.annotationView.text)
            img.annotation = self.annotationView.text;
        [_selectedImageList addObject:img];
        if(_selectedImageList.count > 0)
            self.addMore.enabled = NO;
    }
    [self refreshUI];
    KLog(@"Image Processing End");
}

-(NSData *)compressImage:(UIImage *)image withMaxHeight:(float)maxHeight maxWidth:(float)maxWidth compressionQuality:(float)compressionQuality{
    //default values
    if(maxHeight < 1000)
        maxHeight =  1000;
    if(maxWidth < 1000)
        maxWidth = 1000;
    if(compressionQuality < 0.5)
        compressionQuality = 0.5;
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return imageData;
}

-(void)refreshUI
{
    [self.annotationView resignFirstResponder];
    for(UIView* vw in self.multipleImageView.subviews)
    {
        [vw removeFromSuperview];
    }
    
    if(_selectedImageList.count > 0)
    {
        self.sendButton.enabled = YES;
        self.selectedImageView.image = ((IVMediaData*)[_selectedImageList objectAtIndex:_selectedImageList.count-1]).image;;
        float width = 60.0;
        float height = 60.0;
        float yPos = 0;
        
        int finalCount = _selectedImageList.count > 5? 5:_selectedImageList.count;
        
        for(int i=0;i<finalCount;i++)
        {
            UIImageView* imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10+i*width, yPos, width, height)];
            imgView.image = ((IVMediaData*)[_selectedImageList objectAtIndex:i]).image;
            [self.multipleImageView addSubview:imgView];
        }
        
        yPos = yPos + height;
        if(finalCount < _selectedImageList.count)
        {
            for(int i=finalCount;i<_selectedImageList.count;i++)
            {
                UIImageView* imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10+(i-5)*width, yPos, width, height)];
                imgView.image = ((IVMediaData*)[_selectedImageList objectAtIndex:i]).image;
                [self.multipleImageView addSubview:imgView];
            }
        }
    }
    else
        self.sendButton.enabled = NO;
}


#pragma mark -- UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    KLog(@"Button Clicked at index %ld",(long)buttonIndex);
    [self presentImageSelectionViewOnUserSelection:buttonIndex];
}

-(void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [self presentImageSelectionViewOnUserSelection:-1];
}

-(void)presentImageSelectionViewOnUserSelection:(NSInteger)buttonIndex
{
    BOOL presentView = YES;
    switch (buttonIndex) {
        case 0:
            _imagePickerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 1:
            _imagePickerViewController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            break;
        case 2:
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                _imagePickerViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else
            {
                presentView = NO;
            }
            break;
        default:
            presentView = NO;
            break;
    }
    if(presentView)
        [self presentViewController:_imagePickerViewController animated:YES completion:nil];
}

-(BOOL)shouldAutorotate {
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
