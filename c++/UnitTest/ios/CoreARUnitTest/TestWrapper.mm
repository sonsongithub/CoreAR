//
//  TestWrapper.m
//  CoreARUnitTest
//
//  Created by sonson on 11/09/16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TestWrapper.h"

#include "test.h"

@implementation TestWrapper

+ (void)test {
	chaincode_test();
	corner_test();
	homorgraphy_test();
	// codeCropping_test();
	rodrigues_test();
	levenbergMarquardt_test();
}

@end
