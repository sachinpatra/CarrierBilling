//
//  CustomCallViewController.h
//  ReachMe
//
//  Created by Bhaskar Munireddy on 10/05/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUI.h"

typedef enum: NSInteger {
    CallOptionNone,
    CallOptionFreeCall,  //- Remote user is IV user and GSM call is not supported. (debits = -1)
    CallOptionInvite,    //- Remote user is non-IV user and GSM call is not supported. (debits = -1)
    CallOptionGsm,       //- Remote user is non-IV user but GSM call is supported
    CallOptionGsmFree,   //- Remote user is IV user and GSM call is supported
    CallOptionGsmInvite  //- Remote user is non-IV user and GSM call is supported
} CallOption;

@interface CustomCallViewController : BaseUI
{
    NSMutableArray* _arrFromNumbers;
    NSMutableArray* _arrToNumbers;
    NSString* _calleeProfilePicPath;
    NSString* _calleeName;
    BOOL _isCalleeIVUser;// ReachMe user or not
    NSString* _callCharge;
    CallOption _opSelected;
}

@property (nonatomic, strong) NSMutableArray* arrFromNumbers;
@property (nonatomic, strong) NSMutableArray* arrToNumbers;
@property (nonatomic, strong) NSString* calleeProfilePicPath;
@property (nonatomic, strong) NSString* calleeName;
@property BOOL isCalleeIVUser;
@property (nonatomic, strong) NSDictionary* calleeInfo;

@end
