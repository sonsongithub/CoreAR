/*
 * Core AR
 * glcube.c
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

#include "glcube.h"

#include <stdio.h>

static GLubyte cubeColors[] = {
	255, 255,   0, 255,			// yellow
	255, 255,   0, 255,
	255, 255,   0, 255,
	255, 255,   0, 255,
	
	255,   0, 255, 255,			// purple
	255,   0, 255, 255,
	255,   0, 255, 255,
	255,   0, 255, 255,
	
	255,   0,   0, 255,			// red
	255,   0,   0, 255,
	255,   0,   0, 255,
	255,   0,   0, 255,
	
	  0, 255,   0, 255,			// green
	  0, 255,   0, 255,
	  0, 255,   0, 255,
	  0, 255,   0, 255,
	
	  0,   0, 255, 255,			// blue
	  0,   0, 255, 255,
	  0,   0, 255, 255,
	  0,   0, 255, 255,
	
	0, 255,  255, 255,			// light blue
	0, 255,  255, 255,
	0, 255,  255, 255,
	0, 255,  255, 255,
};


static GLfloat cubeVertices[] = {
	-0.5f,	-0.5f,	-1.0f,
	 0.5f,	-0.5f,	-1.0f,
	-0.5f,	 0.5f,	-1.0f,
	 0.5f,	 0.5f,	-1.0f,
	
	-0.5f,	-0.5f,	 0.0f,
	 0.5f,	-0.5f,	 0.0f,
	-0.5f,	 0.5f,	 0.0f,
	 0.5f,	 0.5f,	 0.0f,
	
	 0.5f,	-0.5f,	-1.0f,
	 0.5f,	 0.5f,	-1.0f,
	 0.5f,	-0.5f,	 0.0f,
	 0.5f,	 0.5f,	 0.0f,
	
	-0.5f,	-0.5f,	-1.0f,
	-0.5f,	 0.5f,	-1.0f,
	-0.5f,	-0.5f,	 0.0f,
	-0.5f,	 0.5f,	 0.0f,
	
	-0.5f,	 0.5f,	-1.0f,
	-0.5f,	 0.5f,	 0.0f,
	 0.5f,	 0.5f,	-1.0f,
	 0.5f,	 0.5f,	 0.0f,
	
	-0.5f,	-0.5f,	-1.0f,
	-0.5f,	-0.5f,	 0.0f,
	 0.5f,	-0.5f,	-1.0f,
	 0.5f,	-0.5f,	 0.0f,
};

static GLfloat cubeNormals[] = {
	0.0f,	 0.0f,	-1.0f,
	0.0f,	 0.0f,	-1.0f,
	0.0f,	 0.0f,	-1.0f,
	0.0f,	 0.0f,	-1.0f,
	
	0.0f,	 0.0f,	 1.0f,
	0.0f,	 0.0f,	 1.0f,
	0.0f,	 0.0f,	 1.0f,
	0.0f,	 0.0f,	 1.0f,
	
	 1.0f,	 0.0f,	 0.0f,
	 1.0f,	 0.0f,	 0.0f,
	 1.0f,	 0.0f,	 0.0f,
	 1.0f,	 0.0f,	 0.0f,
	
	-1.0f,	 0.0f,	 0.0f,
	-1.0f,	 0.0f,	 0.0f,
	-1.0f,	 0.0f,	 0.0f,
	-1.0f,	 0.0f,	 0.0f,
	
	0.0f,	 1.0f,	 0.0f,
	0.0f,	 1.0f,	 0.0f,
	0.0f,	 1.0f,	 0.0f,
	0.0f,	 1.0f,	 0.0f,
	
	0.0f,	-1.0f,	 0.0f,
	0.0f,	-1.0f,	 0.0f,
	0.0f,	-1.0f,	 0.0f,
	0.0f,	-1.0f,	 0.0f,
};

static GLfloat cubeVerticesWireframe[] = {
	-0.5f,	-0.5f,	-1.0f,
	 0.5f,	-0.5f,	-1.0f,
	 0.5f,	 0.5f,	-1.0f,
	-0.5f,	 0.5f,	-1.0f,
	
	-0.5f,	-0.5f,	 0.0f,
	 0.5f,	-0.5f,	 0.0f,
	 0.5f,	 0.5f,	 0.0f,
	-0.5f,	 0.5f,	 0.0f,
	
	0.5f,	-0.5f,	-1.0f,
	0.5f,	 0.5f,	-1.0f,
	0.5f,	 0.5f,	 0.0f,
	0.5f,	-0.5f,	 0.0f,
	
	-0.5f,	-0.5f,	-1.0f,
	-0.5f,	 0.5f,	-1.0f,
	-0.5f,	 0.5f,	 0.0f,
	-0.5f,	-0.5f,	 0.0f,
	
	-0.5f,	 0.5f,	-1.0f,
	-0.5f,	 0.5f,	 0.0f,
	 0.5f,	 0.5f,	 0.0f,
	 0.5f,	 0.5f,	-1.0f,
	
	-0.5f,	-0.5f,	-1.0f,
	-0.5f,	-0.5f,	 0.0f,
	 0.5f,	-0.5f,	 0.0f,
	 0.5f,	-0.5f,	-1.0f,
};

void drawSquare(float s, int color) {
    glDisable(GL_LIGHTING);
	glScalef(s, s, s);	
    
    int i = 1;
    
    glVertexPointer(3, GL_FLOAT, 0, cubeVertices + i * 12);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, cubeColors + color * 16);
    glEnableClientState(GL_COLOR_ARRAY);
    glNormalPointer(GL_FLOAT, 0, cubeNormals + i * 12);
    glEnableClientState(GL_NORMAL_ARRAY);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glEnable(GL_LIGHTING);
}

void drawCubeRenderingMode(float s, int mode) {
	
	glEnable(GL_NORMALIZE);
	glScalef(s, s, s);
	
	if (mode == 0) {
		for (int i = 0; i < 6; i++) {
			glVertexPointer(3, GL_FLOAT, 0, cubeVertices + i * 12);
			glEnableClientState(GL_VERTEX_ARRAY);
			glColorPointer(4, GL_UNSIGNED_BYTE, 0, cubeColors + i * 16);
			glEnableClientState(GL_COLOR_ARRAY);
			glNormalPointer(GL_FLOAT, 0, cubeNormals + i * 12);
			glEnableClientState(GL_NORMAL_ARRAY);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		}
	}
	else if (mode == 1) {
		glDisable(GL_LIGHTING);
		glLineWidth(3.0f);
		for (int i = 0; i < 6; i++) {
			glColor4f(0.0f, 0.0f, 0.0f, 1.0f);
			glVertexPointer(3, GL_FLOAT, 0, cubeVerticesWireframe + i * 12);
			glEnableClientState(GL_VERTEX_ARRAY);
			glDrawArrays(GL_LINES, 0, 4);
		}
		glEnable(GL_LIGHTING);
	}
}

void drawCube(float s) {
	drawCubeRenderingMode(s, 0);
}