//
//  IREViewController.m
//  ImpulseResponseEngine
//
//  Created by Kai Zou on 2014-05-28.
//  Copyright (c) 2014 com.yzz. All rights reserved.
//

#import "IREViewController.h"
#import "IREAudioRecorderQueue.h"

@interface IREViewController () {
    IREAudioRecorderQueue *audioRecorderQueue;
}

@end

@implementation IREViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    audioRecorderQueue = [IREAudioRecorderQueue getSharedAudioRecorderQueue];
    [audioRecorderQueue startAudioQueue];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
