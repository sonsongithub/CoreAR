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
	
	chaincode_test();
	corner_test();
	homorgraphy_test();
	codeCropping_test();
	rodrigues_test();
	levenbergMarquardt_test();
	
    return 0;
}

