/*
 * Core AR
 * CRRodrigues.cpp
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

#include "CRRodrigues.h"

#include <math.h>
#include "CRMatrix.h"

void CRRodriguesR2Matrix4x4(float *r, float matrix[4][4]) {
	float theta = sqrt(r[0]*r[0] + r[1]*r[1] + r[2]*r[2]);
	
	float rx[3][3];
	
	float rx2[3][3];
	
	rx[0][0] =     0;	rx[0][1] = -r[2];	rx[0][2] =  r[1];
	rx[1][0] =  r[2];	rx[1][1] =     0;	rx[1][2] = -r[0];
	rx[2][0] = -r[1];	rx[2][1] =  r[0];	rx[2][2] =     0;
	
	CRMatrixSquareMat3x3(rx2, rx);
	
	CRMatrixScalingMat3x3(rx, sinf(theta)/theta);
	CRMatrixScalingMat3x3(rx2, (1-cosf(theta))/theta/theta);
	
	matrix[0][0] = 1 + rx[0][0] + rx2[0][0];	matrix[0][1] = 0 + rx[0][1] + rx2[0][1];	matrix[0][2] = 0 + rx[0][2] + rx2[0][2];
	matrix[1][0] = 0 + rx[1][0] + rx2[1][0];	matrix[1][1] = 1 + rx[1][1] + rx2[1][1];	matrix[1][2] = 0 + rx[1][2] + rx2[1][2];
	matrix[2][0] = 0 + rx[2][0] + rx2[2][0];	matrix[2][1] = 0 + rx[2][1] + rx2[2][1];	matrix[2][2] = 1 + rx[2][2] + rx2[2][2];
}

void CRRodriguesR2Matrix(float *r, float matrix[3][3]) {
	float theta = sqrt(r[0]*r[0] + r[1]*r[1] + r[2]*r[2]);

	float rx[3][3];
	
	float rx2[3][3];
	
	rx[0][0] =     0;	rx[0][1] = -r[2];	rx[0][2] =  r[1];
	rx[1][0] =  r[2];	rx[1][1] =     0;	rx[1][2] = -r[0];
	rx[2][0] = -r[1];	rx[2][1] =  r[0];	rx[2][2] =     0;
	
	CRMatrixSquareMat3x3(rx2, rx);
	
	CRMatrixScalingMat3x3(rx, sinf(theta)/theta);
	CRMatrixScalingMat3x3(rx2, (1-cosf(theta))/theta/theta);
	
	matrix[0][0] = 1 + rx[0][0] + rx2[0][0];	matrix[0][1] = 0 + rx[0][1] + rx2[0][1];	matrix[0][2] = 0 + rx[0][2] + rx2[0][2];
	matrix[1][0] = 0 + rx[1][0] + rx2[1][0];	matrix[1][1] = 1 + rx[1][1] + rx2[1][1];	matrix[1][2] = 0 + rx[1][2] + rx2[1][2];
	matrix[2][0] = 0 + rx[2][0] + rx2[2][0];	matrix[2][1] = 0 + rx[2][1] + rx2[2][1];	matrix[2][2] = 1 + rx[2][2] + rx2[2][2];
}

void CRRodriguesMatrix4x42R(float *r, float matrix[4][4]) {
	float theta = acos((matrix[0][0] + matrix[1][1] + matrix[2][2] - 1) * 0.5);
    float e1 = (matrix[2][1] - matrix[1][2]) / (2 * sin(theta));
    float e2 = (matrix[0][2] - matrix[2][0]) / (2 * sin(theta));
    float e3 = (matrix[1][0] - matrix[0][1]) / (2 * sin(theta));
    r[0] = theta*e1;
	r[1] = theta*e2;
	r[2] = theta*e3;
}

void CRRodriguesMatrix2R(float *r, float matrix[3][3]) {
	float theta = acos((matrix[0][0] + matrix[1][1] + matrix[2][2] - 1) * 0.5);
    float e1 = (matrix[2][1] - matrix[1][2]) / (2 * sin(theta));
    float e2 = (matrix[0][2] - matrix[2][0]) / (2 * sin(theta));
    float e3 = (matrix[1][0] - matrix[0][1]) / (2 * sin(theta));
    r[0] = theta*e1;
	r[1] = theta*e2;
	r[2] = theta*e3;
}
