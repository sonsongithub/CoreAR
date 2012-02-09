/*
 * Core AR
 * CRMatrix.cpp
 *
 * Copyright (c) Yuichi YOSHIDA, 12/02/09.
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

#include "CRMatrix.h"

#include <math.h>

// result[6][6] = j[8][6]' * j[8][6]
void CRMatrixSquaredTransposeMat8x6(float result[6][6], float j[8][6]) {
	for (int i = 0; i < 6; i++) {
		result[i][0] = j[0][i] * j[0][0] + j[1][i] * j[1][0] + j[2][i] * j[2][0] + j[3][i] * j[3][0] + j[4][i] * j[4][0] + j[5][i] * j[5][0] + j[6][i] * j[6][0] + j[7][i] * j[7][0];
		result[i][1] = j[0][i] * j[0][1] + j[1][i] * j[1][1] + j[2][i] * j[2][1] + j[3][i] * j[3][1] + j[4][i] * j[4][1] + j[5][i] * j[5][1] + j[6][i] * j[6][1] + j[7][i] * j[7][1];
		result[i][2] = j[0][i] * j[0][2] + j[1][i] * j[1][2] + j[2][i] * j[2][2] + j[3][i] * j[3][2] + j[4][i] * j[4][2] + j[5][i] * j[5][2] + j[6][i] * j[6][2] + j[7][i] * j[7][2];
		result[i][3] = j[0][i] * j[0][3] + j[1][i] * j[1][3] + j[2][i] * j[2][3] + j[3][i] * j[3][3] + j[4][i] * j[4][3] + j[5][i] * j[5][3] + j[6][i] * j[6][3] + j[7][i] * j[7][3];
		result[i][4] = j[0][i] * j[0][4] + j[1][i] * j[1][4] + j[2][i] * j[2][4] + j[3][i] * j[3][4] + j[4][i] * j[4][4] + j[5][i] * j[5][4] + j[6][i] * j[6][4] + j[7][i] * j[7][4];
		result[i][5] = j[0][i] * j[0][5] + j[1][i] * j[1][5] + j[2][i] * j[2][5] + j[3][i] * j[3][5] + j[4][i] * j[4][5] + j[5][i] * j[5][5] + j[6][i] * j[6][5] + j[7][i] * j[7][5];
		
	}
}

// result[6] = j[8][6]' * vec[8]
void CRMatrixMultiTransposeMat8x6Vec8(float result[6], float j[8][6], float vec[8]) {
	for (int i = 0; i < 6; i++) {
		result[i] = j[0][i] * vec[0] + j[1][i] * vec[1] + j[2][i] * vec[2] + j[3][i] * vec[3] + j[4][i] * vec[4] + j[5][i] * vec[5] + j[6][i] * vec[6] + j[7][i] * vec[7];
	}
}

// result[3][3] = a[3][3] * b[3][3]
void CRMatrixMultiMat3x3Mat3x3(float result[3][3], float a[3][3], float b[3][3]) {
	for (int i = 0; i < 3; i++) {
		result[i][0] = a[i][0] * b[0][0] + a[i][1] * b[1][0] + a[i][2] * b[2][0];
		result[i][1] = a[i][0] * b[0][1] + a[i][1] * b[1][1] + a[i][2] * b[2][1];
		result[i][2] = a[i][0] * b[0][2] + a[i][1] * b[1][2] + a[i][2] * b[2][2];
	}
}

// result[2][3] = a[2][3] * b[3][3]
void CRMatrixMultiMat2x3Mat3x3(float result[2][3], float a[2][3], float b[3][3]) {
	for (int i = 0; i < 2; i++) {
		result[i][0] = a[i][0] * b[0][0] + a[i][1] * b[1][0] + a[i][2] * b[2][0];
		result[i][1] = a[i][0] * b[0][1] + a[i][1] * b[1][1] + a[i][2] * b[2][1];
		result[i][2] = a[i][0] * b[0][2] + a[i][1] * b[1][2] + a[i][2] * b[2][2];
	}
}

// result[3][3] = a[3][3] * a[3][3]'
void CRMatrixSquareMat3x3(float result[3][3], float a[3][3]) {
	for (int i = 0; i < 3; i++) {
		result[i][0] = a[i][0] * a[0][0] + a[i][1] * a[1][0] + a[i][2] * a[2][0];
		result[i][1] = a[i][0] * a[0][1] + a[i][1] * a[1][1] + a[i][2] * a[2][1];
		result[i][2] = a[i][0] * a[0][2] + a[i][1] * a[1][2] + a[i][2] * a[2][2];
	}
}

// a[3][3] = scale * a[3][3]
void CRMatrixScalingMat3x3(float a[3][3], float scale) {
	for (int i = 0; i < 3; i++) {
		a[i][0] = a[i][0] * scale;
		a[i][1] = a[i][1] * scale;
		a[i][2] = a[i][2] * scale;
	}
}