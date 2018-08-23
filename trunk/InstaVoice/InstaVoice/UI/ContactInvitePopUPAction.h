//
//  ContactInvitePopUPAction.h
//  InstaVoice
//
//  Created by adwivedi on 16/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactData.h"

@interface ContactInvitePopUPAction : NSObject

+(void)setParentView:(id)parent;
+(id)sharedPopUPAction;

+(void)createContactAlert:(ContactData *)data alertType:(NSString *) alertType deviceHeight:(CGSize)deviceHeight alertView:(CustomIOS7AlertView *)popUp;

@end
