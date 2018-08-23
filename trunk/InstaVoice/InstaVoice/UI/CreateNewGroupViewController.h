//
//  CreateNewGroupViewController.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 9/1/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "BaseUI.h"
#import <UIKit/UIKit.h>

#ifndef REACHME_APP
    #import "GroupUtility.h"
#endif



@protocol CreateNewGroupProtocol <NSObject>
-(void)dismissedTheViewController:(id)sender;
@end

@interface CreateNewGroupViewController : BaseUI<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate>
{
    UIImagePickerController *imagePickerViewController;
    BOOL isSearching;
    //GroupUtility *objGroupUtitity;
    //NSManagedObjectContext* _managedObjectContext;
    BOOL _picChanged;
    UIAlertView* alertView;
}

/**
 *  This must be set up before the this controller is presented.
 *
 *  This allows for us to push the new chat onto the correct navigation stack in the tab bar controller
 */
@property (strong, nonatomic) UITabBarController *callingTabBarController;
//

@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *memberSearchTextField;
@property (weak, nonatomic) IBOutlet UIButton *createOrUpdateButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) NSString *groupProfilePicPath;
@property (strong, nonatomic) NSString *groupID;
@property (strong, nonatomic) NSString *groupName;
@property (strong, nonatomic) NSArray *groupMembersOriginal;
@property (strong, nonatomic) NSMutableArray *groupMembersSearch;
@property (strong, nonatomic) NSMutableArray *groupMembersCurrentlySelected;
@property (strong, nonatomic) NSArray *groupMembersInitiallySelected;
@property (strong, nonatomic) NSMutableArray *groupMembersDifferenceSelected;
@property (weak, nonatomic) IBOutlet UITableView *groupMemberTableView;
@property (weak, nonatomic) IBOutlet UIImageView *groupChatImage;
@property (weak, nonatomic) id delegate;
@property (nonatomic) BOOL isImageSelected;
@property (nonatomic) BOOL shouldUpdateScreen;
- (IBAction)cancelGroupCreation:(id)sender;
- (IBAction)createNewGroup:(id)sender;
- (IBAction)selectGroupPicture:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGroupDetails:(NSDictionary*)groupDetails;
-(void)cancel;
-(void)dismissThisViewController;
@end
