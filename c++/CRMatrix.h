/*
 * Core AR
 * CRMatrix.h
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

#ifdef _CRMATIRX_CPP_
#else
#define _CRMATIRX_CPP_

#include <iostream>

// quaternion[4] <= matrix[4][4]
void CRMatrixMat4x42Quaternion(float *r, float matrix[4][4]);

// result[6][6] = j[8][6]' * j[8][6]
void CRMatrixSquaredTransposeMat8x6(float result[6][6], float j[8][6]);

// result[6] = j[8][6]' * vec[8]
void CRMatrixMultiTransposeMat8x6Vec8(float result[6], float j[8][6], float vec[8]);

// result[3][3] = a[3][3] * b[3][3]
void CRMatrixMultiMat3x3Mat3x3(float result[3][3], float a[3][3], float b[3][3]);

// result[2][3] = a[2][3] * b[3][3]
void CRMatrixMultiMat2x3Mat3x3(float result[2][3], float a[2][3], float b[3][3]);

// result[3][3] = a[3][3] * a[3][3]'
void CRMatrixSquareMat3x3(float result[3][3], float a[3][3]);

// a[3][3] = scale * a[3][3]
void CRMatrixScalingMat3x3(float a[3][3], float scale);

// Euler degress(X->Y->Z) <= matrix[4][4]
void CRMatrixMat4x42EulerDegrees3(float *degrees, float matrix[4][4]);

// Euler degress(X->Y->Z) <= matrix[3][3]
void CRMatrixMat3x32EulerDegrees3(float *degrees, float matrix[3][3]);

#endif