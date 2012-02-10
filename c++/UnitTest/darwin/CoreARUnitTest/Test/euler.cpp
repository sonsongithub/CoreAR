/*
 * Core AR
 * euler.cpp
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

#include "euler.h"

#include <math.h>
#include "CRMatrix.h"
#include "CRTest.h"

#define DEGRAD(f) f/180.0f*M_PI;

void euler_test(void) {
	printf("=================================================>Euler expression <-> rotatation matrix test\n");

	float x = DEGRAD(10);
	float y = DEGRAD(8);
	float z = DEGRAD(45);
	
	float rot_x[4][4];
	float rot_y[4][4];
	float rot_z[4][4];

	rot_x[0][0] = 1;		rot_x[0][1] = 0;		rot_x[0][2] = 0;		rot_x[0][3] = 0;
	rot_x[1][0] = 0;		rot_x[1][1] = cos(x);	rot_x[1][2] = -sin(x);	rot_x[1][3] = 0;
	rot_x[2][0] = 0;		rot_x[2][1] = sin(x);	rot_x[2][2] =  cos(x);	rot_x[2][3] = 0;
	rot_x[3][0] = 0;		rot_x[3][1] = 0;		rot_x[3][2] = 0;		rot_x[3][3] = 1;
	
	rot_y[0][0] = cos(y);	rot_y[0][1] = 0;		rot_y[0][2] = sin(y);	rot_y[0][3] = 0;
	rot_y[1][0] = 0;		rot_y[1][1] = 1;		rot_y[1][2] = 0;		rot_y[1][3] = 0;
	rot_y[2][0] = -sin(y);	rot_y[2][1] = 0;		rot_y[2][2] = cos(y);	rot_y[2][3] = 0;
	rot_y[3][0] = 0;		rot_y[3][1] = 0;		rot_y[3][2] = 0;		rot_y[3][3] = 1;
	
	rot_z[0][0] = cos(z);	rot_z[0][1] = -sin(z);	rot_z[0][2] = 0;		rot_z[0][3] = 0;
	rot_z[1][0] = sin(z);	rot_z[1][1] = cos(z);	rot_z[1][2] = 0;		rot_z[1][3] = 0;
	rot_z[2][0] = 0;		rot_z[2][1] = 0;		rot_z[2][2] = 1;		rot_z[2][3] = 0;
	rot_z[3][0] = 0;		rot_z[3][1] = 0;		rot_z[3][2] = 0;		rot_z[3][3] = 1;
	
	float rot[4][4];
	
	{
		// Rotation matrix = RotZ * RotY * RotX
		float temp_rot_y_x[4][4];
		CRMatrixMultiMat4x4Mat4x4(temp_rot_y_x, rot_y, rot_x);
		CRMatrixMultiMat4x4Mat4x4(rot, rot_z, temp_rot_y_x);
	}
	
	_CRTestShowMatrix4x4(rot);
	
	float degrees[4];
	
	CRMatrixMat4x42EulerDegrees3(degrees, rot);
	
	_CRTestDumpVec(degrees);
	
	printf("%lf\n", x);
	printf("%lf\n", y);
	printf("%lf\n", z);
	
}