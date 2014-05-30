//
//  IRESensorRecording.h
//  ImpulseResponseEngine
//
//  Created by Kai Zou on 2014-05-29.
//  Copyright (c) 2014 com.yzz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRESensorRecording : NSObject

@property (assign, nonatomic) int recordingID;
@property (assign, nonatomic) int locationID;
@property (assign, nonatomic) BOOL isValidRecording;

-(id)init;
-(void)registerRecordingWithID:(int)rID AndLocationID:(int)lID;
-(void)zeroAllBuffers;

// functions used for signal processing
-(void)preprocessRecording;
-(void)createTimeForwardMicArrayAndFreqDomArray;

@end
