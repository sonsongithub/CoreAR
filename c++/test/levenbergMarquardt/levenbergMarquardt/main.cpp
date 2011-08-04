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

void subJacobian(float jacobian[8][6], float pointsHomo[3][4], float originalPoint[4][4], float *param) {
	
	float m2[2][3];
	float m3[3][3];
	float m4[3][3];
	float m5[3][3];
	float m6[2][3];
	
	CRRodriguesR2Matrix(param, m3);
	_CRTestShowMatrix3x4(pointsHomo);
	for (int num = 0; num < 4; num++) {
		m2[0][0] = -1/pointsHomo[2][num];	m2[0][1] =                    0;	m2[0][2] =  pointsHomo[0][num]/pointsHomo[2][num]/pointsHomo[2][num];
		m2[1][0] =					  0;	m2[1][1] = -1/pointsHomo[2][num];	m2[1][2] =  pointsHomo[1][num]/pointsHomo[2][num]/pointsHomo[2][num];
		
		m4[0][0] =                      0;	m4[0][1] =  originalPoint[2][num];	m4[0][2] = -originalPoint[1][num];
		m4[1][0] = -originalPoint[2][num];	m4[1][1] =                      0;	m4[1][2] =  originalPoint[0][num];
		m4[2][0] =  originalPoint[1][num];	m4[2][1] = -originalPoint[0][num];	m4[2][2] =  0;
		
		
		_CRTestMultiMat3x3Mat3x3(m5, m3, m4);
		_CRTestMultiMat2x3Mat3x3(m6, m2, m5);
		
		_CRTestShowMatrix2x3(m6);
		_CRTestShowMatrix2x3(m2);
		
		jacobian[num*2  ][0] = m6[0][0];	jacobian[num*2  ][1] = m6[0][1];	jacobian[num*2  ][2] = m6[0][2];
		jacobian[num*2+1][0] = m6[1][0];	jacobian[num*2+1][1] = m6[1][1];	jacobian[num*2+1][2] = m6[1][2];
		
		jacobian[num*2  ][3] = m2[0][0];	jacobian[num*2  ][4] = m2[0][1];	jacobian[num*2  ][5] = m2[0][2];
		jacobian[num*2+1][3] = m2[1][0];	jacobian[num*2+1][4] = m2[1][1];	jacobian[num*2+1][5] = m2[1][2];
	}
}

void getJacobian(float jacobian[8][6], float *param, CRCode *gtCode, float *error) {
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
	subJacobian(jacobian, pointsHomo, originalPoint, param);
}

void CRProjectedPoint(float *param, CRCode *gtCode, float *error) {
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
	
	_CRTestShowMatrix4x4(rt);
	_CRTestShowMatrix3x4(pointsHomo);
	_CRTestShowMatrix2x4(points);
	_CRTestShowVec8(error);
	
	subJacobian(NULL, pointsHomo, originalPoint, param);
}

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
	
//	CRProjectedPoint(gt_param, groundTruthCode, error);
	getJacobian(jacobian, gt_param, groundTruthCode, error);
	
	_CRTestShowMatrix8x6(jacobian);
	
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
}

int main (int argc, const char * argv[]) {
	testCRRodrigues();
	lvm_module_test();
    return 0;
}

