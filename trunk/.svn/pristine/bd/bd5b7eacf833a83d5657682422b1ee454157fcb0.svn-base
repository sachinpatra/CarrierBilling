//
//  FetchService.h
//  InstaVoice
//
//  Created by Vinoth Meganathan on 4/14/14.
//  Copyright (c) 2014 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FetchServiceOutput <NSObject>
-(void)callBackFetchedData:(id)fetchedData;
@end

@interface FetchService : NSObject
@property(nonatomic,weak) id <FetchServiceOutput> delegateFetchService;
-(id)fetchData:(id)sender;

@end
