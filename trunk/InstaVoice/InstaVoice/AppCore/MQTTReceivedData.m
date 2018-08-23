//
//  MQTTReceivedData.m
//  InstaVoice
//
//  Created by adwivedi on 20/05/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "MQTTReceivedData.h"

@implementation MQTTReceivedData

-(id)init
{
    if(self = [super init])
    {
        _error = Nil;
        _responseData = [[NSMutableDictionary alloc]init];
        _requestData = [[NSMutableDictionary alloc]init];
        _errorType = 0;
    }
    return self;
}

@end

@implementation MQTTPublishedData

-(id)init
{
    if(self = [super init])
    {
        
    }
    return self;
}

@end
