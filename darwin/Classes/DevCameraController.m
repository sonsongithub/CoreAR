/*
 * Core AR
 * DevCameraController.m
 *
 * Copyright (c) Yuichi YOSHIDA, 10/11/30
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

#import "DevCameraController.h"

#define BUFFER_VERTICAL_DIRECTION_NORMAL
//#define BUFFER_VERTICAL_DIRECTION_REVERSE

#import "MyGLView.h"
#import "common.h"

@implementation DevCameraController

- (id) initWithPixelsWidth:(unsigned)width pixelsHight:(unsigned)height {
	self = [super initWithPixelsWidth:width pixelsHight:height];
	if (self) {
		
		threshold = 80;

		CRSetXFocalLength(351.79480);
		CRSetYFocalLength(351.79480);
        CRCodeImageTemplateSetMatchingThreshold(0.8);
		
		grayBuff = (unsigned char*)malloc(sizeof(unsigned char)*width*height);
		
		chaincodeFlag = (unsigned char*)malloc(sizeof(unsigned char)*width*height);
		
		if (grayBufProvider == nil) {
			grayBufProvider = CGDataProviderCreateWithData(NULL, grayBuff, width, NULL);
		}
		
		grayColorSpace = CGColorSpaceCreateDeviceGray();
		
		codeImageTemplateStorage = CRCreateCodeImageTemplateStorage();

		NSArray *files = [NSArray arrayWithObjects:@"code01.png", @"code02.png", @"code03.png", @"code04.png", nil];
		
		int code = 0;
		
		for (NSString *file in files) {
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
		}
		
		codeInfoStorage = CRCreateCodeInfoStorage();
		
		DNSLog(@"template storage includes %d images\n", codeImageTemplateStorage->length);		
	}
	return self;
}

- (MyGLView*)glView {
	if (glView == nil) {
		glView = [[MyGLView alloc] initWithFrame:NSMakeRect(0, 0, 320, 240)];
		[glView setCodeInfoStorage:codeInfoStorage];
	}
	return glView;
}

- (void)updateColorPreview {
	if ([self preview]) {		
		// Create CGImage
		CGImageRef image = CGImageCreate(
										 cameraImageWidth,                           // 幅
										 cameraImageHeight,                          // 高さ
										 8,                                 // 構成要素ひとつのビット長
										 32,                               // ピクセル毎のビット長
										 cameraImageWidth * 4,                      // 行ごとのバイト長
										 colorspace,                       // 色空間
										 (kCGBitmapByteOrder32Big | kCGImageAlphaFirst),    
										 // ビットマップのアルファ値，バイトオーダー
										 provider,                         // ピクセルデータが入ったDataProvider
										 NULL,                             //
										 NO,                               //
										 kCGRenderingIntentDefault         //
										 );
		[[self preview] redrawWithImageRef:image];
		CGImageRelease(image);
	}
}

- (void)updateGrayPreview {
	if (preview) {		
		// Create CGImage
		CGImageRef image = CGImageCreate(
										 cameraImageWidth,                           // 幅
										 cameraImageHeight,                          // 高さ
										 8,                                 // 構成要素ひとつのビット長
										 8,                               // ピクセル毎のビット長
										 cameraImageWidth,                      // 行ごとのバイト長
										 grayColorSpace,                       // 色空間
										 (kCGImageAlphaNone),    
										 // ビットマップのアルファ値，バイトオーダー
										 grayBufProvider,                         // ピクセルデータが入ったDataProvider
										 NULL,                             //
										 NO,                               //
										 kCGRenderingIntentDefault         //
										 );
		[preview redrawWithImageRef:image];
		CGImageRelease(image);
	}
}

- (void)copyGrayBufferForImageProcessingBuffer:(unsigned char*)p {
	
	int idxD = 0;

#ifdef BUFFER_VERTICAL_DIRECTION_NORMAL
	for (int y = cameraImageHeight - 1, idxS = cameraImageWidth * 4 * y; y >= 0; y--) {
		for (int x = 0; x < cameraImageWidth * 4; x+=4) {
			int k = (p[ idxS+x+1  ]>>2)
			+ (p[ idxS+x+2 ]>>1)
			+ (p[ idxS+x+3 ]>>2);
			grayBuff[idxD] = k > threshold ? 0 : 255;
			grayBuff[idxD] = k;
			chaincodeFlag[idxD] = k > threshold ? 0 : 1;
			idxD++;
		}
		idxS -= (cameraImageWidth * 4);
	}
#endif
	
#ifdef BUFFER_VERTICAL_DIRECTION_REVERSE
	for (int y = 0, idxS = cameraImageWidth * 4 * y; y < cameraImageHeight; y++) {
		for (int x = 0; x < cameraImageWidth * 4; x+=4) {
			int k = (p[ idxS+x   ]>>2)
			+ (p[ idxS+x+1 ]>>1)
			+ (p[ idxS+x+2 ]>>2);
			grayBuff[idxD] = k > threshold ? 0 : 255;
			grayBuff[idxD] = k;
			chaincodeFlag[idxD] = k > threshold ? 0 : 1;
			idxD++;
		}
		idxS += (cameraImageWidth * 4);
	}
#endif
}

- (void)copyColorBufferForPreviewBuffer:(unsigned char*)p {
	int idxD = 0;
	
#ifdef BUFFER_VERTICAL_DIRECTION_NORMAL
	int idxD2 = 0;
	for (int y = cameraImageHeight - 1, idxS = cameraImageWidth * 4 * y; y >= 0; y--) {
		for (int x = 0; x < cameraImageWidth * 4; x+=4) {
			((unsigned char*)scratchBufferPtr)[idxD2++] = 255;
			((unsigned char*)scratchBufferPtr)[idxD2++] = p[idxS+x+1];
			((unsigned char*)scratchBufferPtr)[idxD2++] = p[idxS+x+2];
			((unsigned char*)scratchBufferPtr)[idxD2++] = p[idxS+x+3];
			idxD++;
		}
		idxS -= (cameraImageWidth * 4);
	}
#endif
	
#ifdef BUFFER_VERTICAL_DIRECTION_REVERSE
	for (int y = 0, idxS = cameraImageWidth * 4 * y; y < cameraImageHeight; y++) {
		for (int x = 0; x < cameraImageWidth * 4; x+=4) {
			((unsigned char*)scratchBufferPtr)[idxS+x] = 255;
			((unsigned char*)scratchBufferPtr)[idxS+x+1] = p[idxS+x+1];
			((unsigned char*)scratchBufferPtr)[idxS+x+2] = p[idxS+x+2];
			((unsigned char*)scratchBufferPtr)[idxS+x+3] = p[idxS+x+3];
			idxD++;
		}
		idxS += (cameraImageWidth * 4);
	}
#endif
}

- (void)capture:(NSTimer*)timer {
	CGLContextObj cgl_ctx =[openGLContext CGLContextObj];
	int	width =  [pixelBuffer pixelsWide];
	int	height = [pixelBuffer pixelsHigh];
	GLint save = 0;
	
	NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];	
	
	//Compute the local time
	if(captureStartTime < 0.0)
		captureStartTime = time;
	time = time - captureStartTime;
	
	//Render a frame from the composition at the specified time
	if(![renderer renderAtTime:time arguments:nil])
		return;
	
#ifdef _USE_STATIC_IMAGE
	[self stop];
#endif
	
	glGetIntegerv(GL_PACK_ROW_LENGTH, &save);
	glPixelStorei(GL_PACK_ROW_LENGTH, scratchBufferRowBytes / 4);
	glReadPixels(0, 0, width, height, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8, buff);
	glPixelStorei(GL_PACK_ROW_LENGTH, save);

	unsigned char* p = (unsigned char*)buff;
	
	[self copyGrayBufferForImageProcessingBuffer:p];

	tic();
	
	CRChainCodeStorage *storage = CRCreateChainCodeStorageByParsingPixel(chaincodeFlag, width, height);
	
//	CRChainCodeStorageDetectCorner(storage);
	
	CRChainCodeStorageDetectCornerWithLSM(storage);
//	CRChainCodeStorageDetectCornerWithoutLSM(storage);
	
//	int idxD = 0;
//	
//	for (int y = cameraImageHeight - 1, idxS = cameraImageWidth * 4 * y; y >= 0; y--) {
//		for (int x = 0; x < cameraImageWidth * 4; x+=4) {
//			int k = (p[ idxS+x+1  ]>>2)
//			+ (p[ idxS+x+2 ]>>1)
//			+ (p[ idxS+x+3 ]>>2);
//			grayBuff[idxD] = k > threshold ? 0 : 100;
//			idxD++;
//		}
//		idxS -= (cameraImageWidth * 4);
//	}
//	
//	drawCornersInChainCodeStoreage(storage, grayBuff, cameraImageWidth, cameraImageHeight);
	
	
	CRCodeInfoStorageReleaseAllCodeInfo(codeInfoStorage);	
	
	CRCodeInfoStorageAddCodeInfoByExtractingFromChainCode(codeInfoStorage, storage, grayBuff, width, height, codeImageTemplateStorage);
	
	CRReleaseChainCodeStorage(&storage);
	
	toc();
	
	// Check opengl status
	if(glGetError())
		return;
	

#ifdef _GRAY_PREVIEW
	[self updateGrayPreview];
#else
	[self copyColorBufferForPreviewBuffer:p];
	[self updateColorPreview];
#endif
	
	if ([delegate respondsToSelector:@selector(didCaptureCameraController:pixelBGRA:width:height:)]) {
		[delegate didCaptureCameraController:self pixelBGRA:scratchBufferPtr width:width height:height];
	}
}

- (void) dealloc {
	free(grayBuff);
	[super dealloc];
}


@end
