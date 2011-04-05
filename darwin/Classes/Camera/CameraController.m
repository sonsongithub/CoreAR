/*
 * Core AR
 * QuartzVirtualRender.m
 *
 * Copyright (c) Yuichi YOSHIDA, 10/10/30
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

#import <OpenGL/CGLMacro.h> 

@implementation CameraPreview

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	
	[self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
	
	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextDrawImage(context, NSRectToCGRect(dirtyRect), image);
}

- (void)redrawWithImageRef:(CGImageRef)newImage {
	CGImageRelease(image);
	image = CGImageRetain(newImage);
	[self setNeedsDisplay:YES];
}

- (void)dealloc {
	CGImageRelease(image);
	[super dealloc];
}

@end

@interface CameraController(Private)
- (void)preparePreviewBuffer;
- (void)releasePreviewBuffer;
@end

@implementation CameraController

#pragma mark -
#pragma mark Private method

- (void)preparePreviewBuffer {
	if (colorspace == nil)
		colorspace = CGColorSpaceCreateDeviceRGB();
}

- (void)releasePreviewBuffer {
	CGDataProviderRelease(provider);
	provider = nil;
	CGColorSpaceRelease(colorspace);
	colorspace = nil;
}

#pragma mark -
#pragma mark Instance method

- (void)setDelegate:(id<CameraControllerDelegate>)newValue {
	if (newValue != delegate) {
		delegate = newValue;
	}
}

- (CameraPreview*)preview {
	if (preview == nil) {
		int	width =  [pixelBuffer pixelsWide];
		int	height = [pixelBuffer pixelsHigh];
		
		preview = [[CameraPreview alloc] initWithFrame:NSMakeRect(0, 0, width, height)];
		
		[self preparePreviewBuffer];
	}
	return preview;
}

- (id) initWithPixelsWidth:(unsigned)width pixelsHight:(unsigned)height {
	DNSLogMethod
	
	NSOpenGLPixelFormatAttribute	attributes[] = {
		NSOpenGLPFAPixelBuffer,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADepthSize, 24,
		(NSOpenGLPixelFormatAttribute) 0
	};
	NSOpenGLPixelFormat* format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
	
	if ((width < 16) || (height < 16)) {
		[self release];
		return nil;
	}
	
	if(self = [super init]) {
		//Create the OpenGL pixel buffer to render into
		pixelBuffer = [[NSOpenGLPixelBuffer alloc] initWithTextureTarget:GL_TEXTURE_RECTANGLE_EXT textureInternalFormat:GL_RGBA textureMaxMipMapLevel:0 pixelsWide:width pixelsHigh:height];
		if(pixelBuffer == nil) {
			NSLog(@"[%@] Cannot create OpenGL pixel buffer",[self className]);
			[self release];
			return nil;
		}
		
		//Create the OpenGL context to render with (with color and depth buffers)
		openGLContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];
		if(openGLContext == nil) {
			NSLog(@"[%@] Cannot create OpenGL context",[self className]);
			[self release];
			return nil;
		}
		[openGLContext setPixelBuffer:pixelBuffer cubeMapFace:0 mipMapLevel:0 currentVirtualScreen:[openGLContext currentVirtualScreen]];
#ifdef _USE_STATIC_IMAGE
		NSString *fileName = [[NSBundle mainBundle] pathForResource:@"dummy" ofType:@"qtz"];
#else
		NSString *fileName = [[NSBundle mainBundle] pathForResource:@"camera" ofType:@"qtz"];
#endif
		renderer = [[QCRenderer alloc] initWithOpenGLContext:openGLContext pixelFormat:format file:fileName];
		
		// failed initialize renderer
		if(renderer == nil) {
			NSLog(@"[%@] Cannot create QCRenderer",[self className]);
			[self release];
			return nil;
		}
		
		cameraImageWidth = width;
		cameraImageHeight = height;

		scratchBufferRowBytes = (width * 4);
		scratchBufferPtr = valloc(height * scratchBufferRowBytes);
		buff = valloc(height * scratchBufferRowBytes);
		if (provider == nil) {
			provider = CGDataProviderCreateWithData(NULL, scratchBufferPtr, scratchBufferRowBytes, NULL);
		}
		
		if(scratchBufferPtr == NULL) {
			[self release];
			return nil;
		}
		captureStartTime = -1;
		
		renderTimer = [[NSTimer timerWithTimeInterval:(1.0 / (NSTimeInterval)kRenderFPS) target:self selector:@selector(capture:) userInfo:nil repeats:YES] retain];
		[[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSDefaultRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSModalPanelRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSEventTrackingRunLoopMode];
	}
	
	return self;
}

- (void)stop {
	[renderTimer invalidate];
	renderTimer = nil;
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

	glGetIntegerv(GL_PACK_ROW_LENGTH, &save);
	glPixelStorei(GL_PACK_ROW_LENGTH, scratchBufferRowBytes / 4);
	glReadPixels(0, 0, width, height, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8, buff);
	glPixelStorei(GL_PACK_ROW_LENGTH, save);
	
	memcpy(scratchBufferPtr, buff, scratchBufferRowBytes * height);
	
	// Check opengl status
	if(glGetError())
		return;
	
	if ([self preview]) {		
		// Create CGImage
		CGImageRef image = CGImageCreate(
										 width,                           // 幅
										 height,                          // 高さ
										 8,                                 // 構成要素ひとつのビット長
										 32,                               // ピクセル毎のビット長
										 width * 4,                      // 行ごとのバイト長
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
	
	if ([delegate respondsToSelector:@selector(didCaptureCameraController:pixelBGRA:width:height:)]) {
		[delegate didCaptureCameraController:self pixelBGRA:scratchBufferPtr width:width height:height];
	}
}

#pragma mark -
#pragma mark Override

- (id) init {
	return [self initWithPixelsWidth:0 pixelsHight:0];
}

#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	DNSLogMethod
	[preview release];
	
	//Destroy the scratch buffer
	if(scratchBufferPtr)
		free(scratchBufferPtr);
	
	//Destroy the renderer
	[renderer release];
	
	//Destroy the OpenGL context
	[openGLContext clearDrawable];
	[openGLContext release];
	
	//Destroy the OpenGL pixel buffer
	[pixelBuffer release];
	
	[self releasePreviewBuffer];
	
	[super dealloc];
}

@end
