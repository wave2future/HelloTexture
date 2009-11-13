//
//  HelloTextureAppDelegate.m
//  HelloTexture
//
//  Created by turner on 5/26/09.
//  Copyright Douglass Turner Consulting 2009. All rights reserved.
//

#import "HelloTextureAppDelegate.h"
#import "GLViewController.h"

@implementation HelloTextureAppDelegate

@synthesize window;
@synthesize controller;

// The Stanford Patterm
- (void)dealloc {
	
    [controller release];
    [window release];
    [super dealloc];
}

// The Stanford Patterm
- (void)applicationDidFinishLaunching:(UIApplication *)application {

    [window addSubview:controller.view];
    [window makeKeyAndVisible];
}

@end
