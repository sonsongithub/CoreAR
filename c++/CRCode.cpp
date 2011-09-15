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
		(corners + i)->y = (float)height/2 - (corners + i)->y;
		(corners + i)->y /= (float)focalY;
	}
}

void CRCode::dumpCorners() {
	printf("%f %f %f %f\n", (corners+0)->x, (corners+1)->x, (corners+2)->x, (corners+3)->x);
	printf("%f %f %f %f\n", (corners+0)->y, (corners+1)->y, (corners+2)->y, (corners+3)->y);
	printf("%f %f %f %f\n\n", (corners+0)->w, (corners+1)->w, (corners+2)->w, (corners+3)->w);
}

void CRCode::crop(float croppingWidth, float croppingHeight, float focalX, float focalY, unsigned char *source, int width, int height) {
	
	croppedCodeImageWidth = croppingWidth;
	croppedCodeImageHeight = croppingHeight;
	
	SAFE_FREE(croppedCodeImage);
	croppedCodeImage = (unsigned char*)malloc(sizeof(unsigned char) * croppedCodeImageWidth * croppedCodeImageHeight);
	
	float codeContentSize = 1;
	
	for (int i = 0; i < croppedCodeImageWidth; i++) {
		for (int j = 0; j < croppedCodeImageHeight; j++) {
			float ii = codeContentSize * 0.25 + 0.5 * i * codeContentSize / (croppedCodeImageWidth - 1);
			float jj = codeContentSize * 0.25 + 0.5 * j * codeContentSize / (croppedCodeImageHeight - 1);
			
			float normalizedX = (h[0] * ii + h[3] * jj + h[6]) / (h[2] * ii + h[5] * jj + 1);
			float normalizedY = (h[1] * ii + h[4] * jj + h[7]) / (h[2] * ii + h[5] * jj + 1);
			
			int x = normalizedX * focalX + width/2;
			int y = height/2 - normalizedY * focalY;
			
			if (x >= 0 && x < width && y < height && y >=0 ) {
				croppedCodeImage[i + j * croppedCodeImageWidth] = source[x + y * (int)width];
			}
		}
	}
}

void CRCode::getSimpleHomography(float scale) {
	
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
	
	rt[0][0] = homography[0][0] / e1_length;
	rt[1][0] = homography[1][0] / e1_length;
	rt[2][0] = homography[2][0] / e1_length;
	rt[3][0] = 0;
	
	rt[0][1] = homography[0][1] / e2_length;
	rt[1][1] = homography[1][1] / e2_length;
	rt[2][1] = homography[2][1] / e2_length;
	rt[3][1] = 0;
	
	rt[0][2] = rt[2][0] * rt[1][1] - rt[1][0] * rt[2][1];
	rt[1][2] = rt[2][0] * rt[0][1] - rt[0][0] * rt[2][1];
	rt[2][2] = rt[0][0] * rt[1][1] - rt[1][0] * rt[0][1];
	rt[3][2] = 0;
	
	rt[0][3] = homography[0][2] / length * scale;
	rt[1][3] = homography[1][2] / length * scale;
	rt[2][3] = homography[2][2] / length * scale;
	rt[3][3] = 1;
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
