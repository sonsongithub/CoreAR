/*
 * Core AR
 * CRTest.cpp
 *
 * Copyright (c) Yuichi YOSHIDA, 10/12/02.
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "CRTest.h"

// private method
void _CRTestSetPixel(unsigned char* pixel, int width, int height, int x, int y, unsigned char value);
void _CRTestProjectPoint(float *x, float *x_projected, float focal, float xdeg, float ydeg, float zdeg, float xt, float yt, float zt);

float getDifferenceBetweenVectors(CRHomogeneousVec3 *p1, CRHomogeneousVec3 *p2) {
	p1->normalize();
	p2->normalize();
	float dif = (p1->x - p2->x) * (p1->x - p2->x) + (p1->y - p2->y) * (p1->y - p2->y);
	return sqrt(dif);
}

void _CRTestSetPixel(unsigned char* pixel, int width, int height, int x, int y, unsigned char value) {
	if (x >= 0 && x < width && y >= 0 && y < height) 
		*(pixel + x + y * width) = value;
}

void _CRTestProjectPoint(float *x, float *x_projected, float focal, float xdeg, float ydeg, float zdeg, float xt, float yt, float zt) {
	float temp[3];
	float temp2[3];
	float r[3][3];
	
	temp[0] = x[0];
	temp[1] = x[1];
	temp[2] = x[2];
	
	r[0][0] = cos(zdeg);	r[0][1] = -sin(zdeg);	r[0][2] = 0;
	r[1][0] = sin(zdeg);	r[1][1] = cos(zdeg);	r[1][2] = 0;
	r[2][0] = 0;			r[2][1] = 0;			r[2][2] = 1;
	
	temp2[0] = temp[0] * r[0][0] + temp[1] * r[0][1] + temp[2] * r[0][2];
	temp2[1] = temp[0] * r[1][0] + temp[1] * r[1][1] + temp[2] * r[1][2];
	temp2[2] = temp[0] * r[2][0] + temp[1] * r[2][1] + temp[2] * r[2][2];
	
	temp[0] = temp2[0];
	temp[1] = temp2[1];
	temp[2] = temp2[2];
	
	r[0][0] = cos(ydeg);	r[0][1] = 0;			r[0][2] = sin(ydeg);
	r[1][0] = 0;			r[1][1] = 1;			r[1][2] = 0;
	r[2][0] = -sin(ydeg);	r[2][1] = 0;			r[2][2] = cos(ydeg);
	
	temp2[0] = temp[0] * r[0][0] + temp[1] * r[0][1] + 
	temp[2] * r[0][2];
	temp2[1] = temp[0] * r[1][0] + temp[1] * r[1][1] + temp[2] * r[1][2];
	temp2[2] = temp[0] * r[2][0] + temp[1] * r[2][1] + temp[2] * r[2][2];
	
	temp[0] = temp2[0];
	temp[1] = temp2[1];
	temp[2] = temp2[2];
	
	r[0][0] = 1;			r[0][1] = 0;			r[0][2] = 0;
	r[1][0] = 0;			r[1][1] = cos(xdeg);	r[1][2] = -sin(xdeg);
	r[2][0] = 0;			r[2][1] = sin(xdeg);	r[2][2] = cos(xdeg);
	
	temp2[0] = temp[0] * r[0][0] + temp[1] * r[0][1] + temp[2] * r[0][2];
	temp2[1] = temp[0] * r[1][0] + temp[1] * r[1][1] + temp[2] * r[1][2];
	temp2[2] = temp[0] * r[2][0] + temp[1] * r[2][1] + temp[2] * r[2][2];
	
	temp[0] = temp2[0] + xt;
	temp[1] = temp2[1] + yt;
	temp[2] = temp2[2] + zt;
	
	temp[0] /= temp[2];
	temp[1] /= temp[2];
	temp[2] = 1;
	
	x_projected[0] = temp[0] * focal;
	x_projected[1] = temp[1] * focal;
	x_projected[2] = temp[2];
}

void _CRTestMakePixelDataWithProjectionSetting(unsigned char **output_pixel, int width, int height, CRHomogeneousVec3* projected_corners, float focal, float xdeg, float ydeg, float zdeg, float xt, float yt, float zt) {
	float corners[4][3];
	corners[0][0] = -0.5;			corners[0][1] = -0.5;			corners[0][2] = 0;
	corners[1][0] = -0.5;			corners[1][1] =  0.5;			corners[1][2] = 0;
	corners[2][0] =  0.5;			corners[2][1] =  0.5;			corners[2][2] = 0;
	corners[3][0] =  0.5;			corners[3][1] = -0.5;			corners[3][2] = 0;
	
	unsigned char *pixel = (unsigned char*)malloc(sizeof(unsigned char)*width*height);
	
	float corners_projected[12];
	
	for (int i = 0; i < 4; i++) {
		float *p = corners_projected + i * 3;
		_CRTestProjectPoint(corners[i], p, focal, xdeg, ydeg, zdeg, xt, yt, zt);
		p[0] += width / 2;
		p[1] += height / 2;
	
		projected_corners[i].x = p[0];
		projected_corners[i].y = p[1];
		projected_corners[i].w = 1;
	}
	
	int precision = 30;
	
	float step = 1.0f / (precision - 1);
	
	for (int i = 0; i < precision; i++) {
		for (int j = 0; j < precision; j++) {
			float x_temp[3];
			float x_temp_projected[3];
			x_temp[0] = -0.5 + step * i;
			x_temp[1] = -0.5 + step * j;
			x_temp[2] = 0;
			
			_CRTestProjectPoint(x_temp, x_temp_projected, focal, xdeg, ydeg, zdeg, xt, yt, zt);
			x_temp_projected[0] += width / 2;
			x_temp_projected[1] += height / 2;
			_CRTestSetPixel(pixel, width, height, x_temp_projected[0], x_temp_projected[1], 0x01);
		}
	}
	
	*output_pixel = pixel;
}

void _CRTestDumpPixel(unsigned char* pixel, int width, int height) {
	for (int y = 0; y < width; y++) {
		for (int x = 0; x < height; x++) {
			printf("%02x ", pixel[x + y * width]);
		}
		printf("\n");
	}
}

void _CRTestMakeSimplePixelData(unsigned char **output_pixel, int *output_width, int *output_height) {
	
	int width = 20;
	int height = 20;
	unsigned char *grayBuff = (unsigned char*)malloc(sizeof(unsigned char)*width*height);
	
	memset(grayBuff, 0, sizeof(unsigned char)*width*height);
	
	for (int y = 4; y < 8; y++) {
		for (int x = 4; x < 8; x++) {
			grayBuff[x + y * width] = 1;
		}
	}
	
	for (int y = 9; y < 18; y++) {
		for (int x = 9; x < 18; x++) {
			grayBuff[x + y * width] = 1;
		}
	}
	
	for (int y = 12; y < 15; y++) {
		for (int x = 12; x < 15; x++) {
			grayBuff[x + y * width] = 0;
		}
	}
	
	grayBuff[7 + 2 * width] = 0;
	grayBuff[8 + 2 * width] = 0;
	grayBuff[8 + 4 * width] = 0;
	
	*output_pixel = grayBuff;
	*output_width = width;
	*output_height = height;
}