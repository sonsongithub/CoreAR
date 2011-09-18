/*
 * Core AR
 * codeImageTemplate.c
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

#include "codeImageTemplate.h"

#include "common.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

static float sharedTemplateMatchingThresholed = DEFAULT_MINIMUM_MATCHING_SCORE;

static int sharedTemplateMatchingGridSize = DEFAULT_TEMPLATE_MATHCING_GRID_SIZE;
static int sharedTemplateMatchingBinSize = DEFAULT_TEMPLATE_BIN_SIZE;

#pragma mark - Prototype

float _CRCodeImageTamplateStorageGetMatchingScoreBetweenSubAreas(unsigned char *inputImage, unsigned char *template, int offsetX, int offsetY, int rangeX, int rangeY, int width, int height);
float _CRCodeImageTamplateStorageGetMatchingScore(unsigned char *inputImage, unsigned char *template, int width, int height);
void _CRCodeImageTamplateStorageVoteToBin(unsigned char *template, int offsetX, int offsetY, int rangeX, int rangeY, int width, int height, int binSize, float *featureVec);
float* _CRCodeImageTamplateStorageCreateFeatureVector(unsigned char *template, int width, int height, int gridSize, int binSize);
float dotProduct(float *vec1, float *vec2, int size);

#pragma mark Implementation

void CRCodeImageTemplateSetMatchingThreshold(float newValue) {
	sharedTemplateMatchingThresholed = newValue;
}

float CRCodeImageTemplateGetMatchingThreshold() {
	return sharedTemplateMatchingThresholed;
}

void CRCodeImageTemplateSetTemplateMatchingGridSize(float newValue) {
	sharedTemplateMatchingGridSize = newValue;
}

int CRCodeImageTemplateGetTemplateMatchingGridSize() {
	return sharedTemplateMatchingGridSize;
}

void CRCodeImageTemplateSetTemplateMatchingBinSize(float newValue) {
	sharedTemplateMatchingBinSize = newValue;
}

int CRCodeImageTemplateGetTemplateMatchingBinSize() {
	return sharedTemplateMatchingBinSize;
}

CRCodeImageTemplateStorage *CRCreateCodeImageTemplateStorage() {
	CRCodeImageTemplateStorage *storage = (CRCodeImageTemplateStorage*)malloc(sizeof(CRCodeImageTemplateStorage));
	
	storage->head = NULL;
	storage->tail = NULL;
	storage->length = 0;
	
	return storage;
}

void CRReleaseCodeImageTemplate(CRCodeImageTemplate **p) {
	if ((*p)->featureVecUp)
		free((*p)->featureVecUp);
	if ((*p)->featureVecDown)
		free((*p)->featureVecDown);
	if ((*p)->featureVecLeft)
		free((*p)->featureVecLeft);
	if ((*p)->featureVecRight)
		free((*p)->featureVecRight);
    
    free(*p);
    *p = NULL;
}

void CRReleaseCodeImageTemplateStorage(CRCodeImageTemplateStorage **storage) {
    CRCodeImageTemplate *p = (*storage)->head;
	while (p) {
        CRCodeImageTemplate *next = p->next;
        CRReleaseCodeImageTemplate(&p);
		if (next == NULL) {
			break;
		}
		p = next;
	}
    
    free(*storage);
    *storage = NULL;
}

void CRCodeImageTemplateStorageAddNewTemplate(CRCodeImageTemplateStorage *storage, CRCodeImageTemplate *newTemplate) {
	if (storage->head == NULL)
		storage->head = newTemplate;
	if (storage->tail == NULL)
		storage->tail = newTemplate;
	else {
		storage->tail->next = newTemplate;
		storage->tail = newTemplate;
	}
	storage->length++;
}

float CRCodeImageTemplateStorageGetSizeOfCodeID(CRCodeImageTemplateStorage *storage, int codeID) {
	CRCodeImageTemplate *p = storage->head;
	while (p) {
		if (p->code == codeID)
			return p->size;
		if (p->next == NULL) {
			break;
		}
		p = p->next;
	}
	return -1;
}

float _CRCodeImageTamplateStorageGetMatchingScoreBetweenSubAreas(unsigned char *inputImage, unsigned char *template, int offsetX, int offsetY, int rangeX, int rangeY, int width, int height) {
    float matchingScore = 0;
    for (int y = offsetY; y < offsetY + rangeY; y++) {
        for (int x = offsetX; x < offsetX + rangeX; x++) {
            if (inputImage[x + y * width] == template[x + y * width]) {
                matchingScore = matchingScore + 1;
            }
        }
    }
    return matchingScore;
}

float _CRCodeImageTamplateStorageGetMatchingScore(unsigned char *inputImage, unsigned char *template, int width, int height) {
    
    int grids = 9;
	int rangeX = width / grids;
	int rangeY = height/ grids;
	
	float *score = (float*)malloc(sizeof(float) * grids * grids);
	float *p = score;
    
    for (int i = 0; i < grids; i++) {
        for (int j = 0; j < grids; j++) {
			int offsetX = j * rangeX;
			int offsetY = i * rangeY;
			*p = _CRCodeImageTamplateStorageGetMatchingScoreBetweenSubAreas(
																				  inputImage, template, 
																				  offsetX, offsetY,
																				  rangeX, rangeY,
																				  width, height);
			*p = *p / (float)(rangeX * rangeY);
			p++;
		}
    }
	
	float scoreLength = 0;
	
	for (int i = 0; i < grids * grids; i++) {
		scoreLength += (score[i] * score[i]);
	}
	
	free(score);
	
    return sqrtf(scoreLength)/grids;
}

void _CRCodeImageTamplateStorageVoteToBin(unsigned char *template, int offsetX, int offsetY, int rangeX, int rangeY, int width, int height, int binSize, float *featureVec) {
    int step = 256 / binSize;
    for (int y = offsetY; y < offsetY + rangeY; y++) {
        for (int x = offsetX; x < offsetX + rangeX; x++) {
			
//			int p = template[x + y * width] > 120 ? 255 : 0;
			
			int p = template[x + y * width];
			
            int binNum = p / step;
			featureVec[binNum] += 1;
        }
    }
}

float* _CRCodeImageTamplateStorageCreateFeatureVector(unsigned char *template, int width, int height, int gridSize, int binSize) {
	float *vec = (float*)malloc(sizeof(float) * gridSize * gridSize * binSize);
	
	for (int i = 0; i < gridSize * gridSize * binSize; i++)
		vec[i] = 0;
    
	int rangeX = width / gridSize;
	int rangeY = height/ gridSize;
    
    for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
			int offsetX = j * rangeX;
			int offsetY = i * rangeY;
            float *p = vec + (i * gridSize + j) * binSize; 
            _CRCodeImageTamplateStorageVoteToBin(template, offsetX, offsetY, rangeX, rangeY, width, height, binSize, p);
		}
    }
	
	float norm2 = 0;
	
	for (int i = 0; i < gridSize * gridSize * binSize; i++)
		norm2 += (vec[i] * vec[i]);
	norm2 = sqrt(norm2);
	for (int i = 0; i < gridSize * gridSize * binSize; i++)
		vec[i] = vec[i] / norm2;
	
    return vec;
}

float dotProduct(float *vec1, float *vec2, int size) {
	float d = 0;
	for (int i = 0; i < size; i++)
		d += (*(vec1+i) * *(vec2+i));
	return d;
}

void CRCodeImageTemplateStorageEvaluateCodeImage(CRCodeImageTemplateStorage *storage, unsigned char *pixel, int width, int height, int *code, int *rotation) {
	CRCodeImageTemplate *p = (storage)->head;

#ifdef DEBUG_TEMPLATE_MATCHING
	printf("------------------------------------------->Read code image\n");
	for (int y = 0; y < DECODE_PIXEL_BUFFER; y++) {
		for (int x = 0; x < DECODE_PIXEL_BUFFER; x++) {
			printf("%2x ", pixel[x + y * DECODE_PIXEL_BUFFER]);
		}
		printf("\n");
	}
#endif
	
	float currentScore = -1;
	int decodePixelBuff = CRGetDecodePixelBuffWidthHeight();
	int gridSize = CRCodeImageTemplateGetTemplateMatchingGridSize();
	int binSize = CRCodeImageTemplateGetTemplateMatchingBinSize();
	
	float matchinThreshold = CRCodeImageTemplateGetMatchingThreshold();
	
	int vecSize = gridSize * gridSize * binSize;
	float *vec = _CRCodeImageTamplateStorageCreateFeatureVector(pixel, decodePixelBuff, decodePixelBuff, gridSize, binSize);

	while (p) {
		float dUp = dotProduct(vec, p->featureVecUp, vecSize);
		float dRight = dotProduct(vec, p->featureVecRight, vecSize);
		float dDown = dotProduct(vec, p->featureVecDown, vecSize);
		float dLeft = dotProduct(vec, p->featureVecLeft, vecSize);
		
		if (dUp > matchinThreshold) {
			if (dUp > currentScore) {
				*code = p->code;
				*rotation = TemplateOrientationUp;
				currentScore = dUp;
			}
		}
		if (dRight > matchinThreshold) {
			if (dRight > currentScore) {
				*code = p->code;
				*rotation = TemplateOrientationRight;
				currentScore = dRight;
			}
		}
		if (dDown > matchinThreshold) {
			if (dDown > currentScore) {
				*code = p->code;
				*rotation = TemplateOrientationDown;
				currentScore = dDown;
			}
		}
		if (dLeft > matchinThreshold) {
			if (dLeft > currentScore) {
				*code = p->code;
				*rotation = TemplateOrientationLeft;
				currentScore = dLeft;
			}
		}
		
		if (p->next == NULL)
			break;
		p = p->next;
	}
	
	free(vec);
	
	return;
}

CRCodeImageTemplate *CRCreateCodeImageTemplate(unsigned char *pixel, int width, int height) {
	
	CRCodeImageTemplate *p = (CRCodeImageTemplate*)malloc(sizeof(CRCodeImageTemplate));
	
	float offsetX = width / 4;
	float offsetY = height / 4;
	
	int decodePixelBuff = CRGetDecodePixelBuffWidthHeight();
	
	float samplingWidth = (float)width / 2 / (decodePixelBuff);
	float samplingHeight = (float)height/ 2 / (decodePixelBuff);
	
	p->next = NULL;
	p->code = 0;
	
	unsigned char *b = (unsigned char*)malloc(sizeof(unsigned char) * decodePixelBuff * decodePixelBuff);
	
	for (int y = 0; y < decodePixelBuff; y++) {
		for (int x = 0; x < decodePixelBuff; x++) {
			b[(x) + (y) * decodePixelBuff] = pixel[(int)(x * samplingWidth + offsetX) + (int)(y * samplingHeight + offsetY) * width];
		}
	}
	
	int gridSize = CRCodeImageTemplateGetTemplateMatchingGridSize();
	int binSize = CRCodeImageTemplateGetTemplateMatchingBinSize();
	
	float *vec = _CRCodeImageTamplateStorageCreateFeatureVector(b, decodePixelBuff, decodePixelBuff, gridSize, binSize);
	
	p->featureVecUp = (float*)malloc(sizeof(float) * gridSize * gridSize * binSize);
	p->featureVecRight = (float*)malloc(sizeof(float) * gridSize * gridSize * binSize);
	p->featureVecDown = (float*)malloc(sizeof(float) * gridSize * gridSize * binSize);
	p->featureVecLeft = (float*)malloc(sizeof(float) * gridSize * gridSize * binSize);
	
	for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
            float *source = vec + (i * gridSize + j) * binSize; 
			
			float *destUp	= p->featureVecUp	+ (i + j * gridSize) * binSize; 
			float *destRight= p->featureVecRight+ ((gridSize - 1 - j) + i * gridSize) * binSize; 
			float *destDown	= p->featureVecDown + ((gridSize - 1 - i) + (gridSize - 1 - j) * gridSize) * binSize; 
			float *destLeft	= p->featureVecLeft + (j + (gridSize - 1 - i) * gridSize) * binSize; 
			
			for (int k = 0; k < binSize; k++) {
				*(destUp+k) = *(source+k);
				*(destRight+k) = *(source+k);
				*(destDown+k) = *(source+k);
				*(destLeft+k) = *(source+k);
			}
		}
    }
	
	free(b);
	free(vec);
	return p;
}