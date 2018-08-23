//
//  FriendsScreen.h
//  InstaVoice
//
//  Created by EninovUser on 19/11/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "BaseUI.h"

#import "CustomIOS7AlertView.h"
#import "ContactDetailData.h"
#import "PopoverView.h"


@interface FriendsScreen : BaseUI <UITextFieldDelegate,CustomIOS7AlertViewDelegate,PopoverViewDelegate, UISearchBarDelegate>
{
    NSMutableArray              *inviteList; //- Invite list contains those contacts to which invitation is needed to send.
    NSIndexPath*                listIndex;   //- listindex is used in MultipleId alert.
    
// search view is shown when click on search button of top view.
    UIView                      *searchTopView;
    UIView                      *topView;    
    UITextField                 *txfSearchField;
    UILabel *title;

    CustomIOS7AlertView         *popUp;
    
    BOOL                        isSearching;
    NSInteger                   alertType;

    __weak IBOutlet NSLayoutConstraint *_topViewHeight;
    __weak IBOutlet UILabel *progressBarLbl;
    __weak IBOutlet UIProgressView *progressbar;
    __weak IBOutlet UIView *progressView;
    
    __weak IBOutlet UISearchBar *inviteSearchBar;
    IBOutlet UITableView  *friendTable;
    
    __weak IBOutlet UILabel *noContactLbl;
    __weak IBOutlet UIView *noContactLblBackgroundView;
    
    ContactData* _invitedContact;
    BOOL _loadAllPBContact;

    PopoverView *pv;
    CGPoint point;
    UIView *button;
    NSMutableArray* _multipleContact;
    BOOL _isNumber;
    NSString *_searchString;
    MBProgressHUD* _progressBar;
    BOOL _bReloadData;
    BOOL _isContactSyncDlgShown;
    UIAlertView* alertWarning;
    UIActionSheet* actionSheetInvite;
    UIActionSheet* actionSheetContactSelect;
}

@property(strong, nonatomic) UITableView *_friendTable;
@property BOOL homeTab;

//- Action on cell class, move it to some delegate
-(void)conversationBtnAction:(id) sender;
-(void)byDefaultSelected:(ContactDetailData *)detailDic tag:(int)tag;
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)cancelBtnInviteAction;
-(void)sendBtnInviteAction;

-(void)dismissThisViewController;
-(void)updateNavigationBarTintColor;

-(void)killScroll;

@end
