/*
 * Core AR
 * Core detect test
 *
 * Copyright (c) Yuichi YOSHIDA, 11/07/24.
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
	
	int test_count = 100;
	float sum_diff_normal = 0;
	float sum_diff_without_lsm = 0;
	float param = 1.0;
	
	for (int i = 0; i < test_count; i++) {
		float diff_normal = 0;
		float diff_without_lsm = 0;
		testCornerDetection(&diff_normal, &diff_without_lsm, param);
		
		sum_diff_normal += diff_normal;
		sum_diff_without_lsm += diff_without_lsm;
		
		//
		param += 0.1;
	}
	
	_DPRINTF("test sum diff normal average = %f\n", sum_diff_normal / test_count);
	_DPRINTF("test sum diff without lsm average = %f\n", sum_diff_without_lsm / test_count);
	
	return 0;
}

