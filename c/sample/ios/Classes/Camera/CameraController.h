/*
 * Core AR
 * CameraController.h
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <MobileCoreServices/MobileCoreServices.h>

@class CameraController;

@interface ValueBufferPreview : UIView {
	BOOL ok;
	CGImageRef image;
}
- (void)redrawWithImageRef:(CGImageRef)newImage;
@end

#if TARGET_IPHONE_SIMULATOR

@interface CameraController : NSObject {
	CGSize							frameSize;
	ValueBufferPreview				*valueBufferPreview;
	
	unsigned char*					tempBuffer;
	
	unsigned char*					valueBuffer;
	CGDataProviderRef				valueBufferProviderForPreview;
	CGColorSpaceRef					colorSpaceValueBufferForPreview;
	
	int								threshold;
}
- (CGSize)frameSize;
- (id)initWithSessionPreset:(NSString*)sessionPresetString;
- (id)initWithSessionPreset:(NSString*)sessionPresetString pixelFormat:(int)format;
- (ValueBufferPreview*)preview;
- (void)preparePreviewBufferForPixelFormat:(int)format;
@end

#else

@interface CameraController : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureSession				*session;
	CGSize							frameSize;
	AVCaptureVideoPreviewLayer		*previewLayer;
	ValueBufferPreview				*valueBufferPreview;
	
	unsigned char*					tempBuffer;
	
	unsigned char*					valueBuffer;
	CGDataProviderRef				valueBufferProviderForPreview;
	CGColorSpaceRef					colorSpaceValueBufferForPreview;
	
	int								threshold;
}
- (AVCaptureSession*)session;
- (CGSize)frameSize;
- (void)start;
- (void)stop;
- (BOOL)isRunning;
- (id)initWithSessionPreset:(NSString*)sessionPresetString;
- (id)initWithSessionPreset:(NSString*)sessionPresetString pixelFormat:(int)format;
- (ValueBufferPreview*)preview;
- (void)preparePreviewBufferForPixelFormat:(int)format;
- (BOOL)updateFrameSizeWithSessionPreset:(NSString*)sessionPresetString;
- (BOOL)setupCameraWithSessionPreset:(NSString *)sessionPresetString pixelFormat:(int)format;
- (BOOL)setupCameraWithSessionPreset:(NSString*)sessionPresetString;
@end

#endif