/*
 * Core AR
 * GLView.m
 *
 * Copyright (c) Yuichi YOSHIDA, 10/12/10.
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

#import "GLView.h"

#import <OpenGL/gl.h>

#import "glcube.h"

@implementation GLView

- (void)update:(NSTimer*)timer {
	[self drawView];
	[[self openGLContext] flushBuffer];
}

- (void)drawView {
	// dummy
}

-(void)setupOpenGLView {
	// dummy
}

- (BOOL)isOpaque {
	return NO;   
}

- (id)initWithFrame:(NSRect)frame {
	NSOpenGLPixelFormatAttribute attrs[] = {
		NSOpenGLPFADoubleBuffer,        // using double back buffer
		NSOpenGLPFAColorSize, 24,       // color bit size
		NSOpenGLPFAAlphaSize, 8,        // alpha bit size
		NSOpenGLPFADepthSize, 16,       // depth bit size
		NSOpenGLPFAAccelerated,         // hard ware acceleration
		0
	};
	
	[self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
	
	NSOpenGLPixelFormat* pixFmt = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];
	
	self = [super initWithFrame:frame pixelFormat:pixFmt];
	[[self openGLContext] makeCurrentContext];
	
	const GLint opq=0;
    [[self openGLContext] setValues:&opq forParameter:NSOpenGLCPSurfaceOpacity];
	
	[self setupOpenGLView];
	
	return(self);
}

- (void)reshape{
	// dummy
}

- (void)drawRect:(NSRect)aRect {
	[self drawView];
	[[self openGLContext] flushBuffer];
}

@end
