//
//  InviteFriendsViewController.m
//  InstaVoice
//
//  Created by Bhaskar C Munireddy on 26/12/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import "FriendsInviteViewController.h"
#import "Profile.h"
#import <MessageUI/MessageUI.h>
#import "Contacts.h"
#import "ContactsApi.h"
#import "ConversationApi.h"
#import "SendFriendInviteAPI.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface InviteFriendsViewController ()<FriendInviteListProtocol,MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;

@end

@implementation InviteFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Invite";
        [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Invite" image:[UIImage imageNamed:@"invite_friends"] selectedImage:[UIImage imageNamed:@"invite_friends_selected"]]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Invite";
    CGFloat bottomPadding;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        bottomPadding = window.safeAreaInsets.bottom;
    }else{
        bottomPadding = 0.0f;
    }
    self.bottomConstraint.constant += bottomPadding;
    self.inviteButton.layer.cornerRadius = 5.0;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIStateMachine sharedStateMachineObj]setCurrentUI:self];
    [super viewWillAppear:animated];
    appDelegate.tabBarController.tabBar.hidden = NO;
    
#ifdef REACHME_APP
    NSArray *items = @[NSLocalizedString(@"SMS_MESSAGE_PHONE", nil)];
    UIActivityViewController * activity =[[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    activity.excludedActivityTypes = @[];
    activity.completionWithItemsHandler = ^(NSString *activityType,
                                            BOOL completed,
                                            NSArray *returnedItems,
                                            NSError *error){
        if (error) {
            KLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
    [self presentViewController:activity animated:true completion:nil];
#endif
    
#ifndef REACHME_APP
    self.invTitle.text = @"Invite your friends to InstaVoice";
    self.invText.text = @"Stay connected at all times. InstaVoice is the only app that tells you who called, even when your phone is switched off. Now, never miss a call!";
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
#ifdef REACHME_APP
    [self dismissViewControllerAnimated:YES completion:nil];
#endif
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
#ifdef REACHME_APP
    [self syncContact];
#endif
}

- (IBAction)inviteFriends:(id)sender {
    
#ifdef REACHME_APP
    NSArray *items = @[NSLocalizedString(@"SMS_MESSAGE_PHONE", nil)];
    UIActivityViewController * activity =[[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    activity.excludedActivityTypes = @[];
    activity.completionWithItemsHandler = ^(NSString *activityType,
                                            BOOL completed,
                                            NSArray *returnedItems,
                                            NSError *error){
        if (error) {
            KLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
    [self presentViewController:activity animated:true completion:nil];
#endif
    
//    inviteFriends = [UIAlertController alertControllerWithTitle:@"Invite Friends" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *inviteBySMS = [UIAlertAction actionWithTitle:@"Invite Friends via SMS" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//        UIStoryboard *voiceMailSettingsStorybaord = [UIStoryboard storyboardWithName:@"IVFriendsStoryboard" bundle:[NSBundle mainBundle]];
//        FriendsInviteViewController *friendsInviteViewController = [voiceMailSettingsStorybaord instantiateViewControllerWithIdentifier:@"FriendsInviteView"];
//        friendsInviteViewController.inviteBySms = YES;
//        friendsInviteViewController.delegate = self;
//        //UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:friendsInviteViewController];
//        //FEB 27, 2018 [self.navigationController presentViewController:navController animated:YES completion:nil];
//        [self.navigationController pushViewController:friendsInviteViewController animated:YES];
//
//    }];
//
//    UIAlertAction *inviteByEmail = [UIAlertAction actionWithTitle:@"Invite Friends via Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//        UIStoryboard *voiceMailSettingsStorybaord = [UIStoryboard storyboardWithName:@"IVFriendsStoryboard" bundle:[NSBundle mainBundle]];
//        FriendsInviteViewController *friendsInviteViewController = [voiceMailSettingsStorybaord instantiateViewControllerWithIdentifier:@"FriendsInviteView"];
//        friendsInviteViewController.inviteBySms = NO;
//        friendsInviteViewController.delegate = self;
//        //FEB 27, 2018 [self.navigationController presentViewController:navController animated:YES completion:nil];
//        //[self.navigationController pushViewController:navController animated:YES];
//        [self.navigationController pushViewController:friendsInviteViewController animated:YES];
//    }];
//
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//
//    }];
//
//    [inviteFriends addAction:inviteBySMS];
//    [inviteFriends addAction:inviteByEmail];
//    [inviteFriends addAction:cancel];
//
//    inviteFriends.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
//    [self presentViewController:inviteFriends animated:YES completion:nil];
}

#pragma mark -- FriendInviteListProtocol
-(void)listSelected:(NSMutableArray *)selectedInviteList forInviteType:(ContactInviteType)inviteType
{
    switch (inviteType)
    {
        case ContactInviteTypeSMS:
        {
            NSMutableDictionary *dic = [Common getSIMInfo];
            if(dic != nil && [dic count] >0)
            {
                [self sendSMSInvitation:selectedInviteList];
            }
            else
            {
                [ScreenUtility showAlertMessage:NSLocalizedString(@"SIM_NOT_AVAILABLE", nil)];
            }
        }
            break;
            
        case ContactInviteTypeEmail:
        {
            NSMutableDictionary* sendMsgDic = [[NSMutableDictionary alloc]init];
            NSMutableArray *contactIds = [[NSMutableArray alloc] init];
            NSString* inviteMode = EMAIL_MODE;
            for(NSString* email in selectedInviteList)
            {
                NSMutableDictionary *contactDic = [[NSMutableDictionary alloc] init];
                [contactDic setValue:inviteMode forKey:API_TYPE];
                [contactDic setValue:email forKey:API_CONTACT];
                [contactIds addObject:contactDic];
            }
            [sendMsgDic setValue:contactIds forKey:API_CONTACT_IDS];
            
            if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
                [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
                return;
            }
            
            SendFriendInviteAPI* api = [[SendFriendInviteAPI alloc]initWithRequest:sendMsgDic];
            [api callNetworkRequest:sendMsgDic withSuccess:^(SendFriendInviteAPI* req, NSMutableDictionary* responseObject) {
                KLog(@"Response %@",responseObject);
                [ScreenUtility showAlertMessage:NSLocalizedString(@"INVITATION_SENT", nil)];
            } failure:^(SendFriendInviteAPI* req, NSError* error) {
                KLog(@"Response %@",error);
                [ScreenUtility showAlert:NSLocalizedString(@"INVITATION_FAIL", nil)];
            }];
        }
            
        default:
            break;
    }
}

-(BOOL)sendSMSInvitation:(NSMutableArray*)smsInvitationList
{
    if(![MFMessageComposeViewController canSendText])
    {
        UIAlertController *warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"SMS_NOT_SUPPORTED", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [warningAlert addAction:ok];
        warningAlert.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
        [self.navigationController presentViewController:warningAlert animated:YES completion:nil];
        
        return NO;
    }
    
    NSArray *recipents = [NSArray arrayWithArray:smsInvitationList];
    NSString* smsText = [[[Profile sharedUserProfile]profileData]inviteSmsText];
    NSString *message = NSLocalizedString(@"SMS_MESSAGE_PHONE", nil);
    if(smsText && smsText.length > 0)
    {
        message = smsText;
    }
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    [self presentViewController:messageController animated:YES completion:nil];
    
    return YES;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
        {
            EnLoge(@"Cancelled");
        }
            break;
        case MessageComposeResultFailed:
        {
            [ScreenUtility showAlertMessage:NSLocalizedString(@"INVITATION_FAIL", nil)];
        }
            break;
        case MessageComposeResultSent:
        {
            [ScreenUtility showAlertMessage:NSLocalizedString(@"INVITATION_SENT", nil)];
        }
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#ifdef REACHME_APP
-(void)syncContact
{
    //
    // Contact Aceess Permission
    BOOL nativeAccessPermission = [Common getNativeContactAccessPermission];
    if(nativeAccessPermission)
    {
        EnLogd(@"Contacts permission allowed. Sync comtacts");
        [[Contacts sharedContact]syncContactFromNativeContact];
        [[ConfigurationReader sharedConfgReaderObj]setContactSyncPermissionFlag:TRUE];
    }
    else
    {
        EnLogd(@"Contacts permission denied.");
        acContacts = [UIAlertController alertControllerWithTitle:@"Contacts Permission"
                                                         message:NSLocalizedString(@"CONTACT_ACCESS_WARNING",nil)
                                                  preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction* settingsBtn = [UIAlertAction actionWithTitle:@"Settings"
                                                              style:(UIAlertActionStyleDefault)
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                
                                                                if ([[UIDevice currentDevice].systemVersion floatValue] < 10.0) {
                                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                                } else {
                                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                                                                       options:@{}
                                                                                             completionHandler:^(BOOL success) {
                                                                                                 //KLog(@"success = %d", success);
                                                                                             }];
                                                                }
                                                                
                                                            }];
        UIAlertAction* cancelBtn = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:(UIAlertActionStyleCancel)
                                                          handler:nil];
        
        [acContacts addAction:settingsBtn];
        [acContacts addAction:cancelBtn];
        acContacts.view.tintColor = [UIColor blueColor];
        [self.navigationController presentViewController:acContacts animated:YES completion:nil];
    }
}

-(void)dismissAlert {
    
    if(acContacts) {
        [acContacts dismissViewControllerAnimated:YES completion:nil];
        acContacts = nil;
    }
    if(inviteFriends) {
        [inviteFriends dismissViewControllerAnimated:YES completion:nil];
        inviteFriends = nil;
    }
}

#endif

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end