//
//  IRESensorsController.m
//  ImpulseResponseEngine
//
//  Created by Kai Zou on 2014-05-29.
//  Copyright (c) 2014 com.yzz. All rights reserved.
//

#import "IRESensorsController.h"
#import <CoreMotion/CoreMotion.h>
#import "IREAudioRecorderQueue.h"
#import "IRECommon.h"

#define DEFAULT_ACCEL_THRESHHOLD 0.05
#define THRESHOLD_FACTOR 3
#define ACCEL_GYRO_READ_INTERVAL 0.009
#define ACCEL_UPDATE_INTERVAL 0.0 //0.0 will default to 0.01
#define GYRO_UPDATE_INTERVAL 0.0 //0.0 will default to 0.01
#define ACCEL_Z_QUIET_STD 0.003

// TODO: this class requires some thread concurrency control

@interface IRESensorsController () {
    double AccZ_Average, AccZ_Deviation;
}
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (weak, nonatomic) IREAudioRecorderQueue *audioRecorderQueue;
@end

@implementation IRESensorsController

+(id)getSharedSensorsController {
    static IRESensorsController *sharedSensorsController = nil;
    static dispatch_once_t onceTokenSensorController;
    dispatch_once(&onceTokenSensorController, ^{
        sharedSensorsController = [[self alloc] init];
    });
    return sharedSensorsController;
}

-(id)init {
    self = [super init];
    if (self) {
        // grab a motion manager
        self.motionManager = [[CMMotionManager alloc] init];
        [self.motionManager setAccelerometerUpdateInterval:ACCEL_UPDATE_INTERVAL];
        [self.motionManager setGyroUpdateInterval:GYRO_UPDATE_INTERVAL];
        
        self.audioRecorderQueue = [IREAudioRecorderQueue getSharedAudioRecorderQueue];
        
        AccZ_Average = 0;
        AccZ_Deviation = 0;
    }
    return self;
}

-(void)startAllSensors {
    // TODO: should make this thread safe
    
    // audio queue start up
    [self.audioRecorderQueue startAudioQueue]; // will immediately begin mic recording
    
    // gyro and accel start up
    [self.motionManager startAccelerometerUpdates];
    [self.motionManager startGyroUpdates];
    
    _allSensorsStarted = YES;
}

-(void)stopAllSensors {
    // TODO: should make this thread safe
    
    [self.motionManager stopDeviceMotionUpdates];
    [self.audioRecorderQueue startAudioQueue];
    _allSensorsStarted = NO;
}

-(BOOL)determineAccelerometerThreshold {
    // TODO: probably should do this in a separate thread
    
    if (_allSensorsStarted == YES) {
        // Only determine accel threshold if everything is shut off
        return NO;
    }
    
    [self.motionManager setAccelerometerUpdateInterval:ACCEL_UPDATE_INTERVAL];
    [self.motionManager startAccelerometerUpdates];
    
    while (self.motionManager.accelerometerActive == NO) {
        [NSThread sleepForTimeInterval:0.01];
    }
    [NSThread sleepForTimeInterval:0.01];
    
    double calibrationZ[100];
    
    BOOL doneFlag = NO;
    while (doneFlag == NO) {
        double sumAccZ = 0;
        double max_AccZ = DBL_MIN;
        double min_AccZ = DBL_MAX;
        double AccZ = 0;
        int totalRun = 100;
        
        for (int i=0; i<totalRun; i++) {
            [NSThread sleepForTimeInterval:ACCEL_GYRO_READ_INTERVAL];
            AccZ = self.motionManager.accelerometerData.acceleration.z;
            if (AccZ > max_AccZ) max_AccZ = AccZ;
            if (AccZ < min_AccZ) min_AccZ = AccZ;
            sumAccZ += AccZ;
            calibrationZ[i] = AccZ;
        }
        
        AccZ_Average = sumAccZ/totalRun;
        if (max_AccZ - AccZ_Average > AccZ_Average - min_AccZ) {
            AccZ_Deviation = max_AccZ - AccZ_Average;
        } else {
            AccZ_Deviation = AccZ_Average - min_AccZ;
        }
        
        float std = 0;
        for (int i=0; i<totalRun; i++) {
            std += (calibrationZ[i] - AccZ_Average) * (calibrationZ[i] - AccZ_Average);
        }
        std = sqrt(std/totalRun);
        if (std < ACCEL_Z_QUIET_STD) {
            doneFlag = true; // keep trying until we get a good calibration
        }
    }
    return true;
}




@end
