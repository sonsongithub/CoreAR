/*
 * Core AR
 * corner.c
 *
 * Copyright (c) Yuichi YOSHIDA, 10/12/02.
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

#include "corner.h"

#pragma mark - Prototype

void _CRGetIntersectionBetweenTwoLines(float *a1, float *b1, float *c1, float *a2, float *b2, float *c2, float *x, float *y);
void _CRGetLineThroughPointsOnEdge(float *a, float *b, float *c, int *n, CRChainCodeElement *start, CRChainCodeElement *end);
int _CRChainCodeGetLengthBetweenTwoElements(CRChainCodeElement *start, CRChainCodeElement *head, CRChainCodeElement *terminater);
BOOL _CRChainCodeCheckEdgeLength(CRChainCode *source, CRChainCodeElement *firstCorner, CRChainCodeElement *secondCorner, CRChainCodeElement *thirdCorner, CRChainCodeElement *fourthCorner, int *lengthes);
void _CRChainCodeDetectCorners(CRChainCode *p, int withLSM);

#pragma mark - Private method

void _CRGetIntersectionBetweenTwoLines(float *a1, float *b1, float *c1, float *a2, float *b2, float *c2, float *x, float *y) {
	// |a1 -c1| |x| |-b1|
	// |a2 -c2| |y|=|-b2|

	float determinant = 1.0/(*a1 * (-*c2) - (-*c1) * *a2);
	
	float inv11 = -*c2;
	float inv12 =  *c1;
	float inv21 = -*a2;
	float inv22 =  *a1;
	
	*x = (inv11 * (-*b1) + inv12 * (-*b2)) * determinant;
	*y = (inv21 * (-*b1) + inv22 * (-*b2)) * determinant;
}

void _CRGetLineThroughPointsOnEdge(float *a, float *b, float *c, int *n, CRChainCodeElement *start, CRChainCodeElement *end) {
	float sigma_x = 0;
	float sigma_y = 0;
	float sigma_xy = 0;
	float sigma_xx = 0;
	*n = 0;
	
	CRChainCodeElement *e = start->next;
	if (e) {
		while (1) {
			
			sigma_x += e->x;
			sigma_y += e->y;
			sigma_xy += (e->x * e->y);
			sigma_xx += (e->x * e->x);
			
			(*n)++;
			
			if (e->next == end->prev)
				break;
			e = e->next;
		}
	}
	
	float t = (*n) * sigma_xx - sigma_x * sigma_x;
	if (t == 0) {
		*a = -1;
		*b = start->x;
		*c = 0;
	}
	else {
		*a = ((*n) * sigma_xy - sigma_x * sigma_y) / t;
		*b = (sigma_xx * sigma_y- sigma_xy * sigma_x) / t;
		*c = 1;
	}
}

int _CRChainCodeGetLengthBetweenTwoElements(CRChainCodeElement *start, CRChainCodeElement *head, CRChainCodeElement *terminater) {
	int length = 0;
	CRChainCodeElement *p = start;
	while(p) {
		if (p == head)
			break;
		if (p == terminater) {
			break;
		}
		length++;
		p = p->next;
	}
	return length;
}

BOOL _CRChainCodeCheckEdgeLength(CRChainCode *source, CRChainCodeElement *firstCorner, CRChainCodeElement *secondCorner, CRChainCodeElement *thirdCorner, CRChainCodeElement *fourthCorner, int *lengthes) {
	
	int maxLength = 0;
	int minLength = 0;
	
	// calculate first edge
	lengthes[0] = _CRChainCodeGetLengthBetweenTwoElements(firstCorner->next, firstCorner, secondCorner);
	if (lengthes[0] == 0)
		return CR_FALSE;
	
	maxLength = lengthes[0];
	minLength = lengthes[0];
	
	// calculate second edge
	lengthes[1] = _CRChainCodeGetLengthBetweenTwoElements(secondCorner->next, secondCorner, thirdCorner);
	if (lengthes[1] == 0)
		return CR_FALSE;
	
	if (maxLength < lengthes[1])
		maxLength = lengthes[1];
	
	if (minLength > lengthes[1])
		minLength = lengthes[1];
	
	// calculate third edge
	lengthes[2] = _CRChainCodeGetLengthBetweenTwoElements(thirdCorner->next, thirdCorner, fourthCorner);
	if (lengthes[2] == 0)
		return CR_FALSE;
	
	if (maxLength < lengthes[2])
		maxLength = lengthes[2];
	
	if (minLength > lengthes[2])
		minLength = lengthes[2];
	
	// calculate fourth edge
	lengthes[3] = _CRChainCodeGetLengthBetweenTwoElements(fourthCorner->next, fourthCorner, firstCorner);	
	if (lengthes[3] == 0)
		return CR_FALSE;
	
	if (maxLength < lengthes[3])
		maxLength = lengthes[3];
	
	if (minLength > lengthes[3])
		minLength = lengthes[3];
	
//	printf("%d %d %d %d\n", lengthes[0], lengthes[1], lengthes[2], lengthes[3]);
	
	return ((maxLength / minLength) < THRESHOLD_RATIO_OF_LONG_TO_SHORT_EDGE);
}

void _CRChainCodeDetectCorners(CRChainCode *p, int withLSM) {
	CRChainCodeElement *e = p->head;
	
	int maxLength = 0;
	CRChainCodeElement *firstCorner = p->head;
	CRChainCodeElement *secondCorner = NULL;
	CRChainCodeElement *thirdCorner = NULL;
	CRChainCodeElement *fourthCorner = NULL;
	
	if (e) {
		while (1) {
			int length = (p->head->x - e->x) * (p->head->x - e->x) + (p->head->y - e->y) * (p->head->y - e->y);
			if (length > maxLength) {
				maxLength = length;
				thirdCorner = e;
			}
			if (e->next == p->head)
				break;
			e = e->next;
		}
	}
	
	float a = 0;
	float b = 1;
	float c = 0;
	
	a = - (float)(thirdCorner->y - firstCorner->y) / (thirdCorner->x - firstCorner->x);
	b = 1;
	c = - a * firstCorner->x - firstCorner->y;
		
		 
	float length = 0;
	e = p->head;
	if (e) {
		while (1) {
			float temp = fabs(a * e->x + b * e->y + c);
			if (temp > length) {
				length = temp;
				secondCorner = e;
			}
			if (e->next == thirdCorner)
				break;
			e = e->next;
		}
	}
	
	length = 0;
	e = thirdCorner;
	if (e) {
		while (1) {
			float temp = fabs(a * e->x + b * e->y + c);
			if (temp > length) {
				length = temp;
				fourthCorner = e;
			}
			if (e->next == firstCorner)
				break;
			e = e->next;
		}
	}
	
	if (!firstCorner || !secondCorner || !thirdCorner || !fourthCorner) {
		p->isCornerDetected = CR_FALSE;
		return;
	}
	
	int lengthes[4];
	memset(lengthes, 0, sizeof(lengthes));
	if (!_CRChainCodeCheckEdgeLength(p, firstCorner, secondCorner, thirdCorner, fourthCorner, lengthes)) {
		p->isCornerDetected = CR_FALSE;
		return;
	}
	
	if (withLSM == CR_FALSE) {
		p->cornersX[0] = firstCorner->x;
		p->cornersY[0] = firstCorner->y;
		
		p->cornersX[1] = secondCorner->x;
		p->cornersY[1] = secondCorner->y;
		
		p->cornersX[2] = thirdCorner->x;
		p->cornersY[2] = thirdCorner->y;
		
		p->cornersX[3] = fourthCorner->x;
		p->cornersY[3] = fourthCorner->y;
		
		p->isCornerDetected = CR_TRUE;
		return;
	}
	
	// least squares method
	float al[4];
	float bl[4];
	float cl[4];
	int n[4];
	
	_CRGetLineThroughPointsOnEdge(al+0, bl+0, cl+0, n+0, firstCorner, secondCorner);
	_CRGetLineThroughPointsOnEdge(al+1, bl+1, cl+1, n+1, secondCorner, thirdCorner);
	_CRGetLineThroughPointsOnEdge(al+2, bl+2, cl+2, n+2, thirdCorner, fourthCorner);
	_CRGetLineThroughPointsOnEdge(al+3, bl+3, cl+3, n+3, fourthCorner, firstCorner);
	
	_CRGetIntersectionBetweenTwoLines(al+0, bl+0, cl+0, al+1, bl+1, cl+1, &p->cornersX[1], &p->cornersY[1]);
	_CRGetIntersectionBetweenTwoLines(al+1, bl+1, cl+1, al+2, bl+2, cl+2, &p->cornersX[2], &p->cornersY[2]);
	_CRGetIntersectionBetweenTwoLines(al+2, bl+2, cl+2, al+3, bl+3, cl+3, &p->cornersX[3], &p->cornersY[3]);
	_CRGetIntersectionBetweenTwoLines(al+3, bl+3, cl+3, al+0, bl+0, cl+0, &p->cornersX[0], &p->cornersY[0]);
	
	float v0x = p->cornersX[0] - p->cornersX[3];
	float v0y = p->cornersY[0] - p->cornersY[3];
	
	float v1x = p->cornersX[1] - p->cornersX[0];
	float v1y = p->cornersY[1] - p->cornersY[0];
	
	float v2x = p->cornersX[2] - p->cornersX[1];
	float v2y = p->cornersY[2] - p->cornersY[1];
	
	float v3x = p->cornersX[3] - p->cornersX[2];
	float v3y = p->cornersY[3] - p->cornersY[2];
	
	float z0 = v0x * v1y - v1x * v0y;
	float z1 = v1x * v2y - v2x * v1y;
	float z2 = v2x * v3y - v3x * v2y;
	float z3 = v3x * v0y - v0x * v3y;
	
	int f = 0;
	if (z0 < 0)
		f++;
	if (z1 < 0)
		f++;
	if (z2 < 0)
		f++;
	if (z3 < 0)
		f++;
	
	if (f==4)
		p->isCornerDetected = CR_TRUE;
}

#pragma mark - Corner detection method

void CRChainCodeStorageDetectCornerWithLSM(CRChainCodeStorage *storage) {
	CRChainCode *p = storage->head;
	if (p) {
		while (1) {
			_CRChainCodeDetectCorners(p, CR_TRUE);
			if (p->next == NULL)
				break;
			p = p->next;
		}
	}
}

void CRChainCodeStorageDetectCornerWithoutLSM(CRChainCodeStorage *storage) {
	CRChainCode *p = storage->head;
	if (p) {
		while (1) {
			_CRChainCodeDetectCorners(p, CR_FALSE);
			if (p->next == NULL)
				break;
			p = p->next;
		}
	}
}