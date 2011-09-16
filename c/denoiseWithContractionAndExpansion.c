/*
 * Core AR
 * denoiseWithContractionAndExpansion.c
 *
 * Copyright (c) Yuichi YOSHIDA, 10/12/29.
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

#include "denoiseWithContractionAndExpansion.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

static unsigned char *sharedPixel = NULL;
static int sharedWidth = 0;
static int sharedHeight  = 0;

void CRDenoiseWithContractionAndExpansion(unsigned char *pixel, int width, int height) {
	
	int flagged = 1;
	
	if (sharedWidth != width || sharedHeight != height) {
		// allocation again
		if (sharedPixel)
			free(sharedPixel);		
		sharedPixel = (unsigned char*)malloc(sizeof(unsigned char) * width * height);
		sharedWidth = width;
		sharedHeight = height;
	}
	
	for (int y = 1; y < height - 1; y++) {
		for (int x = 1; x < width - 1; x++) {
			
			if (*(pixel + (x + 0) + (y + 0) * width)) {
				*(sharedPixel + x + y * width) = flagged;
				continue;
			}
			if (*(pixel + (x + 1) + (y + 0) * width)) {
				*(sharedPixel + x + y * width) = flagged;
				continue;
			}
			if (*(pixel + (x - 1) + (y + 0) * width)) {
				*(sharedPixel + x + y * width) = flagged;
				continue;
			}
			
			if (*(pixel + (x + 0) + (y + 1) * width)) {
				*(sharedPixel + x + y * width) = flagged;
				continue;
			}
			if (*(pixel + (x + 1) + (y + 1) * width)) {
				*(sharedPixel + x + y * width) = flagged;
				continue;
			}
			if (*(pixel + (x - 1) + (y + 1) * width)) {
				*(sharedPixel + x + y * width) = flagged;
				continue;
			}
			
			if (*(pixel + (x + 0) + (y - 1) * width)) {
				*(sharedPixel + x + y * width) = flagged;
				continue;
			}
			if (*(pixel + (x + 1) + (y - 1) * width)) {
				*(sharedPixel + x + y * width) = flagged;
				continue;
			}
			if (*(pixel + (x - 1) + (y - 1) * width)) {
				*(sharedPixel + x + y * width) = flagged;
				continue;
			}
			
			*(sharedPixel + x + y * width) = 0;
		}
	}
	
	for (int y = 1; y < height - 1; y++) {
		for (int x = 1; x < width - 1; x++) {
			
			if (*(sharedPixel + (x + 0) + (y + 0) * width) == 0) {
				*(pixel + x + y * width) = 0;
				continue;
			}
			if (*(sharedPixel + (x + 1) + (y + 0) * width) == 0) {
				*(pixel + x + y * width) = 0;
				continue;
			}
			if (*(sharedPixel + (x - 1) + (y + 0) * width) == 0) {
				*(pixel + x + y * width) = 0;
				continue;
			}
			
			if (*(sharedPixel + (x + 0) + (y + 1) * width) == 0) {
				*(pixel + x + y * width) = 0;
				continue;
			}
			if (*(sharedPixel + (x + 1) + (y + 1) * width) == 0) {
				*(pixel + x + y * width) = 0;
				continue;
			}
			if (*(sharedPixel + (x - 1) + (y + 1) * width) == 0) {
				*(pixel + x + y * width) = 0;
				continue;
			}
			
			if (*(sharedPixel + (x + 0) + (y - 1) * width) == 0) {
				*(pixel + x + y * width) = 0;
				continue;
			}
			if (*(sharedPixel + (x + 1) + (y - 1) * width) == 0) {
				*(pixel + x + y * width) = 0;
				continue;
			}
			if (*(sharedPixel + (x - 1) + (y - 1) * width) == 0) {
				*(pixel + x + y * width) = 0;
				continue;
			}
			
			*(pixel + x + y * width) = flagged;
		}
	}
	
}