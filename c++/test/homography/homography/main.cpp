//
//  main.cpp
//  homography
//
//  Created by sonson on 11/07/25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#include <iostream>


#include <math.h>
#include <time.h>

#include "CRChainCode.h"
#include "CRHomogeneousVec3.h"
#include "CRTest.h"

#include <Accelerate/Accelerate.h>

void getSimpleHomography(float uv[3][4], float homography[3][3]) {
	float h[8];
	
	h[6] = uv[0][0];
	h[7] = uv[1][0];
	
	float param_u_4 = uv[0][0] - uv[0][1] - uv[0][3] + uv[0][2];
	float param_v_4 = uv[1][0] - uv[1][1] - uv[1][3] + uv[1][2];
	
	h[5] = param_u_4 * (uv[1][1] - uv[1][2]) - param_v_4 * (uv[0][1] - uv[0][2]);
	h[5] = h[5] / ((uv[0][3] - uv[0][2]) * (uv[1][1] - uv[1][2]) - (uv[0][1] - uv[0][2]) * (uv[1][3] - uv[1][2]));
	
	h[2] = (param_u_4 - (uv[0][3] - uv[0][2]) * h[5]) / (uv[0][1] - uv[0][2]);
	
	h[0] = uv[0][1] * h[2] - uv[0][0] + uv[0][1];
	h[1] = uv[1][1] * h[2] - uv[1][0] + uv[1][1];
	
	h[3] = uv[0][3] * h[5] - uv[0][0] + uv[0][3];
	h[4] = uv[1][3] * h[5] - uv[1][0] + uv[1][3];
	
	homography[0][0] = h[0];
	homography[1][0] = h[1];
	homography[2][0] = h[2];
	
	homography[0][1] = h[3];
	homography[1][1] = h[4];
	homography[2][1] = h[5];
	
	homography[0][2] = h[6];
	homography[1][2] = h[7];
	homography[2][2] = 1;
}

void getRTMatrix(float rt[4][4], float homography[3][3], float scale) {
	
	float e1_length = homography[0][0] * homography[0][0] + homography[1][0] * homography[1][0] + homography[2][0] * homography[2][0];
	float e2_length = homography[0][1] * homography[0][1] + homography[1][1] * homography[1][1] + homography[2][1] * homography[2][1];
	e1_length = sqrtf(e1_length);
	e2_length = sqrtf(e2_length);
	float length = (e1_length + e2_length) * 0.5;
	
	rt[0][0] = homography[0][0] / length;
	rt[1][0] = homography[1][0] / length;
	rt[2][0] = homography[2][0] / length;
	rt[3][0] = 0;
	
	rt[0][1] = homography[0][1] / length;
	rt[1][1] = homography[1][1] / length;
	rt[2][1] = homography[2][1] / length;
	rt[3][1] = 0;
	
	rt[0][2] = rt[1][0] * rt[2][1] - rt[2][0] * rt[1][1];
	rt[1][2] = rt[2][0] * rt[0][1] - rt[0][0] * rt[2][1];
	rt[2][2] = rt[0][0] * rt[1][1] - rt[1][0] * rt[0][1];
	rt[3][2] = 0;
	
	rt[0][3] = homography[0][2] / length * scale;
	rt[1][3] = homography[1][2] / length * scale;
	rt[2][3] = homography[2][2] / length * scale;
	rt[3][3] = 1;
}

void getHomography(float xy[3][4], float uv[3][4], float homography[3][3]) {
	
	for (int column = 0; column < 4; column++) {
		xy[0][column] = xy[0][column] / xy[2][column];
		xy[1][column] = xy[1][column] / xy[2][column];
		xy[2][column] = 1;
	}
	
	for (int column = 0; column < 4; column++) {
		uv[0][column] = uv[0][column] / uv[2][column];
		uv[1][column] = uv[1][column] / uv[2][column];
		uv[2][column] = 1;
	}
	
	float datamatrix[64];
	
	float b[8];
	
	for (int row = 0; row < 4; row++) {
		
		int row_1 = row * 2;
		int row_2 = row * 2 + 1;
		
		datamatrix[row_1 + 8 * 0] = xy[0][row];
		datamatrix[row_1 + 8 * 1] = xy[1][row];
		datamatrix[row_1 + 8 * 2] = 1;
		
		datamatrix[row_1 + 8 * 3] = 0;
		datamatrix[row_1 + 8 * 4] = 0;
		datamatrix[row_1 + 8 * 5] = 0;
		
		datamatrix[row_1 + 8 * 6] = -uv[0][row] * xy[0][row];
		datamatrix[row_1 + 8 * 7] = -uv[0][row] * xy[1][row];
		
		datamatrix[row_2 + 8 * 0] = 0;
		datamatrix[row_2 + 8 * 1] = 0;
		datamatrix[row_2 + 8 * 2] = 0;
		
		datamatrix[row_2 + 8 * 3] = xy[0][row];
		datamatrix[row_2 + 8 * 4] = xy[1][row];
		datamatrix[row_2 + 8 * 5] = 1;
		
		datamatrix[row_2 + 8 * 6] = -uv[1][row] * xy[0][row];
		datamatrix[row_2 + 8 * 7] = -uv[1][row] * xy[1][row];
	}
	
	for (int row = 0; row < 8; row++) {
		for (int column = 0; column < 8; column++) {
			printf("%f ", datamatrix[row + column * 8]);
		}
		printf("\n");
	}
	
	b[0] = uv[0][0];
	b[1] = uv[1][0];
	b[2] = uv[0][1];
	b[3] = uv[1][1];
	b[4] = uv[0][2];
	b[5] = uv[1][2];
	b[6] = uv[0][3];
	b[7] = uv[1][3];
	
	int rank = 8;
	int nrhs = 1;
	int pivot[8];
	int info = 0;
	
	sgesv_((__CLPK_integer*)&rank, (__CLPK_integer*)&nrhs, (__CLPK_real*)datamatrix, (__CLPK_integer*)&rank, (__CLPK_integer*)pivot,(__CLPK_real*)b, (__CLPK_integer*)&rank, (__CLPK_integer*)&info);
	
	homography[0][0] = b[0];
	homography[0][1] = b[1];
	homography[0][2] = b[2];
	
	homography[1][0] = b[3];
	homography[1][1] = b[4];
	homography[1][2] = b[5];
	
	homography[2][0] = b[6];
	homography[2][1] = b[7];
	homography[2][2] = 1;
	
}

void showMatrix3x4(float x[3][4]) {
	for (int row = 0; row < 3; row++) {
		for (int column = 0; column < 4; column++) {
			printf("%f ", x[row][column]);
		}
		printf(";\n");
	}
	printf("\n");
}

void showMatrix4x4(float x[4][4]) {
	for (int row = 0; row < 4; row++) {
		for (int column = 0; column < 4; column++) {
			printf("%f ", x[row][column]);
		}
		printf(";\n");
	}
	printf("\n");
}

void showMatrix3x3(float x[3][3]) {
	for (int row = 0; row < 3; row++) {
		for (int column = 0; column < 3; column++) {
			printf("%f ", x[row][column]);
		}
		printf(";\n");
	}
	printf("\n");
}

void testCornerDetection();

void testCornerDetection() {
	
	srand((unsigned)time(NULL));
	
	unsigned char *pixel = NULL;
	int width = 0;
	int height = 0;
	
	CRChainCode *chaincode = new CRChainCode();
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// make test pixel data
	//
	////////////////////////////////////////////////////////////////////////////////
	
	width = 640;
	height = 480;
	
	CRHomogeneousVec3 *corners = new CRHomogeneousVec3 [4];
	
	float focal = 650;
	float xdeg = M_PI / 10.0f;
	float ydeg = 0;
	float zdeg = M_PI / 40.0f;
	
	float xt = 0.05;
	float yt = 0;
	float zt = 5;
	float pMat[4][4];
	
	float codeSize = 0.5;
	
	_CRTestMakePixelDataAndPMatrixWithProjectionSettingAndCodeSize(
											  codeSize,
											  pMat,
											  &pixel,
											  width,
											  height,
											  corners,
											  focal,
											  xdeg, 
											  ydeg, 
											  zdeg, 
											  xt, 
											  yt,
											  zt);
	//_CRTestDumpPixel(pixel, width, height);
	_CRTestDumpMat(pMat);
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// parse chain code
	//
	////////////////////////////////////////////////////////////////////////////////
	_tic();
	chaincode->parsePixel(pixel, width, height);
	_toc();
	
	// _CRTestDumpPixel(pixel, width, height);
	
	CRCode *groundTruthCode = new CRCode(corners, corners+1, corners+2, corners+3);
	
	if (!chaincode->blobs->empty()) {
		CRChainCodeBlob *blob = chaincode->blobs->front();
		CRCode *code_normal = blob->code();
		
		code_normal->dumpCorners();
		code_normal->normalizeCornerForImageCoord(width, height, focal, focal);
		code_normal->getSimpleHomography();
		showMatrix3x3(code_normal->homography);
		showMatrix4x4(code_normal->rt);
		
		groundTruthCode->dumpCorners();
		groundTruthCode->normalizeCornerForImageCoord(width, height, focal, focal);
		groundTruthCode->getSimpleHomography();
		showMatrix3x3(groundTruthCode->homography);
		showMatrix4x4(groundTruthCode->rt);
		
/*		
		CRCode *code_without_lsm = blob->codeWithoutLSM();
		
		float xy[3][4];
		float uv[3][4];
		float homography[3][3];
		
		
		_DPRINTF("------------------->\n");
		for (int i = 0; i < 4; i++) {
			(code_normal->corners + i)->dump();
			(code_without_lsm->corners + i)->dump();
			(corners + i)->dump();
			_DPRINTF("------------------->\n");
		}
		_DPRINTF("------------------->\n");
		
		xy[0][0] = 0;	xy[0][1] = 1;	xy[0][2] = 1;	xy[0][3] = 0;
		xy[1][0] = 0;	xy[1][1] = 0;	xy[1][2] = 1;	xy[1][3] = 1;
		xy[2][0] = 1;	xy[2][1] = 1;	xy[2][2] = 1;	xy[2][3] = 1;
		
		for (int i = 0; i < 4; i++) {
			(corners + i)->normalize();
			(corners + i)->x -= (float)width/2;
			(corners + i)->x /= (float)focal;
			(corners + i)->y = (float)height/2 - (corners + i)->y;
			(corners + i)->y /= (float)focal;
			uv[0][i] = (corners + i)->x;
			uv[1][i] = (corners + i)->y;
			uv[2][i] = (corners + i)->w;
		}
		
		showMatrix3x4(xy);
		showMatrix3x4(uv);
		
		float rt[4][4];
		float scale = codeSize;
		
		_DPRINTF("-------------normal homography\n");
		_tic();
			getHomography(xy, uv, homography);
			getRTMatrix(rt, homography, scale);
		_toc();
		showMatrix3x3(homography);
		showMatrix4x4(rt);
		
		_DPRINTF("-------------fast homography\n");
		_tic();
			getSimpleHomography(uv, homography);
			getRTMatrix(rt, homography, scale);
		_toc();
		
		showMatrix3x3(homography);
		showMatrix4x4(rt);
		
		_DPRINTF("-------------ground truth\n");
		_CRTestDumpMat(pMat);
		delete code_without_lsm;
*/		
		delete code_normal;
	}
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// Release
	//
	////////////////////////////////////////////////////////////////////////////////
	free(pixel);
	delete chaincode;
	delete [] corners;
}

int main (int argc, const char * argv[]) {
	testCornerDetection();
    return 0;
}

