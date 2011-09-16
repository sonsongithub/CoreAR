//
//  TestWrapper.m
//  CoreARUnitTest
//
//  Created by sonson on 11/09/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TestWrapper.h"

#import "QuartzHelpLibrary.h"
#include "CoreAR.h"
#include "test.h"


@implementation TestWrapper

+ (void)test {
	chaincode_test();
	corner_test();
	homorgraphy_test();
	rodrigues_test();
	levenbergMarquardt_test();
}

+ (CGImageRef)corner_test {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"001.jpg" ofType:nil];
	
	CGImageRef output = NULL;
	CGImageRef jpegImageRef = CGImageCreateWithPNGorJPEGFilePath((CFStringRef)path);
	
	unsigned char *pixel = NULL;
	unsigned char *source = NULL;
	int width = 0, height = 0, bytesPerPixel = 0;
	
	CGCreatePixelBufferWithImage(jpegImageRef, &pixel, &width, &height, &bytesPerPixel, QH_PIXEL_GRAYSCALE);
	
	int threshold = 100;
	
	source = (unsigned char*)malloc(sizeof(unsigned char) * width * height);
	
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			*(source + x + y * width) = *(pixel + x + y * width) < threshold ? CRChainCodeFlagUnchecked : CRChainCodeFlagIgnore;
		}
	}

	CRChainCode *chaincode = new CRChainCode();
	
	chaincode->parsePixel(source, width, height);
	
	float focal = 650;
	float codeSize = 1;
	
	int croppingSize = 64;
	
	if (!chaincode->blobs->empty()) {
		CRChainCodeBlob *blob = chaincode->blobs->front();
		CRCode *code = blob->code();
		
		printf("Corners on the image.\n");
		code->dumpCorners();
		
		code->normalizeCornerForImageCoord(width, height, focal, focal);
		code->getSimpleHomography(codeSize);
		
		_tic();
		code->crop(croppingSize, croppingSize, focal, focal, pixel, width, height);
		printf("Cropping code image\n\t%0.5f[msec]\n\n", _tocWithoutLog());
		
		output = CGImageCreateWithPixelBuffer(code->croppedCodeImage, code->croppedCodeImageWidth, code->croppedCodeImageHeight, 1, QH_PIXEL_GRAYSCALE);
		

		printf("Crop size %dx%d\n", croppingSize, croppingSize);
		
		SAFE_DELETE(code);
	}
	SAFE_FREE(chaincode);
	SAFE_FREE(pixel);
	SAFE_FREE(source);
	
	CGImageRelease(jpegImageRef);
	
	return output;
}

@end
