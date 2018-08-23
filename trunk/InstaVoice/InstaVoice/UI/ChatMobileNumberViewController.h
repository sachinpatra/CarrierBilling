//
//  ChatMobileNumberViewController.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 7/7/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//


//TODO : UI Alignment is not as per the Autolayout - Need to change the constraints.
#import "BaseUI.h"
#import "ContactDetailData.h"
#import "ContactSyncUtility.h"
#import "ContactData.h"
#import "ContactSyncSavePicOperation.h"
#import "Contacts.h"
#import "ContactInvitePopUPAction.h"
#import "CoreDataSetup.h"
#import <MessageUI/MessageUI.h>


@protocol ChatMobileNumberProtocol <NSObject>
-(void)dismissedChatMobileNumberViewController:(id)sender;
@end

@interface ChatMobileNumberViewController : BaseUI<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,MFMessageComposeViewControllerDelegate>
{
    IBOutlet UILabel        *countryNameLbl;
    IBOutlet UIView         *countryView;
    IBOutlet UITableView    *countryTable;// need to change in countryTable
    IBOutlet UIImageView    *flagview; //inside this flag btn and plus field
    
    IBOutlet UIImageView    *downArrow;
    IBOutlet UITextField    *plusField;
    IBOutlet UITextField    *userID;// need to change in userID
    NSMutableArray          *countryList;
    NSMutableArray          *newCountryList;
    NSMutableArray          *indexArray;
    NSMutableArray          *countryIndexData;
    NSString                *countryIsdCode;
    NSString                *countryName;
    NSInteger               minPhoneLen;
    NSInteger               maxPhoneLen;
    NSString                *numberWithoutFormat;
    NSString                *numberE164format;
    UIImage *worldIconImg;
    UIAlertView             *alertNumberValidation;
    UIAlertView             *alertAddToIVValidation;
    UIAlertView             *alertWarning;
    BOOL                    isPossible;
    
    int                     sepCount;
    CustomIOS7AlertView         *popUp;
    ContactData* _invitedContact;
    NSMutableArray  *inviteList;

}

/**
 *  This must be set up before the this controller is presented.
 *
 *  This allows for us to push the new chat onto the correct navigation stack in the tab bar controller
 */
@property (strong, nonatomic) UITabBarController *callingTabBarController;


@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NSString *currentMobileNumber;
@property (strong) NSManagedObjectContext *managedObjectContext;
-(IBAction)selectCountryBtnAction:(id)sender;
-(IBAction)cancelBtnAction:(id)sender;
- (IBAction)sendMessageTapped:(id)sender;
- (IBAction)addToInstavoiceTapped:(id)sender;

-(void)dismissThisViewController;
@end
