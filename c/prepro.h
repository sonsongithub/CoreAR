/*
 * Core AR
 * prepro.h
 *
 * Copyright (c) Yuichi YOSHIDA, 11/01/17.
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

#define CR_TRUE		1
#define CR_FALSE	0

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// application setting
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#define DEFAULT_DECODE_PIXEL_BUFFER_WIDTH_HEIGHT	96
#define DEFAULT_DECODE_PIXEL_BUFFER_SIZE			9216

// show status inside chaincode algorithm
// #define USE_INSIDE_CHAINCODE

// show input image when chaincode algorithm finds error
// #define OUTPUT_IMAGE_FOR_DEBUG_WHEN_ERROR

// show chaincode result
//#define PRINT_CHAIN_CODE

// show corner detecting
//#define PRINT_CORNER_DETECT_LOG

// buffer size of decode image
//#define DECODE_PIXEL_BUFFER				96
//#define DECODE_PIXEL_BUFFER_SIZE		9216

// save code image to decode 2d code, into code info struct.
// #define SAVE_CODE_IMAGE

// show message aboute code decoding process.
// #define DEBUG_CODE_CALCULATION

// show debug message about template matching
//#define DEBUG_TEMPLATE_MATCHING