CoreAR.framework
=======
![](http://sonson.jp/wp/wp-content/uploads/2011/04/coreARSample.png)

License
=======
[BSD License][].

App Store
=======
You can take the sample application "[CoreAR][]" from App Store.

Sample code in C++
=======

To be done.

Sample code in C
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
DENSO IT Laboratory, Inc. has supported my work. Thank you.

[CoreAR]: http://click.linksynergy.com/fs-bin/click?id=he6amglY4cw&subid=&offerid=94348.1&type=10&tmpid=3910&RD_PARM1=http%3A%2F%2Fitunes.apple.com%2Fus%2Fapp%2Fcorear%2Fid428844303%3Fmt%3D8%2526ls%3D1
[sonson.jp]: http://sonson.jp
[BSD License]: http://www.opensource.org/licenses/bsd-license.php
[Quartz Help Library]: https://github.com/sonsongithub/Quartz-Help-Library
[Real time image processing framework for iOS]: https://github.com/sonsongithub/iOSCameraImageProcessing