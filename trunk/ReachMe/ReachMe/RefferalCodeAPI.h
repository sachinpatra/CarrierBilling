//
//  RefferalCodeAPI.h
//  ReachMe
//
//  Created by Bhaskar Munireddy on 30/01/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface RefferalCodeAPI : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSMutableDictionary*) requestDic withSuccess:(void (^)(RefferalCodeAPI* req , NSMutableDictionary* responseObject))success failure:(void (^)(RefferalCodeAPI* req, NSError *error))failure;

@end
