/*
 * Core AR
 * CRCommon.h
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

#ifdef _CR_COMMON_
#else
#define _CR_COMMON_

#ifdef _DEBUG
	#define _DPRINTF(...) printf(__VA_ARGS__)
#else
	#define _DPRINTF(...) //printf(__VA_ARGS__)
#endif

// safe release
#define SAFE_FREE(p)			if(p){free(p);p=NULL;}
#define SAFE_DELETE(p)			if(p){delete(p);p=NULL;}
#define SAFE_DELETE_ARRAY(p)	if(p){delete [] p;p=NULL;}

// static tic and toc methods

#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

static struct timeval _start, _end;

static void _tic(void);
static void _toc(void);

static void _tic() {
	gettimeofday(&_start, NULL);
}

static void _toc() {
	gettimeofday(&_end, NULL);
	long int e_sec = _end.tv_sec * 1000000 + _end.tv_usec;
	long int s_sec = _start.tv_sec * 1000000 + _start.tv_usec;
	printf( "%9.4lf[ms]\n", (double)(e_sec - s_sec) / 1000.0);
}

#endif