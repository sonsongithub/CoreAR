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

void lvm() {
	
	CRHomogeneousVec3 *corners = new CRHomogeneousVec3 [4];
	CRCode *groundTruthCode = new CRCode(corners, corners+1, corners+2, corners+3);
}

int main (int argc, const char * argv[]) {
	testCRRodrigues();
    return 0;
}

