/*
 * Core AR
 * codeImageTemplate.h
 *
 * Copyright (c) Yuichi YOSHIDA, 10/12/12.
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

#ifdef _codeImageTemplate_H_
#else
#define _codeImageTemplate_H_

#include "prepro.h"
#include "code.h"

#define DEFAULT_MINIMUM_MATCHING_SCORE			0.7
#define THRESHOLD_FOR_READING_TEMPLATE_IMG		100

#define DEFAULT_TEMPLATE_MATHCING_GRID_SIZE     3
#define DEFAULT_TEMPLATE_BIN_SIZE               4

typedef enum {
	TemplateOrientationUp,
	TemplateOrientationRight,
	TemplateOrientationDown,
	TemplateOrientationLeft,
}TemplateOrientation;

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// code image template storage
//
////////////////////////////////////////////////////////////////////////////////////////////////////

float CRCodeImageTemplateStorageGetSizeOfCodeID(CRCodeImageTemplateStorage *storage, int codeID);
CRCodeImageTemplateStorage *CRCreateCodeImageTemplateStorage();
void CRCodeImageTemplateStorageAddNewTemplate(CRCodeImageTemplateStorage *storage, CRCodeImageTemplate *newTemplate);
void CRCodeImageTemplateStorageEvaluateCodeImage(CRCodeImageTemplateStorage *storage, unsigned char *pixel, int width, int height, int *code, int *rotation);
void CRReleaseCodeImageTemplateStorage(CRCodeImageTemplateStorage **storage);

// setting parameters
void CRCodeImageTemplateSetMatchingThreshold(float newValue);
float CRCodeImageTemplateGetMatchingThreshold();

void CRCodeImageTemplateSetTemplateMatchingGridSize(float newValue);
int CRCodeImageTemplateGetTemplateMatchingGridSize();

void CRCodeImageTemplateSetTemplateMatchingBinSize(float newValue);
int CRCodeImageTemplateGetTemplateMatchingBinSize();

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// code image template
//
////////////////////////////////////////////////////////////////////////////////////////////////////

CRCodeImageTemplate *CRCreateCodeImageTemplate(unsigned char *pixel, int width, int height);
void CRReleaseCodeImageTemplate(CRCodeImageTemplate **aTemplate);

#endif