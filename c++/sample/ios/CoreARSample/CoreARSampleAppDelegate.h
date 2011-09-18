//
//  CoreARSampleAppDelegate.h
//  CoreARSample
//
//  Created by sonson on 11/09/18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CoreARSampleViewController;

@interface CoreARSampleAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet CoreARSampleViewController *viewController;

@end
