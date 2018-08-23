//
//  EnquireIVUsersAPI.m
//  InstaVoice
//
//  Created by adwivedi on 03/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "EnquireIVUsersAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "ContactsApi.h"
#import "ConfigurationReader.h"

@implementation EnquireIVUsersAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(NSMutableDictionary *)requestDic withSuccess:(void (^)(EnquireIVUsersAPI *, NSMutableDictionary *))success failure:(void (^)(EnquireIVUsersAPI *, NSError *))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:ENQUIRE_IV_USERS];
    [requestDic setValue:[NSNumber numberWithInt:1] forKey:API_FETCH_PIC_URI_TYPE];
    if([[ConfigurationReader sharedConfgReaderObj]getClearAddressBookFlag])
    {
        [requestDic setValue:[NSNumber numberWithBool:YES] forKey:API_CLEAR_ADDRESS_BOOK];
        [[ConfigurationReader sharedConfgReaderObj]setClearAddressBookFlag:NO];
    }

    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        self.response=responseObject;
        
        success(self,responseObject);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
