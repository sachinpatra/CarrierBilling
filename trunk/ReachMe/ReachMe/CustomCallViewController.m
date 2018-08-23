//
//  CustomCallViewController.m
//  ReachMe
//
//  Created by Bhaskar Munireddy on 10/05/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import "CustomCallViewController.h"
#import "UserProfileModel.h"
#import "Profile.h"
#import "IVFileLocator.h"
#import "SettingModel.h"
#import "Common.h"
#import "Contacts.h"
#import "ContactData.h"
#import "ContactDetailData.h"

NSString* const kIndia = @"91";
NSString* const kUSA = @"1";

NSString* const kValue05 = @"$ 0.05/min"; //for India Numbers
NSString* const kValue03 = @"$ 0.03/min"; //for US Numbers
NSString* const kValue02 = @"$ 0.20/min"; //for other countries

//Defined in LinphoneManager.m
extern NSString* const kLowBalance;
extern NSString* const kLowBalanceTitle;
extern NSString* const kLowBalanceWarning;
//

#define ACCEPTABLE_CHARACTERS @"0123456789"

@interface CustomCallViewController () {
    BOOL isFromDropDown;
    BOOL showCallerDropDown;
    BOOL showCalleeDropDown;
    NSString* _caller;
    NSString* _callee;
}

@property (weak, nonatomic) IBOutlet UIImageView *fromProfilePic;
@property (weak, nonatomic) IBOutlet UIImageView *toProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *fromNumber;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toNumber;
@property (weak, nonatomic) IBOutlet UILabel *toNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *callButton1;
@property (weak, nonatomic) IBOutlet UIButton *callButton2;
@property (weak, nonatomic) IBOutlet UILabel *callTypeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *callTypeLabel2;
@property (weak, nonatomic) IBOutlet UIButton *toDropDownButton;
@property (weak, nonatomic) IBOutlet UIButton *fromDropDownButton;
@property (weak, nonatomic) IBOutlet UITableView *dropDownTable;
@property (weak, nonatomic) IBOutlet UIView *dropDownView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dropDownViewHeightConstant;

@end

@implementation CustomCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _opSelected = CallOptionNone;
    self.fromProfilePic.layer.cornerRadius = 30.0;
    self.toProfilePic.layer.cornerRadius = 30.0;
    
    self.dropDownView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.dropDownView.layer.shadowOffset = CGSizeZero;
    self.dropDownView.layer.shadowOpacity = 1.0f;
    self.dropDownView.layer.shadowRadius = 2;
    self.dropDownView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.dropDownView.bounds].CGPath;
    
    self.dropDownTable.layer.cornerRadius = 5.0;
    self.dropDownTable.layer.masksToBounds = YES;
    self.dropDownTable.tableFooterView = [UIView new];
    
    UITapGestureRecognizer *fromNumeberTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fromNumberGesture:)];
    [self.fromNumber addGestureRecognizer:fromNumeberTap];
    
    UITapGestureRecognizer *toNumeberTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toNumberGesture:)];
    [self.toNumber addGestureRecognizer:toNumeberTap];
    
    UserProfileModel *profileData = [Profile sharedUserProfile].profileData;
    if (profileData) {
        NSString *pathToPicture = [IVFileLocator getMyProfilePicPath:profileData.localPicPath];
        UIImage* callerImg = nil;
        if (pathToPicture && pathToPicture.length > 0)
             callerImg = [UIImage imageWithContentsOfFile:pathToPicture];
        
        if(callerImg) {
            self.fromProfilePic.image = callerImg;
        }
        else {
            [[Profile sharedUserProfile]getProfileDataFromServer];
            self.fromProfilePic.image = [UIImage imageNamed:@"default_profile_img_user"];
        }
        
        UIImage* calleeImg = nil;
        if(self.calleeProfilePicPath.length)
             calleeImg = [ScreenUtility getPicImage:self.calleeProfilePicPath];
        
        if(calleeImg)
            self.toProfilePic.image =  calleeImg;
        else
            self.toProfilePic.image = [UIImage imageNamed:@"default_profile_img_user"];
    }
    
    self.fromNumber.text = [self.arrFromNumbers objectAtIndex:0];
    self.toNumber.text = [self.arrToNumbers objectAtIndex:0];
    self.toNameLabel.text = self.calleeName;
    //self.calleeInfo = [[NSMutableDictionary alloc]init];
    
    if(self.arrFromNumbers.count>1) {
        /*
         showCallerDropDown = YES;
         self.fromDropDownButton.hidden = NO;
         */
        showCalleeDropDown = NO;
        self.fromDropDownButton.hidden = YES;
    } else {
        self.fromDropDownButton.hidden = YES;
        showCallerDropDown = YES;
    }
    
    if(self.arrToNumbers.count>1) {
        showCalleeDropDown = YES;
        self.toDropDownButton.hidden = NO;
    } else {
        self.toDropDownButton.hidden = YES;
        showCalleeDropDown = NO;
    }
    
    [self setCallOptions];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    KLog(@"viewWillDisappear");
}

/*
 Ex:
 dicRate:
 {
 "country_iso2" = IN;
 debits = 5;
 "prefix_debits" =     {
 91973 = 10;
 9199169 = 11;
 };
 pulse = 60;
 "r_pulse" = 2;
 rmVoipDebitPolicyId = 2;
 }
 
 If debits = -1, carrier does not support GSM call for the given country code.
 */

-(CallOption)getCallOptionForCaller:(NSString*)caller  AndCallee:(NSString*)callee WithCallCharge:(NSString*)charge {
    
    CallOption op = CallOptionNone;
    BOOL gsmSupport = NO; //Callee supports GSM call?
    
    //- Get voip_obd flag value for the primary number passed
    VoiceMailInfo* callerVoicemailInfo = [[Setting sharedSetting]voiceMailInfoForPhoneNumber:caller];
    BOOL obdSupport = callerVoicemailInfo.voipOBD; //caller supports VOIP OBD call?
    float callRate=0.0;
    
    if(!charge.length) {
        NSString* countrySimIso = [self.calleeInfo valueForKey:COUNTRY_SIM_ISO];
        NSArray* callRates=nil;
        NSArray* filRate=nil;
        if(!self.calleeInfo.count) {
            callRates = [[Engine sharedEngineObj]fetchObdDebitPolicy:NO];
            //why key is "country_iso2", instead of "COUNTRY_SIM_ISO"
            filRate = [callRates filteredArrayUsingPredicate:
                       [NSPredicate predicateWithFormat:@"self.country_iso2=%@",countrySimIso]];
        } else {
            filRate = [[NSArray alloc]initWithObjects:self.calleeInfo,nil];
        }
        
        //- Find calling charge based on country code of callee's phone number
        if(filRate.count) {
            NSDictionary* dicRate = [filRate objectAtIndex:0];
            if(dicRate.count) {
                NSArray* keyList=nil;
                NSArray* valueList=nil;
                
                NSString* defaultDebits = [dicRate valueForKey:@"debits"];
                NSDictionary* prefixDebits = [dicRate valueForKey:@"prefix_debits"];
                if(prefixDebits.count) {
                    keyList = [prefixDebits allKeys];
                    valueList = [prefixDebits allValues];
                }
                
                if(0 < defaultDebits) {
                    NSString* tmpCallee = [[NSString alloc]initWithString:callee];
                    while(tmpCallee.length>0) {
                        NSArray* resKeyList = [keyList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self MATCHES %@",tmpCallee]];
                        if(resKeyList.count) {
                            NSString* foundKey = [resKeyList objectAtIndex:0];
                            callRate = [[prefixDebits valueForKey:foundKey]floatValue];
                            break;
                        }
                        if(tmpCallee.length>0) {
                            tmpCallee = [tmpCallee substringToIndex:tmpCallee.length-1];
                        } else {
                            KLog(@"Debug");
                        }
                    }
                    if(callRate>0.0) {
                        gsmSupport = YES;
                        callRate /= 100.0;
                        _callCharge = [NSString stringWithFormat:@"$ %.2f/min",callRate];
                    } else {
                        KLog(@"debits not found for the number:%@",callee);
                        EnLogd(@"debits not found for the number:%@",callee);
                    }
                } else {
                    KLog(@"Default debits not found");
                    EnLogd(@"Default debits not found for the number:%@",callee);
                    //TODO: should we allow call?
                }
            }
        } else {
            EnLogd(@"No dic for country_sim_iso=%@",countrySimIso);
            return CallOptionNone;
        }
    } else {
        gsmSupport = YES;
        _callCharge = charge;
    }
    
    [[Engine sharedEngineObj]setCallChargeForNumber:callee WithCharge:_callCharge];
    
    
    if(gsmSupport && obdSupport && self.isCalleeIVUser)
        op = CallOptionGsmFree;
    else if(gsmSupport && !obdSupport && self.isCalleeIVUser)
        op = CallOptionGsm;
    else if(gsmSupport && obdSupport && !self.isCalleeIVUser)
        op = CallOptionGsmInvite;
    else if (gsmSupport && !obdSupport && !self.isCalleeIVUser)
        op = CallOptionGsmInvite;
    else if(!gsmSupport && !self.isCalleeIVUser)
        op = CallOptionInvite;
    else if(!gsmSupport && obdSupport && self.isCalleeIVUser)
        op = CallOptionFreeCall;
    else {
        EnLogd(@"ERR:Invalid option(gsmSupport=%d,obdSupport=%d,isCalleeIv=%d). CHECK the Code.",gsmSupport,obdSupport,self.isCalleeIVUser);
    }
    
    KLog(@"gsmSupport %d, obdSupport=%d, callRate = %f",gsmSupport,obdSupport,callRate);
    KLog(@"call option: %ld", op);
    EnLogd(@"gsmSupport %d, obdSupport=%d, callRate = %f",gsmSupport,obdSupport,callRate);
    EnLogd(@"call option: %ld", op);
    
    return op;
}


-(NSMutableDictionary*)getDebitInfoForNumber:(NSString*)number {
    
    KLog(@"getDebitInfoForNumber - START");
    
    NSMutableDictionary* resDic = nil;
    NSArray* prefixDebits = [[Engine sharedEngineObj]fetchObdDebitPolicy:NO];
    for(NSDictionary* dic in prefixDebits) {
        NSDictionary* prefixList = [dic valueForKey:@"prefix_debits"];
        NSArray* prefixKeys = [prefixList allKeys];
        
        if(prefixKeys.count) {
            @try {
                NSString* pKey = [prefixKeys objectAtIndex:0];
                NSString* firstChar = [pKey substringToIndex:1];
                if(firstChar.length && ![number hasPrefix:firstChar]) {
                    KLog(@"Skip %@", [dic valueForKey:@"country_iso2"]);
                    continue;
                }
            }@catch(NSException* ex) {
                EnLogd(@"ERR:Check the code.");
            }
        }
        NSString* tmpCallee = [[NSString alloc]initWithString:number];
        while(tmpCallee.length>0) {
            NSArray* resKeyList = [prefixKeys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self MATCHES %@",tmpCallee]];
            if(resKeyList.count) {
                resDic = [[NSMutableDictionary alloc]init];
                [resDic setValue:prefixList forKey:@"prefix_debits"];
                [resDic setValue:[dic valueForKey:@"debits"] forKey:@"debits"];
                NSString* simIso = [dic valueForKey:@"country_iso2"];
                [resDic setValue:simIso  forKey:COUNTRY_SIM_ISO];
                break;
            }
            if(tmpCallee.length>0) {
                tmpCallee = [tmpCallee substringToIndex:tmpCallee.length-1];
            } else {
                KLog(@"Debug");
            }
        }
        
        if(resDic.count)
            break;
    }
    
    KLog(@"getDebitInfoForNumber - END");
    
    return resDic;
}

-(void)setCallOptions {
    
    KLog(@"setCallOptions -- START");
    
    NSString* caller = [Common removePlus:self.fromNumber.text];
    NSString* callee = [Common removePlus:self.toNumber.text];
    
    /*
    NSArray* substrings = [callee componentsSeparatedByString:@" "];
    NSString* calleeCC = [substrings objectAtIndex:0];
     */
    
    //- Remove + and space from caller and callee phonenumbers
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    caller = [caller stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    caller = [[caller componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    callee = [callee stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    callee = [[callee componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    //
    
    NSString* ccFromCache=@"";
    if(!self.calleeInfo.count) {
        //- Check the cache for call charge for the selected number
        ccFromCache = [[Engine sharedEngineObj]getCallChargesForNumber:callee];
        if(ccFromCache.length) {
            KLog(@"Call charge found in cache:%@",ccFromCache);
            EnLogd(@"Call charge found in cache:%@",ccFromCache);
        }
        else {
            //- fetch prefix_debits of callee
            self.calleeInfo = [self getDebitInfoForNumber:callee];
        }
    }
    
    if(!self.calleeInfo) {
        EnLogd(@"ERR: CalleeInfo is nil. Check the code.");
        EnLogd(@"ERR: CalleeInfo is nil. Check the code.");
    }
    
    //- Remove + and space from caller and callee phonenumbers
    /*
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    caller = [caller stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    caller = [[caller componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    callee = [callee stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    callee = [[callee componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
     */
    //
    
    //- Check if the new number selected is of IV type
    if(self.arrToNumbers.count>1 && ![_callee isEqualToString:callee]) {
        NSArray* contactDetailList = [[Contacts sharedContact]getContactForPhoneNumber:callee];
        if(contactDetailList.count) {
            ContactDetailData* detail = [contactDetailList objectAtIndex:0];
            if([detail.serverSync boolValue] && [detail.ivUserId longLongValue]>0) {
                self.isCalleeIVUser = YES;
            } else {
                self.isCalleeIVUser = NO;
            }
        }
    }
    
    _caller = caller;
    _callee = callee;
    
     _opSelected = [self getCallOptionForCaller:caller AndCallee:callee WithCallCharge:ccFromCache];
    
    switch(_opSelected) {
        case CallOptionFreeCall: {
            self.callButton1.hidden = NO;
            self.callTypeLabel1.hidden = NO;
            self.callTypeLabel1.text = @"Free Call";
            [self.callButton1 setImage:[UIImage imageNamed:@"free_call"] forState:(UIControlStateNormal)];
            self.callButton2.hidden = YES;
            self.callTypeLabel2.hidden = YES;
        }
            break;
        case CallOptionGsm: {
            self.callButton1.hidden = NO;
            self.callTypeLabel1.hidden = NO;
            self.callTypeLabel1.text = _callCharge;
            [self.callButton1 setImage:[UIImage imageNamed:@"charged_call"] forState:(UIControlStateNormal)];
            
            self.callButton2.hidden = YES;
            self.callTypeLabel2.hidden = YES;
        }
            break;
        case CallOptionInvite: {
            self.callButton1.hidden = NO;
            self.callTypeLabel1.hidden = NO;
            self.callTypeLabel1.text = @"Invite";
            [self.callButton1 setImage:[UIImage imageNamed:@"invite_obd"] forState:(UIControlStateNormal)];
            
            self.callButton2.hidden = YES;
            self.callTypeLabel2.hidden = YES;
        }
            break;
        case CallOptionGsmInvite: {
            self.callButton1.hidden = NO;
            self.callTypeLabel1.hidden = NO;
            self.callTypeLabel1.text = _callCharge;
            [self.callButton1 setImage:[UIImage imageNamed:@"charged_call"] forState:(UIControlStateNormal)];
            
            self.callButton2.hidden = NO;
            self.callTypeLabel2.hidden = NO;
            self.callTypeLabel2.text = @"Invite";
            [self.callButton2 setImage:[UIImage imageNamed:@"invite_obd"] forState:(UIControlStateNormal)];
        }
            break;
        case CallOptionGsmFree: {
            self.callButton1.hidden = NO;
            self.callTypeLabel1.hidden = NO;
            self.callTypeLabel1.text = _callCharge;
            [self.callButton1 setImage:[UIImage imageNamed:@"charged_call"] forState:(UIControlStateNormal)];
            
            self.callButton2.hidden = NO;
            self.callTypeLabel2.hidden = NO;
            self.callTypeLabel2.text = @"Free Call";
            [self.callButton2 setImage:[UIImage imageNamed:@"free_call"] forState:(UIControlStateNormal)];
        }
            break;
        default: {
            EnLogd(@"ERROR:check the code");
        }
            break;
    }
    
    KLog(@"SetCallOptions: END");
}

- (IBAction)callType1:(id)sender {
    
    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
   
    [self setCallOptions];
    
    switch (_opSelected) {
        case CallOptionGsm:
        case CallOptionGsmFree:
        case CallOptionGsmInvite: {
            //- Check credit balance. If credit available is less than 500, do not allow make GSM call.
            AppDelegate* appDelegate = (AppDelegate *)APP_DELEGATE;
            NSUInteger totalCredits = [appDelegate.confgReader getVsmsLimit];
            //totalCredits=0;
            if(totalCredits <= 0) {
                [self dismissViewController];
                [NSNotificationCenter.defaultCenter postNotificationName:kLowBalanceWarning
                                                                  object:self
                                                                userInfo:nil];
                return;
            }
            [LinphoneManager.instance initiateOBDCall:_callee FromNumber:_caller WithCallType:@"gsm"];
        }
            break;
            
        case CallOptionFreeCall:
            [LinphoneManager.instance initiateOBDCall:_callee FromNumber:_caller WithCallType:@"p2p"];
            break;
        case CallOptionInvite:
            [LinphoneManager.instance inviteNewUser];
            break;
            
        default:
            break;
    }
    
    [self dismissViewController];
}

- (IBAction)callType2:(id)sender {
    
    if ([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        [ScreenUtility showAlert:NSLocalizedString(@"NET_NOT_AVAILABLE", nil)];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    KLog(@"App to ReachMe GSM call");
    [self setCallOptions];
    
    switch (_opSelected) {
        case CallOptionGsmFree:
             [LinphoneManager.instance initiateOBDCall:_callee FromNumber:_caller WithCallType:@"p2p"];
            break;
        case CallOptionGsmInvite:
           [LinphoneManager.instance inviteNewUser];
            break;
            
        default:
            break;
    }
}

-(void)fromNumberTapped {
    /*
    if(showCallerDropDown) {
        isFromDropDown = YES;
        [self.dropDownTable reloadData];
        if(self.dropDownView.isHidden) {
            self.dropDownView.hidden = NO;
        } else {
            self.dropDownView.hidden = YES;
        }
    }*/
}

-(void)toNumbberTapped {
    
    if(showCalleeDropDown) {
        isFromDropDown = NO;
        [self.dropDownTable reloadData];
        if(self.dropDownView.isHidden) {
            self.dropDownView.hidden = NO;
        } else {
            self.dropDownView.hidden = YES;
        }
    }
}

- (IBAction)fromDropDown:(id)sender
{
    [self fromNumberTapped];
}

- (IBAction)toDropDown:(id)sender
{
    [self toNumbberTapped];
}

-(void)fromNumberGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [self fromNumberTapped];
}

-(void)toNumberGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [self toNumbberTapped];
}

#pragma TableView Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(isFromDropDown)
        return self.arrFromNumbers.count;
    
    return self.arrToNumbers.count;
    
    //return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.arrToNumbers.count == 2 || self.arrFromNumbers.count == 2) {
        return 73.0;
    }else if (self.arrToNumbers.count == 3 || self.arrFromNumbers.count == 3) {
        return 50.0;
    }
    return 147.0/4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"LinkedNumbers";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSString* phoneNumnber = @"";
    if(isFromDropDown) {
        phoneNumnber = [self.arrFromNumbers objectAtIndex:indexPath.row];
    } else {
        phoneNumnber = [self.arrToNumbers objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = phoneNumnber;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = [UIColor blueColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    
    if(([self.fromNumber.text isEqualToString:phoneNumnber] && isFromDropDown) ||
       ([self.toNumber.text isEqualToString:phoneNumnber] && !isFromDropDown)) {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isFromDropDown) {
        self.fromNumber.text =  [self.arrFromNumbers objectAtIndex:indexPath.row];
    } else {
        self.toNumber.text =  [self.arrToNumbers objectAtIndex:indexPath.row];
    }
    
    self.dropDownView.hidden = YES;
    [self.dropDownTable reloadData];
    self.calleeInfo = nil;//makes getting debits list for the selected number
    [self setCallOptions];
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
