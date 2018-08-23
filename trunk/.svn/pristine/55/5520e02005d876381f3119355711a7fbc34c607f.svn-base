//
//  Header.h
//  ReachMe
//
//  Created by Pandian on 09/02/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RATING_NUMBER       @"KEY_RATING_NUMBER"
#define REASON_SELECTED     @"KEY_REASON_SELECTED"
#define USER_COMMENTS       @"KEY USER_COMMENTS"


@interface CallLog: NSObject {
    
    NSString* _callID;
    NSString* _callDescHdr;
    NSString* _callDesc;       //- Start time, Call ID, From address, To address, Duration
    /*
    NSString* _codecUsedHdr;
    NSString* _codecUsed;          //- Codec, Bit rate, Clock rate
    */
    
    NSString* _bwUsageHdr;
    NSString* _bwUsage;        /*- download BW(kbits/s), upload BW (kbits/s), sender loss rate, receiver loss rate, cumulative number of late packets,
                               sender interarrival jitter, receiver interarrival jitter, jitter buffer size (in ms), roundtrip delay(in sec),
                               call quality */
    NSString* _dataOutgoingHdr;
    NSString* _dataOutgoing;    //- Total packets, Duplicate packets, Total bytes
    
    NSString* _dataIncomingHdr;
    NSString* _dataIncoming;    /*- Total packets, Duplicate packets, Bytes of payload, Bytes of payload delivered to app, Packet lost,
                                    Received too late, Bad format, Discarded due to queue overflow */
    NSString* _rtcpPacketsHdr;
    NSString* _rtcpPackets;     //- Sent, Received
    
    NSString* _callQualityHdr;
    NSString* _callQuality;     //- Computed value, User rating, Reason selected, User comments;
    
    NSString* _errorInfo;
}

@property (nonatomic, strong) NSString* callID;
@property (nonatomic, strong) NSString* callDescHdr;
@property (nonatomic, strong) NSString* callDesc;
/*
@property (nonatomic, strong) NSString* codecUsedHdr;
@property (nonatomic, strong) NSString* codecUsed;
*/
@property (nonatomic, strong) NSString* bwUsageHdr;
@property (nonatomic, strong) NSString* bwUsage;
@property (nonatomic, strong) NSString* dataOutgoingHdr;
@property (nonatomic, strong) NSString* dataOutgoing;
@property (nonatomic, strong) NSString* dataIncomingHdr;
@property (nonatomic, strong) NSString* dataIncoming;
@property (nonatomic, strong) NSString* rtcpPacketsHdr;
@property (nonatomic, strong) NSString* rtcpPackets;
@property (nonatomic, strong) NSString* callQualityHdr;
@property (nonatomic, strong) NSString* callQuality;
@property (nonatomic, strong) NSString* errorInfo;

-(void)cleanup;

@end


@interface CallLogMgr: NSObject
{
    CallLog* _log;
}

@property (nonatomic,strong)CallLog* log;
@property (nonatomic, strong)NSString* callerNumber;
@property (nonatomic, strong)NSString* calledNymber;

#ifdef TODO_TRY_LATER
+(void)enumerateAllDb;
+(void)getCallHistory;
#endif

-(NSString*)prepareCallLog;
-(void)save;
-(void)sendLog;
-(void)sendLogWithUserRating:(NSDictionary*)dicRating forCallID:(NSString*)callID;

@end

