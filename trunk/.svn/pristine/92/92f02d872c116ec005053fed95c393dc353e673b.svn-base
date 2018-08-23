//
//  DBTables.h
//  InstaVoice
//
//  Created by Eninov User on 17/01/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDB.h"


#pragma-mark MESSAGE TABLE
@interface MessageTable : BaseDB
{
    
}

@end

#pragma mark VSMS LIMIT TABLE
@interface VsmsLimitTable : BaseDB

@end


@interface DBTables : NSObject 
{
    MessageTable *msgTableObj;
    VsmsLimitTable *vsmsLimitTblObj;
}

+(id)sharedDBTables;
-(BaseDB *)getTableObj:(int)tableType;

@end
