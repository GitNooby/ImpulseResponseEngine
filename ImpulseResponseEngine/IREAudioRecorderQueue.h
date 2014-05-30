//
//  IREAudioRecorderQueue.h
//  ImpulseResponseEngine
//
//  Created by Kai Zou on 2014-05-28.
//  Copyright (c) 2014 com.yzz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IREAudioRecorderQueue : NSObject

+(id)getSharedAudioRecorderQueue;
-(void)startAudioQueue;
-(void)stopAudioQueue;

@end
