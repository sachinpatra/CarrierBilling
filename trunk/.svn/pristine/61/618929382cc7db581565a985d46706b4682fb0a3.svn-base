//
//  IVChatTableViewCell.h
//  InstaVoice
//
//  Created by Kieraj Mumick on 6/9/15.
//  Copyright (c) 2015 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contacts.h"
#import "ContactDetailData.h"
#import "IVImageUtility.h"
#import "IVFileLocator.h"

@protocol ChatGridCellDelegate <NSObject>
-(void)audioButtonClickedAtIndex:(NSInteger)index;
-(void)transcriptButtonClickedAtIndex:(NSInteger)index withMsgDic:(NSDictionary *)msgDic;
-(void)callbackIndicatorClickedAtIndex:(NSInteger)index;
-(void)setCurrentTime:(double)time;
@end

@interface IVChatTableViewCell : UITableViewCell

@property (nonatomic) NSUInteger cellIndex;
@property(nonatomic,weak)id<ChatGridCellDelegate> delegate;
@property (weak, nonatomic) NSDictionary* dic;


-(void)configureCellForChatTile:(NSMutableDictionary*)dic forRow:(int)rowValue;
-(float)voiceViewWidth:(int)duration;
-(void)setupFields;
-(void)setStatusIcon:(NSString *)status isAvs:(int)avsMsg readCount:(int)readCount msgType:(NSString *)msgType;
-(void)updateVoiceView:(NSDictionary *)voiceDic;
-(void)stopPlaying:(id)sender;
-(void)swapPlayPause:(id)sender;
-(NSString*)formatPhoneNumberString:(NSString*)strNumber;
-(IBAction)buttonClicked:(UIButton *)sender;


@end

