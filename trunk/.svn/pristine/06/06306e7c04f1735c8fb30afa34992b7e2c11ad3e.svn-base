//
//  UIDataMgt.h
//  InstaVoice
//
//  Created by Eninov on 13/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate;

@interface UIDataMgt : NSObject
{
    AppDelegate *appDelegate;
    
    NSMutableDictionary *_currentChatUser;
    NSMutableDictionary *_msgDic;
    //NSMutableDictionary *_infoDic; //Voice dic
    NSMutableDictionary* dicHelpChat;
    NSMutableDictionary* dicSuggestionChat;
}
+(UIDataMgt *)sharedDataMgtObj;

-(void)setCurrentChatUser:(NSMutableDictionary*)infoList;
-(NSMutableArray*)getCurrentChat;

//for get current chat user info
-(NSMutableDictionary*)getCurrentChatUserInfo;


-(NSMutableDictionary*)getMessageDic;
-(void)setMessageDic:(NSMutableDictionary*)msgDic;

/**
 * This function is used to get Notes List.
 */
-(NSMutableArray*)getMyNotes:(BOOL)fetchFromDB;

/**
 * This function is used get the vobolo message List.
 */
-(NSMutableArray*)getMyVoboloList:(BOOL)fetchFromDB;

-(void)configureHelpAndSuggestion;
-(NSDictionary*)getHelpChat;
-(NSDictionary*)getSuggestionChat;

@end
