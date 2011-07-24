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

void _CRTestMultiMat(float result[4][4], float a[4][4], float b[4][4]);
void _CRTestMultiMatAndVec(float result[4], float a[4][4], float x[4]);
void _CRTestDumpMat(float matrix[4][4]);
void _CRTestDumpVec(float vec[4]);
void _CRTestProjectPoint2(float mat[4][4], float *x, float *x_projected, float focal, float xdeg, float ydeg, float zdeg, float xt, float yt, float zt);

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

void _CRTestMultiMat(float result[4][4], float a[4][4], float b[4][4]) {
	//result = a * b;
	for (int i = 0; i < 4; i++) {
		result[i][0] = a[i][0] * b[0][0] + a[i][1] * b[1][0] + a[i][2] * b[2][0] + a[i][3] * b[3][0];
		result[i][1] = a[i][0] * b[0][1] + a[i][1] * b[1][1] + a[i][2] * b[2][1] + a[i][3] * b[3][1];
		result[i][2] = a[i][0] * b[0][2] + a[i][1] * b[1][2] + a[i][2] * b[2][2] + a[i][3] * b[3][2];
		result[i][3] = a[i][0] * b[0][3] + a[i][1] * b[1][3] + a[i][2] * b[2][3] + a[i][3] * b[3][3];
	}
}

void _CRTestMultiMatAndVec(float result[4], float a[4][4], float x[4]) {
	//result = a * x;
	result[0] = a[0][0] * x[0] + a[0][1] * x[1] + a[0][2] * x[2] + a[0][3] * x[3];
	result[1] = a[1][0] * x[0] + a[1][1] * x[1] + a[1][2] * x[2] + a[1][3] * x[3];
	result[2] = a[2][0] * x[0] + a[2][1] * x[1] + a[2][2] * x[2] + a[2][3] * x[3];
	result[3] = a[3][0] * x[0] + a[3][1] * x[1] + a[3][2] * x[2] + a[3][3] * x[3];
}

void _CRTestDumpMat(float matrix[4][4]) {
	printf("--------------\n");
	for (int i = 0; i < 4; i++) {
		printf("%4.3f %4.3f %4.3f %4.3f\n", matrix[i][0],  matrix[i][1],  matrix[i][2],  matrix[i][3]);
	}
}

void _CRTestDumpVec(float vec[4]) {
	printf("--------------\n");
	for (int i = 0; i < 4; i++) {
		printf("%4.3f\n", vec[i]);
	}
}

void _CRTestProjectPoint2(float mat[4][4], float *x, float *x_projected, float focal, float xdeg, float ydeg, float zdeg, float xt, float yt, float zt) {
	float r1[4][4];
	float r2[4][4];
	float r3[4][4];
	float r4[4][4];
	
	float temp1[4][4];
	float temp2[4][4];
	
	r1[0][0] = cos(zdeg);	r1[0][1] = -sin(zdeg);	r1[0][2] = 0;				r1[0][3] = 0;
	r1[1][0] = sin(zdeg);	r1[1][1] = cos(zdeg);	r1[1][2] = 0;				r1[1][3] = 0;
	r1[2][0] = 0;			r1[2][1] = 0;			r1[2][2] = 1;				r1[2][3] = 0;
	r1[3][0] = 0;			r1[3][1] = 0;			r1[3][2] = 0;				r1[3][3] = 1;
	
	r2[0][0] = cos(ydeg);	r2[0][1] = 0;			r2[0][2] = sin(ydeg);		r2[0][3] = 0;
	r2[1][0] = 0;			r2[1][1] = 1;			r2[1][2] = 0;				r2[1][3] = 0;
	r2[2][0] = -sin(ydeg);	r2[2][1] = 0;			r2[2][2] = cos(ydeg);		r2[2][3] = 0;
	r2[3][0] = 0;			r2[3][1] = 0;			r2[3][2] = 0;				r2[3][3] = 1;
	
	r3[0][0] = 1;			r3[0][1] = 0;			r3[0][2] = 0;				r3[0][3] = 0;
	r3[1][0] = 0;			r3[1][1] = cos(xdeg);	r3[1][2] = -sin(xdeg);		r3[1][3] = 0;
	r3[2][0] = 0;			r3[2][1] = sin(xdeg);	r3[2][2] = cos(xdeg);		r3[2][3] = 0;
	r3[3][0] = 0;			r3[3][1] = 0;			r3[3][2] = 0;				r3[3][3] = 1;
	
	r4[0][0] = 1;			r4[0][1] = 0;			r4[0][2] = 0;				r4[0][3] = xt;
	r4[1][0] = 0;			r4[1][1] = 1;			r4[1][2] = 0;				r4[1][3] = yt;
	r4[2][0] = 0;			r4[2][1] = 0;			r4[2][2] = 1;				r4[2][3] = zt;
	r4[3][0] = 0;			r4[3][1] = 0;			r4[3][2] = 0;				r4[3][3] = 1;
	
	_CRTestMultiMat(temp1, r1, r2);
	_CRTestMultiMat(temp2, temp1, r3);
	_CRTestMultiMat(mat, temp2, r4);
	
	float r[4];
	
	_CRTestMultiMatAndVec(r, mat, x);
	x_projected[0] = r[0] / r[2] * focal;
	x_projected[1] = r[1] / r[2] * focal;
	x_projected[2] = 1;
}

void _CRTestProjectPoint(float *x, float *x_projected, float focal, float xdeg, float ydeg, float zdeg, float xt, float yt, float zt);

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
	float corners[4][4];
	corners[0][0] = -0.5;			corners[0][1] = -0.5;			corners[0][2] = 0;			corners[0][3] = 1;
	corners[1][0] = -0.5;			corners[1][1] =  0.5;			corners[1][2] = 0;			corners[1][3] = 1;
	corners[2][0] =  0.5;			corners[2][1] =  0.5;			corners[2][2] = 0;			corners[2][3] = 1;
	corners[3][0] =  0.5;			corners[3][1] = -0.5;			corners[3][2] = 0;			corners[3][3] = 1;
	
	unsigned char *pixel = (unsigned char*)malloc(sizeof(unsigned char)*width*height);
	
	float corners_projected[12];
	
	float mat[4][4];
	
	for (int i = 0; i < 4; i++) {
		float *p = corners_projected + i * 3;
		float p2[2];
		p2[0] = p[0];
		p2[1] = p[1];

		_CRTestProjectPoint2(mat, corners[i], p, focal, xdeg, ydeg, zdeg, xt, yt, zt);
		
		p[0] += width / 2;
		p[1] += height / 2;
	
		projected_corners[i].x = p[0];
		projected_corners[i].y = p[1];
		projected_corners[i].w = 1;
	}
	
	int precision = 300;
	
	float step = 1.0f / (precision - 1);
	
	for (int i = 0; i < precision; i++) {
		for (int j = 0; j < precision; j++) {
			float x_temp[3];
			float x_temp_projected[3];
			x_temp[0] = -0.5 + step * i;
			x_temp[1] = -0.5 + step * j;
			x_temp[2] = 1;

			_CRTestProjectPoint2(mat, x_temp, x_temp_projected, focal, xdeg, ydeg, zdeg, xt, yt, zt);
			
			x_temp_projected[0] += width / 2;
			x_temp_projected[1] += height / 2;
			_CRTestSetPixel(pixel, width, height, x_temp_projected[0], x_temp_projected[1], 0x01);
		}
	}
	
	*output_pixel = pixel;
	
//	_CRTestDumpMat(mat);
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