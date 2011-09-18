/*
 * Core AR
 * chaincode.h
 *
 * Copyright (c) Yuichi YOSHIDA, 10/11/30.
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

#ifdef _CHAINCODE_H_
#else
#define _CHAINCODE_H_

#include "prepro.h"

#define DEFAULT_MINIMUM_CHAINCODE_LENGTH	30
#define DEFAULT_MAXIMUM_CHAINCODE_LENGTH	1000
#define DEFAULT_ASPECT_RATIO_MARGIN			1.0

typedef enum {
	CRChainCodeOutside		= 0,
	ChainCodeInside			= 1,
}CRChainCodeType;

typedef enum {
	CRChainCodeFlagIgnore	= 0,
	CRChainCodeFlagUnchecked= 1,
	CRChainCodeFlagChecked	= 2,
}CRChainCodeFlagType;

typedef enum {
	CRChainCodeNonCorner	= 0,
	CRChainCodeCorner		= 1,
}CRChainCodeCornerFlag;

typedef struct _CRChainCodeElement {
	int							x;
	int							y;
	int							code;
	int							flag;
	float						cornerity;
	float						s1;
	struct _CRChainCodeElement	*next;
	struct _CRChainCodeElement	*prev;
}CRChainCodeElement;

typedef struct _CRChainCode {
	int							left;
	int							top;
	int							right;
	int							bottom;
	int							length;
	int							width;
	int							height;
	CRChainCodeType				type;
	struct _CRChainCodeElement	*head;
	struct _CRChainCodeElement	*tail;
	
	int							isCornerDetected;
	float						cornersX[4];
	float						cornersY[4];
	
	struct _CRChainCode			*next;
}CRChainCode;

typedef struct _CRChainCodeStorage {
	struct _CRChainCode			*head;
	struct _CRChainCode			*tail;
	int							length;
}CRChainCodeStorage;


////////////////////////////////////////////////////////////////////////////////////////////////////
//
// ChainCode Tool
//
////////////////////////////////////////////////////////////////////////////////////////////////////

// chaincode element

CRChainCodeElement *CRCreateChainCodeElement(int x, int y, int code);

// chaincode

CRChainCode *CRCreateChainCode(CRChainCodeType type);
void CRChainCodeAddNewChainCodeElement(CRChainCode *chaincode, int x, int y, int code);
void CRReleaseChainCode(CRChainCode **chaincode);

// chaincode storage

CRChainCodeStorage *CRCreateChainCodeStorage(void);
void CRReleaseChainCodeStorage(CRChainCodeStorage **storage);
void CRChainCodeStorageAddNewChainCode(CRChainCodeStorage *storage, CRChainCode *chaincode);
void CRChainCodeStorageAddNewChainCodeWithFiltering(CRChainCodeStorage *storage, CRChainCode **chaincode, float aspectRatioDiff, int minimumLength, int maximumLength);

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Extract chain code
//
////////////////////////////////////////////////////////////////////////////////////////////////////

CRChainCodeStorage *CRCreateChainCodeStorageByParsingPixel(unsigned char* chaincodeFlag, int width, int height);

#endif