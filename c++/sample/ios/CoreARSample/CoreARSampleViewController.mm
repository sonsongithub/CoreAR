//
//  CoreARSampleViewController.m
//  CoreARSample
//
//  Created by sonson on 11/09/18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CoreARSampleViewController.h"

#import "ARViewController.hpp"

@implementation CoreARSampleViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	ARViewController *con = [[ARViewController alloc] initWithCameraViewControllerType:(CameraViewControllerType)(BufferGrayColor|BufferSize480x360)];
	[self.view addSubview:con.view];
	[con.view setFrame:self.view.bounds];
	[con viewWillAppear:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
