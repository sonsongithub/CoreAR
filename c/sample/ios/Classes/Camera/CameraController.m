/*
 * Core AR
 * CameraController.m
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

#import "CameraController.h"

#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

// static tic and toc methods

static struct timeval _start, _end;

static void _tic() {
	gettimeofday(&_start, NULL);
}

static void _toc() {
	gettimeofday(&_end, NULL);
	long int e_sec = _end.tv_sec * 1000000 + _end.tv_usec;
	long int s_sec = _start.tv_sec * 1000000 + _start.tv_usec;
	printf( "%9.4lf[ms]\n", (double)(e_sec - s_sec) / 1000.0);
}

// previe image buffer

@implementation ValueBufferPreview

- (id)initWithFrame:(CGRect)frame cameraSize:(CGSize)cameraSize {
	self = [super initWithFrame:frame];
	
	CATransform3D tans = CATransform3DIdentity;
	tans = CATransform3DRotate(tans, -M_PI/2, 0, 0, 1);
	[self.layer setTransform:tans];
	ok = YES;
	return self;
}

- (void)redrawWithImageRef:(CGImageRef)newImage {
	if (newImage != image) {
		CGImageRelease(image);
		image = CGImageRetain(newImage);
		[self.layer setContents:(id)image];
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
			self.frame = CGRectMake(0, 0, 768.0, 768.0*427.0/320.0);
		else
			self.frame = CGRectMake(0, 0, 320, 427);
	}
}

- (void)dealloc {
	CGImageRelease(image);
	[super dealloc];
}

@end

#if TARGET_IPHONE_SIMULATOR

@implementation CameraController

- (ValueBufferPreview*)preview {
	if (valueBufferPreview == nil) {
		valueBufferPreview = [[ValueBufferPreview alloc] initWithFrame:CGRectZero cameraSize:frameSize];
	}
	return valueBufferPreview;
}

- (CGSize)frameSize {
	return frameSize;
}

- (BOOL)updateFrameSizeWithSessionPreset:(NSString*)sessionPresetString {
	frameSize = CGSizeMake(640, 480);
	return YES;
	return NO;
}

- (BOOL)setupCameraWithSessionPreset:(NSString *)sessionPresetString pixelFormat:(int)format {
	return YES;
}

- (id)initWithSessionPreset:(NSString*)sessionPresetString {
	DNSLogMethod
	int format = kCVPixelFormatType_32BGRA;
    self = [super init];
	if (self) {
		if (![self updateFrameSizeWithSessionPreset:sessionPresetString]) {
			[self autorelease];
			return nil;
		}
		if (![self setupCameraWithSessionPreset:sessionPresetString pixelFormat:format]) {
			[self autorelease];
			return nil;
		}
		[self preparePreviewBufferForPixelFormat:format];
	}
	return self;
}

- (id)initWithSessionPreset:(NSString*)sessionPresetString pixelFormat:(int)format {
	DNSLogMethod
    self = [super init];
	if (self) {
		if (![self updateFrameSizeWithSessionPreset:sessionPresetString]) {
			[self autorelease];
			return nil;
		}
		if (![self setupCameraWithSessionPreset:sessionPresetString pixelFormat:format]) {
			[self autorelease];
			return nil;
		}
		[self preparePreviewBufferForPixelFormat:format];
	}
	return self;
}

- (void)preparePreviewBufferForPixelFormat:(int)format {
	// common color space for grayscale preview view
	colorSpaceValueBufferForPreview = CGColorSpaceCreateDeviceGray();
	
	if (format == kCVPixelFormatType_32BGRA) {
		valueBuffer = (unsigned char*)malloc(sizeof(unsigned char)*frameSize.width*frameSize.height * 4);
		tempBuffer = (unsigned char*)malloc(sizeof(unsigned char)*frameSize.width*frameSize.height * 4);
		valueBufferProviderForPreview = CGDataProviderCreateWithData(NULL, valueBuffer, frameSize.width * 4, NULL);
	}
	else if (format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange || format == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
		valueBuffer = (unsigned char*)malloc(sizeof(unsigned char)*frameSize.width*frameSize.height);
		tempBuffer = (unsigned char*)malloc(sizeof(unsigned char)*frameSize.width*frameSize.height);
		valueBufferProviderForPreview = CGDataProviderCreateWithData(NULL, valueBuffer, frameSize.width, NULL);
	}
	else {
	}
}

- (void) dealloc {
	CGDataProviderRelease(valueBufferProviderForPreview);
	SAFE_FREE(valueBuffer);
	CGColorSpaceRelease(colorSpaceValueBufferForPreview);
	[super dealloc];
}

@end


#else

@implementation CameraController

- (ValueBufferPreview*)preview {
	if (valueBufferPreview == nil) {
		valueBufferPreview = [[ValueBufferPreview alloc] initWithFrame:CGRectZero cameraSize:frameSize];
	}
	return valueBufferPreview;
}

#pragma mark -
#pragma mark Private Instance method

- (BOOL)updateFrameSizeWithSessionPreset:(NSString*)sessionPresetString {
	if ([sessionPresetString isEqualToString:AVCaptureSessionPreset1280x720]) {
		frameSize = CGSizeMake(1280, 720);
		return YES;
	}
	else if ([sessionPresetString isEqualToString:AVCaptureSessionPreset640x480]) {
		frameSize = CGSizeMake(640, 480);
		return YES;
	}
	else if ([sessionPresetString isEqualToString:AVCaptureSessionPresetHigh]) {
		frameSize = CGSizeMake(640, 480);
		return YES;
	}
	else if ([sessionPresetString isEqualToString:AVCaptureSessionPresetMedium]) {
		frameSize = CGSizeMake(480, 360);
		return YES;
	}
	else if ([sessionPresetString isEqualToString:AVCaptureSessionPresetLow]) {
		frameSize = CGSizeMake(192, 144);
		return YES;
	}
	return NO;
}

- (BOOL)setupCameraWithSessionPreset:(NSString *)sessionPresetString pixelFormat:(int)format {
	NSError *error = nil;
	
	// make capture session
	session = [[AVCaptureSession alloc] init];
	
	// get default video device
	AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	// setup video input
	AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
	
	// setup video output
	NSDictionary *settingInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:format] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	
	AVCaptureVideoDataOutput * videoDataOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
//	[videoDataOutput setMinFrameDuration:CMTimeMake(1, 30)];
	[videoDataOutput setVideoSettings:settingInfo];	
	[videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	
	// attach video to session
	[session beginConfiguration];
	[session addInput:videoInput];
	[session addOutput:videoDataOutput];
	[session setSessionPreset:sessionPresetString];
	[session commitConfiguration];
	
	return YES;
}

- (BOOL)setupCameraWithSessionPreset:(NSString*)sessionPresetString {
	return [self setupCameraWithSessionPreset:sessionPresetString pixelFormat:kCVPixelFormatType_32BGRA];
}

- (AVCaptureSession*)session {
	return session;
}

- (void)start {
//	[session startRunning];
	// Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[session startRunning];
	});
}

- (void)stop {
	[session stopRunning];
}

- (BOOL)isRunning {
	return [session isRunning];
}

- (CGSize)frameSize {
	return frameSize;
}

- (void)preparePreviewBufferForPixelFormat:(int)format {
	// common color space for grayscale preview view
	colorSpaceValueBufferForPreview = CGColorSpaceCreateDeviceGray();
	
	if (format == kCVPixelFormatType_32BGRA) {
		valueBuffer = (unsigned char*)malloc(sizeof(unsigned char)*frameSize.width*frameSize.height * 4);
		tempBuffer = (unsigned char*)malloc(sizeof(unsigned char)*frameSize.width*frameSize.height * 4);
		valueBufferProviderForPreview = CGDataProviderCreateWithData(NULL, valueBuffer, frameSize.width * 4, NULL);
	}
	else if (format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange || format == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
		valueBuffer = (unsigned char*)malloc(sizeof(unsigned char)*frameSize.width*frameSize.height);
		tempBuffer = (unsigned char*)malloc(sizeof(unsigned char)*frameSize.width*frameSize.height);
		valueBufferProviderForPreview = CGDataProviderCreateWithData(NULL, valueBuffer, frameSize.width, NULL);
	}
	else {
	}
}

- (id)initWithSessionPreset:(NSString*)sessionPresetString {
	DNSLogMethod
	int format = kCVPixelFormatType_32BGRA;
    self = [super init];
	if (self) {
		if (![self updateFrameSizeWithSessionPreset:sessionPresetString]) {
			[self autorelease];
			return nil;
		}
		if (![self setupCameraWithSessionPreset:sessionPresetString pixelFormat:format]) {
			[self autorelease];
			return nil;
		}
		[self preparePreviewBufferForPixelFormat:format];
	}
	return self;
}

- (id)initWithSessionPreset:(NSString*)sessionPresetString pixelFormat:(int)format {
	DNSLogMethod
    self = [super init];
	if (self) {
		if (![self updateFrameSizeWithSessionPreset:sessionPresetString]) {
			[self autorelease];
			return nil;
		}
		if (![self setupCameraWithSessionPreset:sessionPresetString pixelFormat:format]) {
			[self autorelease];
			return nil;
		}
		[self preparePreviewBufferForPixelFormat:format];
	}
	return self;
}

- (void)updatePreviewView {
	if (valueBufferPreview && [valueBufferPreview superview]) {		
		// Create CGImage
		CGImageRef image = CGImageCreate(
										 frameSize.width,				// 幅
										 frameSize.height,				// 高さ
										 8,								// 構成要素ひとつのビット長
										 8,								// ピクセル毎のビット長
										 frameSize.width,				// 行ごとのバイト長
										 colorSpaceValueBufferForPreview,				// 色空間
										 (kCGImageAlphaNone),   
										 // ビットマップのアルファ値，バイトオーダー
										 valueBufferProviderForPreview,			// ピクセルデータが入ったDataProvider
										 NULL,							//
										 NO,							//
										 kCGRenderingIntentDefault		//
										 );
		[valueBufferPreview redrawWithImageRef:image];
		CGImageRelease(image);
	}
}

- (void)copyToValueBufferFromPixelBuffer_420YpCbCr8BiPlanarAnyRange:(CVImageBufferRef)imageBuffer {
	size_t width= CVPixelBufferGetWidth(imageBuffer); 
	size_t height = CVPixelBufferGetHeight(imageBuffer); 
	
	CVPixelBufferLockBaseAddress(imageBuffer, 0);
	
	CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
	
	size_t offset = NSSwapBigLongToHost(planar->componentInfoY.offset);
	
	unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
	unsigned char* pixelAddress = baseAddress + offset;
	
	memcpy(tempBuffer, pixelAddress, sizeof(unsigned char) * width * height);
	unsigned char *p = tempBuffer;
	
	for (int y = height-1; y >= 0; y--) {
		for (int x = width-1; x >= 0; x--) {
			*(valueBuffer + y * width + x) = *(p++) > threshold ? 0 : 255;
		}
	}
	
	CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

- (void)copyToValueBufferFromPixelBuffer_32ABGR:(CVImageBufferRef)imageBuffer {
	size_t width = CVPixelBufferGetWidth(imageBuffer);
	size_t height = CVPixelBufferGetHeight(imageBuffer); 
	CVPixelBufferLockBaseAddress(imageBuffer, 0);
	
	unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
	
	memcpy(tempBuffer, baseAddress, sizeof(unsigned char) * width * height * 4);
	unsigned char *p = tempBuffer;
	
	int idxD = 0;
	
	for (int y = height-1, idxS = width * 4 * y; y >= 0; y--) {
		for (int x = width * 4 - 4; x >= 0; x-=4) {
			int k = (p[ idxS+x   ]>>2)
			+ (p[ idxS+x+1 ]>>1)
			+ (p[ idxS+x+2 ]>>2);
			valueBuffer[idxD] = k > threshold ? 0 : 255;
			idxD++;
		}
		idxS -= (width * 4);
	}
	CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

- (void)copyToValueBufferFromPixelBuffer:(CVImageBufferRef)imageBuffer {
	uint type = CVPixelBufferGetPixelFormatType(imageBuffer);
	
	switch (type) {
		case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
		case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
			[self copyToValueBufferFromPixelBuffer_420YpCbCr8BiPlanarAnyRange:imageBuffer];
			break;
		case kCVPixelFormatType_32BGRA:
			[self copyToValueBufferFromPixelBuffer_32ABGR:imageBuffer];
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	if ([session isRunning]) {
		CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
		_tic();
		[self copyToValueBufferFromPixelBuffer:imageBuffer];
		_toc();
		[self updatePreviewView];
	}
}

#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	[session stopRunning];
	[session release];
	CGDataProviderRelease(valueBufferProviderForPreview);
	SAFE_FREE(valueBuffer);
	CGColorSpaceRelease(colorSpaceValueBufferForPreview);
	[super dealloc];
}

@end

#endif