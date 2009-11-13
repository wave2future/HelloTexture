//
//  GLViewController.h
//  HelloTexture
//
//  Created by turner on 5/26/09.
//  Copyright Douglass Turner Consulting 2009. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "GLView.h"

@class TEITexture;

@interface GLViewController : UIViewController  <GLViewDelegate> {
	TEITexture *_over_texture;
	TEITexture *_under_texture;
}

@property (nonatomic, retain) TEITexture *over_texture;
@property (nonatomic, retain) TEITexture *under_texture;

- (void)setupView:(GLView*)view;
- (void)drawView:(GLView*)view;

@end
