//
//  CreateGroupAPI.m
//  InstaVoice
//
//  Created by adwivedi on 01/09/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "CreateGroupAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"

@implementation CreateGroupAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(NSMutableDictionary *)groupDic withSuccess:(void (^)(CreateGroupAPI *, NSMutableDictionary *))success failure:(void (^)(CreateGroupAPI *, NSError *))failure
{
    NSString *filePath = [groupDic valueForKey:@"group_pic_path"];
    NSString* fileName =[groupDic valueForKey:@"group_pic_name"];
    
    NSMutableDictionary* requestDic = [groupDic valueForKey:@"group_server_request"];
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:CREATE_GROUP];
    
    if(filePath != Nil && filePath.length > 1)
    {
        [req uploadDataWithRequest:requestDic fileName:fileName filePath:filePath withSuccess:^(NetworkCommon *req, id responseObject) {
            self.response=responseObject;
            success(self,responseObject);
        } failure:^(NetworkCommon *req, NSError *error) {
            //
            failure(self,error);
        }];
    }
    else
    {
        
        [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
            self.response=responseObject;
            
            success(self,responseObject);
        } failure:^(NetworkCommon *req, NSError *error) {
            failure(self,error);
        }];
    }
}

@end
