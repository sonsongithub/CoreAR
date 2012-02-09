/*
 * Core AR
 * CRLevenbergMarquardt.cpp
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

#include "CRLevenbergMarquardt.h"
#include "CRRodrigues.h"
#include "CRCommon.h"
#include "CRMatrix.h"
#include <Accelerate/Accelerate.h>

// private
void CRGetMatrixFromHessianAndLambda(float hessian_dash[6][6], float hessian[6][6], float lambda);

void CRGetMatrixFromHessianAndLambda(float hessian_dash[6][6], float hessian[6][6], float lambda) {
	memcpy(hessian_dash, hessian, sizeof(float)*36);
	for (int i = 0; i < 6; i++) {
		hessian_dash[i][i] = (1 + lambda) * hessian[i][i];
	}
}

void CRGetDeltaParameter(float delta_param[6], float jacobian[8][6], float hessian[6][6], float error[8], float lambda) {
	float hessian_dash[6][6];
	
	//	_CRTestShowMatrix6x6(hessian);
	
	CRGetMatrixFromHessianAndLambda(hessian_dash, hessian, lambda);
	
	CRMatrixMultiTransposeMat8x6Vec8(delta_param, jacobian, error);
	
	for (int i = 0; i < 6; i++) {
		delta_param[i] = -delta_param[i];
	}
	
	int rank = 6;
	int nrhs = 1;
	int pivot[6];
	int info = 0;
	
	sgesv_((__CLPK_integer*)&rank, (__CLPK_integer*)&nrhs, (__CLPK_real*)hessian_dash, (__CLPK_integer*)&rank, (__CLPK_integer*)pivot,(__CLPK_real*)delta_param, (__CLPK_integer*)&rank, (__CLPK_integer*)&info);
}

float CRSumationOfSquaredVec6(float vec[6]) {
	return vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2] + vec[3]*vec[3] + vec[4]*vec[4] + vec[5]*vec[5];
}

float CRSumationOfSquaredVec8(float vec[8]) {
	return vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2] + vec[3]*vec[3] + vec[4]*vec[4] + vec[5]*vec[5] + vec[6]*vec[6] + vec[7]*vec[7];
}

void CRRTMatrix2RodriguesRotPos(float *param, float matrix[4][4]) {
	CRRodriguesMatrix4x42R(param, matrix);
	param[3] = matrix[0][3];
	param[4] = matrix[1][3];
	param[5] = matrix[2][3];
}

void CRRodriguesRotPos2RTMatrix(float *param, float matrix[4][4]) {
	CRRodriguesR2Matrix4x4(param, matrix);
	matrix[0][3] = param[3];
	matrix[1][3] = param[4];
	matrix[2][3] = param[5];
	matrix[3][0] = 0;
	matrix[3][1] = 0;
	matrix[3][2] = 0;
	matrix[3][3] = 1;
}

void CRGetCurrentErrorAndJacobian(float jacobian[8][6], float hessian[6][6], float *error, float *param, CRCode *gtCode, float codeSize) {
	float points[2][4];
	float pointsHomo[3][4];
	
	float originalPoint[4][4];
	
	float rt[4][4];
	CRRodriguesRotPos2RTMatrix(param, rt);
	
	originalPoint[0][0] =  0;	originalPoint[0][1] =  codeSize;	originalPoint[0][2] =  codeSize;	originalPoint[0][3] =  0;
	originalPoint[1][0] =  0;	originalPoint[1][1] =  0;			originalPoint[1][2] =  codeSize;	originalPoint[1][3] =  codeSize;
	originalPoint[2][0] =  0;	originalPoint[2][1] =  0;			originalPoint[2][2] =  0;			originalPoint[2][3] =  0;
	originalPoint[3][0] =  1;	originalPoint[3][1] =  1;			originalPoint[3][2] =  1;			originalPoint[3][3] =  1;
	
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
	
	//	_CRTestShowMatrix4x4(rt);
	//	_CRTestShowMatrix4x4(originalPoint);
	//	_CRTestShowMatrix3x4(pointsHomo);
	//	_CRTestShowMatrix2x4(points);
	//	gtCode->dumpCorners();
	
	error[0] = (gtCode->corners + 0)->x - points[0][0];
	error[1] = (gtCode->corners + 0)->y - points[1][0];
	error[2] = (gtCode->corners + 1)->x - points[0][1];
	error[3] = (gtCode->corners + 1)->y - points[1][1];
	error[4] = (gtCode->corners + 2)->x - points[0][2];
	error[5] = (gtCode->corners + 2)->y - points[1][2];
	error[6] = (gtCode->corners + 3)->x - points[0][3];
	error[7] = (gtCode->corners + 3)->y - points[1][3];
	
	if (jacobian != NULL) {
		CRGetJacobian(jacobian, pointsHomo, originalPoint, param);
		CRMatrixSquaredTransposeMat8x6(hessian, jacobian);
	}
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
		
		
		CRMatrixMultiMat3x3Mat3x3(m5, m3, m4);
		CRMatrixMultiMat2x3Mat3x3(m6, m2, m5);
		
		jacobian[num*2  ][0] = m6[0][0];	jacobian[num*2  ][1] = m6[0][1];	jacobian[num*2  ][2] = m6[0][2];
		jacobian[num*2+1][0] = m6[1][0];	jacobian[num*2+1][1] = m6[1][1];	jacobian[num*2+1][2] = m6[1][2];
		
		jacobian[num*2  ][3] = m2[0][0];	jacobian[num*2  ][4] = m2[0][1];	jacobian[num*2  ][5] = m2[0][2];
		jacobian[num*2+1][3] = m2[1][0];	jacobian[num*2+1][4] = m2[1][1];	jacobian[num*2+1][5] = m2[1][2];
	}
}
