/*
 * Core AR
 * codeCropping.cpp
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

#include "codeCropping.h"

#include "CoreAR.h"
#include "CRTest.h"

#include <jpeglib.h>

#define JPEG_PATH "/Users/sonson/code/CoreAR.framework/c++/UnitTest/CoreARUnitTest/Test/%s"

// prototype
void binarize(unsigned char *pixel, int width, int height, int threshold);
unsigned char getY(unsigned char *p);
int read_jpeg(char *filename, unsigned char **pixel, int *width, int *height);
int write_jpeg(char *filename, unsigned char *pixel, int width, int height);

// help functions
unsigned char getY(unsigned char *p) {
	int  y =
	((306 * (int)(*(p+0)) + 512 ) >> 10)
	+ ((601 * (int)(*(p+1)) + 512 ) >> 10)
	+ ((117 * (int)(*(p+2)) + 512 ) >> 10);
	
	if (y < 0x00)  y = 0x00;
	if (y > 0xFF)  y = 0xFF;
	return  y;
}

int write_jpeg(char *filename, unsigned char *pixel, int width, int height) {	
	struct jpeg_compress_struct cinfo;
	struct jpeg_error_mgr jerr;
	FILE *outfile;
	
	cinfo.err = jpeg_std_error( &jerr );
	jpeg_create_compress( &cinfo );
	
	outfile = fopen( "/tmp/a.jpg", "wb" );
	jpeg_stdio_dest( &cinfo, outfile );
	
	cinfo.image_width = width;
	cinfo.image_height = height;
	cinfo.input_components = 1;
	cinfo.in_color_space = JCS_GRAYSCALE;
	
	jpeg_set_defaults(&cinfo);
	jpeg_start_compress(&cinfo, TRUE);
	
	// copy buffer per a line.
	JSAMPARRAY buffer = (*cinfo.mem->alloc_sarray)((j_common_ptr) &cinfo, JPOOL_IMAGE, width * 1, 1);
	for (int i = 0; i < height; i++ ) {
		memcpy(buffer[0], pixel + i * width * 1, width * 1);
		jpeg_write_scanlines( &cinfo, buffer, 1 );
	}
	
	jpeg_finish_compress(&cinfo);
	jpeg_destroy_compress(&cinfo);
	fclose(outfile);
	
	return 0;
}

int read_jpeg(char *filename, unsigned char **pixel, int *width, int *height) {
	struct jpeg_error_mgr pub;
	struct jpeg_decompress_struct cinfo;
	
	FILE *infile = fopen(filename, "rb" );
	
	cinfo.err = jpeg_std_error(&pub);
	
	jpeg_create_decompress(&cinfo);
	jpeg_stdio_src( &cinfo, infile );
	jpeg_read_header(&cinfo, TRUE);
	jpeg_start_decompress(&cinfo);
	
	int row_stride = cinfo.output_width * cinfo.output_components;
	
	
	JSAMPARRAY buffer = (*cinfo.mem->alloc_sarray)((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);
	
	unsigned char *image_buffer = (unsigned char *)malloc( cinfo.image_height * cinfo.image_width * 3 );
	
	while (cinfo.output_scanline < cinfo.output_height) {
		jpeg_read_scanlines(&cinfo, buffer, 1);
		memcpy( image_buffer+cinfo.image_width*3*(cinfo.output_scanline-1), buffer[0], cinfo.image_width*3 );
	}
	
	jpeg_finish_decompress(&cinfo);
	
	jpeg_destroy_decompress(&cinfo);
	
	fclose(infile);
	
	unsigned char *output = (unsigned char*)malloc(sizeof(unsigned char) * cinfo.image_width * cinfo.image_height);
	
	for(int y = 0; y < cinfo.image_height; y++)
		for(int x = 0; x < cinfo.image_width; x++)
			*(output + x + y * cinfo.image_width) = getY(image_buffer + 3 * x + y * cinfo.image_width * 3);
	
	*width = cinfo.image_width;
	*height = cinfo.image_height;
	*pixel = output;
	
	free(image_buffer);
	
	return 0;
}

void binarize(unsigned char *pixel, int width, int height, int threshold) {
	for(int y = 0; y < height; y++)
		for(int x = 0; x < width; x++)
			*(pixel + x + y * width) = (*(pixel + x + y * width) < threshold) ? 1 : 0;
}

void codeCropping_test() {
	printf("=================================================>Code cropping test\n");
	
	char filename[1024];
	
	sprintf(filename, JPEG_PATH, "001.jpg");
	
	unsigned char *grayPixel = NULL;
	int width = 0;
	int height = 0;
	read_jpeg(filename, &grayPixel, &width, &height);
	
	unsigned char *source = (unsigned char*)malloc(sizeof(unsigned char) * width * height);
	
	memcpy(source, grayPixel, width * height);
	
	binarize(grayPixel, width, height, 100);
	
	CRChainCode *chaincode = new CRChainCode();
	
	float focal = 650;
	float codeSize = 1;
	
	int croppingSize = 64;
	
	chaincode->parsePixel(grayPixel, width, height);
	
	if (!chaincode->blobs->empty()) {
		CRChainCodeBlob *blob = chaincode->blobs->front();
		CRCode *code = blob->code();
		
		printf("Corners on the image.\n");
		code->dumpCorners();
		
		code->normalizeCornerForImageCoord(width, height, focal, focal);
		code->getSimpleHomography(codeSize);
		
		_tic();
		code->crop(croppingSize, croppingSize, focal, focal, source, width, height);
		printf("Cropping code image\n\t%0.5f[msec]\n\n", _tocWithoutLog());
		
		printf("Crop size %dx%d\n", croppingSize, croppingSize);
		
		write_jpeg(NULL, code->croppedCodeImage, code->croppedCodeImageWidth, code->croppedCodeImageHeight);
		
		SAFE_FREE(code);
	}
	SAFE_FREE(chaincode);
}