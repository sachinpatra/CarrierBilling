//
//  ProfilePicView.m
//  InstaVoice
//
//  Created by kirusa on 4/4/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import "ProfilePicView.h"
#import "Profile.h"
#import "IVFileLocator.h"
#import "IVImageUtility.h"

#define FILETYPE           @"png"
@implementation ProfilePicView
@synthesize changePicButton,userPicView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.backgroundColor = [UIColor clearColor];
        userPicView = [[UIImageView alloc]initWithFrame:CGRectMake(94, 32, 68, 68)];
        [userPicView setImage:[UIImage imageNamed:@"reg_profile_pic"]];
        changePicButton = [[UIButton alloc]initWithFrame:CGRectMake(94, 32, 68, 68)];
        changePicButton.backgroundColor = [UIColor clearColor];
        [self addSubview:userPicView];
        [self addSubview:changePicButton];
        [changePicButton addTarget:self action:@selector(selectPicFromGallery:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

/*selecting picture from the galary*/

-(void)selectPicFromGallery:(id)sender
{
    imagePickerViewController = [[UIImagePickerController alloc] init];
    imagePickerViewController.delegate = (id)self;
    imagePickerViewController.allowsEditing = TRUE;
    imagePickerViewController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self.delegate profilePickerController:self withImagePicker:imagePickerViewController];
}

#pragma mark-picker view delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    BOOL processImage = [IVImageUtility isImageValidForServerUpload:info];
    NSURL *assetURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    NSString *extension = [assetURL pathExtension];
    if(!processImage)
    {
        [imagePickerViewController dismissViewControllerAnimated:NO completion:nil];
        [ScreenUtility showAlertMessage:[NSString stringWithFormat:@"Unsupported image type: %@",extension]];
    }
    else
    {
        [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
        
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        [userPicView setImage:image];
        [NSTimer scheduledTimerWithTimeInterval: 0.0f
                                         target: self
                                       selector: @selector(picChanged:)
                                       userInfo: image
                                        repeats: NO];
        [self.delegate profilePickerController:@"Save"];
    }

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
    [self.delegate profilePickerController:@"Skip"];

}
-(void)picChanged:(NSTimer*)timer
{
    UIImage *image = [timer userInfo];
    if(image != nil)
    {
        image = [IVImageUtility fixrotation:image];
        //JAn 27
        NSString* loginID = nil;
        NSString* fileName = nil;
        //
        
        @autoreleasepool { //JAN 27 CMP
            NSData *imageData = UIImagePNGRepresentation(image);
            //DC MEMLEAK MAY 25 2016
          //  NSArray *contactIds = [[NSArray alloc] initWithObjects:[appDelegate.confgReader getLoginId], nil];
            
            //AVN_TO_DO
            //[appDelegate.dataMgt updateContactOnProfileChange:contactIds profilePic:imageData];
            //NSString *filaPath = [IVFileLocator createImageDirectory];
            NSString *loginID = [appDelegate.confgReader getLoginId];
            NSString* fileName = [[NSString alloc] initWithFormat:@"%@.%@",loginID,FILETYPE];
            //filaPath = [filaPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@.%@",loginID,FILETYPE]];
            [imageData writeToFile:[IVFileLocator getMyProfilePicPath:fileName] atomically:YES];
        }
        [Profile sharedUserProfile].profileData.localPicPath = fileName;
        [userPicView setImage:image];
        
        [self.delegate pathToSendTheFile:[IVFileLocator getMyProfilePicPath:fileName]];
        
        //NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        //[dic setValue:[IVFileLocator getMyProfilePicPath:fileName] forKey:LOCAL_PIC_PATH];
        //[dic setValue:FILETYPE forKey:PIC_TYPE];
        UIImage *cropImg = [IVImageUtility cropImage:image targetSize:[self getCropSize]];
        if(cropImg != nil)
        {
            @autoreleasepool { //JAN 27 CMP
                NSData *cropData = UIImagePNGRepresentation(cropImg);
                NSString* cropFileName = [[NSString alloc] initWithFormat:@"crop%@.%@",loginID,FILETYPE];
                //NSString *cropPath = [IVFileLocator createImageDirectory];
                //cropPath = [cropPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"crop%@.%@",loginID,FILETYPE]];
                [cropData writeToFile:[IVFileLocator getMyProfilePicPath:cropFileName] atomically:YES];
                //[dic setValue:cropPath forKey:CROP_PROFILE_PIC_PATH];
                [Profile sharedUserProfile].profileData.cropProfilePicPath = cropFileName;
            }
        }
        [[Profile sharedUserProfile]writeProfileDataInFile];
    }
}

-(CGSize)getCropSize
{
    CGSize size;
    if(appDelegate.deviceHeight.height < SIZE_481)
    {
        size = CGSizeMake(DEVICE_WIDTH, 205);
    }
    else
    {
        size = CGSizeMake(DEVICE_WIDTH, 230);
    }
    return size;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
