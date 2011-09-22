/*
 * Core AR
 * CRCode.cpp
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

#include "CRCode.h"

#include <math.h>

#include "CRCommon.h"
#include "CRLevenbergMarquardt.h"

#include "CRTest.h"

CRCode::CRCode() {
	corners = new CRHomogeneousVec3 [4];
	this->firstCorner  = corners + 0;
	this->secondCorner = corners + 1;
	this->thirdCorner  = corners + 2;
	this->fourthCorner = corners + 3;
	
	croppedCodeImage = NULL;
}

void CRCode::normalizeCornerForImageCoord(float width, float height, float focalX, float focalY) {
	for (int i = 0; i < 4; i++) {
		(corners + i)->normalize();
		(corners + i)->x -= (float)width/2;
		(corners + i)->x /= (float)focalX;
		(corners + i)->y -= (float)height/2;
		(corners + i)->y /= (float)focalY;
	}
}

void CRCode::dumpCorners() {
	printf("Corners\n");
	printf("%+7.2f %+7.2f %+7.2f %+7.2f\n", (corners+0)->x, (corners+1)->x, (corners+2)->x, (corners+3)->x);
	printf("%+7.2f %+7.2f %+7.2f %+7.2f\n", (corners+0)->y, (corners+1)->y, (corners+2)->y, (corners+3)->y);
	printf("%+7.2f %+7.2f %+7.2f %+7.2f\n\n", (corners+0)->w, (corners+1)->w, (corners+2)->w, (corners+3)->w);
}

void CRCode::dumpMatrix() {
	printf("Matrix\n");
	printf("%+7.2f %+7.2f %+7.2f %+7.2f;\n", matrixGL[ 0], matrixGL[ 4], matrixGL[ 8], matrixGL[12]);
	printf("%+7.2f %+7.2f %+7.2f %+7.2f;\n", matrixGL[ 1], matrixGL[ 5], matrixGL[ 9], matrixGL[13]);
	printf("%+7.2f %+7.2f %+7.2f %+7.2f;\n", matrixGL[ 2], matrixGL[ 6], matrixGL[10], matrixGL[14]);
	printf("%+7.2f %+7.2f %+7.2f %+7.2f;\n\n", matrixGL[ 3], matrixGL[ 7], matrixGL[11], matrixGL[15]);
}

void CRCode::dumpOptimizedMatrix() {
	printf("Optimized matrix\n");
	printf("%+7.2f %+7.2f %+7.2f %+7.2f;\n", optimizedMatrixGL[ 0], optimizedMatrixGL[ 4], optimizedMatrixGL[ 8], optimizedMatrixGL[12]);
	printf("%+7.2f %+7.2f %+7.2f %+7.2f;\n", optimizedMatrixGL[ 1], optimizedMatrixGL[ 5], optimizedMatrixGL[ 9], optimizedMatrixGL[13]);
	printf("%+7.2f %+7.2f %+7.2f %+7.2f;\n", optimizedMatrixGL[ 2], optimizedMatrixGL[ 6], optimizedMatrixGL[10], optimizedMatrixGL[14]);
	printf("%+7.2f %+7.2f %+7.2f %+7.2f;\n\n", optimizedMatrixGL[ 3], optimizedMatrixGL[ 7], optimizedMatrixGL[11], optimizedMatrixGL[15]);
}

void CRCode::dumpHomography() {
	printf("Homography\n");
	printf("%+7.2f %+7.2f %+7.2f;\n", homography[0][0], homography[0][1], homography[0][2]);
	printf("%+7.2f %+7.2f %+7.2f;\n", homography[1][0], homography[1][1], homography[1][2]);
	printf("%+7.2f %+7.2f %+7.2f;\n\n", homography[2][0], homography[2][1], homography[2][2]);
}

void CRCode::crop(float croppingWidth, float croppingHeight, float focalX, float focalY, float codeSize, unsigned char *source, int width, int height) {
	
	croppedCodeImageWidth = croppingWidth;
	croppedCodeImageHeight = croppingHeight;
	
	SAFE_FREE(croppedCodeImage);
	croppedCodeImage = (unsigned char*)malloc(sizeof(unsigned char) * croppedCodeImageWidth * croppedCodeImageHeight);
	
	for (int i = 0; i < croppedCodeImageWidth; i++) {
		for (int j = 0; j < croppedCodeImageHeight; j++) {
			float ii = codeSize * 0.25 + 0.5 * i * codeSize / (croppedCodeImageWidth - 1);
			float jj = codeSize * 0.25 + 0.5 * j * codeSize / (croppedCodeImageHeight - 1);
			
			float normalizedX = (homography[0][0] * ii + homography[0][1] * jj + homography[0][2]) / (homography[2][0] * ii + homography[2][1] * jj + 1);
			float normalizedY = (homography[1][0] * ii + homography[1][1] * jj + homography[1][2]) / (homography[2][0] * ii + homography[2][1] * jj + 1);
			
			int x = normalizedX * focalX + width/2;
			int y = normalizedY * focalY + height/2;
			
			if (x >= 0 && x < width && y < height && y >=0 ) {
				croppedCodeImage[i + j * croppedCodeImageWidth] = source[x + y * (int)width];
			}
		}
	}
}

void CRCode::optimizeRTMatrinxWithLevenbergMarquardtMethod() {
	float lambda = 0.004;
	float theshold = 0.0001;
	
	float initial_p[6];
	
	CRRTMatrix2Parameters(initial_p, this->matrix);
	
	float codeSize = 1;
	
	float error[8];
	float jacobian[8][6];
	float hessian[6][6];
	
	float delta_param[6];
	
	CRGetCurrentErrorAndJacobian(jacobian, hessian, error, initial_p, this, codeSize);
	
	float c = CRSumationOfSquaredVec8(error);
	
	for (int i = 0; i < 100; i++) {
		float p_temp[6];
		
		CRGetDeltaParameter(delta_param, jacobian, hessian, error, lambda);
		
		p_temp[0] = initial_p[0] + delta_param[0];
		p_temp[1] = initial_p[1] + delta_param[1];
		p_temp[2] = initial_p[2] + delta_param[2];
		p_temp[3] = initial_p[3] + delta_param[3];
		p_temp[4] = initial_p[4] + delta_param[4];
		p_temp[5] = initial_p[5] + delta_param[5];
		
		float error_dash[8];
		
		CRGetCurrentErrorAndJacobian(NULL, NULL, error_dash, p_temp, this, codeSize);
		
		float c_dash = CRSumationOfSquaredVec8(error_dash);
		
		_DPRINTF("Error=%+7.5f\n", c_dash);
		
		if (c_dash > c) {
			lambda *= 10;
		}
		else {
			lambda /= 10;
			c = c_dash;
			initial_p[0] = p_temp[0];
			initial_p[1] = p_temp[1];
			initial_p[2] = p_temp[2];
			initial_p[3] = p_temp[3];
			initial_p[4] = p_temp[4];
			initial_p[5] = p_temp[5];
			float delta = CRSumationOfSquaredVec6(delta_param);
			
			if (delta < theshold) {
				_DPRINTF("Last error=%+7.2f, iteration times=%d\n\n", c_dash, i);
				break;
			}
			CRGetCurrentErrorAndJacobian(jacobian, hessian, error, initial_p, this, codeSize);
		}
	}
	
	CRParameters2RTMatrix(initial_p, this->optimizedMatrix);
	
	optimizedMatrixGL[ 0] = optimizedMatrix[0][0];	optimizedMatrixGL[ 4] = optimizedMatrix[0][1];	optimizedMatrixGL[ 8] = optimizedMatrix[0][2];	optimizedMatrixGL[12] = optimizedMatrix[0][3];
	optimizedMatrixGL[ 1] = optimizedMatrix[1][0];	optimizedMatrixGL[ 5] = optimizedMatrix[1][1];	optimizedMatrixGL[ 9] = optimizedMatrix[1][2];	optimizedMatrixGL[13] = optimizedMatrix[1][3];
	optimizedMatrixGL[ 2] = optimizedMatrix[2][0];	optimizedMatrixGL[ 6] = optimizedMatrix[2][1];	optimizedMatrixGL[10] = optimizedMatrix[2][2];	optimizedMatrixGL[14] = optimizedMatrix[2][3];
	optimizedMatrixGL[ 3] = optimizedMatrix[3][0];	optimizedMatrixGL[ 7] = optimizedMatrix[3][1];	optimizedMatrixGL[11] = optimizedMatrix[3][2];	optimizedMatrixGL[15] = optimizedMatrix[3][3];
}

int CRCode::_CRGetHomographyMatrix() {
	
	float x1 = (corners + 0)->x;
	float y1 = (corners + 0)->y;
	float x2 = (corners + 1)->x;
	float y2 = (corners + 1)->y;
	float x3 = (corners + 2)->x;
	float y3 = (corners + 2)->y;
	float x4 = (corners + 3)->x;
	float y4 = (corners + 3)->y;
	

	float a[64];
	float b[8];
	
	float code = 0.5;
	
	a[0] = -code;  a[ 8] =  code;   a[16] = 1;  a[24] =     0;  a[32] =     0;  a[40] = 0;  a[48] = -x1 * (-code);  a[56] = -x1 * ( code);
	a[1] =     0;  a[ 9] =     0;   a[17] = 0;  a[25] = -code;  a[33] =  code;  a[41] = 1;  a[49] = -y1 * (-code);  a[57] = -y1 * ( code);
	
	a[2] =  code;  a[10] =  code;   a[18] = 1;  a[26] =     0;  a[34] =     0;  a[42] = 0;  a[50] = -x2 * ( code);  a[58] = -x2 * ( code);
	a[3] =     0;  a[11] =     0;   a[19] = 0;  a[27] =  code;  a[35] =  code;  a[43] = 1;  a[51] = -y2 * ( code);  a[59] = -y2 * ( code);
	
	a[4] =  code;  a[12] = -code;   a[20] = 1;  a[28] =    0;   a[36] =     0;  a[44] = 0;  a[52] = -x3 * ( code);  a[60] = -x3 * (-code);
	a[5] =     0;  a[13] =     0;   a[21] = 0;  a[29] =  code;  a[37] = -code;  a[45] = 1;  a[53] = -y3 * ( code);  a[61] = -y3 * (-code);
	
	a[6] = -code;  a[14] = -code;   a[22] = 1;  a[30] =     0;  a[38] =     0;  a[46] = 0;  a[54] = -x4 * (-code);  a[62] = -x4 * (-code);
	a[7] =     0;  a[15] =     0;   a[23] = 0;  a[31] = -code;  a[39] = -code;  a[47] = 1;  a[55] = -y4 * (-code);  a[63] = -y4 * (-code);
	
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
	
	printf("Old homography\n");
	printf("%+7.2f %+7.2f %+7.2f;\n", b[0], b[1], b[2]);
	printf("%+7.2f %+7.2f %+7.2f;\n", b[3], b[4], b[5]);
	printf("%+7.2f %+7.2f 1;\n\n", b[6], b[7]);
	
	homography[0][0] = b[0];
	homography[1][0] = b[3];
	homography[2][0] = b[6];
	
	homography[0][1] = b[1];
	homography[1][1] = b[4];
	homography[2][1] = b[7];
	
	homography[0][2] = b[2];
	homography[1][2] = b[5];
	homography[2][2] = 1;
	
	float scale = 1;
	
	float e1_length = homography[0][0] * homography[0][0] + homography[1][0] * homography[1][0] + homography[2][0] * homography[2][0];
	float e2_length = homography[0][1] * homography[0][1] + homography[1][1] * homography[1][1] + homography[2][1] * homography[2][1];
	e1_length = sqrtf(e1_length);
	e2_length = sqrtf(e2_length);
	float length = (e1_length + e2_length) * 0.5;
	
	matrix[0][0] = homography[0][0] / e1_length;
	matrix[1][0] = homography[1][0] / e1_length;
	matrix[2][0] = homography[2][0] / e1_length;
	matrix[3][0] = 0;
	
	matrix[0][1] = homography[0][1] / e2_length;
	matrix[1][1] = homography[1][1] / e2_length;
	matrix[2][1] = homography[2][1] / e2_length;
	matrix[3][1] = 0;
	
	matrix[0][2] = matrix[2][0] * matrix[1][1] - matrix[1][0] * matrix[2][1];
	matrix[1][2] = matrix[2][0] * matrix[0][1] - matrix[0][0] * matrix[2][1];
	matrix[2][2] = matrix[0][0] * matrix[1][1] - matrix[1][0] * matrix[0][1];
	matrix[3][2] = 0;
	
	matrix[0][3] = homography[0][2] / length * scale;
	matrix[1][3] = homography[1][2] / length * scale;
	matrix[2][3] = homography[2][2] / length * scale;
	matrix[3][3] = 1;
	
	matrixGL[ 0] = matrix[0][0];	matrixGL[ 4] = matrix[0][1];	matrixGL[ 8] = matrix[0][2];	matrixGL[12] = matrix[0][3];
	matrixGL[ 1] = matrix[1][0];	matrixGL[ 5] = matrix[1][1];	matrixGL[ 9] = matrix[1][2];	matrixGL[13] = matrix[1][3];
	matrixGL[ 2] = matrix[2][0];	matrixGL[ 6] = matrix[2][1];	matrixGL[10] = matrix[2][2];	matrixGL[14] = matrix[2][3];
	matrixGL[ 3] = matrix[3][0];	matrixGL[ 7] = matrix[3][1];	matrixGL[11] = matrix[3][2];	matrixGL[15] = matrix[3][3];
	
	return (info == 0);	// check result of sgesv_
}

void CRCode::getSimpleHomography(float scale) {
	float h[8];
	float uv[2][4];
	
	for (int i = 0; i < 4; i++) {
		uv[0][i] = (corners + i)->x;
		uv[1][i] = (corners + i)->y;
	}
	
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
		
	float e1_length = homography[0][0] * homography[0][0] + homography[1][0] * homography[1][0] + homography[2][0] * homography[2][0];
	float e2_length = homography[0][1] * homography[0][1] + homography[1][1] * homography[1][1] + homography[2][1] * homography[2][1];
	e1_length = sqrtf(e1_length);
	e2_length = sqrtf(e2_length);
	float length = (e1_length + e2_length) * 0.5;
	
	matrix[0][0] = homography[0][0] / e1_length;
	matrix[1][0] = homography[1][0] / e1_length;
	matrix[2][0] = homography[2][0] / e1_length;
	matrix[3][0] = 0;
	
	matrix[0][1] = homography[0][1] / e2_length;
	matrix[1][1] = homography[1][1] / e2_length;
	matrix[2][1] = homography[2][1] / e2_length;
	matrix[3][1] = 0;
	
	matrix[0][2] = matrix[1][0] * matrix[2][1] - matrix[2][0] * matrix[1][1];
	matrix[1][2] = matrix[2][0] * matrix[0][1] - matrix[0][0] * matrix[2][1];
	matrix[2][2] = matrix[0][0] * matrix[1][1] - matrix[1][0] * matrix[0][1];
	matrix[3][2] = 0;
	
	matrix[0][3] = homography[0][2] / length * scale;
	matrix[1][3] = homography[1][2] / length * scale;
	matrix[2][3] = homography[2][2] / length * scale;
	matrix[3][3] = 1;
	
	matrixGL[ 0] = matrix[0][0];	matrixGL[ 4] = matrix[0][1];	matrixGL[ 8] = matrix[0][2];	matrixGL[12] = matrix[0][3];
	matrixGL[ 1] = matrix[1][0];	matrixGL[ 5] = matrix[1][1];	matrixGL[ 9] = matrix[1][2];	matrixGL[13] = matrix[1][3];
	matrixGL[ 2] = matrix[2][0];	matrixGL[ 6] = matrix[2][1];	matrixGL[10] = matrix[2][2];	matrixGL[14] = matrix[2][3];
	matrixGL[ 3] = matrix[3][0];	matrixGL[ 7] = matrix[3][1];	matrixGL[11] = matrix[3][2];	matrixGL[15] = matrix[3][3];
}

CRCode::CRCode(CRHomogeneousVec3 *firstCorner, CRHomogeneousVec3 *secondCorner, CRHomogeneousVec3 *thirdCorner, CRHomogeneousVec3 *fourthCorner) {
	corners = new CRHomogeneousVec3 [4];
	
	(corners + 0)->x = firstCorner->x;
	(corners + 0)->y = firstCorner->y;
	(corners + 0)->w = firstCorner->w;
	
	(corners + 1)->x = secondCorner->x;
	(corners + 1)->y = secondCorner->y;
	(corners + 1)->w = secondCorner->w;
	
	(corners + 2)->x = thirdCorner->x;
	(corners + 2)->y = thirdCorner->y;
	(corners + 2)->w = thirdCorner->w;
	
	(corners + 3)->x = fourthCorner->x;
	(corners + 3)->y = fourthCorner->y;
	(corners + 3)->w = fourthCorner->w;
	
	this->firstCorner  = corners + 0;
	this->secondCorner = corners + 1;
	this->thirdCorner  = corners + 2;
	this->fourthCorner = corners + 3;
	
	croppedCodeImage = NULL;
}

CRCode::~CRCode() {
	SAFE_FREE(croppedCodeImage);
	SAFE_DELETE_ARRAY(corners);
}
