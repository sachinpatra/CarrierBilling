//
//  UsageSummaryAPI.h
//  ReachMe
//
//  Created by Bhaskar Munireddy on 07/02/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsageSummaryAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(UsageSummaryAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(UsageSummaryAPI* req, NSError *error))failure;
@end
