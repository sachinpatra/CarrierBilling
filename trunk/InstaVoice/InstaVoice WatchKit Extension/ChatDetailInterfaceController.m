//
//  ChatDetailInterfaceController.m
//  InstaVoice
//
//  Created by adwivedi on 13/04/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import "ChatDetailInterfaceController.h"
#import "MessageRowTypeText.h"
#import "MessageRowTypeAudio.h"
#import "MessageRowTypeImage.h"
#import "IVMediaLoader.h"
#import "IVAudioLoader.h"
#import "IVFileLocator.h"

@interface ChatDetailInterfaceController ()

@end

@implementation ChatDetailInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    if([context isKindOfClass:[NSDictionary class]])
    {
        self.userMessageDic = context;
        self.chatDataList = [NSMutableArray arrayWithObject:self.userMessageDic];
        
        [self.titleText setText:[self.userMessageDic valueForKey:@"REMOTE_USER_NAME"]];
    }
    
    // Configure interface objects here.
    int rowCount = 0;
    NSMutableIndexSet* textSet = [[NSMutableIndexSet alloc]init];
    NSMutableIndexSet* audioSet = [[NSMutableIndexSet alloc]init];
    NSMutableIndexSet* imageSet = [[NSMutableIndexSet alloc]init];
    for(NSDictionary* msg in self.chatDataList)
    {
        if([[msg valueForKey:@"MSG_CONTENT_TYPE"] isEqualToString:@"i"])
        {
            [imageSet addIndex:rowCount];
        }
        else if([[msg valueForKey:@"MSG_CONTENT_TYPE"] isEqualToString:@"a"])
        {
            [audioSet addIndex:rowCount];
        }
        else
        {
            [textSet addIndex:rowCount];
        }
        rowCount++;
    }
    NSMutableArray* rowTypes = [[NSMutableArray alloc]init];
    if(textSet.count)
    {
        [rowTypes addObject:@"messageTextRow"];
        [self.messageListView insertRowsAtIndexes:textSet withRowType:@"messageTextRow"];
        [self.messageListView setNumberOfRows:textSet.count withRowType:@"messageTextRow"];
    }
    if(audioSet.count)
    {
        [rowTypes addObject:@"messageAudioRow"];
        [self.messageListView insertRowsAtIndexes:audioSet withRowType:@"messageAudioRow"];
        [self.messageListView setNumberOfRows:audioSet.count withRowType:@"messageAudioRow"];
    }
    if(imageSet.count)
    {
        [rowTypes addObject:@"messageImageRow"];
        [self.messageListView insertRowsAtIndexes:imageSet withRowType:@"messageImageRow"];
        [self.messageListView setNumberOfRows:imageSet.count withRowType:@"messageImageRow"];
    }
    [self.messageListView setRowTypes:rowTypes];
    
    [self configureTableWithData:self.chatDataList];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)configureTableWithData:(NSArray*)dataObjects {
    
    for (NSInteger i = 0; i < dataObjects.count; i++) {
        NSMutableDictionary* dataObj = [dataObjects objectAtIndex:i];
        
        if([[dataObj valueForKey:@"MSG_CONTENT_TYPE"] isEqualToString:@"i"])
        {
            MessageRowTypeImage* theRow = [self.messageListView rowControllerAtIndex:i];
            NSString *msgContent = [dataObj valueForKey:@"MSG_CONTENT"];
            NSData *data = [msgContent dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSMutableDictionary *imageData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSMutableArray* imageArr = [imageData valueForKey:@"img"];
            for(NSMutableDictionary* imageDic in imageArr)
            {
                NSString* thumbnailURL = [imageDic valueForKey:@"thumb_url"];
                NSString* imageUrl = [imageDic valueForKey:@"url"];
                NSString* base64String = [imageDic valueForKey:@"thumb_base64"];
                
                NSString* msgLocalPath = [dataObj valueForKey:@"MSG_LOCAL_PATH"];
                if(!msgLocalPath || msgLocalPath.length == 0)
                {
                    msgLocalPath = [[dataObj valueForKey:@"MSG_ID"]stringValue];
                }
                UIImage* imgThumbnail = [[IVMediaLoader sharedIVMediaLoader]getThumbnailImageForLocalPath:msgLocalPath serverPath:thumbnailURL base64String:base64String];
                
                UIImage* imgMain = [[IVMediaLoader sharedIVMediaLoader]getImageForLocalPath:msgLocalPath serverPath:imageUrl];
                
                if(imgMain)
                {
                    [theRow.imageMessage setImage:imgMain];
                }
                else if(imgThumbnail)
                {
                    [theRow.imageMessage setImage:imgThumbnail];
                }
                else
                {
                    [theRow.imageMessage setImage:nil];
                }
                
            }
        }
        else if([[dataObj valueForKey:@"MSG_CONTENT_TYPE"] isEqualToString:@"a"])
        {
            MessageRowTypeAudio* theRow = [self.messageListView rowControllerAtIndex:i];
            [theRow.audioMessage setTextColor:[UIColor redColor]];
            [theRow.audioMessage setText:[NSString stringWithFormat:@"Audio : %ld",[[dataObj valueForKey:@"DURATION"]integerValue]]];
            NSString* serverPath = [dataObj valueForKey:@"MSG_CONTENT"];
            NSString* msgLocalPath = [dataObj valueForKey:@"MSG_LOCAL_PATH"];
            if(!msgLocalPath || msgLocalPath.length == 0)
            {
                msgLocalPath = [[dataObj valueForKey:@"MSG_ID"]stringValue];
            }
            msgLocalPath = [IVFileLocator getMediaAudioReceivedPath:msgLocalPath];
            NSFileManager *fm = [NSFileManager defaultManager];
            BOOL isFileExist = [fm fileExistsAtPath:[msgLocalPath stringByAppendingPathExtension:@"wav"]];
            if(isFileExist)
            {
                [theRow.audioMessage setTextColor:[UIColor greenColor]];
            }
            else
            {
                [IVAudioLoader loadAudioFileFromServerWithURL:serverPath andSaveToLocalPath:msgLocalPath withCompletionHandler:^(BOOL result){
                    if(result)
                    {
                        [theRow.audioMessage setTextColor:[UIColor greenColor]];
                    }
                }];
            }
        }
        else
        {
            MessageRowTypeText* theRow = [self.messageListView rowControllerAtIndex:i];
            [theRow.textMessage setText:[dataObj valueForKey:@"MSG_CONTENT"]];
        }
    }
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    NSMutableDictionary* selectedRowData = [self.chatDataList objectAtIndex:rowIndex];
    KLog(@"Data = %@",selectedRowData);
    
}

-(id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex
{
    NSMutableDictionary* selectedRowData = [self.chatDataList objectAtIndex:rowIndex];
    KLog(@"Data = %@",selectedRowData);
    return selectedRowData;
}

@end



