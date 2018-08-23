//
//  InAppPurchaseApi.h
//  InstaVoice
//
//  Created by Gundala Yaswanth on 12/5/17.
//  Copyright © 2017 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InAppPurchaseApi : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}

@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(InAppPurchaseApi* req , NSMutableDictionary* responseObject))success failure:(void (^)(InAppPurchaseApi* req, NSError *error))failure;
- (void)callNetworkRequestToFetchProductList:(NSMutableDictionary*) requestDic withSuccess:(void (^)(InAppPurchaseApi* req , NSMutableDictionary* responseObject))success failure:(void (^)(InAppPurchaseApi* req, NSError *error))failure;
@end
