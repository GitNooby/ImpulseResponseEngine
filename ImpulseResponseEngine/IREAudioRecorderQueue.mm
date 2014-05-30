//
//  IREAudioRecorderQueue.m
//  ImpulseResponseEngine
//
//  Created by Kai Zou on 2014-05-28.
//  Copyright (c) 2014 com.yzz. All rights reserved.
//

#import "IREAudioRecorderQueue.h"
#import <AudioToolbox/AudioToolbox.h>
#import "FixedFifo.h"

#define kNumberRecordBuffers 3

#define kNumDrawBuffers 12
#define kDefaultDrawSamples 1024
#define kMinDrawSamples 256
#define kMaxDrawSamples 4096

#define DATA_BUFF_STRUCT_SIZE 32
#define DATA_BUFF_STRUCT_SIZE_TRIGGER 20
#define MIC_DATA_BUFF_SIZE DATA_BUFF_STRUCT_SIZE*kMinDrawSamples
#define MIC_DATA_BUFF_SIZE_TRIGGER 20

typedef struct CallbackInputStruct {
    BOOL queueIsRunning;
    AudioFileID recordFile;
    SInt64 recordPacket;
    FixedFifo *audioFifo;
}CallbackInputStruct;

@interface IREAudioRecorderQueue () {
    AudioStreamBasicDescription recordFormat;
    
    AudioQueueRef audioQueue;
    
    CallbackInputStruct callbackInput;
//    FixedFifo *audioFifo;
}
@end

@implementation IREAudioRecorderQueue

+(id)getSharedAudioRecorderQueue {
    static IREAudioRecorderQueue *sharedAudioRecorderQueue = nil;
    static dispatch_once_t onceTokenAudioRecorderQueue;
    dispatch_once(&onceTokenAudioRecorderQueue, ^{
        sharedAudioRecorderQueue = [[self alloc] init];
    });
    return sharedAudioRecorderQueue;
}

-(id)init {
    self = [super init];
    if (self) {
        
        callbackInput.audioFifo = new FixedFifo(MIC_DATA_BUFF_SIZE, MIC_DATA_BUFF_SIZE_TRIGGER);
        
        [self setupAudioRecorderQueue];
        
    }
    return self;
}

-(void)startAudioQueue {
    checkError(AudioQueueStart(audioQueue, NULL), "AudioQueueStart error");
}
-(void)stopAudioQueue {
    checkError(AudioQueueStop(audioQueue, TRUE), "AudioQueueStop error");
}

-(void)destroyAudioQueue {
    AudioQueueDispose(audioQueue, TRUE);
}

#pragma mark - memory managment
-(void)dealloc {
    [self destroyAudioQueue];
}

#pragma mark - Custom callback used by the audio queue
static void audioQueueInputCallback(void *inUserData, AudioQueueRef inQueue, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime, UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc) {
    CallbackInputStruct *recorder = (CallbackInputStruct*)inUserData;
    if (inNumPackets > 0) {
//        checkError(AudioFileWritePackets(recorder->recordFile, FALSE, inBuffer->mAudioDataByteSize, inPacketDesc, recorder->recordPacket, &inNumPackets, inBuffer->mAudioData), "AudioFileWritePackets error");
        
//        for(int i=0; i<inBuffer->mAudioDataByteSize; i++) {
//            NSLog(@"%d", (int)inBuffer->mAudioData[i]);
//        }
        
        int sampleCount = inBuffer->mAudioDataBytesCapacity / sizeof (SInt32);
        SInt32 *p = (SInt32*)inBuffer->mAudioData;
        for (int i = 0; i < sampleCount; i++) {
            SInt32 val = p[i];
//            NSLog(@"%d", (int)val);
            recorder->audioFifo->push((float)val);
        }
        
        
//        char *saves = "abcd";
//        NSData *data = [[NSData alloc] initWithBytes:saves length:4];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile"];
//        [data writeToFile:appFile atomically:NO];
        
        recorder->recordPacket += inNumPackets;
    }
    if (recorder->queueIsRunning) {
        checkError(AudioQueueEnqueueBuffer(inQueue, inBuffer, 0, NULL), "AudioQueueEnqueueBuffer failed");
    }
}

#pragma mark - Helper functions for setup
-(void)setupAudioRecorderQueue {
    
    memset(&callbackInput, 0, sizeof(callbackInput));
    
    // Setup the data stream description (data stream format)
    memset(&recordFormat, 0, sizeof(recordFormat));
    recordFormat.mSampleRate = 44100;
    recordFormat.mFormatID = kAudioFormatLinearPCM;
    recordFormat.mBytesPerPacket = 4;
    recordFormat.mFramesPerPacket = 1;
    recordFormat.mBytesPerFrame = 4;
    recordFormat.mChannelsPerFrame = 1;
    recordFormat.mBitsPerChannel = 32;
//    recordFormat.mFormatFlags = kAudioFormatFlagsNativeEndian|kAudioFormatFlagIsPacked|kAudioFormatFlagIsFloat;
    recordFormat.mFormatFlags = kAudioFormatFlagIsPacked|kAudioFormatFlagIsSignedInteger;
    UInt32 propertySize = sizeof(recordFormat);
    checkError(AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &propertySize, &recordFormat), "AudioFormatGetProperty error");
    
    // Setup the audio queue
    memset(&audioQueue, 0, sizeof(audioQueue));
    checkError(AudioQueueNewInput(&recordFormat, audioQueueInputCallback, &callbackInput, NULL, NULL, 0, &audioQueue), "AudioQueueNewInput error");
//    UInt32 size = sizeof(recordFormat);
//    checkError(AudioQueueGetProperty(audioQueue, kAudioConverterCurrentOutputStreamDescription, &recordFormat, &size), "can't get queue's format");

    // Setup audio buffers and enqueue them
    int bufferByteSize = computeRecordBufferSize(&recordFormat, audioQueue, 0.1);
    for (int bufferIdx=0; bufferIdx<kNumberRecordBuffers; bufferIdx++) {
        AudioQueueBufferRef buffer;
        checkError(AudioQueueAllocateBuffer(audioQueue, bufferByteSize, &buffer), "AudioQueueAllocateBuffer error");
        checkError(AudioQueueEnqueueBuffer(audioQueue, buffer, 0, NULL), "AudioQueueEnqueueBuffer error");
    }

}

static void checkError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    char errorString[20];
    *(UInt32*)(errorString+1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else {
        sprintf(errorString, "%d", (int)error);
    }
    fprintf(stderr, "error: %s (%s)\n", operation, errorString);
    assert(error == noErr); // if we hit here, then something is seriously wrong with the audio setup
}

static int computeRecordBufferSize(const AudioStreamBasicDescription *format, AudioQueueRef queue, float seconds) {
    int packets, frames, bytes;
    frames = (int)ceil(seconds * format->mSampleRate);
    if (format->mBytesPerFrame > 0) {
        bytes = frames * format->mBytesPerFrame;
    } else {
        UInt32 maxPacketSize;
        if (format->mBytesPerPacket > 0) {
            maxPacketSize = format->mBytesPerPacket;
        } else {
            UInt32 propertySize = sizeof(maxPacketSize);
            checkError(AudioQueueGetProperty(queue, kAudioConverterPropertyMaximumOutputPacketSize, &maxPacketSize, &propertySize), "can't get queue's max output packet size");
        }
        if (format->mFramesPerPacket > 0) {
            packets = frames / format->mFramesPerPacket;
        } else {
            packets = frames;
        }
        if (packets == 0) {
            packets = 1;
        }
        bytes = packets * maxPacketSize;
    }
    return bytes;
}

@end














