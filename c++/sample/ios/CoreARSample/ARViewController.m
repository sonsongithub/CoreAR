//
//  ARViewController.m
//  CoreARSample
//
//  Created by sonson on 11/09/18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ARViewController.h"

@implementation ARViewController

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	[super captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
	
	// image proccessing
	
}

@end
