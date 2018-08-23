//
//  OpusCoder.m
//  InstaVoice
//
//  Created by Pandian on 06/06/14.
//  Copyright (c) 2014 Kirusa. All rights reserved.
//

#import "OpusCoder.h"
#import "Logger.h"

@interface OpusCoder()

+(void) IntToChar: (opus_uint32) i :(unsigned char*) ch;
+(opus_uint32) CharToInt: (unsigned char*) ch;

@end


@implementation OpusCoder

#pragma mark PRIVATE METHODS
+(void) IntToChar: (opus_uint32) i :(unsigned char*) ch {
    ch[0] = i>>24;
    ch[1] = (i>>16)&0xFF;
    ch[2] = (i>>8)&0xFF;
    ch[3] = i&0xFF;
}

+(opus_uint32) CharToInt: (unsigned char*) ch {
    return ((opus_uint32)ch[0]<<24) | ((opus_uint32)ch[1]<<16) | ((opus_uint32)ch[2]<<8) | (opus_uint32)ch[3];
}


-(id)init
{
    self = [super init];
    return self;
}

#pragma mark OPUS CODER

+(int) EncodeAudio:(opus_int32)nSamplingRate Bitrate:(opus_int32)nBitsPerSec Bandwidth:(int)nBandwidth
           PCMFile:(const char*)inFile OPUSFile:(const char*)outFile
{
    
    int error=0;
    OpusEncoder* enc;
    int nChannels=1;
    int nApp = OPUS_APPLICATION_AUDIO;
    
    FILE* fIn = fopen(inFile,"rb");
    if(!fIn) {
        KLog(@"Could not open input file: %s\n",inFile);
        return -1;
    }
    
    FILE* fOut = fopen(outFile,"wb+");
    if(!fOut) {
        KLog(@"Could not open output file: %s",outFile);
        fclose(fIn);
        return -2;
    }
    
    
    enc = opus_encoder_create(nSamplingRate,nChannels,nApp,&error);
    if(error != OPUS_OK) {
        KLog(@"cannot create encoder: %s\n",opus_strerror(error));
        return -3;
    }
    
    int nUseVbr = 1; //variable bit rate
    int nCvbr=0; // disable constained vbr
    int nComp=3; // complexity
    int nUseInbandFEC=0;
    int nForceMono=1;
    int nUseDtx = 0;
    int nPacketLoss=0; // in percentage
    opus_int32 nSkip=0;
    
    opus_encoder_ctl(enc,OPUS_SET_BITRATE(nBitsPerSec));
    opus_encoder_ctl(enc,OPUS_SET_BANDWIDTH(nBandwidth)); //NB,MB,WB,SWB,FB
    opus_encoder_ctl(enc,OPUS_SET_VBR(nUseVbr));//
    opus_encoder_ctl(enc,OPUS_SET_VBR_CONSTRAINT(nCvbr));
    opus_encoder_ctl(enc,OPUS_SET_COMPLEXITY(nComp));
    
    opus_encoder_ctl(enc,OPUS_SET_INBAND_FEC(nUseInbandFEC));
    opus_encoder_ctl(enc,OPUS_SET_FORCE_CHANNELS(nForceMono));
    opus_encoder_ctl(enc,OPUS_SET_DTX(nUseDtx));
    opus_encoder_ctl(enc,OPUS_SET_PACKET_LOSS_PERC(nPacketLoss));
    opus_encoder_ctl(enc,OPUS_GET_LOOKAHEAD(&nSkip));
    opus_encoder_ctl(enc,OPUS_SET_LSB_DEPTH(16));
    
    
    int nMaxFrameSize=960*6;
    int nMaxPayloadBytes = MAX_PACKET;
    unsigned char* data[2];
    
    short int* nIn = (short*)malloc(nMaxFrameSize*nChannels*sizeof(short));
    short int* nOut = (short*)malloc(nMaxFrameSize*nChannels*sizeof(short));
    unsigned char* fBytes= (unsigned char*)malloc(nMaxFrameSize*nChannels*sizeof(short));
    data[0] = (unsigned char*)calloc(nMaxPayloadBytes,sizeof(char));
    
    int nStop = 0;
    int nFrameSize = nSamplingRate/50;
    int nErr = 0;
    int nCurRead=0;
    int nLen[2];
    int nToggle=0;
    opus_uint32 enc_final_range[2];
    int nCount=0,nCountAct=0;
    int k=0;
    
    
    double bits=0.0, bits_max=0.0, bits_act=0.0, bits2=0.0,nrg;
    
    //SKIP wave header
    char SubchunkID[5];
    wav_hdr wh;
    fread(&wh,1,sizeof(wav_hdr),fIn);
    if(wh.Subchunk2ID[0] !='d') {
        fseek(fIn, wh.Subchunk2Size, SEEK_CUR); //SKIP FLLR
        fread(&SubchunkID,1,4,fIn);
        SubchunkID[4]='\0';
        if(strcmp(SubchunkID,"data")) {
            KLog(@"found data");
        }
    }
    //
    
    while(!nStop) {
        
        nErr = fread(fBytes, sizeof(short)*nChannels, nFrameSize, fIn);
        nCurRead = nErr;
        int i=0;
        for(i=0;i<nCurRead*nChannels;i++) {
            opus_int32 s;
            s=fBytes[2*i+1]<<8|fBytes[2*i];
            s=((s&0xFFFF)^0x8000)-0x8000;
            nIn[i]=s;
        }
        if( nCurRead < nFrameSize) {
            for(i=nCurRead*nChannels;i<nFrameSize*nChannels;i++)
                nIn[i] = 0;
            nStop=1;
        }
        
        nLen[nToggle] = opus_encode(enc, nIn, nFrameSize, data[nToggle],nMaxPayloadBytes);
        opus_encoder_ctl(enc, OPUS_GET_FINAL_RANGE(&enc_final_range[nToggle]));
        if(nLen[nToggle] < 0) {
            KLog(@"opus_encode() returned %d\n",nLen[nToggle]);
            fclose(fIn);
            fclose(fOut);
            return EXIT_FAILURE;
        }
        
        unsigned char int_field[4];
        [self IntToChar: nLen[nToggle]: int_field];
        if(fwrite(int_field,1,4,fOut) != 4) {
            KLog(@"Error writing\n");
            return EXIT_FAILURE;
        }
        [self IntToChar: enc_final_range[nToggle]: int_field ];
        if(fwrite(int_field, 1, 4, fOut) != 4) {
            KLog(@"Error writing\n");
            return EXIT_FAILURE;
        }
        if(fwrite(data[nToggle],1, nLen[nToggle],fOut) != (unsigned)nLen[nToggle]) {
            KLog(@"Error writing\n");
            return EXIT_FAILURE;
        }
        
        bits += nLen[nToggle]*8;
        bits_max = (nLen[nToggle]*8 > bits_max) ? nLen[nToggle]*8 : bits_max;
        if(nCount > nUseInbandFEC) {
            nrg=0.0;
            for(k=0;k<nFrameSize*nChannels;k++) {
                nrg += nIn[k] * (double)nIn[k];
            }
        }
        if( (nrg / (nFrameSize*nChannels)) > 1e5) {
            bits_act += nLen[nToggle]*8;
            nCountAct++;
        }
        
        bits2 += nLen[nToggle]*nLen[nToggle]*64;
        
        nCount++;
        nToggle = (nToggle + nUseInbandFEC) & 1;
    }
    
    opus_encoder_destroy(enc);
    free(data[0]);
    fclose(fIn);
    fclose(fOut);
    free(nIn);
    free(nOut);
    free(fBytes);
    
    return EXIT_SUCCESS;
}


+(int) DecodeAudio:(opus_int32)nSamplingRate OPUSFile:(const char*)inFile PCMFile:(const char*)outPcmFile WAVFile:(const char*)outWavFile
{
    int error=0;
    OpusDecoder* dec;
    int nChannels=1;
    
    
    FILE* fIn = fopen(inFile,"rb");
    if(!fIn) {
        KLog(@"Could not open input file: %s\n",inFile);
        return -1;
    }
    
    FILE* fOut = fopen(outPcmFile,"wb+");
    if(!fOut) {
        KLog(@"Could not open output file: %s",outPcmFile);
        fclose(fIn);
        return -2;
    }
    
    dec = opus_decoder_create(nSamplingRate,nChannels,&error);
    if(error != OPUS_OK) {
        KLog(@"cannot create decoder: %s\n",opus_strerror(error));
        return -3;
    }
    
    
    int nUseInbandFEC=0;
    opus_int32 nSkip=0;
    
    int nMaxFrameSize=960*6;
    int nMaxPayloadBytes = MAX_PACKET;
    unsigned char* data[2];
    
    short int* nIn = (short*)malloc(nMaxFrameSize*nChannels*sizeof(short));
    short int* nOut = (short*)malloc(nMaxFrameSize*nChannels*sizeof(short));
    unsigned char* fBytes= (unsigned char*)malloc(nMaxFrameSize*nChannels*sizeof(short));
    data[0] = (unsigned char*)calloc(nMaxPayloadBytes,sizeof(char));
    
    int nStop = 0;
    int nFrameSize = nSamplingRate/50;
    int nErr = 0;
    int nLen[2];
    int nToggle=0;
    opus_uint32 enc_final_range[2];
    opus_int32 nCount=0,nCountAct=0;
    
    double bits=0.0, bits_max=0.0, bits_act=0.0, bits2=0.0,nrg;
    int packet_loss_perc=0;
    opus_uint32 dec_final_range;
    int lost=0,lost_prev=1;
    
    while(!nStop) {
        unsigned char ch[4];
        nErr = fread(ch,1,4,fIn);
        if(feof(fIn)) break;
        nLen[nToggle] = [self CharToInt:ch];
        if(nLen[nToggle] > nMaxPayloadBytes || nLen[nToggle] < 0) {
            KLog(@"Invalid paylod length :%d\n",nLen[nToggle]);
            break;
        }
        
        nErr = fread(ch,1,4,fIn);
        enc_final_range[nToggle] = [self CharToInt:ch];
        nErr = fread(data[nToggle],1,nLen[nToggle],fIn);
        if(nErr < nLen[nToggle]) {
            KLog(@"Ran out of input\n");
            break;
        }
        
        int output_samples;
        lost = nLen[nToggle]==0 || (packet_loss_perc>0 && rand()%100 < packet_loss_perc);
        if(lost)
            opus_decoder_ctl(dec, OPUS_GET_LAST_PACKET_DURATION(&output_samples));
        else
            output_samples = nMaxFrameSize;
        
        if(nCount >= nUseInbandFEC) {
            output_samples = opus_decode(dec, lost?NULL:data[nToggle], nLen[nToggle], nOut, output_samples, 0);
            if(output_samples>0){
                if(output_samples>nSkip) {
                    int i=0;
                    for(i=0;i<(output_samples-nSkip)*nChannels;i++) {
                        short s;
                        s=nOut[i+(nSkip*nChannels)];
                        fBytes[2*i]=s&0xFF;
                        fBytes[2*i+1]=(s>>8)&0xFF;
                    }
                    if(fwrite(fBytes,sizeof(short)*nChannels,output_samples-nSkip,fOut) != (unsigned)(output_samples-nSkip)) {
                        return -4;
                    }
                }
                if(output_samples<nSkip) nSkip -= output_samples;
                else nSkip=0;
            } else {
                KLog(@"Error decoding frame");
            }
        }
        
        opus_decoder_ctl(dec, OPUS_GET_FINAL_RANGE(&dec_final_range));
        if( enc_final_range[nToggle^nUseInbandFEC]!=0 && !lost && !lost_prev && dec_final_range != enc_final_range[nToggle^nUseInbandFEC]) {
            KLog(@"Error: Range coder state mismatch\n");
            fclose(fIn);
            fclose(fOut);
            return -5;
        }
        lost_prev = lost;
        
        bits += nLen[nToggle]*8;
        bits_max = (nLen[nToggle]*8 > bits_max) ? nLen[nToggle]*8 : bits_max;
        if(nCount>= nUseInbandFEC) {
            nrg = 0.0;
            if((nrg / (nFrameSize * nChannels)) > 1e5) {
                bits_act += nLen[nToggle*8];
                nCountAct++;
            }
            bits2 += nLen[nToggle]*nLen[nToggle]*64;
        }
        nCount++;
        nToggle = (nToggle+nUseInbandFEC) & 1;
        
    }
    
    opus_decoder_destroy(dec);
    free(data[0]);
    fclose(fIn);
    fclose(fOut);
    free(nIn);
    free(nOut);
    free(fBytes);

    fIn = fopen(outPcmFile,"rb"); // decoded data
    if(!fIn) return -6;
    
    fOut = fopen(outWavFile,"wb");
    if(!fOut) return -7;
    
    
    wav_hdr waveHdr;
    fseek(fIn, 0, SEEK_END);
    long fileSize = ftell(fIn);
    fseek(fIn,0,SEEK_SET);
    
    waveHdr.RIFF[0]='R';waveHdr.RIFF[1]='I';waveHdr.RIFF[2]='F';waveHdr.RIFF[3]='F';  //Chunk ID
    waveHdr.ChunkSize = fileSize + 4044 + 44;  //Chunk size
    waveHdr.WAVE[0]='W';waveHdr.WAVE[1]='A';waveHdr.WAVE[2]='V';waveHdr.WAVE[3]='E'; //WAVE
    
    waveHdr.fmt[0]='f';waveHdr.fmt[1]='m';waveHdr.fmt[2]='t'; waveHdr.fmt[3]=' '; //format
    waveHdr.Subchunk1Size=16;
    waveHdr.AudioFormat=1;
    waveHdr.NumOfChan=1;
    waveHdr.SamplesPerSec=8000;
    waveHdr.bytesPerSec = 16000;
    waveHdr.blockAlign = 2;
    waveHdr.bitsPerSample=16;
    
    waveHdr.Subchunk2ID[0]='F'; waveHdr.Subchunk2ID[1]='L'; waveHdr.Subchunk2ID[2]='L'; waveHdr.Subchunk2ID[3]='R';
    waveHdr.Subchunk2Size = 4044;
    fwrite(&waveHdr, 1, sizeof(wav_hdr), fOut);
    
    
#define IOS
#ifdef IOS
	char byte[4044+1]={0};
	fwrite(&byte,1,4044,fOut);
#endif
    
    char SubchunkID[4];
    unsigned long SubchunkSize=fileSize;
    SubchunkID[0]='d'; SubchunkID[1]='a'; SubchunkID[2]='t'; SubchunkID[3]='a';
    
    fwrite(&SubchunkID,1,sizeof(SubchunkID),fOut);
    fwrite(&SubchunkSize,1,sizeof(SubchunkSize),fOut);
    
    char buf[READ_BUFFER+1]={0};
	int nRead = 0;
	nRead = fread(&buf,1,READ_BUFFER,fIn);
	while(!feof(fIn)) {
		fwrite(&buf,1,nRead,fOut);
		nRead = fread(&buf,1,READ_BUFFER,fIn);
	}
    
	if(nRead > 0) {
		fwrite(&buf,1,nRead,fOut);
	}
    
    fclose(fIn);
    fclose(fOut);
    
    return 0;
}

@end
