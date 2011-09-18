//
//  main.cpp
//  CoreARUnitTest
//
//  Created by sonson on 11/09/14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#include <iostream>

#include "test.h"

int main (int argc, const char * argv[]) {	
	
	// test for chain code algorithm
	chaincode_test();
	
	// test for corner detection
	corner_test();
	
	// test for estimation of homography matrix
	homorgraphy_test();
	
	// test for copping the image inside a code.
	codeCropping_test();
	
	// test for Rodrigues expression 
	rodrigues_test();
	
	// test for Levenberg-Marquardt algorithm
	levenbergMarquardt_test();
	
    return 0;
}