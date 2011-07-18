/*
 * Core AR
 * CameraViewController.m
 *
 * Copyright (c) Yuichi YOSHIDA, 10/06/25
 * All rights reserved.
 * 
 * BSD License
 *
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this list of
 *  conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *  of conditions and the following disclaimer in the documentation and/or other materia
 * ls provided with the distribution.
 * - Neither the name of the "Yuichi Yoshida" nor the names of its contributors may be u
 * sed to endorse or promote products derived from this software without specific prior 
 * written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
 * XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
 * F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
 * ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
 * AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
 * UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
 * NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
 * CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
 * HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "CameraViewController.h"

#import "InfoViewController.h"
#import "ATKCameraController.h"

@interface CameraViewController()
- (void)prepareToolbar;
- (void)updateFPS:(NSTimer*)timer;
@end

@implementation CameraViewController

#pragma mark -
#pragma mark Instance method

- (void)prepareToolbar {
	// timer for update fps
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateFPS:) userInfo:nil repeats:YES];
	
	// label to show fps
	fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 427, 80, 33)];
	[fpsLabel setFont:[UIFont boldSystemFontOfSize:20]];
	[fpsLabel setTextColor:[UIColor whiteColor]];
	[fpsLabel setShadowColor:[UIColor blackColor]];
	[fpsLabel setBackgroundColor:[UIColor clearColor]];
	
	thresholdSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
	[thresholdSlider setMinimumValue:0];
	[thresholdSlider setMaximumValue:255];
	[thresholdSlider setValue:120];
	[thresholdSlider addTarget:camera action:@selector(changedThreshold:) forControlEvents:UIControlEventValueChanged];
	
	// setup toolbar
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44)];
	UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Info", nil) style:UIBarButtonItemStyleBordered target:nil action:@selector(info:)];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *labelButton = [[UIBarButtonItem alloc] initWithCustomView:fpsLabel];
	UIBarButtonItem *sliderButton = [[UIBarButtonItem alloc] initWithCustomView:thresholdSlider];
	[toolbar setItems:[NSArray arrayWithObjects:info, flexibleSpace, sliderButton, flexibleSpace, labelButton, nil]];
	[self.view addSubview:toolbar];
	[info release];
	[sliderButton release];
	[thresholdSlider release];
}

- (void)updateFPS:(NSTimer*)timer {
	NSString *text = [NSString stringWithFormat:@"%3.1f fps", [camera fps]];
	[fpsLabel setText:text];
}

#pragma mark -
#pragma mark Class method

+ (UINavigationController*)navigationController {
	CameraViewController *con = [[CameraViewController alloc] initWithNibName:nil bundle:nil];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:con];
	[con release];
	return [nav autorelease];
}

#pragma mark -
#pragma mark Override

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    self = [super initWithNibName:nibName bundle:nibBundle];
	if (self) {
		
		// CoreAR Parameter setup
		CRSetDecodePixelBuffWidthHeight(96);
		CRSetXFocalLength(457.89);
		CRSetYFocalLength(457.29);
		CRCodeImageTemplateSetMatchingThreshold(0.85);
		CRCodeImageTemplateSetTemplateMatchingGridSize(12);
		CRCodeImageTemplateSetTemplateMatchingBinSize(2);

#if TARGET_IPHONE_SIMULATOR
#else
		// use YCbCr
		camera = [[ATKCameraController alloc] initWithSessionPreset:AVCaptureSessionPresetMedium pixelFormat:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
		
		// use RGBA
		//camera = [[ATKCameraController alloc] initWithSessionPreset:AVCaptureSessionPresetMedium pixelFormat:kCVPixelFormatType_32BGRA];
		
		// setting preview layer
		previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:[camera session]];
		//previewLayer.frame = CGRectMake(0, 0, 320, 427);//self.view.bounds.size.width, self.view.bounds.size.height);
		previewLayer.frame = CGRectMake(0, 0, 768.0, 768.0*427.0/320.0);
		[self.view.layer addSublayer:previewLayer];
		
		// for debugging
		[self.view addSubview:[camera preview]];
		
		id v2 = [camera glView];
		[self.view addSubview:v2];
	
		// start camera and analyzing
		[camera start];
#endif
		[self prepareToolbar];
	}
	return self;
}

- (void)info:(id)sender {
#if TARGET_IPHONE_SIMULATOR
#else
	if ([camera isRunning]) {
		[camera stop];
	}
#endif
	
	UINavigationController *nav = [InfoViewController controllerWithNavigationController];
	[self presentModalViewController:nav animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
#if TARGET_IPHONE_SIMULATOR
#else
	if (camera) {
		if (![camera isRunning]) {
			[camera start];
		}
	}
#endif
}

- (void)dealloc {
	[toolbar release];
	[camera release];
	[super dealloc];
}

@end
