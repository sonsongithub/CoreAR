//
//  ARViewController.m
//  CoreARSample
//
//  Created by sonson on 11/09/18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ARViewController.h"

#import "CoreAR.h"

#import "QuartzHelpLibrary.h"

@implementation ARViewController

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
	
	if (!chaincode->blobs->empty()) {
		CRChainCodeBlob *blob = chaincode->blobs->front();
		printf("elements=%lu\n", blob->elements->size());
		CRCode *code = blob->code();
		
		if (code) {
			
			std::list<CRChainCodeElement*>::iterator it = blob->elements->begin();
			while(it != blob->elements->end()) {
				CRChainCodeElement* e = (CRChainCodeElement*)*it;
				*(cgimageBuff + (height - 1 - e->y) + e->x * height) = 255;
				++it;
			}
			
			code->normalizeCornerForImageCoord(width, height, focal, focal);
			code->getSimpleHomography(codeSize);
			
			_tic();
			code->crop(croppingSize, croppingSize, focal, focal, buffer, width, height);
			printf("Cropping code image\n\t%0.5f[msec]\n\n", _tocWithoutLog());
			
			CGImageRef output = CGImageCreateWithPixelBuffer(code->croppedCodeImage, code->croppedCodeImageWidth, code->croppedCodeImageHeight, 1, QH_PIXEL_GRAYSCALE);
			
			printf("w=%lu\n", CGImageGetWidth(output));
			
			UIImage *image = [UIImage imageWithCGImage:output];
			
			[imageView setImage:image];
			[imageView.superview bringSubviewToFront:imageView];
			
			CGImageRelease(output);
			
			SAFE_DELETE(code);
		}
	}
	
	CGImageRef cameraBuff = CGImageCreateWithPixelBuffer(cgimageBuff, height, width, 1, QH_PIXEL_GRAYSCALE);
	
	UIImage *image = [UIImage imageWithCGImage:cameraBuff];
	
	[cameraView setImage:image];
	
	CGImageRelease(cameraBuff);
	
	SAFE_DELETE(chaincode);
}

@end
