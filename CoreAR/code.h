/*
 * Core AR
 * code.h
 *
 * Copyright (c) Yuichi YOSHIDA, 10/12/07.
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

#ifdef _CODE_H
#else
#define _CODE_H

#include "prepro.h"
#include "chaincode.h"

typedef struct _CRCodeInfo {
	int							corner_x[4];
	int							corner_y[4];
	int							left;
	int							top;
	int							right;
	int							bottom;
	int							identifier;
	float						size;
	struct _CRCodeInfo			*next;
	struct _CRCodeInfo			*prev;
	float						p[16];
	unsigned char				*pixel;
}CRCodeInfo;

typedef struct _CRCodeInfoStorage {
	struct _CRCodeInfo			*head;
	struct _CRCodeInfo			*tail;
	int							length;
}CRCodeInfoStorage;

typedef struct _CRCodeImageTemplate {
    float               *featureVecUp;
    float               *featureVecDown;
    float               *featureVecLeft;
    float               *featureVecRight;
    
	int					code;
	float				size;
	struct _CRCodeImageTemplate *next;
}CRCodeImageTemplate;

typedef struct _CRCodeImageTemplateStorage {
	int							length;
	struct _CRCodeImageTemplate	*head;
	struct _CRCodeImageTemplate	*tail;
}CRCodeImageTemplateStorage;

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// global parameters
//
////////////////////////////////////////////////////////////////////////////////////////////////////

float CRGetXFocalLength();
void CRSetXFocalLength(float newValue);

float CRGetYFocalLength();
void CRSetYFocalLength(float newValue);

int CRGetDecodePixelBuffWidthHeight();
void CRSetDecodePixelBuffWidthHeight(int newValue);

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// code info
//
////////////////////////////////////////////////////////////////////////////////////////////////////

CRCodeInfo *CRCreateCodeInfo();
void CRReleaseCodeInfo(CRCodeInfo **codeinfo);
CRCodeInfo* CRCreateCodeInfoByParsingChainCode(CRChainCode *chaincode, unsigned char *pixel, int width, int height, CRCodeImageTemplateStorage* codeImageTemplateStorage);

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// code info storage
//
////////////////////////////////////////////////////////////////////////////////////////////////////

CRCodeInfoStorage *CRCreateCodeInfoStorage();
void CRReleaseCodeInfoStorage(CRCodeInfoStorage **storage);
void CRCodeInfoStorageReleaseAllCodeInfo(CRCodeInfoStorage *storage);
CRCodeInfoStorage* CRCreateCodeInfoStorageByExtractingFromChainCodeStorage(CRChainCodeStorage *storage, unsigned char *pixel, int width, int height, CRCodeImageTemplateStorage* codeImageTemplateStorage);
void CRCodeInfoStorageAddCodeInfoByExtractingFromChainCode(CRCodeInfoStorage *codeInfoStorage, CRChainCodeStorage *storage, unsigned char *pixel, int width, int height, CRCodeImageTemplateStorage* codeImageTemplateStorage);

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// dump
//
////////////////////////////////////////////////////////////////////////////////////////////////////

void drawCodeImageInCodeInfoStorageToPixels(CRCodeInfoStorage *storage, unsigned char *inputImageBassAddress, int width, int height);
	
#endif