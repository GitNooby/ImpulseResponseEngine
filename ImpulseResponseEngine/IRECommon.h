//
//  IRECommon.h
//  ImpulseResponseEngine
//
//  Created by Kai Zou on 2014-05-29.
//  Copyright (c) 2014 com.yzz. All rights reserved.
//

#ifndef ImpulseResponseEngine_IRECommon_h
#define ImpulseResponseEngine_IRECommon_h

#define kNumDrawBuffers 12
#define kDefaultDrawSamples 1024
#define kMinDrawSamples 256
#define kMaxDrawSamples 4096

#define DATA_BUFF_STRUCT_SIZE 32
#define DATA_BUFF_STRUCT_SIZE_TRIGGER 20
#define MIC_DATA_BUFF_SIZE DATA_BUFF_STRUCT_SIZE*kMinDrawSamples
#define MIC_DATA_BUFF_SIZE_TRIGGER 20

#define TOTAL_NUMBER_OF_SENSORS 7 //this order is important: Mic, AccX, AccY, AccZ, GyroX, GyroY, GyroZ

#define RECORDING_IS_GOOD_MIC_MAX 20
#define RECORDING_IS_GOOD_MIC_MAX_INDEX 500
#define RECORDING_IS_GOOD_MIC_STD 2

#define PREPROCESS_DATA_SUBSAMPLING_RATIO 4
#define PREPROCESS_DATA_WINDOW_SIZE 2048

#endif
