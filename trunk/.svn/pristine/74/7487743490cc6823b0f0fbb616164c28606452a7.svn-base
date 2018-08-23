//
//  OpusCoder.h
//  InstaVoice
//
//  Created by Pandian on 06/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "opus.h"

typedef struct WAV_HEADER {
    char            RIFF[4];              //4
    unsigned int   ChunkSize;             //4
    char            WAVE[4];              //4
    char            fmt[4];               //4
    unsigned int   Subchunk1Size;         //4
    unsigned short AudioFormat;           //2
    unsigned short NumOfChan;             //2
    unsigned int SamplesPerSec;           //4
    unsigned int bytesPerSec;             //4
    unsigned short blockAlign;            //2
    unsigned short bitsPerSample;         //2
    char Subchunk2ID[4];                  //4
    unsigned int Subchunk2Size;           //4
}wav_hdr;

#define MAX_PACKET      1500
#define READ_BUFFER     1024

@interface OpusCoder : NSObject

/**
 Reads RAW PCM data from the given file, encodes it and saves into a file; PCM audio data should be of 8000Hz, 16 bit, mono.
 Parameters:
 nSamplingRate - sampling rate of the input data (8000 hz)
 nBitsPerSec   - bit rate at which the encoder encodes (e.g 6000, 8000, 12000, 16000, 18000, 20000)
 nBandwidth    - //NB=4khz,MB=6,WB=8,SWB=12,FB=20
 inFile - file that contains PCM data
 outFile - file that will contain the encoded OPUS data
 Retusn 0, if there is no error; otherwise retuns any integer value.
 */
+(int) EncodeAudio:(opus_int32)nSamplingRate
           Bitrate:(opus_int32)nBitsPerSec
         Bandwidth:(int)nBandwidth
            PCMFile:(const char*)inFile
          OPUSFile:(const char*)outFile;

+(int) DecodeAudio:(opus_int32)nSamplingRate
          OPUSFile:(const char*)inFile
           PCMFile:(const char*)outPcmFile
           WAVFile:(const char*)outWavFile;

@end
