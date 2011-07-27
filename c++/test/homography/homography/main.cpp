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
	
	width = 40;
	height = 40;
	
	CRHomogeneousVec3 *corners = new CRHomogeneousVec3 [4];
	
	float focal = 300;
	float xdeg = 0.1;//M_PI/200.0;
	float ydeg = 0;//M_PI/200.0;
	float zdeg = 0.2;
	
	float xt = 0;
	float yt = 0;
	float zt = 14;
	float pMat[4][4];
	_CRTestMakePixelDataAndPMatrixWithProjectionSetting(
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
	_CRTestDumpPixel(pixel, width, height);
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// parse chain code
	//
	////////////////////////////////////////////////////////////////////////////////
	_tic();
	chaincode->parsePixel(pixel, width, height);
	_toc();
	
	// _CRTestDumpPixel(pixel, width, height);
	
	if (!chaincode->blobs->empty()) {
		CRChainCodeBlob *blob = chaincode->blobs->front();
		CRCode *code_normal = blob->code();
		
		float xy[3][4];
		float uv[3][4];
		float uv2[3][4];
		float homography[3][3];
		
		
		_DPRINTF("------------------->\n");
		for (int i = 0; i < 4; i++) {
			(code_normal->corners + i)->dump();
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
			(corners + i)->y -= (float)height/2;
			(corners + i)->y /= (float)focal;
			uv[0][i] = (corners + i)->x;
			uv[1][i] = (corners + i)->y;
			uv[2][i] = (corners + i)->w;
		}
		
		
		for (int i = 0; i < 4; i++) {
			(code_normal->corners + i)->normalize();
			(code_normal->corners + i)->x -= (float)width/2;
			(code_normal->corners + i)->x /= (float)focal;
			(code_normal->corners + i)->y -= (float)height/2;
			(code_normal->corners + i)->y /= (float)focal;
			uv2[0][i] = (code_normal->corners + i)->x;
			uv2[1][i] = (code_normal->corners + i)->y;
			uv2[2][i] = (code_normal->corners + i)->w;
		}
		
		showMatrix3x4(xy);
		showMatrix3x4(uv);
		showMatrix3x4(uv2);
		
		getHomography(xy, uv, homography);
		showMatrix3x3(homography);
		_CRTestDumpMat(pMat);
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

