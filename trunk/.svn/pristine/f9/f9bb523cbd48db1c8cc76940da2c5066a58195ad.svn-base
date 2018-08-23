//
//  DownloadProfilePic.h
//  InstaVoice
//
//  Created by adwivedi on 08/05/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

/** This class is responsible for downlaoding the resources with path - resource may be image, audio 
 TODO: Name of the class should be in general but - Its not - Need to change it*/


#import <Foundation/Foundation.h>

@interface DownloadProfilePic : NSObject
{
    NSMutableDictionary* _request;
    NSMutableDictionary* _response;
}
@property(nonatomic,strong)NSMutableDictionary* request;
@property(nonatomic,strong)NSMutableDictionary* response;

-(id)initWithRequest:(NSMutableDictionary*)request;

- (void)callNetworkRequest:(NSString*) requestDic withSuccess:(void (^)(DownloadProfilePic* req , NSData* responseObject))success failure:(void (^)(DownloadProfilePic* req, NSError *error))failure;


@end
