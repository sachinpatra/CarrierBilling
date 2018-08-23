//
//  FriendsInviteViewController.h
//  InstaVoice
//
//  Created by kirusa on 10/21/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "BaseUI.h"
#import "ContactSyncUtility.h"

@interface FriendsInviteViewController : BaseUI <UITextFieldDelegate>
{
    BOOL                        isSearching;
    BOOL                        _loadAllPBContact;
    BOOL                        _inviteBySms;
    NSMutableArray              *_inviteList;
    
    NSString                    *numberWithoutFormat;
    NSString                    *numberE164format;
    NSString                    *countryIsdCode;
#ifdef REACHME_APP
    UIAlertView* alertWarning;
#endif
}


@property(nonatomic)BOOL inviteBySms;
@property(nonatomic,weak)id<FriendInviteListProtocol> delegate;

@end

/*Older implementation*/


/*#import "BaseUI.h"
#import "ContactSyncUtility.h"

@interface FriendsInviteViewController : BaseUI <UITextFieldDelegate>
{
    UIView                      *searchTopView;
    UIView                      *topView;
    UITextField                 *txfSearchField ;
    UIButton                    *searchBtn;
    UILabel                     *title;
    
    BOOL                        isSearching;
    
    IBOutlet UIButton           *inviteNewContact;
    IBOutlet UITextField        *phoneNumber;
    IBOutlet UITextField        *plusField;
    IBOutlet UITextField        *EmailId;
    
    IBOutlet UIView             *viewWithPhoneNumber;
    IBOutlet UIView             *viewWithEmailAddress;
    
    IBOutlet UITableView        *friendTable;
    __weak IBOutlet UILabel     *noContactLbl;
    
    BOOL                        _loadAllPBContact;
    BOOL                        _inviteBySms;
    NSMutableArray              *_inviteList;
    
    NSString                    *numberWithoutFormat;
    NSString                    *numberE164format;
    NSString                    *countryIsdCode;
    UIAlertView                 *alertNumberValidation;
}

- (IBAction)invite:(id)sender;
- (IBAction)inviteWithPhoneNumber:(id)sender;
- (IBAction)inviteWithEmailAddress:(id)sender;
- (IBAction)selectCountryView:(id)sender;
- (IBAction)inviteNewContactButtonAction:(id)sender;

@property(nonatomic)BOOL inviteBySms;
@property(nonatomic,weak)id<FriendInviteListProtocol> delegate;

@end
*/
