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

static float focalLength = 457.89;

@implementation ARViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

#ifdef _SHOW_DEBUG_BINARIZED_CAMERA_IMAGE	
	// test image view
	cameraView = [[UIImageView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:cameraView];
#endif
#ifdef _SHOW_DEBUG_CROPPING_CODE
	// code image
	codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(172, 312, 128, 128)];
	[self.view addSubview:codeImageView];
#endif	
	
	if (codeListRef == NULL)
		codeListRef = new CRCodeList();
	
	// OpenGL overlaid content view
	CGRect r = self.view.frame;
	r.size.height = 426;
	myGLView = [[GLOverlayView alloc] initWithFrame:r];
	[myGLView setCameraFrameSize:CGSizeMake(480, 360)];
	[myGLView setupOpenGLViewWithFocalX:focalLength focalY:focalLength];
	[myGLView startAnimation];
	[self.view addSubview:myGLView];
	[myGLView release];
	[myGLView setCodeListRef:codeListRef];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	_tic();
	
	[super captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
	
	int width = (int)bufferSize.width;
	int height = (int)bufferSize.height;
	
	// do it
	if (chaincodeBuff == NULL)
		chaincodeBuff = (unsigned char*)malloc(sizeof(unsigned char) * width * height);
	
#ifdef _SHOW_DEBUG_BINARIZED_CAMERA_IMAGE
	if (cgimageBuff == NULL)
		cgimageBuff = (unsigned char*)malloc(sizeof(unsigned char) * width * height);
#endif	
	
	int threshold = 100;
	
	// binarize for chain code
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			*(chaincodeBuff + x + y * width) = *(buffer + x + y * width) < threshold ? CRChainCodeFlagUnchecked : CRChainCodeFlagIgnore;
		}
	}
	
#ifdef _SHOW_DEBUG_BINARIZED_CAMERA_IMAGE
	// copy for preview
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			*(cgimageBuff + (height - 1 - y) + x * height) = *(chaincodeBuff + x + y * width) * 120;
		}
	}
#endif
	
	float codeSize = 1;
	
	int croppingSize = 64;
	
	CRChainCode *chaincode = new CRChainCode();
	
	chaincode->parsePixel(chaincodeBuff, width, height);
	
	CRCodeList::iterator it = codeListRef->begin();
	while(it != codeListRef->end()) {
		SAFE_DELETE(*it);
		++it;
	}
	codeListRef->clear();
	
	if (!chaincode->blobs->empty()) {

		std::list<CRChainCodeBlob*>::iterator blobIterator = chaincode->blobs->begin();
		while(blobIterator != chaincode->blobs->end()) {
			
			if (!(*blobIterator)->isValid(width, height)) {
				blobIterator++;
				continue;
			}
			
			CRCode *code = (*blobIterator)->code();
				
			if(code) {
				
				// get homography
				//code->dumpCorners();
				
				code->normalizeCornerForImageCoord(width, height, focalLength, focalLength);
				
				code->getSimpleHomography(codeSize);
				
				//code->_CRGetHomographyMatrix();
				
				code->optimizeRTMatrinxWithLevenbergMarquardtMethod();
				
				//code->dumpHomography();
				//code->dumpMatrix();
				//code->dumpOptimizedMatrix();
				
				// cropping code image area
				code->crop(croppingSize, croppingSize, focalLength, focalLength, codeSize, buffer, width, height);
				
#ifdef _SHOW_DEBUG_CROPPING_CODE
				// draw code image area
				CGImageRef output = CGImageCreateWithPixelBuffer(code->croppedCodeImage, code->croppedCodeImageWidth, code->croppedCodeImageHeight, 1, QH_PIXEL_GRAYSCALE);
				UIImage *image = [UIImage imageWithCGImage:output];
				[codeImageView setImage:image];
				[codeImageView.superview bringSubviewToFront:codeImageView];
				CGImageRelease(output);
#endif
				codeListRef->push_back(code);

#ifdef _SHOW_DEBUG_BINARIZED_CAMERA_IMAGE
				// draw code edge into preview buffer
				std::list<CRChainCodeElement*>::iterator elementIterator = (*blobIterator)->elements->begin();
				while(elementIterator != (*blobIterator)->elements->end()) {
					CRChainCodeElement* e = (CRChainCodeElement*)*elementIterator;
					*(cgimageBuff + (height - 1 - e->y) + e->x * height) = 255;
					elementIterator++;
				}
#endif
			}
			
			blobIterator++;
		}
	}
	
	[myGLView drawView];

#ifdef _SHOW_DEBUG_BINARIZED_CAMERA_IMAGE
	CGImageRef cameraBuff = CGImageCreateWithPixelBuffer(cgimageBuff, height, width, 1, QH_PIXEL_GRAYSCALE);
	UIImage *image = [UIImage imageWithCGImage:cameraBuff];
	[cameraView setImage:image];
	CGImageRelease(cameraBuff);
#endif
	
	SAFE_DELETE(chaincode);
	_toc();
}

@end
