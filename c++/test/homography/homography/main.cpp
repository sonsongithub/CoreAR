/*
 * Core AR
 * homography
 *
 * Copyright (c) Yuichi YOSHIDA, 11/07/23.
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

#include <iostream>


#include <math.h>
#include <time.h>

#include "CRChainCode.h"
#include "CRHomogeneousVec3.h"
#include "CRTest.h"

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
		_DPRINTF("\n");
		_DPRINTF("Homography matrix from the extracted corners.\n");
		_CRTestShowMatrix3x3(code_normal->homography);
		_DPRINTF("\n");
		_DPRINTF("RT matrix from the extracted corners.\n");
		_CRTestShowMatrix4x4(code_normal->rt);
		
		_DPRINTF("\n");
		_DPRINTF("Using ground truth corners\n");
		groundTruthCode->dumpCorners();
		groundTruthCode->normalizeCornerForImageCoord(width, height, focal, focal);
		groundTruthCode->getSimpleHomography(codeSize);
		_DPRINTF("\n");
		_DPRINTF("Homography matrix from ground truth.\n");
		_CRTestShowMatrix3x3(groundTruthCode->homography);
		_DPRINTF("\n");
		_DPRINTF("RT matrix from ground truth.\n");
		_CRTestShowMatrix4x4(groundTruthCode->rt);
	
		SAFE_DELETE(code_normal);
	}
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// Release
	//
	////////////////////////////////////////////////////////////////////////////////
	SAFE_FREE(pixel);
	SAFE_DELETE(groundTruthCode);
	SAFE_DELETE(chaincode);
	SAFE_DELETE_ARRAY(corners);
}

int main (int argc, const char * argv[]) {
	testCornerDetection();
    return 0;
}

