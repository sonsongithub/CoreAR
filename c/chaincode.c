/*
 * Core AR
 * chaincode.c
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "chaincode.h"
#include "common.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// for ChainCode debugging
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#ifdef OUTPUT_IMAGE_FOR_DEBUG_WHEN_ERROR
	#define CHAIN_ERROR_LOOP_LIMIT 10000
#endif

void outputPixels(unsigned char* pixel, int width, int height) {
	FILE *fp = fopen("/tmp/test.bin", "wb");
	for (int y = 0; y < height; y++)
		fwrite(pixel+ y * width, sizeof(unsigned char), width, fp);
	fclose(fp);
}

#pragma mark -
#pragma mark CRChainCodeElement

CRChainCodeElement *CRCreateChainCodeElement(int x, int y, int code) {
	CRChainCodeElement *element = (CRChainCodeElement*)malloc(sizeof(CRChainCodeElement));
	element->x = x;
	element->y = y;
	element->code = code;
	element->next = NULL;
	element->prev = NULL;
	element->cornerity = 0;
	element->s1 = 0;
	element->flag = 0;
	return element;
}

#pragma mark -
#pragma mark CRChainCode

CRChainCode *CRCreateChainCode(CRChainCodeType type) {
	CRChainCode *chaincode = (CRChainCode*)malloc(sizeof(CRChainCode));
	chaincode->left = 10000;
	chaincode->top = 10000;
	chaincode->right = 0;
	chaincode->bottom = 0;
	chaincode->width = 0;
	chaincode->height = 0;
	chaincode->head = NULL;
	chaincode->tail = NULL;
	chaincode->type = type;
	chaincode->length = 0;
	chaincode->next = NULL;
	chaincode->isCornerDetected = CR_FALSE;
	return chaincode;
}

void CRReleaseChainCode(CRChainCode **chaincode) {
	CRChainCodeElement *p = (*chaincode)->head;
	
	if (p) {
		while (1) {
			CRChainCodeElement *next = p->next;
			if (p == (*chaincode)->tail) {
				free(p);
				break;
			}
			free(p);
			p = next;
		}
	}
	
	free(*chaincode);
	*chaincode = NULL;
}

void CRChainCodeAddNewChainCodeElement(CRChainCode *chaincode, int x, int y, int code) {
	CRChainCodeElement *newTailElement = CRCreateChainCodeElement(x, y, code);
	
	if (chaincode->length == 0) {
		newTailElement->prev = newTailElement;
		newTailElement->next = newTailElement;
		
		chaincode->head = newTailElement;
		chaincode->tail = newTailElement;
	}
	else {
		newTailElement->prev = chaincode->tail;
		newTailElement->next = chaincode->head;
		
		chaincode->tail->next = newTailElement;
		chaincode->head->prev = newTailElement;
		
		chaincode->tail = newTailElement;
	}
	
	chaincode->length++;
	
	if (chaincode->left > x) {
		chaincode->left = x;
		chaincode->width = chaincode->right - chaincode->left;
	}
	else if (chaincode->right < x) {
		chaincode->right = x;
		chaincode->width = chaincode->right - chaincode->left;
	}
	if (chaincode->top > y) {
		chaincode->top = y;
		chaincode->height = chaincode->bottom - chaincode->top;
	}
	else if (chaincode->bottom < y) {
		chaincode->bottom = y;
		chaincode->height = chaincode->bottom - chaincode->top;
	}
}

#pragma mark -
#pragma mark CRChainCodeStorage

CRChainCodeStorage *CRCreateChainCodeStorage() {
	CRChainCodeStorage *storage = (CRChainCodeStorage*)malloc(sizeof(CRChainCodeStorage));
	storage->head = NULL;
	storage->tail = NULL;
	storage->length = 0;
	return storage;
}

void CRReleaseChainCodeStorage(CRChainCodeStorage **storage) {
	
	CRChainCode *p = (*storage)->head;
	if (p) {
		while (1) {
			CRChainCode *next = p->next;
			CRReleaseChainCode(&p);
			if (next == NULL)
				break;
			p = next;
		}
	}
	free(*storage);
	*storage = NULL;
}


void CRChainCodeStorageAddNewChainCode(CRChainCodeStorage *storage, CRChainCode *chaincode) {
	CRChainCode *currentTailCode = storage->tail;
	if (currentTailCode)
		currentTailCode->next = chaincode;
	if (storage->head == NULL)
		storage->head =chaincode;
	storage->tail = chaincode;
	storage->length++;
}

void CRChainCodeStorageAddNewChainCodeWithFiltering(CRChainCodeStorage *storage, CRChainCode **chaincode, float aspectRatioDiff, int minimumLength, int maximumLength) {
	float ratio = (float)(*chaincode)->width/(*chaincode)->height;
	if ((*chaincode)->length > minimumLength && (*chaincode)->length < maximumLength && fabs(ratio - 1) < aspectRatioDiff) {
		CRChainCode *currentTailCode = storage->tail;
		if (currentTailCode)
			currentTailCode->next = (*chaincode);
		if (storage->head == NULL)
			storage->head =(*chaincode);
		storage->tail = (*chaincode);
		storage->length++;
	}
	else {
		CRReleaseChainCode(chaincode);
	}
}

#pragma mark -
#pragma mark For chain code

CRChainCodeStorage *CRCreateChainCodeStorageByParsingPixel(unsigned char* chaincodeFlag, int width, int height) {
	
	CRChainCodeStorage *storage = CRCreateChainCodeStorage();
	
	// cut edge pixels
	for (int x = 0; x < width; x++)
		chaincodeFlag[x + 0 * width] = CRChainCodeFlagIgnore;
	for (int x = 0; x < width; x++)
		chaincodeFlag[x + (height - 1) * width] = CRChainCodeFlagIgnore;
	for (int y = 0; y < height; y++)
		chaincodeFlag[0 + y * width] = CRChainCodeFlagIgnore;
	for (int y = 0; y < height; y++)
		chaincodeFlag[width - 1 + y * width] = CRChainCodeFlagIgnore;
	
	for (int y = 1; y < height-1; y++) {
		for (int x = 1; x < width-1; x++) {
			
			int prev = chaincodeFlag[x-1 + y * width];
			int now = chaincodeFlag[x + y * width];
			int next = chaincodeFlag[x+1 + y * width];
			
			if (prev == CRChainCodeFlagIgnore && now == CRChainCodeFlagUnchecked) {
#ifdef OUTPUT_IMAGE_FOR_DEBUG_WHEN_ERROR
				int loop = 0;
#endif
				int cx = x;
				int cy = y;
				
				int prev_chain = 4;
				int chain = 4;
#ifdef PRINT_CHAIN_CODE
				_dprintf("0=>1 %d,%d(%d)\n", cx, cy, chain);
#endif
				
				CRChainCode *chaincode = CRCreateChainCode(CRChainCodeOutside);
				
				while(1) {
#ifdef OUTPUT_IMAGE_FOR_DEBUG_WHEN_ERROR
					loop++;
#endif
					while(1) {
						if (chaincodeFlag[(cx - 1) + (cy    ) * width] && chain == 4) {
							CRChainCodeAddNewChainCodeElement(chaincode, cx, cy, chain);
							cx--;
#ifdef PRINT_CHAIN_CODE
							_dprintf("左\n");
#endif
							chain = 3;
							prev_chain = 3;
							break;
						}
						else if (chaincodeFlag[(cx - 1) + (cy + 1) * width] && chain == 5) {
							CRChainCodeAddNewChainCodeElement(chaincode, cx, cy, chain);
							cx--;
							cy++;
#ifdef PRINT_CHAIN_CODE
							_dprintf("左下\n");
#endif
							chain = 3;
							prev_chain = 3;
							break;
						}
						else if (chaincodeFlag[(cx    ) + (cy + 1) * width] && chain == 6) {
							CRChainCodeAddNewChainCodeElement(chaincode, cx, cy, chain);
							cy++;
#ifdef PRINT_CHAIN_CODE
							_dprintf("下\n");
#endif
							chain = 5;
							prev_chain = 5;
							break;
						}
						else if (chaincodeFlag[(cx + 1) + (cy + 1) * width] && chain == 7) {
							CRChainCodeAddNewChainCodeElement(chaincode, cx, cy, chain);
							cx++;
							cy++;
#ifdef PRINT_CHAIN_CODE
							_dprintf("右下\n");
#endif
							chain = 5;
							prev_chain = 5;
							break;
						}
						else if (chaincodeFlag[(cx + 1) + (cy    ) * width] && chain == 0) {
							CRChainCodeAddNewChainCodeElement(chaincode, cx, cy, chain);
							cx++;
#ifdef PRINT_CHAIN_CODE
							_dprintf("右\n");
#endif
							chain = 7;
							prev_chain = 7;
							break;
						}
						// 上
						else if (chaincodeFlag[(cx + 1) + (cy - 1) * width] && chain == 1) {
							CRChainCodeAddNewChainCodeElement(chaincode, cx, cy, chain);
							cx++;
							cy--;
#ifdef PRINT_CHAIN_CODE
							//printf("上\n");
#endif
							chain = 7;
							prev_chain = 7;
							break;
						}
						else if (chaincodeFlag[(cx    ) + (cy - 1) * width] && chain == 2) {
							CRChainCodeAddNewChainCodeElement(chaincode, cx, cy, chain);
							cy--;
#ifdef PRINT_CHAIN_CODE
							_dprintf("上\n");
#endif
							chain = 1;
							prev_chain = 1;
							break;
						}
						else if (chaincodeFlag[(cx - 1) + (cy - 1) * width] && chain == 3) {
							CRChainCodeAddNewChainCodeElement(chaincode, cx, cy, chain);
							cx--;
							cy--;
#ifdef PRINT_CHAIN_CODE
							_dprintf("左上\n");
#endif
							chain = 1;
							prev_chain = 1;
							break;
						}
						chain++;
						if (chain > 7) chain = 0;
						
						if (chain == prev_chain) {
							CRChainCodeAddNewChainCodeElement(chaincode, cx, cy, chain);
							cx = x;
							cy = y;
							break;
						}
					}
#ifdef OUTPUT_IMAGE_FOR_DEBUG_WHEN_ERROR
					if (loop > CHAIN_ERROR_LOOP_LIMIT) {
						// parsing error?
						outputPixels(pixel, width, height);
						releaseChainCode(&chaincode);
						break;
					}
#endif
					*(chaincodeFlag + cx + cy * width) = CRChainCodeFlagChecked;
					
					if (cx == x && cy == y) {
						CRChainCodeStorageAddNewChainCodeWithFiltering(storage, &chaincode, DEFAULT_ASPECT_RATIO_MARGIN, DEFAULT_MINIMUM_CHAINCODE_LENGTH, DEFAULT_MAXIMUM_CHAINCODE_LENGTH);
						break;
					}
				}
			}
			
			if (now == 1 && next == 0) {
#ifdef OUTPUT_IMAGE_FOR_DEBUG_WHEN_ERROR
				int loop = 0;
#endif			
				// chain code
				int cx = x;
				int cy = y;
				
#ifdef USE_INSIDE_CHAINCODE
				ChainCode *chaincode = createChainCode(ChainCodeInside);
#endif				
				int prev_chain = 4;
				
				int chain = 0;
#ifdef PRINT_CHAIN_CODE
				_dprintf("1=>0 %d,%d(%d)\n", cx, cy, chain);
#endif
				prev_chain = chain;
				
				while(1) {
#ifdef OUTPUT_IMAGE_FOR_DEBUG_WHEN_ERROR
					loop++;
#endif
					while(1) {
						if (chaincodeFlag[(cx - 1) + (cy    ) * width] && chain == 4) {
#ifdef USE_INSIDE_CHAINCODE
							addNewChainCodeElement(chaincode, cx, cy, chain);
#endif
							cx--;
#ifdef PRINT_CHAIN_CODE
							_dprintf("左\n");
#endif
							chain = 5;
							prev_chain = 5;
							break;
						}
						else if (chaincodeFlag[(cx - 1) + (cy + 1) * width] && chain == 5) {
#ifdef USE_INSIDE_CHAINCODE
							addNewChainCodeElement(chaincode, cx, cy, chain);
#endif
							cx--;
							cy++;
#ifdef PRINT_CHAIN_CODE
							_dprintf("左下\n");
#endif
							chain = 7;
							prev_chain = 7;
							break;
						}
						else if (chaincodeFlag[(cx    ) + (cy + 1) * width] && chain == 6) {
#ifdef USE_INSIDE_CHAINCODE
							addNewChainCodeElement(chaincode, cx, cy, chain);
#endif
							cy++;
#ifdef PRINT_CHAIN_CODE
							_dprintf("下\n");
#endif
							chain = 7;
							prev_chain = 7;
							break;
						}
						else if (chaincodeFlag[(cx + 1) + (cy + 1) * width] && chain == 7) {
#ifdef USE_INSIDE_CHAINCODE
							addNewChainCodeElement(chaincode, cx, cy, chain);
#endif
							cx++;
							cy++;
#ifdef PRINT_CHAIN_CODE
							_dprintf("右下\n");
#endif
							chain = 1;
							prev_chain = 1;
							break;
						}
						else if (chaincodeFlag[(cx + 1) + (cy    ) * width] && chain == 0) {
#ifdef USE_INSIDE_CHAINCODE
							addNewChainCodeElement(chaincode, cx, cy, chain);
#endif
							cx++;
							chain = 1;
							prev_chain = 1;
#ifdef PRINT_CHAIN_CODE
							_dprintf("右\n");
#endif
							break;
						}
						else if (chaincodeFlag[(cx + 1) + (cy - 1) * width] && chain == 1) {
#ifdef USE_INSIDE_CHAINCODE
							addNewChainCodeElement(chaincode, cx, cy, chain);
#endif
							cx++;
							cy--;
#ifdef PRINT_CHAIN_CODE
							_dprintf("右上\n");
#endif
							chain = 3;
							prev_chain = 3;
							break;
						}
						else if (chaincodeFlag[(cx    ) + (cy - 1) * width] && chain == 2) {
#ifdef USE_INSIDE_CHAINCODE
							addNewChainCodeElement(chaincode, cx, cy, chain);
#endif
							cy--;
#ifdef PRINT_CHAIN_CODE
							_dprintf("上\n");
#endif
							chain = 3;
							prev_chain = 3;
							break;
						}
						else if (chaincodeFlag[(cx - 1) + (cy - 1) * width] && chain == 3) {
#ifdef USE_INSIDE_CHAINCODE
							addNewChainCodeElement(chaincode, cx, cy, chain);
#endif
							cx--;
							cy--;
#ifdef PRINT_CHAIN_CODE
							_dprintf("左上\n");
#endif
							chain = 5;
							prev_chain = 5;
							break;
						}
						chain--;
						if (chain < 0) chain = 7;
						if (chain > 7) chain = 0;
						
						if (chain == prev_chain) {
#ifdef USE_INSIDE_CHAINCODE
							addNewChainCodeElement(chaincode, cx, cy, chain);
#endif
							cx = x;
							cy = y;
							break;
						}
					}
#ifdef OUTPUT_IMAGE_FOR_DEBUG_WHEN_ERROR
					if (loop > CHAIN_ERROR_LOOP_LIMIT) {
						// parsing error?
						outputPixels(pixel, width, height);
						releaseChainCode(&chaincode);
						break;
					}
#endif
					*(chaincodeFlag + cx + cy * width) = CRChainCodeFlagChecked;
					
					if (cx == x && cy == y) {
#ifdef USE_INSIDE_CHAINCODE
						addNewChainCodeWithFiltering(storage, &chaincode, DEFAULT_ASPECT_RATIO_MARGIN, DEFAULT_MINIMUM_CHAINCODE_LENGTH, DEFAULT_MAXIMUM_CHAINCODE_LENGTH);
#endif
						break;
					}
				}
			}
		}
	}
	
	return storage;
}
