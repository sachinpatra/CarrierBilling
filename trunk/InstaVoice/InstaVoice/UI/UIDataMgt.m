//
//  UIDataMgt.m
//  InstaVoice
//
//  Created by Eninov on 13/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import "UIDataMgt.h"

#ifdef REACHME_APP
    #import "AppDelegate_rm.h"
#else
    #import "AppDelegate.h"
#endif

#import "HttpConstant.h"
#import "TableColumns.h"
#import "MyProfileApi.h"
#import "Common.h"
#import "Setting.h"
#import "Contacts.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "IVFileLocator.h"

static UIDataMgt *dataMgtObj = NULL;
@implementation UIDataMgt

-(id)init
{
    self = [super init];
    if(self)
    {
        appDelegate = (AppDelegate*)APP_DELEGATE;
        dicSuggestionChat = nil;
        dicHelpChat = nil;
    }
    return self;
}

+(UIDataMgt *)sharedDataMgtObj
{
    /*
    if(dataMgtObj == NULL)
    {
        dataMgtObj = [[UIDataMgt alloc]init];
    }
    return dataMgtObj;
    */

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataMgtObj = [[UIDataMgt alloc]init];
    });
    return dataMgtObj;
}


-(void)setCurrentChatUser:(NSMutableDictionary*)infoList
{
    if([[infoList valueForKey:CONVERSATION_TYPE]isEqualToString:GROUP_TYPE])
        [infoList setValue:@"0" forKey:REMOTE_USER_IV_ID];
    _currentChatUser = infoList;
    [appDelegate.engObj setCurrentChatUser:infoList];
}

/* FEB 1, 2018
-(void)setVoicedic:(NSMutableDictionary *)infoVoiceDic
{
   _infoDic = infoVoiceDic;
}

-(NSMutableDictionary *)getVoicedic
{
    NSMutableDictionary *dic = nil;
    if(_infoDic != nil)
    {
        dic = [[NSMutableDictionary alloc] initWithDictionary:_infoDic];
        _infoDic = nil;
    }
    
    return dic;
}
*/

-(NSMutableArray*)getCurrentChat
{
    NSMutableArray *currentChatList = [appDelegate.engObj getCurrentChat];
    NSMutableArray *currentChat = nil;
    if(currentChatList != nil && [currentChatList count] != 0)
    {
        currentChat = [[NSMutableArray alloc] init];
        for(NSMutableDictionary *dic in currentChatList)
        {
            /*
            //TODO:FIX ME some of the voice vsms msgs have zero DURATION. It is from the server. why?
            if([[dic valueForKey:DURATION] intValue] == 0)
            {
                if([[dic valueForKey:MSG_CONTENT_TYPE] isEqualToString:@"t"] || [[dic valueForKey:MSG_CONTENT_TYPE] isEqualToString:@"i"])//AVN_TO_DO_IMAGES
                {
                    [currentChat addObject:dic];
                }
            }
            else
            {
                [currentChat addObject:dic];
            }*/
            
            NSString* msgContentType = [dic valueForKey:MSG_CONTENT_TYPE];
            if([msgContentType isEqualToString:@"t"] ||
               [msgContentType isEqualToString:@"i"] ||
               [msgContentType isEqualToString:@"a"])
            {
                [currentChat addObject:dic];
            }
        }
    }
    return currentChat;
}


-(NSMutableDictionary*)getCurrentChatUserInfo
{
    return _currentChatUser;
}


-(NSMutableDictionary*)getMessageDic
{
    return _msgDic;
}

-(void)setMessageDic:(NSMutableDictionary*)msg
{
    _msgDic = msg;
}


-(NSMutableArray*)getMyNotes:(BOOL)fetchFromDB
{
    NSMutableArray *notesList =  [appDelegate.engObj getMyNotes:fetchFromDB];
    NSMutableArray *myNotesList = [[NSMutableArray alloc]init];
    if(notesList != nil && [notesList count] > 0)
    {
        myNotesList= [[NSMutableArray alloc] init];
        for(NSMutableDictionary *dic in notesList)
        {
            if([[dic valueForKey:DURATION] intValue] == 0)
            {
                if([[dic valueForKey:MSG_CONTENT_TYPE] isEqualToString:@"t"] || [[dic valueForKey:MSG_CONTENT_TYPE] isEqualToString:@"i"] || [[dic valueForKey:MSG_CONTENT_TYPE] isEqualToString:@"a"])
                {
                    [myNotesList addObject:dic];
                }
            }
            else
            {
                [myNotesList addObject:dic];
            }
        }
    }
    return myNotesList;

}

-(NSMutableArray*)getMyVoboloList:(BOOL)fetchFromDB
{
    NSMutableArray *vobolos = [appDelegate.engObj getMyVoboloList:fetchFromDB];
    NSMutableArray *myVoboloList = nil;
    if(vobolos != nil && [vobolos count] != 0)
    {
        myVoboloList= [[NSMutableArray alloc] init];
        for(NSMutableDictionary *dic in vobolos)
        {
            if([[dic valueForKey:DURATION] intValue] == 0)
            {
                if([[dic valueForKey:MSG_CONTENT_TYPE] isEqualToString:@"t"] || [[dic valueForKey:MSG_CONTENT_TYPE] isEqualToString:@"i"])
                {
                    [myVoboloList addObject:dic];
                }
                
            }
            else
            {
                [myVoboloList addObject:dic];
            }
        }
    }
    return myVoboloList;

}

-(void)configureHelpAndSuggestion
{
    if(dicSuggestionChat != nil && dicHelpChat != nil) {
        return;
    }
    
    NSMutableArray* supportContactList = [[Setting sharedSetting].supportContactList mutableCopy];
    if(supportContactList != nil && supportContactList.count > 0)
    {
        NSUInteger count = (NSUInteger)supportContactList.count;
        for(NSUInteger  i = 0; i < count; i++)
        {
            NSMutableDictionary *dic = [supportContactList objectAtIndex:i];
            NSString *supportName = [dic valueForKey:SUPPORT_NAME];
            
            NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
            NSString *ivUserId = [dic valueForKey:SUPPORT_IV_ID];
            [newDic setValue:IV_TYPE forKey:REMOTE_USER_TYPE];
            [newDic setValue:ivUserId forKey:REMOTE_USER_IV_ID];
            [newDic setValue:[dic valueForKey:SUPPORT_DATA_VALUE] forKey:FROM_USER_ID];
            [newDic setValue:supportName forKey:REMOTE_USER_NAME];
            [newDic setValue:[dic valueForKey:SUPPORT_PIC_URI] forKey:REMOTE_USER_PIC];
            [newDic setValue:@"" forKey:@"HELP_TEXT"];//TODO default text
            
            //- get the pic
            NSNumber* iVID = [NSNumber numberWithLong:[ivUserId longLongValue]];
            NSArray* arr = [[Contacts sharedContact]getContactForIVUserId:iVID usingMainContext:YES];
            ContactDetailData* detailData = Nil;
            if([arr count]>0)
                detailData = [arr objectAtIndex:0];
            
            if(detailData)
                [newDic setValue:[IVFileLocator getNativeContactPicPath:detailData.contactIdParentRelation.contactPic]
                          forKey:REMOTE_USER_PIC];
            
            if([supportName isEqualToString:MENU_FEEDBACK])
            {
                /*- FIXME: We should get the approp. URL to the images for Help and Suggestion users, but we we are not.
                    Till it is implemented at the server-side, we use the images given in Asset catelogue. Check the AppUpdateUtility.
                 */
                NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString* filePath = [documentsPath stringByAppendingPathComponent:@"/Media/ContactImages/Native/2624835.png"];
                [newDic setValue:filePath forKey:SUPPORT_PIC_URI];
                dicSuggestionChat = [[NSMutableDictionary alloc]initWithDictionary:newDic];
            }
            else
            {
                NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString* filePath = [documentsPath stringByAppendingPathComponent:@"/Media/ContactImages/Native/2624836.png"];
                [newDic setValue:filePath forKey:SUPPORT_PIC_URI];
                
                dicHelpChat = [[NSMutableDictionary alloc]initWithDictionary:newDic];
            }
        }
    }
}

-(NSDictionary*)getHelpChat {
    return dicHelpChat;
}

-(NSDictionary*)getSuggestionChat {
    return dicSuggestionChat;
}

@end
