//
//  IRESignalProcessor.h
//  ImpulseResponseEngine
//
//  Created by Kai Zou on 2014-05-29.
//  Copyright (c) 2014 com.yzz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface IRESignalProcessor : NSObject

+(id)getSharedSignalProcessor;

-(float)crosscorrelateMicInput:(float *)micInput WithMicRef:(float *)micRef ofLength:(int)length;

//fft functions and helpers
-(DSPSplitComplex *) malloc_DSPSplitComplexWithLength:(int)length;
-(void) free_DSPSplitComplex:(DSPSplitComplex *)myComplexArray;
-(void) reverse_array:(float *)array ofLen:(int)arrayLen;
-(void) fft_print_output:(DSPSplitComplex *)fft_data ofLen:(int)fft_data_len;
-(void) scale_fft_result:(DSPSplitComplex *)fft_data ofLen:(int)fft_data_len;
-(void) scale_ifft_result:(DSPSplitComplex *)fft_data ofLen:(int)fft_data_len;
-(void) complex_array_multiply_A:(DSPSplitComplex *)A ofLen:(int)lenA withB:(DSPSplitComplex *)B ofLen:(int)lenB output:(DSPSplitComplex*)output;
-(void) ifft_wrap:(DSPSplitComplex*)ifft_in ofInputLen:(int)inLen output:(DSPSplitComplex*)ifft_out;
-(void) fft_wrap:(float*)input ofInputLen:(int)lenInput toGetOutput:(DSPSplitComplex*)output ofOutputLen:(int)fftOutputLen;
-(float)fftxcorr_TapRecording:(DSPSplitComplex *)tapRecording_micFreqDomForward withTapTemplate:(DSPSplitComplex *)tapTemplate_micFreqDomReversed ofLen:(int)complex_array_len;

@end
