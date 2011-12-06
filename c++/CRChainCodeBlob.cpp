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

CRHomogeneousVec3* CRChainCodeBlob::getLineThroughPoints(CRChainCodeElement *start, CRChainCodeElement *end) {
	float sigma_x = 0;
	float sigma_y = 0;
	float sigma_xy = 0;
	float sigma_xx = 0;
	int n = 0;
	
	std::list<CRChainCodeElement*>::iterator it = elements->begin();
	while(it != elements->end()) {
		CRChainCodeElement* e = (CRChainCodeElement*)*it;
		if (e == start)
			break;
		++it;
	}
	while(it != elements->end()) {
		CRChainCodeElement* e = (CRChainCodeElement*)*it;
		
		sigma_x += e->x;
		sigma_y += e->y;
		sigma_xy += (e->x * e->y);
		sigma_xx += (e->x * e->x);
		
		n++;
		
		if (e == end)
			break;
		
		++it;
	}
	
	CRHomogeneousVec3 *line = new CRHomogeneousVec3();
	
	float t = n * sigma_xx - sigma_x * sigma_x;
	if (t == 0) {
		line->x = -1;
		line->y = 0;
		line->w = start->x;
	}
	else {
		line->x = (n * sigma_xy - sigma_x * sigma_y) / t;
		line->y = -1;
		line->w = (sigma_xx * sigma_y- sigma_xy * sigma_x) / t;
	}
	
	return line;
}

int CRChainCodeBlob::isConvex(CRHomogeneousVec3 *firstCorner, CRHomogeneousVec3 *secondCorner, CRHomogeneousVec3 *thirdCorner, CRHomogeneousVec3 *fourthCorner) {

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

CRCode *CRChainCodeBlob::codeWithoutLSM() {
	if (this->elements->size() < MINIMUM_CHAINCODE_LENGTH)
		return NULL;
	
	CRChainCodeElement *thirdCornerElement  = this->thirdCorner();
	CRChainCodeElement *firstCornerElement  = this->firstCorner(thirdCornerElement);
	
	this->reorderChaincode(firstCornerElement);
	
	CRChainCodeElement *secondCornerElement = this->secondCorner(firstCornerElement, thirdCornerElement);
	CRChainCodeElement *fourthCornerElement = this->fourthCorner(firstCornerElement, thirdCornerElement);
	
	if (!firstCornerElement || !thirdCornerElement || !secondCornerElement || !fourthCornerElement)
		return NULL;
	
	CRHomogeneousVec3* firstCorner  = CRHomogeneousVec3::homogeneousVec3FromChainCodeElement(firstCornerElement);
	CRHomogeneousVec3* secondCorner = CRHomogeneousVec3::homogeneousVec3FromChainCodeElement(secondCornerElement);
	CRHomogeneousVec3* thirdCorner  = CRHomogeneousVec3::homogeneousVec3FromChainCodeElement(thirdCornerElement);
	CRHomogeneousVec3* fourthCorner = CRHomogeneousVec3::homogeneousVec3FromChainCodeElement(fourthCornerElement);
	
	if (this->isConvex(firstCorner, secondCorner, thirdCorner, fourthCorner) == CR_FALSE)
		return NULL;
	
	// chaincode search algorithm is reverse order.
	CRCode *code = new CRCode(firstCorner, fourthCorner, thirdCorner, secondCorner);
	
	code->left = this->left;
	code->right= this->right;
	code->top = this->top;
	code->bottom = this->bottom;
	
	delete firstCorner;
	delete secondCorner;
	delete thirdCorner;
	delete fourthCorner;
	
	return code;
}

CRCode *CRChainCodeBlob::code() {
	if (this->elements->size() < MINIMUM_CHAINCODE_LENGTH)
		return NULL;
	
	CRChainCodeElement *thirdCornerElement  = this->thirdCorner();
	CRChainCodeElement *firstCornerElement  = this->firstCorner(thirdCornerElement);
	
	this->reorderChaincode(firstCornerElement);
	
	CRChainCodeElement *secondCornerElement = this->secondCorner(firstCornerElement, thirdCornerElement);
	CRChainCodeElement *fourthCornerElement = this->fourthCorner(firstCornerElement, thirdCornerElement);
	
	if (!firstCornerElement || !thirdCornerElement || !secondCornerElement || !fourthCornerElement)
		return NULL;
	
	CRHomogeneousVec3 *line1 = this->getLineThroughPoints(firstCornerElement, secondCornerElement);
	CRHomogeneousVec3 *line2 = this->getLineThroughPoints(secondCornerElement, thirdCornerElement);
	CRHomogeneousVec3 *line3 = this->getLineThroughPoints(thirdCornerElement, fourthCornerElement);
	CRHomogeneousVec3 *line4 = this->getLineThroughPoints(fourthCornerElement, firstCornerElement);
	
	CRHomogeneousVec3* firstCorner  = CRHomogeneousVec3::outerProduct(line4, line1);
	CRHomogeneousVec3* secondCorner = CRHomogeneousVec3::outerProduct(line1, line2);
	CRHomogeneousVec3* thirdCorner  = CRHomogeneousVec3::outerProduct(line2, line3);
	CRHomogeneousVec3* fourthCorner = CRHomogeneousVec3::outerProduct(line3, line4);
	
	firstCorner->normalize();
	secondCorner->normalize();
	thirdCorner->normalize();
	fourthCorner->normalize();
	
	if (this->isConvex(firstCorner, secondCorner, thirdCorner, fourthCorner) == CR_FALSE)
		return NULL;
	
	// chaincode search algorithm is reverse order.
	CRCode *code = new CRCode(firstCorner, fourthCorner, thirdCorner, secondCorner);
	
	code->left = this->left;
	code->right= this->right;
	code->top = this->top;
	code->bottom = this->bottom;
	
	delete line1;
	delete line2;
	delete line3;
	delete line4;
	
	delete firstCorner;
	delete secondCorner;
	delete thirdCorner;
	delete fourthCorner;
	
	return code;
}

void CRChainCodeBlob::reorderChaincode(CRChainCodeElement *first) {
	std::list<CRChainCodeElement*> *reorderedElements = new std::list<CRChainCodeElement*>();
	
	std::list<CRChainCodeElement*>::iterator it = elements->begin();
	while(it != elements->end()) {
		if (*it == first)
			break;
		++it;
	}
	while(it != elements->end()) {
		reorderedElements->push_back(*it);
		++it;
	}
	it = elements->begin();
	while(it != elements->end()) {
		if (*it == first)
			break;
		reorderedElements->push_back(*it);
		++it;
	}
	delete elements;
	elements = reorderedElements;
}

CRChainCodeElement* CRChainCodeBlob::firstCorner(CRChainCodeElement *third) {
	int maxLength = 0;
	CRChainCodeElement* tempFirstCorner = NULL;
	std::list<CRChainCodeElement*>::iterator it = elements->begin();
	while(it != elements->end()) {
		CRChainCodeElement* e = (CRChainCodeElement*)*it;
		int length = (third->x - e->x) * (third->x - e->x) + (third->y - e->y) * (third->y - e->y);
		if (length > maxLength) {
			maxLength = length;
			tempFirstCorner = e;
		}
		++it;
	}
	return tempFirstCorner;
}

CRChainCodeElement* CRChainCodeBlob::secondCorner(CRChainCodeElement *first, CRChainCodeElement *third) {
	float a = - (float)(third->y - first->y) / (third->x - first->x);
	float b = 1;
	float c = - a * first->x - first->y;
	float maxLength = 0;
	
	CRChainCodeElement* tempSecondCorner = NULL;
	std::list<CRChainCodeElement*>::iterator it = elements->begin();
	++it;
	while(it != elements->end()) {
		CRChainCodeElement* e = (CRChainCodeElement*)*it;
		
		if (e == third)
			break;
		
		float temp = fabs(a * e->x + b * e->y + c);
		
		if (temp > maxLength) {
			maxLength = temp;
			tempSecondCorner = e;
		}
		++it;
	}
	return tempSecondCorner;
}

CRChainCodeElement* CRChainCodeBlob::fourthCorner(CRChainCodeElement *first, CRChainCodeElement *third) {
	float a = - (float)(third->y - first->y) / (third->x - first->x);
	float b = 1;
	float c = - a * first->x - first->y;
	float maxLength = 0;
	
	CRChainCodeElement* tempThirdCorner = NULL;
	std::list<CRChainCodeElement*>::iterator it = elements->begin();
	while(it != elements->end()) {
		CRChainCodeElement* e = (CRChainCodeElement*)*it;
		if (e == third)
			break;
		++it;
	}
	while(it != elements->end()) {
		CRChainCodeElement* e = (CRChainCodeElement*)*it;
		
		float temp = fabs(a * e->x + b * e->y + c);
		
		if (temp > maxLength) {
			maxLength = temp;
			tempThirdCorner = e;
		}
		++it;
	}
	return tempThirdCorner;
}

CRChainCodeElement* CRChainCodeBlob::thirdCorner() {
	
	int maxLength = 0;
	CRChainCodeElement* tempThirdCorner = NULL;
	std::list<CRChainCodeElement*>::iterator it = elements->begin();
	while(it != elements->end()) {
		CRChainCodeElement* e = (CRChainCodeElement*)*it;
		int length = (e->x) * (e->x) + (e->y) * (e->y);
		if (length > maxLength) {
			maxLength = length;
			tempThirdCorner = e;
		}
		++it;
	}
	return tempThirdCorner;
}
