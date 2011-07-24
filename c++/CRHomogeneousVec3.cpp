/*
 * Core AR
 * CRHomogeneousVec3.cpp
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

#include "CRHomogeneousVec3.h"

#include <math.h>

CRHomogeneousVec3::CRHomogeneousVec3() {
//	_DPRINTF("CRHomogeneousVec3 constructor\n");
}

CRHomogeneousVec3::~CRHomogeneousVec3() {
//	_DPRINTF("CRHomogeneousVec3 destructor\n");
}

CRHomogeneousVec3* CRHomogeneousVec3::outerProduct(CRHomogeneousVec3 *p1, CRHomogeneousVec3 *p2) {
	CRHomogeneousVec3 *p = new CRHomogeneousVec3 ();
	
	p->x = p1->y * p2->w - p1->w * p2->y;
	p->y = p1->w * p2->x - p1->x * p2->w;
	p->w = p1->x * p2->y - p1->y * p2->x;
	
	return p;
}

CRHomogeneousVec3* CRHomogeneousVec3::homogeneousVec3FromChainCodeElement(CRChainCodeElement* element) {
	CRHomogeneousVec3 *p = new CRHomogeneousVec3 ();
	p->x = element->x;
	p->y = element->y;
	p->w = 1;
	return p;
}

void CRHomogeneousVec3::normalize() {
	if (fabs(this->w) > MINIMUM_VALUE) {
		this->x /= this->w;
		this->y /= this->w;
		this->w = 1;
	}
	else 
		this->w = 0;
}

void CRHomogeneousVec3::dump() {
	printf("%f,%f,%f\n", x, y, w);
}