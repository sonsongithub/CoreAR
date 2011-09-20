/*
 * Core AR
 * code.c
 *
 * Copyright (c) Yuichi YOSHIDA, 10/12/07.
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

#include "code.h"

#import <Accelerate/Accelerate.h>
#include "common.h"

#include "codeImageTemplate.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define CENTER_MARGIN				5

#define INSIDE_OUTSIDE_RATIO		1.8
#define INSIDE_OUTSIDE_RATIO_MARGIN	0.4

#define MINIMUM_CIRCUMSCRIBED_SIZE	15

typedef struct _CRCorner {
	float x;
	float y;
}CRCorner;

static float XFocalLength = 650;
static float YFocalLength = 650;

static int decodePixelBuffWidthHeight = DEFAULT_DECODE_PIXEL_BUFFER_WIDTH_HEIGHT;

unsigned char *sharedPixelBufferForCodeImage = NULL;

#pragma mark - Prototype

void _CRNormalizeVec(float *x, float *y, float *z);
void _CROuterProductVec(float x1, float y1, float z1, float x2, float y2, float z2, float *x, float *y, float *z);
int _CRIs4CornersConvex(CRChainCodeElement **p);
int _CRGetHomographyMatrix(float *matrix, CRCorner *p, int inputImgWidth, int inputImgHeight);
void _CRAdjustRotationOfHomographyMatrix(float *b, int rotation);
int _CRCheckBlackFrameAvailability(float *b, unsigned char* inputImgBaseAddress, int inputImgWidth, int inputImgHeight);
void _CRExtractAndCopyCodeImageToSharedBuffer(float *b, unsigned char* inputImgBaseAddress, int inputImgWidth, int inputImgHeight);
void _CRGetDefectivePMatrixFromHomographyMatrix(float *b, float *pmat);
void _CRCalculateTranslationParameter(float *ez, float *pmat, CRCorner *c1, CRCorner *c3, float codeSize, int inputImgWidth, int inputImgHeight);
void _CRAdjustTranslationParameterOfPMatrixOf2DCode(float *pmat, CRCorner *c, float codeSize, int inputImgWidth, int inputImgHeight);
int _CRChainCodeExtract4Corners(CRChainCode *chaincode, CRChainCodeElement **c);

#pragma mark - Private

void _CRNormalizeVec(float *x, float *y, float *z) {
	float l = sqrt(*x * *x + *y * *y + *z * *z);
	*x /= l;
	*y /= l;
	*z /= l;
}

void _CROuterProductVec(float x1, float y1, float z1, float x2, float y2, float z2, float *x, float *y, float *z) {
	*x = y1 * z2 - z1 * y2;
	*y = z1 * x2 - x1 * z2;
	*z = x1 * y2 - y1 * x2;
}

int _CRIs4CornersConvex(CRChainCodeElement **p) {
	
	float vx0 = p[1]->x - p[0]->x;
	float vy0 = p[1]->y - p[0]->y;
	
	float vx1 = p[2]->x - p[1]->x;
	float vy1 = p[2]->y - p[1]->y;
	
	float vx2 = p[3]->x - p[2]->x;
	float vy2 = p[3]->y - p[2]->y;
	
	float vx3 = p[0]->x - p[3]->x;
	float vy3 = p[0]->y - p[3]->y;
	
	float v01z = vx0 * vy1 - vy0 * vx1;
	float v12z = vx1 * vy2 - vy1 * vx2;
	float v23z = vx2 * vy3 - vy2 * vx3;
	float v30z = vx3 * vy0 - vy3 * vx0;
	
	return (v01z < 0 && v12z < 0 && v23z < 0 && v30z < 0);
}

int _CRGetHomographyMatrix(float *matrix, CRCorner *p, int inputImgWidth, int inputImgHeight) {
	
	float x1 = (p[0].x - inputImgWidth/2)  / CRGetXFocalLength();
	float y1 = (p[0].y - inputImgHeight/2) / CRGetYFocalLength();
	float x2 = (p[1].x - inputImgWidth/2)  / CRGetXFocalLength();
	float y2 = (p[1].y - inputImgHeight/2) / CRGetYFocalLength();
	float x3 = (p[2].x - inputImgWidth/2)  / CRGetXFocalLength();
	float y3 = (p[2].y - inputImgHeight/2) / CRGetYFocalLength();
	float x4 = (p[3].x - inputImgWidth/2)  / CRGetXFocalLength();
	float y4 = (p[3].y - inputImgHeight/2) / CRGetYFocalLength();
	
#ifdef DEBUG_CODE_CALCULATION
	printf("------------------------------------------->Corner points\n");
	printf(" %d,%d,%d,%d\n", p[0]->x,p[1]->x,p[2]->x,p[3]->x);
	printf(" %d,%d,%d,%d\n", p[0]->y,p[1]->y,p[2]->y,p[3]->y);
	
	printf("------------------------------------------->Corner points(normalized)\n");
	printf(" %f,%f,%f,%f\n", x1, x2, x3, x4);
	printf(" %f,%f,%f,%f\n", y1, y2, y3, y4);
#endif
	
	float a[64];
	float *b = matrix;
	
	float code = 0.5;
	
	a[0] = -code;  a[ 8] =  code;   a[16] = 1;  a[24] =     0;  a[32] =     0;  a[40] = 0;  a[48] = -x1 * (-code);  a[56] = -x1 * ( code);
	a[1] =     0;  a[ 9] =     0;   a[17] = 0;  a[25] = -code;  a[33] =  code;  a[41] = 1;  a[49] = -y1 * (-code);  a[57] = -y1 * ( code);
	
	a[2] =  code;  a[10] =  code;   a[18] = 1;  a[26] =     0;  a[34] =     0;  a[42] = 0;  a[50] = -x2 * ( code);  a[58] = -x2 * ( code);
	a[3] =     0;  a[11] =     0;   a[19] = 0;  a[27] =  code;  a[35] =  code;  a[43] = 1;  a[51] = -y2 * ( code);  a[59] = -y2 * ( code);
	
	a[4] =  code;  a[12] = -code;   a[20] = 1;  a[28] =    0;   a[36] =     0;  a[44] = 0;  a[52] = -x3 * ( code);  a[60] = -x3 * (-code);
	a[5] =     0;  a[13] =     0;   a[21] = 0;  a[29] =  code;  a[37] = -code;  a[45] = 1;  a[53] = -y3 * ( code);  a[61] = -y3 * (-code);
	
	a[6] = -code;  a[14] = -code;   a[22] = 1;  a[30] =     0;  a[38] =     0;  a[46] = 0;  a[54] = -x4 * (-code);  a[62] = -x4 * (-code);
	a[7] =     0;  a[15] =     0;   a[23] = 0;  a[31] = -code;  a[39] = -code;  a[47] = 1;  a[55] = -y4 * (-code);  a[63] = -y4 * (-code);
	
#ifdef	DEBUG_CODE_CALCULATION
	printf("------------------------------------------->Data matrix\n");
	for (int i = 0; i < 8; i++)
		printf(" %3.5f,%3.5f, %3.5f, %3.5f,%3.5f,%3.5f, %3.5f, %3.5f\n", a[i], a[i+8], a[i+16], a[i+24], a[i+32], a[i+40], a[i+48], a[i+56]);
#endif
	
	b[0] = x1;
	b[1] = y1;
	b[2] = x2;
	b[3] = y2;
	b[4] = x3;
	b[5] = y3;
	b[6] = x4;
	b[7] = y4;
	
	int rank = 8;
	int nrhs = 1;
	int pivot[8];
	int info = 0;
	
	sgesv_((__CLPK_integer*)&rank, (__CLPK_integer*)&nrhs, (__CLPK_real*)a, (__CLPK_integer*)&rank, (__CLPK_integer*)pivot,(__CLPK_real*)b, (__CLPK_integer*)&rank, (__CLPK_integer*)&info);
	
	return (info == 0);	// check result of sgesv_
}

void _CRAdjustRotationOfHomographyMatrix(float *b, int rotation) {
	float b_temp[8];	// homography matrix
	
	memcpy(b_temp, b, sizeof(b_temp));
	
	if (rotation == TemplateOrientationUp) {
		b[0] =   b_temp[0];
		b[1] =   b_temp[1];
		
		b[3] =   b_temp[3];
		b[4] =   b_temp[4];
		
		b[6] =   b_temp[6];
		b[7] =   b_temp[7];
	}
	else if (rotation == TemplateOrientationRight) {
		b[0] =   b_temp[1];
		b[1] = - b_temp[0];
		
		b[3] =   b_temp[4];
		b[4] = - b_temp[3];
		
		b[6] =   b_temp[7];
		b[7] = - b_temp[6];
	}
	else if (rotation == TemplateOrientationDown) {
		b[0] = - b_temp[0];
		b[1] = - b_temp[1];
		
		b[3] = - b_temp[3];
		b[4] = - b_temp[4];
		
		b[6] = - b_temp[6];
		b[7] = - b_temp[7];
	}
	else if (rotation == TemplateOrientationLeft) {
		b[0] = - b_temp[1];
		b[1] =   b_temp[0];
		
		b[3] = - b_temp[4];
		b[4] =   b_temp[3];
		
		b[6] = - b_temp[7];
		b[7] =   b_temp[6];
	}
}

int _CRCheckBlackFrameAvailability(float *b, unsigned char* inputImgBaseAddress, int inputImgWidth, int inputImgHeight) {
    
    int frameCheckSize = 20;
    
    int counter = 0;
    int pixels = 0;
    
	float codeContentSize = 1.0;
	
	for (int i = 0; i < frameCheckSize; i++) {
		for (int j = 0; j < frameCheckSize/4; j++) {
			
			float normalizedX = 0;
			float normalizedY = 0;
			
			float ii = -codeContentSize * 0.5 + i * codeContentSize / (frameCheckSize - 1);
			float jj = -codeContentSize * 0.5 + j * codeContentSize / (frameCheckSize - 1);
			
			normalizedX = (b[0] * ii + b[1] * jj + b[2]) / (b[6] * ii + b[7] * jj + 1);
			normalizedY = (b[3] * ii + b[4] * jj + b[5]) / (b[6] * ii + b[7] * jj + 1);
			
			int x = normalizedX * CRGetXFocalLength() + inputImgWidth/2;
			int y = normalizedY * CRGetYFocalLength() + inputImgHeight/2;
			
			pixels++;
			
			if (x >= 0 && x < inputImgWidth && y < inputImgHeight && y >=0 ) {							
				if (inputImgBaseAddress[x + y * (int)inputImgWidth] < 120)
                    counter++;
			}
		}
	}
	for (int i = 0; i < frameCheckSize; i++) {
		for (int j = frameCheckSize/4*3; j < frameCheckSize; j++) {
			
			float normalizedX = 0;
			float normalizedY = 0;
			
			float ii = -codeContentSize * 0.5 + i * codeContentSize / (frameCheckSize - 1);
			float jj = -codeContentSize * 0.5 + j * codeContentSize / (frameCheckSize - 1);
			
			normalizedX = (b[0] * ii + b[1] * jj + b[2]) / (b[6] * ii + b[7] * jj + 1);
			normalizedY = (b[3] * ii + b[4] * jj + b[5]) / (b[6] * ii + b[7] * jj + 1);
			
			int x = normalizedX * CRGetXFocalLength() + inputImgWidth/2;
			int y = normalizedY * CRGetYFocalLength() + inputImgHeight/2;
			
			pixels++;
			
			if (x >= 0 && x < inputImgWidth && y < inputImgHeight && y >=0 ) {							
				if (inputImgBaseAddress[x + y * (int)inputImgWidth] < 120)
                    counter++;
			}
		}
	}
	
	for (int i = 0; i < frameCheckSize/4; i++) {
		for (int j = frameCheckSize/4; j < frameCheckSize/4*3; j++) {
			
			float normalizedX = 0;
			float normalizedY = 0;
			
			float ii = -codeContentSize * 0.5 + i * codeContentSize / (frameCheckSize - 1);
			float jj = -codeContentSize * 0.5 + j * codeContentSize / (frameCheckSize - 1);
			
			normalizedX = (b[0] * ii + b[1] * jj + b[2]) / (b[6] * ii + b[7] * jj + 1);
			normalizedY = (b[3] * ii + b[4] * jj + b[5]) / (b[6] * ii + b[7] * jj + 1);
			
			int x = normalizedX * CRGetXFocalLength() + inputImgWidth/2;
			int y = normalizedY * CRGetYFocalLength() + inputImgHeight/2;
			
			pixels++;
			
			if (x >= 0 && x < inputImgWidth && y < inputImgHeight && y >=0 ) {							
				if (inputImgBaseAddress[x + y * (int)inputImgWidth] < 120)
                    counter++;
			}
		}
	}
	
	for (int i = frameCheckSize/4*3; i < frameCheckSize; i++) {
		for (int j = frameCheckSize/4; j < frameCheckSize/4*3; j++) {
			
			float normalizedX = 0;
			float normalizedY = 0;
			
			float ii = -codeContentSize * 0.5 + i * codeContentSize / (frameCheckSize - 1);
			float jj = -codeContentSize * 0.5 + j * codeContentSize / (frameCheckSize - 1);
			
			normalizedX = (b[0] * ii + b[1] * jj + b[2]) / (b[6] * ii + b[7] * jj + 1);
			normalizedY = (b[3] * ii + b[4] * jj + b[5]) / (b[6] * ii + b[7] * jj + 1);
			
			int x = normalizedX * CRGetXFocalLength() + inputImgWidth/2;
			int y = normalizedY * CRGetYFocalLength() + inputImgHeight/2;
			
			pixels++;
			
			if (x >= 0 && x < inputImgWidth && y < inputImgHeight && y >=0 ) {							
				if (inputImgBaseAddress[x + y * (int)inputImgWidth] < 120)
                    counter++;
			}
		}
	}
    
    _dprintf("frame = %f\n", (float)counter/(float)pixels);
    
    return ((float)counter/(float)pixels > 0.9);
}

void _CRExtractAndCopyCodeImageToSharedBuffer(float *b, unsigned char* inputImgBaseAddress, int inputImgWidth, int inputImgHeight) {
	
	int decodePixelBuff = CRGetDecodePixelBuffWidthHeight();
	
	if (sharedPixelBufferForCodeImage == NULL) {
		sharedPixelBufferForCodeImage = (unsigned char*)malloc(sizeof(unsigned char) * decodePixelBuff * decodePixelBuff);
	}
	
	float codeContentSize = 0.5;
	
	for (int i = 0; i < decodePixelBuff; i++) {
		for (int j = 0; j < decodePixelBuff; j++) {
			
			float normalizedX = 0;
			float normalizedY = 0;
			
			float ii = -codeContentSize * 0.5 + i * codeContentSize / (decodePixelBuff - 1);
			float jj = -codeContentSize * 0.5 + j * codeContentSize / (decodePixelBuff - 1);
			
			normalizedX = (b[0] * ii + b[1] * jj + b[2]) / (b[6] * ii + b[7] * jj + 1);
			normalizedY = (b[3] * ii + b[4] * jj + b[5]) / (b[6] * ii + b[7] * jj + 1);
			
			int x = normalizedX * CRGetXFocalLength() + inputImgWidth/2;
			int y = normalizedY * CRGetYFocalLength() + inputImgHeight/2;
			
			if (x >= 0 && x < inputImgWidth && y < inputImgHeight && y >=0 ) {
				sharedPixelBufferForCodeImage[i + j * decodePixelBuff] = inputImgBaseAddress[x + y * (int)inputImgWidth];
			}
		}
	}
}

void _CRGetDefectivePMatrixFromHomographyMatrix(float *b, float *pmat) {
	float ez[3];
	
	_CRNormalizeVec(&b[0], &b[3], &b[6]);
	_CRNormalizeVec(&b[1], &b[4], &b[7]);
	
	_CROuterProductVec(b[0], b[3], b[6], b[1], b[4], b[7], &ez[0], &ez[1], &ez[2]);
	
	pmat[0] = b[0]; pmat[4] = b[1]; pmat[ 8] = ez[0]; pmat[12] = b[2]; 
	pmat[1] = b[3]; pmat[5] = b[4]; pmat[ 9] = ez[1]; pmat[13] = b[5]; 
	pmat[2] = b[6]; pmat[6] = b[7]; pmat[10] = ez[2]; pmat[14] = 1; 
	pmat[3] = 0;    pmat[7] = 0;    pmat[11] = 0;     pmat[15] = 1;
}

void _CRCalculateTranslationParameter(float *ez, float *pmat, CRCorner *c1, CRCorner *c3, float codeSize, int inputImgWidth, int inputImgHeight) {
	float a;
	float v[3];
	float s1, s3;
	float length;
	
	float p1_x = (c1->x - inputImgWidth/2) / CRGetXFocalLength();
	float p1_y = (c1->y - inputImgHeight/2) / CRGetYFocalLength();
	float p1_z = 1;
	
	float p3_x = (c3->x - inputImgWidth/2) / CRGetXFocalLength();
	float p3_y = (c3->y - inputImgHeight/2) / CRGetYFocalLength();
	float p3_z = 1;
	
	a = (p3_x * pmat[8] + p3_y * pmat[9] + p3_z * pmat[10]) / (p1_x * pmat[8] + p1_y * pmat[9] + p1_z * pmat[10]);
	
	v[0] = a * p1_x - p3_x;
	v[1] = a * p1_y - p3_y;
	v[2] = a * p1_z - p3_z;
	
	length = sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
	
	s3 = codeSize * sqrt(2) / length;
	s1 = a * s3;
	
	ez[0] = s1 * 0.5 * p1_x + s3 * 0.5 * p3_x;
	ez[1] = s1 * 0.5 * p1_y + s3 * 0.5 * p3_y;
	ez[2] = s1 * 0.5 * p1_z + s3 * 0.5 * p3_z;
}

void _CRAdjustTranslationParameterOfPMatrixOf2DCode(float *pmat, CRCorner *c, float codeSize, int inputImgWidth, int inputImgHeight) {
	float ez1[3];
	float ez2[3];
	
	_CRCalculateTranslationParameter(ez1, pmat, &c[0], &c[2], codeSize, inputImgWidth, inputImgHeight);
	_CRCalculateTranslationParameter(ez2, pmat, &c[1], &c[3], codeSize, inputImgWidth, inputImgHeight);
	
	pmat[12] = (ez1[0] + ez2[0])*0.5;
	pmat[13] = (ez1[1] + ez2[1])*0.5;
	pmat[14] = (ez1[2] + ez2[2])*0.5;	
}

int _CRChainCodeExtract4Corners(CRChainCode *chaincode, CRChainCodeElement **c) {
	CRChainCodeElement *p = (chaincode)->head;
	
	int corner_count = 0;
	p = (chaincode)->head;
	if (p) {
		while (1) {
			if (p->flag == 1) {
				if (corner_count < 4) {
					c[corner_count] = p;
				}
				corner_count++;
			}
			if (p->next == chaincode->head)
				break;
			p = p->next;
		}
	}
	
	if (corner_count != 4)
		return 1;
	
	if (!_CRIs4CornersConvex(c))
		return 1;
	
//	_dprintf(" %d,%d\n", c[0]->x, c[0]->y);
//	_dprintf(" %d,%d\n", c[1]->x, c[1]->y);
//	_dprintf(" %d,%d\n", c[2]->x, c[2]->y);
//	_dprintf(" %d,%d\n", c[3]->x, c[3]->y);
	
	return 0;
}

#pragma mark -
#pragma mark Global parameters

int CRGetDecodePixelBuffWidthHeight() {
	return decodePixelBuffWidthHeight;
}

void CRSetDecodePixelBuffWidthHeight(int newValue) {
	decodePixelBuffWidthHeight = newValue;
}

float CRGetXFocalLength() {
	return XFocalLength;
}

void CRSetXFocalLength(float newValue) {
	XFocalLength = newValue;
}

float CRGetYFocalLength() {
	return YFocalLength;
}

void CRSetYFocalLength(float newValue) {
	YFocalLength = newValue;
}

#pragma mark -
#pragma mark CodeInfo

CRCodeInfo *CRCreateCodeInfo() {
	CRCodeInfo *p = (CRCodeInfo*)malloc(sizeof(CRCodeInfo));
	p->pixel = (unsigned char*)malloc(sizeof(unsigned char) * CRGetDecodePixelBuffWidthHeight() * CRGetDecodePixelBuffWidthHeight());
	p->identifier = 0;
	memset(p->corner_x, 0, sizeof(int) * 4);
	memset(p->corner_y, 0, sizeof(int) * 4);
	p->next = NULL;
	p->prev = NULL;
	return p;
}

void CRReleaseCodeInfo(CRCodeInfo **codeinfo) {
	free(*codeinfo);
	*codeinfo = NULL;
}

void CRCodeInfoDumpMatrix(CRCodeInfo *codeinfo) {
	printf(" %f,%f,%f,%f;\n", codeinfo->p[0], codeinfo->p[4], codeinfo->p[8], codeinfo->p[12]);
	printf(" %f,%f,%f,%f;\n", codeinfo->p[1], codeinfo->p[5], codeinfo->p[9], codeinfo->p[13]);
	printf(" %f,%f,%f,%f;\n", codeinfo->p[2], codeinfo->p[6], codeinfo->p[10], codeinfo->p[14]);
	printf(" %f,%f,%f,%f;\n\n", codeinfo->p[3], codeinfo->p[7], codeinfo->p[11], codeinfo->p[15]);
}

CRCodeInfo* CRCreateCodeInfoByParsingChainCode(CRChainCode *chaincode, unsigned char *inputImgBaseAddress, int inputImgWidth, int inputImgHeight, CRCodeImageTemplateStorage* codeImageTemplateStorage) {	
	CRCorner c[4];
	
	if (chaincode->length < 40) {
		return NULL;
	}
	
	float w = abs(chaincode->left - chaincode->right);
	float h = abs(chaincode->top - chaincode->bottom);
	
	if (w < MINIMUM_CIRCUMSCRIBED_SIZE) {
		return NULL;
	}
	
	if (h < MINIMUM_CIRCUMSCRIBED_SIZE) {
		return NULL;
	}
	
	if (w > h) {
		if ( w / h > 4)
			return NULL;
	}
	else {
		if ( h / w > 4)
			return NULL;
	}

	if (chaincode->isCornerDetected == CR_FALSE) {
		return NULL;
	}
	
	for (int i = 0; i < 4; i++) {
		c[i].x = chaincode->cornersX[i];
		c[i].y = chaincode->cornersY[i];
	}
	
	float b[8];			// homography matrix
	
	if (!_CRGetHomographyMatrix(b, c, inputImgWidth, inputImgHeight)) {
		return NULL;
	}
	
	if (!_CRCheckBlackFrameAvailability(b, inputImgBaseAddress, inputImgWidth, inputImgHeight)) {
		return NULL;
	}
	
	int decodePixelBuff = CRGetDecodePixelBuffWidthHeight();
	
	_CRExtractAndCopyCodeImageToSharedBuffer(b, inputImgBaseAddress, inputImgWidth, inputImgHeight);
	
	int codeID = -1;
	int rotation = -1;
	float codeSize = -1;
	
	if (codeImageTemplateStorage)
		CRCodeImageTemplateStorageEvaluateCodeImage(codeImageTemplateStorage, sharedPixelBufferForCodeImage, decodePixelBuff, decodePixelBuff, &codeID, &rotation);
	
	if (codeID == -1 || rotation == -1) {
        CRCodeInfo *info = CRCreateCodeInfo();
        info->identifier = -1;
        info->size = -1;
        info->corner_x[0] = c[0].x;
        info->corner_x[1] = c[1].x;
        info->corner_x[2] = c[2].x;
        info->corner_x[3] = c[3].x;
        info->corner_y[0] = c[0].y;
        info->corner_y[1] = c[1].y;
        info->corner_y[2] = c[2].y;
        info->corner_y[3] = c[3].y;
        info->left = chaincode->left;
        info->right = chaincode->right;
        info->top = chaincode->top;
        info->bottom = chaincode->bottom;
        memcpy(info->pixel, sharedPixelBufferForCodeImage, decodePixelBuff * decodePixelBuff);
		return info;
	}
	
	codeSize = CRCodeImageTemplateStorageGetSizeOfCodeID(codeImageTemplateStorage, codeID);
	if (codeSize < 0) {
		return NULL;
	}
	
#ifdef DEBUG_CODE_CALCULATION
	_dprintf("------------------------------------------->Homography matrix(non revised)\n");
	_dprintf(" %f,%f,%f,%f\n", b[0], b[1], b[2], b[3]);
	_dprintf(" %f,%f,%f,0\n", b[4], b[5], b[6]);
#endif
	
	_CRAdjustRotationOfHomographyMatrix(b, rotation);
	
#ifdef DEBUG_CODE_CALCULATION
	_dprintf("------------------------------------------->Homography matrix\n");
	_dprintf(" %f,%f,%f,%f\n", b[0], b[1], b[2], b[3]);
	_dprintf(" %f,%f,%f,0\n", b[4], b[5], b[6]);
#endif
	
	float pmat[16];
	
	_CRGetDefectivePMatrixFromHomographyMatrix(b, pmat);
	
	// adjust translation parameter
	_CRAdjustTranslationParameterOfPMatrixOf2DCode(pmat, c, codeSize, inputImgWidth, inputImgHeight);
	
#ifdef DEBUG_CODE_CALCULATION
	_dprintf("------------------------------------------->P matrix\n");
	_dprintf(" %f,%f,%f,%f\n", pmat[0], pmat[4], pmat[8], pmat[12]);
	_dprintf(" %f,%f,%f,%f\n", pmat[1], pmat[5], pmat[9], pmat[13]);
	_dprintf(" %f,%f,%f,%f\n", pmat[2], pmat[6], pmat[10], pmat[14]);
	_dprintf(" %f,%f,%f,%f\n", pmat[3], pmat[7], pmat[11], pmat[15]);
#endif
	
	// check whether code image bas been registered.
	CRCodeInfo *info = CRCreateCodeInfo();
	
	info->identifier = codeID;
	info->size = codeSize;
	
#ifdef DEBUG_CODE_CALCULATION
	// copy code content for debug
#ifdef SAVE_CODE_IMAGE
	memcpy(info->pixel, sharedPixelBufferForCodeImage, DECODE_PIXEL_BUFFER * DECODE_PIXEL_BUFFER);
#endif
#endif
	
	// save p matrix
	memcpy(info->p, pmat, sizeof(float) * 16);
	
	return info;
}

#pragma mark -
#pragma mark CodeInfoStorage

CRCodeInfoStorage *CRCreateCodeInfoStorage() {
	CRCodeInfoStorage *storage = (CRCodeInfoStorage*)malloc(sizeof(CRCodeInfoStorage));
	storage->head = NULL;
	storage->tail = NULL;
	storage->length = 0;
	return storage;
}

void CRCodeInfoStorageReleaseAllCodeInfo(CRCodeInfoStorage *storage) {
	if (storage) {
	CRCodeInfo *p = (storage)->head;
	if (p) {
		while (1) {
			CRCodeInfo *next = p->next;
			CRReleaseCodeInfo(&p);
			if (next == NULL)
				break;
			p = next;
		}
	}
	storage->head = NULL;
	storage->tail = NULL;
	storage->length = 0;
	}
}

void CRReleaseCodeInfoStorage(CRCodeInfoStorage **storage) {
	if (*storage == NULL)
		return;

	CRCodeInfo *p = (*storage)->head;
	if (p) {
		while (1) {
			CRCodeInfo *next = p->next;
			CRReleaseCodeInfo(&p);
			if (next == NULL)
				break;
			p = next;
		}
	}
	free(*storage);
	*storage = NULL;
}


void CRCodeInfoStorageAddCodeInfo(CRCodeInfo *newCodeInfo, CRCodeInfoStorage *storage) {
	if (storage->head == NULL)
		storage->head = newCodeInfo;
	if (storage->tail == NULL)
		storage->tail = newCodeInfo;
	else  {
		storage->tail->next = newCodeInfo;
		newCodeInfo->prev = storage->tail;
		storage->tail = newCodeInfo;
	}
	storage->length++;
}

void CRCodeInfoStorageAddCodeInfoByExtractingFromChainCode(CRCodeInfoStorage *codeInfoStorage, CRChainCodeStorage *storage, unsigned char *inputImgBaseAddress, int inputImgWidth, int inputImgHeight, CRCodeImageTemplateStorage* codeImageTemplateStorage) {
	CRChainCode *p = storage->head;
	
	if (p) {
		while (1) {
			CRCodeInfo *newCodeInfo = CRCreateCodeInfoByParsingChainCode(p, inputImgBaseAddress, inputImgWidth, inputImgHeight, codeImageTemplateStorage);
//			_dprintf("length-%d, %d<->%d %d<->%d\n", p->length, p->left, p->right, p->top, p->bottom);
			if (newCodeInfo) {
				CRCodeInfoStorageAddCodeInfo(newCodeInfo, codeInfoStorage);		
			}
			if (p->next == NULL)
				break;
			p = p->next;
		}
	}
}

CRCodeInfoStorage* CRCreateCodeInfoStorageByExtractingFromChainCodeStorage(CRChainCodeStorage *storage, unsigned char *inputImgBaseAddress, int inputImgWidth, int inputImgHeight, CRCodeImageTemplateStorage* codeImageTemplateStorage) {
	
	CRChainCode *p = storage->head;
	
	CRCodeInfoStorage *codeInfoStorage = CRCreateCodeInfoStorage();
	
	if (p) {
		while (1) {
			CRCodeInfo *newCodeInfo = CRCreateCodeInfoByParsingChainCode(p, inputImgBaseAddress, inputImgWidth, inputImgHeight, codeImageTemplateStorage);
//			_dprintf("length-%d, %d<->%d %d<->%d\n", p->length, p->left, p->right, p->top, p->bottom);
			if (newCodeInfo) {
				CRCodeInfoStorageAddCodeInfo(newCodeInfo, codeInfoStorage);		
			}
			if (p->next == NULL)
				break;
			p = p->next;
		}
	}
	
	return codeInfoStorage;
}
