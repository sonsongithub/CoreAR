/*
 * Core AR
 * CRChainCode.cpp
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

#include "CRChainCode.h"

CRChainCode::CRChainCode() {
	_DPRINTF("CRChainCode constructor\n");
	blobs = new std::list<CRChainCodeBlob*> ();
}

CRChainCode::~CRChainCode() {
	_DPRINTF("CRChainCode destructor\n");
	
	std::list<CRChainCodeBlob*>::iterator it = blobs->begin();
	while(it != blobs->end()) {
		delete(*it);
		++it;
	}
	delete blobs;
}

void CRChainCode::detectCorner() {
	std::list<CRChainCodeBlob*>::iterator it = blobs->begin();
	while(it != blobs->end()) {
		CRChainCodeBlob *blob = *it;
		blob->detectCorner();
		++it;
	}
}

void CRChainCode::parsePixel(unsigned char* chaincodeFlag, int width, int height) {
	CRChainCodeBlob *blob = NULL;
	
	// cut edge pixels
	for (int x = 0; x < width; x++)
		chaincodeFlag[x + 0 * width] = CRChainCodeFlagIgnore;
	for (int x = 0; x < width; x++)
		chaincodeFlag[x + (height - 1) * width] = CRChainCodeFlagIgnore;
	for (int y = 0; y < height; y++)
		chaincodeFlag[0 + y * width] = CRChainCodeFlagIgnore;
	for (int y = 0; y < height; y++)
		chaincodeFlag[width - 1 + y * width] = CRChainCodeFlagIgnore;
	
	// start parsing
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
				
				blob = new CRChainCodeBlob();
				blobs->push_back(blob);
#ifdef USE_INSIDE_CHAINCODE
				blob->type = CRChainCodeOutside;
#endif
				
				while(1) {
#ifdef OUTPUT_IMAGE_FOR_DEBUG_WHEN_ERROR
					loop++;
#endif
					while(1) {
						if (chaincodeFlag[(cx - 1) + (cy    ) * width] && chain == 4) {
							blob->appendChainCodeElement(cx, cy, chain);
							cx--;
							chain = 3;
							prev_chain = 3;
							break;
						}
						else if (chaincodeFlag[(cx - 1) + (cy + 1) * width] && chain == 5) {
							blob->appendChainCodeElement(cx, cy, chain);
							cx--;
							cy++;
							chain = 3;
							prev_chain = 3;
							break;
						}
						else if (chaincodeFlag[(cx    ) + (cy + 1) * width] && chain == 6) {
							blob->appendChainCodeElement(cx, cy, chain);
							cy++;
							chain = 5;
							prev_chain = 5;
							break;
						}
						else if (chaincodeFlag[(cx + 1) + (cy + 1) * width] && chain == 7) {
							blob->appendChainCodeElement(cx, cy, chain);
							cx++;
							cy++;
							chain = 5;
							prev_chain = 5;
							break;
						}
						else if (chaincodeFlag[(cx + 1) + (cy    ) * width] && chain == 0) {
							blob->appendChainCodeElement(cx, cy, chain);
							cx++;
							chain = 7;
							prev_chain = 7;
							break;
						}
						// 上
						else if (chaincodeFlag[(cx + 1) + (cy - 1) * width] && chain == 1) {
							blob->appendChainCodeElement(cx, cy, chain);
							cx++;
							cy--;
							chain = 7;
							prev_chain = 7;
							break;
						}
						else if (chaincodeFlag[(cx    ) + (cy - 1) * width] && chain == 2) {
							blob->appendChainCodeElement(cx, cy, chain);
							cy--;
							chain = 1;
							prev_chain = 1;
							break;
						}
						else if (chaincodeFlag[(cx - 1) + (cy - 1) * width] && chain == 3) {
							blob->appendChainCodeElement(cx, cy, chain);
							cx--;
							cy--;
							chain = 1;
							prev_chain = 1;
							break;
						}
						chain++;
						if (chain > 7) chain = 0;
						
						if (chain == prev_chain) {
							blob->appendChainCodeElement(cx, cy, chain);
							cx = x;
							cy = y;
							break;
						}
					}
#ifdef OUTPUT_IMAGE_FOR_DEBUG_WHEN_ERROR
					if (loop > CHAIN_ERROR_LOOP_LIMIT) {
						_DPRINTF("parsing error?\n");
						break;
					}
#endif
					*(chaincodeFlag + cx + cy * width) = CRChainCodeFlagChecked;
					if (cx == x && cy == y) {
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
				CRChainCodeBlob *blob = new CRChainCodeBlob();
				blob->type = CRChainCodeInside;
				blobs->push_back(blob);
#endif				
				int prev_chain = 4;
				
				int chain = 0;
				prev_chain = chain;
				
				while(1) {
#ifdef OUTPUT_IMAGE_FOR_DEBUG_WHEN_ERROR
					loop++;
#endif
					while(1) {
						if (chaincodeFlag[(cx - 1) + (cy    ) * width] && chain == 4) {
#ifdef USE_INSIDE_CHAINCODE
							blob->appendChainCodeElement(cx, cy, chain);
#endif
							cx--;
							chain = 5;
							prev_chain = 5;
							break;
						}
						else if (chaincodeFlag[(cx - 1) + (cy + 1) * width] && chain == 5) {
#ifdef USE_INSIDE_CHAINCODE
							blob->appendChainCodeElement(cx, cy, chain);
#endif
							cx--;
							cy++;
							chain = 7;
							prev_chain = 7;
							break;
						}
						else if (chaincodeFlag[(cx    ) + (cy + 1) * width] && chain == 6) {
#ifdef USE_INSIDE_CHAINCODE
							blob->appendChainCodeElement(cx, cy, chain);
#endif
							cy++;
							chain = 7;
							prev_chain = 7;
							break;
						}
						else if (chaincodeFlag[(cx + 1) + (cy + 1) * width] && chain == 7) {
#ifdef USE_INSIDE_CHAINCODE
							blob->appendChainCodeElement(cx, cy, chain);
#endif
							cx++;
							cy++;
							chain = 1;
							prev_chain = 1;
							break;
						}
						else if (chaincodeFlag[(cx + 1) + (cy    ) * width] && chain == 0) {
#ifdef USE_INSIDE_CHAINCODE
							blob->appendChainCodeElement(cx, cy, chain);
#endif
							cx++;
							chain = 1;
							prev_chain = 1;
							break;
						}
						else if (chaincodeFlag[(cx + 1) + (cy - 1) * width] && chain == 1) {
#ifdef USE_INSIDE_CHAINCODE
							blob->appendChainCodeElement(cx, cy, chain);
#endif
							cx++;
							cy--;
							chain = 3;
							prev_chain = 3;
							break;
						}
						else if (chaincodeFlag[(cx    ) + (cy - 1) * width] && chain == 2) {
#ifdef USE_INSIDE_CHAINCODE
							blob->appendChainCodeElement(cx, cy, chain);
#endif
							cy--;
							chain = 3;
							prev_chain = 3;
							break;
						}
						else if (chaincodeFlag[(cx - 1) + (cy - 1) * width] && chain == 3) {
#ifdef USE_INSIDE_CHAINCODE
							blob->appendChainCodeElement(cx, cy, chain);
#endif
							cx--;
							cy--;
							chain = 5;
							prev_chain = 5;
							break;
						}
						chain--;
						if (chain < 0) chain = 7;
						if (chain > 7) chain = 0;
						
						if (chain == prev_chain) {
#ifdef USE_INSIDE_CHAINCODE
							blob->appendChainCodeElement(cx, cy, chain);
#endif
							cx = x;
							cy = y;
							break;
						}
					}
#ifdef OUTPUT_IMAGE_FOR_DEBUG_WHEN_ERROR
					if (loop > CHAIN_ERROR_LOOP_LIMIT) {
						_DPRINTF("parsing error?\n");
						break;
					}
#endif
					*(chaincodeFlag + cx + cy * width) = CRChainCodeFlagChecked;
					
					if (cx == x && cy == y) {
#ifdef USE_INSIDE_CHAINCODE
#endif
						break;
					}
				}
			}
		}
	}
}
