//
//  CoreARSampleViewController.m
//  CoreARSample
//
//  Created by sonson on 11/09/17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CoreARSampleViewController.h"

#import "CameraViewController.h"

@implementation CoreARSampleViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	CameraViewController *con = [[CameraViewController alloc] initWithNibName:nil bundle:nil];
	
	[self.view addSubview:con.view];
	[con.view setFrame:self.view.bounds];
	
//	[self presentModalViewController:con animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
