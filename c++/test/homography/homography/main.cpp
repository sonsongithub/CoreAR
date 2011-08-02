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

void showMatrix3x4(float x[3][4]) {
	for (int row = 0; row < 3; row++) {
		for (int column = 0; column < 4; column++) {
			printf("%f ", x[row][column]);
		}
		printf(";\n");
	}
}

void showMatrix4x4(float x[4][4]) {
	for (int row = 0; row < 4; row++) {
		for (int column = 0; column < 4; column++) {
			printf("%f ", x[row][column]);
		}
		printf(";\n");
	}
}

void showMatrix3x3(float x[3][3]) {
	for (int row = 0; row < 3; row++) {
		for (int column = 0; column < 3; column++) {
			printf("%f ", x[row][column]);
		}
		printf(";\n");
	}
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
	
	_DPRINTF("Ground truth RT Matrix\n");
	_CRTestDumpMat(pMat);
	_DPRINTF("\n");
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// parse chain code
	//
	////////////////////////////////////////////////////////////////////////////////
	chaincode->parsePixel(pixel, width, height);
	
	CRCode *groundTruthCode = new CRCode(corners, corners+1, corners+2, corners+3);
	
	if (!chaincode->blobs->empty()) {
		CRChainCodeBlob *blob = chaincode->blobs->front();
		CRCode *code_normal = blob->code();
		
		_DPRINTF("Using corners from the image.\n");
		code_normal->dumpCorners();
		code_normal->normalizeCornerForImageCoord(width, height, focal, focal);
		code_normal->getSimpleHomography(codeSize);
		_DPRINTF("Homography matrix from the extracted corners.\n");
		showMatrix3x3(code_normal->homography);
		_DPRINTF("RT matrix from the extracted corners.\n");
		showMatrix4x4(code_normal->rt);
		
		_DPRINTF("\n");
		_DPRINTF("Using ground truth corners\n");
		groundTruthCode->dumpCorners();
		groundTruthCode->normalizeCornerForImageCoord(width, height, focal, focal);
		groundTruthCode->getSimpleHomography(codeSize);
		showMatrix3x3(groundTruthCode->homography);
		showMatrix4x4(groundTruthCode->rt);
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

