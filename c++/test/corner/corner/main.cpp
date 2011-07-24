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

#include "CRChainCode.h"
#include "CRTest.h"

int main (int argc, const char * argv[]) {
	
	unsigned char *pixel = NULL;
	int width = 0;
	int height = 0;
	
	CRChainCode *chaincode = new CRChainCode();
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// make test pixel data
	//
	////////////////////////////////////////////////////////////////////////////////
	
	width = 25;
	height = 25;
	float corners_projected[12];
	
	float focal = 5;
	float xdeg = M_PI/800.0;
	float ydeg = M_PI/800.0;
	float zdeg = M_PI/4.0;
	
	float xt = 0;
	float yt = 0;
	float zt = 0.4;
	_CRTestMakePixelDataWithProjectionSetting(
											  &pixel,
											  width,
											  height,
											  NULL,
											  focal,
											  xdeg, 
											  ydeg, 
											  zdeg, 
											  xt, 
											  yt,
											  zt);
//	printf("%f,%f,%f\n", corners_projected[0], corners_projected[1], corners_projected[2]);
//	printf("%f,%f,%f\n", corners_projected[3], corners_projected[4], corners_projected[5]);
//	printf("%f,%f,%f\n", corners_projected[6], corners_projected[7], corners_projected[8]);
//	printf("%f,%f,%f\n", corners_projected[9], corners_projected[10], corners_projected[11]);
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// parse chain code
	//
	////////////////////////////////////////////////////////////////////////////////
	chaincode->parsePixel(pixel, width, height);
	CRChainCodeBlob *blob = chaincode->blobs->front();
	
	blob->code()->firstCorner->dump();
	blob->codeWithoutLSM()->firstCorner->dump();
	printf("%f,%f,%f\n", corners_projected[0], corners_projected[1], corners_projected[2]);
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// dump
	//
	////////////////////////////////////////////////////////////////////////////////
	_CRTestDumpPixel(pixel, width, height);

	////////////////////////////////////////////////////////////////////////////////
	//
	// Release
	//
	////////////////////////////////////////////////////////////////////////////////
	free(pixel);
	delete(chaincode);
	
    return 0;
}

