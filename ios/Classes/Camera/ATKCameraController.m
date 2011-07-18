/*
 * Core AR
 * ATKCameraController.m
 *
 * Copyright (c) Yuichi YOSHIDA, 10/12/10
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

#import "ATKCameraController.h"

#import "MyGLView.h"

#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

static struct timeval _start, _end;

static void _tic() {
	gettimeofday(&_start, NULL);
}

static double _toc() {
	gettimeofday(&_end, NULL);
	long int e_sec = _end.tv_sec * 1000000 + _end.tv_usec;
	long int s_sec = _start.tv_sec * 1000000 + _start.tv_usec;
	return (double)((e_sec - s_sec) / 1000.0);
}

@implementation ATKCameraController

- (void)changedThreshold:(id)sender {
	if ([sender isKindOfClass:[UISlider class]]) {
		threshold = [(UISlider*)sender value];
	}
}

- (id)initWithSessionPreset:(NSString*)sessionPresetString pixelFormat:(int)format {
	DNSLogMethod
    self = [super initWithSessionPreset:sessionPresetString pixelFormat:format];
	if (self) {
		codeInfoStorage = CRCreateCodeInfoStorage();
		
		codeImageTemplateStorage = CRCreateCodeImageTemplateStorage();
		
		NSArray *files = [NSArray arrayWithObjects:@"code02.png", @"code03.png", @"code04.png", nil];
		
		int code = 0;
		
		for (NSString *file in files) {
			NSAutoreleasePool *pool = [NSAutoreleasePool new];
			NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:nil];
			
			DNSLog(@"%@", path);
			
			CGDataProviderRef pngprovider = CGDataProviderCreateWithFilename([path UTF8String]);
			CGImageRef inputImageRef = CGImageCreateWithPNGDataProvider(pngprovider, NULL, NO, kCGRenderingIntentDefault);
			
			// CGImageからDataProviderを取得
			CGDataProviderRef inputImageProvider = CGImageGetDataProvider(inputImageRef);
			// DataProviderが保持するピクセルデータをコピー
			CFDataRef data = CGDataProviderCopyData(inputImageProvider);
			
			unsigned char *pixelData = (unsigned char *) CFDataGetBytePtr(data);
			// 画像データのサイズを取得
			//int length = CFDataGetLength(data);
			size_t width = CGImageGetWidth(inputImageRef);
			size_t height = CGImageGetHeight(inputImageRef);
			size_t bitsPerComponent = CGImageGetBitsPerComponent(inputImageRef);
			size_t bitsPerPixel = CGImageGetBitsPerPixel(inputImageRef);
			size_t bytesPerRow = CGImageGetBytesPerRow(inputImageRef);
			//CGColorSpaceRef colorspace = CGImageGetColorSpace(inputImageRef);
			
			unsigned char *tempPixel = (unsigned char *)malloc(sizeof(unsigned char) * width * height);
			
			for (int y = 0; y < height; y++) {
				for (int x = 0; x < width; x++) {
					int k = (pixelData[y * bytesPerRow + x * (bitsPerPixel/bitsPerComponent) + 0]>>2)
					+ (pixelData[y * bytesPerRow + x * (bitsPerPixel/bitsPerComponent) + 1]>>1)
					+ (pixelData[y * bytesPerRow + x * (bitsPerPixel/bitsPerComponent) + 2]>>2);
					tempPixel[y * width + x] = k;
				}
			}
			
			CRCodeImageTemplate *template = CRCreateCodeImageTemplate(tempPixel, width, height);
			template->code = code++;
			template->size = 5;
			
			CRCodeImageTemplateStorageAddNewTemplate(codeImageTemplateStorage, template);
			
			CGDataProviderRelease(pngprovider);
			CFRelease(data);
			free(tempPixel);
			[pool release];
		}
		
		threshold = 70;
	}
	return self;
}

- (MyGLView*)glView {
	if (glView == nil) {
//		glView = [[MyGLView alloc] initWithFrame:CGRectMake(0, 0, 320, 427)];
		glView = [[MyGLView alloc] initWithFrame:CGRectMake(0, 0, 768.0, 768.0*427.0/320.0)];
        [glView setCameraFrameSize:self.frameSize];
		[glView setCodeInfoStorage:codeInfoStorage];
		[glView startAnimation];
		[glView setupOpenGLView];
	}
	return glView;
}

- (void)preparePreviewBufferForPixelFormat:(int)format {
	[super preparePreviewBufferForPixelFormat:format];
	chaincodeFlag = (unsigned char*)malloc(sizeof(unsigned char)*frameSize.width*frameSize.height);
}

- (void)analyzeVisualCodeWidth:(int)width height:(int)height {
	CRDenoiseWithContractionAndExpansion(chaincodeFlag, width, height);
	CRChainCodeStorage *storage = CRCreateChainCodeStorageByParsingPixel(chaincodeFlag, width, height);	
	CRChainCodeStorageDetectCornerWithLSM(storage);
	CRCodeInfoStorageReleaseAllCodeInfo(codeInfoStorage);
	CRCodeInfoStorageAddCodeInfoByExtractingFromChainCode(codeInfoStorage, storage, valueBuffer, width, height, codeImageTemplateStorage);
	
	printf("%d\n", codeInfoStorage->length);
	
	//drawChainCodeStorageIntoBuffer(storage, valueBuffer, width, height);
	
	CRReleaseChainCodeStorage(&storage);
}

- (void)copyToValueBufferFromPixelBuffer_420YpCbCr8BiPlanarAnyRange:(CVImageBufferRef)imageBuffer {
	size_t width = CVPixelBufferGetWidth(imageBuffer);
	size_t height = CVPixelBufferGetHeight(imageBuffer); 
	
	CVPixelBufferLockBaseAddress(imageBuffer, 0);
	
	CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
	
	size_t offset = NSSwapBigLongToHost(planar->componentInfoY.offset);
	
	unsigned char* imgBaseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
	unsigned char* pixelBaseAddress = imgBaseAddress + offset;
	
	unsigned char *p = tempBuffer;
	
	memcpy(p, pixelBaseAddress, sizeof(unsigned char) * width * height);
	
	CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
	
	for (int y = height-1; y >= 0; y--) {
		for (int x = width-1; x >= 0; x--) {
			*(chaincodeFlag + y * width + x) = *p > threshold ? 0 : 1;
			*(valueBuffer + y * width + x) = (1 - *(chaincodeFlag + y * width + x)) * 100 + 100;
			
			p++;
		}
	}
	
	[self analyzeVisualCodeWidth:width height:height];
	[[self glView] drawView];
	frameCount++;
}

- (void)copyToValueBufferFromPixelBuffer_32ABGR:(CVImageBufferRef)imageBuffer {
	// size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
	size_t width = CVPixelBufferGetWidth(imageBuffer);
	size_t height = CVPixelBufferGetHeight(imageBuffer); 
	CVPixelBufferLockBaseAddress(imageBuffer, 0);
	
	unsigned char* pixelBaseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
	
	unsigned char *p = tempBuffer;
	
	memcpy(p, pixelBaseAddress, sizeof(unsigned char) * width * height * 4);
	
	CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
	
	int idxD = 0;
	
	for (int y = height-1, idxS = width * 4 * y; y >= 0; y--) {
		for (int x = width * 4 - 4; x >= 0; x-=4) {
			int k = (p[ idxS+x   ]>>2)
			+ (p[ idxS+x+1 ]>>1)
			+ (p[ idxS+x+2 ]>>2);
			valueBuffer[idxD] = k;
			chaincodeFlag[idxD] = k > threshold ? 0 : 1;
			idxD++;
		}
		idxS -= (width * 4);
	}
	
	[self analyzeVisualCodeWidth:width height:height];
	[[self glView] drawView];
	frameCount++;
}

#pragma mark -
#pragma mark FPS

- (double)fps {
	double fps = 0;
	if (_start.tv_sec > 0) {
		double interval = _toc();
		fps = 1000 * frameCount/interval;
		_dprintf("%dframes (%fmsec)\n", frameCount, interval);
	}
	frameCount = 0;
	_tic();
	return fps;
}
 
#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	SAFE_FREE(chaincodeFlag);
	[super dealloc];
}

@end
