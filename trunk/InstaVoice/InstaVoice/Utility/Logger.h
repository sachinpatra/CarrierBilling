//  Logger.h
//  InstaVoice
//
//  Created by Eninov on 11/08/13.
//  Copyright (c) 2013 EninovUser. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define ENABLE_NSLOG 1

#ifdef ENABLE_NSLOG

#define KLog(fmt, ... ) NSLog( @"<%p %@:(%d)> %@", self,\
                                                   [[NSString stringWithUTF8String:__FILE__] lastPathComponent],\
                                                   __LINE__,\
                                                   [NSString stringWithFormat:(fmt), ##__VA_ARGS__] )

#define KLog1(fmt, ... ) NSLog( @"<%s %@:(%d)> %@",__FUNCTION__,\
                                                   [[NSString stringWithUTF8String:__FILE__] lastPathComponent],\
                                                   __LINE__,\
                                                   [NSString stringWithFormat:(fmt), ##__VA_ARGS__] )
#else
#define KLog(fmt, ... )
#define KLog1(fmt, ... )
#endif



#define VERBOSE 0
#define DEBUG   1
#define INFO    2
#define WARNING 3
#define ERROR   4

#define EnLogi(fmt, ...) enLog(INFO,(@"[Line: %ld]: %s " fmt),__LINE__,__PRETTY_FUNCTION__,##__VA_ARGS__);
#define EnLoge(fmt, ...) enLog(ERROR,(@"[Line: %ld]: %s " fmt),__LINE__,__PRETTY_FUNCTION__,##__VA_ARGS__);
#define EnLogv(fmt, ...) enLog(VERBOSE,(@"[Line: %ld]: %s " fmt),__LINE__,__PRETTY_FUNCTION__,##__VA_ARGS__);
#define EnLogw(fmt, ...) enLog(WARNING,(@"[Line: %ld]: %s " fmt),__LINE__,__PRETTY_FUNCTION__,##__VA_ARGS__);
#ifdef DEBUG
#define EnLogd(fmt, ...) enLog(DEBUG,(@"[Line: %ld]: %s " fmt),__LINE__,__PRETTY_FUNCTION__,##__VA_ARGS__)
#else
#define EnLogd(fmt,...)
#endif

void enLog(int level, NSString *format, ...);
int logInit(NSString *filename, bool bEnable);
int setLogLevel(int);
int logClose(void);
BOOL checkLastTime (void);
