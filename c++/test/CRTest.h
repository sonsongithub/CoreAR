/*
 * Core AR
 * CRTest.h
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

#include "CRHomogeneousVec3.h"

float getDifferenceBetweenVectors(CRHomogeneousVec3 *p1, CRHomogeneousVec3 *p2);
void _CRTestDumpPixel(unsigned char* pixel, int width, int height);
void _CRTestDumpMat(float matrix[4][4]);
void _CRTestDumpVec(float vec[4]);
void _CRTestMakeSimplePixelData(unsigned char **output_pixel, int *output_width, int *output_height);
void _CRTestMakePixelDataAndPMatrixWithProjectionSetting(float pMatrix[4][4], unsigned char **output_pixel, int width, int height, CRHomogeneousVec3* projected_corners, float focal, float xdeg, float ydeg, float zdeg, float xt, float yt, float zt);
void _CRTestMakePixelDataWithProjectionSetting(unsigned char **output_pixel, int width, int height, CRHomogeneousVec3* projected_corners, float focal, float xdeg, float ydeg, float zdeg, float xt, float yt, float zt);