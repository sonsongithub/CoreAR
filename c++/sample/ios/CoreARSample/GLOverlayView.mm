/*
 * Core AR
 * GLOverlayView.mm
 *
 * Copyright (c) Yuichi YOSHIDA, 11/09/20
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

#import "GLOverlayView.hpp"

#import "CoreAR.h"
#import "ARViewController.hpp"

#import "glcube.h"
//#import "glteapot.h"

@implementation GLOverlayView

@synthesize cameraFrameSize;
@synthesize codeListRef;

-(void)setupOpenGLView {
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
	
	CGRect rect = self.frame;

	float focalLength = 650;
	
	float focal_inv_x = 1 / focalLength;
	float focal_inv_y = 1 / focalLength;
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glFrustumf(-0.5*rect.size.width*focal_inv_x, 0.5*rect.size.width*focal_inv_x, -0.5*rect.size.height*focal_inv_y, 0.5*rect.size.height*focal_inv_y, 1, 1000);
	glViewport(0, 0, rect.size.width, rect.size.height);
}

- (void)drawView {
	[EAGLContext setCurrentContext:context];
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    
    float ratio = self.frame.size.width / cameraFrameSize.height;
    
	glScalef(ratio, ratio, 1);
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.5f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glRotatef( 90, 0, 0, 1);
	glRotatef(180, 0, 1, 0);
	
	float mm[16];
		
	mm[ 0] =  0;	mm[ 4] =  1;	mm[ 8] =  0;	mm[12] = 0;
	mm[ 1] = -1;	mm[ 5] =  0;	mm[ 9] =  0;	mm[13] = 0;
	mm[ 2] =  0;	mm[ 6] =  0;	mm[10] =  1;	mm[14] = 0;
	mm[ 3] =  0;	mm[ 7] =  0;	mm[11] =  0;	mm[15] = 1;
	
	if (codeListRef) {
		CRCodeList::iterator it = codeListRef->begin();
		while(it != codeListRef->end()) {
			glPushMatrix();
			glMultMatrixf((*it)->matrixGL);
			glMultMatrixf(mm);
			drawCube(1);
			glPopMatrix();
			++it;
		}
	}
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void) dealloc {
	[super dealloc];
}


@end
