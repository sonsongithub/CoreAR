/*
 * Core AR
 * CRChainCodeBlob.h
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

#ifdef _CRCHAINCODEBLOB_CPP_
#else
#define _CRCHAINCODEBLOB_CPP_

#include <iostream>
#include <list>

#include "CRChainCodeElement.h"
#include "CRHomogeneousVec3.h"
#include "CRCode.h"

#ifdef USE_INSIDE_CHAINCODE
typedef enum {
	CRChainCodeOutside		= 0,
	CRChainCodeInside		= 1,
}CRChainCodeType;
#endif

class CRChainCodeBlob {
public:
	int					top;
	int					bottom;
	int					left;
	int					right;
	
	std::list<CRChainCodeElement*> *elements;
#ifdef USE_INSIDE_CHAINCODE
	CRChainCodeType	type;
#endif
public:
	CRChainCodeBlob();
	~CRChainCodeBlob();
	void appendChainCodeElement(int x, int y, int code);
	void dump(void);
	int isValid(int width, int height);
	
	CRCode* code();
	CRCode* codeWithoutLSM();
	CRChainCodeElement* firstCorner(CRChainCodeElement *third);
	CRChainCodeElement* secondCorner(CRChainCodeElement *first, CRChainCodeElement *third);
	CRChainCodeElement* thirdCorner();
	CRChainCodeElement* fourthCorner(CRChainCodeElement *first, CRChainCodeElement *third);
	void reorderChaincode(CRChainCodeElement *first);
	int isConvex(CRHomogeneousVec3 *firstCorner, CRHomogeneousVec3 *secondCorner, CRHomogeneousVec3 *thirdCorner, CRHomogeneousVec3 *fourthCorner);
	
	CRHomogeneousVec3* getLineThroughPoints(CRChainCodeElement *start, CRChainCodeElement *end);
};

#endif