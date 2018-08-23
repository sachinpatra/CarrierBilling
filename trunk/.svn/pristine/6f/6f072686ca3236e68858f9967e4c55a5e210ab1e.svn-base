//
//  PersonalisationViewController.m
//  ReachMe
//
//  Created by Bhaskar Munireddy on 06/02/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "PersonalisationViewController.h"
#import "UserProfileModel.h"
#import "Profile.h"
#import "IVImageUtility.h"
#import "IVFileLocator.h"
#import "ReachMe-Swift.h"

#define FILETYPE        @"png"

typedef NS_ENUM (NSUInteger, ProfileCells){
    eUserNameTextField = 1,
    eEmailIdTextField = 2
};

@interface PersonalisationViewController ()<SettingProtocol,ProfileProtocol>{
    UIImagePickerController *imagePickerViewController;
    BOOL _fetchSettingFromServer, isSaveProgress;
    UserProfileModel* _editedProfileData;
    MBProgressHUD *progressBar;
    NSString* _editedPicPath;
}
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UILabel *warningText;
@property (weak, nonatomic) IBOutlet UILabel *ringToneName;
@property (weak, nonatomic) IBOutlet UIButton *selectImage;

@end

@implementation PersonalisationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Personalisation", nil);
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.hidesBackButton = YES;
    
    //Image Work
    imagePickerViewController = [[UIImagePickerController alloc] init];
    imagePickerViewController.delegate = (id)self;
    imagePickerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerViewController.allowsEditing = YES;
    
    self.selectImage.layer.cornerRadius  = self.selectImage.frame.size.height/2;
    self.profileImage.layer.cornerRadius  = self.profileImage.frame.size.height/2;
    self.nameTextField.tag = eUserNameTextField;
    
    _fetchSettingFromServer = YES;
    
    UITapGestureRecognizer *changeSimCarrier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignResponder:)];
    [self.view addGestureRecognizer:changeSimCarrier];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setEditedData];
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        if(_fetchSettingFromServer) {
            [self showProgressBar];
            [Setting sharedSetting].delegate = self;
            [[Setting sharedSetting]getUserSettingFromServer];
            _fetchSettingFromServer = NO;
        }
        [Profile sharedUserProfile].delegate = self;
        [[Profile sharedUserProfile]getProfileDataFromServer];
    }else{
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
    
    if ([[ConfigurationReader sharedConfgReaderObj] isRingtoneSet])
        self.ringToneName.text = @"iPhone";
    else
        self.ringToneName.text = @"ReachMe";
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [Setting sharedSetting].delegate = nil;
    [Profile sharedUserProfile].delegate = nil;
    [super viewWillDisappear:animated];
}

- (void)resignResponder:(UITapGestureRecognizer *)reco
{
    [self.view endEditing:YES];
}

- (void)saveAction
{
    [self.view endEditing:YES];
    isSaveProgress = YES;
    if (!self.nameTextField.text.length || !self.emailAddressTextField.text.length) {
        self.warningText.text = @"Name & Email Address is Required";
        self.warningText.textColor = [UIColor redColor];
    }else if (![self isValidEmail:self.emailAddressTextField.text]){
        [ScreenUtility showAlertMessage:@"Enter Valid Email Address"];
        return;
    }else{
        UserProfileModel* model = [[Profile sharedUserProfile]getUserProfile];;
        [self updateProfileData:model];
        if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
            [[ConfigurationReader sharedConfgReaderObj] setOnBoardingStatus:NO];
            [appDelegate createTabBarControllerItems];
            return;
        }
        [self showProgressBar];
        [[Profile sharedUserProfile]updateUserProfile:model];
    }
}

- (IBAction)selectImage:(id)sender {
    int isNetAvailable = [Common isNetworkAvailable];
    if(isNetAvailable == NETWORK_AVAILABLE){
        if (self.nameTextField.text.length || self.emailAddressTextField.text.length) {
            UserProfileModel* model = [[Profile sharedUserProfile]getUserProfile];;
            [self updateProfileData:model];
            [[Profile sharedUserProfile]updateUserProfile:model];
        }
        [self presentViewController:imagePickerViewController animated:YES completion:nil];
    }else {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

- (IBAction)changeRingtone:(id)sender {
    [self.view endEditing:YES];
    if (self.nameTextField.text.length || self.emailAddressTextField.text.length) {
        UserProfileModel* model = [[Profile sharedUserProfile]getUserProfile];;
        [self updateProfileData:model];
        [[Profile sharedUserProfile]updateUserProfile:model];
    }
    SingleSelectionTableViewController *changeRingTone = [[SingleSelectionTableViewController alloc] initWith:SelectionTypeRingTone];
    [self.navigationController pushViewController:changeRingTone animated:YES];
}

- (void)setEditedData
{
    UserProfileModel* profileData = [[Profile sharedUserProfile]profileData];
    if (profileData) {
        NSString *pathToPicture = [IVFileLocator getMyProfilePicPath:profileData.localPicPath];
        if (pathToPicture && pathToPicture.length > 0) {
            self.profileImage.image = [UIImage imageWithContentsOfFile:pathToPicture];
        }else{
            self.profileImage.image = [UIImage imageNamed:@"img_profile"];
        }
    }
    if(profileData.screenName != nil) {
        if ([self isNumeric:profileData.screenName])
            self.nameTextField.text = @"";
        else
            self.nameTextField.text = profileData.screenName;
    }
    else {
        self.nameTextField.text = @"";
    }
    
    if(profileData.profileEmailId != nil) {
        self.emailAddressTextField.text = profileData.profileEmailId;
    }
    else {
        self.emailAddressTextField.text = @"";
    }
}

#pragma mark - Imagepicker related Methods -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    BOOL processImage = [IVImageUtility isImageValidForServerUpload:info];
    NSURL *assetURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    NSString *extension = [assetURL pathExtension];
    if(!processImage)
    {
        [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
        [ScreenUtility showAlertMessage:[NSString stringWithFormat:@"Unsupported image type: %@",extension]];
    }
    else
    {
        [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
        int isNetAvailable = [Common isNetworkAvailable];
        if(isNetAvailable == NETWORK_AVAILABLE)
        {
            UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
            [NSTimer scheduledTimerWithTimeInterval: 0.0f
                                             target: self
                                           selector: @selector(picChanged:)
                                           userInfo: image
                                            repeats: NO];
        }
        else
        {
            [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Timer Method -
-(void)picChanged:(NSTimer*)timer
{
    UIImage *image = [timer userInfo];
    if(image != nil)
    {
        image = [IVImageUtility fixrotation:image];
        //JAN 27
        NSString* fileName=nil;
        NSString* loginID=nil;
        
        @autoreleasepool { //JAN 27 CMP
            NSData *imageData = UIImagePNGRepresentation(image);
            //AVN_TO_DO
            loginID = [[ConfigurationReader sharedConfgReaderObj] getLoginId];
            fileName = [[NSString alloc] initWithFormat:@"%@.%@",loginID,FILETYPE];
            [imageData writeToFile:[IVFileLocator getMyProfilePicPath:fileName] atomically:YES];
        }
        
        [Profile sharedUserProfile].profileData.localPicPath = fileName;
        
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
        [[Profile sharedUserProfile]uploadProfilePicWithPath:[IVFileLocator getMyProfilePicPath:fileName] fileName:@""];
    }
}

-(void)updateProfileData:(UserProfileModel*)model
{
    if([self.nameTextField.text length] > 0)
    {
        model.screenName = self.nameTextField.text;
    }
    else
    {
        model.screenName =@"";
    }
    
    if([self.emailAddressTextField.text length] > 0)
    {
        model.profileEmailId = self.emailAddressTextField.text;
    }
    else
    {
        model.profileEmailId =@"";
    }
}

-(void)fetchProfileCompletedWith:(UserProfileModel*)modelData
{
    [self hideProgressBar];
    [self setEditedData];
}
-(void)updateProfileCompletedWith:(UserProfileModel*)modelData
{
    [self hideProgressBar];
    if (isSaveProgress) {
        [[ConfigurationReader sharedConfgReaderObj] setOnBoardingStatus:NO];
        [appDelegate createTabBarControllerItems];
    }
}

-(void)uploadPicCompletedWithPath:(NSString*)path
{
    
}
-(void)downloadPicCompletedWithPath:(NSString*)path
{
   
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* currentText = textField.text;
    if(currentText.length == 0) {
        //first character can not be space
        if([string isEqualToString:@" "])
            return NO;
    }
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField.tag == eUserNameTextField) {
        if (newString.length > 50) {
            [self limitExceedForUsernameAndCity:@"Name should not exceed 50 characters"];
            return NO;
        }
        
        NSString* currentText = textField.text;
        if(currentText.length == 0) {
            //first character can not be numeric
            if([self isNumeric:string])
                return NO;
        }
        
    }
    
    if (range.location == textField.text.length && [string isEqualToString:@" "]) {
        textField.text = [textField.text stringByAppendingString:@"\u00a0"];
        return NO;
    }
    
    return YES;
}

- (void)limitExceedForUsernameAndCity:(NSString *)message
{
    UIAlertController *alertController =   [UIAlertController
                                            alertControllerWithTitle:nil
                                            message:message
                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"OK", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
    [alertController.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
}

#pragma mark - Private Methods -
- (CGSize)getCropSize {
    CGSize size;
    
    size = CGSizeMake(68.0, 68.0);
    
    return size;
}

- (BOOL)isNumeric:(NSString *)name {
    
    BOOL result = FALSE;
    if(name != nil && name.length >0) {
        BOOL valid = [Common validateNumeric:name];
        if (valid)
            result = TRUE;
    }
    return result;
}

-(BOOL)isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
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
