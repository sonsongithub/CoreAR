CoreAR.framework
=======
![](http://sonson.jp/wp/wp-content/uploads/2011/04/coreARSample.png)

Introduction and information
=======
CoreAR.framework is open source AR framework. You can make an AR application using visual code like ARToolKit using this framework. CoreAR.framework does not depend on the other computer vision library like OpenCV. Considered portability, this framework is written only C or C++. The pixel array of an image is passed to CoreAR.framework and then visual code's identification number, rotation and translation matrix are obtained from the image including a visual code. Image processing speed of this framework is about 15 fps on iPhone4.

Take notice that CoreAR.framework depends on [Quartz Help Library][] and [Real time image processing framework for iOS][]. You have to download these libraries and put on them at the path where CoreAR.framework has been installed.

License
=======
[BSD License][].

App Store
=======
You can take a sample application from [App Store][].

Sample code in C++
=======

	float codeSize = 1;
	int croppingSize = 64;
	int threshold = 100;
	int width = (int)bufferSize.width;
	int height = (int)bufferSize.height;

	// do it
	if (chaincodeBuff == NULL)
		chaincodeBuff = (unsigned char*)malloc(sizeof(unsigned char) * width * height);

	// binarize for chain code
	for (int y = 0; y < height; y++)
		for (int x = 0; x < width; x++)
			*(chaincodeBuff + x + y * width) = *(buffer + x + y * width) < threshold ? CRChainCodeFlagUnchecked : CRChainCodeFlagIgnore;

	// prepare to parse chain code
	CRChainCode *chaincode = new CRChainCode();
	chaincode->parsePixel(chaincodeBuff, width, height);

	// clear previous buffer
	CRCodeList::iterator it = codeListRef->begin();
	while(it != codeListRef->end()) {
		SAFE_DELETE(*it);
		++it;
	}
	codeListRef->clear();

	// reload detected codes
	if (!chaincode->blobs->empty()) {
		std::list<CRChainCodeBlob*>::iterator blobIterator = chaincode->blobs->begin();
		while(blobIterator != chaincode->blobs->end()) {
			if (!(*blobIterator)->isValid(width, height)) {
				blobIterator++;
				continue;
			}
			CRCode *code = (*blobIterator)->code();	
			if(code) {
				// estimate and optimize pose and position
				code->normalizeCornerForImageCoord(width, height, focalLength, focalLength);
				code->getSimpleHomography(codeSize);
				code->optimizeRTMatrinxWithLevenbergMarquardtMethod();
				
				// cropping code image area
				code->crop(croppingSize, croppingSize, focalLength, focalLength, codeSize, buffer, width, height);
				codeListRef->push_back(code);
			}
			blobIterator++;
		}
	}

Sample code in C (depracted)
=======

	// Copy image buffer from camera into "pixel".
	int width;
	int height;
	unsigned char *pixel = (unsigned char*)malloc(sizeof(unsigned char) * width * height);
	
	// codeInfoStorage receives the result of visual code recognition.
	CRCodeInfoStorage *codeInfoStorage = CRCreateCodeInfoStorage();
	
	// storage to save visual code templates.
	CRCodeImageTemplate *codeImageTemplateStorage = CRCreateCodeImageTemplateStorage();
	
	// make template to recognize visual codes.
	int c_width;
	int c_height;
	unsigned char *c_p = (unsigned char*)malloc(sizeof(unsigned char) * c_width * c_height);
	
	/* read images of visual codes you want to recognize */
	
	CRCodeImageTemplate *template = CRCreateCodeImageTemplate(c_p, c_width, c_height);
	template->code = codeNumber;
	template->size = codeSize;
	CRCodeImageTemplateStorageAddNewTemplate(codeImageTemplateStorage, template);
	free(c_p);
	
	// Start extraction
	CRChainCodeStorage *storage = CRCreateChainCodeStorageByParsingPixel(pixel, width, height);
	CRChainCodeStorageDetectCornerWithLSM(storage);
	CRCodeInfoStorageAddCodeInfoByExtractingFromChainCode(codeInfoStorage, storage, valueBuffer, width, height, codeImageTemplateStorage);
	
	// Release
	CRReleaseChainCodeStorage(&storage);
	CRReleaseCodeInfoStorage(&codeInfoStorage);
	free(pixel);

Frequently Asked Questions
=======
 * I can't compile CoreAR.framework...
   * Ans. CoreAR.framework depends on [Quartz Help Library][] and [Real time image processing framework for iOS][]. You have to download these libraries and put on them at the path where CoreAR.framework has been installed.
   
 * How do I render a 3D model on the code with CoreAR.framework?
   * Ans. CoreAR.framework does not support rendering any 3D model files. You have to write a code to render 3D model files with OpenGLES. Sample program does not render a cube and Utah teapot with 3D model files but with OpenGLES code.

Blog
=======
 * [sonson.jp][]
Sorry, Japanese only....

Dependency
=======
 * [Quartz Help Library][]
 * [Real time image processing framework for iOS][]
 
Acknowledgement
=======
 * [DENSO IT Laboratory, Inc.][] has supported my work.
 * There are some public projects supported by [DENSO IT Laboratory, Inc.][] in [cvlab.jp][].

[cvlab.jp]: http://cvlab.jp/
[DENSO IT Laboratory, Inc.]: http://www.d-itlab.co.jp/
[App Store]: http://click.linksynergy.com/fs-bin/click?id=he6amglY4cw&subid=&offerid=94348.1&type=10&tmpid=3910&RD_PARM1=http%3A%2F%2Fitunes.apple.com%2Fus%2Fapp%2Fcorear%2Fid428844303%3Fmt%3D8%2526ls%3D1
[sonson.jp]: http://sonson.jp
[BSD License]: http://www.opensource.org/licenses/bsd-license.php
[Quartz Help Library]: https://github.com/sonsongithub/Quartz-Help-Library
[Real time image processing framework for iOS]: https://github.com/sonsongithub/iOSCameraImageProcessing