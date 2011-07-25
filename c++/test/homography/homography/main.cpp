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

void testCornerDetection(float *diff_normal, float *diff_without_lsm, float param);

void testCornerDetection(float *diff_normal, float *diff_without_lsm, float param) {
	
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
	
	width = 320;
	height = 240;
	
	CRHomogeneousVec3 *corners = new CRHomogeneousVec3 [4];
	
	float focal = 10;
	float xdeg = 0;//M_PI/200.0;
	float ydeg = 0;//M_PI/200.0;
	float zdeg = M_PI /4;
	
	float xt = 0;
	float yt = 0;
	float zt = 0.1;
	_CRTestMakePixelDataWithProjectionSetting(
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
		CRCode *code_without_lsm = blob->codeWithoutLSM();
		
		if (code_normal && code_without_lsm) {
			for (int i = 0; i < 4; i++) {
				float d1 = getDifferenceBetweenVectors(code_normal->corners + i, corners + i);
				float d2 = getDifferenceBetweenVectors(code_without_lsm->corners + i, corners + i);
				
				_DPRINTF("--------------------------------------------\n");
				// (code_normal->corners + i)->dump();
				// (code_without_lsm->corners + i)->dump();
				// (corners + i)->dump();
				_DPRINTF("diff             = %f\n", d1);
				_DPRINTF("diff without LSM = %f\n", d2);
				
				*diff_normal += d1;
				*diff_without_lsm += d2;
			}
			
			delete code_normal;
			delete code_without_lsm;
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// dump
	//
	////////////////////////////////////////////////////////////////////////////////
	//	if (*diff_normal > 2)
	//		_CRTestDumpPixel(pixel, width, height);
	
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
    return 0;
}

