//
//  VoiceTotextTableViewController.m
//  ReachMe
//
//  Created by Bhaskar Munireddy on 22/03/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "VoiceTotextTableViewController.h"
#import "BaseUI.h"
#import "ContactDetailData.h"
#import "IVFileLocator.h"
#import "InsideConversationScreen.h"
#import "Contacts.h"

@interface VoiceTotextTableViewController (){
    AppDelegate *appDelegate;
}
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UITextView *chargesDetailsText;
@property (weak, nonatomic) IBOutlet UISwitch *transcriptionSwitch;
@property (nonatomic, strong) NSMutableArray *helpTextArray;
@property (nonatomic, strong) NSMutableArray *supportContactList;
@end

@implementation VoiceTotextTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)APP_DELEGATE;
    
    SettingModel* model = [Setting sharedSetting].data;
    [self.transcriptionSwitch setOn:model.userManualTrans animated:YES];
    
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [infoBtn addTarget:self action:@selector(infoClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
    self.navigationItem.rightBarButtonItem = infoButton;
    self.detailLabel.text = @"Voicemail would be converted into text by the voice recognition software.\n\n\nOn enabling, you can request a transcription for an individual Voicemail by tapping on Voice-To-Text button on Voicemail player.";
    
    NSMutableAttributedString *transcriptionCharges = [[NSMutableAttributedString alloc] initWithString:@"Charges: You need sufficient InstaVoice credits to avail this feature. Find more details about country specific pricing and FAQs at reachme.instavoice.com/faq"];
    [transcriptionCharges addAttribute:NSFontAttributeName
                                 value:[UIFont boldSystemFontOfSize:13.0]
                                 range:NSMakeRange(0, 8)];
    [transcriptionCharges addAttribute:NSFontAttributeName
                                 value:[UIFont systemFontOfSize:13.0]
                                 range:NSMakeRange(8, transcriptionCharges.length - 8)];
    
    self.chargesDetailsText.attributedText = transcriptionCharges;
    self.chargesDetailsText.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
    self.chargesDetailsText.dataDetectorTypes = UIDataDetectorTypeAll;
    self.chargesDetailsText.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    
    
    [self configureHelpAndSuggestion];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)configureHelpAndSuggestion
{
    self.helpTextArray = [[NSMutableArray alloc]init];
    self.supportContactList = [[Setting sharedSetting].supportContactList mutableCopy];
    if(self.supportContactList != nil && [self.supportContactList count] > 0)
    {
        NSUInteger count = (NSUInteger)[self.supportContactList count];
        for(NSUInteger  i = 0; i < count; i++)
        {
            NSMutableDictionary *dic = [self.supportContactList objectAtIndex:i];
            NSString *supportName = [dic valueForKey:SUPPORT_NAME];
            if([supportName isEqualToString:MENU_FEEDBACK])
            {
                //do nothing
            }
            else
            {
                [self.helpTextArray addObject:dic];
            }
        }
    }
}


- (void)showHelpMessage
{
    if([Common isNetworkAvailable] == NETWORK_AVAILABLE) {
        if (self.helpTextArray != nil && [self.helpTextArray count] > 0) {
            NSUInteger count = [self.helpTextArray count];
            for(NSUInteger  i = 0;i < count; i++) {
                NSDictionary *helpPhoneDic = [self.helpTextArray objectAtIndex:i];
                [self gotoHelpChat:helpPhoneDic];
            }
        }
        else
            [ScreenUtility showAlertMessage:NSLocalizedString(@"NO_SUPPORT_LIST", nil)];
    }
    else {
        //OCT 4, 2016 [ScreenUtility showAlertMessage:NSLocalizedString(@"NET_NOT_AVAILABLE",nil)];
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
    }
}

-(void)gotoHelpChat:(NSDictionary *)supportDic
{
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
    
    NSString *ivUserId = [supportDic valueForKey:SUPPORT_IV_ID];
    [newDic setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
    [newDic setValue:ivUserId forKey:REMOTE_USER_IV_ID];
    [newDic setValue:[supportDic valueForKey:SUPPORT_DATA_VALUE] forKey:FROM_USER_ID];
    [newDic setValue:[supportDic valueForKey:SUPPORT_NAME] forKey:REMOTE_USER_NAME];
    [newDic setValue:[supportDic valueForKey:SUPPORT_PIC_URI] forKey:REMOTE_USER_PIC];
    [newDic setValue:@"" forKey:@"HELP_TEXT"];
    
    
    //- get the pic
    NSNumber* ivID = [NSNumber numberWithLong:[ivUserId longLongValue]];
    NSArray* arr = [[Contacts sharedContact]getContactForIVUserId:ivID usingMainContext:YES];
    ContactDetailData* detailData = Nil;
    if([arr count]>0)
        detailData = [arr objectAtIndex:0];
    
    if(detailData)
        [newDic setValue:[IVFileLocator getNativeContactPicPath:detailData.contactIdParentRelation.contactPic]
                  forKey:REMOTE_USER_PIC];
    
    [appDelegate.dataMgt setCurrentChatUser:newDic];
    
    BaseUI* uiObj = [[InsideConversationScreen alloc]initWithNibName:@"BaseConversationScreen_4.0_ios7Master" bundle:nil];
    uiObj.isAnyChangesSpecificSubClass = YES;
    [self.navigationController pushViewController:uiObj animated:YES];
    
}

- (IBAction)voiceToTextSwitch:(id)sender {
    
    if (self.transcriptionSwitch.isOn) {
        [self.transcriptionSwitch setOn:NO animated:YES];
        UIAlertController *turnOnAlert = [UIAlertController alertControllerWithTitle:@"Turn on Voice-To-Text" message:@"TTurning on Voice-To-Text will enable a button for Voicemail transcription. When you tap on transcribe button, transcription will happen at the background and It may take longer. Transcription confidence will be indicated low, if Voicemail audio is difficult to recognise. An error will be shown, if confident Voicemail transcription is not available. " preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        
        UIAlertAction *agree = [UIAlertAction actionWithTitle:@"Agree" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.transcriptionSwitch setOn:YES animated:YES];
            [[Setting sharedSetting]updateUserSettingType:SettingTypeUserManualTrans andValue:YES];
        }];
        
        [turnOnAlert addAction:cancel];
        [turnOnAlert addAction:agree];
        
        [turnOnAlert.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        [self presentViewController:turnOnAlert animated:YES completion:nil];
    }else{
        [self.transcriptionSwitch setOn:YES animated:YES];
        UIAlertController *turnOffAlert = [UIAlertController alertControllerWithTitle:@"Turn off Voice-To-Text" message:@"Turning off Voice-To-Text will stop showing transcription button on voicemail player. You will not be able to transcribe the Voicemail. Do you want to turn it off?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.transcriptionSwitch setOn:YES animated:YES];
        }];
        
        UIAlertAction *turnOff = [UIAlertAction actionWithTitle:@"Turn off" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.transcriptionSwitch setOn:NO animated:YES];
            [[Setting sharedSetting]updateUserSettingType:SettingTypeUserManualTrans andValue:NO];
        }];
        
        [turnOffAlert addAction:cancel];
        [turnOffAlert addAction:turnOff];
        
        [turnOffAlert.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        [self presentViewController:turnOffAlert animated:YES completion:nil];
    }
}

- (IBAction)infoClicked:(id)sender {
    
    UIAlertController *infoAlert = [UIAlertController alertControllerWithTitle:@"Voice-To-Text" message:@"The transcription service is offered currently only in U.S. English. You'll find that names of places, people's names, and complex words sometimes aren't done as well as you'd like, so it might not be correct. However, the transcription would present the voice message in a quick to read manner which would be helpful." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *liveHelp = [UIAlertAction actionWithTitle:@"Get live help" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self showHelpMessage];
    }];
    
    UIAlertAction *gotIt = [UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    
    [infoAlert addAction:liveHelp];
    [infoAlert addAction:gotIt];
    
    [infoAlert.view setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    [self presentViewController:infoAlert animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
