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

CRCode::CRCode() {
	corners = new CRHomogeneousVec3 [4];
	this->firstCorner  = corners + 0;
	this->secondCorner = corners + 1;
	this->thirdCorner  = corners + 2;
	this->fourthCorner = corners + 3;
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
}

CRCode::~CRCode() {
	delete [] corners;
}

void CRCode::getHomographyMatrix() {
	
}
