//
//  FetchCarriersListAPI.m
//  InstaVoice
//
//  Created by Vinoth Meganathan on 9/15/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "FetchCarriersListAPI.h"
#import "NetworkCommon.h"
#import "EventType.h"
#import "SettingModel.h"
#import "ConfigurationReader.h"

#import "TableColumns.h"
#import "HttpConstant.h"
#import "RegistrationApi.h"
#import "Setting.h"

#import "IVSettingsCountryCarrierInfo.h"

@implementation FetchCarriersListAPI
-(id)initWithRequest:(NSMutableDictionary *)request
{
    if(self = [super init])
    {
        _request = [NSMutableDictionary dictionaryWithDictionary:request];
        _response = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)callNetworkRequest:(NSMutableDictionary *)requestDic withSuccess:(void (^)(FetchCarriersListAPI *, NSMutableDictionary *))success failure:(void (^)(FetchCarriersListAPI *, NSError *))failure
{
    //NetworkCommon* req = [[NetworkCommon alloc]init];
    NetworkCommon* req = [NetworkCommon sharedNetworkCommon];
    [NetworkCommon addCommonData:requestDic eventType:GET_CARRIER_DETAILS];
    [req callNetworkRequest:requestDic withSuccess:^(NetworkCommon *req, NSMutableDictionary* responseObject) {
        
        //Create array of carrier details for the country
        NSMutableArray *carrierList = [[NSMutableArray alloc]init];
        
        NSArray *carrierDetailsInfo = responseObject[@"country_list"];
        if (carrierDetailsInfo && [carrierDetailsInfo count]) {
            
            for (NSUInteger i=0; i<[carrierDetailsInfo count]; i++) {
                
                NSDictionary *carrierDetails = [carrierDetailsInfo objectAtIndex:i];
                IVSettingsCountryCarrierInfo *carrierInfo = [[IVSettingsCountryCarrierInfo alloc]initWithCountryCarrierInfo:carrierDetails];
                //Do not include the carrier list which has - \"skip\":\"y\ in the USSD String.
                //As per the mail conversation on date - July 5th add objects whose "test" = "y"

#if SHOW_CARRIER_IN_LIST
                if (![carrierInfo.ussdInfo.skip isEqualToString:@"y"])
                    [carrierList addObject:carrierInfo];
                else if ([carrierInfo.ussdInfo.test isEqualToString:@"y"])
                    [carrierList addObject:carrierInfo];
#else
                if (![carrierInfo.ussdInfo.skip isEqualToString:@"y"])
                    [carrierList addObject:carrierInfo];
    
#endif
            }
            [self.response setObject:carrierList forKey:@"country_list"];
            [self.response setObject:responseObject[@"status"] forKey:@"status"];
        }
        
        //self.response=responseObject;
        success(self,self.response);
    } failure:^(NetworkCommon *req, NSError *error) {
        failure(self,error);
    }];
}

@end
