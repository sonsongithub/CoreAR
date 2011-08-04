/*
 * Core AR
 * levenbergMartquerdt
 *
 * Copyright (c) Yuichi YOSHIDA, 11/08/04.
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

#include "CRChainCode.h"
#include "CRHomogeneousVec3.h"
#include "CRTest.h"
#include "CRRodrigues.h"
#include "CRTest.h"

#include <Accelerate/Accelerate.h>

void CRRTMatrix2Parameters(float *param, float matrix[4][4]) {
	CRRodriguesMatrix4x42R(param, matrix);
	param[3] = matrix[0][3];
	param[4] = matrix[1][3];
	param[5] = matrix[2][3];
}

void CRParameters2RTMatrix(float *param, float matrix[4][4]) {
	CRRodriguesR2Matrix4x4(param, matrix);
	matrix[0][3] = param[3];
	matrix[1][3] = param[4];
	matrix[2][3] = param[5];
	matrix[3][0] = 0;
	matrix[3][1] = 0;
	matrix[3][2] = 0;
	matrix[3][3] = 1;
}

void CRGetJacobian(float jacobian[8][6], float pointsHomo[3][4], float originalPoint[4][4], float *param) {
	
	float m2[2][3];
	float m3[3][3];
	float m4[3][3];
	float m5[3][3];
	float m6[2][3];
	
	CRRodriguesR2Matrix(param, m3);
	
	for (int num = 0; num < 4; num++) {
		m2[0][0] = -1/pointsHomo[2][num];	m2[0][1] =                    0;	m2[0][2] =  pointsHomo[0][num]/pointsHomo[2][num]/pointsHomo[2][num];
		m2[1][0] =					  0;	m2[1][1] = -1/pointsHomo[2][num];	m2[1][2] =  pointsHomo[1][num]/pointsHomo[2][num]/pointsHomo[2][num];
		
		m4[0][0] =                      0;	m4[0][1] =  originalPoint[2][num];	m4[0][2] = -originalPoint[1][num];
		m4[1][0] = -originalPoint[2][num];	m4[1][1] =                      0;	m4[1][2] =  originalPoint[0][num];
		m4[2][0] =  originalPoint[1][num];	m4[2][1] = -originalPoint[0][num];	m4[2][2] =  0;
		
		
		_CRTestMultiMat3x3Mat3x3(m5, m3, m4);
		_CRTestMultiMat2x3Mat3x3(m6, m2, m5);
		
		jacobian[num*2  ][0] = m6[0][0];	jacobian[num*2  ][1] = m6[0][1];	jacobian[num*2  ][2] = m6[0][2];
		jacobian[num*2+1][0] = m6[1][0];	jacobian[num*2+1][1] = m6[1][1];	jacobian[num*2+1][2] = m6[1][2];
		
		jacobian[num*2  ][3] = m2[0][0];	jacobian[num*2  ][4] = m2[0][1];	jacobian[num*2  ][5] = m2[0][2];
		jacobian[num*2+1][3] = m2[1][0];	jacobian[num*2+1][4] = m2[1][1];	jacobian[num*2+1][5] = m2[1][2];
	}
}

void CRGetCurrentErrorAndJacobian(float jacobian[8][6], float *param, CRCode *gtCode, float *error) {
	float points[2][4];
	float pointsHomo[3][4];
	
	float originalPoint[4][4];
	
	float rt[4][4];
	CRParameters2RTMatrix(param, rt);
	
	originalPoint[0][0] =  0;	originalPoint[0][1] =  1;	originalPoint[0][2] =  1;	originalPoint[0][3] =  0;
	originalPoint[1][0] =  0;	originalPoint[1][1] =  0;	originalPoint[1][2] =  1;	originalPoint[1][3] =  1;
	originalPoint[2][0] =  0;	originalPoint[2][1] =  0;	originalPoint[2][2] =  0;	originalPoint[2][3] =  0;
	originalPoint[3][0] =  1;	originalPoint[3][1] =  1;	originalPoint[3][2] =  1;	originalPoint[3][3] =  1;
	
	for (int i = 0; i < 3; i++) {
		pointsHomo[i][0] = rt[i][0] * originalPoint[0][0] + rt[i][1] * originalPoint[1][0] + rt[i][2] * originalPoint[2][0] + rt[i][3] * originalPoint[3][0];
		pointsHomo[i][1] = rt[i][0] * originalPoint[0][1] + rt[i][1] * originalPoint[1][1] + rt[i][2] * originalPoint[2][1] + rt[i][3] * originalPoint[3][1];
		pointsHomo[i][2] = rt[i][0] * originalPoint[0][2] + rt[i][1] * originalPoint[1][2] + rt[i][2] * originalPoint[2][2] + rt[i][3] * originalPoint[3][2];
		pointsHomo[i][3] = rt[i][0] * originalPoint[0][3] + rt[i][1] * originalPoint[1][3] + rt[i][2] * originalPoint[2][3] + rt[i][3] * originalPoint[3][3];
	}
	
	for (int i = 0; i < 4; i++) {
		points[0][i] = pointsHomo[0][i] / pointsHomo[2][i];
		points[1][i] = pointsHomo[1][i] / pointsHomo[2][i];
	}
	
	error[0] = (gtCode->corners + 0)->x - points[0][0];
	error[1] = (gtCode->corners + 0)->y - points[1][0];
	error[2] = (gtCode->corners + 1)->x - points[0][1];
	error[3] = (gtCode->corners + 1)->y - points[1][1];
	error[4] = (gtCode->corners + 2)->x - points[0][2];
	error[5] = (gtCode->corners + 2)->y - points[1][2];
	error[6] = (gtCode->corners + 3)->x - points[0][3];
	error[7] = (gtCode->corners + 3)->y - points[1][3];
	
	CRGetJacobian(jacobian, pointsHomo, originalPoint, param);
}

#pragma mark - Test code

void testCRRodrigues() {
	printf("testCRRodrigues-------------------------------------------------\n");
	// ground truth data made by MATLAB
	float gt_r[3] = {0.9572, 0.4854, 0.8003};
	float r[3];
	float gt_matrix[3][3];
	float matrix[3][3];
	
	gt_matrix[0][0] =  0.6236;	gt_matrix[0][1] = -0.3822;	gt_matrix[0][2] =  0.6820;
	gt_matrix[1][0] =  0.7814;	gt_matrix[1][1] =  0.3312;	gt_matrix[1][2] = -0.5289;
	gt_matrix[2][0] = -0.0237;	gt_matrix[2][1] =  0.8627;	gt_matrix[2][2] =  0.5052;
	
	CRRodriguesR2Matrix(gt_r, matrix);
	
	_CRTestShowMatrix3x3(matrix);
	_CRTestShowMatrix3x3(gt_matrix);
	
	CRRodriguesMatrix2R(r, gt_matrix);
	
	_CRTestShowVec3(r);
	_CRTestShowVec3(gt_r);
}

void _CRTestMultiTransposeMat8x6Mat8x6(float result[6][6], float j[8][6]) {
	//result = a * b;
	for (int i = 0; i < 6; i++) {
		result[i][0] = j[0][i] * j[0][0] + j[1][i] * j[1][0] + j[2][i] * j[2][0] + j[3][i] * j[3][0] + j[4][i] * j[4][0] + j[5][i] * j[5][0] + j[6][i] * j[6][0] + j[7][i] * j[7][0];
		result[i][1] = j[0][i] * j[0][1] + j[1][i] * j[1][1] + j[2][i] * j[2][1] + j[3][i] * j[3][1] + j[4][i] * j[4][1] + j[5][i] * j[5][1] + j[6][i] * j[6][1] + j[7][i] * j[7][1];
		result[i][2] = j[0][i] * j[0][2] + j[1][i] * j[1][2] + j[2][i] * j[2][2] + j[3][i] * j[3][2] + j[4][i] * j[4][2] + j[5][i] * j[5][2] + j[6][i] * j[6][2] + j[7][i] * j[7][2];
		result[i][3] = j[0][i] * j[0][3] + j[1][i] * j[1][3] + j[2][i] * j[2][3] + j[3][i] * j[3][3] + j[4][i] * j[4][3] + j[5][i] * j[5][3] + j[6][i] * j[6][3] + j[7][i] * j[7][3];
		result[i][4] = j[0][i] * j[0][4] + j[1][i] * j[1][4] + j[2][i] * j[2][4] + j[3][i] * j[3][4] + j[4][i] * j[4][4] + j[5][i] * j[5][4] + j[6][i] * j[6][4] + j[7][i] * j[7][4];
		result[i][5] = j[0][i] * j[0][5] + j[1][i] * j[1][5] + j[2][i] * j[2][5] + j[3][i] * j[3][5] + j[4][i] * j[4][5] + j[5][i] * j[5][5] + j[6][i] * j[6][5] + j[7][i] * j[7][5];
		
	}
}

void _CRTestMultiTransposeMat8x6Vec8(float result[6], float j[8][6], float vec[8]) {
	//result = a * b;
	for (int i = 0; i < 6; i++) {
		result[i] = j[0][i] * vec[0] + j[1][i] * vec[1] + j[2][i] * vec[2] + j[3][i] * vec[3] + j[4][i] * vec[4] + j[5][i] * vec[5] + j[6][i] * vec[6] + j[7][i] * vec[7];
	}
}

void _CRTestMultiMat8x6TransposeMat8x6(float result[6][6], float j[8][6]) {
	//result = a * b;
	for (int i = 0; i < 6; i++) {
		result[i][0] = j[0][i] * j[0][0] + j[1][i] * j[1][0] + j[2][i] * j[2][0] + j[3][i] * j[3][0] + j[4][i] * j[4][0] + j[5][i] * j[5][0] + j[6][i] * j[6][0] + j[7][i] * j[7][0];
		result[i][1] = j[0][i] * j[0][1] + j[1][i] * j[1][1] + j[2][i] * j[2][1] + j[3][i] * j[3][1] + j[4][i] * j[4][1] + j[5][i] * j[5][1] + j[6][i] * j[6][1] + j[7][i] * j[7][1];
		result[i][2] = j[0][i] * j[0][2] + j[1][i] * j[1][2] + j[2][i] * j[2][2] + j[3][i] * j[3][2] + j[4][i] * j[4][2] + j[5][i] * j[5][2] + j[6][i] * j[6][2] + j[7][i] * j[7][2];
		result[i][3] = j[0][i] * j[0][3] + j[1][i] * j[1][3] + j[2][i] * j[2][3] + j[3][i] * j[3][3] + j[4][i] * j[4][3] + j[5][i] * j[5][3] + j[6][i] * j[6][3] + j[7][i] * j[7][3];
		result[i][4] = j[0][i] * j[0][4] + j[1][i] * j[1][4] + j[2][i] * j[2][4] + j[3][i] * j[3][4] + j[4][i] * j[4][4] + j[5][i] * j[5][4] + j[6][i] * j[6][4] + j[7][i] * j[7][4];
		result[i][5] = j[0][i] * j[0][5] + j[1][i] * j[1][5] + j[2][i] * j[2][5] + j[3][i] * j[3][5] + j[4][i] * j[4][5] + j[5][i] * j[5][5] + j[6][i] * j[6][5] + j[7][i] * j[7][5];
		
	}
}

void CRGetMatrixFromHessianAndLambda(float hessian[6][6], float lambda) {
	for (int i = 0; i < 6; i++) {
		hessian[i][i] = (1 + lambda) * hessian[i][i];
	}
}

void lvm_test_get_diff() {
	printf("lvm_test_get_diff-------------------------------------------------\n");
	
	float lambda = 1;
	
	float gt_jacobian[8][6];
	gt_jacobian[0][0] = 0;		gt_jacobian[0][1] = 0;			gt_jacobian[0][2] = 0;		gt_jacobian[0][3] = -0.2000;    gt_jacobian[0][4] =  0;			gt_jacobian[0][5] = 0.0020;
	gt_jacobian[1][0] = 0;		gt_jacobian[1][1] = 0;			gt_jacobian[1][2] = 0;		gt_jacobian[1][3] =		  0;    gt_jacobian[1][4] = -0.2000;	gt_jacobian[1][5] = 0;
	gt_jacobian[2][0] = 0;		gt_jacobian[2][1] =-0.0394;		gt_jacobian[2][2] = 0.0284;	gt_jacobian[2][3] = -0.1990;    gt_jacobian[2][4] =  0;			gt_jacobian[2][5] = 0.0415;
	gt_jacobian[3][0] = 0;		gt_jacobian[3][1] =-0.0643;		gt_jacobian[3][2] =-0.1878;	gt_jacobian[3][3] =		  0;    gt_jacobian[3][4] = -0.1990;	gt_jacobian[3][5] = 0.0030;
	gt_jacobian[4][0] = 0.0324;	gt_jacobian[4][1] =-0.0324;		gt_jacobian[4][2] = 0.2113;	gt_jacobian[4][3] = -0.1875;    gt_jacobian[4][4] =  0;			gt_jacobian[4][5] = 0.0341;
	gt_jacobian[5][0] = 0.0922;	gt_jacobian[5][1] =-0.0922;		gt_jacobian[5][2] =-0.1536;	gt_jacobian[5][3] =       0;    gt_jacobian[5][4] = -0.1875;	gt_jacobian[5][5] = 0.0360;
	gt_jacobian[6][0] =-0.0010;	gt_jacobian[6][1] = 0;			gt_jacobian[6][2] = 0.1878;	gt_jacobian[6][3] = -0.1884;    gt_jacobian[6][4] =  0;			gt_jacobian[6][5] =-0.0010;
	gt_jacobian[7][0] = 0.0902;	gt_jacobian[7][1] = 0;			gt_jacobian[7][2] = 0.0132;	gt_jacobian[7][3] =		  0;    gt_jacobian[7][4] = -0.1884;	gt_jacobian[7][5] = 0.0337;
	
	float gt_error[8];
	gt_error[0] = 0;
	gt_error[1] = 0;
	gt_error[2] = -0.0989;
	gt_error[3] = -0.0074;
	gt_error[4] = -0.0831;
	gt_error[5] = -0.0928;
    gt_error[6] = 0.0075;
	gt_error[7] = -0.0866;
	
	float delta_param[6];
	delta_param[0] = 0.0261;
	delta_param[1] = -0.0116;
    delta_param[2] = 0.0041;
    delta_param[3] = 0.0268;
    delta_param[4] = 0.0005;
    delta_param[5] = 2.5077;
	
	float hessian[6][6];
	
	_CRTestMultiTransposeMat8x6Mat8x6(hessian, gt_jacobian);
	
	_CRTestShowMatrix6x6(hessian);
	
	float a[6][6];
	
//	0.0354   -0.0095   -0.0063   -0.0059   -0.0343    0.0075
//	-0.0095    0.0305    0.0183    0.0139    0.0301   -0.0062
//	-0.0063    0.0183    0.2796   -0.0807    0.0637    0.0026
//	-0.0059    0.0139   -0.0807    0.3006         0   -0.0149
//	-0.0343    0.0301    0.0637         0    0.3006   -0.0137
//    0.0075   -0.0062    0.0026   -0.0149   -0.0137    0.0106
	
	CRGetMatrixFromHessianAndLambda(hessian, lambda);
	
	_CRTestShowMatrix6x6(hessian);
	
	float b[6];
	
	_CRTestMultiTransposeMat8x6Vec8(b, gt_jacobian, gt_error);
	
//	-0.0191
//    0.0156
//	-0.0045
//    0.0339
//    0.0352
//	-0.0132
	
	
	float dummya[36];
	
	for (int i = 0; i < 6; i++) {
		b[i] = -b[i];
	}
	
	_CRTestShowVec6(b);
	
	for (int i = 0; i < 6; i++) {
		for (int j = 0; j < 6; j++) {
			dummya[i + j * 6] = hessian[j][i];
		}
	}

	int rank = 6;
	int nrhs = 1;
	int pivot[6];
	int info = 0;
	
	_tic();
	sgesv_((__CLPK_integer*)&rank, (__CLPK_integer*)&nrhs, (__CLPK_real*)dummya, (__CLPK_integer*)&rank, (__CLPK_integer*)pivot,(__CLPK_real*)b, (__CLPK_integer*)&rank, (__CLPK_integer*)&info);
	_toc();
	
	_CRTestShowVec6(b);
	
//	D = lambda * diag(diag(H));
//	delta_p = (H + D) \ (-J' * r);
}

//int _CRGetHomographyMatrix(float *matrix, CRCorner *p, int inputImgWidth, int inputImgHeight) {
//	
//	float x1 = (p[0].x - inputImgWidth/2)  / CRGetXFocalLength();
//	float y1 = (p[0].y - inputImgHeight/2) / CRGetYFocalLength();
//	float x2 = (p[1].x - inputImgWidth/2)  / CRGetXFocalLength();
//	float y2 = (p[1].y - inputImgHeight/2) / CRGetYFocalLength();
//	float x3 = (p[2].x - inputImgWidth/2)  / CRGetXFocalLength();
//	float y3 = (p[2].y - inputImgHeight/2) / CRGetYFocalLength();
//	float x4 = (p[3].x - inputImgWidth/2)  / CRGetXFocalLength();
//	float y4 = (p[3].y - inputImgHeight/2) / CRGetYFocalLength();
//	
//#ifdef DEBUG_CODE_CALCULATION
//	printf("------------------------------------------->Corner points\n");
//	printf(" %d,%d,%d,%d\n", p[0]->x,p[1]->x,p[2]->x,p[3]->x);
//	printf(" %d,%d,%d,%d\n", p[0]->y,p[1]->y,p[2]->y,p[3]->y);
//	
//	printf("------------------------------------------->Corner points(normalized)\n");
//	printf(" %f,%f,%f,%f\n", x1, x2, x3, x4);
//	printf(" %f,%f,%f,%f\n", y1, y2, y3, y4);
//#endif
//	
//	float a[64];
//	float *b = matrix;
//	
//	float code = 0.5;
//	
//	a[0] = -code;  a[ 8] =  code;   a[16] = 1;  a[24] =     0;  a[32] =     0;  a[40] = 0;  a[48] = -x1 * (-code);  a[56] = -x1 * ( code);
//	a[1] =     0;  a[ 9] =     0;   a[17] = 0;  a[25] = -code;  a[33] =  code;  a[41] = 1;  a[49] = -y1 * (-code);  a[57] = -y1 * ( code);
//	
//	a[2] =  code;  a[10] =  code;   a[18] = 1;  a[26] =     0;  a[34] =     0;  a[42] = 0;  a[50] = -x2 * ( code);  a[58] = -x2 * ( code);
//	a[3] =     0;  a[11] =     0;   a[19] = 0;  a[27] =  code;  a[35] =  code;  a[43] = 1;  a[51] = -y2 * ( code);  a[59] = -y2 * ( code);
//	
//	a[4] =  code;  a[12] = -code;   a[20] = 1;  a[28] =    0;   a[36] =     0;  a[44] = 0;  a[52] = -x3 * ( code);  a[60] = -x3 * (-code);
//	a[5] =     0;  a[13] =     0;   a[21] = 0;  a[29] =  code;  a[37] = -code;  a[45] = 1;  a[53] = -y3 * ( code);  a[61] = -y3 * (-code);
//	
//	a[6] = -code;  a[14] = -code;   a[22] = 1;  a[30] =     0;  a[38] =     0;  a[46] = 0;  a[54] = -x4 * (-code);  a[62] = -x4 * (-code);
//	a[7] =     0;  a[15] =     0;   a[23] = 0;  a[31] = -code;  a[39] = -code;  a[47] = 1;  a[55] = -y4 * (-code);  a[63] = -y4 * (-code);
//	
//#ifdef	DEBUG_CODE_CALCULATION
//	printf("------------------------------------------->Data matrix\n");
//	for (int i = 0; i < 8; i++)
//		printf(" %3.5f,%3.5f, %3.5f, %3.5f,%3.5f,%3.5f, %3.5f, %3.5f\n", a[i], a[i+8], a[i+16], a[i+24], a[i+32], a[i+40], a[i+48], a[i+56]);
//#endif
//	
//	b[0] = x1;
//	b[1] = y1;
//	b[2] = x2;
//	b[3] = y2;
//	b[4] = x3;
//	b[5] = y3;
//	b[6] = x4;
//	b[7] = y4;
//	
//	int rank = 8;
//	int nrhs = 1;
//	int pivot[8];
//	int info = 0;
//	
//	sgesv_((__CLPK_integer*)&rank, (__CLPK_integer*)&nrhs, (__CLPK_real*)a, (__CLPK_integer*)&rank, (__CLPK_integer*)pivot,(__CLPK_real*)b, (__CLPK_integer*)&rank, (__CLPK_integer*)&info);
//	
//	return (info == 0);	// check result of sgesv_
//}

void lvm_test_diff_current_parameter() {
	printf("lvm_test_diff_current_parameter-------------------------------------------------\n");
	float gt_param[6];
	float error[8];
	
	CRHomogeneousVec3 *corners = new CRHomogeneousVec3 [4];
	CRCode *groundTruthCode = new CRCode(corners, corners+1, corners+2, corners+3);
	
	(corners + 0)->x = 0.0100;
	(corners + 0)->y = 0.0f;
	(corners + 0)->w = 1.0f;
	
	(corners + 1)->x = 0.1094;
	(corners + 1)->y = 0.0074;
	(corners + 1)->w = 1.0f;
	
	(corners + 2)->x = 0.0986;
	(corners + 2)->y = 0.0990;
	(corners + 2)->w = 1.0f;
	
	(corners + 3)->x = 0.0021;
	(corners + 3)->y = 0.0920;
	(corners + 3)->w = 1.0f;
	
	gt_param[0] = 0.3140;
	gt_param[1] =-0.0123;
	gt_param[2] = 0.0779;
	gt_param[3] = 0.0500;
	gt_param[4] = 0;
	gt_param[5] = 5.0000;

	float jacobian[8][6];
	
	float gt_jacobian[8][6];
	
	gt_jacobian[0][0] = 0;		gt_jacobian[0][1] = 0;			gt_jacobian[0][2] = 0;		gt_jacobian[0][3] = -0.2000;    gt_jacobian[0][4] =  0;			gt_jacobian[0][5] = 0.0020;
	gt_jacobian[1][0] = 0;		gt_jacobian[1][1] = 0;			gt_jacobian[1][2] = 0;		gt_jacobian[1][3] =		  0;    gt_jacobian[1][4] = -0.2000;	gt_jacobian[1][5] = 0;
	gt_jacobian[2][0] = 0;		gt_jacobian[2][1] =-0.0394;		gt_jacobian[2][2] = 0.0284;	gt_jacobian[2][3] = -0.1990;    gt_jacobian[2][4] =  0;			gt_jacobian[2][5] = 0.0415;
	gt_jacobian[3][0] = 0;		gt_jacobian[3][1] =-0.0643;		gt_jacobian[3][2] =-0.1878;	gt_jacobian[3][3] =		  0;    gt_jacobian[3][4] = -0.1990;	gt_jacobian[3][5] = 0.0030;
	gt_jacobian[4][0] = 0.0324;	gt_jacobian[4][1] =-0.0324;		gt_jacobian[4][2] = 0.2113;	gt_jacobian[4][3] = -0.1875;    gt_jacobian[4][4] =  0;			gt_jacobian[4][5] = 0.0341;
	gt_jacobian[5][0] = 0.0922;	gt_jacobian[5][1] =-0.0922;		gt_jacobian[5][2] =-0.1536;	gt_jacobian[5][3] =       0;    gt_jacobian[5][4] = -0.1875;	gt_jacobian[5][5] = 0.0360;
	gt_jacobian[6][0] =-0.0010;	gt_jacobian[6][1] = 0;			gt_jacobian[6][2] = 0.1878;	gt_jacobian[6][3] = -0.1884;    gt_jacobian[6][4] =  0;			gt_jacobian[6][5] =-0.0010;
	gt_jacobian[7][0] = 0.0902;	gt_jacobian[7][1] = 0;			gt_jacobian[7][2] = 0.0132;	gt_jacobian[7][3] =		  0;    gt_jacobian[7][4] = -0.1884;	gt_jacobian[7][5] = 0.0337;
	
	CRGetCurrentErrorAndJacobian(jacobian, gt_param, groundTruthCode, error);
	
	
	printf("jacobian\n");
	_CRTestShowMatrix8x6(jacobian);
	
	printf("ground truth jacobian\n");
	_CRTestShowMatrix8x6(gt_jacobian);
	
	float gt_error[8];
	
	gt_error[0] = 0;
	gt_error[1] = 0;
	gt_error[2] = -0.0989;
	gt_error[3] = -0.0074;
	gt_error[4] = -0.0831;
	gt_error[5] = -0.0928;
    gt_error[6] = 0.0075;
	gt_error[7] = -0.0866;
	
	printf("estimated error\n");
	_CRTestShowVec8(error);
	
	printf("ground truth error\n");
	_CRTestShowVec8(gt_error);
	
	SAFE_DELETE(groundTruthCode);
	SAFE_DELETE_ARRAY(corners);
}

void lvm_test_linear_estimation() {
	printf("lvm_test_linear_estimation-------------------------------------------------\n");
	float codeSize = 0.5;
	float width = 640;
	float height = 480;
	float focal = 650;
	
	float param[6];
	float gt_matrix[4][4];
	float gt_param[6];
	
	gt_matrix[0][0] =  0.997;	gt_matrix[0][1] = -0.078;	gt_matrix[0][2] =  0.000;	gt_matrix[0][3] =  0.050;
	gt_matrix[1][0] =  0.075;	gt_matrix[1][1] =  0.948;	gt_matrix[1][2] = -0.309;	gt_matrix[1][3] =  0.000;
	gt_matrix[2][0] =  0.024;	gt_matrix[2][1] =  0.308;	gt_matrix[2][2] =  0.951;	gt_matrix[2][3] =  5.000;
	gt_matrix[3][0] =  0.000;	gt_matrix[3][1] =  0.000;	gt_matrix[3][2] =  0.000;	gt_matrix[3][3] =  1.000;
	
	gt_param[0] = 0.3140;
	gt_param[1] =-0.0123;
	gt_param[2] = 0.0779;
	gt_param[3] = 0.0500;
	gt_param[4] = 0;
	gt_param[5] = 5.0000;
	
	CRHomogeneousVec3 *corners = new CRHomogeneousVec3 [4];

	(corners + 0)->x = 0.0100;
	(corners + 0)->y = 0.0f;
	(corners + 0)->w = 1.0f;
	
	(corners + 1)->x = 0.1094;
	(corners + 1)->y = 0.0074;
	(corners + 1)->w = 1.0f;
	
	(corners + 2)->x = 0.0986;
	(corners + 2)->y = 0.0990;
	(corners + 2)->w = 1.0f;
	
	(corners + 3)->x = 0.0021;
	(corners + 3)->y = 0.0920;
	(corners + 3)->w = 1.0f;
	
	CRCode *groundTruthCode = new CRCode(corners, corners+1, corners+2, corners+3);
	
	printf("Input corners\n");
	groundTruthCode->dumpCorners();
	
	printf("RT matrix estimated with liner method\n");
	groundTruthCode->getSimpleHomography(codeSize);
	_CRTestShowMatrix3x3(groundTruthCode->homography);
	_CRTestShowMatrix4x4(groundTruthCode->rt);
	CRRTMatrix2Parameters(param, groundTruthCode->rt);
	_CRTestShowVec6(param);

	printf("Ground truth\n");
	_CRTestShowMatrix4x4(gt_matrix);
	_CRTestShowVec6(gt_param);
	SAFE_DELETE(groundTruthCode);
	SAFE_DELETE_ARRAY(corners);
}

void lvm_module_test() {
	printf("lvm_module_test-------------------------------------------------\n");
	lvm_test_linear_estimation();
	lvm_test_diff_current_parameter();
	lvm_test_get_diff();
}

#pragma mark - main

int main (int argc, const char * argv[]) {
	testCRRodrigues();
	lvm_module_test();
    return 0;
}

