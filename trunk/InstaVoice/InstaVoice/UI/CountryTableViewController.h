//
//  CountryTableViewController.h
//  InstaVoice
//
//  Created by kirusa on 11/5/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"
#import "ContactDetailData.h"
#import "ContactSyncUtility.h"
#import "ContactData.h"
#import "ContactSyncSavePicOperation.h"
#import "Contacts.h"
#import "ContactInvitePopUPAction.h"
#import "CoreDataSetup.h"
#import <MessageUI/MessageUI.h>

@interface CountryTableViewController : BaseUI<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,MFMessageComposeViewControllerDelegate>
{
    IBOutlet UILabel        *countryNameLbl;
    IBOutlet UIView         *countryView;
    IBOutlet UITableView    *countryTable;// need to change in countryTable
    IBOutlet UIImageView    *flagview; //inside this flag btn and plus field
    
    IBOutlet UITextField    *plusField;
    IBOutlet UITextField    *userID;// need to change in userID
    //NSMutableArray          *countryList;
    NSMutableArray          *newCountryList;
    NSMutableArray          *indexArray;
    NSMutableArray          *countryIndexData;
    NSString                *countryIsdCode;
    NSString                *countryName;
    NSInteger               minPhoneLen;
    NSInteger               maxPhoneLen;
    UIImage *worldIconImg;
    int                     sepCount;
    ContactData* _invitedContact;
    NSMutableArray  *inviteList;
    
}
@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NSString *currentMobileNumber;
@property (strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSMutableArray *countryList;
@property(nonatomic,strong) NSString *countryIsdCodeSelected;
@property(nonatomic,strong) NSString *countryNameSelected;
@property(nonatomic,strong) NSString *countryFlag;
@property(nonatomic)NSString* countryCode;


-(IBAction)selectCountryBtnAction:(id)sender;
-(IBAction)cancelBtnAction:(id)sender;
-(IBAction)sendMessageTapped:(id)sender;
-(IBAction)addToInstavoiceTapped:(id)sender;

-(void)dismissMe;

@end
