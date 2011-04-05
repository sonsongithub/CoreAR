/*
 * Core AR
 * main.c
 *
 * Copyright (c) Yuichi YOSHIDA, 11/01/17.
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

#include "ar.h"

int main (int argc, char * const argv[]) {
	
#if 1
	////////////////////////////////////////////////////////////////////////////////
	//
	// make dummy data
	//
	////////////////////////////////////////////////////////////////////////////////
	int width = 20;
	int height = 20;
	unsigned char *grayBuff = (unsigned char*)malloc(sizeof(unsigned char)*width*height);
	
	memset(grayBuff, 0, sizeof(unsigned char)*width*height);
	for (int y = 5; y < 17; y++) {
		for (int x = 7; x < 17; x++) {
			grayBuff[x + y * width] = 1;
		}
	}
	
	grayBuff[7 + 2 * width] = 0;
	grayBuff[8 + 2 * width] = 0;
	grayBuff[8 + 4 * width] = 0;
#endif

#if 0
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
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// display pixel before extracting chain code
	//
	////////////////////////////////////////////////////////////////////////////////
	for (int y = 0; y < 20; y++) {
		for (int x = 0; x < 20; x++) {
			printf("%02x ", grayBuff[x + y * width]);
		}
		printf("\n");
	}
	printf("\n");

	unsigned char *chaincodeFlag = grayBuff;
	
	// extract
	CRChainCodeStorage *storage = CRCreateChainCodeStorageByParsingPixel(chaincodeFlag, width, height);

	// release chaincode data
	CRReleaseChainCodeStorage(&storage);
	
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// display pixel after extracting chain code
	//
	////////////////////////////////////////////////////////////////////////////////
	for (int y = 0; y < 20; y++) {
		for (int x = 0; x < 20; x++) {
			printf("%02x ", grayBuff[x + y * width]);
		}
		printf("\n");
	}
	
	free(grayBuff);
	
}
