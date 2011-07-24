/*
 * Core AR
 * CRChainCodeElement.cpp
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

#include "CRChainCodeElement.h"

CRChainCodeElement::CRChainCodeElement() {
//	_DPRINTF("CRChainCodeElement constructor\n");
}

CRChainCodeElement::CRChainCodeElement(int x, int y, int code) {
//	_DPRINTF("CRChainCodeElement constructor\n");
	this->x = x;
	this->y = y;
	this->code = code;
#if 0
#ifdef _DEBUG
	switch (this->code) {
		case 4:
			_DPRINTF("左\n");
			break;
		case 5:
			_DPRINTF("左下\n");
			break;
		case 6:
			_DPRINTF("下\n");
			break;
		case 7:
			_DPRINTF("右下\n");
			break;
		case 0:
			_DPRINTF("右\n");
			break;
		case 1:
			_DPRINTF("右上\n");
			break;
		case 2:
			_DPRINTF("上\n");
			break;
		case 3:
			_DPRINTF("左上\n");
			break;
		default:
			break;
	}
#endif
#endif
}

CRChainCodeElement::~CRChainCodeElement() {
//	_DPRINTF("CRChainCodeElement destructor\n");
}
