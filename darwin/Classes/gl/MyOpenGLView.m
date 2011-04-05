/*
 * Core AR
 * MyOpenGLView.m
 *
 * Copyright (c) Yuichi YOSHIDA, 10/12/24
 * All rights reserved.
 * 
 * BSD License
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * - Neither the name of the "Yuichi YOSHIDA" nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MyOpenGLView.h"

#import <OpenGL/gl.h>
#import <GLUT/GLUT.h>

#import "glcube.h"

@implementation MyOpenGLView

@synthesize codeInfoStorage;

- (void)drawView {
	float codeSize = getCodeSize();
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glRotatef(180, 0, 1, 0);
		
	glClearColor(0.0f, 0.0f, 0.0f, 0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	if (codeInfoStorage) {
		CodeInfo *p = codeInfoStorage->head;
		if (p) {
			while (1) {
				printf("---------------------------------------------------\n");
				printf("%3.5f,%3.5f, %3.5f, %3.5f\n", p->p[0], p->p[4], p->p[ 8], p->p[12]);
				printf("%3.5f,%3.5f, %3.5f, %3.5f\n", p->p[1], p->p[5], p->p[ 9], p->p[13]);
				printf("%3.5f,%3.5f, %3.5f, %3.5f\n", p->p[2], p->p[6], p->p[10], p->p[14]);
				printf("%3.5f,%3.5f, %3.5f, %3.5f\n", p->p[3], p->p[7], p->p[11], p->p[15]);
				glPushMatrix();
				glMultMatrixf(p->p);
				drawCube(codeSize);
				glPopMatrix();
				
				if (p->next == NULL)
					break;
				p = p->next;
			}
		}
	}
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
	
	const GLfloat			lightAmbient[] = {0.2, 0.2, 0.2, 1.0};
	const GLfloat			lightDiffuse[] = {1.0, 0.6, 0.0, 1.0};
	const GLfloat			matAmbient[] = {0.6, 0.6, 0.6, 1.0};
	const GLfloat			matDiffuse[] = {1.0, 1.0, 1.0, 1.0};	
	const GLfloat			matSpecular[] = {1.0, 1.0, 1.0, 1.0};
	const GLfloat			lightPosition[] = {0.0, 0.0, 1.0, 0.0}; 
	const GLfloat			lightShininess = 100.0;
	
	//Configure OpenGL lighting
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, matSpecular);
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, lightShininess);
	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
	glLightfv(GL_LIGHT0, GL_POSITION, lightPosition); 			
	glShadeModel(GL_SMOOTH);
	glEnable(GL_DEPTH_TEST);
	
	return(self);
}

- (void)reshape{
	NSLog(@"reshape");
	NSRect rect = self.bounds;
	float focal = getF();
	float focal_inv = 1 / focal;
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glFrustum(0.5*rect.size.width*focal_inv, -0.5*rect.size.width*focal_inv, 0.5*rect.size.height*focal_inv, -0.5*rect.size.height*focal_inv, 1, 1000);
	glViewport(0, 0, rect.size.width, rect.size.height);
}

- (void)drawRect:(NSRect)aRect {
	NSLog(@"drawRect");
	[self drawView];
    [[self openGLContext] flushBuffer];
    [super drawRect:aRect];
}

@end
