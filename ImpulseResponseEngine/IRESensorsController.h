//
//  IRESensorsController.h
//  ImpulseResponseEngine
//
//  Created by Kai Zou on 2014-05-29.
//  Copyright (c) 2014 com.yzz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRESensorRecording.h"

@interface IRESensorsController : NSObject

@property (readonly, nonatomic) BOOL allSensorsStarted;

+(id)getSharedSensorsController;
-(void)startAllSensors;
-(void)stopAllSensors;
-(BOOL)determineAccelerometerThreshold;

-(BOOL)captureDataAtLocation:(IRESensorRecording*)outSensorRecording;

@end
