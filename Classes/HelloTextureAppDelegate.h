//
//  HelloTextureAppDelegate.h
//  HelloTexture
//
//  Created by turner on 5/26/09.
//  Copyright Douglass Turner Consulting 2009. All rights reserved.
//

@class GLViewController;

@interface HelloTextureAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow				*window;
	GLViewController		*controller;
}
@property (nonatomic, retain) IBOutlet         UIWindow	*window;
@property (nonatomic, retain) IBOutlet GLViewController	*controller;
@end
