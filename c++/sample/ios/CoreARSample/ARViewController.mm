/*
 * Core AR
 * ARViewController.mm
 *
 * Copyright (c) Yuichi YOSHIDA, 11/09/20
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

#import "ARViewController.hpp"

#import "CoreAR.h"

#import "GLOverlayView.hpp"
#import "QuartzHelpLibrary.h"

@implementation ARViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// test image view
	cameraView = [[UIImageView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:cameraView];
	
	// code image
	codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(172, 312, 128, 128)];
	[self.view addSubview:codeImageView];
	
	if (codeListRef == NULL)
		codeListRef = new CRCodeList();
	
	// OpenGL overlaid content view
	myGLView = [[GLOverlayView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:myGLView];
	[myGLView release];
	[myGLView setCodeListRef:codeListRef];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	[super captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
	
	// image proccessing
	
	int width = (int)bufferSize.width;
	int height = (int)bufferSize.height;
	
	// do it
	if (chaincodeBuff == NULL)
		chaincodeBuff = (unsigned char*)malloc(sizeof(unsigned char) * width * height);
	
	if (cgimageBuff == NULL)
		cgimageBuff = (unsigned char*)malloc(sizeof(unsigned char) * width * height);
	
	
	int threshold = 80;
	
	// binarize for chain code
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			*(chaincodeBuff + x + y * width) = *(buffer + x + y * width) < threshold ? CRChainCodeFlagUnchecked : CRChainCodeFlagIgnore;
		}
	}
	
	// copy for preview
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			*(cgimageBuff + (height - 1 - y) + x * height) = *(chaincodeBuff + x + y * width) * 120;
		}
	}
	
	float focal = 650;
	float codeSize = 1;
	
	int croppingSize = 64;
	
	CRChainCode *chaincode = new CRChainCode();
	
	_tic();
	chaincode->parsePixel(chaincodeBuff, width, height);
	_toc();
	
	printf("blobs=%lu\n", chaincode->blobs->size());
	
	
	CRCodeList::iterator it = codeListRef->begin();
	while(it != codeListRef->end()) {
		SAFE_DELETE(*it);
		++it;
	}
	codeListRef->clear();
	
	if (!chaincode->blobs->empty()) {
		CRChainCodeBlob *blob = chaincode->blobs->front();
		printf("elements=%lu\n", blob->elements->size());
		CRCode *code = blob->code();
		
		if (code) {
			// get homography
			code->normalizeCornerForImageCoord(width, height, focal, focal);
			code->getSimpleHomography(codeSize);
			
			// cropping code image area
			code->crop(croppingSize, croppingSize, focal, focal, buffer, width, height);
			
			codeListRef->push_back(code);
			
			// draw code edge into preview buffer
			std::list<CRChainCodeElement*>::iterator it = blob->elements->begin();
			while(it != blob->elements->end()) {
				CRChainCodeElement* e = (CRChainCodeElement*)*it;
				*(cgimageBuff + (height - 1 - e->y) + e->x * height) = 255;
				++it;
			}
			
			// draw code image area
			CGImageRef output = CGImageCreateWithPixelBuffer(code->croppedCodeImage, code->croppedCodeImageWidth, code->croppedCodeImageHeight, 1, QH_PIXEL_GRAYSCALE);
			UIImage *image = [UIImage imageWithCGImage:output];
			[codeImageView setImage:image];
			[codeImageView.superview bringSubviewToFront:codeImageView];
			CGImageRelease(output);
			
			[myGLView drawView];
		}
	}
	
	CGImageRef cameraBuff = CGImageCreateWithPixelBuffer(cgimageBuff, height, width, 1, QH_PIXEL_GRAYSCALE);
	
	UIImage *image = [UIImage imageWithCGImage:cameraBuff];
	
	[cameraView setImage:image];
	
	CGImageRelease(cameraBuff);
	
	SAFE_DELETE(chaincode);
}

@end
