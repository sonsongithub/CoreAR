/*
 * Core AR
 * MyGLView.m
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

#import "MyGLView.h"

#import "glcube.h"
#import "glteapot.h"

@implementation MyGLView

@synthesize codeInfoStorage;

#pragma mark -
#pragma mark Instance method

- (void)setProjectionParameters {
	[[self openGLContext] makeCurrentContext];
	
	NSRect rect = self.bounds;
	float focal_inv_x = 1 / CRGetXFocalLength();
	float focal_inv_y = 1 / CRGetYFocalLength();
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	float width = 320;
	float height = 240;

	glFrustum(0.5*width*focal_inv_x, -0.5*width*focal_inv_x, 0.5*height*focal_inv_y, -0.5*height*focal_inv_y, 1, 1000);
//	glFrustum(0.5*rect.size.width*focal_inv, -0.5*rect.size.width*focal_inv, 0.5*rect.size.height*focal_inv, -0.5*rect.size.height*focal_inv, 1, 1000);
	glViewport(0, 0, rect.size.width, rect.size.height);
}

#pragma mark -
#pragma mark Override

- (void)drawView {
	float c = 10; //get2DCodeSize();
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glRotatef(180, 0, 1, 0);
	
	glClearColor(0.0f, 0.0f, 0.0f, 0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	if (codeInfoStorage) {
		CRCodeInfo *p = codeInfoStorage->head;
		if (p) {
			while (1) {
				glPushMatrix();
				glMultMatrixf(p->p);
#ifdef _USE_STATIC_IMAGE
#else
				glRotatef(t+=2, 0, 0, 1);
#endif
				if (p->identifier >= 0) {
                    drawSquare(c*0.3, p->identifier);
//                  printf("code=%d\n", p->identifier);
				}
				else if (p->identifier == 1) {
					glRotatef(90, 0, 0, 1);
					glRotatef(-90, 1, 0, 0);
					drawTeapot(20);
				}
				glPopMatrix();
				
				if (p->next == NULL)
					break;
				p = p->next;
			}
		}
	}
}

-(void)setupOpenGLView {
	[[self openGLContext] makeCurrentContext];
	
	const GLfloat			lightAmbient[] = {0.2, 0.2, 0.2, 1.0};
	const GLfloat			lightDiffuse[] = {1.0, 0.6, 0.0, 1.0};
	const GLfloat			matAmbient[] = {0.6, 0.6, 0.6, 1.0};
	const GLfloat			matDiffuse[] = {1.0, 1.0, 1.0, 1.0};	
	const GLfloat			matSpecular[] = {1.0, 1.0, 1.0, 1.0};
	const GLfloat			lightPosition[] = {0, 0, 20.0, 0.0}; 
	const GLfloat			lightShininess = 100.0;
	
	// Configure OpenGL lighting
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
	
	t = 0;
	
	[self setProjectionParameters];
}

- (void)reshape {
	[self setProjectionParameters];
}

@end
