/*
 * Core AR
 * corner.cpp
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

#include "corner.h"

#include "CoreAR.h"
#include "CRTest.h"

float getErrorAfterOrderingCorners(CRCode *code1, CRCode *code2);

float getErrorAfterOrderingCorners(CRCode *code1, CRCode *code2) {
	float error = 0;
	
	int diff = 0;
	for (int i = 0; i < 4; i++) {
		int k = i + diff;
		if (k > 3)
			k -= 4;
		error += getDifferenceBetweenVectors(code1->corners + i, code2->corners + k);
	}
	
	for (int diff = 1; diff < 4; diff++) {
		float currentError = 0;
		for (int i = 0; i < 4; i++) {
			int k = i + diff;
			if (k > 3)
				k -= 4;
			currentError += getDifferenceBetweenVectors(code1->corners + i, code2->corners + k);
		}
		if (currentError < error)
			error = currentError;
	}
	return error;
}

void corner_test() {
	printf("=================================================>Corner detection test\n");
	
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
	
	float focal = 600;
	float xdeg = 0;//M_PI/800.0;
	float ydeg = 0;//M_PI/800.0;
	float zdeg = M_PI/10;
	
	float xt = 0;
	float yt = 0;
	float zt = 70;
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
	chaincode->parsePixel(pixel, width, height);
	
	CRCode *gtCode = new CRCode(corners + 0, corners + 1, corners + 2, corners + 3);
	
	if (!chaincode->blobs->empty()) {
		CRChainCodeBlob *blob = chaincode->blobs->front();
		{
			_tic();
			CRCode *code = blob->code();
			float e = _tocWithoutLog();
			float error = getErrorAfterOrderingCorners(code, gtCode);
			printf("Error=%f\n", error);
			printf("Extract corners\n\t%0.5f[msec]\n\n", e);
			SAFE_DELETE(code);
		}
		
		{
			_tic();
			CRCode *code = blob->codeWithoutLSM();
			float e = _tocWithoutLog();
			float error = getErrorAfterOrderingCorners(code, gtCode);
			printf("Error=%f(without LSM)\n", error);
			printf("Extract corners without least square method\n\t%0.5f[msec]\n\n", e);
			SAFE_DELETE(code);
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// dump
	//
	////////////////////////////////////////////////////////////////////////////////
	// _CRTestDumpPixel(pixel, width, height);
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// Release
	//
	////////////////////////////////////////////////////////////////////////////////
	free(pixel);
	delete gtCode;
	delete chaincode;
	delete [] corners;
}