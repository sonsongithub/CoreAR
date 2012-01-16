/*
 * Core AR
 * CRChainCodeBlob.cpp
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

#include "CRChainCodeBlob.h"

#include <math.h>
#include "CRCommon.h"

typedef struct _CRDiffVectorInfo {
	int x;
	int y;
	float dx;
	float dy;
	int label;
}CRDiffVectorInfo;

void CRDiffVectorInfoDump(CRDiffVectorInfo p);
CRHomogeneousVec3 *CreateLineFromCRDiffVectorInfoList(CRDiffVectorInfo *list, int numberOfElements, int targetLabel);
int isConvex(CRHomogeneousVec3 *firstCorner, CRHomogeneousVec3 *secondCorner, CRHomogeneousVec3 *thirdCorner, CRHomogeneousVec3 *fourthCorner);

#pragma mark - Tool

void CRDiffVectorInfoDump(CRDiffVectorInfo p) {
	printf("------------------------\n");
	printf(" x=%d\n", p.x);
	printf(" y=%d\n", p.y);
	printf("dx=%f\n", p.dx);
	printf("dy=%f\n", p.dy);
	printf("label=%d\n", p.label);
}

CRHomogeneousVec3 *CreateLineFromCRDiffVectorInfoList(CRDiffVectorInfo *list, int numberOfElements, int targetLabel) {
	float sigma_x = 0;
	float sigma_y = 0;
	float sigma_xy = 0;
	float sigma_xx = 0;
	int n = 0;
	
	for (int i = 0; i < numberOfElements; i++) {
		if ((list+i)->label == targetLabel) {
			sigma_x += (list+i)->x;
			sigma_y += (list+i)->y;
			sigma_xy += ((list+i)->x * (list+i)->y);
			sigma_xx += ((list+i)->x * (list+i)->x);
			n++;
		}
	}
	
	CRHomogeneousVec3 *line = new CRHomogeneousVec3();
	
	float t = n * sigma_xx - sigma_x * sigma_x;
	if (t == 0) {
		line->x = -1;
		line->y = 0;
		line->w = list->x;
	}
	else {
		line->x = (n * sigma_xy - sigma_x * sigma_y) / t;
		line->y = -1;
		line->w = (sigma_xx * sigma_y- sigma_xy * sigma_x) / t;
	}
	
	return line;
}


int isConvex(CRHomogeneousVec3 *firstCorner, CRHomogeneousVec3 *secondCorner, CRHomogeneousVec3 *thirdCorner, CRHomogeneousVec3 *fourthCorner) {
	
	CRHomogeneousVec3 *side14 = CRHomogeneousVec3::diff(fourthCorner, firstCorner);
	CRHomogeneousVec3 *side12 = CRHomogeneousVec3::diff(secondCorner, firstCorner);
	CRHomogeneousVec3 *outer14_12 = CRHomogeneousVec3::outerProduct(side14, side12);
	
	CRHomogeneousVec3 *side21 = CRHomogeneousVec3::diff(firstCorner, secondCorner);
	CRHomogeneousVec3 *side23 = CRHomogeneousVec3::diff(thirdCorner, secondCorner);
	CRHomogeneousVec3 *outer21_23 = CRHomogeneousVec3::outerProduct(side21, side23);
	
	CRHomogeneousVec3 *side32 = CRHomogeneousVec3::diff(secondCorner, thirdCorner);
	CRHomogeneousVec3 *side34 = CRHomogeneousVec3::diff(fourthCorner, thirdCorner);
	CRHomogeneousVec3 *outer32_34 = CRHomogeneousVec3::outerProduct(side32, side34);
	
	CRHomogeneousVec3 *side43 = CRHomogeneousVec3::diff(thirdCorner, fourthCorner);
	CRHomogeneousVec3 *side41 = CRHomogeneousVec3::diff(firstCorner, fourthCorner);
	CRHomogeneousVec3 *outer43_41 = CRHomogeneousVec3::outerProduct(side43, side41);
	
	outer14_12->dump();
	outer21_23->dump();
	outer32_34->dump();
	outer43_41->dump();
	
	bool isConvex1 = (outer14_12->w > 0);
	bool isConvex2 = (outer21_23->w > 0);
	bool isConvex3 = (outer32_34->w > 0);
	bool isConvex4 = (outer43_41->w > 0);
	
	delete side14;
	delete side12;
	delete outer14_12;
	
	delete side21;
	delete side23;
	delete outer21_23;
	
	delete side32;
	delete side34;
	delete outer32_34;
	
	delete side43;
	delete side41;
	delete outer43_41;
	
	if (!isConvex1 || !isConvex2 || !isConvex3 || !isConvex4)
		return CR_FALSE;
	
	return CR_TRUE;
}

#pragma mark - CRChainCodeBlob Implementation

CRChainCodeBlob::CRChainCodeBlob() {
//	_DPRINTF("CRChainCodeBlob constructor\n");
	elements = new std::list<CRChainCodeElement*>();
}

CRChainCodeBlob::~CRChainCodeBlob() {
//	_DPRINTF("CRChainCodeBlob destructor\n");
	
	std::list<CRChainCodeElement*>::iterator it = elements->begin();
	while(it != elements->end()) {
		delete(*it);
		++it;
	}
	delete elements;
}

void CRChainCodeBlob::appendChainCodeElement(int x, int y, int code) {
	CRChainCodeElement *element = new CRChainCodeElement(x, y, code);
	
	if (this->elements->empty()) {
		left = x;
		right = x;
		top = y;
		bottom = y;
	}
	else {
		if (left > x)
			left = x;
		else if (right < x)
			right = x;
		if (top > y)
			top = y;
		else if (bottom < y)
			bottom = y;
	}
	
	this->elements->push_back(element);
}

void CRChainCodeBlob::dump() {
	printf("CRChainCodeBlob\n");
	printf("Rect (%d %d %d %d)\n", left, top, right, bottom);
	printf("Elements = %lu\n", this->elements->size());
}

int CRChainCodeBlob::isValid(int width, int height) {
	
	if (left == 1)
		return CR_FALSE;
	if (right == width - 2)
		return CR_FALSE;
	if (top == 1)
		return CR_FALSE;
	if (bottom == height - 2)
		return CR_FALSE;
	
	if (right - left < MINIMUM_CHAINCODE_CIRCUMSCRIBED_WIDTH)
		return CR_FALSE;
	
	if (bottom - top < MINIMUM_CHAINCODE_CIRCUMSCRIBED_HEIGHT)
		return CR_FALSE;
	
	if (this->elements->size() < MINIMUM_CHAINCODE_LENGTH)
		return CR_FALSE;
	
	return CR_TRUE;
}

CRCode *CRChainCodeBlob::code() {
	CRCode *code = NULL;
	
	CRDiffVectorInfo seed[4];
	CRHomogeneousVec3 *line1 = NULL, *line2 = NULL, *line3 = NULL, *line4 = NULL;
	CRHomogeneousVec3 *firstCorner = NULL, *secondCorner = NULL, *thirdCorner = NULL, *fourthCorner = NULL;

	int step = 2;
	
	int diffListSize = (int)(this->elements->size() - step);
	CRDiffVectorInfo *diffList = (CRDiffVectorInfo*)malloc(sizeof(CRDiffVectorInfo) * diffListSize);
	
	int i = 0;
	
	
	std::list<CRChainCodeElement*>::iterator it = elements->begin();
	std::list<CRChainCodeElement*>::iterator it_stepped = elements->begin();
	++it_stepped;
	++it_stepped;
	while(i < diffListSize) {
		CRChainCodeElement* p = (CRChainCodeElement*)*it;
		CRChainCodeElement* p_next = (CRChainCodeElement*)*it_stepped;
		
		diffList[i].x = p->x;
		diffList[i].y = p->y;
		diffList[i].dx = p_next->x - p->x;
		diffList[i].dy = p_next->y - p->y;
		diffList[i].label = 0;
		
		++it_stepped;
		++it;
		++i;
	}
	
	// make seed for k-means
	int seedOffset = diffListSize / 8;
	int seedSampling = diffListSize / 4;
	seed[0] = diffList[seedOffset + 0 * seedSampling];
	seed[1] = diffList[seedOffset + 1 * seedSampling];
	seed[2] = diffList[seedOffset + 2 * seedSampling];
	seed[3] = diffList[seedOffset + 3 * seedSampling];
	
	if (this->elements->size() < MINIMUM_CHAINCODE_LENGTH)
		goto CODE_NOT_FOUND_EXCEPTION;
	
	for (int j = 0; j < 10; j++) {
		int labelUpdateCounter = 0;
		
		for (int i = 0; i < diffListSize; i++) {
			int newLabel = 0;
			float length = (diffList[i].dx - seed[0].dx) * (diffList[i].dx - seed[0].dx) + (diffList[i].dy - seed[0].dy) * (diffList[i].dy - seed[0].dy);
			
			for (int k = 1; k < 4; k++) {
				int temp = (diffList[i].dx - seed[k].dx) * (diffList[i].dx - seed[k].dx) + (diffList[i].dy - seed[k].dy) * (diffList[i].dy - seed[k].dy);
				if (temp < length) {
					length = temp;
					newLabel = k;
				}
			}
			
			// update label
			if (diffList[i].label != newLabel) {
				labelUpdateCounter++;
				diffList[i].label = newLabel;
			}
		}
		
		// update centroid
		int seedHistogram[4] = {0, 0, 0, 0};
		for (int k = 0; k < 4; k++) {
			seed[k].dx = 0;
			seed[k].dy = 0;
		}
		for (int i = 0; i < diffListSize; i++) {
			int k = diffList[i].label;
			seedHistogram[k]++;
			seed[k].dx += diffList[i].dx;
			seed[k].dy += diffList[i].dy;
		}
		
		// check number of elements in clusters
		if (seedHistogram[0] == 0 || seedHistogram[1] == 0 || seedHistogram[2] == 0 || seedHistogram[3] == 0)
			goto CODE_NOT_FOUND_EXCEPTION;
		
		for (int k = 0; k < 4; k++) {
			seed[k].dx /= seedHistogram[k];
			seed[k].dy /= seedHistogram[k];
		}
		
		if (labelUpdateCounter == 0)
			break;
	}
	
	line1 = CreateLineFromCRDiffVectorInfoList(diffList, diffListSize, 0);
	line2 = CreateLineFromCRDiffVectorInfoList(diffList, diffListSize, 1);
	line3 = CreateLineFromCRDiffVectorInfoList(diffList, diffListSize, 2);
	line4 = CreateLineFromCRDiffVectorInfoList(diffList, diffListSize, 3);
	
	firstCorner  = CRHomogeneousVec3::outerProduct(line4, line1);	firstCorner->normalize();
	secondCorner = CRHomogeneousVec3::outerProduct(line1, line2);	secondCorner->normalize();
	thirdCorner  = CRHomogeneousVec3::outerProduct(line2, line3);	thirdCorner->normalize();
	fourthCorner = CRHomogeneousVec3::outerProduct(line3, line4);	fourthCorner->normalize();

	if (isConvex(firstCorner, secondCorner, thirdCorner, fourthCorner) == CR_FALSE)
		goto CODE_NOT_FOUND_EXCEPTION;
	
	// chaincode search algorithm is reverse order.
	code = new CRCode(firstCorner, fourthCorner, thirdCorner, secondCorner);
	
	code->left = this->left;
	code->right= this->right;
	code->top = this->top;
	code->bottom = this->bottom;
	
CODE_NOT_FOUND_EXCEPTION:
	SAFE_DELETE(line1);
	SAFE_DELETE(line2);
	SAFE_DELETE(line3);
	SAFE_DELETE(line4);
	
	SAFE_DELETE(firstCorner);
	SAFE_DELETE(secondCorner);
	SAFE_DELETE(thirdCorner);
	SAFE_DELETE(fourthCorner);

	SAFE_FREE(diffList);
	
	return code;
}	