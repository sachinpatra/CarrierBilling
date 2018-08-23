//
//  ViewForContactScreen.h
//  InstaVoice
//
//  Created by kirusa on 7/7/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif

@protocol ChatPhoneNumberProtocol <NSObject>

-(void)dismissedTheViewController:(id)sender withIdentity:(NSString*)str;

@end
@interface ViewForContactScreen : UIView<UITableViewDataSource,UITableViewDelegate, UIToolbarDelegate>{
    UILabel *nameLabel;
    //UILabel *nameLineLabel;
    //UILabel *audioLabel;
    UITableView *tableToSeeTheUserPhoneNo;
    UIBarButtonItem *cancelButton;
    UISegmentedControl *speakerButton;
    NSArray *nameArray;
    NSString* _contactNumber;
    AppDelegate *appDelegate;
    BOOL bShowContacts;
}
@property (strong, nonatomic) NSString *currentMobileNumber;
@property (nonatomic,strong)UILabel *nameLabel;
//@property (nonatomic,strong)UILabel *audioLabel;
//@property (nonatomic,strong)UILabel *nameLineLabel;
@property (nonatomic,strong)UIBarButtonItem *cancelButton;
@property (nonatomic,strong)UISegmentedControl *speakerButton;
@property (nonatomic,strong)NSString *currentlyTapped;
@property (strong, nonatomic) UIImage *profilePicture;
@property (weak, nonatomic) id delegate;

- (id)initWithFrame:(CGRect)frame withPhoneNumber:(NSString*)phoneNumber;
- (void)initializeVariable;
- (void)forReloadingOfTable;



@end
