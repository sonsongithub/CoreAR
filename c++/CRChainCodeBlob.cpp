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
	this->elements->push_back(element);
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

CRCode *CRChainCodeBlob::codeWithoutLSM() {
	if (this->elements->size() < MINIMUM_CHAINCODE_LENGTH)
		return NULL;
	
	CRChainCodeElement *firstCornerElement  = this->firstCorner();
	CRChainCodeElement *thirdCornerElement  = this->thirdCorner(firstCornerElement);
	CRChainCodeElement *secondCornerElement = this->secondCorner(firstCornerElement, thirdCornerElement);
	CRChainCodeElement *fourthCornerElement = this->fourthCorner(firstCornerElement, thirdCornerElement);
	
	CRHomogeneousVec3* firstCorner  = CRHomogeneousVec3::homogeneousVec3FromChainCodeElement(firstCornerElement);
	CRHomogeneousVec3* secondCorner = CRHomogeneousVec3::homogeneousVec3FromChainCodeElement(secondCornerElement);
	CRHomogeneousVec3* thirdCorner  = CRHomogeneousVec3::homogeneousVec3FromChainCodeElement(thirdCornerElement);
	CRHomogeneousVec3* fourthCorner = CRHomogeneousVec3::homogeneousVec3FromChainCodeElement(fourthCornerElement);
	
	CRCode *code = new CRCode(firstCorner, secondCorner, thirdCorner, fourthCorner);
	
	delete firstCorner;
	delete secondCorner;
	delete thirdCorner;
	delete fourthCorner;
	
	return code;
}

CRCode *CRChainCodeBlob::code() {
	if (this->elements->size() < MINIMUM_CHAINCODE_LENGTH)
		return NULL;
	
	CRChainCodeElement *firstCornerElement  = this->firstCorner();
	CRChainCodeElement *thirdCornerElement  = this->thirdCorner(firstCornerElement);
	CRChainCodeElement *secondCornerElement = this->secondCorner(firstCornerElement, thirdCornerElement);
	CRChainCodeElement *fourthCornerElement = this->fourthCorner(firstCornerElement, thirdCornerElement);
	
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
	
	// chaincode search algorithm is reverse order.
	CRCode *code = new CRCode(firstCorner, fourthCorner, thirdCorner, secondCorner);
	
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

CRChainCodeElement* CRChainCodeBlob::firstCorner() {
	return this->elements->front();
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

CRChainCodeElement* CRChainCodeBlob::thirdCorner(CRChainCodeElement *first) {
	int maxLength = 0;
	CRChainCodeElement* tempThirdCorner = NULL;
	std::list<CRChainCodeElement*>::iterator it = elements->begin();
	while(it != elements->end()) {
		CRChainCodeElement* e = (CRChainCodeElement*)*it;
		int length = (first->x - e->x) * (first->x - e->x) + (first->y - e->y) * (first->y - e->y);
		if (length > maxLength) {
			maxLength = length;
			tempThirdCorner = e;
		}
		++it;
	}
	return tempThirdCorner;
}
