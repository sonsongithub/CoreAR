//
//  CameraController+simulator.m
//  AR
//
//  Created by sonson on 11/02/06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraController+simulator.h"

#if TARGET_IPHONE_SIMULATOR

@implementation CameraController(simulator)

- (BOOL)setupCameraWithSessionPreset:(NSString *)sessionPresetString pixelFormat:(int)format {
	return YES;
}

- (BOOL)updateFrameSizeWithSessionPreset:(NSString*)sessionPresetString {
    frameSize = CGSizeMake(640, 480);
    return YES;
}

@end

#endif