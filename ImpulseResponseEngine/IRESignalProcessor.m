//
//  IRESignalProcessor.m
//  ImpulseResponseEngine
//
//  Created by Kai Zou on 2014-05-29.
//  Copyright (c) 2014 com.yzz. All rights reserved.
//

#import "IRESignalProcessor.h"
#import "IRECommon.h"

@interface IRESignalProcessor ()
@property (assign, nonatomic) FFTSetup fftSetup;
@end

@implementation IRESignalProcessor

+(id)getSharedSignalProcessor {
    static IRESignalProcessor *sharedSignalProcessor = nil;
    static dispatch_once_t onceTokenSignalProcessor;
    dispatch_once(&onceTokenSignalProcessor, ^{
        sharedSignalProcessor = [[self alloc] init];
    });
    return sharedSignalProcessor;
}

-(id)init {
    self = [super init];
    if (self) {
        int len = PREPROCESS_DATA_WINDOW_SIZE*2;
        const int log2n = (int)(log10(len)/log10(2));
        self.fftSetup = vDSP_create_fftsetup(log2n, kFFTRadix2);
    }
    return self;
}

-(void)dealloc {
    if (self.fftSetup != NULL) {
        vDSP_destroy_fftsetup(self.fftSetup);
    }
}


@end
