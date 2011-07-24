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

void _CRTestDumpPixel(unsigned char* pixel, int width, int height) {
	////////////////////////////////////////////////////////////////////////////////
	//
	// display pixel after extracting chain code
	//
	////////////////////////////////////////////////////////////////////////////////
	for (int y = 0; y < width; y++) {
		for (int x = 0; x < height; x++) {
			printf("%02x ", pixel[x + y * width]);
		}
		printf("\n");
	}
}

void _CRTestMakeSimplePixelData(unsigned char **output_pixel, int *output_width, int *output_height) {
	
#define _MAKE_DUMMY_DATA
#ifdef _MAKE_DUMMY_DATA
	////////////////////////////////////////////////////////////////////////////////
	//
	// make dummy data
	//
	////////////////////////////////////////////////////////////////////////////////
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
#else
	////////////////////////////////////////////////////////////////////////////////
	//
	// read dummy data from file
	//
	////////////////////////////////////////////////////////////////////////////////
	int width = 320;
	int height = 240;
	unsigned char *grayBuff = (unsigned char*)malloc(sizeof(unsigned char)*width*height);
	
	memset(grayBuff, 0, sizeof(unsigned char)*width*height);
	FILE *fp = fopen("../../test.bin", "rb");
	
	
	for (int y = 0; y < height; y++) {
		unsigned char *p = (grayBuff + y * width);
		fread(p, sizeof(unsigned char), width, fp);
	}
	fclose(fp);
#endif	
	*output_pixel = grayBuff;
	*output_width = width;
	*output_height = height;
}

#if 0

#include "ar.h"
#include "common.h"

void setPixel(unsigned char* pixel, int width, int height, int x, int y, unsigned char value) {
	if (x >= 0 && x < width && y >= 0 && y < height) 
		*(pixel + x + y * width) = value;
}

void projectPoint(float *x, float *x_projected, float focal, float xdeg, float ydeg, float zdeg, float xt, float yt, float zt) {
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

void makeTestData(unsigned char *pixel, int width, int height, float *corners_projected, float focal, float xdeg, float ydeg, float zdeg, float xt, float yt, float zt) {
	float corners[4][3];
	corners[0][0] = -0.5;			corners[0][1] = -0.5;			corners[0][2] = 0;
	corners[1][0] = -0.5;			corners[1][1] =  0.5;			corners[1][2] = 0;
	corners[2][0] =  0.5;			corners[2][1] =  0.5;			corners[2][2] = 0;
	corners[3][0] =  0.5;			corners[3][1] = -0.5;			corners[3][2] = 0;
	
	for (int i = 0; i < 4; i++) {
		float *p = corners_projected + i * 3;
		projectPoint(corners[i], p, focal, xdeg, ydeg, zdeg, xt, yt, zt);
		p[0] += width / 2;
		p[1] += height / 2;
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
			
			projectPoint(x_temp, x_temp_projected, focal, xdeg, ydeg, zdeg, xt, yt, zt);
			x_temp_projected[0] += width / 2;
			x_temp_projected[1] += height / 2;
			setPixel(pixel, width, height, x_temp_projected[0], x_temp_projected[1], 0xff);
		}
	}
	
}

double getError(CRChainCode *chainCode, float *corners_projected) {
	float minimumError = 0;
	float error = 0;

	// pattern 1
	error =         sqrt(pow((chainCode->cornersX[0] - corners_projected[0*3]), 2) + pow((chainCode->cornersY[0] - corners_projected[0*3+1]), 2));
	error = error + sqrt(pow((chainCode->cornersX[1] - corners_projected[1*3]), 2) + pow((chainCode->cornersY[1] - corners_projected[1*3+1]), 2));
	error = error + sqrt(pow((chainCode->cornersX[2] - corners_projected[2*3]), 2) + pow((chainCode->cornersY[2] - corners_projected[2*3+1]), 2));
	error = error + sqrt(pow((chainCode->cornersX[3] - corners_projected[3*3]), 2) + pow((chainCode->cornersY[3] - corners_projected[3*3+1]), 2));
	minimumError = error;
	
	error =         sqrt(pow((chainCode->cornersX[1] - corners_projected[0*3]), 2) + pow((chainCode->cornersY[1] - corners_projected[0*3+1]), 2));
	error = error + sqrt(pow((chainCode->cornersX[2] - corners_projected[1*3]), 2) + pow((chainCode->cornersY[2] - corners_projected[1*3+1]), 2));
	error = error + sqrt(pow((chainCode->cornersX[3] - corners_projected[2*3]), 2) + pow((chainCode->cornersY[3] - corners_projected[2*3+1]), 2));
	error = error + sqrt(pow((chainCode->cornersX[0] - corners_projected[3*3]), 2) + pow((chainCode->cornersY[0] - corners_projected[3*3+1]), 2));
	if (minimumError > error)
		minimumError = error;
	
	error =         sqrt(pow((chainCode->cornersX[2] - corners_projected[0*3]), 2) + pow((chainCode->cornersY[2] - corners_projected[0*3+1]), 2));
	error = error + sqrt(pow((chainCode->cornersX[3] - corners_projected[1*3]), 2) + pow((chainCode->cornersY[3] - corners_projected[1*3+1]), 2));
	error = error + sqrt(pow((chainCode->cornersX[0] - corners_projected[2*3]), 2) + pow((chainCode->cornersY[0] - corners_projected[2*3+1]), 2));
	error = error + sqrt(pow((chainCode->cornersX[1] - corners_projected[3*3]), 2) + pow((chainCode->cornersY[1] - corners_projected[3*3+1]), 2));
	if (minimumError > error)
		minimumError = error;
	
	error =         sqrt(pow((chainCode->cornersX[3] - corners_projected[0*3]), 2) + pow((chainCode->cornersY[3] - corners_projected[0*3+1]), 2));
	error = error + sqrt(pow((chainCode->cornersX[0] - corners_projected[1*3]), 2) + pow((chainCode->cornersY[0] - corners_projected[1*3+1]), 2));
	error = error + sqrt(pow((chainCode->cornersX[1] - corners_projected[2*3]), 2) + pow((chainCode->cornersY[1] - corners_projected[2*3+1]), 2));
	error = error + sqrt(pow((chainCode->cornersX[2] - corners_projected[3*3]), 2) + pow((chainCode->cornersY[2] - corners_projected[3*3+1]), 2));
	if (minimumError > error)
		minimumError = error;
	
	return minimumError;
}

void test(float focal, float xdeg, float ydeg, float zdeg, float xt, float yt, float zt, float *error1, float *error2) {
	int width = 30;
	int height= 30;
	unsigned char *pixel = (unsigned char*)malloc(sizeof(unsigned char)*width*height);
	unsigned char *flag = (unsigned char*)malloc(sizeof(unsigned char)*width*height);
	
	float corners_projected[12];
	
	float withLSMX[4];
	float withLSMY[4];
	float withoutLSMX[4];
	float withoutLSMY[4];
	
	memset(pixel, 0, sizeof(unsigned char)*width*height);
	memset(flag, CRChainCodeFlagIgnore, sizeof(unsigned char)*width*height);
	
	makeTestData(pixel, width, height, corners_projected, focal, xdeg, ydeg, zdeg, xt, yt, zt);
	CRDenoiseWithContractionAndExpansion(pixel, width, height);
	
	CRChainCodeStorage *storage = NULL;
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// without least squre method
	//
	////////////////////////////////////////////////////////////////////////////////
	for (int y = 0; y < height; y++)
		for (int x = 0; x < width; x++)
			if (pixel[x + y * width])
				flag[x + y * width] = CRChainCodeFlagUnchecked;
	
	storage = CRCreateChainCodeStorageByParsingPixel(flag, width, height);
	
//	tic();
	CRChainCodeStorageDetectCornerWithLSM(storage);
//	toc();
	
	for (int i = 0; i < 4; i++) {
		withLSMX[i] = storage->head->cornersX[i];
		withLSMY[i] = storage->head->cornersY[i];
	}
	*error1 = getError(storage->head, corners_projected);
	
	CRReleaseChainCodeStorage(&storage);

	////////////////////////////////////////////////////////////////////////////////
	//
	// with least squre method
	//
	////////////////////////////////////////////////////////////////////////////////
	for (int y = 0; y < height; y++)
		for (int x = 0; x < width; x++)
			if (pixel[x + y * width])
				flag[x + y * width] = CRChainCodeFlagUnchecked;
	
	storage = CRCreateChainCodeStorageByParsingPixel(flag, width, height);
//	tic();
	CRChainCodeStorageDetectCornerWithoutLSM(storage);
//	toc();
	
	for (int i = 0; i < 4; i++) {
		withoutLSMX[i] = storage->head->cornersX[i];
		withoutLSMY[i] = storage->head->cornersY[i];
	}
	*error2 = getError(storage->head, corners_projected);
	
#if 0
	if (*error1 > *error2) {
		printf("---------------------------------------------------------------->test image\n");
		for (int y = 0; y < height; y++) {
			for (int x = 0; x < width; x++)
				printf("%02x ", flag[x + y * width]);
			printf("\n");
		}
		printf("\n");
		
		printf("------------------------------------->true position\n");
		for (int i = 0; i < 4; i++)
			printf("%f,%f\n", corners_projected[i*3], corners_projected[i*3+1]);
		
		printf("------------------------------------->estimate with LSM\n");
		for (int i = 0; i < 4; i++)
			printf("%f,%f\n", withLSMX[i], withLSMY[i]);
		printf("error = %f\n", *error1);
		printf("------------------------------------->estimate without LSM\n");
		for (int i = 0; i < 4; i++)
			printf("%f,%f\n", withoutLSMX[i], withoutLSMY[i]);
		printf("error = %f\n", *error2);
	}
#endif
	
	CRReleaseChainCodeStorage(&storage);
	
	free(pixel);
	free(flag);
}

int main (int argc, const char * argv[]) {
	
	float focal = 5;
	float xdeg = M_PI/400.0;
	float ydeg = M_PI/400.0;
	float zdeg = M_PI/40.0;
	
	float xt = 0;
	float yt = 0;
	float zt = 0.4;
	
	int testCount = 20;
	int dataNum = testCount * testCount;
	float *errorArrayWithLSM = (float*)malloc(sizeof(float)*dataNum);
	float *errorArrayWithoutLSM = (float*)malloc(sizeof(float)*dataNum);
	int k = 0;
	
	for (int i = 0; i < testCount; i++) {
		for (int j = 0; j < testCount; j++) {
				float error1 = 0;
				float error2 = 0;
				test(focal, xdeg, ydeg*j, zdeg * i, xt, yt, zt, &error1, &error2);
				
				errorArrayWithLSM[k] = error1;
				errorArrayWithoutLSM[k] = error2;
				k++;
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// Error statistic analysis
	//
	////////////////////////////////////////////////////////////////////////////////
	
	float withAve = 0;
	float withoutAve = 0;
	float withSigma = 0;
	float withoutSigma = 0;
	for (int k = 0; k < dataNum;k++) {
		withAve = withAve + errorArrayWithLSM[k];
		withoutAve = withoutAve + errorArrayWithoutLSM[k];
	}
	
	withAve /= (float)dataNum;
	withoutAve /= (float)dataNum;
	
	for (int k = 0; k < dataNum;k++) {
		withSigma = withSigma + pow((errorArrayWithLSM[k] - withAve), 2);
		withoutSigma = withoutSigma + pow((errorArrayWithoutLSM[k]- withoutAve), 2);
	}
	
	withSigma /= (float)(dataNum - 1);
	withoutSigma /= (float)(dataNum - 1);
	
	printf("---------------------------------------------------------------->result statistic analysis\n");
	printf("Least square method - average = %f\n", withAve);
	printf("                      variance = %f\n", sqrt(withSigma));
	printf("Normal detection    - average = %f\n", withoutAve);
	printf("                      variance = %f\n", sqrt(withoutSigma));
	
	free(errorArrayWithLSM);
	free(errorArrayWithoutLSM);
	
	return 0;
}

#endif